// The gunner's frozen exposures and ring-off pairs at both pitches and both scales.
// Set APPDATA and GODOT_BIN first. usage: node tools/art/cast_gunner_poses.mjs <output directory>
import { mkdirSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';

const out = process.argv[2];
if (process.argv.length !== 3 || !out) {
  console.error('usage: node tools/art/cast_gunner_poses.mjs <output directory>');
  process.exit(2);
}
const dir = resolve(out);
mkdirSync(dir, { recursive: true });
const args = ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440',
  '--resolution', '1920x1080', '--fixed-fps', '60', '--quit-after', '20000',
  'res://dev/cast/cast_gunner_poses.tscn'];
// One launch runs 70/32 (ring toggle), 70/64 and 55/64 (rim): the RAM-cap wait is per launch.
const r = await runGodot(args, { env: { ...process.env, GTAI_CAST_OUT: dir }, name: 'cast-gunner-poses',
  headless: false, timeoutMs: 1_500_000 });
console.log(r.out.split('\n').filter((l) => /cast:|ERROR/.test(l)).join('\n'));
if (r.status !== 0 || r.timedOut || SCRIPT_ERROR.test(r.out) || !r.out.includes('pose review complete true')) {
  console.error(`gunner poses failed (${describe(r)})`);
  process.exit(1);
}
console.log(`${dir} (${describe(r)})`);
