import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import test from 'node:test';
import { ROOT } from '../lib/repo.mjs';
import { flagReads, knownFlags, launchFlagsCheck, unknownReads } from '../style/launch_flags.mjs';

const ARGS = 'const KNOWN_FLAGS: PackedStringArray = [\n\t"--seed",\n\t# "--old" commented out\n\t"--feel",  # trailing "--note"\n]\n';

test('knownFlags reads the list literals and drops comments', () => {
  assert.deepEqual([...knownFlags(ARGS)].sort(), ['--feel', '--seed']);
  assert.equal(knownFlags('var x = 1\n'), null);
});

test('the real launch_args.gd parses, and holds the flags the game reads', () => {
  const known = knownFlags(readFileSync(join(ROOT, 'project/boot/launch_args.gd'), 'utf8'));
  for (const f of ['--seed', '--replay', '--reduced-motion', '--save-cross']) assert.ok(known.has(f), f);
});

test('flagReads: literals, a same-file const, both calls; comments and unresolved names skipped', () => {
  const src = [
    'const FLAG: String = "--impact-follow"',
    'var a: String = LaunchArgs.value("--seed")',
    'if LaunchArgs.has(FLAG):',
    '# LaunchArgs.value("--in-a-comment")',
    'var b: bool = LaunchArgs.has(OTHER)',
  ].join('\n');
  assert.deepEqual(flagReads(src), [
    { line: 2, call: 'value', flag: '--seed' },
    { line: 3, call: 'has', flag: '--impact-follow' },
  ]);
});

test('unknownReads names file:line of a read KNOWN_FLAGS lacks; tests are not judged', () => {
  const known = knownFlags(ARGS);
  const src = 'var on: bool = LaunchArgs.value("--impact-follow") != "off"\nvar s = LaunchArgs.value("--seed")\n';
  const issues = unknownReads([
    { path: 'project/features/combat/fx.gd', src },
    { path: 'project/tests/unit/test_x.gd', src },
  ], known);
  assert.equal(issues.length, 1);
  assert.match(issues[0], /^project\/features\/combat\/fx\.gd:1: LaunchArgs\.value\("--impact-follow"\) reads a flag not in KNOWN_FLAGS/);
});

test('launchFlagsCheck: red on a planted unknown read, green on the repo as it stands', () => {
  const planted = launchFlagsCheck(() => [{ path: 'project/dev/x.gd', src: 'LaunchArgs.has("--nope")' }]);
  assert.equal(planted.ok, false);
  assert.equal(planted.issues.length, 1);
  assert.deepEqual(launchFlagsCheck().issues, []);
});
