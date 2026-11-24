# Tonnage's own bar, Kerf's cut at 5 (n28)

Ten seeds of the average test player (greedy picks, wheel controls, to wave 15 or death), `mastery_free` 1, the same measurement as n27. The general bar stays `master_at` 30 (Dent, Kerf, Ohm); `master_at_by_form.tonnage` is **85**; `per_boss_cut` 3 -> 5.

| Arm | Runs with a mastery | First-mastery waves | Median | Inside wave 8..15 | Ghosts mastered | Kerf mastered |
|---|---:|---|---:|---:|---|---|
| n27 free (30, cut 3) | 4/10 | 3, 3, 4, 8 | 3.5 | 1/10 | ohm, tonnage | no |
| n28 (Tonnage 85, cut 5) | 2/10 | 8, 8 | 8 | 2/10 | kerf, ohm | yes |

Kerf's bond at the end, seeds 1 to 10: n27 0, 0, 0, 0, 28, 0, 14, 0, 0, 6; n28 0, 0, 0, 0, 30, 0, 18, 0, 0, 10. Boss cuts landed: n27 0, 0, 0, 0, 4, 0, 2, 0, 0, 2; n28 0, 0, 0, 0, 4, 0, 2, 0, 0, 2.

## Arm n28 (shipped)

| Seed | Dent | Kerf | Ohm | Tonnage | Death wave | Form entries | Kerf bond at end | Kerf boss cuts |
|---:|---:|---:|---:|---:|---:|---|---:|---:|
| 1 | — | — | — | — | 9 | 0 | 0 | 0 |
| 2 | — | — | — | — | 5 | 0 | 0 | 0 |
| 3 | — | — | — | — | 10 | 0 | 0 | 0 |
| 4 | — | — | — | — | 5 | 0 | 0 | 0 |
| 5 | — | 10 | 8 | — | 13 | 3 Ohm, 3 Kerf | 30 | 4 |
| 6 | — | — | — | — | 7 | 0 | 0 | 0 |
| 7 | — | — | — | — | 9 | 0 | 18 | 2 |
| 8 | — | — | 8 | — | 10 | 4 Ohm | 0 | 0 |
| 9 | — | — | — | — | 5 | 0 | 0 | 0 |
| 10 | — | — | — | — | 5 | 0 | 10 | 2 |

## Probe arm: Tonnage's unperturbed bond at each rest (bar 999, cut 5)

| Seed | Rest 1 | Rest 2 | Rest 3 | Rest 4 | Rest 5 | Rest 6 | Rest 7 | Rest 8 | Rest 9 | Rest 10 | Rest 11 | Rest 12 | Rest 13 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | 0 | 12 | 32 | 48 | 52 | 64 | 80 | 120 | 120 | — | — | — | — |
| 2 | 0 | 24 | 48 | 60 | 64 | — | — | — | — | — | — | — | — |
| 3 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 12 | 24 | 36 | — | — | — |
| 4 | 0 | 0 | 0 | 0 | 0 | — | — | — | — | — | — | — | — |
| 5 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 6 | 0 | 0 | 0 | 0 | 0 | 4 | 20 | — | — | — | — | — | — |
| 7 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | — | — | — | — |
| 8 | 0 | 0 | 12 | 40 | 44 | 44 | 52 | 60 | 104 | 104 | — | — | — |
| 9 | 0 | 0 | 0 | 0 | 8 | — | — | — | — | — | — | — | — |
| 10 | 0 | 0 | 0 | 0 | 0 | — | — | — | — | — | — | — | — |

Rest i is the end of wave i; the last column of a seed is the wave the run died in. A dash means the run was already dead.

Expectation check: Tonnage's bond did reach 85 in the n28 arm on seeds 1 (wave 8, 80 -> 85) and 8 (wave 9, 60 -> 85), but both runs died (wave 9 and wave 10) before the rest that would offer the mastery card, so neither run took a Tonnage mastery. The brief expected masteries at wave 8 and 9; the bond expectation held, the card expectation did not (the offer needs the rest after the capping wave). The two masteries in the n28 arm are Kerf (seed 5, wave 10) and Ohm (seeds 5 and 8, wave 8). This table chose the value: the smallest multiple of 5 above Tonnage's bond at every rest 1..7 on all ten seeds.

Measurement: `node tools/dev/run.mjs res://dev/ghost-forms/bond_measure.tscn --fixed-fps=60 --bot=average --pick=greedy --seed=<n> --waves=15 --mastery-free=1 --result=<abs path>`, then `node evidence/n28/bond/summarize.mjs <results> build/dev <prefix> <arm>` per arm and this script. [Per-seed data](mastery.json)
