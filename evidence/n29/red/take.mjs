// One arena take with tick-exact stills (FilmProbe --film-stills). Run from the repo root:
// node evidence/n29/red/take.mjs <out dir> <ticks a,b,c> <arena flags...>
import { mkdirSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { runGodot } from '../../../tools/lib/godot.mjs';

const [out, ticks, ...flags] = process.argv.slice(2);
const dir = resolve(out);
mkdirSync(dir, { recursive: true });
const args = ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440', '--resolution', '1920x1080',
  '--fixed-fps', '60', 'res://dev/arena/arena.tscn', '--', ...flags, '--film-dir=' + dir.split(String.fromCharCode(92)).join('/'),
  '--film-stills=' + ticks];
const r = await runGodot(args, { headless: false, timeoutMs: 240000, name: 'red-fire-take' });
writeFileSync(resolve(dir, 'take.log'), r.out);
console.log('exit', r.status, 'timedOut', r.timedOut, dir);
