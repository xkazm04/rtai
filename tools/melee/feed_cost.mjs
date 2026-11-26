#!/usr/bin/env node
// n31 melee 03p3 part 1: the signature-kill feed's frame cost in the gauntlet street. The fight gate's
// horde/city scenes are the arena pit (ArenaSession), which never reads --kill-feed, so this runs the
// closest gauntlet measure instead: play_baseline_take (gauntlet street, the average bot, ONE melee
// weapon, tilt 70 at --ppm 32, 1080p) under --fixed-fps 60 with vsync off, its FightFrames log
// (--frames, the fight gate's probe) per run, arms alternating per round.
//   node tools/melee/feed_cost.mjs [--weapon=chainsaw] [--rounds=2] [--ticks=3600] [--seed=7]
//     [--arms=off:--kill-feed=off,on:] [--out=build/n31/03p3/feed-cost] [--headless] [--tag=03p3]
// --headless: no GPU (the frame is the CPU side only: sim, hooks, the views' script and canvas work);
// used when other lanes saturate the GPU (03p3: draw 270 ms a frame on the off arm, 01:20-01:28).
// Takes the lane Godot lock (build/n31/godot.lock) per run, waiting while another builder holds it.
// Prints one line per run and writes <out>/feed-cost.json (per run stats + per-arm medians).
import { existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { ROOT } from '../lib/repo.mjs';
import { runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';
import { contention } from '../lib/run_ledger.mjs';
import { frameStats } from '../perf/stats.mjs';
import { readLog } from '../perf/ab.mjs';
import { busyCores } from '../perf/fight_gate.mjs';
import { median } from '../perf/paired.mjs';

const arg = (k, d) => process.argv.slice(2).find((a) => a.startsWith(`--${k}=`))?.slice(k.length + 3) ?? d;
const weapon = arg('weapon', 'chainsaw');
const rounds = Number(arg('rounds', '2'));
const ticks = arg('ticks', '3600');
const seed = arg('seed', '7');
const out = resolve(ROOT, arg('out', 'build/n31/03p3/feed-cost'));
const arms = arg('arms', 'off:--kill-feed=off,on:').split(',').map((s) => {
  const [name, ...rest] = s.split(':');
  return { name, user: rest.join(':').split(' ').filter(Boolean) };
});
const headless = process.argv.includes('--headless');
const tag = arg('tag', '03p3'); // first word of the lane lock
const LOCK = join(ROOT, 'build', 'n31', 'godot.lock');
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function takeLock() {
  for (;;) {
    try {
      writeFileSync(LOCK, `${tag} ${process.pid} ${new Date().toTimeString().slice(0, 8)}\n`, { flag: 'wx' });
      return;
    } catch {
      console.log(`feed-cost: lane lock held (${readFileSync(LOCK, 'utf8').trim()}), waiting 30 s`);
      await sleep(30_000);
    }
  }
}

async function runOne(arm, round) {
  const file = join(out, `${weapon}-${arm.name}-${round}.json`).replace(/\\/g, '/');
  rmSync(file, { force: true });
  await takeLock();
  let r;
  let load;
  const others = contention().count;
  try {
    const loadP = busyCores(20_000);
    const gpu = headless ? [] : ['--rendering-driver', 'd3d12', '--position', '0,1440', '--resolution', '1920x1080'];
    r = await runGodot([...gpu, '--disable-vsync', '--fixed-fps', '60', '--quit-after', String(Number(ticks) + 600), 'res://dev/melee_n31/play_baseline_take.tscn', '--', `--weapon=${weapon}`,
      `--seed=${seed}`, '--ppm=32', `--frames=${file}`, `--frames-ticks=${ticks}`, ...arm.user],
    { headless, timeoutMs: 6 * 60_000, stopOn: SCRIPT_ERROR, name: 'feed-cost' });
    load = await loadP;
  } finally { rmSync(LOCK, { force: true }); }
  writeFileSync(file.replace(/\.json$/, '.log'), r.out);
  if (r.status !== 0 || SCRIPT_ERROR.test(r.out) || !existsSync(file)) throw new Error(`${arm.name} r${round}: status ${r.status}`);
  const doc = JSON.parse(readFileSync(file, 'utf8'));
  const s = frameStats(readLog('fight', doc).wall);
  const kills = /take kills by style (\{.*\})/.exec(r.out)?.[1] ?? 'n/a (03p3 r1 logged them; the log line is gone)';
  return { arm: arm.name, round, p50: s.p50, p99: s.p99, worst: s.worst, over25: s.over25, frames: s.frames,
    ticks: doc.summary?.ticks, busy_cores_first_20s: load, other_runs: others, kills, hitches: doc.hitches?.length ?? 0 };
}

mkdirSync(out, { recursive: true });
const runs = [];
for (let r = 0; r < rounds; r++) {
  const order = r % 2 ? [...arms].reverse() : arms;
  for (const arm of order) {
    const x = await runOne(arm, r);
    runs.push(x);
    console.log(`feed-cost ${weapon} ${x.arm} r${r}: p50 ${x.p50.toFixed(2)} p99 ${x.p99.toFixed(2)} worst ${x.worst.toFixed(1)}`
      + ` >25 ${x.over25} frames ${x.frames} ticks ${x.ticks} busy ${x.busy_cores_first_20s.toFixed(1)} cores`
      + ` other-runs ${x.other_runs} kills ${x.kills}`);
  }
}
const med = Object.fromEntries(arms.map((a) => {
  const rs = runs.filter((x) => x.arm === a.name);
  return [a.name, Object.fromEntries(['p50', 'p99', 'worst', 'over25', 'busy_cores_first_20s'].map((k) => [k, median(rs.map((x) => x[k]))]))];
}));
for (const [name, m] of Object.entries(med)) {
  console.log(`feed-cost median ${name}: p50 ${m.p50.toFixed(2)} p99 ${m.p99.toFixed(2)} worst ${m.worst.toFixed(1)} >25 ${m.over25}`);
}
writeFileSync(join(out, 'feed-cost.json'), `${JSON.stringify({ schema: 'gtai.n31-feed-cost/1', weapon, seed: Number(seed),
  ticks: Number(ticks), engine: headless ? 'editor build (debug), --headless (CPU side only), vsync off, --fixed-fps 60, tilt70 32 px/m'
    : 'editor build (debug), d3d12, 1920x1080, vsync off, --fixed-fps 60, tilt70 32 px/m', arms, runs,
  median: med }, null, 2)}\n`);
