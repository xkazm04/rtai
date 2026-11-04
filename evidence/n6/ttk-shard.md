# Homing shard in the range model, before/after (24 trials a cell, 2026-11-04 04:40)

Before: `evidence/n5/ttk.json` (rounds flew straight). After: `evidence/n6/ttk.json` (ProjectileSim homes
like FightReach.home, with GunHand's 20 deg fan). Every other weapon's rows are identical between the two.
Median seconds to kill (kill rate) at 5 / 10 / 20 / 35 m.

| target | model | 5 m | 10 m | 20 m | 35 m |
|---|---|---|---|---|---|
| human_still | straight | 0.28 (100%) | 0.72 (100%) | 1.88 (100%) | - |
| human_still | homing | 0.28 (100%) | 0.58 (100%) | 1.27 (100%) | - |
| human_strafe | straight | 1.70 (100%) | 1.85 (100%) | 2.17 (100%) | - |
| human_strafe | homing | 0.28 (100%) | 0.60 (100%) | 1.25 (100%) | - |

A strafe no longer buys a human time against the shard gun: that is the weapon's design. 35 m stays out of
reach (the shards' range). Hit rates stay low (0.1-0.36) because the bench keeps firing for the whole trial
window; the kill rate and the median are the read.
