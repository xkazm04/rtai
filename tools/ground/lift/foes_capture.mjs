// node tools/ground/lift/foes_capture.mjs --out=<dir> [--ppm=32|64] [--subjects=a,b] [--gaits=walk,run] [--capture=40]
// Renders the n31 foe lift probe (project/dev/ground_n31/foe_lift_probe.tscn) windowed on d3d12 at
// 1920x1080 on the secondary screen; foes.py reads the frames + frames.jsonl it writes.
import { mkdirSync } from 'node:fs';
import { resolve, sep } from 'node:path';
import { pathToFileURL } from 'node:url';
import { parseArgs } from 'node:util';
import { runGodot } from '../../lib/godot.mjs';

/** Godot args for one probe run (exported for the test). */
export function foeArgs({ ppm = '32', subjects, gaits, capture, out }) {
  if (!out) throw Error('foes_capture: --out=<dir> is required');
  if (!['32', '64'].includes(ppm)) throw Error('foes_capture: --ppm=32|64');
  const flags = [`--ppm=${ppm}`, `--out=${resolve(out).split(sep).join('/')}`];
  if (subjects) flags.push(`--subjects=${subjects}`);
  if (gaits) flags.push(`--gaits=${gaits}`);
  if (capture) flags.push(`--capture=${capture}`);
  return ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440', '--resolution', '1920x1080',
    'res://dev/ground_n31/foe_lift_probe.tscn', '--', ...flags];
}

async function main() {
  const { values } = parseArgs({ options: { ppm: { type: 'string' }, subjects: { type: 'string' },
    gaits: { type: 'string' }, capture: { type: 'string' }, out: { type: 'string' } } });
  const args = foeArgs(values);
  mkdirSync(resolve(values.out), { recursive: true });
  const res = await runGodot(args, { headless: false, timeoutMs: 1_500_000, name: 'ground-foe-lift', stopOn: /SCRIPT ERROR/ });
  const errors = res.out.split('\n').filter((l) => /SCRIPT ERROR/.test(l));
  for (const l of errors.slice(0, 10)) console.log(l);
  console.log(`foes_capture: exit ${res.status}${res.timedOut ? ' (timed out)' : ''}, ${errors.length} error lines`);
  process.exit(res.status === 0 && errors.length === 0 ? 0 : 1);
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) await main();
