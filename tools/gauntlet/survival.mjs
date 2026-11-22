import { median } from '../perf/paired.mjs';

const stats = ['damage', 'guard_meter', 'hp_max', 'regen', 'speed'];
const bands = ['1–10', '11–20', '21–30', '31+'];

export function statCards(table) {
  return Object.fromEntries(table.rows.filter((card) => card.kind === 'stat')
    .map(({ id, ref, k }) => [id, { ref, k }]));
}

function waveSamples(run, tuning) {
  const mods = Object.fromEntries(stats.map((stat) => [stat, 1]));
  const picks = [...run.picks].sort((a, b) => a.wave - b.wave);
  let next = 0;
  return [...run.waves].sort((a, b) => a.n - b.n).map((wave) => {
    while (next < picks.length && picks[next].wave < wave.n) {
      const { taken } = picks[next++];
      const card = tuning.stat_cards?.[taken];
      if (card) mods[card.ref] *= card.k;
    }
    return { wave, mods: tuning.stat_cards ? { ...mods } : {}, repair: tuning.repair_per_s * mods.regen };
  });
}

export const damagePerSecond = (wave) => wave.seconds > 0 ? wave.damage_taken / wave.seconds : NaN;
export const repairShare = (wave) => wave.damage_taken > 0 ? 100 * wave.hp?.repaired / wave.damage_taken : NaN;

export function survivalSection(batch, fmt) {
  const rows = [];
  const tuning = batch.survival_tuning ?? {};
  for (const [profile, runs] of Map.groupBy(batch.results, (run) => run.profile)) {
    const samples = runs.flatMap((run) => waveSamples(run, tuning));
    for (const [index, band] of bands.entries()) {
      const group = samples.filter(({ wave }) => Math.min(3, Math.floor((wave.n - 1) / 10)) === index);
      const value = (get) => median(group.map(get).filter(Number.isFinite));
      const mid = (get) => fmt(value(get));
      const hp = group.filter(({ wave }) => wave.hp).length;
      rows.push([profile, band, hp + ' / ' + group.length, mid(({ wave }) => wave.damage_taken),
        mid(({ wave }) => damagePerSecond(wave)),
        mid(({ repair, mods }) => Number.isFinite(mods.regen) ? repair : null),
        mid(({ wave }) => wave.hp?.max > 0 ? 100 * wave.hp.min / wave.hp.max : null),
        mid(({ wave }) => wave.hp?.repaired),
        mid(({ wave }) => repairShare(wave)),
        ...['guard_deflects', 'cover_ticks', 'rolls'].map((key) => mid(({ wave }) => wave[key])),
        ...stats.map((stat) => {
          const multiplier = value(({ mods }) => mods[stat]);
          return Number.isFinite(multiplier) ? String(Number(multiplier.toFixed(5))) : fmt(multiplier);
        })]);
    }
  }
  return { title: 'Survival by wave band', key: 'survival',
    note: 'Each wave contributes once to each available median. Damage/s needs a timed wave. Repair/s is the configured rate when repair is active. '
      + 'HP coverage counts waves sampled by the bot. Repaired HP sums positive HP steps. The share undone uses waves with positive damage. '
      + 'Multipliers include stat cards taken before the wave.',
    columns: ['Profile', 'Waves', 'HP rows / observed', 'Damage', 'Damage/s', 'Repair/s', 'Minimum HP (% of capacity)',
      'Repaired HP', 'Damage undone (%)', 'Guard deflects', 'Cover ticks', 'Rolls', ...stats.map((s) => s + ' ×')], rows };
}
