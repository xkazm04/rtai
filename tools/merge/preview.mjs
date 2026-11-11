#!/usr/bin/env node
// What the morning merge will meet, without a worktree: the lanes merged onto the base in the order
// given (`git merge-tree --write-tree`, each result kept as a dangling commit so the next lane merges
// onto it), each lane's conflicts split into what morning.mjs resolves by itself (the root JOURNAL and
// REPORT, the debt baseline) and the code files it stops on, then every lane pair's code conflicts, so a
// builder sees "my change conflicts with that lane" before committing (n15 tools: a quest1_clip.gd
// flag line conflicted with combat's and was found only by a hand-run merge-tree).
// Writes git objects only: no ref, index, worktree or config is touched.
//   node tools/merge/preview.mjs --lanes=<a,b,c> [--base=main]
// Exit: 0 morning would merge every lane on its own, 1 it would stop on code, 2 usage or a git error.
import { spawnSync } from 'node:child_process';
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';
import { BASELINE, DOCS } from './morning.mjs';

const USAGE = 'usage: node tools/merge/preview.mjs --lanes=<a,b,c> [--base=main]';
const ID = ['-c', 'user.name=merge-preview', '-c', 'user.email=merge-preview@example.invalid'];

/** True for a conflict morning.mjs settles without a person. */
export const autoResolved = (file) => DOCS.includes(file) || file === BASELINE;

/** A git runner: {status, stdout, stderr}. */
export const gitIn = (cwd) => (args) => {
  const r = spawnSync('git', ['-C', cwd, ...ID, ...args], { encoding: 'utf8', windowsHide: true });
  return { status: r.status, stdout: r.stdout ?? '', stderr: r.stderr ?? '' };
};

/** One `merge-tree --write-tree --name-only` of a and b: {tree, files} or {error}. */
export function mergeTree(git, a, b) {
  const r = git(['merge-tree', '--write-tree', '--name-only', a, b]);
  if (r.status !== 0 && r.status !== 1) return { error: `git merge-tree ${a} ${b}: ${r.stderr.trim().slice(0, 300)}` };
  const lines = r.stdout.split(/\r?\n/);
  const end = lines.indexOf('', 1);
  const files = r.status === 1 ? lines.slice(1, end < 0 ? undefined : end).filter(Boolean) : [];
  return { tree: lines[0].trim(), files: [...new Set(files)] };
}

/** The morning order: [{lane, auto, code}] or {error}. */
export function sequence(git, base, lanes) {
  const commit = (ref) => { const r = git(['rev-parse', '--verify', '--quiet', `${ref}^{commit}`]); return r.status === 0 ? r.stdout.trim() : ''; };
  const unknown = [base, ...lanes].filter((ref) => !commit(ref));
  if (unknown.length) return { error: `no such commit: ${unknown.join(', ')}` };
  let acc = commit(base);
  const steps = [];
  for (const lane of lanes) {
    const m = mergeTree(git, acc, lane);
    if (m.error) return m;
    steps.push({ lane, auto: m.files.filter(autoResolved), code: m.files.filter((f) => !autoResolved(f)) });
    const c = git(['commit-tree', m.tree, '-p', acc, '-p', lane, '-m', `merge-preview: ${lane}`]);
    acc = c.stdout.trim();
    if (c.status !== 0 || !acc) return { error: `git commit-tree for ${lane}: ${c.stderr.trim().slice(0, 300)}` };
  }
  return { steps };
}

/** Every lane pair whose merge conflicts on code: [{a, b, code}] or {error}. */
export function pairs(git, lanes) {
  const out = [];
  for (let i = 0; i < lanes.length; i++) {
    for (let j = i + 1; j < lanes.length; j++) {
      const m = mergeTree(git, lanes[i], lanes[j]);
      if (m.error) return m;
      const code = m.files.filter((f) => !autoResolved(f));
      if (code.length) out.push({ a: lanes[i], b: lanes[j], code });
    }
  }
  return out;
}

/** The report lines and the exit code for one preview. */
export function report(base, steps, conflictsByPair) {
  const lines = [`preview: ${base} + ${steps.map((s) => s.lane).join(', ')} (the morning order)`];
  for (const s of steps) {
    const auto = s.auto.length ? `morning resolves ${s.auto.join(', ')}` : '';
    const stop = s.code.length ? `STOP on ${s.code.join(', ')}` : '';
    lines.push(`preview: + ${s.lane}: ${[stop, auto].filter(Boolean).join('; ') || 'clean'}`);
  }
  for (const p of conflictsByPair) lines.push(`preview: ${p.a} x ${p.b} conflict on code: ${p.code.join(', ')}`);
  const first = steps.find((s) => s.code.length);
  lines.push(first ? `preview: morning would STOP at ${first.lane} (${first.code.length} code file(s)); resolve, commit, --resume`
    : `preview: morning merges all ${steps.length} lane(s) without a person`);
  return { lines, code: first ? 1 : 0 };
}

export function main(argv, { git = gitIn(ROOT), out = console.log, err = console.error } = {}) {
  const lanesArg = argv.find((a) => a.startsWith('--lanes='));
  const baseArg = argv.find((a) => a.startsWith('--base='));
  const bad = argv.find((a) => !/^--(lanes|base)=.+$/.test(a));
  if (!lanesArg || bad) { err(`${bad ? `preview: bad argument ${bad}\n` : ''}${USAGE}`); return 2; }
  const lanes = lanesArg.slice('--lanes='.length).split(',').filter(Boolean);
  const base = baseArg ? baseArg.slice('--base='.length) : 'main';
  const seq = sequence(git, base, lanes);
  if (seq.error) { err(`preview: ${seq.error}`); return 2; }
  const pr = pairs(git, lanes);
  if (pr.error) { err(`preview: ${pr.error}`); return 2; }
  const r = report(base, seq.steps, pr);
  for (const l of r.lines) out(l);
  return r.code;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(main(process.argv.slice(2)));
}
