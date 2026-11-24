// node evidence/n27/bond/report.mjs <pace arm json> <free arm json> <out dir>
// Joins the two arm summaries (summarize.mjs) into mastery.json and mastery.md.
import { readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const [paceFile, freeFile, out] = process.argv.slice(2);
const arms = { pace: JSON.parse(readFileSync(paceFile, 'utf8')), free: JSON.parse(readFileSync(freeFile, 'utf8')) };
const forms = ['dent', 'kerf', 'ohm', 'tonnage'];
const cap = s => s[0].toUpperCase() + s.slice(1);
const median = v => { const a = [...v].sort((x, y) => x - y); return a.length ? (a[Math.floor(a.length / 2)] + a[Math.floor((a.length - 1) / 2)]) / 2 : null; };
const firstWaves = arm => arm.runs.map(r => r.first_mastery).filter(Number.isFinite).sort((a, b) => a - b);
const summary = arm => {
  const firsts = firstWaves(arm);
  const ghosts = new Set(arm.runs.flatMap(r => forms.filter(f => r.mastery_at_rest[f] !== null)));
  const kerf = arm.runs.map(r => r.bond_at_end.kerf);
  return { runs_with_mastery: firsts.length, first_mastery_waves: firsts, median_first: median(firsts),
    in_band_8_15: firsts.filter(w => w >= 8 && w <= 15).length,
    masteries_taken: arm.runs.reduce((n, r) => n + forms.filter(f => r.mastery_at_rest[f] !== null).length, 0),
    ghosts_mastered: [...ghosts].sort(), kerf_mastered: arm.runs.some(r => r.mastery_at_rest.kerf !== null),
    kerf_bond_at_end: kerf, kerf_boss_cuts: arm.runs.map(r => r.boss_cuts?.kerf ?? 0),
    median_death_wave: median(arm.runs.map(r => r.death?.wave ?? r.wave_reached)) };
};
const n26 = { master_at: 25, runs_with_mastery: 6, first_mastery_waves: [2, 4, 4, 8, 8, 8], median_first: 6, in_band_8_15: 3, kerf_mastered: false };
const result = { schema: 'gtai.bond-measurement/2', profile: 'average', pick: 'greedy', controls: 'wheel', wave_limit: 15,
  tuning: { master_at: 30, per_kill: 4, per_stun: 3, per_boss_cut: 3 }, n26, summary: { pace: summary(arms.pace), free: summary(arms.free) }, arms };
writeFileSync(join(out, 'mastery.json'), JSON.stringify(result, null, 2) + '\n');

const cell = v => v === null ? '—' : v;
const entries = r => Object.entries(r.entries.reduce((o, e) => ({ ...o, [e.form]: (o[e.form] ?? 0) + 1 }), {}))
  .map(([f, n]) => n + ' ' + cap(f)).join(', ') || '0';
const table = arm => ['| Seed | Dent | Kerf | Ohm | Tonnage | Death wave | Form entries | Longest wave (s) | Kerf bond at end | Kerf boss cuts |',
  '|---:|---:|---:|---:|---:|---:|---|---:|---:|---:|',
  ...arm.runs.map(r => `| ${r.seed} | ${forms.map(f => cell(r.mastery_at_rest[f])).join(' | ')} | ${r.death?.wave ?? r.wave_reached} | ${entries(r)} | ${r.longest_wave_s} | ${r.bond_at_end.kerf} | ${r.boss_cuts?.kerf ?? 0} |`)].join('\n');
const row = (label, s) => `| ${label} | ${s.runs_with_mastery}/10 | ${s.first_mastery_waves.join(', ') || '—'} | ${s.median_first ?? '—'} | ${s.in_band_8_15}/10 | ${s.kerf_mastered ? 'yes' : 'no'} |`;
const md = `# Ghost mastery at 30, boss cuts and free mastery (n27)

Bond is now **master_at 30, 4 per deploy kill, 3 per stun and 3 per Kerf cut that hurt a boss without killing it**. Ten seeds of the average test player (greedy picks, wheel controls, to wave 15 or death) ran twice on the same build: arm \`pace\` with \`mastery_free\` 0 (a mastery card is the rest's pick, as last night) and arm \`free\` with it 1 (the shipped value). Nothing was tuned.

| Arm | Runs with a mastery | First-mastery waves | Median | Inside wave 8..15 | Kerf mastered |
|---|---:|---|---:|---:|---|
${row('n26 (master_at 25, no boss cuts)', n26)}
${row('n27 pace (30 + boss cuts)', result.summary.pace)}
${row('n27 free (30 + boss cuts + free mastery)', result.summary.free)}

Ghosts mastered: pace ${result.summary.pace.ghosts_mastered.join(', ')}; free ${result.summary.free.ghosts_mastered.join(', ')}. Kerf is **${result.summary.free.kerf_mastered || result.summary.pace.kerf_mastered ? 'mastered' : 'still never mastered'}** in either arm. His bond at death, seeds 1 to 10: free ${result.summary.free.kerf_bond_at_end.join(', ')}; pace ${result.summary.pace.kerf_bond_at_end.join(', ')}. Boss cuts landed (free): ${result.summary.free.kerf_boss_cuts.join(', ')}.

## Arm free (shipped)

${table(arms.free)}

## Arm pace (mastery_free 0)

${table(arms.pace)}

Wave numbers are the rest where the mastery card was taken; a dash means the ghost went unmastered through death. The n26 row is quoted from last night's report. In the free arm a taken mastery is its own \`picks\` entry (taken \`master_*\`) beside the rest's one normal pick, because the run-result schema allows no extra field.

## Reading

The band is badly missed. Three of the four masteries in each arm are Tonnage at waves 3, 3 and 4 (the pace arm swaps seed 8's wave 4 for an Ohm at 7); only seed 5's Ohm lands at wave 8. Five of ten runs are dead by wave 5 to 7 in the free arm, before any rest in the band. Free mastery changed the runs it touched (seed 1 lived to wave 9 instead of 5, seed 5 to 12 instead of 10) but not the mastery waves. Kerf reached 28/30 on seed 5, and Ohm 29/30 on seed 7, one stun short.

Measurement: \`node tools/dev/run.mjs res://dev/ghost-forms/bond_measure.tscn --fixed-fps=60 --bot=average --pick=greedy --seed=<n> --waves=15 --mastery-free=<0|1> --result=<abs path>\`, then \`node evidence/n27/bond/summarize.mjs <results> build/dev <arm>- <arm>\` per arm and \`node evidence/n27/bond/report.mjs\`. [Per-seed data](mastery.json)

Single value that would move it (estimate from the free arm's per-rest bond curves, not re-run): \`bond.master_at\` 30 to 22 puts three first masteries at waves 8, 8 and 9 (30 gives one, 25 gives two), still beside three at waves 2 to 4; play changes after the first card, so it is a bound, not a promise.
`;
writeFileSync(join(out, 'mastery.md'), md);
