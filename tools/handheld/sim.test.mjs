import { test } from 'node:test';
import assert from 'node:assert/strict';
import { affinityMask, deviceRow, gpuIndexFrom, parseArgs, projectDir } from './sim.mjs';

test('affinity mask covers the first n logical CPUs', () => {
  assert.equal(affinityMask(8), '255');
  assert.equal(affinityMask(3), '7');
  assert.equal(affinityMask(16), '65535');
});

test('the integrated Radeon is found in the verbose device list', () => {
  const log = 'Devices:\n  #0: NVIDIA NVIDIA GeForce RTX 4090 - Supported, Discrete\n  #1: AMD AMD Radeon(TM) Graphics - Supported, Discrete\n';
  assert.equal(gpuIndexFrom(log, 'igpu'), 1);
  assert.equal(gpuIndexFrom(log, 'dgpu'), 0);
});

test('a dashed device id finds its row; args split at --', () => {
  assert.equal(deviceRow('switch-handheld').sim_threads, 3);
  const a = parseArgs(['--device=deck40', '--ticks=600', '--no-device', '--', '--ppm=48']);
  assert.deepEqual([a.device, a.ticks, a.noDevice, a.extra], ['deck40', 600, true, ['--ppm=48']]);
});

const BACKSLASH = String.fromCharCode(92);

test('--project picks another checkout, else this one', () => {
  assert.match(projectDir(parseArgs(['--project=C:/x/scratch/project'])).replaceAll(BACKSLASH, '/'), /scratch\/project$/);
  assert.match(projectDir(parseArgs([])).replaceAll(BACKSLASH, '/'), /d9-handheld\/project$|\/project$/);
});
