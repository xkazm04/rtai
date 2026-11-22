#!/usr/bin/env node
import { mkdirSync, readdirSync, renameSync, statSync, writeFileSync } from 'node:fs';
import { basename, join, relative, sep } from 'node:path';
import { pathToFileURL } from 'node:url';
import { main as devRun } from '../dev/run.mjs';
import { dirtyLines, git } from '../lib/repo.mjs';
import { MARKER } from '../mutate/worktree.mjs';
import { median } from '../perf/paired.mjs';
import { commandLine, parseArgs, plan } from './commands.mjs';
import { BATCH_SCHEMA, PROFILES, validateRun } from './contract.mjs';
import { tableSnapshot } from './table_snapshot.mjs';
import { streetLog } from './street_log.mjs';
import { capExit, readResult } from './run_result.mjs';

export { parseArgs, plan, validateRun };
const portable = (out, path) => relative(out, path).split(sep).join('/');
const sum = (values) => values.reduce((total, n) => total + n, 0);

function offline(args) {
  const child = join(args.from, 'runs');
  const dir = statSync(child, { throwIfNoEntry: false })?.isDirectory() ? child : args.from;
  const entries = [];
  for (const file of readdirSync(dir, { withFileTypes: true }).filter((e) => e.isFile() && e.name.endsWith('.json'))
    .map((e) => e.name).sort()) {
    if (file === 'batch.json') continue;
    const path = join(dir, file);
    const hint = /^(novice|average|expert|human)-(\d+)\.json$/.exec(file);
    const row = { profile: hint?.[1] ?? 'unknown', seed: hint ? Number(hint[2]) : null,
      pick: args.pick, file: portable(args.out, path), exit: null, wall_s: null, log: null, ok: false };
    const entry = readResult(path, row);
    if (args.profile !== 'all' && row.profile !== args.profile && row.profile !== 'unknown') continue;
    if (args.controls && entry.result && entry.result.controls !== args.controls) continue;
    if (args.seeds && row.seed !== null && (row.seed < args.seed0 || row.seed >= args.seed0 + args.seeds)) continue;
    entries.push(entry);
  }
  return entries;
}

async function liveRun(args, job, launch) {
  const stem = basename(job.file, '.json');
  const log = join(args.out, 'logs', stem + '.log');
  const lines = [commandLine(job.argv)];
  const row = { profile: job.profile, seed: job.seed, pick: args.pick, controls: args.controls,
    file: portable(args.out, job.file), log: portable(args.out, log), exit: null, wall_s: null, ok: false };
  const start = performance.now();
  try {
    const before = statSync(job.file, { throwIfNoEntry: false, bigint: true });
    const note = (line) => lines.push(String(line));
    row.exit = await launch(job.argv, { out: note, err: note, logDir: join(args.out, 'logs', stem) });
    const engineLog = lines.find((line) => line.startsWith('run: log '));
    if (engineLog) row.engine_log = portable(args.out, engineLog.slice('run: log '.length));
    Object.assign(row, streetLog(args.out, row));
    const capped = capExit(row, lines.at(-1));
    if (row.exit !== 0 && !capped) throw new Error(lines.at(-1));
    const after = statSync(job.file, { bigint: true });
    if (before && after.mtimeNs === before.mtimeNs && after.ctimeNs === before.ctimeNs)
      throw new Error('result was not rewritten by this run');
    return readResult(job.file, row, true, capped);
  } catch (err) {
    row.reason = err.message;
    return { row, result: null };
  } finally {
    row.wall_s = (performance.now() - start) / 1000;
    if (row.reason) lines.push(row.reason);
    writeFileSync(log, lines.join('\n') + '\n');
  }
}

async function live(args, launch) {
  mkdirSync(join(args.out, 'runs'), { recursive: true });
  mkdirSync(join(args.out, 'logs'), { recursive: true });
  const jobs = [...plan(args)];
  const entries = [];
  let next = 0;
  async function worker() {
    while (next < jobs.length) {
      const i = next++;
      entries[i] = await liveRun(args, jobs[i], launch);
    }
  }
  await Promise.all(Array.from({ length: Math.min(jobs.length, args.jobs) }, worker));
  return entries;
}

function simulationSeconds({ row, result: run }) {
  if (Number.isSafeInteger(run?.ticks) && run.ticks >= 0) return run.ticks / 60;
  if (Number.isFinite(run?.sim_s)) return run.sim_s;
  if (Number.isSafeInteger(row.ticks) && row.ticks >= 0) return row.ticks / 60;
  if (!run) return null;
  const times = run.waves.map((w) => w.seconds).filter(Number.isFinite);
  return times.length > 0 && times.length === run.wave_reached ? sum(times) : null;
}

export function summary(batch) {
  const fmt = (value) => Number.isFinite(value) ? String(Number(value.toFixed(2))) : 'not measured';
  const profiles = batch.args.profile === 'all' ? PROFILES : [batch.args.profile];
  return [...new Set([...profiles, ...batch.runs.map((r) => r.profile)])].map((p) => {
    const runs = batch.results.filter((r) => r.profile === p);
    const times = runs.flatMap((r) => r.waves.map((w) => w.seconds)).filter(Number.isFinite);
    const capped = batch.runs.filter((r) => r.profile === p && r.outcome === 'capped').length;
    return p + ': ' + runs.length + '/' + batch.runs.filter((r) => r.profile === p).length
      + ' ok' + (capped ? ' (' + capped + ' capped alive)' : '') + ', median wave reached ' + fmt(median(runs.map((r) => r.wave_reached)))
      + ', median seconds per wave ' + fmt(median(times));
  });
}

export async function batch(args, { launch = devRun, out = console.log, err = console.error } = {}) {
  if (args.dryRun) {
    for (const job of plan(args)) out(commandLine(job.argv));
    return null;
  }
  const created = new Date().toISOString();
  const revision = { sha: git('rev-parse', 'HEAD'), branch: git('branch', '--show-current'), dirty: dirtyLines().some((line) => line !== '?? ' + MARKER) };
  const snapshot = tableSnapshot(args.runner);
  const start = performance.now();
  const entries = args.from ? offline(args) : await live(args, launch);
  const wall_s = args.from ? null : (performance.now() - start) / 1000;
  const results = entries.map((entry) => entry.result).filter(Boolean);
  const times = entries.map(simulationSeconds).filter(Number.isFinite);
  const sim_s = times.length ? sum(times) : null;
  const complete = entries.length > 0 && times.length === entries.length;
  const speed = { sim_s, wall_s, sim_per_wall: complete && wall_s > 0 ? sim_s / wall_s : null };
  const doc = { schema: BATCH_SCHEMA, created, git: revision, args, ...snapshot,
    runs: entries.map((entry) => entry.row), results, speed };
  mkdirSync(args.out, { recursive: true });
  const temp = join(args.out, 'batch.' + process.pid + '.tmp');
  writeFileSync(temp, JSON.stringify(doc, null, 2) + '\n');
  renameSync(temp, join(args.out, 'batch.json'));
  for (const r of doc.runs) if (!r.ok) err('failed ' + r.file + ': ' + r.reason);
  for (const line of summary(doc)) out(line);
  return doc;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try {
    const args = parseArgs(process.argv.slice(2));
    const doc = await batch(args);
    if (doc && (!doc.results.length || (!args.from && doc.runs.some((r) => !r.ok)))) process.exitCode = 1;
  } catch (err) {
    console.error('batch: ' + err.message);
    process.exitCode = 2;
  }
}
