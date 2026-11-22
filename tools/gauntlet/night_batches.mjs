import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { isDeepStrictEqual } from 'node:util';
import { canonicalJson } from '../lib/canonical_json.mjs';
import { readJson } from '../lib/repo.mjs';
import { editNumber } from './ablate_args.mjs';
import { PROFILES } from './contract.mjs';
import { planEdits } from './plan_sets.mjs';
import { loadBatch } from './report.mjs';
import { SNAPSHOT_TABLES } from './table_snapshot.mjs';
import { pairNullRuns, pairRuns } from './tune_confirm.mjs';
import { commitsFor, planId, revertFor } from './tune_git.mjs';
import { digest, TABLES } from './tune_state.mjs';

function checkRoster(batch, design) {
  for (const key of ['seeds', 'profile', 'seed0', 'controls', 'pick', 'runner', 'waves', 'pickFilter']) {
    if ((batch.args[key] ?? null) !== (design[key] ?? null)) throw new Error('batch recipe differs: ' + key);
  }
  const profiles = design.profile === 'all' ? PROFILES : [design.profile];
  const rows = pairRuns(batch, batch);
  if (rows.length !== profiles.length * design.seeds || rows.length !== batch.runs.length
    || rows.some(({ seed, a, pick }) => !profiles.includes(a.profile) || a.controls !== design.controls
      || pick !== design.pick || seed < design.seed0 || seed >= design.seed0 + design.seeds))
    throw new Error('batch must match all requested seeds, profiles, controls and pick modes');
}

export function checkPair(before, other, neutral) {
  checkRoster(other, before.args);
  if (neutral) pairNullRuns(before, other);
  else if ((before.args.salt ?? 0) !== (other.args.salt ?? 0)) throw new Error('after uses a different bot salt');
}

export function tableHashes(root, edits = [], reverse = false) {
  const tables = {};
  const files = Map.groupBy(edits, (m) => m.file);
  for (const name of SNAPSHOT_TABLES) {
    const file = name + '.json', key = TABLES + file, path = join(root, key);
    if (!existsSync(path)) continue;
    let bytes = readFileSync(path);
    if (files.has(key)) {
      const table = JSON.parse(bytes);
      for (const { pointer, before, after } of files.get(key)) {
        if (editNumber(table, { pointer, value: reverse ? before : after }) !== (reverse ? after : before))
          throw new Error('plan does not match table at ' + key + '#' + pointer);
      }
      bytes = canonicalJson(table);
      files.delete(key);
    }
    tables[file] = digest(bytes);
  }
  if (files.size) throw new Error('unknown plan table: ' + [...files.keys()][0]);
  return tables;
}

function checkTables(batch, expected, role) {
  if (!Object.keys(expected).length || !isDeepStrictEqual(batch.tables, expected))
    throw new Error(role + ' batch table hashes do not match the tune worktree');
}

function inputBatch(job, arm) {
  const batch = loadBatch(job.files[arm]);
  if (job.rev && batch.git?.sha !== job.rev) throw new Error(arm + ' batch revision differs from --rev');
  return batch;
}

export function checkMeasuredTables(tree, job, arm) {
  checkTables(inputBatch(job, arm), tableHashes(tree), arm);
}

export function checkInputs(tree, job) {
  if (!job.inputs.before) return;
  const before = inputBatch(job, 'before');
  checkRoster(before, job.batch);
  // A resumed plan can already be applied. Its exact inverse reconstructs the before hashes.
  if (!job.resume) checkTables(before, tableHashes(tree), 'before');
  if (job.inputs.null) {
    const neutral = inputBatch(job, 'null');
    checkPair(before, neutral, true);
    checkTables(neutral, before.tables, 'null');
  }
  if (job.inputs.after) checkPair(before, inputBatch(job, 'after'), false);
}

// Validate external measurements before applying a single edit, including when resuming after apply.
export function checkAfterPlan(tree, job) {
  const plan = readJson(job.plan);
  if (digest(readFileSync(job.files.before)) !== plan.batch_sha256) throw new Error('before does not match plan');
  if (plan.profile !== job.batch.profile || plan.metric !== job.metric)
    throw new Error('plan differs from requested profile or metric');
  const edits = planEdits(plan);
  const receipts = commitsFor(tree, plan);
  const active = new Set();
  let reverted = false;
  for (const change of plan.changes) {
    const commit = receipts.get(change.id);
    if (!commit) continue;
    if (revertFor(tree, commit)) reverted = true;
    else for (const m of change.members ?? [change]) active.add(m.id);
  }
  if (reverted) verifyRevertedLedger(job, plan);
  const before = inputBatch(job, 'before'), after = inputBatch(job, 'after');
  checkRoster(before, job.batch);
  checkPair(before, after, false);
  checkTables(before, tableHashes(tree, edits.filter((m) => active.has(m.id)), true), 'before');
  checkTables(after, tableHashes(tree, edits.filter((m) => !active.has(m.id))), 'after');
  return plan.changes.length > 0 && plan.changes.every((c) => receipts.has(c.id));
}

function verifyRevertedLedger(job, plan) {
  const path = join(job.dir, 'after/tune-ledger.json');
  const ledger = existsSync(path) && readJson(path);
  if (ledger?.plan_sha256 !== planId(plan) || ['before', 'null', 'after'].some((arm) =>
    ledger[arm + '_sha256'] !== digest(readFileSync(job.files[arm]))))
    throw new Error('resuming a reverted plan needs its original ledger and measurements');
}
