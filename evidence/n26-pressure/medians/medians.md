# Gauntlet death waves on the pressure lane

Salt 0 ran on bf32bfd1a and salt 1 on f23c6ea36. Only the journal changed between these commits. Both used greedy picks, wheel controls, seeds 1–10, a 40-wave limit and one Godot run at a time. The manifests record the existing evidence and briefs as dirty. The code matched the commit.

| Profile | Salt 0 median | Salt 1 median | Paired death-wave floor | n24 base-main | n24 final |
|---|---:|---:|---:|---:|---:|
| novice | 5 | 5 | 0.3 (10 pairs) | 13 | 5 |
| average | 7.5 | 5 | 3.1 (10 pairs) | 40 | 8 |
| expert | 8.5 | 9 | 1.5 (10 pairs) | 40 | 23 |

The paired floor estimates how much the death-wave measurement varies when only the bot salt changes. The n24 comparison used five seeds per profile. Nine of its 15 base-main runs were censored, so both medians of 40 were lower bounds. The n24 final arm had one censored expert run.

| Profile | Salt 0 killers | Salt 1 killers |
|---|---|---|
| novice | stomp 8, rocket 1, riot_cop 1 | stomp 7, patrol_cop 1, rocket 1, riot_cop 1 |
| average | stomp 5, swat 2, sentry_turret 2, contractor 1 | stomp 7, sentry_turret 1, robot_gunner 1, patrol_cop 1 |
| expert | rocket 3, war_cannon 2, sentry_turret 2, stomp 1, shield_robot 1, contractor 1 | shield_robot 4, sentry_turret 2, war_cannon 2, contractor 1, stomp 1 |

## Completion

- Salt 0 recorded 30 deaths in 30 runs, with zero tick caps and zero freeze reports.
- Salt 1 recorded 30 deaths in 30 runs, with zero tick caps and zero freeze reports.

| Former reproducer | Salt 0 ending (wave, tick) | Salt 1 ending (wave, tick) |
|---|---|---|
| average-9 | sentry_turret, 6, 6,748 | patrol_cop, 3, 3,463 |
| average-8 | contractor, 10, 16,259 | stomp, 5, 5,534 |
| expert-1 | rocket, 10, 17,246 | contractor, 9, 16,045 |
| expert-9 | shield_robot, 9, 18,431 | shield_robot, 10, 20,365 |

The salt 0 result bytes for all four former reproducers match the unmodified lane runs. The historical transformation-enabled replay changed from a cap at tick 216,000 to a wave-40 clear at tick 82,694. [Historical replay and cause](../stall/cause.md)

[Salt 0 report](salt0/report.md) · [Paired floors](floors.md) · [n24 pressure report](../../../docs/day/2026-11-23/n24-pressure/REPORT.md)
