import { test } from 'node:test';
import assert from 'node:assert/strict';
import { argumentsFor, frameWindow, checkTrace, engineErrors, otherGodotAtLaunch } from './polish_ghost_cost.mjs';
import { FRAMES, START } from '../film/ghost_films_plan.mjs';

const ticks = Array.from({ length: FRAMES }, (_, i) => START + i);
const doc = (tick, wall_ms) => ({ schema: 'gtai.fight-frames/1', tick, wall_ms });

test('launch records the last scan after at most 15 seconds or as soon as the machine clears', async () => {
  for (const [until, clears, elapsed, remaining] of [
    [60000, Infinity, 15000, 3], [60000, 3000, 3000, 0], [1200, Infinity, 1200, 3], [60000, 0, 0, 0],
  ]) {
    let time = 0;
    const count = await otherGodotAtLaunch(until, () => time < clears ? 3 : 0,
      () => time, async ms => { time += ms; });
    assert.equal(time, elapsed);
    assert.equal(count, remaining);
  }
});

test('frame statistics are over the same active ticks even when boot wall time differs', () => {
  const stats = frameWindow(doc([START - 1, ...ticks, START + FRAMES],
    [900, ...ticks.map((_, i) => i === 0 ? 26 : 2), 900]));
  assert.equal(stats.frames, FRAMES);
  assert.equal(stats.worst, 26);
  assert.equal(stats.over25, 1);
  assert.equal(stats.p50, 2);
  assert.equal(stats.p99, 2);
});

test('missing or repeated ticks and invalid clock samples invalidate a run', () => {
  assert.throws(() => frameWindow(doc(ticks.slice(1), ticks.slice(1))), /incomplete/);
  assert.throws(() => frameWindow(doc([ticks[1], ...ticks.slice(1)], ticks)), /incomplete/);
  assert.throws(() => frameWindow(doc(ticks, [NaN, ...ticks.slice(1)])), /incomplete/);
  assert.throws(() => frameWindow(doc(ticks, [])), /invalid/);
});

test('runs use the ghost look flag and a separate untimed trace with identical camera and take', () => {
  const args = argumentsFor('dent', 'legacy', 'C:\\test\\run.json', false);
  const trace = argumentsFor('dent', 'legacy', 'C:\\test\\verify.jsonl', true);
  assert.deepEqual(args.slice(0, -1), trace.filter(a => !a.startsWith('--shot')).slice(0, -1));
  assert.equal(args.at(-1), '--frames=C:/test/run.json');
  assert.equal(trace.at(-1), '--film-trace=C:/test/verify.jsonl');
  for (const arg of ['0,1440', '--windowed', 'd3d12', '--disable-vsync', '--fixed-fps',
    '--ghost=dent', '--ghost-look=legacy', '--take=move', '--ppm=32']) assert.ok(args.includes(arg));
});

test('exit disposal messages are preserved in logs without accepting frame or asset errors', () => {
  const bad = ['SCRIPT ERROR: broken', 'ERROR: missing texture', '[ERROR] ghost_review: bad flag'];
  assert.deepEqual(engineErrors([...bad, 'ERROR: 107 resources still in use at exit (run with --verbose for details).',
    'ERROR: Pages in use exist at exit in PagedAllocator: X'].join('\n')), bad);
});

test('the review trace proves form, scale, on-screen position and tick coverage', () => {
  const header = { schema: 'gtai.ghost-review/1', columns: ['tick', 'form', 'px_per_m', 'screen_x', 'screen_y'] };
  const rows = ticks.map(t => [t, 'tonnage', 32, 580, 250]);
  const trace = () => [header, ...rows].map(r => JSON.stringify(r)).join('\n');
  assert.equal(checkTrace(trace(), 'tonnage'), FRAMES);
  assert.throws(() => checkTrace(trace(), 'ohm'), /mismatch/);
  rows[20][3] = -1;
  assert.throws(() => checkTrace(trace(), 'tonnage'), /mismatch/);
  rows[20][3] = 10;
  rows[20][2] = 48;
  assert.throws(() => checkTrace(trace(), 'tonnage'), /mismatch/);
});
