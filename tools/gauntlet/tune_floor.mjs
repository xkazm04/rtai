import { paired } from '../perf/paired.mjs';
import { MIN_AA_PAIRS } from './contract.mjs';
import { interval, measured, pairedMean, samplesFor } from './tune_metric.mjs';

export function floorMode(mode = 'null-salt') {
  if (!['null-salt', 'cross-seed'].includes(mode)) throw new Error('--floor-mode must be null-salt or cross-seed');
  return mode;
}

const seedOf = (row) => row.declineSeed === undefined ? row.seed : [row.seed, row.declineSeed];

function noiseFloor(rows, metric, mode) {
  const pairs = [], groups = [];
  for (const [stratum, group] of Map.groupBy(samplesFor(rows, metric), (row) => row.stratum)) {
    group.sort((a, b) => a.seed - b.seed);
    if (mode === 'null-salt') {
      const seeds = group.map(seedOf);
      for (const observation of group) pairs.push(observation);
      groups.push({ stratum, left: seeds, right: seeds });
      continue;
    }
    const left = [], right = [];
    for (let i = 1; i < group.length; i += 2) {
      pairs.push({ a: group[i - 1].a, b: group[i].a });
      left.push(seedOf(group[i - 1]));
      right.push(seedOf(group[i]));
    }
    if (left.length) groups.push({ stratum, left, right });
  }
  const ci = metric.type === 'death' ? pairedMean(pairs).ci : ['killer', 'spread'].includes(metric.type)
    ? interval(pairs, (values) => measured(metric.type, values))
    : paired(pairs).ci95;
  const estimate = Math.max(...ci.map(Math.abs));
  return { aa_pairs: pairs.length, aa_groups: groups, estimate,
    floor: pairs.length >= MIN_AA_PAIRS ? estimate : NaN };
}

export function floorsFor(beforeRows, nullRows, metric) {
  return {
    'null-salt': nullRows && noiseFloor(nullRows, metric, 'null-salt'),
    'cross-seed': noiseFloor(beforeRows, metric, 'cross-seed')
  };
}
