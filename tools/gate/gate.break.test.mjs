import assert from 'node:assert/strict';
import test from 'node:test';
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, relative } from 'node:path';
import { changedFromPorcelain, softCapIssues, verdictOf } from './quick.mjs';
import { judgeEvidence, parseArgs } from './run.mjs';
import { assertRemovable, markerOf, revParse } from '../lib/snapshot.mjs';

// Reviewed: Codex's table fed the plain porcelain format. quick.mjs now asks git for `--porcelain -z`,
// where a path is never quoted or escaped, so the quoting cases became impossible input and were dropped.
for (const [name, records, expected] of [
  ['ordinary spaces', [' M project/a b.gd'], ['project/a b.gd']],
  ['literal Unicode', [' M project/žluťoučký.gd'], ['project/žluťoučký.gd']],
  ['a quote in a filename', [' M project/a"b.gd'], ['project/a"b.gd']],
  ['rename destination with spaces', ['R  project/new name.gd', 'project/old name.gd'], ['project/new name.gd']],
  ['rename from a non-game path', ['R  project/new.gd', 'elsewhere/old.gd'], ['project/new.gd']],
  ['rename out of the game', ['R  elsewhere/new.gd', 'project/old.gd'], []],
  ['arrow inside an ordinary filename', [' M project/a -> b.gd'], ['project/a -> b.gd']],
  ['excluded and deleted files', [' D project/dead.gd', 'D  project/staged.gd', ' M project/addons/x.gd', ' M tools/x.gd'], []],
]) {
  test(`changed-file coverage: ${name} must not silently omit or rename the file to check`, () => {
    assert.deepEqual(new Set(changedFromPorcelain(`${records.join('\0')}\0`)), new Set(expected));
  });
}

test('soft cap boundary: only crossing from at most 200 to over 200 produces an issue', () => {
  for (const [before, lines, expected] of [[200, 201, 1], [0, 201, 1], [199, 200, 0],
    [201, 202, 0], [300, 100, 0], [200, 200, 0]]) {
    assert.equal(softCapIssues([{ path: 'project/a.gd', before, lines }]).length, expected);
  }
});
test('soft cap coverage: one grandfathered file cannot hide a newly oversized neighbor', () => {
  assert.equal(softCapIssues([{ path: 'old', before: 250, lines: 260 },
    { path: 'new', before: 0, lines: 201 }]).length, 1);
});
for (const result of [
  { missing: true, out: '' }, { ok: false, status: 1, out: '' },
  { ok: false, status: null, out: 'terminated' },
  { ok: false, status: 127, out: 'command not found' },
]) {
  test(`checker honesty: unobserved checker ${JSON.stringify(result)} is unverifiable`, () => {
    const unknown = [];
    assert.deepEqual(verdictOf('gdlint', result, unknown), []);
    assert.ok(unknown.length > 0);
  });
}
test('checker honesty: diagnosed errors are failures while unrelated chatter does not manufacture a diagnosis', () => {
  const unknown = [];
  assert.equal(verdictOf('gdlint', { ok: false, status: 1,
    out: 'banner\nproject/é space.gd:12: Error: violation\nfooter' }, unknown).length, 1);
  assert.equal(unknown.length, 0);
  assert.deepEqual(verdictOf('gdformat', { ok: false, status: 1,
    out: 'would reformat project/a.gd' }, unknown), ['would reformat project/a.gd']);
  assert.deepEqual(verdictOf('gdlint', { ok: true, status: 0, out: '' }, unknown), []);
});

const SHA = 'a'.repeat(40);
const envelope = (status = 'pass', commit = SHA) => ({ status, commit, summary: 'fixture' });
test('snapshot gate honesty: every required kind must exist and name the full exact commit', () => {
  for (const foreign of [null, {}, envelope('pass', 'a'.repeat(12)), envelope('pass', 'b'.repeat(40))]) {
    const result = judgeEvidence(['lint', 'unit-tests'], (kind) => kind === 'lint' ? envelope() : foreign, SHA);
    assert.equal(result.outcome, 'unverifiable');
  }
});
test('snapshot gate aggregation: a known failure dominates missing evidence in either order', () => {
  for (const kinds of [['lint', 'unit-tests'], ['unit-tests', 'lint']]) {
    assert.equal(judgeEvidence(kinds, (kind) => kind === 'lint' ? envelope('fail') : null, SHA).outcome, 'fail');
  }
  assert.equal(judgeEvidence([], () => envelope(), SHA).outcome, 'unverifiable');
});
// The evidence schema permits pass/fail only, so do not require a particular non-pass
// classification for unsupported statuses, despite the gate's own three-valued output.
test('snapshot gate honesty: unsupported or missing evidence status cannot become a pass', () => {
  for (const status of ['unverifiable', 'PASS', '', null, undefined]) {
    const env = { ...envelope(), status };
    assert.notEqual(judgeEvidence(['lint'], () => env, SHA).outcome, 'pass');
  }
});
test('snapshot gate fixture control: all required observed passes for the commit can pass', () => {
  assert.equal(judgeEvidence(['lint', 'unit-tests'], () => envelope(), SHA).outcome, 'pass');
});
test('gate argument refusal: unknown flags and missing values do not start a snapshot', () => {
  for (const argv of [['--unknown'], ['--rev='], ['--timeout=no'], ['--timeout=-1'], ['--bench=yes'], ['HEAD']]) {
    assert.ok(parseArgs(argv).error, JSON.stringify(argv));
  }
});
test('gate arguments: skip switches are explicit and revision text stays a single value', () => {
  const result = parseArgs(['--rev=branch with spaces', '--no-parity', '--no-selftest', '--bench', '--reels', '--timeout=1']);
  assert.equal(result.rev, 'branch with spaces');
  assert.deepEqual([result.parity, result.selftest, result.bench, result.reels, result.timeoutMin],
    [false, false, true, true, 1]);
});

function sandbox(t) {
  const root = mkdtempSync(join(tmpdir(), 'gtai-snapshot-break-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  const base = join(root, 'temp-base');
  const inside = join(base, 'snapshot');
  const outside = join(root, 'outside');
  mkdirSync(inside, { recursive: true });
  mkdirSync(outside);
  return { root, base, inside, outside };
}
test('snapshot removal safety: a marker cannot authorize a directory outside the temp base', (t) => {
  const { base, outside } = sandbox(t);
  writeFileSync(markerOf(outside), 'fixture');
  assert.throws(() => assertRemovable(outside, base));
});
test('snapshot removal safety: the temp base itself is forbidden even with a marker', (t) => {
  const { base } = sandbox(t);
  writeFileSync(markerOf(base), 'fixture');
  assert.throws(() => assertRemovable(base, base));
});
test('snapshot removal safety: an existing descendant without a marker is forbidden', (t) => {
  const { base, inside } = sandbox(t);
  assert.throws(() => assertRemovable(inside, base));
});
test('snapshot removal safety: relative spelling cannot escape the canonical temp base', (t) => {
  const { base, outside } = sandbox(t);
  writeFileSync(markerOf(outside), 'fixture');
  assert.throws(() => assertRemovable(relative(process.cwd(), outside), base));
  assert.throws(() => assertRemovable(join(base, '..', 'outside'), base));
});
test('snapshot removal safety control: a marked descendant is allowed without removing anything', (t) => {
  const { base, inside } = sandbox(t);
  writeFileSync(markerOf(inside), 'fixture');
  assert.doesNotThrow(() => assertRemovable(inside, base));
  assert.doesNotThrow(() => assertRemovable(relative(process.cwd(), inside), base));
});
test('snapshot revision safety: bad revisions and invalid roots return null without a worktree', (t) => {
  const { root } = sandbox(t); // Deliberately not a repository; no git init or worktree commands.
  for (const rev of ['', '--help', 'missing-ref', 'HEAD\0bad', undefined]) {
    assert.equal(revParse(root, rev), null);
  }
  assert.equal(revParse(join(root, 'missing'), 'HEAD'), null);
});
