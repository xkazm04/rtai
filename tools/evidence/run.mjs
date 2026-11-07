#!/usr/bin/env node
// Evidence writer: runs lint, the unit tests, the scenario suite, the parity gate, the render
// selftest and the city bench, and writes the PoF wire contract pof.godot-evidence/1 to
// build/evidence/{lint,unit-tests,scenario-tests,parity,selftest,export-audit,bench}.json.
//   node tools/evidence/run.mjs [--allow-dirty] [--no-parity] [--no-bench] [--bench-headless]
//                               [--no-selftest] [--no-release]
// --no-parity / --no-bench / --no-selftest / --no-release skip a kind (its file is not rewritten, so PoF sees
// it stale or absent, never a fake pass): for runners without the native library or a display.
// Commit first: the evidence names HEAD, and PoF treats evidence from another commit as stale.
// A dirty tree is refused (the evidence would describe code that is not HEAD) unless
// --allow-dirty, which says so in every summary. A run that dirties the tree (import churn)
// fails the unit-tests evidence. Both checks ignore the inert set (scope.mjs: docs/**, evidence/**,
// root JOURNAL.md / REPORT.md), which no kind reads; uncommitted inert paths are only named in a
// summary suffix.
import { mkdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT, dirtyLines, git, godotBin, godotVersion } from '../lib/repo.mjs';
import { runLint } from '../lint/lint.mjs';
import { runUnit } from '../tests/run_unit.mjs';
import { runScenarios } from '../tests/run_scenarios.mjs';
import { runParity } from '../tests/run_parity.mjs';
import { releaseCompile } from '../tests/release_compile.mjs';
import { runBench } from '../bench/run.mjs';
import { runSelftest } from '../selftest/run.mjs';
import { makeEnvelope } from './envelope.mjs';
import { classify, inertNote } from './scope.mjs';

const OUT = join(ROOT, 'build', 'evidence');
const FLAGS = ['--allow-dirty', '--no-parity', '--no-bench', '--bench-headless', '--no-selftest', '--no-release'];

/** The start gate over porcelain lines: refuse (exit 2) on code dirt unless allowDirty; inert dirt only adds a note. */
export function dirtyGate(lines, allowDirty) {
  const c = classify(lines);
  if (c.code && !allowDirty) {
    const messages = ['evidence: working tree is dirty; commit first (or pass --allow-dirty):'];
    for (const l of c.codeLines.slice(0, 20)) messages.push(`  ${l}`);
    return { exit: 2, messages, note: '' };
  }
  const dirty = c.code ? ` [dirty tree: ${c.code} uncommitted paths]` : '';
  return { exit: null, messages: [], note: dirty + inertNote(c.inert) };
}

/**
 * Fails `unit` when the run added code-path porcelain lines (import churn); inert churn is ignored.
 * Lines compare without leading space: dirtyLines() trims the first line, wherever it lands.
 */
export function applyChurn(unit, before, after) {
  const seen = new Set(before.map((l) => l.trimStart()));
  const churn = classify(after.filter((l) => !seen.has(l.trimStart()))).codeLines;
  if (!churn.length) return unit;
  return {
    ...unit,
    ok: false,
    summary: `${unit.summary}; tree changed during run (${churn.length} paths, import churn): ${churn.slice(0, 3).join(', ')}`,
  };
}

async function main() {
  const unknown = process.argv.slice(2).filter((a) => !FLAGS.includes(a));
  if (unknown.length) {
    console.error(`evidence: unknown argument(s) ${unknown.join(' ')}`);
    return 2;
  }
  const before = dirtyLines();
  const gate = dirtyGate(before, process.argv.includes('--allow-dirty'));
  for (const m of gate.messages) console.error(m);
  if (gate.exit !== null) return gate.exit;
  const commit = git('rev-parse', 'HEAD');
  const version = godotVersion();
  const base = { commit, godotVersion: version ?? 'unavailable' };
  const dirtyNote = gate.note;
  mkdirSync(OUT, { recursive: true });

  const lint = runLint();
  const lintCounts = {
    passed: lint.checks.filter((c) => c.ok).length,
    failed: lint.checks.filter((c) => !c.ok).length,
    skipped: 0,
  };
  const lintLog = lint.checks.map((c) => `${c.ok ? 'ok  ' : 'FAIL'} ${c.name}\n${c.issues.map((i) => `     ${i}\n`).join('')}`);
  writeFileSync(join(OUT, 'lint.log'), lintLog.join(''), 'utf8');
  const envelopes = [makeEnvelope({
    ...base, kind: 'lint', ok: lint.ok, summary: lint.summary + dirtyNote,
    counts: lintCounts, artifacts: ['lint.log'],
  })];

  let unit;
  if (version) {
    unit = applyChurn(await runUnit(OUT), before, dirtyLines());
  } else {
    unit = { ok: false, summary: `unit-tests: Godot not found (GODOT_BIN=${godotBin()})` };
  }
  envelopes.push(makeEnvelope({ ...base, kind: 'unit-tests', ...unit, summary: unit.summary + dirtyNote }));
  for (const [kind, res] of await laterKinds(version)) {
    envelopes.push(makeEnvelope({ ...base, kind, ...res, summary: res.summary + dirtyNote }));
  }

  for (const env of envelopes) {
    const file = join(OUT, `${env.kind}.json`);
    writeFileSync(file, `${JSON.stringify(env, null, 2)}\n`, 'utf8');
    console.log(`${env.status === 'pass' ? 'PASS' : 'FAIL'} ${env.kind}: ${env.summary}`);
    console.log(`     -> ${file}`);
  }
  console.log(`evidence: commit ${commit}, godot ${base.godotVersion}`);
  return envelopes.every((e) => e.status === 'pass') ? 0 : 1;
}

/** scenario-tests, then parity and bench unless skipped. */
async function laterKinds(version) {
  const missing = (k) => ({ ok: false, summary: `${k}: Godot not found (GODOT_BIN=${godotBin()})` });
  if (!version) return [['scenario-tests', missing('scenario-tests')], ['parity', missing('parity')]];
  const out = [['scenario-tests', await runScenarios(OUT)]];
  if (!process.argv.includes('--no-parity')) out.push(['parity', await runParity(OUT)]);
  if (!process.argv.includes('--no-selftest')) out.push(['selftest', await runSelftest(OUT)]);
  if (!process.argv.includes('--no-release')) out.push(['export-audit', await releaseEvidence()]); // release-compile; the PCK audit (EXP-05) joins this kind
  if (!process.argv.includes('--no-bench')) {
    out.push(['bench', await runBench(OUT, { headless: process.argv.includes('--bench-headless') })]);
  }
  return out;
}

/** export-audit, part 1: what a release export ships still compiles (tools/tests/release_compile.mjs). */
async function releaseEvidence() {
  const r = await releaseCompile();
  const ran = r.ran ?? 0;
  const summary = r.ran === null
    ? `release-compile: the load pass did not run (${r.timedOut ? 'timed out' : `exit ${r.status}`})`
    : `release-compile: ${ran} loaded, ${r.failed.length} failed${r.failed.length ? ` (${r.failed.slice(0, 3).join(', ')})` : ''}`;
  return { ok: r.ok, summary, counts: { passed: ran, failed: r.failed.length, skipped: 0 } };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(await main());
}
