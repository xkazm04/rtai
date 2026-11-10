import assert from 'node:assert/strict';
import { basename } from 'node:path';
import test from 'node:test';
import { gateLines, SUMMARY_MAX } from './gate_lines.mjs';

const HEAD = '76ed5809e33b921875c82e77c7dd2a0c393acc30';
const ev = (kind, extra = {}) => JSON.stringify({ schema: 'pof.godot-evidence/1', kind, commit: HEAD, status: 'pass', summary: `${kind}: ok`, ...extra });
const fake = (files) => ({ list: () => Object.keys(files), read: (f) => files[basename(f)] });

test('one line per evidence kind, sorted, with its status and summary', () => {
  const lines = gateLines('E', HEAD, fake({ 'unit-tests.json': ev('unit-tests', { summary: 'unit-tests: 2529 passed, 0 failed' }), 'lint.json': ev('lint') }));
  assert.deepEqual(lines, ['morning: gates: lint pass: lint: ok', 'morning: gates: unit-tests pass: unit-tests: 2529 passed, 0 failed']);
});

test('a kind written for another commit is STALE, never shown as this run\'s pass', () => {
  const [line] = gateLines('E', HEAD, fake({ 'parity.json': ev('parity', { commit: 'eb65c8b05aaaa' }) }));
  assert.match(line, /^morning: gates: parity STALE \(written for eb65c8b05\)/);
  assert.doesNotMatch(line, / pass:/);
});

test('a short commit in the file still matches the full head', () => {
  assert.match(gateLines('E', HEAD, fake({ 'a.json': ev('a', { commit: HEAD.slice(0, 9) }) }))[0], / a pass:/);
});

test('other json, broken json and non-evidence schemas are skipped; none at all is said', () => {
  const files = { 'parity-result.json': '{"final_sha_a":"x"}', 'broken.json': '{', 'notes.txt': 'x', 'other.json': JSON.stringify({ schema: 'gtai.x/1', kind: 'k' }) };
  assert.deepEqual(gateLines('E', HEAD, fake(files)), ['morning: gates: no pof.godot-evidence/1 evidence in E']);
});

test('a long summary is cut to one line', () => {
  const [line] = gateLines('E', HEAD, fake({ 's.json': ev('selftest', { summary: `a\n${'x'.repeat(500)}` }) }));
  assert.ok(!line.includes('\n'));
  assert.ok(line.endsWith('...') && line.length < SUMMARY_MAX + 60);
});
