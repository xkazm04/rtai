import test from 'node:test';
import assert from 'node:assert/strict';
import { layout } from './arsenal_turn.mjs';

test('old row above new, adjacent rest/fire pairs clockwise from east', () => {
  const cells = layout([{ label: 'old' }, { label: 'new' }]);
  assert.equal(cells.length, 32);
  for (const [i, cell] of cells.entries()) {
    const col = i % 16, row = Math.floor(i / 16), oct = Math.floor(col / 2);
    const pose = col % 2 ? 'fire' : 'rest';
    const dir = 'E SE S SW W NW N NE'.split(' ')[oct];
    assert.deepEqual([cell.row, cell.col, cell.stem, cell.caption],
      [row, col, 'oct' + oct + '_' + pose, [dir, pose, row ? 'new' : 'old'].join(' ')]);
  }
});
