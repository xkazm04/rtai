#!/usr/bin/env node
// The scenario suite headless (TST-01 layer 3): tests/run_scenarios.gd, incl. the 60 s replay,
// the city replay, the bake check, the ref-vs-ref parity harness and the quest selftest.
// Scenarios may leave detail files in outDir (--evidence-dir): each quest scenario's file
// (quest-selftest.json, quest-collect-call.json) becomes an artifact of the scenario-tests
// envelope plus its metrics (quest*, collectCall*).
//   node tools/tests/run_scenarios.mjs [--quiet-wait=<minutes, default 5>] [--only=<name>[,<name>]]
//
// CONTENDED: ~15 lanes share one machine, so the two wall-clock budget scenarios (city_chase nav
// 2 ms, rig_stress p50 1 ms) cannot be judged while others run. The runner tells Godot how many other
// runs are active (GTAI_CONTENTION at launch + a live GTAI_CONTENTION_FILE, see run_ledger.mjs); a
// budget miss then logs `CONTENDED: <metric> ...` and passes. Afterwards those scenarios alone are
// re-run ONCE when the machine is quiet (waits up to --quiet-wait) and judged strictly; a machine
// that never quiets leaves the summary saying CONTENDED (neither PASS nor FAIL, exit unchanged).
// Test-only: GTAI_BUDGET_SCALE=0.001 forces a budget miss in those two scenarios.
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join, resolve, sep } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';
import { describe, removeStale, runGodot } from '../lib/godot.mjs';
import { contention, parseContended, settleContended } from '../lib/run_ledger.mjs';

export const LOG_NAME = 'scenario-tests.log';
// the suite takes ~8 min on a loaded machine; a hang past this is a parse error or a deadlock
const SCENARIOS_TIMEOUT_MS = 25 * 60 * 1000;
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

const CONTENTION_POLL_MS = 10000;
const NL = String.fromCharCode(10);

/** One Godot scenario pass. The live contention file is refreshed while it runs, so a lane that
 *  starts mid-suite still turns a later budget miss into CONTENDED. `only` re-runs named scenarios. */
async function godotPass(outDir, { only = null, strict = false, name = 'scenarios' } = {}) {
  const file = join(ROOT, 'build', `scenario-contention-${process.pid}.txt`);
  const sample = () => contention().count;
  removeStale(file);
  const initial = strict ? 0 : sample();
  writeFileSync(file, String(initial));
  const timer = setInterval(() => { try { writeFileSync(file, String(sample())); } catch { /* advisory */ } }, CONTENTION_POLL_MS);
  timer.unref();
  const evidenceDir = `--evidence-dir=${resolve(outDir).split(sep).join('/')}`;
  const args = ['-s', 'res://tests/run_scenarios.gd', '--', evidenceDir, ...(only ? [`--only=${only.join(',')}`] : [])];
  const env = { ...process.env, GTAI_CONTENTION: String(initial), GTAI_CONTENTION_FILE: file.split(sep).join('/') };
  try {
    return { ...(await runGodot(args, { name, timeoutMs: SCENARIOS_TIMEOUT_MS, env })), initial };
  } finally {
    clearInterval(timer);
    removeStale(file);
  }
}

const tally = (out) => {
  const m = /run_scenarios: (\d+) ran, (\d+) failed/.exec(out);
  return { ran: m ? Number(m[1]) : 0, failed: m ? Number(m[2]) : 0, fails: [...out.matchAll(/^FAIL (\S+):/gm)].map((f) => f[1]) };
};

export async function runScenarios(outDir, { quietWaitMs = 5 * 60 * 1000, pollMs = CONTENTION_POLL_MS, only = null } = {}) {
  mkdirSync(outDir, { recursive: true });
  removeStale(...QUEST_EVIDENCE.map(([name]) => join(outDir, name)));
  const res = await godotPass(outDir, { only });
  let log = `===== scenarios (${describe(res)}, ${res.initial} other runs at launch)${NL}${res.out}`;
  const first = tally(res.out);
  const contended = parseContended(res.out);
  const settled = await settleContended({
    contended,
    quiet: async () => contention().count === 0,
    rerun: async (names) => {
      const again = await godotPass(outDir, { only: names, strict: true, name: 'scenarios-rejudge' });
      log += `${NL}===== re-judge alone: ${names.join(', ')} (${describe(again)})${NL}${again.out}`;
      const t = tally(again.out);
      return { ok: again.status === 0 && !again.timedOut && t.ran > 0 && t.failed === 0, contended: parseContended(again.out), fails: t.fails, status: again.status, timedOut: again.timedOut };
    },
    waitMs: quietWaitMs,
    pollMs,
    log: (line) => { log += `${NL}[contention] ${line}${NL}`; console.error(`scenarios: ${line}`); },
  });
  writeFileSync(join(outDir, LOG_NAME), log, 'utf8');
  const rejudgeFails = settled.state === 'failed' ? settled.rerun.fails : [];
  const failed = first.failed + rejudgeFails.length;
  const counts = { passed: first.ran - failed, failed, skipped: 0 };
  const fails = [...first.fails, ...rejudgeFails];
  const ok = res.status === 0 && !res.timedOut && first.ran > 0 && failed === 0 && settled.state !== 'failed';
  let summary = ok
    ? `scenario-tests: ${first.ran} passed (headless)`
    : `scenario-tests: ${describe(res)},${failed} of ${first.ran} failed${fails.length ? ` (${fails.join(', ')})` : ''}`;
  if (settled.state === 'passed') summary += `; ${contended.map((c) => c.scenario).join(', ')} missed under contention, re-judged alone: within budget`;
  if (settled.state === 'failed') summary += `; budget re-judged alone on a quiet machine: FAIL (${rejudgeFails.join(', ') || 'see log'})`;
  if (settled.state === 'contended') {
    summary = `scenario-tests: ${first.ran} ran${ok ? '' : `, ${failed} failed`}, CONTENDED: ${settled.contended.map((c) => c.text).join('; ')}; budget not judged, ${settled.why}`;
  }
  const metrics = { scenarioContended: settled.state === 'contended' ? settled.contended.length : 0 };
  const artifacts = [LOG_NAME];
  for (const [name, prefix] of QUEST_EVIDENCE) {
    Object.assign(metrics, questMetrics(join(outDir, name), prefix));
    if (existsSync(join(outDir, name))) artifacts.push(name);
  }
  return { ok, counts, summary, metrics, artifacts, durationMs: res.durationMs, contended: settled.state === 'contended', verdict: settled.state };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const qw = process.argv.find((a) => a.startsWith('--quiet-wait='));
  const only = process.argv.find((a) => a.startsWith('--only='));
  const r = await runScenarios(join(ROOT, 'build', 'test-results'), {
    ...(qw ? { quietWaitMs: Number(qw.split('=')[1]) * 60000 } : {}),
    ...(only ? { only: only.split('=')[1].split(',') } : {}),
  });
  console.log(r.summary);
  process.exit(r.ok ? 0 : 1);
}
