#!/usr/bin/env node
// Fast parse check without the windowed-hang risk of running a broken script for real.
//   node tools/godot/check.mjs <res://path | project-relative | absolute file> ...
// .gd  -> `--headless --path project --check-only -s <script>` (Godot parses it and quits).
// .tscn/.tres -> no check-only exists for resources, so a throwaway SceneTree script (written to
//   the OS temp dir, deleted after) load()s each one; a broken dependent script shows up as a parse error.
// Prints `ok <path>` or the error lines (file:line); exit 0 all ok, 1 some failed, 2 usage/no Godot.
// Each file gets a 60 s budget with a process-tree kill. A stale class cache is refreshed first
// (runGodot does that once per process), so a script using a brand new class_name is not a false alarm.
import { existsSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { isAbsolute, join, relative, resolve, sep } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';
import { runGodot } from '../lib/godot.mjs';

export const CHECK_TIMEOUT_MS = 60 * 1000;
const ERROR_LINE = /SCRIPT ERROR|Parse Error|Compile Error|Failed to load|ERROR:|^\s+at: /;
const PROJECT = join(ROOT, 'project');

/** res:// path for any accepted spelling, or null when it is outside project/. */
export function toRes(arg) {
  if (arg.startsWith('res://')) return arg;
  const abs = isAbsolute(arg) ? arg : (existsSync(resolve(arg)) ? resolve(arg) : join(PROJECT, arg));
  const r = relative(PROJECT, abs).split(sep).join('/');
  return r.startsWith('..') || isAbsolute(r) ? null : `res://${r}`;
}

/** Autoload singleton names from project.godot: --check-only does not register them, so a script that
 *  names one reports "Identifier not found: Log" although it is fine at run time. */
const autoloadNames = () => {
  try {
    const sec = /^\[autoload\]([^[]*)/m.exec(readFileSync(join(PROJECT, 'project.godot'), 'utf8'));
    return new Set([...(sec?.[1] ?? '').matchAll(/^(\w+)=/gm)].map((m) => m[1]));
  } catch { return new Set(); }
};

const isAt = (l) => /^\s+at: /.test(l ?? '');

/** The error lines of a run minus autoload-identifier false positives (and their `at:` lines). When
 *  nothing else was reported the script is fine, so the generic "Failed to load script" trailer goes too. */
export function errorLines(out, autoloads = autoloadNames()) {
  const lines = out.split('\n').filter((l) => ERROR_LINE.test(l)).map((l) => l.trimEnd());
  const kept = [];
  for (let i = 0; i < lines.length; i += 1) {
    const m = /Identifier not found: (\w+)/.exec(lines[i]);
    if (m && autoloads.has(m[1])) {
      while (isAt(lines[i + 1])) i += 1;
      continue;
    }
    kept.push(lines[i]);
  }
  const real = kept.filter((l) => !isAt(l) && !/Failed to load script/.test(l));
  return real.length ? kept : [];
}

/** ok when nothing but autoload false positives was reported (Godot still exits 1 for those). */
const judge = (r, bad) => ({
  ...r,
  ok: !r.timedOut && bad.length === 0 && (r.status === 0 || ERROR_LINE.test(r.out)),
  lines: bad,
});

async function checkScript(res) {
  const r = await runGodot(['--check-only', '-s', res], { name: 'check', timeoutMs: CHECK_TIMEOUT_MS });
  const bad = errorLines(r.out);
  return judge(r, bad);
}

async function checkResource(res) {
  const tmp = join(tmpdir(), `gtai-check-${process.pid}-${Date.now()}.gd`);
  writeFileSync(tmp, `extends SceneTree\n\nfunc _initialize() -> void:\n\tvar r: Resource = load("${res}")\n\tquit(0 if r != null else 3)\n`);
  try {
    const r = await runGodot(['-s', tmp.split(sep).join('/')], { name: 'check', timeoutMs: CHECK_TIMEOUT_MS });
    const bad = errorLines(r.out);
    return judge(r, bad);
  } finally {
    rmSync(tmp, { force: true, recursive: false }); // one explicit file under os.tmpdir()
  }
}

/** Checks each target; {results: [{target, ok, lines, note}], code}. */
export async function checkAll(targets) {
  const results = [];
  for (const t of targets) {
    const res = toRes(t);
    if (!res) { results.push({ target: t, ok: false, lines: [`not under project/: ${t}`], note: 'usage' }); continue; }
    if (!existsSync(join(PROJECT, res.slice(6)))) { results.push({ target: res, ok: false, lines: ['no such file'], note: 'usage' }); continue; }
    const r = /\.gd$/.test(res) ? await checkScript(res) : await checkResource(res);
    if (r.notFound) return { results: [{ target: res, ok: false, lines: [r.out], note: 'nogodot' }], code: 2 };
    const lines = r.timedOut ? [`timed out after ${CHECK_TIMEOUT_MS / 1000} s (killed)`, ...r.lines] : r.lines;
    results.push({ target: res, ok: r.ok, lines: lines.length || r.ok ? lines : [`exit ${r.status}`, ...r.out.split('\n').slice(-5)] });
  }
  return { results, code: results.some((x) => x.note === 'usage') ? 2 : results.every((x) => x.ok) ? 0 : 1 };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const targets = process.argv.slice(2);
  if (!targets.length) {
    console.error('usage: node tools/godot/check.mjs <res://path | file> ...');
    process.exit(2);
  }
  const { results, code } = await checkAll(targets);
  for (const r of results) {
    if (r.ok) console.log(`ok ${r.target}`);
    else console.log(`FAIL ${r.target}\n${r.lines.map((l) => `  ${l}`).join('\n')}`);
  }
  process.exit(code);
}
