import { execFileSync } from 'node:child_process';
import { createHash, randomUUID } from 'node:crypto';
import { closeSync, existsSync, mkdirSync, openSync, readFileSync, renameSync, unlinkSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { canonicalJson } from '../lib/canonical_json.mjs';
import { readJson } from '../lib/repo.mjs';

export const BASELINE = 'tools/gauntlet/baseline.json';
const BASE_SCHEMA = 'gtai.gauntlet-baseline/1';
export const TABLES = 'project/data/tables/';
export const digest = (bytes) => createHash('sha256').update(bytes).digest('hex');

export function git(root, ...args) {
  const env = Object.fromEntries(Object.entries(process.env).filter(([k]) => !/^GIT_/i.test(k)));
  return execFileSync('git', args, { cwd: root, env, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });
}

export function atomicWrite(file, contents) {
  mkdirSync(dirname(file), { recursive: true });
  const tmp = file + '.' + randomUUID() + '.tmp';
  writeFileSync(tmp, contents, { flag: 'wx' });
  try { renameSync(tmp, file); }
  finally { if (existsSync(tmp)) unlinkSync(tmp); }
}

// Shared by propose, apply and revert in this worktree. An interrupted owner leaves a visible lock.
export function withLock(root, action) {
  const path = join(git(root, 'rev-parse', '--absolute-git-dir').trim(), 'gauntlet-tune.lock');
  let fd;
  try { fd = openSync(path, 'wx'); }
  catch (err) {
    if (err.code === 'EEXIST') throw new Error('tuner lock held: ' + path);
    throw err;
  }
  try { writeFileSync(fd, String(process.pid)); return action(); }
  finally { closeSync(fd); unlinkSync(path); }
}

export function numericSlot(table, knob) {
  const keys = knob.pointer.slice(1).split('/').map((k) => k.replaceAll('~1', '/').replaceAll('~0', '~'));
  const key = keys.pop();
  let parent = table;
  for (const k of keys) {
    if (!parent || !Object.hasOwn(parent, k)) return null;
    parent = parent[k];
  }
  if (!parent || !Object.hasOwn(parent, key) || !Number.isFinite(parent[key])) return null;
  // Array indices in a JSON pointer are positional. Never silently tune a different row after a reorder.
  if (keys[0] === 'archetypes' && knob.id !== parent.id + '.' + key) return null;
  if (Array.isArray(table.weapons) && keys[0] === 'weapons' && knob.id !== 'weapon.' + parent.id + '.' + key) return null;
  return { parent, key };
}

export function inventory(root, warn = console.error) {
  const knobs = readJson(join(root, 'tools/gauntlet/knobs.json'));
  const tables = new Map(), entries = new Map(), seen = new Set();
  for (const knob of knobs) {
    const { id, file, kind, min, max } = knob;
    if (!/^project\/data\/tables\/(combat|enemies|gauntlet|weapons)\.json$/.test(file) || seen.has(id)
      || !knob.pointer?.startsWith('/') || !['int', 'float'].includes(kind)
      || !Number.isFinite(min) || !Number.isFinite(max) || min > max) throw new Error('invalid knob: ' + id);
    seen.add(id);
    const path = join(root, file);
    if (!tables.has(file) && existsSync(path)) tables.set(file, readJson(path));
    const table = tables.get(file);
    const slot = table && numericSlot(table, knob);
    if (!slot || knob.pending) {
      warn(id + (knob.pending ? ' pending' : ' unresolved') + ': ' + file + '#' + knob.pointer + ' skipped');
      continue;
    }
    entries.set(id, { knob, value: slot.parent[slot.key] });
  }
  return { entries, tables };
}

export function readBaseline(root) {
  const doc = readJson(join(root, BASELINE));
  if (doc.schema !== BASE_SCHEMA || !doc.created || !doc.git_sha || !doc.values
    || Array.isArray(doc.values) || typeof doc.values !== 'object'
    || !Object.values(doc.values).every(Number.isFinite)) throw new Error('invalid tuner baseline');
  return doc;
}

// Called under the worktree lock. Only missing keys may be appended to an existing baseline.
export function ensureBaseline(root, entries) {
  const path = join(root, BASELINE);
  const existing = existsSync(path);
  const baseline = existing ? readBaseline(root) : {
    schema: BASE_SCHEMA, created: new Date().toISOString(), git_sha: git(root, 'rev-parse', 'HEAD').trim(), values: {}
  };
  const additions = [...entries].filter(([id]) => !Object.hasOwn(baseline.values, id));
  for (const [id, { value }] of additions) baseline.values[id] = value;
  if (!existing || additions.length) atomicWrite(path, canonicalJson(baseline));
  return baseline;
}

export function clamped(knob, current, baseline, requested) {
  if (![current, baseline, requested].every(Number.isFinite)) return current;
  let lo = Math.max(knob.min, current * 0.8, baseline * 0.5);
  let hi = Math.min(knob.max, current * 1.25, baseline * 2);
  let value = requested;
  if (knob.kind === 'int') {
    lo = Math.ceil(lo);
    hi = Math.floor(hi);
    value = requested > current ? Math.ceil(value) : Math.floor(value);
  } else value = Number(value.toPrecision(12));
  if (lo > hi) return current;
  const next = Math.min(hi, Math.max(lo, value));
  // Avoid long decimal tails from multiplying binary floats where the decimal bound is exact.
  const short = Number(next.toPrecision(12));
  return short >= lo && short <= hi ? short : next;
}
