// One 32 px/m movie of the reel's rocket, flame and molotov chapters (Godot's movie writer, 60 fps, 1080p),
// encoded to mp4. node evidence/n29/red/film.mjs <out.mp4> [extra arena flags...]
import { execFileSync } from 'node:child_process';
import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { runGodot } from '../../../tools/lib/godot.mjs';

const [out, ...extra] = process.argv.slice(2);
const work = resolve('build/n29red/film');
mkdirSync(work, { recursive: true });
mkdirSync(dirname(resolve(out)), { recursive: true });
const avi = resolve(work, 'take.avi').split(String.fromCharCode(92)).join('/');
const args = ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440', '--resolution', '1920x1080',
  '--fixed-fps', '60', '--write-movie', avi, '--quit-after', '1200', 'res://dev/arena/arena.tscn', '--', '--rigs',
  '--bot=reel', '--reel=director', '--loadout=pistol', '--chapter=rocket_launcher,flamethrower,molotov', '--ppm=32',
  '--clean', '--silent', ...extra];
const r = await runGodot(args, { headless: false, timeoutMs: 600000, name: 'red-fire-film' });
writeFileSync(resolve(work, 'film.log'), r.out);
console.log('godot exit', r.status, 'timedOut', r.timedOut);
execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', '-i', avi, '-c:v', 'libx264', '-crf', '18',
  '-pix_fmt', 'yuv420p', '-r', '60', resolve(out)], { windowsHide: true });
console.log('wrote', out);
