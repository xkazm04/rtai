import assert from 'node:assert/strict';
import test from 'node:test';
import { execFileSync } from 'node:child_process';
import { mkdirSync, mkdtempSync, rmSync, utimesSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { withoutGitEnv } from '../lint/lint.mjs';
import { dirtyStartLine, movedLine, porcelainPath, treeMoves, treeState, unquote } from './live_tree.mjs';
import { main } from './kill_reel.mjs';
import { filmedRoot } from './side.mjs';

function throwaway(t) {
  const repo = mkdtempSync(join(tmpdir(), 'gtai-live-'));
  t.after(() => rmSync(repo, { recursive: true, force: true }));
  const env = { ...withoutGitEnv(), GIT_CONFIG_NOSYSTEM: '1', GIT_CONFIG_GLOBAL: join(repo, 'none') };
  const git = (tree, ...a) => execFileSync('git', ['-C', tree, '-c', 'user.name=t', '-c', 'user.email=t@t', ...a], { encoding: 'utf8', env, stdio: ['ignore', 'pipe', 'pipe'] });
  git(repo, 'init', '-q');
  mkdirSync(join(repo, 'project', 'core'), { recursive: true });
  writeFileSync(join(repo, 'project', 'core', 'a.gd'), 'extends Node\n');
  writeFileSync(join(repo, 'notes.md'), 'x\n');
  git(repo, 'add', 'project/core/a.gd', 'notes.md');
  git(repo, 'commit', '-qm', 'one');
  return { repo, git };
}

test('a clean tree has its HEAD and no paths; outside project/ does not count', (t) => {
  const { repo, git } = throwaway(t);
  writeFileSync(join(repo, 'notes.md'), 'edited\n');
  const s = treeState(repo, { git });
  assert.match(s.head, /^[0-9a-f]{40}$/);
  assert.deepEqual(s.paths, {});
  assert.equal(dirtyStartLine(s, 4), null);
  assert.equal(treeState(join(repo, 'project', 'core', 'nowhere'), { git }), null, 'not a git tree: unknown, not clean');
});

test('an edit, a new untracked class (even in a new folder) and a deletion each show; an edit to an already dirty file moves', (t) => {
  const { repo, git } = throwaway(t);
  writeFileSync(join(repo, 'project', 'core', 'a.gd'), 'extends Node2D\n');
  const begin = treeState(repo, { git });
  assert.deepEqual(Object.keys(begin.paths), ['project/core/a.gd']);
  assert.match(dirtyStartLine(begin, 6), /1 uncommitted project\/ path\(s\) \(project\/core\/a\.gd\); each of the 6 film\(s\).*--rev=HEAD/);
  assert.deepEqual(treeMoves(begin, treeState(repo, { git })), [], 'nothing moved, nothing said');
  mkdirSync(join(repo, 'project', 'features', 'kills'), { recursive: true });
  writeFileSync(join(repo, 'project', 'features', 'kills', 'kill_new.gd'), 'class_name KillNew\n');
  utimesSync(join(repo, 'project', 'core', 'a.gd'), new Date(), new Date(Date.now() + 5000));
  const later = treeState(repo, { git });
  assert.ok('project/features/kills/kill_new.gd' in later.paths, 'untracked-files=all names the file, not its folder');
  assert.deepEqual(treeMoves(begin, later), ['2 project/ path(s) changed (project/core/a.gd, project/features/kills/kill_new.gd)']);
  rmSync(join(repo, 'project', 'core', 'a.gd'));
  assert.equal(treeState(repo, { git }).paths['project/core/a.gd'], 'gone');
});

test('a commit part-way moves HEAD even when the tree ends up clean', (t) => {
  const { repo, git } = throwaway(t);
  writeFileSync(join(repo, 'project', 'core', 'a.gd'), 'extends Node2D\n');
  const begin = treeState(repo, { git });
  git(repo, 'add', 'project/core/a.gd');
  git(repo, 'commit', '-qm', 'two');
  const later = treeState(repo, { git });
  const moves = treeMoves(begin, later);
  assert.equal(moves.length, 2);
  assert.match(moves[0], /^HEAD [0-9a-f]{9} -> [0-9a-f]{9}$/);
  assert.match(movedLine('after katana dir 90 32 px/m', begin, later), /moved since the reel began \(HEAD .*\): after katana dir 90 32 px\/m films the tree as it stands now.*--rev=<commit>/);
  assert.equal(movedLine('x', null, later), null, 'an unknown state says nothing');
});

test('a dry run of a live-tree reel warns once about uncommitted project/ paths; a --rev reel never asks the live tree', async () => {
  const lines = [];
  const runner = () => { throw new Error('launched'); };
  const asked = [];
  const state = (tree) => { asked.push(tree); return { head: 'a'.repeat(40), paths: { 'project/x.gd': '1@2', 'project/y.gd': '3@4' } }; };
  assert.equal(await main(['--out=x', '--weapons=katana', '--quick', '--dry-run'], { out: (l) => lines.push(l), err: (l) => lines.push(l), runner, state }), 0);
  assert.equal(lines.filter((l) => /uncommitted project\/ path/.test(l)).length, 1);
  assert.match(lines.join('\n'), /2 uncommitted project\/ path\(s\) \(project\/x\.gd, project\/y\.gd\); each of the 1 film\(s\)/);
  const pinned = [];
  const resolveSide = () => ({ tree: filmedRoot(), label: 'abc', snapshot: true, injected: false });
  assert.equal(await main(['--out=x', '--weapons=katana', '--quick', '--rev=HEAD', '--dry-run'], { out: (l) => pinned.push(l), err: (l) => pinned.push(l), runner, state: (t) => { asked.push(`rev:${t}`); return null; }, resolveSide }), 0, 'the --rev dry run reaches the plan');
  assert.ok(pinned.some((l) => /1 film\(s\)/.test(l)));
  assert.ok(!asked.some((a) => a.startsWith('rev:')), 'a commit side is a snapshot: its tree cannot move');
  assert.ok(!pinned.some((l) => /uncommitted/.test(l)));
});

test('git C-quotes a space, a quote and non-ASCII (octal UTF-8 bytes): each path is the real file, renames give the new name', (t) => {
  const { repo, git } = throwaway(t);
  mkdirSync(join(repo, 'project', 'a b'), { recursive: true });
  writeFileSync(join(repo, 'project', 'a b', 'c d.gd'), 'x\n');
  writeFileSync(join(repo, 'project', 'ü.gd'), 'y\n');
  git(repo, 'mv', 'project/core/a.gd', 'project/core/new name.gd');
  const s = treeState(repo, { git });
  assert.deepEqual(Object.keys(s.paths).sort(), ['project/a b/c d.gd', 'project/core/new name.gd', 'project/ü.gd']);
  assert.ok(Object.values(s.paths).every((v) => v !== 'gone'), 'every one is stat-ed where it lies');
  assert.equal(unquote(String.raw`"project/\303\274.gd"`), 'project/ü.gd');
  assert.equal(unquote(String.raw`"a\"b\\c\td"`), 'a"b\\c\td');
  assert.equal(porcelainPath('R  "old x.gd" -> "new -> y.gd"'), 'new -> y.gd');
  assert.equal(porcelainPath('R  old.gd -> new.gd'), 'new.gd');
  assert.equal(porcelainPath('?? plain.gd'), 'plain.gd');
});
