#!/usr/bin/env node
// Director's evidence script (not product code): what kills the gauntlet test player and when.
//   node killers.mjs <label>=<batch dir> [<label>=<batch dir> ...]   -> markdown on stdout
// Reads <dir>/runs/*.json (gtai gauntlet run rows). Per profile: median death wave, killers (last blow) with the
// death waves, seconds alive (sum of wave seconds, the death wave counted to its end-of-row), damage per wave.
import { readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

const median = (xs) => {
  const s = [...xs].sort((a, b) => a - b);
  if (!s.length) return NaN;
  const m = s.length >> 1;
  return s.length % 2 ? s[m] : (s[m - 1] + s[m]) / 2;
};
const fmt = (x, d = 1) => (Number.isFinite(x) ? Number(x.toFixed(d)).toString() : '-');

function load(dir) {
  const runs = [];
  for (const f of readdirSync(join(dir, 'runs')).filter((n) => n.endsWith('.json'))) {
    runs.push(JSON.parse(readFileSync(join(dir, 'runs', f), 'utf8')));
  }
  return runs;
}

function describe(run) {
  const seconds = run.waves.reduce((a, w) => a + (Number.isFinite(w.seconds) ? w.seconds : (w.form_seconds?.rivet ?? 0)), 0);
  const died = run.death && run.death.by !== 'timeout';
  const last = run.waves[run.waves.length - 1] ?? {};
  return {
    profile: run.profile, seed: run.seed, wave: died ? run.death.wave : run.wave_reached, censored: !died,
    by: died ? run.death.by : 'alive', seconds, lastDamage: last.damage_taken ?? 0,
    damage: run.waves.reduce((a, w) => a + (w.damage_taken ?? 0), 0), repaired: run.waves.reduce((a, w) => a + (w.hp?.repaired ?? 0), 0),
  };
}

const arms = process.argv.slice(2).map((a) => { const i = a.indexOf('='); return [a.slice(0, i), a.slice(i + 1)]; });
const rows = arms.map(([label, dir]) => [label, load(dir).map(describe)]);
const profiles = ['novice', 'average', 'expert'];
const out = [];
out.push('| arm | ' + profiles.map((p) => p + ' median death wave').join(' | ') + ' |', '|---|---:|---:|---:|');
for (const [label, rs] of rows) {
  out.push('| ' + label + ' | ' + profiles.map((p) => {
    const r = rs.filter((x) => x.profile === p);
    const c = r.filter((x) => x.censored).length;
    return fmt(median(r.map((x) => x.wave))) + (c ? ` (${c} censored)` : '');
  }).join(' | ') + ' |');
}
for (const p of profiles) {
  out.push('', `### ${p}`, '', '| arm | killer (last blow) | deaths | death waves | median s alive | median dmg taken in death wave |', '|---|---|---:|---|---:|---:|');
  for (const [label, rs] of rows) {
    const r = rs.filter((x) => x.profile === p);
    const by = new Map();
    for (const x of r) { if (!by.has(x.by)) by.set(x.by, []); by.get(x.by).push(x); }
    for (const [k, xs] of [...by].sort((a, b) => b[1].length - a[1].length || a[0].localeCompare(b[0]))) {
      out.push(`| ${label} | ${k} | ${xs.length} | ${xs.map((x) => x.wave).sort((a, b) => a - b).join(', ')} | ${fmt(median(xs.map((x) => x.seconds)), 0)} | ${fmt(median(xs.map((x) => x.lastDamage)))} |`);
    }
  }
}
// n28 addition: stomp share of wave 5 deaths and HP taken in the wave 5 stomp wave
out.push('', '### Stomp share of wave 5 deaths', '', '| arm | profile | runs | died in wave 5 | by stomp | stomp share of wave 5 deaths | median dmg taken in that wave 5 (stomp deaths) |', '|---|---|---:|---:|---:|---:|---:|');
for (const [label, rs] of rows) for (const p of ['novice', 'average']) {
  const r = rs.filter((x) => x.profile === p), w5 = r.filter((x) => !x.censored && x.wave === 5), st = w5.filter((x) => x.by === 'stomp');
  out.push(`| ${label} | ${p} | ${r.length} | ${w5.length} | ${st.length} | ${w5.length ? fmt(100 * st.length / w5.length, 0) + ' %' : '-'} | ${fmt(median(st.map((x) => x.lastDamage)))} |`);
}
process.stdout.write(out.join('\n') + '\n');
