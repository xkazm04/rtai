// n15 item 5: lint never drops a failing test name, and a check's issues past SHOWN go to a file it names.
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { SHOWN, failingTests, report } from './lint.mjs';

const FIXTURE = `import test from 'node:test';
import assert from 'node:assert';
test('passes', () => {});
for (let i = 0; i < 45; i++) test('fails number ' + i, () => assert.equal(i, -1));
test('group', async (t) => { await t.test('inner fails', () => assert.ok(false)); });
`;

test('every failing test of a real node --test run is named, past any cap', () => {
  const dir = mkdtempSync(join(tmpdir(), 'gtai-lint-report-'));
  try {
    writeFileSync(join(dir, 'f.test.mjs'), FIXTURE);
    const env = Object.fromEntries(Object.entries(process.env).filter(([k]) => !/^(GIT_|NODE_TEST)/i.test(k)));
    const res = spawnSync(process.execPath, ['--test', '--test-reporter=spec', 'f.test.mjs'], { cwd: dir, encoding: 'utf8', env });
    assert.notEqual(res.status, 0);
    const names = failingTests(`${res.stdout}${res.stderr}`);
    assert.equal(names.length, 46, '45 top-level failures and one inner one');
    assert.ok(names.some((n) => /^f\.test\.mjs:\d+:\d+ fails number 44$/.test(n)), 'the 45th failure is still named');
    assert.ok(names.some((n) => /^f\.test\.mjs:\d+:\d+ inner fails$/.test(n)), names.at(-1));
    assert.ok(!names.some((n) => / group$/.test(n)), 'a parent that failed only through its child is not a second name');
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test('no failing-tests section: no names, never a guess', () => {
  assert.deepEqual(failingTests('ok 1 - passes\n# pass 1\n'), []);
  assert.deepEqual(failingTests(''), []);
});

test('report: every failing name, SHOWN issue lines, then the spill file with the full count', () => {
  const issues = Array.from({ length: SHOWN + 7 }, (_, i) => `line ${i}`);
  const failing = Array.from({ length: 50 }, (_, i) => `a.test.mjs:${i}:1 t${i}`);
  let spilled = null;
  const lines = report({ name: 'tool-tests', ok: false, issues, failing }, (c) => { spilled = c; return 'build/lint/tool-tests.txt'; });
  assert.equal(lines[0], '50 failing test(s):');
  assert.equal(lines.filter((l) => l.startsWith('  FAILED ')).length, 50);
  assert.equal(lines.filter((l) => l.startsWith('line ')).length, SHOWN);
  assert.equal(lines.at(-1), `... 7 more not shown: all ${SHOWN + 7} lines in build/lint/tool-tests.txt`);
  assert.equal(spilled.issues.length, SHOWN + 7, 'the spill gets every line');
});

test('report: a short list prints whole and writes no file', () => {
  const lines = report({ name: 'gdlint', ok: false, issues: ['a', 'b'] }, () => assert.fail('no spill under the cap'));
  assert.deepEqual(lines, ['a', 'b']);
});
