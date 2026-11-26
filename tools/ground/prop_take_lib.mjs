// Pure parts of tools/ground/prop_take.mjs (n31-21): the probe list for item 4 "what blocks", built from a
// rev's data tables and the prop audit rows (drawn base edges), and the stops table.
// Coordinates: yard = arena metres (y grows south); gauntlet = segment-local x (the probe adds the segment's start).
export const BAR_M = 0.25;
const r3 = (v) => Math.round(v * 1000) / 1000;
const rect = (at, size) => ({ x0: at[0] - size[0] / 2, x1: at[0] + size[0] / 2, y0: at[1] - size[1] / 2, y1: at[1] + size[1] / 2 });

/** The drawn base edge on the side of `box` that a walker meets, from an audit row's mismatch (footprint minus drawing).
 *  Side names the box side he walks at: W (walking east), E (west), N (south), S (north). */
export function drawnEdge(box, mm, side) {
  const m = mm ?? {};
  if (side === 'W') return r3(box.x0 + (m.west ?? 0));
  if (side === 'E') return r3(box.x1 - (m.east ?? 0));
  if (side === 'N') return r3(box.y0 + (m.north ?? 0));
  return r3(box.y1 - (m.south ?? 0));
}

const DIR = { W: [1, 0], E: [-1, 0], N: [0, 1], S: [0, -1] };

/** A stop probe walking at side `side` of `box` from `gap` metres out, along the box's centre line. */
export function stopProbe({ id, segment, box, mm, side, gap = 3.5, arena, ticks = 420, base = false }) {
  const dir = DIR[side];
  const cx = (box.x0 + box.x1) / 2;
  const cy = (box.y0 + box.y1) / 2;
  const start = side === 'W' ? [box.x0 - gap, cy] : side === 'E' ? [box.x1 + gap, cy] : side === 'N' ? [cx, box.y0 - gap] : [cx, box.y1 + gap];
  const edge = drawnEdge(box, mm, side);
  return { id: `${id} from ${side}`, prop: id, arena, ...(segment ? { segment } : {}), start: start.map(r3), dir, edge, box_edge: r3(side === 'W' ? box.x0 : side === 'E' ? box.x1 : side === 'N' ? box.y0 : box.y1), side, gap, hint: [box.x0, box.y0, box.x1, box.y1].map(r3), base, ticks, mode: 'stop' };
}

/** A pass probe: walk `dir` from `start` until the axis coordinate reaches `passTo`. */
export const passProbe = ({ id, prop, segment, start, dir, passTo, arena, ticks = 420, fixture = false }) =>
  ({ id, prop, arena, fixture, ...(segment ? { segment } : {}), start: start.map(r3), dir, pass_to: r3(passTo), edge: r3(passTo), ticks, mode: 'pass' });

const byId = (rows) => new Map(rows.map((r) => [r.id, r]));

/** The yard probes: 3 conveyors, the fuel vessel, 2 arches or spans (walk under), 2 debris rows. */
export function yardProbes(look, rows, base = false) {
  const A = byId(rows);
  const cover = new Map(look.layout.cover.map((c) => [c.id, c]));
  const debris = new Map(look.layout.debris.map((c) => [c.id, c]));
  const row = (id) => A.get(id) ?? A.get(`${id} vs ${id.replace(/^conveyor_/, 'arch_')}`);
  const stop = (id, side, gap) => { const c = cover.get(id); return stopProbe({ id, box: rect(c.at, c.size_m), mm: row(id)?.mismatch_m, side, gap, arena: 'yard', base }); };
  const under = (id, x, startY, toY) => passProbe({ id: `${id} walk under at x ${x}`, prop: id, start: [x, startY], dir: [0, -1], passTo: Math.max(toY, 1.2), arena: 'yard' });
  const across = (id, startX, y, dir, toX) => passProbe({ id: `${id} walk along`, prop: id, start: [startX, y], dir: [dir, 0], passTo: toX, arena: 'yard' });
  const arch = debris.get('arch_feed');
  const span = debris.get('span_door_feed');
  return [
    stop('conveyor_door', 'S', 4.5), stop('conveyor_turn', 'W', 4), stop('conveyor_return', 'E', 5),
    stop('fuel_vessel', 'N', 3.2),
    under('arch_feed', arch.at[0] + 3.9, arch.at[1] + arch.size_m[1] / 2 + 1.0, arch.at[1]),
    under('span_door_feed', span.at[0] + 3.6, span.at[1] + span.size_m[1] / 2 + 3.2, span.at[1]),
    across('drag_door', debris.get('drag_door').at[0] - 4, debris.get('drag_door').at[1], 1, debris.get('drag_door').at[0] + 2.5),
    across('belt_feed', debris.get('belt_feed').at[0] + 4.3, debris.get('belt_feed').at[1], -1, debris.get('belt_feed').at[0] - 2.5),
  ];
}

/** The gauntlet probes from gauntlet.json segments: kiosk, 2 stalls, 1 low cover, 2 standing fixtures. */
export function gauntletProbes(segments, strips, base = false) {
  const S = byId(strips);
  const seg = (id) => segments.find((s) => s.id === id);
  const prop = (sid, i) => { const p = seg(sid).props[i]; return { id: `${sid}#${i}:${p.kind}`, box: rect(p.at, p.size) }; };
  const cover = (sid, i, side, gap = 3.5) => { const p = prop(sid, i); return stopProbe({ id: p.id, segment: sid, box: p.box, mm: S.get(p.id)?.mismatch_m, side, gap, arena: 'gauntlet', base }); };
  const fixture = (sid, art) => {
    const f = seg(sid).dressing.fixtures.find((x) => x.art === art);
    return passProbe({ id: `${sid}:${art}@${f.at.join(',')} walk at it`, prop: art, segment: sid, start: [f.at[0], f.at[1] + 3.6], dir: [0, -1], passTo: f.at[1], arena: 'gauntlet', fixture: true });
  };
  return [
    cover('kiosk_plaza', 2, 'W'), cover('kiosk_plaza', 2, 'E'),
    cover('market_stalls', 3, 'W'), cover('market_stalls', 6, 'E'),
    cover('plain_block', 3, 'W'),
    fixture('plain_block', 'payphone'), fixture('plain_block', 'street_sign'),
  ];
}

/** The bar for one probe. A stop probe passes when |m - radius| <= BAR_M, m = base_m (the visible base pad, when the rev draws
 *  one) else stop_m (the art). A pass probe passes when he walked through; a fixture behind the street's wall is n/a. */
export function judge(p, s) {
  if (s.verdict === undefined || s.verdict === 'not run' || s.verdict === 'unreached') return { bar: 'unmeasured', on: '' };
  if (p.mode === 'pass') return s.verdict === 'passed' ? { bar: 'pass', on: 'walked through' } : p.fixture ? { bar: 'n/a', on: 'behind the building wall' } : { bar: 'FAIL', on: 'blocked' };
  if (s.verdict !== 'stopped') return { bar: 'FAIL', on: s.verdict };
  const r = s.radius_m ?? 0.6;
  const onBase = p.base && s.box_m !== undefined && s.box_m !== null;
  const m = onBase ? s.box_m : s.stop_m;
  return { bar: Math.abs(m - r) <= BAR_M + 1e-9 ? 'pass' : 'FAIL', on: onBase ? 'base_m' : 'stop_m' };
}

/** stops.json rows + probes -> markdown table. stop_m: metres from Rivet's ground point to the drawn art's base edge, signed
 *  in the walking direction (negative: he stopped inside the drawing; positive: short of it, an invisible wall).
 *  base_m: the same to the visible base pad (the collision box edge) where the rev draws a PropBase. */
export function stopsMarkdown(title, probes, stops) {
  const S = byId(stops);
  const radii = [...new Set(stops.map((s) => s.radius_m).filter((x) => x !== undefined))];
  const lines = [`# ${title}`, '', `Rivet radius ${radii.length ? radii.join(' / ') : 'unmeasured'} m (read from the sim body in this take). stop_m = distance from his ground point to the drawn art's base edge along his heading (negative: inside the drawing, positive: invisible wall); base_m = the same to the visible base pad (the collision box edge) where the rev draws one. A perfect stop reads +radius; the bar is |m - radius| <= ${BAR_M} m on base_m where there is a pad, else on stop_m. pass = he walked through.`, '', '| probe | expect | verdict | stop_m | base_m | radius | walked m | bar (judged on) | reading | placed from |', '|---|---|---|---|---|---|---|---|---|---|'];
  for (const p of probes) {
    const s = S.get(p.id) ?? { verdict: 'not run' };
    const j = judge(p, s);
    const base = p.base && s.box_m !== undefined && s.box_m !== null ? s.box_m : '';
    const reading = s.verdict === 'passed' ? 'passed through' : s.verdict === 'unreached' ? 'segment not streamed' : s.stop_m === undefined ? '' : s.stop_m < -0.1 ? 'stopped INSIDE the drawing' : s.stop_m > (s.radius_m ?? 0.6) + BAR_M ? 'invisible wall, short of the art' : 'at the drawn edge';
    lines.push(`| ${p.id} | ${p.mode === 'pass' ? 'pass' : 'stop'} | ${s.verdict} | ${s.stop_m ?? ''} | ${base} | ${s.radius_m ?? ''} | ${s.walked_m ?? ''} | ${j.bar} (${j.on}) | ${reading} | ${s.placed ?? ''} |`);
  }
  return `${lines.join('\n')}\n`;
}
