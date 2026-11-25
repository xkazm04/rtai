// node tools/ground/lift/capture.mjs --weapon=hands|pistol --pitch=p70|p55 --gaits=move,sprint [--ppm=32|64] --out=<dir>
// Renders the n31 lift probe (project/dev/ground_n31/lift_probe.gd) windowed on d3d12 on the
// secondary screen; the frames + frames.jsonl it writes are read by lift.py.
import { mkdirSync } from 'node:fs';
import { resolve, sep } from 'node:path';
import { pathToFileURL } from 'node:url';
import { parseArgs } from 'node:util';
import { runGodot } from '../../lib/godot.mjs';

/** Godot args for one probe run (exported for the test). */
export function probeArgs({ weapon = 'hands', pitch = 'p70', gaits = 'move,sprint', ppm = '32', out }) {
  if (!out) throw Error('capture: --out=<dir> is required');
  if (!['p55', 'p70'].includes(pitch)) throw Error('capture: --pitch=p55|p70');
  if (!['32', '64'].includes(ppm)) throw Error('capture: --ppm=32|64');
  return ['--rendering-driver', 'd3d12', '--position', '0,1440', '-s',
    'res://dev/ground_n31/lift_probe.gd', '--', `--weapon=${weapon}`, `--pitch=${pitch}`,
    `--gaits=${gaits}`, `--ppm=${ppm}`, `--out=${resolve(out).split(sep).join('/')}`];
}

async function main() {
  const { values } = parseArgs({ options: { weapon: { type: 'string' }, pitch: { type: 'string' },
    gaits: { type: 'string' }, ppm: { type: 'string' }, out: { type: 'string' } } });
  const args = probeArgs(values);
  mkdirSync(resolve(values.out), { recursive: true });
  const res = await runGodot(args, { headless: false, timeoutMs: 900_000, name: 'ground-lift', stopOn: /SCRIPT ERROR/ });
  const errors = res.out.split('\n').filter((l) => /SCRIPT ERROR/.test(l)); // engine exit leaks are not ours
  for (const l of errors.slice(0, 10)) console.log(l);
  console.log(`capture: exit ${res.status}${res.timedOut ? ' (timed out)' : ''}, ${errors.length} error lines`);
  process.exit(res.status === 0 && errors.length === 0 ? 0 : 1);
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) await main();
