#!/usr/bin/env node
// The pile-driver (war_machine card) at a true 1920 x 1080 on its walks, the cast_door_films.mjs twin. Staged copies,
// the real tree is never touched: "four" = the committed tree (CastWarAnchors.WALK as committed; the held-foot view
// again since the n29 pad placement was reverted); "eight" = a copy whose cast_war_anchors.gd selects WALK = EIGHT;
// "before" = the four with FoeWarCardView from 20be6ffaa (the held
// foot before the n29 pad placement 5d8e4b6f8: that commit changed only the view and its test); "eight_held" = the
// eight on that held-foot view (what the eight art does without the pad placement).
//   stills: 64 px/m, right facing, the same tick, four left | eight right -> war8_feet_before_after_64.png
//   clip:   the eight (staged preview, WALK = EIGHT) at 32 px/m, right then down-right -> war8_walk_32.mp4
//   feet:   cast_feet.tscn at 64 px/m on war_machine, both pitches, cast_war_feet.py (pad, + n28 on the four)
// usage: node tools/film/cast_war_films.mjs <output-dir> [stills|clip|feet|all] [feet walks, default before,four,eight]
import { copyFileSync, existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, symlinkSync,
  writeFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { join, resolve } from 'node:path';
import { ROOT } from '../lib/repo.mjs';
import { describe, runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';

const [out, what = 'all', feetArg = 'before,four,eight'] = process.argv.slice(2);
if (!out || !['stills', 'clip', 'feet', 'all'].includes(what)) {
  console.error('usage: node tools/film/cast_war_films.mjs <output-dir> [stills|clip|feet|all]'); process.exit(2);
}
const SPEED = 1.8;
const CHARS = 'features/characters';
const VIEW = 'features/combat/squad/foe_war_card_view.gd';
// The eight-drawing switch (WALK70/55, WALK_STEP_M and WALK_ROWS follow WALK), applied to the staged copy only.
const EIGHT_PATCH = [['cast_war_anchors.gd', 'const WALK: String = FOUR', 'const WALK: String = EIGHT']];
const BEFORE = '20be6ffaa';

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

function stageProject(dir, walk) {
  const source = join(ROOT, 'project'), dst = join(dir, 'project');
  mirror(source, dst, { features: { characters: {}, combat: { squad: {} } } });
  const config = readFileSync(join(source, 'project.godot'), 'utf8');
  writeFileSync(join(dst, 'project.godot'), config.replace(/viewport_width=\d+/, 'viewport_width=1920')
    .replace(/viewport_height=\d+/, 'viewport_height=1080') + '\n[threading]\nworker_pool/max_threads=4\n');
  for (const [file, from, to] of walk.startsWith('eight') ? EIGHT_PATCH : []) {
    const path = join(dst, CHARS, file), text = readFileSync(path, 'utf8');
    if (!text.includes(from)) throw Error(`eight switch: ${file} has no "${from}"`);
    writeFileSync(path, text.replace(from, to));
  }
  if (walk === 'before' || walk === 'eight_held') {
    writeFileSync(join(dst, VIEW), execFileSync('git', ['show', `${BEFORE}:project/${VIEW}`], { cwd: ROOT }));
  }
}

const work = join(ROOT, 'build', 'film');
mkdirSync(work, { recursive: true });
const feetWalks = feetArg.split(',');
if (feetWalks.some((w) => !['before', 'four', 'eight', 'eight_held'].includes(w))) throw Error(`feet walks: ${feetArg}`);
const walks = { stills: ['four', 'eight'], clip: ['eight'], feet: feetWalks,
  all: [...new Set(['four', 'eight', ...feetWalks])] }[what];
const dirs = {};
for (const walk of walks) {
  dirs[walk] = mkdtempSync(join(work, `war8-${walk}-`));
  stageProject(dirs[walk], walk);
}
const outDir = resolve(out);
mkdirSync(outDir, { recursive: true });
const soles = join(ROOT, 'build', 'cast', 'war_film_soles.json');
mkdirSync(join(ROOT, 'build', 'cast'), { recursive: true });
execFileSync('python', [join(ROOT, 'tools/art/cast_war_feet.py'), '--film-soles', soles],
  { cwd: join(ROOT, 'tools/art'), stdio: 'inherit' });

async function godot(walk, args, env, label, expect) {
  const r = await runGodot(['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440', '--fixed-fps', '60',
    '--audio-driver', 'Dummy', ...args], { cwd: dirs[walk], name: 'cast-war8', ensure: false, headless: false,
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
    { GTAI_CAST_PPM: String(ppm), GTAI_CAST_SUBJECT: 'war_machine', GTAI_CAST_SPEED: String(SPEED),
      GTAI_CAST_TICKS: String(ticks), GTAI_CAST_SOLES: soles, GTAI_CAST_STILL: still ?? '', GTAI_CAST_DIR: dirName },
    `${walk} ${ppm} ${dirName}`, still ?? avi);
}

if (what === 'stills' || what === 'all') {
  const stills = [];
  for (const walk of ['four', 'eight']) {
    stills.push(join(dirs[walk], `war_${walk}_64.png`));
    await take(walk, 64, 'right', 150, stills.at(-1), null);
  }
  execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', '-i', stills[0], '-i', stills[1], '-filter_complex',
    '[0]crop=960:1080:480:0[a];[1]crop=960:1080:480:0[b];[a][b]hstack', join(outDir, 'war8_feet_before_after_64.png')],
  { windowsHide: true, stdio: 'inherit' });
}
if (what === 'clip' || what === 'all') {
  const mp4s = [];
  for (const [name, ticks] of [['right', 900], ['downright', 600]]) {
    const avi = join(dirs.eight, `war8_${name}.avi`);
    await take('eight', 32, name, ticks, null, avi);
    mp4s.push(avi.replace('.avi', '.mp4'));
    execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', '-i', avi, '-c:v', 'libx264', '-crf', '18',
      '-pix_fmt', 'yuv420p', '-r', '60', mp4s.at(-1)], { windowsHide: true, stdio: 'inherit' });
  }
  const list = join(dirs.eight, 'list.txt');
  writeFileSync(list, mp4s.map((m) => `file '${m.split('\\').join('/')}'`).join('\n'));
  execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', '-f', 'concat', '-safe', '0', '-i', list,
    '-c', 'copy', join(outDir, 'war8_walk_32.mp4')], { windowsHide: true, stdio: 'inherit' });
}
if (what === 'feet' || what === 'all') {
  for (const walk of feetWalks) {
    const dest = join(outDir, `feet_${walk}`);
    mkdirSync(dest, { recursive: true });
    for (const pitch of ['70', '55']) {
      await godot(walk, ['--resolution', '1280x720', 'res://dev/cast/cast_feet.tscn'], { GTAI_CAST_OUT: dest,
        GTAI_CAST_PPM: '64', GTAI_CAST_PITCH: pitch, GTAI_CAST_SUBJECT: 'war_machine' }, `feet ${walk} ${pitch}`,
      join(dest, `tracks_${pitch}_64.json`));
    }
    for (const reader of walk.startsWith('eight') ? ['pad'] : ['pad', 'n28']) {
      console.log(`== ${walk} reader ${reader}`);
      execFileSync('python', [join(ROOT, 'tools/art/cast_war_feet.py'), dest, '64', `--reader=${reader}`],
        { cwd: join(ROOT, 'tools/art'), stdio: 'inherit' });
    }
  }
}
console.log('work dirs', ...Object.values(dirs));
