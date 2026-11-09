#!/usr/bin/env node
// Deterministic, dependency-free contact sheets for film stills.
import { mkdirSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { basename, dirname, join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { deflateSync } from 'node:zlib';
import { readPng } from './png.mjs';

export const EXIT = { pass: 0, fail: 1, usage: 2, unverifiable: 3 };
export const GUTTER = 4;
export const LABEL_H = 18;
export const MAX_SIDE = 16384;
const USAGE = 'usage: node tools/film/sheet.mjs <film-dir> --out=<file.png> [--ticks=<a,b,c-d>] [--cols=<n>] [--crop=<x,y,w,h>] [--shrink=<n>]';
const DIGITS = [
  '01110/10001/10011/10101/11001/10001/01110',
  '00100/01100/00100/00100/00100/00100/01110',
  '01110/10001/00001/00010/00100/01000/11111',
  '11110/00001/00001/01110/00001/00001/11110',
  '00010/00110/01010/10010/11111/00010/00010',
  '11111/10000/10000/11110/00001/00001/11110',
  '01110/10000/10000/11110/10001/10001/01110',
  '11111/00001/00010/00100/01000/01000/01000',
  '01110/10001/10001/01110/10001/10001/01110',
  '01110/10001/10001/01111/00001/00001/01110',
].map((digit) => digit.split('/'));

/** Validated options, with tick ranges kept compact even for very large ticks. */
export function parseArgv(argv) {
  const flags = { shrink: 1 };
  let dir;
  for (const arg of argv) {
    if (!arg.startsWith('-') && !dir && arg) { dir = arg; continue; }
    const match = /^--(out|ticks|cols|crop|shrink)=(.+)$/.exec(arg);
    if (!match) return { error: `bad argument ${arg}` };
    flags[match[1]] = match[2];
  }
  if (!dir || !flags.out) return { error: 'film directory and --out are required' };
  if (!/\.png$/i.test(flags.out)) return { error: '--out must name a .png file (it is deleted first, so it cannot be anything else)' };
  if (resolve(dirname(flags.out)) === resolve(dir) && /^t\d+\.png$/i.test(basename(flags.out))) return { error: `--out ${flags.out} would replace one of the film's own frames` };
  for (const key of ['cols', 'shrink']) {
    if (flags[key] === undefined) continue;
    if (!/^\d+$/.test(String(flags[key])) || !Number.isSafeInteger(Number(flags[key])) || Number(flags[key]) < 1) {
      return { error: `--${key} must be an integer >=1` };
    }
    flags[key] = Number(flags[key]);
  }
  if (flags.crop !== undefined) {
    const crop = flags.crop.split(',').map(Number);
    if (!/^\d+,\d+,\d+,\d+$/.test(flags.crop) || !crop.every(Number.isSafeInteger) || crop[2] < 1 || crop[3] < 1) {
      return { error: '--crop must be x,y,w,h with nonnegative origins and positive sizes' };
    }
    flags.crop = crop;
  }
  if (flags.ticks !== undefined) {
    if (!/^\d+(?:-\d+)?(?:,\d+(?:-\d+)?)*$/.test(flags.ticks)) return { error: 'malformed --ticks' };
    const ranges = flags.ticks.split(',').map((part) => {
      const [a, b = a] = part.split('-').map(BigInt);
      return [a, b];
    });
    if (ranges.some(([a, b]) => a > b)) return { error: '--ticks has a reversed range' };
    ranges.sort((a, b) => a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0);
    flags.ticks = [];
    for (const range of ranges) {
      const last = flags.ticks.at(-1);
      if (last && range[0] <= last[1] + 1n) last[1] = range[1] > last[1] ? range[1] : last[1];
      else flags.ticks.push(range);
    }
  }
  return { dir, flags };
}

const CRC_TABLE = Array.from({ length: 256 }, (_, value) => {
  for (let i = 0; i < 8; i++) value = value & 1 ? 0xedb88320 ^ (value >>> 1) : value >>> 1;
  return value >>> 0;
});

function chunk(type, body) {
  const result = Buffer.alloc(body.length + 12);
  result.writeUInt32BE(body.length);
  result.write(type, 4, 'latin1');
  body.copy(result, 8);
  let crc = 0xffffffff;
  for (const byte of result.subarray(4, -4)) crc = CRC_TABLE[(crc ^ byte) & 255] ^ (crc >>> 8);
  result.writeUInt32BE((crc ^ 0xffffffff) >>> 0, result.length - 4);
  return result;
}

function encodePng(width, height, pixels) {
  const header = Buffer.alloc(13);
  header.writeUInt32BE(width);
  header.writeUInt32BE(height, 4);
  header[8] = 8;
  header[9] = 2;
  const stride = width * 3;
  const raw = Buffer.alloc((stride + 1) * height);
  for (let y = 0; y < height; y++) pixels.copy(raw, y * (stride + 1) + 1, y * stride, (y + 1) * stride);
  return Buffer.concat([Buffer.from('89504e470d0a1a0a', 'hex'), chunk('IHDR', header),
    chunk('IDAT', deflateSync(raw)), chunk('IEND', Buffer.alloc(0))]);
}

function label(pixels, width, left, top, cellW, tick) {
  for (const [i, digit] of [...String(tick)].entries()) {
    const glyph = DIGITS[Number(digit)];
    for (let y = 0; y < 14; y++) {
      for (let x = 0; x < 10; x++) {
        const dx = 2 + i * 12 + x;
        if (dx < cellW && glyph[y >> 1][x >> 1] === '1') {
          pixels.fill(255, ((top + 2 + y) * width + left + dx) * 3,
            ((top + 2 + y) * width + left + dx) * 3 + 3);
        }
      }
    }
  }
}

function render(frames, flags, crop) {
  const cellW = Math.ceil(crop[2] / flags.shrink);
  const cellH = Math.ceil(crop[3] / flags.shrink);
  const cols = flags.cols ?? Math.ceil(Math.sqrt(frames.length));
  const rows = Math.ceil(frames.length / cols);
  const width = cols * cellW + (cols + 1) * GUTTER;
  const height = rows * (cellH + LABEL_H) + (rows + 1) * GUTTER;
  if (width > MAX_SIDE || height > MAX_SIDE) return { error: `sheet exceeds MAX_SIDE=${MAX_SIDE}; use --shrink or --ticks` };
  const pixels = Buffer.alloc(width * height * 3, 0x18);
  frames.forEach(({ tick, image }, index) => {
    const left = GUTTER + (index % cols) * (cellW + GUTTER);
    const top = GUTTER + Math.floor(index / cols) * (cellH + LABEL_H + GUTTER);
    label(pixels, width, left, top, cellW, tick);
    for (let y = 0; y < cellH; y++) {
      for (let x = 0; x < cellW; x++) {
        const source = ((crop[1] + y * flags.shrink) * image.width + crop[0] + x * flags.shrink) * image.channels;
        image.data.copy(pixels, ((top + LABEL_H + y) * width + left + x) * 3, source, source + 3);
      }
    }
  });
  return { png: encodePng(width, height, pixels) };
}

function identical(a, b) {
  for (let p = 0; p < a.width * a.height; p++) {
    for (let c = 0; c < 4; c++) {
      const av = c < a.channels ? a.data[p * a.channels + c] : 255;
      const bv = c < b.channels ? b.data[p * b.channels + c] : 255;
      if (av !== bv) return false;
    }
  }
  return true;
}

function missingTicks(ranges, files) {
  const missing = [];
  const add = (a, b) => { if (a <= b) missing.push(a === b ? String(a) : `${a}-${b}`); };
  for (const [a, b] of ranges) {
    let next = a;
    for (const { tick } of files) {
      if (tick < next || tick > b) continue;
      add(next, tick - 1n);
      next = tick + 1n;
    }
    add(next, b);
  }
  return missing;
}

function collect(dir, flags, reasons) {
  const files = readdirSync(dir, { withFileTypes: true })
    .filter((entry) => entry.isFile() && /^t\d+\.png$/.test(entry.name))
    .map(({ name }) => ({ name, tick: BigInt(name.slice(1, -4)) }))
    .filter(({ tick }) => !flags.ticks || flags.ticks.some(([a, b]) => tick >= a && tick <= b))
    .sort((a, b) => a.tick < b.tick ? -1 : a.tick > b.tick ? 1 : a.name < b.name ? -1 : a.name > b.name ? 1 : 0);
  if (!files.length) reasons.push('no frames');
  if (flags.ticks) {
    const missing = missingTicks(flags.ticks, files);
    if (missing.length) reasons.push(`missing ticks: ${missing.join(', ')}`);
  }
  const frames = [];
  for (const file of files) {
    try { frames.push({ ...file, image: readPng(join(dir, file.name)) }); }
    catch (error) { reasons.push(`${file.name} does not decode: ${error.message}`); }
  }
  try {
    const manifest = JSON.parse(readFileSync(join(dir, 'film.json'), 'utf8'));
    if (manifest?.outcome !== 'pass') reasons.push(`film.json outcome is ${JSON.stringify(manifest?.outcome) ?? 'missing'}`);
  } catch (error) {
    if (error.code !== 'ENOENT') reasons.push(`film.json cannot be read or parsed: ${error.message}`);
  }
  return frames;
}

export async function main(argv, { out = console.log, err = console.error } = {}) {
  const parsed = parseArgv(argv);
  if (parsed.error) { err(argv.length ? `sheet: ${parsed.error}\n${USAGE}` : USAGE); return EXIT.usage; }
  const { dir, flags } = parsed;
  const usage = (message) => { err(`sheet: ${message}\n${USAGE}`); return EXIT.usage; };
  try {
    rmSync(flags.out, { force: true });
    try {
      if (!statSync(dir).isDirectory()) return usage(`not a directory: ${dir}`);
    } catch (error) {
      if (['ENOENT', 'ENOTDIR'].includes(error.code)) return usage(`directory does not exist: ${dir}`);
      throw error;
    }
    const reasons = [];
    const frames = collect(dir, flags, reasons);
    const sizes = [...new Set(frames.map(({ image }) => `${image.width}x${image.height}`))];
    if (sizes.length > 1) reasons.push(`frames have different sizes: ${sizes.join(', ')}`);
    if (flags.crop && frames.some(({ image }) => flags.crop[0] + flags.crop[2] > image.width
      || flags.crop[1] + flags.crop[3] > image.height)) return usage('--crop does not fit inside the frame');
    let written = false;
    if (frames.length && sizes.length === 1) {
      if (frames.length > 1 && frames.every(({ image }) => identical(frames[0].image, image))) reasons.push('nothing moved');
      const image = frames[0].image;
      const result = render(frames, flags, flags.crop ?? [0, 0, image.width, image.height]);
      if (result.error) return usage(result.error);
      mkdirSync(dirname(flags.out), { recursive: true });
      writeFileSync(flags.out, result.png);
      written = true;
    }
    out(`sheet: ${reasons.length ? 'UNVERIFIABLE' : 'PASS'}${reasons.length ? `: ${reasons.join('; ')}` : ''}; ${written ? flags.out : 'no sheet written'}`);
    return reasons.length ? EXIT.unverifiable : EXIT.pass;
  } catch (error) {
    err(`sheet: FAIL: ${error.message}`);
    return EXIT.fail;
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(await main(process.argv.slice(2)));
}
