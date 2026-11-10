#!/usr/bin/env node
// The fight frame gate (n12 A2): the combat frame in one command, with its own noise floor.
//   node tools/perf/fight_gate.mjs [--scenes=city,horde] [--arms=base:[<flags>][,<name>:<flags>...]]
//        [--rounds=6] [--out=<dir>] [--no-export] [--wait=<min, default 20>] [--quiet=<cores> [--quiet-wait=<s, 180>]]
// Scenes (the exported windows-showcase release, 1920x1080, d3d12, vsync off, --fixed-fps 60, so a
// frame's wall time is the cost of one 60 Hz tick; the first second is dropped as warm-up):
//   city  = reel chapter 18, the city block fight (perf-city's fight.sh: the pit reel on --arena=city,
//           riot cops, 4 guns) at combo, 32 px/m, 2100 ticks;
//   horde = the arena pit's back-to-back hordes (--horde) under Rivet's Gatling at combo, 32 px/m.
// Arms are `name:<user flags, space separated>`; the first is the base and gets an identical twin
// (`<name>~aa`) as the A/A control, so every table prints its own noise floor. One export serves
// every arm: an A/B is two flag sets on one build (law 4: every change has a before flag).
// Per round each arm runs once, the order rotated and reversed (n10's cpu_ab.ps1), so drift lands
// on all arms. Per run: frame p50 / p99 / worst / frames over 25 ms and the process CPU seconds
// (GetProcessTimes after exit, tools/perf/cpu_run.ps1). Paired deltas per round, a 95 % bootstrap
// interval and a sign test (paired.mjs). Waits for the bench slot like tools/bench/run.mjs
// (acquireBench); a run with another Godot up is counted CONTENDED in the table.
// --quiet=<cores>: before each run wait (at most --quiet-wait s) until the whole machine is busy on
// fewer cores than that (any process: the ledger sees only Godot); the run's own figures say how long.
// Writes <out>/gate.json (gtai.fight-gate/1) and each run's frame log and console log.
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { spawn } from 'node:child_process';
import { cpus } from 'node:os';
import { ROOT } from '../lib/repo.mjs';
import { killTree, runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';
import { acquireBench, contention, register } from '../lib/run_ledger.mjs';
import { frameStats } from './stats.mjs';
import { readLog } from './ab.mjs';
import { median, paired } from './paired.mjs';

export const ENGINE = ['--screen', '0', '--rendering-driver', 'd3d12', '--disable-vsync', '--fixed-fps', '60',
  '--resolution', '1920x1080'];
export const SCENES = {
  city: ['--bot=reel', '--reel=pit', '--arena=city', '--riot', '--rigs',
    '--loadout=pistol,plasma_rifle,rocket_launcher,molotov', '--ppm=32', '--clean', '--view=combo', '--frames-ticks=2100'],
  horde: ['--bot=gunplay', '--weapon=gatling', '--horde', '--cam=fight', '--rigs', '--ppm=32', '--clean',
    '--view=combo', '--frames-ticks=1800'],
};
const DIR = join(ROOT, 'build', 'export', 'fight-gate');
const EXE = join(DIR, 'RTAI-bench.exe'); // the name the run ledger's process scan counts
const METRICS = ['p50', 'p99', 'worst', 'over25', 'cpu'];
// Cores the rest of the machine took during a run (GetSystemTimes minus this run): any process, not
// only Godot, so a vitest or a rustc build on the box shows up beside the figure it inflated.
const SIDE = ['load'];

export function parseArgs(argv) {
  const o = { scenes: 'city,horde', arms: 'base:', rounds: 6, out: '', export: true, wait: 20, quiet: 0, quietWait: 180 };
  for (const a of argv) {
    const [k, ...rest] = a.replace(/^--/, '').split('=');
    const v = rest.join('=');
    if (k === 'no-export') o.export = false;
    else if (k === 'rounds' || k === 'wait' || k === 'quiet') o[k] = Number(v);
    else if (k === 'quiet-wait') o.quietWait = Number(v);
    else if (k === 'scenes' || k === 'arms' || k === 'out') o[k] = v;
    else throw new Error(`fight_gate: unknown argument ${a}`);
  }
  const arms = o.arms.split(',').map((s) => {
    const i = s.indexOf(':');
    if (i < 1) throw new Error(`fight_gate: an arm is name:<flags>, got "${s}"`);
    return { name: s.slice(0, i), user: s.slice(i + 1).split(' ').filter(Boolean) };
  });
  arms.push({ name: `${arms[0].name}~aa`, user: arms[0].user, twin: true });
  o.arms = arms;
  o.scenes = o.scenes.split(',');
  for (const s of o.scenes) if (!SCENES[s]) throw new Error(`fight_gate: unknown scene ${s} (${Object.keys(SCENES)})`);
  return o;
}

/** Round r's arm order: rotated by r, reversed on odd rounds. */
export function order(arms, r) {
  const k = r % arms.length;
  const o = [...arms.slice(k), ...arms.slice(0, k)];
  return r % 2 ? o.reverse() : o;
}

/** Runs the exe under cpu_run.ps1: resolves {cpu: {exit, total_s, ...} | {error}, out}. */
function cpuRun(args, log) {
  if (args.some((a) => /\s/.test(a))) throw new Error('fight_gate: an argument holds a space');
  const entry = register({ kind: 'fight-gate' });
  return new Promise((done) => {
    const ps = spawn('powershell', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', join(ROOT, 'tools', 'perf', 'cpu_run.ps1'),
      '-Exe', EXE, '-ArgLine', args.join(' '), '-Cwd', DIR, '-Log', log, '-TimeoutS', '300'], { windowsHide: true });
    let text = '';
    const guard = setTimeout(() => killTree(ps.pid), 330000);
    ps.stdout.on('data', (d) => {
      text += d.toString('utf8');
      const m = text.match(/PID (\d+)/);
      if (m) entry.setChild(Number(m[1]));
    });
    ps.on('close', () => {
      clearTimeout(guard);
      entry.release();
      const line = text.split(/\r?\n/).find((l) => l.startsWith('{'));
      done({ cpu: line ? JSON.parse(line) : { error: `no result: ${text.slice(-200)}` },
        out: existsSync(log) ? readFileSync(log, 'utf8') : '' });
    });
  });
}

/** Busy cores of the whole machine over `ms` (os.cpus: every logical core's non-idle time). */
export async function busyCores(ms = 2000) {
  const busy = () => cpus().reduce((s, c) => s + c.times.user + c.times.nice + c.times.sys + c.times.irq, 0);
  const b0 = busy();
  const t0 = Date.now();
  await new Promise((r) => setTimeout(r, ms));
  return (busy() - b0) / (Date.now() - t0);
}

/** --quiet=<cores>: before a run, wait (up to quietWait s) while the machine is busier than that. */
async function settle(quiet, quietWait) {
  if (!(quiet > 0)) return { waited: 0, pre: NaN };
  const t0 = Date.now();
  let pre = await busyCores();
  while (pre > quiet && Date.now() - t0 < quietWait * 1000) {
    await new Promise((r) => setTimeout(r, 3000));
    pre = await busyCores();
  }
  return { waited: (Date.now() - t0) / 1000, pre };
}

async function runOne(scene, arm, round, outDir, o) {
  const calm = await settle(o.quiet, o.quietWait);
  const file = resolve(outDir, `${scene}-${arm.name}-${round}.json`).replace(/\\/g, '/');
  const others = contention().count;
  const user = [...SCENES[scene], ...arm.user, `--frames=${file}`];
  const { cpu, out } = await cpuRun([...ENGINE, '--', ...user], file.replace(/\.json$/, '.log'));
  const errors = (out.match(new RegExp(SCRIPT_ERROR.source, 'g')) ?? []).length;
  if (cpu.error || cpu.exit !== 0 || !existsSync(file)) {
    return { error: `${scene}/${arm.name} r${round}: ${cpu.error ?? `exit ${cpu.exit}`}, log ${existsSync(file)}` };
  }
  const doc = JSON.parse(readFileSync(file, 'utf8'));
  const s = frameStats(readLog('fight', doc).wall);
  const after = contention().count;
  return { p50: s.p50, p99: s.p99, worst: s.worst, over25: s.over25, cpu: cpu.total_s, load: cpu.others_cores, frames: s.frames,
    ticks: doc.summary?.ticks, errors, contended: Math.max(others, after), pre: calm.pre, waited: calm.waited };
}

const fmt = (v, d = 2) => (Number.isFinite(v) ? v.toFixed(d) : '-');
const sgn = (v, d = 3) => (Number.isFinite(v) ? `${v >= 0 ? '+' : ''}${v.toFixed(d)}` : '-');

/** The per-scene summary: medians per arm, the A/A floor, each arm against the base. */
export function summarise(runs, arms) {
  const base = arms[0].name;
  const twin = arms.find((a) => a.twin).name;
  const pick = (arm, m) => runs.filter((r) => r.arm === arm).map((r) => r[m]);
  const rounds = (a, b, m) => [...new Set(runs.map((r) => r.round))].map((k) => ({
    a: runs.find((r) => r.round === k && r.arm === a)?.[m], b: runs.find((r) => r.round === k && r.arm === b)?.[m] }));
  const out = { medians: {}, floor: {}, vsBase: {} };
  for (const a of arms) out.medians[a.name] = Object.fromEntries([...METRICS, ...SIDE].map((m) => [m, median(pick(a.name, m))]));
  for (const m of METRICS) {
    const aa = paired(rounds(base, twin, m));
    out.floor[m] = { ...aa, halfWidth: Math.max(Math.abs(aa.ci95[0]), Math.abs(aa.ci95[1])) };
  }
  for (const a of arms.filter((x) => x.name !== base && !x.twin)) {
    out.vsBase[a.name] = Object.fromEntries(METRICS.map((m) => [m, paired(rounds(base, a.name, m), { floor: out.floor[m].halfWidth })]));
  }
  return out;
}

export function report(scene, sum, runs, arms) {
  const lines = [`${scene}: ${new Set(runs.map((r) => r.round)).size} rounds, ${runs.filter((r) => r.contended).length} of ${runs.length} runs CONTENDED`
    + `, ${runs.reduce((s, r) => s + r.errors, 0)} SCRIPT ERROR`];
  lines.push(`  ${'arm'.padEnd(14)} p50 ms  p99 ms  worst ms  >25ms  cpu s  others' cores`);
  for (const a of arms) {
    const m = sum.medians[a.name];
    lines.push(`  ${a.name.padEnd(14)} ${fmt(m.p50).padStart(6)}  ${fmt(m.p99).padStart(6)}  ${fmt(m.worst, 1).padStart(8)}  ${fmt(m.over25, 0).padStart(5)}  ${fmt(m.cpu, 2).padStart(5)}  ${fmt(m.load, 1).padStart(5)}`);
  }
  const f = sum.floor;
  lines.push(`  A/A floor (${arms.find((a) => a.twin).name} - ${arms[0].name}): ` + METRICS.map((m) => `${m} ${sgn(f[m].median)} [${sgn(f[m].ci95[0])},${sgn(f[m].ci95[1])}]`).join('  '));
  for (const [name, row] of Object.entries(sum.vsBase)) {
    lines.push(`  ${name} - ${arms[0].name}: ` + METRICS.map((m) => `${m} ${sgn(row[m].median)} [${sgn(row[m].ci95[0])},${sgn(row[m].ci95[1])}] ${row[m].lower}/${row[m].n} lower ${row[m].call}`).join('  '));
  }
  return lines.join('\n');
}

async function prepare() {
  mkdirSync(DIR, { recursive: true });
  const exp = await runGodot(['--headless', '--export-release', 'windows-showcase', '../build/export/fight-gate/RTAI-bench.exe'],
    { headless: false, name: 'fight-gate-export' });
  if (exp.status !== 0 || !existsSync(EXE)) throw new Error(`export failed: ${exp.out.slice(-300)}`);
}

async function main() {
  const o = parseArgs(process.argv.slice(2));
  const outDir = resolve(ROOT, o.out || join('build', 'perf', 'fight-gate', new Date().toISOString().replace(/[:.]/g, '-')));
  mkdirSync(outDir, { recursive: true });
  if (o.export) await prepare();
  if (!existsSync(EXE)) throw new Error(`no ${EXE}: run without --no-export once`);
  const slot = await acquireBench({ waitMs: o.wait * 60000, log: (l) => console.log(`fight_gate: ${l}`) });
  if (slot.error) throw new Error(slot.error);
  const runs = {};
  try {
    for (let r = 0; r < o.rounds; r++) {
      for (const scene of o.scenes) {
        for (const arm of order(o.arms, r)) {
          const x = await runOne(scene, arm, r, outDir, o);
          if (x.error) { console.error(`fight_gate: ${x.error}`); continue; }
          (runs[scene] ??= []).push({ ...x, arm: arm.name, round: r });
          console.log(`${scene} ${arm.name} r${r}: p50 ${fmt(x.p50)} p99 ${fmt(x.p99)} worst ${fmt(x.worst, 1)} >25 ${x.over25} cpu ${fmt(x.cpu)} s load ${fmt(x.load, 1)} ticks ${x.ticks}${o.quiet > 0 ? ` pre ${fmt(x.pre, 1)} waited ${Math.round(x.waited)} s` : ''}${x.contended ? ` CONTENDED(${x.contended})` : ''}${x.errors ? ` SCRIPT ERROR ${x.errors}` : ''}`);
        }
      }
    }
  } finally {
    slot.lock.release();
  }
  const doc = { schema: 'gtai.fight-gate/1', when: new Date().toISOString(), contendedStart: slot.contended, arms: o.arms, scenes: {} };
  for (const scene of o.scenes) {
    const rs = runs[scene] ?? [];
    doc.scenes[scene] = { summary: summarise(rs, o.arms), runs: rs };
    console.log(report(scene, doc.scenes[scene].summary, rs, o.arms));
  }
  writeFileSync(join(outDir, 'gate.json'), JSON.stringify(doc, null, 1));
  console.log(`fight_gate: ${join(outDir, 'gate.json')}`);
  const bad = Object.values(runs).flat().filter((r) => r.errors).length;
  const missing = o.scenes.some((s) => (runs[s] ?? []).length < o.rounds * o.arms.length);
  process.exit(bad || missing ? 1 : 0);
}

if (process.argv[1]?.replace(/\\/g, '/').endsWith('tools/perf/fight_gate.mjs')) {
  main().catch((e) => { console.error(e.message); process.exit(1); });
}
