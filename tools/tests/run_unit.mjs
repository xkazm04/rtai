#!/usr/bin/env node
// Unit + integration tests headless (TST-01 layers 1-2): import, load every script, then GUT.
//   node tools/tests/run_unit.mjs
// Guards GUT's silent-green hazard (a test file that fails to parse is skipped and GUT exits 0):
// any SCRIPT ERROR / Parse Error line, or zero tests run, is a failure.
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';
import { SCRIPT_ERROR, describe, removeStale, runGodot } from '../lib/godot.mjs';

export const JUNIT_NAME = 'unit-tests.junit.xml';
export const LOG_NAME = 'unit-tests.log';

const godot = (name, args) => runGodot(args, { name });

function junitCounts(xml) {
  const attr = (name) => [...xml.matchAll(new RegExp(`<testsuite [^>]*\\b${name}="(\\d+)"`, 'g'))]
    .reduce((sum, m) => sum + Number(m[1]), 0);
  const tests = attr('tests');
  const failed = attr('failures') + attr('errors');
  const skipped = attr('skipped');
  return { passed: tests - failed - skipped, failed, skipped };
}

export async function runUnit(outDir) {
  mkdirSync(outDir, { recursive: true });
  const junit = join(outDir, JUNIT_NAME).replace(/\\/g, '/');
  removeStale(join(outDir, JUNIT_NAME)); // never read a previous run's tally
  const probe = await godot('version', ['--version']);
  if (probe.status !== 0) {
    const summary = `unit-tests: ${probe.out.split('\n')[0]}; 0 passed, 0 failed, 0 skipped`;
    return { ok: false, counts: { passed: 0, failed: 0, skipped: 0 }, summary, artifacts: [] };
  }
  const steps = [
    ['import', await godot('import', ['--import'])],
    ['load_all', await godot('load_all', ['-s', 'res://tests/load_all.gd'])],
    ['gut', await godot('gut', ['-s', 'res://addons/gut/gut_cmdln.gd', '-gconfig=res://.gutconfig.json',
      `-gjunit_xml_file=${junit}`])],
  ];
  const log = steps.map(([name, r]) => `===== ${name} (${describe(r)})\n${r.out}`).join('\n');
  writeFileSync(join(outDir, LOG_NAME), log, 'utf8');
  const problems = [];
  for (const [name, r] of steps) {
    if (r.timedOut) problems.push(`${name} timed out`);
    else if (r.status !== 0) problems.push(`${name} exit ${r.status}`);
    if (SCRIPT_ERROR.test(r.out)) problems.push(`${name} reported script errors`);
  }
  let counts = { passed: 0, failed: 0, skipped: 0 };
  try {
    counts = junitCounts(readFileSync(junit, 'utf8'));
  } catch {
    problems.push('no JUnit report');
  }
  if (counts.passed + counts.failed === 0) problems.push('zero tests ran');
  if (counts.failed > 0) problems.push(`${counts.failed} failing`);
  const ok = problems.length === 0;
  const tally = `${counts.passed} passed, ${counts.failed} failed, ${counts.skipped} skipped`;
  const summary = ok ? `unit-tests: ${tally} (GUT, headless)` : `unit-tests: ${problems.join('; ')} (${tally})`;
  const durationMs = steps.reduce((a, [, r]) => a + r.durationMs, 0);
  return { ok, counts, summary, artifacts: [JUNIT_NAME, LOG_NAME], durationMs };
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const result = await runUnit(join(ROOT, 'build', 'test-results'));
  console.log(result.summary);
  process.exit(result.ok ? 0 : 1);
}
