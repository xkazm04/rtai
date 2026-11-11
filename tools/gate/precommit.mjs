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
// Lint gets the staged list (--scope): a commit wholly under project/ lints its own .gd files and
// skips the tool tests unless it stages a file they read (tools/lint/scope.mjs); the gates lint all.
// Every commit (inert ones too: docs/decisions.md stops the morning merge as well) first asks
// tools/merge/clash.mjs whether it makes a NEW code conflict with a sibling lane: a warning, never a block.
// Exit: lint's own code, or 0 when every staged path is inert or nothing is staged.
import { spawnSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { isInert } from '../evidence/scope.mjs';
import { ROOT } from '../lib/repo.mjs';
import { withoutGitEnv } from '../lint/lint.mjs';
import { driftPaths, exportIndex, removeExport, sample } from './staged_tree.mjs';
import { lines as clashLines, newClashes } from '../merge/clash.mjs';

/** The merge-clash warning lines for the commit being made, through the hook's own git runner. */
export function clashCheck(cwd, git, env = process.env) {
  const run = (args) => {
    const r = git('git', args, { cwd, encoding: 'utf8', windowsHide: true });
    return { status: r?.status ?? 1, stdout: typeof r?.stdout === 'string' ? r.stdout : '', stderr: String(r?.stderr ?? '') };
  };
  try { return clashLines(newClashes(run, env)); } catch (e) { return [`merge-clash: not checked (${e.message})`]; }
}

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

const TREE = /^[0-9a-f]{40,64}$/;

/** True only when git itself says the index tree is HEAD's tree (an empty commit). git runs the hook
 *  before it notices that (n15 hero 00:08: ten empty commits each waited for a full lint); an empty
 *  path list alone is never trusted, git may have failed to list. */
export function sameTreeAsHead(cwd, git = spawnSync) {
  const out = (args) => {
    const r = git('git', args, { cwd, encoding: 'utf8', windowsHide: true });
    return r && r.status === 0 && typeof r.stdout === 'string' ? r.stdout.trim() : '';
  };
  const index = out(['write-tree']);
  return TREE.test(index) && index === out(['rev-parse', 'HEAD^{tree}']);
}

export function main({ cwd = ROOT, git = spawnSync, lint = spawnSync, err = console.error, exporter, remover,
  clash = clashCheck } = {}) {
  for (const l of clash(cwd, git)) err(l);
  const paths = stagedPaths(cwd, git);
  let d = paths === null ? { skip: false, line: 'pre-commit: git could not list the staged paths, running lint' } : decide(paths);
  if (paths && !paths.length && sameTreeAsHead(cwd, git)) d = { skip: true, line: 'pre-commit: nothing staged, the index tree is the HEAD tree: lint skipped (git refuses the commit unless --allow-empty)' };
  if (d.line) err(d.line);
  if (d.skip) return 0;
  const t = lintTarget(cwd, { git, exporter, remover });
  if (t.line) err(t.line);
  const env = t.dir === cwd ? process.env : withoutGitEnv();
  const scopeDir = paths ? mkdtempSync(join(tmpdir(), 'gtai-lintscope-')) : null;
  const scopeArg = [];
  if (scopeDir) {
    writeFileSync(join(scopeDir, 'staged.txt'), `${paths.join('\n')}\n`, 'utf8');
    scopeArg.push(`--scope=${join(scopeDir, 'staged.txt')}`);
  }
  try {
    const r = lint(process.execPath, [join(t.dir, 'tools', 'lint', 'lint.mjs'), ...scopeArg], { cwd: t.dir, stdio: 'inherit', windowsHide: true, env });
    return typeof r.status === 'number' ? r.status : 1;
  } finally {
    try { t.cleanup(); } catch (e) { err(`pre-commit: ${e.message}`); }
    if (scopeDir) rmSync(scopeDir, { recursive: true, force: true });
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(main());
}
