// The merge preview in the builders' loop: before a commit, does it make a NEW code conflict with a
// sibling lane? The staged index becomes a dangling commit on HEAD; each sibling lane is merged
// (`git merge-tree --write-tree`, ~50 ms a pair) with HEAD and with that commit, and a conflict on a
// file morning.mjs cannot resolve that only the commit has is named. Never blocks: the other lane's
// change is not yours to refuse, so it is a warning line (n15 tools 04:48: my quest1_clip.gd flag
// line clashed with combat's and was found 40 minutes later by a hand-run merge-tree).
// Siblings: every branch checked out in a worktree of this repo that shares the current branch's
// prefix up to its first "-" (n15-tools -> n15-hero, n15-combat); GTAI_MERGE_LANES=<a,b> names them
// instead, GTAI_MERGE_LANES=off skips the check. Writes git objects only (no ref, index or worktree).
//   node tools/merge/clash.mjs [--repo=<worktree>]   (also run by tools/gate/precommit.mjs)
// --repo checks another worktree's staged index with this copy of the tool (a lane without it yet),
// on a temp COPY of that index: write-tree may rewrite an index (its cache-tree), and that file is theirs.
import { spawnSync } from 'node:child_process';
import { copyFileSync, mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { isAbsolute, join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';
import { autoResolved, gitIn, mergeTree } from './preview.mjs';

const ID = ['-c', 'user.name=merge-clash', '-c', 'user.email=merge-clash@example.invalid'];

/** The sibling lanes of `branch` among the worktrees' branches, or the env's list. */
export function siblings(git, branch, env = process.env) {
  const named = env.GTAI_MERGE_LANES;
  if (named === 'off') return [];
  if (named) return named.split(',').filter((b) => b && b !== branch);
  const dash = branch.indexOf('-');
  if (dash <= 0) return [];
  const prefix = branch.slice(0, dash + 1);
  const r = git(['worktree', 'list', '--porcelain']);
  if (r.status !== 0) return [];
  return [...r.stdout.matchAll(/^branch refs\/heads\/(\S+)$/gm)].map((m) => m[1])
    .filter((b) => b !== branch && b.startsWith(prefix));
}

const code = (m) => (m.files ?? []).filter((f) => !autoResolved(f));

/** {branch, lanes, clashes: [{lane, files}], known, error}: the code conflicts the staged commit adds. */
export function newClashes(git, env = process.env) {
  const head = git(['symbolic-ref', '--quiet', '--short', 'HEAD']);
  const branch = head.status === 0 ? head.stdout.trim() : '';
  const lanes = branch ? siblings(git, branch, env) : [];
  if (!lanes.length) return { branch, lanes, clashes: [], known: 0 };
  const tree = git(['write-tree']);
  if (tree.status !== 0) return { branch, lanes, clashes: [], known: 0, error: 'git write-tree failed (unmerged index?)' };
  const c = git(['commit-tree', tree.stdout.trim(), '-p', 'HEAD', '-m', 'merge-clash: staged']);
  if (c.status !== 0) return { branch, lanes, clashes: [], known: 0, error: `git commit-tree: ${c.stderr.trim().slice(0, 200)}` };
  const staged = c.stdout.trim();
  const clashes = [];
  let known = 0;
  for (const lane of lanes) {
    const before = mergeTree(git, 'HEAD', lane);
    const after = mergeTree(git, staged, lane);
    if (before.error || after.error) return { branch, lanes, clashes, known, error: before.error ?? after.error };
    const had = new Set(code(before));
    known += had.size;
    const files = code(after).filter((f) => !had.has(f));
    if (files.length) clashes.push({ lane, files });
  }
  return { branch, lanes, clashes, known };
}

/** The warning lines for one check (empty when there is nothing to say). */
export function lines(r) {
  if (r.error) return [`merge-clash: not checked (${r.error})`];
  if (!r.lanes.length) return [];
  const out = r.clashes.map((c) => `merge-clash: WARNING this commit makes ${c.files.join(', ')} conflict with ${c.lane} `
    + `(git merge-tree; morning.mjs would stop on it). Move your lines off theirs, or say so in JOURNAL`);
  if (!out.length) out.push(`merge-clash: no new code conflict with ${r.lanes.join(', ')}${r.known ? ` (${r.known} known, unchanged)` : ''}`);
  return out;
}

/** A git runner on `repo` whose index is a temp copy of the repo's: {git, done}. GIT_* of the caller
 *  (a hook's GIT_DIR) are dropped, so it is the repo's own index and objects. */
export function copiedIndex(repo, baseEnv = process.env) {
  const clean = Object.fromEntries(Object.entries(baseEnv).filter(([k]) => !/^GIT_(DIR|WORK_TREE|INDEX_FILE|OBJECT_DIRECTORY|COMMON_DIR|PREFIX)$/i.test(k)));
  const where = spawnSync('git', ['-C', repo, 'rev-parse', '--git-path', 'index'], { encoding: 'utf8', windowsHide: true, env: clean });
  if (where.status !== 0) throw new Error(`not a git worktree: ${repo}`);
  const rel = where.stdout.trim();
  const dir = mkdtempSync(join(tmpdir(), 'gtai-clash-'));
  const index = join(dir, 'index');
  copyFileSync(isAbsolute(rel) ? rel : join(repo, rel), index);
  const env = { ...clean, GIT_INDEX_FILE: index };
  const git = (args) => {
    const r = spawnSync('git', ['-C', repo, ...ID, ...args], { encoding: 'utf8', windowsHide: true, env });
    return { status: r.status, stdout: r.stdout ?? '', stderr: r.stderr ?? '' };
  };
  return { git, done: () => rmSync(dir, { recursive: true, force: true }) };
}

export function main(argv = [], { git, err = console.error, env = process.env } = {}) {
  const repo = argv.find((a) => a.startsWith('--repo='))?.slice('--repo='.length);
  const bad = argv.find((a) => !/^--repo=.+$/.test(a));
  if (bad) { err(`merge-clash: bad argument ${bad}\nusage: node tools/merge/clash.mjs [--repo=<worktree>]`); return 2; }
  if (git || !repo) { for (const l of lines(newClashes(git ?? gitIn(ROOT), env))) err(l); return 0; }
  let copy;
  try {
    copy = copiedIndex(repo, env);
    for (const l of lines(newClashes(copy.git, env))) err(l);
    return 0;
  } catch (e) { err(`merge-clash: ${e.message}`); return 2; } finally { copy?.done(); }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(main(process.argv.slice(2)));
}
