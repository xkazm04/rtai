import test from 'node:test';
import assert from 'node:assert/strict';
import { fitStrip, auditStrips } from './strip_cards.mjs';

test('a strip card with no table row is null, a real one is fitted foot-on-south-edge', () => {
  assert.equal(fitStrip('no_such_prop', { x0: 0, x1: 2, y0: 0, y1: 1 }, 1), null);
  const fit = fitStrip('dumpster', { x0: -1.5, x1: 1.5, y0: -0.85, y1: 0.85 }, 1);
  assert.ok(Math.abs(fit.drawn.y1 - (0.85 - 0.04)) < 1e-9);
  assert.ok(fit.drawn.x1 - fit.drawn.x0 <= 3 - 0.08 + 1e-9);
});

test('the 8 rows the flat audit flagged each get a confirmation', () => {
  const rows = auditStrips('p70');
  const flagged = rows.filter((r) => r.flagged_by_flat);
  assert.equal(flagged.length, 8);
  assert.ok(flagged.every((r) => r.confirmation === 'confirmed' || r.confirmation === 'not confirmed'));
  assert.ok(rows.every((r) => r.verdict !== 'unmeasured'));
});
