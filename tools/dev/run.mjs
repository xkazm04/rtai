#!/usr/bin/env node
// One front door for dev entries: resolves the entry (tools/dev/entries.mjs), refuses a flag the
// entry's own declared list does not have (exit 2, a did-you-mean, nothing spawned), launches it
// through runGodot (ledger, import preflight, tree-kill timeout) and ends with ONE verdict line
// (tools/lib/dev_verdict.mjs) a lane can paste into its REPORT. The full log goes to build/dev/.
//   node tools/dev/run.mjs <entry> [--windowed] [--timeout=<s>] [--result=<file>] [--dry-run]
//     [--quit-after=<n>] [--fixed-fps=<n>] [--keep-going] [entry flags...] [-- verbatim entry flags...]
// The run is cut short 1.5 s after its first SCRIPT ERROR (the verdict is FAIL either way);
// --keep-going waits for the entry to end or time out instead.
// <entry>: a bare name searched in project/dev (arena, stations_check), a res:// path or a file path.
// Exit: 0 verdict ok, 1 the run failed, 2 usage (unknown entry or a refused flag, or the entry's own 2).
import { mkdirSync, writeFileSync } from 'node:fs';
import { join, resolve as resolvePath } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';
import { describe, HEADLESS_TIMEOUT_MS, runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';
import { verdict } from '../lib/dev_verdict.mjs';
import { resolve } from './entries.mjs';

const USAGE = 'usage: node tools/dev/run.mjs <entry> [--windowed] [--timeout=<s>] [--result=<file>] [--dry-run] '
  + '[--quit-after=<n>] [--fixed-fps=<n>] [--keep-going] [entry flags] [-- entry flags]';
const RUNNER = /^--(windowed|dry-run|keep-going|timeout|result)(?:=(.*))?$/;

/** {entry, rest, opts: {windowed, dryRun, keepGoing, timeoutMs, result}}; runner options only before a `--`. */
export function parseArgv(argv) {
  const opts = { windowed: false, dryRun: false, keepGoing: false, timeoutMs: HEADLESS_TIMEOUT_MS, result: null };
  const rest = [];
  let entry = null;
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--') { rest.push(...argv.slice(i)); break; }
    const m = RUNNER.exec(a);
    if (m?.[1] === 'windowed') opts.windowed = true;
    else if (m?.[1] === 'dry-run') opts.dryRun = true;
    else if (m?.[1] === 'keep-going') opts.keepGoing = true;
    else if (m?.[1] === 'timeout') opts.timeoutMs = Number(m[2]) * 1000;
    else if (m?.[1] === 'result') opts.result = resolvePath(m[2] ?? '');
    else if (entry === null && !a.startsWith('-')) entry = a;
    else rest.push(a);
  }
  return { entry, rest, opts };
}

const stamp = (t) => new Date(t).toISOString().replace(/[:.]/g, '-');

function refuse(r, err) {
  for (const p of r.problems) {
    const hint = p.suggestion ? `did you mean ${p.suggestion}?` : `declared: ${r.spec.join(' ')}`;
    err(`run: unknown flag ${p.flag} for ${r.path} (${hint})`);
  }
  err(`run: refused before launch; ${r.specNote}`);
  return 2;
}

/** The CLI as a function (tests inject `runner`, `out`, `err`, `projectDir`, `logDir`). Returns the exit code. */
export async function main(argv, { runner = runGodot, out = console.log, err = console.error, projectDir,
  logDir = join(ROOT, 'build', 'dev'), now = Date.now } = {}) {
  const { entry, rest, opts } = parseArgv(argv);
  if (!entry || !(opts.timeoutMs > 0)) { err(USAGE); return 2; }
  const r = resolve(entry, rest, projectDir ? { projectDir } : {});
  if (!r.ok) { err(`run: ${r.error}`); return 2; }
  if (r.problems.length) return refuse(r, err);
  out(`run: godot ${opts.windowed ? '' : '--headless '}--path project ${r.godotArgs.join(' ')}`);
  if (opts.dryRun) { out(`run: dry run, nothing launched; ${r.specNote}`); return 0; }
  const startedAt = now();
  const name = `dev-${entry.split(/[\\/]/).pop().replace(/\.(gd|tscn)$/, '')}`;
  const res = await runner(r.godotArgs, { headless: !opts.windowed, timeoutMs: opts.timeoutMs, name,
    stopOn: opts.keepGoing ? null : SCRIPT_ERROR });
  if (res.notFound) err(`run: ${res.out}`);
  mkdirSync(logDir, { recursive: true });
  const log = join(logDir, `${name.slice(4)}-${stamp(startedAt)}.log`);
  writeFileSync(log, `# ${r.godotArgs.join(' ')}\n# ${describe(res)}\n${res.out}`);
  out(`run: log ${log}`);
  const v = verdict(res, { resultFile: opts.result, startedAt, notes: [r.specNote] });
  out(v.line);
  if (v.ok) return 0;
  return res.status === 2 ? 2 : 1;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(await main(process.argv.slice(2)));
}
