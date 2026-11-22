#!/usr/bin/env node
import { parseArgs } from 'node:util';
import { pathToFileURL } from 'node:url';
import { median } from '../perf/paired.mjs';
import { pairedMean } from './tune_metric.mjs';
import { loadBatch } from './report.mjs';
import { pairRuns } from './tune_confirm.mjs';
import { enemies, stratum } from './move_stats.mjs';

function timePair(before, after, enemy, which) {
  const on = new Map(after.waves.map((w) => [w.n, w]));
  const deltas = [];
  for (const left of before.waves) {
    const right = on.get(left.n);
    if (!right || !Number.isFinite(left.seconds) || !Number.isFinite(right.seconds)) continue;
    if (stratum(left, enemy) === which && stratum(right, enemy) === which)
      deltas.push(right.seconds - left.seconds);
  }
  return deltas.length ? median(deltas) : null;
}

function summary(deltas) {
  const finite = deltas.filter(Number.isFinite);
  const { gain, ci } = pairedMean(finite.map((b) => ({ a: 0, b })));
  return { pairs: finite.length, delta: finite.length ? gain : null, ci95: finite.length >= 2 ? ci : null };
}

const lethal = (r) => r.death && r.death.by !== 'timeout';

export function moveTable(off, on, move) {
  if (!enemies.has(move)) throw new Error('unknown move ' + move);
  if ((off.args.salt ?? 0) !== (on.args.salt ?? 0)) throw new Error('bot salts differ');
  const pairs = pairRuns(off, on);
  if (!pairs.length) throw new Error('no matching seeds, profiles, controls and pick policies');
  const enemy = enemies.get(move);
  return [...Map.groupBy(pairs, (p) => p.stratum)].map(([key, group]) => {
    const [profile, controls, pick] = JSON.parse(key);
    const times = (which) => summary(group.map(({ a, b }) => timePair(a, b, enemy, which)));
    const deaths = group.filter(({ a, b }) => lethal(a) && lethal(b));
    return { move, enemy, profile, controls, pick, matched: group.length,
      with_enemy_seconds: times('present'), without_enemy_seconds: times('absent'),
      death_wave: summary(deaths.map(({ a, b }) => b.death.wave - a.death.wave)),
      without_paired_death: group.length - deaths.length };
  });
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try {
    const { values } = parseArgs({ options: { off: { type: 'string' }, on: { type: 'string' }, move: { type: 'string' } } });
    if (!values.off || !values.on || !values.move) throw new Error('expected --off=<batch.json> --on=<batch.json> --move=<id>');
    console.log(JSON.stringify({ difference: 'on minus off', statistic: 'mean of per-seed median matched-wave deltas; paired bootstrap CI95',
      rows: moveTable(loadBatch(values.off), loadBatch(values.on), values.move) }, null, 2));
  } catch (err) {
    console.error('move_table: ' + err.message);
    process.exitCode = 2;
  }
}
