# Time to kill, every playable weapon (range model, 24 trials a cell, 2026-11-04 03:5x, tree b97fc382)

Median seconds to kill (kill rate) at 5 / 10 / 20 / 35 m. `-` = no kill in range/time. The range model
(ProjectileSim, `dev/gunplay/ttk_bench.gd`) flies rounds straight: the homing shard's curve and the fan
live in the real fight (FightReach.home) only, so its strafe row understates it. Raw: `evidence/n5/ttk.json`.

## human_still

| weapon | 5 m | 10 m | 20 m | 35 m |
|---|---|---|---|---|
| pistol | 0.08 (100%) | 0.17 (100%) | 0.33 (100%) | 0.85 (100%) |
| machine_pistol | 0.15 (100%) | 0.32 (100%) | 0.70 (100%) | - |
| rocket_launcher | 0.25 (100%) | 0.52 (100%) | 1.08 (100%) | 1.92 (100%) |
| flamethrower | 1.42 (100%) | - | - | - |
| electro_gun | 0.62 (100%) | 0.73 (100%) | 1.00 (100%) | - |
| molotov | 1.17 (100%) | 1.53 (100%) | 2.98 (100%) | - |
| gloria | 0.10 (100%) | 0.22 (100%) | 0.43 (100%) | - |
| hand_cannon | 0.07 (100%) | 0.13 (100%) | 0.28 (100%) | 0.50 (100%) |
| plasma_rifle | 0.15 (100%) | 0.32 (100%) | 0.65 (100%) | 1.32 (100%) |
| ray_gun | 0.05 (100%) | 0.12 (100%) | 0.22 (100%) | - |
| homing_shard | 0.28 (100%) | 0.72 (100%) | 1.88 (100%) | - |
| mini_nuke | 0.38 (100%) | 0.80 (100%) | 1.63 (100%) | 2.88 (100%) |

## human_strafe

| weapon | 5 m | 10 m | 20 m | 35 m |
|---|---|---|---|---|
| pistol | 0.08 (100%) | 1.52 (100%) | 1.67 (100%) | 3.25 (96%) |
| machine_pistol | 0.22 (100%) | 0.65 (100%) | 1.37 (100%) | - |
| rocket_launcher | 0.27 (100%) | 0.53 (100%) | 4.70 (100%) | 3.75 (100%) |
| flamethrower | 2.47 (100%) | - | - | - |
| electro_gun | 1.65 (100%) | - | - | - |
| molotov | 1.98 (100%) | 3.20 (100%) | 4.70 (100%) | - |
| gloria | 0.10 (100%) | 4.63 (100%) | 3.23 (100%) | - |
| hand_cannon | 0.07 (100%) | 6.12 (100%) | - | 4.67 (29%) |
| plasma_rifle | 1.55 (96%) | 1.68 (100%) | 1.83 (96%) | 2.17 (100%) |
| ray_gun | 0.05 (100%) | 1.32 (100%) | 1.63 (100%) | - |
| homing_shard | 1.70 (100%) | 1.85 (100%) | 2.17 (100%) | - |
| mini_nuke | 0.38 (100%) | 0.80 (100%) | 1.63 (100%) | 2.88 (100%) |
