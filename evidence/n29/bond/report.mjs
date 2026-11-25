// node evidence/n29/bond/report.mjs <n29 arm json> <n28 mastery.json> <out dir>
// n29 = Tonnage's bar 70. Writes mastery.json and mastery.md: n27 free, n28 and n29 rows.
import { readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const [n29File, n28File, out] = process.argv.slice(2);
const read = f => JSON.parse(readFileSync(f, 'utf8'));
const n29 = read(n29File), n28 = read(n28File);
const forms = ['dent', 'kerf', 'ohm', 'tonnage'];
const cap = s => s[0].toUpperCase() + s.slice(1);
const median = v => { const a = [...v].sort((x, y) => x - y); return a.length ? (a[Math.floor(a.length / 2)] + a[Math.floor((a.length - 1) / 2)]) / 2 : null; };
const tonnageOf = arm => arm.runs.filter(r => r.mastery_at_rest.tonnage !== null)
  .map(r => `${r.seed} (w${r.mastery_at_rest.tonnage})`).join(', ') || 'none';
const summary = arm => {
  const firsts = arm.runs.map(r => r.first_mastery).filter(Number.isFinite).sort((a, b) => a - b);
  const ghosts = new Set(arm.runs.flatMap(r => forms.filter(f => r.mastery_at_rest[f] !== null)));
  return { runs_with_mastery: firsts.length, first_mastery_waves: firsts, median_first: median(firsts),
    ghosts_mastered: [...ghosts].sort(), tonnage_mastered: tonnageOf(arm),
    kerf_mastered: arm.runs.some(r => r.mastery_at_rest.kerf !== null) };
};
const s29 = summary(n29);
const s27 = n28.summary.n27_free, s28 = n28.summary.n28;
const t28 = tonnageOf(n28.arms.n28);
const cell = v => v === null ? '—' : v;
const entries = r => Object.entries((r.entries ?? []).reduce((o, e) => ({ ...o, [e.form]: (o[e.form] ?? 0) + 1 }), {}))
  .map(([f, n]) => n + ' ' + cap(f)).join(', ') || '0';
const row = (label, s, t) => `| ${label} | ${s.runs_with_mastery}/10 | ${s.first_mastery_waves.join(', ') || '—'} | ${s.median_first ?? '—'} | ${s.ghosts_mastered.join(', ') || '—'} | ${t} | ${s.kerf_mastered ? 'yes' : 'no'} |`;
const table = ['| Seed | Dent | Kerf | Ohm | Tonnage | Death wave | Form entries | Tonnage bond at end |',
  '|---:|---:|---:|---:|---:|---:|---|---:|',
  ...n29.runs.map(r => `| ${r.seed} | ${forms.map(f => cell(r.mastery_at_rest[f])).join(' | ')} | ${r.death?.wave ?? r.wave_reached} | ${entries(r)} | ${r.bond_at_end.tonnage} |`)].join('\n');
const rests = n29.runs.map(r => `| ${r.seed} | ` + r.waves.map(w => w.bond.tonnage).join(', ') + ' |').join('\n');
const result = { schema: 'gtai.bond-measurement/3', profile: 'average', pick: 'greedy', controls: 'wheel', wave_limit: 15,
  tuning: { master_at: 30, master_at_by_form: { tonnage: 70 }, per_kill: 4, per_stun: 3, per_boss_cut: 5 },
  summary: { n27_free: s27, n28: { ...s28, tonnage_mastered: t28 }, n29: s29 }, arms: { n29 } };
writeFileSync(join(out, 'mastery.json'), JSON.stringify(result, null, 2) + '\n');
const md = `# Tonnage's bar 85 -> 70 (n29)

Ten seeds of the average test player (greedy picks, wheel controls, to wave 15 or death), \`mastery_free\` 1, the same measurement as n28. Only \`master_at_by_form.tonnage\` changed (85 -> **70**).

| Arm | Runs with a mastery | First-mastery waves | Median | Ghosts mastered | Tonnage mastered (seeds, wave) | Kerf mastered |
|---|---:|---|---:|---|---|---|
${row('n27 free (30, cut 3)', s27, 'ohm, tonnage: see n27')}
${row('n28 (Tonnage 85, cut 5)', s28, t28)}
${row('**n29 (Tonnage 70, cut 5)**', s29, s29.tonnage_mastered)}

## Arm n29 per seed

${table}

Tonnage's bond at the end of each wave (the last value is the death wave):

| Seed | Bond by wave |
|---:|---|
${rests}

EXPECTATION_PLACEHOLDER

Measurement: \`node tools/dev/run.mjs res://dev/ghost-forms/bond_measure.tscn --fixed-fps=60 --bot=average --pick=greedy --seed=<n> --waves=15 --mastery-free=1 --result=<abs path>\`, then \`node evidence/n29/bond/summarize.mjs <results> build/dev n29- n29\` and \`report.mjs\`. [Per-seed data](mastery.json)
`;
writeFileSync(join(out, 'mastery.md'), md);
