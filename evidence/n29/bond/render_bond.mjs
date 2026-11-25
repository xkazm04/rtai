// Render one bond_film take natively and encode it. Run from the repo root:
//   node evidence/n29/bond/render_bond.mjs <out.mp4|dir> <32|64> <seed> <prefill> <fromTick> <toTick> [--waves=4]
// 32: films/bond_mastery.mp4 (all frames in the tick window); 64: the jpg frames stay in build/n29-films/<tag>.
import { execFileSync } from 'node:child_process';
import { mkdirSync, rmSync } from 'node:fs';
import { resolve } from 'node:path';
import { runGodot } from '../../../tools/lib/godot.mjs';

const [out, ppm, seed, prefill, from, to, ...rest] = process.argv.slice(2);
const waves = (rest.find(a => a.startsWith('--waves=')) ?? '--waves=4');
const tag = `bond-${ppm}-s${seed}-p${prefill}`;
const dir = resolve('build/n29-films', tag);
rmSync(dir, { recursive: true, force: true });
mkdirSync(dir, { recursive: true });
const scene = ppm === '64' ? 'res://dev/ghost-forms/bond_film_64.tscn' : 'res://dev/ghost-forms/bond_film.tscn';
const args = ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440', '--resolution', '1920x1080',
  '--fixed-fps', '60', '--path', resolve('project'), scene, '--', '--bot=expert', '--pick=greedy', '--controls=wheel',
  `--seed=${seed}`, waves, `--bond-prefill=${prefill}`, '--result=' + resolve(dir, 'result.json')];
const env = { ...process.env, GTAI_FILM_DIR: dir, GTAI_FILM_FROM: from, GTAI_FILM_TO: to };
const r = await runGodot(args, { headless: false, timeoutMs: 900000, name: 'bond-film', env });
const fs = await import('node:fs');
fs.writeFileSync(resolve(dir, 'film.log'), r.out);
if (r.status !== 0 || r.timedOut || /SCRIPT ERROR:|\[ERROR\]/.test(r.out)) throw Error('failed, see ' + dir);
console.log(r.out.split('\n').filter(l => /bond-film: (tick|capture)/.test(l)).join('\n'));
if (ppm === '32') {
  mkdirSync(resolve(out, '..'), { recursive: true });
  execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', '-framerate', '60', '-i', resolve(dir, '%05d.jpg'),
    '-c:v', 'libx264', '-preset', 'veryfast', '-crf', '16', '-pix_fmt', 'yuv420p', '-movflags', '+faststart', resolve(out)],
  { windowsHide: true });
}
console.log('done', tag, dir);
