import { readFileSync } from 'node:fs';
import { basename, isAbsolute, join, relative, resolve, sep } from 'node:path';
import { canonicalJson } from '../lib/canonical_json.mjs';
import { validate } from '../lib/mini_schema.mjs';
import { readJson } from '../lib/repo.mjs';
import { PLAN_SCHEMA } from './tune_propose.mjs';
import { atomicWrite, clamped, digest, git, inventory, numericSlot, readBaseline } from './tune_state.mjs';

// Label the night by its morning. A batch run on both sides of midnight gets one allowance.
export const nightOf = (time = Date.now()) => new Date(time + 12 * 3600_000).toISOString().slice(0, 10);
export const planId = (plan) => digest(canonicalJson(plan));

export function checkPlan(plan) {
  if (plan?.schema !== PLAN_SCHEMA || !Array.isArray(plan.changes) || !Number.isSafeInteger(plan.max)
    || plan.max < 0 || plan.changes.length > plan.max || !/^[a-f0-9]{64}$/.test(plan.batch_sha256))
    throw new Error('invalid tuner plan');
  const seen = new Set();
  for (const c of plan.changes) {
    if (!c || typeof c.id !== 'string' || !c.id || seen.has(c.id) || !c.miss || /[\r\n\0]/.test(c.miss)
      || typeof c.miss !== 'string' || ![c.before, c.after, c.baseline].every(Number.isFinite)
      || !['wave', 'killer', 'spread', 'offer'].includes(c.metric?.type) || !Number.isFinite(c.metric.target))
      throw new Error('invalid or duplicate change: ' + c?.id);
    seen.add(c.id);
  }
}

export function ownBranch(root) {
  if (!git(root, 'branch', '--show-current').trim().startsWith('n22-tune'))
    throw new Error('tuner applies only on its own branch');
}

function clean(root, artifacts = []) {
  ownBranch(root);
  const outputs = artifacts.map((file) => relative(root, resolve(file))).filter((file) =>
    file && !isAbsolute(file) && file !== '..' && !file.startsWith('..' + sep));
  const exclude = outputs.map((file) => ':(exclude,top,literal)' + file.split(sep).join('/'));
  const status = git(root, 'status', '--short', '-z', '--no-renames', '--untracked-files=all', '--', '.',
    ':(exclude)evidence/**', ':(exclude)build/**', ...exclude);
  if (status) throw new Error('dirty tree outside evidence/ and build/: ' + status.split('\0')[0]);
}

function history(root, trailer, value) {
  const parts = git(root, 'log', '-z', '--format=%H%x00%B', '--fixed-strings', '--grep=' + trailer + ': ' + value).split('\0');
  const receipts = new Map();
  for (let i = 0; i + 1 < parts.length; i += 2) {
    const lines = parts[i + 1].trimEnd().split('\n');
    const knob = lines.at(-1)?.match(/^Gauntlet-Knob: (\S+)$/)?.[1];
    if (knob && lines.includes(trailer + ': ' + value) && !receipts.has(knob)) receipts.set(knob, parts[i]);
  }
  return receipts;
}

export const nightly = (root) => history(root, 'Gauntlet-Night', nightOf());
export const commitsFor = (root, plan) => history(root, 'Gauntlet-Plan', planId(plan));

export const revertFor = (root, sha) => sha && git(root, 'log', '-1', '--format=%H', '--fixed-strings',
  '--grep=This reverts commit ' + sha + '.').trim() || null;

// Lossy UTF-8 decoding could otherwise make distinct byte sequences compare equal.
const decoder = new TextDecoder('utf-8', { fatal: true, ignoreBOM: true });
const tableText = (path) => decoder.decode(readFileSync(path));

function edit(text, knob, before, after, schema) {
  const table = JSON.parse(text);
  if (canonicalJson(table) !== text) throw new Error(knob.file + ': canonical round-trip changed bytes');
  const slot = numericSlot(table, knob);
  if (!slot || slot.parent[slot.key] !== before) throw new Error('stale or unresolved knob: ' + knob.id);
  slot.parent[slot.key] = after;
  const errors = validate(schema, table);
  if (errors.length) throw new Error(knob.file + ': ' + errors.join(', '));
  return canonicalJson(table);
}

function schemaOf(root, knob) {
  return readJson(join(root, 'project/data/schemas', basename(knob.file, '.json') + '.schema.json'));
}

function preflight(root, plan, receipts) {
  const { entries, skipped } = inventory(root);
  const baseline = readBaseline(root);
  const used = nightly(root);
  const inputs = new Map(), writes = [];
  for (const change of plan.changes) {
    const { id, before, after } = change;
    if (skipped.has(id)) continue;
    const entry = entries.get(id);
    if (!entry) throw new Error('knob unavailable: ' + id);
    const { knob, value } = entry;
    if (change.file !== knob.file || change.pointer !== knob.pointer) throw new Error('plan differs from knob catalog: ' + id);
    const first = baseline.values[id];
    if (first !== change.baseline || !Number.isFinite(first)) throw new Error('baseline mismatch: ' + id);
    if (receipts.has(id) && value === after) continue;
    if (used.has(id)) throw new Error('knob already tuned this night: ' + id);
    if (receipts.has(id) || value !== before) throw new Error('stale plan: ' + id);
    if (before === after || clamped(knob, before, first, after) !== after) throw new Error('outside tuner bounds: ' + id);
    const file = knob.file, path = join(root, file);
    git(root, 'ls-files', '--error-unmatch', '--', file);
    const prior = inputs.get(file) ?? tableText(path);
    const schema = schemaOf(root, knob);
    const next = edit(prior, knob, before, after, schema);
    inputs.set(file, next);
    writes.push({ change, file, path, prior, next, schema });
  }
  return writes;
}

export function applyPlan(root, plan) {
  clean(root);
  checkPlan(plan);
  const hash = planId(plan), receipts = commitsFor(root, plan);
  const writes = preflight(root, plan, receipts);
  for (const { change, file, path, prior, next, schema } of writes) {
    clean(root);
    if (tableText(path) !== prior) throw new Error('table changed since preflight: ' + file);
    const head = git(root, 'rev-parse', 'HEAD').trim();
    const { id, before, after, miss } = change;
    const title = 'tune(n22): ' + id + ' ' + before + ' -> ' + after + ': ' + miss;
    atomicWrite(path, next);
    try {
      const errors = validate(schema, readJson(path));
      if (errors.length) throw new Error(file + ': ' + errors.join(', '));
      git(root, 'add', '--', file);
      git(root, 'commit', '--only', '-m', title, '-m', 'Gauntlet-Plan: ' + hash + '\nGauntlet-Night: '
        + nightOf() + '\nGauntlet-Knob: ' + id, '--', file);
    } catch (err) {
      // Restore only our failed edit. Preserve other staged files and any concurrent edit.
      if (tableText(path) === next && git(root, 'rev-parse', 'HEAD').trim() === head)
        git(root, 'restore', '--source=HEAD', '--staged', '--worktree', '--', file);
      throw err;
    }
    receipts.set(id, git(root, 'rev-parse', 'HEAD').trim());
  }
  return receipts;
}

function verifyCommit(root, sha, knob, change) {
  const files = git(root, 'diff-tree', '--no-commit-id', '--name-only', '--no-renames', '-r', sha).trim();
  if (files !== knob.file) throw new Error('unexpected paths in tuner commit ' + sha);
  const original = git(root, 'show', sha + '^:' + knob.file);
  const expected = edit(original, knob, change.before, change.after, schemaOf(root, knob));
  if (expected !== git(root, 'show', sha + ':' + knob.file)) throw new Error('unexpected edits in tuner commit ' + sha);
}

function undoCommit(root, change, knob) {
  const path = join(root, knob.file);
  const expected = edit(tableText(path), knob, change.after, change.before, schemaOf(root, knob));
  try { git(root, 'revert', '--no-edit', change.commit); }
  catch (err) {
    let reverting;
    try { reverting = git(root, 'rev-parse', '--verify', 'REVERT_HEAD').trim(); } catch { /* revert did not start */ }
    if (reverting !== change.commit) throw err;
    try {
      // Adjacent JSON numbers can conflict textually. The verified single-slot inverse above
      // preserves every other value, including kept changes made after this commit.
      if (git(root, 'diff', '--name-only', '--diff-filter=U').trim() !== knob.file) throw err;
      atomicWrite(path, expected);
      git(root, 'add', '--', knob.file);
      git(root, '-c', 'core.editor=true', 'revert', '--continue');
    } catch (failure) {
      git(root, 'revert', '--abort');
      throw failure;
    }
  }
}

export function revertChanges(root, ledger, save, artifacts) {
  clean(root, artifacts);
  const rejected = [...ledger.changes].reverse().filter((c) => c.verdict !== 'kept');
  const { entries } = inventory(root);
  const undo = [];
  for (const change of rejected) {
    const { id, commit } = change, entry = entries.get(id);
    if (!commit || change.revert_commit) continue; // Skipped, interrupted or already undone.
    if (!entry || entry.value !== change.after) throw new Error('knob has changed since apply: ' + id);
    verifyCommit(root, commit, entry.knob, change);
    undo.push(change);
  }
  save();
  for (const change of undo) {
    clean(root, artifacts);
    // git revert needs a clean index. Keep the operator's staged evidence out of its commit.
    if (git(root, 'diff', '--cached', '--name-only').trim()) throw new Error('git revert needs a clean index');
    undoCommit(root, change, entries.get(change.id).knob);
    change.revert_commit = git(root, 'rev-parse', 'HEAD').trim();
    save();
  }
}
