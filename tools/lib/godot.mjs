// The one Godot launcher: discovery, a version check against versions.toml, an async spawn with a
// timeout that kills the whole process tree and keeps the partial log, and the shared script-error
// scan. Every runner under tools/ goes through here (no per-runner spawn code).
//
// MEASURED (2026-11-06, Windows 11, Godot_v4.7.2-stable_win64_console.exe, a planted `while true`
// -s script, tasklist at +10 s): the console exe DOES spawn the real engine as a child process -
// two processes, Godot_v4.7.2-stable_win64_console.exe (pid A) and Godot_v4.7.2-stable_win64.exe
// (its child). Killing only the direct child (spawnSync timeout) would orphan the spinning engine,
// so the whole-tree kill (taskkill /F /T) is REQUIRED, not optional. Verified: after the timeout
// no Godot process was left and the partial log was kept.
import { spawn, spawnSync } from 'node:child_process';
import { existsSync, readdirSync, readFileSync, rmSync, statSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve, sep } from 'node:path';
import { ROOT } from './repo.mjs';
import { isStale } from './class_cache.mjs';
import { register } from './run_ledger.mjs';

export const SCRIPT_ERROR = /SCRIPT ERROR|Parse Error|Compile Error|Failed to load script/;
export const HEADLESS_TIMEOUT_MS = 10 * 60 * 1000;
const ANSI = /\x1b\[[0-9;]*m/g;
const KILL_SETTLE_MS = 5000;

const realFs = {
  exists: existsSync,
  read: (p) => readFileSync(p, 'utf8'),
  list: (dir) => { try { return readdirSync(dir); } catch { return []; } },
};

/** `version` from versions.toml [godot], e.g. "4.7.2-stable". */
export function pinnedVersion(fs = realFs, root = ROOT) {
  const m = /^\[godot\][^[]*?^version\s*=\s*"([^"]+)"/ms.exec(fs.read(join(root, 'versions.toml')));
  return m ? m[1] : null;
}

/** "4.7.2.stable.official.abc" satisfies the pin "4.7.2-stable". */
export const versionMatches = (printed, pin) => !!printed && printed.startsWith(pin.replace('-', '.'));

function defaultProbe(bin) {
  const res = spawnSync(bin, ['--version'], { encoding: 'utf8', timeout: 30000, windowsHide: true });
  if (res.error || res.status !== 0) return null;
  return res.stdout.trim().split('\n').pop().trim();
}

/** Plausible install spots next to the repo (also reached from a worktree under ../gtai-wt/x):
 *  no disk crawl, only these folders, console binaries only. */
function knownPaths(fs, root) {
  const out = [];
  for (const base of [root, join(root, '..'), join(root, '..', '..')]) {
    for (const sub of ['tools/godot', 'gtai-spike/tools/godot']) {
      const dir = join(base, sub);
      for (const f of fs.list(dir).sort().reverse()) {
        if (/console.*\.exe$|^godot.*console$/i.test(f)) out.push(join(dir, f));
      }
    }
  }
  return [...new Set(out)];
}

/** Ordered candidates: GODOT_BIN, POF_GODOT_BIN, tools/local.json {"godot"}, known paths, PATH.
 *  `explicit` ones fail loudly when unusable instead of silently falling through. */
export function candidates({ env = process.env, fs = realFs, root = ROOT } = {}) {
  const list = [];
  if (env.GODOT_BIN) list.push({ bin: env.GODOT_BIN, source: 'GODOT_BIN', explicit: true });
  if (env.POF_GODOT_BIN) list.push({ bin: env.POF_GODOT_BIN, source: 'POF_GODOT_BIN', explicit: true });
  const local = join(root, 'tools', 'local.json');
  if (fs.exists(local)) {
    try {
      const g = JSON.parse(fs.read(local)).godot;
      if (g) list.push({ bin: g, source: 'tools/local.json', explicit: true });
    } catch { /* unreadable local file: ignore, the message below still names the way out */ }
  }
  for (const bin of knownPaths(fs, root)) list.push({ bin, source: 'known path', explicit: false });
  list.push({ bin: 'godot', source: 'PATH', explicit: false });
  return list;
}

const HOWTO = 'set GODOT_BIN or tools/local.json {"godot": "<path>"}';
let cached = null;

/** {ok, bin, version, source} or {ok: false, message} (one line). Cached per process when called
 *  without injected `env`/`fs`/`probe`. */
export function resolveGodot(opts = {}) {
  const injected = Object.keys(opts).length > 0;
  if (!injected && cached) return cached;
  const fs = opts.fs ?? realFs;
  const pin = opts.pin ?? pinnedVersion(fs, opts.root ?? ROOT) ?? '4.7.2-stable';
  const probe = opts.probe ?? defaultProbe;
  const want = pin.split('-')[0];
  let result = { ok: false, message: `Godot ${want} not found: ${HOWTO}` };
  for (const c of candidates({ ...opts, fs })) {
    const printed = probe(c.bin);
    if (versionMatches(printed, pin)) { result = { ok: true, bin: c.bin, version: printed, source: c.source }; break; }
    if (c.explicit) {
      const why = printed ? `prints ${printed}, need ${pin}` : 'cannot be run';
      result = { ok: false, message: `Godot ${want} not usable: ${c.source}=${c.bin} ${why}; ${HOWTO}` };
      break;
    }
  }
  if (!injected) cached = result;
  return result;
}

/** Kills `pid` and every descendant. */
export function killTree(pid) {
  if (process.platform === 'win32') {
    spawnSync('taskkill', ['/F', '/T', '/PID', String(pid)], { stdio: 'ignore', windowsHide: true });
    return;
  }
  try { process.kill(-pid, 'SIGKILL'); } catch { try { process.kill(pid, 'SIGKILL'); } catch { /* gone */ } }
}

/** Async spawn with merged stdout+stderr (ANSI stripped). On timeout the tree is killed and the
 *  partial output is kept. Resolves {status, out, timedOut, durationMs}; status -1 = never ran. */
export function runProcess(cmd, args, { cwd = ROOT, timeoutMs = HEADLESS_TIMEOUT_MS, env, onSpawn } = {}) {
  return new Promise((done) => {
    const t0 = Date.now();
    let out = '';
    let timedOut = false;
    let finished = false;
    const finish = (status) => {
      if (finished) return;
      finished = true;
      clearTimeout(timer);
      const text = out.replace(ANSI, '') + (timedOut ? `\n[timeout: killed the process tree after ${timeoutMs} ms]\n` : '');
      done({ status: status ?? -1, out: text, timedOut, durationMs: Date.now() - t0 });
    };
    const child = spawn(cmd, args, { cwd, env, windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'],
      detached: process.platform !== 'win32' });
    if (onSpawn && child.pid) onSpawn(child.pid);
    const take = (d) => { out += d.toString('utf8'); };
    child.stdout.on('data', take);
    child.stderr.on('data', take);
    child.on('error', (e) => { out += String(e); finish(-1); });
    child.on('close', (code) => finish(timedOut ? -1 : code));
    const timer = setTimeout(() => {
      timedOut = true;
      killTree(child.pid);
      setTimeout(() => finish(-1), KILL_SETTLE_MS).unref(); // a grandchild holding the pipes must not hang us
    }, timeoutMs);
  });
}

const IMPORT_TIMEOUT_MS = 8 * 60 * 1000;
const importChecks = new Map(); // projectDir -> Promise<{imported, reason, durationMs}>, one check per process

/** Runs `--headless --path <dir> --import` only when the class cache is stale (see class_cache.mjs),
 *  logging the reason to stderr. Idempotent: one check per process and project dir (concurrent
 *  callers share the promise). Resolves {imported, reason, durationMs, status?}. A failed import is
 *  reported, not thrown: the caller's own run then shows the real errors. */
export function ensureImport({ projectDir = join(ROOT, 'project'), timeoutMs = IMPORT_TIMEOUT_MS } = {}) {
  const key = resolve(projectDir);
  if (!importChecks.has(key)) importChecks.set(key, (async () => {
    const t0 = Date.now();
    const { stale, reason } = isStale(key);
    if (!stale) return { imported: false, reason, durationMs: Date.now() - t0 };
    console.error(`godot: class cache stale (${reason}): running --import first`);
    const res = await runGodot(['--import'], { name: 'import', timeoutMs, cwd: resolve(key, '..'), ensure: false });
    const note = res.status === 0 && !res.timedOut ? 'done' : `FAILED (${describe(res)})`;
    console.error(`godot: --import ${note} in ${(res.durationMs / 1000).toFixed(1)} s`);
    return { imported: true, reason, durationMs: Date.now() - t0, status: res.status };
  })());
  return importChecks.get(key);
}

/** Ledger label when the caller gave no `name`: the script basename or the first flag. */
const kindOf = (args) => {
  const i = args.indexOf('-s');
  return i >= 0 && args[i + 1] ? args[i + 1].split('/').pop().replace(/[.]gd$/, '') : (args[0] ?? 'godot').replace(/^-+/, '');
};

/** Runs the resolved Godot. `headless` (default) prepends --headless; `--path project` is always
 *  added. `name` is only a label for callers' logs. `env` replaces the child environment (default:
 *  inherit). `ensure` (default: on unless the args contain --import) first refreshes a stale class
 *  cache once per process via ensureImport. */
export async function runGodot(args, { timeoutMs = HEADLESS_TIMEOUT_MS, cwd = ROOT, name, headless = true, env,
  ensure = !args.includes('--import') } = {}) {
  const g = resolveGodot();
  if (!g.ok) return { status: -1, out: g.message, timedOut: false, durationMs: 0, notFound: true, name };
  if (ensure) await ensureImport({ projectDir: join(cwd, 'project') });
  const full = [...(headless ? ['--headless'] : []), '--path', 'project', ...args];
  const entry = register({ kind: name ?? kindOf(args), root: cwd }); // machine-wide run ledger (run_ledger.mjs)
  try {
    return { ...(await runProcess(g.bin, full, { cwd, timeoutMs, env, onSpawn: (pid) => entry.setChild(pid) })), name };
  } finally {
    entry.release(); // also on timeout/kill: runProcess resolves after the tree kill
  }
}

/** True when `file` resolves strictly inside <repo>/build or the OS temp dir. */
export function inSafeRoot(file, root = ROOT, tmp = tmpdir()) {
  const abs = resolve(file);
  return [join(root, 'build'), tmp].some((r) => abs.toLowerCase().startsWith(resolve(r).toLowerCase() + sep));
}

/** Removes stale output FILES before a run so a failed launch can never report an old result.
 *  Deletes only explicit files (never recursive) and throws for any path outside <repo>/build or
 *  the OS temp dir (the project/ wipe incident: no helper may delete on a computed path). */
export function removeStale(...files) {
  for (const f of files) {
    if (!inSafeRoot(f)) throw new Error(`removeStale refuses ${f}: not under <repo>/build or the temp dir`);
    if (existsSync(f) && statSync(f).isDirectory()) throw new Error(`removeStale refuses ${f}: a directory`);
    rmSync(f, { force: true, recursive: false });
  }
}

/** "exit 0, 12.3 s" / "TIMED OUT after 600 s" for log headers and summaries. */
export const describe = (r) => (r.timedOut ? `TIMED OUT after ${Math.round(r.durationMs / 1000)} s`
  : `exit ${r.status}, ${(r.durationMs / 1000).toFixed(1)} s`);
