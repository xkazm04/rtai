// Reach index: which unit/integration tests a changed project file can reach, and why.
//
// Build: buildReach({sources, autoloads}) over the shipped + dev text sources (realReachIndex() reads
// project/{boot,core,features,dev,data/tables}: .gd .tscn .tres .gdshader .json; project.godot autoloads).
// It records (a) every res:// literal -> the files holding it (a literal is cut at its first %/{ to its
// directory, so "res://x/art/%s.png" counts as the dir x/art), and (b) class_name and autoload names ->
// declaring file.
//
// Query: reachOf(changedPaths, index) -> {reached: {<test>: Chain[]}, full: string|null, notes: string[]}
//   changedPaths: repo-relative (project/...); index: {tests: {<project-relative test path>: text},
//   classNames(local) -> string[], reach?: buildReach(...)}. A Chain is the list of steps from the changed
//   file to the test: [{file}, {file, how}, ...] with how = 'res:// path' | 'res:// dir <d>/' |
//   'names <Class>' | 'twin test_<base>' | 'is the change'. formatChain(chain) renders
//   'a <- b (how) <- test (how)'. mapChanges in test_map.mjs is reachOf projected to test names.
// Rules, per changed path under project/ (outside project/: a note; .uid/.import/.md: ignored):
//   project.godot, .gutconfig.json, addons/, data/schemas/, an autoload script (GUT boots every
//     autoload for every test), tests/support/ and other shared test code -> full (with the reason).
//   a test file -> itself. tests/scenarios|golden|parity -> the unit tests naming its path, else none
//     (run_scenarios covers it).
//   a .gd -> its direct tests (names a class/autoload it declares, its res:// path, or the test_<base>
//     twin) plus the direct tests of its one-hop dependents (files naming its classes or res:// path).
//   any other file -> the tests mentioning its path, plus the reach (as a .gd above) of every file whose
//     res:// literal names it, else of the files naming its nearest ancestor directory (>= 2 segments).
//   nothing reached: under dev/ -> none (layers lint keeps shipped code off dev/); an asset no file
//     references -> full 'unreferenced asset <path>'; else full '<path>: no test mentions it'.
// Full transitive closure was rejected: through the composition root most files reach most tests.
import { readFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { PROJECT, ROOT, rel, walk } from '../lib/repo.mjs';

const FULL_PREFIXES = ['project/tests/support/', 'project/addons/', 'project/data/schemas/'];
const FULL_FILES = ['project/project.godot', 'project/.gutconfig.json'];
const IGNORED_EXT = /\.(uid|import|md)$/;
const TEST_FILE = /^project\/tests\/(unit|integration)\/(?:.*\/)?test_[^/]*\.gd$/;
const SCENARIO_DIR = /^project\/tests\/(scenarios|golden|parity)\//;
const SOURCE_DIRS = ['boot', 'core', 'features', 'dev', 'data/tables'];
const SOURCE_EXT = /\.(gd|tscn|tres|gdshader|json)$/;
const LITERAL = /res:\/\/([^"'\s)\]]*)/g;
const MAX_ASSET_DEPTH = 3;

const escapeRe = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
const wordRe = (names) => (names.length ? new RegExp(`\\b(${names.map(escapeRe).join('|')})\\b`) : null);

/** Normalises a res:// literal body: cut at a format char to its directory, drop the trailing slash. */
function literalPath(body) {
  const cut = body.search(/[%{]/);
  const s = cut < 0 ? body : body.slice(0, body.lastIndexOf('/', cut) + 1);
  return s.replace(/\/+$/, '');
}

/** Pure. sources: {<project-relative path>: text}; autoloads: {Name: project-relative path}. */
export function buildReach({ sources, autoloads = {} }) {
  const refs = new Map();
  const names = {};
  for (const [file, text] of Object.entries(sources)) {
    for (const m of text.matchAll(LITERAL)) {
      const p = literalPath(m[1]);
      if (!p) continue;
      if (!refs.has(p)) refs.set(p, new Set());
      refs.get(p).add(file);
    }
    if (file.endsWith('.gd')) {
      for (const m of text.matchAll(/^(?:@abstract\s+)?class_name\s+(\w+)/gm)) (names[file] ??= []).push(m[1]);
    }
  }
  const autoloadOf = {};
  for (const [name, file] of Object.entries(autoloads)) { (names[file] ??= []).push(name); autoloadOf[file] = name; }
  return { sources, refs, names, autoloadOf };
}

/** {Name: project-relative path} from project.godot's [autoload] section. */
export function parseAutoloads(godotText) {
  const out = {};
  const section = godotText.split(/^\[autoload\]\s*$/m)[1]?.split(/^\[/m)[0] ?? '';
  for (const m of section.matchAll(/^(\w+)="\*?res:\/\/([^"]+)"/gm)) out[m[1]] = m[2];
  return out;
}

/** The real reach index over the project tree. */
export function realReachIndex() {
  const files = SOURCE_DIRS.flatMap((d) => walk(join(PROJECT, d), (n) => SOURCE_EXT.test(n))).map(rel);
  const sources = Object.fromEntries(files.map((f) => [f.slice('project/'.length), readFileSync(join(ROOT, f), 'utf8')]));
  let autoloads = {};
  try { autoloads = parseAutoloads(readFileSync(join(PROJECT, 'project.godot'), 'utf8')); } catch { /* none */ }
  return buildReach({ sources, autoloads });
}

const EMPTY = buildReach({ sources: {} });
const MEMO = new WeakMap();
const memoOf = (index) => { if (!MEMO.has(index)) MEMO.set(index, new Map()); return MEMO.get(index); };

/** Direct tests of `local`: twin, res:// path mention, declared names. -> [[test, how]]. */
function directTests(local, index) {
  const reach = index.reach ?? EMPTY;
  const out = [];
  const twin = `tests/unit/test_${basename(local, '.gd')}.gd`;
  const hasTwin = local.endsWith('.gd') && index.tests[twin] !== undefined;
  if (hasTwin) out.push([twin, `twin test_${basename(local, '.gd')}`]);
  const declared = local.endsWith('.gd') ? [...new Set([...index.classNames(local), ...(reach.names[local] ?? [])])] : [];
  const re = wordRe(declared);
  for (const [t, text] of Object.entries(index.tests)) {
    if (hasTwin && t === twin) continue;
    if (text.includes(`res://${local}`)) out.push([t, 'res:// path']);
    else if (re) { const m = re.exec(text); if (m) out.push([t, `names ${m[1]}`]); }
  }
  return out;
}

/** Files (other than `local`) that name a class `local` declares or hold its res:// path. */
function dependents(local, reach) {
  const re = wordRe(reach.names[local] ?? []);
  const out = [];
  for (const [file, text] of Object.entries(reach.sources)) {
    if (file === local) continue;
    if (reach.refs.get(local)?.has(file)) out.push([file, 'res:// path']);
    else if (re) { const m = re.exec(text); if (m) out.push([file, `names ${m[1]}`]); }
  }
  return out;
}

/** Referrers of a non-.gd file: exact res:// path, else the nearest ancestor-directory literal. */
function referrers(local, reach) {
  const exact = reach.refs.get(local);
  if (exact) return [...exact].filter((f) => f !== local).map((f) => [f, 'res:// path']);
  const parts = local.split('/');
  for (let n = parts.length - 1; n >= 2; n--) {
    const dir = parts.slice(0, n).join('/');
    const hit = reach.refs.get(dir);
    if (hit) return [...hit].map((f) => [f, `res:// dir ${dir}/`]);
  }
  return [];
}

/** Chains (lists of steps, test last) from `local` to tests. depth bounds asset -> asset referrals. */
function sourceChains(local, index, depth = 0) {
  const reach = index.reach ?? EMPTY;
  const memo = memoOf(index);
  const key = `${local}#${depth}`;
  if (memo.has(key)) return memo.get(key);
  memo.set(key, { chains: [], refs: [] });
  const chains = directTests(local, index).map(([t, how]) => [{ file: t, how }]);
  let refs = [];
  if (local.endsWith('.gd')) {
    for (const [dep, depHow] of dependents(local, reach)) {
      for (const [t, how] of directTests(dep, index)) chains.push([{ file: dep, how: depHow }, { file: t, how }]);
    }
  } else if (depth < MAX_ASSET_DEPTH) {
    refs = referrers(local, reach);
    for (const [r, rHow] of refs) {
      for (const tail of sourceChains(r, index, depth + 1).chains) chains.push([{ file: r, how: rHow }, ...tail]);
    }
  }
  const res = { chains, refs };
  memo.set(key, res);
  return res;
}

/** See the module header. */
export function reachOf(changedPaths, index) {
  const reached = {};
  const notes = [];
  const outside = [];
  let full = null;
  const needFull = (why) => { full ??= why; };
  const add = (test, chain) => { (reached[test] ??= []).push(chain); };
  for (const path of [...new Set(changedPaths.map((p) => p.replace(/\\/g, '/')))].sort()) {
    if (!path.startsWith('project/')) { outside.push(path); continue; }
    if (IGNORED_EXT.test(path)) continue;
    const local = path.slice('project/'.length);
    if (FULL_FILES.includes(path) || FULL_PREFIXES.some((p) => path.startsWith(p))) {
      needFull(`${path} affects every test`);
    } else if ((index.reach ?? EMPTY).autoloadOf[local]) {
      needFull(`${path} is autoload ${(index.reach ?? EMPTY).autoloadOf[local]}: it runs in every test`);
    } else if (TEST_FILE.test(path)) {
      if (index.tests[local] !== undefined) add(local, [{ file: local, how: 'is the change' }]);
      else notes.push(`${path}: deleted test, nothing to run`);
    } else if (SCENARIO_DIR.test(path)) {
      const hits = directTests(local, index).filter(([, how]) => how === 'res:// path');
      hits.forEach(([t, how]) => add(t, [{ file: local }, { file: t, how }]));
      if (!hits.length) notes.push(`${path}: scenario code: run_scenarios covers it`);
    } else if (path.startsWith('project/tests/')) {
      needFull(`${path} is shared test code`);
    } else {
      mapProjectFile(path, local, index, { add, needFull, notes });
    }
  }
  if (outside.length) {
    const more = outside.length > 3 ? ` +${outside.length - 3} more` : '';
    notes.push(`${outside.length} path(s) outside project/ need no unit tests (${outside.slice(0, 3).join(', ')}${more})`);
  }
  return { reached: Object.fromEntries(Object.keys(reached).sort().map((t) => [t, reached[t]])), full, notes };
}

function mapProjectFile(path, local, index, { add, needFull, notes }) {
  const { chains, refs } = sourceChains(local, index);
  for (const chain of chains) add(chain.at(-1).file, [{ file: local }, ...chain]);
  if (chains.length) {
    const via = new Set(chains.filter((c) => c.length > 1).map((c) => c[0].file));
    if (via.size) notes.push(`${path}: reached via ${via.size} file(s) (${[...via].slice(0, 3).join(', ')}${via.size > 3 ? ', ...' : ''})`);
    return;
  }
  const shipped = refs.filter(([f]) => !f.startsWith('dev/'));
  if (path.startsWith('project/dev/') || (refs.length && !shipped.length)) {
    notes.push(`${path}: dev/ is unreachable from shipped code (layers lint); no test names it`);
  } else if (!local.endsWith('.gd') && !refs.length) {
    needFull(`unreferenced asset ${path}`);
  } else if (shipped.length) {
    needFull(`${path} via ${shipped[0][0]}: no test reaches it`);
  } else {
    needFull(`${path}: no test mentions it`);
  }
}

/** 'a <- b (how) <- test (how)'. */
export const formatChain = (chain) => chain.map((s) => (s.how ? `${s.file} (${s.how})` : s.file)).join(' <- ');
