import { createHash } from 'node:crypto';
import { readFileSync } from 'node:fs';

// node evidence/guard-wall/measure-street.mjs <FilmProbe probe.json>
// Shipped city base y=524 + station wall y=7 + half-thickness 0.30 + body radius 0.45.
const strip = JSON.parse(readFileSync(process.argv[2], 'utf8'));
const ids = [3001, 3002, 3003, 3004];
const rows = strip.rows.filter(row => row.tick >= 1 && row.tick <= 650);
if (rows.length !== 650 || rows.some((row, index) => row.tick !== index + 1)) {
  throw new Error('Expected one row for every tick 1 through 650.');
}
const trace = rows.map(row => [0, ...ids].map(id => {
  const f = row.fighters.find(fighter => fighter.id === id);
  if (!f?.alive) throw new Error(`Missing live fighter ${id} at tick ${row.tick}`);
  return [id, ...f.pos];
}));
const clearY = 531.75;
const guards = ids.map((id, index) => {
  const slot = index + 1;
  const crossing = trace.findIndex(tick => tick[slot][2] >= clearY);
  return {
    id,
    first_body_south_tick: crossing < 0 ? null : crossing + 1,
    crossing_pos_m: crossing < 0 ? null : trace[crossing][slot].slice(1),
    pos_at_650_m: trace.at(-1)[slot].slice(1)
  };
});
console.log(JSON.stringify({
  ticks: rows.length,
  body_south_y_m: clearY,
  sha256_positions: createHash('sha256').update(JSON.stringify(trace)).digest('hex'),
  rivet_at_650_m: trace.at(-1)[0].slice(1),
  body_south_at_650: guards.filter(g => g.pos_at_650_m[1] >= clearY).length,
  guards
}, null, 2));
