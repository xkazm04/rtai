import { isDeepStrictEqual } from 'node:util';
import { MAX_SEED, MIN_AA_PAIRS } from './contract.mjs';
import { floorMode, floorsFor } from './tune_floor.mjs';
import { recordedRuns } from './death_score.mjs';
import { interval, measured, pairedMean, samplesFor } from './tune_metric.mjs';

function indexedRuns(batch) {
  const index = new Map();
  for (const { run, row } of recordedRuns(batch)) {
    const pick = row.pick ?? batch.args.pick;
    if (!['random', 'greedy'].includes(pick)) throw new Error('missing pick policy for seed ' + run.seed);
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

export function confirmChange(rows, change, { beforeRows = rows, nullRows = null, mode = 'null-salt', verdict = 'point' } = {}) {
  floorMode(mode);
  verdictMode(verdict);
  if (mode === 'null-salt' && !nullRows) throw new Error('null-salt needs matched null runs');
  const { metric } = change;
  if (metric.type === 'death' && (mode !== 'null-salt' || !nullRows))
    throw new Error('death-wave confirmation requires --null and the null-salt floor');
  const samples = samplesFor(rows, metric);
  const before = measured(metric.type, samples.map((s) => s.a));
  const after = measured(metric.type, samples.map((s) => s.b));
  const aggregate = distance(metric, before) - distance(metric, after);
  const floors = floorsFor(beforeRows, nullRows, metric);
  const noise = floors[mode];
  const { floor } = noise;
  let improvement = aggregate, ci, statistic;
  if (metric.type === 'death') {
    const direction = Math.sign(metric.target - before);
    ({ gain: improvement, ci } = pairedMean(samples, direction));
    statistic = 'mean paired death-wave change toward target';
  } else if (metric.type === 'wave' || metric.type === 'offer') {
    const gains = samples.map((r) => ({ a: -distance(metric, r.a), b: -distance(metric, r.b) }));
    ({ gain: improvement, ci } = pairedMean(gains));
    statistic = 'mean paired reduction in miss';
  } else {
    ci = interval(samples, (v) => -distance(metric, measured(metric.type, v)));
    statistic = 'paired reduction in aggregate miss';
  }
  const enough = samples.length >= 2 && noise.aa_pairs >= MIN_AA_PAIRS;
  const verdicts = {
    point: enough ? verdictFor(improvement, ci, floor, 'point') : 'too few pairs',
    strict: enough ? verdictFor(improvement, ci, floor, 'strict') : 'too few pairs'
  };
  return { ...change, measured_before: before, measured_after: after, pairs: samples.length,
    ...(metric.type === 'death' && { censored_before: samples.filter((r) => r.censoredA).length,
      censored_after: samples.filter((r) => r.censoredB).length, median_uses_censored_lower_bounds: true }),
    improvement, statistic, aggregate_improvement: aggregate, ci95: ci, floor_mode: mode, floors,
    floor, aa_pairs: noise.aa_pairs, aa_groups: noise.aa_groups, verdict_mode: verdict, verdicts, verdict: verdicts[verdict] };
}
