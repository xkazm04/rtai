// Render the six-row review table from the real arena's tick observations.
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { runGodot } from '../lib/godot.mjs';

const dir = process.argv[2];
if (!dir) throw Error('usage: node tools/film/swing_table.mjs <telemetry-dir>');
mkdirSync(dir, { recursive: true });
const recorder = fileURLToPath(new URL('./swing_measure.tscn', import.meta.url));
const env = { ...process.env, GTAI_MELEE_OUT: resolve(dir), GTAI_MELEE_PLAYER: 'res://dev/melee/swing_measure.tscn' };
const run = await runGodot(['--fixed-fps', '60', recorder, '--', '--enemy-brain=squad', '--silent'],
  { name: 'melee-swing-measure', env, timeoutMs: 150000 });
if (run.status !== 0 || /SCRIPT ERROR:|\[ERROR\] swing_measure/.test(run.out)) throw Error(run.out.slice(-6000));
const { trials, tick_rate: hz } = JSON.parse(readFileSync(join(dir, 'swings.json'), 'utf8'));
const rows = ['<table><thead><tr><th>Weapon</th><th>40-tick clicks, old &rarr; shipped</th><th>6-tick mash, old &rarr; shipped</th><th>Held starts/s over 3 s, old &rarr; shipped</th><th>Shipped row, Hz</th></tr></thead><tbody>'];
for (const weapon of new Set(trials.map(t => t.weapon))) {
  const cell = (cadence, single) => trials.find(t => t.weapon === weapon && t.cadence === cadence && t.single_swing === single);
  const pairs = ['single', 'mash', 'held'].map(mode => [false, true].map(single => {
    const t = cell(mode, single);
    return mode === 'held' ? t.swings_per_second.toFixed(2) : t.swings_per_click.toFixed(2);
  }).join(' &rarr; '));
  const rate = (hz / cell('held', true).row_ticks).toFixed(2);
  rows.push('<tr>' + [weapon, ...pairs, rate].map(x => '<td>' + x + '</td>').join('') + '</tr>');
}
writeFileSync(join(dir, 'swings.md'), rows.join('\n') + '</tbody></table>\n');
