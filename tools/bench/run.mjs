#!/usr/bin/env node
// The city bench (WLD-08, STANDARDS section 20): bake the chunks, export the windows-bench
// release build, run the crowded drive and the 400-actor riot, judge the hard limits.
//   node tools/bench/run.mjs [--headless] [--secs=60]
// --headless (or no export templates / no Windows) runs the editor binary with --fixed-fps 60
// instead: CPU only, no rendering, and every summary says so.
import { existsSync, mkdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT, godotBin, run } from '../lib/repo.mjs';

// Hard limits that fail the job (section 20); worstFrameMs has none (TEL-03 records > 25 ms).
export const LIMITS = { p99CpuMs: 7, low1Fps: 45, worstSwapMs: 50 };
const SCENARIOS = [
  { name: 'drive', zoom: '0.3' },
  { name: 'riot', zoom: '1.0' },
];
const EXE = join(ROOT, 'build', 'export', 'windows-bench', 'RTAI-bench.exe');
const NATIVE_DLL = join(ROOT, 'project', 'native', 'bin', 'gtai_sim.windows.template_release.x86_64.dll');

const godot = (args, opts = {}) => run(godotBin(), args, { cwd: ROOT, ...opts });

function prepare(headless) {
  const bake = godot(['--headless', '--path', 'project', '-s', 'res://dev/bake_city.gd']);
  if (bake.status !== 0) return { error: `bake failed: ${bake.out.slice(-300)}` };
  if (headless) return { mode: 'headless' };
  const exp = godot(['--headless', '--path', 'project', '--export-release', 'windows-bench',
    '../build/export/windows-bench/RTAI-bench.exe']);
  if (exp.status !== 0 || !existsSync(EXE)) return { error: `export failed: ${exp.out.slice(-300)}` };
  return { mode: 'exported' };
}

function runScenario(sc, mode, secs, outDir) {
  const out = join(outDir, `bench-${sc.name}.json`).replace(/\\/g, '/');
  const user = ['--', `--scenario=${sc.name}`, `--secs=${secs}`, `--zoom=${sc.zoom}`, `--out=${out}`];
  const res = mode === 'exported'
    ? run(EXE, user, { cwd: join(ROOT, 'build', 'export', 'windows-bench'), timeout: (secs + 120) * 1000 })
    : godot(['--headless', '--fixed-fps', '60', '--path', 'project', 'res://dev/bench/city_bench.tscn', ...user],
      { timeout: (secs + 120) * 1000 });
  if (res.status !== 0 || !existsSync(out)) return { error: `${sc.name} exit ${res.status}` };
  return { data: JSON.parse(readFileSync(out, 'utf8')), file: `bench-${sc.name}.json` };
}

function combine(byName, mode) {
  const ms = Object.values(byName).map((d) => d.metrics);
  const metrics = {
    p99CpuMs: Math.max(...ms.map((m) => m.p99CpuMs)),
    low1Fps: Math.min(...ms.map((m) => m.low1Fps)),
    worstSwapMs: Math.max(...ms.map((m) => m.worstSwapMs)),
    worstFrameMs: Math.max(...ms.map((m) => m.worstFrameMs)),
    exported: mode === 'exported' ? 1 : 0,
  };
  for (const [name, d] of Object.entries(byName)) {
    for (const k of ['p99CpuMs', 'low1Fps', 'worstSwapMs', 'worstFrameMs', 'visibleAvg', 'visibleMax',
      'actorsAvg', 'simStepMsPerTick', 'streamSpawnMsPerTick']) {
      metrics[`${name}.${k}`] = Math.round(d.metrics[k] * 1000) / 1000;
    }
    metrics[`${name}.chunkFailures`] = d.chunk_failures;
  }
  return metrics;
}

export function runBench(outDir, { headless = false, secs = 60 } = {}) {
  mkdirSync(outDir, { recursive: true });
  if (!existsSync(NATIVE_DLL)) {
    return { ok: false, summary: 'bench: native release library not built (scons in native/)' };
  }
  const wantHeadless = headless || process.platform !== 'win32';
  const prep = prepare(wantHeadless);
  if (prep.error) return { ok: false, summary: `bench: ${prep.error}` };
  const byName = {};
  const artifacts = [];
  for (const sc of SCENARIOS) {
    const r = runScenario(sc, prep.mode, secs, outDir);
    if (r.error) return { ok: false, summary: `bench: ${r.error} (${prep.mode})` };
    if (r.data.backend !== 'native') return { ok: false, summary: `bench: ${sc.name} ran on ${r.data.backend}` };
    byName[sc.name] = r.data;
    artifacts.push(r.file);
  }
  const metrics = combine(byName, prep.mode);
  const misses = Object.entries(LIMITS).filter(([k, lim]) => (k === 'low1Fps' ? metrics[k] <= lim : metrics[k] > lim));
  const failures = metrics['drive.chunkFailures'] + metrics['riot.chunkFailures'];
  const what = prep.mode === 'exported' ? 'exported release build, windowed' : 'headless CPU only, no rendering';
  const summary = `bench (${what}, ${secs} s each): drive + 400-actor riot; p99 ${metrics.p99CpuMs} ms, `
    + `1% low ${Math.round(metrics.low1Fps)} fps, worst swap ${metrics.worstSwapMs} ms, worst frame `
    + `${metrics.worstFrameMs} ms; visible avg ${metrics['drive.visibleAvg']} (drive) / `
    + `${metrics['riot.visibleAvg']} (riot)`
    + (misses.length ? `; MISSES ${misses.map(([k]) => k).join(', ')}` : '')
    + (failures ? `; ${failures} chunk failures` : '');
  return { ok: !misses.length && !failures, summary, metrics, artifacts };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const secsArg = process.argv.find((a) => a.startsWith('--secs='));
  const res = runBench(join(ROOT, 'build', 'bench'), {
    headless: process.argv.includes('--headless'),
    secs: secsArg ? Number(secsArg.slice(7)) : 60,
  });
  console.log(res.summary);
  process.exit(res.ok ? 0 : 1);
}
