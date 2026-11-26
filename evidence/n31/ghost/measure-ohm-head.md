# n31 ghost 10: Ohm drop, lab radius sweep (charge 18 ticks)

Builder `g10-ohm`, 2026-11-26 00:15-00:17, tree `48d6fbc37` (Ohm drop mode in code, shipped row still `hold`).
`node tools/ghost/deploy_measure.mjs --mode=lab --form=ohm --tag=g10-ohm-drop-r<R>` once per radius, with the
working-tree `ghost_attacks.json` Ohm row set to `press_mode` drop, `life_ticks` 66, `radius_m` R for that run
(restored to HEAD after each run, inside the lane Godot lock; `build/n31/g10_sweep.sh`). Why not `--radius`: for
`--form=ohm` the tool's `--radius` only moves the cursor search (`GhostN31Lab.best`); the real `GhostDeployStrike._ohm`
reads the row's `radius_m`, so the row itself has to carry the radius. `--charge` is play-only; the lab used the row's
`charge_s` 0.3 = 18 ticks (key-down -> damage median 18 below confirms it). The strike is the real one: full circle on
the spot, victim body radius added (`TonnageDump.victims`), foes move during the charge. Per-size 15 gauntlet cluster
shapes of patrol cops. JSON: `evidence/n31/ghost/measure-48d6fbc37-lab-g10-ohm-drop-r<R>.json`.
The variant label says `(main)` because each run is the tool's "shipped" variant of the edited row.

## Headline
- **Smallest radius with 8-cop share hit >= 75 %: r 5.0 m (83 %, 6.6 of 7.7). Main (hold, r 3.5, centre distance): 45 %.**
- r 3.5 as a drop (victim radius added, 18-tick charge): 58 %; r 4.5: 69 %; r 5.5: 88 %; 12-cop crosses 75 % at r 5.5 (81 %).

## 8 cops (the gate)
| variant | share hit | mean hits | mean near | key-down->damage |
|---|---|---|---|---|
| main: hold r3.5, centre distance (`measure-others-main.md`) | 45% | 3.60 | 7.67 | 1 |
| drop r3.5 | 58% | 4.67 | 7.73 | 18 |
| drop r4.5 | 69% | 5.53 | 7.73 | 18 |
| **drop r5** | **83%** | **6.60** | **7.67** | 18 |
| drop r5.5 | 88% | 7.07 | 8 | 18 |
| drop r6 | 90% | 7.20 | 8 | 18 |
| drop r6.5 | 95% | 7.60 | 8 | 18 |
| drop r7 | 96% | 7.67 | 8 | 18 |

## All sizes (share hit; every hit foe died, kills = hits; zero-hit 0 everywhere)
| variant | 4 cops | 8 cops | 12 cops |
|---|---|---|---|
| main hold r3.5 | 75% | 45% | 40% |
| drop r3.5 | 87% | 58% | 51% |
| drop r4.5 | 95% | 69% | 63% |
| drop r5 | 92% | 83% | 74% |
| drop r5.5 | 98% | 88% | 81% |
| drop r6 | 92% | 90% | 91% |
| drop r6.5 | 97% | 95% | 94% |
| drop r7 | 98% | 96% | 96% |

Note: 15 shapes per size, so a few points of noise (4-cop r5 92 % < r4.5 95 %). The drop gains over main come from
the body radius (+0.4 m for a patrol cop) and the cursor search scoring the same circle the strike uses.
