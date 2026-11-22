import assert from 'node:assert/strict';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { test } from 'node:test';
import { runAblation } from './ablate.mjs';
import { parseAblation } from './ablate_args.mjs';
import { night } from './night.mjs';
import { PLAN_SCHEMA } from './tune_propose.mjs';
import { git } from './tune_state.mjs';

// A Node-only batch records what the detached tree actually contains.
function batchScript(version) {
  return `import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
const out = process.argv.find((arg) => arg.startsWith('--out=')).slice(6);
mkdirSync(out, { recursive: true });
const rate = JSON.parse(readFileSync('table.json')).rate;
writeFileSync(join(out, 'batch.json'), JSON.stringify({ version: ${version}, rate, results: [], runs: [] }));
`;
}

function repository(t) {
  const temp = mkdtempSync(join(tmpdir(), 'gauntlet-revision-test-'));
  t.after(() => rmSync(temp, { recursive: true, force: true }));
  const root = join(temp, 'lane'), path = join(temp, 'arm'), out = join(temp, 'output');
  const file = 'tools/gauntlet/batch.mjs';
  mkdirSync(join(root, 'tools/gauntlet'), { recursive: true });
  git(root, 'init', '-b', 'lane');
  git(root, 'config', 'user.name', 'Revision test');
  git(root, 'config', 'user.email', 'test@example.invalid');
  writeFileSync(join(root, 'table.json'), '{"rate":10}');
  writeFileSync(join(root, file), batchScript(1));
  git(root, 'add', '--', file, 'table.json');
  git(root, 'commit', '-m', 'before');
  const before = git(root, 'rev-parse', 'HEAD').trim();
  writeFileSync(join(root, file), batchScript(2));
  git(root, 'commit', '-m', 'lane moved', '--', file);
  const flags = ['--name=test', '--set=table.json#/rate=8', '--', '--profile=average',
    '--pick=greedy', '--seeds=1', '--out=' + out];
  return { root, path, out, before, flags };
}

test('a short commit SHA pins batch code, edits and receipt after lane HEAD moves', (t) => {
  const { root, path, out, before, flags } = repository(t);
  for (const [rev, version, sha] of [[before.slice(0, 9), 1, before],
    [undefined, 2, git(root, 'rev-parse', 'HEAD').trim()]]) {
    const opts = parseAblation(rev ? ['--rev=' + rev, ...flags] : flags, root);
    assert.equal(opts.rev, rev ? sha : undefined);
    assert.ok(!opts.batchArgs.some((a) => a.startsWith('--rev')));
    runAblation(opts, { root, path });
    const read = (name) => JSON.parse(readFileSync(join(out, name), 'utf8'));
    const receipt = read('ablation.json');
    assert.equal(receipt.head, sha);
    assert.deepEqual(receipt.edits, [{ file: 'table.json', pointer: '/rate', value: 8, before: 10 }]);
    assert.deepEqual([read('batch.json').version, read('batch.json').rate], [version, 8]);
    assert.equal(existsSync(path), false);
    assert.equal(readFileSync(join(root, 'table.json'), 'utf8'), '{"rate":10}');
  }
});

test('ablation and night refuse refs, unknown SHAs and non-commit objects before creating a worktree', (t) => {
  const { root, path, flags } = repository(t);
  git(root, 'tag', '-a', 'tagged', '-m', 'annotated');
  const nightOut = join(root, 'evidence/n23-loop/test');
  for (const rev of ['', 'HEAD', 'HEAD~1', 'lane', '--all', '0'.repeat(40),
    ...['HEAD^{tree}', 'HEAD:table.json', 'tagged'].map((ref) => git(root, 'rev-parse', ref).trim())]) {
    assert.throws(() => parseAblation(['--rev=' + rev, ...flags], root), /--rev.*commit SHA/);
    assert.throws(() => night(['--rev=' + rev, '--dry-run', '--worktree=' + path,
      '--branch=n23-tune-test', '--seeds=1', '--out=' + nightOut], { root }), /--rev.*commit SHA/);
  }
  assert.equal(existsSync(path), false);
  assert.equal(existsSync(nightOut), false);
});

test('a pinned night forwards one full SHA to all three arms and the plan only to the after arm', (t) => {
  const { root, path, before } = repository(t);
  const out = join(root, 'evidence/n23-loop/pinned'), logs = [];
  night(['--rev=' + before.slice(0, 9), '--dry-run', '--worktree=' + path,
    '--branch=n23-tune-pinned', '--seeds=1', '--out=' + out], { root, log: (line) => logs.push(line) });
  const arms = logs.filter((line) => line.includes('ablate.mjs'));
  assert.equal(arms.length, 3);
  assert.ok(arms.every((line) => line.includes('--rev=' + before) && line.includes(' -- ')));
  assert.ok(arms[1].includes('--salt=1'));
  assert.ok(!arms[0].includes('--plan=') && !arms[1].includes('--plan='));
  assert.ok(arms[2].includes('--name=after') && arms[2].includes('--plan=' + join(out, 'plan.json')));
  const members = [['repair_per_s', 10, 8], ['repair_delay_s', 3, 3.75]].map(([key, value, after]) => ({
    id: 'rivet.' + key, file: 'table.json', pointer: '/rivet/' + key, before: value, after, baseline: value
  }));
  mkdirSync(out, { recursive: true });
  const plan = join(out, 'plan.json');
  writeFileSync(plan, JSON.stringify({ schema: PLAN_SCHEMA, max: 1, batch_sha256: '0'.repeat(64),
    changes: [{ id: 'rivet_repair', members, factor: 1.25, miss: 'late death', metric: { type: 'death', profile: 'average', target: 12 } }] }));
  const options = parseAblation(['--name=after', '--rev=' + before, '--plan=' + plan, '--',
    '--profile=average', '--pick=greedy', '--seeds=1', '--out=' + out], root);
  assert.deepEqual(options.edits, members.map(({ file, pointer, after }) => ({ file, pointer, value: after })));
});
