// One 32 px/m movie of the reel's rocket, flame and molotov chapters (Godot's movie writer, 60 fps, 1080p),
// encoded to mp4. node evidence/n29/red/film.mjs <out.mp4> [extra arena flags...]
import { execFileSync } from 'node:child_process';
import { copyFileSync, mkdirSync, readdirSync, readFileSync, symlinkSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { runGodot } from '../../../tools/lib/godot.mjs';

const [out, ...extra] = process.argv.slice(2);
const work = resolve('build/n29red/film');
mkdirSync(work, { recursive: true });
// The movie writer records the project's base size, so stage a project copy (dirs junctioned) at 1920x1080,
// as tools/film/cast_*_films.mjs do.
const stage = resolve(work, 'stage');
const source = resolve('project'), dst = resolve(stage, 'project');
mkdirSync(dst, { recursive: true });
for (const f of readdirSync(source, { withFileTypes: true })) {
  const a = resolve(source, f.name), b = resolve(dst, f.name);
  if (f.isDirectory()) { try { symlinkSync(a, b, 'junction'); } catch { /* already staged */ } }
  else if (f.name !== 'project.godot') copyFileSync(a, b);
}
writeFileSync(resolve(dst, 'project.godot'), readFileSync(resolve(source, 'project.godot'), 'utf8')
  .replace(/viewport_width=\d+/, 'viewport_width=1920').replace(/viewport_height=\d+/, 'viewport_height=1080')
  + ['', '[threading]', 'worker_pool/max_threads=4', ''].join(String.fromCharCode(10)));
mkdirSync(dirname(resolve(out)), { recursive: true });
const avi = resolve(work, 'take.avi').split(String.fromCharCode(92)).join('/');
const args = ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440', '--resolution', '1920x1080',
  '--fixed-fps', '60', '--audio-driver', 'Dummy', '--write-movie', avi, '--quit-after', '1500', 'res://dev/arena/arena.tscn', '--', '--rigs',
  '--bot=reel', '--reel=director', '--loadout=pistol', '--chapter=rocket_launcher,flamethrower,molotov', '--ppm=32',
  '--clean', '--silent', ...extra];
const r = await runGodot(args, { cwd: stage, ensure: false, headless: false, timeoutMs: 600000, name: 'red-fire-film' });
writeFileSync(resolve(work, 'film.log'), r.out);
console.log('godot exit', r.status, 'timedOut', r.timedOut);
execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', '-i', avi, '-c:v', 'libx264', '-crf', '18',
  '-pix_fmt', 'yuv420p', '-r', '60', resolve(out)], { windowsHide: true });
console.log('wrote', out);
