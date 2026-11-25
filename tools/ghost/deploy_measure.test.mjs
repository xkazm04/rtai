import { test } from 'node:test';
import assert from 'node:assert/strict';
import { formatTable, parseArgs, stats, summarize } from './deploy_measure.mjs';

test('parseArgs passes the dev flags through and refuses unknown ones', () => {
  const a = parseArgs(['--mode=lab', '--radius=4,5', '--full=both', '--tag=sweep']);
  assert.equal(a.mode, 'lab');
  assert.equal(a.tag, 'sweep');
  assert.deepEqual(a.pass, ['--radius=4,5', '--full=both']);
  assert.match(parseArgs(['--mode=lab', '--bogus=1']).error, /unknown argument --bogus/);
  assert.match(parseArgs(['--radius=4']).error, /needs --mode/);
});

test('stats gives mean and median, odd and even', () => {
  assert.deepEqual(stats([3, 1, 2]), { n: 3, mean: 2, median: 2 });
  assert.deepEqual(stats([1, 2, 3, 6]), { n: 4, mean: 3, median: 2.5 });
  assert.deepEqual(stats([]), { n: 0, mean: 0, median: 0 });
});

test('lab summary is per variant and group size with share hit and zero-hit count', () => {
  const row = (size, hits, extra = {}) => ({ size, hits, kills: hits, landed: true, press_to_damage_ticks: 1,
    shape: 'half', radius_m: 4, at: 'spot', shipped: true, ...extra });
  const report = { mode: 'lab', rows: [row(4, 2), row(4, 0), row(8, 4),
    row(8, 8, { shape: 'full', radius_m: 6, shipped: false })] };
  const rows = summarize(report);
  assert.equal(rows.length, 3);
  assert.deepEqual([rows[0].variant, rows[0].group, rows[0].mean_hits, rows[0].share_hit, rows[0].zero_hit],
    ['half r4 at spot (main)', '4 cops', 1, 0.25, 1]);
  assert.equal(rows[2].variant, 'full r6 at spot');
  assert.equal(rows[2].share_hit, 1);
});

test('play summary is per seed plus a total, charge named in the variant', () => {
  const d = (hits) => ({ hits, kills: hits - 1 < 0 ? 0 : hits - 1, press_to_damage_ticks: 1 });
  const report = { mode: 'play', rows: [
    { seed: 1, shape: 'full', radius_m: 5, at: 'rivet', charge_ticks: 27, deploys: [d(3), d(0)] },
    { seed: 2, shape: 'full', radius_m: 5, at: 'rivet', charge_ticks: 27, deploys: [d(5)] }] };
  const rows = summarize(report);
  assert.deepEqual(rows.map((r) => r.group), ['seed 1', 'seed 2', 'total']);
  assert.equal(rows[2].variant, 'full r5 at rivet charge 27');
  assert.equal(rows[2].deploys, 3);
  assert.equal(rows[2].zero_hit, 1);
  assert.equal(rows[2].median_hits, 3);
  assert.equal(rows[2].share_hit, null);
});

test('formatTable prints a markdown header and one line per row', () => {
  const text = formatTable([{ mode: 'lab', variant: 'v', group: '8 cops', deploys: 2, mean_hits: 2.5,
    median_hits: 2.5, mean_kills: 2, share_hit: 0.3125, zero_hit: 0, press_to_damage_ticks: 1 }]);
  const lines = text.split('\n');
  assert.equal(lines.length, 3);
  assert.match(lines[2], /\| lab \| v \| 8 cops \| 2 \| 2\.50 \| 2\.50 \| 2 \| 31% \| 0 \| 1 \|/);
});
