// Frame-time statistics for the perf lane's A/B runner (docs/perf/LEDGER.md).
// Pure functions over arrays of milliseconds; no I/O, so `node --test` covers them.

/** The q-quantile of `a` (nearest rank on a sorted copy; q in [0, 1]). NaN when empty. */
export function quantile(a, q) {
  if (!a.length) return NaN;
  const s = [...a].sort((x, y) => x - y);
  return s[Math.min(s.length - 1, Math.floor(s.length * q))];
}

export const mean = (a) => (a.length ? a.reduce((s, v) => s + v, 0) / a.length : NaN);

/** 1000 / mean of the worst 1 % of frames (the STANDARDS section 20 "1 % low"). */
export function low1Fps(a) {
  if (!a.length) return NaN;
  const s = [...a].sort((x, y) => y - x);
  const n = Math.max(1, Math.ceil(a.length * 0.01));
  return 1000 / mean(s.slice(0, n));
}

/** Frame pacing: the spread between consecutive frames, |f[i] - f[i-1]| (p50, p99, max). */
export function pacing(a) {
  const d = [];
  for (let i = 1; i < a.length; i++) d.push(Math.abs(a[i] - a[i - 1]));
  return { p50: quantile(d, 0.5), p99: quantile(d, 0.99), max: d.length ? Math.max(...d) : NaN };
}

/** Every number the LEDGER reports for one frame series (warm-up frames already dropped). */
export function frameStats(a) {
  const p = pacing(a);
  return {
    frames: a.length,
    mean: mean(a),
    p50: quantile(a, 0.5),
    p99: quantile(a, 0.99),
    p999: quantile(a, 0.999),
    worst: a.length ? Math.max(...a) : NaN,
    low1Fps: low1Fps(a),
    over25: a.filter((v) => v > 25).length,
    over50: a.filter((v) => v > 50).length,
    pace50: p.p50,
    pace99: p.p99,
  };
}

/** Median and spread (max - min) of one metric over runs. */
export function medianSpread(values) {
  const v = values.filter((x) => Number.isFinite(x));
  return { median: quantile(v, 0.5), spread: v.length ? Math.max(...v) - Math.min(...v) : NaN, n: v.length };
}

/**
 * The verdict of an interleaved A/B: B's median against A's, judged against the noise. The noise
 * is the larger of the two arms' spreads; a difference inside it is a WASH, never a win.
 */
export function verdict(aVals, bVals, { lowerIsBetter = true } = {}) {
  const a = medianSpread(aVals);
  const b = medianSpread(bVals);
  const delta = b.median - a.median;
  const noise = Math.max(a.spread, b.spread);
  let call = 'WASH';
  if (Math.abs(delta) > noise) call = (delta < 0) === lowerIsBetter ? 'WIN' : 'LOSS';
  return { a, b, delta, pct: (100 * delta) / a.median, noise, call };
}
