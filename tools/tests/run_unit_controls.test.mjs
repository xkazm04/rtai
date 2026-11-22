import assert from 'node:assert/strict';
import test from 'node:test';
import { gutEnv, parseArgs, UsageError } from './run_unit.mjs';

for (const mode of ['wheel', 'legacy']) {
  test(`GUT receives ${mode} through its environment`, () => {
    const { controls } = parseArgs([`--controls=${mode}`]);
    assert.equal(controls, mode);
    assert.equal(gutEnv(controls).GTAI_CONTROLS, mode);
  });
}

test('the default GUT invocation omits a controls override', () => {
  assert.equal(gutEnv(parseArgs([]).controls).GTAI_CONTROLS, '');
});

test('unsupported or missing controls values are usage errors', () => {
  for (const arg of ['--controls=foo', '--controls=', '--controls']) {
    assert.throws(() => parseArgs([arg]), UsageError);
  }
});
