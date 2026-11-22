import assert from 'node:assert/strict';
import test from 'node:test';
import { gutArgs, parseArgs, UsageError } from './run_unit.mjs';

for (const mode of ['wheel', 'legacy']) {
  test(`GUT receives ${mode} as a Godot user argument`, () => {
    const { controls } = parseArgs([`--controls=${mode}`]);
    assert.equal(controls, mode);
    assert.deepEqual(gutArgs('config', 'junit', controls).slice(-3),
      ['-gjunit_xml_file=junit', '--', `--controls=${mode}`]);
  });
}

test('the default GUT invocation omits a controls override', () => {
  assert.ok(!gutArgs('config', 'junit', parseArgs([]).controls).includes('--'));
});

test('unsupported or missing controls values are usage errors', () => {
  for (const arg of ['--controls=foo', '--controls=', '--controls']) {
    assert.throws(() => parseArgs([arg]), UsageError);
  }
});
