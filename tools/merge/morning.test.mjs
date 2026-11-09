import assert from 'node:assert/strict';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { STEPS, STEP_RUNNERS, conflictAdvice, git, laneDocsDir, main, parseArgs, refusal } from './morning.mjs';

test('git(): push and anything off the list is refused before git is even called', () => {
  let called = 0;
  const spawnGit = () => { called += 1; return { status: 0, stdout: '', stderr: '' }; };
  assert.throws(() => git('.', ['push', 'origin', 'main'], spawnGit), /refusing git push/);
  assert.throws(() => git('.', ['checkout', 'main'], spawnGit), /refusing git checkout/);
  assert.throws(() => git('.', ['reset', '--hard'], spawnGit), /refusing git reset/);
  assert.throws(() => git('.', ['branch', '-f', 'main'], spawnGit), /refusing git branch/);
  assert.equal(called, 0);
});

test('parseArgs: a worktree, lanes in order and a date are required', () => {
  assert.match(parseArgs(['--lanes=a', '--date=2026-11-10']).error, /--worktree/);
  assert.match(parseArgs(['--worktree=x', '--date=2026-11-10']).error, /--lanes/);
  assert.match(parseArgs(['--worktree=x', '--lanes=a']).error, /--date/);
  assert.match(parseArgs(['--worktree=x', '--lanes=a', '--date=tomorrow']).error, /--date/);
  assert.match(parseArgs(['--worktree=x', '--lanes=a', '--date=2026-11-10', '--steps=ship']).error, /unknown step ship/);
  assert.deepEqual(parseArgs(['--worktree=x', '--lanes=b,a', '--date=2026-11-10']).lanes, ['b', 'a']);
  assert.deepEqual(parseArgs(['--worktree=x', '--lanes=b', '--date=2026-11-10']).steps, STEPS);
});

const safe = { branch: 'int-day', dirty: '', merging: false, lanes: ['a'], known: ['a', 'int-day', 'main'] };

test('refusal: main, a detached head, a lane, a dirty tree, an unfinished merge and a missing branch', () => {
  assert.equal(refusal(safe), null);
  assert.match(refusal({ ...safe, branch: 'main' }), /never touches it/);
  assert.match(refusal({ ...safe, branch: 'master' }), /never touches it/);
  assert.match(refusal({ ...safe, branch: '' }), /detached/);
  assert.match(refusal({ ...safe, branch: 'a' }), /a lane being merged/);
  assert.match(refusal({ ...safe, dirty: ' M x' }), /not clean/);
  assert.match(refusal({ ...safe, merging: true }), /merge is in progress/);
  assert.match(refusal({ ...safe, lanes: ['nope'] }), /no such branch: nope/);
});

test('the lane docs folder drops the night prefix', () => {
  assert.equal(laneDocsDir('2026-11-10', 'n11-hero'), 'docs/day/2026-11-10/hero');
  assert.equal(laneDocsDir('2026-11-10', 'tools'), 'docs/day/2026-11-10/tools');
});

test('conflict advice names every file with what to do', () => {
  const lines = conflictAdvice('n11-hero', ['tools/debt/baseline.json', 'docs/decisions.md', 'a.gd.uid', 'b.gd']);
  assert.match(lines[0], /merging n11-hero conflicted on 4/);
  assert.match(lines.find((l) => l.includes('baseline.json')), /debt\.mjs --update/);
  assert.match(lines.at(-1), /--resume/);
});

// A fake git for the flow: all verbs ok, a clean tree on int-day with the lanes known.
function fakeGit(overrides = {}) {
  return (cmd, args) => {
    const verb = args[2];
    const r = (stdout, status = 0) => ({ status, stdout, stderr: '' });
    if (overrides[verb]) { const o = overrides[verb](args); if (o) return o; }
    if (verb === 'rev-parse' && args[3] === '--is-inside-work-tree') return r('true');
    if (verb === 'symbolic-ref') return r('int-day');
    if (verb === 'show-ref') return r('x refs/heads/a\ny refs/heads/b\nz refs/heads/int-day');
    if (verb === 'rev-parse' && args.includes('MERGE_HEAD')) return r('', 1);
    if (verb === 'status') return r('');
    if (verb === 'rev-parse') return r('abc123456789');
    if (verb === 'log') return r('the subject');
    return r('');
  };
}

function workspace() {
  const dir = mkdtempSync(join(tmpdir(), 'gtai-morning-'));
  return { dir, done: () => rmSync(dir, { recursive: true, force: true }) };
}

function runners(list, red = null) {
  const seen = [];
  const out = Object.fromEntries(STEPS.map((s) => [s, (ctx) => { seen.push(s); return s === red ? { ok: false, advice: [`RED ${s}`] } : { ok: true }; }]));
  return { out, seen, list };
}

test('main: refuses main with exit 2 before running any step', () => {
  const { dir, done } = workspace();
  const r = runners(STEPS);
  try {
    const res = main([`--worktree=${dir}`, '--lanes=a', '--date=2026-11-10'], {
      err: () => {}, out: () => {}, runners: r.out,
      spawnGit: fakeGit({ 'symbolic-ref': () => ({ status: 0, stdout: 'main', stderr: '' }) }) });
    assert.equal(res.code, 2);
    assert.deepEqual(r.seen, []);
  } finally { done(); }
});

test('main: runs every step in order and says nothing was pushed', () => {
  const { dir, done } = workspace();
  const r = runners(STEPS);
  const lines = [];
  try {
    const res = main([`--worktree=${dir}`, '--lanes=a,b', '--date=2026-11-10'], { out: (l) => lines.push(l), err: () => {}, runners: r.out, spawnGit: fakeGit() });
    assert.equal(res.code, 0);
    assert.deepEqual(r.seen, STEPS);
    assert.match(lines.at(-1), /Nothing was pushed; main was not touched/);
  } finally { done(); }
});

test('main: stops at the first red step, prints what to do, runs nothing after it', () => {
  const { dir, done } = workspace();
  const r = runners(STEPS, 'bake');
  const lines = [];
  try {
    const res = main([`--worktree=${dir}`, '--lanes=a', '--date=2026-11-10'], { out: (l) => lines.push(l), err: () => {}, runners: r.out, spawnGit: fakeGit() });
    assert.equal(res.code, 1);
    assert.equal(res.stoppedAt, 'bake');
    assert.deepEqual(r.seen, ['merge', 'debt', 'native', 'bake']);
    assert.ok(lines.includes('RED bake'));
  } finally { done(); }
});

test('main: --resume skips what is done and continues from the red step', () => {
  const { dir, done } = workspace();
  const first = runners(STEPS, 'bake');
  try {
    main([`--worktree=${dir}`, '--lanes=a', '--date=2026-11-10'], { out: () => {}, err: () => {}, runners: first.out, spawnGit: fakeGit() });
    const second = runners(STEPS);
    const res = main([`--worktree=${dir}`, '--lanes=a', '--date=2026-11-10', '--resume'], { out: () => {}, err: () => {}, runners: second.out, spawnGit: fakeGit() });
    assert.equal(res.code, 0);
    assert.deepEqual(second.seen, ['bake', 'gates', 'reels', 'export']);
  } finally { done(); }
});

test('main: --dry-run touches nothing', () => {
  const { dir, done } = workspace();
  const r = runners(STEPS);
  const lines = [];
  try {
    assert.equal(main([`--worktree=${dir}`, '--lanes=a,b', '--date=2026-11-10', '--dry-run'], { out: (l) => lines.push(l), err: () => {}, runners: r.out, spawnGit: fakeGit() }).code, 0);
    assert.deepEqual(r.seen, []);
    assert.match(lines[0], /a -> b/);
  } finally { done(); }
});

test('main: a --resume cannot run over an unfinished merge', () => {
  const { dir, done } = workspace();
  const r = runners(STEPS);
  const errs = [];
  try {
    const res = main([`--worktree=${dir}`, '--lanes=a', '--date=2026-11-10', '--resume'], { out: () => {}, err: (l) => errs.push(l), runners: r.out,
      spawnGit: fakeGit({ 'rev-parse': (args) => (args.includes('MERGE_HEAD') ? { status: 0, stdout: 'abc', stderr: '' } : null) }) });
    assert.equal(res.code, 2);
    assert.match(errs[0], /still in progress/);
    assert.deepEqual(r.seen, []);
  } finally { done(); }
});

test('a conflict only on the lane docs is resolved with the lane\'s copy and the lane keeps going', () => {
  const { dir, done } = workspace();
  const calls = [];
  const g = (args) => {
    calls.push(args.join(' '));
    if (args[0] === 'merge') return { ok: false, out: 'conflict', stdout: '' };
    if (args[0] === 'status') return { ok: true, out: '', stdout: 'DU JOURNAL.md\nAA REPORT.md' };
    if (args[0] === 'show') return { ok: true, out: 'their text', stdout: 'their text' };
    return { ok: true, out: '', stdout: '' };
  };
  const seen = [];
  try {
    const r = STEP_RUNNERS.merge({ git: g, cwd: dir, lanes: ['lane-x'], date: '2026-11-10', out: (l) => seen.push(l), done: [], mark: () => {} });
    assert.equal(r.ok, true);
    assert.ok(calls.includes('show MERGE_HEAD:JOURNAL.md'));
    assert.ok(calls.includes('add JOURNAL.md'));
    assert.ok(calls.includes('commit --no-edit'));
    assert.match(seen[0], /merged lane-x/);
  } finally { done(); }
});

test('a conflict on anything else still stops for a person, even beside a doc conflict', () => {
  const g = (args) => (args[0] === 'merge' ? { ok: false, out: '', stdout: '' } : { ok: true, out: '', stdout: 'UU JOURNAL.md\nUU project/a.gd' });
  const r = STEP_RUNNERS.merge({ git: g, cwd: 'NOT-A-REAL-TREE', lanes: ['lane-x'], date: '2026-11-10', out: () => {}, done: [], mark: () => {} });
  assert.equal(r.ok, false);
  assert.match(r.advice[0], /conflicted on 2/);
});

function runRecorder(outputs) {
  const calls = [];
  return { calls, run: (name, cmd, args) => { calls.push({ name, cmd, args }); return { status: outputs[name] ?? 0, out: '', log: `${name}.log` }; } };
}

test('debt step: over the baseline with no reason stops and asks for one, with a reason it records it', () => {
  const gitCalls = [];
  const ctx = { cwd: 'NOT-A-REAL-TREE', git: (a) => { gitCalls.push(a[0]); return { ok: true, out: '', stdout: '' }; }, date: '2026-11-10', debtReason: null, out: () => {}, done: [] };
  const red = runRecorder({ 'debt-check': 1 });
  const stopped = STEP_RUNNERS.debt({ ...ctx, run: (n, c, a) => { red.run(n, c, a); return { status: 1, out: 'dev_loc grew', log: 'x' }; } });
  assert.equal(stopped.ok, false);
  assert.match(stopped.advice[1], /--debt-reason/);
  const calls = [];
  const withReason = STEP_RUNNERS.debt({ ...ctx, debtReason: 'night n11 tools', run: (n, c, a) => { calls.push(n); return { status: n === 'debt-check' ? 1 : 0, out: '', log: 'x' }; } });
  assert.equal(withReason.ok, true);
  assert.deepEqual(calls, ['debt-check', 'debt-accept']);
  assert.deepEqual(gitCalls, ['add', 'commit'], 'through the injected git, never the real one');
});

test('the export and gate steps stop on a red and give the next command', () => {
  const ctx = { cwd: 'NOT-A-REAL-TREE', git: () => ({ ok: true, out: '', stdout: '' }), run: () => ({ status: 1, out: '', log: 'log' }), out: () => {} };
  for (const s of ['gates', 'reels', 'export', 'bake']) {
    const r = STEP_RUNNERS[s](ctx);
    assert.equal(r.ok, false, s);
    assert.match(r.advice.join('\n'), /--resume|Fix/, s);
  }
});
