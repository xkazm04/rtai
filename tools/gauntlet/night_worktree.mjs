import { existsSync, writeFileSync } from 'node:fs';
import { isAbsolute, join, relative, resolve } from 'node:path';
import { assertSafe, copyRuntime, MARKER, removeWorktree } from '../mutate/worktree.mjs';
import { seedImportCache } from './prepare_worktree.mjs';
import { physical } from './night_paths.mjs';
import { digest, git, withLock } from './tune_state.mjs';

export function checkLocation(root, path, branch) {
  if (!/^n23-tune-[A-Za-z0-9][A-Za-z0-9_-]*$/.test(branch ?? ''))
    throw new Error('--branch must be n23-tune-<id>');
  if (!path || !isAbsolute(path)) throw new Error('--worktree must be an absolute path');
  assertSafe(path, { root, realpath: physical });
}

function checkBranch(root, path, branch) {
  // Git's registry identifies the worktree without following .git files supplied by strangers.
  const entries = git(root, 'worktree', 'list', '--porcelain', '-z').split('\0\0');
  const fields = entries.map((entry) => entry.split('\0')).find(([line]) =>
    line.startsWith('worktree ') && relative(path, line.slice(9)) === '');
  if (!fields?.includes('branch refs/heads/' + branch))
    throw new Error('expected a worktree of this repo on ' + branch + ': ' + path);
}

export function requireClean(path) {
  const changes = git(path, 'status', '--porcelain', '-z', '--untracked-files=all').split('\0')
    .filter((line) => line && line !== '?? ' + MARKER);
  if (changes.length) throw new Error('dirty tune worktree: ' + changes[0]);
}

function prepare(root, path, branch) {
  if (!existsSync(path)) git(root, 'worktree', 'add', '--quiet', '-b', branch, path, 'HEAD');
  checkBranch(root, path, branch);
  requireClean(path);
  const marker = join(path, MARKER);
  if (!existsSync(marker)) writeFileSync(marker, JSON.stringify({ root: resolve(root) }), { flag: 'wx' });
  assertSafe(path, { root, requireMarker: true });
  copyRuntime(root, path);
  seedImportCache(root, path);
}

function remove(root, path, branch) {
  checkBranch(root, path, branch);
  assertSafe(path, { root, requireMarker: true });
  requireClean(path);
  const head = git(path, 'rev-parse', 'HEAD').trim();
  if (git(root, 'rev-list', '--count', 'HEAD..' + head).trim() !== '0')
    throw new Error(branch + ' has commits beyond lane HEAD');
  removeWorktree({ root, path });
  git(root, 'update-ref', '-d', 'refs/heads/' + branch, head);
}

export function inWorktree(root, job, action) {
  const { path, branch } = job;
  checkLocation(root, path, branch);
  return withLock(root, () => {
    if (job.remove) return remove(root, path, branch);
    prepare(root, path, branch);
    return action(path);
  }, 'night-' + digest(branch).slice(0, 16));
}
