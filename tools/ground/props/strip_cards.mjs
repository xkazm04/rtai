#!/usr/bin/env node
// n31-18: the gauntlet cover as the tilt70 strip card GauntletPropArt.cover really draws, not the flat art.
// Reproduces GauntletPropArt (_face strip cell 0, cell_w_m_<art> or cell_w_m, height / ground_k, the cell trimmed
// to its used rect, size = min(metres * scale, box - 0.04 pad), foot on the box's south edge) and marks each row
// the flat audit flagged "invisible wall" as confirmed / not confirmed. Usage: node tools/ground/props/strip_cards.mjs [--art=p70] [--out=<dir>]
import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { auditGauntlet, opaqueBox, mismatch, verdict, load, rectOf, r3, PROJECT, BAND_M, TOL_M, SOLID } from './audit.mjs';

const FACINGS = 5;
const facades = JSON.parse(readFileSync(join(PROJECT, 'data/tables/city_facades.json'), 'utf8'));

/** Strip card `name` at view art `art` (p70), cell 0, fitted into `box` (m) at `scale`; null when the table has no card. */
export function fitStrip(name, box, scale, art = 'p70') {
  const row = facades.props[name];
  if (!row) return null;
  const file = [art, facades.art_fallback[art] ?? art].map((k) => join(PROJECT, row.art.replace('<art>', k).replace('res://', ''))).find(existsSync);
  const png = file ? load(file) : { error: 'no strip' };
  if (png.error) return null;
  const cw = Math.floor(png.width / FACINGS);
  const used = opaqueBox(png, { x: 0, y: 0, w: cw, h: png.height }, 1);
  if (!used) return null;
  const gk = Math.sin((Number(art.slice(1)) * Math.PI) / 180);
  const wM = row['cell_w_m_' + art] ?? row.cell_w_m;
  const cell = { w: wM, h: (wM * png.height) / cw / gk };
  const pad = { w: box.x1 - box.x0 - 0.08, h: box.y1 - box.y0 - 0.08 };
  const sw = Math.min(cell.w * scale, pad.w);
  const sh = Math.min(cell.h * scale, pad.h);
  const foot = [(box.x0 + box.x1) / 2, box.y1 - 0.04];
  const drawn = { x0: foot[0] - sw / 2, x1: foot[0] + sw / 2, y0: foot[1] - sh, y1: foot[1] };
  const uw = used.x1 - used.x0;
  const uh = used.y1 - used.y0;
  const bandPx = Math.max(1, Math.round((BAND_M / sh) * uh));
  const band = opaqueBox(png, { x: used.x0, y: used.y1 - bandPx, w: uw, h: bandPx }, 1);
  const base = { x0: drawn.x0 + ((band.x0 - used.x0) / uw) * sw, x1: drawn.x0 + ((band.x1 - used.x0) / uw) * sw, y0: drawn.y1 - (bandPx / uh) * sh, y1: drawn.y1 };
  const natural = { w: cell.w * scale * (uw / cw), h: cell.h * scale * (uh / png.height) };
  return { drawn, base, body_w_m: r3(sw), body_fills_box_width: sw >= pad.w - 0.01, card_h_m: r3(sh), stretch: r3(sw / uw / (sh / uh) / (cell.w / cw / (cell.h / png.height))), clipped_to_box: sw < cell.w * scale - 1e-9 || sh < cell.h * scale - 1e-9, natural_trim_m: [r3(natural.w), r3(natural.h)] };
}

export function auditStrips(art = 'p70') {
  const flat = new Map(auditGauntlet().map((r) => [r.id, r]));
  const rows = [];
  for (const seg of JSON.parse(readFileSync(join(PROJECT, 'data/tables/gauntlet.json'), 'utf8')).segments) {
    const d = seg.dressing;
    seg.props.forEach((p, i) => {
      if (!SOLID.includes(p.kind) || p.kind === 'wall_high' || d.landmark === 'barriers' || (d.landmark === 'viaduct' && p.kind === 'cover_high')) return;
      const id = `${seg.id}#${i}:${p.kind}`;
      const key = p.kind === 'cover_high' ? 'high' : 'low';
      const box = rectOf([0, 0], p.size);
      const fit = fitStrip(d[key], box, d[key + '_scale'], art);
      const was = flat.get(id);
      if (!fit) { rows.push({ id, art: d[key], footprint_m: p.size, flat_verdict: was.verdict, verdict: 'unmeasured', note: 'no strip card, flat art draws' }); return; }
      const mm = mismatch(box, fit.base);
      const v = verdict(mm, ['west', 'east', 'south']);
      const flagged = was.verdict === 'invisible wall' && was.worst_m > TOL_M;
      rows.push({ id, art: d[key], footprint_m: p.size, drawn_base_m: [r3(fit.base.x1 - fit.base.x0)], body_w_m: fit.body_w_m, body_fills_box_width: fit.body_fills_box_width, card_h_m: fit.card_h_m, stretch: fit.stretch, clipped_to_box: fit.clipped_to_box, mismatch_m: mm, ...v, flat_verdict: was.verdict, flat_worst_m: was.worst_m, flagged_by_flat: flagged, confirmation: flagged ? (v.verdict === 'invisible wall' && v.worst_m > TOL_M ? 'confirmed' : 'not confirmed') : '' });
    });
  }
  return rows;
}

export function stripMarkdown(rows, art) {
  const out = [`# Gauntlet strip-card audit (n31-18, view art ${art})`, '', 'Same fit as GauntletPropArt.cover: strip cell 0, width cell_w_m, height / sin(pitch), trimmed to the opaque cell, size = min(card * scale, box - 0.08), foot on the box south edge. Mismatch = box minus drawn lowest-15 cm base per side (m, positive = box reaches beyond the art). `stretch` is the drawn aspect over the art aspect (1 = undistorted; the trim is stretched into the box-clipped rect). The base is only the lowest 15 cm of art: `body w` is the whole card width (above the base the art is usually wider, which is why a still shows the prop filling its outline while the base mismatch reads 0.3-0.6 m). Tolerance 0.25 m; N is not measurable (front card).', '', '| id | art | footprint | base w | body w | card h | stretch | W | E | S | strip verdict | flat verdict (worst) | flagged row |', '|---|---|---|---|---|---|---|---|---|---|---|---|---|'];
  for (const r of rows) out.push(`| ${r.id} | ${r.art} | ${r.footprint_m.join('x')} | ${r.drawn_base_m ?? ''} | ${r.body_w_m ?? ''}${r.body_fills_box_width ? ' (fills box)' : ''} | ${r.card_h_m ?? ''} | ${r.stretch ?? ''} | ${r.mismatch_m?.west ?? ''} | ${r.mismatch_m?.east ?? ''} | ${r.mismatch_m?.south ?? ''} | ${r.verdict} ${r.worst_m ?? ''} | ${r.flat_verdict} ${r.flat_worst_m ?? ''} | ${r.confirmation} |`);
  return out.join('\n') + '\n';
}

if (process.argv[1] && resolve(process.argv[1]) === resolve(new URL(import.meta.url).pathname.replace(/^\/(\w:)/, '$1'))) {
  const art = (process.argv.find((a) => a.startsWith('--art=')) ?? '--art=p70').slice(6);
  const o = process.argv.find((a) => a.startsWith('--out='));
  const out = o ? o.slice(6) : join(PROJECT, '..', 'evidence/n31-ground');
  mkdirSync(out, { recursive: true });
  const rows = auditStrips(art);
  writeFileSync(join(out, 'prop_audit_strip.json'), JSON.stringify({ schema: 'gtai.prop-audit-strip/1', art, rows }, null, 1));
  writeFileSync(join(out, 'prop_audit_strip.md'), stripMarkdown(rows, art));
  const flagged = rows.filter((r) => r.flagged_by_flat);
  console.log(JSON.stringify({ solid_cards: rows.length, flagged_by_flat: flagged.length, confirmed: flagged.filter((r) => r.confirmation === 'confirmed').length, not_confirmed: flagged.filter((r) => r.confirmation === 'not confirmed').length, strip_invisible_wall: rows.filter((r) => r.verdict === 'invisible wall').length, unmeasured: rows.filter((r) => r.verdict === 'unmeasured').length }));
  for (const r of rows) if (r.flagged_by_flat) console.log(`${r.id} ${r.confirmation} strip ${r.verdict} ${r.worst_m} flat ${r.flat_worst_m}`);
}
