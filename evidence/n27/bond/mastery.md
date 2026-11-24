# Ghost mastery at 30, boss cuts and free mastery (n27)

Bond is now **master_at 30, 4 per deploy kill, 3 per stun and 3 per Kerf cut that hurt a boss without killing it**. Ten seeds of the average test player (greedy picks, wheel controls, to wave 15 or death) ran twice on the same build: arm `pace` with `mastery_free` 0 (a mastery card is the rest's pick, as last night) and arm `free` with it 1 (the shipped value). Nothing was tuned.

| Arm | Runs with a mastery | First-mastery waves | Median | Inside wave 8..15 | Kerf mastered |
|---|---:|---|---:|---:|---|
| n26 (master_at 25, no boss cuts) | 6/10 | 2, 4, 4, 8, 8, 8 | 6 | 3/10 | no |
| n27 pace (30 + boss cuts) | 4/10 | 3, 3, 4, 8 | 3.5 | 1/10 | no |
| n27 free (30 + boss cuts + free mastery) | 4/10 | 3, 3, 4, 8 | 3.5 | 1/10 | no |

Ghosts mastered: pace ohm, tonnage; free ohm, tonnage. Kerf is **still never mastered** in either arm. His bond at death, seeds 1 to 10: free 0, 0, 0, 0, 28, 0, 14, 0, 0, 6; pace 0, 0, 0, 0, 21, 0, 14, 0, 0, 6. Boss cuts landed (free): 0, 0, 0, 0, 4, 0, 2, 0, 0, 2.

## Arm free (shipped)

| Seed | Dent | Kerf | Ohm | Tonnage | Death wave | Form entries | Longest wave (s) | Kerf bond at end | Kerf boss cuts |
|---:|---:|---:|---:|---:|---:|---|---:|---:|---:|
| 1 | — | — | — | 3 | 9 | 4 Tonnage | 28.85 | 0 | 0 |
| 2 | — | — | — | 3 | 5 | 2 Tonnage | 23.1 | 0 | 0 |
| 3 | — | — | — | — | 10 | 0 | 25.17 | 0 | 0 |
| 4 | — | — | — | — | 5 | 0 | 18.4 | 0 | 0 |
| 5 | — | — | 8 | — | 12 | 4 Ohm | 21.95 | 28 | 4 |
| 6 | — | — | — | — | 7 | 0 | 25.05 | 0 | 0 |
| 7 | — | — | — | — | 9 | 0 | 37.1 | 14 | 2 |
| 8 | — | — | — | 4 | 10 | 5 Tonnage | 27.6 | 0 | 0 |
| 9 | — | — | — | — | 5 | 0 | 21.1 | 0 | 0 |
| 10 | — | — | — | — | 5 | 0 | 25.37 | 6 | 2 |

## Arm pace (mastery_free 0)

| Seed | Dent | Kerf | Ohm | Tonnage | Death wave | Form entries | Longest wave (s) | Kerf bond at end | Kerf boss cuts |
|---:|---:|---:|---:|---:|---:|---|---:|---:|---:|
| 1 | — | — | — | 3 | 5 | 2 Tonnage | 25.87 | 0 | 0 |
| 2 | — | — | — | 3 | 5 | 2 Tonnage | 23.1 | 0 | 0 |
| 3 | — | — | — | — | 10 | 0 | 25.17 | 0 | 0 |
| 4 | — | — | — | — | 5 | 0 | 18.4 | 0 | 0 |
| 5 | — | — | 8 | — | 10 | 2 Ohm | 21.95 | 21 | 3 |
| 6 | — | — | — | — | 7 | 0 | 25.05 | 0 | 0 |
| 7 | — | — | — | — | 9 | 0 | 37.1 | 14 | 2 |
| 8 | — | — | 7 | 4 | 10 | 5 Tonnage, 2 Ohm | 32.87 | 0 | 0 |
| 9 | — | — | — | — | 5 | 0 | 21.1 | 0 | 0 |
| 10 | — | — | — | — | 5 | 0 | 25.37 | 6 | 2 |

Wave numbers are the rest where the mastery card was taken; a dash means the ghost went unmastered through death. The n26 row is quoted from last night's report. In the free arm a taken mastery is its own `picks` entry (taken `master_*`) beside the rest's one normal pick, because the run-result schema allows no extra field.

## Reading

The band is badly missed. Three of the four masteries in each arm are Tonnage at waves 3, 3 and 4 (the pace arm swaps seed 8's wave 4 for an Ohm at 7); only seed 5's Ohm lands at wave 8. Five of ten runs are dead by wave 5 to 7 in the free arm, before any rest in the band. Free mastery changed the runs it touched (seed 1 lived to wave 9 instead of 5, seed 5 to 12 instead of 10) but not the mastery waves. Kerf reached 28/30 on seed 5, and Ohm 29/30 on seed 7, one stun short.

Measurement: `node tools/dev/run.mjs res://dev/ghost-forms/bond_measure.tscn --fixed-fps=60 --bot=average --pick=greedy --seed=<n> --waves=15 --mastery-free=<0|1> --result=<abs path>`, then `node evidence/n27/bond/summarize.mjs <results> build/dev <arm>- <arm>` per arm and `node evidence/n27/bond/report.mjs`. [Per-seed data](mastery.json)

Single value that would move it (estimate from the free arm's per-rest bond curves, not re-run): `bond.master_at` 30 to 22 puts three first masteries at waves 8, 8 and 9 (30 gives one, 25 gives two), still beside three at waves 2 to 4; play changes after the first card, so it is a bound, not a promise.
