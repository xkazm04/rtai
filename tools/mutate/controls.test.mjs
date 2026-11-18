import assert from 'node:assert/strict';
import { test } from 'node:test';
import { judgeControl, plantControl } from './controls.mjs';
import { UsageError } from './mutate.mjs';

test('each control starts from the original and plants only at the first eligible body', () => {
  const header = 'func first() -> void:\n';
  const body = '\tlog_call()\n\nfunc later() -> void:\n\tpass\n';
  const source = header + body;
  for (const [name, inserted] of [
    ['hang', '\twhile true: pass\n'],
    ['crash', '\tvar _crash: Array[int] = []\n\t_crash[1] = 0\n'],
    ['parse', '\tvar = \n'],
    ['clean', ''],
  ]) assert.equal(plantControl(source, name), header + inserted + body);
});

test('planting handles multiline static signatures, comments, CRLF and skipped bodies', () => {
  const header = ['const TEXT = """', 'func decoy():', '\tpass', '"""', 'func inline(): pass',
    'func spaces():', '    pass', 'static func target(', '\tx: int', ') -> Array[int]: # comment', ''].join('\r\n');
  const body = '\r\n\t# first statement follows\r\n\treturn [x]';
  assert.equal(plantControl(header + body, 'hang'), header + '\twhile true: pass\r\n' + body);
  for (const s of ['class_name Empty', 'func f(): pass', 'func f():\n    pass', 'func f():\n\t\tpass']) {
    assert.throws(() => plantControl(s, 'crash'), UsageError);
  }
});

test('controls require the verdict and its cause, and time the hang through the inclusive grace limit', () => {
  for (const [name, verdict, via] of [
    ['hang', 'timeout', 'timeout'], ['crash', 'killed', 'crash'], ['parse', 'invalid', 'parse'], ['clean', 'survived', 'ok'],
  ]) {
    const expected = `${verdict}/${via}`;
    assert.deepEqual(judgeControl(name, { verdict, via }, 75000, 60000), { expected, got: expected, pass: true });
    assert.equal(judgeControl(name, { verdict, via: 'golden' }, 1, 60000).pass, false);
    assert.equal(judgeControl(name, { verdict: 'unknown', via }, 1, 60000).pass, false);
  }
  assert.equal(judgeControl('hang', { verdict: 'timeout', via: 'timeout' }, 75001, 60000).pass, false);
  assert.equal(judgeControl('clean', { infra: 'unexpected exit' }, 1, 60000).pass, false);
});
