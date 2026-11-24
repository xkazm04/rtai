#!/usr/bin/env node
// The door carrier at a true 1920 x 1080: before/after stills at 64 px/m (sole dots, contact bracketed) and one
// 32 px/m clip (right, then down-right). "Before" renames CastDoorAnchors.SHEET in the working tree for the run
// (the anchored placement then never matches the sheet: the shipped four-drawing walk) and restores the file.
// usage: node tools/film/cast_door_films.mjs <output-dir> [stills|clip|all]
import { copyFileSync, existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, symlinkSync,
  writeFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { join, resolve } from 'node:path';
import { ROOT } from '../lib/repo.mjs';
import { describe, runGodot } from '../lib/godot.mjs';

const [out, what = 'all'] = process.argv.slice(2);
if (!out) { console.error('usage: node tools/film/cast_door_films.mjs <output-dir> [stills|clip|all]'); process.exit(2); }
const SPEED = 1.6;
const anchors = join(ROOT, 'project/features/characters/cast_door_anchors.gd');

function stageProject(dir) {
  const source = join(ROOT, 'project'), dst = join(dir, 'project');
  mkdirSync(dst);
  for (const f of readdirSync(source, { withFileTypes: true })) {
    const a = join(source, f.name), b = join(dst, f.name);
    if (f.isDirectory()) symlinkSync(a, b, process.platform === 'win32' ? 'junction' : 'dir');
    else if (f.name !== 'project.godot') copyFileSync(a, b);
  }
  const config = readFileSync(join(source, 'project.godot'), 'utf8');
  writeFileSync(join(dst, 'project.godot'), config.replace(/viewport_width=\d+/, 'viewport_width=1920')
    .replace(/viewport_height=\d+/, 'viewport_height=1080') + '\n[threading]\nworker_pool/max_threads=4\n');
}

const work = join(ROOT, 'build', 'film');
mkdirSync(work, { recursive: true });
const dir = mkdtempSync(join(work, 'door-'));
stageProject(dir);
const outDir = resolve(out);
mkdirSync(outDir, { recursive: true });
const soles = join(ROOT, 'build', 'cast', 'door_film_soles.json');

async function take(mode, ppm, dirName, ticks, still, avi) {
  const original = readFileSync(anchors, 'utf8');
  if (mode === 'before') writeFileSync(anchors, original.replace('"shield_robot_armed_walk.png"', '"shield_robot_armed_walk_off.png"'));
  try {
    const extra = avi ? ['--write-movie', avi, '--quit-after', String(ticks + 40)] : [];
    const args = ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440', '--resolution', '1920x1080',
      '--fixed-fps', '60', '--audio-driver', 'Dummy', ...extra, 'res://dev/cast/cast_foot_film.tscn'];
    const r = await runGodot(args, { cwd: dir, name: 'cast-door-film', ensure: false, headless: false,
      timeoutMs: 900000, stopOn: /SCRIPT ERROR|SHADER ERROR/i,
      env: { ...process.env, GTAI_CAST_PPM: String(ppm), GTAI_CAST_SUBJECT: 'shield_robot', GTAI_CAST_SPEED: String(SPEED),
        GTAI_CAST_TICKS: String(ticks), GTAI_CAST_SOLES: soles, GTAI_CAST_STILL: still ?? '', GTAI_CAST_DIR: dirName } });
    if (r.status !== 0 || (still && !existsSync(still)) || (avi && !existsSync(avi))) {
      writeFileSync(join(dir, 'fail.log'), r.out);
      throw Error(`${mode} ${ppm} ${dirName} failed (${describe(r)}), see ${join(dir, 'fail.log')}`);
    }
    console.log(mode, ppm, dirName, describe(r));
  } finally { writeFileSync(anchors, original); }
}

if (what !== 'clip') {
  for (const mode of ['before', 'after']) await take(mode, 64, 'right', 150, join(outDir, `door_${mode}_64.png`), null);
}
if (what !== 'stills') {
  const parts = [];
  for (const [name, ticks] of [['right', 900], ['downright', 600]]) {
    const avi = join(dir, `door_${name}.avi`);
    await take('after', 32, name, ticks, null, avi);
    parts.push(avi);
  }
  const list = join(dir, 'list.txt');
  const mp4s = [];
  for (const avi of parts) {
    const mp4 = avi.replace('.avi', '.mp4');
    execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', '-i', avi, '-c:v', 'libx264', '-crf', '18',
      '-pix_fmt', 'yuv420p', '-r', '60', mp4], { windowsHide: true, stdio: 'inherit' });
    mp4s.push(mp4);
  }
  writeFileSync(list, mp4s.map((m) => `file '${m.split('\\').join('/')}'`).join('\n'));
  execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', '-f', 'concat', '-safe', '0', '-i', list,
    '-c', 'copy', join(outDir, 'feet_door_32.mp4')], { windowsHide: true, stdio: 'inherit' });
}
console.log('work dir', dir);
