import assert from 'node:assert/strict';
import test from 'node:test';
import { drawText } from './font.mjs';
import { cellLabel, movieSpan, reelPlan } from './kill_reel_lib.mjs';
import { label } from './sheet.mjs';

const background = 0x18;
const canvas = (width, height = 24) => ({ width, pixels: Buffer.alloc(width * height * 3, background) });
const pixel = ({ width, pixels }, x, y) => [...pixels.subarray((y * width + x) * 3, (y * width + x) * 3 + 3)];

test('quick true changes both defaults while either named --dirs or --ppm wins independently', () => {
  const plan = (flags) => reelPlan({ out: 'out', weapons: 'katana', quick: true, ...flags }, []);
  assert.deepEqual([plan({}).ppm, plan({}).dirs], [[32], [90]]);
  assert.deepEqual([plan({ dirs: '0,wall' }).ppm, plan({ dirs: '0,wall' }).dirs], [[32], [0, 'wall']]);
  assert.deepEqual([plan({ ppm: '64' }).ppm, plan({ ppm: '64' }).dirs], [[64], [90]]);
  assert.deepEqual(plan({ dirs: 'wall' }).jobs, [
    { weapon: 'katana', victim: '', dir_deg: 'wall', ppm: 32 },
  ]);
});

test('quick with any value other than true is an error naming --quick; normal defaults remain a cross product', () => {
  for (const value of [false, 0, 1, '', 'true', null]) {
    assert.match(reelPlan({ out: 'out', weapons: 'katana', quick: value }, []).error, /--quick/);
  }
  const normal = reelPlan({ out: 'out', weapons: 'katana' }, []);
  assert.deepEqual([normal.ppm, normal.dirs], [[32, 64], [0]]);
  assert.deepEqual(normal.jobs, [
    { weapon: 'katana', victim: '', dir_deg: 0, ppm: 32 },
    { weapon: 'katana', victim: '', dir_deg: 0, ppm: 64 },
  ]);
});

test('cell labels handle a kill at tick zero, negative offsets, wall direction, and an empty victim', () => {
  const job = { side: 'before', victim: '', dir_deg: 'wall', ppm: 32 };
  const film = { kill: 0 };
  assert.equal(cellLabel(job, film, -3, 0), '-3 -3 before guard dwall 32');
  assert.equal(cellLabel(job, film, 0, 1), '0 kill');
  assert.equal(cellLabel(job, film, 4, 2), '4 +4');
});

test('cell labels append hs only for a positive numeric hitstop_frames measurement', () => {
  const job = { side: 'after', victim: 'thug', dir_deg: 90, ppm: 64 };
  for (const hitstop_frames of [0, null, undefined, -2, '6']) {
    const measured = { hitstop_frames };
    assert.equal(cellLabel(job, { kill: 0, measured }, 0, 1), '0 kill', String(hitstop_frames));
  }
  assert.equal(cellLabel(job, { kill: 0, measured: { hitstop_frames: 3 } }, 0, 1), '0 kill hs3');
});

test('drawText upper-cases strings, blanks spaces and unknown glyphs, accepts numbers, and counts whole advances', () => {
  const lower = canvas(100);
  const upper = canvas(100);
  assert.equal(drawText(lower.pixels, lower.width, 0, 0, 100, 'a ?z'), 4);
  assert.equal(drawText(upper.pixels, upper.width, 0, 0, 100, 'A ?Z'), 4);
  assert.deepEqual(lower.pixels, upper.pixels);
  for (let y = 2; y <= 15; y++) {
    for (let x = 14; x < 36; x++) assert.deepEqual(pixel(lower, x, y), [background, background, background]);
  }
  const number = canvas(40);
  assert.equal(drawText(number.pixels, number.width, 0, 0, 40, 42), 2);
  assert.ok(number.pixels.includes(255));
});

test('drawText clips at a nonzero cell edge and writes only rows top+2 through top+15', () => {
  const c = canvas(50, 30);
  assert.equal(drawText(c.pixels, c.width, 7, 5, 9, 'MW'), 0);
  for (let y = 0; y < 30; y++) {
    for (let x = 0; x < 50; x++) {
      if (x >= 7 && x < 16 && y >= 7 && y <= 20) continue;
      assert.deepEqual(pixel(c, x, y), [background, background, background], `${x},${y}`);
    }
  }
});

test('sheet label is drawText, including its whole-character return and decimal tick pixels', () => {
  const direct = canvas(64);
  const throughSheet = canvas(64);
  const directCount = drawText(direct.pixels, direct.width, 5, 3, 30, 123);
  const labelCount = label(throughSheet.pixels, throughSheet.width, 5, 3, 30, 123);
  assert.equal(labelCount, directCount);
  assert.deepEqual(throughSheet.pixels, direct.pixels);
});

test('movieSpan ignores row order, tolerates identical duplicate ticks, and includes held frames through to+1 minus one', () => {
  const probe = { rows: [
    { tick: 12, frame: 30 }, { tick: 10, frame: 20 }, { tick: 11, frame: 21 },
    { tick: 10, frame: 20 }, { tick: 13, frame: 36 },
  ] };
  assert.deepEqual(movieSpan(probe, 10, 12), [20, 35]);
});

test('movieSpan accepts frame zero, uses the to frame without to+1, and rejects missing or noninteger endpoints', () => {
  assert.deepEqual(movieSpan({ rows: [{ tick: 0, frame: 0 }, { tick: 1, frame: 7 }] }, 0, 1), [0, 7]);
  assert.equal(movieSpan({ rows: [{ tick: 0, frame: 0.5 }, { tick: 1, frame: 7 }] }, 0, 1), null);
  assert.equal(movieSpan({ rows: [{ tick: 0, frame: 0 }, { tick: 1 }] }, 0, 1), null);
  assert.equal(movieSpan({ rows: [{ tick: 0, frame: 0 }] }, 0, 1), null);
});

test('movieSpan rejects a reversed from-to interval instead of returning a backwards clip', () => {
  const probe = { rows: [{ tick: 1, frame: 10 }, { tick: 2, frame: 20 }, { tick: 3, frame: 30 }] };
  assert.equal(movieSpan(probe, 3, 1), null);
});
