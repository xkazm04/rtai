import assert from 'node:assert/strict';
import { readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import test from 'node:test';
import { ROOT } from '../lib/repo.mjs';
import { isLintNeutral, narrow, readScope, toolTestInputs } from './scope.mjs';
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

test('every real-tree file the traced tool tests read runs the tool tests (fs_trace, 2026-11-11)', () => {
  const traced = ['project/project.godot', 'project/data/tables/view.json', 'project/dev/frames/film_probe.gd',
    'project/dev/showcase/reel_chapters.gd'];
  for (const p of traced) assert.equal(narrow([p], ALL).toolTests, true, p);
  assert.equal(narrow(['project/features/characters/art/x.png', 'project/features/a.gd'], ALL).toolTests, false);
});

test('provenance, tools/art python and the KILLS/DEFECTS notes ride along with a scoped commit (n16 FRICTION)', () => {
  const s = narrow(['project/b/c.gd', 'project/art/x.png', 'steam/ai-provenance/2026-11.jsonl', 'tools/art/gib_pieces.py',
    'KILLS.md', 'DEFECTS.md', 'JOURNAL.md'], ALL);
  assert.deepEqual(s.gd, ['project/b/c.gd']);
  assert.equal(s.toolTests, false);
  assert.match(s.line, /2 staged path\(s\), all under project\/ \+ 4 lint-neutral/);
  const only = narrow(['steam/ai-provenance/2026-11.jsonl', 'tools/art/x.py'], ALL);
  assert.deepEqual(only.gd, [], 'a provenance + art-script commit lints no .gd and runs every whole-tree check');
  for (const p of ['tools/art/canon_json.mjs', 'tools/art/fx_colour.json', 'tools/art/sub/x.py', 'steam/manifest.json',
    'steam/achievements/achievements.json', 'tools/x.py', 'AGENTS.md', 'KILLS.md.bak']) {
    assert.equal(isLintNeutral(p), false, p);
    assert.equal(narrow(['project/a.gd', p], ALL), null, p);
  }
});

test('guard: no tool code reads a lint-neutral path (else it must leave the neutral list)', () => {
  const hits = [];
  const walkMjs = (dir) => {
    for (const e of readdirSync(join(ROOT, dir), { withFileTypes: true })) {
      const rel = `${dir}/${e.name}`;
      if (e.isDirectory()) { if (!['node_modules', 'fixtures'].includes(e.name)) walkMjs(rel); continue; }
      if (!e.name.endsWith('.mjs') || rel.startsWith('tools/art/') || rel.startsWith('tools/lint/scope')) continue;
      const src = readFileSync(join(ROOT, rel), 'utf8');
      for (const needle of ['ai-provenance', 'KILLS.md', 'DEFECTS.md', 'tools/art', "'art'"]) if (src.includes(needle)) hits.push(`${rel}: ${needle}`);
    }
  };
  walkMjs('tools');
  assert.deepEqual(hits, []);
});
