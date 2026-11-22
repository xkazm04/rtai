import assert from 'node:assert/strict';
import { test } from 'node:test';
import { moveTable } from './move_table.mjs';
import { moveSection } from './move_stats.mjs';

const make = (seed, seconds, death, profile = 'expert') => ({
  seed, profile, controls: 'wheel', waves: [
    { n: 1, seconds: seconds + 20, enemies: {} },
    { n: 2, seconds, enemies: { sentry_turret: 1 }, moves: { ohm_short_circuit: 2 } },
    { n: 3, seconds: 1000 } // Unknown roster.
  ], ...(death ? { death: { wave: death, by: 'rifle' } } : {})
});
const batch = (...results) => ({ args: { runner: 'gauntlet', waves: 15, pick: 'greedy' }, results,
  runs: results.map(({ seed, profile, controls }) => ({ seed, profile, controls, ok: true })) });

test('move table pairs seed and wave, separates profiles, and omits censored deaths', () => {
  const a = batch(make(1, 20, 3), make(2, 40, 4), make(5, 100, 2), make(1, 2, 1, 'novice'));
  const b = batch(make(2, 35, null), make(1, 15, 5), make(1, 2, 1, 'novice'));
  const [expert, novice] = moveTable(a, b, 'ohm_short_circuit');
  assert.equal(expert.matched, 2);
  assert.deepEqual(expert.with_enemy_seconds, { pairs: 2, delta: -5, ci95: [-5, -5] });
  assert.deepEqual(expert.without_enemy_seconds, expert.with_enemy_seconds);
  assert.deepEqual(expert.death_wave, { pairs: 1, delta: 2, ci95: null });
  assert.equal(expert.without_paired_death, 1);
  assert.equal(novice.with_enemy_seconds.delta, 0);
  b.results[1].waves[1].enemies = {};
  assert.equal(moveTable(a, b, 'ohm_short_circuit')[0].with_enemy_seconds.pairs, 1);
  assert.equal(moveTable(a, b, 'overkill_carry')[0].without_enemy_seconds.pairs, 0);
  assert.throws(() => moveTable(a, b, 'typo'), /unknown move/);
  b.args.salt = 16;
  assert.throws(() => moveTable(a, b, 'overkill_carry'), /salts/);
});

test('move report includes zero-use observations and separates timed rosters', () => {
  const first = make(1, 10, 3), second = make(2, 8, 3);
  delete second.waves[1].moves;
  second.waves[1].enemies = {};
  const section = moveSection(batch(first, second), String);
  assert.equal(section.title, 'Moves');
  assert.deepEqual(section.rows.find((r) => r[1] === 2 && r[2] === 'ohm_short_circuit'),
    ['expert', 2, 'ohm_short_circuit', 'sentry_turret', 2, 2, '1', '10 (1)', '8 (1)']);
  assert.deepEqual(section.rows.find((r) => r[1] === 3 && r[2] === 'overkill_carry').slice(-2),
    ['1000 (2)', '—']);
});
