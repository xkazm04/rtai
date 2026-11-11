// node --test "tools/dev/*.test.mjs"
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { fileURLToPath } from 'node:url';
import { indexTexts, projectIndex, unreadFlags } from './flag_index.mjs';

const FIX = fileURLToPath(new URL('./fixtures', import.meta.url));
// The shapes the game reads flags in (cast_flags.gd, launch_args.gd, arena_args.gd).
const SRC = [
  'if arg == "--ghost-ohm-hand=sim":\n\tpass\nelif arg.begins_with("--ghost-"):\n\t_ghost(arg)',
  'elif arg.begins_with("--rivet-form="):\n\tform = arg.substr(13)\nvar out := LaunchArgs.value("--out")',
  'if arg == "--rivet-visor":\n\tpass',
];
const idx = indexTexts(SRC);

test('hero n15 FRICTION: --ohm-hand=sim is refused and pointed at --ghost-ohm-hand', () => {
  assert.deepEqual(unreadFlags(['--ohm-hand=sim'], idx),
    [{ arg: '--ohm-hand=sim', flag: '--ohm-hand', suggestion: '--ghost-ohm-hand' }]);
});

test('an exact read accepts only its own value; the suggestion is that value', () => {
  assert.deepEqual(unreadFlags(['--ghost-ohm-hand=sim'], idx), []);
  assert.deepEqual(unreadFlags(['--ghost-ohm-hand=snm'], idx),
    [{ arg: '--ghost-ohm-hand=snm', flag: '--ghost-ohm-hand=snm', suggestion: '--ghost-ohm-hand=sim' }]);
  assert.equal(unreadFlags(['--ghost-ohm-hand'], idx).length, 1, 'bare flag, only a valued read exists');
});

test('prefix and bare reads accept any value', () => {
  assert.deepEqual(unreadFlags(['--rivet-form=wide', '--out=C:/x/y', '--out', '--rivet-visor'], idx), []);
});

test('a family prefix ("--ghost-") never makes a longer name known', () => {
  assert.equal(unreadFlags(['--ghost-lunge=off'], idx).length, 1);
  assert.equal(unreadFlags(['--ghost-'], idx).length, 0);
});

test('non-flags and the bare -- are ignored', () => {
  assert.deepEqual(unreadFlags(['pit', '-x', '--'], idx), []);
});

test('the real project reads the flags the lanes film with, and unit-test fake args are not indexed', () => {
  const real = projectIndex();
  assert.deepEqual(unreadFlags(['--bot=pit', '--rivet-form=wide', '--rivet-walk=4'], real), []);
  assert.ok(!real.has('--foo'), 'the GUT optparse docs say "--foo": addons are not indexed');
  assert.ok(projectIndex(FIX).has('--bot'));
});
