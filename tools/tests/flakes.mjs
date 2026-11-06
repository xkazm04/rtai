#!/usr/bin/env node
// Flake ledger: a machine-wide JSON-lines file every lane appends to when a test fails and then
// passes on an isolated re-run of its file (run_unit.mjs does the re-run).
//   node tools/tests/flakes.mjs report [--min=3]    tests with >= min flakes = quarantine candidates
//   node tools/tests/flakes.mjs path                where the ledger lives
// Ledger path: $GTAI_FLAKES_FILE, else %LOCALAPPDATA%/gtai/flakes.jsonl (~/.local/state/gtai/ elsewhere).
// One entry per line, < 4 KB, written with a single appendFileSync (O_APPEND: lines from concurrent
// lanes do not interleave on NTFS in practice; flakes.test.mjs races two processes to prove it).
// `load` is the number of running Godot processes (os.loadavg() is 0 on Windows), -1 if unknown.
import { appendFileSync, existsSync, mkdirSync, readFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { dirname, join } from 'node:path';
import { spawnSync } from 'node:child_process';
import { pathToFileURL } from 'node:url';
import { ROOT, git } from '../lib/repo.mjs';

export function ledgerPath(env = process.env) {
  if (env.GTAI_FLAKES_FILE) return env.GTAI_FLAKES_FILE;
  const base = env.LOCALAPPDATA || join(homedir(), '.local', 'state');
  return join(base, 'gtai', 'flakes.jsonl');
}

/** Appends one entry as one line. Never throws on a missing directory; returns the path. */
export function recordFlake(entry, path = ledgerPath()) {
  const line = `${JSON.stringify(entry)}\n`;
  if (line.length > 4000) throw new Error('flake entry larger than 4 KB');
  mkdirSync(dirname(path), { recursive: true });
  appendFileSync(path, line, 'utf8');
  return path;
}

/** Valid entries only (a torn or foreign line is skipped, never fatal). */
export function readLedger(path = ledgerPath()) {
  if (!existsSync(path)) return [];
  return readFileSync(path, 'utf8').split('\n').flatMap((l) => {
    try { const e = JSON.parse(l); return e && e.test ? [e] : []; } catch { return []; }
  });
}

/** [{test, file, count, last}] with count >= min, most flaky first. */
export function quarantineCandidates(entries, min = 3) {
  const by = new Map();
  for (const e of entries) {
    const key = `${e.file ?? ''} ${e.test}`;
    const cur = by.get(key) ?? { test: e.test, file: e.file ?? '', count: 0, last: '' };
    cur.count += 1;
    if (String(e.ts) > cur.last) cur.last = String(e.ts);
    by.set(key, cur);
  }
  return [...by.values()].filter((c) => c.count >= min).sort((a, b) => b.count - a.count || a.test.localeCompare(b.test));
}

/** Count of running Godot processes (cheap load proxy), -1 when tasklist is unavailable. */
export function godotProcessCount() {
  if (process.platform !== 'win32') return -1;
  const r = spawnSync('tasklist', ['/FI', 'IMAGENAME eq Godot*', '/FO', 'CSV', '/NH'], { encoding: 'utf8', windowsHide: true });
  if (r.error || r.status !== 0) return -1;
  return r.stdout.split('\n').filter((l) => /^"Godot/i.test(l.trim())).length;
}

/** Entry for one flaky test. */
export function flakeEntry(file, test, now = new Date()) {
  const safe = (...a) => { try { return git(...a); } catch { return ''; } };
  return { ts: now.toISOString(), test, file, commit: safe('rev-parse', 'HEAD'), worktree: ROOT,
    lane: safe('rev-parse', '--abbrev-ref', 'HEAD'), load: godotProcessCount() };
}

/** Splits the first pass's failing cases by the isolated re-run: passed on re-run = flaky, else
 *  still failing (a test missing from the re-run counts as failing). */
export function classifyRerun(failed, rerunCases) {
  const passed = new Set(rerunCases.filter((c) => c.status === 'pass').map((c) => `${c.file} ${c.name}`));
  return {
    flaky: failed.filter((c) => passed.has(`${c.file} ${c.name}`)),
    failing: failed.filter((c) => !passed.has(`${c.file} ${c.name}`)),
  };
}

export function reportText(entries, min = 3) {
  const cands = quarantineCandidates(entries, min);
  const head = `${entries.length} flake(s) in the ledger; ${cands.length} test(s) with >= ${min} (quarantine candidates)`;
  return [head, ...cands.map((c) => `  ${c.count}x ${c.file} ${c.test} (last ${c.last})`)].join('\n');
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const [cmd, ...rest] = process.argv.slice(2);
  const min = Number((rest.find((a) => a.startsWith('--min=')) ?? '--min=3').slice(6));
  if (cmd === 'report' && Number.isInteger(min) && min > 0) {
    console.log(`ledger: ${ledgerPath()}`);
    console.log(reportText(readLedger(), min));
  } else if (cmd === 'path') {
    console.log(ledgerPath());
  } else {
    console.error('usage: node tools/tests/flakes.mjs report [--min=3] | path');
    process.exit(2);
  }
}
