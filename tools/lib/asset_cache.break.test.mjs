import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { mkdirSync, mkdtempSync, rmSync, utimesSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import test from 'node:test';
import { staleAssets } from './asset_cache.mjs';

const OLD = new Date('2025-01-01T00:00:00Z');
const NEW = new Date('2026-01-01T00:00:00Z');
const HASH = '0123456789abcdef0123456789abcdef';
const digest = (body) => createHash('md5').update(body).digest('hex');

function project(t, cache = true) {
  const root = mkdtempSync(join(tmpdir(), 'asset-cache-break-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  if (cache) mkdirSync(join(root, '.godot/imported'), { recursive: true });
  return root;
}

function write(root, rel, body) {
  const file = join(root, rel);
  mkdirSync(dirname(file), { recursive: true });
  writeFileSync(file, body);
  return file;
}

function imported(root, { name = 'art/source.png', body = 'pixels', recorded = body,
  newline = '\n', suffixes = ['ctex'], sourceNew = true } = {}) {
  const src = write(root, name, body);
  const stem = `.godot/imported/texture-${HASH}`;
  const dests = suffixes.map((suffix) => `${stem}.${suffix}`);
  const text = `[deps]${newline}source_file="res://${name}"${newline}dest_files=[${dests.map((d) => `"res://${d}"`).join(', ')}]${newline}`;
  write(root, `${name}.import`, text);
  for (const dest of dests) {
    const file = write(root, dest, 'imported');
    utimesSync(file, sourceNew ? OLD : NEW, sourceNew ? OLD : NEW);
  }
  const record = write(root, `${stem}.md5`, `source_md5="${digest(recorded)}"${newline}`);
  utimesSync(src, sourceNew ? NEW : OLD, sourceNew ? NEW : OLD);
  return { src, name, dests, record, text };
}

function assertStale(root, name) {
  const result = staleAssets(root);
  assert.equal(result.count, 1);
  assert.deepEqual(result.sample, [`res://${name}`]);
}

test('a matching import stays fresh despite a new timestamp, spaces, uppercase extension and hex-like name', (t) => {
  const root = project(t);
  imported(root, { name: `art with spaces/dead-beef-${HASH}.PNG`, newline: '\r\n', suffixes: ['bptc.ctex'] });
  assert.deepEqual(staleAssets(root), { count: 0, sample: [] });
});

test('a changed asset with spaces, uppercase extension and CRLF import is stale and named', (t) => {
  const root = project(t);
  const { name } = imported(root, { name: 'art with spaces/face-deadbeef.PNG', recorded: 'old', newline: '\r\n' });
  assertStale(root, name);
});

for (const missing of ['first destination', 'second destination', 'record file']) {
  test(`a missing ${missing} is stale even when the source timestamp is old`, (t) => {
    const root = project(t);
    const asset = imported(root, { sourceNew: false, suffixes: ['s3tc.ctex', 'bptc.ctex'] });
    const file = missing === 'record file' ? asset.record : join(root, asset.dests[missing === 'first destination' ? 0 : 1]);
    rmSync(file);
    assertStale(root, asset.name);
  });
}

for (const sourceNew of [true, false]) {
  test(`a missing source_md5 in an existing record is stale with ${sourceNew ? 'a new' : 'an old'} source timestamp`, (t) => {
    const root = project(t);
    const asset = imported(root, { sourceNew });
    writeFileSync(asset.record, 'dest_md5="abcdef"\r\n');
    assertStale(root, asset.name);
  });
}

for (const destLine of ['', 'dest_files=[]\r\n']) {
  test(`an asset with ${destLine ? 'empty' : 'no'} dest_files cannot hide its missing imported output`, (t) => {
    const root = project(t);
    const name = 'art/missing-output.png';
    write(root, name, 'pixels');
    write(root, `${name}.import`, `[deps]\r\nsource_file="res://${name}"\r\n${destLine}`);
    assertStale(root, name);
  });
}

test('odd quotes inside a double-quoted source path cannot hide a changed asset', (t) => {
  const root = project(t);
  const asset = imported(root, { name: "art/face 'dead-beef'.png", recorded: 'old' });
  assertStale(root, asset.name);
});

test('a changed asset is named even when a copy preserved its old timestamp', (t) => {
  const root = project(t);
  const { name } = imported(root, { recorded: 'old pixels', sourceNew: false });
  assertStale(root, name);
});

test('folders with .gdignore leave changed imports and uppercase unimported assets alone', (t) => {
  const root = project(t);
  imported(root, { name: 'ignored/nested/changed.PNG', recorded: 'old' });
  write(root, 'ignored/new.WAV', 'audio');
  write(root, 'ignored/.gdignore', '');
  write(root, 'visible/fresh.OTF', 'font');
  assertStale(root, 'visible/fresh.OTF');
});

test('a tree with no import cache is not stale despite broken imports and uppercase assets', (t) => {
  const root = project(t, false);
  write(root, 'art/new.PNG', 'pixels');
  write(root, 'art/broken.png', 'pixels');
  write(root, 'art/broken.png.import', '[deps]\nsource_file="res://art/broken.png"\ndest_files=[]\n');
  assert.deepEqual(staleAssets(root), { count: 0, sample: [] });
});
