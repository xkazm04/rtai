// The mutation worktree: a dedicated `git worktree` OUTSIDE the repo where every mutation happens.
// Safety law (the project/ wipe incident): this module never writes or deletes in the main checkout
// or in a lane worktree. The ONLY deletion is `git worktree remove --force <exact path>` after
// assertSafe() passed (marker present, real path under the OS temp dir, not ROOT, not inside ROOT,
// not under a gtai-wt lane folder). Restoring a mutated file is a rewrite from the original bytes.
import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { copyFileSync, existsSync, mkdirSync, readdirSync, readFileSync, realpathSync, statSync, unlinkSync,
  writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { basename, isAbsolute, join, resolve, sep } from 'node:path';

export const MARKER = '.gtai-mutate-worktree';
export const SIDECAR = '.gtai-orig';
export const LOCK = '.gtai-mutate-lock';
const norm = (p) => resolve(p).replace(/[\\/]+$/, '').split(sep).join('/').toLowerCase();
const inside = (child, parent) => norm(child).startsWith(`${norm(parent)}/`);

export class UnsafePath extends Error {}

/** <tmp>/gtai-mutate-<8 hex of sha1(main checkout root)>. */
export function defaultWorktreePath(root, tmp = tmpdir()) {
  return join(tmp, `gtai-mutate-${createHash('sha1').update(norm(root)).digest('hex').slice(0, 8)}`);
}

const realOrSelf = (p) => { try { return realpathSync(p); } catch { return resolve(p); } };

/** Throws UnsafePath unless `path` may host (or be removed as) the mutation worktree.
 *  requireMarker: the folder must exist and carry the marker (always for removal and reuse). */
export function assertSafe(path, { root, tmp = tmpdir(), requireMarker = false, realpath = realOrSelf,
  exists = existsSync, read = (p) => readFileSync(p, 'utf8') } = {}) {
  if (!path || !isAbsolute(path)) throw new UnsafePath(`not an absolute path: ${path}`);
  const real = realpath(path);
  const rootReal = realpath(root);
  const tmpReal = realpath(tmp);
  if (norm(real) === norm(rootReal) || norm(path) === norm(root)) throw new UnsafePath(`${path} is the repo root`);
  if (inside(real, rootReal) || inside(path, root)) throw new UnsafePath(`${path} is inside the repo root`);
  if (/(^|\/)gtai-wt(\/|$)/.test(norm(real)) || /(^|\/)gtai-wt(\/|$)/.test(norm(path))
    || inside(real, join(rootReal, '..', 'gtai-wt'))) throw new UnsafePath(`${path} is under a gtai-wt lane folder`);
  if (!inside(real, tmpReal)) throw new UnsafePath(`${path} is not under the OS temp dir (${tmp})`);
  if (requireMarker) {
    if (!exists(join(path, MARKER))) throw new UnsafePath(`${path} has no ${MARKER} marker`);
    let m = null;
    try { m = JSON.parse(read(join(path, MARKER))); } catch { /* unreadable marker */ }
    if (!m || norm(m.root ?? '') !== norm(root)) throw new UnsafePath(`${path}: marker belongs to another checkout`);
  }
  return real;
}

const git = (cwd, ...args) => execFileSync('git', ['-C', cwd, ...args], { encoding: 'utf8', windowsHide: true }).trim();

/** Porcelain lines of the worktree minus the marker and sidecars. */
export function dirtyLines(wt) {
  return git(wt, 'status', '--porcelain', '--untracked-files=all').split('\n').filter(Boolean)
    .filter((l) => !l.endsWith(SIDECAR) && !l.endsWith(MARKER) && !l.endsWith(LOCK));
}

/** Writes the original bytes next to the file (crash repair). Returns the sidecar path. */
export function writeSidecar(file, bytes) {
  writeFileSync(file + SIDECAR, bytes);
  return file + SIDECAR;
}

function findSidecars(dir, out = []) {
  for (const e of readdirSync(dir, { withFileTypes: true })) {
    if (e.name === '.godot' || e.name === '.git' || e.name === 'node_modules') continue;
    const p = join(dir, e.name);
    if (e.isDirectory()) findSidecars(p, out);
    else if (e.name.endsWith(SIDECAR)) out.push(p);
  }
  return out;
}

/** Restores every sidecar found under <wt>/project and removes it. Returns the restored file paths. */
export function repairSidecars(wt) {
  const base = join(wt, 'project');
  if (!existsSync(base)) return [];
  return findSidecars(base).map((side) => {
    const target = side.slice(0, -SIDECAR.length);
    writeFileSync(target, readFileSync(side));
    unlinkSync(side);
    return target;
  });
}

/** Rewrites `file` from `original` and byte-verifies it. Throws if the bytes differ afterwards. */
export function restoreFile(file, original) {
  writeFileSync(file, original);
  if (!readFileSync(file).equals(original)) throw new Error(`restore verification failed for ${file}`);
}

/** Copies the git-ignored runtime files a run needs (read-only on the source side). */
export function copyRuntime(root, wt) {
  const copied = [];
  const bin = join(root, 'project', 'native', 'bin');
  const items = [];
  if (existsSync(bin)) for (const f of readdirSync(bin)) items.push(['project/native/bin', f]);
  if (existsSync(join(root, 'project', 'override.cfg'))) items.push(['project', 'override.cfg']);
  for (const [dir, f] of items) {
    const src = join(root, dir, f);
    const dst = join(wt, dir, f);
    if (!statSync(src).isFile()) continue;
    if (existsSync(dst) && statSync(dst).size === statSync(src).size && statSync(dst).mtimeMs >= statSync(src).mtimeMs) continue;
    mkdirSync(join(wt, dir), { recursive: true });
    copyFileSync(src, dst);
    copied.push(`${dir}/${f}`);
  }
  return copied;
}

/** Creates or reuses the worktree at the main checkout's HEAD. -> {path, head, created, repaired, notes, copied}. */
export function ensureWorktree({ root, path = defaultWorktreePath(root), tmp = tmpdir() }) {
  assertSafe(path, { root, tmp });
  const head = git(root, 'rev-parse', 'HEAD');
  const notes = [];
  let created = false;
  let repaired = [];
  if (existsSync(path)) {
    assertSafe(path, { root, tmp, requireMarker: true });
    repaired = repairSidecars(path);
    for (const l of dirtyLines(path)) {
      if (!l.startsWith('??')) { // tracked change: repair with the allowed fallback
        const f = l.slice(3).trim();
        git(path, 'checkout', '--', f);
        notes.push(`repaired tracked change: ${f}`);
      } else notes.push(`untracked file left alone: ${l.slice(3).trim()}`);
    }
    git(path, 'checkout', '--quiet', '--detach', head);
  } else {
    execFileSync('git', ['-C', root, 'worktree', 'prune'], { windowsHide: true });
    execFileSync('git', ['-C', root, 'worktree', 'add', '--quiet', '--detach', path, head], { encoding: 'utf8', windowsHide: true });
    writeFileSync(join(path, MARKER), JSON.stringify({ root: resolve(root), head, created: new Date().toISOString() }));
    created = true;
  }
  return { path, head, created, repaired, notes, copied: copyRuntime(root, path) };
}

/** The ONLY removal: `git worktree remove --force <exact path>` + prune, after assertSafe. */
export function removeWorktree({ root, path, tmp = tmpdir() }) {
  assertSafe(path, { root, tmp, requireMarker: true });
  execFileSync('git', ['-C', root, 'worktree', 'remove', '--force', path], { windowsHide: true });
  execFileSync('git', ['-C', root, 'worktree', 'prune'], { windowsHide: true });
}

export const slugOf = (projectRel) => projectRel.replace(/\.gd$/, '').replace(/[^\w]+/g, '-').replace(/^-|-$/g, '');
export const stemOf = (p) => basename(p, '.gd');

/** One mutate run per worktree: a pid lock file. A lock whose pid is dead is stale and taken over.
 *  Returns a release function; throws when another live run holds the worktree. */
export function acquireLock(wt, pid = process.pid) {
  const file = join(wt, LOCK);
  for (let attempt = 0; attempt < 2; attempt++) {
    try {
      writeFileSync(file, String(pid), { flag: 'wx' });
      return () => { try { unlinkSync(file); } catch { /* already gone */ } };
    } catch (e) {
      if (e.code !== 'EEXIST') throw e;
      const other = Number(readFileSync(file, 'utf8'));
      let alive = false;
      try { process.kill(other, 0); alive = other !== pid; } catch { /* dead */ }
      if (alive) throw new Error(`another mutate run (pid ${other}) holds ${wt}; wait for it or use --worktree=<other path>`);
      unlinkSync(file); // stale lock of a dead run
    }
  }
  throw new Error(`cannot lock ${wt}`);
}
