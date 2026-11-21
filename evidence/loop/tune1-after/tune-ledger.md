# Gauntlet tune ledger

Plan 8732036a7ad64ab9c4ff2fe529c151bc032c1c1cc6e5cc3e31df5e34404a0783. Matched 8 of 9 before and 8 after runs.

Positive improvement means the measured miss shrank. An empty apply SHA means this branch has no commit for that edit. A revert SHA records an executed undo.

| Knob | Before → after | Baseline | Measured miss | Confirmation before → after | Pairs | Improvement (CI95) | A/A floor (pairs) | Verdict | Apply / revert SHA |
|---|---:|---:|---|---:|---:|---:|---:|---|---|
| robot_gunner.hp | 4 → 3.2 | 4 | average wave 23 median 62.43 s over 4 timed runs against 15 s, robot_gunner present in 4/4 timed rosters | 62.43 → 47.78 s | 2 | 14.66 (12.62 to 16.7) | 46.8 (2) | noise | c8fb30f8531964803f58f9502fc6c16ce8175f1c / 9c019401e4d47de007b75e03a31f9b6963183dfc |
| shield_robot.hp | 10 → 8 | 10 | average wave 20 median 62.32 s over 6 timed runs against 15 s, shield_robot present in 6/6 timed rosters | 79.07 → 38.55 s | 3 | 20.58 (19.08 to 49.75) | 42.57 (3) | noise | 9f908b18f0d95b8e2805cf3899edc7ff6b69ec5a / 1dc8f016141ecbb7faa5d0897f3afd40104f8893 |
| war_machine.hp | 60 → 48 | 60 | average wave 10 median 47.81 s over 8 timed runs against 15 s, war_machine present in 8/8 timed rosters | 53.6 → 29.55 s | 7 | 16.37 (5.9 to 25.43) | 43.03 (4) | noise | 114775bfa95dcf0dcb4cddf7c7b5806d52e97b3e / 7e2bf625c264ef3070476efa80463a6fe56acc43 |
| robot_thug.hp | 6 → 4.8 | 6 | average wave 13 median 43.71 s over 8 timed runs against 15 s, robot_thug present in 7/8 timed rosters | 49.99 → 43.23 s | 6 | 3.27 (0.68 to 12.17) | 19.13 (4) | noise | 5dfbcd18f86b93a361ec964369611b2361130487 / 609ba37d3352f3b19defe20974e5985aeb53c01f |
| sentry_turret.hp | 8 → 6.4 | 8 | average wave 19 median 39.28 s over 7 timed runs against 15 s, sentry_turret present in 7/7 timed rosters | 47.83 → 42.45 s | 4 | 0.18 (-15.33 to 38.88) | 29.88 (3) | noise | cc5f44ffc28415095a6f8029799b696a5b9a93a8 / 33ad79efba86c19e5f45c4740bc0d5965b6cd8cf |
