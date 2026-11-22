import { deathScore } from './death_score.mjs';
import { median } from '../perf/paired.mjs';
import { mean, quantile } from '../perf/stats.mjs';
import { matchObservations, offerObservation } from './offers.mjs';

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

export function samplesFor(rows, metric) {
  switch (metric.type) {
    case 'death': return rows.filter((r) => r.a.profile === metric.profile).flatMap((r) => {
      const a = deathScore(r.a, r.waves), b = deathScore(r.b, r.waves);
      return a && b ? [{ ...r, a: a.wave, b: b.wave, censoredA: a.censored, censoredB: b.censored }] : [];
    });
    case 'reached': return rows.map((r) => ({ ...r, a: r.a.wave_reached, b: r.b.wave_reached }));
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

export function measured(type, sample) {
  if (type === 'killer') {
    const deaths = sample.filter((v) => v >= 0);
    return deaths.length ? deaths.reduce((sum, v) => sum + v, 0) / deaths.length : NaN;
  }
  if (type === 'spread') return median(sample.map((v) => v[1])) - median(sample.map((v) => v[0]));
  return median(sample);
}

// Bootstrap the change of the actual aggregate. Median per-seed changes cannot estimate a death
// share or a difference of profile medians. Each draw carries BOTH observations of its sampled unit.
export function interval(rows, measure) {
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

export function pairedMean(rows, direction = 1) {
  const deltas = rows.map((r) => direction * (r.b - r.a));
  const ci = interval(deltas.map((b) => ({ a: 0, b })), mean);
  return { gain: mean(deltas), ci };
}
