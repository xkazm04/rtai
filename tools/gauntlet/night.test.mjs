import assert from 'node:assert/strict';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { test } from 'node:test';
import { ROOT } from '../lib/repo.mjs';
import { night } from './night.mjs';

function setup(t) {
  mkdirSync(join(ROOT, 'build'), { recursive: true });
  const root = mkdtempSync(join(ROOT, 'build/night-test-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  const dir = join(root, 'night output'), calls = [], lines = [];
  const io = { root, run: (args) => calls.push(args), branch: () => 'n22-tune-test', log: (line) => lines.push(line) };
  return { root, dir, calls, lines, io, args: ['--seeds=3', '--out=' + dir] };
}

test('dry run previews the full conditional recipe without writes or a runner', (t) => {
  const { dir, io, args, calls, lines } = setup(t);
  night([...args, '--dry-run'], io);
  assert.equal(calls.length, 0);
  assert.equal(existsSync(dir), false);
  assert.equal(lines.filter((s) => s.startsWith('node ')).length, 8);
  assert.match(lines[0], /--seeds=3 --profile=average --pick=greedy --controls=wheel.*'--out=night output\/before'/);
  assert.match(lines[1], /null'.*--salt=1/);
  assert.match(lines[4], /n22-tune\*/);
  assert.match(lines.at(-1), /night\.md/);
  for (const bad of ['--seeds=0', '--profile=unknown', '--pick=x', '--controls=x', '--jobs=2', '--floor-mode=unknown'])
    assert.throws(() => night([...args, bad, '--dry-run'], io));
});

test('an ordinary branch finishes its measure, report and proposal then stops', (t) => {
  const { dir, io, args, calls, lines } = setup(t);
  night(args, { ...io, branch: () => 'n22-loop' });
  assert.deepEqual(calls.map((cmd) => cmd[0]), ['tools/gauntlet/batch.mjs', 'tools/gauntlet/batch.mjs',
    'tools/gauntlet/report.mjs', 'tools/gauntlet/tune.mjs']);
  assert.equal(calls[3][1], 'propose');
  assert.match(lines.at(-1), /Stopped after propose on n22-loop/);
  assert.equal(existsSync(join(dir, 'night.md')), false);
});

test('the tune branch repeats the seed recipe, reverts, reports against the baseline and summarizes receipts', (t) => {
  const { dir, io, args, calls } = setup(t);
  const run = (cmd) => {
    calls.push(cmd);
    if (cmd[1] !== 'confirm') return;
    const change = { id: 'war_machine.hp', before: 60, after: 48, baseline: 60, miss: 'wave 10 median 29 s',
      pairs: 12, measured_before: 29, measured_after: 22, improvement: 7, ci95: [4, 9], floor: 2, aa_pairs: 6,
      commit: 'apply-a', revert_commit: null, verdict: 'kept' };
    const changes = [change, { ...change, id: 'robot_gunner.hp', verdict: 'too few pairs', aa_pairs: 4, floor: null, commit: 'apply-b', revert_commit: 'undo-b' },
      { ...change, id: 'shield_robot.hp', commit: null }];
    mkdirSync(join(dir, 'after'));
    writeFileSync(join(dir, 'after/tune-ledger.json'), JSON.stringify({ matched_runs: 12, before_runs: 12, after_runs: 12, changes }));
  };
  night(['--seeds=12', '--out=' + dir, '--profile=expert', '--pick=random', '--controls=legacy'], { ...io, run });
  assert.equal(calls.length, 8);
  assert.deepEqual(calls[0].slice(0, -1), calls[1].slice(0, -2));
  assert.equal(calls[1].at(-1), '--salt=1');
  assert.deepEqual(calls[0].slice(0, -1), calls[5].slice(0, -1));
  assert.ok(calls[3].includes('--profile=expert'));
  assert.equal(calls[4][1], 'apply');
  assert.ok(calls[6].includes('--revert') && calls[6].includes('--floor-mode=null-salt'));
  assert.ok(calls[6].includes('--null=night output/null/batch.json'));
  assert.ok(calls[7].includes('--baseline=night output/before/batch.json'));
  const md = readFileSync(join(dir, 'night.md'), 'utf8');
  assert.match(md, /Kept \| war_machine.hp \| 60 \| 48 \| 60 \|.*7 \(4 to 9\).*apply-a/);
  assert.match(md, /Reverted \| robot_gunner.hp.*too few pairs.*apply-b \| undo-b/);
  assert.match(md, /Skipped \| shield_robot.hp/);
  for (const path of ['before/batch.json', 'after/batch.json', 'plan.json', 'after/tune-ledger.md'])
    assert.ok(md.includes('](' + path + ')'));
  assert.throws(() => night(args, io), /output must be empty/);
  assert.equal(readFileSync(join(dir, 'night.md'), 'utf8'), md);
});

test('a failed confirm batch stops before revert and preserves evidence for recovery', (t) => {
  const { root, dir, io, args, calls } = setup(t);
  const run = (cmd) => {
    calls.push(cmd);
    if (calls.length === 1) writeFileSync(join(dir, 'record'), 'before evidence');
    if (calls.length === 6) throw new Error('confirm batch failed');
  };
  assert.throws(() => night(args, { ...io, run }), /confirm batch failed/);
  assert.equal(calls.length, 6);
  assert.equal(readFileSync(join(dir, 'record'), 'utf8'), 'before evidence');
  assert.equal(existsSync(join(dir, 'night.md')), false);
  assert.equal(existsSync(join(root, 'build/gauntlet/night.lock')), false);
});
