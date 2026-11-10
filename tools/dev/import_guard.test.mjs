// dev/run refuses an LFS pointer and an --import that printed an import error (hero n11 REQUEST,
// it18 06:50: `git show HEAD:<png> > <png>` wrote a pointer, Godot imported it ERR_FILE_CORRUPT,
// exited 0, and the film drew without the sheet).
// Run: node --test tools/dev/import_guard.test.mjs
import assert from 'node:assert/strict';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { after, test } from 'node:test';
import { importErrors, main } from './run.mjs';
import { isLfsPointer } from '../lib/asset_cache.mjs';

const made = [];
after(() => { for (const d of made) rmSync(d, { recursive: true, force: true }); });
const tmp = () => { const d = mkdtempSync(join(tmpdir(), 'gtai-import-guard-')); made.push(d); return d; };

function harness(stale, importOut = '') {
  const calls = [];
  const lines = { out: [], err: [] };
  const opts = {
    runner: async (args) => { calls.push(args); return { status: 0, out: args[0] === '--import' ? importOut : '', timedOut: false, durationMs: 1 }; },
    out: (l) => lines.out.push(l), err: (l) => lines.err.push(l), logDir: tmp(),
    assets: () => stale, touch: () => {},
  };
  return { calls, lines, opts };
}

test('isLfsPointer: a pointer file is one, a PNG and a missing file are not', () => {
  const d = tmp();
  writeFileSync(join(d, 'p.png'), 'version https://git-lfs.github.com/spec/v1\noid sha256:ab\nsize 12\n');
  writeFileSync(join(d, 'r.png'), Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]));
  assert.equal(isLfsPointer(join(d, 'p.png')), true);
  assert.equal(isLfsPointer(join(d, 'r.png')), false);
  assert.equal(isLfsPointer(join(d, 'none.png')), false);
});

test('importErrors keeps the corrupt-file and error-importing lines only, CRLF or LF', () => {
  const out = 'ok\r\nERROR: Error importing \'res://a.png\'.\r\nload: ERR_FILE_CORRUPT\nreimport: res://b.png\n';
  assert.deepEqual(importErrors(out).map((l) => l.trim()), ["ERROR: Error importing 'res://a.png'.", 'load: ERR_FILE_CORRUPT']);
  assert.deepEqual(importErrors(undefined), []);
});

test('a stale asset that is an LFS pointer: exit 1, named, nothing imported or launched', async () => {
  const h = harness({ count: 1, sample: ['res://x.png'], pointers: ['res://x.png'] });
  assert.equal(await main(['arena'], h.opts), 1);
  assert.equal(h.calls.length, 0);
  assert.ok(h.lines.err.some((l) => l.includes('Git LFS pointers') && l.includes('res://x.png')), h.lines.err.join('\n'));
});

test('an --import that exits 0 but prints an import error: exit 1 with the line, nothing launched', async () => {
  const h = harness({ count: 1, sample: ['res://x.png'], pointers: [] }, 'ERROR: Error importing \'res://x.png\'.\n');
  assert.equal(await main(['arena'], h.opts), 1);
  assert.deepEqual(h.calls.map((a) => a[0]), ['--import']);
  assert.ok(h.lines.err.some((l) => l.includes("Error importing 'res://x.png'")), h.lines.err.join('\n'));
});

test('a clean --import still launches (no pointers field from an older fake is fine)', async () => {
  let n = 0;
  const h = harness({ count: 1, sample: ['res://x.png'] }, 'reimport: res://x.png\n');
  h.opts.assets = () => (n++ === 0 ? { count: 1, sample: ['res://x.png'] } : { count: 0, sample: [] });
  assert.equal(await main(['arena'], h.opts), 0, h.lines.err.join('\n'));
  assert.equal(h.calls.length, 2);
});
