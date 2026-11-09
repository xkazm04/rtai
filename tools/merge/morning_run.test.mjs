// Tests for morning.mjs's step runner with real child processes (no Godot, no git).
// Run: node --test tools/merge/morning_run.test.mjs
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, readFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { STEP_FLOOR_MIN, defaultRun } from './morning.mjs';

const dir = () => mkdtempSync(join(tmpdir(), 'morning-run-'));

test('a step writes its output to its log as it runs, and announces the log and its limit first', () => {
  const said = [];
  const run = defaultRun(process.cwd(), dir(), 45, (l) => said.push(l));
  const r = run('bake', 'node', ['-e', "console.log('one'); console.error('two'); process.exit(3)"]);
  assert.equal(r.status, 3);
  assert.match(r.out, /one/);
  assert.match(r.out, /two/);
  assert.equal(readFileSync(r.log, 'utf8'), r.out);
  assert.equal(said.length, 1);
  assert.match(said[0], /^morning: bake: log .*bake\.log \(tail it; limit 45 min\)$/);
});

test('reels and gates never get less than their floor, whatever --timeout says', () => {
  const said = [];
  const run = defaultRun(process.cwd(), dir(), 45, (l) => said.push(l));
  run('reels', 'node', ['-e', '0']);
  run('gates', 'node', ['-e', '0']);
  assert.match(said[0], new RegExp(`limit ${STEP_FLOOR_MIN.reels} min`));
  assert.match(said[1], new RegExp(`limit ${STEP_FLOOR_MIN.gates} min`));
  assert.ok(STEP_FLOOR_MIN.reels > 3 * 20, 'above three reel views at their own 20 min limit');
});

test('a timed-out step keeps what it printed before the kill and says it timed out', { timeout: 60_000 }, () => {
  const run = defaultRun(process.cwd(), dir(), 0.03);
  const r = run('debt-check', 'node', ['-e', "console.log('before the hang'); setTimeout(() => {}, 30000)"]);
  assert.equal(r.status, -1);
  const log = readFileSync(r.log, 'utf8');
  assert.match(log, /before the hang/);
  assert.match(log, /morning: debt-check: timed out after 0\.03 min/);
});
