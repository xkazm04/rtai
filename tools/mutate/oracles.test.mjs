import assert from 'node:assert/strict';
import { test } from 'node:test';
import { join } from 'node:path';
import { parseArgs, UsageError } from './mutate.mjs';
import { baseline, classifyBake, classifyTests, judgeMutant } from './oracles.mjs';
import { buildJson, formatReport } from './report.mjs';

const names = ['tests', 'bake-check'];
const survived = { durationMs: 100, verdict: 'survived', via: 'ok', status: 0, out: '' };
const golden = { durationMs: 200, verdict: 'killed', via: 'golden', detail: 'c_03_00.bin' };

test('oracle selection defaults to legacy tests and preserves explicit order', () => {
  const options = (...args) => parseArgs(['--file=a.gd', ...args]);
  assert.deepEqual(options().oracles, ['tests']);
  assert.equal(options().explicit, false);
  assert.equal(options('--oracle=tests').explicit, true);
  assert.deepEqual(options('--oracle=bake-check,tests').oracles, ['bake-check', 'tests']);
  for (const bad of ['', 'bake', 'tests,']) assert.throws(() => options(`--oracle=${bad}`), UsageError);
});

test('bake output is scored only on an explicit verdict or identified fault', () => {
  const classify = (status, out, timedOut = false) => classifyBake({ status, out, timedOut });
  const ok = 'bake_city: OK deterministic, matches golden\r\n';
  assert.deepEqual(classify(0, ok), { verdict: 'survived', via: 'ok' });
  for (const [record, via] of [['GOLDEN-DIFF', 'golden'], ['NONDETERMINISTIC', 'nondeterministic']]) {
    assert.deepEqual(classify(1, `engine\r\nbake_city: ${record} c_03_00.bin differs\r\n`),
      { verdict: 'killed', via, detail: 'c_03_00.bin' });
  }
  assert.deepEqual(classify(-1, 'SCRIPT ERROR: Invalid call'), { verdict: 'killed', via: 'crash' });
  assert.equal(classify(0, 'SCRIPT ERROR: Invalid call\n' + ok).via, 'crash');
  for (const cause of ['Parse Error', 'Failed to load script', 'Compile Error']) {
    assert.deepEqual(classify(-1, `SCRIPT ERROR: ${cause}\nSCRIPT ERROR: Invalid call`), { verdict: 'invalid', via: 'parse' });
  }
  assert.deepEqual(classify(-1, 'partial', true), { verdict: 'timeout', via: 'timeout' });
  for (const [status, out] of [[1, 'boom'], [0, ''], [1, ok], [0, 'prefix ' + ok]]) assert.ok(classify(status, out).infra);
});

test('a survivor reaches the next oracle with the remaining budget', async () => {
  const calls = [];
  const runner = (name, result) => (ms) => { calls.push([name, ms]); return result; };
  const result = await judgeMutant(names,
    { tests: runner('tests', survived), 'bake-check': runner('bake-check', golden) }, 1000);
  assert.deepEqual(calls, [['tests', 1000], ['bake-check', 900]]);
  assert.deepEqual(result, { oracle: 'bake-check', verdict: 'killed', via: 'golden', detail: 'c_03_00.bin', ms: 300 });
  for (const end of [{ verdict: 'killed' }, { verdict: 'invalid' }, { verdict: 'timeout' }, { infra: 'exit 2' }]) {
    const stop = await judgeMutant(names, { tests: () => ({ durationMs: 90, ...end }) }, 100);
    assert.equal(stop.oracle, 'tests');
    assert.equal(stop.verdict, end.verdict);
  }
  const timeout = await judgeMutant(names, { tests: () => survived }, 100);
  assert.equal(timeout.verdict, 'timeout');
  assert.equal(timeout.ms, 100);
});

test('explicit tests preserve the failing count and distinguish a runtime crash', () => {
  const raw = { status: 1, out: 'unit-tests: 1 passed, 2 failed' };
  assert.deepEqual(classifyTests(raw, true), { verdict: 'killed', via: 'tests', detail: '2 failing test(s)' });
  assert.deepEqual(classifyTests(raw, false), { verdict: 'killed', via: '2 failing test(s)' });
  assert.deepEqual(classifyTests({ status: 1, out: 'SCRIPT ERROR: Invalid call' }, true), { verdict: 'killed', via: 'crash' });
});

test('a premature SceneTree quit needs evidence that GUT entered a test', () => {
  const raw = { status: 1, out: 'unit-tests: gut exit 1; no JUnit report; zero tests ran (0 passed, 0 failed, 0 skipped)' };
  const log = '===== gut (exit 1, 2.4 s)\n---  GUT  ---\nres://tests/unit/test_game.gd\n* test_save\n';
  assert.match(classifyTests(raw, false, log).via, /exited during test_save/);
  assert.equal(classifyTests(raw, true, log).verdict, 'killed');
  assert.ok(classifyTests(raw, true).infra);
  assert.ok(classifyTests(raw, true, log.replace('* test_save', '')).infra);
  assert.ok(classifyTests(raw, true, log + '= Run Summary\n').infra);
  assert.ok(classifyTests({ ...raw, out: raw.out.replace('gut exit 1', 'import exit 1; gut exit 1') }, true, log).infra);
});

test('each baseline must pass before mutation, import is separate from the bake cap', async () => {
  const calls = [];
  const wt = 'scratch';
  const options = { names, wt, timeoutS: 0, note: () => {}, explicit: true,
    importProject: ({ projectDir }) => { calls.push(projectDir); return { imported: true, status: 0, durationMs: 999 }; },
    runners: { tests: () => { calls.push('tests'); return survived; },
      'bake-check': () => { calls.push('bake-check'); return { ...survived, durationMs: 41000 }; } } };
  assert.deepEqual(await baseline(options), { durationMs: 41100, firstImportMs: 999, timeoutMs: 213000 });
  assert.deepEqual(calls, ['tests', join(wt, 'project'), 'bake-check']);
  assert.equal((await baseline({ ...options, timeoutS: 3 })).timeoutMs, 3000);
  const contendedBake = await baseline({ ...options, names: ['bake-check'],
    runners: { 'bake-check': () => ({ ...survived, durationMs: 20700 }) } });
  assert.equal(contendedBake.timeoutMs, 120000);
  await assert.rejects(baseline({ ...options, runners: { ...options.runners, 'bake-check': () => ({ ...golden, status: 1, out: 'diff' }) } }),
    /baseline red: bake-check: golden.*nothing mutated/);
});

const mutant = { id: 1, line: 9, col: 2, op: 'literal', before: '1', after: '0', ms: 200 };
const report = { file: 'core/a.gd', tests: ['test_a'], head: 'abc', totalMs: 1200, baselineMs: 600, total: 3, max: 2 };

test('default report matches the original text and JSON fields exactly', () => {
  const results = [{ ...mutant, verdict: 'killed', via: '2 failing test(s)', oracle: 'tests' },
    { ...mutant, id: 2, line: 10, verdict: 'survived', via: 'all tests passed', oracle: 'tests' }];
  assert.equal(formatReport({ ...report, results, sampled: 3 }), [
    'mutate core/a.gd: 2 mutant(s) (sampled from 3), tests: test_a',
    '  core/a.gd:10 literal  1 -> 0  survived',
    '  core/a.gd:9 literal  1 -> 0  killed',
    'score 50.0% = killed 1 / (killed 1 + survived 1); timeout 0, invalid 0; 1 s',
  ].join('\n'));
  assert.deepEqual(buildJson({ ...report, results }), {
    schema: 'gtai.mutate/1', file: report.file, head: 'abc', tests: ['test_a'],
    counts: { killed: 1, survived: 1, timeout: 0, invalid: 0 }, score: 0.5, mutants_total: 3, max: 2,
    baseline_ms: 600, first_import_ms: null, total_ms: 1200, mutants: results.map(({ oracle, ...fields }) => fields),
  });
});

test('explicit reports attribute kills, list all surviving oracles, and exclude setup from mean cost', () => {
  const results = [{ ...mutant, ...golden, oracle: 'bake-check' },
    { ...mutant, verdict: 'killed', via: 'tests', detail: '2 failing test(s)', oracle: 'tests' },
    { ...mutant, ...survived, oracle: 'bake-check' }];
  const args = { ...report, results, oracles: names };
  const text = formatReport(args);
  for (const label of ['killed [bake-check: golden c_03_00.bin]', 'killed [tests: 2 failing test(s)]',
    'survived [tests, bake-check]', '0.20 s/mutant', 'kills by oracle: tests 1, bake-check 1', 'by via: golden 1, tests 1']) {
    assert.ok(text.includes(label), label);
  }
  const json = buildJson(args);
  assert.deepEqual(json.oracles, names);
  assert.deepEqual(json.mutants.map((m) => m.oracle), ['bake-check', 'tests', 'bake-check']);
  assert.equal(json.mutants[0].detail, 'c_03_00.bin');
});
