// Rivet, the patrol cop and the contractor at 70/32, 55/32 and 70/64 (size log + the beside still).
// Set APPDATA and GODOT_BIN first. usage: node tools/art/cast_contractor_lineup.mjs <output directory>
import { copyFileSync, mkdirSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { describe, runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';

const out = process.argv[2];
if (process.argv.length !== 3 || !out) {
  console.error('usage: node tools/art/cast_contractor_lineup.mjs <output directory>');
  process.exit(2);
}
const directory = resolve(out);
mkdirSync(directory, { recursive: true });
const args = ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440',
  '--resolution', '1920x1080', '--fixed-fps', '60', '--quit-after', '4000',
  'res://dev/cast/cast_contractor_lineup.tscn'];
for (const [pitch, ppm] of [[70, 32], [55, 32], [70, 64]]) {
  const env = { ...process.env, GTAI_CAST_OUT: directory, GTAI_CAST_PITCH: String(pitch),
    GTAI_CAST_PPM: String(ppm) };
  const r = await runGodot(args, { env, name: 'cast-contractor-lineup', headless: false, timeoutMs: 240_000 });
  if (r.status !== 0 || r.timedOut || SCRIPT_ERROR.test(r.out) || !r.out.includes('cast: saved ')) {
    console.error(r.out.split('\n').slice(-30).join('\n'), describe(r));
    process.exit(1);
  }
  console.log(r.out.split('\n').filter((l) => /facing \d body/.test(l)).join('\n'));
  copyFileSync(join(directory, `audit_lineup_${ppm}ppm_tilt${pitch}.png`),
    join(directory, `contractor_beside_${ppm}ppm_tilt${pitch}.png`));
  console.log(`pitch ${pitch} ppm ${ppm} (${describe(r)})`);
}
