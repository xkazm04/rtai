import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { mkdirSync, mkdtempSync, rmSync, statSync, utimesSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import test from 'node:test';
import { staleAssets, touchStale } from './asset_cache.mjs';

const OLD = new Date('2026-01-01T00:00:00Z');
const NEW = new Date('2026-06-01T00:00:00Z');

function project(t) {
  const root = mkdtempSync(join(tmpdir(), 'asset-cache-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  mkdirSync(join(root, '.godot', 'imported'), { recursive: true });
  return root;
}
const write = (root, rel, body) => { const f = join(root, rel); mkdirSync(dirname(f), { recursive: true }); writeFileSync(f, body); return f; };

/** One imported texture: the source, its .import, the .ctex and the recorded MD5. */
function imported(root, name, body, { recorded = body } = {}) {
  const src = write(root, `art/${name}.png`, body);
  write(root, `art/${name}.png.import`, `[remap]\n\n[deps]\n\nsource_file="res://art/${name}.png"\ndest_files=["res://.godot/imported/${name}.png-0123456789abcdef0123456789abcdef.ctex"]\n`);
  const dest = write(root, `.godot/imported/${name}.png-0123456789abcdef0123456789abcdef.ctex`, 'x');
  write(root, `.godot/imported/${name}.png-0123456789abcdef0123456789abcdef.md5`, `source_md5="${createHash('md5').update(recorded).digest('hex')}"\ndest_md5="0"\n`);
  utimesSync(src, OLD, OLD);
  utimesSync(dest, NEW, NEW);
  return src;
}

test('an asset whose import still matches is not stale, however new its file looks', (t) => {
  const root = project(t);
  const src = imported(root, 'a', 'same');
  assert.equal(staleAssets(root).count, 0);
  utimesSync(src, NEW, new Date(NEW.getTime() + 60000)); // a checkout or a copy touches the file, not the bytes
  assert.equal(staleAssets(root).count, 0);
});

test('a VRAM texture records its hash without the .bptc.ctex suffix', (t) => {
  const root = project(t);
  const hash = 'd61cb1662b3d535e6365084eaa725899';
  const src = write(root, 'art/baton.png', 'same');
  write(root, 'art/baton.png.import', `[deps]\nsource_file="res://art/baton.png"\ndest_files=["res://.godot/imported/baton.png-${hash}.bptc.ctex"]\n`);
  const dest = write(root, `.godot/imported/baton.png-${hash}.bptc.ctex`, 'x');
  write(root, `.godot/imported/baton.png-${hash}.md5`, `source_md5="${createHash('md5').update('same').digest('hex')}"\n`);
  utimesSync(src, NEW, new Date(NEW.getTime() + 60000));
  utimesSync(dest, OLD, OLD);
  assert.equal(staleAssets(root).count, 0);
});

test('a swapped asset is stale and named', (t) => {
  const root = project(t);
  const src = imported(root, 'helmet', 'new pixels', { recorded: 'old pixels' });
  utimesSync(src, NEW, new Date(NEW.getTime() + 60000));
  const r = staleAssets(root);
  assert.equal(r.count, 1);
  assert.deepEqual(r.sample, ['res://art/helmet.png']);
});

test('a missing .ctex or a missing recorded hash means it was never imported', (t) => {
  const root = project(t);
  imported(root, 'a', 'x');
  rmSync(join(root, '.godot/imported/a.png-0123456789abcdef0123456789abcdef.ctex'));
  assert.equal(staleAssets(root).count, 1);
  const other = project(t);
  imported(other, 'b', 'x');
  rmSync(join(other, '.godot/imported/b.png-0123456789abcdef0123456789abcdef.md5'));
  assert.equal(staleAssets(other).count, 1);
});

test('a new asset with no .import at all is stale; a .gdignore folder is left alone', (t) => {
  const root = project(t);
  write(root, 'art/fresh.png', 'x');
  write(root, 'ignored/.gdignore', '');
  write(root, 'ignored/raw.png', 'x');
  assert.deepEqual(staleAssets(root).sample, ['res://art/fresh.png']);
});

test('a tree with no import cache is not called stale here', (t) => {
  const root = mkdtempSync(join(tmpdir(), 'asset-cache-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  write(root, 'art/a.png', 'x');
  assert.equal(staleAssets(root).count, 0);
});

test('only five are named however many changed', (t) => {
  const root = project(t);
  for (let i = 0; i < 9; i += 1) write(root, `art/n${i}.png`, 'x');
  const r = staleAssets(root);
  assert.equal(r.count, 9);
  assert.equal(r.sample.length, 5);
});

test('touchStale dates only the stale source, so Godot, which trusts the date, re-imports it', (t) => {
  const root = project(t);
  const changed = imported(root, 'a', 'new bytes', { recorded: 'old bytes' });
  const same = imported(root, 'b', 'same');
  const before = statSync(same).mtimeMs;
  touchStale(root);
  assert.ok(statSync(changed).mtimeMs > OLD.getTime() + 1000, 'the changed source got a new date');
  assert.equal(statSync(same).mtimeMs, before, 'a source that matches keeps its date');
});

test('a second scan does not hash a source that is unchanged, and a changed one is hashed again', (t) => {
  const root = project(t);
  const src = imported(root, 'a', 'same');
  assert.equal(staleAssets(root).count, 0);
  writeFileSync(src, 'bytes of the same size is not the point: this is longer');
  utimesSync(src, OLD, OLD);
  assert.equal(staleAssets(root).count, 1, 'size differs from the stamp, so the hash is taken again');
});
