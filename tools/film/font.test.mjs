import assert from 'node:assert/strict';
import test from 'node:test';
import { ADVANCE, GLYPHS, drawText } from './font.mjs';

const canvas = (w, h) => ({ w, h, px: Buffer.alloc(w * h * 3, 0x18) });
const at = (c, x, y) => [...c.px.subarray((y * c.w + x) * 3, (y * c.w + x) * 3 + 3)];

test('every glyph is 7 rows of 5 cells, and lower case draws as upper case', () => {
  for (const [ch, rows] of Object.entries(GLYPHS)) {
    assert.equal(rows.length, 7, ch);
    for (const r of rows) assert.match(r, /^[01]{5}$/, ch);
  }
  const [a, b] = [canvas(40, 20), canvas(40, 20)];
  drawText(a.px, a.w, 0, 0, a.w, 'kill hs6');
  drawText(b.px, b.w, 0, 0, b.w, 'KILL HS6');
  assert.deepEqual(a.px, b.px);
});

test('a glyph is 2x2 white blocks from (left+2, top+2); unknown characters and spaces leave a blank advance', () => {
  const c = canvas(3 * ADVANCE + 4, 20);
  drawText(c.px, c.w, 0, 0, c.w, 'H?H');
  for (let y = 0; y < 14; y++) {
    for (let x = 0; x < 10; x++) {
      const on = GLYPHS.H[y >> 1][x >> 1] === '1' ? [255, 255, 255] : [24, 24, 24];
      assert.deepEqual(at(c, 2 + x, 2 + y), on);
      assert.deepEqual(at(c, 2 + 2 * ADVANCE + x, 2 + y), on);
      assert.deepEqual(at(c, 2 + ADVANCE + x, 2 + y), [24, 24, 24]);
    }
  }
});

test('text is clipped to the cell and the count of whole characters is returned', () => {
  const c = canvas(60, 20);
  assert.equal(drawText(c.px, c.w, 0, 0, 30, 'ABCDE'), 2);
  for (let y = 0; y < 20; y++) for (let x = 30; x < 60; x++) assert.deepEqual(at(c, x, y), [24, 24, 24]);
});
