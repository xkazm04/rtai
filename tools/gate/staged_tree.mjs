// What the pre-commit lint must read: the commit, not the working tree. When a path lint could read
// differs between the tree and the index (an unstaged edit, an untracked file), the index is written
// out to a throwaway dir under the OS temp dir and lint runs there. FRICTION removed: "the pre-commit
// lint runs over the working tree, so my half-edited boss_cam.gd failed the evidence commit three
// times" (docs/day/2026-11-08/handheld:357), "an unstaged over-cap function blocked" a commit
// (docs/night/2026-11-05/king:881); and the silent reverse, a broken staged file passing because
// its fixed copy was not staged yet.
// Inside the hook git sets GIT_INDEX_FILE, so `git commit <paths>` and `-a` export their own index.
import { spawnSync } from 'node:child_process';
import { mkdtempSync, realpathSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { basename, dirname } from 'node:path';
import { isInert } from '../evidence/scope.mjs';

export const PREFIX = 'gtai-precommit-';

/** Binary and log files lint never reads (measured: 25 MB and about 2 s for the rest, 315 MB with). */
const SKIP_EXT = /\.(png|jpe?g|webp|exr|hdr|wav|ogg|mp3|glb|gltf|blend|ttf|otf|dll|so|dylib|exe|pck|zip|mp4|log)$/i;

/** True when the staged snapshot carries `path`: inert paths and binaries stay out. */
export const wanted = (path) => !isInert(path) && !SKIP_EXT.test(path);

const list = (git, cwd, args) => {
  const r = git('git', args, { cwd, encoding: 'utf8', windowsHide: true, maxBuffer: 256 * 1024 * 1024 });
  return r.status === 0 && typeof r.stdout === 'string' ? r.stdout.split('\0').filter(Boolean) : null;
};

/** Non-inert paths whose tree content is not the index's (unstaged edits, deletes, untracked), or
 *  null when git could not say. Empty means linting the tree is linting the commit. */
export function driftPaths(cwd, git = spawnSync) {
  const changed = list(git, cwd, ['diff', '--name-only', '--no-renames', '-z']);
  const untracked = list(git, cwd, ['ls-files', '--others', '--exclude-standard', '-z']);
  if (!changed || !untracked) return null;
  return [...new Set([...changed, ...untracked])].filter((p) => !isInert(p)).sort();
}

/** Writes every wanted index entry into a new temp dir: {dir, count}. Throws on any git failure. */
export function exportIndex(cwd, git = spawnSync, base = tmpdir()) {
  const paths = list(git, cwd, ['ls-files', '-z']);
  if (!paths) throw new Error('git ls-files failed');
  const keep = paths.filter(wanted);
  const dir = mkdtempSync(`${base}/${PREFIX}`);
  const prefix = `${dir.replace(/\\/g, '/')}/`;
  const r = git('git', ['checkout-index', '-z', '--stdin', `--prefix=${prefix}`], { cwd, input: `${keep.join('\0')}\0`, encoding: 'utf8', windowsHide: true });
  if (r.status !== 0) {
    removeExport(dir, base);
    throw new Error(`git checkout-index exit ${r.status}: ${String(r.stderr || '').trim().split('\n')[0]}`);
  }
  return { dir, count: keep.length };
}

/** Removes one export. Refuses anything that is not a direct PREFIX child of the temp dir. */
export function removeExport(dir, base = tmpdir()) {
  if (!basename(dir).startsWith(PREFIX) || realpathSync(dirname(dir)) !== realpathSync(base)) {
    throw new Error(`staged_tree refuses to remove ${dir}: not a ${PREFIX}* dir in ${base}`);
  }
  rmSync(dir, { recursive: true, force: true });
}

/** "a, b, c, +4" for a line. */
export const sample = (paths, n = 3) => `${paths.slice(0, n).join(', ')}${paths.length > n ? `, +${paths.length - n}` : ''}`;
