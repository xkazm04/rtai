import { median, paired } from '../perf/paired.mjs';
import { quantile } from '../perf/stats.mjs';
import { MIN_AA_PAIRS } from './contract.mjs';
import { matchObservations, offerObservation } from './offers.mjs';

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
    index.set(id, { run, seed: run.seed, stratum, pick });
  }
  return index;
}

export function pairRuns(before, after) {
  if (before.args.runner !== after.args.runner || before.args.waves !== after.args.waves)
    throw new Error('confirmation needs the same runner and wave limit');
  const left = indexedRuns(before), right = indexedRuns(after);
  const rows = [];
  for (const [key, { run, ...identity }] of left) {
    if (right.has(key)) rows.push({ ...identity, a: run, b: right.get(key).run });
  }
  return rows;
}

function offerSamples(rows, metric) {
  const observations = [];
  for (const { a, b, seed, pick } of rows) {
    const left = offerObservation(a, metric.id), right = offerObservation(b, metric.id);
    if (!left || !right || left.took !== right.took || left.stratum !== right.stratum) continue;
    if (!Number.isFinite(left[metric.outcome]) || !Number.isFinite(right[metric.outcome])) continue;
    observations.push({ a: left[metric.outcome], b: right[metric.outcome], took: left.took, seed,
      stratum: JSON.stringify([pick, left.stratum]) });
  }
  const matches = matchObservations(observations.filter((r) => r.took), observations.filter((r) => !r.took));
  return matches.map(([take, decline]) => ({ seed: take.seed, declineSeed: decline.seed, stratum: take.stratum,
    a: take.a - decline.a, b: take.b - decline.b }));
}

function spreadSamples(rows) {
  const groups = Map.groupBy(rows, (r) => JSON.stringify([r.seed, r.pick]));
  const samples = [];
  for (const runs of groups.values()) {
    const novices = runs.filter((r) => r.a.profile === 'novice'), experts = runs.filter((r) => r.a.profile === 'expert');
    for (const novice of novices) {
      const expert = novices.length === 1 && experts.length === 1 ? experts[0] : experts.find((r) => r.a.controls === novice.a.controls);
      if (expert) samples.push({ seed: novice.seed, stratum: JSON.stringify([novice.stratum, expert.stratum]),
        a: [novice.a.wave_reached, expert.a.wave_reached], b: [novice.b.wave_reached, expert.b.wave_reached] });
    }
  }
  return samples;
}

function samplesFor(rows, metric) {
  switch (metric.type) {
    case 'offer': return offerSamples(rows, metric);
    case 'spread': return spreadSamples(rows);
    case 'killer': {
      const indicator = (r) => r.death ? Number(r.death.by === metric.id) : -1;
      return rows.map((r) => ({ ...r, a: indicator(r.a), b: indicator(r.b) }));
    }
    case 'wave': {
      const seconds = (r) => r.waves.find((w) => w.n === metric.wave)?.seconds;
      return rows.filter((r) => r.a.profile === metric.profile).map((r) => ({ ...r, a: seconds(r.a), b: seconds(r.b) }))
        .filter((r) => Number.isFinite(r.a) && Number.isFinite(r.b));
    }
    default: throw new Error('unknown confirmation metric ' + metric.type);
  }
}

function measured(type, sample) {
  if (type === 'killer') {
    const deaths = sample.filter((v) => v >= 0);
    return deaths.length ? deaths.reduce((sum, v) => sum + v, 0) / deaths.length : NaN;
  }
  if (type === 'spread') return median(sample.map((v) => v[1])) - median(sample.map((v) => v[0]));
  return median(sample);
}

function distance(metric, value) {
  if (metric.type === 'killer') return Math.max(0, value - metric.target);
  if (metric.type === 'spread') return Math.max(0, metric.target - value);
  return Math.abs(value - metric.target);
}

// Bootstrap the change of the actual aggregate. Median per-seed changes cannot estimate a death
// share or a difference of profile medians. Each draw carries BOTH observations of its sampled unit.
function interval(rows, measure) {
  if (rows.length < 2) return [NaN, NaN];
  const deltas = [];
  let seed = 1979;
  for (let draw = 0; draw < 2000; draw++) {
    const a = [], b = [];
    for (let i = 0; i < rows.length; i++) {
      seed = seed * 48271 % 2147483647;
      const row = rows[Math.floor(seed / 2147483647 * rows.length)];
      a.push(row.a);
      b.push(row.b);
    }
    const delta = measure(b) - measure(a);
    if (Number.isFinite(delta)) deltas.push(delta);
  }
  return deltas.length < 1900 ? [NaN, NaN] : [quantile(deltas, 0.025), quantile(deltas, 0.975)];
}

function noiseFloor(samples, metric) {
  const aa = [], groups = [];
  for (const [stratum, group] of Map.groupBy(samples, (r) => r.stratum)) {
    group.sort((x, y) => x.seed - y.seed);
    const left = [], right = [];
    const seeds = (r) => r.declineSeed === undefined ? r.seed : [r.seed, r.declineSeed];
    for (let i = 1; i < group.length; i += 2) {
      aa.push({ a: group[i - 1].a, b: group[i].a });
      left.push(seeds(group[i - 1]));
      right.push(seeds(group[i]));
    }
    if (left.length) groups.push({ stratum, left, right });
  }
  const split = { aa_pairs: aa.length, aa_groups: groups };
  if (aa.length < MIN_AA_PAIRS) return { ...split, floor: NaN };
  const ci = ['killer', 'spread'].includes(metric.type)
    ? interval(aa, (v) => measured(metric.type, v))
    : paired(aa).ci95;
  return { ...split, floor: Math.max(...ci.map(Math.abs)) };
}

export function confirmChange(rows, change, beforeRows = rows) {
  const { metric } = change;
  const samples = samplesFor(rows, metric);
  const before = measured(metric.type, samples.map((s) => s.a));
  const after = measured(metric.type, samples.map((s) => s.b));
  const aggregate = distance(metric, before) - distance(metric, after);
  const noise = noiseFloor(beforeRows === rows ? samples : samplesFor(beforeRows, metric), metric);
  const { floor } = noise;
  let improvement = aggregate, ci, statistic;
  if (metric.type === 'wave' || metric.type === 'offer') {
    // Orient paired() so a reduction in distance from the target is positive.
    const comparison = paired(samples.map((r) => ({
      a: -distance(metric, r.a), b: -distance(metric, r.b)
    })), { floor });
    improvement = comparison.median;
    ci = comparison.ci95;
    statistic = 'median paired reduction in miss';
  } else {
    ci = interval(samples, (v) => -distance(metric, measured(metric.type, v)));
    statistic = 'paired reduction in aggregate miss';
  }
  let verdict = samples.length < 2 || noise.aa_pairs < MIN_AA_PAIRS ? 'too few pairs' : 'noise';
  if (samples.length >= 2 && aggregate > floor && ci[0] > floor) verdict = 'kept';
  if (samples.length >= 2 && aggregate < -floor && ci[1] < -floor) verdict = 'reverted';
  return { ...change, measured_before: before, measured_after: after, pairs: samples.length,
    improvement, statistic, aggregate_improvement: aggregate, ci95: ci, ...noise, verdict };
}
