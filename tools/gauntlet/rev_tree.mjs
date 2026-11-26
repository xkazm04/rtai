// n31 foes: the async twins of waiting.mjs's lane lock and --rev worktree, for callers whose Godot
// runs go through runGodot (a promise). Same lock file, same worktree recipe (tools/mutate/worktree.mjs
// marker + runtime copy, prepare_worktree.mjs import cache, the lane's probe dir copied in).
import { spawnSync } from 'node:child_process';
import { cpSync, existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { ROOT } from '../lib/repo.mjs';
import { copyRuntime, MARKER, removeWorktree } from '../mutate/worktree.mjs';
import { seedImportCache } from './prepare_worktree.mjs';

export const LANE_LOCK = join(ROOT, 'build', 'n31', 'godot.lock');
export const PROBE_DIR = 'project/dev/foes_n31';

const pause = (ms) => new Promise((r) => setTimeout(r, ms));

/** Awaits `action()` holding the lane lock (exclusive create `<tag> <pid>`; re-checks every `pollMs`). */
export async function withLaneLockAsync(tag, action, { lock = LANE_LOCK, log = console.log, pollMs = 30_000 } = {}) {
  mkdirSync(join(lock, '..'), { recursive: true });
  const mine = `${tag} ${process.pid}`;
  for (let waited = 0; ; waited += pollMs) {
    try { writeFileSync(lock, mine + '\n', { flag: 'wx' }); break; } catch (e) {
      if (e.code !== 'EEXIST') throw e;
      log(`waiting: lane lock held by ${readFileSync(lock, 'utf8').trim()} (${Math.round(waited / 1000)} s)`);
      await pause(pollMs);
    }
  }
  try { return await action(); } finally {
    if (existsSync(lock) && readFileSync(lock, 'utf8').startsWith(mine)) rmSync(lock);
  }
}

/** The full sha of `rev` in `root`, or throws. */
export function resolveRev(rev, root = ROOT) {
  const sha = spawnSync('git', ['-C', root, 'rev-parse', '--verify', rev + '^{commit}'], { encoding: 'utf8' }).stdout.trim();
  if (!sha) throw new Error('unknown rev ' + rev);
  return sha;
}

/** A temp detached worktree at `rev` with the lane's probe dir copied in; awaits `action(tree, sha)`; removed after. */
export async function inRevTreeAsync(rev, action, { root = ROOT, prefix = 'gtai-foes-takes' } = {}) {
  const sha = resolveRev(rev, root);
  const tree = join(tmpdir(), `${prefix}-${sha.slice(0, 9)}-${process.pid}`);
  const r = spawnSync('git', ['-C', root, 'worktree', 'add', '--detach', '--quiet', tree, sha], { encoding: 'utf8' });
  if (r.status) throw new Error(r.stderr);
  try {
    writeFileSync(join(tree, MARKER), JSON.stringify({ root: resolve(root) }), { flag: 'wx' });
    copyRuntime(root, tree);
    seedImportCache(root, tree);
    cpSync(join(root, PROBE_DIR), join(tree, PROBE_DIR), { recursive: true });
    return await action(tree, sha);
  } finally {
    removeWorktree({ root, path: tree });
  }
}
