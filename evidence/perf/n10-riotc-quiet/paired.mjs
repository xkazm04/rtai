import { readFileSync } from 'node:fs';
const d = JSON.parse(readFileSync('evidence/perf/n10-riotc-quiet/ab.json', 'utf8'));
const by = {}; for (const [k, v] of Object.entries(d.raw.riotc)) by[k.split('@')[0]] = v;
const med = (v) => { const s = [...v].sort((a, b) => a - b); const n = s.length; return n % 2 ? s[(n - 1) / 2] : (s[n / 2 - 1] + s[n / 2]) / 2; };
for (const [x, y] of [['main', 'head'], ['main', 'twin'], ['twin', 'head']])
  for (const m of ['p50', 'p99', 'p999', 'worst']) {
    const ds = by.main.map((_, i) => by[y][i].stats[m] - by[x][i].stats[m]);
    console.log(`${y}-${x} ${m}: median ${med(ds).toFixed(3)} min ${Math.min(...ds).toFixed(3)} max ${Math.max(...ds).toFixed(3)} lower ${ds.filter((v) => v < 0).length}/${ds.length}`);
  }
console.log('locked', d.locked, 'others', Object.values(by).flat().map((r) => r.others).join(','), 'contended', Object.values(by).flat().filter((r) => r.contended).length);
