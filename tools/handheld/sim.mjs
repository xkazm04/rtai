#!/usr/bin/env node
// Handheld simulator (docs/handheld/LEDGER.md): runs the dev arena under a device profile on this
// PC the way a handheld would see it: the process pinned to the device's logical CPUs (affinity),
// at below-normal priority, rendering on the integrated Radeon (Godot --gpu-index), with the
// profile's window and frame cap (--device=<id>, devices.json). Reads the frame log (the dev
// arena's --frames=<json>, FightFrames) and samples CPU %, RAM and GPU memory from outside
// (sample.ps1). Writes one gtai.handheld-sim/1 JSON per run. Every number is "on the simulator".
//
// Usage: node tools/handheld/sim.mjs --device=deck [--scene=reel|city|city_combo|king|servo] [--ticks=1800]
//   [--gpu=igpu|dgpu|<index>] [--threads=<n>] [--priority=belownormal|normal] [--label=<name>]
//   [--out=<dir>] [--no-device] [--movie=<abs .avi>] [--renderer=forward_plus|mobile|compat]
//   [--bin=<gui exe>] [--suspend=<after s>:<for s>] [--project=<dir>] [-- <extra user args for the arena>]
// --project=<dir> runs another checkout's project (an import-settings A/B arm in a scratch worktree).
// --grab=<after s>:<abs .png> copies the game window's client area from the screen (grab_window.ps1).
// --no-device runs the same pin/GPU without the --device flag (the desktop row: the A side).
// --cpu-cap=<pct> caps the game at <pct> % of one logical CPU (cpu_cap.ps1, a job object hard cap): a slower core.
import { spawn, spawnSync } from 'node:child_process';
import { mkdirSync, readFileSync, writeFileSync, existsSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { resolveGodot, killTree } from '../lib/godot.mjs';
import { contention } from '../lib/run_ledger.mjs';

const HERE = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(HERE, '..', '..');
export const SCENES = {
  reel: ['--rigs', '--bot=reel', '--reel=director', '--view=tilt70'],
  city: ['--arena=city', '--bot=course', '--seed=2', '--rigs', '--view=tilt70'],
  // the city as main plays it after world's combo switch (the boss view's pitch ease in the open city)
  city_combo: ['--arena=city', '--bot=course', '--seed=2', '--rigs', '--view=combo'],
  king: ['--rigs', '--boss=king', '--bot=boss', '--view=combo'],
  servo: ['--rigs', '--boss=servo', '--bot=boss', '--view=combo'],
};

export function parseArgs(argv) {
  const a = { device: 'deck', scene: 'reel', ticks: 1800, gpu: 'igpu', priority: 'belownormal',
    out: join(ROOT, 'evidence', 'sim'), extra: [], noDevice: false };
  const dash = argv.indexOf('--');
  const own = dash >= 0 ? argv.slice(0, dash) : argv;
  if (dash >= 0) a.extra = argv.slice(dash + 1);
  for (const arg of own) {
    const [k, v] = [arg.split('=')[0].replace(/^--/, ''), arg.includes('=') ? arg.slice(arg.indexOf('=') + 1) : ''];
    if (k === 'no-device') a.noDevice = true;
    else if (k === 'ticks' || k === 'threads') a[k] = Number(v);
    else a[k] = v;
  }
  return a;
}

/** The device row (devices.json) for the simulator's pin and GPU class. */
export function deviceRow(id, table = JSON.parse(readFileSync(join(ROOT, 'project/data/tables/devices.json'), 'utf8'))) {
  const want = id.replaceAll('-', '_');
  return table.devices.find((d) => d.id === want) ?? null;
}

/** `--cpu-cap=<pct>` as a number in (0, 100], else 0 (no cap). */
export const cpuCapPct = (a) => { const n = Number(a['cpu-cap']); return n > 0 && n <= 100 ? n : 0; };

/** The Godot project to run: `--project=<dir>` (an A/B arm in a scratch worktree), else this checkout's. */
export const projectDir = (a) => (a.project ? resolve(a.project) : join(ROOT, 'project'));

/** Affinity mask over the first `n` logical CPUs (on SMT, n = 2 x cores). */
export const affinityMask = (n) => (2n ** BigInt(n) - 1n).toString();

/** Godot's adapter index for an integrated / discrete GPU, read from a --verbose device list. */
export function gpuIndexFrom(log, kind) {
  for (const m of log.matchAll(/#(\d+): (.+?) - Supported, (\w+)/g)) {
    const integrated = /Radeon\(TM\) Graphics|Intel\(R\) (UHD|Iris|Arc\(TM\) Graphics)/.test(m[2]);
    if ((kind === 'igpu') === integrated) return Number(m[1]);
  }
  return null;
}

function detectGpu(bin, kind) {
  if (/^\d+$/.test(kind)) return Number(kind);
  const r = spawnSync(bin, ['--rendering-driver', 'd3d12', '--verbose', '--path', join(ROOT, 'project'),
    '--quit-after', '2', 'res://dev/arena/arena.tscn'], { encoding: 'utf8', timeout: 90000, windowsHide: true });
  return gpuIndexFrom(`${r.stdout}${r.stderr}`, kind);
}

/** Engine args per renderer: Forward+ (the shipped one), Mobile (both on D3D12), Compatibility
 *  (OpenGL 3: --gpu-index does not apply, the driver picks the adapter). */
export function rendererArgs(renderer = 'forward_plus') {
  if (renderer === 'mobile') return ['--rendering-driver', 'd3d12', '--rendering-method', 'mobile'];
  if (renderer === 'compat') return ['--rendering-driver', 'opengl3', '--rendering-method', 'gl_compatibility'];
  return ['--rendering-driver', 'd3d12'];
}

/** The adapter the run really used (the engine log's "Using Device" line): the request is not
 *  the fact (an OpenGL run goes to the display's GPU whatever --gpu-index says). */
export function adapterLine(logPath) {
  try {
    return readFileSync(logPath, 'utf8').match(/^.*Using Device.*$/m)?.[0].trim() ?? 'unknown';
  } catch { return 'unknown (no log)'; }
}

/** The frame that carried the suspend (the longest wall time) and the sim ticks it advanced. */
export function resumeFrame(frames) {
  let i = 0;
  frames.wall_ms.forEach((w, k) => { if (w > frames.wall_ms[i]) i = k; });
  return { frame: i, wall_ms: Math.round(frames.wall_ms[i]), ticks_advanced: i > 0 ? frames.tick[i] - frames.tick[i - 1] : null,
    next_wall_ms: frames.wall_ms.slice(i + 1, i + 6).map((w) => Math.round(w * 10) / 10) };
}

const median = (xs) => { const s = [...xs].sort((p, q) => p - q); return s.length ? s[s.length >> 1] : null; };
const pct = (xs, p) => { const s = [...xs].sort((x, y) => x - y); return s.length ? s[Math.min(s.length - 1, Math.floor(s.length * p))] : null; };
const r2 = (x) => (x == null ? null : Math.round(x * 100) / 100);

/** The run's summary: FightFrames' own plus medians/p95 of the split, settled past 60 frames. */
export function summarize(frames, samples) {
  const settled = (k) => frames[k].slice(60);
  const out = { ...frames.summary };
  for (const k of ['render_gpu_ms', 'render_cpu_ms', 'process_ms', 'loop_ms', 'draw_calls']) {
    out[`${k}_p50`] = r2(median(settled(k)));
    out[`${k}_p95`] = r2(pct(settled(k), 0.95));
  }
  const s = samples.slice(2); // the first two seconds are boot and the prewarm
  out.affinity_seen = [...new Set(samples.map((x) => x.affinity))];
  for (const k of ['cpu_machine_pct', 'cpu_pinned_pct']) out[`${k}_p50`] = r2(median(s.map((x) => x[k])));
  for (const k of ['ws_mb', 'private_mb', 'gpu_dedicated_mb', 'gpu_shared_mb']) {
    out[`${k}_max`] = s.length ? Math.max(...s.map((x) => x[k])) : null;
  }
  return out;
}

async function main() {
  const a = parseArgs(process.argv.slice(2));
  const row = deviceRow(a.device);
  if (!row) { console.error(`sim: no device row ${a.device}`); process.exit(2); }
  const g = resolveGodot();
  if (!g.ok) { console.error(g.message); process.exit(2); }
  const gui = a.bin || g.bin.replace(/_console\.exe$/i, '.exe');
  const threads = a.threads || row.sim_threads || 16;
  const gpuIndex = a.renderer === 'compat' ? null : detectGpu(g.bin, a.gpu);
  const label = a.label || `${a.noDevice ? 'desktop' : row.id}-${a.scene}-${a.gpu}-t${threads}-${a.renderer || 'forward_plus'}`;
  a.out = resolve(a.out);
  mkdirSync(a.out, { recursive: true });
  const framesPath = join(a.out, `${label}.frames.json`).replaceAll('\\', '/');
  const before = contention();
  const godotArgs = [...rendererArgs(a.renderer), ...(gpuIndex == null ? [] : ['--gpu-index', String(gpuIndex)]),
    '--path', projectDir(a).replaceAll('\\', '/'), ...(a.movie ? ['--write-movie', a.movie, '--fixed-fps', '60'] : []),
    'res://dev/arena/arena.tscn', '--', ...SCENES[a.scene], '--clean', `--frames=${framesPath}`,
    `--frames-ticks=${a.ticks}`, ...(a.noDevice ? [] : [`--device=${row.id}`]), ...a.extra];
  const ps = `$p = Start-Process -FilePath '${gui}' -ArgumentList '${godotArgs.join(' ')}' -PassThru; `
    + `$p.ProcessorAffinity = [IntPtr][long]${affinityMask(threads)}; `
    + `$p.PriorityClass = '${a.priority === 'normal' ? 'Normal' : 'BelowNormal'}'; $p.WaitForExit(); exit $p.ExitCode`;
  const sampler = spawn('powershell', ['-NoProfile', '-NonInteractive', '-File', join(HERE, 'sample.ps1'),
    '-Tag', framesPath, '-Threads', String(threads)], { windowsHide: true });
  let sampled = '';
  sampler.stdout.on('data', (d) => { sampled += d.toString(); });
  const game = spawn('powershell', ['-NoProfile', '-NonInteractive', '-Command', ps], { windowsHide: true, stdio: 'inherit' });
  let suspended = '';
  const [afterS, forS] = (a.suspend || '').split(':').map(Number);
  if (forS > 0) {
    const sus = spawn('powershell', ['-NoProfile', '-NonInteractive', '-File', join(HERE, 'suspend.ps1'), '-Tag', framesPath,
      '-AfterS', String(afterS), '-ForS', String(forS)], { windowsHide: true });
    sus.stdout.on('data', (d) => { suspended += d.toString(); });
  }
  let grabbed = '';
  if (a.grab) {
    const [after, png] = [a.grab.slice(0, a.grab.indexOf(':')), a.grab.slice(a.grab.indexOf(':') + 1)];
    const gr = spawn('powershell', ['-NoProfile', '-NonInteractive', '-File', join(HERE, 'grab_window.ps1'), '-Tag', framesPath,
      '-AfterSec', after, '-Out', png], { windowsHide: true });
    gr.stdout.on('data', (d) => { grabbed += d.toString(); });
  }
  let capped = '';
  if (cpuCapPct(a) > 0) {
    const cp = spawn('powershell', ['-NoProfile', '-NonInteractive', '-File', join(HERE, 'cpu_cap.ps1'), '-Tag', framesPath,
      '-Pct', String(cpuCapPct(a))], { windowsHide: true });
    cp.stdout.on('data', (d) => { capped += d.toString(); });
  }
  const timer = setTimeout(() => killTree(game.pid), (a.ticks / 60 + 120 + (forS || 0)) * 1000);
  const code = await new Promise((done) => game.on('close', done));
  clearTimeout(timer);
  await new Promise((done) => { sampler.on('close', done); setTimeout(done, 5000); });
  if (!existsSync(framesPath)) { console.error(`sim: no frame log (exit ${code})`); process.exit(1); }
  const adapter = adapterLine(join(process.env.APPDATA ?? '', 'RTAI Uprising', 'logs', 'godot.log'));
  const samples = sampled.split(/\r?\n/).filter((l) => l.startsWith('{')).map((l) => JSON.parse(l));
  const doc = { schema: 'gtai.handheld-sim/1', label, device: a.noDevice ? 'desktop' : row.id, scene: a.scene,
    scene_args: SCENES[a.scene], extra: a.extra, renderer: a.renderer || 'forward_plus', gpu: a.gpu, gpu_index: gpuIndex, threads, priority: a.priority,
    ticks: a.ticks, exit: code, adapter, contended: before.count > 0 ? `CONTENDED (${before.count} other Godot runs)` : 'quiet',
    at: new Date().toISOString(), summary: summarize(JSON.parse(readFileSync(framesPath, 'utf8')), samples), samples };
  if (a.project) doc.project = projectDir(a);
  if (grabbed) doc.grab = grabbed.trim();
  if (capped) doc.cpu_cap = JSON.parse(capped.trim().split(/\r?\n/)[0]);
  if (forS > 0) doc.suspend = { ...JSON.parse(suspended.trim() || '{}'), resume: resumeFrame(JSON.parse(readFileSync(framesPath, 'utf8'))) };
  const outPath = join(a.out, `${label}.json`);
  writeFileSync(outPath, `${JSON.stringify(doc, null, 2)}\n`);
  console.log(`${label}: ${doc.contended} ${JSON.stringify(doc.summary)}`);
  console.log(`-> ${outPath}`);
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) await main();
