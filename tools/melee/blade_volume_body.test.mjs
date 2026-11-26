import assert from 'node:assert/strict';
import test from 'node:test';
import { HEAD_PX, cutBody, headBox, hurtRadius } from './blade_volume_body.mjs';

const W = 200, H = 120;
// 1 px per metre-ish camera: 10 px per m, no lift, origin at crop (100, 80)
const meta = { crop: [0, 0, W, H], world_to_screen: [1, 0, 0, 1, 100, 80], px_per_m: 10, origin_m: [0, 0], lift_m: [0, 0], poses: {} };
const box = (x0, y0, x1, y1) => {
  const m = new Uint8Array(W * H);
  for (let y = y0; y <= y1; y++) for (let x = x0; x <= x1; x++) m[y * W + x] = 1;
  return m;
};
const count = (m) => m.reduce((a, v) => a + v, 0);
const idleBody = box(95, 20, 105, 85); // top row 20: head rows 20..55

test('headBox spans the silhouette over its head rows, grown', () => {
  const b = headBox(idleBody, W, H);
  assert.equal(b.top, 20);
  assert.ok(b.x0 < 95 && b.x1 > 105);
});

test('the radius cut drops pixels within r of his centre, keeps a blade beyond it', () => {
  const mask = box(100, 78, 160, 82); // a blade from his centre out to 6 m
  const r = cutBody(mask, idleBody, meta, 0, 0.6);
  assert.ok(r.radius > 0);
  for (let x = 100; x <= 105; x++) assert.equal(r.mask[80 * W + x], 0);
  assert.equal(r.mask[80 * W + 150], 1);
});

test('the head cut drops his head column above the shoulder line only', () => {
  const head = box(96, 22, 104, 30);
  assert.equal(count(cutBody(head, idleBody, meta, 0, 0.6).mask), 0);
  const far = box(160, 22, 170, 30); // high on screen, far from him: a real far cut
  assert.equal(count(cutBody(far, idleBody, meta, 0, 0.6).mask), count(far));
  const below = box(96, 20 + HEAD_PX + 2, 104, 20 + HEAD_PX + 4);
  assert.equal(cutBody(below, idleBody, meta, 0, 0.1).head, 0);
});

test('the head cut follows his lunge (poses[k])', () => {
  const m = { ...meta, poses: { 3: [4, 0, 0.5] } }; // 4 m right = 40 px
  const head = box(136, 22, 144, 30);
  assert.equal(count(cutBody(head, idleBody, m, 3, 0.6).mask), 0);
  assert.equal(count(cutBody(head, idleBody, meta, 3, 0.6).mask), count(head));
});

test('the floor cut drops pixels that match the empty arena', () => {
  const bg = Buffer.alloc(W * H * 3, 40);
  const frame = Buffer.from(bg);
  for (let x = 150; x <= 160; x++) frame.fill(250, (40 * W + x) * 3, (40 * W + x) * 3 + 3);
  const mask = box(140, 40, 160, 40);
  const r = cutBody(mask, idleBody, meta, 0, 0.6, { frame, bg });
  assert.equal(r.floor, 10);
  assert.equal(count(r.mask), 11);
});

test('hurtRadius reads rivet.radius_m from combat.json', () => {
  assert.equal(hurtRadius(new URL('../..', import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1')), 0.6);
});
