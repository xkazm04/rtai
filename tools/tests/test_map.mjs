// Changed file -> unit/integration test files (repo-relative to project/, e.g. tests/unit/test_x.gd).
//   node tools/tests/test_map.mjs [<changed path>...]     (no args: the working-tree changes)
//   node tools/tests/test_map.mjs --why=<test> [<path>...] the reach chain to that test; exit 1 'not reached'
//   node tools/tests/test_map.mjs --history[=600]         replay the last N non-merge commits through the map
// Rules: tools/tests/reach_index.mjs (header). In short: a changed test maps to itself; a .gd to the tests
// naming its classes/autoloads or res:// path (+ the test_<basename> twin), plus the direct tests of its
// one-hop dependents; any other file through the files whose res:// literal (or nearest ancestor-directory
// literal) names it; dev/ nobody reaches and scenario code map to nothing; support code, project.godot,
// .gutconfig.json, addons/, data/schemas, an unreferenced asset -> the FULL suite (with the reason);
// paths outside project/ need no unit tests.
import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { PROJECT, ROOT, git, rel, walk } from '../lib/repo.mjs';
import { formatChain, realReachIndex, reachOf } from './reach_index.mjs';

const TEST_FILE = /^project\/tests\/(unit|integration)\/(?:.*\/)?test_[^/]*\.gd$/;
const COUNTED = (p) => p.startsWith('project/') && !/\.(uid|import|md)$/.test(p);

/** Pure. changed: repo-relative paths. index: {tests: {<path relative to project/>: text},
 *  classNames(projectRelPath) -> string[], reach?: reach index}. -> {tests, full: string|null, notes}. */
export function mapChanges(changed, index) {
  const r = reachOf(changed, index);
  return { tests: Object.keys(r.reached), full: r.full, notes: r.notes };
}

/** The real index: every test file under project/tests/{unit,integration}; class_name via file read;
 *  `reach` (tools/tests/reach_index.mjs) is built on first use. */
export function realIndex() {
  const files = walk(join(PROJECT, 'tests'), (n) => /^test_.*\.gd$/.test(n)).map(rel)
    .filter((p) => TEST_FILE.test(p));
  const tests = Object.fromEntries(files.map((f) => [f.slice('project/'.length), readFileSync(join(ROOT, f), 'utf8')]));
  const classNames = (local) => {
    try {
      return [...readFileSync(join(PROJECT, local), 'utf8').matchAll(/^class_name\s+(\w+)/gm)].map((m) => m[1]);
    } catch { return []; }
  };
  let reach = null;
  return { tests, classNames, get reach() { return (reach ??= realReachIndex()); } };
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

/** Pure. commits: [{sha, files}]; map(files) -> mapChanges result; total = files a FULL run selects.
 *  Counts commits with a project/ path (not .uid/.import/.md). -> {commits, full, pctFull, zero, meanFiles, reasons}. */
export function replayHistory(commits, map, { total }) {
  let full = 0; let files = 0; let zero = 0; let n = 0;
  const reasons = {};
  for (const c of commits) {
    if (!c.files.some(COUNTED)) continue;
    n++;
    const r = map(c.files);
    if (r.full) {
      full++; files += total;
      const key = r.full.replace(/^unreferenced asset /, '').split(/[: ]/)[0].split('/').slice(0, 3).join('/');
      reasons[key] = (reasons[key] ?? 0) + 1;
    } else { files += r.tests.length; if (!r.tests.length) zero++; }
  }
  const pct = (x) => (n ? Math.round((100 * x) / n) : 0);
  return { commits: n, full, pctFull: pct(full), zero, meanFiles: n ? Math.round((10 * files) / n) / 10 : 0, reasons };
}

/** The last `n` non-merge commits, keeping only paths that still exist (the index is today's tree). */
export function gitHistory(n) {
  const log = git('log', '--no-merges', `-n${n}`, '--name-only', '--format=@@%h');
  return log.split('@@').slice(1).map((b) => {
    const [sha, ...f] = b.trim().split('\n');
    return { sha, files: f.filter((p) => p && existsSync(join(ROOT, p))) };
  });
}

function cliWhy(test, paths, index) {
  const r = reachOf(paths, index);
  const chains = r.reached[test];
  if (chains) {
    console.log(`${test}: reached`);
    chains.forEach((c) => console.log(`  ${formatChain(c)}`));
    return 0;
  }
  if (r.full) { console.log(`${test}: reached (FULL suite: ${r.full})`); return 0; }
  console.log(`${test}: not reached by ${paths.join(', ') || '(no changes)'}`);
  return 1;
}

function cliHistory(n, index) {
  const h = replayHistory(gitHistory(n), (files) => mapChanges(files, index), { total: Object.keys(index.tests).length });
  console.log(`last ${n} non-merge commits; commits touching project/: ${h.commits}`);
  console.log(`FULL: ${h.full} (${h.pctFull}%); need no unit tests: ${h.zero}`);
  console.log(`mean selected files: ${h.meanFiles} (FULL counts as ${Object.keys(index.tests).length})`);
  const top = Object.entries(h.reasons).sort((a, b) => b[1] - a[1]).slice(0, 6);
  if (top.length) console.log(`top FULL reasons: ${top.map(([k, v]) => `${k} ${v}`).join(', ')}`);
  return 0;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const args = process.argv.slice(2);
  const why = args.find((a) => a.startsWith('--why='));
  const hist = args.find((a) => a === '--history' || a.startsWith('--history='));
  const paths = args.filter((a) => !a.startsWith('--'));
  const unknown = args.filter((a) => a.startsWith('--') && a !== why && a !== hist);
  if (unknown.length) { console.error(`test_map: unknown argument ${unknown[0]}`); process.exit(2); }
  const index = realIndex();
  if (hist) process.exit(cliHistory(Number(hist.split('=')[1] ?? 600) || 600, index));
  const changed = paths.length ? paths : changedFiles();
  if (why) process.exit(cliWhy(why.slice('--why='.length).replace(/^project\//, ''), changed, index));
  const res = mapChanges(changed, index);
  res.notes.forEach((n) => console.log(`note: ${n}`));
  console.log(res.full ? `FULL suite: ${res.full}` : `${res.tests.length} test file(s):`);
  if (!res.full) res.tests.forEach((t) => console.log(`  ${t}`));
}
