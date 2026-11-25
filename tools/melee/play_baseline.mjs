#!/usr/bin/env node
// n31 melee 01b: the gauntlet melee baseline. For each weapon and seed one headless run of
// res://dev/melee_n31/play_baseline.tscn (the average bot, waves 1..N, holding ONE melee weapon),
// then per-weapon totals: swings, hits, kills, kills per swing, damage taken, deaths, wave reached.
//   node tools/melee/play_baseline.mjs [--label=before] [--seeds=5] [--waves=4] [--weapons=a,b]
//     [--out=evidence/n31-melee/01-baseline] [--from=<dir of run jsons>]   (--from only aggregates)
// Takes the lane Godot lock (build/n31/godot.lock) around every run.
import { mkdirSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';

export const WEAPONS = ['claw', 'chainsaw', 'electro_baton', 'katana', 'plasma_sword'];
const sum = (rows, key) => rows.reduce((t, r) => t + (r[key] ?? 0), 0);
const ratio = (a, b) => (b > 0 ? Number((a / b).toFixed(3)) : null);

export function parseArgs(argv) {
  const o = { label: 'before', seeds: 5, waves: 4, weapons: WEAPONS, out: 'evidence/n31-melee/01-baseline', from: null };
  for (const a of argv) {
    const m = /^--([\w-]+)=(.*)$/.exec(a);
    if (!m) throw new Error('bad argument ' + a);
    const [, k, v] = m;
    if (k === 'label') o.label = v;
    else if (k === 'seeds' || k === 'waves') o[k] = Number(v);
    else if (k === 'weapons') o.weapons = v.split(',');
    else if (k === 'out') o.out = v;
    else if (k === 'from') o.from = v;
    else throw new Error('unknown flag --' + k);
  }
  if (!/^[\w.-]+$/.test(o.label)) throw new Error('--label must be a plain word');
  for (const w of o.weapons) if (!WEAPONS.includes(w)) throw new Error('unknown weapon ' + w);
  return o;
}

/** Totals and means for one weapon's run rows. */
export function summarize(rows) {
  const n = rows.length;
  const swings = sum(rows, 'swings');
  const kills = sum(rows, 'kills_own_weapon');
  return {
    runs: n,
    seeds: rows.map((r) => r.seed),
    swings,
    hits: sum(rows, 'hits'),
    whiffs: sum(rows, 'whiffs'),
    kills_own_weapon: kills,
    kills_all: sum(rows, 'kills_all'),
    kills_per_swing: ratio(kills, swings),
    kills_all_per_swing: ratio(sum(rows, 'kills_all'), swings),
    mean_kills_per_swing: ratio(rows.reduce((t, r) => t + (r.swings > 0 ? r.kills_own_weapon / r.swings : 0), 0), n),
    hit_rate: ratio(sum(rows, 'hits'), swings),
    damage_taken_mean: ratio(sum(rows, 'damage_taken'), n),
    deaths: rows.filter((r) => !r.alive).length,
    unfinished: rows.filter((r) => !r.finished).length,
    wave_reached_mean: ratio(sum(rows, 'wave_reached'), n),
    wave_reached_min: n ? Math.min(...rows.map((r) => r.wave_reached)) : null,
  };
}

export function table(summary) {
  const head = '| weapon | runs | swings | hits | kills (own) | kills/swing | mean k/s | kills all | dmg taken/run | deaths | wave (mean/min) |\n'
    + '|---|---|---|---|---|---|---|---|---|---|---|\n';
  return head + Object.entries(summary).map(([w, s]) => `| ${w} | ${s.runs} | ${s.swings} | ${s.hits} | `
    + `${s.kills_own_weapon} | ${s.kills_per_swing} | ${s.mean_kills_per_swing} | ${s.kills_all} | ${s.damage_taken_mean} | `
    + `${s.deaths} | ${s.wave_reached_mean}/${s.wave_reached_min} |`).join('\n') + '\n';
}

const LOCK = join(ROOT, 'build/n31/godot.lock');
function sleep(ms) { Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, ms); }
function takeLock(tag) {
  mkdirSync(join(ROOT, 'build/n31'), { recursive: true });
  for (;;) {
    try { writeFileSync(LOCK, `${tag} ${process.pid} ${new Date().toTimeString().slice(0, 8)}\n`, { flag: 'wx' }); return; }
    catch {
      let age = 0;
      try { age = Date.now() - statSync(LOCK).mtimeMs; } catch { continue; }
      if (age > 30 * 60 * 1000) rmSync(LOCK, { force: true });
      else sleep(10000);
    }
  }
}

function runOne(weapon, seed, waves, file) {
  takeLock('01b');
  try {
    const r = spawnSync('node', ['tools/dev/run.mjs', 'play_baseline', `--weapon=${weapon}`, `--seed=${seed}`,
      `--waves=${waves}`, `--result=${file}`], { cwd: ROOT, encoding: 'utf8' });
    return r.stdout.trim().split('\n').at(-1);
  } finally { rmSync(LOCK, { force: true }); }
}

export function main(argv) {
  const o = parseArgs(argv);
  const dir = resolve(ROOT, o.out, o.label);
  const runs = o.from ? resolve(o.from) : join(dir, 'runs');
  mkdirSync(runs, { recursive: true });
  const log = [];
  if (!o.from) {
    for (const w of o.weapons) for (let s = 1; s <= o.seeds; s++) {
      const file = join(runs, `${w}-${s}.json`);
      rmSync(file, { force: true });
      log.push(`${w} seed ${s}: ${runOne(w, s, o.waves, file)}`);
      console.log(log.at(-1));
    }
  }
  const byWeapon = {};
  const all = [];
  for (const f of readdirSync(runs).filter((n) => n.endsWith('.json')).sort()) {
    const row = JSON.parse(readFileSync(join(runs, f), 'utf8'));
    if (!o.weapons.includes(row.weapon)) continue;
    (byWeapon[row.weapon] ??= []).push(row);
    all.push(row);
  }
  const summary = Object.fromEntries(o.weapons.filter((w) => byWeapon[w]).map((w) => [w, summarize(byWeapon[w])]));
  const out = { schema: 'gtai.play-baseline/1', label: o.label, waves: o.waves, bot: 'average', pick: 'greedy',
    seeds: o.seeds, weapons: summary, runs: all.map(({ melee_all, ...r }) => r), log };
  writeFileSync(join(dir, 'baseline.json'), JSON.stringify(out, null, 2) + '\n');
  writeFileSync(join(dir, `${o.label}.md`), `# gauntlet melee baseline: ${o.label}\n\n`
    + `Average bot, greedy picks, waves 1..${o.waves}, seeds 1..${o.seeds}, one melee weapon held (blades swing through the `
    + `primary button; claw through the melee key). kills (own) = kills credited to the held weapon.\n\n${table(summary)}`);
  console.log(table(summary));
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) main(process.argv.slice(2));
