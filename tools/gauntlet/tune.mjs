#!/usr/bin/env node
import { existsSync, readFileSync } from 'node:fs';
import { dirname, join, relative, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { parseArgs } from 'node:util';
import { canonicalJson } from '../lib/canonical_json.mjs';
import { readJson } from '../lib/repo.mjs';
import { PROFILES } from './contract.mjs';
import { loadBatch } from './report.mjs';
import { fmt } from './report_tables.mjs';
import { confirmChange, pairRuns } from './tune_confirm.mjs';
import { applyPlan, checkPlan, commitsFor, nightly, nightOf, ownBranch, planId, revertChanges, revertFor } from './tune_git.mjs';
import { PLAN_SCHEMA, propose } from './tune_propose.mjs';
import { atomicWrite, BASELINE, digest, ensureBaseline, git, inventory, withLock } from './tune_state.mjs';

const hashFile = (file) => digest(readFileSync(file));
const LEDGER = 'gtai.gauntlet-tune-ledger/1';

function options(argv, required, optional, flags = []) {
  const strings = [...required, ...optional].map((key) => [key, { type: 'string' }]);
  const booleans = flags.map((key) => [key, { type: 'boolean' }]);
  const { values } = parseArgs({ args: argv, options: Object.fromEntries([...strings, ...booleans]) });
  for (const key of required) if (!values[key]) throw new Error('--' + key + ' is required');
  return values;
}

function artifact(root, file) {
  const name = relative(root, resolve(file)).replaceAll('\\', '/').toLowerCase();
  if (name === BASELINE) throw new Error('tuner baseline is write-once');
  if (/^(project|tools|\.git|\.githooks)\//.test(name)) throw new Error('choose an artifact output outside ' + name.split('/')[0]);
}

function writePlan(root, v) {
  const target = Number(v['target-s'] ?? 15), profile = v.profile ?? 'average';
  const max = Number(v.max ?? 6), killerShare = Number(v['killer-share'] ?? 0.5);
  if (!(target > 0 && Number.isFinite(target))) throw new Error('--target-s must be positive');
  if (![...PROFILES, 'human'].includes(profile)) throw new Error('unknown profile ' + profile);
  if (!Number.isSafeInteger(max) || max < 0) throw new Error('--max must be a nonnegative integer');
  if (!(killerShare > 0 && killerShare < 1)) throw new Error('--killer-share must be between 0 and 1');
  artifact(root, v.out);
  if (!v.out.toLowerCase().endsWith('.json')) throw new Error('--out must name a JSON file');
  if (existsSync(v.out) && readJson(v.out).schema !== PLAN_SCHEMA) throw new Error('refusing to replace a non-plan: ' + v.out);
  const batch = loadBatch(v.batch);
  const state = inventory(root);
  const baseline = ensureBaseline(root, state.entries);
  const plan = propose(batch, state, baseline, { target, profile, max, killerShare, batchHash: hashFile(v.batch),
    night: nightOf(), used: new Set(nightly(root).keys()) });
  atomicWrite(v.out, canonicalJson(plan));
  for (const c of plan.changes) console.log(c.miss + ': ' + c.id + ' ' + c.before + ' -> ' + c.after);
  console.log(plan.changes.length + ' changes from ' + plan.misses.length + ' measured misses in ' + v.out);
  return plan;
}

const cell = (s) => String(s).replaceAll('|', '\\|').replace(/[\r\n]+/g, ' ');
function markdown(ledger) {
  const lines = ['# Gauntlet tune ledger', '', 'Plan ' + ledger.plan_sha256 + '. Matched ' + ledger.matched_runs + ' of '
    + ledger.before_runs + ' before and ' + ledger.after_runs + ' after runs.', '',
    'Positive improvement means the measured miss shrank. An empty apply SHA means this branch has no commit for that edit. A revert SHA records an executed undo.', '',
    '| Knob | Before → after | Baseline | Measured miss | Confirmation before → after | Pairs | Improvement (CI95) | A/A floor (pairs) | Verdict | Apply / revert SHA |',
    '|---|---:|---:|---|---:|---:|---:|---:|---|---|'];
  for (const c of ledger.changes) {
    const unit = { wave: 's', spread: 'waves', killer: 'death share', offer: c.metric.outcome === 'seconds' ? 's' : 'waves' }[c.metric.type];
    lines.push('| ' + [c.id, c.before + ' → ' + c.after, c.baseline, c.miss,
      fmt(c.measured_before) + ' → ' + fmt(c.measured_after) + ' ' + unit, c.pairs,
      fmt(c.improvement) + ' (' + c.ci95.map(fmt).join(' to ') + ')', fmt(c.floor) + ' (' + c.aa_pairs + ')',
      c.verdict, [c.commit, c.revert_commit].filter(Boolean).join(' / ') || '—'].map(cell).join(' | ') + ' |');
  }
  if (!ledger.changes.length) lines.push('', 'The plan contained no changes.');
  return lines.join('\n') + '\n';
}

function confirmation(root, v) {
  if (v.revert) ownBranch(root);
  const plan = readJson(v.plan);
  checkPlan(plan);
  const beforeHash = hashFile(v.before);
  if (plan.batch_sha256 !== beforeHash) throw new Error('before batch does not match the plan');
  const before = loadBatch(v.before), after = loadBatch(v.after);
  const rows = pairRuns(before, after);
  const beforeRows = pairRuns(before, before);
  const receipts = commitsFor(root, plan);
  const ledger = { schema: LEDGER, plan_sha256: planId(plan), before_sha256: beforeHash, after_sha256: hashFile(v.after),
    before_runs: before.results.length, after_runs: after.results.length, matched_runs: rows.length,
    changes: plan.changes.map((c) => {
      const commit = receipts.get(c.id) ?? null;
      return { ...confirmChange(rows, c, beforeRows), commit, revert_commit: revertFor(root, commit) };
    }) };
  const stem = join(dirname(resolve(v.after)), 'tune-ledger');
  artifact(root, stem);
  if (existsSync(stem + '.json') && readJson(stem + '.json').schema !== LEDGER)
    throw new Error('ledger path already holds a different artifact');
  const save = () => {
    atomicWrite(stem + '.json', canonicalJson(ledger));
    atomicWrite(stem + '.md', markdown(ledger));
  };
  if (v.revert && plan.changes.length && !rows.length) {
    save();
    throw new Error('no matching seeds, profiles, controls and pick modes to confirm');
  }
  if (v.revert) revertChanges(root, ledger, save, [v.before, v.after, v.plan, stem + '.json', stem + '.md']);
  else save();
  for (const c of ledger.changes) console.log(c.id + ' ' + c.verdict + ', improvement ' + fmt(c.improvement)
    + ', CI95 ' + c.ci95.map(fmt).join(' to ') + ', A/A floor ' + fmt(c.floor));
  console.log('wrote ' + stem + '.json and .md');
  return ledger;
}

export function main([command, ...argv]) {
  const root = git(process.cwd(), 'rev-parse', '--show-toplevel').trim();
  if (command === 'propose') {
    if (argv.includes('--overwrite-baseline')) throw new Error('tuner baseline is write-once');
    const v = options(argv, ['batch', 'out'], ['target-s', 'profile', 'max', 'killer-share']);
    return withLock(root, () => writePlan(root, v));
  }
  if (command === 'apply') {
    ownBranch(root);
    const v = options(argv, ['plan'], []);
    return withLock(root, () => {
      const receipts = applyPlan(root, readJson(v.plan));
      for (const [id, sha] of receipts) console.log(id + ' ' + sha);
      return receipts;
    });
  }
  if (command === 'confirm') {
    const v = options(argv, ['before', 'after', 'plan'], [], ['revert']);
    return withLock(root, () => confirmation(root, v));
  }
  throw new Error('usage: tune.mjs propose|apply|confirm [options]');
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try { main(process.argv.slice(2)); }
  catch (err) { console.error(err.message); process.exitCode = 1; }
}
