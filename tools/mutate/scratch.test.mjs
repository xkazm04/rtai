import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, realpathSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { test } from 'node:test';
import { createScratch } from './scratch.mjs';
import { parseArgs } from './mutate.mjs';

test('local scratch exports HEAD and preserves both staged and unstaged source bytes', () => {
  const root = realpathSync.native(mkdtempSync(join(tmpdir(), 'gtai-scratch-test-')));
  const git = (...args) => execFileSync('git', args, { cwd: root, windowsHide: true });
  try {
    git('init', '--quiet');
    const name = 'project/example.gd';
    const file = join(root, name);
    mkdirSync(dirname(file));
    writeFileSync(file, 'head');
    git('add', '--', name);
    git('-c', 'user.name=fixture', '-c', 'user.email=test@invalid', '-c', 'commit.gpgSign=false',
      '-c', 'core.hooksPath=.no-hooks', 'commit', '-qm', 'fixture');
    writeFileSync(file, 'index');
    git('add', '--', name);
    writeFileSync(file, 'working');
    const scratch = createScratch(root);
    assert.equal(dirname(scratch.path), join(root, 'build', 'mutate'));
    assert.equal(readFileSync(join(scratch.path, name), 'utf8'), 'head');
    writeFileSync(join(scratch.path, name), 'mutated');
    scratch.release();
    assert.equal(existsSync(scratch.path), false);
    assert.equal(readFileSync(file, 'utf8'), 'working');
    assert.equal(git('show', ':' + name).toString(), 'index');
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});

test('project-prefixed names and scratch select the same target as the default oracle', () => {
  const opts = parseArgs(['--file=project/boot/example.gd', '--scratch']);
  assert.equal(opts.file, 'boot/example.gd');
  assert.equal(opts.scratch, true);
  assert.throws(() => parseArgs(['--file=a.gd', '--scratch', '--worktree=other']));
});
