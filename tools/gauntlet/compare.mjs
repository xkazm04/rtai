#!/usr/bin/env node
import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, isAbsolute } from 'node:path';
import { pathToFileURL } from 'node:url';
import { parseArgs } from 'node:util';
import { readJson } from '../lib/repo.mjs';
import { compareArm } from './compare_metrics.mjs';
import { renderComparison } from './compare_render.mjs';
import { PROFILES } from './contract.mjs';
import { targets as defaults } from './death_score.mjs';
import { loadBatch } from './report.mjs';

function readTargets(path) {
  if (!path) return defaults;
  const t = readJson(path);
  const positive = (n) => Number.isFinite(n) && n > 0;
  const bosses = t?.boss_wave_seconds;
  if (t?.schema !== defaults.schema || !Number.isSafeInteger(t.boss_every) || t.boss_every < 1
    || !positive(t.wave_seconds?.average) || !PROFILES.every((p) => positive(t.death_wave?.[p]))
    || !Array.isArray(bosses) || bosses.length !== 2 || !bosses.every(positive) || bosses[0] > bosses[1]
    || !Number.isFinite(t.separation?.min_wave_gap) || t.separation.min_wave_gap < 0
    || !Number.isFinite(t.separation.min_seed_share) || t.separation.min_seed_share < 0 || t.separation.min_seed_share > 1)
    throw new Error(path + ': invalid gauntlet targets');
  return t;
}

function armSpec(value) {
  const at = value.indexOf('=');
  const label = value.slice(0, at).trim(), path = value.slice(at + 1);
  if (at < 1 || !label || !isAbsolute(path))
    throw new Error('expected --arm=<label>=<absolute batch.json path>');
  return { label, path };
}

export function compare(argv) {
  const { values } = parseArgs({ args: argv, options: {
    arm: { type: 'string', multiple: true }, targets: { type: 'string' }, out: { type: 'string' }
  } });
  const specs = (values.arm ?? []).map(armSpec);
  if (specs.length < 2) throw new Error('at least two --arm=<label>=<absolute batch.json path> arguments are required');
  if (new Set(specs.map((s) => s.label)).size !== specs.length) throw new Error('arm labels must be distinct');
  if (!values.out || !isAbsolute(values.out)) throw new Error('--out=<absolute output path without extension> is required');
  const targets = readTargets(values.targets);
  const arms = specs.map(({ label, path }) => compareArm(label, loadBatch(path, { lookupTables: false }), targets));
  const { markdown, html } = renderComparison(arms, targets);
  mkdirSync(dirname(values.out), { recursive: true });
  writeFileSync(values.out + '.md', markdown);
  writeFileSync(values.out + '.html', html);
  return values.out;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try {
    const out = compare(process.argv.slice(2));
    console.log('Wrote ' + out + '.md and ' + out + '.html');
  } catch (err) {
    console.error('compare: ' + err.message.replace(/[\r\n]+/g, ' '));
    process.exitCode = 2;
  }
}
