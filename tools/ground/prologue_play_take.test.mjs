import { test } from 'node:test';
import assert from 'node:assert/strict';
import { godotArgs, parse, OVERRIDE } from './prologue_play_take.mjs';

test('parse needs a rev and an out dir and takes whole numbers', () => {
  assert.ok(parse(['--rev=HEAD']).error);
  assert.ok(parse(['--rev=HEAD', '--out=x', '--ppm=a']).error);
  assert.deepEqual(parse(['--rev=HEAD', '--out=x']).f, { ppm: '32', limit: '2700', from: '1140', rev: 'HEAD', out: 'x' });
});

test('the movie is a window override, not a viewport override (the stretch stays on)', () => {
  assert.match(OVERRIDE, /window_width_override=1920/);
  assert.doesNotMatch(OVERRIDE, /viewport_width/);
});

test('godot args write a movie on the secondary screen and pass the probe flags after the separator', () => {
  const a = godotArgs({ avi: 'a.avi', ppm: '64', from: '2150', limit: '2700', result: 'C:/o' });
  assert.equal(a[a.indexOf('--position') + 1], '0,1440');
  assert.ok(a.includes('--write-movie'));
  assert.deepEqual(a.slice(a.indexOf('--') + 1), ['--bot', '--clip=64:2150:2700', '--result=C:/o']);
});
