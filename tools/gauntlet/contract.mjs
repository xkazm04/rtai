// Validate the producer's envelope and only the telemetry it actually supplies.
export const PROFILES = ['novice', 'average', 'expert'];
export const RUN_SCHEMA = 'gtai.gauntlet-run/1';
export const BATCH_SCHEMA = 'gtai.gauntlet-batch/1';
export const MAX_SEED = 0xffffffff;
export const MIN_AA_PAIRS = 6;
const object = (value) => value !== null && typeof value === 'object' && !Array.isArray(value);
const count = (value) => Number.isSafeInteger(value) && value >= 0;
const magnitude = (value) => Number.isFinite(value) && value >= 0;
const id = (value) => typeof value === 'string' && value.length > 0;
const dictionary = (value, check) => object(value)
  && Object.entries(value).every(([key, item]) => id(key) && check(item));

/** Return the first bad field with its path. Optional fields must be valid when present. */
export function validateRun(run) {
  if (!object(run) || run.schema !== RUN_SCHEMA) return 'schema: expected ' + RUN_SCHEMA;
  if (!count(run.seed) || run.seed > MAX_SEED) return 'seed: expected unsigned 32-bit integer';
  if (![...PROFILES, 'human'].includes(run.profile)) return 'profile: missing or unknown';
  if (!['legacy', 'wheel'].includes(run.controls)) return 'controls: missing or unknown';
  if (!count(run.wave_reached)) return 'wave_reached: expected nonnegative integer';
  if (!Array.isArray(run.waves)) return 'waves: expected array';
  if (!Array.isArray(run.picks)) return 'picks: expected array';
  if (!dictionary(run.mods, Number.isFinite)) return 'mods: expected numeric dictionary';
  if ('sim_s' in run && !magnitude(run.sim_s)) return 'sim_s: expected nonnegative seconds';
  if ('capped' in run && (run.capped !== true || run.death)) return 'capped: expected a live tick-cap run';
  if ('death' in run) {
    if (!object(run.death) || !count(run.death.wave) || run.death.wave > run.wave_reached)
      return 'death.wave: expected reached death wave';
    if ('by' in run.death && !id(run.death.by)) return 'death.by: expected killer id';
  }
  const seen = new Set();
  for (const [i, wave] of run.waves.entries()) {
    const prefix = 'waves[' + i + '].';
    if (!object(wave) || !count(wave.n) || wave.n < 1 || wave.n > run.wave_reached || seen.has(wave.n))
      return prefix + 'n: expected unique reached wave number';
    seen.add(wave.n);
    if ('timed_out' in wave && wave.timed_out !== true) return prefix + 'timed_out: expected true';
    if ('hp' in wave) {
      const keys = ['start', 'min', 'end', 'max', 'repaired'];
      if (!object(wave.hp) || Object.keys(wave.hp).length !== keys.length
        || !keys.every((key) => magnitude(wave.hp[key]))) return prefix + 'hp: invalid health sample';
    }
    for (const key of ['seconds', 'damage_taken'])
      if (key in wave && !magnitude(wave[key])) return prefix + key + ': expected nonnegative number';
    for (const key of ['guard_deflects', 'rolls', 'shots', 'hits', 'guard_ticks', 'cover_ticks'])
      if (key in wave && !count(wave[key])) return prefix + key + ': expected nonnegative integer';
    if ('moves' in wave && !dictionary(wave.moves, count)) return prefix + 'moves: invalid counts';
    if ('enemies' in wave && !dictionary(wave.enemies, count)) return prefix + 'enemies: invalid counts';
    if ('form_seconds' in wave && !dictionary(wave.form_seconds, magnitude))
      return prefix + 'form_seconds: invalid seconds';
  }
  for (const [i, pick] of run.picks.entries()) {
    const prefix = 'picks[' + i + '].';
    if (!object(pick) || !count(pick.wave) || pick.wave < 1 || pick.wave > run.wave_reached)
      return prefix + 'wave: expected reached wave number';
    if (!Array.isArray(pick.offered) || pick.offered.length < 1 || pick.offered.length > 3
      || !pick.offered.every(id) || new Set(pick.offered).size !== pick.offered.length)
      return prefix + 'offered: expected one to three distinct ids';
    if (!pick.offered.includes(pick.taken)) return prefix + 'taken: not in offer';
  }
  return null;
}
