import assert from 'node:assert/strict';
import test from 'node:test';
import { judgeEvidence, kindsFor, parseArgs, worktrees } from './run.mjs';

const SHA = 'a'.repeat(40);
const env = (status, commit = SHA, summary = 'ran') => ({ status, commit, summary });

test('all kinds passing for this commit is a pass', () => {
  const r = judgeEvidence(['lint', 'unit-tests'], () => env('pass'), SHA);
  assert.equal(r.outcome, 'pass');
  assert.equal(r.lines.length, 2);
});

test('a missing result is unverifiable, never a pass', () => {
  const r = judgeEvidence(['lint', 'unit-tests'], (k) => (k === 'lint' ? env('pass') : null), SHA);
  assert.equal(r.outcome, 'unverifiable');
  assert.match(r.lines[1], /no result was written/);
});

test('a result naming another commit is unverifiable: a stale pass cannot count', () => {
  const r = judgeEvidence(['lint'], () => env('pass', 'b'.repeat(40)), SHA);
  assert.equal(r.outcome, 'unverifiable');
  assert.match(r.lines[0], /result is for bbbbbbbb/);
});

test('a failing kind makes the whole gate fail, even with another unverifiable', () => {
  const read = (k) => (k === 'lint' ? env('fail') : k === 'parity' ? null : env('pass'));
  const r = judgeEvidence(['lint', 'parity', 'unit-tests'], read, SHA);
  assert.equal(r.outcome, 'fail');
});

test('no kinds at all is unverifiable', () => {
  assert.equal(judgeEvidence([], () => null, SHA).outcome, 'unverifiable');
});

test('a skipped kind is left out of what must exist', () => {
  const base = { parity: true, selftest: true, bench: false };
  assert.ok(kindsFor(base).includes('parity'));
  assert.ok(!kindsFor({ ...base, parity: false }).includes('parity'));
  assert.ok(!kindsFor(base).includes('bench'));
  assert.ok(kindsFor({ ...base, bench: true }).includes('bench'));
});

test('arguments: an unknown flag is an error, the defaults are the full gate', () => {
  assert.match(parseArgs(['--nope']).error, /bad argument/);
  const o = parseArgs([]);
  assert.deepEqual([o.rev, o.parity, o.bench, o.reels], ['HEAD', true, false, false]);
  assert.equal(parseArgs(['--rev=abc']).rev, 'abc');
});

test('worktrees reads git\'s porcelain list', () => {
  assert.deepEqual(worktrees('worktree C:/a\nHEAD x\nbranch y\n\nworktree C:/b c\nHEAD z\n'), ['C:/a', 'C:/b c']);
});
