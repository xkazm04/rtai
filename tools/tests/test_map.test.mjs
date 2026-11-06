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
  assert.match(map('project/data/tables/guns.json').full, /no test mentions it/);
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
