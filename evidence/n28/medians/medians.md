# Median death waves (10 seeds, salts 0 and 1, greedy pick, wheel controls, 40 waves)

Arms are data toggles on the n28-combat HEAD (see `<arm>/tree.txt`): `main` = `ghost_forms.json` and `rivet_motion.json`
from `d0ab9d03a`; `keys` = main's `ghost_forms.json`, HEAD's `rivet_motion.json` (dash 24), salt 0 only; `combat` = HEAD, nothing toggled.
n27 columns are from `docs/day/2026-11-24/n27-pressure/REPORT.md` section 1. Cells are salt 0 / salt 1.

| profile | n27 main `a3b3f1466` | n27 after keys `e403c4a40` | n27 after melee `4a3ff4b04` | n28 main | n28 keys (s0 only) | n28 combat | floor main (n28) | floor combat (n28) | n27 floor (main / melee) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| novice | 5 / 5 | 5 / 5 | 5 / 5 | 5 / 5 | 5 / - | 5 / 5 | 0.3 | 0.3 | 0.3 / 0.3 |
| average | 6 / 5 | 6 / 5 | 8 / 5 | 8 / 5 | 8 / - | 8 / 5 | 3.6 | 4 | 2.6 / 3.6 |
| expert | 8.5 / 9 | 8.5 / 9 | 8.5 / 9 | 8.5 / 9 | 8.5 / - | 8.5 / 9 | 1.6 | 3.2 | 1.8 / 1.6 |

Floor = paired null-salt floor on "Death wave (including cap lower bounds)" (`main/floors.md`, `combat/floors.md`; both: main/combat
salt 0 vs salt 1). Keys has no floor (one salt).

## Per row

- novice: every arm 5 / 5, floor 0.3: no move.
- average: main 8 / 5 -> combat 8 / 5, keys 8: no move; the 8-vs-5 gap between salts is itself inside the average floor (3.6 main, 4 combat), so average is salt noise.
- expert: 8.5 / 9 in every arm; combat floor 3.2 vs main 1.6, nothing moved, so nothing to read.
- Keys dash 24 and the combat lane's `per_boss_cut`/`master_at_by_form` do not move any median beyond its floor. `compare_s0.md`
  (main vs combat, salt 0): medians identical (5 / 8 / 8.5); top killers differ only below the median (average: patrol_cop x1 on main, rocket x2 on combat; expert top killers sentry_turret x3 vs x4); wave 11-20 average seconds 20.1 vs 17.3.

## Cross-check: n28 main against n27 after-melee

n27 after melee: 5/5, 8/5, 8.5/9. n28 main (toggled d0ab9d03a data): 5/5, 8/5, 8.5/9, and the floors match n27's melee column
exactly (0.3, 3.6, 1.6). No difference outside the floor (no difference at all): the toggled main tree reproduces n27's after-melee tree
in gauntlet terms. Not reported from n27: whether per-run bytes are identical (not compared).

## Killers

See `killers.md`. Combat arm: stomp share of wave 5 deaths, novice 8 of 9 (89 %) salt 0, 16 of 17 (94 %) pooled; average 3 of 4 (75 %) salt 0, 9 of 10 (90 %) pooled.
Median HP taken in the wave 5 stomp wave: novice 81, average ~100.
