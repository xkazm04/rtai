import assert from 'node:assert/strict';
import { mkdtempSync, rmdirSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { test } from 'node:test';
import { UsageError, checkFilePath, parseArgs } from './mutate.mjs';
import { buildJson, classifyRun, formatReport, scoreOf, tally } from './report.mjs';
import { LOCK, acquireLock } from './worktree.mjs';

test('classification: parse errors are invalid, failing tests are killed, green is survived', () => {
  assert.equal(classifyRun({ status: 0, out: 'unit-tests: 5 passed, 0 failed', timedOut: false }).verdict, 'survived');
  assert.equal(classifyRun({ status: 1, out: 'SCRIPT ERROR: Parse Error: x\nunit-tests: 0 passed, 0 failed', timedOut: false }).verdict, 'invalid');
  assert.equal(classifyRun({ status: 1, out: 'Failed to load script "res://a.gd"', timedOut: false }).verdict, 'invalid');
  assert.equal(classifyRun({ status: 1, out: 'unit-tests: 1 failing (4 passed, 1 failed, 0 skipped)', timedOut: false }).verdict, 'killed');
  assert.equal(classifyRun({ status: -1, out: 'partial', timedOut: true }).verdict, 'timeout');
  assert.equal(classifyRun({ status: 1, out: 'SCRIPT ERROR: Invalid call', timedOut: false }).verdict, 'killed');
  assert.ok(classifyRun({ status: 1, out: 'boom', timedOut: false }).infra, 'no result at all is an infrastructure error');
});

test('score counts only decided mutants and the report lists survivors first', () => {
  const mk = (verdict, line) => ({ id: line, line, col: 1, op: 'cmp_flip', before: '<', after: '>=', verdict, via: 'x', ms: 5 });
  const results = [mk('killed', 1), mk('survived', 2), mk('invalid', 3), mk('killed', 4), mk('timeout', 5)];
  assert.deepEqual(tally(results), { killed: 2, survived: 1, timeout: 1, invalid: 1 });
  assert.equal(scoreOf(tally(results)), 2 / 3);
  assert.equal(scoreOf({ killed: 0, survived: 0, timeout: 2, invalid: 1 }), null);
  const text = formatReport({ file: 'core/a.gd', results, totalMs: 12000, tests: ['test_a'] }).split('\n');
  assert.match(text[1], /core\/a\.gd:2 cmp_flip {2}< -> >= {2}survived/);
  assert.match(text.at(-1), /score 66\.7% = killed 2 \/ \(killed 2 \+ survived 1\); timeout 1, invalid 1; 12 s/);
  const doc = buildJson({ file: 'core/a.gd', head: 'abc', tests: ['test_a'], results, totalMs: 1, baselineMs: 2, total: 9, max: 5 });
  assert.equal(doc.schema, 'gtai.mutate/1');
  assert.equal(doc.mutants.length, 5);
});

test('argument parsing and file path checks', () => {
  const o = parseArgs(['--file=core\\save\\x.gd', '--max=5', '--ops=arith,delete', '--tests=test_a.gd,tests/unit/test_b.gd', '--json']);
  assert.deepEqual([o.file, o.max, o.ops, o.tests, o.json], ['core/save/x.gd', 5, ['arith', 'delete'], ['test_a', 'test_b'], true]);
  for (const bad of [[], ['--file=a.gd', '--max=0'], ['--file=a.gd', '--ops=nope'], ['--file=a.gd', '--wat']]) {
    assert.throws(() => parseArgs(bad), UsageError);
  }
  assert.doesNotThrow(() => checkFilePath('core/save/x.gd'));
  for (const bad of ['../x.gd', '/abs/x.gd', 'core/x.txt', 'tests/unit/test_x.gd', 'addons/gut/x.gd', 'a/../../b.gd']) {
    assert.throws(() => checkFilePath(bad), UsageError, bad);
  }
});

test('the run lock refuses a live holder and takes over a dead one', () => {
  const wt = mkdtempSync(join(tmpdir(), 'gtai-mutate-test-'));
  try {
    writeFileSync(join(wt, LOCK), String(process.ppid)); // a live process that is not us
    assert.throws(() => acquireLock(wt), /another mutate run/);
    rmSync(join(wt, LOCK));
    writeFileSync(join(wt, LOCK), '2147483646'); // no such pid
    const release = acquireLock(wt);
    assert.throws(() => acquireLock(wt, 1), /another mutate run|cannot lock/);
    release();
  } finally {
    try { rmSync(join(wt, LOCK)); } catch { /* released */ }
    rmdirSync(wt);
  }
});
