import assert from 'node:assert/strict';
import test from 'node:test';
import { isLintNeutral, narrow } from './scope.mjs';

const ALL = ['project/a.gd', 'project/b.gd', 'tools/not-project.gd'];

test('isLintNeutral accepts only descendants of steam/ai-provenance, the two exact root notes, and named top-level tools/art python files', () => {
  for (const path of ['steam/ai-provenance/2026-11.jsonl', 'KILLS.md', 'DEFECTS.md', 'tools/art/x.py']) {
    assert.equal(isLintNeutral(path), true, path);
  }
  for (const path of [
    'tools/art/x.PY',
    'tools/art/.py',
    'tools/art/sub/x.py',
    'steam/ai-provenance',
    'steam/ai-provenance-old/x',
    './KILLS.md',
    'docs/KILLS.md',
    'project/KILLS.md',
    'tools\\art\\x.py',
  ]) assert.equal(isLintNeutral(path), false, `${path} (scope consumes Git's forward-slash repo paths)`);
});

test('narrow keeps a project plus neutral commit scoped and counts neutral paths without treating inert notes as staged code', () => {
  const scoped = narrow([
    'project/a.gd',
    'project/sprite.png',
    'steam/ai-provenance/a.jsonl',
    'tools/art/cut.py',
    'KILLS.md',
    'docs/review.md',
  ], ALL);
  assert.deepEqual(scoped.gd, ['project/a.gd']);
  assert.equal(scoped.toolTests, false);
  assert.match(scoped.line, /2 staged path\(s\), all under project\/ \+ 3 lint-neutral/);
});

test('narrow returns a scoped empty gd selection for a staged list made only of lint-neutral paths', () => {
  const scoped = narrow(['steam/ai-provenance/a.jsonl', 'tools/art/cut.py', 'DEFECTS.md'], ALL);
  assert.deepEqual(scoped.gd, []);
  assert.equal(scoped.toolTests, false);
  assert.match(scoped.line, /0 staged path\(s\), all under project\/ \+ 3 lint-neutral/);
});

test('narrow returns full lint for any other non-inert path and for nothing but inert paths', () => {
  for (const staged of [
    ['project/a.gd', 'tools/lint/scope.mjs'],
    ['project/a.gd', 'tools\\art\\x.py'],
    ['project/a.gd', 'steam/ai-provenance'],
    ['docs/review.md'],
    ['JOURNAL.md'],
    [],
    null,
  ]) assert.equal(narrow(staged, ALL), null, JSON.stringify(staged));
});

test('narrow runs tool tests for any staged tool-test input, a neutral one included, never for an unread neutral companion', () => {
  assert.equal(narrow(['project/a.gd', 'tools/art/cut.py'], ALL).toolTests, false);
  const input = narrow(['project/a.gd', 'tools/art/cut.py'], ALL, new Set(['project/a.gd']));
  assert.equal(input.toolTests, true);
  // Review (n16 s6): a neutral path a tool test reads DOES run the tool tests (Codex pinned false: the weak side).
  const neutral = narrow(['tools/art/cut.py'], ALL, new Set(['tools/art/cut.py']));
  assert.equal(neutral.toolTests, true);
});
