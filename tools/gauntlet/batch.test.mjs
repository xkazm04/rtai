import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { test } from 'node:test';
import { ROOT } from '../lib/repo.mjs';
import { batch, parseArgs, plan } from './batch.mjs';
import { RUN_SCHEMA, validateRun } from './contract.mjs';

const args = ['--profile=all', '--pick=random', '--seeds=2'];
const fixtureDir = join(ROOT, 'tools', 'gauntlet', 'fixtures');
const skeleton = { schema: RUN_SCHEMA, seed: 1, profile: 'average', controls: 'wheel',
  wave_reached: 0, waves: [], picks: [], mods: {} };

test('a fresh alive cap contributes timed waves, its final clock and a successful manifest row', async (t) => {
  const out = workspace(t);
  const launch = (argv, io) => {
    const n = Number(argv.find((arg) => arg.startsWith('--seed=')).slice(7));
    const file = argv.find((arg) => arg.startsWith('--result=')).slice(9);
    writeFileSync(file, JSON.stringify({ ...skeleton, seed: n, wave_reached: 2,
      waves: [{ n: 1, seconds: 12 }, { n: 2 }], ...(n === 1 && { ticks: 120 }) }));
    const log = join(out, 'engine-' + n + '.log');
    writeFileSync(log, '[INFO] gauntlet: tick 60, segment 0\n'
      + '[INFO] gauntlet: tick 180, segment 2\n'
      + (n === 3 ? '[ERROR] gauntlet: headless tick cap reached before run ended\n' : ''));
    io.out('run: log ' + log);
    if (n === 3) io.out('FAIL exit 1 (fail); SCRIPT ERROR 0; unknown arg 0; result fresh');
    return n === 3 ? 1 : 0;
  };
  const doc = await batch(parseArgs(['--seeds=3', '--profile=average', '--pick=greedy', '--out=' + out]), {
    launch, out() {}, err() {}
  });
  assert.equal(doc.speed.sim_s, 2 + 3 + 3);
  assert.ok(doc.speed.sim_per_wall > 0);
  assert.equal(doc.runs[2].outcome, 'capped');
  assert.ok(doc.runs.every((r) => r.ok));
  assert.deepEqual(doc.results[2].waves, [{ n: 1, seconds: 12 }, { n: 2 }]);
});

function workspace(t) {
  const base = join(ROOT, 'build', 'gauntlet', 'tests');
  mkdirSync(base, { recursive: true });
  const dir = mkdtempSync(join(base, 'batch-'));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  return dir;
}

test('job cap, unsigned seed range, human imports and profile expansion', () => {
  assert.throws(() => parseArgs([...args, '--jobs=3']), /shared by four lanes/);
  for (const flag of ['--jobs=0', '--jobs=1.5', '--waves=-2', '--seed0=4294967295', '--unknown'])
    assert.throws(() => parseArgs([...args, flag]));
  assert.throws(() => parseArgs([...args, '--runner=pit', '--controls=wheel']), /legacy only/);
  assert.throws(() => parseArgs(['--seeds=1', '--profile=human', '--pick=random']), /profile/);
  const options = parseArgs([...args, '--seed0=0', '--jobs=2']);
  assert.deepEqual([...plan(options)].map((j) => [j.profile, j.seed]),
    [['novice', 0], ['novice', 1], ['average', 0], ['average', 1], ['expert', 0], ['expert', 1]]);
  assert.equal(parseArgs(args).jobs, 1);
  assert.equal(parseArgs(args).controls, 'wheel');
  assert.equal(parseArgs([...args, '--runner=pit']).controls, 'legacy');
  assert.equal(parseArgs([...args, '--controls=legacy']).controls, 'legacy');
  assert.equal(validateRun({ ...skeleton, profile: 'human' }), null);
});

test('wire validation preserves unavailable metrics and measured zeroes', () => {
  const wave = { n: 1, shots: 0, form_seconds: { kerf: 0 } };
  const valid = { ...skeleton, wave_reached: 1, death: { wave: 1 }, waves: [wave] };
  assert.equal(validateRun(skeleton), null);
  assert.equal(validateRun(valid), null);
  assert.deepEqual(wave, { n: 1, shots: 0, form_seconds: { kerf: 0 } });
  for (const key of Object.keys(skeleton)) {
    const copy = { ...skeleton };
    delete copy[key];
    assert.match(validateRun(copy), new RegExp(key));
  }
  for (const bad of [{ n: 1, hits: null }, { n: 1, seconds: -1 }, { n: 1, shots: 1.2 },
    { n: 1, enemies: { cop: '1' } }, { n: 1, form_seconds: { kerf: NaN } }, { n: 2 }])
    assert.ok(validateRun({ ...valid, waves: [bad] }));
  assert.match(validateRun({ ...valid, waves: [wave, wave] }), /unique/);
  for (const offered of [['a', 'a', 'b'], ['a', 'b'], ['a', 'b', 'c']])
    assert.ok(validateRun({ ...valid, picks: [{ wave: 1, offered, taken: 'unknown' }] }));
});

test('offline manifest includes provenance and failed input while omitting missing measurements', async (t) => {
  const out = workspace(t);
  const messages = [], failures = [];
  const doc = await batch(parseArgs(['--from=' + fixtureDir, '--profile=all', '--pick=random', '--out=' + out]), {
    launch: () => assert.fail('offline invoked Godot'), out: (s) => messages.push(s), err: (s) => failures.push(s)
  });
  assert.equal(doc.schema, 'gtai.gauntlet-batch/1');
  assert.equal(doc.results.length, 24);
  assert.equal(doc.runs.length, 25);
  assert.equal(doc.speed.wall_s, null);
  assert.equal(doc.speed.sim_per_wall, null);
  assert.match(doc.git.sha, /^[0-9a-f]{40}$/);
  assert.equal(typeof doc.git.dirty, 'boolean');
  assert.match(doc.tables['test_player.json'], /^[0-9a-f]{64}$/);
  assert.equal(doc.weapon_refs.weapon_pistol, 'pistol');
  assert.deepEqual(messages, ['novice: 8/8 ok, median wave reached 4, median seconds per wave 22',
    'average: 8/9 ok, median wave reached 5, median seconds per wave 19',
    'expert: 8/8 ok, median wave reached 6, median seconds per wave 15']);
  assert.equal(failures.length, 1);
  const bad = doc.runs.find((r) => !r.ok);
  assert.match(bad.reason, /waves/);
  assert.equal(bad.seed, 9);
  assert.ok(existsSync(resolve(out, bad.file)));
  const first = doc.results.find((r) => r.profile === 'average' && r.seed === 8).waves[0];
  assert.equal('seconds' in first, false);
  assert.equal('hits' in first, false);
  assert.deepEqual(JSON.parse(readFileSync(join(out, 'batch.json'), 'utf8')), doc);
});

test('dry run prints six reproducible commands without creating results', (t) => {
  const dir = join(workspace(t), 'unused path');
  const stdout = execFileSync(process.execPath, [join(ROOT, 'tools/gauntlet/batch.mjs'), '--dry-run',
    '--seeds=2', '--profile=all', '--pick=greedy', '--out=' + dir], { encoding: 'utf8' });
  const lines = stdout.trim().split(/\r?\n/);
  assert.equal(lines.length, 6);
  assert.match(lines[0], /^node tools\/dev\/run.mjs gauntlet --seed=1 --bot=novice --pick=greedy /);
  assert.ok(lines[5].endsWith("'--result=" + join(dir, 'runs', 'expert-2.json') + "'"));
  assert.equal(existsSync(dir), false);
});

test('live pool records every exit and log, rejects the wrong seed, and continues', async (t) => {
  const out = workspace(t);
  let active = 0, peak = 0;
  async function launch(argv, io) {
    active++;
    peak = Math.max(peak, active);
    await new Promise((r) => setTimeout(r, 10));
    active--;
    const get = (name) => argv.find((arg) => arg.startsWith('--' + name + '=')).split('=').slice(1).join('=');
    const n = Number(get('seed'));
    if (n === 2) { io.err('engine timeout'); return 1; }
    if (n === 3) throw new Error('spawn failed');
    const file = get('result');
    mkdirSync(dirname(file), { recursive: true });
    writeFileSync(file, JSON.stringify({ ...skeleton, profile: get('bot'), seed: n === 4 ? 99 : n, sim_s: 12 }));
    return 0;
  }
  const doc = await batch(parseArgs(['--profile=average', '--pick=random', '--seeds=5', '--jobs=2', '--out=' + out]),
    { launch, out() {}, err() {} });
  assert.equal(peak, 2);
  assert.deepEqual(doc.runs.map((r) => r.exit), [0, 1, null, 0, 0]);
  assert.deepEqual(doc.results.map((r) => r.seed), [1, 5]);
  assert.match(doc.runs[1].reason, /timeout/);
  assert.match(doc.runs[2].reason, /spawn failed/);
  assert.match(doc.runs[3].reason, /seed/);
  assert.ok(doc.runs.every((r) => r.wall_s > 0 && existsSync(join(out, r.log))));
  assert.equal(doc.speed.sim_s, 24);
  assert.equal(doc.speed.sim_per_wall, null); // Wall time includes failed, unmeasured simulation.
});
