#!/usr/bin/env node
// The perf lane's interleaved A/B runner (docs/perf/LEDGER.md). Runs each scene once per arm per
// round, alternating the arm order every round (ABBA...), so a machine's slow drift lands on both.
//   node tools/perf/ab.mjs --scenes=king,drive70,riot --arms=base:,lever:--some-flag [--pairs=3]
//        [--out=evidence/perf/<name>] [--headless] [--no-lock]
// An arm is `<name>:<extra user args>[^<extra engine args>]` (space separated, comma-free), e.g.
// `mobile:^--rendering-method mobile` A/Bs the renderer without touching the project. Takes C:/Users/kazda/kiro/gtai-n5/bench.lock
// (noclobber) for the whole run; every run is stamped CONTENDED when another Godot was up.
// Writes <out>/<scene>-<arm>-<round>.json (the scene's own log) and <out>/ab.json (the summary).
import { spawn } from 'node:child_process';
import { existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { ROOT } from '../lib/repo.mjs';
import { describe, runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';
import { foreignGodot } from '../lib/run_ledger.mjs';
import { frameStats, verdict } from './stats.mjs';

const LOCK = 'C:/Users/kazda/kiro/gtai-n5/bench.lock';
// --fixed-fps 60 with vsync off: every frame steps exactly one sim tick and runs as fast as it can,
// so a frame's wall time is the cost of one 60 Hz gameplay frame. Uncapped without it, most frames
// carry no tick (the riot at ~400 fps ticks every 6-7th frame) and p50 reads the cheap ones (F3).
const WIN = ['--rendering-driver', 'd3d12', '--disable-vsync', '--fixed-fps', '60', '--resolution', '1920x1080'];

/** Scene presets: engine args, scene, user args (`OUT` is replaced by the log path), log kind. */
export const SCENES = {
  king: { engine: WIN, scene: 'res://dev/arena/arena.tscn', kind: 'fight',
    user: ['--boss=king', '--bot=boss', '--seed=2', '--rigs', '--view=combo', '--frames=OUT', '--frames-ticks=1500'] },
  reel: { engine: WIN, scene: 'res://dev/arena/arena.tscn', kind: 'fight',
    user: ['--bot=reel', '--reel=director', '--loadout=pistol', '--rigs', '--view=tilt70', '--frames=OUT', '--frames-ticks=3600'] },
  drive70: { engine: WIN, scene: 'res://dev/bench/city_bench.tscn', kind: 'bench',
    user: ['--scenario=drive_dense', '--zoom=1.5', '--view=tilt70', '--secs=30', '--out=OUT'] },
  riot: { engine: WIN, scene: 'res://dev/bench/city_bench.tscn', kind: 'bench',
    user: ['--scenario=riot', '--zoom=1.0', '--view=tilt70', '--secs=30', '--out=OUT'] },
  drive70h: { engine: ['--fixed-fps', '60'], headless: true, scene: 'res://dev/bench/city_bench.tscn', kind: 'bench',
    user: ['--scenario=drive_dense', '--zoom=1.5', '--view=tilt70', '--secs=30', '--out=OUT'] },
};

function parseArgs(argv) {
  const o = { scenes: 'king', arms: 'base:', pairs: 3, out: '', lock: true };
  for (const a of argv) {
    const [k, ...rest] = a.replace(/^--/, '').split('=');
    const v = rest.join('=');
    if (k === 'no-lock') o.lock = false;
    else if (k in o) o[k] = k === 'pairs' ? Number(v) : v;
    else throw new Error(`ab: unknown argument ${a}`);
  }
  o.arms = o.arms.split(',').map((s) => {
    const i = s.indexOf(':');
    const [user, engine = ''] = s.slice(i + 1).split('^');
    return { name: s.slice(0, i), user: user.split(' ').filter(Boolean), engine: engine.split(' ').filter(Boolean) };
  });
  o.scenes = o.scenes.split(',');
  return o;
}

/** Frames of one log, warm-up / settle frames dropped, plus the side series (render, draws). */
export function readLog(kind, doc) {
  if (kind === 'bench') {
    const m = doc.metrics ?? {};
    return { wall: doc.frame_ms, side: { draws: m.drawCallsAvg, renderCpu: m.renderCpuMsAvg, sim: m.simStepMsPerTick } };
  }
  let t = 0;
  let k = 0;
  while (k < doc.wall_ms.length && t < 1000) t += doc.wall_ms[k++];
  const cut = (a) => (a ?? []).slice(k);
  const avg = (a) => (a.length ? a.reduce((s, v) => s + v, 0) / a.length : NaN);
  return { wall: cut(doc.wall_ms), side: { draws: avg(cut(doc.draw_calls)), renderCpu: avg(cut(doc.render_cpu_ms)),
    renderGpu: avg(cut(doc.render_gpu_ms)), process: avg(cut(doc.process_ms)) } };
}

async function runOnce(sceneName, arm, round, outDir) {
  const sc = SCENES[sceneName];
  const file = resolve(outDir, `${sceneName}-${arm.name}-${round}.json`).replace(/\\/g, '/');
  rmSync(file, { force: true });
  const user = sc.user.map((u) => u.replace('OUT', file));
  const others = foreignGodot().length;
  const env = { ...process.env, APPDATA: process.env.APPDATA_PERF ?? 'C:/Users/kazda/kiro/gtai-d9x/appdata/perf' };
  const sampler = startSampler();
  const res = await runGodot([...sc.engine, ...arm.engine, sc.scene, '--', ...user, ...arm.user],
    { headless: !!sc.headless, env, timeoutMs: 6 * 60 * 1000, name: `perf-ab-${sceneName}` });
  const proc = sampler.stop();
  const errors = (res.out.match(new RegExp(SCRIPT_ERROR.source, 'g')) ?? []).length;
  if (!existsSync(file)) return { error: `${sceneName}/${arm.name}: no log (${describe(res)}) ${res.out.slice(-400)}` };
  const log = readLog(sc.kind, JSON.parse(readFileSync(file, 'utf8')));
  return { stats: frameStats(log.wall), side: { ...log.side, ...proc }, errors, contended: others > 0 || foreignGodot().length > 0, others };
}

/** The process sampler (proc_sample.ps1) over this runner's Godot children. stop() returns the
 *  steady-state CPU in cores (the first SKIP samples, the boot, left out), the peak working set
 *  in MB and the peak thread count; NaN when it saw fewer than two steady samples. */
export function startSampler(skip = 3) {
  const ps = spawn('powershell', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File',
    join(ROOT, 'tools', 'perf', 'proc_sample.ps1'), '-Root', String(process.pid)], { windowsHide: true });
  let text = '';
  ps.stdout.on('data', (d) => { text += d.toString('utf8'); });
  return { stop() { ps.kill(); return procStats(text, skip); } };
}

export function procStats(text, skip = 3) {
  const rows = text.split(String.fromCharCode(10)).map((l) => l.trim()).filter((l) => l.startsWith('{')).map((l) => JSON.parse(l)).filter((r) => r.procs > 0);
  const steady = rows.slice(skip);
  const out = { cpuCores: NaN, peakWsMb: NaN, threads: NaN };
  if (!rows.length) return out;
  out.peakWsMb = Math.max(...rows.map((r) => r.ws)) / 1048576;
  out.threads = Math.max(...rows.map((r) => r.threads));
  if (steady.length >= 2) {
    const a = steady[0];
    const b = steady[steady.length - 1];
    out.cpuCores = (b.cpu100ns - a.cpu100ns) / 1e4 / (b.t - a.t);
  }
  return out;
}

function takeLock() {
  try {
    writeFileSync(LOCK, JSON.stringify({ lane: 'perf', pid: process.pid, start: new Date().toISOString() }), { flag: 'wx' });
    return true;
  } catch { return false; }
}

const METRICS = ['p50', 'p99', 'p999', 'worst', 'mean', 'pace99', 'over25'];

export function summarise(results, arms) {
  const out = {};
  for (const [scene, byArm] of Object.entries(results)) {
    out[scene] = {};
    const base = byArm[arms[0].name] ?? [];
    for (const arm of arms) {
      const runs = byArm[arm.name] ?? [];
      const row = {};
      for (const m of METRICS) row[m] = verdict(base.map((r) => r.stats[m]), runs.map((r) => r.stats[m]));
      for (const s of ['draws', 'renderCpu', 'renderGpu', 'process', 'sim', 'cpuCores', 'peakWsMb', 'threads']) {
        row[s] = verdict(base.map((r) => r.side[s] ?? NaN), runs.map((r) => r.side[s] ?? NaN));
      }
      row.contended = runs.filter((r) => r.contended).length;
      row.scriptErrors = runs.reduce((s, r) => s + r.errors, 0);
      out[scene][arm.name] = row;
    }
  }
  return out;
}

async function main() {
  const o = parseArgs(process.argv.slice(2));
  const outDir = resolve(ROOT, o.out || join('evidence', 'perf', `ab-${Date.now()}`));
  mkdirSync(outDir, { recursive: true });
  let locked = false;
  if (o.lock) {
    const t0 = Date.now();
    while (!(locked = takeLock()) && Date.now() - t0 < 10 * 60 * 1000) await new Promise((r) => setTimeout(r, 15000));
    if (!locked) console.error('ab: bench.lock still held after 10 min: running CONTENDED');
  }
  const results = {};
  try {
    for (let round = 0; round < o.pairs; round++) {
      const order = round % 2 === 0 ? o.arms : [...o.arms].reverse();
      for (const scene of o.scenes) {
        for (const arm of order) {
          const r = await runOnce(scene, arm, round, outDir);
          if (r.error) { console.error(`ab: ${r.error}`); continue; }
          ((results[scene] ??= {})[arm.name] ??= []).push(r);
          const s = r.stats;
          console.log(`${scene} ${arm.name} r${round}: p50 ${s.p50.toFixed(2)} p99 ${s.p99.toFixed(2)} worst ${s.worst.toFixed(1)} `
            + `draws ${Math.round(r.side.draws)} cpu ${r.side.cpuCores.toFixed(2)} cores ws ${Math.round(r.side.peakWsMb)} MB errors ${r.errors}${r.contended ? ` CONTENDED(${r.others})` : ''}`);
        }
      }
    }
  } finally {
    if (locked) rmSync(LOCK, { force: true });
  }
  const summary = { schema: 'gtai.perf-ab/1', when: new Date().toISOString(), locked, arms: o.arms, summary: summarise(results, o.arms), raw: results };
  writeFileSync(join(outDir, 'ab.json'), JSON.stringify(summary, null, 1));
  for (const [scene, rows] of Object.entries(summary.summary)) {
    for (const [arm, row] of Object.entries(rows)) {
      const f = (v) => `${v.b.median.toFixed(2)}±${(v.b.spread / 2).toFixed(2)}${arm === o.arms[0].name ? '' : ` ${v.call}`}`;
      console.log(`${scene} ${arm}: p50 ${f(row.p50)} p99 ${f(row.p99)} p99.9 ${f(row.p999)} worst ${f(row.worst)} draws ${f(row.draws)}`
        + ` renderCpu ${f(row.renderCpu)} cpu ${f(row.cpuCores)} ws ${f(row.peakWsMb)} contended ${row.contended} errors ${row.scriptErrors}`);
    }
  }
}

if (import.meta.url === `file:///${process.argv[1].replace(/\\/g, '/')}` || process.argv[1].endsWith('ab.mjs')) {
  main().catch((e) => { console.error(e.message); process.exit(1); });
}
