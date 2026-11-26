#!/usr/bin/env node
// n31-24: before -> after table of two prop takes (the dirs prop_take.mjs wrote).
//   node tools/ground/prop_take_report.mjs --before=<dir> --after=<dir>... > table.md
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { judge } from './prop_take_lib.mjs';

const read = (dir, f) => JSON.parse(readFileSync(join(dir, f), 'utf8'));
const cell = (v) => (v === undefined || v === null ? '' : v);

/** One arena: rows pairing each probe's before and after stop. */
export function compare(beforeDir, afterDir) {
  const [bp, ap] = [read(beforeDir, 'probes.json'), read(afterDir, 'probes.json')];
  const [bs, as] = [read(beforeDir, 'stops.json').stops, read(afterDir, 'stops.json').stops];
  return ap.probes.map((p) => {
    const q = bp.probes.find((x) => x.id === p.id) ?? p;
    const b = bs.find((s) => s.id === p.id) ?? {};
    const a = as.find((s) => s.id === p.id) ?? {};
    return { id: p.id, pb: q.base, pa: p.base, mode: p.mode, b, a, jb: judge(q, b), ja: judge(p, a) };
  });
}

export function table(arena, rows) {
  const out = [`## ${arena}`, '', '| probe | before stop_m | before base_m | before bar | after stop_m | after base_m | after bar (judged on) | radius before / after | placed from (after) |', '|---|---|---|---|---|---|---|---|---|'];
  for (const r of rows) {
    out.push(`| ${r.id} | ${cell(r.b.stop_m)} | ${r.pb ? cell(r.b.box_m) : ''} | ${r.jb.bar} | ${cell(r.a.stop_m)} | ${r.pa ? cell(r.a.box_m) : ''} | ${r.ja.bar} (${r.ja.on}) | ${cell(r.b.radius_m)} / ${cell(r.a.radius_m)} | ${cell(r.a.placed)} |`);
  }
  const n = (k) => rows.filter((r) => r[k].bar === 'pass').length;
  const live = (k) => rows.filter((r) => r[k].bar !== 'n/a').length;
  out.push('', `Bar passes: before ${n('jb')}/${live('jb')}, after ${n('ja')}/${live('ja')} (n/a = fixture behind the building wall, not counted).`);
  return out.join('\n');
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const arg = (k) => process.argv.filter((a) => a.startsWith(`--${k}=`)).map((a) => a.slice(k.length + 3));
  console.log(table(arg('arena')[0] ?? '', compare(arg('before')[0], arg('after')[0])));
}
