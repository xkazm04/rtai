import { median } from '../perf/paired.mjs';

export const enemies = new Map([
  ['ohm_short_circuit', 'sentry_turret'],
  ['tonnage_armour_crack', 'war_machine'],
  ['kerf_blink_behind', 'shield_robot'],
  ['overkill_carry', null]
]);

// A missing roster cannot establish absence. Carry applies to every timed wave.
export function stratum(wave, enemy) {
  if (enemy === null) return 'present';
  if (!wave.enemies) return null;
  return wave.enemies[enemy] > 0 ? 'present' : 'absent';
}

export function moveSection(batch, fmt) {
  const rows = [];
  for (const [profile, runs] of Map.groupBy(batch.results, (r) => r.profile)) {
    const waves = runs.flatMap((r) => r.waves);
    const byWave = [...Map.groupBy(waves, (w) => w.n)].sort(([a], [b]) => a - b);
    for (const [n, group] of [['All', waves], ...byWave]) {
      if (!group.length) continue;
      for (const [id, enemy] of enemies) {
        const uses = group.reduce((sum, wave) => sum + (wave.moves?.[id] ?? 0), 0);
        const timings = (which) => {
          const times = group.filter((w) => stratum(w, enemy) === which)
            .map((w) => w.seconds).filter(Number.isFinite);
          return times.length ? fmt(median(times)) + ' (' + times.length + ')' : '—';
        };
        rows.push([profile, n, id, enemy ?? 'all waves', uses, group.length, fmt(uses / group.length),
          timings('present'), timings('absent')]);
      }
    }
  }
  return { title: 'Moves', note: 'Uses count recorded activations by profile and wave number. The game omits zero counts. '
    + 'Times are medians in seconds, with timed wave counts in parentheses. Carry applies to all waves.',
    columns: ['Profile', 'Wave', 'Move', 'Enemy', 'Recorded uses', 'Observed waves', 'Uses per wave',
      'With enemy s (n)', 'Without enemy s (n)'], rows };
}
