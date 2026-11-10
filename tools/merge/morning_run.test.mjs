// Tests for morning.mjs's step runner with real child processes (no Godot, no git).
// Run: node --test tools/merge/morning_run.test.mjs
import { after, test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, readFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { STEP_FLOOR_MIN, defaultRun } from './morning.mjs';
import { budgetMs } from '../lib/node_start.mjs';

const made = [];
after(() => { for (const d of made) rmSync(d, { recursive: true, force: true }); });
const dir = () => { const d = mkdtempSync(join(tmpdir(), 'morning-run-')); made.push(d); return d; };

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

// The step's timer starts before the child's node does (n15 item 6): each limit below is what the test
// means (1.8 s, 3 s) plus the cold node starts inside it, measured now, not a fixed guess.
test('a timed-out step keeps what it printed before the kill and says it timed out', { timeout: 120_000 }, () => {
  const min = budgetMs(1800, 1) / 60000;
  const run = defaultRun(process.cwd(), dir(), min);
  const r = run('debt-check', 'node', ['-e', "console.log('before the hang'); setTimeout(() => {}, 300000)"]);
  assert.equal(r.status, -1);
  const log = readFileSync(r.log, 'utf8');
  assert.match(log, /before the hang/);
  assert.match(log, /morning: debt-check: timed out after [\d.]+ min/);
});

const alive = (pid) => { try { process.kill(pid, 0); return true; } catch (e) { return e.code === 'EPERM'; } };

test('a timed-out step leaves no grandchild running (the engine is a grandchild of the gate runners)', { timeout: 120_000 }, async () => {
  const d = dir();
  const pidFile = join(d, 'grandchild.pid');
  const grand = `require('fs').writeFileSync(${JSON.stringify(pidFile)}, String(process.pid)); setTimeout(() => {}, 60000)`;
  // The middle process must not be node: node's children sit in its kill-on-close job and die with
  // it, which hid the bug. Godot's console exe has no such job, so a shell stands in for it.
  const mid = process.platform === 'win32' ? ['cmd.exe', ['/d', '/c', process.execPath, '-e', grand]] : ['sh', ['-c', '"$0" -e "$1"; :', process.execPath, grand]];
  const parent = `require('child_process').spawn(${JSON.stringify(mid[0])}, ${JSON.stringify(mid[1])}, { stdio: 'inherit' }); setTimeout(() => {}, 60000)`;
  const min = budgetMs(3000, 2) / 60000; // the parent and the grandchild are cold node starts
  const r = defaultRun(process.cwd(), d, min)('gates-like', process.execPath, ['-e', parent]);
  assert.equal(r.status, -1);
  assert.match(readFileSync(r.log, 'utf8'), /timed out after [\d.]+ min \(the process tree was killed\)/);
  const pid = Number(readFileSync(pidFile, 'utf8'));
  for (let i = 0; i < 20 && alive(pid); i++) await new Promise((ok) => setTimeout(ok, 250));
  assert.equal(alive(pid), false, `grandchild ${pid} still running after the step timed out`);
});

test('a limit that is not whole ms runs (spawnSync wants whole ms; 1000.5 ms threw ERR_OUT_OF_RANGE)', () => {
  const r = defaultRun(process.cwd(), dir(), 1000.5 / 60000)('frac', 'node', ['-e', '0']);
  assert.equal(r.status, 0);
});
