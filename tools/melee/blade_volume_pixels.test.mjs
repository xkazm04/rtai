import assert from 'node:assert/strict';
import { test } from 'node:test';
import { diffMask, dilate, groundToScreen, judge, maskPoints, offAim, polar, screenToGround, swingMask, touches } from './blade_volume_pixels.mjs';

// A tilt-70 camera at 64 px/m view zoom on a 64 px/m world: x 1, y sin(70); Rivet at world (10, 20) m.
const K = Math.sin((70 * Math.PI) / 180);
const META = {
  world_to_screen: [1, 0, 0, K, 100, 50], px_per_m: 64, lift_m: [0, -0.36], origin_m: [10, 20], crop: [740, 1200, 60, 60],
};

test('screenToGround inverts groundToScreen at gun height and on the floor', () => {
  for (const g of [[0, 0], [1.5, -0.7], [-2, 3]]) {
    const [sx, sy] = groundToScreen(g[0], g[1], META);
    const back = screenToGround(sx, sy, META);
    assert.ok(Math.abs(back[0] - g[0]) < 1e-9 && Math.abs(back[1] - g[1]) < 1e-9);
  }
  const floor = groundToScreen(0, 0, META, false);
  const gun = groundToScreen(0, 0, META, true);
  assert.equal(floor[0], gun[0]);
  assert.ok(gun[1] < floor[1], 'gun height draws higher up the screen');
});

test('a pixel drawn at gun height over Rivet maps to his ground point, not 0.36 m behind him', () => {
  const [sx, sy] = groundToScreen(0, 0, META, true);
  const g = screenToGround(sx, sy, META);
  assert.ok(Math.hypot(g[0], g[1]) < 1e-9);
  // one ground metre forward (+x) is 64 screen px right; one metre down-screen (+y) is 64 * sin70 px
  const fwd = screenToGround(sx + 64, sy, META);
  const down = screenToGround(sx, sy + 64 * K, META);
  assert.ok(Math.abs(fwd[0] - 1) < 1e-9 && Math.abs(down[1] - 1) < 1e-9);
});

test('swingMask drops the idle body, pure darkening (a shadow) and specks', () => {
  const n = 4 * 4;
  const bg = new Uint8Array(n * 3).fill(100);
  const frame = Uint8Array.from(bg);
  const body = new Uint8Array(n);
  body[0] = 1;
  for (const i of [0, 1, 2]) frame.fill(250, i * 3, i * 3 + 3); // bright blade px; 0 is under the body
  frame.fill(60, 5 * 3, 5 * 3 + 3); // a shadow: darker, same hue
  const m = Array.from(diffMask(frame, bg, n, 60, true));
  assert.deepEqual(m.slice(0, 6), [1, 1, 1, 0, 0, 0]);
  assert.equal(swingMask(frame, bg, body, n).reduce((a, b) => a + b, 0), 0, 'two px is a speck (under MIN_PIXELS)');
});

test('dilate grows a mask by r', () => {
  const m = new Uint8Array(25);
  m[12] = 1;
  assert.equal(dilate(m, 5, 5, 1).reduce((a, b) => a + b, 0), 9);
});

test('maskPoints puts the crop pixels on the ground; polar reads angle off the aim and reach', () => {
  const [, , w, h] = META.crop;
  const mask = new Uint8Array(w * h);
  const [sx, sy] = groundToScreen(0.5, 0, META, true);
  mask[Math.floor(sy - 1200) * w + Math.floor(sx - 740)] = 1;
  const pts = maskPoints(mask, META, 1);
  assert.equal(pts.length, 1);
  assert.ok(Math.abs(pts[0][0] - 0.5) < 0.02 && Math.abs(pts[0][1]) < 0.02);
  assert.equal(offAim([0, 1], 90), 0);
  assert.equal(offAim([1, 0], 90), -90);
  assert.equal(Math.round(offAim([0.7, -0.7], 315)), 0);
  const p = polar([[1, 0], [0, 1], [0.1, 0]], 0);
  assert.deepEqual(p.deg, [0, 90]);
  assert.equal(p.reach_m, 1);
});

test('judge: a cell is drawn when any tick touches its body circle, the counts follow', () => {
  const cells = [
    { kind: 'ring', angle_deg: 0, dist_m: 1.4, radius_m: 0.45, hit: true },
    { kind: 'ring', angle_deg: 90, dist_m: 1.4, radius_m: 0.45, hit: false },
    { kind: 'ring', angle_deg: 180, dist_m: 1.4, radius_m: 0.45, hit: true },
    { kind: 'ring', angle_deg: 270, dist_m: 3.2, radius_m: 0.45, hit: false },
  ];
  const movers = [{ kind: 'mover', lag: 0, dir: 1, radius_m: 0.45, hit: true }];
  const ticks = { 3: [[1.1, 0.1]], 4: [[0.1, 1.2], [1.4, 0]] };
  const r = judge({ cells, movers, land_k: 4 }, ticks);
  assert.deepEqual(r.ring, { both: 1, drawn_no_hit: 1, hit_not_drawn: 1, neither: 1 });
  assert.deepEqual(r.cells[0].drawn_ks, [3, 4]);
  assert.deepEqual(r.movers[0].drawn_ks, [3, 4], 'the mover is 0.02 m off the aim line at k 3, on it at k 4');
  assert.ok(touches([[0, 0.45]], [0, 0], 0.45));
});
