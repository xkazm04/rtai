#!/usr/bin/env node
// Handheld simulator (docs/handheld/LEDGER.md): runs the dev arena under a device profile on this
// PC the way a handheld would see it: the process pinned to the device's logical CPUs (affinity),
// at below-normal priority, rendering on the integrated Radeon (Godot --gpu-index), with the
// profile's window and frame cap (--device=<id>, devices.json). Reads the frame log (the dev
// arena's --frames=<json>, FightFrames) and samples CPU %, RAM and GPU memory from outside
// (sample.ps1). Writes one gtai.handheld-sim/1 JSON per run. Every number is "on the simulator".
//
// Usage: node tools/handheld/sim.mjs --device=deck [--scene=reel|city|king|servo] [--ticks=1800]
//   [--gpu=igpu|dgpu|<index>] [--threads=<n>] [--priority=belownormal|normal] [--label=<name>]
//   [--out=<dir>] [--no-device] [--movie=<abs .avi>] [--renderer=forward_plus|mobile|compat]
//   [-- <extra user args for the arena>]
// --no-device runs the same pin/GPU without the --device flag (the desktop row: the A side).
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
  city: ['--arena=city', '--rigs', '--view=tilt70'],
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
  const gui = g.bin.replace(/_console\.exe$/i, '.exe');
  const threads = a.threads || row.sim_threads || 16;
  const gpuIndex = a.renderer === 'compat' ? null : detectGpu(g.bin, a.gpu);
  const label = a.label || `${a.noDevice ? 'desktop' : row.id}-${a.scene}-${a.gpu}-t${threads}-${a.renderer || 'forward_plus'}`;
  mkdirSync(a.out, { recursive: true });
  const framesPath = join(a.out, `${label}.frames.json`).replaceAll('\\', '/');
  const before = contention();
  const godotArgs = [...rendererArgs(a.renderer), ...(gpuIndex == null ? [] : ['--gpu-index', String(gpuIndex)]),
    '--path', join(ROOT, 'project').replaceAll('\\', '/'), ...(a.movie ? ['--write-movie', a.movie, '--fixed-fps', '60'] : []),
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
  const timer = setTimeout(() => killTree(game.pid), (a.ticks / 60 + 120) * 1000);
  const code = await new Promise((done) => game.on('close', done));
  clearTimeout(timer);
  await new Promise((done) => { sampler.on('close', done); setTimeout(done, 5000); });
  if (!existsSync(framesPath)) { console.error(`sim: no frame log (exit ${code})`); process.exit(1); }
  const samples = sampled.split(/\r?\n/).filter((l) => l.startsWith('{')).map((l) => JSON.parse(l));
  const doc = { schema: 'gtai.handheld-sim/1', label, device: a.noDevice ? 'desktop' : row.id, scene: a.scene,
    scene_args: SCENES[a.scene], extra: a.extra, renderer: a.renderer || 'forward_plus', gpu: a.gpu, gpu_index: gpuIndex, threads, priority: a.priority,
    ticks: a.ticks, exit: code, contended: before.count > 0 ? `CONTENDED (${before.count} other Godot runs)` : 'quiet',
    at: new Date().toISOString(), summary: summarize(JSON.parse(readFileSync(framesPath, 'utf8')), samples), samples };
  const outPath = join(a.out, `${label}.json`);
  writeFileSync(outPath, `${JSON.stringify(doc, null, 2)}\n`);
  console.log(`${label}: ${doc.contended} ${JSON.stringify(doc.summary)}`);
  console.log(`-> ${outPath}`);
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) await main();
