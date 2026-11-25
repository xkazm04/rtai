#!/usr/bin/env node
// The n29 cast films at a true 1920 x 1080 (a scratch project carries the viewport, as cast_gunner_films).
// usage: node tools/film/cast_n29_films.mjs size|flash <output.mp4> [ticks] [--stills=<dir>]
import { execFileSync } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, symlinkSync,
  writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { ROOT } from '../lib/repo.mjs';
import { describe, runGodot } from '../lib/godot.mjs';

const SCENES = { size: ['cast_size_beside_walk', 'size walk done', 1980], flash: ['cast_flash_fight', 'flash fight pass', 1500] };
const args = process.argv.slice(2);
const stills = args.find((a) => a.startsWith('--stills='))?.slice(9);
const [kind, out, ticksArg] = args.filter((a) => !a.startsWith('--'));
if (!SCENES[kind] || !out) { console.error('usage: node tools/film/cast_n29_films.mjs size|flash <output.mp4> [ticks] [--stills=<dir>]'); process.exit(2); }
const [scene, ok, defaultTicks] = SCENES[kind];
const ticks = Number(ticksArg ?? defaultTicks);

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
const dir = mkdtempSync(join(work, `n29-${kind}-`));
stageProject(dir);
mkdirSync(dirname(resolve(out)), { recursive: true });
if (stills) mkdirSync(resolve(stills), { recursive: true });
const avi = join(dir, `${kind}.avi`);
const r = await runGodot(['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440', '--resolution', '1920x1080',
  '--fixed-fps', '60', '--audio-driver', 'Dummy', '--write-movie', avi, '--quit-after', String(ticks + 80),
  `res://dev/cast/${scene}.tscn`], { cwd: dir, name: `cast-n29-${kind}`, ensure: false, headless: false, timeoutMs: 1200000,
  env: { ...process.env, GTAI_CAST_TICKS: String(ticks), GTAI_CAST_FLASH_OUT: stills ? resolve(stills) : '' },
  stopOn: /SCRIPT ERROR|SHADER ERROR/i });
writeFileSync(join(dir, `${kind}.log`), r.out);
if (r.status !== 0 || !existsSync(avi) || !r.out.includes(ok)) throw Error(`${kind} failed (${describe(r)}), see ${join(dir, `${kind}.log`)}`);
execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', '-i', avi, '-c:v', 'libx264', '-crf', '18',
  '-pix_fmt', 'yuv420p', '-r', '60', resolve(out)], { windowsHide: true, stdio: 'inherit' });
console.log(kind, resolve(out), describe(r), 'log', join(dir, `${kind}.log`));
