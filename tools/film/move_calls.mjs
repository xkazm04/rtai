// Render the owner's two arena comparisons with the live stage, one Godot process at a time.
// node tools/film/move_calls.mjs [output-dir] [cover|vault]
import { mkdirSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, runGodot } from '../lib/godot.mjs';
import { ROOT } from '../lib/repo.mjs';

const out = resolve(process.argv[2] ?? resolve(ROOT, 'build/owner-calls')).replaceAll('\\', '/');
const subject = process.argv[3];
if (subject && !['cover', 'vault'].includes(subject)) throw new Error('expected cover or vault');
mkdirSync(out, { recursive: true });
const measurements = [];
for (const [name, options] of [['cover', ['0.8', '0.45']], ['vault', ['false', 'true']]]) {
  if (subject && subject !== name) continue;
  for (const ppm of [64, 32]) {
    for (const value of options) {
      const args = ['--rendering-driver', 'd3d12', '--windowed', '--position', '0,1440',
        '--resolution', '1280x800', '--disable-vsync', '--fixed-fps', '60',
        'res://tests/support/move_calls/call_stills.tscn', '--', '--view=tilt70',
        '--subject=' + name, '--value=' + value, '--ppm=' + ppm, '--out=' + out];
      const r = await runGodot(args, { headless: false, timeoutMs: 120000, name: 'move-call',
        stopOn: /SCRIPT ERROR/ });
      const measured = r.out.split('\n').find(line => line.includes('[INFO] owner-call:'));
      writeFileSync(out + '/' + [name, value, ppm].join('_') + '.log', r.out);
      if (r.status !== 0 || !measured || /SCRIPT ERROR|^ERROR:/m.test(r.out)) {
        throw new Error([name, value, ppm, describe(r), r.out.slice(-2000)].join(' '));
      }
      console.log(ppm + ' px/m ' + measured);
      measurements.push({ subject: name, value, ppm, measured: measured.trim() });
    }
  }
}
writeFileSync(out + '/measurements' + (subject ? '-' + subject : '') + '.json',
  JSON.stringify(measurements, null, 2) + '\n');
