// Picks the fighter a verdict is about from a tick of FilmProbe numbers.

/** The subject's probe row at a tick, or null when the probe has no such fighter. */
export function subjectRow(row, subject) {
  const list = Array.isArray(row?.fighters) ? row.fighters : [];
  if (subject === 'rivet') return list.find((f) => f.role === 'rivet') ?? null;
  if (subject === 'hostile') return list.find((f) => f.role === 'hostile' && f.alive && f.on_screen) ?? list.find((f) => f.role === 'hostile' && f.alive) ?? null;
  if (subject === 'dead') return list.find((f) => f.role === 'hostile' && f.alive === false && f.on_screen) ?? list.find((f) => f.role === 'hostile' && f.alive === false) ?? null;
  const id = Number(subject.slice(3));
  return list.find((f) => f.id === id) ?? null;
}
