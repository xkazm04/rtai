// Each run appears once per offered item. Effects and A/A controls use disjoint run pairs.
import { bootCi, median } from '../perf/paired.mjs';

function afterPick(run, pick) {
  const last = run.wave_reached;
  const terminal = run.waves.find((w) => w.n === last);
  // Entering the next wave proves the previous one was survived. A censoring boundary alone
  // does not prove completion of the final wave. A clear or a post-wave offer does.
  const clearedFinal = !run.death && (terminal?.status === 'cleared' || run.picks.some((p) => p.wave === last));
  return { seed: run.seed, stratum: JSON.stringify([run.profile, run.controls, pick.wave]),
    survived: Math.max(0, last - pick.wave - Number(!clearedFinal)),
    seconds: median(run.waves.filter((w) => w.n > pick.wave).map((w) => w.seconds).filter(Number.isFinite)) };
}

function collect(runs, identify) {
  const exposures = new Map();
  for (const run of runs) {
    const first = new Map();
    for (const pick of [...run.picks].sort((a, b) => a.wave - b.wave)) {
      const taken = identify(pick.taken);
      for (const item of new Set(pick.offered.map(identify).filter(Boolean))) {
        const earlier = first.get(item);
        if (!earlier || (!earlier.took && taken === item)) first.set(item, { took: taken === item, pick });
      }
    }
    for (const [item, { took, pick }] of first) {
      if (!exposures.has(item)) exposures.set(item, { took: [], declined: [] });
      exposures.get(item)[took ? 'took' : 'declined'].push(afterPick(run, pick));
    }
  }
  return exposures;
}

function differences(a, b, metric) {
  const strata = Map.groupBy(b, (r) => r.stratum);
  const deltas = [];
  for (const [stratum, left] of Map.groupBy(a, (r) => r.stratum)) {
    const right = strata.get(stratum);
    if (!right?.length) continue;
    left.sort((x, y) => x.seed - y.seed);
    right.sort((x, y) => x.seed - y.seed);
    const n = Math.min(left.length, right.length);
    // Sample across both seed ranges when one cohort is bigger. No run is paired twice.
    for (let i = 0; i < n; i++) {
      const l = left[Math.floor((i + 0.5) * left.length / n)];
      const r = right[Math.floor((i + 0.5) * right.length / n)];
      deltas.push(l[metric] - r[metric]);
    }
  }
  return deltas;
}

function compare(exposure, metric) {
  const took = exposure.took.filter((r) => Number.isFinite(r[metric]));
  const declined = exposure.declined.filter((r) => Number.isFinite(r[metric]));
  const deltas = differences(took, declined, metric);
  const aaSplit = (pool) => differences(pool.filter((r) => r.seed % 2 === 0),
    pool.filter((r) => r.seed % 2 === 1), metric);
  let aa = aaSplit(declined);
  let aaSource = 'decliners';
  if (aa.length < 2) {
    aa = aaSplit([...took, ...declined]);
    aaSource = 'all offered';
  }
  const delta = median(deltas);
  const ci = deltas.length >= 2 ? bootCi(deltas) : [NaN, NaN];
  const floor = aa.length >= 2 ? Math.max(...bootCi(aa).map(Math.abs)) : NaN;
  let label = 'insufficient data';
  if (deltas.length >= 2) {
    if ((ci[0] <= 0 && ci[1] >= 0) || Math.abs(delta) <= floor) label = 'noise';
    else if (Number.isFinite(floor)) label = delta > 0 ? 'higher' : 'lower';
  }
  return { metric, took: took.length, declined: declined.length,
    takeMedian: median(took.map((r) => r[metric])), declineMedian: median(declined.map((r) => r[metric])),
    pairs: deltas.length, delta, ci, floor, aaSource, aaPairs: aa.length, label };
}

export function offerEffects(runs, weapons) {
  const rows = [];
  for (const [kind, identify] of [['bonus', (id) => id], ['weapon', (id) => weapons.get(id)]]) {
    const exposures = collect(runs, identify);
    for (const id of [...exposures.keys()].sort()) {
      const exposure = exposures.get(id);
      for (const metric of ['survived', 'seconds']) rows.push({ kind, id, ...compare(exposure, metric) });
    }
  }
  return rows;
}
