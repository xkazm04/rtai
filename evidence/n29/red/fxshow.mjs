// The FX showcase (every fx kind, incl. explosion = fx_atlas cells 9-12) at 32/48/64 px/m.
// node evidence/n29/red/fxshow.mjs <out dir>
import { mkdirSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { runGodot } from '../../../tools/lib/godot.mjs';

const dir = resolve(process.argv[2]);
mkdirSync(dir, { recursive: true });
const args = ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440', '--resolution', '1920x1080',
  '--fixed-fps', '60', 'res://dev/selftest/fx_showcase.tscn', '--', '--out=' + dir.split(String.fromCharCode(92)).join('/')];
const r = await runGodot(args, { headless: false, timeoutMs: 240000, name: 'red-fire-fxshow' });
writeFileSync(resolve(dir, 'take.log'), r.out);
console.log('exit', r.status, 'timedOut', r.timedOut, dir);
