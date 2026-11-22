import { existsSync, readFileSync } from 'node:fs';
import { dirname } from 'node:path';
import { MIN_AA_PAIRS } from './contract.mjs';
import { loadBatch } from './report.mjs';
import { fmt } from './report_tables.mjs';
import { batchFile } from './street_log.mjs';
import { pairNullRuns, pairRuns } from './tune_confirm.mjs';
import { floorsFor } from './tune_floor.mjs';
import { digest } from './tune_state.mjs';

// Pre-salt manifests predate result digests. Use the original file if it is still beside the batch.
export function loadFloorBatch(path) {
  const batch = loadBatch(path);
  for (const row of batch.runs) {
    if (!row.ok || row.result_sha256) continue;
    const file = batchFile(dirname(path), row.file);
    if (file && existsSync(file)) row.result_sha256 = digest(readFileSync(file));
  }
  return batch;
}

export function floorReport(before, neutral) {
  const beforeRows = pairRuns(before, before);
  const nullRows = pairNullRuns(before, neutral);
  const nullGroups = Map.groupBy(nullRows, (row) => row.stratum);
  let differ = 0, embedded = 0;
  for (const row of nullRows) {
    if (row.shaA && row.shaB) differ += Number(row.shaA !== row.shaB);
    else {
      // Older standalone manifests contain the result payload but no source-file digest.
      embedded++;
      differ += Number(JSON.stringify(row.a) !== JSON.stringify(row.b));
    }
  }
  const lines = ['# Gauntlet noise floors', '',
    'Result bytes differ in ' + differ + ' of ' + nullRows.length + ' matched runs (' + before.results.length
      + ' before, ' + neutral.results.length + ' null).',
    ...(embedded ? [embedded + ' comparisons used serialized embedded results because the original digests were unavailable.'] : []),
    '', '| Profile / controls / pick | Metric | Null-salt floor | Pairs | Cross-seed floor | Pairs |',
    '|---|---|---:|---:|---:|---:|'];
  const value = (floor) => fmt(floor.estimate) + (Number.isFinite(floor.estimate) && floor.aa_pairs < MIN_AA_PAIRS ? '*' : '');
  for (const [stratum, base] of Map.groupBy(beforeRows, (row) => row.stratum)) {
    const matched = nullGroups.get(stratum) ?? [];
    const profile = base[0].a.profile;
    const waves = [...new Set(base.flatMap((row) => row.a.waves.map((w) => w.n)))].sort((a, b) => a - b);
    const metrics = [...waves.map((wave) => ({ type: 'wave', wave, profile })), { type: 'reached' }];
    for (const metric of metrics) {
      const floors = floorsFor(base, matched, metric);
      const same = floors['null-salt'], cross = floors['cross-seed'];
      const label = metric.type === 'wave' ? 'Wave ' + metric.wave + ' (s)' : 'Wave reached';
      lines.push('| ' + [JSON.parse(stratum).join(' / '), label, value(same), same.aa_pairs,
        value(cross), cross.aa_pairs].join(' | ') + ' |');
    }
  }
  lines.push('', '* Estimates with fewer than ' + MIN_AA_PAIRS + ' pairs cannot decide a verdict.');
  return lines.join('\n') + '\n';
}
