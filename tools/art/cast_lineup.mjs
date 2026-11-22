// Render the four native-size plates sequentially. Set APPDATA and GODOT_BIN before launching.
import { statSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { describe, runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';

const out = process.argv[2];
if (process.argv.length !== 3 || !out) {
  console.error('usage: node tools/art/cast_lineup.mjs <output directory>');
  process.exit(2);
}
const directory = resolve(out);
const args = ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440',
  '--resolution', '1920x1080', '--fixed-fps', '60', '--quit-after', '4000',
  'res://dev/cast/cast_lineup.tscn'];
for (const pitch of [70, 55]) {
  for (const ppm of [32, 64]) {
    const image = join(directory, `audit_lineup_${ppm}ppm_tilt${pitch}.png`);
    const start = Date.now();
    const env = { ...process.env, GTAI_CAST_OUT: directory, GTAI_CAST_PITCH: String(pitch),
      GTAI_CAST_PPM: String(ppm) };
    const result = await runGodot(args, { env, name: 'cast-lineup', headless: false, timeoutMs: 180_000 });
    const file = statSync(image, { throwIfNoEntry: false });
    console.log(result.out.trimEnd());
    if (result.status !== 0 || result.timedOut || SCRIPT_ERROR.test(result.out)
        || !file?.size || file.mtimeMs < start || !result.out.includes('cast: saved ')) {
      console.error(`cast lineup failed at ${ppm} px/m, pitch ${pitch} (${describe(result)})`);
      process.exit(1);
    }
    console.log(`${image} (${describe(result)})`);
  }
}
