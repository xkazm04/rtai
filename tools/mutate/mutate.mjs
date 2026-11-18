#!/usr/bin/env node
// Real mutation testing for one GDScript file: "do my tests bite on this file?"
//   node tools/mutate/mutate.mjs --file=<project-relative .gd> [--lines=<n,a-b>] [--max=N] [--ops=a,b] [--tests=<basenames>]
//                                [--oracle=tests,bake-check] [--timeout=<s>] [--worktree=<path>] [--remove-worktree] [--json]
// All mutation happens in a dedicated git worktree OUTSIDE the repo (see worktree.mjs and the README);
// the main checkout is only read, and --json writes build/mutate/<slug>.json in it. Exit 0 for every
// completed run (it is a measurement), 2 for usage or infrastructure errors.
import { existsSync, mkdirSync, readFileSync, unlinkSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { canonicalJson } from '../lib/canonical_json.mjs';
import { resolveGodot } from '../lib/godot.mjs';
import { ROOT } from '../lib/repo.mjs';
import { OPS, applyMutant, generateMutants, sampleMutants } from './operators.mjs';
import { baseline, judgeMutant, ORACLES, oracleRunners } from './oracles.mjs';
import { buildJson, formatReport, mutantLine } from './report.mjs';
import { ensureWorktree, removeWorktree, restoreFile, slugOf, stemOf, writeSidecar }
  from './worktree.mjs';

export class UsageError extends Error {}

function parseLines(value) {
  return value.split(',').map((item) => {
    const match = /^(\d+)(?:-(\d+))?$/.exec(item);
    if (match) {
      const first = Number(match[1]);
      const last = Number(match[2] ?? match[1]);
      if (first > 0 && last >= first && Number.isSafeInteger(last)) return [first, last];
    }
    throw new UsageError(`invalid --lines=${value}; expected positive line numbers or ranges like 40-60`);
  });
}

/** Keep source order and original mutant ids, even for overlapping ranges. */
export function filterMutantsByLines(mutants, ranges) {
  if (!ranges) return mutants;
  const selected = mutants.filter(({ line }) => ranges.some(([a, b]) => a <= line && line <= b));
  if (selected.length) return selected;
  const lines = [...new Set(mutants.map((m) => m.line))].sort((a, b) => a - b);
  const nearby = new Set();
  for (const [a, b] of ranges) {
    const before = lines.findLast((n) => n < a);
    const after = lines.find((n) => n > b);
    if (before !== undefined) nearby.add(before);
    if (after !== undefined) nearby.add(after);
  }
  const requested = ranges.map(([a, b]) => a === b ? a : `${a}-${b}`);
  throw new UsageError(`--lines=${requested.join(',')} matches no mutants; nearest mutant lines: ${[...nearby].join(', ') || 'none'}`);
}

/** argv -> options; unknown or malformed args throw UsageError. */
export function parseArgs(argv) {
  const o = { file: null, max: 0, ops: OPS, tests: [], oracles: ['tests'], explicit: false,
    timeoutS: 0, worktree: null, json: false, remove: false };
  const unknown = [];
  for (const a of argv) {
    const k = a.split('=')[0];
    const v = a.includes('=') ? a.slice(a.indexOf('=') + 1) : '';
    if (k === '--file' && v) o.file = v.replace(/\\/g, '/');
    else if (k === '--lines') o.lines = parseLines(v);
    else if (k === '--max' && /^\d+$/.test(v) && Number(v) > 0) o.max = Number(v);
    else if (k === '--ops' && v) o.ops = v.split(',').filter(Boolean);
    else if (k === '--oracle' && v) {
      o.oracles = v.split(',');
      if (o.oracles.some((name) => !ORACLES.includes(name))) {
        throw new UsageError(`invalid --oracle=${v}; known: ${ORACLES.join(',')}`);
      }
      o.explicit = true;
    }
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
export async function pickTests(o, wt) {
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

/** Runs every mutant; the file is restored (and byte-verified) after each one. */
async function mutateLoop({ file, target, original, mutants, names, runners, timeoutMs, oracles }) {
  const results = [];
  const source = original.toString('utf8');
  for (const [i, m] of mutants.entries()) {
    writeFileSync(target, Buffer.from(applyMutant(source, m), 'utf8'));
    let decision;
    try { decision = await judgeMutant(names, runners, timeoutMs); } finally { restoreFile(target, original); }
    if (decision.infra) throw new Error(`infrastructure failure on mutant ${m.id} (line ${m.line}): ${decision.infra}`);
    const result = { ...m, ...decision };
    results.push(result);
    note(`[${i + 1}/${mutants.length}] ${mutantLine(file, result, oracles)}  (${(result.ms / 1000).toFixed(1)} s)`);
  }
  return results;
}

/** Run with exclusive ownership of the scratch file. Save its sidecar just before the first write. */
export async function withMutationFile(o, run) {
  checkFilePath(o.file);
  const g = resolveGodot();
  if (!g.ok) throw new Error(g.message);
  const t0 = Date.now();
  const wtInfo = ensureWorktree({ root: ROOT, path: o.worktree ?? undefined });
  const wt = wtInfo.path;
  note(`worktree ${wt} at ${wtInfo.head.slice(0, 8)} (${wtInfo.created ? 'created' : 'reused'})`);
  for (const r of wtInfo.repaired) note(`REPAIRED a crashed run: restored ${r} from its sidecar`);
  for (const n of wtInfo.notes) note(n);
  const target = join(wt, 'project', ...o.file.split('/'));
  let original = null;
  let sidecar = null;
  const cleanup = () => {
    try {
      if (sidecar) {
        restoreFile(target, original);
        unlinkSync(sidecar);
      }
    } finally { wtInfo.release(); }
  };
  const interrupt = () => process.exit(130);
  process.once('exit', cleanup);
  for (const sig of ['SIGINT', 'SIGTERM']) process.once(sig, interrupt);
  try {
    if (!existsSync(target)) throw new UsageError(`${o.file} does not exist at HEAD ${wtInfo.head.slice(0, 8)} (commit it first)`);
    original = readFileSync(target);
    const saveOriginal = () => { sidecar = writeSidecar(target, original); };
    return await run({ wt, wtInfo, target, original, saveOriginal, t0, env: { ...process.env, GODOT_BIN: g.bin } });
  } finally {
    process.off('exit', cleanup);
    for (const sig of ['SIGINT', 'SIGTERM']) process.off(sig, interrupt);
    cleanup();
  }
}

export async function main(argv) {
  const o = parseArgs(argv);
  const wt = await withMutationFile(o, async ({ wt, wtInfo, target, original, saveOriginal, t0, env }) => {
    const all = filterMutantsByLines(generateMutants(original.toString('utf8'), { ops: o.ops }), o.lines);
    if (!all.length) throw new UsageError(`${o.file}: no mutants for ops ${o.ops.join(',')}`);
    const mutants = sampleMutants(all, o.max, o.file);
    const tests = o.oracles.includes('tests') ? await pickTests(o, wt) : [];
    const oracles = o.explicit ? o.oracles : undefined;
    note(`${mutants.length}/${all.length} mutant(s); baseline run of ${(oracles ?? tests).join(', ')}`);
    const runners = oracleRunners(wt, tests, env, o.explicit);
    const base = await baseline({ names: o.oracles, runners, wt, timeoutS: o.timeoutS, explicit: o.explicit, note });
    const { timeoutMs } = base;
    note(`baseline green in ${(base.durationMs / 1000).toFixed(1)} s; per-mutant timeout ${timeoutMs / 1000} s`);
    saveOriginal();
    const results = await mutateLoop({ file: o.file, target, original, mutants, names: o.oracles, runners, timeoutMs, oracles });
    const totalMs = Date.now() - t0;
    console.log(formatReport({ file: o.file, results, totalMs, tests, oracles, sampled: mutants.length < all.length ? all.length : 0 }));
    if (o.json) {
      const dir = join(ROOT, 'build', 'mutate');
      mkdirSync(dir, { recursive: true });
      const out = join(dir, `${slugOf(o.file)}.json`);
      writeFileSync(out, canonicalJson(buildJson({ file: o.file, head: wtInfo.head, tests, oracles, results, totalMs,
        baselineMs: base.durationMs, firstImportMs: base.firstImportMs,
        total: all.length, max: o.max })));
      note(`wrote build/mutate/${slugOf(o.file)}.json`);
    }
    return wt;
  });
  if (o.remove) { removeWorktree({ root: ROOT, path: wt }); note(`removed ${wt}`); }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try { await main(process.argv.slice(2)); } catch (e) {
    console.error(`mutate: ${e.message}`);
    process.exit(2);
  }
}
