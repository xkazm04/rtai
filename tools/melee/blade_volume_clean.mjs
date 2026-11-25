// n31 melee 01d: the drawn swing mask cut down to the blade, swipe and smear (pure).
// blade_pixels.gd draws each tick twice with the sim held: full (`k<k>`) and with Rivet's held view
// hidden (`k<k>_nw`: held weapon, swipe crescent, smear are its children). The clean mask of tick k:
//   layer = full vs nw: exactly what the held view drew (claw slash, baton + crescent, every game smear);
//   strip = nw vs idle, minus Rivet's idle silhouette moved by his lunge (poses[k]) and grown BODY_GROW px:
//           what his strip cell drew outside his body (the katana, plasma and saw blades live in the cell);
//   then only connected pieces near his moved body survive (stray arena motion metres away drops out).
import { THRESHOLD, MIN_PIXELS, diffMask, dilate, groundToScreen } from './blade_volume_pixels.mjs';

export const BODY_GROW = 4; // px the moved idle silhouette grows by (the brief's 4 px)
export const GAP = 6; // px: pieces closer than 2 * GAP are one piece (a crescent beside its blade)
export const NEAR = 24; // px: a piece must come this close to his moved body to be kept

/** The mask moved by (dx, dy) whole px; what leaves the crop is dropped. */
export function shift(mask, w, h, dx, dy) {
  const out = new Uint8Array(mask.length);
  for (let y = 0; y < h; y++) {
    const sy = y - dy;
    if (sy < 0 || sy >= h) continue;
    for (let x = 0; x < w; x++) {
      const sx = x - dx;
      if (sx >= 0 && sx < w && mask[sy * w + sx]) out[y * w + x] = 1;
    }
  }
  return out;
}

/** Keeps the 8-connected pieces of `mask` (joined across `gap` px) that touch `anchor`. */
export function keepTouching(mask, anchor, w, h, gap = GAP) {
  const grown = gap > 0 ? dilate(mask, w, h, gap) : mask;
  const label = new Int32Array(mask.length).fill(-1);
  const keep = [];
  const stack = [];
  for (let i = 0; i < grown.length; i++) {
    if (!grown[i] || label[i] >= 0) continue;
    const id = keep.length;
    let hit = false;
    label[i] = id;
    stack.push(i);
    while (stack.length) {
      const j = stack.pop();
      if (anchor[j] && mask[j]) hit = true;
      const x = j % w, y = (j - x) / w;
      for (let yy = Math.max(0, y - 1); yy <= Math.min(h - 1, y + 1); yy++) {
        for (let xx = Math.max(0, x - 1); xx <= Math.min(w - 1, x + 1); xx++) {
          const q = yy * w + xx;
          if (grown[q] && label[q] < 0) { label[q] = id; stack.push(q); }
        }
      }
    }
    keep.push(hit);
  }
  const out = new Uint8Array(mask.length);
  for (let i = 0; i < mask.length; i++) if (mask[i] && keep[label[i]]) out[i] = 1;
  return out;
}

/** Rivet's screen displacement (whole px) at tick k from poses[k] = [dx_m, dy_m, strike_t]. */
export function lungePx(meta, k) {
  const p = meta.poses?.[String(k)];
  if (!p) return [0, 0];
  const [x0, y0] = groundToScreen(0, 0, meta, false);
  const [x1, y1] = groundToScreen(p[0], p[1], meta, false);
  return [Math.round(x1 - x0), Math.round(y1 - y0)];
}

/** The clean mask of one tick: {mask, layer, strip, body} (body = his moved silhouette, for overlays). */
export function cleanMask(frame, nw, idle, idleBody, meta, k) {
  const [, , w, h] = meta.crop;
  const n = w * h;
  const [dx, dy] = lungePx(meta, k);
  const body = shift(idleBody, w, h, dx, dy);
  const grown = dilate(body, w, h, BODY_GROW);
  const layer = diffMask(frame, nw, n, THRESHOLD);
  const strip = diffMask(nw, idle, n, THRESHOLD, true);
  const both = new Uint8Array(n);
  for (let i = 0; i < n; i++) {
    if (!layer[i] && grown[i]) strip[i] = 0;
    both[i] = layer[i] | strip[i];
  }
  let mask = keepTouching(both, dilate(body, w, h, NEAR), w, h);
  let count = 0;
  for (let i = 0; i < n; i++) count += mask[i];
  if (count < MIN_PIXELS) mask = new Uint8Array(n);
  return { mask, layer, strip, body };
}

/** True when two raw frames are byte-identical (a held pose or a repeated readback). */
export function same(a, b) {
  return a.length === b.length && a.equals(b);
}
