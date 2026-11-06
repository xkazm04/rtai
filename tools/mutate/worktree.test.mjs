import assert from 'node:assert/strict';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmdirSync, unlinkSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { test } from 'node:test';
import { MARKER, SIDECAR, UnsafePath, assertSafe, defaultWorktreePath, removeWorktree, repairSidecars, restoreFile,
  writeSidecar } from './worktree.mjs';

const ROOT = 'C:/Users/kazda/kiro/gtai';
const TMP = tmpdir();
const slash = (p) => p.replace(/\\/g, '/');
const ident = (p) => p; // fixture paths do not exist: no symlink resolution
const opts = (extra = {}) => ({ root: ROOT, tmp: TMP, realpath: ident, ...extra });
const KIRO = { tmp: 'C:/Users/kazda/kiro' }; // a fake temp dir so repo-internal fixtures reach the right check

test('default path is under the temp dir, stable per root, differs per root', () => {
  const p = defaultWorktreePath(ROOT);
  assert.match(slash(p), /\/gtai-mutate-[0-9a-f]{8}$/);
  assert.equal(p, defaultWorktreePath('c:\\Users\\kazda\\kiro\\gtai\\'));
  assert.notEqual(p, defaultWorktreePath('C:/other/repo'));
  assert.doesNotThrow(() => assertSafe(p, opts()));
});

test('refuses the repo root', () => {
  assert.throws(() => assertSafe(ROOT, opts(KIRO)), /repo root/);
  assert.throws(() => assertSafe('c:\\Users\\kazda\\kiro\\gtai\\', opts(KIRO)), UnsafePath);
});

test('refuses paths inside the repo root (project/, build/, tools/)', () => {
  for (const sub of ['project', 'build/mutate', 'tools/mutate/x']) {
    assert.throws(() => assertSafe(`${ROOT}/${sub}`, opts(KIRO)), /inside the repo root/);
  }
});

test('refuses gtai-wt lane worktrees', () => {
  for (const lane of ['d6-combat-notes', 'n7-king/project', '']) {
    assert.throws(() => assertSafe(`C:/Users/kazda/kiro/gtai-wt/${lane}`, opts(KIRO)), /gtai-wt/);
  }
  assert.throws(() => assertSafe(`${TMP}/gtai-wt/x`, opts()), /gtai-wt/);
});

test('refuses anything outside the OS temp dir', () => {
  for (const p of ['D:/elsewhere/gtai-mutate-abcd1234', 'C:/Windows/System32', 'C:/Users/kazda/Desktop/wt']) {
    assert.throws(() => assertSafe(p, opts()), /not under the OS temp dir/);
  }
  assert.throws(() => assertSafe(TMP, opts()), /not under the OS temp dir/, 'the temp dir itself');
  assert.throws(() => assertSafe('relative/path', opts()), /not an absolute path/);
  assert.throws(() => assertSafe('', opts()), UnsafePath);
});

test('a symlink-style escape is judged by the real path', () => {
  const real = (p) => (p.endsWith('link') ? ROOT : p);
  assert.throws(() => assertSafe(`${TMP}/link`, opts({ realpath: real })), /repo root/);
});

test('removal and reuse require the marker, and the marker must belong to this checkout', () => {
  const dir = mkdtempSync(join(TMP, 'gtai-mutate-test-'));
  try {
    assert.throws(() => assertSafe(dir, { root: ROOT, tmp: TMP, requireMarker: true }), /no \.gtai-mutate-worktree marker/);
    assert.throws(() => removeWorktree({ root: ROOT, path: dir }), /marker/);
    writeFileSync(join(dir, MARKER), JSON.stringify({ root: 'C:/some/other/repo' }));
    assert.throws(() => assertSafe(dir, { root: ROOT, tmp: TMP, requireMarker: true }), /another checkout/);
    writeFileSync(join(dir, MARKER), JSON.stringify({ root: ROOT }));
    assert.doesNotThrow(() => assertSafe(dir, { root: ROOT, tmp: TMP, requireMarker: true }));
    assert.ok(existsSync(dir), 'the refusals deleted nothing');
  } finally {
    try { unlinkSync(join(dir, MARKER)); } catch { /* absent */ }
    rmdirSync(dir);
  }
});

test('sidecar crash repair restores the original bytes and removes the sidecar', () => {
  const wt = mkdtempSync(join(TMP, 'gtai-mutate-test-'));
  const dir = join(wt, 'project', 'core');
  mkdirSync(dir, { recursive: true });
  const file = join(dir, 'a.gd');
  const original = Buffer.from('func f() -> bool:\r\n\treturn a < b\r\n', 'utf8');
  try {
    writeSidecar(file, original);
    writeFileSync(file, 'func f() -> bool:\r\n\treturn a >= b\r\n'); // the "crash" left a mutant behind
    const repaired = repairSidecars(wt);
    assert.deepEqual(repaired.map(slash), [slash(file)]);
    assert.ok(readFileSync(file).equals(original));
    assert.ok(!existsSync(file + SIDECAR));
    assert.deepEqual(repairSidecars(wt), []);
    writeFileSync(file, 'x');
    restoreFile(file, original);
    assert.ok(readFileSync(file).equals(original));
  } finally {
    unlinkSync(file);
    rmdirSync(dir);
    rmdirSync(join(wt, 'project'));
    rmdirSync(wt);
  }
});
