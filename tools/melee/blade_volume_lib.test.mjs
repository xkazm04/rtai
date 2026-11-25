import { test } from 'node:test';
import assert from 'node:assert/strict';
import { moverSummary, span, summarize, table, weaponRow } from './blade_volume_lib.mjs';

const cell = (drawn, hit, drawn_ks = []) => ({ kind: 'ring', drawn, hit, drawn_ks });
const result = {
  weapon: 'katana', weapon_id: 'katana', reach_m: 1.3, cone_dot: 0.3, land_k: 9, land_ks: [9],
  cut_ks: [7, 8, 9, 10], shown_ks: [1, 2, 3, 12], overlap_ks: [8, 11],
  ring: { drawn_no_hit: 2, hit_not_drawn: 1, both: 1, neither: 0 },
  cells: [cell(true, false, [11]), cell(true, false, [8]), cell(false, true), cell(true, true, [9])],
  movers: [{ lag: 10, dir: 1, drawn: true, hit: false, drawn_ks: [12] }, { lag: 0, dir: -1, drawn: true, hit: true, drawn_ks: [9] }],
};

test('span is min..max or null', () => {
  assert.deepEqual(span([4, 2, 9]), [2, 9]);
  assert.equal(span([]), null);
});

test('weaponRow carries ring counts and the drawn-after-the-test share', () => {
  const row = weaponRow(result);
  assert.equal(row.drawn_no_hit, 2);
  assert.equal(row.hit_not_drawn, 1);
  assert.equal(row.drawn_no_hit_after_test, 1);
  assert.deepEqual(row.cut_window, [7, 10]);
  assert.deepEqual(row.hit_test_ks, [9]);
});

test('moverSummary folds hit and drawn', () => {
  const m = moverSummary(result.movers);
  assert.deepEqual([m.trials, m.hit, m.drawn, m.drawn_no_hit, m.hit_not_drawn], [2, 1, 2, 1, 0]);
});

test('table prints one row per weapon with windows', () => {
  const md = table(summarize([result], { label: 'before' }));
  assert.match(md, /\| katana \(katana\) \| 2 \| 1 \| 1 \| 1 \| 9 \| 7\.\.10 \| 1\.\.12 \| 8\.\.11 \| 1 \/ 2 \/ 1 \|/);
  assert.equal(md.trim().split('\n').length, 3);
});
