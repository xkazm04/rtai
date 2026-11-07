// Resolves every path a lane REPORT or a decision line cites in backticks.
//   node tools/evidence/cites.mjs <file.md>... [--all] [--json] [--tracked] [--strict] [--root NAME=<dir>]
// --all = every tracked docs/**/REPORT.md plus docs/decisions.md. Statuses: OK, MISSING (+ a
// basename suggestion over git ls-files), MISSING-LINE (file:L past the end), UNTRACKED (on disk,
// not in git: it vanishes with the worktree), PATTERN (a <placeholder> or glob: skipped, counted),
// UNCHECKED (a root alias like `M/` the file never declares; `frames/` with no root holding it),
// IGNORED (absent, but git-ignored build output such as project/data/generated/city/). Exit 1 on MISSING/MISSING-LINE,
// +UNTRACKED with --tracked, +UNCHECKED with --strict; 2 on bad arguments.
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { basename, dirname, isAbsolute, join, posix } from 'node:path';
import { fileURLToPath } from 'node:url';
import { ROOT, git, run } from '../lib/repo.mjs';

export const PREFIXES = ['evidence/', 'project/', 'tools/', 'docs/', 'native/', 'frames/'];
const ALIAS = String.raw`(?:<[\w-]+>|[A-Za-z][\w-]*)[:/\\]?`;
const DIR = String.raw`(?:[A-Za-z]:[\\/]|[\\/]|(?:evidence|project|tools|docs|native|frames)/)[^\x60]*`;
// Declaration forms seen in the lane reports, each [regex, alias group, dir group]:
//   `M/` = `<dir>` | `M` below means/stands for `<dir>` | `masters/`, which means `<dir>`
//   `<dir>` (written `M/` below) | `<dir>` (M below) | `<dir>`; `M/` below means that folder
//   (outside git, `M/` below): `<dir>` | `WT` means this worktree (dir = the repo root)
const decl = (src, a, d) => [new RegExp(src.replaceAll('ALIAS', ALIAS).replaceAll('DIR', DIR), 'g'), a, d];
const DECLS = [
  decl(String.raw`\`(ALIAS)\`[^\`\n]{0,40}?(?:=|\bmeans\b|\bstands for\b)\s*\`(DIR)\``, 1, 2),
  decl(String.raw`\`(DIR)\`\s*\((?:written|as)\s+\`?(ALIAS)\`?(?:\s+below)?\s*\)`, 2, 1),
  decl(String.raw`\`(DIR)\`\s*\(\`?(ALIAS)\`?\s+below\)`, 2, 1),
  decl(String.raw`\`(DIR)\`[;,]?\s*\`(ALIAS)\` below (?:means|is) that folder`, 2, 1),
  decl(String.raw`\`(ALIAS)\` below\)?:\s*\`(DIR)\``, 1, 2),
  decl(String.raw`\`(ALIAS)\`[^\`\n]{0,20}?\b(?:means|is|=|stands for)\s+(this worktree)\b`, 1, 2),
];
const UNDECLARED = /^(<[\w-]+>|[A-Z][A-Z0-9]{0,7}|masters)(?:[/\\]|:(?![\\/]))/;
const MAX_EXPAND = 200;

const aliasName = (raw) => raw.replace(/^<|[:/\\]$/g, '').replace(/>$/, '');

/** Root aliases a document declares in prose, as Map name -> dir (a repo-relative dir stays relative). */
export function parseAliases(text) {
  const out = new Map();
  const add = (name, dir) => {
    const n = aliasName(name);
    if (!PREFIXES.includes(`${n}/`)) out.set(n, dir.replace(/[\\/]+$/, ''));
  };
  for (const [re, a, d] of DECLS) for (const m of text.matchAll(re)) add(m[a], m[d] === 'this worktree' ? '.' : m[d]);
  return out;
}

/** Splits `path:7,57` / `path:3-9` into the path and the line numbers to check. */
export function splitLines(token) {
  const m = /^(.*?):(\d+(?:[-,]\d+)*)$/.exec(token);
  if (!m) return { path: token, lines: [] };
  return { path: m[1], lines: m[2].split(/[-,]/).map(Number) };
}

/** Expands {a,b} and itN..itM / 0001..0005; null when the expansion is too large. */
export function expand(path) {
  const brace = /\{([^{}]*,[^{}]*)\}/.exec(path);
  if (brace) {
    const parts = brace[1].split(',').map((p) => path.slice(0, brace.index) + p + path.slice(brace.index + brace[0].length));
    return joinExpansions(parts);
  }
  const range = /([A-Za-z_]*)(\d+)\.\.([A-Za-z_]*)(\d+)/.exec(path);
  if (range && (range[3] === '' || range[3] === range[1]) && Number(range[4]) >= Number(range[2])) {
    const [lo, hi] = [Number(range[2]), Number(range[4])];
    if (hi - lo >= MAX_EXPAND) return null;
    const width = range[2].startsWith('0') ? range[2].length : 0;
    const parts = [];
    for (let i = lo; i <= hi; i += 1) {
      const n = String(i).padStart(width, '0');
      parts.push(path.slice(0, range.index) + range[1] + n + path.slice(range.index + range[0].length));
    }
    return joinExpansions(parts);
  }
  return [path];
}

function joinExpansions(parts) {
  const out = [];
  for (const p of parts) {
    const sub = expand(p);
    if (!sub || out.length + sub.length > MAX_EXPAND) return null;
    out.push(...sub);
  }
  return out;
}

const isPattern = (p) => /[<>*?]|\.\.\.|[{}]/.test(p);

/** Backtick tokens that cite a path, as [{line, token}] (the first word of the token, trailing punctuation off). */
export function extractCites(text, aliases) {
  const out = [];
  text.split('\n').forEach((lineText, i) => {
    for (const m of lineText.matchAll(/`([^`]+)`/g)) {
      const token = m[1].trim().split(/\s+/)[0].replace(/[),;.]+$/, '');
      if (citesPath(token, aliases)) out.push({ line: i + 1, token });
    }
  });
  return out;
}

function citesPath(token, aliases) {
  if (PREFIXES.some((p) => token.startsWith(p) && token.length > p.length)) return true;
  const m = /^(<[\w-]+>|[A-Za-z][\w-]*)[:/\\](.+)$/.exec(token);
  if (m && aliases.has(aliasName(m[1]))) return true;
  return UNDECLARED.test(token) && token.length > 3;
}

/** Index of tracked paths: the set of files and dirs, plus files by basename (for suggestions). */
export function trackedIndex(list) {
  const set = new Set();
  const byBase = new Map();
  for (const p of list) {
    set.add(p);
    for (let d = posix.dirname(p); d !== '.'; d = posix.dirname(d)) set.add(d);
    const base = posix.basename(p);
    if (!byBase.has(base)) byBase.set(base, []);
    byBase.get(base).push(p);
  }
  return { set, byBase };
}

function suggest(path, index) {
  const segs = path.split('/');
  // only a basename that is unique in the tracked tree, under the same top folder: a common name
  // (README.md, scenarios-it7.log) has no single right answer
  const hits = (index.byBase.get(posix.basename(path)) ?? []).filter((p) => p.split('/')[0] === segs[0]);
  return hits.length === 1 ? hits[0] : undefined;
}

const isAbs = (p) => isAbsolute(p) || /^[A-Za-z]:/.test(p);

const countLines = (abs) => {
  const text = readFileSync(abs, 'utf8');
  const n = text.split('\n').length;
  return text.endsWith('\n') ? n - 1 : n;
};

/** MISSING-LINE when a cited line number is past the end of the file, else null. */
function lineCheck(abs, lines) {
  if (!lines.length || !statSync(abs).isFile()) return null;
  const total = countLines(abs);
  const past = lines.find((n) => n > total);
  return past === undefined ? null : { status: 'MISSING-LINE', detail: `line ${past} past end (${total} lines)` };
}

/** `patches/0001` names `0001-<subject>.patch` (git format-patch): an extensionless stem with a sibling `<stem>-*`/`<stem>.*`. */
function stemHit(abs) {
  const dir = dirname(abs);
  const stem = basename(abs);
  if (stem.includes('.') || !existsSync(dir) || !statSync(dir).isDirectory()) return false;
  return readdirSync(dir).some((n) => n.startsWith(`${stem}-`) || n.startsWith(`${stem}.`));
}

/** Status of one expanded path ({status, suggestion?, detail?}). */
function checkPath(path, lines, ctx) {
  const m = /^(<[\w-]+>|[A-Za-z][\w-]*)[:/\\](.*)$/.exec(path);
  const alias = m && !PREFIXES.includes(`${m[1]}/`) ? aliasName(m[1]) : null;
  if (alias && !ctx.aliases.has(alias) && m[1].startsWith('<')) return { status: 'PATTERN' };
  if (alias && !ctx.aliases.has(alias)) return { status: 'UNCHECKED', detail: `undeclared root ${alias}/` };
  if (isPattern(alias ? m[2] : path)) return { status: 'PATTERN' };
  if (path.startsWith('frames/')) return checkFrames(path, lines, ctx);
  const base = alias ? ctx.aliases.get(alias) : null;
  const relPath = alias ? posix.join(base.replace(/\\/g, '/'), m[2].replace(/\\/g, '/')) : path;
  const inRepo = !isAbs(relPath);
  const abs = inRepo ? join(ctx.root, relPath) : relPath;
  if (!existsSync(abs)) {
    const gone = (p) => p !== '.' && !/^[A-Za-z]:\/?$|^\/$/.test(p) && !existsSync(inRepo ? join(ctx.root, p) : p);
    let parent = posix.dirname(relPath.replace(/\/$/, ''));
    while (gone(parent) && gone(posix.dirname(parent))) parent = posix.dirname(parent);
    if (gone(parent)) {
      return { status: 'MISSING', detail: `no folder ${parent}/ here`, ...(inRepo ? { rel: relPath } : {}) };
    }
    if (stemHit(abs)) return { status: 'OK' };
    const hint = inRepo ? suggest(relPath, ctx.index) : undefined;
    return { status: 'MISSING', ...(hint ? { suggestion: hint } : {}), ...(inRepo ? { rel: relPath } : {}) };
  }
  const short = lineCheck(abs, lines);
  if (short) return short;
  if (inRepo && !ctx.index.set.has(relPath.replace(/\/$/, ''))) {
    return { status: 'UNTRACKED', detail: 'exists here, vanishes with the worktree', rel: relPath.replace(/\/$/, '') };
  }
  return { status: 'OK' };
}

/** `frames/x` names a masters folder's frames dir: the repo root if it has one, else each declared root. */
function checkFrames(path, lines, ctx) {
  const roots = [...(existsSync(join(ctx.root, 'frames')) ? [ctx.root] : []), ...ctx.aliases.values()];
  if (!roots.length) return { status: 'UNCHECKED', detail: 'frames/ under no declared root' };
  const hit = roots.map((r) => (isAbs(r) ? join(r, path) : join(ctx.root, r, path))).find((a) => existsSync(a));
  if (!hit) return { status: 'MISSING' };
  return lineCheck(hit, lines) ?? { status: 'OK' };
}

/** Every cite in one document, as rows {file, line, path, status, suggestion?, detail?}. */
export function checkText(text, file, ctx) {
  const aliases = new Map([...parseAliases(text), ...ctx.rootFlags]);
  const local = { ...ctx, aliases };
  const rows = [];
  for (const { line, token } of extractCites(text, aliases)) {
    const { path, lines } = splitLines(token);
    const paths = isPattern(path.replace(/\{[^{}]*,[^{}]*\}/g, '').replace(/\d+\.\.[A-Za-z_]*\d+/g, '')) ? [path] : expand(path);
    for (const p of paths ?? [path]) {
      const res = paths ? checkPath(p, lines, local) : { status: 'PATTERN' };
      rows.push({ file, line, path: paths && paths.length > 1 ? p : token, ...res });
    }
  }
  return rows.sort((a, b) => a.line - b.line);
}

const FAIL = new Set(['MISSING', 'MISSING-LINE']);

export function exitCode(rows, flags) {
  const bad = (r) => FAIL.has(r.status) || (flags.tracked && r.status === 'UNTRACKED') || (flags.strict && r.status === 'UNCHECKED');
  return rows.some(bad) ? 1 : 0;
}

export function formatRows(rows) {
  const out = [];
  for (const r of rows) {
    if (r.status === 'OK' || r.status === 'PATTERN') continue;
    const hint = r.suggestion ? ` (did you mean ${r.suggestion}?)` : r.detail ? ` (${r.detail})` : '';
    out.push(`${r.file}:${r.line} ${r.path} ${r.status}${hint}`);
  }
  const count = (s) => rows.filter((r) => r.status === s).length;
  const parts = [`${count('OK')} ok`];
  for (const s of ['MISSING', 'MISSING-LINE', 'UNTRACKED', 'UNCHECKED', 'IGNORED', 'PATTERN']) {
    if (count(s)) parts.push(`${count(s)} ${s.toLowerCase()}`);
  }
  out.push(`cites: ${rows.length} paths, ${parts.join(', ')}`);
  return out;
}

export function parseArgs(argv) {
  const flags = { json: false, tracked: false, strict: false, all: false, files: [], roots: new Map() };
  for (let i = 0; i < argv.length; i += 1) {
    const a = argv[i];
    const name = a.replace(/^--/, '');
    if (['json', 'tracked', 'strict', 'all'].includes(name) && a.startsWith('--')) flags[name] = true;
    else if (a === '--root' || a.startsWith('--root=')) {
      const val = a === '--root' ? argv[(i += 1)] : a.slice('--root='.length);
      const m = /^([^=]+)=(.+)$/.exec(val ?? '');
      if (!m) return { error: `--root needs NAME=<dir>, got ${val}` };
      flags.roots.set(aliasName(m[1]), m[2].replace(/[\\/]+$/, ''));
    } else if (a.startsWith('-')) return { error: `unknown argument ${a}` };
    else flags.files.push(a);
  }
  if (!flags.files.length && !flags.all) return { error: 'no files given (or --all)' };
  return flags;
}

const lsFiles = (root) => git('-C', root, 'ls-files').split('\n').filter(Boolean);
/** The subset of repo paths git ignores, in one check-ignore call. */
function gitIgnored(root, paths) {
  if (!paths.length) return new Set();
  // only the repo's own .gitignore rules count: a machine-local .git/info/exclude line is not a contract
  const res = run('git', ['-C', root, 'check-ignore', '-v', '--no-index', '--stdin'], { input: paths.join('\n') });
  const hits = res.out.split(/\r?\n/).map((l) => /^(.*?):\d+:.*\t(.+)$/.exec(l)).filter(Boolean);
  return new Set(hits.filter((m) => /(^|[\\/])\.gitignore$/.test(m[1])).map((m) => m[2]));
}

/** Absent paths that are git-ignored build output become IGNORED instead of MISSING. */
function markIgnored(rows, root, deps) {
  const rels = [...new Set(rows.filter((r) => r.rel).map((r) => r.rel))];
  const hit = deps.ignored ? new Set(rels.filter(deps.ignored)) : deps.tracked ? new Set() : gitIgnored(root, rels);
  for (const r of rows) {
    if (r.rel && hit.has(r.rel)) {
      const detail = r.status === 'UNTRACKED' ? 'git-ignored output' : 'git-ignored output, not on disk here';
      Object.assign(r, { status: 'IGNORED', detail, suggestion: undefined });
    }
    delete r.rel;
  }
}

/** CLI body. deps: {root, tracked (list), ignored (path -> bool), write} for tests; defaults to the repo and git ls-files. */
export function main(argv, deps = {}) {
  const write = deps.write ?? ((s) => process.stdout.write(`${s}\n`));
  const flags = parseArgs(argv);
  if (flags.error) {
    write(`cites: ${flags.error}`);
    write('usage: node tools/evidence/cites.mjs <file.md>... [--all] [--json] [--tracked] [--strict] [--root NAME=<dir>]');
    return 2;
  }
  const root = deps.root ?? ROOT;
  const tracked = deps.tracked ?? lsFiles(root);
  const files = flags.all ? tracked.filter((p) => /^docs\/.*REPORT\.md$/.test(p) || p === 'docs/decisions.md') : [];
  const ctx = { root, index: trackedIndex(tracked), rootFlags: flags.roots };
  const rows = [];
  for (const f of [...files, ...flags.files]) {
    const abs = isAbsolute(f) ? f : join(root, f);
    if (!existsSync(abs)) {
      write(`cites: no such file ${f}`);
      return 2;
    }
    rows.push(...checkText(readFileSync(abs, 'utf8'), f.replace(/\\/g, '/'), ctx));
  }
  markIgnored(rows, root, deps);
  for (const line of flags.json ? [JSON.stringify(rows.map(jsonRow), null, 1)] : formatRows(rows)) write(line);
  return exitCode(rows, flags);
}

const jsonRow = ({ file, line, path, status, suggestion }) => (suggestion ? { file, line, path, status, suggestion } : { file, line, path, status });

if (process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1]) process.exitCode = main(process.argv.slice(2));
