// n31 melee 01a: the summary of blade_volume's per-weapon results (gtai.blade-volume/1), pure.

/** [min, max] of a tick list, or null when empty. */
export function span(ks) {
  if (!ks || ks.length === 0) return null;
  return [Math.min(...ks), Math.max(...ks)];
}

const fmtSpan = (s) => (s ? (s[0] === s[1] ? `${s[0]}` : `${s[0]}..${s[1]}`) : '-');

/** The mover trials folded: per lag and direction, hit / drawn, plus the drawn-no-hit count. */
export function moverSummary(movers) {
  const out = { trials: movers.length, hit: 0, drawn: 0, drawn_no_hit: 0, hit_not_drawn: 0, rows: [] };
  for (const m of movers) {
    out.hit += m.hit ? 1 : 0;
    out.drawn += m.drawn ? 1 : 0;
    out.drawn_no_hit += m.drawn && !m.hit ? 1 : 0;
    out.hit_not_drawn += m.hit && !m.drawn ? 1 : 0;
    out.rows.push({ lag: m.lag, dir: m.dir, hit: m.hit, drawn: m.drawn, drawn_ks: m.drawn_ks });
  }
  return out;
}

/** One weapon's row: counts over the ring, tick windows, the mover fold. */
export function weaponRow(r) {
  const ring = r.ring;
  const lateDrawn = r.cells.filter((c) => c.drawn && !c.hit && c.drawn_ks.some((k) => k > r.land_k)).length;
  return {
    weapon: r.weapon,
    weapon_id: r.weapon_id,
    cells: r.cells.length,
    drawn_no_hit: ring.drawn_no_hit,
    hit_not_drawn: ring.hit_not_drawn,
    both: ring.both,
    neither: ring.neither,
    drawn_no_hit_after_test: lateDrawn,
    hit_test_ks: r.land_ks.length ? r.land_ks : [r.land_k],
    cut_window: span(r.cut_ks),
    shown_window: span(r.shown_ks),
    overlap_window: span(r.overlap_ks),
    pixel_window: span(r.pixel_ks),
    reach_m: r.reach_m,
    cone_dot: r.cone_dot,
    mover: moverSummary(r.movers),
  };
}

export function summarize(results, meta = {}) {
  return { schema: 'gtai.blade-volumes/1', ...meta, weapons: results.map(weaponRow) };
}

/** The per-weapon markdown table. */
export function table(summary) {
  const head = '| weapon | drawn-no-hit /60 | of them drawn after the test | hit-not-drawn /60 | both | hit test k | cut drawn k | blade/crescent shown k | overlaps drawn k | mover hit / drawn / drawn-no-hit (of 14) | blade in strip pixels only k |';
  const rule = '|---|---|---|---|---|---|---|---|---|---|---|';
  const rows = summary.weapons.map((w) => `| ${w.weapon} (${w.weapon_id}) | ${w.drawn_no_hit} | ${w.drawn_no_hit_after_test} | ${w.hit_not_drawn} | ${w.both} | ${w.hit_test_ks.join(', ')} | ${fmtSpan(w.cut_window)} | ${fmtSpan(w.shown_window)} | ${fmtSpan(w.overlap_window)} | ${w.mover.hit} / ${w.mover.drawn} / ${w.mover.drawn_no_hit} | ${fmtSpan(w.pixel_window)} |`);
  return [head, rule, ...rows].join('\n') + '\n';
}

/** 01c: the per-weapon markdown table of the pixel drawn side (gtai.blade-volumes/2). */
export function pixelTable(summary) {
  const head = '| weapon | drawn-no-hit /60 | of them drawn after the test | hit-not-drawn /60 | both | hit test k | cut k (clip) | drawn mask k | overlaps drawn k | mover hit / drawn / drawn-no-hit (of 14) |';
  const rule = '|---|---|---|---|---|---|---|---|---|---|';
  const rows = summary.weapons.map((w) => `| ${w.weapon} (${w.weapon_id}) | ${w.drawn_no_hit} | ${w.drawn_no_hit_after_test} | ${w.hit_not_drawn} | ${w.both} | ${w.hit_test_ks.join(', ')} | ${fmtSpan(w.cut_window)} | ${fmtSpan(w.drawn_window)} | ${fmtSpan(w.overlap_window)} | ${w.mover.hit} / ${w.mover.drawn} / ${w.mover.drawn_no_hit} |`);
  return [head, rule, ...rows].join('\n') + '\n';
}
