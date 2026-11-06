// node --test tools/lib/
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { spawn, spawnSync } from 'node:child_process';
import { existsSync, mkdtempSync, readdirSync, rmdirSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import {
  acquireBench, activeRuns, benchHolder, contention, enqueue, etaMinutes, foreignGodot, ledgerDir, pidAlive, queueTickets,
  parseContended, register, settleContended, takeBenchLock,
} from './run_ledger.mjs';

/** An empty ledger folder under os.tmpdir(); done() deletes the files left in it, then the folder. */
function fixtureDir() {
  const dir = mkdtempSync(join(tmpdir(), 'gtai-ledger-'));
  const done = () => {
    for (const f of readdirSync(dir)) rmSync(join(dir, f), { force: true, recursive: false });
    rmdirSync(dir);
  };
  return { dir, done };
}

/** A node child that lives until killed; resolves once it is running. */
const sleeper = () => spawn(process.execPath, ['-e', 'setInterval(() => {}, 1000)'], { stdio: 'ignore', windowsHide: true });
/** A pid that is certainly dead: a child that already exited. */
const deadPid = () => spawnSync(process.execPath, ['-e', '0']).pid;

const entryFile = (dir, name, e) => { writeFileSync(join(dir, name), JSON.stringify(e)); return join(dir, name); };
const entry = (pid, extra = {}) => ({ pid, childPid: null, worktree: '/wt/x', branch: 'lane-x', kind: 'scenarios', start: Date.now(), ...extra });

test('ledgerDir honours GTAI_RUNS_DIR and defaults under LOCALAPPDATA', () => {
  assert.equal(ledgerDir({ GTAI_RUNS_DIR: '/x/runs' }), '/x/runs');
  assert.equal(ledgerDir({ LOCALAPPDATA: join('/a', 'b') }), join('/a', 'b', 'gtai', 'runs'));
});

test('pidAlive: self and a live child are alive, an exited child is not, junk is not', () => {
  const c = sleeper();
  try {
    assert.ok(pidAlive(process.pid));
    assert.ok(pidAlive(c.pid));
  } finally { c.kill(); }
  assert.ok(!pidAlive(deadPid()));
  assert.ok(!pidAlive(0));
  assert.ok(!pidAlive(NaN));
});

test('register writes an entry file, setChild updates it, release removes it', () => {
  const f = fixtureDir();
  try {
    const h = register({ kind: 'unit', dir: f.dir });
    assert.ok(existsSync(h.file));
    h.setChild(4242);
    assert.equal(JSON.parse(spawnSync(process.execPath, ['-e', `process.stdout.write(require('fs').readFileSync(${JSON.stringify(h.file)}, 'utf8'))`]).stdout).childPid, 4242);
    assert.equal(activeRuns({ dir: f.dir }).length, 0); // excludeSelf (default)
    const all = activeRuns({ dir: f.dir, excludeSelf: false });
    assert.equal(all.length, 1);
    assert.equal(all[0].kind, 'unit');
    assert.equal(all[0].pid, process.pid);
    h.release();
    assert.ok(!existsSync(h.file));
  } finally { f.done(); }
});

test('activeRuns lists a live foreign entry and reaps a dead-pid entry (one file deleted)', () => {
  const f = fixtureDir();
  const c = sleeper();
  try {
    entryFile(f.dir, `${c.pid}-aaaaaa.json`, entry(c.pid));
    const dead = entryFile(f.dir, 'dead-bbbbbb.json', entry(deadPid()));
    const runs = activeRuns({ dir: f.dir });
    assert.deepEqual(runs.map((r) => r.pid), [c.pid]);
    assert.ok(!existsSync(dead), 'dead entry reaped');
  } finally { c.kill(); f.done(); }
});

test('an entry older than MAX_AGE is reaped even when its pid is alive (pid reuse)', () => {
  const f = fixtureDir();
  try {
    const old = entryFile(f.dir, 'old-cccccc.json', entry(process.pid, { start: Date.now() - 2 * 60 * 60 * 1000 }));
    assert.equal(activeRuns({ dir: f.dir, excludeSelf: false }).length, 0);
    assert.ok(!existsSync(old));
  } finally { f.done(); }
});

test('contention = ledger others + unregistered Godot processes; GTAI_COUNT_FOREIGN=0 ignores the latter', () => {
  const f = fixtureDir();
  const c = sleeper();
  try {
    entryFile(f.dir, `${c.pid}-dddddd.json`, entry(c.pid, { childPid: 900 }));
    const procs = [
      { pid: 900, ppid: 1, name: 'Godot_console.exe' }, // the ledger run's own child
      { pid: 901, ppid: 900, name: 'Godot.exe' },       // ... and its engine
      { pid: 910, ppid: 5, name: 'Godot_console.exe' }, // a hand-run console exe
      { pid: 911, ppid: 910, name: 'Godot.exe' },       // ... and its engine: counts once
    ];
    assert.deepEqual(foreignGodot({ dir: f.dir, procs }).map((p) => p.pid), [910, 911]);
    const c1 = contention({ dir: f.dir, env: {}, procs });
    assert.equal(c1.others.length, 1);
    assert.equal(c1.foreign, 1);
    assert.equal(c1.count, 2);
    assert.equal(contention({ dir: f.dir, env: { GTAI_COUNT_FOREIGN: '0' }, procs }).count, 1);
  } finally { c.kill(); f.done(); }
});

test('etaMinutes: remaining typical time of the longest run plus a bench per queued ticket', () => {
  const now = 10 * 60000;
  assert.equal(etaMinutes([], 0, now), 0);
  assert.equal(etaMinutes([{ kind: 'scenarios', start: now - 3 * 60000 }], 0, now), 5);
  assert.equal(etaMinutes([{ kind: 'bench', start: now - 20 * 60000 }], 1, now), 0.5 + 14);
});

test('the queue is FIFO and drops dead owners; bench.lock is exclusive and reaped when its owner died', () => {
  const f = fixtureDir();
  try {
    const t1 = enqueue({ dir: f.dir, now: 1000 });
    const t2 = enqueue({ dir: f.dir, now: 2000 });
    entryFile(f.dir, 'queue-000000000000500-1-dead.json', entry(deadPid()));
    assert.deepEqual(queueTickets({ dir: f.dir }).map((t) => t.start), [1000, 2000]);
    t1.release();
    assert.deepEqual(queueTickets({ dir: f.dir }).map((t) => t.start), [2000]);
    t2.release();

    const lock = takeBenchLock({ dir: f.dir, root: f.dir });
    assert.ok(lock);
    assert.equal(takeBenchLock({ dir: f.dir, root: f.dir }), null, 'second taker is refused');
    assert.equal(benchHolder({ dir: f.dir, root: f.dir }).pid, process.pid);
    lock.release();
    assert.equal(benchHolder({ dir: f.dir, root: f.dir }), null);
    entryFile(f.dir, 'bench.lock', { pid: deadPid(), start: Date.now(), worktree: 'x', branch: 'y' });
    assert.equal(benchHolder({ dir: f.dir, root: f.dir }), null, 'a dead holder does not hold');
    assert.ok(!existsSync(join(f.dir, 'bench.lock')));
  } finally { f.done(); }
});

test('parseContended finds each distinct CONTENDED line and its scenario', () => {
  const out = ['x', '[WARN] scenario: CONTENDED: city_chase.nav_max_us 3100 > 2000 (2 other runs)',
    '[WARN] scenario: CONTENDED: rig_stress.rigMsP50 1.200 > 1.000 (1 other runs)',
    '[WARN] scenario: CONTENDED: rig_stress.rigMsP50 1.300 > 1.000 (1 other runs)'].join(String.fromCharCode(13, 10));
  const list = parseContended(out);
  assert.deepEqual(list.map((c) => c.scenario), ['city_chase', 'rig_stress']);
  assert.equal(list[0].text, 'city_chase.nav_max_us 3100 > 2000 (2 other runs)');
  assert.deepEqual(parseContended('FAIL scenario_x.gd: nope'), []);
});

const miss = [{ metric: 'city_chase.nav_max_us', scenario: 'city_chase', text: 't' }];
const noSleep = async () => {};

test('settleContended: nothing contended is none; a quiet machine re-runs once and passes or fails strictly', async () => {
  assert.equal((await settleContended({ contended: [], quiet: async () => true, rerun: async () => assert.fail('no rerun') })).state, 'none');
  let seen = null;
  const passed = await settleContended({ contended: miss, quiet: async () => true, rerun: async (s) => { seen = s; return { ok: true, contended: [] }; } });
  assert.equal(passed.state, 'passed');
  assert.deepEqual(seen, ['city_chase']);
  const failed = await settleContended({ contended: miss, quiet: async () => true, rerun: async () => ({ ok: false, contended: [] }) });
  assert.equal(failed.state, 'failed', 'a real regression on a quiet machine is never green');
});

test('settleContended: waits for quiet, then re-runs; a machine that never quiets stays CONTENDED without a re-run', async () => {
  let polls = 0;
  const r = await settleContended({ contended: miss, quiet: async () => ++polls > 3, rerun: async () => ({ ok: true, contended: [] }), sleep: noSleep, pollMs: 1000 });
  assert.equal(r.state, 'passed');
  assert.equal(r.waitedMs, 3000);
  const never = await settleContended({ contended: miss, quiet: async () => false, rerun: async () => assert.fail('must not re-run'), sleep: noSleep, waitMs: 5000, pollMs: 1000 });
  assert.equal(never.state, 'contended');
  assert.match(never.why, /never went quiet/);
  const busyAgain = await settleContended({ contended: miss, quiet: async () => true, rerun: async () => ({ ok: true, contended: miss }) });
  assert.equal(busyAgain.state, 'contended');
});

/** A fake clock: sleep(ms) advances it. */
const clock = () => { let t = 1000000; return { now: () => t, sleep: async (ms) => { t += ms; } }; };
const quietCount = { others: [], foreign: 0, count: 0 };

test('acquireBench: an idle machine takes bench.lock at once, and the ticket is gone', async () => {
  const f = fixtureDir();
  try {
    const r = await acquireBench({ dir: f.dir, root: f.dir, count: () => quietCount, ...clock() });
    assert.equal(r.contended, false);
    assert.ok(benchHolder({ dir: f.dir, root: f.dir }));
    assert.equal(queueTickets({ dir: f.dir }).length, 0);
    r.lock.release();
  } finally { f.done(); }
});

test('acquireBench: waits while busy (logging an ETA), then runs once the machine is quiet', async () => {
  const f = fixtureDir();
  try {
    const c = clock();
    const busy = { others: [{ kind: 'scenarios', start: c.now(), branch: 'lane-x', worktree: '/wt/lane-x' }], foreign: 0, count: 1 };
    let polls = 0;
    const logs = [];
    const r = await acquireBench({ dir: f.dir, root: f.dir, count: () => (++polls > 3 ? quietCount : busy), log: (l) => logs.push(l), logEveryMs: 1, ...c });
    assert.equal(r.contended, false);
    assert.ok(r.waitedMs >= 45000);
    assert.match(logs[0], /ETA ~\d+ min/);
    assert.match(logs[0], /scenarios \(lane-x/);
    r.lock.release();
  } finally { f.done(); }
});

test('acquireBench: at the deadline the head of the queue runs anyway, flagged contended; waitMs 0 with a holder gives up', async () => {
  const f = fixtureDir();
  try {
    const busy = { others: [], foreign: 2, count: 2 };
    const r = await acquireBench({ dir: f.dir, root: f.dir, waitMs: 60000, count: () => busy, ...clock() });
    assert.equal(r.contended, true);
    assert.equal(r.others, 2);
    const second = await acquireBench({ dir: f.dir, root: f.dir, waitMs: 0, count: () => quietCount, ...clock() });
    assert.match(second.error, /bench lock held/);
    assert.equal(queueTickets({ dir: f.dir }).length, 0, 'the giving-up ticket is released');
    r.lock.release();
  } finally { f.done(); }
});
