#!/usr/bin/env node
// Unit + integration tests headless (TST-01 layers 1-2): import, load every script, then GUT.
//   node tools/tests/run_unit.mjs [--select=<name|glob>[,..]]... [--test=<test function>]
//                                 [--changed[=<git ref>]] [--fast] [--all] [--no-rerun]
// No args = EVERYTHING (the gate). --fast skips the slow tier (tools/tests/tiers.json). --select
// takes test file basenames (test_x, x or a glob). --test runs the files that define that test
// function. --changed maps the changed files to tests (tools/tests/test_map.mjs), skipping the slow
// tier unless it is mapped (--all adds it to a full-suite fallback). Unknown args exit 2.
// After failures each failing test FILE is re-run once in isolation: fail-then-pass is FLAKY
// (loud line, one JSON line in the machine-wide ledger, see flakes.mjs; the run stays ok, the
// summary says FLAKY n and the evidence carries metrics.flaky); failing twice fails the run.
// --no-rerun turns that off. Selections write a temp gutconfig under build/test-results/ (dirs emptied, tests = the files).
// Guards GUT's silent-green hazard (a test file that fails to parse is skipped and GUT exits 0):
// any SCRIPT ERROR / Parse Error line, or zero tests run, is a failure.
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { PROJECT, ROOT, readJson } from '../lib/repo.mjs';
import { SCRIPT_ERROR, describe, removeStale, runGodot } from '../lib/godot.mjs';
import { digestLines, parseJunit, slowest } from './junit.mjs';
import { classifyRerun, flakeEntry, recordFlake } from './flakes.mjs';
import { changedFiles, mapChanges, realIndex } from './test_map.mjs';

export const JUNIT_NAME = 'unit-tests.junit.xml';
export const LOG_NAME = 'unit-tests.log';
export const CONFIG_NAME = 'unit-tests.gutconfig.json';
const FLAGS = ['--all', '--fast'];
export const RERUN_JUNIT = 'unit-tests.rerun.junit.xml';

export class UsageError extends Error {}

const godot = (name, args) => runGodot(args, { name });

/** argv -> {select, test, changed (false | true | ref), all, fast}; unknown args throw UsageError. */
export function parseArgs(argv) {
  const o = { select: [], test: null, changed: false, all: false, fast: false, rerun: true };
  const unknown = [];
  for (const a of argv) {
    const k = a.split('=')[0];
    const v = a.includes('=') ? a.slice(a.indexOf('=') + 1) : null;
    if (k === '--select' && v) o.select.push(...v.split(',').filter(Boolean));
    else if (k === '--test' && v) o.test = v;
    else if (k === '--changed') o.changed = v || true;
    else if (a === '--no-rerun') o.rerun = false;
    else if (FLAGS.includes(a)) o[a.slice(2)] = true;
    else unknown.push(a);
  }
  if (unknown.length) throw new UsageError(`unknown or malformed argument(s): ${unknown.join(' ')}`);
  return o;
}

const globRe = (g) => new RegExp(`^${g.replace(/[.+?^${}()|[\]\\]/g, '\\$&').replace(/\*/g, '.*')}$`);
const stem = (p) => p.split('/').pop().replace(/\.gd$/, '');

/** Slow tier (tools/tests/tiers.json), as paths relative to project/. */
export const slowTier = () => readJson(join(ROOT, 'tools', 'tests', 'tiers.json')).slow;

/** Which test files to run. -> {files: null (everything, the config's own dirs) | string[] (relative
 *  to project/), skipped, notes, targeted}. Throws UsageError for a select that matches nothing. */
export function buildPlan(o, index = realIndex(), slow = slowTier(), changedList = null) {
  const all = Object.keys(index.tests).sort();
  const fastOnly = (list) => (o.all ? list : list.filter((f) => !slow.includes(f)));
  const notes = [];
  let files = null;
  if (o.select.length) {
    files = [...new Set(o.select.flatMap((g) => {
      const res = globRe(g.replace(/\.gd$/, ''));
      const hit = all.filter((f) => res.test(stem(f)) || (!g.includes('*') && stem(f) === `test_${g}`));
      if (!hit.length) throw new UsageError(`--select=${g} matches no test file`);
      return hit;
    }))].sort();
  } else if (o.changed) {
    const map = mapChanges(changedList ?? changedFiles(o.changed === true ? null : o.changed), index);
    notes.push(...map.notes);
    if (map.full) { notes.push(`FULL suite: ${map.full}`); files = fastOnly(all); } else files = map.tests;
    if (!files.length) notes.push('no unit tests needed for this change');
  }
  if (o.test) {
    const re = new RegExp(`^func ${o.test.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}`, 'm');
    files = (files ?? fastOnly(all)).filter((f) => re.test(index.tests[f]));
    if (!files.length) throw new UsageError(`--test=${o.test}: no selected test file defines it`);
  }
  if (!files && o.fast) files = fastOnly(all);
  const targeted = Boolean(o.select.length || o.changed || o.test);
  const skipped = files && !targeted ? all.length - files.length : 0;
  if (skipped) notes.push(`slow tier skipped: ${skipped} file(s): ${slow.join(', ')}`);
  return { files, skipped, notes, targeted, testName: o.test };
}

/** A temp gutconfig (dirs emptied, tests = the res:// files) under outDir; returns its path. */
function writeConfig(outDir, files, testName) {
  const cfg = readJson(join(PROJECT, '.gutconfig.json'));
  cfg.dirs = [];
  cfg.tests = files.map((f) => `res://${f}`);
  if (testName) cfg.unit_test_name = testName;
  const path = join(outDir, CONFIG_NAME);
  writeFileSync(path, `${JSON.stringify(cfg, null, 2)}\n`, 'utf8');
  return path.replace(/\\/g, '/');
}

/** SCRIPT ERROR and load_all FAILED lines, each followed by its `at:` line (file:line) when present. */
export function scriptErrors(out) {
  const lines = out.split('\n');
  return lines.flatMap((l, i) => (/^load_all: FAILED /.test(l) ? [l.trim()] : SCRIPT_ERROR.test(l)
    ? [l.trim(), ...(/^\s*at:/.test(lines[i + 1] ?? '') ? [lines[i + 1].trim()] : [])] : []));
}

const NONE = { passed: 0, failed: 0, skipped: 0 };

/** One GUT pass over `files` (null = the config's own dirs). */
async function gutPass(outDir, files, testName, junitName) {
  const junit = join(outDir, junitName).replace(/\\/g, '/');
  removeStale(join(outDir, junitName)); // never read a previous run's tally
  const config = files ? writeConfig(outDir, files, testName) : 'res://.gutconfig.json';
  const r = await godot('gut', ['-s', 'res://addons/gut/gut_cmdln.gd', `-gconfig=${config}`,
    `-gjunit_xml_file=${junit}`]);
  let parsed = { counts: NONE, cases: [] };
  let missing = false;
  try { parsed = parseJunit(readFileSync(junit, 'utf8')); } catch { missing = true; }
  return { r, ...parsed, missing };
}

export async function runUnit(outDir, opts = {}) {
  mkdirSync(outDir, { recursive: true });
  const plan = buildPlan({ select: [], test: null, changed: false, all: false, fast: false, rerun: true, ...opts });
  if (plan.files && plan.files.length === 0) {
    return { ok: true, counts: NONE, summary: `unit-tests: ${plan.notes.at(-1)}; 0 passed, 0 failed, 0 skipped`,
      artifacts: [], notes: plan.notes, digest: [], slowest: [], ran: 0 };
  }
  const probe = await godot('version', ['--version']);
  if (probe.status !== 0) {
    const summary = `unit-tests: ${probe.out.split('\n')[0]}; 0 passed, 0 failed, 0 skipped`;
    return { ok: false, counts: { ...NONE }, summary, artifacts: [], notes: plan.notes, digest: [], slowest: [] };
  }
  const steps = [['import', await godot('import', ['--import'])]];
  if (!plan.targeted) steps.push(['load_all', await godot('load_all', ['-s', 'res://tests/load_all.gd'])]);
  const gut = await gutPass(outDir, plan.files, plan.testName, JUNIT_NAME);
  steps.push(['gut', gut.r]);
  const failed = gut.cases.filter((c) => c.status === 'fail');
  const flake = failed.length && opts.rerun !== false ? await rerunFailures(outDir, failed) : { flaky: [], failing: failed, log: '', notes: [] };
  if (flake.rerun) steps.push(['gut rerun', flake.rerun]);
  const log = steps.map(([name, r]) => `===== ${name} (${describe(r)})\n${r.out}`).join('\n');
  writeFileSync(join(outDir, LOG_NAME), log, 'utf8');
  const explained = failed.length > 0 && flake.failing.length === 0; // every failure passed on re-run
  const problems = [];
  for (const [name, r] of steps) {
    if (r.timedOut) problems.push(`${name} timed out`);
    else if (r.status !== 0 && !(name === 'gut' && explained)) problems.push(`${name} exit ${r.status}`);
    if (SCRIPT_ERROR.test(r.out)) problems.push(`${name} reported script errors`);
  }
  if (gut.missing) problems.push('no JUnit report');
  const n = flake.flaky.length;
  const counts = { ...gut.counts, passed: gut.counts.passed + n, failed: gut.counts.failed - n };
  if (counts.passed + counts.failed === 0) problems.push('zero tests ran');
  if (counts.failed > 0) problems.push(`${counts.failed} failing`);
  if (n) problems.push(`FLAKY ${n}`);
  const ok = problems.every((p) => p.startsWith('FLAKY'));
  const tally = `${counts.passed} passed, ${counts.failed} failed, ${counts.skipped} skipped`;
  const scope = (plan.skipped ? `, slow tier skipped (${plan.skipped} file)` : '') + (n ? `, FLAKY ${n}` : '');
  const summary = ok ? `unit-tests: ${tally} (GUT, headless${scope})` : `unit-tests: ${problems.join('; ')} (${tally})`;
  const durationMs = steps.reduce((a, [, r]) => a + r.durationMs, 0);
  const errs = steps.flatMap(([, r]) => scriptErrors(r.out));
  const flakyLines = flake.flaky.map((c) => `FLAKY: ${c.file} ${c.name}`);
  return { ok, counts, summary, durationMs, notes: [...plan.notes, ...flake.notes], ran: gut.cases.length,
    artifacts: [JUNIT_NAME, LOG_NAME, ...(flake.rerun ? [RERUN_JUNIT] : [])], ...(n ? { metrics: { flaky: n } } : {}),
    flaky: flakyLines, digest: [...digestLines(flake.failing), ...errs], slowest: slowest(gut.cases) };
}

/** Re-runs each failing test file once in isolation. -> {flaky, failing, rerun (godot result), notes};
 *  every flaky test is appended to the machine-wide ledger. */
async function rerunFailures(outDir, failed) {
  const files = [...new Set(failed.map((c) => c.file.slice('res://'.length)))].sort();
  const pass = await gutPass(outDir, files, null, RERUN_JUNIT);
  const { flaky, failing } = classifyRerun(failed, pass.cases);
  const notes = [];
  for (const c of flaky) {
    try { recordFlake(flakeEntry(c.file, c.name)); } catch (e) { notes.push(`flake ledger not written: ${e.message}`); }
  }
  return { flaky, failing, rerun: pass.r, notes };
}

/** Prints the notes, the failure digest, and (for a full run) the 10 slowest tests. */
export function report(result, full) {
  for (const n of result.notes ?? []) console.log(`note: ${n}`);
  console.log(result.summary);
  for (const l of result.flaky ?? []) console.log(l);
  for (const l of result.digest ?? []) console.log(`  FAIL ${l}`);
  if (full && result.slowest?.length) console.log(`10 slowest tests:\n${result.slowest.join('\n')}`);
  if (result.durationMs) console.log(`log: build/test-results/${LOG_NAME} (${(result.durationMs / 1000).toFixed(1)} s)`);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  let opts;
  try { opts = parseArgs(process.argv.slice(2)); } catch (e) {
    if (!(e instanceof UsageError)) throw e;
    console.error(`run_unit: ${e.message}`);
    process.exit(2);
  }
  let result;
  try { result = await runUnit(join(ROOT, 'build', 'test-results'), opts); } catch (e) {
    if (!(e instanceof UsageError)) throw e;
    console.error(`run_unit: ${e.message}`);
    process.exit(2);
  }
  report(result, !opts.select.length && !opts.test && !opts.changed);
  process.exit(result.ok ? 0 : 1);
}
