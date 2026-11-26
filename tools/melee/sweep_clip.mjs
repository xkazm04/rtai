#!/usr/bin/env node
// n31 melee 02p4 part 2: one slow clip per weapon with the hit volume drawn live (sweep_clip.tscn).
//   node tools/melee/sweep_clip.mjs [--weapons=hands,chainsaw,electro_baton,katana,plasma_sword] [--swings=4]
//     [--slow=4] [--tag=02p4] [--no-render (re-encode the last avis)] [--out=C:/Users/kazda/kiro/gtai-masters/n31/melee]
// Per weapon two windowed d3d12 Movie Maker runs at 64 px/m, tilt 70, 1080p60: `--melee-sweep=off` (main) and
// `--melee-sweep` (n31 sweep); each cropped 960x1080 around Rivet, side by side, labelled, slowed --slow x
// (setpts) -> <out>/slow_<weapon>.mp4. Takes the lane Godot lock per run (first word --tag).
import { execFileSync } from 'node:child_process';
import { mkdirSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { ROOT } from '../lib/repo.mjs';
import { runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';

const arg = (k, d) => process.argv.find((a) => a.startsWith(`--${k}=`))?.slice(k.length + 3) ?? d;
const weapons = arg('weapons', 'hands,chainsaw,electro_baton,katana,plasma_sword').split(',');
const swings = arg('swings', '4');
const slow = Number(arg('slow', '4'));
const tag = arg('tag', '02p4');
const out = arg('out', 'C:/Users/kazda/kiro/gtai-masters/n31/melee');
const LOCK = join(ROOT, 'build/n31/godot.lock');
const scratch = join(ROOT, `build/n31/${tag}/clip`);
const BASE = ['--enemy-brain=squad', '--silent', '--seed=20261109', '--cam-lock=5,-38', '--ppm=64', '--clean'];
const ARMS = [['main', '--melee-sweep=off'], ['sweep', '--melee-sweep']];
const FONT = "fontfile='C\\:/Windows/Fonts/arialbd.ttf'";
mkdirSync(scratch, { recursive: true });
mkdirSync(out, { recursive: true });

function takeLock() {
  for (;;) {
    try { writeFileSync(LOCK, `${tag} ${process.pid} ${new Date().toTimeString().slice(0, 8)}\n`, { flag: 'wx' }); return; }
    catch {
      let age = 0;
      try { age = Date.now() - statSync(LOCK).mtimeMs; } catch { continue; }
      if (age > 30 * 60 * 1000) rmSync(LOCK, { force: true });
      else Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, 10000);
    }
  }
}

async function render(w, arm, flag) {
  const avi = join(scratch, `${arm}_${w}.avi`);
  if (process.argv.includes('--no-render')) return avi;
  rmSync(avi, { force: true });
  takeLock();
  try {
    const r = await runGodot(['--rendering-driver', 'd3d12', '--position', '0,1440', '--resolution', '1920x1080',
      '--write-movie', avi, '--fixed-fps', '60', 'res://dev/melee_n31/sweep_clip.tscn', '--', ...BASE, `--blade=${w}`,
      `--swings=${swings}`, flag], { headless: false, timeoutMs: 5 * 60_000, stopOn: SCRIPT_ERROR, name: 'sweep-clip',
      onLine: (l) => /sweep_clip|SCRIPT ERROR/.test(l) && console.log(l) });
    writeFileSync(join(scratch, `${arm}_${w}.log`), r.out);
    if (r.status !== 0 || SCRIPT_ERROR.test(r.out)) throw new Error(`clip ${w} ${arm} failed (status ${r.status})`);
  } finally { rmSync(LOCK, { force: true }); }
  return avi;
}

const label = (text) => `drawtext=${FONT}:text='${text}':x=24:y=20:fontsize=34:fontcolor=0xf4ecd8:box=1:` +
  'boxcolor=0x15171b@0.75:boxborderw=8';

for (const w of weapons) {
  const [main, sweep] = [await render(w, ...ARMS[0]), await render(w, ...ARMS[1])];
  const mp4 = join(out, `slow_${w}.mp4`);
  // the middle half of each run (the Movie Maker frame is the window's size, 1280x800 here), side by side,
  // fitted to 1080 lines and padded to 1920x1080
  const crop = 'trim=start_frame=58,setpts=PTS-STARTPTS,crop=iw/2:ih:iw/4:0';  // from the press, not the warm-up
  execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', '-i', main, '-i', sweep, '-filter_complex',
    `[0:v]${crop},${label('main (flag off)')}[a];[1:v]${crop},${label('n31 sweep')}[b];` +
    `[a][b]hstack=inputs=2,scale=-2:1080,pad=1920:1080:(ow-iw)/2:0:color=0x15171b,setpts=${slow}*PTS,fps=60,drawtext=${FONT}:text='${w}  x${slow} slower  64 px/m':` +
    'x=(w-tw)/2:y=h-60:fontsize=30:fontcolor=0xf4ecd8:box=1:boxcolor=0x15171b@0.75:boxborderw=8[v]',
    '-map', '[v]','-c:v', 'libx264', '-crf', '18', '-pix_fmt', 'yuv420p', '-an', mp4], { stdio: 'inherit' });
  const dur = execFileSync('ffprobe', ['-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', mp4],
    { encoding: 'utf8' }).trim();
  console.log(`${w}: ${mp4} ${dur} s`);
}
