#!/usr/bin/env node
// The scenario suite headless (TST-01 layer 3): tests/run_scenarios.gd, incl. the 60 s replay,
// the city replay, the bake check, the ref-vs-ref parity harness and the quest selftest.
// Scenarios may leave detail files in outDir (--evidence-dir): each quest scenario's file
// (quest-selftest.json, quest-collect-call.json) becomes an artifact of the scenario-tests
// envelope plus its metrics (quest*, collectCall*).
//   node tools/tests/run_scenarios.mjs
import { existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT, godotBin, run } from '../lib/repo.mjs';

export const LOG_NAME = 'scenario-tests.log';
/** Quest scenario detail files and the metric prefix each one's numbers get. */
export const QUEST_EVIDENCE = [
  ['quest-selftest.json', 'quest'],
  ['quest-collect-call.json', 'collectCall'],
];

/** <prefix>* metrics from one quest scenario's detail file, or {} when it did not write one. */
function questMetrics(file, prefix) {
  if (!existsSync(file)) return {};
  const q = JSON.parse(readFileSync(file, 'utf8'));
  const checks = Object.values(q.checks ?? {});
  const m = {
    Pass: q.pass ? 1 : 0,
    Ticks: q.ticks,
    BeatsReached: q.beatsReached,
    LinesShown: (q.linesShown ?? []).length,
    CashPaid: q.cash ?? 0,
    ChecksPassed: checks.filter(Boolean).length,
    ChecksTotal: checks.length,
    Stubbed: (q.stubbed ?? []).length,
  };
  return Object.fromEntries(Object.entries(m).map(([k, v]) => [prefix + k, v]));
}

export function runScenarios(outDir) {
  mkdirSync(outDir, { recursive: true });
  for (const [name] of QUEST_EVIDENCE) rmSync(join(outDir, name), { force: true });
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
  const metrics = {};
  const artifacts = [LOG_NAME];
  for (const [name, prefix] of QUEST_EVIDENCE) {
    Object.assign(metrics, questMetrics(join(outDir, name), prefix));
    if (existsSync(join(outDir, name))) artifacts.push(name);
  }
  return { ok, counts, summary, metrics, artifacts };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const r = runScenarios(join(ROOT, 'build', 'test-results'));
  console.log(r.summary);
  process.exit(r.ok ? 0 : 1);
}
