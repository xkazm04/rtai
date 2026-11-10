import { test } from 'node:test';
import assert from 'node:assert/strict';
import { order, parseArgs, report, SCENES, summarise } from './fight_gate.mjs';

test('the first arm gets an identical A/A twin', () => {
  const o = parseArgs(['--arms=off:--ink-pulse=0,on:', '--rounds=2']);
  assert.deepEqual(o.arms.map((a) => a.name), ['off', 'on', 'off~aa']);
  assert.deepEqual(o.arms[2].user, ['--ink-pulse=0']);
  assert.equal(o.arms[2].twin, true);
  assert.equal(o.rounds, 2);
  assert.deepEqual(o.scenes, ['city', 'horde']);
});

test('unknown arguments and scenes are refused', () => {
  assert.throws(() => parseArgs(['--round=2']), /unknown argument/);
  assert.throws(() => parseArgs(['--scenes=riot']), /unknown scene/);
  assert.throws(() => parseArgs(['--arms=:x']), /name:<flags>/);
});

test('every arm takes every slot over the rounds, and odd rounds run reversed', () => {
  const arms = ['a', 'b', 'c'];
  assert.deepEqual(order(arms, 0), ['a', 'b', 'c']);
  assert.deepEqual(order(arms, 1), ['a', 'c', 'b']);
  assert.deepEqual(order(arms, 2), ['c', 'a', 'b']);
  const first = new Set([0, 1, 2, 3, 4, 5].map((r) => order(arms, r)[0]));
  assert.equal(first.size, 3);
});

test('the scenes run at combo, 32 px/m, a fixed length', () => {
  for (const user of Object.values(SCENES)) {
    assert.ok(user.includes('--view=combo'));
    assert.ok(user.includes('--ppm=32'));
    assert.ok(user.some((u) => u.startsWith('--frames-ticks=')));
  }
});

test('the summary pairs each arm with the base per round and prints the A/A floor', () => {
  const arms = parseArgs(['--arms=base:,new:--x']).arms;
  const runs = [];
  for (let r = 0; r < 6; r++) {
    const row = (arm, p50) => ({ arm, round: r, p50, p99: p50 * 2, worst: 20, over25: 0, cpu: 10, load: 1, errors: 0, contended: 0 });
    runs.push(row('base', 5 + r * 0.1), row('base~aa', 5.01 + r * 0.1), row('new', 5.5 + r * 0.1));
  }
  const s = summarise(runs, arms);
  assert.equal(s.vsBase.new.p50.call, 'HIGHER');
  assert.equal(s.vsBase.new.p50.lower, 0);
  assert.ok(Math.abs(s.floor.p50.median - 0.01) < 1e-9);
  assert.equal(s.vsBase.new.worst.call, 'WASH');
  const text = report('city', s, runs, arms);
  assert.match(text, /A\/A floor \(base~aa - base\)/);
  assert.match(text, /new - base: p50 \+0\.500/);
});
