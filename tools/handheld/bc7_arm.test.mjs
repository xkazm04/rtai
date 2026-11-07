import { test } from 'node:test';
import assert from 'node:assert/strict';
import { toBc7 } from './bc7_arm.mjs';

test('a lossless texture import becomes BC7 high quality', () => {
  const src = '[remap]\n\nimporter="texture"\n\n[params]\n\ncompress/mode=0\ncompress/high_quality=false\n';
  const out = toBc7(src);
  assert.match(out, /^compress\/mode=2$/m);
  assert.match(out, /^compress\/high_quality=true$/m);
});

test('a non-texture import is left alone', () => {
  const src = 'importer="wav"\ncompress/mode=0\n';
  assert.equal(toBc7(src), src);
});
