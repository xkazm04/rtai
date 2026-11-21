# Gauntlet tune ledger

Plan bf8daa619f36d1fc0fe9c4142acb26be0dbdcc1d3d89cac303a4e7745a42ca1c. Matched 30 of 30 before and 30 after runs.

Positive improvement means the measured miss shrank. An empty apply SHA means this branch has no commit for that edit. A revert SHA records an executed undo.

| Knob | Before → after | Baseline | Measured miss | Confirmation before → after | Pairs | Improvement (CI95) | A/A floor (pairs) | Verdict | Apply / revert SHA |
|---|---:|---:|---|---:|---:|---:|---:|---|---|
| robot_thug.hp | 6 → 4.8 | 6 | average wave 26 median 58.53 s over 5 timed runs against 15 s, robot_thug present in 5/5 timed rosters | 49.03 → 51.28 s | 3 | -2.25 (-14.32 to 12.02) | not measured (2) | too few pairs | aa367f09b7d441c4fb071fd79f669f1b4d999778 / b4647eb7321487f24cb8c4c8b3a56756955f8193 |
| war_machine.hp | 60 → 48 | 60 | average wave 20 median 54.77 s over 16 timed runs against 15 s, war_machine present in 16/16 timed rosters | 59.61 → 39.92 s | 12 | 13.67 (4.75 to 19.08) | 40.95 (8) | noise | 57906043cf1187bf0539b378074fd19a195635b2 / 84cfd45518e7465d15b7fb577775f59ecce746e4 |
| robot_gunner.hp | 4 → 3.2 | 4 | average wave 23 median 51.8 s over 13 timed runs against 15 s, robot_gunner present in 13/13 timed rosters | 51.8 → 38.75 s | 9 | 10.9 (-7.52 to 16.7) | 37.18 (6) | noise | 4f60fce8ec793e9a7bbf2bb0abf118642d0b51c0 / fbabd10e612212ad26add23ece178536f8629d77 |
| sentry_turret.hp | 8 → 6.4 | 8 | average wave 19 median 39.22 s over 20 timed runs against 15 s, sentry_turret present in 19/20 timed rosters | 41.63 → 37.38 s | 15 | 0.33 (-2.1 to 9.83) | 27.03 (10) | noise | 7c9d3fd2c6ef2e3ea2c84b163c09e05cbc825556 / 18865f69f690eb8a2a8230eeeb9add13bed3a250 |
| shield_robot.hp | 10 → 8 | 10 | average wave 13 median 32.61 s over 26 timed runs against 15 s, shield_robot present in 20/26 timed rosters | 32.7 → 27.73 s | 25 | 3.67 (1.72 to 6.6) | 12.57 (13) | noise | e945e1e39249c5a199687709599150efc2f8dbb9 / 0ce71cf3f8c65048df18d7bdbe2ce090fa1baadb |

## A/A seed pairs

Within each eligible before-batch group, sort by seed and pair adjacent ranks. Read the two lists in matching order. The floor is the larger absolute CI95 endpoint for right minus left, with at least 6 pairs. Offer entries show take/decline seed pairs.

| Knob | Before group | Left seeds | Right seeds |
|---|---|---|---|
| robot_thug.hp | ["average","wheel","greedy"] | 10, 27 | 24, 28 |
| war_machine.hp | ["average","wheel","greedy"] | 1, 6, 8, 10, 15, 22, 26, 28 | 5, 7, 9, 12, 17, 24, 27, 29 |
| robot_gunner.hp | ["average","wheel","greedy"] | 5, 8, 10, 15, 24, 27 | 7, 9, 12, 17, 26, 28 |
| sentry_turret.hp | ["average","wheel","greedy"] | 1, 5, 7, 9, 12, 15, 18, 23, 26, 28 | 3, 6, 8, 10, 14, 17, 22, 24, 27, 29 |
| shield_robot.hp | ["average","wheel","greedy"] | 1, 4, 6, 8, 10, 12, 14, 16, 18, 22, 24, 26, 28 | 3, 5, 7, 9, 11, 13, 15, 17, 19, 23, 25, 27, 29 |
