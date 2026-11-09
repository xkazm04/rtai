// Run: node --test tools/merge/step_guard.test.mjs
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { GUARD_EXIT, parseGuardArgs } from './step_guard.mjs';

const GUARD = fileURLToPath(new URL('./step_guard.mjs', import.meta.url));

test('the guard reads step, limit, shell flag and the command after --', () => {
  assert.deepEqual(parseGuardArgs(['bake', '60000', '0', '--', 'node', '-e', '0']),
    { step: 'bake', timeoutMs: 60000, shell: false, cmd: 'node', args: ['-e', '0'] });
  assert.equal(parseGuardArgs(['bake', '60000', '1', '--', 'scons']).shell, true);
});

test('the guard refuses a bad limit, a bad shell flag, a missing -- or no command', () => {
  for (const argv of [['bake', '0', '0', '--', 'x'], ['bake', 'NaN', '0', '--', 'x'], ['bake', '9', 'yes', '--', 'x'],
    ['bake', '9', '0', 'x'], ['bake', '9', '0', '--'], ['9', '0', '--', 'x']]) assert.equal(parseGuardArgs(argv), null, argv.join(' '));
});

test('run directly with bad arguments it exits 2 with its usage, never runs anything', () => {
  const r = spawnSync(process.execPath, [GUARD, 'bake', '0', '0', '--', process.execPath, '-e', 'process.exit(5)'], { encoding: 'utf8' });
  assert.equal(r.status, 2);
  assert.match(r.stderr, /^usage: node step_guard\.mjs/);
});

test('a clean run passes the exit code through and writes nothing of its own', () => {
  const r = spawnSync(process.execPath, [GUARD, 'x', '60000', '0', '--', process.execPath, '-e', "process.stdout.write('hi'); process.exit(4)"], { encoding: 'utf8' });
  assert.equal(r.status, 4);
  assert.equal(r.stdout, 'hi');
  assert.notEqual(GUARD_EXIT, 4);
});
