#!/usr/bin/env node
// n31 melee 01b part C: the before play take, one film per weapon (Godot Movie Maker, then ffmpeg).
//   node tools/melee/play_take.mjs [--label=before] [--weapons=katana,plasma_sword,claw] [--seed=7]
//     [--frames=1500] [--ppm=32] [--out=C:/Users/kazda/kiro/gtai-masters/n31/melee]
//     [--game-flags=--melee-sweep,--kill-feed] [--before-flags=--melee-sweep=off] [--tag=01b]
// --game-flags go to the scene after `--` (LaunchArgs and ArenaArgs both read the user args); without it
// a --label=before take gets --before-flags (default --melee-sweep=off = main) and any other label none.
// --tag is the first word of the lane lock and names the scratch dir build/n31/<tag>/take.
// 1080p60, tilt 70, the gauntlet with wheel controls, the average bot holding one melee weapon
// (res://dev/melee_n31/play_baseline_take.tscn). Takes the lane Godot lock. The after run uses the same
// seed/frames/ppm and --label=after so the two films line up tick for tick.
import { mkdirSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { join } from 'node:path';
import { ROOT } from '../lib/repo.mjs';
import { runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';

const arg = (k, d) => process.argv.find((a) => a.startsWith(`--${k}=`))?.slice(k.length + 3) ?? d;
const label = arg('label', 'before');
const weapons = arg('weapons', 'katana,plasma_sword,claw').split(',');
const seed = arg('seed', '7');
const frames = arg('frames', '1500');
const ppm = arg('ppm', '32');
const out = arg('out', 'C:/Users/kazda/kiro/gtai-masters/n31/melee');
const tag = arg('tag', '01b');
const split = (v) => v.split(',').map((f) => f.trim()).filter(Boolean);
const gameFlags = split(arg('game-flags', label === 'before' ? arg('before-flags', '--melee-sweep=off') : ''));
const LOCK = join(ROOT, 'build/n31/godot.lock');
const scratch = join(ROOT, `build/n31/${tag}/take`);
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

console.log(`play-take ${label}: game flags [${gameFlags.join(' ')}]`);
for (const w of weapons) {
  const avi = join(scratch, `${label}_${w}.avi`);
  const mp4 = join(out, `${label}_play_${w}.mp4`);
  rmSync(avi, { force: true });
  takeLock();
  try {
    const r = await runGodot(['--rendering-driver', 'd3d12', '--position', '0,1440', '--resolution', '1920x1080', '--write-movie', avi,
      '--fixed-fps', '60', '--quit-after', frames, 'res://dev/melee_n31/play_baseline_take.tscn', '--', `--weapon=${w}`,
      `--seed=${seed}`, `--ppm=${ppm}`, ...gameFlags], { headless: false, timeoutMs: 15 * 60_000, stopOn: SCRIPT_ERROR, name: 'play-take' });
    if (r.status !== 0 || SCRIPT_ERROR.test(r.out)) throw new Error(`take ${w} failed (status ${r.status}); see build/dev`);
  } finally { rmSync(LOCK, { force: true }); }
  execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', '-i', avi, '-c:v', 'libx264', '-crf', '20', '-pix_fmt', 'yuv420p',
    '-an', mp4], { stdio: 'inherit' });
  const dur = execFileSync('ffprobe', ['-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', mp4], { encoding: 'utf8' }).trim();
  console.log(`${w}: ${mp4} ${dur} s`);
}
