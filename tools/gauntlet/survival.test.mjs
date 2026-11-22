import assert from 'node:assert/strict';
import { test } from 'node:test';
import { fmt } from './report_tables.mjs';
import { survivalSection } from './survival.mjs';

test('survival medians use within-wave ratios and only preceding stat picks', () => {
  const fixture = { survival_tuning: { repair_per_s: 10, stat_cards: { boost: { ref: 'regen', k: 1.25 } } },
    results: [{ profile: 'average', picks: [{ wave: 10, taken: 'boost' }], waves: [
      { n: 10, seconds: 4, damage_taken: 20, hp: { start: 95, min: 80, end: 85, max: 100, repaired: 5 },
        guard_deflects: 2, cover_ticks: 4, rolls: 3 },
      { n: 11, seconds: 8, damage_taken: 16, guard_deflects: 0, cover_ticks: 0, rolls: 1 },
      { n: 21, damage_taken: 0, hp: { start: 75, min: 75, end: 75, max: 100, repaired: 0 } },
      { n: 31, seconds: 5, damage_taken: 15 }, { n: 32, seconds: 2, damage_taken: 12 },
      { n: 33, seconds: 1, damage_taken: 10 }
    ] }] };
  const { rows } = survivalSection(fixture, fmt);
  assert.deepEqual(rows[0], ['average', '1–10', '1 / 1', '20', '5', '10', '80', '5', '25', '2', '4', '3',
    '1', '1', '1', '1', '1']);
  assert.deepEqual(rows[1].slice(2, 12), ['0 / 1', '16', '2', '12.5', 'not measured', 'not measured',
    'not measured', '0', '0', '1']);
  assert.equal(rows[1][15], '1.25');
  assert.deepEqual(rows[2].slice(3, 9), ['0', 'not measured', '12.5', '75', '0', 'not measured']);
  assert.deepEqual(rows[3].slice(1, 5), ['31+', '0 / 3', '12', '6']);
});
