import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { git, main, parseArgs, STEPS, STEP_RUNNERS } from './morning.mjs';

// No subprocess is ever created: even the real step runners receive this fake.
function fixture(t, options = {}) {
  const dir = mkdtempSync(join(tmpdir(), 'morning-break-'));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  const calls = [];
  const seen = [];
  const messages = [];
  const result = (stdout = '', status = 0) => ({ stdout, status, stderr: '' });
  const spawnGit = (cmd, args, opts) => {
    assert.equal(cmd, 'git');
    assert.equal(opts.shell, undefined, 'hostile names must never enter a shell');
    assert.deepEqual(args.slice(0, 2), ['-C', dir]);
    const a = args.slice(2);
    calls.push(a);
    const override = options.reply?.(a);
    if (override) return override;
    if (a[0] === 'symbolic-ref') return result(options.branch ?? 'int-day');
    if (a[0] === 'show-ref') return result(['a', 'b', 'c', 'int-day', 'main', 'lane with spaces']
      .map((b) => `abc refs/heads/${b}`).join('\n'));
    if (a.includes('MERGE_HEAD')) return result('', options.merging ? 0 : 1);
    if (a.includes('--is-inside-work-tree')) return result('true');
    if (a[0] === 'status') return result(options.dirty ?? '');
    return result('abc123');
  };
  const runners = Object.fromEntries(STEPS.map((s) => [s, () => {
    seen.push(s);
    return { ok: true };
  }]));
  const invoke = (extra = [], injected = {}) => main([
    `--worktree=${dir}`, '--lanes=a,b', '--date=2026-11-10', ...extra,
  ], { spawnGit, runners, run: () => { throw new Error('unexpected external runner'); },
    out: (s) => messages.push(s), err: (s) => messages.push(s), ...injected });
  const state = (done) => {
    mkdirSync(join(dir, 'build'), { recursive: true });
    writeFileSync(join(dir, 'build/merge-state.json'), JSON.stringify({ done }));
  };
  return { dir, calls, seen, messages, invoke, state };
}

test('never pushes: forbidden verbs and option-shaped verbs never reach spawnGit', () => {
  for (const verb of ['push', 'checkout', 'reset', 'branch', '-c', '--exec-path=evil']) {
    assert.throws(() => git('.', [verb, 'main'], () => assert.fail('spawned forbidden git')));
  }
});

for (const branch of ['main', 'master', '', 'a', 'int-day']) {
  test(`never works on protected, detached or input-lane branches: ${JSON.stringify(branch)}`, (t) => {
    const f = fixture(t, { branch });
    assert.equal(f.invoke(branch === 'int-day' ? ['--lanes=int-day'] : []).code, 2);
    assert.deepEqual(f.seen, []);
    assert.ok(f.calls.every((a) => !['merge', 'add', 'commit', 'mv'].includes(a[0])));
  });
}

for (const dirty of [' M file', '?? "odd\\tname.gd"', 'R  old -> new', ' U odd', '\n?? x\n']) {
  test(`refuses dirty trees before work even with odd porcelain: ${JSON.stringify(dirty)}`, (t) => {
    const f = fixture(t, { dirty });
    assert.equal(f.invoke().code, 2);
    assert.deepEqual(f.seen, []);
  });
}

test('refuses dirty trees on resume too, before any step can commit unrelated changes', (t) => {
  const f = fixture(t, { dirty: ' M project/unrelated.gd' });
  f.state(['merge']);
  assert.equal(f.invoke(['--resume']).code, 2);
  assert.deepEqual(f.seen, []);
});

for (const resume of [false, true]) {
  test(`refuses unfinished merges before work, resume=${resume}`, (t) => {
    const f = fixture(t, { merging: true });
    assert.equal(f.invoke(resume ? ['--resume'] : []).code, 2);
    assert.deepEqual(f.seen, []);
  });
}

test('lanes with spaces stay a single git argument and never invoke a shell', (t) => {
  const f = fixture(t);
  assert.equal(f.invoke(['--lanes=lane with spaces', '--steps=merge'], { runners: STEP_RUNNERS }).code, 0);
  assert.equal(f.calls.find((a) => a[0] === 'merge').at(-1), 'lane with spaces');
});

test('lane names must not become git merge options such as --abort', (t) => {
  const f = fixture(t);
  // Git cannot create this branch; show-ref therefore must not claim it exists.
  assert.equal(f.invoke(['--lanes=--abort', '--steps=merge'], { runners: STEP_RUNNERS }).code, 2);
  assert.ok(f.calls.every((a) => !['log', 'merge'].includes(a[0])));
});

test('duplicate lanes never redo an already marked lane merge', (t) => {
  const f = fixture(t);
  assert.equal(f.invoke(['--lanes=a,a,b,a', '--steps=merge'], { runners: STEP_RUNNERS }).code, 0);
  assert.deepEqual(f.calls.filter((a) => a[0] === 'merge').map((a) => a.at(-1)), ['a', 'b']);
});

test('resume preserves lane marks and retries only the failed lane before later steps', (t) => {
  let red = true;
  const f = fixture(t, { reply: (a) => a[0] === 'merge' && a.at(-1) === 'b' && red
    ? { status: 1, stdout: '', stderr: 'merge failed' } : null });
  const runners = { ...STEP_RUNNERS, debt: () => { f.seen.push('debt'); return { ok: true }; } };
  assert.equal(f.invoke(['--steps=merge,debt'], { runners }).stoppedAt, 'merge');
  assert.deepEqual(JSON.parse(readFileSync(join(f.dir, 'build/merge-state.json'))).done, ['merge:a']);
  red = false;
  assert.equal(f.invoke(['--steps=merge,debt', '--resume'], { runners }).code, 0);
  assert.deepEqual(f.calls.filter((a) => a[0] === 'merge').map((a) => a.at(-1)), ['a', 'b', 'b']);
  assert.deepEqual(f.seen, ['debt']);
});

test('resume never skips a newly requested lane because an earlier lane list marked merge done', (t) => {
  const f = fixture(t);
  assert.equal(f.invoke(['--lanes=a', '--steps=merge'], { runners: STEP_RUNNERS }).code, 0);
  const before = f.calls.length;
  const r = f.invoke(['--lanes=a,b', '--steps=merge', '--resume'], { runners: STEP_RUNNERS });
  assert.ok(r.code !== 0 || f.calls.slice(before).some((a) => a[0] === 'merge' && a.at(-1) === 'b'),
    'resume reported success without merging the new lane or refusing the changed plan');
});

test('resume never redoes completed work when its state is malformed JSON', (t) => {
  const f = fixture(t);
  f.state(['merge']);
  writeFileSync(join(f.dir, 'build/merge-state.json'), '{"done":["merge"');
  assert.notEqual(f.invoke(['--resume']).code, 0, 'unreadable marks must not silently become an empty plan');
  assert.deepEqual(f.seen, []);
});

test('first red stops every later step and supplies recovery instructions for every step position', (t) => {
  for (const red of STEPS) {
    const f = fixture(t);
    const runners = Object.fromEntries(STEPS.map((s) => [s, () => {
      f.seen.push(s);
      return s === red ? { ok: false, advice: ['repair the fixture and --resume'] } : { ok: true };
    }]));
    assert.equal(f.invoke([], { runners }).stoppedAt, red);
    assert.deepEqual(f.seen, STEPS.slice(0, STEPS.indexOf(red) + 1));
    assert.ok(f.messages.some((s) => s.includes('repair the fixture')));
  }
});

test('first red debt update stops before staging or committing a baseline', () => {
  const calls = [];
  const r = STEP_RUNNERS.debt({ date: '2026-11-10',
    run: (name) => ({ status: name === 'debt-check' ? 0 : 1, out: 'tighten: baseline', log: 'fake.log' }),
    git: (a) => { calls.push(a); return { ok: true, out: '', stdout: '' }; } });
  assert.equal(r.ok, false, 'failed debt-update must not be reported green');
  assert.deepEqual(calls, []);
});

test('non-document conflicts with quoted porcelain paths never get automatic resolution', (t) => {
  let merged = false;
  const f = fixture(t, { reply: (a) => {
    if (a[0] === 'merge') { merged = true; return { status: 1, stdout: '', stderr: 'conflict' }; }
    if (a[0] === 'status' && merged) return { status: 0, stdout: 'UU "project/odd\\tname.gd"\nAA REPORT.md', stderr: '' };
    return null;
  } });
  assert.equal(f.invoke(['--steps=merge'], { runners: STEP_RUNNERS }).stoppedAt, 'merge');
  assert.ok(f.calls.every((a) => !['add', 'commit', 'show'].includes(a[0])));
});

test('date input cannot escape docs/day even when it looks calendar-like', () => {
  for (const date of ['2026-11-10/../../x', '2026-1-10', '2026-11-10 extra']) {
    assert.ok(parseArgs(['--worktree=x', '--lanes=a', `--date=${date}`]).error);
  }
});

test('dry-run never writes or runs steps even with valid-looking impossible calendar dates', (t) => {
  for (const date of ['2026-02-30', '2026-13-01', '2026-00-10', '2025-02-29']) {
    const f = fixture(t);
    f.invoke([`--date=${date}`, '--dry-run'], { runners: STEP_RUNNERS });
    assert.deepEqual(f.seen, []);
    assert.ok(f.calls.every((a) => !['merge', 'commit', 'mv', 'add'].includes(a[0])));
    assert.throws(() => readFileSync(join(f.dir, 'build/merge-state.json')), { code: 'ENOENT' });
  }
});
