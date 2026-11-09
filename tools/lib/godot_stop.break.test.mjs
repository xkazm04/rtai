// Node children only. Every real runner/test timeout is >=60 s; child watchdogs
// exit normally after 4 s so missed stopOn matches fail without a minute's wait.
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { describe, killTree, runProcess, SCRIPT_ERROR } from './godot.mjs';
import { verdict } from './dev_verdict.mjs';
import { PROGRESS } from '../tests/run_scenarios.mjs';

const LIMIT = 60_000;
const OPTIONS = { timeout: LIMIT };
const WATCHDOG = 'setTimeout(() => process.exit(0), 4000);';
const write = (text, stream = 'stdout') => `process.${stream}.write(${JSON.stringify(text)});`;
const run = (script, options = {}) => runProcess(process.execPath, ['-e', script],
  { timeoutMs: LIMIT, ...options });
const stop = (script, options = {}) => run(WATCHDOG + script,
  { stopOn: SCRIPT_ERROR, stopGraceMs: 250, ...options });

function assertStopped(r, first) {
  assert.equal(r.timedOut, false);
  assert.equal(r.status, -1);
  assert.equal(r.stopped, first);
  assert.match(describe(r), /^STOPPED\b/);
}

for (const parts of [['SCRIPT ER', 'ROR: split\n'], ['SCR', 'IPT ER', 'ROR: split\n']]) {
  test(`stopOn and onLine reconstruct a matching whole line across ${parts.length} writes`, OPTIONS, async () => {
    const seen = [];
    const script = parts.map((part, i) =>
      `setTimeout(() => { ${write(part)} }, ${i * 80});`).join('');
    const r = await stop(script, { onLine: (line) => seen.push(line) });
    assertStopped(r, 'SCRIPT ERROR: split');
    assert.deepEqual(seen, ['SCRIPT ERROR: split']);
  });
}

test('stopOn trims a CRLF match and onLine delivers it once without the CR', OPTIONS, async () => {
  const seen = [];
  const r = await stop(write('  SCRIPT ERROR: CRLF  \r')
    + `setTimeout(() => { ${write('\n')} }, 80);`, { onLine: (line) => seen.push(line) });
  assertStopped(r, 'SCRIPT ERROR: CRLF');
  assert.deepEqual(seen, ['  SCRIPT ERROR: CRLF  ']);
});

test('ANSI stripped output and stopOn still recognize colour codes inside a matching line', OPTIONS, async () => {
  const seen = [];
  // Split both the error token and an ANSI escape across writes.
  const r = await stop(write('\x1b[3')
    + `setTimeout(() => { ${write('1mSCRIPT\x1b[0m ERROR: coloured\x1b[32m\n\x1b[0m')} }, 80);`,
  { onLine: (line) => seen.push(line) });
  assertStopped(r, 'SCRIPT ERROR: coloured');
  assert.deepEqual(seen, ['SCRIPT ERROR: coloured']);
  assert.ok(!r.out.includes('\x1b'), 'merged output must contain no SGR colour escapes');
});

test('whole-line matching leaves an unterminated last fragment alone and keeps it in out', OPTIONS, async () => {
  // The task specifies WHOLE lines: no newline means no live whole-line event.
  // EOF still must retain the fragment, and a natural exit must not be stopped.
  const seen = [];
  const r = await run(write('SCRIPT ERROR: final fragment'),
    { stopOn: SCRIPT_ERROR, stopGraceMs: 100, onLine: (line) => seen.push(line) });
  assert.equal(r.status, 0);
  assert.equal(r.stopped, null);
  assert.equal(r.timedOut, false);
  assert.equal(r.out, 'SCRIPT ERROR: final fragment');
  assert.deepEqual(seen, []);
});

test('stopOn keeps the FIRST of two matching lines and output arriving during grace', OPTIONS, async () => {
  const seen = [];
  const r = await stop(write('SCRIPT ERROR: first\n')
    + `setTimeout(() => { ${write('SCRIPT ERROR: second\n   at: grace location\n')} }, 60);`,
  { onLine: (line) => seen.push(line) });
  assertStopped(r, 'SCRIPT ERROR: first');
  assert.deepEqual(seen, ['SCRIPT ERROR: first', 'SCRIPT ERROR: second', '   at: grace location']);
  assert.ok(r.out.includes('SCRIPT ERROR: second\n   at: grace location\n'));
});

test('stderr matching and onLine never combine a stdout partial line with stderr', OPTIONS, async () => {
  const seen = [];
  const r = await stop(write('stdout partial ')
    + `setTimeout(() => { ${write('SCRIPT ERROR: stderr\n', 'stderr')} }, 60);`
    + `setTimeout(() => { ${write('completed\n')} }, 120);`,
  { stopOn: /^SCRIPT ERROR: stderr$/, onLine: (line) => seen.push(line) });
  assertStopped(r, 'SCRIPT ERROR: stderr');
  assert.deepEqual(seen, ['SCRIPT ERROR: stderr', 'stdout partial completed']);
});

test('a natural exit 0 inside stop grace keeps status 0 and stopped null', OPTIONS, async () => {
  const r = await run(write('SCRIPT ERROR: exits during grace\n')
    + 'setTimeout(() => process.exit(0), 40);', { stopOn: SCRIPT_ERROR, stopGraceMs: 500 });
  assert.equal(r.status, 0);
  assert.equal(r.stopped, null);
  assert.equal(r.timedOut, false);
  assert.match(describe(r), /^exit 0\b/);
  assert.ok(!r.out.includes('[stopped:'));
});

test('a very large pre-match burst loses neither output nor whole-line callbacks', OPTIONS, async () => {
  const count = 20_000;
  const seen = [];
  const r = await stop(`process.stdout.write('burst-0123456789\\n'.repeat(${count}), () => {
    ${write('SCRIPT ERROR: after burst\n')}
  });`, { onLine: (line) => seen.push(line) });
  assertStopped(r, 'SCRIPT ERROR: after burst');
  assert.equal(seen.length, count + 1);
  assert.ok(seen.slice(0, count).every((line) => line === 'burst-0123456789'));
  assert.equal(seen[count], 'SCRIPT ERROR: after burst');
  assert.ok(r.out.startsWith('burst-0123456789\n'.repeat(count) + 'SCRIPT ERROR: after burst\n'));
});

test('stopOn with g still stops at the first match when the same RegExp is reused', OPTIONS, async () => {
  const pattern = /^SCRIPT ERROR/g;
  const first = await stop(write('SCRIPT ERROR: first run\n'), { stopOn: pattern });
  assertStopped(first, 'SCRIPT ERROR: first run');
  const second = await stop(write('SCRIPT ERROR: second run\n'), { stopOn: pattern });
  assertStopped(second, 'SCRIPT ERROR: second run');
});

test('onLine delivers empty whole lines once without inventing a line after the final newline', OPTIONS, async () => {
  const seen = [];
  const r = await run(write('\n\r\nlast\n'), { onLine: (line) => seen.push(line) });
  assert.equal(r.status, 0);
  assert.equal(r.stopped, null);
  assert.deepEqual(seen, ['', '', 'last']);
  assert.equal(r.out, '\n\r\nlast\n');
});

const alive = (pid) => { try { process.kill(pid, 0); return true; } catch { return false; } };

test('stopOn kills a running grandchild as well as the matching parent', OPTIONS, async () => {
  let descendant;
  try {
    // Grandchild announces readiness through the parent's pipe; no startup race.
    const grandchild = WATCHDOG + write('grandchild-ready\n');
    const parent = `const { spawn } = require('node:child_process');
      const c = spawn(process.execPath, ['-e', ${JSON.stringify(grandchild)}], {stdio: ['ignore', 'pipe', 'ignore']});
      c.stdout.once('data', () => console.log('SCRIPT ERROR: grandchild=' + c.pid));`;
    const r = await stop(parent, { onLine: (line) => {
      const m = /grandchild=(\d+)/.exec(line);
      if (m) descendant = Number(m[1]);
    } });
    assert.ok(descendant, 'grandchild reached readiness');
    assertStopped(r, `SCRIPT ERROR: grandchild=${descendant}`);
    assert.equal(alive(descendant), false, 'a whole-tree stop must leave no running grandchild');
  } finally {
    if (descendant && alive(descendant)) killTree(descendant);
  }
});

test('timeout kills the tree, keeps partial output and reports status -1 and TIMED OUT', OPTIONS, async (t) => {
  let ready;
  const started = new Promise((resolve) => { ready = resolve; });
  let descendant;
  // Advance only the launcher's clock AFTER real child/grandchild readiness.
  // This exercises its 60 s timeout without a 60 s wall-clock test.
  t.mock.timers.enable({ apis: ['setTimeout'] });
  try {
    const grandchild = WATCHDOG + write('ready\n');
    const script = WATCHDOG + `const c = require('node:child_process').spawn(process.execPath,
      ['-e', ${JSON.stringify(grandchild)}], {stdio: ['ignore', 'pipe', 'ignore']});
      c.stdout.once('data', () => { console.log('PARTIAL grandchild=' + c.pid); });`;
    const result = run(script, { onLine: (line) => {
      const m = /PARTIAL grandchild=(\d+)/.exec(line);
      if (m) { descendant = Number(m[1]); ready(); }
    } });
    await started;
    t.mock.timers.tick(LIMIT);
    t.mock.timers.reset(); // Let close/pipe events finish on the real clock.
    const r = await result;
    assert.equal(r.timedOut, true);
    assert.equal(r.status, -1);
    assert.equal(r.stopped, null);
    assert.ok(r.out.includes(`PARTIAL grandchild=${descendant}`));
    assert.match(describe(r), /^TIMED OUT\b/);
    assert.equal(alive(descendant), false, 'timeout must kill the grandchild too');
  } finally {
    t.mock.timers.reset();
    if (descendant && alive(descendant)) killTree(descendant);
  }
});

test('onLine throwing is isolated while probing whole-line delivery and stopOn', OPTIONS, async (t) => {
  // No documented callback-exception policy. Observe it in a separate Node
  // supervisor rather than inventing a required rejection/recovery behaviour.
  const moduleURL = new URL('./godot.mjs', import.meta.url).href;
  const script = `
    const { runProcess } = await import(${JSON.stringify(moduleURL)});
    const seen = [];
    let exceptions = 0;
    process.on('uncaughtException', () => { exceptions++; });
    const r = await runProcess(process.execPath, ['-e', ${JSON.stringify(write('one\nSCRIPT ERROR: throw probe\n') + WATCHDOG)}], {
      timeoutMs: ${LIMIT}, stopGraceMs: 100, stopOn: /SCRIPT ERROR/,
      onLine(line) { seen.push(line); if (line === 'one') throw new Error('hostile callback'); }
    });
    console.log(JSON.stringify({seen, exceptions, status: r.status, stopped: r.stopped}));`;
  const r = await run(script);
  assert.equal(r.status, 0, r.out);
  const observation = JSON.parse(r.out.trim());
  assert.equal(observation.seen[0], 'one', 'the hostile callback must actually run');
  t.diagnostic(`Unspecified onLine exception policy: ${JSON.stringify(observation)}`);
});

test('a stopped verdict counts only real SCRIPT ERROR lines and keeps the first output location', OPTIONS, async () => {
  const r = await stop(write('SCRIPT ERROR: first\n   at: _tick (res://dev/first.gd:41)\n'
    + 'SCRIPT ERROR: second\n   at: _tick (res://dev/second.gd:99)\n'));
  assertStopped(r, 'SCRIPT ERROR: first');
  const v = verdict(r);
  assert.equal(v.ok, false);
  assert.match(v.line, /^FAIL stopped at the first script error\b/);
  assert.equal(v.scriptErrors[0].at, 'res://dev/first.gd:41');
  assert.equal(v.scriptErrors.length, 2, 'the launcher footer is not another child script error');
  assert.match(v.line, /SCRIPT ERROR 2\b/);
});

test('a stopped verdict is never ok even when output has no script-error token and status is 0', OPTIONS, () => {
  // The public result shape permits arbitrary stopOn expressions. Isolate the
  // stopped invariant from the usual SCRIPT_ERROR + status -1 combination.
  const v = verdict({ status: 0, out: 'HALT\n', stopped: 'HALT', timedOut: false, durationMs: 1 });
  assert.match(v.line, /^FAIL stopped at the first script error\b/);
  assert.equal(v.scriptErrors.length, 0);
  assert.equal(v.ok, false);
});

test('PROGRESS matches scenario successes and failures while rejecting summary lines', OPTIONS, () => {
  for (const line of [
    'run_scenarios: [1/12] city_chase ok, 0.25 s',
    'run_scenarios: [12/12] rig_stress FAIL, 12.000 s',
    'FAIL scenario_city_chase.gd: navigation budget exceeded',
  ]) assert.equal(PROGRESS.test(line), true, line);
  for (const line of ['run_scenarios: 12 ran, 0 failed', 'run_scenarios: 0 ran, 0 failed',
    'run_scenarios: 999 ran, 999 failed']) assert.equal(PROGRESS.test(line), false, line);
});
