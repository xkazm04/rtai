#!/usr/bin/env node
// The scenario suite headless (TST-01 layer 3): tests/run_scenarios.gd, incl. the 60 s replay,
// the city replay, the bake check and the ref-vs-ref parity harness.
//   node tools/tests/run_scenarios.mjs
import { mkdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT, godotBin, run } from '../lib/repo.mjs';

export const LOG_NAME = 'scenario-tests.log';

export function runScenarios(outDir) {
  mkdirSync(outDir, { recursive: true });
  const res = run(godotBin(), ['--headless', '--path', 'project', '-s', 'res://tests/run_scenarios.gd'], { cwd: ROOT });
  writeFileSync(join(outDir, LOG_NAME), res.out, 'utf8');
  const m = /run_scenarios: (\d+) ran, (\d+) failed/.exec(res.out);
  const ran = m ? Number(m[1]) : 0;
  const failed = m ? Number(m[2]) : 0;
  const counts = { passed: ran - failed, failed, skipped: 0 };
  const fails = [...res.out.matchAll(/^FAIL (\S+):/gm)].map((f) => f[1]);
  const ok = res.status === 0 && ran > 0 && failed === 0;
  const summary = ok
    ? `scenario-tests: ${ran} passed (headless)`
    : `scenario-tests: exit ${res.status}, ${failed} of ${ran} failed${fails.length ? ` (${fails.join(', ')})` : ''}`;
  return { ok, counts, summary, artifacts: [LOG_NAME] };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const r = runScenarios(join(ROOT, 'build', 'test-results'));
  console.log(r.summary);
  process.exit(r.ok ? 0 : 1);
}
