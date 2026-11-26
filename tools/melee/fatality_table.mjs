#!/usr/bin/env node
// n31 melee 03p2: the fatality proof table. For each weapon and seed one headless run of
// res://dev/melee_n31/fatality_probe.tscn (the play_baseline bot holding ONE melee weapon, waves
// 1..N, the signature-kill feed installed), then weapon x victim kind -> counts per what plays
// (the signature row id or `generic`), and the owner's chainsaw rule share.
//   node tools/melee/fatality_table.mjs [--seeds=5] [--waves=4] [--weapons=a,b]
//     [--out=evidence/n31-melee/03-fatal] [--from=<dir of run jsons>]   (--from only aggregates)
// Takes the lane Godot lock (build/n31/godot.lock) around every run.
import { mkdirSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';

export const WEAPONS = ['claw', 'chainsaw', 'electro_baton', 'katana', 'plasma_sword'];
export const GRIND = 'chainsaw_grind';

export function parseArgs(argv) {
  const o = { seeds: 5, waves: 4, weapons: WEAPONS, out: 'evidence/n31-melee/03-fatal', from: null, label: '' };
  for (const a of argv) {
    const m = /^--([\w-]+)=(.*)$/.exec(a);
    if (!m) throw new Error('bad argument ' + a);
    const [, k, v] = m;
    if (k === 'seeds' || k === 'waves') o[k] = Number(v);
    else if (k === 'weapons') o.weapons = v.split(',');
    else if (k === 'out') o.out = v;
    else if (k === 'from') o.from = v;
    else if (k === 'label') o.label = v;
    else throw new Error('unknown flag --' + k);
  }
  for (const w of o.weapons) if (!WEAPONS.includes(w)) throw new Error('unknown weapon ' + w);
  if (o.label && !/^[\w.-]+$/.test(o.label)) throw new Error('--label must be a plain word');
  return o;
}

/** The base row of what plays: `chainsaw_grind_riot_cop:riot_cop` -> `chainsaw_grind_riot_cop`. */
export function plays(rec) {
  return String(rec.plays ?? 'generic').split(':')[0];
}

/** The victim kind column: archetype, with the shield state when he carries one. */
export function victimKind(rec) {
  const base = rec.archetype || rec.fighter_kind || 'unknown';
  return rec.shield && rec.shield !== 'none' ? `${base} (shield ${rec.shield})` : base;
}

/** weapon -> victim kind -> plays -> count, over every record of every run. */
export function tally(runs) {
  const out = {};
  for (const run of runs) for (const r of run.records ?? []) {
    const w = (out[r.weapon] ??= {});
    const v = (w[victimKind(r)] ??= {});
    v[plays(r)] = (v[plays(r)] ?? 0) + 1;
  }
  return out;
}

/** The owner's rule: every chainsaw kill on a shieldless human plays chainsaw_grind. */
export function chainsawShare(runs) {
  let n = 0, m = 0;
  const misses = [];
  for (const run of runs) for (const r of run.records ?? []) {
    if (r.weapon !== 'chainsaw' || !r.human || (r.shield && r.shield !== 'none')) continue;
    m += 1;
    if (plays(r).startsWith(GRIND)) n += 1;
    else misses.push({ seed: run.seed, tick: r.tick, archetype: r.archetype, plays: r.plays, kill_kind: r.kill_kind });
  }
  return { n, m, share: m > 0 ? Number((n / m).toFixed(4)) : null, misses };
}

export function shareLine(s) {
  const pct = s.share === null ? 'n/a' : `${(s.share * 100).toFixed(1)} %`;
  return `chainsaw kill on a shieldless human = chainsaw_grind: ${s.n}/${s.m} (${pct}; bar 100 %)`;
}

export function markdown(t) {
  const lines = ['| weapon | victim kind | what plays (count) |', '|---|---|---|'];
  for (const w of Object.keys(t).sort()) for (const v of Object.keys(t[w]).sort()) {
    const cell = Object.entries(t[w][v]).sort((a, b) => b[1] - a[1]).map(([p, c]) => `${p}: ${c}`).join(', ');
    lines.push(`| ${w} | ${v} | ${cell} |`);
  }
  return lines.join('\n') + '\n';
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

export function runArgs(weapon, seed, waves, file) {
  return ['tools/dev/run.mjs', 'fatality_probe', `--weapon=${weapon}`, `--seed=${seed}`, `--waves=${waves}`, `--result=${file}`];
}

function runOne(weapon, seed, waves, file) {
  takeLock('03p2');
  try {
    const r = spawnSync('node', runArgs(weapon, seed, waves, file), { cwd: ROOT, encoding: 'utf8' });
    return r.stdout.trim().split('\n').at(-1);
  } finally { rmSync(LOCK, { force: true }); }
}

export function main(argv) {
  const o = parseArgs(argv);
  const dir = resolve(ROOT, o.out);
  const runs = o.from ? resolve(o.from) : join(dir, 'runs' + (o.label ? '-' + o.label : ''));
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
  const all = readdirSync(runs).filter((n) => n.endsWith('.json')).sort()
    .map((f) => JSON.parse(readFileSync(join(runs, f), 'utf8'))).filter((r) => o.weapons.includes(r.weapon));
  const t = tally(all);
  const share = chainsawShare(all);
  const name = 'table' + (o.label ? '-' + o.label : '');
  const out = { schema: 'gtai.fatality-table/1', waves: o.waves, seeds: o.seeds, weapons: o.weapons, table: t, chainsaw: share,
    runs: all.map(({ records, ...r }) => ({ ...r, records: records.length })), log };
  writeFileSync(join(dir, `${name}.json`), JSON.stringify(out, null, 2) + '\n');
  const md = `# fatality proof table${o.label ? ' (' + o.label + ')' : ''}\n\nAverage bot, greedy picks, waves 1..${o.waves}, seeds 1..${o.seeds}, `
    + 'one melee weapon held, the signature-kill feed installed (as `--kill-feed`). Every kill of the run is listed, '
    + 'including the ones by allies and deploys (their weapon id). `generic` = the standard death.\n\n'
    + `${shareLine(share)}\n\n${markdown(t)}`;
  writeFileSync(join(dir, `${name}.md`), md);
  console.log(md);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) main(process.argv.slice(2));
