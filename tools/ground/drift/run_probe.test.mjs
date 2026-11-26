import { test } from 'node:test';
import assert from 'node:assert/strict';
import { probeArgs } from './run_probe.mjs';

test('the probe renders on the secondary screen at 1080p, d3d12, fixed 60 fps', () => {
  const a = probeArgs('res://dev/ground_n31/drift_probe.tscn', 'C:/out', ['--bot=pilot']);
  assert.deepEqual(a.slice(0, 2), ['--rendering-driver', 'd3d12']);
  assert.equal(a[a.indexOf('--position') + 1], '0,1440');
  assert.equal(a[a.indexOf('--resolution') + 1], '1920x1080');
  assert.equal(a[a.indexOf('--fixed-fps') + 1], '60');
});

test('user flags and the result dir go after the scene and the separator', () => {
  const a = probeArgs('res://x.tscn', 'C:/out', ['--clip=play']);
  const cut = a.indexOf('--');
  assert.equal(a[cut - 1], 'res://x.tscn');
  assert.deepEqual(a.slice(cut + 1), ['--clip=play', '--result=C:/out']);
});
