// Tests for the evidence scope (scope.mjs): the inert set, porcelain parsing and the inert-readers guard.
// Run: node --test "tools/evidence/*.test.mjs"
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { ROOT, rel, walk } from '../lib/repo.mjs';
import { classify, isInert, readersOfInert } from './scope.mjs';

test('docs, evidence and root JOURNAL/REPORT lines are inert', () => {
  const c = classify(['?? evidence/n7-melee/x.log', ' M JOURNAL.md', ' M REPORT.md', ' M docs/perf/LEDGER.md']);
  assert.equal(c.inert, 4);
  assert.equal(c.code, 0);
});

test('guard: AGENTS.md, justfile, project docs, the debt baseline and .uid files are code', () => {
  const lines = [' M AGENTS.md', ' M justfile', ' M project/core/README.md', ' M tools/debt/baseline.json', ' M project/core/a.gd.uid'];
  const c = classify(lines);
  assert.equal(c.inert, 0);
  assert.equal(c.code, 5);
  assert.deepEqual(c.codePaths, ['AGENTS.md', 'justfile', 'project/core/README.md', 'tools/debt/baseline.json', 'project/core/a.gd.uid']);
});

test('a nested JOURNAL.md, a docs-lookalike root and a rename out of docs/ are code', () => {
  assert.equal(isInert('project/JOURNAL.md'), false);
  assert.equal(isInert('docsx/a.md'), false);
  assert.equal(isInert('evidence'), false);
  assert.equal(isInert('evidence/it11/padwalk/'), true);
  assert.equal(classify(['R  docs/a.gd -> project/a.gd']).code, 1);
  assert.equal(classify(['R  docs/a.md -> docs/b.md']).inert, 1);
  assert.equal(classify(['?? "docs/a b.md"']).inert, 1);
});

test('the trimmed first porcelain line (dirtyLines strips its leading space) still parses', () => {
  const c = classify(['M JOURNAL.md', 'M  JOURNAL.md', 'M project/x.gd']);
  assert.equal(c.inert, 2);
  assert.deepEqual(c.codePaths, ['project/x.gd']);
});

const KIND_DIRS = ['lint', 'tests', 'debt', 'selftest', 'bench', 'style', 'gen_constants'];

test('guard: no evidence-kind tool reads docs/, evidence/ or root JOURNAL/REPORT today', () => {
  const sources = KIND_DIRS.flatMap((d) => walk(join(ROOT, 'tools', d), (n) => n.endsWith('.mjs') && !n.endsWith('.test.mjs'), []))
    .map((abs) => ({ file: rel(abs), text: readFileSync(abs, 'utf8') }));
  assert.ok(sources.length > 10, `expected the kind tools, got ${sources.length}`);
  assert.deepEqual(readersOfInert(sources), []);
});

test('readersOfInert flags a docs/ or evidence/ read root and ignores a write', () => {
  const sources = [
    { file: 'a.mjs', text: "const t = readFileSync(join(ROOT, 'docs', 'perf', 'LEDGER.md'), 'utf8');" },
    { file: 'b.mjs', text: "const dir = join(ROOT, 'evidence');\nfor (const f of walk(dir, keep)) use(f);" },
    { file: 'c.mjs', text: "const out = join(ROOT, 'evidence', 'x.json');\nmkdirSync(join(ROOT, 'evidence'), { recursive: true });\nwriteFileSync(out, s);" },
    { file: 'd.mjs', text: "const j = readFileSync(join(root, 'JOURNAL.md'), 'utf8');" },
    { file: 'e.mjs', text: "const logs = readdirSync('evidence/d9-seams');" },
  ];
  assert.deepEqual(readersOfInert(sources), ['a.mjs', 'b.mjs', 'd.mjs', 'e.mjs']);
});
