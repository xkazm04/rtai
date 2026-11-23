import assert from 'node:assert/strict';
import test from 'node:test';
import { ROOT } from '../lib/repo.mjs';
import { checkId, godotArgs, parseShot } from './shots.mjs';

test('melee shot uses its click scene on the film display and selects the actual weapon', () => {
  for (const id of ['hands', 'chainsaw', 'electro_baton', 'katana', 'plasma_sword']) {
    assert.equal(checkId('melee', id, ROOT), null);
    const shot = parseShot(`melee:${id}`);
    const args = godotArgs(shot, { ticks: 90, stills: [], extra: [], lock: 'spawn' });
    assert.match(args[args.indexOf('--') - 1], /melee_click\.tscn$/);
    assert.equal(args[args.indexOf('--position') + 1], '0,1440');
    assert.deepEqual(shot.shot.flags(id), id === 'hands' ? [] : [`--loadout=${id}`]);
  }
  assert.match(checkId('melee', 'pistol', ROOT), /unknown melee/);
});
