#!/usr/bin/env node
// n31 ghost: how many foes one Tonnage deploy hits. Runs res://dev/ghost_n31/ghost_measure.tscn
// through tools/dev/run.mjs (runGodot: ledger, import preflight, tree-kill timeout), writes
// build/n31/ghost/measure-<rev>-<mode>[-<tag>].json and prints one table row per variant and size
// (lab) or per variant and seed plus a total (play).
//   node tools/ghost/deploy_measure.mjs --mode=lab|play [--radius=4,5] [--full=only|both]
//     [--at=spot|rivet|both] [--charge=<ticks>] [--seeds=10] [--waves=8] [--per-size=15]
//     [--form=tonnage|ohm|dent|kerf] [--shapes-out=<abs>] [--tag=<name>] [--root=<worktree to run Godot in>] [--timeout=<s>]
// No --radius = main as shipped. --root runs another worktree's Godot project (its dev/ghost_n31 must
// exist there); the JSON still lands in this worktree's build/.
import { spawnSync } from 'node:child_process';
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT } from '../lib/repo.mjs';

const PASS = ['radius', 'full', 'at', 'charge', 'seeds', 'waves', 'per-size', 'shapes-out', 'profile', 'form'];
const OWN = ['mode', 'tag', 'root', 'timeout'];

/** {mode, tag, root, timeout, pass: ['--k=v'...]} or {error}. */
export function parseArgs(argv) {
  const out = { mode: null, tag: '', root: ROOT, timeout: 900, pass: [] };
  for (const a of argv) {
    const m = /^--([a-z-]+)(?:=(.*))?$/.exec(a);
    if (!m || (!PASS.includes(m[1]) && !OWN.includes(m[1]))) return { error: `unknown argument ${a}` };
    const [, key, value = ''] = m;
    if (key === 'mode') out.mode = value;
    else if (key === 'tag') out.tag = value;
    else if (key === 'root') out.root = resolve(value);
    else if (key === 'timeout') out.timeout = Number(value);
    else out.pass.push(value === '' ? `--${key}` : `--${key}=${value}`);
  }
  if (out.mode !== 'lab' && out.mode !== 'play') return { error: 'needs --mode=lab|play' };
  if (out.tag && !/^[a-z0-9_.-]+$/i.test(out.tag)) return { error: `bad --tag ${out.tag}` };
  return out;
}

export function stats(values) {
  if (values.length === 0) return { n: 0, mean: 0, median: 0 };
  const sorted = [...values].sort((a, b) => a - b);
  const mid = Math.floor(sorted.length / 2);
  const median = sorted.length % 2 ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2;
  return { n: values.length, mean: values.reduce((s, v) => s + v, 0) / values.length, median };
}

const variantOf = (row, form = 'tonnage') => (form === 'tonnage' ? '' : `${form} `) + `${row.shape ?? 'half'} r${row.radius_m} at ${row.at ?? 'spot'}`
  + (row.charge_ticks ? ` charge ${row.charge_ticks}` : '') + (row.shipped ? ' (main)' : '');

function summaryRow(mode, variant, group, deploys, size) {
  const near = deploys.reduce((t, d) => t + (d.near ?? 0), 0);
  const hits = stats(deploys.map((d) => d.hits));
  const kills = stats(deploys.map((d) => d.kills));
  const press = stats(deploys.map((d) => d.press_to_damage_ticks));
  return {
    mode, variant, group, deploys: deploys.length,
    mean_hits: hits.mean, median_hits: hits.median, mean_kills: kills.mean,
    share_hit: size ? hits.mean / size : (near ? deploys.reduce((t, d) => t + d.hits, 0) / near : null),
    mean_near: near ? near / deploys.length : null,
    zero_hit: deploys.filter((d) => d.hits === 0).length,
    press_to_damage_ticks: press.median,
  };
}

/** Lab: one row per variant and group size. Play: per variant and seed, then the variant's total. */
export function summarize(report) {
  const rows = [];
  const form = report.form ?? 'tonnage';
  const variants = [...new Set(report.rows.map((r) => variantOf(r, form)))];
  for (const v of variants) {
    const mine = report.rows.filter((r) => variantOf(r, form) === v);
    if (report.mode === 'lab') {
      for (const size of [...new Set(mine.map((r) => r.size))].sort((a, b) => a - b)) {
        const deploys = mine.filter((r) => r.size === size && r.landed);
        rows.push(summaryRow('lab', v, `${size} cops`, deploys, size));
      }
      continue;
    }
    for (const r of mine) rows.push(summaryRow('play', v, `seed ${r.seed}`, r.deploys ?? [], 0));
    rows.push(summaryRow('play', v, 'total', mine.flatMap((r) => r.deploys ?? []), 0));
  }
  return rows;
}

const fmt = (v) => (v === null ? '-' : Number.isInteger(v) ? String(v) : v.toFixed(2));

export function formatTable(rows) {
  const near = rows.some((r) => r.mean_near !== null && r.mean_near !== undefined);
  const head = ['mode', 'variant', 'group', 'deploys', 'mean hits', 'median hits', 'mean kills',
    ...(near ? ['mean near'] : []), 'share hit', 'zero-hit', 'key-down->damage ticks (median)'];
  const lines = [`| ${head.join(' | ')} |`, `|${head.map(() => '---').join('|')}|`];
  for (const r of rows) {
    const cells = [r.mode, r.variant, r.group, r.deploys, fmt(r.mean_hits), fmt(r.median_hits), fmt(r.mean_kills),
      ...(near ? [r.mean_near === null || r.mean_near === undefined ? '-' : fmt(r.mean_near)] : []),
      r.share_hit === null ? '-' : `${Math.round(r.share_hit * 100)}%`, r.zero_hit, fmt(r.press_to_damage_ticks)];
    lines.push(`| ${cells.join(' | ')} |`);
  }
  return lines.join('\n');
}

function main(argv) {
  const opts = parseArgs(argv);
  if (opts.error) { console.error(`deploy_measure: ${opts.error}`); return 2; }
  const rev = spawnSync('git', ['-C', opts.root, 'rev-parse', '--short', 'HEAD'], { encoding: 'utf8' }).stdout.trim();
  const dir = join(ROOT, 'build', 'n31', 'ghost');
  mkdirSync(dir, { recursive: true });
  const name = `measure-${rev}-${opts.mode}${opts.tag ? `-${opts.tag}` : ''}`;
  const raw = join(dir, `${name}.raw.json`).replace(/\\/g, '/');
  const started = Date.now();
  const run = spawnSync(process.execPath, [join(opts.root, 'tools', 'dev', 'run.mjs'),
    'res://dev/ghost_n31/ghost_measure.tscn', `--timeout=${opts.timeout}`, '--',
    `--mode=${opts.mode}`, `--out=${raw}`, ...opts.pass], { cwd: opts.root, stdio: 'inherit' });
  if (run.status !== 0) { console.error(`deploy_measure: run exit ${run.status}`); return 1; }
  const report = JSON.parse(readFileSync(raw, 'utf8'));
  const summary = summarize(report);
  const out = { schema: 'gtai.ghost-n31-measure-summary/1', rev, args: opts.pass, mode: opts.mode,
    run_s: (Date.now() - started) / 1000, godot_wall_s: report.wall_s, profile: report.profile ?? null,
    summary, report };
  writeFileSync(join(dir, `${name}.json`), `${JSON.stringify(out, null, 2)}\n`);
  console.log(formatTable(summary));
  console.log(`deploy_measure: wrote build/n31/ghost/${name}.json (${out.run_s.toFixed(1)} s)`);
  return 0;
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) process.exitCode = main(process.argv.slice(2));
