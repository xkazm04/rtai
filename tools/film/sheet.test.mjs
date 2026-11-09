import assert from 'node:assert/strict';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import test from 'node:test';
import { deflateSync } from 'node:zlib';
import { decodePng } from './png.mjs';
import { EXIT, GUTTER, LABEL_H, MAX_SIDE, main, parseArgv } from './sheet.mjs';

// Independent fixture encoder: filter-zero rows and bitwise CRC (no production helpers).
function png(width, height, pixel, channels = 3) {
  const chunk = (name, body) => {
    const bytes = Buffer.concat([Buffer.from(name), body]);
    let crc = 0xffffffff;
    for (const byte of bytes) {
      crc ^= byte;
      for (let bit = 0; bit < 8; bit++) crc = (crc >>> 1) ^ (crc & 1 ? 0xedb88320 : 0);
    }
    const result = Buffer.alloc(body.length + 12);
    result.writeUInt32BE(body.length);
    bytes.copy(result, 4);
    result.writeUInt32BE((crc ^ 0xffffffff) >>> 0, result.length - 4);
    return result;
  };
  const header = Buffer.alloc(13);
  header.writeUInt32BE(width);
  header.writeUInt32BE(height, 4);
  header[8] = 8;
  header[9] = channels === 4 ? 6 : 2;
  const stride = width * channels + 1;
  const raw = Buffer.alloc(stride * height);
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) raw.set(pixel(x, y), y * stride + 1 + x * channels);
  }
  return Buffer.concat([Buffer.from('89504e470d0a1a0a', 'hex'), chunk('IHDR', header),
    chunk('IDAT', deflateSync(raw)), chunk('IEND', Buffer.alloc(0))]);
}

function fixture(t) {
  const dir = mkdtempSync(join(tmpdir(), 'gtai-sheet-test-'));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  const output = join(dir, 'nested', 'sheet.png');
  const frame = (tick, width = 32, height = 3, pixel = () => [Number(BigInt(tick) % 256n), 20, 30], channels = 3) => {
    writeFileSync(join(dir, `t${tick}.png`), png(width, height, pixel, channels));
  };
  const run = async (...args) => {
    const out = [], err = [];
    const code = await main([dir, `--out=${output}`, ...args], { out: (s) => out.push(s), err: (s) => err.push(s) });
    return { code, out: out.join('\n'), err: err.join('\n') };
  };
  return { dir, output, frame, run };
}

const pixelAt = (image, x, y) => [...image.data.subarray((y * image.width + x) * 3, (y * image.width + x) * 3 + 3)];

test('exports and validated arguments', () => {
  assert.deepEqual(EXIT, { pass: 0, fail: 1, usage: 2, unverifiable: 3 });
  assert.deepEqual([GUTTER, LABEL_H, MAX_SIDE], [4, 18, 16384]);
  const parsed = parseArgv(['film', '--out=o.png', '--ticks=10,2-4,3-5', '--crop=0,1,9,8', '--cols=3', '--shrink=2']);
  assert.deepEqual(parsed, { dir: 'film', flags: { out: 'o.png', ticks: [[2n, 5n], [10n, 10n]], crop: [0, 1, 9, 8], cols: 3, shrink: 2 } });
  for (const args of [[], ['film'], ['--out=o.png'], ['film', '--out='], ['film', '--out'],
    ['film', '--out=o.png', 'extra'], ['film', '--out=o.png', '--help'], ['film', '--out=o'],
    ['film', '--out=../JOURNAL.md'], ['film', '--out=film/t333.png']]) assert.ok(parseArgv(args).error, args.join(' '));
  for (const flag of ['--cols=0', '--cols=-1', '--cols=1.5', '--cols=1e2', '--cols=9007199254740992',
    '--shrink=0', '--shrink=NaN', '--shrink=2.5', '--ticks=3-2', '--ticks=1,', '--ticks=-1', '--ticks=1.5',
    '--ticks=1--2', '--crop=0,0,0,1', '--crop=-1,0,2,2', '--crop=0,0,1.5,2', '--crop=1,2,3', '--crop=0,0,2,2,2']) {
    assert.ok(parseArgv(['film', '--out=o.png', flag]).error, flag);
  }
});

test('numeric order, full pixel preservation, exact gutters, labels, empty cell and deterministic PNG', async (t) => {
  const f = fixture(t);
  for (const tick of [100, 9, 10]) f.frame(tick);
  writeFileSync(join(f.dir, 't8.png.bak'), 'ignored');
  writeFileSync(join(f.dir, 'T7.png'), 'ignored');
  mkdirSync(join(f.dir, 't6.png'));
  writeFileSync(join(f.dir, 'film.json'), '{"outcome":"pass"}');
  const result = await f.run();
  assert.equal(result.code, EXIT.pass);
  assert.match(result.out, /^sheet: PASS/);
  const first = readFileSync(f.output);
  const sheet = decodePng(first); // Also validates every output chunk CRC.
  assert.deepEqual([sheet.width, sheet.height, sheet.channels], [76, 54, 3]);
  const positions = [[4, 4, 9], [40, 4, 10], [4, 29, 100]];
  for (let y = 0; y < sheet.height; y++) {
    for (let x = 0; x < sheet.width; x++) {
      const cell = positions.find(([left, top]) => x >= left && x < left + 32 && y >= top && y < top + 21);
      if (!cell) assert.deepEqual(pixelAt(sheet, x, y), [24, 24, 24]);
      else if (y >= cell[1] + 18) assert.deepEqual(pixelAt(sheet, x, y), [cell[2], 20, 30]);
    }
  }
  // Tick 9: first row 01110, each font pixel occupies a 2x2 block at offset 2,2.
  for (let y = 6; y < 8; y++) {
    for (let x = 6; x < 16; x++) assert.deepEqual(pixelAt(sheet, x, y), x >= 8 && x < 14 ? [255, 255, 255] : [24, 24, 24]);
  }
  assert.equal((await f.run()).code, EXIT.pass);
  assert.deepEqual(readFileSync(f.output), first);
});

test('crop precedes shrink, retaining non-divisible final samples and RGB from RGBA', async (t) => {
  const f = fixture(t);
  f.frame(1, 8, 6, (x, y) => [x, y, x + y, 0], 4);
  assert.equal((await f.run('--crop=1,1,5,3', '--shrink=2', '--cols=2')).code, EXIT.pass);
  const sheet = decodePng(readFileSync(f.output));
  assert.deepEqual([sheet.width, sheet.height], [18, 28]);
  for (let y = 0; y < 2; y++) {
    for (let x = 0; x < 3; x++) assert.deepEqual(pixelAt(sheet, 4 + x, 22 + y), [1 + 2 * x, 1 + 2 * y, 2 + 2 * x + 2 * y]);
  }
});

test('tick ranges select only exact names and report every missing tick while writing readable frames', async (t) => {
  const f = fixture(t);
  for (const tick of [1, 2, 4, 10]) f.frame(tick);
  writeFileSync(join(f.dir, 't3.png'), 'damaged');
  const result = await f.run('--ticks=2-5,8,10');
  assert.equal(result.code, EXIT.unverifiable);
  assert.match(result.out, /^sheet: UNVERIFIABLE.*missing ticks: 5, 8.*t3.png does not decode/);
  const sheet = decodePng(readFileSync(f.output));
  assert.deepEqual([sheet.width, sheet.height], [76, 54]);
  assert.deepEqual(pixelAt(sheet, 4, 22), [2, 20, 30]);
  assert.deepEqual(pixelAt(sheet, 40, 22), [4, 20, 30]);
  assert.deepEqual(pixelAt(sheet, 4, 47), [10, 20, 30]);
});

test('empty or wholly unreadable selections remove stale output, never write and never pass', async (t) => {
  const f = fixture(t);
  mkdirSync(join(f.output, '..'), { recursive: true });
  writeFileSync(f.output, 'stale');
  assert.equal((await f.run()).code, EXIT.unverifiable);
  assert.equal(existsSync(f.output), false);
  writeFileSync(join(f.dir, 't1.png'), 'bad');
  writeFileSync(join(f.dir, 't2.png'), 'also bad');
  const result = await f.run();
  assert.equal(result.code, EXIT.unverifiable);
  assert.match(result.out, /t1.png does not decode.*t2.png does not decode.*no sheet written/);
  assert.equal(existsSync(f.output), false);
  const missing = await f.run('--ticks=9007199254740993-9007199254740995');
  assert.match(missing.out, /no frames.*missing ticks: 9007199254740993-9007199254740995/);
});

test('different source dimensions are named and suppress output even if crop could equalize them', async (t) => {
  const f = fixture(t);
  f.frame(1, 10, 10);
  f.frame(2, 20, 10);
  const result = await f.run('--crop=0,0,2,2');
  assert.equal(result.code, EXIT.unverifiable);
  assert.match(result.out, /different sizes: 10x10, 20x10/);
  assert.equal(existsSync(f.output), false);
});

test('identical decoded pixels and failed or malformed manifests accumulate reasons but allow inspection', async (t) => {
  const f = fixture(t);
  for (const tick of [1, 2, 3]) f.frame(tick, 20, 5, () => [6, 7, 8]);
  for (const manifest of ['{"outcome":"fail"}', '{', 'null', '{}']) {
    writeFileSync(join(f.dir, 'film.json'), manifest);
    const result = await f.run();
    assert.equal(result.code, EXIT.unverifiable);
    assert.match(result.out, /^sheet: UNVERIFIABLE.*film.json.*nothing moved/);
    assert.ok(existsSync(f.output));
  }
});

test('motion outside the crop counts; one readable frame alone is valid', async (t) => {
  const f = fixture(t);
  f.frame(1, 8, 4, () => [0, 0, 0]);
  f.frame(2, 8, 4, (x) => [x === 7 ? 1 : 0, 0, 0]);
  assert.equal((await f.run('--crop=0,0,2,2')).code, EXIT.pass);
  assert.equal((await f.run('--ticks=1')).code, EXIT.pass);
});

test('runtime usage errors delete stale output: missing directory, invalid crop and oversized sheet', async (t) => {
  const f = fixture(t);
  f.frame(1, 8, 4);
  for (const args of [['--crop=7,0,2,1'], ['--crop=0,4,1,1'], [`--cols=${MAX_SIDE}`]]) {
    mkdirSync(dirname(f.output), { recursive: true });
    writeFileSync(f.output, 'stale');
    const result = await f.run(...args);
    assert.equal(result.code, EXIT.usage);
    assert.equal(existsSync(f.output), false);
    if (args[0].startsWith('--cols')) assert.match(result.err, /--shrink or --ticks/);
  }
  writeFileSync(f.output, 'stale');
  const errors = [];
  assert.equal(await main([join(f.dir, 'absent'), `--out=${f.output}`], { err: (s) => errors.push(s) }), EXIT.usage);
  assert.equal(existsSync(f.output), false);
  assert.match(errors.join(''), /directory does not exist/);
});

test('MAX_SIDE applies to height and includes label and gutters; shrink can make it fit', async (t) => {
  const f = fixture(t);
  f.frame(1, 1, MAX_SIDE - LABEL_H - 2 * GUTTER);
  assert.equal((await f.run()).code, EXIT.pass);
  assert.equal(decodePng(readFileSync(f.output)).height, MAX_SIDE);
  f.frame(1, 1, MAX_SIDE);
  assert.equal((await f.run()).code, EXIT.usage);
  assert.equal(existsSync(f.output), false);
  assert.equal((await f.run('--shrink=2')).code, EXIT.pass);
});

test('MAX_SIDE applies to width including outer gutters', async (t) => {
  const f = fixture(t);
  f.frame(1, MAX_SIDE - 2 * GUTTER, 1);
  assert.equal((await f.run()).code, EXIT.pass);
  assert.equal(decodePng(readFileSync(f.output)).width, MAX_SIDE);
  f.frame(1, MAX_SIDE - 2 * GUTTER + 1, 1);
  assert.equal((await f.run()).code, EXIT.usage);
  assert.equal(existsSync(f.output), false);
  assert.equal((await f.run('--shrink=2')).code, EXIT.pass);
});

test('all decimal glyphs use white 2x blocks, and narrow labels stay within their cells', async (t) => {
  const f = fixture(t);
  f.frame('01234567890', 122, 1);
  assert.equal((await f.run()).code, EXIT.pass);
  const sheet = decodePng(readFileSync(f.output));
  // Leading zero in the filename is not part of the decimal tick label.
  const firstRows = ['00100', '01110', '11110', '00010', '11111', '01110', '11111', '01110', '01110', '01110'];
  firstRows.forEach((row, i) => {
    for (let x = 0; x < 10; x++) {
      for (let y = 0; y < 2; y++) {
        assert.deepEqual(pixelAt(sheet, 6 + i * 12 + x, 6 + y), row[x >> 1] === '1' ? [255, 255, 255] : [24, 24, 24]);
      }
    }
  });
  rmSync(join(f.dir, 't01234567890.png'));
  f.frame(8, 3, 1);
  f.frame(9, 3, 1);
  assert.equal((await f.run()).code, EXIT.pass);
  const narrow = decodePng(readFileSync(f.output));
  for (let y = 0; y < narrow.height; y++) {
    for (let x = 7; x < 11; x++) assert.deepEqual(pixelAt(narrow, x, y), [24, 24, 24]);
  }
});

test('write failures return fail and no arguments emit exactly one usage line', async (t) => {
  const f = fixture(t);
  f.frame(1);
  writeFileSync(join(f.dir, 'nested'), 'parent is a file');
  assert.equal((await f.run()).code, EXIT.fail);
  const errors = [];
  assert.equal(await main([], { err: (s) => errors.push(s) }), EXIT.usage);
  assert.equal(errors.length, 1);
  assert.match(errors[0], /^usage: [^\n]+$/);
});
