import assert from 'node:assert/strict';
import { mkdirSync, mkdtempSync, rmSync, utimesSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { etaLine, judgeEvidence, kindsFor, parseArgs, reelSecs } from './run.mjs';

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

test('--reels=<views> runs only those views (a partial check); all three or plain --reels is the full reel gate', () => {
  assert.deepEqual([parseArgs(['--reels=combo']).reels, parseArgs(['--reels=combo']).reelViews], [true, ['combo']]);
  assert.deepEqual(parseArgs(['--reels=combo,top']).reelViews, ['top', 'combo'], 'run in the gate order');
  assert.equal(parseArgs(['--reels=combo,tilt70,top']).reelViews, null, 'all three = the full gate');
  assert.equal(parseArgs(['--reels']).reelViews, null);
  assert.match(parseArgs(['--reels=side']).error, /--reels takes top, tilt70, combo, not side/);
});

test('reel timings come from run_reels progress lines; the ETA reads the newest gate.json that kept one (n16 s5)', () => {
  const log = ['run_reels: [1/3] top OK, 319 s; log x', 'run_reels: [2/3] tilt70 OK, 745 s; log y', 'run_reels: [3/3] combo FAIL, 310 s; log z', ''].join('\n');
  assert.deepEqual(reelSecs(log), { top: 319, tilt70: 745, combo: 310 });
  assert.deepEqual(reelSecs(''), {});
  const dir = mkdtempSync(join(tmpdir(), 'gtai-gate-eta-'));
  try {
    assert.equal(etaLine(join(dir, 'none')), null);
    const put = (name, body, age) => {
      mkdirSync(join(dir, name));
      const f = join(dir, name, 'gate.json');
      writeFileSync(f, JSON.stringify(body));
      const t = Date.now() / 1000 - age;
      utimesSync(f, t, t);
    };
    put('old', { sha: 'b'.repeat(40), timing: { evidence_s: 60, reels: {} } }, 300);
    put('untimed', { sha: 'c'.repeat(40) }, 10);
    assert.equal(etaLine(dir), 'gate: the last gate here (bbbbbbbb) took evidence 1.0 min, no reels', 'an untimed (older kit) gate is skipped');
    put('new', { sha: 'd'.repeat(40), timing: { evidence_s: 540, reels: { top: 319, tilt70: 745, combo: 310 } } }, 100);
    assert.equal(etaLine(dir), 'gate: the last gate here (dddddddd) took evidence 9.0 min + reels 22.9 min (top 319 s, tilt70 745 s, combo 310 s)');
  } finally { rmSync(dir, { recursive: true, force: true }); }
});
