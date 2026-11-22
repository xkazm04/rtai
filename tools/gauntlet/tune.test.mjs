import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { cpSync, existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { test } from 'node:test';
import { canonicalJson } from '../lib/canonical_json.mjs';
import { ROOT, readJson } from '../lib/repo.mjs';
import { BATCH_SCHEMA, RUN_SCHEMA, validateRun } from './contract.mjs';
import { night } from './night.mjs';
import { confirmChange, pairNullRuns, pairRuns, verdictFor } from './tune_confirm.mjs';
import { knobStep, occupied } from './tune_groups.mjs';
import { nightOf } from './tune_git.mjs';
import { propose } from './tune_propose.mjs';
import { BASELINE, baselineValue, budgetUnit, clamped, digest, ensureBaseline, git, inventory, TABLES, withLock } from './tune_state.mjs';

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
  assert.equal(clamped(k, 12, 12, 11.9), 12);
  assert.equal(clamped(k, 12, 12, 12.1), 12);
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

test('the catalog fails on an unresolved pointer or mismatched row id', (t) => {
  const root = repository(t);
  const rows = readJson(join(root, catalog));
  assert.equal(inventory(root).entries.size, rows.length);
  const a = rows.find((k) => k.id === 'war_machine.hp');
  for (const invalid of [{ ...a, pointer: '/archetypes/999/hp' }, { ...a, id: 'new_robot.hp' }]) {
    write(root, catalog, [invalid]);
    assert.throws(() => inventory(root), /unresolved/);
  }
});

test('budget units preserve first-night tier bounds and round steps to the nearest table integer', (t) => {
  const root = repository(t);
  const file = TABLES + 'gauntlet.json', table = readJson(join(root, file));
  for (const unit of [1, 10, 4]) {
    table.budget = { base: 2 * unit, per_wave: 2 * unit };
    if (unit !== 1) table.budget.unit = unit;
    write(root, file, table);
    const { entries } = inventory(root), entry = entries.get('budget.per_wave');
    const baseline = ensureBaseline(root, entries);
    assert.equal(budgetUnit(table), unit);
    assert.equal(baseline.values['budget.per_wave'], 2);
    assert.equal(baselineValue(entry, baseline), 2 * unit);
    assert.equal(knobStep('budget.per_wave', 1.01, entries, baseline), null);
    const after = knobStep('budget.per_wave', 1.21, entries, baseline)?.after ?? entry.value;
    assert.equal(after, Math.round(2 * unit * 1.21));
  }
  assert.throws(() => budgetUnit({ budget: { unit: 0 } }), /positive integer/);
  table.budget = { base: 1, per_wave: 1 };
  write(root, file, table);
  const state = inventory(root), batch = robotBatch();
  for (const r of batch.results) r.waves = [{ n: 1, enemies: { patrol_cop: 1 }, seconds: 19 }];
  const plan = propose(batch, state, ensureBaseline(root, state.entries));
  assert.equal(plan.changes.length, 0);
  assert.match(plan.misses[0].reason, /budget.base rounds to the current integer 1/);

  for (const [direction, requested, expected] of [['down', 12, 10], ['down', 9, 9], ['up', 9, 10], ['up', 12, 12]]) {
    assert.equal(clamped({ direction, kind: 'float', min: 0, max: 100 }, 10, 10, requested), expected);
  }
});

test('street cost knobs follow named overrides and the cap resolves in table units', (t) => {
  const root = repository(t), { entries, tables } = inventory(root);
  const street = tables.get(TABLES + 'gauntlet.json');
  assert.equal(entries.get('max_alive').value, street.max_alive);
  const knobs = [...entries.keys()].filter((id) => id.startsWith('cost.'));
  assert.deepEqual(knobs.sort(), Object.keys(street.cost).map((id) => 'cost.' + id).sort());
  for (const [id, value] of Object.entries(street.cost)) {
    const entry = entries.get('cost.' + id);
    assert.equal(entry.knob.pointer, '/cost/' + id);
    assert.equal(entry.value, value);
    assert.equal(entry.unit, budgetUnit(street));
  }
  if (street.rivet) {
    assert.equal(entries.get('rivet.repair_delay_s').knob.direction, 'up');
    assert.equal(entries.get('rivet.repair_per_s').knob.direction, 'down');
  }
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
  const batch = manifest(runs.filter((r) => !validateRun(r)));
  batch.args.runner = 'pit'; // Historical bonus/guard fixtures exercise their independent metrics.
  return batch;
}

function robotBatch() {
  const ids = ['shield_robot', 'war_machine', 'sentry_turret'];
  return manifest(Array.from({ length: 12 }, (_, i) => ({
    schema: RUN_SCHEMA, seed: i + 1, profile: 'average', controls: 'wheel', wave_reached: 3, picks: [], mods: {},
    waves: ids.map((id, w) => ({ n: w + 1, seconds: [30, 24, 23][w], enemies: { [id]: 2 } }))
  })));
}

const beforeFile = 'build/before/batch.json', planFile = 'build/before/plan.json', afterFile = 'build/after/batch.json';
const proposeArgs = ['--batch=' + beforeFile, '--out=' + planFile];
const crossSeed = { mode: 'cross-seed' };
const confirmArgs = ['--floor-mode=cross-seed', '--before=' + beforeFile, '--after=' + afterFile, '--plan=' + planFile];

function prepare(root, batch, ...flags) {
  write(root, beforeFile, batch);
  ok(cli(root, 'propose', ...proposeArgs, ...flags));
  git(root, 'add', '--', BASELINE);
  git(root, 'commit', '-m', 'first-night baseline', '--', BASELINE);
  return readJson(join(root, planFile));
}

test('shared knobs need an opt-in and a single shared member excludes the whole damage group', (t) => {
  const root = repository(t), batch = robotBatch();
  batch.args.waves = 40;
  for (const run of batch.results) run.wave_reached = 40;
  write(root, beforeFile, batch);
  const rows = readJson(join(root, catalog));
  for (const knob of rows) {
    const privateTable = ['gauntlet.json', 'gauntlet_bonuses.json'].some((table) => knob.file === TABLES + table);
    assert.equal(knob.shared === true, !privateTable, knob.id);
  }
  for (const knob of rows.filter((k) => k.file.endsWith('/enemies.json')))
    knob.shared = knob.id === 'enemy_weapon.cannon.damage';
  write(root, catalog, rows);
  const plan = (...flags) => {
    ok(cli(root, 'propose', ...proposeArgs, '--metric=death', ...flags));
    return readJson(join(root, planFile));
  };
  const guarded = plan();
  assert.equal(guarded.changes.length, 1);
  assert.deepEqual(guarded.skipped, [{ id: 'enemy_damage', reason: 'shared with quest 1 / replays' }]);
  assert.ok(guarded.changes.every((c) => (c.members ?? [c]).every((m) => m.file === TABLES + 'gauntlet.json')));
  assert.equal(plan('--allow-shared').changes[0].id, 'enemy_damage');
});

test('propose uses measured fixture effects, records untunable misses and respects the plan limit', (t) => {
  const root = repository(t), batch = fixtureBatch();
  const state = inventory(root), baseline = ensureBaseline(root, state.entries);
  const plan = propose(batch, state, baseline, { max: 1, allowShared: true });
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
  assert.ok(propose(opposite, state, baseline, { allowShared: true }).changes.find((c) => c.id === pistol.id).after > pistol.before);
  const expert = manifest(robotBatch().results.map((r) => ({ ...r, profile: 'expert' })));
  const custom = propose(expert, state, baseline, { target: 20, profile: 'expert' });
  assert.deepEqual(custom.changes.map((c) => c.metric.wave), [1]); // 24 s is exactly on the upper boundary.
  assert.match(custom.changes[0].miss, /expert wave 1 median 30 s.*against 20 s/);
});

test('propose counts timed runs per wave and requires five deaths before acting on killer share', (t) => {
  const root = repository(t), runs = robotBatch().results.slice(0, 6);
  for (const [i, run] of runs.entries()) {
    if (i >= 3) delete run.waves[0].seconds;
    if (i >= 2) delete run.waves[1].seconds;
    if (i < 4) run.death = { wave: 3, by: 'turret_gun' };
    run.waves[2].seconds = 15;
  }
  write(root, beforeFile, manifest(runs));
  const output = ok(cli(root, 'propose', ...proposeArgs, '--allow-shared'));
  assert.match(output, /wave 2 median 24 s over 2 timed runs.*too few runs/);
  assert.match(output, /4\/4 deaths.*too few runs/);
  assert.deepEqual(readJson(join(root, planFile)).changes.map((c) => c.id), ['enemy_damage', 'shield_robot.hp']);
  runs[4].death = { wave: 3 }; // An unattributed death counts toward the denominator.
  write(root, beforeFile, manifest(runs));
  ok(cli(root, 'propose', ...proposeArgs, '--min-n=4', '--allow-shared'));
  const plan = readJson(join(root, planFile));
  assert.equal(plan.min_n, 4);
  assert.deepEqual(plan.changes.map((c) => c.id), ['enemy_damage']);
  assert.ok(plan.misses.some((m) => /4\/5 deaths/.test(m.miss) && /already selected/.test(m.reason)));
  assert.match(cli(root, 'propose', ...proposeArgs, '--min-n=0').stderr, /positive integer/);
});

test('fast street medians raise only the opening or growing budget, according to their extent', (t) => {
  const root = repository(t);
  const file = TABLES + 'gauntlet.json';
  const table = readJson(join(root, file));
  table.budget = { base: 8, per_wave: 8 };
  write(root, file, table);
  const state = inventory(root), baseline = ensureBaseline(root, state.entries), batch = robotBatch();
  for (const run of batch.results) {
    run.wave_reached = 6;
    run.waves = [9, 10, 12, 15, 27, 15].map((seconds, i) => ({
      n: i + 1, seconds, enemies: { robot_thug: 2 }
    }));
  }
  const edits = () => propose(batch, state, baseline).changes;
  const opening = edits();
  assert.deepEqual(opening.map((c) => [c.id, c.before, c.after]), [['budget.base', 8, 10]]);
  assert.match(opening[0].miss, /wave 1 median 9 s over 12 timed runs.*below the 12 s lower bound/);
  for (const run of batch.results) run.waves[5].seconds = 8;
  const spanning = edits();
  assert.deepEqual(spanning.map((c) => [c.id, c.after]), [['budget.per_wave', 10]]);
  assert.equal(spanning[0].metric.wave, 6);
  batch.args.runner = 'pit';
  assert.deepEqual(edits(), []);
});

test('early and late death-wave misses prefer the group then the budget; a cap can leave direction unknown', (t) => {
  const root = repository(t);
  const file = TABLES + 'gauntlet.json', table = readJson(join(root, file));
  table.budget.per_wave = 20;
  write(root, file, table);
  const state = inventory(root), base = ensureBaseline(root, state.entries);
  const batch = robotBatch();
  for (const [wave, factor] of [[6, 0.8], [24, 1.25]]) {
    for (const run of batch.results) {
      run.death = { wave, by: 'turret_gun' };
      run.wave_reached = wave + 1; // A younger roster can clear before the last survivor.
    }
    const plan = propose(batch, state, base, { allowShared: true });
    assert.equal(plan.changes[0].id, 'enemy_damage');
    assert.equal(plan.changes[0].factor, factor);
    assert.deepEqual(plan.changes[0].metric, { type: 'death', profile: 'average', target: 12 });
    const fallback = propose(batch, state, base, { used: new Set(['enemy_damage']) });
    assert.equal(fallback.changes[0].id, 'budget.per_wave');
  }
  for (const r of batch.results) { delete r.death; r.capped = true; r.wave_reached = 3; }
  const censored = propose(batch, state, base);
  assert.match(censored.misses[0].reason, /censoring/);
  assert.ok(!censored.changes.some((c) => c.metric.type === 'death'));
});

test('death-wave confirm pairs the recorded death or cap per seed with its null-salt floor', (t) => {
  const root = repository(t), before = robotBatch();
  for (const r of before.results) {
    r.death = { wave: r.seed + 13 };
    r.wave_reached = r.death.wave + 1;
  }
  delete before.results[0].death;
  before.runs[0].outcome = 'capped';
  const plan = prepare(root, before, '--allow-shared');
  assert.equal(plan.changes[0].id, 'enemy_damage');
  const neutral = structuredClone(before), after = structuredClone(before);
  neutral.args.salt = 1;
  for (const batch of [neutral, after]) {
    const delta = batch === neutral ? 1 : -3;
    for (const r of batch.results) {
      r.wave_reached += delta;
      if (r.death) r.death.wave += delta;
    }
    batch.results.reverse();
  }
  const nullFile = 'build/null/batch.json';
  write(root, nullFile, neutral);
  write(root, afterFile, after);
  assert.match(cli(root, 'confirm', ...confirmArgs).stderr, /death-wave.*--null/);
  const args = ['--before=' + beforeFile, '--after=' + afterFile, '--plan=' + planFile, '--null=' + nullFile];
  for (const mode of ['point', 'strict']) {
    ok(cli(root, 'confirm', ...args, '--verdict=' + mode));
    const c = readJson(join(root, 'build/after/tune-ledger.json')).changes[0];
    assert.deepEqual([c.metric.target, c.measured_before, c.measured_after, c.pairs, c.floor, c.improvement],
      [12, 19.5, 16.5, 12, 1, 3]);
    assert.deepEqual(c.ci95, [3, 3]);
    assert.deepEqual(c.verdicts, { point: 'kept', strict: 'kept' });
    assert.equal(c.verdict_mode, mode);
    assert.equal(c.censored_before, 1);
    assert.equal(c.censored_after, 1);
    assert.match(readFileSync(join(root, 'build/after/tune-ledger.md'), 'utf8'), /median uses lower bounds/);
  }
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
  const result = confirmChange(pairRuns(before, after), c, crossSeed);
  assert.equal(result.pairs, 12);
  assert.equal(result.improvement, 2);
  assert.equal(result.floor, 10);
  assert.equal(result.verdict, 'noise');
  const rows = pairRuns(before, after);
  const small = confirmChange(rows, c, { ...crossSeed, beforeRows: rows.slice(0, 11) });
  assert.equal(small.verdict, 'too few pairs');
  assert.ok(Number.isNaN(small.floor));
  assert.equal(small.aa_pairs, 5);
  assert.deepEqual(result.aa_groups, [{ stratum: '["average","wheel","random"]',
    left: [1, 3, 5, 7, 9, 11], right: [2, 4, 6, 8, 10, 12] }]);
  after.runs.forEach((r) => { r.pick = 'greedy'; });
  assert.equal(pairRuns(before, after).length, 0);
  after.runs.forEach((r) => { r.pick = 'random'; r.controls = 'legacy'; });
  after.results.forEach((r) => { r.controls = 'legacy'; });
  assert.equal(pairRuns(before, after).length, 0);
});

test('null-salt pairs matching seeds, measures byte changes and decides independently of cross-seed', (t) => {
  const root = repository(t), before = robotBatch();
  for (const run of before.results) run.waves[0].seconds = run.seed % 2 ? 40 : 50;
  // The legacy before manifest has no digests. Keep its original bytes next to it.
  for (const [i, row] of before.runs.entries()) {
    row.file = 'runs/' + row.seed + '.json';
    write(root, 'build/before/' + row.file, before.results[i]);
  }
  prepare(root, before);
  const neutral = structuredClone(before), after = structuredClone(before);
  neutral.args.salt = 1;
  for (const [i, r] of neutral.results.entries()) {
    if (r.seed > 2) r.waves[0].seconds++;
    // Seed 2 differs only by its trailing newline, so a parsed-value comparison would miss it.
    neutral.runs[i].result_sha256 = digest(JSON.stringify(r, null, 2) + (r.seed === 2 ? '' : '\n'));
  }
  for (const r of after.results) r.waves[0].seconds -= 2;
  neutral.results.reverse();
  const nullFile = 'build/null/batch.json';
  write(root, nullFile, neutral);
  write(root, afterFile, after);
  const args = ['--before=' + beforeFile, '--null=' + nullFile];
  const report = ok(cli(root, 'floor', ...args, '--out=build/floors.md'));
  assert.equal(readFileSync(join(root, 'build/floors.md'), 'utf8'), report);
  assert.match(report, /differ in 11 of 12 matched/);
  assert.match(report, /Wave 1 \(s\) \| 1 \| 12 \| 10 \| 6/);
  assert.match(report, /Wave reached \| 0 \| 12 \| 0 \| 6/);
  for (const [mode, verdict] of [['null-salt', 'kept'], ['cross-seed', 'noise']]) {
    ok(cli(root, 'confirm', ...args, '--after=' + afterFile, '--plan=' + planFile,
      ...(mode === 'null-salt' ? [] : ['--floor-mode=' + mode])));
    const ledger = readJson(join(root, 'build/after/tune-ledger.json'));
    const change = ledger.changes.find((c) => c.metric.wave === 1);
    assert.equal(change.floor_mode, mode);
    assert.equal(change.verdict, verdict);
    assert.equal(change.floor, mode === 'null-salt' ? 1 : 10);
    assert.equal(change.floors['null-salt'].floor, 1);
    assert.equal(change.floors['cross-seed'].floor, 10);
    const group = change.floors['null-salt'].aa_groups[0];
    assert.deepEqual(group.left, before.results.map((r) => r.seed));
    assert.deepEqual(group.right, group.left);
    const md = readFileSync(join(root, 'build/after/tune-ledger.md'), 'utf8');
    assert.match(md, /Null-salt floor \(pairs\) \| Cross-seed floor \(pairs\) \| Deciding mode/);
    assert.ok(md.includes('1 (12) | 10 (6) | ' + mode + ' | ' + verdict));
  }
  assert.match(cli(root, 'confirm', '--before=' + beforeFile, '--after=' + afterFile, '--plan=' + planFile).stderr, /--null/);
  assert.match(cli(root, 'floor', '--before=' + beforeFile, '--null=' + beforeFile).stderr, /different bot salts/);
});

test('a missing null wave reduces only its own floor coverage', () => {
  const before = robotBatch(), neutral = structuredClone(before);
  neutral.args.salt = 1;
  for (const run of neutral.results.slice(5)) delete run.waves[0].seconds;
  const rows = pairRuns(before, before);
  const metric = { type: 'wave', profile: 'average', wave: 1, target: 15 };
  const result = confirmChange(rows, { metric }, { beforeRows: rows, nullRows: pairNullRuns(before, neutral) });
  assert.equal(result.verdict, 'too few pairs');
  assert.equal(result.aa_pairs, 5);
  assert.ok(Number.isNaN(result.floor));
  assert.equal(result.floors['cross-seed'].aa_pairs, 6);
  assert.equal(result.floors['cross-seed'].floor, 0);
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
  const result = confirmChange(pairRuns(before, after), change, crossSeed);
  assert.deepEqual([result.pairs, result.measured_before, result.measured_after, result.verdict], [12, 2, 0, 'kept']);
  for (const r of after.results) r.picks[0].taken = 'ghost_kerf';
  const switched = confirmChange(pairRuns(before, after), change, crossSeed);
  assert.equal(switched.pairs, 0);
  assert.equal(switched.verdict, 'too few pairs');
});

test('apply preflights bounds, canonical bytes and schemas for the whole plan before its first commit', (t) => {
  const root = repository(t, 'n23-tune-test');
  const plan = prepare(root, fixtureBatch(), '--allow-shared');
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
  const root = repository(t, 'n23-tune-robot');
  const before = robotBatch(), after = structuredClone(before);
  const plan = prepare(root, before, '--allow-shared');
  assert.deepEqual(plan.changes.map((c) => c.id), ['shield_robot.hp', 'war_machine.hp', 'sentry_turret.hp']);
  assert.match(plan.changes[0].miss, /median 30 s over 12 timed runs.*15 s, shield_robot present in 12\/12/);
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
      'tune(n23): ' + c.id + ' ' + c.before + ' -> ' + c.after + ': ' + c.miss);
    expected.archetypes.find((r) => c.id === r.id + '.hp').hp = c.after;
    assert.equal(git(root, 'show', receipts[i] + ':' + file), canonicalJson(expected));
  }
  const head = git(root, 'rev-parse', 'HEAD');
  ok(cli(root, 'apply', '--plan=' + planFile));
  assert.equal(git(root, 'rev-parse', 'HEAD'), head);
  const nextPlan = 'build/next-plan.json';
  ok(cli(root, 'propose', '--batch=' + beforeFile, '--out=' + nextPlan, '--allow-shared'));
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
  assert.match(md, /Left seeds \| Right seeds/);
  assert.match(md, /1, 3, 5, 7, 9, 11 \| 2, 4, 6, 8, 10, 12/);
  const reverted = git(root, 'rev-parse', 'HEAD');
  ok(cli(root, 'confirm', ...confirmArgs, '--revert'));
  assert.equal(git(root, 'rev-parse', 'HEAD'), reverted);
  assert.equal(git(root, 'status', '--short', '--', 'project/'), '');
});


test('a failed second commit restores that table and retry resumes from the first receipt', (t) => {
  const root = repository(t, 'n23-tune-retry');
  const plan = prepare(root, fixtureBatch(), '--allow-shared');
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
  const root = repository(t, 'n23-tune-adjacent');
  const file = TABLES + 'gauntlet.json';
  const table = readJson(join(root, file));
  table.budget = { ...table.budget, base: 10, per_wave: 10 };
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
  assert.deepEqual(readJson(join(root, file)).budget, { ...table.budget, per_wave: 8 });
  const ledger = readJson(join(root, 'build/after/tune-ledger.json'));
  assert.equal(ledger.changes[0].revert_commit, git(root, 'rev-parse', 'HEAD').trim());
  assert.equal(ledger.changes[1].verdict, 'kept');
});


test('apply refuses a dead or reordered pointer before writing another change', (t) => {
  const root = repository(t, 'n23-tune-missing');
  prepare(root, fixtureBatch(), '--allow-shared');
  const rows = readJson(join(root, catalog));
  const knob = rows.find((k) => k.id === 'weapon.pistol.rof_hz');
  for (const pointer of ['/weapons/999/rof_hz', '/weapons/1/rof_hz']) {
    knob.pointer = pointer;
    write(root, catalog, rows);
    git(root, 'commit', '-m', 'unresolved fixture pointer', '--', catalog);
    const head = git(root, 'rev-parse', 'HEAD');
    const result = cli(root, 'apply', '--plan=' + planFile);
    assert.equal(result.status, 1);
    assert.match(result.stderr, /weapon\.pistol\.rof_hz/);
    assert.equal(git(root, 'rev-parse', 'HEAD'), head);
    assert.equal(git(root, 'diff', '--', TABLES), '');
  }
});

test('a night with synthetic batches drives the real report, propose, apply and selective revert CLIs', (t) => {
  const root = repository(t, 'lane');
  const tree = join(tmpdir(), 'night-' + root.split(/[\\/]/).at(-1));
  t.after(() => rmSync(tree, { recursive: true, force: true }));
  writeFileSync(join(root, '.gitignore'), '/build/\n');
  git(root, 'add', '--', '.gitignore');
  git(root, 'commit', '-m', 'ignore runner output');
  ensureBaseline(root, inventory(root).entries);
  git(root, 'add', '--', BASELINE);
  git(root, 'commit', '-m', 'first-night baseline', '--', BASELINE);
  const dir = join(root, 'evidence/n23-loop/night output'), jobs = [];
  function run([script, ...args], cwd) {
    assert.equal(cwd, tree);
    if (script.endsWith('/batch.mjs')) {
      const data = robotBatch();
      data.args.salt = args.includes('--salt=1') ? 1 : 0;
      if (jobs.length === 2) for (const r of data.results) r.waves[0].seconds = 15;
      const dest = args.find((arg) => arg.startsWith('--out=')).slice(6);
      write(dest, 'batch.json', data);
      jobs.push(args.filter((arg) => !arg.startsWith('--out=')));
      return;
    }
    const invoke = () => spawnSync(process.execPath, [join(ROOT, script), ...args], { cwd, encoding: 'utf8' });
    if (args[0] === 'apply') {
      const note = join(tree, 'owner-note');
      writeFileSync(note, 'outside the generated evidence');
      assert.match(invoke().stderr, /dirty tree.*owner-note/);
      rmSync(note);
    }
    ok(invoke());
  }
  night(['--worktree=' + tree, '--branch=n23-tune-night', '--seeds=12', '--pick=random', '--out=' + dir], { root, run, log() {} });
  assert.deepEqual(jobs[1], [...jobs[0], '--salt=1']);
  assert.deepEqual(jobs[0], jobs[2]);
  const ledger = readJson(join(dir, 'after/tune-ledger.json'));
  assert.deepEqual(ledger.changes.map((c) => [c.id, c.verdict]), [['budget.base', 'kept'], ['budget.per_wave', 'noise']]);
  const md = readFileSync(join(dir, 'night.md'), 'utf8');
  for (const c of ledger.changes) {
    assert.ok(md.includes(c.commit));
    if (c.revert_commit) assert.ok(md.includes(c.revert_commit));
  }
  for (const arm of ['before', 'after']) for (const ext of ['md', 'html'])
    assert.ok(existsSync(join(dir, arm, 'report.' + ext)));
});

test('point and strict verdicts reproduce the n22 gains and their mirrored losses', () => {
  for (const [gain, ci, floor, point, strict] of [
    [13.67, [4.75, 19.08], 11.48, 'kept', 'noise'],
    [3.67, [1.72, 6.6], 6.73, 'noise', 'noise'],
    [13, [12, 16], 11, 'kept', 'kept'],
    [13, [0, 16], 11, 'noise', 'noise']
  ]) {
    for (const [mode, expected] of [['point', point], ['strict', strict]]) {
      assert.equal(verdictFor(gain, ci, floor, mode), expected);
      assert.equal(verdictFor(-gain, [-ci[1], -ci[0]], floor, mode), expected === 'kept' ? 'reverted' : 'noise');
    }
  }
});

test('enemy damage uses one factor, one commit and one reversible receipt', (t) => {
  const root = repository(t, 'n23-tune-damage'), batch = robotBatch();
  const plan = prepare(root, batch);
  const { entries } = inventory(root), baseline = readJson(join(root, BASELINE));
  const group = knobStep('enemy_damage', 3, entries, baseline);
  assert.equal(group.factor, 1.25);
  assert.deepEqual(group.members.map((m) => m.id), [...entries.keys()].filter((id) =>
    id.endsWith('.production_damage') || (id.startsWith('enemy_weapon.') && id.endsWith('damage'))));
  const overlap = new Set([group.members[0].id]);
  assert.equal(occupied(group.id, overlap), true);
  assert.equal(occupied(group.members[0].id, new Set([group.id])), true);
  for (const m of group.members) assert.equal(m.after, Math.min(entries.get(m.id).knob.max, m.before * 1.25));
  const capped = structuredClone(baseline);
  capped.values['enemy_weapon.cannon.damage'] = 8;
  assert.equal(knobStep(group.id, 1.25, entries, capped).members.find((m) => m.id === 'enemy_weapon.cannon.damage').after, 16);
  plan.changes = [{ ...group, metric: { type: 'wave', profile: 'average', wave: 1, target: 15 }, miss: 'fixture wave time' }];
  const budget = knobStep('budget.base', 1.25, entries, baseline);
  write(root, planFile, { ...plan, changes: [...plan.changes, { ...budget, metric: plan.changes[0].metric, miss: 'late death' }] });
  const lines = ok(cli(root, 'sets', '--plan=' + planFile)).trimEnd().split(/\r?\n/);
  assert.deepEqual(lines, [...group.members, budget].map((m) => '--set=' + m.file + '#' + m.pointer + '=' + m.after));
  assert.equal(budget.after, Math.round(entries.get('budget.base').value * 1.25));
  const apply = () => cli(root, 'apply', '--plan=' + planFile);
  const invalid = structuredClone(plan);
  invalid.changes[0].members.pop();
  write(root, planFile, invalid);
  assert.match(apply().stderr, /group catalog/);
  write(root, planFile, plan);
  const head = git(root, 'rev-parse', 'HEAD').trim();
  ok(apply());
  ok(apply());
  assert.equal(git(root, 'rev-list', '--count', head + '..HEAD').trim(), '1');
  const updated = inventory(root).entries;
  for (const m of group.members) assert.equal(updated.get(m.id).value, m.after);
  write(root, afterFile, batch);
  ok(cli(root, 'confirm', ...confirmArgs, '--revert'));
  const ledger = readJson(join(root, 'build/after/tune-ledger.json'));
  assert.equal(ledger.changes.length, 1);
  assert.equal(ledger.changes[0].verdict, 'noise');
  assert.ok(ledger.changes[0].revert_commit);
  assert.equal(git(root, 'diff', head, '--', TABLES), '');
});

test('changing the verdict threshold uses the same mean and interval on skewed pairs', () => {
  const before = robotBatch(), after = structuredClone(before);
  for (const r of after.results) r.waves[0].seconds -= r.seed === 1 ? 12 : 0;
  const rows = pairRuns(before, after), change = { metric: { type: 'wave', profile: 'average', wave: 1, target: 15 } };
  const point = confirmChange(rows, change, crossSeed);
  const strict = confirmChange(rows, change, { ...crossSeed, verdict: 'strict' });
  assert.equal(point.improvement, 1);
  assert.equal(strict.improvement, point.improvement);
  assert.deepEqual(strict.ci95, point.ci95);
  assert.deepEqual(strict.verdicts, point.verdicts);
});

test('the catalog bounds every numeric combat move and blast self damage', () => {
  const combat = readJson(join(ROOT, 'project/data/tables/combat.json'));
  const { entries } = inventory(ROOT);
  function verify(value, id) {
    if (typeof value === 'object') {
      for (const [key, member] of Object.entries(value)) verify(member, id + '.' + key);
    } else if (typeof value === 'number') {
      const entry = entries.get(id);
      assert.ok(entry, id);
      assert.equal(entry.knob.pointer, '/' + id.replaceAll('.', '/'));
      assert.equal(entry.value, value);
      assert.ok(entry.knob.min <= value && value <= entry.knob.max, id);
      assert.equal(entry.knob.kind, id.endsWith('.hops') ? 'int' : 'float');
    } else {
      assert.equal(entries.has(id), false, id);
    }
  }
  verify(combat.moves, 'moves');
  verify(combat.blast.self_k, 'blast.self_k');
});
