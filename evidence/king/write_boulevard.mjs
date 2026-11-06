// Lane n7-king: King's boulevard in the dev arena (area + the boss station's props). Run from the
// worktree root: node evidence/king/write_boulevard.mjs. Rect [x, y, w, h] in metres from the hub.
import { readFileSync, writeFileSync } from 'node:fs';
import { canonicalJson } from '../../tools/lib/canonical_json.mjs';

const R = [60, -30, 80, 30];
const cx = R[0] + R[2] / 2;
const cy = R[1] + R[3] / 2;
const arenaPath = 'project/data/tables/arena.json';
const arena = JSON.parse(readFileSync(arenaPath, 'utf8'));
arena.areas = arena.areas.filter((a) => a.id !== 'boulevard');
arena.areas.push({ id: 'boulevard', name: "KING'S BOULEVARD", rect: R });
writeFileSync(arenaPath, canonicalJson(arena));

const props = [];
// Planters (low cover) along both kerbs, every 12 m, leaving a 20 m clear street.
for (let x = R[0] + 8; x <= R[0] + R[2] - 20; x += 12) {
  props.push({ at: [x, cy - 12], kind: 'cover_low', size: [2.4, 0.8] });
  props.push({ at: [x, cy + 12], kind: 'cover_low', size: [2.4, 0.8] });
}
// The centre line (paint, stops nothing).
for (let x = R[0] + 4; x <= R[0] + R[2] - 4; x += 6) props.push({ at: [x, cy], kind: 'lane_mark', size: [2.6, 0.25] });
// The plaza: two statue plinths (high cover) at the east end.
props.push({ at: [R[0] + R[2] - 10, cy - 6], kind: 'cover_high', size: [1.6, 1.6] });
props.push({ at: [R[0] + R[2] - 10, cy + 6], kind: 'cover_high', size: [1.6, 1.6] });

const stPath = 'project/data/tables/arena_stations/bosses.json';
const st = JSON.parse(readFileSync(stPath, 'utf8'));
const s = st.stations.find((x) => x.id === 'boss_fight');
s.area = 'boulevard';
s.props = props;
s.doc = "A boss fight on the arena floor: --boss=king jumps straight in (the boss and Rivet stand at the boss arena record). King's boulevard: planters along both kerbs, a painted centre line, two plinths in the plaza at the east end.";
writeFileSync(stPath, canonicalJson(st));
console.log(`boulevard ${R} centre ${cx},${cy}: ${props.length} props`);
