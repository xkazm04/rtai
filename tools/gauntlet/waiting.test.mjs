import { strict as assert } from 'node:assert';
import { cpSync, existsSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { test } from 'node:test';
import { fileURLToPath } from 'node:url';
import { aggregate, markdown, pct } from './waiting_agg.mjs';
import { main, parse, plan, resultDiff, withLaneLock } from './waiting.mjs';

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
  assert.equal(cop.idle_share, 0.25);
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
