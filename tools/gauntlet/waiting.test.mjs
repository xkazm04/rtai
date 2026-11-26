import { strict as assert } from 'node:assert';
import { cpSync, existsSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { test } from 'node:test';
import { fileURLToPath } from 'node:url';
import { aggregate, markdown, pct } from './waiting_agg.mjs';
import { main, parse, plan, resultDiff, withLaneLock } from './waiting.mjs';
import { compareMarkdown, damageSum, headline } from './waiting_compare.mjs';

const FIXTURE = fileURLToPath(new URL('./fixtures/waiting/', import.meta.url));
const docs = () => ['average-1.json', 'average-2.json'].map((n) => JSON.parse(readFileSync(join(FIXTURE, 'runs', n), 'utf8')));

test('nearest-rank percentiles', () => {
  assert.equal(pct([], 50), null);
  assert.equal(pct([3, 1, 2], 50), 2);
  assert.equal(pct([5, 7, 9, 11, 13], 10), 5);
  assert.equal(pct([5, 7, 9, 11, 13], 90), 13);
});

test('pools a wave over seeds per ranged archetype', () => {
  const w1 = aggregate(docs()).profiles.average.waves[1];
  assert.equal(w1.reached, 2);
  const cop = w1.kinds.cop;
  assert.equal(cop.n, 4);
  assert.deepEqual([cop.react_p50, cop.react_p90, cop.react_any_p50, cop.react_any_p90], [3, 5, 4, 6]);
  assert.deepEqual([cop.never_fired, cop.never_fired_clear], [1, 1]);
  assert.equal(cop.idle_strict, 0.25);
  assert.equal(cop.idle_share, null, 'a pre-b4a run file has no engaged counters');
  assert.equal(w1.pressing_share, null);
  assert.deepEqual([cop.dist_p10, cop.dist_p50, cop.dist_p90], [5, 9, 13]);
  assert.deepEqual(cop.dist_hist_2m, { 4: 1, 6: 1, 8: 1, 10: 1, 12: 1 });
  assert.equal(w1.firing_per_s_mean, 1);
  assert.equal(w1.firing_per_s_max, 2);
  assert.equal(w1.damage_taken_mean, 20);
  assert.equal(w1.deaths, 0);
});

test('melee apart, deaths, shot parity and unreached waves', () => {
  const p = aggregate(docs()).profiles.average;
  assert.equal(p.waves[2].reached, 1);
  assert.equal(p.waves[2].deaths, 1);
  assert.equal(p.waves[2].shots_mismatch, 1);
  assert.deepEqual(Object.keys(p.waves[2].kinds), ['cop']);
  assert.equal(p.waves[2].melee.brute.never_fired, 1);
  assert.equal(p.waves[2].all_ranged.n, 1);
  assert.deepEqual(p.waves[3], { reached: 0, runs: 2 });
  assert.equal(p.totals.all_ranged.n, 5);
  const md = markdown(aggregate(docs()));
  assert.match(md, /\| 3 \| not reached \(0\/2 seeds\) \|/);
  assert.match(md, /\| 2 \(reached 1\/2\) \| cop \| 1 \|/);
  assert.match(md, /\*\*1-4, 6-7\*\*/);
  assert.match(md, /Rivet shots probe = run result on 2\/3 wave rows/);
  assert.doesNotMatch(md, /\| 0 \| -/);
});

test('rejects a file of another schema', () => {
  assert.throws(() => aggregate([{ schema: 'x/1', seed: 1 }]), /gtai.foes-waiting\/1/);
});

test('probe argv mirrors a gauntlet bot run and adds --waiting-out', () => {
  const a = parse(['--out=' + join(tmpdir(), 'w'), '--profiles=average', '--seeds=2', '--seed0=3']);
  const jobs = [...plan(a)];
  assert.equal(jobs.length, 2);
  const [entry, ...flags] = jobs[0].argv;
  assert.equal(entry, 'waiting_probe');
  for (const f of ['--seed=3', '--bot=average', '--pick=greedy', '--controls=wheel', '--waves=7']) assert.ok(flags.includes(f), f);
  assert.ok(flags.some((f) => f.startsWith('--result=') && f.endsWith('average-3.result.json')));
  assert.ok(flags.at(-1).startsWith('--waiting-out=') && flags.at(-1).endsWith('average-3.json'));
  assert.equal(jobs[0].plain[0], 'gauntlet');
  assert.ok(!jobs[0].plain.some((f) => f.startsWith('--waiting-out')));
  assert.throws(() => parse(['--out=x', '--profiles=pro']), /unknown profile/);
  assert.throws(() => parse([]), /--out/);
});

test('result diff names the differing keys', () => {
  assert.equal(resultDiff({ a: 1, b: [1] }, { a: 1, b: [1] }), '');
  assert.equal(resultDiff({ a: 1, b: 2 }, { a: 1, b: 3 }), 'differs in b');
});

test('lane lock is exclusive and only its owner removes it', () => {
  const dir = mkdtempSync(join(tmpdir(), 'gtai-waiting-test-'));
  const lock = join(dir, 'godot.lock');
  try {
    assert.equal(withLaneLock('t1', () => readFileSync(lock, 'utf8').split(' ')[0], { lock }), 't1');
    assert.ok(!existsSync(lock));
    writeFileSync(lock, 'other 1\n');
    assert.throws(() => withLaneLock('t1', () => { throw new Error('ran'); }, { lock, log: () => { throw new Error('waited'); } }), /waited/);
    assert.ok(existsSync(lock));
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test('--from re-aggregates run files without Godot', () => {
  const dir = mkdtempSync(join(tmpdir(), 'gtai-waiting-test-'));
  try {
    cpSync(FIXTURE, dir, { recursive: true });
    assert.equal(main(['--from=' + dir], { log: () => {} }), 0);
    const out = JSON.parse(readFileSync(join(dir, 'waiting.json'), 'utf8'));
    assert.equal(out.profiles.average.runs, 2);
    assert.match(readFileSync(join(dir, 'waiting.md'), 'utf8'), /## average \(2 seeds: 1, 2\)/);
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

/** The fixture runs with the b4a engaged counters added (1 s of 10 in range unengaged per cop row). */
function engagedDocs() {
  const out = docs();
  for (const doc of out) for (const row of doc.waves) {
    row.press_eligible_s = 8;
    row.press_s = row.n === 1 ? 6 : 2;
    for (const k of Object.values(row.archetypes)) Object.assign(k, { clear_unengaged_s: 2, clear_in_unengaged_s: 1 });
  }
  return out;
}

test('engaged idle share, strict columns and pressing share pool by seconds', () => {
  const p = aggregate(engagedDocs()).profiles.average;
  const cop = p.waves[1].kinds.cop;
  assert.equal(cop.idle_share, 0.1);
  assert.equal(cop.idle_share_any, 0.2);
  assert.equal(cop.idle_strict, 0.25);
  assert.equal(p.waves[1].pressing_share, 0.75);
  assert.equal(p.waves[2].pressing_share, 0.25);
  assert.equal(p.totals.pressing_share, round3(14 / 24));
  assert.match(markdown(aggregate(engagedDocs())), /\| 10 % \(25 %, 25 %\) \|/);
});

const round3 = (x) => Math.round(x * 1000) / 1000;

test('--compare prints one column per dir and the damage sum of waves 1-4', () => {
  const p = aggregate(engagedDocs()).profiles.average;
  const rows = Object.fromEntries(headline(p));
  assert.equal(rows['pressing share'], '58 %');
  assert.equal(rows['damage taken w3 mean'], '-');
  assert.equal(damageSum(p), null, 'wave 3 not reached');
  const full = { waves: { 1: { damage_taken_mean: 1.25 }, 2: { damage_taken_mean: 2 }, 3: { damage_taken_mean: 3 }, 4: { damage_taken_mean: 4 } } };
  assert.equal(damageSum(full), 10.3);
  const dirs = [0, 1].map(() => mkdtempSync(join(tmpdir(), 'gtai-waiting-cmp-')));
  try {
    const sums = [aggregate(docs()), aggregate(engagedDocs())];
    sums.forEach((s, i) => writeFileSync(join(dirs[i], 'waiting.json'), JSON.stringify({ ...s, meta: { rev: 'r' + i } })));
    const file = join(dirs[0], 'cmp.md');
    assert.equal(main(['--compare=' + dirs.join(','), '--labels=main,gait', '--out=' + file], { log: () => {} }), 0);
    const md = readFileSync(file, 'utf8');
    assert.match(md, /\| metric \| main \| gait \|/);
    assert.match(md, /\| pressing share \| - \| 58 % \|/);
    assert.match(md, /main = r0; gait = r1/);
    assert.throws(() => parse(['--compare=' + dirs[0]]), /two or more/);
    assert.throws(() => parse(['--compare=a,b', '--labels=x']), /every --compare dir/);
    assert.throws(() => compareMarkdown([{ schema: 'x' }], ['a']), /summary/);
  } finally { for (const d of dirs) rmSync(d, { recursive: true, force: true }); }
});

test('--game-flag rides on every probe argv', () => {
  const a = parse(['--out=/tmp/x', '--game-flag=--foe-fire=hot', '--seeds=2', '--profiles=average']);
  const jobs = [...plan(a)];
  assert.equal(jobs.length, 2);
  for (const j of jobs) assert.equal(j.argv.at(-1), '--foe-fire=hot');
  assert.deepEqual([...plan(parse(['--out=/tmp/x', '--seeds=1', '--profiles=average']))][0].argv.filter((x) => x.includes('foe')), []);
});
