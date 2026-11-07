#!/usr/bin/env node
// Interleaved A/B over the handheld simulator (sim.mjs): each round runs every variant once, in
// order, so a slow spell on the shared machine lands on all of them; prints each variant's median
// over the rounds and the spread (max - min) as the noise. Writes <out>/<name>.ab.json.
// Usage: node tools/handheld/ab.mjs --name=<exp> --rounds=3 --variant="<sim args>" --variant="..."
// e.g. --variant="--device=deck_bench --renderer=forward_plus" --variant="--device=deck_bench --renderer=mobile"
import { spawnSync } from 'node:child_process';
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(HERE, '..', '..');
const KEYS = ['p50_ms', 'p99_ms', 'low1_fps', 'over33_settled', 'render_gpu_ms_p50', 'render_cpu_ms_p50',
  'process_ms_p50', 'cpu_pinned_pct_p50', 'private_mb_max', 'gpu_shared_mb_max', 'gpu_dedicated_mb_max'];

/** Splits a variant string into args, keeping "..." groups whole. */
export const splitArgs = (s) => (s.match(/(?:[^\s"]+|"[^"]*")+/g) ?? []).map((x) => x.replaceAll('"', ''));

export function aggregate(runs) {
  const out = {};
  for (const k of KEYS) {
    const xs = runs.map((r) => r.summary[k]).filter((x) => typeof x === 'number').sort((a, b) => a - b);
    if (!xs.length) continue;
    out[k] = { median: Math.round(xs[xs.length >> 1] * 100) / 100, spread: Math.round((xs[xs.length - 1] - xs[0]) * 100) / 100 };
  }
  return out;
}

function main() {
  const own = process.argv.slice(2);
  const name = (own.find((a) => a.startsWith('--name=')) ?? '--name=ab').slice(7);
  const rounds = Number((own.find((a) => a.startsWith('--rounds=')) ?? '--rounds=3').slice(9));
  const variants = own.filter((a) => a.startsWith('--variant=')).map((a) => a.slice(10));
  const out = join(ROOT, 'evidence', 'sim', name);
  mkdirSync(out, { recursive: true });
  const runs = variants.map(() => []);
  for (let r = 0; r < rounds; r++) {
    variants.forEach((v, i) => {
      const label = `v${i}-r${r}`;
      const res = spawnSync('node', [join(HERE, 'sim.mjs'), ...splitArgs(v), `--out=${out}`, `--label=${label}`],
        { encoding: 'utf8', stdio: ['ignore', 'pipe', 'inherit'] });
      try { runs[i].push(JSON.parse(readFileSync(join(out, `${label}.json`), 'utf8'))); } catch { console.error(`${label}: no result (${res.status})`); }
      console.log(`round ${r + 1}/${rounds} variant ${i}: ${res.stdout.split('\n')[0].slice(0, 160)}`);
    });
  }
  const table = variants.map((v, i) => ({ variant: v, runs: runs[i].length,
    contended: runs[i].filter((x) => x.contended !== 'quiet').length, ...aggregate(runs[i]) }));
  writeFileSync(join(out, `${name}.ab.json`), `${JSON.stringify({ schema: 'gtai.handheld-ab/1', name, rounds, at: new Date().toISOString(), table }, null, 2)}\n`);
  for (const t of table) {
    console.log(`\n${t.variant}  (${t.runs} runs, ${t.contended} contended)`);
    for (const k of KEYS) if (t[k]) console.log(`  ${k.padEnd(22)} ${String(t[k].median).padStart(8)}  +-${t[k].spread}`);
  }
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main();
