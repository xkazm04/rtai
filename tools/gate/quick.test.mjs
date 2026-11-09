import assert from 'node:assert/strict';
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { changedFromPorcelain, checkFiles, hasCrlf, lineCount, main, softCapIssues, verdictOf } from './quick.mjs';

test('the changed list is game .gd files only, with renames as the new name and deletions dropped', () => {
  const text = ' M project/a.gd\n?? project/dev/b.gd\nR  project/old.gd -> project/new.gd\n D project/gone.gd\nD  project/gone2.gd\n M tools/x.mjs\n M project/addons/gut/y.gd\n M project/z.tscn\n';
  assert.deepEqual(changedFromPorcelain(text), ['project/a.gd', 'project/dev/b.gd', 'project/new.gd']);
});

test('CRLF is seen in the bytes', () => {
  assert.equal(hasCrlf(Buffer.from('a\r\nb')), true);
  assert.equal(hasCrlf(Buffer.from('a\nb\n')), false);
});

test('lineCount matches the lint: a trailing newline is no extra line', () => {
  assert.equal(lineCount('a\nb\n'), 2);
  assert.equal(lineCount('a\nb'), 2);
});

test('crossing the soft cap fails; a file already over it does not fail again', () => {
  assert.equal(softCapIssues([{ path: 'a', lines: 201, before: 200 }]).length, 1);
  assert.equal(softCapIssues([{ path: 'a', lines: 201, before: 0 }]).length, 1, 'a new file past the cap');
  assert.equal(softCapIssues([{ path: 'a', lines: 250, before: 240 }]).length, 0);
  assert.equal(softCapIssues([{ path: 'a', lines: 200, before: 100 }]).length, 0);
});

test('verdictOf: a checker that failed without naming a file is unverifiable, not ok', () => {
  const un = [];
  const issues = verdictOf('gdlint', { ok: false, out: "'gdlint' is not recognized as an internal or external command", status: 1 }, un);
  assert.deepEqual(issues, []);
  assert.match(un[0], /gdlint exited 1 without naming a file/);
});

test('verdictOf: reported issues pass through, a missing tool is unverifiable, ok is silent', () => {
  const un = [];
  assert.deepEqual(verdictOf('gdlint', { ok: false, out: 'project/a.gd:3: Error: too long\n', status: 1 }, un), ['project/a.gd:3: Error: too long']);
  assert.deepEqual(un, []);
  assert.deepEqual(verdictOf('gdlint', { ok: true, out: '' }, un), []);
  assert.deepEqual(verdictOf('gdformat', { missing: true, out: '' }, un), []);
  assert.match(un[0], /gdformat could not run/);
});

function tree() {
  const root = mkdtempSync(join(tmpdir(), 'gtai-quick-'));
  mkdirSync(join(root, 'project'), { recursive: true });
  writeFileSync(join(root, 'project/a.gd'), 'extends RefCounted\n');
  return root;
}
const fine = () => ({ ok: true, out: '', status: 0 });

test('checkFiles: a clean file with working checkers has no issues', () => {
  const root = tree();
  try { assert.deepEqual(checkFiles(['project/a.gd'], { root, run: fine, godot: false }), { issues: [], unverifiable: [] }); } finally { rmSync(root, { recursive: true, force: true }); }
});

test('checkFiles: a Godot launcher that cannot start (exit 2) is unverifiable', () => {
  const root = tree();
  const run = (cmd) => (cmd === 'node' ? { ok: false, status: 2, out: 'Godot 4.7.2 not found\n' } : fine());
  try {
    const r = checkFiles(['project/a.gd'], { root, run, godot: true });
    assert.deepEqual(r.issues, []);
    assert.match(r.unverifiable[0], /Godot parse check could not run/);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test('checkFiles: a real parse error from Godot is an issue', () => {
  const root = tree();
  const run = (cmd) => (cmd === 'node' ? { ok: false, status: 1, out: 'ok res://x.gd\nSCRIPT ERROR: Parse Error: bad\n' } : fine());
  try {
    assert.deepEqual(checkFiles(['project/a.gd'], { root, run, godot: true }).issues, ['SCRIPT ERROR: Parse Error: bad']);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test('main: unverifiable when a checker could not run, exit 3; a usage error is exit 2', () => {
  const root = tree();
  const lines = [];
  const run = (cmd) => (cmd === 'gdlint' ? { missing: true, out: '' } : fine());
  try {
    assert.equal(main(['--files=project/a.gd', '--no-godot'], { root, out: (l) => lines.push(l), run }), 3);
    assert.match(lines.at(-1), /UNVERIFIABLE/);
    assert.equal(main(['--nope'], { root, err: () => {}, run }), 2);
    assert.equal(main(['--files=project/none.gd'], { root, err: () => {}, run }), 2);
  } finally { rmSync(root, { recursive: true, force: true }); }
});
