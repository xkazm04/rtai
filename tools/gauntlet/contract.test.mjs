import assert from 'node:assert/strict';
import { test } from 'node:test';
import { RUN_SCHEMA, validateRun } from './contract.mjs';

test('HP is optional and all five nonnegative measurements travel together', () => {
  const wave = { n: 1 };
  const run = { schema: RUN_SCHEMA, seed: 1, profile: 'average', controls: 'wheel',
    wave_reached: 1, waves: [wave], picks: [], mods: {} };
  assert.equal(validateRun(run), null);
  wave.hp = { start: 100, min: 0, end: 0, max: 100, repaired: 0 };
  assert.equal(validateRun(run), null);
  for (const field of Object.keys(wave.hp)) {
    const hp = { ...wave.hp };
    delete hp[field];
    assert.match(validateRun({ ...run, waves: [{ ...wave, hp }] }), /waves\[0\]\.hp/);
  }
  wave.hp.repaired = -1;
  assert.match(validateRun(run), /waves\[0\]\.hp/);
});

test('a retiring bonus pool can offer two ids, then one', () => {
  const run = { schema: RUN_SCHEMA, seed: 4, profile: 'expert', controls: 'wheel',
    wave_reached: 28, waves: [], mods: {} };
  const pick = (offered) => ({ ...run, picks: [{ wave: 25, offered, taken: 'a' }] });
  for (const offered of [['a'], ['a', 'b'], ['a', 'b', 'c']])
    assert.equal(validateRun(pick(offered)), null);
  for (const offered of [[], ['a', 'a'], ['a', 'b', 'c', 'd']])
    assert.match(validateRun(pick(offered)), /offered/);
});
