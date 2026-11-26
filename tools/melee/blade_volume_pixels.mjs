// n31 melee 01c: the drawn swing from rendered pixels (pure). blade_pixels.gd saves raw RGB8 crops
// around Rivet: bg (Rivet hidden), idle (Rivet standing, before the press) and each swing tick k.
// The drawn swing mask = pixels of tick k that differ from idle beyond a threshold, less Rivet's idle
// body (idle vs bg, dilated: what idle drew) and less pure darkening (a cast shadow on the floor). Each mask pixel is
// put on the ground with the camera's real world-to-screen transform, as the game draws Rivet's gun:
// at gun height (ShotLift.up_m, GUN_H_M 1 m), so ground = T^-1(screen) / px_per_m - lift.

export const THRESHOLD = 60; // sum of |dR|+|dG|+|dB| (0..765) for a pixel to count as changed
export const BODY_DILATE = 6; // px the idle body mask grows by
export const MIN_PIXELS = 12; // a tick with fewer mask pixels draws nothing (noise)

/** 1 where a and b (RGB8, same size) differ by more than `thr`, 0 elsewhere. */
export function diffMask(a, b, n, thr = THRESHOLD, dropShadow = false) {
  const m = new Uint8Array(n);
  for (let i = 0; i < n; i++) {
    const o = i * 3;
    const dr = a[o] - b[o], dg = a[o + 1] - b[o + 1], db = a[o + 2] - b[o + 2];
    if (Math.abs(dr) + Math.abs(dg) + Math.abs(db) <= thr) continue;
    if (dropShadow && dr <= 6 && dg <= 6 && db <= 6 && a[o] + a[o + 1] + a[o + 2] >= 0.3 * (b[o] + b[o + 1] + b[o + 2])) continue;
    m[i] = 1;
  }
  return m;
}

/** The mask grown by r px (square). */
export function dilate(mask, w, h, r) {
  const out = new Uint8Array(mask.length);
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      if (!mask[y * w + x]) continue;
      for (let yy = Math.max(0, y - r); yy <= Math.min(h - 1, y + r); yy++) {
        out.fill(1, yy * w + Math.max(0, x - r), yy * w + Math.min(w - 1, x + r) + 1);
      }
    }
  }
  return out;
}

/** The drawn swing mask of one tick: changed against the idle frame, not Rivet's idle body, not a shadow. */
export function swingMask(frame, idle, body, n) {
  const m = diffMask(frame, idle, n, THRESHOLD, true);
  let count = 0;
  for (let i = 0; i < n; i++) {
    if (body[i]) m[i] = 0;
    count += m[i];
  }
  return count < MIN_PIXELS ? new Uint8Array(n) : m;
}

/** A screen pixel (full-frame px) to ground metres relative to Rivet's start, at gun height. */
export function screenToGround(sx, sy, meta) {
  const [xx, xy, yx, yy, ox, oy] = meta.world_to_screen;
  const det = xx * yy - yx * xy;
  const dx = sx - ox, dy = sy - oy;
  const wx = (yy * dx - yx * dy) / det;
  const wy = (-xy * dx + xx * dy) / det;
  const ppm = meta.px_per_m;
  return [wx / ppm - meta.lift_m[0] - meta.origin_m[0], wy / ppm - meta.lift_m[1] - meta.origin_m[1]];
}

/** Ground metres (relative to Rivet's start) to a full-frame screen pixel, at `lifted` gun height or on the floor. */
export function groundToScreen(gx, gy, meta, lifted = true) {
  const [xx, xy, yx, yy, ox, oy] = meta.world_to_screen;
  const ppm = meta.px_per_m;
  const wx = (gx + meta.origin_m[0] + (lifted ? meta.lift_m[0] : 0)) * ppm;
  const wy = (gy + meta.origin_m[1] + (lifted ? meta.lift_m[1] : 0)) * ppm;
  return [xx * wx + yx * wy + ox, xy * wx + yy * wy + oy];
}

/** The mask's pixels as ground points (every `step` px), crop offset from meta.crop. */
export function maskPoints(mask, meta, step = 2) {
  const [cx, cy, w, h] = meta.crop;
  const pts = [];
  for (let y = 0; y < h; y += step) {
    for (let x = 0; x < w; x += step) {
      if (mask[y * w + x]) pts.push(screenToGround(cx + x + 0.5, cy + y + 0.5, meta));
    }
  }
  return pts;
}

/** Signed degrees of `p` off the aim `facingDeg` in (-180, 180]. */
export function offAim(p, facingDeg) {
  let a = (Math.atan2(p[1], p[0]) * 180) / Math.PI - facingDeg;
  while (a > 180) a -= 360;
  while (a <= -180) a += 360;
  return a;
}

/** {deg: [min, max] off the aim, reach_m: max distance} of ground points, null when empty. */
export function polar(points, facingDeg, minReach = 0.3) {
  const far = points.filter((p) => Math.hypot(p[0], p[1]) >= minReach);
  if (far.length === 0) return null;
  let lo = Infinity, hi = -Infinity, reach = 0;
  for (const p of far) {
    const a = offAim(p, facingDeg);
    lo = Math.min(lo, a);
    hi = Math.max(hi, a);
    reach = Math.max(reach, Math.hypot(p[0], p[1]));
  }
  const r1 = (v) => Math.round(v * 10) / 10;
  const angs = far.map((p) => offAim(p, facingDeg)).sort((a, b) => a - b);
  const dists = far.map((p) => Math.hypot(p[0], p[1])).sort((a, b) => a - b);
  const q = (xs, f) => xs[Math.min(xs.length - 1, Math.floor(f * xs.length))];
  // deg_p5_p95 / reach_p95: the bulk of the mask (stray specks of arena motion do not widen it)
  return { deg: [r1(lo), r1(hi)], reach_m: Math.round(reach * 100) / 100, points: far.length,
    deg_p5_p95: [r1(q(angs, 0.05)), r1(q(angs, 0.95))], reach_p95: Math.round(q(dists, 0.95) * 100) / 100 };
}

/** True when any ground point lies within r of the centre c (a body circle the drawn swing touches). */
export function touches(points, c, r) {
  const r2 = r * r;
  return points.some((p) => (p[0] - c[0]) ** 2 + (p[1] - c[1]) ** 2 <= r2);
}

/** A ring cell's centre (m, relative to Rivet's start) from its angle and distance. */
export function cellAt(cell) {
  const a = (cell.angle_deg * Math.PI) / 180;
  return [Math.cos(a) * cell.dist_m, Math.sin(a) * cell.dist_m];
}

/** A mover's offset at tick k (BladeTrials.at): x = 1.4 m, crossing at 1.4 m/s, on the aim line lag ticks after landK. */
export function moverAt(m, k, landK, x = 1.4, speed = 1.4, dt = 1 / 60) {
  return [x, m.dir * speed * dt * (Math.max(landK, 0) + m.lag - k)];
}

/** Re-judges 01a's hit cells with the pixel drawn side: ticks = {k: points} (facing 0). */
export function judge(hitResult, ticks) {
  const union = Object.values(ticks).flat();
  const ring = { drawn_no_hit: 0, hit_not_drawn: 0, both: 0, neither: 0 };
  const cells = hitResult.cells.map((c) => {
    const at = cellAt(c);
    const drawnKs = Object.keys(ticks).map(Number).filter((k) => touches(ticks[k], at, c.radius_m));
    const drawn = union.length > 0 && drawnKs.length > 0;
    const key = drawn && c.hit ? 'both' : drawn ? 'drawn_no_hit' : c.hit ? 'hit_not_drawn' : 'neither';
    ring[key] += 1;
    return { ...c, drawn, drawn_ks: drawnKs };
  });
  const movers = hitResult.movers.map((m) => {
    const drawnKs = Object.keys(ticks).map(Number).filter((k) => touches(ticks[k], moverAt(m, k, hitResult.land_k), m.radius_m));
    return { ...m, drawn: drawnKs.length > 0, drawn_ks: drawnKs };
  });
  return { ring, cells, movers };
}
