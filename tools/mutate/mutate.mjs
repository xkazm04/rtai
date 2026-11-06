#!/usr/bin/env node
// Real mutation testing for one GDScript file: "do my tests bite on this file?"
//   node tools/mutate/mutate.mjs --file=<project-relative .gd> [--max=N] [--ops=a,b] [--tests=<basenames>]
//                                [--timeout=<s per mutant>] [--worktree=<path>] [--remove-worktree] [--json]
// All mutation happens in a dedicated git worktree OUTSIDE the repo (see worktree.mjs and the README);
// the main checkout is only read, and --json writes build/mutate/<slug>.json in it. Exit 0 for every
// completed run (it is a measurement), 2 for usage or infrastructure errors.
import { existsSync, mkdirSync, readFileSync, unlinkSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { canonicalJson } from '../lib/canonical_json.mjs';
import { resolveGodot, runProcess } from '../lib/godot.mjs';
import { ROOT } from '../lib/repo.mjs';
import { OPS, applyMutant, generateMutants, sampleMutants } from './operators.mjs';
import { buildJson, classifyRun, formatReport, mutantLine } from './report.mjs';
import { acquireLock, ensureWorktree, removeWorktree, restoreFile, slugOf, stemOf, writeSidecar }
  from './worktree.mjs';

export class UsageError extends Error {}

const FLAGS = ['--keep-worktree', '--remove-worktree', '--json'];
const BASELINE_TIMEOUT_MS = 15 * 60 * 1000;

/** argv -> options; unknown or malformed args throw UsageError. */
export function parseArgs(argv) {
  const o = { file: null, max: 0, ops: OPS, tests: [], timeoutS: 0, worktree: null, json: false, remove: false };
  const unknown = [];
  for (const a of argv) {
    const k = a.split('=')[0];
    const v = a.includes('=') ? a.slice(a.indexOf('=') + 1) : '';
    if (k === '--file' && v) o.file = v.replace(/\\/g, '/');
    else if (k === '--max' && /^\d+$/.test(v) && Number(v) > 0) o.max = Number(v);
    else if (k === '--ops' && v) o.ops = v.split(',').filter(Boolean);
    else if (k === '--tests' && v) o.tests = v.split(',').filter(Boolean).map((t) => t.replace(/\.gd$/, '').split('/').pop());
    else if (k === '--timeout' && /^\d+$/.test(v) && Number(v) > 0) o.timeoutS = Number(v);
    else if (k === '--worktree' && v) o.worktree = v;
    else if (a === '--json') o.json = true;
    else if (a === '--remove-worktree') o.remove = true;
    else if (a === '--keep-worktree') o.remove = false; // the default; accepted for explicitness
    else unknown.push(a);
  }
  if (unknown.length) throw new UsageError(`unknown or malformed argument(s): ${unknown.join(' ')}`);
  if (!o.file) throw new UsageError('--file=<project-relative .gd path> is required');
  const bad = o.ops.filter((op) => !OPS.includes(op));
  if (bad.length) throw new UsageError(`unknown operator(s) ${bad.join(',')}; known: ${OPS.join(',')}`);
  return o;
}

/** The project-relative path must be a real source .gd (not a test, not an addon). */
export function checkFilePath(file) {
  if (!/^[\w./-]+\.gd$/.test(file) || file.split('/').includes('..') || file.startsWith('/')) {
    throw new UsageError(`--file must be a project-relative .gd path like core/save/gtsv_container.gd, got ${file}`);
  }
  if (/^(tests|addons)\//.test(file)) throw new UsageError(`--file ${file}: mutate source files, not tests or addons`);
}

const note = (s) => console.error(`mutate: ${s}`);

/** The tests to run: --tests, else the test_map mapping (from the worktree copy), slow tier dropped. */
async function pickTests(o, wt) {
  if (o.tests.length) return o.tests;
  const tm = await import(pathToFileURL(join(wt, 'tools', 'tests', 'test_map.mjs')).href);
  const map = tm.mapChanges([`project/${o.file}`], tm.realIndex());
  if (map.full) {
    throw new UsageError(`${o.file} maps to the FULL suite (${map.full}); running ~1,400 tests per mutant is not `
      + 'acceptable. Pass --tests=<test basenames> (e.g. --tests=test_thing).');
  }
  const slow = JSON.parse(readFileSync(join(wt, 'tools', 'tests', 'tiers.json'), 'utf8')).slow;
  const fast = map.tests.filter((t) => !slow.includes(t));
  if (fast.length < map.tests.length) note(`slow tier dropped: ${map.tests.filter((t) => slow.includes(t)).join(', ')}`);
  if (!fast.length) throw new UsageError(`no fast-tier test maps to ${o.file}; pass --tests=...`);
  return fast.map(stemOf);
}

const runTests = (wt, tests, timeoutMs, env) => runProcess(process.execPath,
  [join(wt, 'tools', 'tests', 'run_unit.mjs'), `--select=${tests.join(',')}`, '--no-rerun'], { cwd: wt, timeoutMs, env });

/** Runs every mutant; the file is restored (and byte-verified) after each one. */
async function mutateLoop({ file, wt, target, original, mutants, tests, timeoutMs, env }) {
  const results = [];
  const source = original.toString('utf8');
  for (const [i, m] of mutants.entries()) {
    writeFileSync(target, Buffer.from(applyMutant(source, m), 'utf8'));
    let r;
    try { r = await runTests(wt, tests, timeoutMs, env); } finally { restoreFile(target, original); }
    const c = classifyRun(r);
    if (c.infra) throw new Error(`infrastructure failure on mutant ${m.id} (line ${m.line}): ${c.infra}`);
    results.push({ ...m, ...c, ms: r.durationMs });
    note(`[${i + 1}/${mutants.length}] ${mutantLine(file, { ...m, ...c })}  (${(r.durationMs / 1000).toFixed(1)} s)`);
  }
  return results;
}

export async function main(argv) {
  const o = parseArgs(argv);
  checkFilePath(o.file);
  const g = resolveGodot();
  if (!g.ok) throw new Error(g.message);
  const t0 = Date.now();
  const wtInfo = ensureWorktree({ root: ROOT, path: o.worktree ?? undefined });
  const wt = wtInfo.path;
  note(`worktree ${wt} at ${wtInfo.head.slice(0, 8)} (${wtInfo.created ? 'created' : 'reused'})`);
  for (const r of wtInfo.repaired) note(`REPAIRED a crashed run: restored ${r} from its sidecar`);
  for (const n of wtInfo.notes) note(n);
  const release = acquireLock(wt);
  const target = join(wt, 'project', ...o.file.split('/'));
  let original = null;
  let sidecar = null;
  const cleanup = () => {
    if (original) { try { restoreFile(target, original); } catch (e) { note(String(e)); } }
    if (sidecar) { try { unlinkSync(sidecar); } catch { /* gone */ } sidecar = null; }
    release();
  };
  for (const sig of ['SIGINT', 'SIGTERM']) process.on(sig, () => { cleanup(); process.exit(130); });
  try {
    if (!existsSync(target)) throw new UsageError(`${o.file} does not exist at HEAD ${wtInfo.head.slice(0, 8)} (commit it first)`);
    original = readFileSync(target);
    const all = generateMutants(original.toString('utf8'), { ops: o.ops });
    if (!all.length) throw new UsageError(`${o.file}: no mutants for ops ${o.ops.join(',')}`);
    const mutants = sampleMutants(all, o.max, o.file);
    const tests = await pickTests(o, wt);
    const env = { ...process.env, GODOT_BIN: g.bin };
    note(`${mutants.length}/${all.length} mutant(s); baseline run of ${tests.join(', ')}`);
    const base = await runTests(wt, tests, BASELINE_TIMEOUT_MS, env);
    if (base.status !== 0 || base.timedOut) {
      throw new Error(`baseline red: the mapped tests fail on the unmutated file (exit ${base.status}${base.timedOut ? ', timeout' : ''}); `
        + `nothing mutated.\n${base.out.trim().split('\n').slice(-12).join('\n')}`);
    }
    const imp = /class cache stale[\s\S]*?--import (?:done|FAILED[^\n]*?) in ([\d.]+) s/.exec(base.out);
    const timeoutMs = (o.timeoutS || Math.min(300, Math.max(90, Math.ceil(base.durationMs / 1000) * 3))) * 1000;
    note(`baseline green in ${(base.durationMs / 1000).toFixed(1)} s; per-mutant timeout ${timeoutMs / 1000} s`);
    sidecar = writeSidecar(target, original);
    const results = await mutateLoop({ file: o.file, wt, target, original, mutants, tests, timeoutMs, env });
    const totalMs = Date.now() - t0;
    console.log(formatReport({ file: o.file, results, totalMs, tests, sampled: mutants.length < all.length ? all.length : 0 }));
    if (o.json) {
      const dir = join(ROOT, 'build', 'mutate');
      mkdirSync(dir, { recursive: true });
      const out = join(dir, `${slugOf(o.file)}.json`);
      writeFileSync(out, canonicalJson(buildJson({ file: o.file, head: wtInfo.head, tests, results, totalMs,
        baselineMs: base.durationMs, firstImportMs: imp ? Math.round(Number(imp[1]) * 1000) : null,
        total: all.length, max: o.max })));
      note(`wrote build/mutate/${slugOf(o.file)}.json`);
    }
  } finally {
    cleanup();
  }
  if (o.remove) { removeWorktree({ root: ROOT, path: wt }); note(`removed ${wt}`); }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try { await main(process.argv.slice(2)); } catch (e) {
    console.error(`mutate: ${e.message}`);
    process.exit(2);
  }
}
