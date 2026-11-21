import assert from 'node:assert/strict';
import { test } from 'node:test';
import { RUN_SCHEMA, validateRun } from './contract.mjs';

test('a retiring bonus pool can offer two ids, then one', () => {
  const run = { schema: RUN_SCHEMA, seed: 4, profile: 'expert', controls: 'wheel',
    wave_reached: 28, waves: [], mods: {} };
  const pick = (offered) => ({ ...run, picks: [{ wave: 25, offered, taken: 'a' }] });
  for (const offered of [['a'], ['a', 'b'], ['a', 'b', 'c']])
    assert.equal(validateRun(pick(offered)), null);
  for (const offered of [[], ['a', 'a'], ['a', 'b', 'c', 'd']])
    assert.match(validateRun(pick(offered)), /offered/);
});
