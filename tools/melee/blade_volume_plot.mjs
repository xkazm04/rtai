// n31 melee 01c: one weapon's polar plot from the pixel drawn side. Rivet at the centre facing right
// (+x), 64 px per metre. Hit volume (reach + body radius inside the cone) filled translucent, the
// union of the drawn mask (facing 0) outlined cream, each ring cell's body circle: drawn-no-hit
// vermilion, hit-not-drawn ice blue, both grey, neither a dim ring. Range rings every metre.
import { execFileSync } from 'node:child_process';
import { rmSync, writeFileSync } from 'node:fs';
import { cellAt } from './blade_volume_pixels.mjs';

const SIZE = 480, PX_M = 64, C = SIZE / 2;
const BG = [21, 23, 27], CREAM = [244, 236, 216], HIT = [140, 158, 178], VERMILION = [227, 66, 52];
const ICE = [143, 211, 255], BOTH = [153, 153, 153], DIM = [89, 89, 97];

function canvas() {
  const im = Buffer.alloc(SIZE * SIZE * 3);
  for (let i = 0; i < SIZE * SIZE; i++) im.set(BG, i * 3);
  const put = (x, y, c, a = 1) => {
    x = Math.round(x); y = Math.round(y);
    if (x < 0 || y < 0 || x >= SIZE || y >= SIZE) return;
    const o = (y * SIZE + x) * 3;
    for (let j = 0; j < 3; j++) im[o + j] = Math.round(im[o + j] * (1 - a) + c[j] * a);
  };
  return { im, put };
}

const px = (m) => [C + m[0] * PX_M, C + m[1] * PX_M];

function circle(put, at, r, col, thick) {
  const [x, y] = px(at);
  const steps = Math.max(24, Math.round(r * PX_M * 7));
  for (let s = 0; s < steps; s++) {
    const a = (s / steps) * Math.PI * 2;
    for (let t = 0; t < thick; t++) put(x + Math.cos(a) * (r * PX_M - t), y + Math.sin(a) * (r * PX_M - t), col);
  }
}

/** Writes `png`: hit = 01a's hit result (reach_m, cone_dot, cells), judged = blade_volume_pixels.judge, union = ground points. */
export function plot(hit, judged, union, png) {
  const { im, put } = canvas();
  const half = Math.acos(Math.max(-1, Math.min(1, hit.cone_dot)));
  const r = (hit.reach_m + 0.45) * PX_M;
  for (let y = 0; y < SIZE; y++) {
    for (let x = 0; x < SIZE; x++) {
      const dx = x - C, dy = y - C;
      if (Math.hypot(dx, dy) <= r && Math.abs(Math.atan2(dy, dx)) <= half) put(x, y, HIT, 0.35);
    }
  }
  for (let m = 1; m <= 3; m++) circle(put, [0, 0], m, DIM, 1);
  const grid = new Uint8Array(SIZE * SIZE);
  for (const p of union) {
    const [x, y] = px(p).map(Math.round);
    if (x >= 0 && y >= 0 && x < SIZE && y < SIZE) grid[y * SIZE + x] = 1;
  }
  const near = (x, y) => [-1, 0, 1].some((a) => [-1, 0, 1].some((b) => grid[(y + b) * SIZE + x + a]));
  for (let y = 1; y < SIZE - 1; y++) {
    for (let x = 1; x < SIZE - 1; x++) {
      if (near(x, y) && !(near(x - 2, y) && near(x + 2, y) && near(x, y - 2) && near(x, y + 2))) put(x, y, CREAM);
      else if (grid[y * SIZE + x]) put(x, y, CREAM, 0.25);
    }
  }
  for (const c of judged.cells) {
    const col = c.drawn && c.hit ? BOTH : c.drawn ? VERMILION : c.hit ? ICE : DIM;
    circle(put, cellAt(c), c.radius_m, col, c.drawn || c.hit ? 3 : 1);
  }
  const tmp = png + '.rgb';
  writeFileSync(tmp, im);
  execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', '-f', 'rawvideo', '-pix_fmt', 'rgb24',
    '-s', `${SIZE}x${SIZE}`, '-i', tmp, png], { windowsHide: true });
  rmSync(tmp);
}
