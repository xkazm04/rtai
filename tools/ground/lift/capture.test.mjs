import assert from 'node:assert/strict';
import { test } from 'node:test';
import { probeArgs } from './capture.mjs';

test('probe args render on d3d12 on the secondary screen and pass the probe flags', () => {
  const args = probeArgs({ weapon: 'pistol', pitch: 'p55', gaits: 'sprint', ppm: '64', out: 'build/x' });
  assert.deepEqual(args.slice(0, 6), ['--rendering-driver', 'd3d12', '--position', '0,1440', '-s',
    'res://dev/ground_n31/lift_probe.gd']);
  assert.ok(args.includes('--weapon=pistol') && args.includes('--pitch=p55') && args.includes('--ppm=64'));
  assert.ok(args.at(-1).startsWith('--out=') && !args.at(-1).includes(String.fromCharCode(92)));
});

test('probe args refuse a missing out or an unknown pitch', () => {
  assert.throws(() => probeArgs({}), /--out/);
  assert.throws(() => probeArgs({ out: 'x', pitch: 'top' }), /pitch/);
  assert.throws(() => probeArgs({ out: 'x', ppm: '48' }), /ppm/);
});
