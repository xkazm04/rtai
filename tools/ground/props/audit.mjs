#!/usr/bin/env node
// n31-17 prop audit, data half: footprint (m) against the drawn base of the art, for the gauntlet
// street (gauntlet.json segments) and the prologue yard (prologue_yard_dressings.json, the stage's
// dressing). Reproduces gauntlet_prop_art.gd `cover` (flat card, foot on the box's south edge,
// size = min(art metres * scale, box - 0.04)) and prologue_yard_paint.gd `wreck` (art stretched
// into the footprint, optional crop). Usage: node tools/ground/props/audit.mjs [--out=<dir>]
import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path'; import { fileURLToPath } from 'node:url';
import { readPng } from '../../film/png.mjs';
import { auditYardStructures } from './yard_structures.mjs';

export const PX_PER_M = 48; // boot/collect_call/view/ink.gd
export const TOL_M = 0.25; export const ALPHA = 32; export const BAND_M = 0.15; // gauntlet base = the lowest 15 cm of opaque art
export const SOLID = ['wall_high', 'cover_high', 'cover_low'];
const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..', '..');
export const PROJECT = join(ROOT, 'project'); export const r3 = (v) => Math.round(v * 1000) / 1000;

/** Opaque bounding box {x0,y0,x1,y1} (px, x1/y1 exclusive) of a region, or null when nothing is opaque. */
export function opaqueBox(png, region = { x: 0, y: 0, w: png.width, h: png.height }, alpha = ALPHA) {
  const { width, channels, data } = png;
  let x0 = Infinity;
  let y0 = Infinity;
  let x1 = -1;
  let y1 = -1;
  let count = 0;
  for (let y = region.y; y < region.y + region.h; y++) {
    for (let x = region.x; x < region.x + region.w; x++) {
      const a = channels === 4 ? data[(y * width + x) * 4 + 3] : 255;
      if (a < alpha) continue;
      count++;
      if (x < x0) x0 = x;
      if (x > x1) x1 = x;
      if (y < y0) y0 = y;
      if (y > y1) y1 = y;
    }
  }
  if (x1 < 0) return null;
  return { x0, y0, x1: x1 + 1, y1: y1 + 1, fraction: count / (region.w * region.h) };
}

/** Footprint minus drawn base per side, metres; positive = footprint reaches beyond the drawing. */
export function mismatch(box, base) {
  return {
    west: r3(base.x0 - box.x0),
    east: r3(box.x1 - base.x1),
    north: r3(base.y0 - box.y0),
    south: r3(box.y1 - base.y1),
  };
}

export function verdict(mm, sides, tol = TOL_M) {
  const out = sides.filter((s) => Math.abs(mm[s]) > tol);
  if (!out.length) return { verdict: 'ok', worst_m: 0, sides: [] };
  const worst = Math.max(...out.map((s) => Math.abs(mm[s])));
  const outside = out.some((s) => mm[s] > 0);
  const over = out.some((s) => mm[s] < 0);
  const v = outside && over ? 'footprint and drawing differ' : outside ? 'invisible wall' : 'art overhangs passable';
  return { verdict: v, worst_m: r3(worst), sides: out };
}

/** Gauntlet cover card fitted into `box` (m): {drawn, base (m), cardH, clipped}. */
export function fitCard(png, box, scaleM) {
  const art = { w: png.width / PX_PER_M, h: png.height / PX_PER_M };
  const padW = box.x1 - box.x0 - 0.08;
  const padH = box.y1 - box.y0 - 0.08;
  const sw = Math.min(art.w * scaleM, padW);
  const sh = Math.min(art.h * scaleM, padH);
  const footX = (box.x0 + box.x1) / 2;
  const footY = box.y1 - 0.04;
  const drawn = { x0: footX - sw / 2, x1: footX + sw / 2, y0: footY - sh, y1: footY };
  const opaque = opaqueBox(png);
  if (!opaque) return null;
  const bandPx = Math.max(1, Math.round(BAND_M * PX_PER_M));
  const top = Math.max(opaque.y0, opaque.y1 - bandPx);
  const band = opaqueBox(png, { x: 0, y: top, w: png.width, h: opaque.y1 - top });
  const kx = sw / png.width;
  const ky = sh / png.height;
  const base = {
    x0: drawn.x0 + band.x0 * kx,
    x1: drawn.x0 + band.x1 * kx,
    y0: drawn.y0 + top * ky,
    y1: drawn.y0 + opaque.y1 * ky,
  };
  return { drawn, base, cardH: r3((opaque.y1 - opaque.y0) * ky), clipped: sw < art.w * scaleM - 1e-9 || sh < art.h * scaleM - 1e-9 };
}

export const rectOf = (at, size) => ({ x0: at[0] - size[0] / 2, x1: at[0] + size[0] / 2, y0: at[1] - size[1] / 2, y1: at[1] + size[1] / 2 });
const readJson = (rel) => JSON.parse(readFileSync(join(PROJECT, rel), 'utf8'));
export const load = (path) => {
  try {
    return readPng(path);
  } catch (e) {
    return { error: String(e.message || e) };
  }
};

export function auditGauntlet() {
  const rows = [];
  for (const seg of readJson('data/tables/gauntlet.json').segments) {
    const d = seg.dressing;
    seg.props.forEach((p, i) => {
      const size = p.size;
      const box = rectOf([0, 0], size);
      const row = { arena: 'gauntlet', id: `${seg.id}#${i}:${p.kind}`, segment: seg.id, kind: p.kind, class: SOLID.includes(p.kind) ? 'blocks movement + shots' : 'decorative', footprint_m: [size[0], size[1]] };
      if (p.kind === 'wall_high') return rows.push({ ...row, art: 'procedural coping/wing/edge, drawn to the footprint', verdict: 'ok', worst_m: 0 });
      if (d.landmark === 'barriers') return rows.push({ ...row, art: 'barricade.png inset 0.08 m on a hatched slab', verdict: 'ok', worst_m: 0 });
      if (d.landmark === 'viaduct' && p.kind === 'cover_high') return rows.push({ ...row, art: 'procedural pier, drawn to the footprint', verdict: 'ok', worst_m: 0 });
      const entry = p.kind === 'cover_high' ? 'high' : 'low';
      const art = d[entry];
      const scale = d[entry + '_scale'];
      const file = join(PROJECT, 'features/city/art/props', `${art}.png`);
      const png = existsSync(file) ? load(file) : { error: 'no flat png (strip-only art)' };
      if (png.error) return rows.push({ ...row, art, scale, verdict: 'unmeasured', note: png.error });
      const fit = fitCard(png, box, scale);
      const mm = mismatch(box, fit.base);
      const v = verdict(mm, ['west', 'east', 'south']);
      return rows.push({ ...row, art, scale, drawn_base_m: [r3(fit.base.x1 - fit.base.x0), 'front card, no floor depth'], card_height_m: fit.cardH, clipped_to_box: fit.clipped, mismatch_m: mm, ...v, note: 'north side not measurable (front-facing card); hatched slab marks the footprint' });
    });
    for (const f of d.fixtures) {
      const file = join(PROJECT, 'features/city/art/props', `${f.art}.png`);
      const png = existsSync(file) ? load(file) : { error: 'no flat png (strip-only art)' };
      const o = png.error ? null : opaqueBox(png);
      const high = o ? r3(((o.y1 - o.y0) / PX_PER_M) * f.scale) : null;
      rows.push({ arena: 'gauntlet', id: `${seg.id}:${f.art}@${f.at.join(',')}`, segment: seg.id, kind: 'fixture', class: 'decorative', art: f.art, standing_height_m: high, projected_shadow: 'unknown (card draw)', verdict: high === null ? 'unmeasured' : high > 0.5 ? 'decorative-looks-solid candidate' : 'ok', worst_m: 0 });
    }
  }
  return rows;
}

export function auditYard() {
  const table = readJson('data/tables/prologue_yard_dressings.json').dressings;
  const stage = readJson('data/tables/prologue_stage.json');
  const look = table[stage.yard.dressing];
  const rows = [];
  const shadowed = Boolean(look.shadows?.reach_m && (look.shadows.reach_m[0] || look.shadows.reach_m[1]));
  for (const c of look.layout.cover) {
    const box = rectOf(c.at, c.size_m);
    const row = { arena: 'yard', id: c.id, kind: 'cover_low', class: 'blocks movement + shots', footprint_m: c.size_m, art: c.art.split('/').pop(), projected_shadow: shadowed };
    const png = load(join(PROJECT, c.art.replace('res://', '')));
    if (png.error) { rows.push({ ...row, verdict: 'unmeasured', note: png.error }); continue; }
    const region = c.crop
      ? { x: Math.round(c.crop.origin[0] * png.width), y: Math.round(c.crop.origin[1] * png.height), w: Math.round(c.crop.size[0] * png.width), h: Math.round(c.crop.size[1] * png.height) }
      : { x: 0, y: 0, w: png.width, h: png.height };
    const o = opaqueBox(png, region);
    if (!o) { rows.push({ ...row, verdict: 'invisible wall', worst_m: Math.max(...c.size_m), note: 'art has no opaque pixel' }); continue; }
    const kx = (box.x1 - box.x0) / region.w;
    const ky = (box.y1 - box.y0) / region.h;
    const base = { x0: box.x0 + (o.x0 - region.x) * kx, x1: box.x0 + (o.x1 - region.x) * kx, y0: box.y0 + (o.y0 - region.y) * ky, y1: box.y0 + (o.y1 - region.y) * ky };
    const mm = mismatch(box, base);
    rows.push({ ...row, drawn_base_m: [r3(base.x1 - base.x0), r3(base.y1 - base.y0)], opaque_fraction: r3(o.fraction), mismatch_m: mm, ...verdict(mm, ['west', 'east', 'north', 'south']) });
  }
  const st = auditYardStructures(look, look.layout.cover.map((c) => ({ id: c.id, box: rectOf(c.at, c.size_m) })));
  const paired = new Set(st.filter((r) => r.id.includes(' vs ')).map((r) => r.id.split(' vs ')[0]));
  rows.splice(0, rows.length, ...rows.filter((r) => !paired.has(r.id)), ...st);
  const fxShadow = Boolean(look.shadows?.fixture_reach_m);
  for (const f of look.fixtures) {
    const height = f.size_m[1];
    rows.push({ arena: 'yard', id: f.art.split('/').pop().replace('.png', '') + '@' + f.at.join(','), kind: 'fixture', class: 'decorative', art: f.art.split('/').pop(), standing_height_m: height, projected_shadow: fxShadow, verdict: height > 0.5 && fxShadow ? 'decorative-looks-solid' : 'ok', worst_m: 0 });
  }
  for (const d of look.layout.debris.filter((x) => !/^(arch|span)_/.test(x.id))) rows.push({ arena: 'yard', id: d.id, kind: 'debris', class: 'decorative', art: d.art.split('/').pop(), projected_shadow: false, verdict: 'ok', worst_m: 0 });
  return rows;
}


export function summarize(rows) {
  const solid = rows.filter((r) => r.class.startsWith('blocks'));
  const bad = (r) => r.verdict !== 'ok' && r.verdict !== 'unmeasured';
  return {
    props: rows.length,
    solid: solid.length,
    solid_mismatch_over_0_25_m: solid.filter((r) => bad(r) && r.worst_m > TOL_M).length,
    solid_unmeasured: solid.filter((r) => r.verdict === 'unmeasured').length,
    decorative_looks_solid: rows.filter((r) => r.verdict.startsWith('decorative-looks-solid')).length,
    by_verdict: rows.reduce((m, r) => ({ ...m, [r.verdict]: (m[r.verdict] || 0) + 1 }), {}),
  };
}

export const worst = (rows, n = 10) => rows.filter((r) => r.verdict !== 'ok' && r.verdict !== 'unmeasured' && r.worst_m > 0).sort((a, b) => b.worst_m - a.worst_m).slice(0, n);

export function markdown(rows, sum) {
  const lines = ['# Prop audit before (n31-17, yard structures n31-18)', '', 'Gauntlet measured on the flat art (city/art/props PNG, 48 px/m); the tilt70 strip cards the game actually shows are NOT measured here. In the tilt70 stills (masters n31/ground/item4/audit_gauntlet_before.png) market stalls, kiosk and loading-bay props fill their footprint outline, so the gauntlet "invisible wall" rows below are flat-art numbers and need the strip-based probe (next call). The yard numbers read the art the yard really draws. The existing overlays (show_solid_bounds, --footprints) draw one thin white outline for every solid and do not label class. Tolerance 0.25 m. Mismatch = footprint minus drawn base per side in m (positive: the footprint reaches beyond the drawing). Gauntlet N is not measurable (front-facing card).', '', '```json', JSON.stringify(sum, null, 1), '```', '', '| arena | id | class | footprint m | drawn base m | W | E | N | S | verdict | worst m |', '|---|---|---|---|---|---|---|---|---|---|---|'];
  for (const r of rows) {
    const m = r.mismatch_m ?? {};
    const foot = r.footprint_m ? r.footprint_m.join('x') : r.standing_height_m != null ? 'h ' + r.standing_height_m : '';
    lines.push(`| ${r.arena} | ${r.id} | ${r.class} | ${foot} | ${r.drawn_base_m ? r.drawn_base_m.join(' x ') : ''} | ${m.west ?? ''} | ${m.east ?? ''} | ${m.north ?? ''} | ${m.south ?? ''} | ${r.verdict} | ${r.worst_m ?? ''} |`);
  }
  return lines.join('\n') + '\n';
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const arg = process.argv.find((a) => a.startsWith('--out='));
  const out = arg ? arg.slice(6) : join(ROOT, 'evidence/n31-ground');
  mkdirSync(out, { recursive: true });
  const rows = [...auditGauntlet(), ...auditYard()];
  const sum = summarize(rows);
  writeFileSync(join(out, 'prop_audit_before.json'), JSON.stringify({ schema: 'gtai.prop-audit/1', summary: sum, worst: worst(rows), rows }, null, 1));
  writeFileSync(join(out, 'prop_audit_before.md'), markdown(rows, sum));
  console.log(JSON.stringify(sum));
  for (const w of worst(rows, 15)) console.log(`${w.arena} ${w.id} ${w.verdict} ${w.worst_m} m ${JSON.stringify(w.mismatch_m ?? '')}`);
}
