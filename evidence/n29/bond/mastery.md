# Tonnage's bar 85 -> 70 (n29)

Ten seeds of the average test player (greedy picks, wheel controls, to wave 15 or death), `mastery_free` 1, the same measurement as n28. Only `master_at_by_form.tonnage` changed (85 -> **70**).

| Arm | Runs with a mastery | First-mastery waves | Median | Ghosts mastered | Tonnage mastered (seeds, wave) | Kerf mastered |
|---|---:|---|---:|---|---|---|
| n27 free (30, cut 3) | 4/10 | 3, 3, 4, 8 | 3.5 | ohm, tonnage | ohm, tonnage: see n27 | no |
| n28 (Tonnage 85, cut 5) | 2/10 | 8, 8 | 8 | kerf, ohm | none | yes |
| **n29 (Tonnage 70, cut 5)** | 3/10 | 7, 8, 8 | 8 | kerf, ohm, tonnage | 1 (w7) | yes |

## Arm n29 per seed

| Seed | Dent | Kerf | Ohm | Tonnage | Death wave | Form entries | Tonnage bond at end |
|---:|---:|---:|---:|---:|---:|---|---:|
| 1 | — | — | — | 7 | 10 | 4 Tonnage | 70 |
| 2 | — | — | — | — | 5 | 0 | 64 |
| 3 | — | — | — | — | 10 | 0 | 36 |
| 4 | — | — | — | — | 5 | 0 | 0 |
| 5 | — | 10 | 8 | — | 13 | 3 Ohm, 3 Kerf | 0 |
| 6 | — | — | — | — | 7 | 0 | 20 |
| 7 | — | — | — | — | 9 | 0 | 0 |
| 8 | — | — | 8 | — | 10 | 4 Ohm | 70 |
| 9 | — | — | — | — | 5 | 0 | 8 |
| 10 | — | — | — | — | 5 | 0 | 0 |

Tonnage's bond at the end of each wave (the last value is the death wave):

| Seed | Bond by wave |
|---:|---|
| 1 | 0, 12, 32, 48, 52, 64, 70, 70, 70, 70 |
| 2 | 0, 24, 48, 60, 64 |
| 3 | 0, 0, 0, 0, 0, 0, 0, 12, 24, 36 |
| 4 | 0, 0, 0, 0, 0 |
| 5 | 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 |
| 6 | 0, 0, 0, 0, 0, 4, 20 |
| 7 | 0, 0, 0, 0, 0, 0, 0, 0, 0 |
| 8 | 0, 0, 12, 40, 44, 44, 52, 60, 70, 70 |
| 9 | 0, 0, 0, 0, 8 |
| 10 | 0, 0, 0, 0, 0 |

Expectation check: the probe curves predicted Tonnage masteries at wave 7-8 on seeds 1, 2 and 8. Seed 1 held exactly: Tonnage reached 70 in wave 7 (64 -> 70), the rest after it offered master_tonnage and the player took it (wave 7), the first Tonnage mastery in the n28/n29 arms (n27 had one at the old bar 30). Seed 2 did not: the run died in wave 5 with Tonnage at 64, 6 points short of 70 and before the wave 6 that would have filled it (the probe curve there is 64 at rest 5 and the run is dead after). Seed 8 did not: Tonnage reached 70 only in wave 9 (60 -> 70), and that wave was not cleared (the run died to a sentry turret, wave 10 in the death record), so no rest followed to offer the card; the bond was short of 70 at every earlier rest (44, 44, 52, 60). Net: 1 Tonnage mastery in 10 seeds (n28: 0), run count with any mastery 3/10 (n28 2/10); the other two runs with a mastery are the unchanged Kerf and Ohm ones (seeds 5 and 8). Tonnage bond is capped at the bar, so seeds 1 and 8 show 70 at the end. The bar is not the limit on seeds 2 and 8, survival to the next rest is.

Measurement: `node tools/dev/run.mjs res://dev/ghost-forms/bond_measure.tscn --fixed-fps=60 --bot=average --pick=greedy --seed=<n> --waves=15 --mastery-free=1 --result=<abs path>`, then `node evidence/n29/bond/summarize.mjs <results> build/dev n29- n29` and `report.mjs`. [Per-seed data](mastery.json)
