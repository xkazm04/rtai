#!/usr/bin/env node
// The pre-commit hook's front: a commit that stages only inert paths (docs/**, evidence/**, root
// JOURNAL.md, REPORT.md, ASSETS-REPLIES.md: tools/evidence/scope.mjs, whose guard test fails if lint
// starts reading them) cannot change what lint sees, so lint is skipped and the hook says so. Any
// other commit runs the full lint, as before. FRICTION removed: journal commits that waited 1 to 8
// minutes for a lint of code they did not touch (13 FRICTION lines in docs/*/JOURNAL.md, n11 tools
// alone made about 40 journal commits a night).
//   node tools/gate/precommit.mjs        (from .githooks/pre-commit)
// When the tree differs from the index on a path lint could read, lint runs on an export of the
// index instead (tools/gate/staged_tree.mjs), so it judges the commit and not your unstaged edits.
// Exit: lint's own code, or 0 when every staged path is inert.
import { spawnSync } from 'node:child_process';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { isInert } from '../evidence/scope.mjs';
import { ROOT } from '../lib/repo.mjs';
import { withoutGitEnv } from '../lint/lint.mjs';
import { driftPaths, exportIndex, removeExport, sample } from './staged_tree.mjs';

/** {skip, line}: skip only when something is staged and every staged path is inert. */
export function decide(paths) {
  const staged = paths.filter(Boolean);
  if (!staged.length) return { skip: false, line: 'pre-commit: nothing staged reads as a path list, running lint' };
  const code = staged.filter((p) => !isInert(p));
  if (code.length) return { skip: false, line: null };
  return { skip: true, line: `pre-commit: ${staged.length} staged path(s), all inert (docs, evidence, JOURNAL, REPORT, ASSETS-REPLIES): lint skipped, it reads none of them` };
}

/** Every staged path, both sides of a rename (--no-renames), or null when git could not say. */
export function stagedPaths(cwd = ROOT, git = spawnSync) {
  const r = git('git', ['diff', '--cached', '--name-only', '--no-renames', '-z'], { cwd, encoding: 'utf8', windowsHide: true });
  if (r.status !== 0 || typeof r.stdout !== 'string') return null;
  return r.stdout.split('\0').filter(Boolean);
}

/** Where lint should run: {dir, line, cleanup}. The tree when it holds exactly the commit, else an
 *  export of the index; when neither can be known, the tree, saying it is not the commit. */
export function lintTarget(cwd, { git = spawnSync, exporter = exportIndex, remover = removeExport } = {}) {
  const drift = driftPaths(cwd, git);
  if (drift && !drift.length) return { dir: cwd, line: null, cleanup: () => {} };
  try {
    if (!drift) throw new Error('git could not list the unstaged paths');
    const { dir, count } = exporter(cwd, git);
    const line = `pre-commit: ${drift.length} path(s) in your tree differ from what you commit (${sample(drift)}): linting the staged snapshot (${count} files) in ${dir}`;
    return { dir, line, cleanup: () => remover(dir) };
  } catch (e) {
    return { dir: cwd, line: `pre-commit: no staged snapshot (${e.message}): linting the WORKING TREE, which is not exactly what you commit`, cleanup: () => {} };
  }
}

export function main({ cwd = ROOT, git = spawnSync, lint = spawnSync, err = console.error, exporter, remover } = {}) {
  const paths = stagedPaths(cwd, git);
  const d = paths === null ? { skip: false, line: 'pre-commit: git could not list the staged paths, running lint' } : decide(paths);
  if (d.line) err(d.line);
  if (d.skip) return 0;
  const t = lintTarget(cwd, { git, exporter, remover });
  if (t.line) err(t.line);
  const env = t.dir === cwd ? process.env : withoutGitEnv();
  try {
    const r = lint(process.execPath, [join(t.dir, 'tools', 'lint', 'lint.mjs')], { cwd: t.dir, stdio: 'inherit', windowsHide: true, env });
    return typeof r.status === 'number' ? r.status : 1;
  } finally {
    try { t.cleanup(); } catch (e) { err(`pre-commit: ${e.message}`); }
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(main());
}
