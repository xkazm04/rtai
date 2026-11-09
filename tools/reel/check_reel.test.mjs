import { test } from 'node:test';
import assert from 'node:assert/strict';
import { parseReel } from './check_reel.mjs';

const chapter = (name, a, b) => `[INFO] showcase: director chapter ${name} (${name}) at tick 0\n[INFO] showcase: director chapter ${name}: ${a}/${b} down\n`;

test('a clean reel is ok and counts its chapters', () => {
  const r = parseReel(chapter('pistol', 2, 2) + chapter('katana', 4, 4), { expect: 2 });
  assert.equal(r.chapters, 2);
  assert.equal(r.fullyDown, 2);
  assert.equal(r.ok, true);
  assert.deepEqual(r.problems, []);
});

test('the start-of-chapter line is not a chapter result', () => {
  assert.equal(parseReel('[INFO] showcase: director chapter pistol (pistol) at tick 360\n', { expect: 1 }).chapters, 0);
});

test('a chapter not fully down fails and is named', () => {
  const r = parseReel(chapter('pistol', 1, 2), { expect: 1 });
  assert.equal(r.ok, false);
  assert.match(r.problems.join(' '), /pistol/);
});

test('a zero-victim chapter is not fully down', () => {
  assert.equal(parseReel(chapter('pistol', 0, 0), { expect: 1 }).ok, false);
});

test('a short reel fails: fewer chapters than expected', () => {
  const r = parseReel(chapter('pistol', 2, 2), { expect: 19 });
  assert.equal(r.ok, false);
  assert.match(r.problems.join(' '), /19/);
});

test('SCRIPT ERROR fails and is counted', () => {
  const r = parseReel(`${chapter('pistol', 2, 2)}SCRIPT ERROR: Invalid call\nSCRIPT ERROR: again\n`, { expect: 1 });
  assert.equal(r.scriptErrors, 2);
  assert.equal(r.ok, false);
});

test('no carry fails: the chapter skipped its weapon', () => {
  const r = parseReel(`${chapter('pistol', 2, 2)}[INFO] showcase: no carry for pistol, skipped\n`, { expect: 1 });
  assert.equal(r.noCarry, 1);
  assert.equal(r.ok, false);
});

test('CRLF logs parse the same', () => {
  assert.equal(parseReel(chapter('pistol', 2, 2).replaceAll('\n', '\r\n'), { expect: 1 }).ok, true);
});
