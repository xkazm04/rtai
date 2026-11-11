import assert from 'node:assert/strict';
import test from 'node:test';
import { START_FACTOR, budgetMs, nodeStartMs } from './node_start.mjs';

test('nodeStartMs takes the slowest sample and really starts node', () => {
  let calls = 0;
  const ms = nodeStartMs(3, (cmd, args) => { calls++; assert.equal(cmd, process.execPath); assert.deepEqual(args, ['-e', '']); });
  assert.equal(calls, 3);
  assert.ok(ms >= 0);
  assert.ok(nodeStartMs(1) > 0, 'a real cold start costs something');
});

test('budgetMs gives each cold start START_FACTOR times its cost on top of the meant budget', () => {
  assert.equal(budgetMs(1800, 0, 999), 1800);
  assert.equal(budgetMs(1800, 2, 100), 1800 + START_FACTOR * 2 * 100);
});
