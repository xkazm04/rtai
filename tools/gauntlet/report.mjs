#!/usr/bin/env node
import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { parseArgs } from 'node:util';
import { PROJECT, readJson } from '../lib/repo.mjs';
import { batchFile, streetLog } from './street_log.mjs';
import { capExit, readResult } from './run_result.mjs';
import { enemyWeapons } from './enemy_weapons.mjs';
import { analyze } from './analysis.mjs';
import { BATCH_SCHEMA, validateRun } from './contract.mjs';
import { render } from './render.mjs';
import { statCards } from './survival.mjs';

export function loadBatch(path, { lookupTables = true } = {}) {
  const doc = readJson(path);
  if (doc?.schema !== BATCH_SCHEMA || !Array.isArray(doc.results) || !Array.isArray(doc.runs)
    || !doc.args || !doc.git) throw new Error(path + ': expected ' + BATCH_SCHEMA);
  for (const [i, run] of doc.results.entries()) {
    const reason = validateRun(run);
    if (reason) throw new Error(path + ': results[' + i + '].' + reason);
  }
  if (doc.runs.filter((r) => r.ok).length !== doc.results.length)
    throw new Error(path + ': successful runs and result count differ');
  for (const row of doc.runs) {
    if (!row.ok && !row.outcome) Object.assign(row, streetLog(dirname(path), row));
    // Earlier batches excluded the result on every nonzero exit. Recover only a
    // matching, validated local sidecar with the launcher's original freshness verdict.
    if (!row.ok && capExit(row, row.reason)) {
      const file = batchFile(dirname(path), row.file);
      if (!file) continue;
      const { result } = readResult(file, row, true, true);
      if (result) doc.results.push(result);
    }
  }
  if (!lookupTables) return doc;
  if (!doc.enemy_weapons && doc.tables?.['enemies.json']) {
    const bytes = readFileSync(join(PROJECT, 'data', 'tables', 'enemies.json'));
    if (createHash('sha256').update(bytes).digest('hex') === doc.tables['enemies.json'])
      doc.enemy_weapons = enemyWeapons(JSON.parse(bytes));
  }
  if (!doc.survival_tuning) {
    doc.survival_tuning = {};
    for (const file of ['combat.json', 'gauntlet.json', 'gauntlet_bonuses.json']) {
      if (!doc.tables?.[file]) continue;
      const bytes = readFileSync(join(PROJECT, 'data', 'tables', file));
      if (createHash('sha256').update(bytes).digest('hex') !== doc.tables[file]) continue;
      const table = JSON.parse(bytes);
      if (file === 'combat.json') doc.survival_tuning.repair_per_s = table.rivet.repair_per_s;
      if (file === 'gauntlet.json' && doc.args.runner === 'gauntlet' && table.rivet)
        doc.survival_tuning.repair_per_s = table.rivet.repair_per_s;
      if (file === 'gauntlet_bonuses.json') doc.survival_tuning.stat_cards = statCards(table);
    }
  }
  return doc;
}

export function weaponsOf(batch) {
  if (batch.weapon_refs) return new Map(Object.entries(batch.weapon_refs));
  // Older/external manifests may carry only hashes. Never resolve ids against a different table.
  const file = 'gauntlet_bonuses.json';
  const path = join(PROJECT, 'data', 'tables', file);
  if (!batch.tables?.[file] || !existsSync(path)) return new Map();
  const bytes = readFileSync(path);
  if (createHash('sha256').update(bytes).digest('hex') !== batch.tables[file])
    throw new Error('gauntlet_bonuses.json differs from the batch and no weapon ref snapshot is available');
  return new Map(JSON.parse(bytes).rows.filter((r) => r.kind === 'weapon').map((r) => [r.id, r.ref]));
}

export function generate(batchPath, baselinePath, out = dirname(batchPath)) {
  const batch = loadBatch(batchPath);
  const baseline = baselinePath ? loadBatch(baselinePath) : null;
  const model = analyze(batch, baseline, weaponsOf(batch));
  const { markdown, html } = render(batch, model, baseline);
  mkdirSync(out, { recursive: true });
  writeFileSync(join(out, 'report.md'), markdown);
  writeFileSync(join(out, 'report.html'), html);
  return model;
}

export { analyze };

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try {
    const { values } = parseArgs({ options: {
      batch: { type: 'string' }, baseline: { type: 'string' }, out: { type: 'string' }
    } });
    if (!values.batch) throw new Error('--batch=<batch.json> is required');
    const dir = resolve(values.out ?? dirname(values.batch));
    const model = generate(values.batch, values.baseline, dir);
    console.log('report: ' + model.waves.length + ' profile/wave rows, ' + model.waves.filter((w) => w.miss).length
      + ' average target misses; wrote ' + join(dir, 'report.md') + ' and report.html');
  } catch (err) {
    console.error('report: ' + err.message);
    process.exitCode = 2;
  }
}
