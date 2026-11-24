// The contractor's stop, turn and reversal takes at both pitches (32 px/m), card row forced on.
// Set APPDATA and GODOT_BIN first. usage: node tools/art/cast_contractor_turns.mjs <output directory>
import { mkdirSync } from 'node:fs';
import { resolve, join } from 'node:path';
import { spawnSync } from 'node:child_process';
import { describe, runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';

const out = process.argv[2];
if (process.argv.length !== 3 || !out) {
  console.error('usage: node tools/art/cast_contractor_turns.mjs <output directory>');
  process.exit(2);
}
const dir = resolve(out);
mkdirSync(dir, { recursive: true });
for (const pitch of ['70', '55']) {
  const env = { ...process.env, GTAI_CAST_OUT: dir, GTAI_CAST_PPM: '32', GTAI_CAST_PITCH: pitch,
    GTAI_CAST_SUBJECT: 'contractor', GTAI_CAST_FORCE: 'contractor' };
  const args = ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440',
    '--resolution', '1280x720', '--fixed-fps', '60', 'res://dev/cast/cast_contractor_turns.tscn'];
  const r = await runGodot(args, { headless: false, env, name: 'cast-contractor-turns',
    timeoutMs: 420_000, stopOn: SCRIPT_ERROR });
  if (r.status !== 0 || r.timedOut || SCRIPT_ERROR.test(r.out)) {
    console.error(r.out.split('\n').slice(-40).join('\n'), describe(r));
    process.exit(1);
  }
  console.log(`pitch ${pitch} (${describe(r)})`);
}
const a = spawnSync('python', ['tools/art/cast_contractor_transitions.py', join(dir)], { stdio: 'inherit' });
process.exit(a.status ?? 1);
