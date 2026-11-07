// node --test tools/tests/ - the red-run triage: cause lines from the log, the reach verdict, the
// flake history and the paste-ready rerun command per failure.
import assert from 'node:assert/strict';
import { existsSync, mkdtempSync, readFileSync, rmSync, rmdirSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { test } from 'node:test';
import { buildReach } from './reach_index.mjs';
import { TRIAGE_NAME, blockLines, logSlice, parseEntries, rerunCommand, triage, verdictOf, writeTriage } from './triage.mjs';

const LOG = `===== gut (exit 1, 3.0 s)
res://tests/unit/test_save_slots.gd
* test_leftover_tmp_from_a_crash_is_ignored_then_removed
* test_unwritable_profile_reports_and_does_not_throw
ERROR: Could not create directory: 'user://test_tmp/28c5ef7f/61972/save/blocker/auto_a'.
   at: make_dir_recursive (core/io/dir_access.cpp:179)
   GDScript backtrace (most recent call first):
       [0] write (res://core/save/slot_file.gd:18)
       [1] _run (res://core/save/save_worker.gd:120)
[WARN] save: write to auto_a failed (Can't create)
* test_both_slots_corrupt_starts_fresh_and_keeps_the_evidence
ERROR: not mine
16/16 passed.


res://tests/unit/test_saw_marks.gd
* test_the_shipped_table_loads
ERROR: also not mine
`;

/** A fixture index: tests + a reach index over `sources`; classNames from the reach's own names. */
function fixtureIndex(tests, sources, autoloads = {}) {
  const reach = buildReach({ sources, autoloads });
  return { tests, classNames: (local) => reach.names[local] ?? [], reach };
}

const VEHICLES = fixtureIndex({
  'tests/unit/test_vehicle_view.gd': 'extends GutTest\nfunc test_glow_is_lit() -> void:\n\tvar v := VehicleView.new()\n',
  'tests/unit/test_hud_feed.gd': 'extends GutTest\nfunc test_feed() -> void:\n\tvar f := HudFeed.new()\n',
}, {
  'features/vehicles/vehicle_view.gd': 'class_name VehicleView\nconst GLOW = preload("res://features/vehicles/vehicle_glow.gdshader")\n',
  'features/vehicles/vehicle_glow.gdshader': 'shader_type canvas_item;\n',
  'features/hud/hud_feed.gd': 'class_name HudFeed\n',
});

const VIEW = 'res://tests/unit/test_vehicle_view.gd';

test('logSlice: the ERROR, its at: line and the first backtrace frame, stopping at the next test', () => {
  assert.deepEqual(logSlice(LOG, 'res://tests/unit/test_save_slots.gd', 'test_unwritable_profile_reports_and_does_not_throw'), [
    "ERROR: Could not create directory: 'user://test_tmp/28c5ef7f/61972/save/blocker/auto_a'.",
    'at: make_dir_recursive (core/io/dir_access.cpp:179)',
    '[0] write (res://core/save/slot_file.gd:18)',
  ]);
  assert.deepEqual(logSlice(LOG, 'res://tests/unit/test_save_slots.gd', 'test_leftover_tmp_from_a_crash_is_ignored_then_removed'), []);
  assert.deepEqual(logSlice(LOG, 'res://tests/unit/test_save_slots.gd', 'test_both_slots_corrupt_starts_fresh_and_keeps_the_evidence'),
    ['ERROR: not mine'], 'stops at the "n/m passed" line, never runs into the next file');
  assert.deepEqual(logSlice(LOG, 'res://tests/unit/test_saw_marks.gd', 'test_missing'), []);
  assert.deepEqual(logSlice(LOG, 'res://tests/unit/test_nope.gd', 'test_the_shipped_table_loads'), []);
});

test('verdict: REACHED by the changed shader through the view that preloads it; UNREACHED for an unrelated file', () => {
  const hit = verdictOf(VIEW, ['project/features/vehicles/vehicle_glow.gdshader'], VEHICLES);
  assert.equal(hit.verdict, 'REACHED by project/features/vehicles/vehicle_glow.gdshader');
  assert.equal(hit.reach.length, 1);
  assert.match(hit.reach[0], /vehicle_glow\.gdshader <- features\/vehicles\/vehicle_view\.gd \(res:\/\/ path\) <- tests\/unit\/test_vehicle_view\.gd/);
  const miss = verdictOf(VIEW, ['project/features/hud/hud_feed.gd'], VEHICLES);
  assert.equal(miss.verdict, 'UNREACHED: none of your 1 changed file(s) reaches this test - suspect the base or the machine');
  assert.deepEqual(miss.reach, []);
});

test('rerun: the exact basename and function from the junit case', () => {
  assert.equal(rerunCommand(VIEW, 'test_glow_is_lit'), 'node tools/tests/run_unit.mjs --select=test_vehicle_view --test=test_glow_is_lit');
  const [entry] = triage({ failing: [{ file: VIEW, name: 'test_glow_is_lit', line: 3, message: 'Unexpected Errors:', cause: ['[1] <engine>x'] }],
    outs: [], changed: ['project/features/hud/hud_feed.gd'], index: VEHICLES, ledger: [] });
  const block = blockLines(entry);
  assert.equal(block.at(-1).trim(), 'rerun: node tools/tests/run_unit.mjs --select=test_vehicle_view --test=test_glow_is_lit');
  assert.ok(block.some((l) => l.includes('[1] <engine>x')), 'the cause is in the block');
});

test('PARSE: a SCRIPT ERROR + at: res://tests/... names the file GUT skipped', () => {
  const out = 'SCRIPT ERROR: Parse Error: Identifier "nope" not declared in the current scope.\n   at: GDScript::reload (res://tests/unit/test_x.gd:12)\n';
  const [e] = parseEntries([out, out]);
  assert.equal(parseEntries([out, out]).length, 1, 'one entry per file:line, however many steps saw it');
  assert.equal(e.verdict.split(' ')[0], 'PARSE');
  assert.match(e.verdict, /res:\/\/tests\/unit\/test_x\.gd:12/);
  assert.equal(e.file, 'res://tests/unit/test_x.gd');
  assert.equal(e.line, 12);
  assert.equal(e.rerun, 'node tools/tests/run_unit.mjs --select=test_x');
  const viaTriage = triage({ failing: [], outs: [`at: res://tests/unit/test_x.gd:12\n${out}`], changed: [], index: VEHICLES, ledger: [] });
  assert.equal(viaTriage.length, 1);
  assert.equal(viaTriage[0].verdict.split(' ')[0], 'PARSE');
});

test('unit-triage.json: written for a red run (one entry per failure, the schema keys), removed by a green one', () => {
  const dir = mkdtempSync(join(tmpdir(), 'gtai-triage-'));
  try {
    const entries = triage({ failing: [{ file: VIEW, name: 'test_glow_is_lit', line: 3, message: 'm', cause: [] }],
      outs: [], changed: ['project/features/vehicles/vehicle_glow.gdshader'], index: VEHICLES, ledger: [] });
    writeTriage(dir, entries, false);
    const doc = JSON.parse(readFileSync(join(dir, TRIAGE_NAME), 'utf8'));
    assert.equal(doc.schema, 'gtai.unit-triage/1');
    assert.equal(doc.entries.length, 1);
    assert.deepEqual(Object.keys(doc.entries[0]).sort(), ['cause', 'file', 'flakes', 'line', 'message', 'name', 'reach', 'rerun', 'verdict']);
    assert.ok(Array.isArray(doc.entries[0].cause) && Array.isArray(doc.entries[0].reach));
    writeTriage(dir, [], true);
    assert.equal(existsSync(join(dir, TRIAGE_NAME)), false, 'a green run removes the stale triage');
  } finally { rmSync(join(dir, TRIAGE_NAME), { force: true }); rmdirSync(dir); }
});

test('flake history: 2 ledger entries -> "flaked 2x before (last <ts>, <lanes>)"', () => {
  const ledgerFile = join(mkdtempSync(join(tmpdir(), 'gtai-flk-')), 'flakes.jsonl');
  const rows = [
    { ts: '2026-11-05T10:00:00.000Z', test: 'test_glow_is_lit', file: VIEW, lane: 'lane/look' },
    { ts: '2026-11-06T11:00:00.000Z', test: 'test_glow_is_lit', file: VIEW, lane: 'lane/vehicles' },
    { ts: '2026-11-06T12:00:00.000Z', test: 'test_other', file: VIEW, lane: 'lane/x' },
  ];
  writeFileSync(ledgerFile, rows.map((r) => JSON.stringify(r)).join('\n'), 'utf8');
  const prev = process.env.GTAI_FLAKES_FILE;
  process.env.GTAI_FLAKES_FILE = ledgerFile;
  try {
    const [e] = triage({ failing: [{ file: VIEW, name: 'test_glow_is_lit', line: 3, message: 'm', cause: [] }],
      outs: [], changed: [], index: VEHICLES });
    assert.equal(e.flakes.count, 2);
    assert.ok(blockLines(e).some((l) => l.trim() === 'flaked 2x before (last 2026-11-06T11:00:00.000Z, lane/look, lane/vehicles)'));
  } finally {
    if (prev === undefined) delete process.env.GTAI_FLAKES_FILE; else process.env.GTAI_FLAKES_FILE = prev;
    rmSync(ledgerFile, { force: true });
  }
});

// GUARD (critic): the verdict never calls a failure unreached for a test the reach map cannot see.
const SIM = fixtureIndex({
  'tests/unit/test_world_tick.gd': 'extends GutTest\nfunc test_ticks() -> void:\n\tvar w := WorldTick.new()\n',
  'tests/unit/test_world.gd': 'extends GutTest\nfunc test_boots() -> void:\n\tvar w := World.new()\n',
  'tests/unit/test_sim_loop.gd': 'extends GutTest\n',
}, {
  'core/clock/sim_loop.gd': 'class_name SimLoop\n',
  'features/city/world_tick.gd': 'class_name WorldTick\nvar loop := SimLoop.new()\n',
  'features/city/world.gd': 'class_name World\nvar tick := WorldTick.new()\n',
  'core/events/events.gd': 'extends Node\n',
}, { Events: 'core/events/events.gd' });
const BLIND = /UNREACHED|suspect the base or the machine/;

test('GUARD: a test reaching SimLoop through a dependent is REACHED with the chain', () => {
  const v = verdictOf('res://tests/unit/test_world_tick.gd', ['project/core/clock/sim_loop.gd'], SIM);
  assert.doesNotMatch(v.verdict, BLIND);
  assert.equal(v.verdict, 'REACHED by project/core/clock/sim_loop.gd');
  assert.match(v.reach[0], /sim_loop\.gd <- features\/city\/world_tick\.gd \(names SimLoop\) <- tests\/unit\/test_world_tick\.gd \(twin test_world_tick\)/);
});

test('GUARD: two hops past the one-hop index -> UNMAPPED with the chain, never UNREACHED', () => {
  const v = verdictOf('res://tests/unit/test_world.gd', ['project/core/clock/sim_loop.gd'], SIM);
  assert.doesNotMatch(v.verdict, BLIND);
  assert.match(v.verdict, /^UNMAPPED: the map is not exhaustive/);
  assert.match(v.reach[0], /sim_loop\.gd <- .*world_tick\.gd .*<- .*world\.gd .*<- tests\/unit\/test_world\.gd/);
});

test('GUARD: a change that maps FULL says FULL, never UNREACHED', () => {
  for (const changed of [['project/core/events/events.gd'], ['project/tests/support/helper.gd'], ['project/project.godot']]) {
    const v = verdictOf('res://tests/unit/test_world.gd', changed, SIM);
    assert.doesNotMatch(v.verdict, BLIND, changed[0]);
    assert.match(v.verdict, /^FULL: /, changed[0]);
  }
});

test('GUARD: a change outside the map (native/, tools/) is UNMAPPED, never UNREACHED', () => {
  for (const changed of [['native/sim_core/src/step.cpp'], ['tools/tests/run_unit.mjs', 'project/features/hud/hud_feed.gd']]) {
    const v = verdictOf(VIEW, changed, VEHICLES);
    assert.doesNotMatch(v.verdict, BLIND, changed[0]);
    assert.match(v.verdict, /^UNMAPPED: the map is not exhaustive/, changed[0]);
  }
});

test('GUARD: a walk that meets an autoload reaches every test (GUT boots it), never UNREACHED', () => {
  const idx = fixtureIndex({ 'tests/unit/test_save.gd': 'extends GutTest\n', 'tests/unit/test_helper.gd': 'extends GutTest\nvar h := Helper.new()\n' }, {
    'core/util/helper.gd': 'class_name Helper\n',
    'core/util/user.gd': 'class_name HelperUser\nvar h := Helper.new()\n',
    'core/boot/autoboot.gd': 'extends Node\nvar u := HelperUser.new()\n',
  }, { Autoboot: 'core/boot/autoboot.gd' });
  const v = verdictOf('res://tests/unit/test_save.gd', ['project/core/util/helper.gd'], idx);
  assert.doesNotMatch(v.verdict, BLIND);
  assert.match(v.verdict, /^UNMAPPED: /);
  assert.match(v.reach[0], /autoboot\.gd .*<- tests\/unit\/test_save\.gd \(autoload Autoboot/);
});
