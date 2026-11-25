import test from 'node:test';
import assert from 'node:assert/strict';
import { overhang, parseArgs, table, verdict } from './foe_reach.mjs';

const foe = (id, trials) => ({ foe: id, weapon: 'x', authored_reach_m: 1.6, swing_starts_within_m: 2.2, hit_reach_centre_m: 2.2,
  drawn_tip_m: 1.6, drawn_source: 's', telegraph_ticks: 33, rivet_radius_m: 0.6, trials });

test('overhang reads the centre distance, the shield its forward run', () => {
  assert.ok(Math.abs(overhang(foe('riot_cop'), { centre_dist_m: 2.0, forward_m: 9 }) - 0.4) < 1e-9);
  assert.ok(Math.abs(overhang(foe('shield_robot'), { centre_dist_m: 9, forward_m: 2.0 }) - 0.4) < 1e-9);
});

test('verdict counts centre-past and body-past hits and ignores misses', () => {
  const v = verdict(foe('riot_cop', [
    { hit: false },
    { hit: true, mode: 'away', centre_dist_m: 1.5, lateral_m: 0, since_tell: 32 },
    { hit: true, mode: 'side', centre_dist_m: 2.0, lateral_m: 0.5, since_tell: 32 },
    { hit: true, mode: 'away', centre_dist_m: 2.3, lateral_m: 0, since_tell: 33 },
  ]));
  assert.equal(v.hits, 3);
  assert.equal(v.hits_centre_beyond_drawn_tip, 2);
  assert.equal(v.hits_body_beyond_drawn_tip, 1);
  assert.equal(v.max_centre_overhang_m, 0.7);
  assert.equal(v.hits_while_walking_sideways, 1);
});

test('table and args', () => {
  assert.equal(table([verdict(foe('riot_cop', []))]).trim().split('\n').length, 3);
  assert.equal(parseArgs(['--step=6']).step, 6);
  assert.throws(() => parseArgs(['--label=a/b']));
});
