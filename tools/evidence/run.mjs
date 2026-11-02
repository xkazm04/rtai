#!/usr/bin/env node
// Evidence writer: runs lint, the unit tests, the scenario suite, the parity gate, the render
// selftest and the city bench, and writes the PoF wire contract pof.godot-evidence/1 to
// build/evidence/{lint,unit-tests,scenario-tests,parity,selftest,bench}.json.
//   node tools/evidence/run.mjs [--allow-dirty] [--no-parity] [--no-bench] [--bench-headless]
//                               [--no-selftest]
// --no-parity / --no-bench / --no-selftest skip a kind (its file is not rewritten, so PoF sees
// it stale or absent, never a fake pass): for runners without the native library or a display.
// Commit first: the evidence names HEAD, and PoF treats evidence from another commit as stale.
// A dirty tree is refused (the evidence would describe code that is not HEAD) unless
// --allow-dirty, which says so in every summary. A run that dirties the tree (import churn)
// fails the unit-tests evidence.
import { mkdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { ROOT, dirtyLines, git, godotBin, godotVersion } from '../lib/repo.mjs';
import { runLint } from '../lint/lint.mjs';
import { runUnit } from '../tests/run_unit.mjs';
import { runScenarios } from '../tests/run_scenarios.mjs';
import { runParity } from '../tests/run_parity.mjs';
import { runBench } from '../bench/run.mjs';
import { runSelftest } from '../selftest/run.mjs';
import { makeEnvelope } from './envelope.mjs';

const OUT = join(ROOT, 'build', 'evidence');
const FLAGS = ['--allow-dirty', '--no-parity', '--no-bench', '--bench-headless', '--no-selftest'];
const allowDirty = process.argv.includes('--allow-dirty');
const unknown = process.argv.slice(2).filter((a) => !FLAGS.includes(a));

function main() {
  if (unknown.length) {
    console.error(`evidence: unknown argument(s) ${unknown.join(' ')}`);
    return 2;
  }
  const before = dirtyLines();
  if (before.length && !allowDirty) {
    console.error('evidence: working tree is dirty; commit first (or pass --allow-dirty):');
    for (const l of before.slice(0, 20)) console.error(`  ${l}`);
    return 2;
  }
  const commit = git('rev-parse', 'HEAD');
  const version = godotVersion();
  const base = { commit, godotVersion: version ?? 'unavailable' };
  const dirtyNote = before.length ? ` [dirty tree: ${before.length} uncommitted paths]` : '';
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
    unit = runUnit(OUT);
    const churn = dirtyLines().filter((l) => !before.includes(l));
    if (churn.length) {
      unit.ok = false;
      unit.summary += `; tree changed during run (${churn.length} paths, import churn): ${churn.slice(0, 3).join(', ')}`;
    }
  } else {
    unit = { ok: false, summary: `unit-tests: Godot not found (GODOT_BIN=${godotBin()})` };
  }
  envelopes.push(makeEnvelope({ ...base, kind: 'unit-tests', ...unit, summary: unit.summary + dirtyNote }));
  for (const [kind, res] of laterKinds(version)) {
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
function laterKinds(version) {
  const missing = (k) => ({ ok: false, summary: `${k}: Godot not found (GODOT_BIN=${godotBin()})` });
  if (!version) return [['scenario-tests', missing('scenario-tests')], ['parity', missing('parity')]];
  const out = [['scenario-tests', runScenarios(OUT)]];
  if (!process.argv.includes('--no-parity')) out.push(['parity', runParity(OUT)]);
  if (!process.argv.includes('--no-selftest')) out.push(['selftest', runSelftest(OUT)]);
  if (!process.argv.includes('--no-bench')) {
    out.push(['bench', runBench(OUT, { headless: process.argv.includes('--bench-headless') })]);
  }
  return out;
}

process.exit(main());
