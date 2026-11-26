import assert from 'node:assert/strict';
import { test } from 'node:test';
import { foeArgs } from './foes_capture.mjs';

test('foe probe args render the scene on d3d12 at 1080p on the secondary screen', () => {
  const args = foeArgs({ ppm: '64', subjects: 'swat', gaits: 'run', capture: '30', out: 'build/x' });
  assert.deepEqual(args.slice(0, 8), ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440',
    '--resolution', '1920x1080', 'res://dev/ground_n31/foe_lift_probe.tscn']);
  assert.ok(args.includes('--ppm=64') && args.includes('--subjects=swat') && args.includes('--gaits=run'));
  assert.ok(args.includes('--capture=30') && args.some((a) => a.startsWith('--out=') && !a.includes(String.fromCharCode(92))));
});

test('foe probe args refuse a missing out or a bad ppm', () => {
  assert.throws(() => foeArgs({}), /--out/);
  assert.throws(() => foeArgs({ out: 'x', ppm: '48' }), /ppm/);
});
