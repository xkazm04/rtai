#!/usr/bin/env node
// Unit + integration tests headless (TST-01 layers 1-2): import, load every script, then GUT.
//   node tools/tests/run_unit.mjs
// Guards GUT's silent-green hazard (a test file that fails to parse is skipped and GUT exits 0):
// any SCRIPT ERROR / Parse Error line, or zero tests run, is a failure.
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT, godotBin, run } from '../lib/repo.mjs';

export const JUNIT_NAME = 'unit-tests.junit.xml';
export const LOG_NAME = 'unit-tests.log';
const SCRIPT_ERROR = /SCRIPT ERROR|Parse Error|Compile Error|Failed to load script/;

const godot = (args) => run(godotBin(), ['--headless', '--path', 'project', ...args], { cwd: ROOT });

function junitCounts(xml) {
  const attr = (name) => [...xml.matchAll(new RegExp(`<testsuite [^>]*\\b${name}="(\\d+)"`, 'g'))]
    .reduce((sum, m) => sum + Number(m[1]), 0);
  const tests = attr('tests');
  const failed = attr('failures') + attr('errors');
  const skipped = attr('skipped');
  return { passed: tests - failed - skipped, failed, skipped };
}

export function runUnit(outDir) {
  mkdirSync(outDir, { recursive: true });
  const junit = join(outDir, JUNIT_NAME).replace(/\\/g, '/');
  const steps = [
    ['import', godot(['--import'])],
    ['load_all', godot(['-s', 'res://tests/load_all.gd'])],
    ['gut', godot(['-s', 'res://addons/gut/gut_cmdln.gd', '-gconfig=res://.gutconfig.json',
      `-gjunit_xml_file=${junit}`])],
  ];
  const log = steps.map(([name, r]) => `===== ${name} (exit ${r.status})\n${r.out}`).join('\n');
  writeFileSync(join(outDir, LOG_NAME), log, 'utf8');
  const problems = [];
  for (const [name, r] of steps) {
    if (r.status !== 0) problems.push(`${name} exit ${r.status}`);
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
  return { ok, counts, summary, artifacts: [JUNIT_NAME, LOG_NAME] };
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const result = runUnit(join(ROOT, 'build', 'test-results'));
  console.log(result.summary);
  process.exit(result.ok ? 0 : 1);
}
