import assert from 'node:assert/strict';
import { test } from 'node:test';
import { setArguments } from './plan_sets.mjs';
import { knobStep, occupied } from './tune_groups.mjs';
import { propose } from './tune_propose.mjs';

const rate = 'rivet.repair_per_s', delay = 'rivet.repair_delay_s';
const file = 'project/data/tables/gauntlet.json';
const baseline = { values: { [rate]: 10, [delay]: 3, 'budget.per_wave': 16 } };

function catalog() {
  const entries = new Map();
  for (const [id, value] of Object.entries(baseline.values)) {
    const direction = { [rate]: 'down', [delay]: 'up' }[id];
    const knob = { id, file, direction, pointer: '/' + id.replace('.', '/'),
      kind: direction ? 'float' : 'int', min: 0, max: 1000 };
    entries.set(id, { knob, value });
  }
  return entries;
}

function deathPlan(wave, entries, used = new Set()) {
  const results = [1, 2, 3].map((seed) => ({ seed, profile: 'expert', controls: 'wheel',
    wave_reached: wave, death: { wave, by: 'bot' } }));
  const batch = { args: { runner: 'gauntlet', waves: 40 }, results, runs: results.map((r) => ({ ...r, ok: true })) };
  return propose(batch, { entries }, baseline, { profile: 'expert', metric: 'death', used, batchHash: '0'.repeat(64) });
}

test('one repair change yields two set arguments and mirrors a miss of more than three waves', () => {
  for (const [wave, factor, afterRate, afterDelay] of [[24, 1.25, 8, 3.75], [16, 0.8, 12.5, 2.4]]) {
    const plan = deathPlan(wave, catalog());
    assert.equal(plan.changes.length, 1);
    const [change] = plan.changes;
    assert.deepEqual([change.id, change.factor, change.profiles], ['rivet_repair', factor, ['expert']]);
    assert.deepEqual(setArguments(plan), [
      '--set=' + file + '#/rivet/repair_per_s=' + afterRate,
      '--set=' + file + '#/rivet/repair_delay_s=' + afterDelay
    ]);
  }
  assert.equal(deathPlan(21, catalog()).changes[0].factor, 1.05);
});

test('either repair member occupies the whole group and leaves the per-wave budget available', () => {
  for (const id of ['rivet_repair', rate, delay]) {
    const used = new Map([[id, 'receipt']]);
    for (const other of ['rivet_repair', rate, delay]) assert.ok(occupied(other, used));
    assert.equal(occupied('budget.per_wave', used), false);
    assert.equal(deathPlan(24, catalog(), new Set(used.keys())).changes[0].id, 'budget.per_wave');
  }
});

test('repair clamps each member to its first-night range and falls back when both hit the limit', () => {
  const entries = catalog();
  for (const [wave, requested, factor, nearRate, nearDelay, endRate, endDelay] of [
    [24, 2, 1.25, 5.1, 5.9, 5, 6], [16, 0.5, 0.8, 19.9, 1.6, 20, 1.5]
  ]) {
    entries.get(rate).value = nearRate;
    entries.get(delay).value = nearDelay;
    const change = knobStep('rivet_repair', requested, entries, baseline);
    assert.equal(change.factor, factor);
    assert.deepEqual(change.members.map((m) => m.after), [endRate, endDelay]);
    entries.get(rate).value = endRate;
    entries.get(delay).value = endDelay;
    assert.equal(deathPlan(wave, entries).changes[0].id, 'budget.per_wave');
  }
});
