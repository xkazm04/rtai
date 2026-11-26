// n31 melee 01e: Rivet's own body out of the clean drawn mask, by geometry (pure). 01d's mask still held
// his head, shoulders and strike arm (the strike pose differs from the idle outline; katana, plasma and saw
// are drawn inside his body strip cell, so no body-only drawing of the same pose exists to diff against).
// Three cuts (radius and head moved with his lunge at that tick, poses[k]):
//   radius: a mask pixel whose ground point (the measure's own projection, gun height) lies within
//           rivet.radius_m (combat.json, 0.6 m) of his centre at that tick;
//   head:   a mask pixel above his shoulder line (idle silhouette top + HEAD_PX) inside his head column
//           (the idle silhouette's x-span over those rows, grown HEAD_GROW px). Only the column: a blade
//           drawn high on screen away from him is a real far cut (ring cells at -90 deg, 1.5 m+ sit there).
//   floor:  a mask pixel whose colour matches the empty-arena bg frame (Rivet hidden) within THRESHOLD: floor
//           his idle body covered and his lunge uncovered (the idle diff flags it; a band along his back).
// What it hides: a blade within 0.6 m of his centre (the inner ring cell's body reaches 0.35 m, so only the
// inner part of that cell is lost) and a blade crossing in front of his head on screen.
import { readFileSync } from 'node:fs';
import { THRESHOLD, screenToGround } from './blade_volume_pixels.mjs';
import { lungePx } from './blade_volume_clean.mjs';

export const HEAD_PX = 36; // idle silhouette top to the shoulder row (measured: top y 396, shoulders 432 at 64 px/m)
export const HEAD_GROW = 6; // px the head column grows by on each side (the strike pose leans)

/** rivet.radius_m from combat.json at `root` (the checkout the measure reads). */
export function hurtRadius(root) {
  const t = JSON.parse(readFileSync(`${root}/project/data/tables/combat.json`, 'utf8'));
  return t.rivet.radius_m;
}

/** {top, x0, x1}: the idle silhouette's top row and its x-span over the head rows (crop px), null if empty. */
export function headBox(idleBody, w, h) {
  let top = -1, x0 = w, x1 = -1;
  for (let y = 0; y < h && (top < 0 || y < top + HEAD_PX); y++) {
    for (let x = 0; x < w; x++) {
      if (!idleBody[y * w + x]) continue;
      if (top < 0) top = y;
      x0 = Math.min(x0, x);
      x1 = Math.max(x1, x);
    }
  }
  return top < 0 ? null : { top, x0: x0 - HEAD_GROW, x1: x1 + HEAD_GROW };
}

/** True when pixel i of RGB8 frames a and b differs by THRESHOLD or less (the same floor). */
function alike(a, b, i) {
  const o = i * 3;
  return Math.abs(a[o] - b[o]) + Math.abs(a[o + 1] - b[o + 1]) + Math.abs(a[o + 2] - b[o + 2]) <= THRESHOLD;
}

/** The mask with Rivet's body at tick k cut out: {mask, radius, head, floor: px each cut}.
 * px = {frame, bg} (RGB8 of tick k and the empty arena) enables the floor cut. */
export function cutBody(mask, idleBody, meta, k, radiusM, px = null) {
  const [cx, cy, w, h] = meta.crop;
  const p = meta.poses?.[String(k)] ?? [0, 0];
  const [dx, dy] = lungePx(meta, k);
  const box = headBox(idleBody, w, h);
  const out = new Uint8Array(mask);
  const r2 = radiusM * radiusM;
  let radius = 0, head = 0, floor = 0;
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const i = y * w + x;
      if (!out[i]) continue;
      if (px && alike(px.frame, px.bg, i)) {
        out[i] = 0;
        floor += 1;
        continue;
      }
      if (box && y < box.top + HEAD_PX + dy && x >= box.x0 + dx && x <= box.x1 + dx) {
        out[i] = 0;
        head += 1;
        continue;
      }
      const [gx, gy] = screenToGround(cx + x + 0.5, cy + y + 0.5, meta);
      if ((gx - p[0]) ** 2 + (gy - p[1]) ** 2 <= r2) {
        out[i] = 0;
        radius += 1;
      }
    }
  }
  return { mask: out, radius, head, floor };
}
