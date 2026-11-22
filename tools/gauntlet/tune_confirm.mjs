import { isDeepStrictEqual } from 'node:util';
import { paired } from '../perf/paired.mjs';
import { MAX_SEED, MIN_AA_PAIRS } from './contract.mjs';
import { floorMode, floorsFor } from './tune_floor.mjs';
import { interval, measured, samplesFor } from './tune_metric.mjs';

function indexedRuns(batch) {
  const recorded = batch.runs.filter((r) => r.ok);
  const key = (r) => JSON.stringify([r.seed, r.profile]);
  const byIdentity = Map.groupBy(recorded, key);
  const index = new Map();
  for (const [i, run] of batch.results.entries()) {
    const candidates = (byIdentity.get(key(run)) ?? []).filter((r) => !r.controls || r.controls === run.controls);
    const row = candidates.length === 1 ? candidates[0] : candidates.includes(recorded[i]) ? recorded[i] : null;
    if (!row) throw new Error('ambiguous run manifest for ' + key(run));
    const pick = row.pick ?? batch.args.pick;
    if (!['random', 'greedy'].includes(pick)) throw new Error('missing pick policy for ' + key(run));
    const stratum = JSON.stringify([run.profile, run.controls, pick]);
    const id = JSON.stringify([stratum, run.seed]);
    if (index.has(id)) throw new Error('duplicate run identity ' + id);
    index.set(id, { run, sha: row.result_sha256, seed: run.seed, stratum, pick });
  }
  return index;
}

export function pairRuns(before, after) {
  if (before.args.runner !== after.args.runner || before.args.waves !== after.args.waves)
    throw new Error('confirmation needs the same runner and wave limit');
  const left = indexedRuns(before), right = indexedRuns(after);
  const rows = [];
  for (const [key, { run, sha, ...identity }] of left) {
    const match = right.get(key);
    if (match) rows.push({ ...identity, a: run, b: match.run, shaA: sha, shaB: match.sha });
  }
  return rows;
}

export function pairNullRuns(before, neutral) {
  const baseSalt = before.args.salt ?? 0, salt = neutral.args.salt ?? 0;
  if (![baseSalt, salt].every((v) => Number.isInteger(v) && v >= 0 && v <= MAX_SEED) || baseSalt === salt)
    throw new Error('before and null batches must record different bot salts (uint32)');
  if (before.tables && neutral.tables && !isDeepStrictEqual(before.tables, neutral.tables))
    throw new Error('before and null batches must use the same balance tables');
  const rows = pairRuns(before, neutral);
  if (!rows.length) throw new Error('no matching seeds, profiles, controls and pick modes in the null batch');
  return rows;
}

function distance(metric, value) {
  if (metric.type === 'killer') return Math.max(0, value - metric.target);
  if (metric.type === 'spread') return Math.max(0, metric.target - value);
  return Math.abs(value - metric.target);
}

export function verdictMode(value = 'point') {
  if (!['point', 'strict'].includes(value)) throw new Error('--verdict must be point or strict');
  return value;
}

export function verdictFor(gain, ci, floor, mode) {
  if (!Number.isFinite(floor) || !ci.every(Number.isFinite)) return 'too few pairs';
  const threshold = verdictMode(mode) === 'strict' ? floor : 0;
  if (gain > floor && ci[0] > threshold) return 'kept';
  if (gain < -floor && ci[1] < -threshold) return 'reverted';
  return 'noise';
}

const mean = (values) => values.reduce((sum, value) => sum + value, 0) / values.length;

export function confirmChange(rows, change, { beforeRows = rows, nullRows = null, mode = 'null-salt', verdict = 'point' } = {}) {
  floorMode(mode);
  verdictMode(verdict);
  if (mode === 'null-salt' && !nullRows) throw new Error('null-salt needs matched null runs');
  const { metric } = change;
  const samples = samplesFor(rows, metric);
  const before = measured(metric.type, samples.map((s) => s.a));
  const after = measured(metric.type, samples.map((s) => s.b));
  const aggregate = distance(metric, before) - distance(metric, after);
  const floors = floorsFor(beforeRows, nullRows, metric);
  const noise = floors[mode];
  const { floor } = noise;
  let point = aggregate, strictCi, pointCi, statistic;
  if (metric.type === 'wave' || metric.type === 'offer') {
    const gains = samples.map((r) => ({ a: -distance(metric, r.a), b: -distance(metric, r.b) }));
    point = mean(gains.map((r) => r.b - r.a));
    pointCi = interval(gains, mean);
    strictCi = paired(gains).ci95;
    statistic = 'mean paired reduction in miss';
  } else {
    pointCi = interval(samples, (v) => -distance(metric, measured(metric.type, v)));
    strictCi = pointCi;
    statistic = 'paired reduction in aggregate miss';
  }
  const enough = samples.length >= 2 && noise.aa_pairs >= MIN_AA_PAIRS;
  const verdicts = {
    point: enough ? verdictFor(point, pointCi, floor, 'point') : 'too few pairs',
    strict: enough ? verdictFor(aggregate, strictCi, floor, 'strict') : 'too few pairs'
  };
  return { ...change, measured_before: before, measured_after: after, pairs: samples.length,
    improvement: verdict === 'point' ? point : aggregate, statistic: verdict === 'point' ? statistic : 'aggregate reduction in miss',
    aggregate_improvement: aggregate, ci95: verdict === 'point' ? pointCi : strictCi, floor_mode: mode, floors,
    floor, aa_pairs: noise.aa_pairs, aa_groups: noise.aa_groups, verdict_mode: verdict, verdicts, verdict: verdicts[verdict] };
}
