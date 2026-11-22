import { PROFILES } from './contract.mjs';
import { median } from '../perf/paired.mjs';
import targets from './targets.json' with { type: 'json' };

export { targets };

// A legacy timer death was an administrative end. A wave-limited clear also has no death score.
export function deathScore(run) {
  if (run.death && run.death.by !== 'timeout') return { wave: run.death.wave, censored: false };
  if (run.capped) return { wave: run.wave_reached, censored: true };
  return null;
}

// Older manifests recorded the cap only on the successful launcher row.
export function recordedRuns(batch) {
  const recorded = batch.runs.filter((r) => r.ok);
  const key = (r) => JSON.stringify([r.seed, r.profile]);
  const byIdentity = Map.groupBy(recorded, key);
  return batch.results.map((result, i) => {
    const candidates = (byIdentity.get(key(result)) ?? []).filter((r) => !r.controls || r.controls === result.controls);
    const row = candidates.length === 1 ? candidates[0] : candidates.includes(recorded[i]) ? recorded[i] : null;
    if (!row) throw new Error('ambiguous run manifest for ' + key(result));
    const run = row.outcome === 'capped' && !result.capped ? { ...result, capped: true } : result;
    return { run, row };
  });
}

export function profileScores(batch, records = recordedRuns(batch)) {
  const observations = records.flatMap(({ run, row }) => {
    const score = deathScore(run);
    return score ? [{ ...score, run, pick: row.pick ?? batch.args.pick }] : [];
  });
  const groups = Map.groupBy(observations, (s) => s.run.profile);
  return PROFILES.map((profile) => {
    const target = targets.death_wave[profile];
    const scores = groups.get(profile) ?? [];
    const waves = scores.map((s) => s.wave);
    const capped = scores.filter((s) => s.censored).length;
    const upper = median(scores.map((s) => s.censored ? Infinity : s.wave));
    return { profile, target, scores, median: median(waves), upper, deaths: scores.length - capped, capped };
  });
}
