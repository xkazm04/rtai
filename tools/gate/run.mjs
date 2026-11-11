#!/usr/bin/env node
// Runs the gates on a snapshot of one commit, so you can keep editing and no log lands in your tree:
// a detached checkout in the temp dir with the git-ignored runtime (DLLs, baked city, import cache)
// copied in, running that commit's own tools/evidence/run.mjs. The verdict is read from what the run
// wrote, and every result must name the commit: a missing or foreign result is not a pass.
//   node tools/gate/run.mjs [--rev=HEAD] [--reels[=top,tilt70,combo]] [--bench] [--no-parity] [--no-selftest] [--clean]
// --reels=<views> runs only those reel views: a mid-session check, labelled `not the full reel gate` (the
// final commit needs plain --reels). gate.json keeps `timing` (evidence and each reel view, s); the next gate
// prints it as an ETA, since the gate holds the lane's one Godot for ~30-40 min (n16 kill lanes' FRICTION).
// Results: build/gate/<sha>/ in your tree (git-ignored): the game tree you run it from (cwd or an ancestor), not
// this kit's, so a lane running `node ../n16-tools/tools/gate/run.mjs` finds them in its own tree, and its snapshot
// gets ITS DLLs (n16 s6, kills-new REQUEST 17:4x: results and the runtime donor were the tools tree's).
// Exit: 0 pass, 1 fail, 2 usage, 3 unverifiable (the run produced no judgeable result).
import { execFileSync, spawn } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, readdirSync, readFileSync, statSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { filmedRoot, nativeDiffers } from '../film/side.mjs';
import { killTree } from '../lib/godot.mjs';
import { ensureSnapshot, removeSnapshot, revParse } from '../lib/snapshot.mjs';

const USAGE = 'usage: node tools/gate/run.mjs [--rev=HEAD] [--reels[=top,tilt70,combo]] [--bench] [--no-parity] [--no-selftest] [--clean] [--timeout=<min>]';
export const REEL_VIEWS = ['top', 'tilt70', 'combo'];

/** The evidence kinds that must exist and pass; a skipped one is left out of the list. */
export function kindsFor(o) {
  return ['lint', 'unit-tests', 'scenario-tests', ...(o.parity ? ['parity'] : []), ...(o.selftest ? ['selftest'] : []),
    'export-audit', ...(o.bench ? ['bench'] : [])];
}

export function parseArgs(argv) {
  const o = { rev: 'HEAD', reels: false, reelViews: null, bench: false, parity: true, selftest: true, clean: false, timeoutMin: 45 };
  for (const a of argv) {
    const m = /^--rev=(.+)$/.exec(a);
    const t = /^--timeout=(\d+)$/.exec(a);
    const v = /^--reels=(.+)$/.exec(a);
    if (m) o.rev = m[1];
    else if (v) {
      const views = [...new Set(v[1].split(','))];
      const bad = views.filter((x) => !REEL_VIEWS.includes(x));
      if (bad.length) return { error: `gate: --reels takes ${REEL_VIEWS.join(', ')}, not ${bad.join(', ')}` };
      o.reels = true;
      o.reelViews = REEL_VIEWS.every((x) => views.includes(x)) ? null : REEL_VIEWS.filter((x) => views.includes(x));
    }
    else if (t) o.timeoutMin = Number(t[1]);
    else if (a === '--reels') { o.reels = true; o.reelViews = null; } // the last --reels form wins
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

/** {view: seconds} from run_reels' progress lines (`run_reels: [2/3] tilt70 OK, 745 s; log ...`). */
export function reelSecs(text) {
  const out = {};
  for (const m of String(text ?? '').matchAll(/^run_reels: \[\d+\/\d+\] (\S+) \S+, (\d+(?:\.\d+)?) s/gm)) out[m[1]] = Number(m[2]);
  return out;
}

/** The ETA line from the newest gate.json under `dir` that kept a timing, or null. */
export function etaLine(dir) {
  if (!existsSync(dir)) return null;
  const runs = readdirSync(dir).map((d) => join(dir, d, 'gate.json')).filter((f) => existsSync(f))
    .sort((a, b) => statSync(b).mtimeMs - statSync(a).mtimeMs);
  for (const f of runs) {
    let g = null;
    try { g = JSON.parse(readFileSync(f, 'utf8')); } catch { continue; }
    if (!g?.timing) continue;
    const reels = Object.entries(g.timing.reels ?? {});
    const total = reels.reduce((n, [, sec]) => n + sec, 0);
    const min = (sec) => (sec / 60).toFixed(1);
    return `gate: the last gate here (${String(g.sha).slice(0, 8)}) took evidence ${min(g.timing.evidence_s)} min`
      + (reels.length ? ` + reels ${min(total)} min (${reels.map(([view, sec]) => `${view} ${sec} s`).join(', ')})` : ', no reels');
  }
  return null;
}

const readEnv = (dir) => (kind) => {
  const f = join(dir, `${kind}.json`);
  if (!existsSync(f)) return null;
  try { return JSON.parse(readFileSync(f, 'utf8')); } catch { return null; }
};

/** The warning when the snapshot of `sha` runs `here`'s DLLs built from another native/ (null when they match). */
export function nativeLine(here, sha, differs = nativeDiffers) {
  if (!differs(here, sha)) return null;
  return `gate: WARNING native/ at ${sha.slice(0, 8)} differs from ${here}'s HEAD: the snapshot runs that tree's DLLs, so parity and the sim scenarios are not ${sha.slice(0, 8)}'s native (gate from a worktree at the commit to judge its sim)`;
}

export async function main(argv, { out = console.log, err = console.error, here = filmedRoot() } = {}) {
  const o = parseArgs(argv);
  if (o.error) { err(`${o.error}\n${USAGE}`); return 2; }
  const ROOT = here;
  const sha = revParse(ROOT, o.rev);
  if (!sha) { err(`gate: git does not know ${o.rev}`); return 2; }
  const dirty = execFileSync('git', ['-C', ROOT, 'status', '--porcelain'], { encoding: 'utf8', windowsHide: true }).trim();
  out(`gate: ${sha.slice(0, 8)} from ${ROOT}${dirty ? ' (your uncommitted changes are NOT in this run)' : ''}`);
  const native = nativeLine(ROOT, sha);
  if (native) out(native);
  const snap = ensureSnapshot({ root: ROOT, rev: sha, kind: 'gate' });
  out(`gate: snapshot ${snap.path} (${snap.created ? 'new' : 'reused'}${snap.copied.length ? `, copied ${snap.copied.join(', ')}` : ''})`);
  const eta = etaLine(join(ROOT, 'build', 'gate'));
  if (eta) out(eta);
  const results = join(ROOT, 'build', 'gate', sha.slice(0, 12));
  mkdirSync(results, { recursive: true });
  const t0 = Date.now();
  const flags = ['tools/evidence/run.mjs', ...(o.bench ? [] : ['--no-bench']), ...(o.parity ? [] : ['--no-parity']), ...(o.selftest ? [] : ['--no-selftest'])];
  const log = join(results, 'evidence.log');
  out(`gate: running the gates in the snapshot; log ${log}`);
  const code = await runLogged(process.execPath, flags, { cwd: snap.path, log, timeoutMs: o.timeoutMin * 60000 });
  const timing = { evidence_s: Math.round((Date.now() - t0) / 1000) };
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
    const views = o.reelViews ? [`--views=${o.reelViews.join(',')}`] : [];
    const reel = await runLogged(process.execPath, ['tools/reel/run_reels.mjs', `--out=${reelDir}`, ...views], { cwd: snap.path, log: reelLog, timeoutMs: o.timeoutMin * 60000 });
    const reelOk = reel === 0;
    timing.reels = reelSecs(existsSync(reelLog) ? readFileSync(reelLog, 'utf8') : '');
    const part = o.reelViews ? ` (${o.reelViews.join(', ')} only: not the full reel gate)` : '';
    out(`${reelOk ? 'PASS' : 'FAIL'} reels${part}: exit ${reel}`);
    if (!reelOk && outcome === 'pass') outcome = 'fail';
  }
  writeFileSync(join(results, 'gate.json'), `${JSON.stringify({ schema: 'gtai.gate/1', sha, outcome, lines: judged.lines, code, reels: o.reels ? (o.reelViews ?? 'all') : 'none', timing }, null, 1)}\n`);
  if (o.clean) removeSnapshot(ROOT, snap.path);
  out(`gate: ${outcome.toUpperCase()}; ${join(results, 'gate.json')}`);
  return { pass: 0, fail: 1, unverifiable: 3 }[outcome];
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(await main(process.argv.slice(2)));
}
