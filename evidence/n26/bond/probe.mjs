// Run the normal street test player and print cumulative bond at each wave close.
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { main as runDev } from '../../../tools/dev/run.mjs';

const [seed = '1', waves = '12'] = process.argv.slice(2);
const result = resolve('build', 'gauntlet', `bond-average-${seed}-${waves}.json`);
const status = await runDev(['res://dev/gauntlet/gauntlet.tscn', '--bot=average', '--pick=greedy',
  `--seed=${seed}`, `--waves=${waves}`, `--result=${result}`, '--timeout=600']);
if (status !== 0) process.exit(status);

const run = JSON.parse(readFileSync(result, 'utf8'));
for (const row of run.waves) {
  // On death the street omits clear time. Its form buckets cover every live tick.
  const seconds = row.seconds ?? Object.values(row.form_seconds).reduce((sum, s) => sum + s, 0);
  const pick = run.picks.find(p => p.wave === row.n);
  const mastered = pick?.taken.startsWith('master_') ? pick.taken : '-';
  console.log(`wave ${row.n}  ${seconds.toFixed(2)} s  ${JSON.stringify(row.bond)}  ${mastered}`);
  if (seconds > 180) process.exitCode = 1;
}
console.log(run.death ? `died on wave ${run.death.wave}` : `cleared ${run.wave_reached} waves`);
if (process.exitCode) console.error('FAIL: wave exceeded 180 simulated seconds');
