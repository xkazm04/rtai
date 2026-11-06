// Changed file -> unit/integration test files (repo-relative to project/, e.g. tests/unit/test_x.gd).
//   node tools/tests/test_map.mjs [<changed path>...]   (no args: the working-tree changes)
// Rules (mapChanges): a changed test maps to itself; a changed .gd under project/ maps to the tests
// whose text mentions a class_name it declares or its res:// path, plus tests/unit/test_<basename>.gd;
// support code, project.godot, .gutconfig.json, addons/, data/schemas and any other project file no
// test mentions -> the FULL suite (with the reason); paths outside project/ need no unit tests.
import { readFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { PROJECT, ROOT, git, rel, walk } from '../lib/repo.mjs';

const FULL_PREFIXES = ['project/tests/support/', 'project/addons/', 'project/data/schemas/'];
const FULL_FILES = ['project/project.godot', 'project/.gutconfig.json'];
const IGNORED_EXT = /\.(uid|import|md)$/;
const TEST_FILE = /^project\/tests\/(unit|integration)\/(?:.*\/)?test_[^/]*\.gd$/;

const escapeRe = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

/** Pure. changed: repo-relative paths. index: {tests: {<path relative to project/>: text},
 *  classNames(projectRelPath) -> string[]}. -> {tests: string[], full: string|null, notes: string[]}. */
export function mapChanges(changed, index) {
  const tests = new Set();
  const notes = [];
  const outside = [];
  let full = null;
  const needFull = (why) => { full ??= why; };
  const testPaths = Object.keys(index.tests);
  for (const path of [...new Set(changed.map((p) => p.replace(/\\/g, '/')))].sort()) {
    if (!path.startsWith('project/')) { outside.push(path); continue; }
    if (IGNORED_EXT.test(path)) continue;
    const local = path.slice('project/'.length);
    if (FULL_FILES.includes(path) || FULL_PREFIXES.some((p) => path.startsWith(p))) {
      needFull(`${path} affects every test`);
    } else if (TEST_FILE.test(path)) {
      if (index.tests[local] !== undefined) tests.add(local);
      else notes.push(`${path}: deleted test, nothing to run`);
    } else if (path.startsWith('project/tests/')) {
      needFull(`${path} is shared test code`);
    } else {
      const hits = mapSource(local, index, testPaths);
      if (hits.length) hits.forEach((t) => tests.add(t));
      else needFull(`${path}: no test mentions it`);
    }
  }
  if (outside.length) {
    const more = outside.length > 3 ? ` +${outside.length - 3} more` : '';
    notes.push(`${outside.length} path(s) outside project/ need no unit tests (${outside.slice(0, 3).join(', ')}${more})`);
  }
  return { tests: [...tests].sort(), full, notes };
}

function mapSource(local, index, testPaths) {
  const hits = new Set();
  const twin = `tests/unit/test_${basename(local, '.gd')}.gd`;
  if (index.tests[twin] !== undefined) hits.add(twin);
  const names = local.endsWith('.gd') ? index.classNames(local) : [];
  const nameRe = names.length ? new RegExp(`\\b(?:${names.map(escapeRe).join('|')})\\b`) : null;
  for (const t of testPaths) {
    const text = index.tests[t];
    if (text.includes(`res://${local}`) || (nameRe && nameRe.test(text))) hits.add(t);
  }
  return [...hits];
}

/** The real index: every test file under project/tests/{unit,integration}; class_name via file read. */
export function realIndex() {
  const files = walk(join(PROJECT, 'tests'), (n) => /^test_.*\.gd$/.test(n)).map(rel)
    .filter((p) => TEST_FILE.test(p));
  const tests = Object.fromEntries(files.map((f) => [f.slice('project/'.length), readFileSync(join(ROOT, f), 'utf8')]));
  const classNames = (local) => {
    try {
      return [...readFileSync(join(PROJECT, local), 'utf8').matchAll(/^class_name\s+(\w+)/gm)].map((m) => m[1]);
    } catch { return []; }
  };
  return { tests, classNames };
}

/** Changed repo-relative paths: working tree vs `ref` (+ untracked), and with no ref also
 *  HEAD vs the merge-base with main. */
export function changedFiles(ref = null) {
  const lines = (...a) => { try { return git(...a).split('\n').filter(Boolean); } catch { return []; } };
  const out = [...lines('diff', '--name-only', ref ?? 'HEAD'), ...lines('ls-files', '--others', '--exclude-standard')];
  if (!ref) {
    const base = lines('merge-base', 'HEAD', 'main')[0];
    if (base) out.push(...lines('diff', '--name-only', `${base}..HEAD`));
  }
  return [...new Set(out)];
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const args = process.argv.slice(2);
  const res = mapChanges(args.length ? args : changedFiles(), realIndex());
  res.notes.forEach((n) => console.log(`note: ${n}`));
  console.log(res.full ? `FULL suite: ${res.full}` : `${res.tests.length} test file(s):`);
  if (!res.full) res.tests.forEach((t) => console.log(`  ${t}`));
}
