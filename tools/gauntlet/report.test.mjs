import assert from 'node:assert/strict';
import { mkdirSync, mkdtempSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { test } from 'node:test';
import { ROOT, readJson } from '../lib/repo.mjs';
import { analyze } from './analysis.mjs';
import { BATCH_SCHEMA, validateRun } from './contract.mjs';
import { offerEffects } from './offers.mjs';
import { generate, loadBatch } from './report.mjs';
import { render } from './render.mjs';
import { confirmChange, pairRuns } from './tune_confirm.mjs';

const dir = join(ROOT, 'tools/gauntlet/fixtures');
const all = readdirSync(dir).filter((name) => name.endsWith('.json')).map((name) => readJson(join(dir, name)));
const batch = { schema: BATCH_SCHEMA, created: '2026-11-21T00:00:00Z', git: { sha: 'fixture', branch: 'test', dirty: false },
  args: { profile: 'all', runner: 'gauntlet', pick: 'random', waves: 10 },
  tables: {}, weapon_refs: { weapon_pistol: 'pistol' },
  runs: all.map((r) => ({ profile: r.profile, seed: r.seed, ok: !validateRun(r), reason: validateRun(r),
    pick: 'random', file: r.profile + '-' + r.seed + '.json' })), results: all.filter((r) => !validateRun(r)) };
const model = analyze(batch);

test('weapon deaths count for their carrier and preserve the attack that killed', () => {
  const roster = { war_machine: ['war_cannon', 'stomp'], sentry_turret: ['turret_gun'] };
  const causes = ['turret_gun', 'war_cannon', 'stomp', 'timeout', null];
  const runs = causes.map((by, seed) => ({ ...batch.results[0], seed, profile: 'average',
    waves: [{ n: 1, enemies: { sentry_turret: 1, war_machine: 1 } }], wave_reached: 1,
    picks: [], death: by ? { wave: 1, by } : { wave: 1 } }));
  const fixture = { ...batch, enemy_weapons: roster, results: runs,
    runs: runs.map((r) => ({ ok: true, seed: r.seed, profile: r.profile })) };
  const report = analyze(fixture);
  assert.deepEqual(report.enemies.map((e) => [e.id, e.kills, e.weapons]), [
    ['sentry_turret', 1, [['turret_gun', 1]]],
    ['war_machine', 2, [['stomp', 1], ['war_cannon', 1]]]
  ]);
  assert.equal(report.deaths[0].timeouts, 1);
  assert.equal(report.deaths[0].unknown, 1);
  assert.match(render(fixture, report).markdown, /\| timeout \| 1 \|/);
});

test('historical tick-cap evidence counts by profile in the header and deaths', (t) => {
  mkdirSync(join(ROOT, 'build'), { recursive: true });
  const dir = mkdtempSync(join(ROOT, 'build', 'stall-report-'));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  const rows = ['novice', 'expert', 'expert'].map((profile, i) => ({
    profile, seed: i, ok: false, file: profile + i + '.json', exit: 1, engine_log: i + '.log'
  }));
  for (const [i, row] of rows.entries()) writeFileSync(join(dir, row.engine_log),
    i < 2 ? '[ERROR] gauntlet: headless tick cap reached before run ended\n' : 'SCRIPT ERROR\n');
  const path = join(dir, 'batch.json');
  writeFileSync(path, JSON.stringify({ ...batch, results: [], runs: rows }));
  const report = generate(path, null, dir);
  assert.deepEqual(report.deaths.map((d) => [d.profile, d.runs, d.stalled, d.total]),
    [['novice', 1, 1, 0], ['expert', 2, 1, 0]]);
  const md = readFileSync(join(dir, 'report.md'), 'utf8');
  assert.match(md, /Stalled runs by profile: novice 1, expert 1/);
  assert.match(md, /\| expert \| 2 \| 0 \| 1 \| 0 \|/);
});

test('archived alive caps count in reports and paired confirmation, only for measured waves', (t) => {
  mkdirSync(join(ROOT, 'build'), { recursive: true });
  const dir = mkdtempSync(join(ROOT, 'build', 'cap-report-'));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  const rows = Array.from({ length: 16 }, (_, i) => ({ profile: 'average', controls: 'wheel', seed: i,
    ok: false, file: i + '.json', exit: 1, outcome: 'stalled',
    reason: 'FAIL exit 1 (fail); SCRIPT ERROR 0; unknown arg 0; result fresh' }));
  for (const row of rows) {
    const run = { ...all[0], profile: row.profile, controls: row.controls, seed: row.seed, wave_reached: 2,
      waves: [{ n: 1, seconds: 24 }, { n: 2 }], picks: [] };
    delete run.death;
    if (row.seed === 12) run.death = { wave: 2 };
    if (row.seed === 13) run.seed = 100;
    if (row.seed === 14) row.reason = row.reason.replace('fresh', 'stale');
    if (row.seed === 15) row.reason = row.reason.replace('SCRIPT ERROR 0', 'SCRIPT ERROR 1');
    writeFileSync(join(dir, row.file), JSON.stringify(run));
  }
  const file = join(dir, 'batch.json');
  writeFileSync(file, JSON.stringify({ ...batch, results: [], runs: rows }));
  const before = loadBatch(file), after = structuredClone(before);
  assert.equal(before.results.length, 12);
  for (const run of after.results) run.waves[0].seconds = 15;
  const pairs = pairRuns(before, after);
  const measure = (wave) => confirmChange(pairs, { metric: { type: 'wave', profile: 'average', wave, target: 15 } },
    { mode: 'cross-seed' });
  assert.deepEqual([measure(1).pairs, measure(1).verdict, measure(2).pairs], [12, 'kept', 0]);
  const model = analyze(before);
  assert.deepEqual(model.waves.map((w) => w.timed), [12, 0]);
  assert.deepEqual([model.deaths[0].capped, model.deaths[0].total], [12, 0]);
  assert.match(render(before, model).markdown, /Capped alive by profile: average 12/);
});

test('a shared gun identifies a carrier only when the death-wave roster singles it out', () => {
  const enemy_weapons = { cop: ['rifle'], contractor: ['rifle'] };
  const runs = [{ cop: 1 }, { cop: 1, contractor: 1 }].map((enemies, seed) => ({
    ...batch.results[0], seed, waves: [{ n: 1, enemies }], wave_reached: 1, picks: [],
    death: { by: 'rifle', wave: 1 }
  }));
  const report = analyze({ ...batch, results: runs, enemy_weapons });
  assert.equal(report.enemies.find((e) => e.id === 'cop').kills, 1);
  assert.equal(report.enemies.find((e) => e.id === 'contractor').kills, 0);
  assert.ok(!report.enemies.some((e) => e.id === 'rifle'));
  assert.equal(report.deaths.find((d) => d.profile === runs[0].profile).total, 2);
});

test('wave telemetry reports independent medians and coverage for rounds and contacts', () => {
  const w = model.waves.find((r) => r.profile === 'average' && r.n === 1);
  assert.deepEqual([w.observed, w.timed, w.min, w.p25, w.median, w.p75, w.max], [8, 7, 12, 13, 15, 17, 18]);
  assert.deepEqual(w.guard, { median: 2, n: 2 });
  assert.deepEqual(w.shots, { median: 6.5, n: 8 });
  assert.deepEqual(w.hits, { median: 5.5, n: 2 });
  const { markdown, html } = render(batch, model);
  assert.match(markdown, /gun rounds \| damaging contacts \(all sources\)/);
  assert.match(html, /There is no rate because/);
  assert.doesNotMatch(markdown + html, /hit rate/i);
  assert.deepEqual(w.forms, [{ id: 'kerf', median: 3, n: 6 }, { id: 'tonnage', median: 4, n: 1 }]);
  assert.deepEqual(model.waves.filter((row) => row.miss).map((r) => r.n), [2, 3, 4, 5, 6]);
});

test('counts named and unattributed deaths; only measured rosters contribute to enemy comparisons', () => {
  const d = model.deaths.find((r) => r.profile === 'average');
  assert.deepEqual(d.waves, [[4, 3], [6, 4]]);
  assert.deepEqual(d.killers, [['patrol_cop', 6]]);
  assert.equal(d.unknown, 1);
  assert.equal(d.total, 7);
  const cop = model.enemies.find((e) => e.id === 'patrol_cop');
  assert.deepEqual(cop.present, { n: 51, median: 21 });
  assert.deepEqual(cop.absent, { n: 63, median: 19 });
  assert.equal(cop.kills, 6);
  assert.ok(Math.abs(cop.share - 0.4753) < 0.0001);
  assert.equal(model.enemies.find((e) => e.id === 'contractor').absent.n, 0);
});

test('offered-only comparisons report the planted shift, and both noise rules', () => {
  const get = (kind, id, metric) => model.effects.find((e) => e.kind === kind && e.id === id && e.metric === metric);
  const pistol = get('bonus', 'weapon_pistol', 'survived');
  assert.deepEqual([pistol.took, pistol.declined, pistol.pairs, pistol.delta, pistol.ci, pistol.floor, pistol.label],
    [12, 12, 12, 2, [2, 2], 0, 'higher']);
  const weapon = get('weapon', 'pistol', 'seconds');
  assert.deepEqual([weapon.delta, weapon.ci, weapon.label], [-6, [-6, -6], 'lower']);
  const zero = get('bonus', 'stat_hp_max_10', 'survived');
  assert.deepEqual([zero.ci, zero.label], [[0, 0], 'noise']);
  const floor = get('bonus', 'stat_damage_10', 'survived');
  assert.deepEqual([floor.ci, floor.floor, floor.label], [[-2, -2], 2, 'noise']);
  assert.equal(get('bonus', 'ghost_ohm', 'seconds').label, 'insufficient data');
});

test('a later take, repeated offer, alias and unoffered run each affect the right weapon cohort once', () => {
  const make = (seed, picks) => ({ ...batch.results[0], seed, picks, wave_reached: 4,
    death: { wave: 4 }, waves: [{ n: 1, seconds: 100 }, { n: 2, seconds: 60 }, { n: 3, seconds: 10 }] });
  const pick = (wave, offered, taken) => ({ wave, offered, taken });
  const dec = pick(1, ['p1', 'p2', 'x'], 'x');
  const take = pick(2, ['p2', 'x', 'y'], 'p2');
  const runs = [make(1, [dec, take]), make(2, [dec]), make(3, [pick(1, ['x', 'y', 'z'], 'x')])];
  const row = offerEffects(runs, new Map([['p1', 'pistol'], ['p2', 'pistol']]))
    .find((e) => e.kind === 'weapon' && e.metric === 'seconds');
  assert.deepEqual([row.took, row.declined, row.takeMedian, row.declineMedian], [1, 1, 10, 35]);
  assert.equal(row.pairs, 0); // The first take was a different wave from the decliner's offer.
});

test('report files include baseline changes, ranked reproducible commands and embedded charts', (t) => {
  const temp = join(ROOT, 'build/gauntlet/tests');
  mkdirSync(temp, { recursive: true });
  const out = mkdtempSync(join(temp, 'report-'));
  t.after(() => rmSync(out, { recursive: true, force: true }));
  const before = structuredClone(batch);
  for (const r of before.results) for (const w of r.waves) if ('seconds' in w) w.seconds -= 2;
  const file = join(out, 'batch.json'), baseFile = join(out, 'before.json');
  writeFileSync(file, JSON.stringify(batch));
  writeFileSync(baseFile, JSON.stringify(before));
  const compared = generate(file, baseFile, out);
  assert.equal(compared.waves.find((w) => w.profile === 'average' && w.n === 1).baseline.median, 13);
  const winners = compared.winners.filter(({ run }) => run.profile === 'expert');
  assert.equal(winners[0].run.seed, 4);
  assert.equal(winners[0].command, 'node tools/dev/run.mjs gauntlet --seed=4 --bot=expert --pick=random --controls=wheel --waves=10');
  const html = readFileSync(join(out, 'report.html'), 'utf8');
  const md = readFileSync(join(out, 'report.md'), 'utf8');
  assert.doesNotMatch(html, /https?:|\bsrc\s*=|\bhref\s*=|@import|url\s*\(|<script/i);
  assert.equal((html.match(/<svg\b/g) ?? []).length, 3);
  assert.match(html, /<style>/);
  assert.match(md, /\| average \| 1 \| 7 \/ 8 \| 13 \(7\) \| 15 \| 2 \|/);
  assert.ok(md.includes(winners[0].command));
  assert.match(html, /Excluded runs/);
});

test('partial street counters stay unmeasured, report text is escaped, human input remains selectable', () => {
  const run = { ...batch.results[0], profile: 'human', wave_reached: 1, waves: [{ n: 1 }],
    picks: [], death: { wave: 1, by: '<img onerror=alert(1)>' } };
  const partial = { ...batch, runs: [{ profile: 'human', seed: run.seed, ok: true }], results: [run] };
  const result = analyze(partial);
  const w = result.waves[0];
  assert.equal(w.timed, 0);
  assert.equal(w.hits.n, 0);
  assert.equal(w.shots.n, 0);
  assert.equal(w.guard.n, 0);
  assert.equal(result.winners.length, 0);
  const { html, markdown } = render(partial, result);
  assert.match(markdown, /not measured/);
  assert.match(html, /&lt;img onerror/);
  assert.doesNotMatch(html, /<img\b/);
});
