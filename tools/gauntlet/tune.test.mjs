import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { cpSync, existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { test } from 'node:test';
import { canonicalJson } from '../lib/canonical_json.mjs';
import { ROOT, readJson } from '../lib/repo.mjs';
import { BATCH_SCHEMA, RUN_SCHEMA, validateRun } from './contract.mjs';
import { confirmChange, pairRuns } from './tune_confirm.mjs';
import { nightOf } from './tune_git.mjs';
import { propose } from './tune_propose.mjs';
import { BASELINE, clamped, ensureBaseline, git, inventory, TABLES, withLock } from './tune_state.mjs';

const catalog = 'tools/gauntlet/knobs.json';

function write(root, file, data) {
  const path = join(root, file);
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, JSON.stringify(data, null, 2) + '\n');
}

function repository(t, branch = 'fixture') {
  const root = mkdtempSync(join(tmpdir(), 'gauntlet-tune-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  git(root, 'init', '-b', branch);
  git(root, 'config', 'user.name', 'Gauntlet test');
  git(root, 'config', 'user.email', 'gauntlet@example.invalid');
  git(root, 'config', 'core.autocrlf', 'false');
  git(root, 'config', 'core.hooksPath', '.test-no-hooks');
  const files = [catalog];
  for (const table of ['combat', 'enemies', 'gauntlet', 'weapons']) {
    files.push(TABLES + table + '.json', 'project/data/schemas/' + table + '.schema.json');
  }
  for (const file of files) {
    mkdirSync(dirname(join(root, file)), { recursive: true });
    cpSync(join(ROOT, file), join(root, file));
  }
  git(root, 'add', '--', ...files);
  git(root, 'commit', '-m', 'fixture tables');
  return root;
}

test('nightly and first-night bounds intersect in both directions, including integer rounding', () => {
  const k = { kind: 'float', min: 0, max: 1000 };
  assert.equal(clamped(k, 12, 12, 99), 15);
  assert.equal(clamped(k, 10, 10, 0), 8);
  assert.equal(clamped(k, 19, 10, 45), 20);
  assert.equal(clamped(k, 5.5, 10, 1), 5);
  assert.equal(clamped({ ...k, min: 5.4 }, 5.5, 10, 1), 5.4);
  assert.equal(clamped({ ...k, max: 11 }, 10, 10, 99), 11);
  assert.equal(clamped(k, 0, 0, 1), 0);
  k.kind = 'int';
  assert.equal(clamped(k, 12, 12, 11.9), 11);
  assert.equal(clamped(k, 12, 12, 12.1), 13);
  assert.equal(clamped(k, 12, 12, 1), 10);
  assert.equal(clamped(k, 11, 11, 99), 13);
  assert.equal(clamped(k, 2, 2, 9), 2);
});

test('first-night values and provenance survive reruns and additions', (t) => {
  const root = repository(t);
  const save = (items) => withLock(root, () => ensureBaseline(root, new Map(items)));
  const baseline = save([['a', { value: 10 }]]);
  const bytes = readFileSync(join(root, BASELINE));
  const again = save([['a', { value: 12 }]]);
  assert.deepEqual(again, baseline);
  assert.deepEqual(readFileSync(join(root, BASELINE)), bytes);
  const added = save([['a', { value: 12 }], ['b', { value: 4 }]]);
  assert.deepEqual(added, { ...baseline, values: { a: 10, b: 4 } });
});

test('shipped pointers resolve and missing, reordered or pending rows are reported and skipped', (t) => {
  const root = repository(t);
  const rows = readJson(join(root, catalog));
  assert.equal(inventory(root, assert.fail).entries.size, rows.length);
  const a = rows.find((k) => k.id === 'war_machine.hp');
  write(root, catalog, [{ ...a, pointer: '/archetypes/999/hp' },
    { ...a, id: 'new_robot.hp' }, { ...a, id: 'new_robot.damage', pending: true }]);
  const warnings = [];
  assert.equal(inventory(root, (s) => warnings.push(s)).entries.size, 0);
  assert.equal(warnings.length, 3);
  assert.match(warnings[0], /war_machine.hp unresolved.*999/);
  assert.match(warnings[1], /new_robot.hp unresolved/);
  assert.match(warnings[2], /pending/);
});


function cli(root, command, ...args) {
  return spawnSync(process.execPath, [join(ROOT, 'tools/gauntlet/tune.mjs'), command, ...args], { cwd: root, encoding: 'utf8' });
}

function ok(result) {
  assert.equal(result.status, 0, result.stderr + result.stdout);
  return result.stdout;
}

function manifest(results) {
  return { schema: BATCH_SCHEMA, git: { sha: 'fixture' }, args: { runner: 'gauntlet', waves: 10, pick: 'random' },
    weapon_refs: { weapon_pistol: 'pistol' }, results, runs: results.map(({ seed, profile, controls }) => ({
      seed, profile, controls, pick: 'random', ok: true
    })) };
}

function fixtureBatch() {
  const dir = join(ROOT, 'tools/gauntlet/fixtures');
  const runs = readdirSync(dir).filter((n) => n.endsWith('.json')).map((n) => readJson(join(dir, n)));
  return manifest(runs.filter((r) => !validateRun(r)));
}

function robotBatch() {
  const ids = ['shield_robot', 'war_machine', 'sentry_turret'];
  return manifest(Array.from({ length: 8 }, (_, i) => ({
    schema: RUN_SCHEMA, seed: i + 1, profile: 'average', controls: 'wheel', wave_reached: 3, picks: [], mods: {},
    waves: ids.map((id, w) => ({ n: w + 1, seconds: [30, 24, 23][w], enemies: { [id]: 2 } }))
  })));
}

const beforeFile = 'build/before/batch.json', planFile = 'build/before/plan.json', afterFile = 'build/after/batch.json';
const proposeArgs = ['--batch=' + beforeFile, '--out=' + planFile];
const confirmArgs = ['--before=' + beforeFile, '--after=' + afterFile, '--plan=' + planFile];

function prepare(root, batch) {
  write(root, beforeFile, batch);
  ok(cli(root, 'propose', ...proposeArgs));
  git(root, 'add', '--', BASELINE);
  git(root, 'commit', '-m', 'first-night baseline', '--', BASELINE);
  return readJson(join(root, planFile));
}

test('propose uses measured fixture effects, records untunable misses and respects the plan limit', (t) => {
  const root = repository(t), batch = fixtureBatch();
  const state = inventory(root), baseline = ensureBaseline(root, state.entries);
  const plan = propose(batch, state, baseline, { max: 1 });
  assert.equal(plan.changes.length, 1);
  const pistol = plan.changes[0];
  assert.equal(pistol.id, 'weapon.pistol.rof_hz');
  assert.equal(pistol.after, 3.2);
  assert.match(pistol.miss, /weapon_pistol took 4 vs declined 2 waves survived.*CI95 2 to 2.*floor 0.*12 pairs/);
  assert.ok(plan.misses.some((m) => /wave 2 median 22 s over 8 timed runs against 15 s/.test(m.miss)));
  assert.ok(plan.misses.some((m) => /12\/21 deaths/.test(m.miss) && m.reason === 'plan limit'));
  const opposite = structuredClone(batch);
  for (const r of opposite.results) {
    const pick = r.picks.find((p) => p.wave === 1);
    pick.taken = pick.taken === 'weapon_pistol' ? 'ghost_kerf' : 'weapon_pistol';
  }
  assert.ok(propose(opposite, state, baseline).changes.find((c) => c.id === pistol.id).after > pistol.before);
  const expert = manifest(robotBatch().results.map((r) => ({ ...r, profile: 'expert' })));
  const custom = propose(expert, state, baseline, { target: 20, profile: 'expert' });
  assert.deepEqual(custom.changes.map((c) => c.metric.wave), [1]); // 24 s is exactly on the upper boundary.
  assert.match(custom.changes[0].miss, /expert wave 1 median 30 s.*against 20 s/);
});

test('a collapsed profile gap and a dominant enemy weapon each select a measured table knob', (t) => {
  const root = repository(t), state = inventory(root), base = ensureBaseline(root, state.entries);
  const runs = ['novice', 'expert'].flatMap((profile) => robotBatch().results.map((r) => ({
    ...r, profile, death: { wave: r.wave_reached, by: 'turret_gun' }
  })));
  const batch = manifest(runs);
  const plan = propose(batch, state, base);
  assert.match(plan.changes.find((c) => c.metric.type === 'spread').miss, /novice median wave 3, expert 3/);
  assert.equal(plan.changes.find((c) => c.metric.type === 'killer').id, 'enemy_weapon.turret_gun.damage');
  const after = structuredClone(batch);
  for (const r of after.results) {
    if (r.profile === 'expert') r.wave_reached = r.death.wave = 5;
    r.death.by = 'other';
  }
  const paired = pairRuns(batch, after);
  for (const c of plan.changes) assert.equal(confirmChange(paired, c).verdict, 'kept', c.id);
});

test('apply refuses on the wrong branch before reading a plan; the baseline refuses overwrite', (t) => {
  const root = repository(t);
  const result = cli(root, 'apply', '--plan=missing.json');
  assert.equal(result.status, 1);
  assert.equal(result.stderr.trim(), 'tuner applies only on its own branch');
  assert.equal(existsSync(join(root, BASELINE)), false);
  prepare(root, fixtureBatch());
  const bytes = readFileSync(join(root, BASELINE));
  for (const args of [['--batch=' + beforeFile, '--out=' + BASELINE], [...proposeArgs, '--overwrite-baseline']]) {
    assert.match(cli(root, 'propose', ...args).stderr, /baseline is write-once/);
    assert.deepEqual(readFileSync(join(root, BASELINE)), bytes);
  }
});

test('nightly allowance spans midnight and renews at noon UTC', () => {
  const night = (iso) => nightOf(Date.parse(iso + 'Z'));
  assert.equal(night('2026-11-20T23:59:59'), night('2026-11-21T00:00:01'));
  assert.notEqual(night('2026-11-21T11:59:59'), night('2026-11-21T12:00:00'));
});

test('confirmation pairs seed, profile, controls and pick, and respects a measured A/A floor', () => {
  const before = robotBatch();
  const c = { metric: { type: 'wave', profile: 'average', wave: 1, target: 15 } };
  for (const r of before.results) r.waves[0].seconds = r.seed % 2 ? 40 : 50;
  const after = structuredClone(before);
  after.results.reverse();
  for (const r of after.results) r.waves[0].seconds -= 2;
  const result = confirmChange(pairRuns(before, after), c);
  assert.equal(result.pairs, 8);
  assert.equal(result.improvement, 2);
  assert.equal(result.floor, 10);
  assert.equal(result.verdict, 'noise');
  after.runs.forEach((r) => { r.pick = 'greedy'; });
  assert.equal(pairRuns(before, after).length, 0);
  after.runs.forEach((r) => { r.pick = 'random'; r.controls = 'legacy'; });
  after.results.forEach((r) => { r.controls = 'legacy'; });
  assert.equal(pairRuns(before, after).length, 0);
});

test('confirmation keeps the same taker and decliner seeds on both sides of a bonus comparison', () => {
  const before = fixtureBatch(), after = structuredClone(before);
  for (const r of after.results) {
    if (r.picks[0].taken !== 'weapon_pistol') continue;
    r.wave_reached -= 2;
    r.death.wave = r.wave_reached;
    r.waves = r.waves.filter((w) => w.n <= r.wave_reached);
  }
  const change = { metric: { type: 'offer', id: 'weapon_pistol', outcome: 'survived', target: 0 } };
  const result = confirmChange(pairRuns(before, after), change);
  assert.deepEqual([result.pairs, result.measured_before, result.measured_after, result.verdict], [12, 2, 0, 'kept']);
  for (const r of after.results) r.picks[0].taken = 'ghost_kerf';
  const switched = confirmChange(pairRuns(before, after), change);
  assert.equal(switched.pairs, 0);
  assert.equal(switched.verdict, 'noise');
});

test('apply preflights bounds, canonical bytes and schemas for the whole plan before its first commit', (t) => {
  const root = repository(t, 'n22-tune-test');
  const plan = prepare(root, fixtureBatch());
  const apply = () => cli(root, 'apply', '--plan=' + planFile);
  const tampered = structuredClone(plan);
  tampered.changes.at(-1).after *= 2;
  write(root, planFile, tampered);
  assert.match(apply().stderr, /outside tuner bounds/);
  assert.equal(git(root, 'status', '--short', '--', 'project/'), '');
  const wrongPath = structuredClone(plan);
  wrongPath.changes[0].file = 'project/project.godot';
  write(root, planFile, wrongPath);
  assert.match(apply().stderr, /differs from knob catalog/);
  write(root, planFile, plan);
  const file = TABLES + 'combat.json';
  const path = join(root, file), original = readFileSync(path, 'utf8');
  writeFileSync(path, original + '\n');
  assert.match(apply().stderr, /dirty tree/);
  git(root, 'commit', '-m', 'noncanonical fixture', '--', file);
  assert.match(apply().stderr, /round-trip changed bytes/);
  writeFileSync(path, original);
  const schema = 'project/data/schemas/combat.schema.json';
  const doc = readJson(join(root, schema));
  doc.properties.guard.properties.meter_max.maximum = 105;
  write(root, schema, doc);
  git(root, 'commit', '-m', 'tighter fixture schema', '--', file, schema);
  const head = git(root, 'rev-parse', 'HEAD');
  assert.match(apply().stderr, /must be <= 105/);
  assert.equal(git(root, 'rev-parse', 'HEAD'), head);
  assert.equal(git(root, 'status', '--short', '--', 'project/'), '');
});

test('apply commits each knob alone and confirm selectively reverts regression and noise, once', (t) => {
  const root = repository(t, 'n22-tune-robot');
  const before = robotBatch(), after = structuredClone(before);
  const plan = prepare(root, before);
  assert.deepEqual(plan.changes.map((c) => c.id), ['shield_robot.hp', 'war_machine.hp', 'sentry_turret.hp']);
  assert.match(plan.changes[0].miss, /median 30 s over 8 timed runs.*15 s, shield_robot present in 8\/8/);
  const file = TABLES + 'enemies.json';
  const original = readJson(join(root, file));
  // Evidence staged by someone else must stay staged and out of all three table commits.
  const evidence = 'evidence/note.json';
  write(root, evidence, { ready: true });
  git(root, 'add', '--', evidence);
  const start = git(root, 'rev-parse', 'HEAD').trim();
  ok(cli(root, 'apply', '--plan=' + planFile));
  assert.equal(git(root, 'diff', '--cached', '--name-only').trim(), evidence);
  git(root, 'commit', '-m', 'record fixture evidence', '--', evidence);
  const receipts = git(root, 'log', '--reverse', '--format=%H', '--grep=Gauntlet-Plan:', start + '..HEAD').trim().split('\n');
  assert.equal(receipts.length, 3);
  const expected = structuredClone(original);
  for (const [i, c] of plan.changes.entries()) {
    assert.equal(git(root, 'diff-tree', '--no-commit-id', '--name-only', '-r', receipts[i]).trim(), file);
    assert.equal(git(root, 'show', '-s', '--format=%s', receipts[i]).trim(),
      'tune(n22): ' + c.id + ' ' + c.before + ' -> ' + c.after + ': ' + c.miss);
    expected.archetypes.find((r) => c.id === r.id + '.hp').hp = c.after;
    assert.equal(git(root, 'show', receipts[i] + ':' + file), canonicalJson(expected));
  }
  const head = git(root, 'rev-parse', 'HEAD');
  ok(cli(root, 'apply', '--plan=' + planFile));
  assert.equal(git(root, 'rev-parse', 'HEAD'), head);
  const nextPlan = 'build/next-plan.json';
  ok(cli(root, 'propose', '--batch=' + beforeFile, '--out=' + nextPlan));
  assert.equal(readJson(join(root, nextPlan)).changes.length, 0);
  for (const r of after.results) {
    r.waves[0].seconds = 16;
    r.waves[1].seconds = 31;
  }
  write(root, afterFile, after);
  ok(cli(root, 'confirm', ...confirmArgs, '--revert'));
  const ledger = readJson(join(root, 'build/after/tune-ledger.json'));
  assert.deepEqual(ledger.changes.map((c) => c.commit), receipts);
  assert.deepEqual(ledger.changes.map((c) => c.verdict), ['kept', 'reverted', 'noise']);
  assert.deepEqual(ledger.changes.map((c) => c.ci95), [[14, 14], [-7, -7], [0, 0]]);
  assert.ok(ledger.changes.slice(1).every((c) => /^[a-f0-9]{40}$/.test(c.revert_commit)));
  original.archetypes.find((r) => r.id === 'shield_robot').hp = 8;
  assert.equal(readFileSync(join(root, file), 'utf8'), canonicalJson(original));
  const md = readFileSync(join(root, 'build/after/tune-ledger.md'), 'utf8');
  assert.ok(md.includes('shield_robot.hp') && md.includes('14 (14 to 14)') && md.includes(receipts[0]));
  const reverted = git(root, 'rev-parse', 'HEAD');
  ok(cli(root, 'confirm', ...confirmArgs, '--revert'));
  assert.equal(git(root, 'rev-parse', 'HEAD'), reverted);
  assert.equal(git(root, 'status', '--short', '--', 'project/'), '');
});


test('a failed second commit restores that table and retry resumes from the first receipt', (t) => {
  const root = repository(t, 'n22-tune-retry');
  const plan = prepare(root, fixtureBatch());
  const combat = TABLES + 'combat.json';
  const original = readFileSync(join(root, combat));
  git(root, 'config', 'core.hooksPath', '.git/hooks');
  const hook = join(root, '.git/hooks/pre-commit');
  writeFileSync(hook, '#!/bin/sh\ntest -z "$(git diff --cached --name-only -- project/data/tables/combat.json)"\n', { mode: 0o755 });
  assert.equal(cli(root, 'apply', '--plan=' + planFile).status, 1);
  assert.deepEqual(readFileSync(join(root, combat)), original);
  assert.equal(git(root, 'status', '--short', '--', 'project/'), '');
  const changes = () => git(root, 'log', '--format=%s', '--grep=Gauntlet-Plan:').trim().split('\n');
  assert.equal(changes().length, 1);
  rmSync(hook);
  ok(cli(root, 'apply', '--plan=' + planFile));
  assert.equal(changes().length, 2);
  // A fresh plan with legal bounds and tonight's current value still has no second allowance.
  const next = structuredClone(plan);
  const c = next.changes[0];
  next.changes = [{ ...c, before: c.after, after: c.before }];
  write(root, 'build/again.json', next);
  assert.match(cli(root, 'apply', '--plan=build/again.json').stderr, /already tuned this night/);
});

test('a selective Git revert preserves a later kept edit on the adjacent budget line', (t) => {
  const root = repository(t, 'n22-tune-adjacent');
  const file = TABLES + 'gauntlet.json';
  const table = readJson(join(root, file));
  table.budget = { base: 10, per_wave: 10 };
  write(root, file, table);
  git(root, 'commit', '-m', 'fixture with adjustable integer budget', '--', file);
  const before = robotBatch();
  for (const r of before.results) {
    r.wave_reached = 2;
    r.waves = r.waves.slice(0, 2);
    for (const wave of r.waves) wave.enemies = { patrol_cop: 1 };
  }
  const plan = prepare(root, before);
  assert.deepEqual(plan.changes.map((c) => c.id), ['budget.base', 'budget.per_wave']);
  ok(cli(root, 'apply', '--plan=' + planFile));
  const after = structuredClone(before);
  for (const r of after.results) r.waves[1].seconds = 15;
  write(root, afterFile, after);
  ok(cli(root, 'confirm', ...confirmArgs, '--revert'));
  assert.deepEqual(readJson(join(root, file)).budget, { base: 10, per_wave: 8 });
  const ledger = readJson(join(root, 'build/after/tune-ledger.json'));
  assert.equal(ledger.changes[0].revert_commit, git(root, 'rev-parse', 'HEAD').trim());
  assert.equal(ledger.changes[1].verdict, 'kept');
});


test('a vanished pointer is reported and skipped while another planned knob still applies', (t) => {
  const root = repository(t, 'n22-tune-missing');
  const plan = prepare(root, fixtureBatch());
  const rows = readJson(join(root, catalog));
  rows.find((k) => k.id === 'weapon.pistol.rof_hz').pointer = '/weapons/999/rof_hz';
  write(root, catalog, rows);
  git(root, 'commit', '-m', 'unresolved fixture pointer', '--', catalog);
  const result = cli(root, 'apply', '--plan=' + planFile);
  ok(result);
  assert.match(result.stderr, /weapon\.pistol\.rof_hz unresolved.*skipped/);
  assert.equal(readJson(join(root, TABLES + 'weapons.json')).weapons[0].rof_hz, 4);
  assert.equal(readJson(join(root, TABLES + 'combat.json')).guard.meter_max, plan.changes[1].after);
  // The confirm input and the ledger beside it can live outside the ignored build directory.
  const after = 'night-output/after.json';
  write(root, after, fixtureBatch());
  ok(cli(root, 'confirm', '--before=' + beforeFile, '--after=' + after, '--plan=' + planFile, '--revert'));
  const ledger = readJson(join(root, 'night-output/tune-ledger.json'));
  assert.equal(ledger.changes[0].commit, null);
  assert.ok(ledger.changes[1].revert_commit);
  assert.equal(readJson(join(root, TABLES + 'combat.json')).guard.meter_max, plan.changes[1].before);
});
