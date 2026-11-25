# n31 ghost 08: Ohm, Dent and Kerf deploys measured on main (`ba8e470b0`)

Builder `g08-measure`, 2026-11-25. Run in a temp worktree at `ba8e470b0` (`gtai-wt/g08-main`, removed after) with
`project/dev/ghost_n31` and `tools/ghost/deploy_measure.mjs` copied in; `--import` there; one Godot per run.
The tool gained `--form=tonnage|ohm|dent|kerf` (default tonnage, Tonnage output unchanged). The strike is the
shipped `GhostDeployStrike` (nothing replaced): `GhostN31Strike` counts per deploy the foes hit (every `_hit`),
kills (`release_kills`), `near` = live foes within 9 m of the spot at the release tick, and key-down to damage
ticks. Share = hits / near (play) or hits / cluster size (lab). JSON: `evidence/n31/ghost/measure-ba8e470b0-<mode>-main-<form>.json`
(full copies in `build/n31/ghost/`).

## Headline
- **Dent: 53 deploys over 10 seeds x 3 waves hit 1.81 foes (median 2) of 5.13 near, 35 %; 6 deploys (11 %) hit nobody.**
- **Ohm: lab, one deploy hits 3 of 4 (75 %), 3.6 of 7.7 near in an 8 cluster (45 %), 4.8 of 11.5 in a 12 cluster (40 %); each hit foe dies (bolt 2 kills a cop).**
  A r3.5 circle at 9 m range is too small for a cluster: the share falls as the group grows.
- **Ohm and Kerf: the shipped `GhostDeployBot` made ZERO deploys in 10 seeds x 3 waves (and Ohm none in 10 seeds up to wave 5).**
  Not a tool fault (Dent deploys with the same grant). The bot's fit rules (`ghost_deploy_bot_spot.gd`) fire Ohm only at
  2+ machines (`robot`) or a sentry turret, Kerf only at tier 3+, `shield_robot` or `war_machine` targets, and early gauntlet
  waves bring none within range. So play numbers for those two cannot come from the bot as shipped; a bot-driven
  Ohm/Kerf play measure needs either later waves or a relaxed fit in a dev-only `GhostDeployBotSpot` subclass (not done).
- Key-down to damage is 1 tick for Dent and Ohm (an instant strike on the release input; Ohm's lab row confirms 1).

## Ohm lab (per-size 15, 4/8/12 gauntlet cluster shapes, Ohm at the bot's best spot, full circle r3.5)
| mode | variant | group | deploys | mean hits | median hits | mean kills | mean near | share hit | zero-hit | key-down->damage ticks (median) |
|---|---|---|---|---|---|---|---|---|---|---|
| lab | ohm full r3.5 at spot (main) | 4 cops | 15 | 3 | 3 | 3 | 4 | 75% | 0 | 1 |
| lab | ohm full r3.5 at spot (main) | 8 cops | 15 | 3.60 | 3 | 3.60 | 7.67 | 45% | 0 | 1 |
| lab | ohm full r3.5 at spot (main) | 12 cops | 13 | 4.77 | 4 | 4.77 | 11.54 | 40% | 0 | 1 |

Note: the lab cursor choice scores a body radius on top of 3.5 m (dev `GhostN31Geometry` full circle); the real strike
uses centre distance only. The strike itself is the real one, so hits are real.

## Ohm play (10 seeds x 3 waves, profile average): per-seed rows in the JSON, total here
| mode | variant | group | deploys | mean hits | median hits | mean kills | share hit | zero-hit | key-down->damage ticks (median) |
|---|---|---|---|---|---|---|---|---|---|
| play | ohm full r3.5 at spot (main) | total | 0 | 0 | 0 | 0 | - | 0 | 0 |

Ohm play, 10 seeds x `--waves=8` (runs ended at wave 5):
| mode | variant | group | deploys | mean hits | median hits | mean kills | share hit | zero-hit | key-down->damage ticks (median) |
|---|---|---|---|---|---|---|---|---|---|
| play | ohm full r3.5 at spot (main) | total | 0 | 0 | 0 | 0 | - | 0 | 0 |

## Dent play (10 seeds x 3 waves)
| mode | variant | group | deploys | mean hits | median hits | mean kills | mean near | share hit | zero-hit | key-down->damage ticks (median) |
|---|---|---|---|---|---|---|---|---|---|---|
| play | dent full r0 at spot (main) | seed 1 | 6 | 1.67 | 2 | 1.67 | 4.67 | 36% | 1 | 1 |
| play | dent full r0 at spot (main) | seed 2 | 4 | 2 | 2 | 2 | 6 | 33% | 0 | 1 |
| play | dent full r0 at spot (main) | seed 3 | 6 | 2 | 2 | 2 | 4.83 | 41% | 0 | 1 |
| play | dent full r0 at spot (main) | seed 4 | 6 | 1.67 | 2 | 1.67 | 5.67 | 29% | 2 | 1 |
| play | dent full r0 at spot (main) | seed 5 | 6 | 2.17 | 2.50 | 2.17 | 4.50 | 48% | 1 | 1 |
| play | dent full r0 at spot (main) | seed 6 | 5 | 2 | 2 | 2 | 5.80 | 34% | 0 | 1 |
| play | dent full r0 at spot (main) | seed 7 | 5 | 1.60 | 2 | 1.60 | 7.20 | 22% | 1 | 1 |
| play | dent full r0 at spot (main) | seed 8 | 3 | 2 | 2 | 2 | 5 | 40% | 0 | 1 |
| play | dent full r0 at spot (main) | seed 9 | 4 | 1.75 | 2 | 1.75 | 5.75 | 30% | 0 | 1 |
| play | dent full r0 at spot (main) | seed 10 | 8 | 1.50 | 2 | 1.50 | 3.38 | 44% | 1 | 1 |
| play | dent full r0 at spot (main) | total | 53 | 1.81 | 2 | 1.81 | 5.13 | 35% | 6 | 1 |

## Kerf play (10 seeds x 3 waves)
| mode | variant | group | deploys | mean hits | median hits | mean kills | share hit | zero-hit | key-down->damage ticks (median) |
|---|---|---|---|---|---|---|---|---|---|
| play | kerf full r0 at spot (main) | total | 0 | 0 | 0 | 0 | - | 0 | 0 |

## Commands
```
export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/ghost GODOT_BIN=<gtai-spike>/tools/godot/Godot_v4.7.2-stable_win64_console.exe
R=/c/Users/kazda/kiro/gtai-wt/g08-main   # git worktree at ba8e470b0 + dev/ghost_n31 + tools/ghost copied
node tools/ghost/deploy_measure.mjs --mode=lab  --form=ohm --per-size=15           --root=$R --tag=main-ohm
node tools/ghost/deploy_measure.mjs --mode=play --form=ohm  --seeds=10 --waves=3   --root=$R --tag=main-ohm
node tools/ghost/deploy_measure.mjs --mode=play --form=ohm  --seeds=10 --waves=8   --root=$R --tag=main-ohm-w8
node tools/ghost/deploy_measure.mjs --mode=play --form=dent --seeds=10 --waves=3   --root=$R --tag=main-dent
node tools/ghost/deploy_measure.mjs --mode=play --form=kerf --seeds=10 --waves=3   --root=$R --tag=main-kerf
```
Not run: Kerf at 8 waves (Godot lock held by another builder), the Ohm what-if radii 4.5 / 5.5 (item 4; the bot never
deploys Ohm in play, so only the lab could take a radius; no time).
