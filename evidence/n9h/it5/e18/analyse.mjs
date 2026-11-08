// E18 analysis: per run, the per-frame work (wall - pump: pump is the frame-pacing wait), the sim's
// ticks per wall second over the settled window (frame 60 on: real time = 60), and the stalls.
// node evidence/n9h/it5/e18/analyse.mjs <ab dir>...
import { readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
const q = (xs, p) => { const s = [...xs].sort((a, b) => a - b); return s[Math.min(s.length - 1, Math.floor(p * s.length))]; };
const r2 = (x) => Math.round(x * 100) / 100;
for (const dir of process.argv.slice(2)) {
  const rows = [];
  for (const f of readdirSync(dir).filter((x) => /^v\d-r\d\.json$/.test(x)).sort()) {
    const run = JSON.parse(readFileSync(join(dir, f), 'utf8'));
    const fr = JSON.parse(readFileSync(join(dir, f.replace('.json', '.frames.json')), 'utf8'));
    const n = fr.wall_ms.length, from = 60;
    const work = fr.wall_ms.slice(from).map((w, i) => w - fr.pump_ms[from + i]);
    const wallS = fr.wall_ms.slice(from).reduce((a, b) => a + b, 0) / 1000;
    const ticks = fr.tick[n - 1] - fr.tick[from];
    const stalls = fr.wall_ms.slice(from).filter((w) => w > 100).length;
    rows.push({ run: f.replace('.json', ''), cap: run.cpu_cap?.pct_of_one_cpu ?? 0, contended: run.contended !== 'quiet',
      work_p50: r2(q(work, 0.5)), work_p95: r2(q(work, 0.95)), ticks_per_s: r2(ticks / wallS),
      over20_pct: r2(100 * fr.wall_ms.slice(from).filter((w) => w > 20).length / (n - from)), stalls_100ms: stalls,
      worst_ms: r2(Math.max(...fr.wall_ms.slice(from))), cpu_cores: r2((run.summary.cpu_pinned_pct_p50 ?? 0) * run.threads / 100) });
  }
  console.log(`\n${dir}`);
  console.table(rows);
}
