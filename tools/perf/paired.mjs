// Paired round deltas for the interleaved runners (n10's evidence/perf/n10-cputime/analyse.py, in JS):
// every round runs each arm once, so `b - a` per round cancels the machine's drift; the verdict is
// the median delta, its 95 % bootstrap interval and a two-sided sign test. Pure, no I/O.

import { quantile } from './stats.mjs';

/** mulberry32: a seeded PRNG so the same rounds always print the same interval. */
function rng(seed) {
  let s = seed >>> 0;
  return () => {
    s = (s + 0x6d2b79f5) >>> 0;
    let t = s;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

/** 95 % bootstrap interval of the median of `d` (n resamples, fixed seed). */
export function bootCi(d, { n = 4000, seed = 1 } = {}) {
  if (!d.length) return [NaN, NaN];
  const r = rng(seed);
  const meds = [];
  for (let i = 0; i < n; i++) {
    const s = [];
    for (let k = 0; k < d.length; k++) s.push(d[Math.floor(r() * d.length)]);
    meds.push(quantile(s, 0.5));
  }
  meds.sort((x, y) => x - y);
  return [meds[Math.floor(0.025 * n)], meds[Math.floor(0.975 * n)]];
}

function comb(n, k) {
  let c = 1;
  for (let i = 1; i <= k; i++) c = (c * (n - k + i)) / i;
  return c;
}

/** Two-sided sign test: `lower` of `n` deltas below zero. */
export function signP(lower, n) {
  if (!n) return NaN;
  const k = Math.min(lower, n - lower);
  let s = 0;
  for (let i = 0; i <= k; i++) s += comb(n, i);
  return Math.min(1, (2 * s) / 2 ** n);
}

/** Median of a sorted-copy (the true middle for an even count, unlike nearest-rank quantile). */
export function median(a) {
  if (!a.length) return NaN;
  const s = [...a].sort((x, y) => x - y);
  const m = Math.floor(s.length / 2);
  return s.length % 2 ? s[m] : (s[m - 1] + s[m]) / 2;
}

/**
 * The paired verdict of arm `b` against arm `a` over rounds: `byRound` is [{a, b}] of one metric.
 * Rounds missing either arm are left out. `floor` (optional) is the A/A's half-interval: a delta
 * whose interval does not clear zero, or whose size is inside the floor, is a WASH.
 */
export function paired(byRound, { floor = 0 } = {}) {
  const d = byRound.filter((r) => Number.isFinite(r.a) && Number.isFinite(r.b)).map((r) => r.b - r.a);
  const med = median(d);
  const [lo, hi] = bootCi(d);
  const lower = d.filter((v) => v < 0).length;
  let call = 'WASH';
  if (d.length && (lo > 0 || hi < 0) && Math.abs(med) > floor) call = med < 0 ? 'LOWER' : 'HIGHER';
  return { n: d.length, median: med, ci95: [lo, hi], lower, signP: signP(lower, d.length), call };
}
