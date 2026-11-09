#!/usr/bin/env node
// The lint rules builders keep tripping, on the files you changed, in seconds, before the commit
// hook finds them one round trip at a time: CRLF left by gdformat or a text-mode write, gdformat,
// line length and the other gdlint rules, the size and function caps, the banned APIs, and the
// engine's own parse check, which is the only thing that sees a warning-as-error such as float(Variant).
//   node tools/gate/quick.mjs [--files=<a,b>] [--fix] [--no-godot]
// With no --files it checks every changed, staged or untracked .gd under project/ (never addons/).
// --fix runs gdformat and strips CRLF, then checks. A file that grew past the soft cap fails even
// though the full lint only warns, because the debt ratchet stops the commit for it.
// Exit: 0 ok, 1 issues, 2 usage, 3 unverifiable (a checker could not run, so the file is unproven).
import { spawnSync } from 'node:child_process';
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { join, relative, resolve, sep } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';
import { FILE_SOFT_LINES, checkAll } from '../style/check_gd.mjs';

const USAGE = 'usage: node tools/gate/quick.mjs [--files=<a,b>] [--fix] [--no-godot]';
const LINE_LENGTH = ['--line-length', '100'];

const norm = (p) => p.split(sep).join('/');
const isGame = (p) => p.endsWith('.gd') && p.startsWith('project/') && !p.startsWith('project/addons/');

/** Project-relative .gd paths from `git status --porcelain -z`. NUL-separated, so a path is never
 *  quoted or escaped; a rename or copy is followed by one extra record, the old path. */
export function changedFromPorcelain(z) {
  const paths = [];
  const records = z.split('\0').filter(Boolean);
  for (let i = 0; i < records.length; i++) {
    const status = records[i].slice(0, 2);
    if (/[RC]/.test(status)) i += 1;
    if (!/D/.test(status)) paths.push(records[i - (/[RC]/.test(status) ? 1 : 0)].slice(3));
  }
  return paths.filter(isGame).sort();
}

export const hasCrlf = (buffer) => buffer.includes('\r\n');

/** Lines of the HEAD version of a file, or 0 when it is new (git prints nothing and fails). */
function headLines(root, path) {
  const r = spawnSync('git', ['-C', root, 'show', `HEAD:${path}`], { encoding: 'utf8', windowsHide: true, maxBuffer: 1 << 26 });
  if (r.status !== 0) return 0;
  return lineCount(r.stdout);
}

export function lineCount(text) {
  const lines = text.split('\n');
  if (lines.at(-1) === '') lines.pop();
  return lines.length;
}

/** {issue} per file now past the soft cap that was under it at HEAD. */
export function softCapIssues(entries) {
  return entries.filter(({ lines, before }) => lines > FILE_SOFT_LINES && before <= FILE_SOFT_LINES)
    .map(({ path, lines, before }) => `${path}: ${lines} lines > ${FILE_SOFT_LINES} (it was ${before}; the debt ratchet stops the commit)`);
}

/** Runs a checker. {ok, out} or {missing: true} when it could not be started at all. */
function tool(cmd, args, root) {
  const r = spawnSync(cmd, args, { cwd: root, encoding: 'utf8', windowsHide: true, shell: process.platform === 'win32', maxBuffer: 1 << 26 });
  if (r.error || r.status === 9009 || r.status === 127) return { missing: true, out: String(r.error ?? r.stderr ?? '') };
  return { ok: r.status === 0, out: `${r.stdout ?? ''}${r.stderr ?? ''}`, status: r.status };
}

const gdLines = (out) => out.split('\n').filter((l) => /would reformat|:\d+: Error/.test(l)).map((l) => l.trim());

/** A failing checker that names no file is one that did not run: under cmd.exe a missing command is
 *  only a non-zero exit. Returns the issue lines; an unreadable failure goes to `unverifiable`. */
export function verdictOf(name, result, unverifiable) {
  if (result.missing) { unverifiable.push(`${name} could not run`); return []; }
  if (result.ok) return [];
  const lines = gdLines(result.out);
  if (!lines.length) unverifiable.push(`${name} exited ${result.status} without naming a file: ${result.out.trim().split('\n')[0]}`);
  return lines;
}

/** Every check on `paths` (project-relative). {issues, unverifiable}. */
export function checkFiles(paths, { root = ROOT, godot = true, run = tool } = {}) {
  const issues = [];
  const unverifiable = [];
  const abs = paths.map((p) => join(root, p));
  for (const [i, p] of paths.entries()) {
    if (hasCrlf(readFileSync(abs[i]))) issues.push(`${p}: CRLF line endings (gdformat on Windows and Python text-mode writes do this; --fix strips them)`);
  }
  const fmt = run('gdformat', ['--check', ...LINE_LENGTH, ...paths], root);
  issues.push(...verdictOf('gdformat', fmt, unverifiable).map((l) => `gdformat: ${l}`));
  const lint = run('gdlint', paths, root);
  issues.push(...verdictOf('gdlint', lint, unverifiable));
  for (const c of checkAll(abs)) issues.push(...(c.issues ?? []));
  issues.push(...softCapIssues(paths.map((path, i) => ({ path, lines: lineCount(readFileSync(abs[i], 'utf8')), before: headLines(root, path) }))));
  if (godot) {
    const check = run('node', ['tools/godot/check.mjs', ...paths], root);
    if (check.missing || check.status === 2) unverifiable.push(`the Godot parse check could not run${check.out ? `: ${check.out.split('\n')[0]}` : ''}`);
    else if (!check.ok) issues.push(...check.out.split('\n').map((l) => l.trim()).filter((l) => l && !l.startsWith('ok ')));
  }
  return { issues, unverifiable };
}

function fix(paths, root, run) {
  const r = run('gdformat', [...LINE_LENGTH, ...paths], root);
  if (r.missing) return 'gdformat could not run';
  for (const p of paths) {
    const file = join(root, p);
    const bytes = readFileSync(file);
    if (hasCrlf(bytes)) writeFileSync(file, bytes.toString('utf8').replace(/\r\n/g, '\n'));
  }
  return null;
}

/** The CLI as a function. Returns the exit code. */
export function main(argv, { root = ROOT, out = console.log, err = console.error, run = tool } = {}) {
  const opts = { files: null, fix: false, godot: true };
  for (const a of argv) {
    const m = /^--files=(.+)$/.exec(a);
    if (m) opts.files = m[1].split(',').filter(Boolean);
    else if (a === '--fix') opts.fix = true;
    else if (a === '--no-godot') opts.godot = false;
    else { err(`quick: bad argument ${a}\n${USAGE}`); return 2; }
  }
  const t0 = Date.now();
  let paths;
  if (opts.files) {
    paths = opts.files.map((f) => norm(relative(root, resolve(root, f))));
    const missing = paths.filter((p) => !existsSync(join(root, p)));
    if (missing.length) { err(`quick: no such file: ${missing.join(', ')}`); return 2; }
  } else {
    const status = spawnSync('git', ['-C', root, 'status', '--porcelain', '-z'], { encoding: 'utf8', windowsHide: true });
    paths = changedFromPorcelain(status.stdout).filter((p) => existsSync(join(root, p)));
  }
  if (!paths.length) { out('quick: no changed .gd files, nothing checked'); return 0; }
  if (opts.fix) {
    const e = fix(paths, root, run);
    if (e) { err(`quick: --fix failed: ${e}`); return 3; }
  }
  const { issues, unverifiable } = checkFiles(paths, { root, godot: opts.godot, run });
  for (const i of issues) out(i);
  for (const u of unverifiable) out(`UNVERIFIABLE: ${u}`);
  const secs = ((Date.now() - t0) / 1000).toFixed(1);
  if (issues.length) { out(`quick: FAIL, ${issues.length} issue(s) in ${paths.length} file(s), ${secs} s`); return 1; }
  if (unverifiable.length) { out(`quick: UNVERIFIABLE, ${unverifiable.length} checker(s) could not run, ${paths.length} file(s), ${secs} s`); return 3; }
  out(`quick: ok, ${paths.length} file(s), ${secs} s`);
  return 0;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(main(process.argv.slice(2)));
}
