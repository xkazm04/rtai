import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import * as fs from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { CHAPTER, lineSink, runReels } from './run_reels.mjs';
import { parseReel } from './check_reel.mjs';
import { candidates, mainCheckout } from '../lib/godot.mjs';

const options = { timeout: 60_000 };
const chapter = (name = 'pistol', counts = '2/2') =>
  `[INFO] showcase: director chapter ${name}: ${counts} down`;

function scratch(t) {
  const dir = fs.mkdtempSync(join(tmpdir(), 'reels-break-'));
  // Only remove the exact directory just created under the OS temp directory.
  assert.equal(resolve(dir, '..'), resolve(tmpdir()));
  t.after(() => fs.rmSync(dir, { recursive: true, force: true }));
  return dir;
}

for (const [description, line] of [
  ['CRLF result', `${chapter()}\r\n`],
  ['result embedded after unrelated text', `quoted diagnostic: ${chapter()}`],
  ['result with trailing unrelated text', `${chapter()} is only an example`],
  ['chapter-start without a result', '[INFO] showcase: director chapter start pistol'],
  ['zero-over-zero result', chapter('empty', '0/0')],
]) {
  test(`live chapter recognition agrees with parseReel for a ${description}`, options, (t) => {
    const log = join(scratch(t), 'live.log');
    const seen = [];
    lineSink('top', log, (line) => seen.push(line))(line);
    assert.equal(fs.readFileSync(log, 'utf8'), `${line}\n`);
    const judged = parseReel(line, { expect: 0 });
    assert.equal(seen.length, judged.chapters);
    assert.equal(CHAPTER.test(line), judged.chapters === 1);
    if (judged.chapters) {
      const counts = description === 'zero-over-zero result' ? '0/0' : '2/2';
      const name = description === 'zero-over-zero result' ? 'empty' : 'pistol';
      assert.deepEqual(seen, [`run_reels: top chapter 1 ${name} ${counts} down`]);
    }
  });
}

test('lineSink persists each line immediately and restarts chapter numbering per sink', options, (t) => {
  const dir = scratch(t);
  const seen = [];
  const firstLog = join(dir, 'first.log');
  const secondLog = join(dir, 'second.log');
  const first = lineSink('top', firstLog, (line) => seen.push(line));
  const second = lineSink('combo', secondLog, (line) => seen.push(line));
  let text = '';
  for (const line of ['boot', '', chapter('pistol'), 'half-written run', chapter('rocket', '1/4')]) {
    first(line);
    text += `${line}\n`;
    assert.equal(fs.readFileSync(firstLog, 'utf8'), text);
  }
  second(chapter('katana'));
  assert.deepEqual(seen, [
    'run_reels: top chapter 1 pistol 2/2 down',
    'run_reels: top chapter 2 rocket 1/4 down',
    'run_reels: combo chapter 1 katana 2/2 down',
  ]);
});

test('lineSink writes the current line before a hostile progress callback throws', options, (t) => {
  const log = join(scratch(t), 'partial.log');
  const sink = lineSink('top', log, () => { throw new Error('broken observer'); });
  // Propagation itself is unspecified here; persistence is the promised observable outcome.
  try { sink(chapter()); } catch { /* simulate a caller that survives its observer */ }
  assert.equal(fs.readFileSync(log, 'utf8'), `${chapter()}\n`);
  sink('still logging');
  assert.equal(fs.readFileSync(log, 'utf8'), `${chapter()}\nstill logging\n`);
});

for (const failure of ['throw after half a log', 'nonzero exit', 'absent log', 'unreadable log', '0/0 down']) {
  test(`each view is independent after ${failure}, with one immediate FAIL verdict`, options, async (t) => {
    const outDir = scratch(t);
    const events = [];
    const logs = [];
    const progress = (line) => events.push(line);
    const result = await runReels({ views: ['top', 'combo'], expect: 2, outDir, progress,
      run: async (view, log) => {
        events.push(`run ${view}`);
        logs.push(log);
        if (view === 'combo') {
          fs.writeFileSync(log, `${chapter()}\n${chapter('rocket')}`);
          return 0;
        }
        if (failure === 'absent log') return 0;
        // A directory is portably unreadable as a UTF-8 log, even as administrator.
        if (failure === 'unreadable log') { fs.mkdirSync(log); return 0; }
        fs.writeFileSync(log, failure === '0/0 down'
          ? `${chapter()}\n${chapter('empty', '0/0')}` : chapter());
        if (failure === 'throw after half a log') throw new Error('wrapper killed');
        if (failure === 'nonzero exit') {
          fs.appendFileSync(log, `\n${chapter('rocket')}`);
          return 137;
        }
        return 0;
      } });
    assert.equal(result.ok, false);
    assert.deepEqual(result.views.map(({ ok }) => ok), [false, true]);
    assert.ok(result.views[0].problems.length > 0);
    assert.deepEqual(result.views[1].problems, []);
    assert.equal(events.length, 4);
    assert.equal(events[0], 'run top');
    assert.match(events[1], /^run_reels: \[1\/2\] top FAIL, \d+ s; log /);
    assert.ok(events[1].endsWith(`; log ${logs[0]}`));
    assert.equal(events[2], 'run combo');
    assert.match(events[3], /^run_reels: \[2\/2\] combo OK, \d+ s; log /);
    assert.ok(events[3].endsWith(`; log ${logs[1]}`));
    if (failure === 'throw after half a log') assert.equal(fs.readFileSync(logs[0], 'utf8'), chapter());
  });
}

test('a previous successful log is removed before a failed rerun can judge it', options, async (t) => {
  const outDir = scratch(t);
  const first = await runReels({ views: ['top'], expect: 1, outDir,
    run: async (_view, log) => { fs.writeFileSync(log, chapter()); return 0; } });
  assert.equal(first.ok, true);
  for (const throws of [false, true]) {
    fs.writeFileSync(first.views[0].log, chapter());
    const next = await runReels({ views: ['top'], expect: 1, outDir,
      run: async (_view, log) => {
        assert.equal(fs.existsSync(log), false, 'stale log must be absent at launch');
        if (throws) throw new Error('launch failed');
        return 0;
      } });
    assert.equal(next.ok, false);
    assert.equal(next.views[0].ok, false);
    assert.equal(fs.existsSync(first.views[0].log), false);
  }
});

test('the same view twice runs twice in order with independent logs and verdicts', options, async (t) => {
  const logs = [];
  const result = await runReels({ views: ['top', 'top'], expect: 1, outDir: scratch(t),
    run: async (view, log) => {
      assert.equal(view, 'top');
      assert.equal(fs.existsSync(log), false);
      logs.push(log);
      fs.writeFileSync(log, logs.length === 1 ? chapter() : 'incomplete second run');
      return 0;
    } });
  assert.equal(logs.length, 2);
  assert.notEqual(logs[0], logs[1]);
  assert.equal(fs.readFileSync(logs[0], 'utf8'), chapter());
  assert.deepEqual(result.views.map(({ ok }) => ok), [true, false]);
  assert.equal(result.ok, false);
});

test('view independence survives a progress callback throwing at the first verdict', options, async (t) => {
  const ran = [];
  const seen = [];
  let rejection;
  let result;
  try {
    result = await runReels({ views: ['top', 'combo'], expect: 1, outDir: scratch(t),
      run: async (view, log) => { ran.push(view); fs.writeFileSync(log, chapter()); return 0; },
      progress: (line) => { seen.push(line); if (seen.length === 1) throw new Error('observer failed'); } });
  } catch (error) { rejection = error; }
  assert.deepEqual(ran, ['top', 'combo'], 'an observer must not prevent the next independent view');
  assert.equal(rejection, undefined);
  assert.equal(seen.length, 2);
  assert.equal(result.views.length, 2);
  assert.equal(result.views[1].ok, true);
});

test('overall ok requires at least one view even when expect is zero', options, async (t) => {
  let calls = 0;
  const result = await runReels({ views: [], expect: 0, outDir: scratch(t),
    run: async () => { calls += 1; return 0; }, progress: () => { calls += 1; } });
  assert.equal(result.ok, false);
  assert.deepEqual(result.views, []);
  assert.equal(calls, 0);
});

function fakeFs(files = new Map(), dirs = new Map()) {
  return {
    exists: (file) => files.has(file),
    read: (file) => { assert.ok(files.has(file)); return files.get(file); },
    list: (dir) => [...(dirs.get(dir) ?? [])],
  };
}

const consoleBin = 'Godot_v4.7.2-stable_win64_console.exe';
const nearDirs = (root) => [root, resolve(root, '..'), resolve(root, '..', '..')]
  .flatMap((base) => [join(base, 'tools', 'godot'), join(base, 'gtai-spike', 'tools', 'godot')]);

for (const relation of ['equal to root', 'inside root', 'far away with spaces']) {
  test(`candidate search includes all six levels without duplicate known paths when main is ${relation}`,
    options, () => {
      const root = resolve('virtual', 'worktrees', 'deep', 'lane');
      const main = relation === 'equal to root' ? root : relation === 'inside root'
        ? join(root, 'main', 'checkout') : resolve('virtual main with spaces', 'game', 'checkout');
      const dirs = [...new Set([...nearDirs(root), ...nearDirs(main)])];
      const known = dirs.map((dir) => join(dir, consoleBin));
      const local = join(root, 'tools', 'local.json');
      const fs = fakeFs(new Map([[local, JSON.stringify({ godot: 'local binary with spaces' })]]),
        new Map(dirs.map((dir) => [dir, [consoleBin, 'Godot_v4.7.2-stable_win64.exe', 'notes.txt']])));
      const result = candidates({ root, main, fs, env: { GODOT_BIN: 'env one', POF_GODOT_BIN: 'env two' } });
      assert.deepEqual(result.slice(0, 3).map(({ bin }) => bin),
        ['env one', 'env two', 'local binary with spaces']);
      const found = result.filter(({ source }) => source === 'known path').map(({ bin }) => bin);
      assert.deepEqual(found, known);
      assert.equal(new Set(found).size, found.length);
      assert.deepEqual(result.at(-1), { bin: 'godot', source: 'PATH', explicit: false });
    });
}

test('main null excludes checkout-only paths while retaining every root search level', options, () => {
  const root = resolve('virtual', 'worktrees', 'deep', 'lane');
  const main = resolve('unrelated main with spaces', 'game', 'checkout');
  const dirs = new Map([...nearDirs(root), ...nearDirs(main)].map((dir) => [dir, [consoleBin]]));
  const result = candidates({ root, main: null, env: {}, fs: fakeFs(new Map(), dirs) });
  assert.deepEqual(result.filter(({ source }) => source === 'known path').map(({ bin }) => bin),
    nearDirs(root).map((dir) => join(dir, consoleBin)));
});

test('mainCheckout returns null for a temporary directory outside every repository', options, (t) => {
  const root = scratch(t);
  // Distinguish a real non-repository from a missing/blocked git executable.
  const probe = spawnSync('git', ['rev-parse', '--git-common-dir'], {
    cwd: root, encoding: 'utf8', windowsHide: true, timeout: 60_000,
  });
  assert.ifError(probe.error);
  assert.equal(probe.status, 128);
  assert.match(probe.stderr, /not a git repository/i);
  assert.equal(mainCheckout(root), null);
});
