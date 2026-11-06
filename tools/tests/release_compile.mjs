#!/usr/bin/env node
// Release-compile pass: does what a release export ships still compile? Copies project/ minus the
// export_presets exclude_filter dirs (tests/, dev/, addons/gut/) into a scratch dir, imports it and
// loads every script/scene there (project/tests/load_release.gd). Needs Godot, so it is not part
// of lint.
// Usage: node tools/tests/release_compile.mjs [--dir=<scratch dir>] [--src=<project dir>] [--keep]
// Exit 0 clean, 1 compile failures, 2 the pass could not run or refused its scratch dir.
//
// Deletion safety: this tool only ever removes a directory it created itself and stamped with
// MARKER. Anything else (unmarked, inside the repo, the src, the home dir, a drive root, reached
// through a link) is refused, never deleted.
import {
  copyFileSync, cpSync, existsSync, lstatSync, mkdirSync, readdirSync, realpathSync, rmSync, writeFileSync,
} from 'node:fs';
import { basename, dirname, join, resolve, sep } from 'node:path';
import { homedir, tmpdir } from 'node:os';
import { pathToFileURL } from 'node:url';
import { PROJECT, ROOT, godotBin, run } from '../lib/repo.mjs';

export const EXCLUDED = ['tests', 'dev', 'addons/gut'];
export const MARKER = '.gtai-release-compile';

export class Refused extends Error {}

/** Real path of `p` even when it does not exist yet (resolves its nearest existing ancestor). */
export function realish(p) {
  const abs = resolve(p);
  const tail = [];
  let cur = abs;
  while (!existsSync(cur)) {
    const up = dirname(cur);
    if (up === cur) break;
    tail.unshift(basename(cur));
    cur = up;
  }
  return join(realpathSync.native(cur), ...tail);
}

const norm = (p) => (process.platform === 'win32' ? p.toLowerCase() : p);
const within = (child, parent) => {
  const [c, p] = [norm(child), norm(parent)];
  return c === p || c.startsWith(p.endsWith(sep) ? p : p + sep);
};

/** Returns the real dest path, or throws Refused. Deletes nothing. */
export function guardDest(dest, src = PROJECT, root = ROOT) {
  const d = realish(dest);
  const s = realish(src);
  const r = realish(root);
  const home = realish(homedir());
  if (dirname(d) === d) throw new Refused(`dest ${d} is a drive/filesystem root`);
  if (within(d, r)) throw new Refused(`dest ${d} is the repo root or inside it`);
  if (within(s, d)) throw new Refused(`dest ${d} is, or contains, the source project ${s}`);
  if (within(r, d)) throw new Refused(`dest ${d} contains the repo root`);
  if (within(home, d)) throw new Refused(`dest ${d} is, or contains, the home directory`);
  return d;
}

/** Removes `d` only when it is a real directory carrying MARKER. Anything else is refused. */
export function removeMarked(d) {
  if (!existsSync(d)) return;
  const st = lstatSync(d);
  if (st.isSymbolicLink() || !st.isDirectory()) throw new Refused(`${d} is not a plain directory`);
  if (!existsSync(join(d, MARKER))) {
    throw new Refused(`${d} exists but was not created by release_compile (no ${MARKER})`);
  }
  rmSync(d, { recursive: true, force: true });
}

/** Throws if any link (symlink/junction) sits inside `dir`. */
function assertNoLinks(dir) {
  for (const e of readdirSync(dir, { withFileTypes: true })) {
    const p = join(dir, e.name);
    if (lstatSync(p).isSymbolicLink()) throw new Refused(`link copied into scratch dir: ${p}`);
    if (e.isDirectory()) assertNoLinks(p);
  }
}

/** Copies project/ without the release-excluded folders; keeps .godot so the import is incremental. */
export function stageRelease(dest, src = PROJECT, root = ROOT) {
  const d = guardDest(dest, src, root);
  removeMarked(d);
  mkdirSync(d, { recursive: true });
  writeFileSync(join(d, MARKER), 'created by tools/tests/release_compile.mjs; safe to delete\n');
  const skip = new Set(EXCLUDED.map((x) => norm(resolve(src, x))));
  const keep = (p) => {
    if (lstatSync(p).isSymbolicLink()) return false;
    const n = norm(resolve(p));
    return !skip.has(n) && !n.endsWith(`${sep}.godot${sep}editor`);
  };
  cpSync(src, d, { recursive: true, dereference: false, filter: keep });
  assertNoLinks(d);
  copyFileSync(join(src, 'tests', 'load_release.gd'), join(d, 'load_release.gd'));
  return d;
}

/** Pure: failing res:// paths named in the load script's output. */
export function failures(out) {
  return [...out.matchAll(/load_release: FAILED (res:\/\/\S+)/g)].map((m) => m[1]);
}

export function releaseCompile({ dir, keep = false, src = PROJECT } = {}) {
  const bin = godotBin();
  const dest = stageRelease(dir ?? join(tmpdir(), 'gtai-release-compile'), src);
  const imp = run(bin, ['--headless', '--path', dest, '--import']);
  const res = run(bin, ['--headless', '--path', dest, '-s', 'res://load_release.gd']);
  if (!keep) removeMarked(dest);
  const failed = failures(res.out);
  const ran = /load_release: (\d+) loaded, (\d+) failed/.exec(res.out);
  const errors = [...res.out.matchAll(/^(?:SCRIPT ERROR|ERROR): .*$/gm)].map((m) => m[0]);
  const ok = ran !== null && failed.length === 0 && res.status === 0;
  return { ok, ran: ran ? Number(ran[1]) : null, failed, errors, status: res.status, importStatus: imp.status, out: res.out };
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const arg = (k) => process.argv.find((a) => a.startsWith(`--${k}=`))?.slice(k.length + 3);
  try {
    const src = arg('src');
    const r = releaseCompile({
      dir: arg('dir'),
      keep: process.argv.includes('--keep'),
      src: src ? resolve(src) : PROJECT,
    });
    if (r.ran === null) {
      console.error(`release_compile: the load pass did not run (exit ${r.status})\n${r.out.slice(-2000)}`);
      process.exit(2);
    }
    for (const p of r.failed) console.error(`release_compile: FAILED ${p}`);
    for (const e of r.errors.slice(0, 20)) console.error(`  ${e}`);
    console.log(`release_compile: ${r.ran} loaded, ${r.failed.length} failed`);
    process.exit(r.ok ? 0 : 1);
  } catch (e) {
    if (!(e instanceof Refused)) throw e;
    console.error(`release_compile: refused: ${e.message}`);
    process.exit(2);
  }
}
