import test from 'node:test';
import assert from 'node:assert/strict';
import { placedBase } from './yard_structures.mjs';
import { opaqueBox, mismatch, verdict, fitCard, auditGauntlet, auditYard, summarize, PX_PER_M } from './audit.mjs';

// A w x h RGBA image, opaque inside [x0,x1) x [y0,y1).
function image(w, h, x0, y0, x1, y1) {
  const data = Buffer.alloc(w * h * 4);
  for (let y = y0; y < y1; y++) for (let x = x0; x < x1; x++) data[(y * w + x) * 4 + 3] = 255;
  return { width: w, height: h, channels: 4, data };
}

test('opaqueBox finds the opaque bounds and fraction', () => {
  const o = opaqueBox(image(10, 10, 2, 3, 6, 9));
  assert.deepEqual([o.x0, o.y0, o.x1, o.y1], [2, 3, 6, 9]);
  assert.equal(o.fraction, 0.24);
  assert.equal(opaqueBox(image(4, 4, 0, 0, 0, 0)), null);
});

test('mismatch is positive where the footprint reaches beyond the drawing', () => {
  const mm = mismatch({ x0: 0, x1: 4, y0: 0, y1: 2 }, { x0: 1, x1: 3.5, y0: 0.5, y1: 2 });
  assert.deepEqual(mm, { west: 1, east: 0.5, north: 0.5, south: 0 });
  assert.equal(verdict(mm, ['west', 'east', 'south']).verdict, 'invisible wall');
  assert.equal(verdict({ west: -0.5, east: 0, north: 0, south: 0 }, ['west']).verdict, 'art overhangs passable');
  assert.equal(verdict({ west: 0.1, east: 0, north: 0, south: 0 }, ['west', 'east']).verdict, 'ok');
});

test('fitCard puts a full-width card on the box and the foot on its south edge', () => {
  const png = image(96, 96, 0, 0, 96, 96); // 2 x 2 m of art
  const box = { x0: 0, x1: 2.08, y0: 0, y1: 2.08 };
  const fit = fitCard(png, box, 1);
  assert.ok(Math.abs(fit.base.x1 - fit.base.x0 - 2) < 1e-9);
  assert.ok(Math.abs(fit.base.y1 - (2.08 - 0.04)) < 1e-9);
  assert.equal(PX_PER_M, 48);
  const narrow = fitCard(image(96, 96, 24, 0, 72, 96), box, 1);
  assert.ok(Math.abs(narrow.base.x0 - (0.04 + 0.5)) < 1e-9, 'a half-width base leaves 0.5 m each side');
});

test('the real tables audit: every solid prop gets a verdict and the counts add up', () => {
  const rows = [...auditGauntlet(), ...auditYard()];
  const sum = summarize(rows);
  assert.equal(sum.props, rows.length);
  assert.ok(sum.solid >= 50);
  assert.equal(rows.filter((r) => r.arena === 'yard' && r.kind === 'cover_low').length, 26); // n31-19: + 12 arch supports
  assert.ok(Object.values(sum.by_verdict).reduce((a, b) => a + b, 0) === rows.length);
});

test('placedBase puts the lowest band and its column runs in world metres', () => {
  // 96 x 48 px art stretched into 4 x 2 m centred at (10, 5): 24 px/m. Two feet 0.5 m wide in the bottom rows.
  const w = 96, h = 48;
  const data = Buffer.alloc(w * h * 4);
  const fill = (x0, y0, x1, y1) => { for (let y = y0; y < y1; y++) for (let x = x0; x < x1; x++) data[(y * w + x) * 4 + 3] = 255; };
  fill(0, 0, 96, 20);
  fill(10, 20, 22, 48);
  fill(70, 20, 82, 48);
  const pb = placedBase({ width: w, height: h, channels: 4, data }, [10, 5], [4, 2]);
  assert.equal(pb.legs.length, 2);
  assert.ok(Math.abs(pb.legs[0].x0 - 8.417) < 0.01 && Math.abs(pb.legs[0].x1 - 8.917) < 0.01);
  assert.equal(pb.base.y1, 6);
});

test('the yard audit lists the six arches (legs blocked, n31-19) and six spans (none blocked)', () => {
  const rows = auditYard();
  assert.equal(rows.filter((r) => r.legs_m).length, 12);
  assert.ok(rows.filter((r) => r.kind === 'span').every((r) => r.legs_blocking === 0));
  assert.ok(rows.filter((r) => r.kind === 'arch').every((r) => r.legs_blocking === r.legs));
  assert.equal(rows.filter((r) => r.id.includes(' vs ') && r.verdict === 'footprint north of drawn base').length, 0); // n31-19 (was 6)
});
