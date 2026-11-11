// Paired t-5 summary of a t5_aab.sh TSV: per round B-A and A2-A for both sims, medians, sign counts.
import { readFileSync } from 'node:fs';
const rows = readFileSync(process.argv[2], 'utf8').trim().split(/\r?\n/).slice(1).map((l) => l.split('\t'));
const by = {};
for (const [r, arm, gd, nat, , others] of rows) (by[r] ??= {})[arm] = { gd: +gd, nat: +nat * 1000, others: +others };
const med = (a) => { const s = [...a].sort((x, y) => x - y); const m = s.length >> 1; return s.length % 2 ? s[m] : (s[m - 1] + s[m]) / 2; };
for (const k of ['gd', 'nat']) {
  const unit = k === 'gd' ? 'ms' : 'us';
  const rs = Object.values(by).filter((x) => x.A && x.B && x.A2);
  const ba = rs.map((x) => x.B[k] - x.A[k]); const aa = rs.map((x) => x.A2[k] - x.A[k]);
  const base = med(rs.map((x) => x.A[k]));
  console.log(`${k === 'gd' ? 'GDScript ref step' : 'native step'}: B-A ${ba.map((v) => v.toFixed(k === 'gd' ? 3 : 1)).join(' ')} ${unit}; median ${med(ba).toFixed(k === 'gd' ? 3 : 1)} ${unit} on A ${base.toFixed(k === 'gd' ? 2 : 1)} (${(100 * med(ba) / base).toFixed(1)} %), B faster in ${ba.filter((v) => v < 0).length}/${ba.length}; A2-A median ${med(aa).toFixed(k === 'gd' ? 3 : 1)}, max |${Math.max(...aa.map(Math.abs)).toFixed(k === 'gd' ? 3 : 1)}|`);
}
console.log(`rounds ${Object.keys(by).length}; other Godot processes at run starts: ${rows.map((r) => r[5]).join(',')}`);
