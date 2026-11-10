import { test } from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { exportArgs, exportChecked, outPath } from './export_checked.mjs';

const OK = { ok: true, expected: 256, missing: [], mismatched: [] };

test('exportArgs is the release export command', () => {
  assert.deepEqual(exportArgs('../build/export/windows/RTAI.exe'), ['--headless', '--path', 'project', '--export-release', 'windows-showcase', '../build/export/windows/RTAI.exe']);
});

test('a baked tree exports', async () => {
  let args = null;
  const r = await exportChecked({ out: 'x.exe', check: () => OK, run: async (a) => { args = a; return 0; } });
  assert.equal(r.ok, true);
  assert.deepEqual(args, exportArgs('x.exe'));
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
  const root = mkdtempSync(join(tmpdir(), 'export-out-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  const out = '../build/export/windows/RTAI.exe';
  assert.equal(outPath(out, root), join(root, 'build', 'export', 'windows', 'RTAI.exe'));
  let seen = null;
  const r = await exportChecked({ out, root, check: () => OK, run: async () => { seen = existsSync(dirname(outPath(out, root))); return 0; } });
  assert.equal(r.ok, true);
  assert.equal(seen, true, 'the folder existed when the export ran');
});

test('a refused export makes no folder', async (t) => {
  const root = mkdtempSync(join(tmpdir(), 'export-out-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  await exportChecked({ out: '../build/export/w/RTAI.exe', root, check: () => ({ ok: false, missing: ['a'] }), run: async () => 0 });
  assert.equal(existsSync(join(root, 'build')), false);
});
