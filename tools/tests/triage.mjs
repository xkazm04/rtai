// Red-run triage for run_unit.mjs: one block per failure with the cause, whether YOUR diff reaches
// the test, its flake history and a paste-ready rerun command; written to
// build/test-results/unit-triage.json (gtai.unit-triage/1) so agents read it instead of the log.
//   cause   GUT's numbered engine errors (junit `cause`) + the ERROR / at: / first backtrace frame
//           the log prints under that test's '* test_' header (logSlice).
//   verdict REACHED by <changed path>   the one-hop reach index (reach_index.mjs reachOf) maps it
//           FULL: <reason>              the change maps the whole suite, so it cannot be ruled out
//           UNMAPPED: the map is not exhaustive - ...  a changed path outside project/ (native/, tools/),
//                                       a longer chain than the index follows (found by a bounded walk
//                                       over the same index, chain shown), or the walk hit its cap
//           NO DIFF / UNREACHED ... suspect the base or the machine   only when the walk exhausted every
//                                       file that names (or res://-references) a changed file
//           PARSE res://f.gd:N          a SCRIPT ERROR Parse/Compile error: GUT skips that file silently
// The UNREACHED wording is only ever said for a search that ran out of files, never for one cut short.
import { mkdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { removeStale } from '../lib/godot.mjs';
import { readLedger } from './flakes.mjs';
import { formatChain, reachOf } from './reach_index.mjs';

export const TRIAGE_NAME = 'unit-triage.json';
export const TRIAGE_SCHEMA = 'gtai.unit-triage/1';
const RUN = 'node tools/tests/run_unit.mjs';
const MAX_WALK = 2000;
const MAX_ERRORS = 3;
const SAFE_OUTSIDE = /^(docs\/|steam\/|\.claude\/)|\.md$/;
const ENGINE_ERROR = /^(?:USER )?(?:SCRIPT )?ERROR:/;
const PARSE_ERROR = /SCRIPT ERROR:.*(?:Parse|Compile) Error|^Parse Error:/;
const AT_RES = /(res:\/\/[^\s():]+):(\d+)/;
const stem = (file) => file.split('/').pop().replace(/\.gd$/, '');
const escapeRe = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

/** The engine output GUT logged under `* name` in `file`'s section: each ERROR line, its at: line and the
 *  first GDScript backtrace frame (at most 3 errors). [] when the test logged none. */
export function logSlice(log, file, name) {
  const lines = log.split('\n').map((l) => l.replace(/\r$/, ''));
  const head = lines.findIndex((l) => l === file || l.startsWith(`${file}.`));
  if (head < 0) return [];
  let i = head + 1;
  const endOfFile = (l) => /^res:\/\//.test(l) || /^\d+\/\d+ passed/.test(l) || l.startsWith('=====');
  while (i < lines.length && lines[i].trim() !== `* ${name}` && !endOfFile(lines[i])) i++;
  if (i >= lines.length || lines[i].trim() !== `* ${name}`) return [];
  const out = [];
  let errors = 0;
  for (let j = i + 1; j < lines.length && !lines[j].startsWith('* test_') && !endOfFile(lines[j]); j++) {
    if (!ENGINE_ERROR.test(lines[j].trim()) || ++errors > MAX_ERRORS) continue;
    out.push(lines[j].trim());
    if (/^\s*at:/.test(lines[j + 1] ?? '')) out.push(lines[j + 1].trim());
    for (let k = j + 1; k < Math.min(lines.length, j + 6); k++) {
      if (/^\s*\[0\]/.test(lines[k])) { out.push(lines[k].trim()); break; }
    }
  }
  return out;
}

export const rerunCommand = (file, name) => `${RUN} --select=${stem(file)}${name ? ` --test=${name}` : ''}`;

/** PARSE entries from the step outputs: one per file:line a Parse/Compile SCRIPT ERROR names. */
export function parseEntries(outs) {
  const seen = new Map();
  for (const out of outs) {
    const lines = out.split('\n').map((l) => l.trim());
    lines.forEach((l, i) => {
      if (!PARSE_ERROR.test(l)) return;
      const at = [lines[i + 1], lines[i + 2]].find((n) => n && /^at:/.test(n) && AT_RES.test(n));
      const m = at ? AT_RES.exec(at) : AT_RES.exec(l);
      if (!m || seen.has(`${m[1]}:${m[2]}`)) return;
      const isTest = /^res:\/\/tests\/.*\/test_[^/]*\.gd$/.test(m[1]);
      seen.set(`${m[1]}:${m[2]}`, { file: m[1], line: Number(m[2]), name: '', message: l, cause: at ? [l, at] : [l],
        verdict: `PARSE ${m[1]}:${m[2]} does not parse (GUT skips such a file silently; every test in it is unrun)`,
        reach: [], flakes: { count: 0, last: '', lanes: [] },
        rerun: isTest ? rerunCommand(m[1], '') : `node tools/godot/check.mjs ${m[1]}` });
    });
  }
  return [...seen.values()];
}

const REFERRERS = new WeakMap();

/** Files that name a class `local` declares or res://-reference it (exactly, or via a parent dir). Memoised per reach. */
function referrersOf(local, reach) {
  if (!REFERRERS.has(reach)) REFERRERS.set(reach, new Map());
  const memo = REFERRERS.get(reach);
  if (!memo.has(local)) memo.set(local, scanReferrers(local, reach));
  return memo.get(local);
}

function scanReferrers(local, reach) {
  const names = reach.names[local] ?? [];
  const re = names.length ? new RegExp(`\\b(${names.map(escapeRe).join('|')})\\b`) : null;
  const out = [];
  for (const [file, text] of Object.entries(reach.sources)) {
    if (file === local) continue;
    if (reach.refs.get(local)?.has(file)) { out.push([file, 'res:// path']); continue; }
    const m = re?.exec(text);
    if (m) { out.push([file, `names ${m[1]}`]); continue; }
    const dir = local.split('/').slice(0, -1).join('/');
    if (dir.includes('/') && reach.refs.get(dir)?.has(file)) out.push([file, `res:// dir ${dir}/`]);
  }
  return out;
}

/** How the test reaches `local` (it is an autoload, or the test names its res:// path or a class it declares), or null. */
function testReaches(local, testText, reach) {
  if (reach.autoloadOf[local]) return `autoload ${reach.autoloadOf[local]}: GUT boots it for every test`;
  if (testText.includes(`res://${local}`)) return 'res:// path';
  for (const n of reach.names[local] ?? []) if (new RegExp(`\\b${escapeRe(n)}\\b`).test(testText)) return `names ${n}`;
  return null;
}

/** Breadth-first walk from the changed files over referrers, beyond the index's one hop.
 *  -> {chain} on a hit, {capped: true} when cut short, {} when every referrer was visited. */
function walkToTest(locals, test, index) {
  const reach = index.reach;
  const text = index.tests[test] ?? '';
  const seen = new Set(locals);
  let frontier = locals.map((l) => [{ file: l }]);
  while (frontier.length) {
    const next = [];
    for (const path of frontier) {
      for (const [file, how] of referrersOf(path.at(-1).file, reach)) {
        if (seen.has(file)) continue;
        if (seen.size >= MAX_WALK) return { capped: true };
        seen.add(file);
        const step = [...path, { file, how }];
        const hit = testReaches(file, text, reach);
        if (hit) return { chain: [...step, { file: test, how: hit }] };
        next.push(step);
      }
    }
    frontier = next;
  }
  return {};
}

/** -> {verdict, reach: string[]} for the failing test `file` (res://...) against the changed paths. */
export function verdictOf(file, changed, index, r = reachOf(changed, index)) {
  const test = file.replace(/^res:\/\//, '');
  const chains = r.reached[test];
  if (chains?.length) return { verdict: `REACHED by project/${chains[0][0].file}`, reach: chains.map(formatChain) };
  if (r.full) return { verdict: `FULL: ${r.full} - every test is in reach of this change`, reach: [] };
  const counted = changed.filter((p) => !/\.(uid|import)$/.test(p) && !SAFE_OUTSIDE.test(p));
  const outside = counted.filter((p) => !p.startsWith('project/'));
  if (outside.length) {
    return { verdict: `UNMAPPED: the map is not exhaustive - ${outside[0]}${outside.length > 1 ? ` (+${outside.length - 1})` : ''} is outside project/ and can still break a test`, reach: [] };
  }
  if (index.tests[test] === undefined) return { verdict: `UNMAPPED: the map is not exhaustive - ${test} is not in the test index`, reach: [] };
  if (!counted.length) return { verdict: 'NO DIFF: you changed nothing the tests load - suspect the base or the machine', reach: [] };
  const walk = index.reach ? walkToTest(counted.map((p) => p.slice('project/'.length)), test, index) : { capped: true };
  if (walk.chain) {
    const hops = walk.chain.length - 2;
    return { verdict: `UNMAPPED: the map is not exhaustive - project/${walk.chain[0].file} reaches this test in ${hops} hops (past the one-hop index)`, reach: [formatChain(walk.chain)] };
  }
  if (walk.capped) return { verdict: `UNMAPPED: the map is not exhaustive - the reach walk stopped at ${MAX_WALK} files`, reach: [] };
  return { verdict: `UNREACHED: none of your ${counted.length} changed file(s) reaches this test - suspect the base or the machine`, reach: [] };
}

/** {count, last, lanes} for one test in the flake ledger entries. */
export function flakeHistory(ledger, file, name) {
  const hits = ledger.filter((e) => e.test === name && (e.file ?? file) === file);
  const last = hits.reduce((a, e) => (String(e.ts) > a ? String(e.ts) : a), '');
  return { count: hits.length, last, lanes: [...new Set(hits.map((e) => e.lane).filter(Boolean))].sort() };
}

/** Entries for the still-failing cases plus the PARSE errors in `outs` (each step's output). */
export function triage({ failing, gutOut = '', outs = [], changed, index, ledger = null }) {
  const flakes = ledger ?? (() => { try { return readLedger(); } catch { return []; } })();
  const r = reachOf(changed, index);
  const entries = failing.map((c) => {
    const cause = [...new Set([...(c.cause ?? []), ...logSlice(gutOut, c.file, c.name)])];
    return { file: c.file, line: c.line, name: c.name, message: c.message || 'failed', cause,
      ...verdictOf(c.file, changed, index, r), flakes: flakeHistory(flakes, c.file, c.name), rerun: rerunCommand(c.file, c.name) };
  });
  return [...entries, ...parseEntries(outs)];
}

/** The printed block for one entry; its last line is the rerun command. */
export function blockLines(e) {
  const f = e.flakes;
  return [
    `  FAIL ${e.file}:${e.line}${e.name ? ` ${e.name}` : ''} - ${e.message}`,
    ...e.cause.filter((l) => l !== e.message).map((l) => `    cause: ${l}`),
    `    verdict: ${e.verdict}`,
    ...e.reach.slice(0, 3).map((l) => `      via ${l}`),
    ...(f.count ? [`    flaked ${f.count}x before (last ${f.last}, ${f.lanes.join(', ') || 'unknown lane'})`] : []),
    `    rerun: ${e.rerun}`,
  ];
}

/** Writes unit-triage.json for a red run; a green run removes a stale one. */
export function writeTriage(outDir, entries, ok) {
  const path = join(outDir, TRIAGE_NAME);
  if (ok) { removeStale(path); return null; }
  mkdirSync(outDir, { recursive: true });
  writeFileSync(path, `${JSON.stringify({ schema: TRIAGE_SCHEMA, entries }, null, 2)}\n`, 'utf8');
  return path;
}
