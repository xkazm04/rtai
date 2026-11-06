// Machine-wide run ledger: ~15 lanes share one box, and a wall-clock budget (nav 2 ms, rig p50 1 ms,
// the bench) is only meaningful when nothing else is running. Every runGodot call registers an entry
// file in one shared folder and removes it when the run ends (also on timeout/kill and process exit),
// so any runner can ask "who else is running right now?" and report CONTENDED instead of FAIL.
//
//   dir:   $GTAI_RUNS_DIR, else %LOCALAPPDATA%/gtai/runs (else ~/.gtai/runs)
//   entry: <pid>-<rand>.json {pid, childPid, worktree, branch, kind, start}   (one per Godot run)
//   queue: queue-<epoch ms>-<pid>-<rand>.json {pid, ...}                       (bench FIFO tickets)
//   lock:  bench.lock {pid, worktree, branch, start}                           (the bench holder)
//
// Liveness: process.kill(pid, 0) works for non-child pids on Windows (ESRCH = gone, EPERM = alive,
// measured 2026-11-06). Dead entries are reaped by deleting that single file. An entry older than
// MAX_AGE_MS is also reaped (pid reuse must not pin a ghost forever). Deletion law: this module only
// ever removes single files it finds in its own folder.
import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, readdirSync, readFileSync, renameSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { join } from 'node:path';
import { randomBytes } from 'node:crypto';
import { ROOT } from './repo.mjs';

export const MAX_AGE_MS = 60 * 60 * 1000;
/** Typical wall time per kind of run, for ETAs (minutes). */
export const TYPICAL_MIN = { bench: 14, scenarios: 8, unit: 6, parity: 3, import: 1, selftest: 2, check: 0.5 };
const DEFAULT_MIN = 3;

export function ledgerDir(env = process.env) {
  if (env.GTAI_RUNS_DIR) return env.GTAI_RUNS_DIR;
  return join(env.LOCALAPPDATA || join(homedir(), '.gtai'), 'gtai', 'runs');
}

/** True when `pid` is a live process (works for pids that are not our children). */
export function pidAlive(pid) {
  if (!Number.isInteger(pid) || pid <= 0) return false;
  try { process.kill(pid, 0); return true; } catch (e) { return e.code === 'EPERM'; }
}

/** Current branch of the checkout at `root` ("detached" / "?" when unknown); reads .git, no spawn. */
export function branchOf(root = ROOT) {
  try {
    let gitDir = join(root, '.git');
    if (statSync(gitDir).isFile()) {
      const m = /^gitdir:\s*(.+)$/m.exec(readFileSync(gitDir, 'utf8'));
      if (m) gitDir = m[1].trim();
    }
    const head = readFileSync(join(gitDir, 'HEAD'), 'utf8').trim();
    const ref = /^ref:\s*refs\/heads\/(.+)$/.exec(head);
    return ref ? ref[1] : 'detached';
  } catch { return '?'; }
}

const readEntry = (file) => { try { return JSON.parse(readFileSync(file, 'utf8')); } catch { return null; } };
const names = (dir, prefix) => { try { return readdirSync(dir).filter((f) => f.endsWith('.json') && prefix(f)); } catch { return []; } };
const reap = (file) => rmSync(file, { force: true, recursive: false });

const live = new Set(); // entry files this process still owns; the exit hook removes them
let hooked = false;
function hookExit() {
  if (hooked) return;
  hooked = true;
  process.on('exit', () => { for (const f of live) reap(f); });
}

/** Registers a run; returns {file, setChild(pid), release()}. Never throws (a broken ledger must
 *  not break a test run): on any fs error the handle is a no-op. */
export function register({ kind = 'godot', childPid = null, root = ROOT, dir = ledgerDir() } = {}) {
  const none = { file: null, setChild() {}, release() {} };
  try {
    mkdirSync(dir, { recursive: true });
    const file = join(dir, `${process.pid}-${randomBytes(3).toString('hex')}.json`);
    const entry = { pid: process.pid, childPid, worktree: root, branch: branchOf(root), kind, start: Date.now() };
    const write = () => { writeFileSync(`${file}.tmp`, JSON.stringify(entry)); renameSync(`${file}.tmp`, file); };
    write();
    live.add(file);
    hookExit();
    return {
      file,
      setChild(pid) { entry.childPid = pid; try { write(); } catch { /* ledger is advisory */ } },
      release() { live.delete(file); reap(file); },
    };
  } catch { return none; }
}

/** Live entries of other runs (own pid excluded by default); dead and over-age ones are reaped. */
export function activeRuns({ excludeSelf = true, dir = ledgerDir(), now = Date.now() } = {}) {
  const out = [];
  for (const f of names(dir, (n) => !n.startsWith('queue-'))) {
    const file = join(dir, f);
    const e = readEntry(file);
    if (!e || !pidAlive(e.pid) || now - (e.start ?? 0) > MAX_AGE_MS) {
      reap(file); // dead owner (or an unreadable half-written file): drop that one entry
      continue;
    }
    if (excludeSelf && e.pid === process.pid) continue;
    out.push({ ...e, file });
  }
  return out.sort((a, b) => a.start - b.start);
}

/** Godot processes on the machine as [{pid, ppid, name}] (one PowerShell CIM query, ~0.2 s). */
export function godotProcesses() {
  if (process.platform !== 'win32') return [];
  const q = "Get-CimInstance Win32_Process -Filter \"Name like 'Godot%' or Name='RTAI-bench.exe'\" | "
    + 'ForEach-Object { "$($_.ProcessId),$($_.ParentProcessId),$($_.Name)" }';
  const r = spawnSync('powershell', ['-NoProfile', '-NonInteractive', '-Command', q], { encoding: 'utf8', timeout: 15000, windowsHide: true });
  if (r.error || r.status !== 0) return [];
  return r.stdout.split(/\r?\n/).filter(Boolean).map((l) => {
    const [pid, ppid, name] = l.split(',');
    return { pid: Number(pid), ppid: Number(ppid), name };
  });
}

/** Godot processes that no ledger entry accounts for (lanes running Godot by hand, an IDE editor).
 *  A ledger run owns its child (the console exe) and that child's own child (the real engine). */
export function foreignGodot({ dir = ledgerDir(), procs = godotProcesses() } = {}) {
  const mine = new Set();
  for (const f of names(dir, (n) => !n.startsWith('queue-'))) {
    const e = readEntry(join(dir, f));
    if (e?.childPid && pidAlive(e.pid)) mine.add(e.childPid);
  }
  return procs.filter((p) => !mine.has(p.pid) && !mine.has(p.ppid));
}

/** How many other runs are active right now: ledger entries plus unregistered Godot processes
 *  (a console exe and its engine child count once). GTAI_COUNT_FOREIGN=0 turns the latter off. */
export function contention({ dir = ledgerDir(), env = process.env, procs } = {}) {
  const others = activeRuns({ dir });
  let foreign = 0;
  if (env.GTAI_COUNT_FOREIGN !== '0') {
    const list = foreignGodot({ dir, procs: procs ?? godotProcesses() });
    const pids = new Set(list.map((p) => p.pid));
    foreign = list.filter((p) => !pids.has(p.ppid)).length; // an engine whose console parent is listed adds nothing
  }
  return { others, foreign, count: others.length + foreign };
}

/** Minutes until the machine is likely quiet, from the running entries' start times and kinds. */
export function etaMinutes(entries, queuedAhead = 0, now = Date.now()) {
  let eta = 0;
  for (const e of entries) {
    const typical = TYPICAL_MIN[e.kind] ?? DEFAULT_MIN;
    eta = Math.max(eta, Math.max(0.5, typical - (now - e.start) / 60000));
  }
  return eta + queuedAhead * TYPICAL_MIN.bench;
}

/** "scenarios (lane-x, 2.1 min in)" style description for waiting messages. */
export const describeEntry = (e, now = Date.now()) =>
  `${e.kind} (${e.branch}@${e.worktree.split(/[\\/]/).pop()}, ${((now - e.start) / 60000).toFixed(1)} min in)`;

// ---- the bench queue: FIFO tickets + the bench.lock holder ----------------------------------------

/** Takes a FIFO ticket; returns {file, release()}. */
export function enqueue({ dir = ledgerDir(), root = ROOT, now = Date.now() } = {}) {
  mkdirSync(dir, { recursive: true });
  const file = join(dir, `queue-${String(now).padStart(15, '0')}-${process.pid}-${randomBytes(2).toString('hex')}.json`);
  writeFileSync(file, JSON.stringify({ pid: process.pid, worktree: root, branch: branchOf(root), start: now }));
  live.add(file);
  hookExit();
  return { file, release() { live.delete(file); reap(file); } };
}

/** Live tickets in FIFO order (dead owners reaped). */
export function queueTickets({ dir = ledgerDir() } = {}) {
  const out = [];
  for (const f of names(dir, (n) => n.startsWith('queue-')).sort()) {
    const file = join(dir, f);
    const e = readEntry(file);
    if (!e || !pidAlive(e.pid)) { reap(file); continue; }
    out.push({ ...e, file });
  }
  return out;
}

/** The holder of bench.lock, or null when free. A lock whose owner died, or older than MAX_AGE_MS,
 *  is stale and removed; a legacy `<repo>/build/bench.lock` (hand-written, 20 min rule) also holds. */
export function benchHolder({ dir = ledgerDir(), root = ROOT, now = Date.now() } = {}) {
  const file = join(dir, 'bench.lock');
  const e = existsSync(file) ? readEntry(file) : null;
  if (e && pidAlive(e.pid) && now - e.start < MAX_AGE_MS) return { ...e, file };
  if (existsSync(file)) reap(file);
  const legacy = join(root, 'build', 'bench.lock');
  if (existsSync(legacy) && now - statSync(legacy).mtimeMs < 20 * 60 * 1000) {
    return { pid: 0, worktree: root, branch: '?', start: statSync(legacy).mtimeMs, file: legacy, legacy: true };
  }
  return null;
}

/** Takes bench.lock atomically (exclusive create); returns {release()} or null when held. */
export function takeBenchLock({ dir = ledgerDir(), root = ROOT, now = Date.now() } = {}) {
  if (benchHolder({ dir, root, now })) return null;
  const file = join(dir, 'bench.lock');
  try {
    writeFileSync(file, JSON.stringify({ pid: process.pid, worktree: root, branch: branchOf(root), start: now }), { flag: 'wx' });
  } catch { return null; }
  live.add(file);
  hookExit();
  return { release() { live.delete(file); reap(file); } };
}

// ---- contention verdicts -------------------------------------------------------------------------

/** `CONTENDED: <metric> <value> > <budget> (<n> other runs)` lines in a Godot log, as
 *  [{metric, scenario, text}] (scenario = the part of the metric before the first dot). */
export function parseContended(out) {
  const found = new Map();
  for (const m of out.matchAll(/CONTENDED: (\S+) ([^\r\n]*)/g)) {
    const metric = m[1];
    if (!found.has(metric)) found.set(metric, { metric, scenario: metric.split('.')[0], text: `${metric} ${m[2]}` });
  }
  return [...found.values()];
}

const realSleep = (ms) => new Promise((r) => setTimeout(r, ms));

/** Settles a budget verdict that was waved through as CONTENDED. Waits (polling `quiet()`) up to
 *  `waitMs` for the machine to go quiet, then calls `rerun(scenarios)` once, which must judge
 *  strictly and resolve {ok, contended: [...]} (contended again = the machine got busy mid-run).
 *  Resolves {state, waitedMs, contended}: 'none' (nothing to settle), 'passed' (re-judged alone,
 *  inside budget), 'failed' (re-judged alone, over budget: a real regression), 'contended' (never
 *  quiet, or busy again during the re-run: not judged, neither pass nor fail). */
export async function settleContended({ contended, quiet, rerun, waitMs = 5 * 60 * 1000, pollMs = 10000, sleep = realSleep, log = () => {} }) {
  if (!contended.length) return { state: 'none', waitedMs: 0, contended };
  const scenarios = [...new Set(contended.map((c) => c.scenario))];
  let waited = 0;
  while (!(await quiet())) {
    if (waited >= waitMs) return { state: 'contended', waitedMs: waited, contended, why: `the machine never went quiet in ${Math.round(waitMs / 60000)} min` };
    if (waited === 0) log(`budget missed under contention (${scenarios.join(', ')}); waiting up to ${Math.round(waitMs / 60000)} min for a quiet machine`);
    await sleep(pollMs);
    waited += pollMs;
  }
  log(`machine quiet after ${Math.round(waited / 1000)} s: re-judging ${scenarios.join(', ')} alone`);
  const r = await rerun(scenarios);
  if (!r.ok) return { state: 'failed', waitedMs: waited, contended: [], rerun: r };
  if (r.contended?.length) return { state: 'contended', waitedMs: waited, contended: r.contended, why: 'the machine got busy again during the re-run', rerun: r };
  return { state: 'passed', waitedMs: waited, contended: [], rerun: r };
}

/** Waits for the bench slot: a FIFO ticket, then the machine quiet (no other ledger run, no
 *  unregistered Godot) and no bench.lock holder. Logs an ETA from the running entries' start times.
 *  After `waitMs` the head of the queue runs anyway, flagged `contended` (a number is better than
 *  never running; the bench judges its limits strictly regardless). Resolves
 *  {lock, contended, waitedMs, others} or {error} (waitMs = 0 with a holder, or still queued behind
 *  another ticket at the deadline). The caller releases `lock`. */
export async function acquireBench({ dir = ledgerDir(), root = ROOT, waitMs = 20 * 60 * 1000, pollMs = 15000, logEveryMs = 60000,
  sleep = realSleep, log = () => {}, now = () => Date.now(), count = () => contention({ dir }) } = {}) {
  const ticket = enqueue({ dir, root, now: now() });
  const t0 = now();
  let lastLog = -Infinity;
  try {
    for (;;) {
      const queue = queueTickets({ dir });
      const ahead = queue.findIndex((t) => t.file === ticket.file);
      const holder = benchHolder({ dir, root });
      const c = count();
      const head = ahead === 0;
      const waited = now() - t0;
      if (head && !holder && c.count === 0) {
        const lock = takeBenchLock({ dir, root });
        if (lock) return { lock, contended: false, waitedMs: waited, others: 0 };
      } else if (head && !holder && waited >= waitMs) {
        const lock = takeBenchLock({ dir, root });
        if (lock) return { lock, contended: true, waitedMs: waited, others: c.count };
      }
      if (waited >= waitMs) {
        const why = holder ? `bench lock held by ${holder.branch} since ${new Date(holder.start).toISOString()}` : `${Math.max(ahead, 0)} bench run(s) queued ahead`;
        return { error: `gave up waiting ${Math.round(waited / 60000)} min: ${why}` };
      }
      if (waited - lastLog >= logEveryMs) {
        lastLog = waited;
        const running = c.others.map((e) => describeEntry(e, now())).join(', ') || 'no ledger run';
        const eta = etaMinutes(c.others, Math.max(ahead, 0) + (holder ? 1 : 0), now());
        log(`bench queued (${Math.max(ahead, 0)} ahead, ${c.count} other run(s) active: ${running}${c.foreign ? `, ${c.foreign} unregistered Godot` : ''}); ETA ~${Math.ceil(eta)} min`);
      }
      await sleep(Math.min(pollMs, Math.max(1, waitMs - waited)));
    }
  } finally {
    ticket.release();
  }
}
