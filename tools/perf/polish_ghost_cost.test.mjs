import { test } from 'node:test';
import assert from 'node:assert/strict';
import { argumentsFor, frameWindow, checkTrace } from './polish_ghost_cost.mjs';
import { FRAMES, START } from '../film/ghost_films_plan.mjs';

const ticks = Array.from({ length: FRAMES }, (_, i) => START + i);
const doc = (tick, wall_ms) => ({ schema: 'gtai.fight-frames/1', tick, wall_ms });

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
  assert.deepEqual(args.slice(0, -1), trace.slice(0, -1));
  assert.equal(args.at(-1), '--frames=C:/test/run.json');
  assert.equal(trace.at(-1), '--film-trace=C:/test/verify.jsonl');
  for (const arg of ['0,1440', '--windowed', 'd3d12', '--disable-vsync', '--fixed-fps',
    '--ghost=dent', '--ghost-look=legacy', '--take=move', '--ppm=32']) assert.ok(args.includes(arg));
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
