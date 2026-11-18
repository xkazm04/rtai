import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { describe, it } from 'node:test';
import { runProcess, STOP_GRACE_MS } from '../lib/godot.mjs';
import { oracleRunners } from './oracles.mjs';

function bake(script, capMs, onLine) {
  const runBake = (_args, options) => runProcess(process.execPath, ['-e', script], { ...options, onLine });
  return oracleRunners(process.cwd(), [], process.env, true, { runBake })['bake-check'](capMs);
}

function assertGrandchildStopped(pid) {
  try {
    process.kill(pid, 0);
  } catch (err) {
    assert.equal(err.code, 'ESRCH');
    return;
  }
  // On Linux, kill(pid, 0) can still see a dead process while init reaps it.
  if (process.platform === 'linux') {
    try {
      if (/^\d+ \(.*\) Z/.test(readFileSync(`/proc/${pid}/stat`, 'utf8'))) return;
    } catch (err) {
      if (err.code === 'ENOENT') return;
      throw err;
    }
  }
  process.kill(pid, 'SIGKILL');
  assert.fail(`grandchild ${pid} was still running after the stop`);
}

describe('bake-check with real children', { concurrency: 2 }, () => {
  it('returns a timeout for a silent hang', async () => {
    const start = performance.now();
    const result = await bake('setInterval(() => {}, 1000)', 1500);
    const wallMs = performance.now() - start;
    assert.equal(result.verdict, 'timeout');
    assert.equal(result.timedOut, true);
    assert.ok(wallMs < 5000, `silent hang took ${wallMs} ms`);
  });

  it('survives a clean bake and identifies the first differing chunk', async () => {
    const ok = await bake("console.log('bake_city: OK deterministic, matches golden')", 8000);
    assert.equal(ok.verdict, 'survived');
    const diff = await bake("console.error('bake_city: GOLDEN-DIFF c_01_00.bin differs'); process.exitCode = 1", 8000);
    assert.equal(diff.verdict, 'killed');
    assert.equal(diff.via, 'golden');
    assert.equal(diff.detail, 'c_01_00.bin');
  });

  it('stops the crashing bake and its sleeping grandchild after the error grace', async () => {
    const script = `
      const child = require('node:child_process').spawn(process.execPath,
        ['-e', "console.log('ready'); setTimeout(() => {}, 30000)"], { stdio: ['ignore', 'pipe', 'ignore'] });
      child.stdout.once('data', () => console.error('SCRIPT ERROR: Invalid call grandchild=' + child.pid));
    `;
    let errorAt;
    const result = await bake(script, 12000, (line) => {
      if (line.startsWith('SCRIPT ERROR')) errorAt = performance.now();
    });
    const stopMs = performance.now() - errorAt;
    const pid = /grandchild=(\d+)/.exec(result.out);
    assert.ok(pid, 'the grandchild reached readiness');
    assertGrandchildStopped(Number(pid[1]));
    assert.equal(result.verdict, 'killed');
    assert.equal(result.via, 'crash');
    assert.match(result.stopped, /^SCRIPT ERROR: Invalid call/);
    assert.ok(Math.ceil(stopMs) >= STOP_GRACE_MS && stopMs < 6000, `stop after error took ${stopMs} ms`);
  });

  it('classifies a hanging parse error as invalid', async () => {
    const result = await bake("console.error('Parse Error: expected expression'); setInterval(() => {}, 1000)", 8000);
    assert.equal(result.verdict, 'invalid');
    assert.equal(result.via, 'parse');
    assert.equal(result.stopped, 'Parse Error: expected expression');
  });
});
