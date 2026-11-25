#!/usr/bin/env node
// One windowed yard_film take through runGodot (mem-budget wait, tree-kill timeout, ledger):
//   node tools/art/prologue_yard_film.mjs --dressing=arched_line --place=mid --tick=2290 --ppm=32 --still=<png>
//   node tools/art/prologue_yard_film.mjs --dressing=arched_line --place=mid --tick=1757 --frames=1500 --ppm=32 --movie=<avi>
// 1920x1080, d3d12, secondary screen, --fixed-fps 60. Extra flags after `--` go to yard_film (e.g. --cast-card=off).
import { runGodot } from '../lib/godot.mjs';
import { copyFileSync, existsSync, mkdirSync, readdirSync, symlinkSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

// The movie writer reads its quality and the 1920x1080 viewport from the project profile at engine startup,
// before scene scripts run, and `--path project` has 1280x800. So a movie runs from `build/prologue-film`:
// junctions to every project dir, copies of its files, plus an override.cfg (the same profile as
// project/dev/prologue/capture/film.ps1). Rebuilt on every movie take so it never goes stale.
const PROFILE = `[display]
window/size/viewport_width=1920
window/size/viewport_height=1080
window/size/window_width_override=1920
window/size/window_height_override=1080
[editor]
movie_writer/video_quality=0.32
`;

export function prepareFilmProject(root) {
  const project = join(root, 'project');
  const film = join(root, 'build', 'prologue-film');
  mkdirSync(film, { recursive: true });
  for (const e of readdirSync(project, { withFileTypes: true })) {
    const to = join(film, e.name);
    if (e.isDirectory()) {
      if (!existsSync(to)) symlinkSync(join(project, e.name), to, 'junction');
    } else if (e.name !== 'override.cfg') copyFileSync(join(project, e.name), to);
  }
  writeFileSync(join(film, 'override.cfg'), PROFILE);
  return film;
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) await main();

async function main() {

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
  const filmDir = movie ? prepareFilmProject(resolve(dirname(fileURLToPath(import.meta.url)), '..', '..')) : null;
  const engine = [...(filmDir ? ['--path', filmDir] : []), '--windowed', '--rendering-driver', 'd3d12', '--position', '0,1440', '--resolution', '1920x1080', '--fixed-fps', '60',
    ...(movie ? ['--write-movie', resolve(movie)] : []), 'res://dev/prologue_yard/yard_film.tscn', '--', ...game];
  const r = await runGodot(engine, { headless: false, timeoutMs: 1500 * 1000, name: 'yard_film' });
  const out = String(r.out ?? '');
  const errors = (out.match(/SCRIPT ERROR/g) ?? []).length;
  console.log(`yard_film exit ${r.status}; SCRIPT ERROR ${errors}; ` + (out.split('\n').filter((l) => l.includes('yard-film')).pop() ?? ''));
  process.exitCode = r.status === 0 && errors === 0 ? 0 : 1;
}
