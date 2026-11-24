#!/usr/bin/env node
// One windowed yard_film take through runGodot (mem-budget wait, tree-kill timeout, ledger):
//   node tools/art/prologue_yard_film.mjs --dressing=arched_line --place=mid --tick=2290 --ppm=32 --still=<png>
//   node tools/art/prologue_yard_film.mjs --dressing=arched_line --place=mid --tick=1757 --frames=1500 --ppm=32 --movie=<avi>
// 1920x1080, d3d12, secondary screen, --fixed-fps 60. Extra flags after `--` go to yard_film (e.g. --cast-card=off).
import { runGodot } from '../lib/godot.mjs';

const argv = process.argv.slice(2);
const dash = argv.indexOf('--');
const own = dash >= 0 ? argv.slice(0, dash) : argv;
const extra = dash >= 0 ? argv.slice(dash + 1) : [];
const get = (k) => own.find((a) => a.startsWith(`--${k}=`))?.slice(k.length + 3);
const still = get('still');
const movie = get('movie');
if (!still === !movie || !get('dressing') || !get('place') || !get('tick') || !get('ppm')) {
  console.error('usage: prologue_yard_film.mjs --dressing=<id> --place=<gate|mid|front> --tick=<n> [--frames=<n>] --ppm=<n> (--still=<png> | --movie=<avi>)');
  process.exit(2);
}
const game = ['--yard-dressing=' + get('dressing'), '--place=' + get('place'), '--tick=' + get('tick'),
  '--frames=' + (get('frames') ?? '1'), '--ppm=' + get('ppm'), ...(still ? ['--still=' + still] : []), ...extra];
const engine = ['--windowed', '--rendering-driver', 'd3d12', '--position', '0,1440', '--resolution', '1920x1080', '--fixed-fps', '60',
  ...(movie ? ['--write-movie', movie] : []), 'res://dev/prologue_yard/yard_film.tscn', '--', ...game];
const r = await runGodot(engine, { headless: false, timeoutMs: 1500 * 1000, name: 'yard_film' });
const out = String(r.out ?? '');
const errors = (out.match(/SCRIPT ERROR/g) ?? []).length;
console.log(`yard_film exit ${r.status}; SCRIPT ERROR ${errors}; ` + (out.split('\n').filter((l) => l.includes('yard-film')).pop() ?? ''));
process.exitCode = r.status === 0 && errors === 0 ? 0 : 1;
