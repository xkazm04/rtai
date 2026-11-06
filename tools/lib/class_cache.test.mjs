// node --test tools/lib/
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { mkdirSync, mkdtempSync, rmdirSync, rmSync, utimesSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { declaredClass, isStale, parseCache } from './class_cache.mjs';

const entry = (name, base, path) => `{\n"base": &"${base}",\n"class": &"${name}",\n"icon": "",\n"is_abstract": false,\n"is_tool": false,\n"language": &"GDScript",\n"path": "${path}"\n}`;
const cacheText = (...entries) => `list=[${entries.join(', ')}]\n`;

/** A fixture project under os.tmpdir(): files = {relative path: text}; cache = entries text or null. */
function fixture(files, cache) {
  const dir = mkdtempSync(join(tmpdir(), 'gtai-cc-'));
  const made = new Set();
  const put = (rel, text) => {
    const abs = join(dir, rel);
    mkdirSync(dirname(abs), { recursive: true });
    writeFileSync(abs, text);
    made.add(abs);
    return abs;
  };
  for (const [rel, text] of Object.entries(files)) put(rel, text);
  if (cache !== null) put(join('.godot', 'global_script_class_cache.cfg'), cache);
  // delete only the files this fixture wrote, then its (now empty) folders: no recursive delete
  const done = () => {
    const dirs = new Set([dir]);
    for (const abs of made) {
      rmSync(abs, { force: true, recursive: false });
      for (let d = dirname(abs); d.length > dir.length; d = dirname(d)) dirs.add(d);
    }
    for (const d of [...dirs].sort((a, b) => b.length - a.length)) rmdirSync(d);
  };
  return { dir, put, done };
}

const A = 'class_name Alpha\nextends RefCounted\n';

test('parseCache reads class, base and path', () => {
  const list = parseCache(cacheText(entry('Alpha', 'RefCounted', 'res://a.gd'), entry('Beta', 'Node', 'res://b/b.gd')));
  assert.deepEqual(list, [
    { name: 'Alpha', base: 'RefCounted', path: 'res://a.gd' },
    { name: 'Beta', base: 'Node', path: 'res://b/b.gd' },
  ]);
});

test('declaredClass handles @abstract on the same line, extends on the same line, and no class', () => {
  assert.deepEqual(declaredClass('@abstract class_name Scenario\nextends RefCounted\n'), { name: 'Scenario', base: 'RefCounted' });
  assert.deepEqual(declaredClass('class_name X extends Node2D\n'), { name: 'X', base: 'Node2D' });
  assert.equal(declaredClass('extends Node\nvar a = 1\n'), null);
});

test('missing cache is stale', () => {
  const f = fixture({ 'a.gd': A }, null);
  try {
    const r = isStale(f.dir);
    assert.ok(r.stale);
    assert.match(r.reason, /missing/);
  } finally { f.done(); }
});

test('a matching cache is fresh, and a body edit of a class file does not make it stale', () => {
  const f = fixture({ 'a.gd': A }, cacheText(entry('Alpha', 'RefCounted', 'res://a.gd')));
  try {
    assert.equal(isStale(f.dir).stale, false);
    const abs = f.put('a.gd', `${A}\nfunc x() -> int:\n\treturn 2\n`);
    const later = new Date(Date.now() + 60000);
    utimesSync(abs, later, later);
    assert.equal(isStale(f.dir).stale, false);
  } finally { f.done(); }
});

test('a new class_name file absent from the cache is stale, even when older than the cache', () => {
  const f = fixture({ 'a.gd': A, 'sub/b.gd': 'class_name Beta\nextends Node\n' }, cacheText(entry('Alpha', 'RefCounted', 'res://a.gd')));
  try {
    const r = isStale(f.dir);
    assert.ok(r.stale);
    assert.match(r.reason, /Beta/);
  } finally { f.done(); }
});

test('a cached path that no longer exists is stale', () => {
  const f = fixture({ 'a.gd': A }, cacheText(entry('Alpha', 'RefCounted', 'res://a.gd'), entry('Gone', 'Node', 'res://gone.gd')));
  try {
    const r = isStale(f.dir);
    assert.ok(r.stale);
    assert.match(r.reason, /Gone/);
  } finally { f.done(); }
});

test('a renamed class and a changed base are stale; files without class_name are ignored', () => {
  const f = fixture({ 'a.gd': 'class_name Alpha2\nextends RefCounted\n', 'plain.gd': 'extends Node\n' },
    cacheText(entry('Alpha', 'RefCounted', 'res://a.gd')));
  try {
    const later = new Date(Date.now() + 60000);
    utimesSync(join(f.dir, 'a.gd'), later, later); // an edited file is newer than the cache
    assert.match(isStale(f.dir).reason, /Alpha2/);
    const abs = f.put('a.gd', 'class_name Alpha\nextends Node\n');
    utimesSync(abs, later, later);
    assert.match(isStale(f.dir).reason, /extends Node/);
  } finally { f.done(); }
});

test('.godot and .gdignore folders are not scanned', () => {
  const f = fixture({
    'a.gd': A,
    '.godot/junk.gd': 'class_name Junk\n',
    'ignored/.gdignore': '',
    'ignored/x.gd': 'class_name Hidden\n',
  }, cacheText(entry('Alpha', 'RefCounted', 'res://a.gd')));
  try {
    assert.equal(isStale(f.dir).stale, false);
  } finally { f.done(); }
});
