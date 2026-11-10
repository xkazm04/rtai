import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import test from 'node:test';
import { ROOT } from '../lib/repo.mjs';
import { narrow, readScope, toolTestInputs } from './scope.mjs';
import { scopeOf } from './lint.mjs';

const ALL = ['project/a.gd', 'project/b/c.gd', 'tools/canary.gd'];

test('a commit wholly under project/ lints only its staged .gd files', () => {
  const s = narrow(['project/b/c.gd', 'project/art/x.png', 'JOURNAL.md'], ALL);
  assert.deepEqual(s.gd, ['project/b/c.gd']);
  assert.equal(s.toolTests, false);
  assert.match(s.line, /2 staged path\(s\), all under project\/\): gdformat \+ gdlint over 1 of 3 \.gd; tool-tests skipped/);
  assert.deepEqual(narrow(['project/art/x.png'], ALL).gd, [], 'no staged .gd: no per-file run');
  assert.deepEqual(narrow(['project/gone.gd'], ALL).gd, [], 'a deleted .gd is not in the tree: nothing to lint');
});

test('any staged path outside project/ (or none) gives the full lint', () => {
  for (const staged of [['project/a.gd', 'tools/lint/lint.mjs'], ['gdlintrc'], ['gdformatrc'], ['versions.toml'],
    ['native/src/x.cpp'], ['AGENTS.md'], ['projectx/a.gd'], [], ['JOURNAL.md'], null]) {
    assert.equal(narrow(staged, ALL), null, JSON.stringify(staged));
  }
});

test('a staged file a tool test reads runs the tool tests', () => {
  const s = narrow(['project/a.gd'], ALL, new Set(['project/a.gd']));
  assert.equal(s.toolTests, true);
  assert.match(s.line, /tool-tests run \(a tool test reads project\/a\.gd\)/);
});

test('tool-test inputs are the join(ROOT, literal) reads, the real factory test among them', () => {
  assert.deepEqual([...toolTestInputs(["join(ROOT, 'project/x.gd')", 'join( ROOT , "a/b.json" )', 'join(ROOT, `t/${x}`)', "join(dir, 'project/y.gd')"])],
    ['project/x.gd', 'a/b.json']);
  const real = toolTestInputs([readFileSync(join(ROOT, 'tools/codex/factory.test.mjs'), 'utf8')]);
  assert.ok(real.has('project/features/city/city_spawn_plan.gd'));
});

test('an unreadable scope file is the full lint, and lint says so', () => {
  assert.equal(readScope('x', () => { throw new Error('ENOENT'); }), null);
  assert.deepEqual(readScope('x', () => 'project/a.gd\r\n\r\n tools/b.mjs \n'), ['project/a.gd', 'tools/b.mjs']);
  const r = scopeOf(['--scope=Z:/no/such/scope.txt']);
  assert.equal(r.scope, null);
  assert.match(r.line, /unreadable: full lint/);
  assert.deepEqual(scopeOf([]), { scope: null, line: null });
});

test('the real tree: a project/ commit of a real file narrows, and the factory test input runs tool tests', () => {
  const s = scopeOf([`--scope=${join(ROOT, 'tools/lint/fixtures/scope_city.txt')}`]).scope;
  assert.deepEqual(s.gd, ['project/features/city/city_spawn_plan.gd']);
  assert.equal(s.toolTests, true);
});
