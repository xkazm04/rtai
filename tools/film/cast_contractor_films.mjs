#!/usr/bin/env node
// The contractor fight at a true 1920 x 1080, at 32 and 64 px/m. Movie Maker takes its size from the
// project viewport, so a scratch project mounts the live assets with that viewport (as ghost_films).
// usage: node tools/film/cast_contractor_films.mjs <output-dir> [32|64 ...]
import { execFileSync } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, symlinkSync,
  writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { ROOT } from '../lib/repo.mjs';
import { describe, runGodot } from '../lib/godot.mjs';

const TICKS = 1220;
const [out, ...takes] = process.argv.slice(2);
if (!out) { console.error('usage: node tools/film/cast_contractor_films.mjs <output-dir> [32|64 ...]'); process.exit(2); }
const sizes = takes.length ? takes : ['32', '64'];

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
const dir = mkdtempSync(join(work, 'contractor-'));
stageProject(dir);
mkdirSync(resolve(out), { recursive: true });
for (const ppm of sizes) {
  const avi = join(dir, `fight_${ppm}.avi`);
  const args = ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440', '--resolution', '1920x1080',
    '--fixed-fps', '60', '--audio-driver', 'Dummy', '--write-movie', avi, '--quit-after', String(TICKS),
    'res://dev/cast/cast_contractor_fight.tscn'];
  const r = await runGodot(args, { cwd: dir, name: 'cast-contractor-film', ensure: false, headless: false,
    timeoutMs: 900000, env: { ...process.env, GTAI_CAST_PPM: ppm, GTAI_CAST_FOES: ppm === '64' ? '1' : '3' }, stopOn: /SCRIPT ERROR|SHADER ERROR/i });
  writeFileSync(join(dir, `fight_${ppm}.log`), r.out);
  if (r.status !== 0 || !existsSync(avi) || !r.out.includes('contractor fight pass true')) {
    throw Error(`take ${ppm} failed (${describe(r)}), see ${join(dir, `fight_${ppm}.log`)}`);
  }
  const mp4 = resolve(out, ppm === '64' ? 'contractor_close_64.mp4' : 'contractor_fight_32.mp4');
  execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', '-i', avi, '-c:v', 'libx264', '-crf', '18',
    '-pix_fmt', 'yuv420p', '-r', '60', mp4], { windowsHide: true, stdio: 'inherit' });
  console.log(ppm + ' px/m', mp4, describe(r));
}
