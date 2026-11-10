#!/usr/bin/env node
// The pre-commit hook's front: a commit that stages only inert paths (docs/**, evidence/**, root
// JOURNAL.md, REPORT.md, ASSETS-REPLIES.md: tools/evidence/scope.mjs, whose guard test fails if lint
// starts reading them) cannot change what lint sees, so lint is skipped and the hook says so. Any
// other commit runs the full lint, as before. FRICTION removed: journal commits that waited 1 to 8
// minutes for a lint of code they did not touch (13 FRICTION lines in docs/*/JOURNAL.md, n11 tools
// alone made about 40 journal commits a night).
//   node tools/gate/precommit.mjs        (from .githooks/pre-commit)
// Exit: lint's own code, or 0 when every staged path is inert.
import { spawnSync } from 'node:child_process';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { isInert } from '../evidence/scope.mjs';
import { ROOT } from '../lib/repo.mjs';

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

export function main({ cwd = ROOT, git = spawnSync, lint = spawnSync, err = console.error } = {}) {
  const paths = stagedPaths(cwd, git);
  const d = paths === null ? { skip: false, line: 'pre-commit: git could not list the staged paths, running lint' } : decide(paths);
  if (d.line) err(d.line);
  if (d.skip) return 0;
  const r = lint(process.execPath, [join(cwd, 'tools', 'lint', 'lint.mjs')], { cwd, stdio: 'inherit', windowsHide: true });
  return typeof r.status === 'number' ? r.status : 1;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(main());
}
