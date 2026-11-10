// The pre-commit lint's scope: a commit that stages only paths under project/ cannot change what
// the per-file checks say about the files it does not stage, so the hook runs gdformat and gdlint
// over its staged .gd files only, and the Node tool tests only when it stages a file they read.
// Every whole-tree check (sizes, banned API, layers, tables, debt, achievements) still runs in full,
// and so does the whole lint in every gate (tools/gate/run.mjs, tools/evidence/run.mjs).
// FRICTION removed: n15 hero, 00:29: "each commit took ~1.5 min", stopping a five-commit loop; lint
// measured 88 s on 1428 .gd files: gdformat + gdlint about 50 s, tool tests 35 s.
// A staged path outside project/ (tools/, gdlintrc, gdformatrc, versions.toml, native/, ...) or an
// unreadable scope file gives the full lint, as before.
//   node tools/lint/lint.mjs --scope=<file of staged paths, one per line>
import { readFileSync } from 'node:fs';
import { isInert } from '../evidence/scope.mjs';

/** Repo paths a tool test reads from the real tree: every `join(ROOT, '<path>')` literal. */
export function toolTestInputs(sources) {
  const found = new Set();
  for (const src of sources) {
    for (const m of String(src).matchAll(/join\(\s*ROOT\s*,\s*(['"`])([^'"`$]+)\1\s*\)/g)) found.add(m[2]);
  }
  return found;
}

/** The staged paths in a scope file, or null when it cannot be read. */
export function readScope(file, read = readFileSync) {
  try {
    return String(read(file, 'utf8')).split(/\r?\n/).map((l) => l.trim()).filter(Boolean);
  } catch {
    return null;
  }
}

/**
 * What a commit of `staged` (repo-relative, forward slashes) needs: null for the full lint, else
 * {gd, toolTests, line}: gd = the staged files among `allGd` (repo-relative), toolTests = true when
 * a staged path is a tool-test input.
 */
export function narrow(staged, allGd, inputs = new Set()) {
  const code = (staged ?? []).filter((p) => !isInert(p));
  if (!code.length || code.some((p) => !p.startsWith('project/'))) return null;
  const want = new Set(code);
  const gd = allGd.filter((f) => want.has(f));
  const reads = code.filter((p) => inputs.has(p));
  const toolTests = reads.length > 0;
  const tests = toolTests ? `tool-tests run (a tool test reads ${reads.join(', ')})` : 'tool-tests skipped (no staged path under tools/ or read by a tool test)';
  const line = `lint: scoped to the commit (${code.length} staged path(s), all under project/): gdformat + gdlint over ${gd.length} of ${allGd.length} .gd; ${tests}; every whole-tree check runs; the gates run the full lint`;
  return { gd, toolTests, line };
}
