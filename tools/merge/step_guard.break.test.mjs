// Adversarial contract tests; only disposable Node/shell processes, never production tools.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spawn, spawnSync } from 'node:child_process';
import { closeSync, existsSync, mkdtempSync, openSync, readFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { setTimeout as delay } from 'node:timers/promises';
import { GUARD_EXIT, parseGuardArgs } from './step_guard.mjs';
import { defaultRun } from './morning.mjs';
import { budgetMs, nodeStartMs } from '../lib/node_start.mjs';

const GUARD = fileURLToPath(new URL('./step_guard.mjs', import.meta.url));
const OPTIONS = { timeout: 90_000 };
// step limit for runs that test bytes and exit codes, not timing: 3 s was killed by load (2 Godot + lint, 05:27)
const CLEAN_MS = 60_000;
const alive = (pid) => {
  try { process.kill(pid, 0); return true; }
  catch (e) { if (e.code === 'ESRCH') return false; throw e; }
};

function cleanupPid(pid) {
  if (!pid || !alive(pid)) return;
  if (process.platform === 'win32') {
    spawnSync('taskkill', ['/F', '/T', '/PID', String(pid)], {
      windowsHide: true, stdio: 'ignore', timeout: 3000,
    });
  } else {
    try { process.kill(-pid, 'SIGKILL'); } catch { /* not a group leader */ }
    try { process.kill(pid, 'SIGKILL'); } catch { /* already gone */ }
  }
}

function fixture(t) {
  const dir = mkdtempSync(join(tmpdir(), 'step-guard-break-'));
  const pidFiles = [];
  t.after(() => {
    for (const file of pidFiles) {
      if (existsSync(file)) cleanupPid(Number(readFileSync(file, 'utf8')));
    }
    // dir is the exact directory returned by mkdtempSync under os.tmpdir().
    rmSync(dir, { recursive: true, force: true });
  });
  return {
    dir,
    pidFile(name = 'child.pid') {
      const file = join(dir, name);
      pidFiles.push(file);
      return file;
    },
  };
}

function runGuard(f, argv, logName = 'guard.log') {
  const log = join(f.dir, logName);
  const fd = openSync(log, 'w');
  let result;
  const started = performance.now();
  try {
    result = spawnSync(process.execPath, [GUARD, ...argv], {
      stdio: ['ignore', fd, fd], timeout: CLEAN_MS + 10_000, windowsHide: true,
    });
  } finally { closeSync(fd); }
  assert.ifError(result.error);
  return { ...result, log, out: readFileSync(log, 'utf8'), ms: performance.now() - started };
}

const args = (step, ms, source, extra = []) =>
  [step, String(ms), '0', '--', process.execPath, '-e', source, ...extra];
const nonemptyLines = (s) => s.split(/\r?\n/).filter((line) => line.trim());

async function waitFor(predicate, message, limit = 3000) {
  const end = Date.now() + limit;
  while (!predicate() && Date.now() < end) await delay(25);
  assert.ok(predicate(), message);
}

test('malformed argv must be rejected without running the command or hiding usage', OPTIONS, (t) => {
  const f = fixture(t);
  const marker = join(f.dir, 'must-not-run');
  const command = [process.execPath, '-e', `require('fs').writeFileSync(${JSON.stringify(marker)}, 'ran')`];
  const bad = [
    ['', '1000', '0', '--'], ['x', '0', '0', '--'], ['x', '-1', '0', '--'],
    ['x', 'NaN', '0', '--'], ['x', '1000', 'true', '--'], ['x', '1000', '0'],
    ['x', '1000', '0', 'extra', '--'],
  ];
  for (const prefix of bad) {
    const argv = [...prefix, ...command];
    assert.equal(parseGuardArgs(argv), null, JSON.stringify(argv));
    const r = spawnSync(process.execPath, [GUARD, ...argv], {
      encoding: 'utf8', timeout: 3000, windowsHide: true,
    });
    assert.ifError(r.error);
    assert.equal(r.status, 2, JSON.stringify(argv));
    assert.match(r.stderr, /usage:/i);
    assert.equal(r.stdout, '');
    assert.equal(existsSync(marker), false);
  }
  assert.equal(parseGuardArgs(['x', '10', '0', '--']), null);
});

test('parseGuardArgs must reject a non-finite timeout rather than arm an immediate timer', OPTIONS, () => {
  assert.equal(parseGuardArgs(['x', 'Infinity', '0', '--', process.execPath]), null);
});

test('parseGuardArgs must reject an empty executable instead of letting spawn throw', OPTIONS, () => {
  assert.equal(parseGuardArgs(['x', '1000', '0', '--', '']), null);
});

test('a positional step named -- must not consume the actual command separator', OPTIONS, (t) => {
  const r = runGuard(fixture(t), args('--', CLEAN_MS, "process.stdout.write('ran'); process.exit(7)"));
  assert.equal(r.status, 7);
  assert.equal(r.out, 'ran');
});

test('shell 0 must forward --, empty strings, spaces and metacharacters byte for byte', OPTIONS, (t) => {
  const f = fixture(t);
  const injected = join(f.dir, 'injected');
  const values = ['--', '', 'two words', '"quoted"', "'single'", 'a\\b\\',
    `& echo injected > "${injected}"`, '; exit 19', '$(echo injected)', '%PATH%', '!PATH!', '|', '\n'];
  const r = runGuard(f, args('literal-argv', CLEAN_MS,
    'process.stdout.write(JSON.stringify(process.argv.slice(1)))', ['--', ...values]));
  assert.equal(r.status, 0);
  assert.deepEqual(JSON.parse(r.out), values);
  assert.equal(existsSync(injected), false);
});

test('a clean run must inherit stdout and stderr without adding or losing binary bytes', OPTIONS, (t) => {
  const f = fixture(t);
  const outFile = join(f.dir, 'stdout');
  const errFile = join(f.dir, 'stderr');
  const out = openSync(outFile, 'w');
  const err = openSync(errFile, 'w');
  let r;
  try {
    r = spawnSync(process.execPath, [GUARD, ...args('binary', CLEAN_MS,
      "require('fs').writeSync(1, Buffer.from([0,255,13,10])); require('fs').writeSync(2, Buffer.from([128,0,10])); process.exit(23)")],
    { stdio: ['ignore', out, err], timeout: CLEAN_MS + 10_000, windowsHide: true });
  } finally { closeSync(out); closeSync(err); }
  assert.ifError(r.error);
  assert.equal(r.status, 23);
  assert.deepEqual(readFileSync(outFile), Buffer.from([0, 255, 13, 10]));
  assert.deepEqual(readFileSync(errFile), Buffer.from([128, 0, 10]));
});

test('a missing executable must produce GUARD_EXIT and exactly one step diagnostic', OPTIONS, (t) => {
  const f = fixture(t);
  const r = runGuard(f, ['cannot-spawn', '3000', '0', '--', join(f.dir, 'absent-executable')]);
  assert.equal(r.status, GUARD_EXIT);
  assert.equal(nonemptyLines(r.out).length, 1);
  assert.match(r.out, /morning: cannot-spawn:/);
});

test('a 1 ms timeout must kill a hanging command and report its own timeout once', OPTIONS, (t) => {
  const f = fixture(t);
  const pid = f.pidFile();
  const r = runGuard(f, args('one-ms', 1,
    `require('fs').writeFileSync(${JSON.stringify(pid)}, String(process.pid)); setInterval(() => {}, 1000)`));
  assert.equal(r.status, GUARD_EXIT);
  assert.equal(nonemptyLines(r.out).length, 1);
  assert.match(r.out, /morning: one-ms: timed out after .* min \(the process tree was killed\)/);
  if (existsSync(pid)) assert.equal(alive(Number(readFileSync(pid, 'utf8'))), false);
});

test('a huge finite timeout must not overflow into a 1 ms timeout and kill a clean command', OPTIONS, (t) => {
  const r = runGuard(fixture(t), args('large-limit', 2 ** 31,
    "setTimeout(() => { process.stdout.write('completed'); process.exit(17); }, 150)"));
  assert.equal(r.status, 17);
  assert.equal(r.out, 'completed');
});

test('defaultRun must preserve logs and map a command returning GUARD_EXIT to status -1', OPTIONS, (t) => {
  const f = fixture(t);
  const source = `process.stdout.write('intentional reserved exit'); process.exit(${GUARD_EXIT})`;
  const direct = runGuard(f, args('reserved-exit', CLEAN_MS, source));
  assert.equal(direct.status, GUARD_EXIT);
  assert.equal(direct.out, 'intentional reserved exit');
  const r = defaultRun(process.cwd(), f.dir, 0.2)('reserved-exit', process.execPath, ['-e', source]);
  assert.equal(r.status, -1);
  assert.equal(r.out, direct.out);
  assert.equal(readFileSync(r.log, 'utf8'), r.out);
  t.diagnostic('An ordinary exit 222 reports -1: the documented reserved-code collision, not a contract defect.');
});

test('defaultRun must report -1 when a step never ran and preserve an ordinary nonzero command code', OPTIONS, (t) => {
  const f = fixture(t);
  const run = defaultRun(process.cwd(), f.dir, 0.2);
  const missing = run('missing-command', join(f.dir, 'absent-executable'), []);
  assert.equal(missing.status, -1);
  assert.equal(nonemptyLines(missing.out).length, 1);
  assert.match(missing.out, /morning: missing-command:/);
  assert.equal(readFileSync(missing.log, 'utf8'), missing.out);
  const neverRan = run('missing-cwd', process.execPath, ['-e', "process.stdout.write('must-not-run')"],
    { cwd: join(f.dir, 'absent-directory') });
  assert.equal(neverRan.status, -1);
  assert.doesNotMatch(neverRan.out, /must-not-run/);
  assert.equal(readFileSync(neverRan.log, 'utf8'), neverRan.out);
  const ordinary = run('ordinary-code', process.execPath, ['-e',
    "require('fs').writeSync(1, 'stdout'); require('fs').writeSync(2, 'stderr'); process.exit(29)"]);
  assert.equal(ordinary.status, 29);
  assert.equal(ordinary.out, 'stdoutstderr');
  assert.equal(readFileSync(ordinary.log, 'utf8'), ordinary.out);
});

test('signal termination must not be mistaken for a clean command or a guard timeout', OPTIONS, (t) => {
  const f = fixture(t);
  const source = "process.stdout.write('before signal'); process.kill(process.pid, 'SIGTERM')";
  const bare = spawnSync(process.execPath, ['-e', source], {
    encoding: 'utf8', timeout: 3000, windowsHide: true,
  });
  assert.ifError(bare.error);
  const r = defaultRun(process.cwd(), f.dir, 0.2)('signal-exit', process.execPath,
    ['-e', source]);
  // Windows reports TerminateProcess as code 1; POSIX reports null + SIGTERM.
  assert.equal(r.status, bare.status ?? -1);
  assert.match(r.out, /before signal/);
  if (bare.signal) assert.match(r.out, /morning: signal-exit:/);
  else assert.equal(r.out, bare.stdout + bare.stderr);
  assert.doesNotMatch(r.out, /timed out/);
  t.diagnostic(`Bare command: code=${bare.status}, signal=${bare.signal}; defaultRun status=${r.status}`);
});

test('an externally killed command must make its guard exit promptly with the platform exit result', OPTIONS, async (t) => {
  const f = fixture(t);
  const bare = spawn(process.execPath, ['-e', 'setInterval(() => {}, 1000)'], {
    stdio: 'ignore', windowsHide: true,
  });
  t.after(() => cleanupPid(bare.pid));
  const bareExit = new Promise((resolve, reject) => {
    bare.once('error', reject);
    bare.once('exit', (code, signal) => resolve({ code, signal }));
  });
  process.kill(bare.pid, 'SIGKILL');
  await waitFor(() => bare.exitCode !== null || bare.signalCode !== null, 'bare command must exit');
  const baseline = await bareExit;
  const pidFile = f.pidFile();
  const fd = openSync(join(f.dir, 'external.log'), 'w');
  const child = spawn(process.execPath, [GUARD, ...args('external-kill', 10_000,
    `require('fs').writeFileSync(${JSON.stringify(pidFile)}, String(process.pid)); setInterval(() => {}, 1000)`) ],
  { stdio: ['ignore', fd, fd], windowsHide: true });
  closeSync(fd);
  t.after(() => cleanupPid(child.pid));
  const exited = new Promise((resolve, reject) => {
    child.once('error', reject);
    child.once('exit', (code, signal) => resolve({ code, signal }));
  });
  // the guard and the command are two cold node starts before the pid file can exist (n15 item 6)
  await waitFor(() => existsSync(pidFile), 'command must start before the external kill', budgetMs(3000, 2));
  process.kill(Number(readFileSync(pidFile, 'utf8')), 'SIGKILL');
  await waitFor(() => child.exitCode !== null || child.signalCode !== null, 'guard must exit within 3 s');
  assert.deepEqual(await exited, { code: baseline.code ?? GUARD_EXIT, signal: null });
  const log = readFileSync(join(f.dir, 'external.log'), 'utf8');
  if (baseline.signal) {
    assert.equal(nonemptyLines(log).length, 1);
    assert.match(log, /morning: external-kill:/);
  } else assert.equal(log, '');
  assert.doesNotMatch(log, /timed out/);
  t.diagnostic(`External kill: bare code=${baseline.code}, signal=${baseline.signal}; guard code=${child.exitCode}`);
});

function treeSource(pidFile, lateFile, lateMs = 3000) {
  // The grandchild source contains no double quotes, so cmd.exe and sh can quote it safely.
  const grand = "require('fs').writeFileSync(process.env.BREAK_PID, String(process.pid)); " +
    "process.on('SIGTERM', () => {}); " +
    (lateFile ? `setTimeout(() => { require('fs').writeFileSync(process.env.BREAK_LATE, 'late'); process.stdout.write('LATE'); }, ${Math.ceil(lateMs)}); ` : '') +
    'setInterval(() => {}, 1000)';
  const mid = process.platform === 'win32'
    ? ['cmd.exe', ['/d', '/s', '/c', `""${process.execPath}" -e "${grand}""`]]
    : ['sh', ['-c', `"${process.execPath}" -e "${grand}"; wait`]];
  return `const cp = require('child_process'); cp.spawn(${JSON.stringify(mid[0])}, ${JSON.stringify(mid[1])}, ` +
    `{ stdio: 'inherit', windowsVerbatimArguments: ${process.platform === 'win32'}, env: { ...process.env, ` +
    `BREAK_PID: ${JSON.stringify(pidFile)}, BREAK_LATE: ${JSON.stringify(lateFile ?? '')} } }); ` +
    "process.stdout.write('parent-started\\n'); setInterval(() => {}, 1000)";
}

test('timeout must kill a grandchild behind a non-Node shell before any post-timeout output', OPTIONS, async (t) => {
  const f = fixture(t);
  const pidFile = f.pidFile();
  const lateFile = join(f.dir, 'late');
  // 2 s meant, plus the parent's and the grandchild's cold node starts (n15 item 6); the grandchild's
  // late write comes the limit plus 1 s (the tree kill's own time) after its own start, so after the kill.
  const limit = budgetMs(2000, 2);
  const started = performance.now();
  const r = defaultRun(process.cwd(), f.dir, limit / 60000)('shell-tree', process.execPath,
    ['-e', treeSource(pidFile, lateFile, limit + 1000)]);
  assert.ok(performance.now() - started < limit + 5000, 'guard must finish before the 2 minute outer backstop');
  assert.equal(r.status, -1);
  assert.ok(existsSync(pidFile), `grandchild must actually have started: ${r.out}`);
  const pid = Number(readFileSync(pidFile, 'utf8'));
  await waitFor(() => !alive(pid), `grandchild ${pid} must be dead after timeout`);
  await delay(1400);
  assert.equal(existsSync(lateFile), false, 'grandchild executed code after the guard timeout');
  assert.equal(readFileSync(r.log, 'utf8'), r.out, 'log changed after guard returned');
  assert.match(r.out, /parent-started/);
  assert.match(r.out, /morning: shell-tree: timed out after .* min \(the process tree was killed\)/);
  assert.equal(nonemptyLines(r.out).filter((line) => line.startsWith('morning:')).length, 1);
});

test('a descendant retaining inherited log handles after its parent exits must not hold the guard open', OPTIONS, async (t) => {
  const f = fixture(t);
  const pidFile = f.pidFile();
  // Parent waits for proof that the descendant holds the log before exiting normally.
  const source = treeSource(pidFile);
  const parent = source.slice(0, source.lastIndexOf("setInterval(() => {}, 1000)")) +
    `const timer = setInterval(() => { if (require('fs').existsSync(${JSON.stringify(pidFile)})) process.exit(6); }, 20);`;
  // three cold node starts (guard, parent, descendant) sit inside both numbers (n15 item 6)
  const start = nodeStartMs();
  const r = runGuard(f, args('held-log', Math.ceil(budgetMs(6000, 3, start)), parent));
  assert.ok(existsSync(pidFile), `descendant must start before parent exits: ${r.out}`);
  assert.ok(alive(Number(readFileSync(pidFile, 'utf8'))), 'descendant must still hold the log after parent death');
  assert.equal(r.status, 6);
  assert.ok(r.ms < budgetMs(4000, 3, start), `guard waited ${r.ms} ms for a descendant's log handle`);
  assert.equal(r.out, 'parent-started\n');
});
