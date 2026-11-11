// Picks the fighter a verdict is about from a tick of FilmProbe numbers.

/** The id of the first hostile to die in a probe (alive the tick before the first kill, dead on it), or null. */
export function killedId(probe) {
  const kill = probe?.events?.kill?.[0];
  if (!Number.isInteger(kill)) return null;
  const at = (t) => probe.rows?.find((r) => r.tick === t)?.fighters ?? [];
  const alive = new Set(at(kill - 1).filter((f) => f.role === 'hostile' && f.alive).map((f) => f.id));
  return at(kill).find((f) => f.role === 'hostile' && !f.alive && alive.has(f.id))?.id ?? null;
}

/** `--subject=kill` (kills-new n16 REQUEST: `dead` was off screen for every signature kill): the first kill's
 *  victim. A signature death hides his rig (draw -1, the probe's screen point is then not his), so without a
 *  card he is placed from the sim: Rivet's screen point plus the metres between them at `ppm`. */
function killRow(list, ctx) {
  const id = killedId(ctx?.probe);
  const f = id === null ? null : list.find((x) => x.id === id);
  const r = list.find((x) => x.role === 'rivet');
  if (!f || f.draw?.[0] > 0 || !r || !(ctx?.ppm > 0)) return f ?? null;
  const screen = [r.screen[0] + (f.pos[0] - r.pos[0]) * ctx.ppm, r.screen[1] + (f.pos[1] - r.pos[1]) * ctx.ppm];
  const [w, h] = ctx.view ?? [1280, 800];
  return { ...f, screen, placed: 'sim', on_screen: screen[0] >= 0 && screen[1] >= 0 && screen[0] < w && screen[1] < h };
}

/** The subject's probe row at a tick, or null when the probe has no such fighter. `ctx` ({probe, ppm, view})
 *  is needed by `kill` only. */
export function subjectRow(row, subject, ctx = null) {
  const list = Array.isArray(row?.fighters) ? row.fighters : [];
  if (subject === 'rivet') return list.find((f) => f.role === 'rivet') ?? null;
  if (subject === 'hostile') return list.find((f) => f.role === 'hostile' && f.alive && f.on_screen) ?? list.find((f) => f.role === 'hostile' && f.alive) ?? null;
  if (subject === 'dead') return list.find((f) => f.role === 'hostile' && f.alive === false && f.on_screen) ?? list.find((f) => f.role === 'hostile' && f.alive === false) ?? null;
  if (subject === 'kill') return killRow(list, ctx);
  const id = Number(subject.slice(3));
  return list.find((f) => f.id === id) ?? null;
}
