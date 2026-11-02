#!/usr/bin/env node
// Evidence writer: runs lint, then the unit tests headless, and writes the PoF wire contract
// pof.godot-evidence/1 to build/evidence/{lint,unit-tests}.json.
//   node tools/evidence/run.mjs [--allow-dirty]
// Commit first: the evidence names HEAD, and PoF treats evidence from another commit as stale.
// A dirty tree is refused (the evidence would describe code that is not HEAD) unless
// --allow-dirty, which says so in every summary. A run that dirties the tree (import churn)
// fails the unit-tests evidence.
import { mkdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { ROOT, dirtyLines, git, godotBin, godotVersion } from '../lib/repo.mjs';
import { runLint } from '../lint/lint.mjs';
import { runUnit } from '../tests/run_unit.mjs';
import { makeEnvelope } from './envelope.mjs';

const OUT = join(ROOT, 'build', 'evidence');
const allowDirty = process.argv.includes('--allow-dirty');
const unknown = process.argv.slice(2).filter((a) => a !== '--allow-dirty');

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

  for (const env of envelopes) {
    const file = join(OUT, `${env.kind}.json`);
    writeFileSync(file, `${JSON.stringify(env, null, 2)}\n`, 'utf8');
    console.log(`${env.status === 'pass' ? 'PASS' : 'FAIL'} ${env.kind}: ${env.summary}`);
    console.log(`     -> ${file}`);
  }
  console.log(`evidence: commit ${commit}, godot ${base.godotVersion}`);
  return envelopes.every((e) => e.status === 'pass') ? 0 : 1;
}

process.exit(main());
