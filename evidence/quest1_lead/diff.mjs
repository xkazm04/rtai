// t13708 of the two --stills lists, per arm: changed pixels (tolerance 4, tools/film/png.mjs).
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { diffImages, readPng } from '../../tools/film/png.mjs';
const out = process.argv[2];
for (const arm of ['jump', 'lead']) {
  const a = readPng(readFileSync(join(out, `${arm}-13600`, 't13708.png')));
  const b = readPng(readFileSync(join(out, `${arm}-13708`, 't13708.png')));
  const d = diffImages(a, b);
  console.log(`${arm}: t13708 from --stills=13600,13708 vs --stills=13708: ${d.changed} of ${d.total} px differ (${(d.fraction * 100).toFixed(2)} %)`);
}
