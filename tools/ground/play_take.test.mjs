import assert from 'node:assert/strict';
import { test } from 'node:test';
import { encodeArgs, godotArgs, labelOf, parseArgv, sampleFrames, sideArgs, stillArgs, SCENES } from './play_take_lib.mjs';

const good = ['--rev=HEAD', '--seed=7', '--ticks=2400', '--out=build/x'];

test('defaults: gauntlet, 32 px/m, average bot, from 0', () => {
  const { flags } = parseArgv(good);
  assert.equal(flags.ppm, '32');
  assert.equal(flags.bot, 'average');
  assert.equal(flags.from, '0');
});

test('refuses bad input', () => {
  for (const bad of [['--rev=HEAD'], [...good, '--ppm=48'], [...good, '--bot=human'], [...good, '--scene=quest1'], [...good, '--from=2400'], [...good, '--seed=-1'], [...good, '--nope=1'], ['--side=a', '--out=x']]) {
    assert.ok(parseArgv(bad).error, bad.join(' '));
  }
});

test('godot args: owner mode flags after the scene, movie, fixed 60', () => {
  const a = godotArgs({ scene: SCENES[64], avi: 'a.avi', ticks: 99, seed: 7, bot: 'average' });
  const dash = a.indexOf('--');
  assert.deepEqual(a.slice(dash), ['--', '--pick-view', '--bot=average', '--controls=wheel', '--seed=7']);
  assert.equal(a[dash - 1], 'res://dev/ground_n31/gauntlet_64.tscn');
  const text = a.join(' ');
  assert.ok(text.includes('--fixed-fps 60') && text.includes('--write-movie a.avi') && text.includes('--position 0,1440'));
});

test('ffmpeg: encode trims from the tick, h264 crf 23 yuv420p; stills pick one frame', () => {
  const e = encodeArgs('a.avi', 'a.mp4', 120).join(' ');
  assert.match(e, /trim=start_frame=120,setpts=PTS-STARTPTS,format=yuv420p/);
  assert.match(e, /-crf 23/);
  assert.match(stillArgs('a.avi', 5, 'p.png').join(' '), /start_frame=5:end_frame=6/);
  assert.deepEqual(sampleFrames(0, 2400), [600, 1200, 1800]);
});

test('side: stacks two crops to 1920x1080 with both labels', () => {
  const h = sideArgs('a.mp4', 'b.mp4', 'o.mp4', ['main ba8e470b0', 'HEAD abc'], 'h').join(' ');
  assert.match(h, /crop=960:1080/);
  assert.match(h, /hstack/);
  assert.match(h, /main ba8e470b0/);
  assert.match(sideArgs('a', 'b', 'o', ['x', 'y'], 'v').join(' '), /crop=1920:540.*vstack/);
});

test('label: a hash alone, a name with its hash', () => {
  assert.equal(labelOf('ba8e470b0', 'ba8e470b0aaaaaaa'), 'ba8e470b0');
  assert.equal(labelOf('HEAD', 'ba8e470b0aaaaaaa'), 'HEAD ba8e470b0');
});

test('wave-timeout is passed to the gauntlet scene only when given', () => {
  const base = { scene: SCENES[32], avi: 'a.avi', ticks: 99, seed: 7, bot: 'average' };
  assert.ok(!godotArgs(base).some((x) => x.startsWith('--wave-timeout')));
  assert.ok(godotArgs({ ...base, waveTimeout: '5' }).includes('--wave-timeout=5'));
  assert.equal(parseArgv(['--rev=HEAD', '--seed=7', '--ticks=9', '--out=o', '--wave-timeout=5']).flags['wave-timeout'], '5');
});
