#!/usr/bin/env node
// The scenario suite headless (TST-01 layer 3): tests/run_scenarios.gd, incl. the 60 s replay,
// the city replay, the bake check, the ref-vs-ref parity harness and the quest selftest.
// Scenarios may leave detail files in outDir (--evidence-dir); the quest selftest's
// quest-selftest.json becomes an artifact plus quest* metrics of the scenario-tests envelope.
//   node tools/tests/run_scenarios.mjs
import { existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT, godotBin, run } from '../lib/repo.mjs';

export const LOG_NAME = 'scenario-tests.log';
export const QUEST_EVIDENCE = 'quest-selftest.json';

/** quest* metrics from the quest selftest's detail file, or {} when it did not write one. */
function questMetrics(file) {
  if (!existsSync(file)) return {};
  const q = JSON.parse(readFileSync(file, 'utf8'));
  const checks = Object.values(q.checks ?? {});
  return {
    questPass: q.pass ? 1 : 0,
    questTicks: q.ticks,
    questBeatsReached: q.beatsReached,
    questLinesShown: (q.linesShown ?? []).length,
    questChecksPassed: checks.filter(Boolean).length,
    questChecksTotal: checks.length,
  };
}

export function runScenarios(outDir) {
  mkdirSync(outDir, { recursive: true });
  const questFile = join(outDir, QUEST_EVIDENCE);
  rmSync(questFile, { force: true });
  const evidenceDir = `--evidence-dir=${resolve(outDir).replaceAll('\\', '/')}`;
  const args = ['--headless', '--path', 'project', '-s', 'res://tests/run_scenarios.gd', '--', evidenceDir];
  const res = run(godotBin(), args, { cwd: ROOT });
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
  const metrics = questMetrics(questFile);
  const artifacts = existsSync(questFile) ? [LOG_NAME, QUEST_EVIDENCE] : [LOG_NAME];
  return { ok, counts, summary, metrics, artifacts };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const r = runScenarios(join(ROOT, 'build', 'test-results'));
  console.log(r.summary);
  process.exit(r.ok ? 0 : 1);
}
