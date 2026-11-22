import assert from 'node:assert/strict';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { test } from 'node:test';
import { night } from './night.mjs';
import { parseNight } from './night_args.mjs';
import { git } from './tune_state.mjs';

function setup(t) {
  const temp = mkdtempSync(join(tmpdir(), 'gtai-night-test-'));
  t.after(() => rmSync(temp, { recursive: true, force: true }));
  const root = join(temp, 'lane'), tree = join(temp, 'tune');
  mkdirSync(root);
  git(root, 'init', '-b', 'lane');
  git(root, 'config', 'user.name', 'Night test');
  git(root, 'config', 'user.email', 'night@example.invalid');
  writeFileSync(join(root, '.gitignore'), '/build/\n.godot/\n/project/native/bin/\n');
  git(root, 'add', '--', '.gitignore');
  git(root, 'commit', '-m', 'fixture');
  const dir = join(root, 'evidence/n23-loop/night output'), calls = [], lines = [];
  const io = { root, run: (cmd, cwd) => { assert.equal(cwd, tree); calls.push(cmd); }, log: (line) => lines.push(line) };
  const location = ['--branch=n23-tune-test', '--worktree=' + tree];
  return { root, tree, dir, calls, lines, io, location, args: [...location, '--seeds=3', '--out=' + dir] };
}

test('dry run prepares and reuses a private worktree, shows absolute paths and removes it', (t) => {
  const { root, tree, dir, io, args, location, calls, lines } = setup(t);
  for (const [folder, file] of [['native/bin', 'sim.dll'], ['.godot/imported', 'test.ctex']]) {
    mkdirSync(join(root, 'project', folder), { recursive: true });
    writeFileSync(join(root, 'project', folder, file), 'seed');
  }
  night([...args, '--dry-run', '--waves=24'], io);
  assert.equal(calls.length, 0);
  assert.equal(existsSync(dir), false);
  assert.equal(readFileSync(join(tree, 'project/native/bin/sim.dll'), 'utf8'), 'seed');
  assert.equal(readFileSync(join(tree, 'project/.godot/imported/test.ctex'), 'utf8'), 'seed');
  assert.equal(lines.filter((s) => s.startsWith('node ')).length, 8);
  assert.ok(lines[0].includes(tree) && lines[0].includes(dir));
  assert.equal(lines.filter((s) => s.includes('batch.mjs') && s.includes('--waves=24')).length, 3);
  assert.match(lines.at(-1), /night\.md/);
  night([...args, '--dry-run'], io);
  night([...location, '--remove'], io);
  assert.equal(existsSync(tree), false);
  assert.equal(git(root, 'branch', '--list', 'n23-tune-test'), '');
});

test('argument and ownership refusals leave other directories and branches alone', (t) => {
  const { root, tree, args, io } = setup(t);
  for (const bad of ['--waves=0', '--seeds=0', '--profile=unknown', '--pick=x', '--controls=x',
    '--jobs=3', '--floor-mode=unknown', '--worktree=relative', '--worktree=' + join(root, 'child'),
    '--branch=n23-tuner', '--branch=n23-tune-', '--out=relative', '--out=' + join(root, 'evidence/unrelated')])
    assert.throws(() => parseNight([...args, bad], root));
  mkdirSync(tree);
  assert.throws(() => night(args, io), /worktree of this repo/);
  assert.ok(existsSync(tree));
});

test('removal refuses uncommitted work, a mismatched branch and unmerged commits', (t) => {
  const { root, tree, args, location, io } = setup(t);
  night([...args, '--dry-run'], io);
  assert.throws(() => night([...args, '--branch=n23-tune-other', '--dry-run'], io), /worktree of this repo/);
  writeFileSync(join(tree, 'note'), 'keep me');
  assert.throws(() => night([...location, '--remove'], io), /dirty/);
  git(tree, 'add', '--', 'note');
  git(tree, 'commit', '-m', 'keep this change');
  assert.throws(() => night([...location, '--remove'], io), /commits beyond/);
  night([...args, '--dry-run'], io);
  git(root, 'merge', '--ff-only', 'n23-tune-test');
  night([...location, '--remove'], io);
  assert.equal(readFileSync(join(root, 'note'), 'utf8'), 'keep me');
});

test('a failed after batch preserves output and leaves the checkout available for recovery', (t) => {
  const { root, tree, dir, io, args, calls } = setup(t);
  const run = (cmd, cwd) => {
    io.run(cmd, cwd);
    if (calls.length === 1) writeFileSync(join(dir, 'record'), 'before evidence');
    if (calls.length === 6) throw new Error('confirm batch failed');
  };
  assert.throws(() => night(args, { ...io, run }), /confirm batch failed/);
  assert.equal(calls.length, 6);
  assert.equal(readFileSync(join(dir, 'record'), 'utf8'), 'before evidence');
  assert.equal(existsSync(join(dir, 'night.md')), false);
  assert.equal(existsSync(join(tree, 'build/gauntlet/tuner.lock')), false);
  assert.equal(git(root, 'branch', '--show-current').trim(), 'lane');
  assert.throws(() => night(args, io), /output must be empty/);
});
