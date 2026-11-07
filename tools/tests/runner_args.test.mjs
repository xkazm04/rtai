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
