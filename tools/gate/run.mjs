#!/usr/bin/env node
// Runs the gates on a snapshot of one commit, so you can keep editing and no log lands in your tree:
// a detached checkout in the temp dir with the git-ignored runtime (DLLs, baked city, import cache)
// copied in, running that commit's own tools/evidence/run.mjs. The verdict is read from what the run
// wrote, and every result must name the commit: a missing or foreign result is not a pass.
//   node tools/gate/run.mjs [--rev=HEAD] [--reels] [--bench] [--no-parity] [--no-selftest] [--clean]
// Results: build/gate/<sha>/ in your tree (git-ignored).
// Exit: 0 pass, 1 fail, 2 usage, 3 unverifiable (the run produced no judgeable result).
import { execFileSync, spawn } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';
import { killTree } from '../lib/godot.mjs';
import { ensureSnapshot, removeSnapshot, revParse } from '../lib/snapshot.mjs';

const USAGE = 'usage: node tools/gate/run.mjs [--rev=HEAD] [--reels] [--bench] [--no-parity] [--no-selftest] [--clean] [--timeout=<min>]';
/** The evidence kinds that must exist and pass; a skipped one is left out of the list. */
export function kindsFor(o) {
  return ['lint', 'unit-tests', 'scenario-tests', ...(o.parity ? ['parity'] : []), ...(o.selftest ? ['selftest'] : []),
    'export-audit', ...(o.bench ? ['bench'] : [])];
}

export function parseArgs(argv) {
  const o = { rev: 'HEAD', reels: false, bench: false, parity: true, selftest: true, clean: false, timeoutMin: 45 };
  for (const a of argv) {
    const m = /^--rev=(.+)$/.exec(a);
    const t = /^--timeout=(\d+)$/.exec(a);
    if (m) o.rev = m[1];
    else if (t) o.timeoutMin = Number(t[1]);
    else if (a === '--reels') o.reels = true;
    else if (a === '--bench') o.bench = true;
    else if (a === '--no-parity') o.parity = false;
    else if (a === '--no-selftest') o.selftest = false;
    else if (a === '--clean') o.clean = true;
    else return { error: `gate: bad argument ${a}` };
  }
  return o;
}

/** Judges the envelopes against the commit. {outcome, lines}: missing or foreign = unverifiable. */
export function judgeEvidence(kinds, read, sha) {
  const lines = [];
  const outcomes = [];
  for (const kind of kinds) {
    const env = read(kind);
    if (!env) { lines.push(`UNVERIFIABLE ${kind}: no result was written`); outcomes.push('unverifiable'); continue; }
    if (env.commit !== sha) { lines.push(`UNVERIFIABLE ${kind}: the result is for ${String(env.commit).slice(0, 8)}, not ${sha.slice(0, 8)}`); outcomes.push('unverifiable'); continue; }
    if (env.status !== 'pass') { lines.push(`FAIL ${kind}: ${env.summary}`); outcomes.push('fail'); continue; }
    lines.push(`PASS ${kind}: ${env.summary}`);
    outcomes.push('pass');
  }
  const outcome = outcomes.includes('fail') ? 'fail' : outcomes.includes('unverifiable') || !outcomes.length ? 'unverifiable' : 'pass';
  return { outcome, lines };
}

/** The worktrees git knows, for finding a donor of git-ignored files. */
export function worktrees(text) {
  return text.split('\n').filter((l) => l.startsWith('worktree ')).map((l) => l.slice(9).trim());
}

/** Spawns one process to a log file with a tree-kill timeout. Resolves its exit code (-1 = timed out). */
function runLogged(cmd, args, { cwd, log, timeoutMs }) {
  return new Promise((done) => {
    const child = spawn(cmd, args, { cwd, windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'] });
    const chunks = [];
    const take = (d) => { chunks.push(d); writeFileSync(log, Buffer.concat(chunks)); };
    child.stdout.on('data', take);
    child.stderr.on('data', take);
    const timer = setTimeout(() => { killTree(child.pid); done(-1); }, timeoutMs);
    child.on('close', (code) => { clearTimeout(timer); done(code); });
    child.on('error', () => { clearTimeout(timer); done(-1); });
  });
}

const readEnv = (dir) => (kind) => {
  const f = join(dir, `${kind}.json`);
  if (!existsSync(f)) return null;
  try { return JSON.parse(readFileSync(f, 'utf8')); } catch { return null; }
};

function donorFor(rel) {
  const text = execFileSync('git', ['-C', ROOT, 'worktree', 'list', '--porcelain'], { encoding: 'utf8', windowsHide: true });
  return [ROOT, ...worktrees(text)].find((t) => existsSync(join(t, rel))) ?? ROOT;
}

function copyFromAnyDonor(path, rel) {
  const dst = join(path, rel);
  const src = join(donorFor(rel), rel);
  if (existsSync(dst) || !existsSync(src)) return false;
  mkdirSync(dst, { recursive: true });
  for (const n of readdirSync(src)) copyFileSync(join(src, n), join(dst, n));
  return true;
}

export async function main(argv, { out = console.log, err = console.error } = {}) {
  const o = parseArgs(argv);
  if (o.error) { err(`${o.error}\n${USAGE}`); return 2; }
  const sha = revParse(ROOT, o.rev);
  if (!sha) { err(`gate: git does not know ${o.rev}`); return 2; }
  const dirty = execFileSync('git', ['-C', ROOT, 'status', '--porcelain'], { encoding: 'utf8', windowsHide: true }).trim();
  out(`gate: ${sha.slice(0, 8)}${dirty ? ' (your uncommitted changes are NOT in this run)' : ''}`);
  const snap = ensureSnapshot({ root: ROOT, rev: sha, kind: 'gate' });
  const baked = copyFromAnyDonor(snap.path, 'project/data/generated/city');
  out(`gate: snapshot ${snap.path} (${snap.created ? 'new' : 'reused'}${snap.copied.length ? `, copied ${snap.copied.join(', ')}` : ''}${baked ? ', baked city from a sibling' : ''})`);
  const results = join(ROOT, 'build', 'gate', sha.slice(0, 12));
  mkdirSync(results, { recursive: true });
  const flags = ['tools/evidence/run.mjs', ...(o.bench ? [] : ['--no-bench']), ...(o.parity ? [] : ['--no-parity']), ...(o.selftest ? [] : ['--no-selftest'])];
  const log = join(results, 'evidence.log');
  out(`gate: running the gates in the snapshot; log ${log}`);
  const code = await runLogged(process.execPath, flags, { cwd: snap.path, log, timeoutMs: o.timeoutMin * 60000 });
  if (code === -1) out('gate: the run was killed at the timeout');
  const kinds = kindsFor(o);
  const evidence = join(snap.path, 'build', 'evidence');
  for (const kind of kinds) {
    const f = join(evidence, `${kind}.json`);
    if (existsSync(f)) copyFileSync(f, join(results, `${kind}.json`));
  }
  const judged = judgeEvidence(kinds, readEnv(results), sha);
  for (const l of judged.lines) out(l);
  let outcome = judged.outcome;
  if (o.reels) {
    const reelDir = join(results, 'reels');
    const reelLog = join(results, 'reels.log');
    out(`gate: reel gate; log ${reelLog}`);
    const reel = await runLogged(process.execPath, ['tools/reel/run_reels.mjs', `--out=${reelDir}`], { cwd: snap.path, log: reelLog, timeoutMs: o.timeoutMin * 60000 });
    const reelOk = reel === 0;
    out(`${reelOk ? 'PASS' : 'FAIL'} reels: exit ${reel}`);
    if (!reelOk && outcome === 'pass') outcome = 'fail';
  }
  writeFileSync(join(results, 'gate.json'), `${JSON.stringify({ schema: 'gtai.gate/1', sha, outcome, lines: judged.lines, code }, null, 1)}\n`);
  if (o.clean) removeSnapshot(ROOT, snap.path);
  out(`gate: ${outcome.toUpperCase()}; ${join(results, 'gate.json')}`);
  return { pass: 0, fail: 1, unverifiable: 3 }[outcome];
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(await main(process.argv.slice(2)));
}
