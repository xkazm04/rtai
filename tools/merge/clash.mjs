// The merge preview in the builders' loop: before a commit, does it make a NEW code conflict with a
// sibling lane? The staged index becomes a dangling commit on HEAD; each sibling lane is merged
// (`git merge-tree --write-tree`, ~50 ms a pair) with HEAD and with that commit, and a conflict on a
// file morning.mjs cannot resolve that only the commit has is named. Never blocks: the other lane's
// change is not yours to refuse, so it is a warning line (n15 tools 04:48: my quest1_clip.gd flag
// line clashed with combat's and was found 40 minutes later by a hand-run merge-tree).
// Siblings: every branch checked out in a worktree of this repo that shares the current branch's
// prefix up to its first "-" (n15-tools -> n15-hero, n15-combat); GTAI_MERGE_LANES=<a,b> names them
// instead, GTAI_MERGE_LANES=off skips the check. Writes git objects only (no ref, index or worktree).
//   node tools/merge/clash.mjs        (also run by tools/gate/precommit.mjs)
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';
import { autoResolved, gitIn, mergeTree } from './preview.mjs';

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

export function main({ git = gitIn(ROOT), err = console.error, env = process.env } = {}) {
  for (const l of lines(newClashes(git, env))) err(l);
  return 0;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(main());
}
