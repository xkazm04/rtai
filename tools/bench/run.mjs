#!/usr/bin/env node
// The city bench (WLD-08, STANDARDS section 20): bake the chunks, export the windows-bench
// release build, run the crowded drive and the 400-actor riot, judge the hard limits.
//   node tools/bench/run.mjs [--headless] [--secs=60] [--runs=3]
// --headless (or no export templates / no Windows) runs the editor binary with --fixed-fps 60
// instead: CPU only, no rendering, and every summary says so.
import { existsSync, mkdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT, godotBin, run } from '../lib/repo.mjs';

// Hard limits that fail the job (section 20); worstFrameMs has none (TEL-03 records > 25 ms).
export const LIMITS = { p99CpuMs: 7, low1Fps: 45, worstSwapMs: 50 };
// drive = the crowded-drive stress case (9.6 px/m, ~50 actors on screen); drive48 = the same lap
// at the in-car gameplay camera (48 px/m, the owner's decision) with the 400 actors in a tighter
// bubble so the 40 x 25 m view is crowded; riot = 400 actors on foot.
const SCENARIOS = [
  { name: 'drive', scenario: 'drive', zoom: '0.3' },
  { name: 'drive48', scenario: 'drive_dense', zoom: '1.5' },
  { name: 'riot', scenario: 'riot', zoom: '1.0' },
  // the as-shipped presentation (vsync on): the stress runs above present uncapped with vsync
  // off, where DXGI blocks on the swap chain in ~32 ms trios (attributed `present`).
  { name: 'drive48vsync', scenario: 'drive_dense', zoom: '1.5', vsync: 'enabled' },
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
  const user = ['--', `--scenario=${sc.scenario}`, `--label=${sc.name}`, `--secs=${secs}`, `--zoom=${sc.zoom}`, `--vsync=${sc.vsync ?? 'disabled'}`, `--out=${out}`];
  const res = mode === 'exported'
    ? run(EXE, user, { cwd: join(ROOT, 'build', 'export', 'windows-bench'), timeout: (secs + 120) * 1000 })
    : godot(['--headless', '--fixed-fps', '60', '--path', 'project', 'res://dev/bench/city_bench.tscn', ...user],
      { timeout: (secs + 120) * 1000 });
  if (res.status !== 0 || !existsSync(out)) return { error: `${sc.name} exit ${res.status}` };
  return { data: JSON.parse(readFileSync(out, 'utf8')), file: `bench-${sc.name}.json` };
}

const DETAIL = ['p99CpuMs', 'low1Fps', 'worstSwapMs', 'worstFrameMs', 'visibleAvg', 'visibleMax',
  'actorsAvg', 'simStepMsPerTick', 'streamSpawnMsPerTick', 'hitches25', 'hitchesOver50', 'over50.unexplained',
  'avgFrameMs', 'rigMsP50', 'rigMsP99', 'rigMsPerTick', 'fullRigsMax', 'bloodUsPerFrame'];
const round3 = (v) => Math.round(v * 1000) / 1000;

/** Worst case over every run and scenario, plus per-scenario detail (worst over runs). */
// The CPU-frame limits are judged on the uncapped (vsync off) runs; a vsync-paced run's frame
// time is the display's, so it only feeds the hitch counts and the worst frame.
function combine(runs, mode) {
  const all = runs.flatMap((r) => Object.values(r));
  const cpu = all.filter((d) => d.vsync === 'disabled');
  const sum = (k) => all.reduce((a, d) => a + (d.metrics[k] ?? 0), 0);
  const metrics = {
    p99CpuMs: Math.max(...cpu.map((d) => d.metrics.p99CpuMs)),
    low1Fps: Math.min(...cpu.map((d) => d.metrics.low1Fps)),
    worstSwapMs: Math.max(...cpu.map((d) => d.metrics.worstSwapMs)),
    worstFrameMs: Math.max(...all.map((d) => d.metrics.worstFrameMs)),
    exported: mode === 'exported' ? 1 : 0,
    runs: runs.length,
    hitches25: sum('hitches25'),
    hitchesOver50: sum('hitchesOver50'),
  };
  for (const cause of ['outside', 'pipeline', 'game', 'render', 'present', 'unexplained']) {
    metrics[`over50.${cause}`] = sum(`over50.${cause}`);
  }
  for (const name of Object.keys(runs[0])) {
    for (const k of DETAIL) {
      const vals = runs.map((r) => r[name].metrics[k] ?? 0);
      metrics[`${name}.${k}`] = round3(k === 'low1Fps' ? Math.min(...vals) : Math.max(...vals));
    }
    metrics[`${name}.chunkFailures`] = Math.max(...runs.map((r) => r[name].chunk_failures));
  }
  return metrics;
}

/** One pass over every scenario; {byName, files} or {error}. */
function onePass(mode, secs, outDir, pass) {
  const byName = {};
  const files = [];
  for (const sc of SCENARIOS) {
    const r = runScenario({ ...sc, name: sc.name }, mode, secs, outDir);
    if (r.error) return { error: `${r.error} (${mode}, run ${pass})` };
    if (r.data.backend !== 'native') return { error: `${sc.name} ran on ${r.data.backend}` };
    byName[sc.name] = r.data;
    files.push(r.file);
  }
  return { byName, files };
}

// Gate: section 20 hard limits on every run, and F-07's "no unexplained frame over 50 ms".
export function runBench(outDir, { headless = false, secs = 60, runs = 3 } = {}) {
  mkdirSync(outDir, { recursive: true });
  if (!existsSync(NATIVE_DLL)) {
    return { ok: false, summary: 'bench: native release library not built (scons in native/)' };
  }
  const prep = prepare(headless || process.platform !== 'win32');
  if (prep.error) return { ok: false, summary: `bench: ${prep.error}` };
  const passes = [];
  let artifacts = [];
  for (let pass = 1; pass <= runs; pass += 1) {
    const r = onePass(prep.mode, secs, outDir, pass);
    if (r.error) return { ok: false, summary: `bench: ${r.error}` };
    passes.push(r.byName);
    artifacts = r.files;
  }
  const m = combine(passes, prep.mode);
  const misses = Object.entries(LIMITS).filter(([k, lim]) => (k === 'low1Fps' ? m[k] <= lim : m[k] > lim));
  if (m['over50.unexplained'] > 0) misses.push(['over50.unexplained']);
  const failures = SCENARIOS.reduce((a, sc) => a + m[`${sc.name}.chunkFailures`], 0);
  const what = prep.mode === 'exported' ? 'exported release build, windowed' : 'headless CPU only, no rendering';
  const summary = `bench (${what}, ${runs} consecutive runs x ${SCENARIOS.length} scenarios x ${secs} s): `
    + `p99 ${m.p99CpuMs} ms, 1% low ${Math.round(m.low1Fps)} fps, worst swap ${m.worstSwapMs} ms, `
    + `worst frame ${m.worstFrameMs} ms; hitches >25 ms ${m.hitches25}, >50 ms ${m.hitchesOver50} `
    + `(unexplained ${m['over50.unexplained']}, outside ${m['over50.outside']}, present `
    + `${m['over50.present']}); vsync-on drive >25 ms: ${m['drive48vsync.hitches25']}; visible avg `
    + `${m['drive.visibleAvg']} / ${m['drive48.visibleAvg']} / ${m['riot.visibleAvg']} (drive/drive48/riot); `
    + `rigs p50 ${m['riot.rigMsP50']} / p99 ${m['riot.rigMsP99']} ms per frame (riot, up to ${m['riot.fullRigsMax']})`
    + (misses.length ? `; MISSES ${misses.map(([k]) => k).join(', ')}` : '')
    + (failures ? `; ${failures} chunk failures` : '');
  return { ok: !misses.length && !failures, summary, metrics: m, artifacts };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const arg = (name, dflt) => Number((process.argv.find((a) => a.startsWith(`${name}=`)) ?? `=${dflt}`).split('=')[1]);
  const res = runBench(join(ROOT, 'build', 'bench'), {
    headless: process.argv.includes('--headless'), secs: arg('--secs', 60), runs: arg('--runs', 3),
  });
  console.log(res.summary);
  process.exit(res.ok ? 0 : 1);
}
