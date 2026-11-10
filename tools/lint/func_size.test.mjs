// lint's gd-size function count (tools/style/check_gd.mjs longFunctions): signature to last body line.
import assert from 'node:assert/strict';
import test from 'node:test';
import { FUNC_MAX_LINES, longFunctions } from '../style/check_gd.mjs';

const body = (n) => Array.from({ length: n }, (_, k) => `\tvar v${k}: int = ${k}`);
const fn = (name, n) => [`func ${name}() -> void:`, ...body(n - 1)];

test('a function of exactly the cap passes, one line more fails', () => {
  assert.deepEqual(longFunctions(fn('a', FUNC_MAX_LINES)), []);
  assert.deepEqual(longFunctions(fn('a', FUNC_MAX_LINES + 1)), [{ name: 'a', lines: FUNC_MAX_LINES + 1 }]);
});

test('the next function\'s doc comment is not counted in the one above it (combat n15 FRICTION)', () => {
  const src = [...fn('a', FUNC_MAX_LINES), '', '', '## doc one', '## doc two', '## doc three', ...fn('b', 3)];
  assert.deepEqual(longFunctions(src), []);
});

test('a column-0 comment between functions, and blank lines, never lengthen a function', () => {
  const src = [...fn('a', FUNC_MAX_LINES), '', '# a section note', '', '@warning_ignore("unused")', ...fn('b', 2)];
  assert.deepEqual(longFunctions(src), []);
});

test('an indented comment inside the body still counts as a body line', () => {
  const src = [...fn('a', FUNC_MAX_LINES), '\t# the last word', '', ...fn('b', 2)];
  assert.deepEqual(longFunctions(src), [{ name: 'a', lines: FUNC_MAX_LINES + 1 }]);
});

test('a body line after a column-0 comment inside the function still counts', () => {
  const src = [...fn('a', FUNC_MAX_LINES - 1), '#\tcommented_out()', '\tvar z: int = 0', '', ...fn('b', 2)];
  assert.deepEqual(longFunctions(src), [{ name: 'a', lines: FUNC_MAX_LINES + 1 }]);
});
