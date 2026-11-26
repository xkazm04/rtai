// n31-18: yard conveyors and spans from the draw (split from audit.mjs for the file-size debt ratchet).
import { join } from 'node:path';
import { opaqueBox, mismatch, verdict, load, r3, PROJECT, BAND_M } from './audit.mjs';

export const LEG_BAND_M = 0.3;
export const FOOT_PAD_M = 0.12;
const hit = (a, b) => a.x0 < b.x1 && b.x0 < a.x1 && a.y0 < b.y1 && b.y0 < a.y1;

/** Art stretched into rect `at`/`size` (m), as PrologueYardPaint.wreck lays an unrotated piece: opaque bounds, lowest-band
 * base and the column runs of the lowest `LEG_BAND_M` (legs / machine feet) in world metres. */
export function placedBase(png, at, size, bandM = LEG_BAND_M) {
  const o = opaqueBox(png);
  if (!o) return null;
  const left = at[0] - size[0] / 2;
  const top = at[1] - size[1] / 2;
  const kx = size[0] / png.width;
  const ky = size[1] / png.height;
  const bandPx = Math.max(1, Math.round((bandM / ky)));
  const y0px = Math.max(o.y0, o.y1 - bandPx);
  const runs = [];
  let start = -1;
  let gap = 0;
  const gapPx = Math.max(1, Math.round(0.12 / kx));
  for (let x = o.x0; x <= o.x1; x++) {
    const col = x < o.x1 ? opaqueBox(png, { x, y: y0px, w: 1, h: o.y1 - y0px }) : null;
    if (col) { if (start < 0) start = x; gap = 0; continue; }
    if (start >= 0 && ++gap > gapPx) { runs.push([start, x - gap + 1]); start = -1; gap = 0; }
  }
  const m = (px, k, base) => r3(base + px * k);
  return {
    opaque: { x0: m(o.x0, kx, left), x1: m(o.x1, kx, left), y0: m(o.y0, ky, top), y1: m(o.y1, ky, top) },
    base: { x0: m(o.x0, kx, left), x1: m(o.x1, kx, left), y0: m(y0px, ky, top), y1: m(o.y1, ky, top) },
    legs: runs.map(([a, b]) => ({ x0: m(a, kx, left), x1: m(b, kx, left), y0: m(y0px, ky, top), y1: m(o.y1, ky, top) })),
    fraction: o.fraction,
  };
}

function footVerdict(mm) {
  const v = verdict(mm, ['south']);
  return v.verdict === 'art overhangs passable' ? { ...v, verdict: 'footprint north of drawn base' } : v;
}

/** Yard conveyors from the draw: each `conveyor_*` cover box against the `arch_*` belt art over-printed on it (same x),
 * and every `span_*` / `arch_*` piece: overhead or not, where the legs stand, whether a cover box stops them. */
export function auditYardStructures(look, coverBoxes) {
  const rows = [];
  const pieces = look.layout.debris.filter((d) => /^(arch|span)_/.test(d.id));
  for (const d of pieces) {
    const png = load(join(PROJECT, d.art.replace('res://', '')));
    const row = { arena: 'yard', id: d.id, kind: d.id.startsWith('span') ? 'span' : 'arch', class: 'passable (not in layout.cover)', art: d.art.split('/').pop(), footprint_m: d.size_m, projected_shadow: false };
    if (png.error) { rows.push({ ...row, verdict: 'unmeasured', note: png.error }); continue; }
    const pb = placedBase(png, d.at, d.size_m);
    if (!pb) { rows.push({ ...row, verdict: 'unmeasured', note: 'no opaque pixel' }); continue; }
    const legs = pb.legs.map((l) => ({ ...l, blocked_by: coverBoxes.filter((c) => hit(l, c.box)).map((c) => c.id) }));
    const blocked = legs.filter((l) => l.blocked_by.length).length;
    const span = pb.opaque.x1 - pb.opaque.x0;
    rows.push({ ...row, drawn_span_m: [r3(span), r3(pb.opaque.y1 - pb.opaque.y0)], opaque_fraction: r3(pb.fraction), legs_m: legs.map((l) => ({ x: [l.x0, l.x1], y: [l.y0, l.y1], blocked_by: l.blocked_by })), legs: legs.length, legs_blocking: blocked, verdict: row.kind === 'span' ? 'overhead span (passable by rule: offset floor shadow, no base)' : span > 3 && blocked < legs.length ? 'big drawn structure, legs walkable' : 'ok', worst_m: 0, note: row.kind === 'span' ? 'overhead span: PrologueSpanShadow draws Rivet under it, no collider' : 'belt + machines art over-printed on the conveyor_* box; only the box blocks' });
  }
  for (const c of coverBoxes.filter((b) => b.id.startsWith('conveyor_'))) {
    const arch = pieces.find((d) => d.id === 'arch_' + c.id.slice('conveyor_'.length));
    if (!arch) continue;
    const png = load(join(PROJECT, arch.art.replace('res://', '')));
    const pb = png.error ? null : placedBase(png, arch.at, arch.size_m, BAND_M);
    if (!pb) continue;
    const mm = mismatch(c.box, pb.base);
    rows.push({ arena: 'yard', id: `${c.id} vs ${arch.id}`, kind: 'cover_low', class: 'blocks movement + shots', art: arch.art.split('/').pop() + ' (over-printed on the box)', footprint_m: [r3(c.box.x1 - c.box.x0), r3(c.box.y1 - c.box.y0)], drawn_base_m: [r3(pb.base.x1 - pb.base.x0), r3(pb.base.y1 - pb.base.y0)], base_south_m: pb.base.y1, box_south_m: r3(c.box.y1), mismatch_m: mm, ...footVerdict(mm), note: 'footing_shadow row above is the floor shadow; this is the machine/belt art drawn over it. south = box south minus drawn bottom (negative: art hangs below the box). W/E/N not compared: belt art spans 8.7 m, box 5.2 m' });
  }
  for (const c of coverBoxes.filter((b) => b.id.startsWith('leg_'))) {
    const arch = pieces.find((d) => d.id === 'arch_' + c.id.split('_')[1]);
    const png = arch ? load(join(PROJECT, arch.art.replace('res://', ''))) : { error: 'no arch' };
    const base = png.error ? null : footUnder(png, arch, c.box);
    const row = { arena: 'yard', id: `${c.id} vs ${arch?.id}`, kind: 'cover_low', class: 'blocks movement + shots', art: `${arch?.art.split('/').pop()} (drawn leg)`, footprint_m: [r3(c.box.x1 - c.box.x0), r3(c.box.y1 - c.box.y0)] };
    if (!base) { rows.push({ ...row, verdict: 'invisible wall', worst_m: r3(c.box.x1 - c.box.x0), note: 'no drawn leg over the box' }); continue; }
    const mm = mismatch(c.box, base);
    rows.push({ ...row, drawn_base_m: [r3(base.x1 - base.x0), r3(base.y1 - base.y0)], mismatch_m: mm, ...verdict(mm, ['west', 'east', 'south']), note: 'leg foot: arch art columns over the box, lowest opaque row; N is the leg itself' });
  }
  return rows;
}

/** The drawn foot of an arch leg over `box` (m): opaque columns of the placed arch art within `pad` m of the box
 * whose lowest pixel falls in its depth (+ `pad` south), their x extent and lowest row. Null when none qualifies. */
export function footUnder(png, piece, box, pad = FOOT_PAD_M) {
  const kx = piece.size_m[0] / png.width;
  const ky = piece.size_m[1] / png.height;
  const left = piece.at[0] - piece.size_m[0] / 2;
  const top = piece.at[1] - piece.size_m[1] / 2;
  let x0 = Infinity, x1 = -Infinity, y1 = -Infinity;
  for (let x = Math.max(0, Math.floor((box.x0 - pad - left) / kx)); x < Math.min(png.width, Math.ceil((box.x1 + pad - left) / kx)); x++) {
    const col = opaqueBox(png, { x, y: 0, w: 1, h: png.height });
    if (!col) continue;
    const bottom = top + col.y1 * ky;
    if (bottom < box.y0 || bottom > box.y1 + pad) continue;
    x0 = Math.min(x0, left + x * kx); x1 = Math.max(x1, left + (x + 1) * kx); y1 = Math.max(y1, bottom);
  }
  return x1 > x0 ? { x0: r3(x0), x1: r3(x1), y0: r3(box.y0), y1: r3(y1) } : null;
}
