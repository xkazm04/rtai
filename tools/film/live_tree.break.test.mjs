import assert from 'node:assert/strict';
import test from 'node:test';
import { execFileSync } from 'node:child_process';
import { mkdirSync, mkdtempSync, rmSync, statSync, utimesSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { withoutGitEnv } from '../lint/lint.mjs';
import { main } from './kill_reel.mjs';
import { dirtyStartLine, movedLine, treeMoves, treeState } from './live_tree.mjs';
import { filmedRoot } from './side.mjs';

function fakeGit(head, status, failure = null) {
  return (_tree, command) => {
    if (command === failure) throw new Error(`${command} failed`);
    if (command === 'rev-parse') return `${head}\n`;
    if (command === 'status') return status;
    throw new Error(`unexpected git command ${command}`);
  };
}

function throwaway(t) {
  const repo = mkdtempSync(join(tmpdir(), 'gtai-live-break-'));
  t.after(() => rmSync(repo, { recursive: true, force: true }));
  const env = {
    ...withoutGitEnv(),
    GIT_CONFIG_NOSYSTEM: '1',
    GIT_CONFIG_GLOBAL: join(repo, 'missing-git-config'),
  };
  const git = (tree, ...args) => execFileSync(
    'git',
    ['-C', tree, '-c', 'user.name=t', '-c', 'user.email=t@t', ...args],
    { encoding: 'utf8', env, stdio: ['ignore', 'pipe', 'pipe'] },
  );
  git(repo, 'init', '-q');
  mkdirSync(join(repo, 'project', 'core'), { recursive: true });
  writeFileSync(join(repo, 'project', 'core', 'base.gd'), 'extends Node\n');
  writeFileSync(join(repo, 'outside.txt'), 'outside\n');
  git(repo, 'add', 'project/core/base.gd', 'outside.txt');
  git(repo, 'commit', '-qm', 'base');
  return { repo, git };
}

test('treeState attacks quoted paths, renames, stat failures, and CRLF porcelain without corrupting names', () => {
  const head = 'a'.repeat(40);
  const status = [
    ' M "project/core/path with spaces.gd"',
    'R  project/core/old.gd -> project/core/new.gd',
    ' D project/core/deleted.gd',
    '?? project/features/new/nested.gd',
    '',
  ].join('\r\n');
  const stamps = new Map([
    ['project/core/path with spaces.gd', { size: 11, mtimeMs: 20.4 }],
    ['project/core/new.gd', { size: 12, mtimeMs: 20.5 }],
    ['project/features/new/nested.gd', { size: 13, mtimeMs: 21.6 }],
  ]);
  const asked = [];
  const state = treeState('C:/fake', {
    git: fakeGit(head, status),
    stat: (path) => {
      const relative = path.replaceAll('\\', '/').replace('C:/fake/', '');
      asked.push(relative);
      if (relative === 'project/core/deleted.gd') throw new Error('ENOENT');
      assert.ok(stamps.has(relative), `stat received the exact porcelain path: ${relative}`);
      return stamps.get(relative);
    },
  });
  assert.deepEqual(state, {
    head,
    paths: {
      'project/core/path with spaces.gd': '11@20',
      'project/core/new.gd': '12@21',
      'project/core/deleted.gd': 'gone',
      'project/features/new/nested.gd': '13@22',
    },
  });
  assert.deepEqual(asked, [
    'project/core/path with spaces.gd',
    'project/core/new.gd',
    'project/core/deleted.gd',
    'project/features/new/nested.gd',
  ]);
});

test('treeState attacks a status failure after rev-parse and returns null instead of a partial state', () => {
  assert.equal(treeState('C:/fake', {
    git: fakeGit('b'.repeat(40), '', 'status'),
    stat: () => assert.fail('a failed status must not stat anything'),
  }), null);
});

test('treeState attacks same-rounded-millisecond edits and detects the changed size', (t) => {
  const { repo, git } = throwaway(t);
  const file = join(repo, 'project', 'core', 'base.gd');
  writeFileSync(file, 'one\n');
  const fixed = new Date(Math.floor(Date.now() / 1000) * 1000);
  utimesSync(file, fixed, fixed);
  const before = treeState(repo, { git });
  writeFileSync(file, 'a different byte count\n');
  utimesSync(file, fixed, fixed);
  const after = treeState(repo, { git });
  assert.equal(Math.round(statSync(file).mtimeMs), fixed.getTime());
  assert.notEqual(before.paths['project/core/base.gd'], after.paths['project/core/base.gd']);
  assert.deepEqual(treeMoves(before, after), ['1 project/ path(s) changed (project/core/base.gd)']);
});

test('treeState attacks scope and completeness with nested untracked, staged, modified, renamed, and deleted paths', (t) => {
  const { repo, git } = throwaway(t);
  writeFileSync(join(repo, 'project', 'core', 'delete_me.gd'), 'class_name DeleteMe\n');
  git(repo, 'add', 'project/core/delete_me.gd');
  git(repo, 'commit', '-qm', 'add deletion target');
  writeFileSync(join(repo, 'project', 'core', 'base.gd'), 'extends Node2D\n');
  writeFileSync(join(repo, 'project', 'core', 'staged.gd'), 'class_name Staged\n');
  git(repo, 'add', 'project/core/staged.gd');
  git(repo, 'mv', 'project/core/base.gd', 'project/core/renamed.gd');
  mkdirSync(join(repo, 'project', 'features', 'brand_new'), { recursive: true });
  writeFileSync(join(repo, 'project', 'features', 'brand_new', 'nested.gd'), 'class_name Nested\n');
  writeFileSync(join(repo, 'outside.txt'), 'must not count\n');
  rmSync(join(repo, 'project', 'core', 'delete_me.gd'));
  const state = treeState(repo, { git });
  assert.deepEqual(Object.keys(state.paths).sort(), [
    'project/core/delete_me.gd',
    'project/core/renamed.gd',
    'project/core/staged.gd',
    'project/features/brand_new/nested.gd',
  ]);
  assert.equal(state.paths['project/core/delete_me.gd'], 'gone');
  assert.ok(!('outside.txt' in state.paths));
});

test('treeMoves attacks a dirty path committed away while HEAD moves and reports both changes', (t) => {
  const { repo, git } = throwaway(t);
  writeFileSync(join(repo, 'project', 'core', 'base.gd'), 'extends Node2D\n');
  const before = treeState(repo, { git });
  git(repo, 'add', 'project/core/base.gd');
  git(repo, 'commit', '-qm', 'commit dirty path');
  const after = treeState(repo, { git });
  assert.deepEqual(treeMoves(before, after), [
    `HEAD ${before.head.slice(0, 9)} -> ${after.head.slice(0, 9)}`,
    '1 project/ path(s) changed (project/core/base.gd)',
  ]);
  assert.equal(treeMoves(null, after).length, 0);
  assert.equal(treeMoves(before, null).length, 0);
});

test('treeMoves attacks four unsorted changed paths and limits its sorted sample to three', () => {
  const before = { head: '1'.repeat(40), paths: { 'project/z.gd': '1@1', 'project/b.gd': '2@2' } };
  const after = { head: '1'.repeat(40), paths: { 'project/a.gd': '3@3', 'project/c.gd': '4@4' } };
  assert.deepEqual(treeMoves(before, after), [
    '4 project/ path(s) changed (project/a.gd, project/b.gd, project/c.gd, ...)',
  ]);
});

test('warning helpers attack empty states, samples, labels, and stable-revision advice', () => {
  assert.equal(dirtyStartLine(null, 2), null);
  assert.equal(dirtyStartLine({ head: 'a', paths: {} }, 2), null);
  const dirty = dirtyStartLine({ head: 'a', paths: {
    'project/a.gd': '1@1', 'project/b.gd': '2@2', 'project/c.gd': '3@3', 'project/d.gd': '4@4',
  } }, 7);
  assert.match(dirty, /4 uncommitted project\/ path\(s\) \(project\/a\.gd, project\/b\.gd, project\/c\.gd, \.\.\.\)/);
  assert.match(dirty, /each of the 7 film\(s\).*--rev=HEAD/);
  assert.equal(movedLine('label', { head: 'a', paths: {} }, { head: 'a', paths: {} }), null);
  assert.match(movedLine('after pistol dir 90 32 px/m',
    { head: 'a'.repeat(40), paths: {} }, { head: 'b'.repeat(40), paths: {} }),
  /^kill_reel: the live tree moved since the reel began \(HEAD aaaaaaaaa -> bbbbbbbbb\): after pistol dir 90 32 px\/m .*--rev=<commit>$/);
});

test('kill_reel main attacks live versus --rev state calls and warns before a launch-free dry run', async () => {
  const liveLines = [];
  const calls = [];
  const runner = () => assert.fail('a dry run must launch nothing');
  const state = (tree) => {
    calls.push(tree);
    return { head: 'c'.repeat(40), paths: { 'project/a.gd': '1@1' } };
  };
  assert.equal(await main(['--out=x', '--weapons=katana', '--quick', '--dry-run'], {
    out: (line) => liveLines.push(line), err: (line) => liveLines.push(line), runner, state,
  }), 0);
  assert.equal(calls.length, 1, 'the one live after side is sampled once at dry-run start');
  assert.equal(liveLines.filter((line) => line.includes('uncommitted project/ path')).length, 1);
  assert.ok(liveLines.findIndex((line) => line.includes('uncommitted project/ path'))
    < liveLines.findIndex((line) => line === 'kill_reel: dry run, nothing launched'));

  const pinnedLines = [];
  const resolveSide = () => ({ tree: filmedRoot(), label: 'pinned', snapshot: true, injected: false });
  assert.equal(await main(['--out=x', '--weapons=katana', '--quick', '--rev=HEAD', '--dry-run'], {
    out: (line) => pinnedLines.push(line), err: (line) => pinnedLines.push(line), runner, resolveSide,
    state: () => assert.fail('a --rev after side must never ask for live tree state'),
  }), 0);
  assert.ok(!pinnedLines.some((line) => line.includes('uncommitted project/ path')));
});
