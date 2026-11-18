import assert from 'node:assert/strict';
import { test } from 'node:test';
import { filterMutantsByLines, parseArgs, UsageError } from './mutate.mjs';
import { sampleMutants } from './operators.mjs';

const options = (...args) => parseArgs(['--file=a.gd', ...args]);
const mutants = [10, 40, 50, 60, 63, 63, 104, 120].map((line, id) => ({ line, id }));

test('line lists accept positive integers and ascending inclusive ranges', () => {
  assert.deepEqual(options('--lines=63,104,40-60').lines, [[63, 63], [104, 104], [40, 60]]);
  for (const bad of ['', '0', '-1', '1.5', '1,,2', '1,', 'x', '2-', '3-2', '2-3-4', '1-9007199254740992']) {
    assert.throws(() => options(`--lines=${bad}`), UsageError, bad);
  }
});

test('line filtering keeps all matching mutants once in source order before sampling', () => {
  assert.equal(filterMutantsByLines(mutants, options().lines), mutants);
  const o = options('--max=2', '--lines=104,40-63,63');
  const selected = filterMutantsByLines(mutants, o.lines);
  assert.deepEqual(selected, mutants.slice(1, 7));
  assert.deepEqual(sampleMutants(selected, o.max, o.file), sampleMutants(mutants.slice(1, 7), 2, 'a.gd'));
});

test('unmatched lines report the requested ranges and their nearest populated neighbors', () => {
  assert.throws(() => filterMutantsByLines(mutants, options('--lines=1,52-58,130').lines),
    { name: 'Error', message: /--lines=1,52-58,130 matches no mutants; nearest mutant lines: 10, 50, 60, 120$/ });
  assert.throws(() => filterMutantsByLines([], [[9, 9]]), UsageError);
});
