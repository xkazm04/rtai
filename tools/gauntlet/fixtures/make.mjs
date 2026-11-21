// Deterministic synthetic observations. Regenerate from any working directory with node make.mjs.
import { writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';

const dir = fileURLToPath(new URL('.', import.meta.url));
const profiles = [['novice', 3, 3], ['average', 4, 0], ['expert', 5, -4]];

for (const [profile, baseDepth, offset] of profiles) {
  for (let seed = 1; seed <= 8; seed++) {
    const pistol = seed <= 4;
    const last = baseDepth + (pistol ? 2 : 0);
    const picks = [
      { wave: 1, offered: ['weapon_pistol', 'ghost_kerf', 'stat_damage_10'],
        taken: pistol ? 'weapon_pistol' : seed < 8 ? 'ghost_kerf' : 'stat_damage_10' },
      { wave: 2, offered: ['stat_hp_max_10', 'stat_regen_10', 'ghost_ohm'],
        taken: seed % 2 ? 'stat_hp_max_10' : 'stat_regen_10' }
    ];
    const waves = [];
    for (let n = 1; n <= last; n++) {
      const wave = { n, seconds: (n === 1 ? 11 + seed : pistol ? 19 : 25) + offset,
        enemies: n % 2 ? { contractor: 2 } : { patrol_cop: 2, contractor: 1 },
        shots: n + seed, damage_taken: seed % 3, rolls: (seed + n) % 3,
        form_seconds: seed === 4 ? { tonnage: 4 } : { kerf: 3 } };
      if (n === 1) {
        if (seed === 1) Object.assign(wave, { shots: 4, hits: 2, guard_deflects: 0 });
        if (seed === 2) Object.assign(wave, { shots: 12, hits: 9, guard_deflects: 4 });
        if (seed === 8) {
          delete wave.seconds;
          delete wave.enemies;
          delete wave.form_seconds;
        }
      } else {
        wave.hits = Math.floor(wave.shots / 2);
        wave.guard_deflects = seed % 3;
      }
      waves.push(wave);
    }
    const mods = { [seed % 2 ? 'hp_max' : 'regen']: 1.1 };
    if (seed === 8) mods.damage = 1.1;
    const run = { schema: 'gtai.gauntlet-run/1', profile, seed, controls: profile === 'expert' ? 'wheel' : 'legacy',
      wave_reached: last, waves, picks, mods };
    if (seed < 8) {
      run.death = { wave: last };
      if (seed !== 7) run.death.by = last % 2 ? 'contractor' : 'patrol_cop';
    } else {
      waves.at(-1).status = 'tick_limit';
      delete waves.at(-1).seconds;
    }
    writeFileSync(join(dir, profile + '-' + seed + '.json'), JSON.stringify(run, null, 2) + '\n');
  }
}
const malformed = { schema: 'gtai.gauntlet-run/1', seed: 9, profile: 'average', controls: 'legacy',
  wave_reached: 1, picks: [], mods: {} };
writeFileSync(join(dir, 'average-9.json'), JSON.stringify(malformed, null, 2) + '\n');
