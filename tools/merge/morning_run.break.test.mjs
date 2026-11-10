// Adversarial contract tests; only real Node children, never the merge's build tools.
import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { Worker } from 'node:worker_threads';
import { STEP_FLOOR_MIN, defaultRun } from './morning.mjs';

// Test watchdogs allow slow machines; the intentional runner timeout below is 2.4 s.
const WATCHDOG = { timeout: 60_000 };
function fixture(t, minutes = 1, say = () => {}) {
  const root = mkdtempSync(join(tmpdir(), 'morning-break-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  const logs = join(root, 'missing', 'logs');
  return { root, logs, run: defaultRun(root, logs, minutes, say) };
}

// Keep the bulk-output probes free of shell syntax so they isolate log handling.
// A separate test below attacks unmodified -e argument forwarding.
function child(run, name, source, opts) {
  const encoded = Buffer.from(source).toString('base64');
  return run(name, process.execPath,
    ['-e', `eval(Buffer.from('${encoded}','base64').toString())`], opts);
}

function complete(result, expectedStatus, expected) {
  assert.equal(result.status, expectedStatus);
  assert.equal(result.out, readFileSync(result.log, 'utf8'), 'out must include the entire final log');
  if (expected !== undefined) assert.equal(result.out, expected);
}

test('creates logDir and announces exactly once before the child starts', WATCHDOG, (t) => {
  const said = [];
  let f;
  f = fixture(t, 1, (line) => {
    assert.equal(existsSync(join(f.root, 'started')), false, 'announcement precedes child startup');
    said.push(line);
    writeFileSync(join(f.root, 'announced'), 'yes');
  });
  const r = child(f.run, 'announce', `
    const fs = require('node:fs');
    if (!fs.existsSync('announced')) process.exit(29);
    fs.writeFileSync('started', 'yes');
    process.stdout.write('started');
  `);
  complete(r, 0, 'started');
  assert.equal(existsSync(join(f.root, 'started')), true);
  assert.deepEqual(said, [`morning: announce: log ${join(f.logs, 'announce.log')} (tail it; limit 1 min)`]);
});

test('writes a large stdout and stderr burst without truncation or a buffer-limit failure', WATCHDOG, (t) => {
  const { run } = fixture(t);
  const count = 5 * 1024 * 1024;
  const r = child(run, 'burst', `
    const fs = require('node:fs');
    fs.writeFileSync(1, 'A'.repeat(${count}));
    fs.writeFileSync(2, 'B'.repeat(${count}));
  `);
  assert.equal(r.status, 0);
  assert.equal(readFileSync(r.log).length, count * 2);
  assert.equal(r.out.length, count * 2);
  assert.equal(r.out.slice(0, count), 'A'.repeat(count));
  assert.equal(r.out.slice(count), 'B'.repeat(count));
});

test('preserves writes without a trailing newline from both child streams', WATCHDOG, (t) => {
  const { run } = fixture(t);
  complete(child(run, 'no-newline', `
    const fs = require('node:fs');
    fs.writeSync(1, 'stdout-fragment');
    fs.writeSync(2, 'stderr-fragment');
  `), 0, 'stdout-fragmentstderr-fragment');
});

test('returns the non-zero child exit code and retains its stdout and stderr', WATCHDOG, (t) => {
  const { run } = fixture(t);
  complete(child(run, 'red', `
    require('node:fs').writeSync(1, 'before failure\\n');
    require('node:fs').writeSync(2, 'failure detail');
    process.exitCode = 23;
  `), 23, 'before failure\nfailure detail');
});

test('returns -1 and logs a step-named spawn error when the command does not exist', WATCHDOG, (t) => {
  const { root, run } = fixture(t);
  const r = run('missing-command', join(root, 'no-such-executable'), []);
  const log = readFileSync(r.log, 'utf8');
  assert.ok(log.trim().length > 0, 'the spawn failure is recorded');
  assert.deepEqual({ status: r.status, namesStep: log.includes('missing-command') },
    { status: -1, namesStep: true }, 'a command that never ran needs -1 and a step-named diagnostic');
  complete(r, -1);
});

test('returns the complete log including spawn diagnostics when cwd does not exist', WATCHDOG, (t) => {
  const { root, run } = fixture(t);
  const r = child(run, 'missing-cwd', "process.stdout.write('must not run')",
    { cwd: join(root, 'absent-cwd') });
  assert.equal(r.status, -1);
  const log = readFileSync(r.log, 'utf8');
  assert.match(log, /missing-cwd/);
  assert.match(log, /ENOENT|no such|cannot find/i);
  assert.ok(!log.includes('must not run'));
  complete(r, -1);
});

test('uses logDir/name.log literally for a step name containing spaces', WATCHDOG, (t) => {
  const { logs, run } = fixture(t);
  const r = child(run, 'a step with spaces', "process.stdout.write('space-name')");
  assert.equal(r.log, join(logs, 'a step with spaces.log'));
  complete(r, 0, 'space-name');
});

test('uses logDir/name.log as a nested path for a step name containing a separator', WATCHDOG, (t) => {
  const { logs, run } = fixture(t);
  // The documented path implies nesting, not basename sanitization. Pre-create
  // the nested parent: the promise only explicitly requires creating logDir.
  mkdirSync(join(logs, 'group'), { recursive: true });
  const r = child(run, 'group/step', "process.stdout.write('nested-name')");
  assert.equal(r.log, join(logs, 'group', 'step.log'));
  complete(r, 0, 'nested-name');
});

test('replaces a longer old log when the same step name runs a second time', WATCHDOG, (t) => {
  const { run } = fixture(t);
  const first = child(run, 'repeat', "process.stdout.write('old-output'.repeat(10000))");
  complete(first, 0, 'old-output'.repeat(10000));
  const second = child(run, 'repeat', "process.stdout.write('new')");
  assert.equal(second.log, first.log);
  complete(second, 0, 'new');
  assert.equal(readFileSync(second.log).length, 3);
});

test('keeps partial writes and returns the timeout diagnostic as part of out', WATCHDOG, (t) => {
  const { run } = fixture(t, 0.04);
  const r = child(run, 'mid-write', `
    const fs = require('node:fs');
    fs.writeSync(1, 'partial:');
    const timer = setInterval(() => fs.writeSync(2, 'x'), 30);
    setTimeout(() => { clearInterval(timer); fs.writeSync(1, 'FINISHED'); }, 6000);
  `);
  assert.equal(r.status, -1);
  const log = readFileSync(r.log, 'utf8');
  assert.match(log, /^partial:x+/);
  assert.ok(!log.includes('FINISHED'), 'the child must be interrupted mid-write');
  assert.match(log, /\n[^\n]*mid-write[^\n]*timed out after 0\.04 min[^\n]*\n/);
  complete(r, -1);
});

test('preserves non-UTF-8 stdout and stderr bytes in the log without transcoding', WATCHDOG, (t) => {
  const { run } = fixture(t);
  const bytes = [0x00, 0xff, 0xc3, 0x28, 0x80, 0xf0, 0x9f, 0x92];
  const r = child(run, 'binary', `
    const fs = require('node:fs');
    fs.writeSync(1, Buffer.from(${JSON.stringify(bytes.slice(0, 4))}));
    fs.writeSync(2, Buffer.from(${JSON.stringify(bytes.slice(4))}));
  `);
  assert.deepEqual(readFileSync(r.log), Buffer.from(bytes));
  // out is text; require parity with reading the log, not a lossless text codec.
  complete(r, 0);
});

test('uses the larger caller timeout for reels and applies the exported reels and gates floors', WATCHDOG, (t) => {
  assert.ok(STEP_FLOOR_MIN.reels > 3 * 20);
  assert.ok(STEP_FLOOR_MIN.gates > 0);
  const said = [];
  const f = fixture(t, STEP_FLOOR_MIN.reels + 7, (s) => said.push(s));
  complete(child(f.run, 'reels', '0'), 0, '');
  assert.deepEqual(said, [
    `morning: reels: log ${join(f.logs, 'reels.log')} (tail it; limit ${STEP_FLOOR_MIN.reels + 7} min)`,
  ]);
  const low = fixture(t, 0.04, (s) => said.push(s));
  for (const name of ['reels', 'gates']) {
    complete(child(low.run, name, '0'), 0, '');
    assert.equal(said.at(-1),
      `morning: ${name}: log ${join(low.logs, `${name}.log`)} (tail it; limit ${STEP_FLOOR_MIN[name]} min)`);
  }
});

test('forwards -e arguments unchanged so the child can print spaces and shell metacharacters', WATCHDOG, (t) => {
  const { run } = fixture(t);
  const payload = 'two words & a pipe | and > a redirect';
  const r = run('arguments', process.execPath, ['-e', 'process.stdout.write(process.argv[1])', payload]);
  complete(r, 0, payload);
});

test('lets an independent reader see the first line during the two-second pause before the child ends', WATCHDOG, async (t) => {
  const { root, logs, run } = fixture(t);
  const log = join(logs, 'live.log');
  const done = join(root, 'child-done');
  const worker = new Worker(`
    const { parentPort, workerData } = require('node:worker_threads');
    const fs = require('node:fs');
    const deadline = Date.now() + 8000;
    function poll() {
      let text = '';
      try { text = fs.readFileSync(workerData.log, 'utf8'); }
      catch (e) { if (e.code !== 'ENOENT') throw e; }
      if (text.includes('first\\n') && !text.includes('second') && !fs.existsSync(workerData.done)) {
        parentPort.postMessage({ text, beforeEnd: true });
      } else if (Date.now() >= deadline) {
        parentPort.postMessage({ text, beforeEnd: false });
      } else setTimeout(poll, 20);
    }
    parentPort.postMessage('ready');
    poll();
  `, { eval: true, workerData: { log, done } });
  let ready;
  const started = new Promise((resolve) => { ready = resolve; });
  const observed = new Promise((resolve, reject) => {
    worker.on('message', (m) => m === 'ready' ? ready() : resolve(m));
    worker.on('error', (e) => { ready(); reject(e); });
    worker.on('exit', (code) => {
      ready();
      if (code !== 0) reject(new Error(`reader worker exited ${code}`));
    });
  });
  try {
    await started;
    const r = child(run, 'live', `
      const fs = require('node:fs');
      fs.writeSync(1, 'first\\n');
      setTimeout(() => {
        fs.writeSync(2, 'second\\n');
        fs.writeFileSync('child-done', 'yes');
      }, 2000);
    `);
    const snapshot = await observed;
    assert.equal(snapshot.beforeEnd, true, JSON.stringify(snapshot));
    assert.equal(snapshot.text, 'first\n');
    assert.equal(existsSync(done), true, 'child reached its end after the live observation');
    complete(r, 0, 'first\nsecond\n');
  } finally { await worker.terminate(); }
});
