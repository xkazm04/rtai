// A throwaway checkout of one commit that can really run the game: a detached git worktree under the
// OS temp dir, with the git-ignored runtime copied in from a donor tree (the native DLLs, the baked
// city, the import cache), so nothing a run writes lands in anyone's tree and a builder can keep
// editing. Used by the film compare and the gate snapshot. The ONLY removal is `git worktree remove`
// on an exact path that sits in the temp dir and carries this module's marker.
import { execFileSync } from 'node:child_process';
import { cpSync, existsSync, mkdirSync, readdirSync, realpathSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, relative, resolve } from 'node:path';

/** The marker sits beside the checkout, never in it: an untracked file would make the tree dirty. */
export const markerOf = (path) => `${path}.gtai-snapshot`;
const git = (cwd, ...args) => execFileSync('git', ['-C', cwd, ...args], { encoding: 'utf8', windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'] }).trim();

/** The full hash of `rev`, or null when git does not know it. */
export function revParse(root, rev) {
  try { return git(root, 'rev-parse', '--verify', `${rev}^{commit}`); } catch { return null; }
}

/** The fixed path a commit's snapshot lives at (per tool, so a film never reuses a gate's tree). */
export const snapshotPath = (kind, sha, base = tmpdir()) => join(base, `gtai-${kind}-${sha.slice(0, 12)}`);

/** Throws unless `path` is strictly inside the temp dir and has the marker. */
export function assertRemovable(path, base = tmpdir()) {
  const inside = relative(realpathSync(base), realpathSync(path));
  if (!inside || inside.startsWith('..') || resolve(inside) === inside) throw new Error(`snapshot refuses ${path}: not inside ${base}`);
  if (!existsSync(markerOf(path))) throw new Error(`snapshot refuses ${path}: no marker`);
}

const RUNTIME = ['project/native/bin', 'project/data/generated/city', 'project/.godot'];

/** Copies each git-ignored runtime dir the snapshot lacks from `donor`; returns what it copied. */
export function copyRuntime(donor, path) {
  const copied = [];
  for (const rel of RUNTIME) {
    const from = join(donor, rel);
    const to = join(path, rel);
    if (!existsSync(from) || existsSync(to)) continue;
    cpSync(from, to, { recursive: true });
    copied.push(rel);
  }
  const cfg = join(donor, 'project/override.cfg');
  if (existsSync(cfg) && !existsSync(join(path, 'project/override.cfg'))) {
    cpSync(cfg, join(path, 'project/override.cfg'));
    copied.push('project/override.cfg');
  }
  return copied;
}

/** Creates (or reuses) the snapshot of `rev`: {path, sha, created, copied}. Never touches `root`'s files. */
export function ensureSnapshot({ root, rev, kind, donor = root, base = tmpdir() }) {
  const sha = revParse(root, rev);
  if (!sha) throw new Error(`snapshot: git does not know ${rev}`);
  mkdirSync(base, { recursive: true });
  const path = snapshotPath(kind, sha, base);
  let created = false;
  if (!existsSync(path)) {
    git(root, 'worktree', 'prune');
    git(root, 'worktree', 'add', '--quiet', '--detach', path, sha);
    writeFileSync(markerOf(path), `${sha}\n`);
    created = true;
  }
  if (!existsSync(markerOf(path))) throw new Error(`snapshot: ${path} exists without its marker`);
  return { path, sha, created, copied: copyRuntime(donor, path) };
}

/** Removes one snapshot. Refuses anything that is not ours. */
export function removeSnapshot(root, path, base = tmpdir()) {
  assertRemovable(path, base);
  git(root, 'worktree', 'remove', '--force', path);
  git(root, 'worktree', 'prune');
  rmSync(markerOf(path), { force: true });
}

/** Paths of every snapshot of `kind` under the temp dir. */
export function listSnapshots(kind, base = tmpdir()) {
  return readdirSync(base).filter((n) => n.startsWith(`gtai-${kind}-`) && !n.endsWith('.gtai-snapshot')).map((n) => join(base, n))
    .filter((p) => existsSync(markerOf(p)));
}
