// ACH-04 rules over steam/achievements/achievements.json. Pure: returns {errors, warnings}.
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { validate } from '../lib/mini_schema.mjs';
import { ROOT, ownGdFiles, readJson } from '../lib/repo.mjs';

// DEVIATION ACH-04 (docs/decisions.md): until the first gameplay port there is no emit site
// and no canon in this repo, so a dead trigger and an unresolved source only warn.
export const DEAD_TRIGGER_IS_ERROR = false;
export const UNRESOLVED_SOURCE_IS_ERROR = false;

const BLOCK_BANDS = { story: [10, 12], soul: [8, 10], absurd: [8, 10], mastery: [3, 4], meta: [1, 2] };
const MISSABLE_BLOCKS = ['absurd', 'mastery'];

const wordlist = (name) =>
  readFileSync(join(ROOT, 'tools', 'achievements', 'wordlists', name), 'utf8')
    .split('\n').map((l) => l.trim().toLowerCase()).filter((l) => l && !l.startsWith('#'));

function emitSites() {
  const sites = new Set();
  for (const file of ownGdFiles()) {
    for (const m of readFileSync(file, 'utf8').matchAll(/Events\.([a-z0-9_]+)\.emit\(/g)) {
      sites.add(m[1]);
    }
  }
  return sites;
}

export function checkAll(doc, schema, events) {
  const errors = validate(schema, doc).map((e) => `schema ${e}`);
  const warnings = [];
  if (errors.length) return { errors, warnings };
  const stats = new Map(doc.stats.map((s) => [s.id, s]));
  const signals = new Map(events.signals.map((s) => [s.name, s]));
  const sites = emitSites();
  const banned = [...wordlist('profanity.txt'), ...wordlist('brands.txt')];
  const seen = new Set();
  for (const id of [...doc.stats.map((s) => s.id), ...doc.achievements.map((a) => a.id)]) {
    if (seen.has(id)) errors.push(`${id}: duplicate id`);
    seen.add(id);
  }
  for (const ach of doc.achievements) {
    const err = (msg) => errors.push(`${ach.id}: ${msg}`);
    checkBlock(ach, err);
    checkTrigger(ach, signals, stats, err);
    checkStat(ach, stats, err);
    checkAllAges(ach, banned, err);
    if (!sites.has(ach.trigger.on)) {
      const msg = `${ach.id}: dead trigger, no Events.${ach.trigger.on}.emit( site in project/`;
      (DEAD_TRIGGER_IS_ERROR ? errors : warnings).push(msg);
    }
    const unresolved = `${ach.id}: source ${ach.source} not resolved (no canon in this repo yet)`;
    (UNRESOLVED_SOURCE_IS_ERROR ? errors : warnings).push(unresolved);
  }
  warnings.push(...blockMix(doc.achievements));
  return { errors, warnings };
}

function checkBlock(ach, err) {
  if (!ach.missable) return;
  if (!MISSABLE_BLOCKS.includes(ach.block)) err(`a ${ach.block} achievement must not be missable`);
  if (!ach.retry) err('missable without a noted retry path');
}

function checkTrigger(ach, signals, stats, err) {
  const sig = signals.get(ach.trigger.on);
  if (!sig) return err(`trigger on "${ach.trigger.on}" is not in data/schemas/events.json`);
  const params = new Set(sig.params.map((p) => p.name));
  for (const w of ach.trigger.where ?? []) {
    if (!params.has(w.param)) err(`where.param "${w.param}" is not a param of ${sig.name}`);
    const ops = ['eq', 'in', 'gte'].filter((k) => k in w);
    if (ops.length !== 1) err(`where on "${w.param}" needs exactly one of eq/in/gte`);
  }
  for (const d of ach.trigger.do) {
    if (d.op === 'stat_inc' && !stats.has(d.stat)) err(`stat_inc on unknown stat ${d.stat}`);
    if (d.op === 'flag' && !d.flag) err('flag op without a flag name');
  }
  const gte = ach.trigger.unlock_when?.stat_gte;
  if (gte && !stats.has(gte.stat)) err(`unlock_when on unknown stat ${gte.stat}`);
  if (gte && ach.stat && gte.value !== ach.stat.goal) err('unlock_when value differs from goal');
}

function checkStat(ach, stats, err) {
  if (!ach.stat) return;
  const def = stats.get(ach.stat.id);
  if (!def) return err(`unknown stat ${ach.stat.id}`);
  if (def.max !== ach.stat.goal) err(`goal ${ach.stat.goal} differs from ${def.id} max ${def.max}`);
}

function checkAllAges(ach, banned, err) {
  const texts = [...Object.values(ach.name), ...Object.values(ach.desc), ach.icon.brief];
  const hay = ` ${texts.join(' ').toLowerCase().replace(/[^a-z0-9]+/g, ' ')} `;
  for (const word of banned) {
    if (hay.includes(` ${word} `)) err(`all-ages lint: "${word}" in name, desc or icon brief`);
  }
}

function blockMix(achievements) {
  const counts = Object.fromEntries(Object.keys(BLOCK_BANDS).map((b) => [b, 0]));
  for (const a of achievements) counts[a.block] += 1;
  const off = Object.entries(BLOCK_BANDS)
    .filter(([b, [lo, hi]]) => counts[b] < lo || counts[b] > hi)
    .map(([b, [lo, hi]]) => `${b} ${counts[b]} (want ${lo}-${hi})`);
  return off.length ? [`block mix off-band (ACH-11): ${off.join(', ')}`] : [];
}

export function loadInputs() {
  return {
    doc: readJson(join(ROOT, 'steam', 'achievements', 'achievements.json')),
    schema: readJson(join(ROOT, 'steam', 'achievements', 'achievements.schema.json')),
    events: readJson(join(ROOT, 'project', 'data', 'schemas', 'events.json')),
  };
}
