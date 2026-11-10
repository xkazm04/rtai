// node --test tools/tests/ - the scenario and bench runners refuse arguments they cannot honour
// (a NaN --quiet-wait / --wait used to wait forever on a busy machine; a typo ran the default).
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { parseArgs as scenarioArgs } from './run_scenarios.mjs';
import { parseArgs as benchArgs } from '../bench/run.mjs';

test('run_scenarios: defaults, minutes and a name list', () => {
  assert.deepEqual(scenarioArgs([]), {});
  assert.deepEqual(scenarioArgs(['--quiet-wait=2.5', '--only=city_chase,rig_stress']),
    { quietWaitMs: 150000, only: ['city_chase', 'rig_stress'] });
  assert.deepEqual(scenarioArgs(['--quiet-wait=0']), { quietWaitMs: 0 });
});

test('run_scenarios: a malformed wait, an empty --only or an unknown flag is a usage error', () => {
  for (const bad of [['--quiet-wait=5m'], ['--quiet-wait='], ['--quiet-wait=-1'], ['--only='], ['--onyl=x'], ['extra']]) {
    assert.throws(() => scenarioArgs(bad), { name: 'UsageError' }, bad.join(' '));
  }
});

test('bench: defaults and numbers', () => {
  assert.deepEqual(benchArgs([]), { headless: false, secs: 60, runs: 3, waitMin: 20 });
  assert.deepEqual(benchArgs(['--headless', '--secs=30', '--runs=1', '--wait=0']), { headless: true, secs: 30, runs: 1, waitMin: 0 });
});

test('bench: NaN, zero runs or secs, and unknown flags are usage errors', () => {
  for (const bad of [['--wait=20m'], ['--wait=-1'], ['--secs=abc'], ['--secs=0'], ['--runs=0'], ['--runs=1.5'], ['--headles'], ['--secs']]) {
    assert.throws(() => benchArgs(bad), { name: 'UsageError' }, bad.join(' '));
  }
});

test('run_parity takes no arguments; release_compile only --dir=, --src= and --keep', async () => {
  const { parseArgs: parityArgs } = await import('./run_parity.mjs');
  const { parseArgs: releaseArgs } = await import('./release_compile.mjs');
  assert.deepEqual(parityArgs([]), {});
  assert.throws(() => parityArgs(['--steps=100']), { name: 'UsageError' }, 'a step count it would silently ignore');
  assert.deepEqual(releaseArgs(['--dir=C:/t/x', '--src=p', '--keep']), { dir: 'C:/t/x', src: 'p', keep: true });
  assert.deepEqual(releaseArgs([]), { dir: undefined, src: undefined, keep: false });
  for (const bad of [['--dri=x'], ['--dir='], ['--keep=no'], ['x']]) {
    assert.throws(() => releaseArgs(bad), { name: 'UsageError' }, bad.join(' '));
  }
});

test('run_unit --failed: re-runs exactly the files that failed in the previous junit; no report is a usage error', async () => {
  const { UsageError, buildPlan, parseArgs: unitArgs } = await import('./run_unit.mjs');
  assert.equal(unitArgs(['--failed']).failed, true);
  assert.equal(unitArgs([]).failed, false);
  assert.throws(() => unitArgs(['--failed=x']), (e) => e instanceof UsageError);
  const tests = { 'tests/unit/test_a.gd': '', 'tests/unit/test_b.gd': '', 'tests/unit/test_c.gd': '' };
  const index = { tests, classNames: () => [] };
  const tc = (name, fail) => `<testcase name="${name}" status="${fail ? 'fail' : 'pass'}" time="0.1" >${fail ? '<failure message="failed"><![CDATA[x\nat line 3]]></failure>' : ''}</testcase>`;
  const suite = (f, ...cases) => `<testsuite name="tests/unit/${f}.gd" >${cases.join('')}</testsuite>`;
  const prev = `<testsuites>${suite('test_a', tc('test_1', true), tc('test_2', false))}${suite('test_b', tc('test_3', true))}${suite('test_c', tc('test_4', false))}</testsuites>`;
  const plan = buildPlan(unitArgs(['--failed']), index, [], null, prev);
  assert.deepEqual(plan.files, ['tests/unit/test_a.gd', 'tests/unit/test_b.gd']);
  assert.equal(plan.targeted, true);
  assert.equal(plan.testName, null, 'two different failing names: the files run whole');
  const one = `<testsuites>${suite('test_a', tc('test_1', true))}</testsuites>`;
  assert.equal(buildPlan(unitArgs(['--failed']), index, [], null, one).testName, 'test_1');
  assert.throws(() => buildPlan(unitArgs(['--failed']), index, [], null, null),
    (e) => e instanceof UsageError && /no previous unit run to re-run/.test(e.message));
});

test('run_unit --select: an unmatched name is said with the nearest stem, the rest run, and the plan carries it (hero n11 REQUEST)', async () => {
  const { UsageError, buildPlan, parseArgs: unitArgs, selectMiss } = await import('./run_unit.mjs');
  const tests = { 'tests/unit/test_rivet_x15.gd': '', 'tests/unit/test_ghost_stride.gd': '', 'tests/unit/test_ghost_drawn.gd': '' };
  const index = { tests, classNames: () => [] };
  const plan = buildPlan(unitArgs(['--select=test_rivet_x15,test_ghost_strid']), index, []);
  assert.deepEqual(plan.files, ['tests/unit/test_rivet_x15.gd']);
  assert.deepEqual(plan.unmatched, ['test_ghost_strid']);
  assert.match(plan.notes.join('\n'), /--select=test_ghost_strid matches no test file \(did you mean test_ghost_stride\?\): the other 1 file\(s\) run, and this run cannot pass/);
  assert.deepEqual(buildPlan(unitArgs(['--select=test_ghost_*']), index, []).unmatched, [], 'a matching glob leaves nothing unmatched');
  assert.throws(() => buildPlan(unitArgs(['--select=nope_at_all,ghost_strid']), index, []),
    (e) => e instanceof UsageError && /nope_at_all matches no test file;/.test(e.message) && /did you mean test_ghost_stride/.test(e.message),
    'nothing matched: still a usage error, now with the suggestion');
  const all = Object.keys(tests);
  assert.equal(selectMiss('rivet', all), '--select=rivet matches no test file (did you mean test_rivet_x15?)', 'a substring of a stem');
  assert.equal(selectMiss('zzzz_unrelated', all), '--select=zzzz_unrelated matches no test file', 'nothing near: no guess');
  assert.equal(selectMiss('ghost_*x', all), '--select=ghost_*x matches no test file', 'a glob gets no substring guess');
});
