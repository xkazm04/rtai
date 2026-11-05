// Lane n7-king: writes project/data/tables/bosses.json and its schema canonically
// (sorted keys, 2-space, LF). Run from the worktree root: node evidence/king/write_bosses.mjs
import { writeFileSync } from 'node:fs';
import { canonicalJson } from '../../tools/lib/canonical_json.mjs';

const P = 'project/data/';
const king = {
  arena: 'king_boulevard',
  doc: 'Act 1: REG-1 the press king on his gilded throne-car (targets-2026-11-05-bosses/img/boss_king.jpg). Moveset: docs/bosses/king.md.',
  hp: 120,
  move_mps: 2.2,
  radius_m: 1.1,
  rng: 'boss_king',
  script: 'res://features/bosses/king/king_moves.gd',
  phases: [
    { id: 'procession', hp_below: 1.0, attacks: ['ram', 'coin_fan'], gap_s: 1.2, transition_s: 0,
      doc: 'The throne-car rams down the boulevard; the hood cannon sprays coins; the gang rides along.' },
    { id: 'court', hp_below: 0.66, attacks: ['coin_fan', 'decree'], gap_s: 1.4, transition_s: 2.5,
      adds: { archetype: 'robot_thug', count: 4, every_s: 14 },
      doc: 'The car is wrecked; the gang leaps off to brawl; King shouts decrees that buff the gang.' },
    { id: 'on_foot', hp_below: 0.33, attacks: ['press_slam', 'charge', 'coin_fan'], gap_s: 0.9, transition_s: 2.5,
      doc: 'King steps down: press-plate slams that shower coins, and a charge.' },
  ],
  attacks: {
    ram: { shape: 'charge', windup_s: 1.3, aim_lock_s: 0.45, active_s: 1.4, recovery_s: 1.6, punish_s: 1.2, punish_k: 1.5,
      cooldown_s: 3.5, damage: 30, range_m: 22, width_m: 3.2, move_mps: 15, min_m: 5, max_m: 40, weight: 3,
      doc: 'Engine rev and headlights flare, the car backs up, then rams along the locked line; it skids to a stop and the gang has to push.' },
    coin_fan: { shape: 'cone', windup_s: 1.1, aim_lock_s: 0.5, active_s: 0.6, recovery_s: 0.9, punish_s: 0.6, punish_k: 1.25,
      cooldown_s: 2.5, damage: 14, range_m: 13, arc_deg: 36, min_m: 0, max_m: 16, weight: 2,
      doc: 'The hood cannon swings to Rivet and glows; the cone locks and a hail of coins sprays the fan.' },
    decree: { shape: 'none', windup_s: 1.2, aim_lock_s: 0, active_s: 0.5, recovery_s: 1.8, punish_s: 1.8, punish_k: 1.5,
      cooldown_s: 9, damage: 0, range_m: 0, min_m: 0, max_m: 99, weight: 1,
      doc: 'King raises the megaphone and shouts a decree: the gang hits harder and faster for a while. Long recovery: the best punish window.' },
    press_slam: { shape: 'circle', windup_s: 1.1, aim_lock_s: 0.35, active_s: 0.25, recovery_s: 1.3, punish_s: 1.0, punish_k: 1.5,
      cooldown_s: 2.0, damage: 28, range_m: 2.5, radius_m: 3.2, min_m: 0, max_m: 6, weight: 3,
      doc: 'Both press plates rise over the head (ring drawn on the floor), then slam: a shockwave ring that showers coins.' },
    charge: { shape: 'charge', windup_s: 1.0, aim_lock_s: 0.35, active_s: 0.9, recovery_s: 1.4, punish_s: 1.0, punish_k: 1.5,
      cooldown_s: 4.0, damage: 24, range_m: 10, width_m: 2.0, move_mps: 11, min_m: 4, max_m: 18, weight: 2,
      doc: 'He drops his shoulder, cape flares, then barrels along the locked line.' },
  },
};
const table = {
  schema: 'gtai.bosses/1',
  doc: "Act bosses as data (lane n7-king framework). A boss: hp, phases (entered by hp fraction), attacks with a tell (windup_s, aim_lock_s), an active window, a recovery whose first punish_s takes punish_k damage. Interface: n7-king JOURNAL REQUEST 1. One boss's special case lives in its script (features/bosses/<id>/), never here.",
  bosses: { king },
  arenas: {
    king_boulevard: { area: 'pit', boss_at: [10, 0], rivet_at: [-8, 0], add_spawns: [[12, -8], [12, 8], [-12, -8], [-12, 8]],
      doc: "King's district: a long boulevard for the procession, its plaza for phases 2-3 (first pass: the arena pit)." },
  },
};

const num = (min, max) => ({ type: 'number', minimum: min, maximum: max });
const doc = { type: 'string', minLength: 1 };
const id = { type: 'string', pattern: '^[a-z][a-z0-9_]*$' };
const adds = { type: 'object', additionalProperties: false, required: ['archetype', 'count'],
  properties: { archetype: id, count: { type: 'integer', minimum: 1, maximum: 12 }, every_s: num(0, 120) } };
const attack = { type: 'object', additionalProperties: false,
  required: ['shape', 'windup_s', 'aim_lock_s', 'active_s', 'recovery_s', 'punish_s', 'punish_k', 'cooldown_s', 'damage', 'range_m', 'min_m', 'max_m', 'weight', 'doc'],
  properties: { shape: { enum: ['charge', 'circle', 'cone', 'line', 'none'] }, windup_s: num(0.4, 5), aim_lock_s: num(0, 2),
    active_s: num(0.05, 10), recovery_s: num(0.2, 10), punish_s: num(0, 10), punish_k: num(1, 4), cooldown_s: num(0, 60),
    damage: num(0, 100), range_m: num(0, 60), width_m: num(0.2, 10), arc_deg: num(5, 360), radius_m: num(0.5, 20),
    move_mps: num(0, 40), min_m: num(0, 100), max_m: num(0, 100), weight: num(0, 10), adds, doc } };
const phase = { type: 'object', additionalProperties: false, required: ['id', 'hp_below', 'attacks', 'gap_s', 'transition_s', 'doc'],
  properties: { id, hp_below: num(0, 1), attacks: { type: 'array', minItems: 1, items: id }, gap_s: num(0, 10),
    transition_s: num(0, 10), adds, doc } };
const boss = { type: 'object', additionalProperties: false, required: ['arena', 'hp', 'move_mps', 'radius_m', 'rng', 'phases', 'attacks', 'doc'],
  properties: { arena: id, hp: num(1, 100000), move_mps: num(0, 20), radius_m: num(0.3, 6), rng: id,
    script: { type: 'string', pattern: '^res://features/bosses/[a-z0-9_]+/[a-z0-9_]+\\.gd$' },
    phases: { type: 'array', minItems: 1, items: { $ref: '#/$defs/phase' } },
    attacks: { type: 'object', additionalProperties: { $ref: '#/$defs/attack' } }, doc } };
const vec = { type: 'array', minItems: 2, items: { type: 'number' } };
const arena = { type: 'object', additionalProperties: false, required: ['area', 'boss_at', 'rivet_at', 'add_spawns', 'doc'],
  properties: { area: id, boss_at: vec, rivet_at: vec, add_spawns: { type: 'array', items: vec }, doc } };
const schema = { $id: 'gtai.bosses/1', type: 'object', additionalProperties: false, required: ['schema', 'doc', 'bosses', 'arenas'],
  $defs: { attack, phase, boss, arena },
  properties: { schema: { const: 'gtai.bosses/1' }, doc, bosses: { type: 'object', additionalProperties: { $ref: '#/$defs/boss' } },
    arenas: { type: 'object', additionalProperties: { $ref: '#/$defs/arena' } } } };

writeFileSync(P + 'tables/bosses.json', canonicalJson(table));
writeFileSync(P + 'schemas/bosses.schema.json', canonicalJson(schema));
