#!/usr/bin/env node
// A file as it was at a commit, real bytes: `git show <rev>:<png> > x.png` writes the Git LFS
// pointer for an LFS-tracked asset, not the image (hero's FRICTION, n15). This reads the blob and,
// when it is a pointer, runs it through `git lfs smudge` (which reads the local LFS store, fetching
// only when the object is missing).
//   node tools/film/blob.mjs <rev>:<repo path> [--out=<file>]   (default out: build/blob/<rev>/<path>)
// Exit 0 written, 1 git or LFS failed, 2 usage.
import { execFileSync } from 'node:child_process';
import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';

export const LFS_HEADER = 'version https://git-lfs.github.com/spec/v1';
const USAGE = 'usage: node tools/film/blob.mjs <rev>:<repo path> [--out=<file>]';

export const isPointer = (buf) => buf.subarray(0, LFS_HEADER.length).toString('latin1') === LFS_HEADER;

export function parseArgs(argv) {
  const specs = argv.filter((a) => !a.startsWith('--'));
  const flags = argv.filter((a) => a.startsWith('--'));
  const bad = flags.find((f) => !f.startsWith('--out='));
  if (bad) throw new Error(`unknown flag ${bad}\n${USAGE}`);
  if (specs.length !== 1 || !/^[^:]+:.+/.test(specs[0])) throw new Error(USAGE);
  const [rev, ...rest] = specs[0].split(':');
  const path = rest.join(':').replace(/\\/g, '/').replace(/^\.?\//, '');
  const out = flags.find((f) => f.startsWith('--out='))?.slice(6) || join('build', 'blob', rev.replace(/[^\w.-]/g, '_'), path);
  return { rev, path, out };
}

/** {bytes, lfs}: the blob at rev:path, smudged when it is an LFS pointer. `run(args, input)` is git. */
export function readBlob(rev, path, { cwd = ROOT, run = gitRun(cwd) } = {}) {
  const raw = run(['cat-file', 'blob', `${rev}:${path}`]);
  if (!isPointer(raw)) return { bytes: raw, lfs: false };
  const bytes = run(['lfs', 'smudge', '--', path], raw);
  if (isPointer(bytes)) throw new Error(`git lfs smudge returned the pointer again for ${path} (is git-lfs installed?)`);
  return { bytes, lfs: true };
}

const gitRun = (cwd) => (args, input) => execFileSync('git', args, { cwd, input, maxBuffer: 1 << 30, stdio: ['pipe', 'pipe', 'pipe'] });

export function main(argv, { cwd = ROOT, run, out: say = console.log, err = console.error } = {}) {
  let a;
  try { a = parseArgs(argv); } catch (e) { err(`blob: ${e.message}`); return 2; }
  let r;
  try { r = readBlob(a.rev, a.path, { cwd, run: run ?? gitRun(cwd) }); } catch (e) {
    err(`blob: ${a.rev}:${a.path}: ${String(e.stderr ?? e.message).trim().split('\n')[0]}`);
    return 1;
  }
  const file = resolve(cwd, a.out);
  mkdirSync(dirname(file), { recursive: true });
  writeFileSync(file, r.bytes);
  say(`blob: wrote ${file} (${r.bytes.length} bytes, ${r.lfs ? 'LFS object, smudged' : 'plain blob'})`);
  return 0;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) process.exit(main(process.argv.slice(2)));
