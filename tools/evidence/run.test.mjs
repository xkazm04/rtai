// Tests for run.mjs's dirty-tree gate and import-churn check (pure exports; no Godot runs).
// Run: node --test "tools/evidence/*.test.mjs"
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { applyChurn, dirtyGate } from './run.mjs';

test('dirty gate: inert-only dirt is not refused and is named in a note', () => {
  const g = dirtyGate(['?? evidence/n7-melee/x.log', ' M JOURNAL.md', ' M docs/perf/LEDGER.md'], false);
  assert.equal(g.exit, null);
  assert.equal(g.note, ' [inert: 3 docs/evidence paths uncommitted]');
  assert.ok(`lint: 9 checks ok${g.note}`.endsWith('[inert: 3 docs/evidence paths uncommitted]'));
});

test('dirty gate: code dirt is refused (exit 2) naming only the code path', () => {
  const g = dirtyGate(['?? evidence/n7-melee/x.log', ' M JOURNAL.md', ' M docs/perf/LEDGER.md', ' M project/x.gd'], false);
  assert.equal(g.exit, 2);
  const text = g.messages.join('\n');
  assert.match(text, /project\/x\.gd/);
  assert.doesNotMatch(text, /JOURNAL|LEDGER|evidence\//);
});

test('guard: --allow-dirty still runs on code dirt and says so before the inert note', () => {
  const g = dirtyGate([' M project/x.gd', ' M JOURNAL.md'], true);
  assert.equal(g.exit, null);
  assert.equal(g.note, ' [dirty tree: 1 uncommitted paths] [inert: 1 docs/evidence paths uncommitted]');
  assert.deepEqual(dirtyGate([], false), { exit: null, messages: [], note: '' });
});

test('unit churn: an inert JOURNAL edit during the run keeps unit ok', () => {
  const unit = applyChurn({ ok: true, summary: 'unit-tests: 3 passed' }, [], [' M JOURNAL.md']);
  assert.equal(unit.ok, true);
  assert.equal(unit.summary, 'unit-tests: 3 passed');
});

test('unit churn: a code line that was first (trimmed) before the run is not new churn', () => {
  const unit = applyChurn({ ok: true, summary: 'u' }, ['M project/x.gd'], ['?? docs/a.md', ' M project/x.gd']);
  assert.equal(unit.ok, true);
});

test('guard: unit churn on a code path (a .uid) fails unit and names it', () => {
  const unit = applyChurn({ ok: true, summary: 'unit-tests: 3 passed' }, [' M JOURNAL.md'], [' M JOURNAL.md', '?? evidence/a.log', ' M project/core/a.gd.uid']);
  assert.equal(unit.ok, false);
  assert.match(unit.summary, /tree changed during run \(1 paths, import churn\): {2}M project\/core\/a\.gd\.uid$/);
});
