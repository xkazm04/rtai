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
// An asset whose source no longer matches its import is re-imported first (as tools/film does), or the
// run would draw the old pixels (hero n11 line 255); if it still does not match: exit 3, nothing run.
// Exit: 0 verdict ok, 1 the run failed, 2 usage (unknown entry or a refused flag, or the entry's own 2),
// 3 unverifiable (stale assets after --import).
import { mkdirSync, writeFileSync } from 'node:fs';
import { join, resolve as resolvePath } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';
import { describe, HEADLESS_TIMEOUT_MS, runGodot, SCRIPT_ERROR } from '../lib/godot.mjs';
import { verdict } from '../lib/dev_verdict.mjs';
import { staleAssets, touchStale } from '../lib/asset_cache.mjs';
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

/** The lines of an --import run that say an asset did not import (Godot still exits 0 on them). */
export const importErrors = (out) => String(out ?? '').split(/\r?\n/).filter((l) => /ERR_FILE_CORRUPT|Error importing/.test(l));

/** 0 when every asset matches its import (re-importing once if not), 1 an LFS pointer or a failed import, 3 still stale. */
async function freshAssets(project, { runner, err, assets, touch, timeoutMs }) {
  const stale = assets(project, { onFirstScan: () => err('run: first asset check in this tree, hashing every source once (up to a minute)') });
  if (!stale.count) return 0;
  const pointers = stale.pointers ?? [];
  if (pointers.length) {
    err(`run: ${pointers.length} asset(s) are Git LFS pointers, not images (${pointers.slice(0, 5).join(', ')}): \`git show HEAD:<png> > <png>\` writes one. Restore with \`git checkout -- <png> <png>.import\` (or pipe through \`git lfs smudge\`); nothing imported or launched`);
    return 1;
  }
  err(`run: ${stale.count} asset(s) changed since the last import (${stale.sample.join(', ')}): running --import first, or the run draws the old pixels`);
  touch(project);
  const imported = await runner(['--import'], { timeoutMs, name: 'import', ensure: false });
  if (imported.status !== 0 || imported.timedOut) { err(`run: --import failed: ${describe(imported)}`); return 1; }
  const bad = importErrors(imported.out);
  if (bad.length) {
    err(`run: --import exited 0 but ${bad.length} line(s) say an asset did not import, so the run would draw without it; nothing launched:`);
    for (const l of bad.slice(0, 6)) err(`  ${l.trim()}`);
    return 1;
  }
  const still = assets(project);
  if (!still.count) return 0;
  err(`run: UNVERIFIABLE: ${still.count} asset(s) still do not match their import after --import (${still.sample.join(', ')}); nothing launched`);
  return 3;
}

/** The CLI as a function (tests inject `runner`, `out`, `err`, `projectDir`, `logDir`). Returns the exit code. */
export async function main(argv, { runner = runGodot, out = console.log, err = console.error, projectDir,
  logDir = join(ROOT, 'build', 'dev'), now = Date.now, assets = staleAssets, touch = touchStale } = {}) {
  const { entry, rest, opts } = parseArgv(argv);
  if (!entry || !(opts.timeoutMs > 0)) { err(USAGE); return 2; }
  const r = resolve(entry, rest, projectDir ? { projectDir } : {});
  if (!r.ok) { err(`run: ${r.error}`); return 2; }
  if (r.problems.length) return refuse(r, err);
  out(`run: godot ${opts.windowed ? '' : '--headless '}--path project ${r.godotArgs.join(' ')}`);
  if (opts.dryRun) { out(`run: dry run, nothing launched; ${r.specNote}`); return 0; }
  const fresh = await freshAssets(projectDir ?? join(ROOT, 'project'), { runner, err, assets, touch, timeoutMs: opts.timeoutMs });
  if (fresh !== 0) return fresh;
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
