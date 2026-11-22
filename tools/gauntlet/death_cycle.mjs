import { PROFILES } from './contract.mjs';
import { targets } from './death_score.mjs';
import { confirmChange } from './tune_confirm.mjs';

export function deathProfiles(rows, selection, options) {
  const profiles = selection === 'all' ? PROFILES : [selection];
  return profiles.map((profile) => {
    const metric = { type: 'death', profile, target: targets.death_wave[profile] };
    const result = confirmChange(rows, { metric }, options);
    const away = result.aggregate_improvement < -result.floor || result.improvement < -result.floor;
    const verdicts = { ...result.verdicts };
    if (away) {
      for (const mode of Object.keys(verdicts)) if (verdicts[mode] !== 'too few pairs') verdicts[mode] = 'reverted';
    }
    return { ...result, profile, beyond_floor_away: away, paired_verdicts: result.verdicts,
      verdicts, verdict: verdicts[result.verdict_mode] };
  });
}

function cycleVerdict(profiles, served, mode) {
  if (profiles.some((p) => p.verdicts[mode] === 'too few pairs')) return 'too few pairs';
  if (profiles.some((p) => p.beyond_floor_away)) return 'reverted';
  return profiles.some((p) => served.includes(p.profile) && p.verdicts[mode] === 'kept') ? 'kept' : 'noise';
}

export function deathChange(change, profiles, mode) {
  const primary = profiles.find((p) => p.profile === change.metric.profile);
  const verdicts = Object.fromEntries(['point', 'strict'].map((rule) => [rule, cycleVerdict(profiles, change.profiles, rule)]));
  return { ...primary, ...change, verdicts, verdict: verdicts[mode] };
}
