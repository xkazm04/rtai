#!/usr/bin/env node
// n31 foes: how long gauntlet enemies wait to shoot. Runs res://dev/foes_n31/waiting_probe once per
// profile x seed through tools/dev/run.mjs, one Godot at a time under the lane lock build/n31/godot.lock,
// then pools the gtai.foes-waiting/1 files into waiting.json + waiting.md (waiting_agg.mjs).
//   node tools/gauntlet/waiting.mjs --out=<dir> [--profiles=novice,average] [--seeds=10] [--seed0=1]
//     [--waves=7] [--rev=<commit>] [--from=<dir>] [--parity] [--check] [--tag=b1]
// --rev runs in a temp detached worktree at that commit (the probe files copied in), removed after.
// --from re-aggregates <dir>/runs/*.json without Godot. --parity also runs plain `gauntlet` with the
// same args and compares the two run results. --check only parse-checks the probe (in the --rev tree).
//   node tools/gauntlet/waiting.mjs --compare=<dirA>,<dirB>[,...] [--labels=main,gait] [--out=<file.md>]
// prints (or writes) the headline of each dir's waiting.json side by side (waiting_compare.mjs).
import { spawnSync } from 'node:child_process';
import { cpSync, existsSync, mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { basename, join, resolve } from 'node:path';
import { isDeepStrictEqual, parseArgs } from 'node:util';
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';
import { copyRuntime, MARKER, removeWorktree } from '../mutate/worktree.mjs';
import { seedImportCache } from './prepare_worktree.mjs';
import { entryArgs } from './commands.mjs';
import { aggregate, markdown, SCHEMA } from './waiting_agg.mjs';
import { compareMarkdown } from './waiting_compare.mjs';

const PROBE_DIR = 'project/dev/foes_n31';
const PROBE_RES = ['res://dev/foes_n31/waiting_probe.gd', 'res://dev/foes_n31/waiting_probe.tscn'];
const LOCK = join(ROOT, 'build', 'n31', 'godot.lock');

export function parse(argv) {
  const { values: v } = parseArgs({ args: argv, options: Object.fromEntries(
    ['profiles', 'seeds', 'seed0', 'waves', 'out', 'rev', 'from', 'tag', 'compare', 'labels'].map((k) => [k, { type: 'string' }])
      .concat([['parity', { type: 'boolean' }], ['check', { type: 'boolean' }]])) });
  const int = (name, x, min) => {
    if (!/^\d+$/.test(x) || Number(x) < min) throw new Error(`--${name} must be an integer >= ${min}`);
    return Number(x);
  };
  const profiles = (v.profiles ?? 'novice,average').split(',');
  for (const p of profiles) if (!['novice', 'average', 'expert'].includes(p)) throw new Error('unknown profile ' + p);
  if (!v.out && !v.check && !v.from && !v.compare) throw new Error('--out=<dir> is required');
  const compare = v.compare ? v.compare.split(',').map((d) => resolve(d)) : null;
  if (compare && compare.length < 2) throw new Error('--compare needs two or more dirs');
  const labels = v.labels ? v.labels.split(',') : compare?.map((d) => basename(d));
  if (compare && labels.length !== compare.length) throw new Error('--labels must name every --compare dir');
  return { profiles, seeds: int('seeds', v.seeds ?? '10', 1), seed0: int('seed0', v.seed0 ?? '1', 0),
    waves: int('waves', v.waves ?? '7', 1), out: v.out ? resolve(v.out) : null, rev: v.rev ?? null,
    from: v.from ? resolve(v.from) : null, parity: v.parity ?? false, check: v.check ?? false, tag: v.tag ?? 'b1',
    compare, labels };
}

/** The dev-runner argv for one probe run (mirrors commands.mjs entryArgs for a bot run). */
export function probeArgv({ profile, seed, waves }, runsDir) {
  const base = join(runsDir, `${profile}-${seed}`);
  const args = entryArgs({ runner: 'gauntlet', profile, seed, pick: 'greedy', controls: 'wheel', waves }, base + '.result.json');
  return { file: base + '.json', result: base + '.result.json', argv: ['waiting_probe', ...args.slice(1), '--waiting-out=' + base + '.json'],
    plain: ['gauntlet', ...args.slice(1, -1), '--result=' + base + '.plain.json'], plainFile: base + '.plain.json' };
}

export function* plan(a) {
  for (const profile of a.profiles)
    for (let seed = a.seed0; seed < a.seed0 + a.seeds; seed++) yield { profile, seed, ...probeArgv({ profile, seed, waves: a.waves }, join(a.out, 'runs')) };
}

function sleep(ms) { Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, ms); }

/** Runs `action` holding the lane lock (exclusive create; waits while another tag holds it). */
export function withLaneLock(tag, action, { lock = LOCK, log = console.log } = {}) {
  mkdirSync(join(lock, '..'), { recursive: true });
  for (let waited = 0; ; waited += 5) {
    try { writeFileSync(lock, `${tag} ${process.pid}\n`, { flag: 'wx' }); break; } catch (e) {
      if (e.code !== 'EEXIST') throw e;
      if (waited % 60 === 0) log(`waiting: lane lock held by ${readFileSync(lock, 'utf8').trim()} (${waited} s)`);
      sleep(5000);
    }
  }
  try { return action(); } finally {
    if (existsSync(lock) && readFileSync(lock, 'utf8').startsWith(`${tag} ${process.pid}`)) rmSync(lock);
  }
}

function devRun(tree, argv, tag) {
  return withLaneLock(tag, () => {
    const t0 = Date.now();
    const r = spawnSync(process.execPath, [join(tree, 'tools/dev/run.mjs'), '--timeout=900', ...argv],
      { cwd: tree, encoding: 'utf8', windowsHide: true, maxBuffer: 64 << 20 });
    const verdict = r.stdout.trim().split('\n').at(-1);
    const waited = /mem-budget: waiting/.test(r.stdout + r.stderr) ? ' (mem-budget waited)' : '';
    return { status: r.status, seconds: Math.round((Date.now() - t0) / 1000), last: verdict + waited };
  });
}

/** A temp detached worktree at `rev` with the probe files copied in; `action(tree)`; removed after. */
export function inRevTree(rev, action, root = ROOT) {
  const sha = spawnSync('git', ['-C', root, 'rev-parse', '--verify', rev + '^{commit}'], { encoding: 'utf8' }).stdout.trim();
  if (!sha) throw new Error('unknown --rev ' + rev);
  const tree = join(tmpdir(), `gtai-foes-waiting-${sha.slice(0, 9)}-${process.pid}`);
  const git = (...a) => { const r = spawnSync('git', ['-C', root, ...a], { encoding: 'utf8' }); if (r.status) throw new Error(r.stderr); };
  git('worktree', 'add', '--detach', '--quiet', tree, sha);
  try {
    writeFileSync(join(tree, MARKER), JSON.stringify({ root: resolve(root) }), { flag: 'wx' });
    copyRuntime(root, tree);
    seedImportCache(root, tree);
    cpSync(join(root, PROBE_DIR), join(tree, PROBE_DIR), { recursive: true,
      filter: (src) => src === join(root, PROBE_DIR) || basename(src).startsWith('waiting_') });
    if (process.env.GTAI_PROBE_REV) { // a rev without FoeGait cannot compile the newer probe files: use the probe of an older commit
      for (const n of readdirSync(join(tree, PROBE_DIR))) if (n.startsWith("waiting_")) rmSync(join(tree, PROBE_DIR, n));
      const co = spawnSync("git", ["-C", tree, "checkout", process.env.GTAI_PROBE_REV, "--", PROBE_DIR], { encoding: "utf8" });
      if (co.status) throw new Error(co.stderr);
    }
    return action(tree, sha);
  } finally {
    removeWorktree({ root, path: tree });
  }
}

function readRuns(dir) {
  return readdirSync(dir).filter((n) => /^[a-z]+-\d+\.json$/.test(n)).sort()
    .map((n) => JSON.parse(readFileSync(join(dir, n), 'utf8'))).filter((d) => d.schema === SCHEMA);
}

/** Field-by-field difference of two run results ('' when equal). */
export function resultDiff(a, b) {
  if (isDeepStrictEqual(a, b)) return '';
  const keys = [...new Set([...Object.keys(a), ...Object.keys(b)])].filter((k) => !isDeepStrictEqual(a[k], b[k]));
  return 'differs in ' + keys.join(', ');
}

function runAll(a, tree, log) {
  const times = [];
  for (const job of plan(a)) {
    const r = devRun(tree, job.argv, a.tag);
    times.push({ profile: job.profile, seed: job.seed, seconds: r.seconds, status: r.status });
    log(`${job.profile} seed ${job.seed}: exit ${r.status}, ${r.seconds} s; ${r.last}`);
    if (!a.parity) continue;
    const p = devRun(tree, job.plain, a.tag);
    const diff = existsSync(job.plainFile) && existsSync(job.result)
      ? resultDiff(JSON.parse(readFileSync(job.result, 'utf8')), JSON.parse(readFileSync(job.plainFile, 'utf8'))) : 'missing result';
    log(`parity ${job.profile} seed ${job.seed}: plain exit ${p.status}; ${diff || 'run results identical'}`);
  }
  return times;
}

export function main(argv, { log = console.log } = {}) {
  const a = parse(argv);
  if (a.compare) return compareDirs(a, log);
  if (a.check) {
    const check = (tree) => devCheck(tree, a.tag, log);
    return a.rev ? inRevTree(a.rev, check) : check(ROOT);
  }
  let rev = a.rev ? a.rev : 'live tree';
  let times = null;
  if (!a.from) {
    mkdirSync(join(a.out, 'runs'), { recursive: true });
    times = a.rev ? inRevTree(a.rev, (tree, sha) => { rev = sha; return runAll(a, tree, log); }) : runAll(a, ROOT, log);
  }
  const summary = aggregate(readRuns(join(a.from ?? a.out, 'runs')));
  const previous = a.from && existsSync(join(a.from, 'waiting.json')) ? JSON.parse(readFileSync(join(a.from, 'waiting.json'), 'utf8')).meta : null;
  const meta = previous ?? { rev, waves: a.waves, controls: 'wheel', pick: 'greedy', ...(times ? { wall_s: times } : {}) };
  rev = meta.rev;
  const out = a.out ?? a.from;
  writeFileSync(join(out, 'waiting.json'), JSON.stringify({ ...summary, meta }, null, 2) + '\n');
  writeFileSync(join(out, 'waiting.md'), markdown(summary, { note: `Measured at ${rev}, gauntlet --controls=wheel --pick=greedy --waves=${a.waves}.` }));
  log(`wrote ${join(out, 'waiting.md')}`);
  return 0;
}

function compareDirs(a, log) {
  const sums = a.compare.map((d) => JSON.parse(readFileSync(join(d, 'waiting.json'), 'utf8')));
  const md = compareMarkdown(sums, a.labels);
  if (a.out) {
    writeFileSync(a.out, md + '\n');
    log(`wrote ${a.out}`);
  } else log(md);
  return 0;
}

function devCheck(tree, tag, log) {
  return withLaneLock(tag, () => {
    const r = spawnSync(process.execPath, [join(tree, 'tools/godot/check.mjs'), ...PROBE_RES], { cwd: tree, encoding: 'utf8', windowsHide: true });
    log((r.stdout + r.stderr).trim());
    return r.status ?? 1;
  });
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try { process.exit(main(process.argv.slice(2))); } catch (e) { console.error('waiting: ' + e.message); process.exit(2); }
}
