import assert from 'node:assert/strict';
import test from 'node:test';
import { cleanMask, keepTouching, shift } from './blade_volume_clean.mjs';

const W = 80, H = 30;
const rgb = (paint) => {
  const b = Buffer.alloc(W * H * 3, 20);
  for (const [x0, y0, x1, y1, c] of paint) {
    for (let y = y0; y <= y1; y++) for (let x = x0; x <= x1; x++) b.fill(c, (y * W + x) * 3, (y * W + x) * 3 + 3);
  }
  return b;
};
const count = (m) => m.reduce((a, v) => a + v, 0);
const meta = { crop: [0, 0, W, H], world_to_screen: [64, 0, 0, 64, 0, 0], px_per_m: 1, origin_m: [0, 0], lift_m: [0, 0], poses: {} };

test('shift moves a mask by whole pixels and drops what leaves the crop', () => {
  const m = new Uint8Array(W * H);
  m[0] = 1;
  m[W * H - 1] = 1;
  const s = shift(m, W, H, 2, 1);
  assert.equal(s[1 * W + 2], 1);
  assert.equal(count(s), 1);
});

test('keepTouching drops a piece far from the anchor and keeps one joined across the gap', () => {
  const m = new Uint8Array(W * H), anchor = new Uint8Array(W * H);
  for (const x of [5, 6, 12, 60]) m[10 * W + x] = 1;
  anchor[10 * W + 5] = 1;
  const k = keepTouching(m, anchor, W, H, 4);
  assert.deepEqual([k[10 * W + 5], k[10 * W + 6], k[10 * W + 12], k[10 * W + 60]], [1, 1, 1, 0]);
});

test('cleanMask keeps the held layer and the strip blade, not the body nor a far blob', () => {
  const bg = rgb([]);
  const idle = rgb([[10, 10, 14, 20, 200]]);
  const idleBody = new Uint8Array(W * H);
  for (let i = 0; i < W * H; i++) idleBody[i] = idle[i * 3] !== bg[i * 3] ? 1 : 0;
  // nw: the body, a strip blade out to the right (x 19..27), an arena blob far right (x 70..72, y 0..2)
  const nw = rgb([[10, 10, 14, 20, 200], [19, 14, 27, 15, 255], [70, 0, 72, 2, 120]]);
  // full: nw plus the held view's crescent below the blade
  const full = rgb([[10, 10, 14, 20, 200], [19, 14, 27, 15, 255], [70, 0, 72, 2, 120], [18, 18, 26, 19, 90]]);
  const { mask, layer } = cleanMask(full, nw, idle, idleBody, meta, 3);
  assert.equal(count(layer), 9 * 2);
  assert.equal(mask[14 * W + 22], 1, 'strip blade kept');
  assert.equal(mask[18 * W + 22], 1, 'crescent kept');
  assert.equal(mask[15 * W + 12], 0, 'body dropped');
  assert.equal(mask[1 * W + 71], 0, 'far blob dropped');
});
