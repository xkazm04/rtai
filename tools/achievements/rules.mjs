// ACH-04 rules over steam/achievements/achievements.json. Pure: returns {errors, warnings}.
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { validate } from '../lib/mini_schema.mjs';
import { ROOT, ownGdFiles, readJson, rel } from '../lib/repo.mjs';
import { stripComment } from '../style/check_gd.mjs';

// DEVIATION ACH-04 (docs/decisions.md): a trigger on a signal events.json still marks
// `wired: false` (planned, no emitter yet) only warns; on a wired signal the emitter-wiring
// check below guarantees an emit site, so it cannot be dead. No canon in this repo yet, so an
// unresolved source only warns.
export const DEAD_TRIGGER_IS_ERROR = false;
export const UNRESOLVED_SOURCE_IS_ERROR = false;

// Emit sites in these trees never count as wiring: a test or dev cheat emitting a signal does
// not make the game emit it.
const NON_PRODUCTION = ['project/tests/', 'project/dev/'];

const BLOCK_BANDS = { story: [10, 12], soul: [8, 10], absurd: [8, 10], mastery: [3, 4], meta: [1, 2] };
const MISSABLE_BLOCKS = ['absurd', 'mastery'];

const wordlist = (name) =>
  readFileSync(join(ROOT, 'tools', 'achievements', 'wordlists', name), 'utf8')
    .split('\n').map((l) => l.trim().toLowerCase()).filter((l) => l && !l.startsWith('#'));

/**
 * Production emit sites per signal: Map<name, repo-relative paths>. Matches the autoload
 * (`Events.x.emit(`) and the injected bus (`ctx.events.x.emit(`, `_events.x.emit(`).
 */
export function emitSites(files = ownGdFiles()) {
  const sites = new Map();
  for (const file of files) {
    const path = rel(file);
    if (NON_PRODUCTION.some((p) => path.startsWith(p))) continue;
    const code = readFileSync(file, 'utf8').split('\n').map(stripComment).join('\n');
    for (const m of code.matchAll(/\b_?[Ee]vents\.([a-z0-9_]+)\.emit\(/g)) {
      if (!sites.has(m[1])) sites.set(m[1], []);
      sites.get(m[1]).push(path);
    }
  }
  return sites;
}

/**
 * Emitter wiring (ARC-06 + ACH-04), read from events.json: a `wired` signal has at least one
 * production emit site and all of them sit under project/<emitter>/; a planned one has none.
 * Emits of names events.json does not list are errors too.
 */
export function emitterWiring(events, sites) {
  const errors = [];
  const warnings = [];
  const listed = new Set(events.signals.map((s) => s.name));
  for (const sig of events.signals) {
    const at = sites.get(sig.name) ?? [];
    const home = `project/${sig.emitter.replace(/\/$/, '')}/`;
    if (sig.wired && !at.length) errors.push(`${sig.name}: wired in events.json but no emit site`);
    if (sig.wired) {
      for (const p of at.filter((x) => !x.startsWith(home))) {
        errors.push(`${sig.name}: emitted from ${p}, outside its declared emitter ${home}`);
      }
    }
    if (!sig.wired && at.length) {
      errors.push(`${sig.name}: emitted from ${at.join(', ')} but events.json says wired: false`);
    }
    if (!sig.wired) warnings.push(`${sig.name}: planned, no emitter yet (${home})`);
  }
  for (const [name, at] of sites) {
    if (!listed.has(name)) errors.push(`${name}: emitted from ${at.join(', ')}, not in events.json`);
  }
  return { errors, warnings };
}

export function checkAll(doc, schema, events) {
  const errors = validate(schema, doc).map((e) => `schema ${e}`);
  const warnings = [];
  if (errors.length) return { errors, warnings };
  const stats = new Map(doc.stats.map((s) => [s.id, s]));
  const signals = new Map(events.signals.map((s) => [s.name, s]));
  const wiring = emitterWiring(events, emitSites());
  errors.push(...wiring.errors);
  warnings.push(...wiring.warnings);
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
    const sig = signals.get(ach.trigger.on);
    if (sig && !sig.wired) {
      const msg = `${ach.id}: dead trigger, ${sig.name} is not wired yet (events.json)`;
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
