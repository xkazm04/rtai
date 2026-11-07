import { test } from 'node:test';
import assert from 'node:assert/strict';
import { frameStats, low1Fps, medianSpread, pacing, quantile, verdict } from './stats.mjs';
import { readLog } from './ab.mjs';

test('quantile is nearest rank on a sorted copy', () => {
  const a = [5, 1, 4, 2, 3];
  assert.equal(quantile(a, 0.5), 3);
  assert.equal(quantile(a, 0.99), 5);
  assert.deepEqual(a, [5, 1, 4, 2, 3]);
  assert.ok(Number.isNaN(quantile([], 0.5)));
});

test('1 % low is 1000 over the mean of the worst 1 %', () => {
  const a = Array(99).fill(10).concat([40]);
  assert.equal(low1Fps(a), 25);
});

test('pacing reads the spread between consecutive frames, not the level', () => {
  assert.deepEqual(pacing([10, 10, 10]), { p50: 0, p99: 0, max: 0 });
  assert.equal(pacing([10, 30, 10]).max, 20);
});

test('frameStats counts hitches over 25 and 50 ms', () => {
  const s = frameStats([10, 26, 51, 10]);
  assert.equal(s.over25, 2);
  assert.equal(s.over50, 1);
  assert.equal(s.worst, 51);
});

test('a difference inside the noise is a WASH, beyond it a WIN or LOSS', () => {
  assert.equal(verdict([10, 11, 12], [10.5, 11, 11.5]).call, 'WASH');
  assert.equal(verdict([10, 10.2, 10.1], [8, 8.1, 8.2]).call, 'WIN');
  assert.equal(verdict([10, 10.2, 10.1], [12, 12.1, 12.2]).call, 'LOSS');
  assert.equal(verdict([10, 10.2, 10.1], [12, 12.1, 12.2], { lowerIsBetter: false }).call, 'WIN');
});

test('medianSpread ignores non-finite runs', () => {
  assert.deepEqual(medianSpread([1, NaN, 3]), { median: 3, spread: 2, n: 2 });
});

test('a fight log drops its first second of wall time', () => {
  const doc = { wall_ms: [600, 500, 10, 12], draw_calls: [1, 1, 100, 200], render_cpu_ms: [0, 0, 1, 3] };
  const log = readLog('fight', doc);
  assert.deepEqual(log.wall, [10, 12]);
  assert.equal(log.side.draws, 150);
  assert.equal(log.side.renderCpu, 2);
});

test('a bench log carries the render GPU ms from its metrics', () => {
  const doc = { frame_ms: [5, 6], metrics: { drawCallsAvg: 300, renderCpuMsAvg: 0.2, renderGpuMsAvg: 1.5 } };
  const log = readLog('bench', doc);
  assert.deepEqual(log.wall, [5, 6]);
  assert.equal(log.side.renderGpu, 1.5);
});

test('procStats: steady CPU in cores after the boot samples, peak working set in MB', async () => {
  const { procStats } = await import('./ab.mjs');
  const row = (t, cpu, ws) => JSON.stringify({ t, cpu100ns: cpu, ws, threads: 30, procs: 2 });
  const text = [row(0, 0, 1048576), row(1000, 9e6, 2 * 1048576), row(2000, 1e7, 1048576),
    row(3000, 2e7, 1048576), row(5000, 4e7, 3 * 1048576)].join('\r\n');
  const s = procStats(text, 3);
  assert.equal(s.cpuCores, 1); // 2e7 x 100 ns = 2000 ms of CPU over 2000 ms of wall
  assert.equal(s.peakWsMb, 3);
  assert.ok(Number.isNaN(procStats(row(0, 0, 1), 3).cpuCores));
});
