// node --test "tools/selftest/*.test.mjs"
import assert from 'node:assert/strict';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { after, test } from 'node:test';
import { runAccentAudit, runWorldLock } from './run.mjs';

const lockJson = JSON.stringify({ ok: true, max_share: 0.01, frames: [{ ppm: 32, differing_share: 0 }] });
const made = [];
after(() => { for (const d of made) rmSync(d, { recursive: true, force: true }); });
const fresh = () => { const d = mkdtempSync(join(tmpdir(), 'gtai-selftest-')); made.push(d); return d; };

/** A stub windowed runner: writes `name` into `dir` (after removeStale) and exits `status`. */
const stub = (dir, name, text, status, out = '') => async () => {
  writeFileSync(join(dir, name), text);
  return { status, out, timedOut: false, durationMs: 1 };
};

test('runWorldLock: an exit 1 fails even when world-lock.json says ok:true', async () => {
  const dir = fresh();
  const r = await runWorldLock(dir, dir, stub(dir, 'world-lock.json', lockJson, 1));
  assert.equal(r.ok, false);
  assert.match(r.summary, /FAIL exit 1/);
});

test('runWorldLock: exit 0, no errors, a fresh ok result holds (guard)', async () => {
  const dir = fresh();
  const r = await runWorldLock(dir, dir, stub(dir, 'world-lock.json', lockJson, 0));
  assert.equal(r.ok, true, r.summary);
});

test('runWorldLock: a SCRIPT ERROR behind an ok JSON fails', async () => {
  const dir = fresh();
  const r = await runWorldLock(dir, dir, stub(dir, 'world-lock.json', lockJson, 0, 'SCRIPT ERROR: x\n'));
  assert.equal(r.ok, false);
});

test('runAccentAudit: an exit 1 fails a clean audit', async () => {
  const dir = fresh();
  const audit = JSON.stringify({ frames: [{ ppm: 32, frame_share: 0, offenders: [] }] });
  const r = await runAccentAudit(dir, dir, 'junction', stub(dir, 'accent-audit.json', audit, 1));
  assert.equal(r.ok, false);
});

test('a debt row seen by the block site is not reported unseen (n15: the junction alone said delete it)', async () => {
  const { unseenDebtRows, unseenNote } = await import('./run.mjs');
  const rows = [{ id: 'blood_flicker_vehicles_64', ppm: 64, accent: 'blood', layer: 'vehicles' },
    { id: 'blood_flicker_cop_48', ppm: 48, accent: 'vermilion', layer: 'cop' }];
  const junction = ['32 px/m vermilion on cop: 4 px'];
  const block = ['64 px/m blood on vehicles: 4 px'];
  assert.deepEqual(unseenDebtRows(rows, [junction, block]), ['blood_flicker_cop_48']);
  assert.deepEqual(unseenDebtRows(rows, [junction]), ['blood_flicker_vehicles_64', 'blood_flicker_cop_48']);
  assert.equal(unseenNote([]), '');
  assert.doesNotMatch(unseenNote(['x']), /delete/);
});

test('runAccentAudit no longer judges debt rows unseen from one site', async () => {
  const dir = fresh();
  const audit = JSON.stringify({ frames: [{ ppm: 32, frame_share: 0, offenders: [] }] });
  const r = await runAccentAudit(dir, dir, 'junction', stub(dir, 'accent-audit.json', audit, 0));
  assert.doesNotMatch(r.summary, /no longer seen|neither site/);
});
