import assert from 'node:assert/strict';
import { resolve } from 'node:path';
import { test } from 'node:test';
import { ROOT } from '../lib/repo.mjs';
import { applyEdit, summarize } from './ablate.mjs';
import { editNumber, parseAblation } from './ablate_args.mjs';
import { parseArgs, plan } from './commands.mjs';

const batch = ['--', '--profile=average', '--pick=greedy', '--seeds=2', '--jobs=1', '--out=evidence/arm'];
const set = '--set=project/data/tables/combat.json#/rivet/repair_per_s=0';

test('control takes no edits; repeatable sets and filter are passed to the intended batch', () => {
  assert.deepEqual(parseAblation(['--name=base', ...batch]).edits, []);
  const opts = parseAblation(['--name=example', set, '--set=x.json#/a=-1.25e1', '--pick-filter=stat_', ...batch]);
  assert.equal(opts.edits.length, 2);
  assert.deepEqual(opts.edits[1], { file: 'x.json', pointer: '/a', value: -12.5 });
  const parsed = parseArgs(opts.batchArgs);
  assert.equal(parsed.out, resolve('evidence/arm'));
  assert.ok([...plan(parsed)].every((j) => j.argv.includes('--pick-filter=stat_')));
  for (const flags of [['--name=bad/name'], ['--name=x', '--set=../x.json#/k=1'],
    ['--name=x', '--set=C:\\temp\\x.json#/k=1'], ['--name=x', '--set=x.json#/k=Infinity'],
    ['--name=x', '--set=x.json#/k~2=1'], ['--name=x', '--pick-filter=']])
    assert.throws(() => parseAblation([...flags, ...batch]));
});

test('numeric edits support arrays and escaped JSON pointer tokens', () => {
  const data = { 'a/b': [{ '~rate': 10, intact: 2 }] };
  assert.equal(editNumber(data, { pointer: '/a~1b/0/~0rate', value: 0 }), 10);
  assert.deepEqual(data, { 'a/b': [{ '~rate': 0, intact: 2 }] });
  for (const pointer of ['/a~1b/length', '/a~1b/00', '/missing', '/toString', '/a~1b/0'])
    assert.throws(() => editNumber(data, { pointer, value: 1 }));
});

test('edit refuses the caller checkout before it reads or writes the target', () => {
  assert.throws(() => applyEdit(ROOT, ROOT, { file: 'x.json', pointer: '/v', value: 1 }), /repo root/);
});

test('a timeout with living HP is distinguished from a lethal hit', () => {
  const results = [{ wave_reached: 9 }, { wave_reached: 5, death: { by: 'rifle', wave: 5 } },
    { wave_reached: 2, death: { by: 'timeout', wave: 2 } }];
  assert.deepEqual(summarize({ results, runs: [{ ok: true, outcome: 'capped' }, { ok: true }, { ok: true }] }),
    { attempted: 3, accepted: 3, deaths: 1, median_wave_reached: 5, median_death_wave: 5,
      capped_alive: 1, wave_timeouts: 1 });
});
