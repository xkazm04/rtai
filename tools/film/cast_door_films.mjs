#!/usr/bin/env node
// The door carrier at a true 1920 x 1080 on its two walks. "four" = the committed tree (the shipped four-drawing
// anchored walk while CastDoorAnchors.WALK is FOUR); "eight" = a staged copy whose features/characters files select
// the n29 eight-drawing walk (CastDoorAnchors.WALK = EIGHT; CastCardKinds keys rows and cell ratio on FOUR / EIGHT and
// FoeShieldCardView.walk_sheet does the sheet swap; the real tree is never touched). FoeShieldCardView re-plants the
// anchored sole after its height rescale in the tree since n29-09, so the old "keep" probe is gone.
//   stills: 64 px/m, right facing, the same tick, four left | eight right -> door8_feet_before_after_64.png
//   clip:   the eight at 32 px/m, right then down-right -> door8_walk_32.mp4
//   feet:   cast_feet.tscn at 64 px/m on shield_robot, both pitches, both walks, analysed by cast_door_feet.py
// usage: node tools/film/cast_door_films.mjs <output-dir> [stills|clip|feet|all]
import { copyFileSync, existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, symlinkSync,
  writeFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { join, resolve } from 'node:path';
import { ROOT } from '../lib/repo.mjs';
import { describe, runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';

const [out, what = 'all'] = process.argv.slice(2);
if (!out || !['stills', 'clip', 'feet', 'all'].includes(what)) {
  console.error('usage: node tools/film/cast_door_films.mjs <output-dir> [stills|clip|feet|all]'); process.exit(2);
}
const SPEED = 1.6;
const CHARS = 'features/characters';
// [file, from, to]: the eight-drawing switch (one value since n29-11: WALK70/55 and WALK_STEP_M follow WALK),
// applied to the staged copies only.
const EIGHT_PATCH = [['cast_door_anchors.gd', 'const WALK: String = FOUR', 'const WALK: String = EIGHT']];

function link(a, b) { symlinkSync(a, b, process.platform === 'win32' ? 'junction' : 'dir'); }

function mirror(source, dst, deep) {
  mkdirSync(dst);
  for (const f of readdirSync(source, { withFileTypes: true })) {
    const a = join(source, f.name), b = join(dst, f.name);
    if (f.isDirectory() && deep[f.name]) mirror(a, b, deep[f.name]);
    else if (f.isDirectory()) link(a, b);
    else if (f.name !== 'project.godot') copyFileSync(a, b);
  }
}

function stageProject(dir, eight) {
  const source = join(ROOT, 'project'), dst = join(dir, 'project');
  mirror(source, dst, { features: { characters: {}, combat: { squad: {} } } });
  const config = readFileSync(join(source, 'project.godot'), 'utf8');
  writeFileSync(join(dst, 'project.godot'), config.replace(/viewport_width=\d+/, 'viewport_width=1920')
    .replace(/viewport_height=\d+/, 'viewport_height=1080') + '\n[threading]\nworker_pool/max_threads=4\n');
  for (const [file, from, to] of eight ? EIGHT_PATCH : []) {
    const path = join(dst, CHARS, file), text = readFileSync(path, 'utf8');
    if (!text.includes(from)) throw Error(`eight switch: ${file} has no "${from}"`);
    writeFileSync(path, text.replace(from, to));
  }
}

const work = join(ROOT, 'build', 'film');
mkdirSync(work, { recursive: true });
const dirs = {};
const walks = ['four', 'eight'];
for (const walk of walks) {
  dirs[walk] = mkdtempSync(join(work, `door9-${walk}-`));
  stageProject(dirs[walk], walk === 'eight');
}
const outDir = resolve(out);
mkdirSync(outDir, { recursive: true });
const soles = join(ROOT, 'build', 'cast', 'door_film_soles.json');
mkdirSync(join(ROOT, 'build', 'cast'), { recursive: true });
execFileSync('python', [join(ROOT, 'tools/art/cast_door_film_soles.py'), soles], { cwd: join(ROOT, 'tools/art'), stdio: 'inherit' });

async function godot(walk, args, env, label, expect) {
  const r = await runGodot(['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440', '--fixed-fps', '60',
    '--audio-driver', 'Dummy', ...args], { cwd: dirs[walk], name: 'cast-door8', ensure: false, headless: false,
    timeoutMs: 900000, stopOn: SCRIPT_ERROR, env: { ...process.env, ...env } });
  if (r.status !== 0 || SCRIPT_ERROR.test(r.out) || (expect && !existsSync(expect))) {
    writeFileSync(join(dirs[walk], 'fail.log'), r.out);
    throw Error(`${label} failed (${describe(r)}), see ${join(dirs[walk], 'fail.log')}`);
  }
  console.log(label, describe(r));
}

function take(walk, ppm, dirName, ticks, still, avi) {
  const extra = avi ? ['--write-movie', avi, '--quit-after', String(ticks + 40)] : [];
  return godot(walk, ['--resolution', '1920x1080', ...extra, 'res://dev/cast/cast_foot_film.tscn'],
    { GTAI_CAST_PPM: String(ppm), GTAI_CAST_SUBJECT: 'shield_robot', GTAI_CAST_SPEED: String(SPEED),
      GTAI_CAST_TICKS: String(ticks), GTAI_CAST_SOLES: soles, GTAI_CAST_STILL: still ?? '', GTAI_CAST_DIR: dirName },
    `${walk} ${ppm} ${dirName}`, still ?? avi);
}

if (what === 'stills' || what === 'all') {
  const stills = [];
  for (const walk of ['four', 'eight']) {
    stills.push(join(dirs[walk], `door_${walk}_64.png`));
    await take(walk, 64, 'right', 150, stills.at(-1), null);
  }
  execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', '-i', stills[0], '-i', stills[1], '-filter_complex',
    '[0]crop=960:1080:480:0[a];[1]crop=960:1080:480:0[b];[a][b]hstack', join(outDir, 'door8_feet_before_after_64.png')],
  { windowsHide: true, stdio: 'inherit' });
}
if (what === 'clip' || what === 'all') {
  const mp4s = [];
  for (const [name, ticks] of [['right', 900], ['downright', 600]]) {
    const avi = join(dirs.eight, `door8_${name}.avi`);
    await take('eight', 32, name, ticks, null, avi);
    mp4s.push(avi.replace('.avi', '.mp4'));
    execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', '-i', avi, '-c:v', 'libx264', '-crf', '18',
      '-pix_fmt', 'yuv420p', '-r', '60', mp4s.at(-1)], { windowsHide: true, stdio: 'inherit' });
  }
  const list = join(dirs.eight, 'list.txt');
  writeFileSync(list, mp4s.map((m) => `file '${m.split('\\').join('/')}'`).join('\n'));
  execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', '-f', 'concat', '-safe', '0', '-i', list,
    '-c', 'copy', join(outDir, 'door8_walk_32.mp4')], { windowsHide: true, stdio: 'inherit' });
}
if (what === 'feet' || what === 'all') {
  for (const walk of walks) {
    const dest = join(outDir, `feet_${walk}`);
    mkdirSync(dest, { recursive: true });
    for (const pitch of ['70', '55']) {
      await godot(walk, ['--resolution', '1280x720', 'res://dev/cast/cast_feet.tscn'], { GTAI_CAST_OUT: dest,
        GTAI_CAST_PPM: '64', GTAI_CAST_PITCH: pitch, GTAI_CAST_SUBJECT: 'shield_robot' }, `feet ${walk} ${pitch}`,
      join(dest, `tracks_${pitch}_64.json`));
    }
    execFileSync('python', [join(ROOT, 'tools/art/cast_door_feet.py'), dest, '64'], { cwd: join(ROOT, 'tools/art'),
      stdio: 'inherit' });
  }
}
console.log('work dirs', ...Object.values(dirs));
