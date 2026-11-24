// Capture both pitches serially. The optional 64 px/m take also saves a native viewport still.
import { mkdirSync, statSync } from 'node:fs';
import { resolve, join } from 'node:path';
import { spawnSync } from 'node:child_process';
import { describe, runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';

const [out = 'build/cast', ppm = '32', subject = ''] = process.argv.slice(2);
if (!['32', '64'].includes(ppm) || process.argv.length > 5) {
  console.error('usage: node tools/art/cast_feet.mjs [output-directory [32|64 [archetype,...]]]');
  process.exit(2);
}
const directory = resolve(out);
mkdirSync(directory, { recursive: true });
for (const pitch of ['70', '55']) {
  const start = Date.now();
  const env = { ...process.env, GTAI_CAST_OUT: directory, GTAI_CAST_PPM: ppm,
    GTAI_CAST_PITCH: pitch, GTAI_CAST_SUBJECT: subject };
  const args = ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440',
    '--resolution', '1280x720', '--fixed-fps', '60', 'res://dev/cast/cast_feet.tscn'];
  if (ppm === '32' && subject.split(',').includes('patrol_cop')) {
    args.push('--', '--cast-patrol-feet');
  }
  const result = await runGodot(args, { headless: false, env, name: 'cast-feet', timeoutMs: 420_000,
    stopOn: SCRIPT_ERROR });
  const path = join(directory, `tracks_${pitch}_${ppm}.json`);
  const file = statSync(path, { throwIfNoEntry: false });
  if (result.status !== 0 || result.timedOut || SCRIPT_ERROR.test(result.out)
      || !file?.size || file.mtimeMs < start) {
    console.error(result.out, describe(result));
    process.exit(1);
  }
  console.log(`${path} (${describe(result)})`);
}
const analysis = spawnSync('python', ['tools/art/cast_feet.py', directory, ppm, subject], { stdio: 'inherit' });
process.exit(analysis.status ?? 1);
