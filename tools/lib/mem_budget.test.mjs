import { after, test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { waitForBudget } from './mem_budget.mjs';

const dir = mkdtempSync(join(tmpdir(), 'membudget-'));
after(() => rmSync(dir, { recursive: true, force: true }));
const status = (o = {}) => JSON.stringify({ name: 't', capMB: 8192, usedMB: 1000, peakMB: 1000, procs: 1,
  ts: new Date().toISOString(), pid: 1, done: false, ...o });
const put = (name, text) => { const f = join(dir, name); writeFileSync(f, text); return f; };
const quiet = () => {};

test('no env: immediate', async () => {
  const lines = [];
  const r = await waitForBudget({ estMB: 1200, env: {}, log: (l) => lines.push(l) });
  assert.equal(r.waitedS, 0);
  assert.deepEqual(lines, []);
});

test('missing file: immediate', async () => {
  const r = await waitForBudget({ estMB: 1200, env: { GTAI_CAP_STATUS: join(dir, 'nope.json') }, log: quiet });
  assert.equal(r.waitedS, 0);
});

test('stale ts: immediate even when over budget', async () => {
  const f = put('stale.json', status({ usedMB: 8000, ts: new Date(Date.now() - 120_000).toISOString() }));
  const r = await waitForBudget({ estMB: 1200, env: { GTAI_CAP_STATUS: f }, log: quiet });
  assert.equal(r.waitedS, 0);
});

test('done: immediate', async () => {
  const f = put('done.json', status({ usedMB: 8000, done: true }));
  const r = await waitForBudget({ estMB: 1200, env: { GTAI_CAP_STATUS: f }, log: quiet });
  assert.equal(r.waitedS, 0);
});

test('BOM-prefixed JSON parses and a fitting launch is immediate', async () => {
  const f = put('bom.json', '﻿' + status({ usedMB: 100 }));
  const lines = [];
  await waitForBudget({ estMB: 1200, env: { GTAI_CAP_STATUS: f }, log: (l) => lines.push(l) });
  assert.deepEqual(lines, []);
});

test('BOM-prefixed JSON over budget waits (proves it was parsed)', async () => {
  const f = put('bom2.json', '﻿' + status({ usedMB: 7000 }));
  const lines = [];
  let n = 0;
  await waitForBudget({ estMB: 1200, env: { GTAI_CAP_STATUS: f }, log: (l) => lines.push(l), pollMs: 1,
    sleep: async () => { if (++n === 2) writeFileSync(f, status({ usedMB: 100 })); } });
  assert.match(lines[0], /^mem-budget: waiting for 1200 MB \(7000\/6554 MB used\) before launch$/);
});

test('over budget then under: waits, logs once, returns', async () => {
  const f = put('wait.json', status({ usedMB: 7000 }));
  const lines = [];
  let n = 0;
  const r = await waitForBudget({ estMB: 1200, label: 'check x', env: { GTAI_CAP_STATUS: f }, log: (l) => lines.push(l),
    pollMs: 1, sleep: async () => { if (++n === 3) writeFileSync(f, status({ usedMB: 2000 })); } });
  assert.equal(n, 3);
  assert.equal(lines.length, 1);
  assert.match(lines[0], /before check x$/);
  assert.ok(r.waitedS >= 0);
});

test('timeout: gives up with the log line', async () => {
  const f = put('timeout.json', status({ usedMB: 7900 }));
  const lines = [];
  let t = 0;
  const r = await waitForBudget({ estMB: 1200, env: { GTAI_CAP_STATUS: f, GTAI_MEM_WAIT_MAX_S: '30' },
    log: (l) => lines.push(l), clock: () => Date.now() + t, sleep: async () => { t += 10_000; } });
  assert.equal(lines.length, 2);
  assert.match(lines[1], /^mem-budget: waited 30 s, starting anyway$/);
  assert.equal(r.waitedS, 30);
});
