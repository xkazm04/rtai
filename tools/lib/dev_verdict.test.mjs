// node --test "tools/lib/*.test.mjs"
import assert from 'node:assert/strict';
import { mkdtempSync, rmSync, utimesSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { after, test } from 'node:test';
import { verdict } from './dev_verdict.mjs';

const tmp = mkdtempSync(join(tmpdir(), 'gtai-verdict-'));
after(() => rmSync(tmp, { recursive: true, force: true }));

test('a SCRIPT ERROR fails an exit 0 and names the first location', () => {
  const v = verdict({ status: 0, out: 'SCRIPT ERROR: Invalid call\n   at: _tick (res://dev/x.gd:41)' });
  assert.equal(v.ok, false);
  assert.ok(v.line.includes('SCRIPT ERROR 1 (first res://dev/x.gd:41)'), v.line);
  assert.deepEqual(v.scriptErrors, [{ text: 'SCRIPT ERROR: Invalid call', at: 'res://dev/x.gd:41' }]);
});

test('an unknown launch arg warning fails the run and is named', () => {
  const v = verdict({ status: 0, out: 'WARN boot: unknown launch arg --boss=servo (ignored)' });
  assert.equal(v.ok, false);
  assert.ok(v.line.includes('unknown arg 1: --boss=servo'), v.line);
  assert.deepEqual(v.unknownArgs, ['--boss=servo']);
});

test('a result file older than the launch is stale; a missing one is missing', () => {
  const file = join(tmp, 'old.json');
  writeFileSync(file, '{}');
  const past = new Date(Date.now() - 60000);
  utimesSync(file, past, past);
  const stale = verdict({ status: 0, out: '' }, { resultFile: file, startedAt: Date.now() - 1000 });
  assert.equal(stale.ok, false);
  assert.ok(stale.line.includes('result stale'), stale.line);
  const missing = verdict({ status: 0, out: '' }, { resultFile: join(tmp, 'nope.json'), startedAt: Date.now() });
  assert.equal(missing.ok, false);
  assert.ok(missing.line.includes('result missing'), missing.line);
});

test('exit 2 reads as usage; exit 0 + no errors + a fresh result reads ok', () => {
  assert.ok(verdict({ status: 2, out: '' }).line.startsWith('FAIL exit 2 (usage)'));
  const file = join(tmp, 'fresh.json');
  const startedAt = Date.now() - 1000;
  writeFileSync(file, '{}');
  const v = verdict({ status: 0, out: 'all good' }, { resultFile: file, startedAt });
  assert.equal(v.ok, true);
  assert.ok(v.line.startsWith('ok exit 0'), v.line);
  for (const part of ['SCRIPT ERROR 0', 'unknown arg 0', 'result fresh']) assert.ok(v.line.includes(part), v.line);
});

test('never ran and timeout are failures with their own label', () => {
  assert.ok(verdict({ status: -1, out: '' }).line.startsWith('FAIL exit -1 (never ran)'));
  const t = verdict({ status: -1, out: '', timedOut: true, durationMs: 3000 });
  assert.ok(t.line.startsWith('FAIL timeout after 3 s'), t.line);
});

test('notes are appended to the line', () => {
  const v = verdict({ status: 0, out: '' }, { notes: ['flags unchecked: no declared spec'] });
  assert.ok(v.line.endsWith('; flags unchecked: no declared spec'), v.line);
});
