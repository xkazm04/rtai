// node --test "tools/dev/*.test.mjs"
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { fileURLToPath } from 'node:url';
import { didYouMean, readFixedFps, readRunTicks, readSpec, resolve } from './entries.mjs';

const FIX = fileURLToPath(new URL('./fixtures', import.meta.url));

test('arena: the scene goes before -- and the flags after it (lanes left the scene out)', () => {
  const r = resolve('arena', ['--bot=pit']);
  assert.ok(r.ok, r.error);
  assert.equal(r.kind, 'scene');
  const a = r.godotArgs;
  const sep = a.indexOf('--');
  const scene = a.indexOf('res://dev/arena/arena.tscn');
  assert.ok(scene >= 0 && scene < sep, a.join(' '));
  assert.ok(a.indexOf('--bot=pit') > sep, a.join(' '));
});

test('arena on the real tree declares no spec: no flag check, the note says so', () => {
  const r = resolve('arena', ['--bto=pit']);
  assert.ok(r.ok, r.error);
  assert.equal(r.spec, null);
  assert.deepEqual(r.problems, []);
  assert.equal(r.specNote, 'flags unchecked: no declared spec');
});

test('a declared KNOWN_FLAGS const is read and a near miss gets a did-you-mean', () => {
  const r = resolve('arena_args.gd', ['--bto=pit', '--ppm=48'], { projectDir: FIX });
  assert.ok(r.ok, r.error);
  assert.equal(r.kind, 'script');
  assert.deepEqual(r.spec, ['--bot', '--ppm', '--out']);
  assert.deepEqual(r.problems, [{ arg: '--bto=pit', flag: '--bto', suggestion: '--bot' }]);
  assert.match(r.specNote, /flags checked: 2 against KNOWN_FLAGS/);
});

test('a declared RUN_TICKS derives --fixed-fps 60 --quit-after 900', () => {
  const r = resolve('reel.gd', [], { projectDir: FIX });
  assert.ok(r.ok, r.error);
  const s = r.godotArgs.join(' ');
  assert.ok(s.includes('--fixed-fps 60'), s);
  assert.ok(s.includes('--quit-after 900'), s);
  assert.equal(r.godotArgs.slice(0, 2).join(' '), '-s res://reel.gd');
});

test('an explicit --quit-after=20000 is kept, not overridden', () => {
  const r = resolve('reel.gd', ['--quit-after=20000'], { projectDir: FIX });
  const s = r.godotArgs.join(' ');
  assert.ok(s.includes('--quit-after 20000'), s);
  assert.ok(!s.includes('900'), s);
  assert.ok(!r.userArgs.includes('--quit-after=20000'));
});

test('a stray -- is a separator, not a user arg; args after it pass verbatim', () => {
  const r = resolve('reel.gd', ['--', '--quit-after=5'], { projectDir: FIX });
  assert.deepEqual(r.userArgs, ['--quit-after=5']);
  assert.ok(r.godotArgs.join(' ').includes('--quit-after 900'));
});

test('an unknown entry fails with one line', () => {
  const r = resolve('no_such_entry_xyz');
  assert.equal(r.ok, false);
  assert.match(r.error, /no dev entry named no_such_entry_xyz/);
});

test('readSpec: KNOWN or KNOWN_FLAGS, multi-line, comments ignored; none -> null', () => {
  assert.deepEqual(readSpec('const KNOWN: PackedStringArray = ["--a", "--b"]\n').flags, ['--a', '--b']);
  const multi = 'const KNOWN_FLAGS: PackedStringArray = [\n\t"--a",  # "--not"\n\t"--b"\n]\n';
  assert.deepEqual(readSpec(multi).flags, ['--a', '--b']);
  assert.equal(readSpec('var x: int = 1\n'), null);
});

test('readRunTicks: an int literal only', () => {
  assert.equal(readRunTicks('const RUN_TICKS: int = 900\n'), 900);
  assert.equal(readRunTicks('const RUN_TICKS: int = 12 * SimClock.TICK_RATE\n'), null);
});

test('didYouMean: nearest within two edits, else null', () => {
  assert.equal(didYouMean('--bto', ['--bot', '--out']), '--bot');
  assert.equal(didYouMean('--zzzzzz', ['--bot']), null);
});

test('a declared FIXED_FPS adds --fixed-fps alone; the caller can still override it', () => {
  const r = resolve('film_scene.gd', [], { projectDir: FIX });
  assert.ok(r.ok, r.error);
  const s = r.godotArgs.join(' ');
  assert.ok(s.includes('--fixed-fps 30'), s);
  assert.ok(!s.includes('--quit-after'), s);
  const o = resolve('film_scene.gd', ['--fixed-fps=60'], { projectDir: FIX }).godotArgs.join(' ');
  assert.ok(o.includes('--fixed-fps 60') && !o.includes('--fixed-fps 30'), o);
});

test('FIXED_FPS is read only as a positive literal', () => {
  assert.equal(readFixedFps('const FIXED_FPS: int = 60  # films every tick\n'), '60');
  assert.equal(readFixedFps('const FIXED_FPS: int = 0\n'), null);
  assert.equal(readFixedFps('const FIXED_FPS: int = SimClock.TICK_RATE\n'), null);
  assert.equal(readFixedFps('# const FIXED_FPS: int = 60\n'), null);
});
