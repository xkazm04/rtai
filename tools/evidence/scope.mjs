// Evidence scope: which paths an evidence kind can possibly read. The inert set is docs/**,
// evidence/** and the root JOURNAL.md / REPORT.md / ASSETS-REPLIES.md (lane notes, the assets lane's
// prose replies, logs, stills); every other path is code. Root *.md is NOT blanket-inert: tools/debt/metrics.mjs reads AGENTS.md and justfile, and
// lint's layers check reads names under project/ (a project README or a .uid is code).
// run.mjs uses classify() for the dirty-tree gate and the import-churn check; readersOfInert() is
// the guard (scope.test.mjs) that fails loudly if an evidence kind's tool starts reading the inert set.

const INERT_DIRS = ['docs/', 'evidence/'];
const INERT_FILES = ['JOURNAL.md', 'REPORT.md', 'ASSETS-REPLIES.md'];

/** True when a repo-relative path (forward slashes; a trailing / for an untracked dir) is inert. */
export function isInert(path) {
  return INERT_FILES.includes(path) || INERT_DIRS.some((d) => path.startsWith(d));
}

const unquote = (p) => (p.length > 1 && p.startsWith('"') && p.endsWith('"') ? p.slice(1, -1) : p);

/**
 * The path(s) a `git status --porcelain` line names: both sides of a rename/copy. repo.mjs's git()
 * trims its output, so the first line can arrive as 'M path' (from ' M path'): one status char.
 */
export function porcelainPaths(line) {
  const start = line[1] === ' ' && line[2] !== ' ' ? 2 : 3;
  return line.slice(start).split(' -> ').map(unquote);
}

/** Splits porcelain lines into inert and code; a line is inert only if every path it names is. */
export function classify(lines) {
  const inertLines = [];
  const codeLines = [];
  for (const l of lines) (porcelainPaths(l).every(isInert) ? inertLines : codeLines).push(l);
  return {
    inert: inertLines.length,
    code: codeLines.length,
    inertLines,
    codeLines,
    codePaths: codeLines.flatMap(porcelainPaths).filter((p) => !isInert(p)),
  };
}

/** The summary suffix naming uncommitted inert paths ('' when there are none). */
export const inertNote = (n) => (n ? ` [inert: ${n} docs/evidence paths uncommitted]` : '');

// A read root: join(ROOT|root, 'docs'|'evidence'|'JOURNAL.md'|'REPORT.md', ...) or a literal
// 'docs/...', 'evidence/...', 'JOURNAL.md', 'REPORT.md'.
const ROOT_RE = /join\(\s*(?:ROOT|root)\s*,\s*['"`](?:docs|evidence|JOURNAL\.md|REPORT\.md|ASSETS-REPLIES\.md)\b|['"`](?:\.\/)?(?:docs|evidence)\/|['"`](?:JOURNAL|REPORT|ASSETS-REPLIES)\.md['"`]/;
const READ_RE = /\b(?:readFileSync|readFile|readdirSync|readdir|opendirSync|readJson|readText|statSync|existsSync|createReadStream|globSync|walk|walkRel)\s*\(/;
const ASSIGN_RE = /\b(?:const|let|var)\s+([A-Za-z_$][\w$]*)\s*=/;

/** Does `text` read an inert root, directly on one line or through a variable bound to one? */
function readsInert(text) {
  const lines = text.split('\n');
  for (const line of lines) {
    if (!ROOT_RE.test(line)) continue;
    if (READ_RE.test(line)) return true;
    const name = line.match(ASSIGN_RE)?.[1];
    if (!name) continue;
    const use = new RegExp(`${READ_RE.source}[^)]*\\b${name.replace(/\$/g, '\\$')}\\b`);
    if (lines.some((l) => use.test(l))) return true;
  }
  return false;
}

/** The files among `sources` ([{file, text}]) that read docs/, evidence/ or root JOURNAL/REPORT. */
export function readersOfInert(sources) {
  return sources.filter((s) => readsInert(s.text)).map((s) => s.file).sort();
}
