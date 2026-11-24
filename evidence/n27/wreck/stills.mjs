// Same-tick stills of one robot finish. Run from the repo root:
//   node evidence/n27/wreck/stills.mjs <outDir> <ppm> <victim> <electro_gun|claw_shock>
// Writes <victim>-alive.png (one tick before the shot) and <victim>-execute-plus{00,10,30,60}.png.
import { mkdirSync } from 'node:fs';
import { resolve } from 'node:path';
import { runGodot } from '../../../tools/lib/godot.mjs';

const [out, ppm, victim, gun] = process.argv.slice(2);
mkdirSync(out, { recursive: true });
const loadout = gun === 'electro_gun' ? 'electro_gun' : 'hands';
const args = ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440', '--resolution', '1920x1080',
  '--fixed-fps', '60', resolve('tools/film/electric_stills.tscn'), '--', `--loadout=${loadout}`, `--sig-gun=${gun}`,
  `--victim=${victim}`, '--view=tilt70', `--ppm=${ppm}`, '--rigs', '--clean', '--silent', '--feel=off',
  '--enemy-brain=squad', '--seed=20261109'];
const env = { ...process.env, GTAI_MELEE_TAKE: resolve(out), GTAI_MELEE_NATIVE: '1' };
const r = await runGodot(args, { headless: false, timeoutMs: 240000, name: 'wreck-stills', env });
if (r.status !== 0 || r.timedOut || /SCRIPT ERROR:/.test(r.out)) {
  console.log(r.out.split('\n').slice(-25).join('\n'));
  throw Error('failed');
}
console.log(r.out.split('\n').filter(l => /electric_stills/.test(l)).join('\n'));
