import { test } from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, mkdirSync, mkdtempSync, rmSync, utimesSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { exportArgs, exportChecked, outPath } from './export_checked.mjs';

const tmpRoot = (t) => {
  const root = mkdtempSync(join(tmpdir(), 'export-out-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  return root;
};
/** A fake Godot that writes the exe where Godot would. */
const writes = (root, out, bytes = 'MZ') => async () => { writeFileSync(outPath(out, root), bytes); return 0; };

const OK = { ok: true, expected: 256, missing: [], mismatched: [] };

test('exportArgs is the release export command', () => {
  assert.deepEqual(exportArgs('../build/export/windows/RTAI.exe'), ['--headless', '--path', 'project', '--export-release', 'windows-showcase', '../build/export/windows/RTAI.exe']);
});

test('a baked tree exports', async (t) => {
  const root = tmpRoot(t);
  let args = null;
  const write = writes(root, 'x.exe');
  const r = await exportChecked({ out: 'x.exe', root, check: () => OK, run: async (a) => { args = a; return write(); } });
  assert.equal(r.ok, true);
  assert.deepEqual(args, exportArgs('x.exe'));
});

test('exit 0 with no exe written is not ok, and says so', async (t) => {
  const root = tmpRoot(t);
  const r = await exportChecked({ out: 'x.exe', root, check: () => OK, run: async () => 0 });
  assert.equal(r.ok, false);
  assert.match(r.reason, /wrote no/);
});

test('exit 0 over a stale exe from an earlier export is not ok', async (t) => {
  const root = tmpRoot(t);
  mkdirSync(join(root, 'project'));
  writeFileSync(outPath('x.exe', root), 'MZ');
  const old = new Date(Date.now() - 3600 * 1000);
  utimesSync(outPath('x.exe', root), old, old);
  const r = await exportChecked({ out: 'x.exe', root, check: () => OK, run: async () => 0 });
  assert.equal(r.ok, false);
  assert.match(r.reason, /did not rewrite/);
});

test('exit 0 with an empty exe is not ok', async (t) => {
  const root = tmpRoot(t);
  const r = await exportChecked({ out: 'x.exe', root, check: () => OK, run: writes(root, 'x.exe', '') });
  assert.equal(r.ok, false);
  assert.match(r.reason, /empty/);
});

test('an unbaked tree refuses and never starts the export', async () => {
  let ran = false;
  const r = await exportChecked({ out: 'x.exe', check: () => ({ ok: false, expected: 2, missing: ['a.bin'], mismatched: [] }), run: async () => { ran = true; return 0; } });
  assert.equal(ran, false);
  assert.equal(r.ok, false);
  assert.match(r.reason, /a\.bin|1 missing|missing/);
});

test('a failing export is not ok and carries its exit code', async () => {
  const r = await exportChecked({ out: 'x.exe', check: () => OK, run: async () => 3 });
  assert.equal(r.ok, false);
  assert.equal(r.code, 3);
});

test('a check that throws refuses instead of exporting', async () => {
  let ran = false;
  const r = await exportChecked({ out: 'x.exe', check: () => { throw new Error('boom'); }, run: async () => { ran = true; return 0; } });
  assert.equal(ran, false);
  assert.equal(r.ok, false);
});

test('the output folder is made before Godot starts, resolved against project/ (fresh worktree)', async (t) => {
  const root = tmpRoot(t);
  const out = '../build/export/windows/RTAI.exe';
  assert.equal(outPath(out, root), join(root, 'build', 'export', 'windows', 'RTAI.exe'));
  let seen = null;
  const write = writes(root, out);
  const r = await exportChecked({ out, root, check: () => OK, run: async () => { seen = existsSync(dirname(outPath(out, root))); return write(); } });
  assert.equal(r.ok, true);
  assert.equal(seen, true, 'the folder existed when the export ran');
});

test('a refused export makes no folder', async (t) => {
  const root = mkdtempSync(join(tmpdir(), 'export-out-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  await exportChecked({ out: '../build/export/w/RTAI.exe', root, check: () => ({ ok: false, missing: ['a'] }), run: async () => 0 });
  assert.equal(existsSync(join(root, 'build')), false);
});
