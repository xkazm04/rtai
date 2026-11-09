import { test } from 'node:test';
import assert from 'node:assert/strict';
import { bootCi, median, paired, signP } from './paired.mjs';

test('median takes the middle pair for an even count', () => {
  assert.equal(median([4, 1, 3, 2]), 2.5);
  assert.equal(median([3, 1, 2]), 2);
  assert.ok(Number.isNaN(median([])));
});

test('the sign test matches the binomial tail', () => {
  assert.equal(signP(0, 6), 2 / 64);
  assert.equal(signP(3, 6), 1);
  assert.equal(signP(6, 6), 2 / 64);
});

test('the bootstrap interval is seeded and brackets a constant shift', () => {
  const d = [-0.21, -0.19, -0.2, -0.22, -0.18, -0.2];
  assert.deepEqual(bootCi(d), bootCi(d));
  const [lo, hi] = bootCi(d);
  assert.ok(lo <= -0.2 && hi >= -0.2 && hi < 0);
});

test('a consistent drop is LOWER, a mixed one a WASH, and the A/A floor holds a small one back', () => {
  const rounds = (deltas) => deltas.map((x) => ({ a: 3, b: 3 + x }));
  const down = paired(rounds([-0.2, -0.21, -0.19, -0.22, -0.2, -0.18]));
  assert.equal(down.call, 'LOWER');
  assert.equal(down.lower, 6);
  assert.equal(paired(rounds([0.1, -0.1, 0.05, -0.05, 0.02, -0.02])).call, 'WASH');
  assert.equal(paired(rounds([-0.2, -0.21, -0.19, -0.22, -0.2, -0.18]), { floor: 0.5 }).call, 'WASH');
  assert.equal(paired(rounds([0.3, 0.31, 0.29, 0.3, 0.32, 0.28])).call, 'HIGHER');
});

test('rounds missing an arm are left out', () => {
  const p = paired([{ a: 1, b: 2 }, { a: NaN, b: 1 }, { a: 1 }]);
  assert.equal(p.n, 1);
});
