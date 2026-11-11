// The pre-commit lint's scope: a commit that stages only paths under project/ cannot change what
// the per-file checks say about the files it does not stage, so the hook runs gdformat and gdlint
// over its staged .gd files only, and the Node tool tests only when it stages a file they read.
// Every whole-tree check (sizes, banned API, layers, tables, debt, achievements) still runs in full,
// and so does the whole lint in every gate (tools/gate/run.mjs, tools/evidence/run.mjs).
// FRICTION removed: n15 hero, 00:29: "each commit took ~1.5 min", stopping a five-commit loop; lint
// measured 88 s on 1428 .gd files: gdformat + gdlint about 50 s, tool tests 35 s.
// Tool-test inputs: the `join(ROOT, '<path>')` literals, plus INPUT_PREFIXES, which a traced run found
// read through tool code with the real root as default (2026-11-11: `node --import
// ./tools/lint/fs_trace.mjs --test <lint's tool-test globs>` with TRACE_ROOT/TRACE_OUT set listed
// project/project.godot, project/data/tables/view.json, project/dev/frames/film_probe.gd,
// project/dev/showcase/reel_chapters.gd and city_spawn_plan.gd; re-run it when a tool test changes).
// A staged path outside project/ (tools/, gdlintrc, gdformatrc, versions.toml, native/, ...) or an
// unreadable scope file gives the full lint, as before, except the lint-neutral paths below.
// n16 (kills-polish FRICTION 17:2x: "the pre-commit full lint runs ~2 min when a commit stages a path
// outside project/ (provenance, tools/art)"): every new PNG stages its steam/ai-provenance line and
// often the tools/art/*.py that cut it, and the kill lanes keep root KILLS.md / DEFECTS.md notes. No
// lint check is per-file over them and no tool test reads them (scope.test.mjs's guard greps every
// tools/**/*.mjs for them), so they ride along with a scoped commit instead of forcing the full lint.
//   node tools/lint/lint.mjs --scope=<file of staged paths, one per line>
import { readFileSync } from 'node:fs';
import { isInert } from '../evidence/scope.mjs';

/** Prefixes whose staged paths always run the tool tests (the traced reads above, widened to their
 *  folders: film reads dev entries and tables, native_side and film read project.godot). */
export const INPUT_PREFIXES = ['project/project.godot', 'project/data/', 'project/dev/'];

/** Staged paths outside project/ that no per-file check and no tool test reads (whole-tree checks
 *  such as json-canonical still run on every commit). Python under tools/art only: its .mjs/.json are code. */
export const NEUTRAL_PREFIXES = ['steam/ai-provenance/'];
export const NEUTRAL_NOTES = ['KILLS.md', 'DEFECTS.md'];

/** True when a staged repo path cannot change what the scoped lint skips. */
export function isLintNeutral(path) {
  return NEUTRAL_PREFIXES.some((x) => path.startsWith(x)) || NEUTRAL_NOTES.includes(path)
    || /^tools\/art\/[^/]+\.py$/.test(path); // a named top-level script (Codex n16t-break-aftermath: not `tools/art/.py`)
}

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
  const kept = (staged ?? []).filter((p) => !isInert(p));
  if (!kept.length || kept.some((p) => !p.startsWith('project/') && !isLintNeutral(p))) return null;
  const code = kept.filter((p) => p.startsWith('project/'));
  const neutral = kept.length - code.length;
  const want = new Set(code);
  const gd = allGd.filter((f) => want.has(f));
  // Every kept path, the neutral ones too: should a tool test ever read one, it runs (review of n16t-break-aftermath).
  const reads = kept.filter((p) => inputs.has(p) || INPUT_PREFIXES.some((x) => p.startsWith(x)));
  const toolTests = reads.length > 0;
  const tests = toolTests ? `tool-tests run (a tool test reads ${reads.join(', ')})` : 'tool-tests skipped (no staged path under tools/ or read by a tool test)';
  const also = neutral ? ` + ${neutral} lint-neutral (provenance, tools/art/*.py, KILLS/DEFECTS notes)` : '';
  const line = `lint: scoped to the commit (${code.length} staged path(s), all under project/${also}): gdformat + gdlint over ${gd.length} of ${allGd.length} .gd; ${tests}; every whole-tree check runs; the gates run the full lint`;
  return { gd, toolTests, line };
}
