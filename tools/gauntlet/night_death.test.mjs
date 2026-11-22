import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { test } from 'node:test';
import { ROOT, readJson } from '../lib/repo.mjs';
import { BATCH_SCHEMA, PROFILES, RUN_SCHEMA } from './contract.mjs';
import { deathChange, deathProfiles } from './death_cycle.mjs';
import { night } from './night.mjs';
import { tableHashes } from './night_batches.mjs';
import { pairNullRuns, pairRuns } from './tune_confirm.mjs';
import { BASELINE, ensureBaseline, git, inventory, TABLES } from './tune_state.mjs';

function save(file, data) {
  mkdirSync(dirname(file), { recursive: true });
  writeFileSync(file, JSON.stringify(data, null, 2) + '\n');
}

function sample(waves, tables = {}, salt = 0) {
  const results = PROFILES.flatMap((profile, i) => Array.from({ length: 8 }, (_, j) => ({
    schema: RUN_SCHEMA, profile, seed: j + 1, controls: 'wheel', waves: [], picks: [], mods: {},
    wave_reached: waves[i], death: { wave: waves[i], by: 'turret_gun' }
  })));
  return { schema: BATCH_SCHEMA, args: { runner: 'gauntlet', seeds: 8, seed0: 1, waves: 30,
    profile: 'all', controls: 'wheel', pick: 'greedy', salt }, git: {}, tables, weapon_refs: {},
    enemy_weapons: {}, survival_tuning: {}, results, runs: results.map(({ seed, profile }) => ({ seed, profile, ok: true })) };
}

test('each profile has its own floor; harm beyond it or an unmeasured profile vetoes a gain', () => {
  const before = sample([9, 15, 20]), neutral = sample([9, 16, 22], {}, 1);
  const settings = { beforeRows: pairRuns(before, before), nullRows: pairNullRuns(before, neutral) };
  const change = { metric: { profile: 'novice' }, profiles: ['novice', 'average'] };
  const decision = (after) => {
    const profiles = deathProfiles(pairRuns(before, after), 'all', settings);
    assert.deepEqual(profiles.map((p) => p.floor), [0, 1, 2]);
    return deathChange(change, profiles, 'point').verdict;
  };
  assert.equal(decision(sample([6, 12, 22])), 'kept');
  assert.equal(decision(sample([6, 12, 23])), 'reverted');
  assert.equal(decision(sample([2, 12, 20])), 'reverted'); // Overshot novice target 6.
  assert.equal(decision(sample([9, 15, 20])), 'noise');
  const missing = sample([6, 12, 20]);
  missing.results = missing.results.filter((r) => r.profile !== 'expert');
  missing.runs = missing.runs.filter((r) => r.profile !== 'expert');
  assert.equal(decision(missing), 'too few pairs');
});

function lane(t) {
  const temp = mkdtempSync(join(tmpdir(), 'gtai-night-death-'));
  t.after(() => rmSync(temp, { recursive: true, force: true }));
  const root = join(temp, 'lane'), tree = join(temp, 'tune');
  const table = TABLES + 'gauntlet.json', knobs = 'tools/gauntlet/knobs.json', schema = 'project/data/schemas/gauntlet.schema.json';
  save(join(root, table), { budget: { per_wave: 20, unit: 10 } });
  save(join(root, knobs), [{ id: 'budget.per_wave', file: table, pointer: '/budget/per_wave',
    kind: 'int', min: 1, max: 100, scale: 'budget.unit' }]);
  save(join(root, schema), { type: 'object' });
  writeFileSync(join(root, '.gitignore'), '/build/\n');
  git(root, 'init', '-b', 'lane');
  git(root, 'config', 'core.autocrlf', 'false');
  git(root, 'config', 'user.name', 'Night');
  git(root, 'config', 'user.email', 'night@example.invalid');
  git(root, 'add', '--', '.gitignore', table, knobs, schema);
  git(root, 'commit', '-m', 'fixture');
  ensureBaseline(root, inventory(root).entries);
  git(root, 'add', '--', BASELINE);
  git(root, 'commit', '-m', 'baseline');
  return { root, tree, table };
}

test('a hand-measured cycle resumes at confirmation and chains its kept after into the next baseline', (t) => {
  const { root, tree, table } = lane(t);
  const dir = join(root, 'evidence/n23-loop/cycle-1');
  const arm = (name) => join(root, 'evidence', name, 'batch.json');
  const before = tableHashes(root);
  const after = tableHashes(root, [{ file: table, pointer: '/budget/per_wave', before: 20, after: 25 }]);
  save(arm('base'), sample([9, 15, 20], before));
  save(arm('null'), sample([9, 16, 22], before, 1));
  save(arm('external-after'), sample([6, 12, 20], after));
  const location = ['--worktree=' + tree, '--branch=n23-tune-1'];
  const args = [...location, '--out=' + dir, '--before=' + arm('base'), '--null=' + arm('null'),
    '--after-from=' + arm('external-after'), '--metric=death', '--profile=all', '--jobs=2'];
  const calls = [];
  let interrupt = true;
  const run = ([script, ...flags], cwd) => {
    assert.equal(cwd, tree);
    assert.ok(!script.endsWith('/batch.mjs'));
    calls.push(flags[0]);
    if (flags[0] === 'confirm' && interrupt) throw new Error('simulated interruption');
    const r = spawnSync(process.execPath, [join(ROOT, script), ...flags], { cwd, encoding: 'utf8' });
    assert.equal(r.status, 0, r.stderr);
  };
  assert.throws(() => night(args, { root, run, log() {} }), /simulated interruption/);
  const plan = readJson(join(dir, 'plan.json'));
  assert.equal(plan.changes.length, 1);
  assert.deepEqual(plan.changes[0].profiles, ['novice', 'average']);
  calls.length = 0;
  interrupt = false;
  night(args, { root, run, log() {} });
  assert.deepEqual(calls, ['confirm', '--batch=' + arm('external-after')]);
  const ledger = readJson(join(dir, 'after/tune-ledger.json'));
  assert.equal(ledger.changes[0].verdict, 'kept');
  assert.deepEqual(ledger.profiles.map((p) => p.floor), [0, 1, 2]);
  assert.equal(readJson(join(tree, table)).budget.per_wave, 25);
  assert.equal(readJson(join(root, table)).budget.per_wave, 20);
  const md = readFileSync(join(dir, 'night.md'), 'utf8');
  assert.equal(md.split('\n')[0], 'cycle 1: kept budget.per_wave 20 -> 25');
  assert.match(md, /novice \| 6 \| 9 \| 9–9 \(9–9\) \| 6 \| 6–6 \(6–6\) \| 0 → 0 \| 0 \(8\)/);
  assert.match(md, /expert \| 20 \| 20 .* 2 \(8\) \| noise/);
  assert.match(md, /novice → average \| 6 \| 8\/8 \(100%\) \| 0 \| separated \| 6/);
  assert.ok(md.includes(ledger.changes[0].commit));
  assert.ok(!existsSync(join(tree, 'night.md')));
  for (const name of ['base', 'null', 'external-after']) assert.deepEqual(readdirSync(dirname(arm(name))), ['batch.json']);
  const lines = [];
  night([...location, '--out=' + dir + '-next', '--before=' + arm('external-after'), '--jobs=2', '--metric=death', '--dry-run'],
    { root, run, log: (line) => lines.push(line) });
  const batches = lines.filter((line) => line.startsWith('node ') && line.includes('/batch.mjs'));
  assert.equal(batches.length, 2);
  assert.ok(batches.every((line) => line.includes('--jobs=2') && line.includes('--profile=all') && line.includes('--waves=30')));
});
