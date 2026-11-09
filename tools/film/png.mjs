// A small PNG reader for what Godot's save_png writes (8-bit RGB or RGBA, not interlaced) and the
// pixel measures tools/film/compare.mjs judges with. No dependency: a tool that must never say pass
// by accident should not lean on a decoder it cannot read.
import { readFileSync } from 'node:fs';
import { inflateSync } from 'node:zlib';

const SIGNATURE = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
const paeth = (a, b, c) => {
  const p = a + b - c;
  const pa = Math.abs(p - a);
  const pb = Math.abs(p - b);
  const pc = Math.abs(p - c);
  if (pa <= pb && pa <= pc) return a;
  return pb <= pc ? b : c;
};

/** {width, height, channels, data: Buffer of raw rows}. Throws on anything it cannot read exactly. */
export function decodePng(buffer) {
  if (!buffer.subarray(0, 8).equals(SIGNATURE)) throw new Error('not a PNG');
  let pos = 8;
  let header = null;
  const idat = [];
  while (pos < buffer.length) {
    const size = buffer.readUInt32BE(pos);
    const type = buffer.toString('latin1', pos + 4, pos + 8);
    const body = buffer.subarray(pos + 8, pos + 8 + size);
    if (type === 'IHDR') header = body;
    else if (type === 'IDAT') idat.push(body);
    else if (type === 'IEND') break;
    pos += 12 + size;
  }
  if (!header) throw new Error('no IHDR');
  const [depth, colour, , , interlace] = [header[8], header[9], header[10], header[11], header[12]];
  const channels = { 2: 3, 6: 4 }[colour];
  if (depth !== 8 || !channels || interlace !== 0) throw new Error(`unsupported PNG: depth ${depth}, colour ${colour}, interlace ${interlace}`);
  const width = header.readUInt32BE(0);
  const height = header.readUInt32BE(4);
  const raw = inflateSync(Buffer.concat(idat));
  const stride = width * channels;
  if (raw.length !== (stride + 1) * height) throw new Error(`PNG data is ${raw.length} bytes, expected ${(stride + 1) * height}`);
  const data = Buffer.alloc(stride * height);
  for (let y = 0; y < height; y++) {
    const filter = raw[y * (stride + 1)];
    const from = y * (stride + 1) + 1;
    const to = y * stride;
    for (let x = 0; x < stride; x++) {
      const left = x >= channels ? data[to + x - channels] : 0;
      const up = y > 0 ? data[to + x - stride] : 0;
      const corner = x >= channels && y > 0 ? data[to + x - stride - channels] : 0;
      const add = [0, left, up, (left + up) >> 1, paeth(left, up, corner)][filter];
      if (add === undefined) throw new Error(`bad PNG filter ${filter}`);
      data[to + x] = (raw[from + x] + add) & 0xff;
    }
  }
  return { width, height, channels, data };
}

export const readPng = (file) => decodePng(readFileSync(file));

/** How two images differ: {changed, total, fraction, box} where a pixel counts as changed when any
 *  colour channel moved more than `tolerance`; box = [x0, y0, x1, y1] around the changes, or null.
 *  Throws when the images are not the same size: such a pair is no comparison. */
export function diffImages(a, b, tolerance = 4) {
  if (a.width !== b.width || a.height !== b.height) {
    throw new Error(`the two sides are different sizes: ${a.width}x${a.height} and ${b.width}x${b.height}`);
  }
  let changed = 0;
  let [x0, y0, x1, y1] = [a.width, a.height, -1, -1];
  for (let y = 0; y < a.height; y++) {
    for (let x = 0; x < a.width; x++) {
      const ia = (y * a.width + x) * a.channels;
      const ib = (y * b.width + x) * b.channels;
      let moved = false;
      for (let c = 0; c < 3 && !moved; c++) moved = Math.abs(a.data[ia + c] - b.data[ib + c]) > tolerance;
      if (!moved) continue;
      changed++;
      if (x < x0) x0 = x;
      if (x > x1) x1 = x;
      if (y < y0) y0 = y;
      if (y > y1) y1 = y;
    }
  }
  const total = a.width * a.height;
  return { changed, total, fraction: changed / total, box: changed ? [x0, y0, x1, y1] : null };
}
