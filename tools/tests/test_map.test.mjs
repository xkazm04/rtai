import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mapChanges } from './test_map.mjs';

const index = {
  tests: {
    'tests/unit/test_alpha.gd': 'var a: Alpha = Alpha.new()',
    'tests/unit/test_beta.gd': 'extends GutTest',
    'tests/unit/test_uses_rig.gd': 'preload("res://features/rig/rig.gd")',
    'tests/integration/test_replay.gd': 'World.new(); Alphabet',
  },
  classNames: (p) => (p === 'core/alpha.gd' ? ['Alpha'] : []),
};
const map = (...c) => mapChanges(c, index);

test('a changed test maps to itself', () => {
  assert.deepEqual(map('project/tests/unit/test_beta.gd').tests, ['tests/unit/test_beta.gd']);
});

test('a source maps by class_name (word match) and by test_<basename> twin', () => {
  const r = map('project/core/alpha.gd');
  assert.deepEqual(r.tests, ['tests/unit/test_alpha.gd']);
  assert.equal(r.full, null);
});

test('a source maps by res:// path mention', () => {
  assert.deepEqual(map('project/features/rig/rig.gd').tests, ['tests/unit/test_uses_rig.gd']);
});

test('twin by basename without class_name', () => {
  assert.deepEqual(map('project/features/x/beta.gd').tests, ['tests/unit/test_beta.gd']);
});

test('shared inputs force the full suite and say why', () => {
  for (const p of ['project/tests/support/fake.gd', 'project/project.godot', 'project/.gutconfig.json',
    'project/addons/gut/gut.gd', 'project/data/schemas/a.schema.json', 'project/tests/load_all.gd']) {
    assert.ok(map(p).full.includes(p), p);
  }
});

test('an unmappable project file forces the full suite', () => {
  assert.match(map('project/data/tables/guns.json').full, /unreferenced asset project\/data\/tables\/guns\.json/);
  assert.match(map('project/core/nobody.gd').full, /no test mentions it/);
});

test('outside project/ needs no unit tests; .uid is ignored', () => {
  const r = map('tools/lint/lint.mjs', 'docs/x.txt', 'project/core/alpha.gd.uid');
  assert.deepEqual(r.tests, []);
  assert.equal(r.full, null);
  assert.equal(r.notes.length, 1);
  assert.match(r.notes[0], /^2 path\(s\) outside project/);
});

test('a deleted test is a note, not a failure', () => {
  const r = map('project/tests/unit/test_gone.gd');
  assert.deepEqual(r.tests, []);
  assert.equal(r.full, null);
});

test('a word-boundary miss does not map', () => {
  assert.ok(!map('project/core/alpha.gd').tests.includes('tests/integration/test_replay.gd'));
});

// --- reach index (card ts-a): res:// refs, tables, dev/, scenarios and one class hop ---
const { buildReach } = await import('./reach_index.mjs');
const { replayHistory } = await import('./test_map.mjs');

const reachFixture = {
  tests: {
    'tests/unit/test_boss_fight.gd': 'var spec: BossSpec = BossSpec.new()',
    'tests/unit/test_walkers.gd': 'StreetWalkerCards.frame_of(0)',
    'tests/unit/test_a.gd': 'var loop: SimLoop = SimLoop.new()',
    'tests/unit/test_b.gd': 'LoopUser.new().run()',
    'tests/unit/test_bench.gd': 'BenchDriver.new()',
  },
  classNames: () => [],
  reach: buildReach({
    sources: {
      'features/bosses/boss_spec.gd': 'class_name BossSpec\nconst TABLE: String = "res://data/tables/bosses.json"\n',
      'features/characters/street_walker_cards.gd':
        'class_name StreetWalkerCards\nconst DIR: String = "res://features/characters/art/view/"\n',
      'core/clock/sim_loop.gd': 'class_name SimLoop\nextends RefCounted\n',
      'features/x/loop_user.gd': 'class_name LoopUser\nvar _loop: SimLoop = SimLoop.new()\n',
      'dev/bench/bench_driver.gd': 'class_name BenchDriver\n',
      'dev/bench/lonely.gd': 'class_name LonelyBench\n',
      'core/everything.gd': 'const ROOT: String = "res://"\nconst F: String = "res://features/"\n',
    },
    autoloads: {},
  }),
};
const reachMap = (...c) => mapChanges(c, reachFixture);

test('a data table maps through the script holding its res:// path to the tests of that script', () => {
  const r = reachMap('project/data/tables/bosses.json');
  assert.deepEqual(r.tests, ['tests/unit/test_boss_fight.gd']);
  assert.equal(r.full, null);
});

test('an art file maps through the nearest ancestor-directory res:// constant', () => {
  const r = reachMap('project/features/characters/art/view/p55/cop_patrol_walk.png');
  assert.deepEqual(r.tests, ['tests/unit/test_walkers.gd']);
  assert.equal(r.full, null);
});

test('dev/ code no test names maps to nothing, with the layers note', () => {
  const r = reachMap('project/dev/bench/lonely.gd');
  assert.deepEqual(r.tests, []);
  assert.equal(r.full, null);
  assert.ok(r.notes.some((n) => n.includes('dev/ is unreachable from shipped code (layers lint)')), r.notes.join('|'));
});

test('dev/ code a test names maps to exactly that test', () => {
  const r = reachMap('project/dev/bench/bench_driver.gd');
  assert.deepEqual(r.tests, ['tests/unit/test_bench.gd']);
  assert.equal(r.full, null);
});

test('a source maps to its direct tests plus the direct tests of its one-hop dependents', () => {
  const r = reachMap('project/core/clock/sim_loop.gd');
  assert.deepEqual(r.tests, ['tests/unit/test_a.gd', 'tests/unit/test_b.gd']);
  assert.equal(r.full, null);
});

test('scenario code maps to no unit tests; support and schemas stay FULL', () => {
  const r = reachMap('project/tests/scenarios/scenario_arena_city.gd');
  assert.deepEqual(r.tests, []);
  assert.equal(r.full, null);
  assert.ok(r.notes.some((n) => n.includes('scenario code: run_scenarios covers it')), r.notes.join('|'));
  assert.ok(reachMap('project/tests/support/dummy_bot.gd').full);
  assert.ok(reachMap('project/data/schemas/x.json').full);
});

test('an asset no file references (path or ancestor dir) stays FULL, never silently zero', () => {
  const r = reachMap('project/features/nowhere/art/thing.png');
  assert.equal(r.full, 'unreferenced asset project/features/nowhere/art/thing.png');
});

test('replayHistory counts project commits, FULL share and mean files', () => {
  const commits = [
    { sha: 'a', files: ['project/data/tables/bosses.json'] },
    { sha: 'b', files: ['project/features/nowhere/x.png'] },
    { sha: 'c', files: ['tools/x.mjs', 'project/x.gd.uid'] },
  ];
  const h = replayHistory(commits, (c) => mapChanges(c, reachFixture), { total: 5 });
  assert.equal(h.commits, 2);
  assert.equal(h.full, 1);
  assert.equal(h.pctFull, 50);
  assert.equal(h.meanFiles, 3);
});
