import test from 'node:test';
import assert from 'node:assert/strict';
import { parseArgs, runArgs, summarize, table } from './play_baseline.mjs';

const row = (o) => ({ seed: 1, swings: 10, hits: 8, whiffs: 2, kills_own_weapon: 12, kills_all: 20, damage_taken: 30,
  alive: true, finished: true, wave_reached: 4, ...o });

test('summarize totals and ratios', () => {
  const s = summarize([row({}), row({ seed: 2, swings: 30, kills_own_weapon: 18, alive: false, wave_reached: 3 })]);
  assert.equal(s.swings, 40);
  assert.equal(s.kills_per_swing, 0.75);
  assert.equal(s.deaths, 1);
  assert.equal(s.wave_reached_min, 3);
  assert.equal(s.damage_taken_mean, 30);
});

test('no swings gives null ratios, not NaN', () => {
  assert.equal(summarize([row({ swings: 0 })]).kills_per_swing, null);
});

test('parseArgs defaults and refusals', () => {
  assert.equal(parseArgs([]).label, 'before');
  assert.deepEqual(parseArgs(['--weapons=claw,katana']).weapons, ['claw', 'katana']);
  assert.throws(() => parseArgs(['--weapons=spoon']));
  assert.throws(() => parseArgs(['--label=a/b']));
  assert.throws(() => parseArgs(['--nope=1']));
});

test('table has one line per weapon', () => {
  assert.equal(table({ claw: summarize([row({})]) }).trim().split('\n').length, 3);
});

test('--sweep passes --melee-sweep to every run; without it --melee-sweep=off (the game default is on since 02p3)', () => {
  assert.equal(parseArgs([]).sweep, false);
  assert.equal(parseArgs(['--sweep']).sweep, true);
  assert.ok(runArgs('katana', 1, 4, 'f.json', true).includes('--melee-sweep'));
  assert.ok(!runArgs('katana', 1, 4, 'f.json', false).includes('--melee-sweep'));
  assert.ok(runArgs('katana', 1, 4, 'f.json', false).includes('--melee-sweep=off'));
});
