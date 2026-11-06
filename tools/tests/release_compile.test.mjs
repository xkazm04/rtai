// The guard must refuse every dangerous dest without deleting anything. Fixtures live under
// os.tmpdir(); the real project is never passed to anything that deletes.
import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, mkdirSync, mkdtempSync, rmSync, symlinkSync, writeFileSync } from 'node:fs';
import { homedir, tmpdir } from 'node:os';
import { join, parse } from 'node:path';
import { MARKER, Refused, guardDest, removeMarked, stageRelease } from './release_compile.mjs';

const fixture = () => {
  const base = mkdtempSync(join(tmpdir(), 'gtai-rc-test-'));
  const root = join(base, 'repo');
  const src = join(root, 'project');
  mkdirSync(join(src, 'tests'), { recursive: true });
  mkdirSync(join(src, 'dev'));
  mkdirSync(join(src, 'features'));
  writeFileSync(join(src, 'tests', 'load_release.gd'), 'extends SceneTree\n');
  writeFileSync(join(src, 'features', 'a.gd'), 'x\n');
  writeFileSync(join(src, 'dev', 'd.gd'), 'x\n');
  // Only the fixture dir is ever deleted, and only after proving it is the fixture.
  const done = () => {
    if (base.startsWith(tmpdir()) && base.includes('gtai-rc-test-')) {
      rmSync(base, { recursive: true, force: true });
    }
  };
  return { base, root, src, done };
};

test('refuses dest = src, repo root, inside the repo, its parent, home, a drive root', () => {
  const f = fixture();
  try {
    for (const dest of [f.src, f.root, join(f.root, 'build'), f.base, homedir(), parse(f.base).root]) {
      assert.throws(() => stageRelease(dest, f.src, f.root), Refused, dest);
    }
    assert.ok(existsSync(join(f.src, 'features', 'a.gd')), 'nothing was deleted');
    assert.ok(existsSync(join(f.src, 'dev', 'd.gd')));
  } finally {
    f.done();
  }
});

test('refuses "." and "project" when cwd is the repo root', () => {
  const f = fixture();
  const prev = process.cwd();
  try {
    process.chdir(f.root);
    assert.throws(() => stageRelease('.', f.src, f.root), Refused);
    assert.throws(() => stageRelease('project', f.src, f.root), Refused);
    assert.ok(existsSync(join(f.src, 'features', 'a.gd')));
  } finally {
    process.chdir(prev);
    f.done();
  }
});

test('refuses an unmarked existing directory and leaves it intact', () => {
  const f = fixture();
  try {
    const d = join(f.base, 'scratch');
    mkdirSync(d);
    writeFileSync(join(d, 'precious.txt'), 'keep');
    assert.throws(() => stageRelease(d, f.src, f.root), Refused);
    assert.throws(() => removeMarked(d), Refused);
    assert.ok(existsSync(join(d, 'precious.txt')));
  } finally {
    f.done();
  }
});

test('refuses a dest reached through a link to the project', (t) => {
  const f = fixture();
  try {
    const link = join(f.base, 'lnk');
    try {
      symlinkSync(f.src, link, 'junction');
    } catch {
      t.skip('cannot create a link here');
      return;
    }
    assert.throws(() => guardDest(link, f.src, f.root), Refused);
    assert.throws(() => stageRelease(link, f.src, f.root), Refused);
    assert.ok(existsSync(join(f.src, 'features', 'a.gd')));
  } finally {
    f.done();
  }
});

test('stages a marked copy without the excluded dirs, and removes a marked dir', () => {
  const f = fixture();
  try {
    const d = stageRelease(join(f.base, 'out'), f.src, f.root);
    assert.ok(existsSync(join(d, MARKER)));
    assert.ok(existsSync(join(d, 'features', 'a.gd')));
    assert.ok(existsSync(join(d, 'load_release.gd')));
    assert.ok(!existsSync(join(d, 'dev')) && !existsSync(join(d, 'tests')));
    stageRelease(d, f.src, f.root); // re-staging over its own marked dir is allowed
    removeMarked(d);
    assert.ok(!existsSync(d));
    assert.ok(existsSync(join(f.src, 'dev', 'd.gd')), 'source untouched');
  } finally {
    f.done();
  }
});
