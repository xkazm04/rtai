// LaunchArgs (project/boot/launch_args.gd) keeps only the flags in its KNOWN_FLAGS list, so
// `LaunchArgs.value("--x")` for a flag missing there is "" on every run and `has()` is false: a dev
// before-flag read that way never fires, and nothing says so (n15 combat FRICTION, 2026-11-11: a
// before/after came out byte-identical). This check names every such read at commit time.
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { PROJECT, ownGdFiles, rel } from '../lib/repo.mjs';

export const NAME = 'launch-flags';
export const LAUNCH_ARGS = 'project/boot/launch_args.gd';

/** The string literals inside `const KNOWN_FLAGS ... = [ ... ]` (comments dropped). */
export function knownFlags(src) {
  const m = /const KNOWN_FLAGS[^=]*=\s*\[([\s\S]*?)\n\]/.exec(src);
  if (!m) return null;
  const body = m[1].split('\n').map((l) => l.replace(/#.*$/, '')).join('\n');
  return new Set([...body.matchAll(/"([^"]+)"/g)].map((x) => x[1]));
}

/** Each `LaunchArgs.value|has(<arg>)` in `src` as {line, call, flag}; a bare NAME argument is
 *  resolved through a `const NAME ... = "--x"` in the same file (unresolved ones are skipped). */
export function flagReads(src) {
  const consts = new Map([...src.matchAll(/^\s*const\s+([A-Z][A-Z0-9_]*)\b[^=\n]*=\s*"([^"]*)"/gm)].map((x) => [x[1], x[2]]));
  const reads = [];
  src.split('\n').forEach((text, i) => {
    const code = text.replace(/#.*$/, '');
    for (const m of code.matchAll(/LaunchArgs\.(value|has)\(\s*(?:"([^"]*)"|([A-Z][A-Z0-9_]*))\s*\)/g)) {
      const flag = m[2] ?? consts.get(m[3]);
      if (flag !== undefined) reads.push({ line: i + 1, call: m[1], flag });
    }
  });
  return reads;
}

/** Issues for reads of flags not in `known`; `files` is [{path, src}]. Tests are skipped: they may
 *  re-parse LaunchArgs with made-up args on purpose. */
export function unknownReads(files, known) {
  const issues = [];
  for (const { path, src } of files) {
    if (path.startsWith('project/tests/')) continue;
    for (const r of flagReads(src)) {
      if (known.has(r.flag)) continue;
      issues.push(`${path}:${r.line}: LaunchArgs.${r.call}("${r.flag}") reads a flag not in KNOWN_FLAGS (${LAUNCH_ARGS}): it is "" on every run; add it there`);
    }
  }
  return issues;
}

export function launchFlagsCheck(read = () => ownGdFiles().map((f) => ({ path: rel(f), src: readFileSync(f, 'utf8') }))) {
  const known = knownFlags(readFileSync(join(PROJECT, 'boot', 'launch_args.gd'), 'utf8'));
  if (!known) return { name: NAME, ok: false, issues: [`${LAUNCH_ARGS}: no const KNOWN_FLAGS list found`] };
  const issues = unknownReads(read(), known);
  return { name: NAME, ok: !issues.length, issues };
}
