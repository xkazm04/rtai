// Lane n7-servo: puts Servo's row (bosses.servo) and his arena (arenas.depot) into
// project/data/tables/bosses.json, leaving every other row as it is (n7-king owns the table and
// its schema). Run from the worktree root: node evidence/servo/write_servo_row.mjs
// Design: docs/bosses/servo.md. Servo-only swarm numbers live in data/tables/servo.json.
import { readFileSync, writeFileSync } from 'node:fs';
import { canonicalJson } from '../../tools/lib/canonical_json.mjs';

const PATH = 'project/data/tables/bosses.json';
const servo = {
  arena: 'depot',
  doc: 'Act 2: Servo, the courier-hub robot whose back is a launch rack of delivery drones (targets-2026-11-05-bosses/img/boss_servo.jpg). Moveset: docs/bosses/servo.md. The drones, parcels and rack are his own (features/bosses/servo/, data/tables/servo.json).',
  hp: 4200,
  move_mps: 2.0,
  radius_m: 1.6,
  rng: 'boss_servo',
  script: 'res://features/bosses/servo/servo_moves.gd',
  phases: [
    { id: 'depot', hp_below: 1.0, attacks: ['scan_drop', 'rotor_dash'], gap_s: 1.0, transition_s: 0,
      doc: 'Teaches the loop: the scanner marks Rivet, a drone wave drops on the mark, the rack docks (punish), the rotor dash.' },
    { id: 'rush_hour', hp_below: 0.65, attacks: ['scan_drop', 'package_carpet', 'bay_hop', 'rotor_dash'], gap_s: 0.8, transition_s: 2.0,
      doc: 'The conveyor starts and the bay doors roll up; bigger waves, package carpets in lanes, Servo hops between loading bays.' },
    { id: 'overtime', hp_below: 0.3, attacks: ['kamikaze', 'rotor_dash_hot', 'scan_drop'], gap_s: 0.6, transition_s: 2.0,
      doc: 'Half the rack blows off; drones kamikaze; Servo dashes often and overheats (long vent: the biggest punish).' },
  ],
  attacks: {
    scan_drop: { shape: 'line', windup_s: 1.6, aim_lock_s: 0.4, active_s: 0.3, recovery_s: 2.6, punish_s: 2.0, punish_k: 1.5,
      cooldown_s: 1.5, damage: 0, range_m: 24, width_m: 0.6, min_m: 3, max_m: 24, weight: 3,
      doc: 'The visor beam sweeps, tracks Rivet (thin), locks (thick) and stamps a vermilion mark on his spot; the beam itself does not hurt. The wave launches on the stamp and drops on the mark during the recovery: the dock window is the punish.' },
    rotor_dash: { shape: 'charge', windup_s: 0.9, aim_lock_s: 0.35, active_s: 0.75, recovery_s: 1.2, punish_s: 1.0, punish_k: 1.5,
      cooldown_s: 3.0, damage: 30, range_m: 14, width_m: 2.4, move_mps: 22, min_m: 4, max_m: 18, weight: 2,
      doc: 'The pads spin up (dust ring, the lane arrow tracks Rivet, locks), then a 14 m dash at 22 m/s; a skid and vent after.' },
    package_carpet: { shape: 'none', windup_s: 1.4, aim_lock_s: 0.4, active_s: 0.3, recovery_s: 2.6, punish_s: 2.0, punish_k: 1.5,
      cooldown_s: 5.0, damage: 0, range_m: 20, min_m: 0, max_m: 30, weight: 2,
      doc: 'Drones form a line and fly a lane across the yard dropping a carpet of parcels; the lane is painted first; the gap is safe.' },
    bay_hop: { shape: 'none', windup_s: 1.2, aim_lock_s: 0.4, active_s: 0.2, recovery_s: 1.0, punish_s: 1.0, punish_k: 1.25,
      cooldown_s: 6.0, damage: 20, range_m: 3, min_m: 0, max_m: 30, weight: 1,
      doc: 'Rotors lift Servo to the loading bay nearest Rivet; the 3 m landing ring fills during the tell; the landing hurts inside it.' },
    kamikaze: { shape: 'none', windup_s: 0.8, aim_lock_s: 0.3, active_s: 0.2, recovery_s: 1.2, punish_s: 0.8, punish_k: 1.25,
      cooldown_s: 3.0, damage: 0, range_m: 20, min_m: 0, max_m: 30, weight: 3,
      doc: 'The broken rack spits sparking drones that each draw a dive line at Rivet, lock and dive (their blasts are the damage).' },
    rotor_dash_hot: { shape: 'charge', windup_s: 0.8, aim_lock_s: 0.3, active_s: 0.75, recovery_s: 2.5, punish_s: 2.2, punish_k: 2.0,
      cooldown_s: 1.2, damage: 30, range_m: 14, width_m: 2.4, move_mps: 22, min_m: 3, max_m: 18, weight: 3,
      doc: 'Overtime: the dash comes often but overheats Servo into a 2.5 s vent (steam, glowing pads): the fight\'s biggest punish.' },
  },
};
const depot = { area: 'pit', boss_at: [9, 0], rivet_at: [-8, 0], add_spawns: [],
  doc: 'The CS courier depot: loading bays, a conveyor and stacked CS crates, room for the drones (first pass: the arena pit).' };

const table = JSON.parse(readFileSync(PATH, 'utf8'));
table.bosses.servo = servo;
table.arenas.depot = depot;
writeFileSync(PATH, canonicalJson(table));
