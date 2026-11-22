import assert from 'node:assert/strict';
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { test } from 'node:test';
import { parseNight, recipe } from './night_args.mjs';
import { checkAfterPlan, checkInputs, tableHashes } from './night_batches.mjs';
import { BATCH_SCHEMA, RUN_SCHEMA } from './contract.mjs';
import { PLAN_SCHEMA } from './tune_propose.mjs';
import { digest, git, TABLES } from './tune_state.mjs';

function save(path, data) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, JSON.stringify(data, null, 2) + '\n');
}

function fixture(t) {
  const tmp = mkdtempSync(join(tmpdir(), 'gtai-reuse-test-'));
  t.after(() => rmSync(tmp, { recursive: true, force: true }));
  const root = join(tmp, 'lane'), tree = join(tmp, 'tune');
  const table = TABLES + 'gauntlet.json';
  save(join(tree, table), { budget: { base: 20 } });
  git(tree, 'init', '-b', 'n23-tune-1');
  git(tree, '-c', 'user.name=test', '-c', 'user.email=test@example.invalid', 'commit', '--allow-empty', '-m', 'fixture');
  const results = [3, 4].map((seed) => ({ schema: RUN_SCHEMA, seed, profile: 'average',
    controls: 'wheel', wave_reached: 12, mods: {}, waves: [], picks: [] }));
  const batch = { args: { seed0: 3, seeds: 2, profile: 'average', controls: 'wheel', pick: 'greedy',
    runner: 'gauntlet', salt: 0, waves: 12 }, tables: tableHashes(tree), git: {}, schema: BATCH_SCHEMA,
    enemy_weapons: {}, survival_tuning: {}, results, runs: results.map(({ seed, profile }) => ({ seed, profile, ok: true })) };
  const file = (arm) => join(root, 'evidence', arm, 'batch.json');
  save(file('base'), batch);
  const neutral = structuredClone(batch);
  neutral.args.salt = 1;
  save(file('neutral'), neutral);
  const args = ['--worktree=' + tree, '--branch=n23-tune-1', '--out=' + join(root, 'evidence/n23-loop/cycle'),
    '--before=' + file('base'), '--null=' + file('neutral')];
  return { args, root, tree, batch, neutral, file, table };
}

test('imported baseline determines seed range, policy and limit for the remaining batch', (t) => {
  const { args, root, tree, file } = fixture(t);
  const job = parseNight(args, root);
  checkInputs(tree, job);
  const steps = recipe(job), batches = steps.filter(([s]) => s.endsWith('/batch.mjs'));
  assert.equal(batches.length, 1);
  assert.ok(['--seed0=3', '--waves=12', '--seeds=2'].every((s) => batches[0].includes(s)));
  assert.ok(steps.flat().includes('--before=' + file('base')));
  assert.ok(steps.flat().includes('--out=' + join(job.dir, 'before')));
  assert.throws(() => parseNight([...args, '--null=' + join(root, 'foreign.json')], root), /lane evidence/);
  assert.throws(() => checkInputs(tree, parseNight([...args, '--waves=11'], root)), /waves/);
});

test('refuse stale tables and nulls with partial, extra or different seeds, profiles, controls or picks', (t) => {
  const { args, root, tree, batch, neutral, file } = fixture(t);
  const job = parseNight(args, root);
  for (const mutate of [
    (b) => { b.results.pop(); b.runs.pop(); },
    (b) => { b.results[0].seed = b.runs[0].seed = 1; },
    (b) => { b.results[0].profile = b.runs[0].profile = 'expert'; },
    (b) => { b.results[0].controls = 'legacy'; },
    (b) => { b.runs[0].pick = 'random'; },
    (b) => { b.args.seeds++; },
    (b) => { b.args.salt = 0; },
    (b) => { b.tables = {}; }
  ]) {
    const altered = structuredClone(neutral);
    mutate(altered);
    save(file('neutral'), altered);
    assert.throws(() => checkInputs(tree, job));
  }
  save(file('neutral'), neutral);
  save(file('base'), { ...batch, tables: {} });
  assert.throws(() => checkInputs(tree, job), /before batch table hashes/);
});

test('external after must reproduce the exact planned bytes before apply; sources remain read-only', (t) => {
  const { args, root, tree, batch, file, table } = fixture(t);
  save(file('after'), batch);
  const job = parseNight([...args, '--after-from=' + file('after')], root);
  const change = { id: 'budget.base', file: table, pointer: '/budget/base', before: 20, after: 25,
    baseline: 20, metric: { type: 'death', profile: 'average', target: 12 }, miss: 'late death' };
  const plan = { schema: PLAN_SCHEMA, max: 1, changes: [change], batch_sha256: digest(readFileSync(file('base'))) };
  save(job.plan, plan);
  assert.throws(() => checkAfterPlan(tree, job), /after batch table hashes/);
  save(file('after'), { ...batch, tables: tableHashes(tree, [change]) });
  assert.equal(checkAfterPlan(tree, job), false);
  assert.equal(JSON.parse(readFileSync(join(tree, table))).budget.base, 20);
  const steps = recipe(job);
  assert.ok(!steps.some(([s]) => s.endsWith('/batch.mjs')));
  assert.ok(steps.flat().includes('--ledger-dir=' + join(job.dir, 'after')));
});
