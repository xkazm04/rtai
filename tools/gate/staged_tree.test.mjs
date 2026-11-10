import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { driftPaths, exportIndex, PREFIX, removeExport, wanted } from './staged_tree.mjs';
import { lintTarget, main } from './precommit.mjs';
import { withoutGitEnv } from '../lint/lint.mjs';

// Never the hook's GIT_DIR / GIT_INDEX_FILE: with them a temp repo test commits into the real repo.
const env = withoutGitEnv();
const gitWith = (extra = {}) => (c, a, o) => spawnSync(c, a, { ...o, env: { ...env, ...extra } });

function repo() {
  const dir = mkdtempSync(join(tmpdir(), 'gtai-stagedtree-repo-'));
  const git = (...a) => execFileSync('git', ['-C', dir, ...a], { encoding: 'utf8', windowsHide: true, env });
  git('init', '-q');
  git('config', 'core.autocrlf', 'false');
  for (const [p, body] of [['project/a.gd', 'good\n'], ['tools/t.mjs', 'x\n'], ['project/i.png', 'PNG'], ['JOURNAL.md', 'j\n'], ['docs/d.md', 'd\n']]) {
    mkdirSync(join(dir, p, '..'), { recursive: true });
    writeFileSync(join(dir, p), body);
  }
  git('add', '.');
  git('-c', 'user.email=t@t', '-c', 'user.name=t', 'commit', '-q', '-m', 'x', '--no-verify');
  return { dir, git };
}

test('wanted keeps text code and drops inert paths and binaries', () => {
  assert.equal(wanted('project/a.gd'), true);
  assert.equal(wanted('project/a.png.import'), true, 'an .import is text lint may read');
  assert.equal(wanted('project/a.PNG'), false);
  assert.equal(wanted('build/x.log'), false);
  assert.equal(wanted('JOURNAL.md'), false);
  assert.equal(wanted('docs/x.gd'), false);
});

test('a tree equal to the index has no drift and lints in place (real git)', () => {
  const { dir } = repo();
  try {
    writeFileSync(join(dir, 'JOURNAL.md'), 'unstaged inert edit\n');
    assert.deepEqual(driftPaths(dir, gitWith()), []);
    const t = lintTarget(dir, { git: gitWith(), exporter: () => assert.fail('no export for a clean tree') });
    assert.equal(t.dir, dir);
    assert.equal(t.line, null);
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test('an unstaged edit and an untracked file drift; the export holds the staged bytes only (real git)', () => {
  const { dir, git } = repo();
  try {
    writeFileSync(join(dir, 'project/a.gd'), 'staged fix\n');
    git('add', 'project/a.gd');
    writeFileSync(join(dir, 'project/a.gd'), 'half-edited, over the cap\n');
    writeFileSync(join(dir, 'project/new.gd'), 'untracked\n');
    assert.deepEqual(driftPaths(dir, gitWith()), ['project/a.gd', 'project/new.gd']);
    const { dir: out, count } = exportIndex(dir, gitWith());
    try {
      assert.equal(readFileSync(join(out, 'project/a.gd'), 'utf8'), 'staged fix\n');
      assert.equal(existsSync(join(out, 'project/new.gd')), false, 'an untracked file is not in the commit');
      assert.equal(existsSync(join(out, 'project/i.png')), false);
      assert.equal(existsSync(join(out, 'JOURNAL.md')), false);
      assert.equal(existsSync(join(out, 'tools/t.mjs')), true);
      assert.equal(count, 2);
    } finally { removeExport(out); }
    assert.equal(existsSync(out), false);
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test('the export follows GIT_INDEX_FILE, as `git commit <paths>` sets it (real git)', () => {
  const { dir, git } = repo();
  const alt = join(dir, '.git', 'alt-index');
  try {
    writeFileSync(join(dir, 'project/a.gd'), 'only in the alt index\n');
    execFileSync('git', ['-C', dir, 'add', 'project/a.gd'], { env: { ...env, GIT_INDEX_FILE: alt }, windowsHide: true });
    git('checkout', '--', '.');
    writeFileSync(join(dir, 'project/a.gd'), 'tree\n');
    const { dir: out } = exportIndex(dir, gitWith({ GIT_INDEX_FILE: alt }));
    try {
      assert.equal(readFileSync(join(out, 'project/a.gd'), 'utf8'), 'only in the alt index\n');
    } finally { removeExport(out); }
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test('removeExport refuses anything but a PREFIX child of the temp dir', () => {
  const other = mkdtempSync(join(tmpdir(), 'gtai-stagedtree-other-'));
  const nested = join(other, `${PREFIX}x`);
  mkdirSync(nested);
  try {
    assert.throws(() => removeExport(other), /refuses/);
    assert.throws(() => removeExport(nested), /refuses/, 'the prefix alone is not enough: it must sit in the temp dir');
    assert.equal(existsSync(nested), true);
  } finally { rmSync(other, { recursive: true, force: true }); }
});

test('no snapshot means the tree, and the line says it is not the commit', () => {
  const failing = () => ({ status: 128, stdout: '' });
  assert.match(lintTarget('/r', { git: failing }).line, /no staged snapshot \(git could not list the unstaged paths\): linting the WORKING TREE/);
  const drifting = () => ({ status: 0, stdout: 'project/a.gd\0' });
  const t = lintTarget('/r', { git: drifting, exporter: () => { throw new Error('disk full'); } });
  assert.equal(t.dir, '/r');
  assert.match(t.line, /no staged snapshot \(disk full\)/);
});

test('main lints the export without GIT_ variables and always removes it', () => {
  const git = () => ({ status: 0, stdout: 'project/a.gd\0' });
  const removed = [];
  const lines = [];
  let seen = null;
  const lint = (cmd, args, o) => { seen = { args, o }; throw new Error('lint crashed'); };
  assert.throws(() => main({ cwd: '/r', git, lint, err: (l) => lines.push(l), exporter: () => ({ dir: '/tmp/gtai-precommit-1', count: 9 }), remover: (d) => removed.push(d) }), /lint crashed/);
  assert.deepEqual(removed, ['/tmp/gtai-precommit-1']);
  assert.equal(seen.o.cwd, '/tmp/gtai-precommit-1');
  assert.match(seen.args[0].replace(/\\/g, '/'), /gtai-precommit-1\/tools\/lint\/lint\.mjs$/);
  assert.equal(Object.keys(seen.o.env).some((k) => /^GIT_/i.test(k)), false);
  assert.match(lines.at(-1), /1 path\(s\) in your tree differ from what you commit \(project\/a\.gd\): linting the staged snapshot \(9 files\)/);
});
