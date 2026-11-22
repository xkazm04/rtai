import { quantile } from '../perf/stats.mjs';
import { deathScore, profileScores, recordedRuns, targets } from './death_score.mjs';

function activeAtDeath(run) {
  if (!run.death || run.death.by === 'timeout') return null;
  // The stacked street starts a row on first spawn and writes seconds only when that roster clears.
  // A clear on the death tick also sampled Rivet at zero HP.
  if (!run.waves.length || !run.waves.every((w) => Object.hasOwn(w, 'spawn_delayed'))) return null;
  return run.waves.filter((w) => !Number.isFinite(w.seconds) || w.hp?.end === 0).length;
}

function separation(a, b) {
  const key = (s) => JSON.stringify([s.run.seed, s.run.controls, s.pick]);
  const left = new Map(a.scores.map((s) => [key(s), s]));
  let shared = 0, later = 0, unknown = 0;
  for (const sb of b.scores) {
    const sa = left.get(key(sb));
    if (!sa) continue;
    shared++;
    const lastA = sa.censored ? Infinity : sa.wave, lastB = sb.censored ? Infinity : sb.wave;
    if (sb.wave > lastA) later++;
    else if (lastB > sa.wave) unknown++;
  }
  const { min_wave_gap: gap, min_seed_share: share } = targets.separation;
  const observedGap = b.median - a.median;
  const lowerGap = b.median - a.upper, upperGap = b.upper - a.median;
  let verdict = 'undetermined';
  if (shared && lowerGap >= gap && later / shared >= share) verdict = 'separated';
  else if (shared && (upperGap < gap || (later + unknown) / shared < share)) verdict = 'below target';
  return { a: a.profile, b: b.profile, observedGap, shared, later, unknown, verdict };
}

export function scoreSections(batch, fmt) {
  const records = recordedRuns(batch);
  const profiles = profileScores(batch, records);
  const comparisons = profiles.flatMap((a, i) => profiles.slice(i + 1).map((b) => separation(a, b)));
  const rows = records.map(({ run }) => {
    const score = deathScore(run);
    let outcome = run.death?.by === 'timeout' ? 'wave timer' : 'finished alive';
    if (score) outcome = score.censored ? 'capped ≥ ' + score.wave : 'died on ' + score.wave;
    const active = activeAtDeath(run);
    return [run.profile, run.seed, outcome, run.waves.filter((w) => w.timed_out).length, active ?? '—'];
  });
  const limits = targets.separation;
  return [{
    title: 'Death-wave score', note: 'Capped runs contribute their last reached wave as a lower bound to the median and spread.',
    columns: ['Profile', 'Target', 'Median wave', 'P25–P75', 'Min–max', 'Deaths / capped'],
    rows: profiles.filter((p) => p.scores.length).map((p) => {
      const waves = p.scores.map((s) => s.wave);
      const range = (lo, hi) => fmt(quantile(waves, lo)) + '–' + fmt(quantile(waves, hi));
      return [p.profile, p.target, fmt(p.median), range(0.25, 0.75), range(0, 1), p.deaths + ' / ' + p.capped];
    })
  }, {
    title: 'Profile separation', note: 'Targets require a median gap of ' + limits.min_wave_gap
      + ' waves and a later death on at least ' + fmt(100 * limits.min_seed_share)
      + '% of shared seeds with the same controls and pick policy. Unresolved censored pairs stay in the denominator.',
    columns: ['Profiles', 'Observed median gap', 'Later / shared seeds', 'Confirmed later share', 'Unresolved', 'Verdict'],
    rows: comparisons.map((c) => [c.a + ' → ' + c.b, fmt(c.observedGap), c.later + ' / ' + c.shared,
      c.shared ? fmt(100 * c.later / c.shared) + '%' : '—', c.unknown, c.verdict])
  }, {
    title: 'Waves per run', note: 'A timed-out wave can clear later. Active counts include each started roster still fighting at death.',
    columns: ['Profile', 'Seed', 'Outcome', 'Timed-out waves', 'Active waves at death'], rows
  }];
}
