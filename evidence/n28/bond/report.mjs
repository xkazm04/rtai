// node evidence/n28/bond/report.mjs <n28 arm json> <probe arm json> <n27 mastery.json> <out dir>
// n28 = shipped values; probe = master_at_by_form.tonnage 999 (Tonnage never masters).
// Writes mastery.json and mastery.md: the n27 free row beside the n28 row.
import { readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const [n28File, probeFile, n27File, out] = process.argv.slice(2);
const read = f => JSON.parse(readFileSync(f, 'utf8'));
const n28 = read(n28File), probe = read(probeFile), n27 = read(n27File);
const bar = Number(process.env.TONNAGE_BAR ?? 0);
const forms = ['dent', 'kerf', 'ohm', 'tonnage'];
const cap = s => s[0].toUpperCase() + s.slice(1);
const median = v => { const a = [...v].sort((x, y) => x - y); return a.length ? (a[Math.floor(a.length / 2)] + a[Math.floor((a.length - 1) / 2)]) / 2 : null; };
const summary = arm => {
  const firsts = arm.runs.map(r => r.first_mastery).filter(Number.isFinite).sort((a, b) => a - b);
  const ghosts = new Set(arm.runs.flatMap(r => forms.filter(f => r.mastery_at_rest[f] !== null)));
  return { runs_with_mastery: firsts.length, first_mastery_waves: firsts, median_first: median(firsts),
    in_band_8_15: firsts.filter(w => w >= 8 && w <= 15).length, ghosts_mastered: [...ghosts].sort(),
    kerf_mastered: arm.runs.some(r => r.mastery_at_rest.kerf !== null),
    kerf_bond_at_end: arm.runs.map(r => r.bond_at_end.kerf), kerf_boss_cuts: arm.runs.map(r => r.boss_cuts?.kerf ?? 0) };
};
// Rest i is the end of wave i (the rest after it); the bond is the value in that wave's record, so the
// last entry is the wave the run died in (its bond at death).
const tonnageByRest = arm => arm.runs.map(r => ({ seed: r.seed,
  rests: r.waves.map((w, i) => ({ rest: i + 1, wave: w.wave, tonnage: w.bond.tonnage })) }));
const s28 = summary(n28), s27 = n27.summary.free, sp = summary(probe);
const probeRests = tonnageByRest(probe);
const result = { schema: 'gtai.bond-measurement/3', profile: 'average', pick: 'greedy', controls: 'wheel', wave_limit: 15,
  tuning: { master_at: 30, master_at_by_form: { tonnage: bar }, per_kill: 4, per_stun: 3, per_boss_cut: 5 },
  summary: { n27_free: s27, n28: s28, probe: sp }, probe_tonnage_bond_by_rest: probeRests, arms: { n28, probe } };
writeFileSync(join(out, 'mastery.json'), JSON.stringify(result, null, 2) + '\n');

const cell = v => v === null ? '—' : v;
const entries = r => Object.entries((r.entries ?? []).reduce((o, e) => ({ ...o, [e.form]: (o[e.form] ?? 0) + 1 }), {}))
  .map(([f, n]) => n + ' ' + cap(f)).join(', ') || '0';
const table = arm => ['| Seed | Dent | Kerf | Ohm | Tonnage | Death wave | Form entries | Kerf bond at end | Kerf boss cuts |',
  '|---:|---:|---:|---:|---:|---:|---|---:|---:|',
  ...arm.runs.map(r => `| ${r.seed} | ${forms.map(f => cell(r.mastery_at_rest[f])).join(' | ')} | ${r.death?.wave ?? r.wave_reached} | ${entries(r)} | ${r.bond_at_end.kerf} | ${r.boss_cuts?.kerf ?? 0} |`)].join('\n');
const row = (label, s) => `| ${label} | ${s.runs_with_mastery}/10 | ${s.first_mastery_waves.join(', ') || '—'} | ${s.median_first ?? '—'} | ${s.in_band_8_15}/10 | ${s.ghosts_mastered.join(', ') || '—'} | ${s.kerf_mastered ? 'yes' : 'no'} |`;
const maxRest = n => Math.max(...probeRests.map(p => p.rests.length), n);
const header = '| Seed | ' + Array.from({ length: maxRest(0) }, (_, i) => 'Rest ' + (i + 1)).join(' | ') + ' |';
const probeTable = [header, '|---:|' + '---:|'.repeat(maxRest(0)),
  ...probeRests.map(p => `| ${p.seed} | ` + Array.from({ length: maxRest(0) }, (_, i) => p.rests[i]?.tonnage ?? '—').join(' | ') + ' |')].join('\n');
const md = `# Tonnage's own bar, Kerf's cut at 5 (n28)

Ten seeds of the average test player (greedy picks, wheel controls, to wave 15 or death), \`mastery_free\` 1, the same measurement as n27. The general bar stays \`master_at\` 30 (Dent, Kerf, Ohm); \`master_at_by_form.tonnage\` is **${bar}**; \`per_boss_cut\` 3 -> 5.

| Arm | Runs with a mastery | First-mastery waves | Median | Inside wave 8..15 | Ghosts mastered | Kerf mastered |
|---|---:|---|---:|---:|---|---|
${row('n27 free (30, cut 3)', s27)}
${row('n28 (Tonnage ' + bar + ', cut 5)', s28)}

Kerf's bond at the end, seeds 1 to 10: n27 ${s27.kerf_bond_at_end.join(', ')}; n28 ${s28.kerf_bond_at_end.join(', ')}. Boss cuts landed: n27 ${s27.kerf_boss_cuts.join(', ')}; n28 ${s28.kerf_boss_cuts.join(', ')}.

## Arm n28 (shipped)

${table(n28)}

## Probe arm: Tonnage's unperturbed bond at each rest (bar 999, cut 5)

${probeTable}

Rest i is the end of wave i; the last column of a seed is the wave the run died in. A dash means the run was already dead.

Expectation check: Tonnage's bond did reach 85 in the n28 arm on seeds 1 (wave 8, 80 -> 85) and 8 (wave 9, 60 -> 85), but both runs died (wave 9 and wave 10) before the rest that would offer the mastery card, so neither run took a Tonnage mastery. The brief expected masteries at wave 8 and 9; the bond expectation held, the card expectation did not (the offer needs the rest after the capping wave). The two masteries in the n28 arm are Kerf (seed 5, wave 10) and Ohm (seeds 5 and 8, wave 8). This table chose the value: the smallest multiple of 5 above Tonnage's bond at every rest 1..7 on all ten seeds.

Measurement: \`node tools/dev/run.mjs res://dev/ghost-forms/bond_measure.tscn --fixed-fps=60 --bot=average --pick=greedy --seed=<n> --waves=15 --mastery-free=1 --result=<abs path>\`, then \`node evidence/n28/bond/summarize.mjs <results> build/dev <prefix> <arm>\` per arm and this script. [Per-seed data](mastery.json)
`;
writeFileSync(join(out, 'mastery.md'), md);
