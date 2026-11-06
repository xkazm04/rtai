import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { mkdtempSync, readFileSync, appendFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { classifyRerun, ledgerPath, quarantineCandidates, readLedger, recordFlake, reportText } from './flakes.mjs';

const tmp = () => join(mkdtempSync(join(tmpdir(), 'gtai-flakes-')), 'sub', 'flakes.jsonl');

test('ledgerPath honours GTAI_FLAKES_FILE, else LOCALAPPDATA', () => {
  assert.equal(ledgerPath({ GTAI_FLAKES_FILE: 'x/y.jsonl' }), 'x/y.jsonl');
  assert.match(ledgerPath({ LOCALAPPDATA: 'C:/L' }).replace(/\\/g, '/'), /C:\/L\/gtai\/flakes\.jsonl$/);
});

test('record then read round-trips; torn lines are skipped', () => {
  const p = tmp();
  recordFlake({ ts: 't1', test: 'test_a', file: 'res://f.gd' }, p);
  appendFileSync(p, '{"torn":\n');
  recordFlake({ ts: 't2', test: 'test_b', file: 'res://f.gd' }, p);
  assert.deepEqual(readLedger(p).map((e) => e.test), ['test_a', 'test_b']);
  assert.deepEqual(readLedger(`${p}.missing`), []);
});

test('quarantine candidates need >= 3 flakes of the same file+test', () => {
  const e = (test, file = 'f', ts = '1') => ({ test, file, ts });
  const c = quarantineCandidates([e('a'), e('a'), e('a', 'f', '9'), e('b'), e('b'), e('a', 'other')]);
  assert.deepEqual(c.map((x) => [x.test, x.count, x.last]), [['a', 3, '9']]);
  assert.match(reportText([e('a'), e('a'), e('a')]), /3x f a/);
  assert.match(reportText([e('a')]), /0 test\(s\)/);
});

test('two processes appending 500 lines each yield 1000 valid lines', async () => {
  const p = tmp();
  const url = new URL('./flakes.mjs', import.meta.url).href;
  const code = `import(${JSON.stringify(url)}).then(({recordFlake})=>{for(let i=0;i<500;i++)`
    + `recordFlake({ts:String(i),test:'t'+process.argv[1],file:'res://pad/'+'x'.repeat(200)},${JSON.stringify(p)});})`;
  const run = (id) => new Promise((done, fail) => {
    const c = spawn(process.execPath, ['-e', code, id], { stdio: 'ignore' });
    c.on('exit', (s) => (s === 0 ? done() : fail(new Error(`child ${id} exit ${s}`))));
  });
  await Promise.all([run('A'), run('B')]);
  const lines = readFileSync(p, 'utf8').split('\n').filter(Boolean);
  assert.equal(lines.length, 1000);
  assert.ok(lines.every((l) => JSON.parse(l).test.startsWith('t')));
  assert.equal(readLedger(p).filter((e) => e.test === 'tA').length, 500);
});

test('classifyRerun: pass on re-run is flaky, fail or missing stays failing', () => {
  const c = (name, status = 'fail') => ({ file: 'res://f.gd', name, status });
  const r = classifyRerun([c('a'), c('b'), c('d')], [c('a', 'pass'), c('b'), c('x', 'pass')]);
  assert.deepEqual(r.flaky.map((x) => x.name), ['a']);
  assert.deepEqual(r.failing.map((x) => x.name), ['b', 'd']);
});
