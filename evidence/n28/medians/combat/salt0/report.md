# Gauntlet run report

30 of 30 runs accepted. Average-profile waves 5 (22.33 s), 6 (20.82 s), 8 (20.55 s), 9 (20.66 s), 10 (16.6 s) fell outside 12–18 s for ordinary waves and 25–30 s for boss waves.

Live gauntlet batch · n28-combat @ b9df9127b760 (dirty) · 2026-11-24T19:12:54.575Z.

Stalled runs by profile: novice 0, average 0, expert 0.

Capped alive by profile: novice 0, average 0, expert 0.

## Death-wave score

Censored runs contribute their last reached wave as a lower bound to the median and spread.

| Profile | Target | Median wave | P25–P75 | Min–max | Deaths / censored |
| --- | --- | --- | --- | --- | --- |
| novice | 6 | 5 | 5–5 | 3–5 | 10 / 0 |
| average | 12 | 8 | 5–10 | 5–13 | 10 / 0 |
| expert | 20 | 8.5 | 7–10 | 3–11 | 10 / 0 |

## Profile separation

Targets require a median gap of 3 waves and a later death on at least 75% of shared seeds with the same controls and pick policy. Unresolved censored pairs stay in the denominator.

| Profiles | Observed median gap | Later / shared seeds | Confirmed later share | Unresolved | Verdict |
| --- | --- | --- | --- | --- | --- |
| novice → average | 3 | 7 / 10 | 70% | 0 | below target |
| novice → expert | 3.5 | 8 / 10 | 80% | 0 | separated |
| average → expert | 0.5 | 4 / 10 | 40% | 0 | below target |

## Waves per run

A timed-out wave can clear later. Active counts include each started roster still fighting at death.

| Profile | Seed | Outcome | Timed-out waves | Active waves at death |
| --- | --- | --- | --- | --- |
| novice | 1 | died on 5 | 0 | 1 |
| novice | 2 | died on 5 | 0 | 1 |
| novice | 3 | died on 5 | 0 | 1 |
| novice | 4 | died on 5 | 0 | 1 |
| novice | 5 | died on 5 | 0 | 1 |
| novice | 6 | died on 5 | 0 | 1 |
| novice | 7 | died on 5 | 0 | 1 |
| novice | 8 | died on 5 | 0 | 1 |
| novice | 9 | died on 3 | 0 | 1 |
| novice | 10 | died on 5 | 0 | 1 |
| average | 1 | died on 9 | 1 | 2 |
| average | 2 | died on 5 | 0 | 1 |
| average | 3 | died on 10 | 0 | 1 |
| average | 4 | died on 5 | 0 | 1 |
| average | 5 | died on 13 | 0 | 1 |
| average | 6 | died on 7 | 0 | 1 |
| average | 7 | died on 9 | 0 | 1 |
| average | 8 | died on 10 | 1 | 2 |
| average | 9 | died on 5 | 0 | 1 |
| average | 10 | died on 5 | 0 | 1 |
| expert | 1 | died on 10 | 2 | 3 |
| expert | 2 | died on 5 | 0 | 1 |
| expert | 3 | died on 11 | 0 | 1 |
| expert | 4 | died on 8 | 2 | 3 |
| expert | 5 | died on 10 | 0 | 1 |
| expert | 6 | died on 7 | 0 | 1 |
| expert | 7 | died on 8 | 0 | 1 |
| expert | 8 | died on 10 | 1 | 2 |
| expert | 9 | died on 3 | 0 | 1 |
| expert | 10 | died on 9 | 0 | 1 |

## Wave time

Seconds per observed wave. The target is 15 s ±20% for ordinary average-profile waves. Every 5th wave targets 25–30 s. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Median s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 10 / 10 | 15.12 | 13.43…15.98 | 10.6…16.68 | — |
| novice | 2 | 10 / 10 | 14.98 | 12.18…16.88 | 11.57…17.68 | — |
| novice | 3 | 9 / 10 | 17.23 | 14.7…20.73 | 12.43…31.5 | — |
| novice | 4 | 9 / 9 | 15.15 | 12.08…16.8 | 8.22…28.22 | — |
| novice | 5 | 0 / 9 | not measured | not measured | not measured | — |
| average | 1 | 10 / 10 | 14.71 | 12.52…17 | 10.72…21.13 | within target |
| average | 2 | 10 / 10 | 15.01 | 13.12…18.4 | 8.95…21.1 | within target |
| average | 3 | 10 / 10 | 17.04 | 12.97…21.22 | 8.42…23.77 | within target |
| average | 4 | 10 / 10 | 14.32 | 11.73…19.55 | 8.83…25.37 | within target |
| average | 5 | 6 / 10 | 22.33 | 17.7…24.5 | 17.63…25.05 | miss |
| average | 6 | 6 / 6 | 20.82 | 18.67…23.65 | 16.12…25.17 | miss |
| average | 7 | 5 / 6 | 16.25 | 13.05…21.95 | 12.92…42.9 | within target |
| average | 8 | 4 / 5 | 20.55 | 18.9…37.1 | 15.37…37.1 | miss |
| average | 9 | 2 / 5 | 20.66 | 17.47…23.85 | 17.47…23.85 | miss |
| average | 10 | 1 / 3 | 16.6 | 16.6…16.6 | 16.6…16.6 | miss |
| average | 11 | 1 / 1 | 16.72 | 16.72…16.72 | 16.72…16.72 | within target |
| average | 12 | 1 / 1 | 17.88 | 17.88…17.88 | 17.88…17.88 | within target |
| average | 13 | 0 / 1 | not measured | not measured | not measured | not measured |
| expert | 1 | 10 / 10 | 16.31 | 13.4…18.35 | 13.02…22.67 | — |
| expert | 2 | 10 / 10 | 14.38 | 12.08…17.35 | 11.57…22.1 | — |
| expert | 3 | 9 / 10 | 19.7 | 18.92…21.78 | 6.93…36.67 | — |
| expert | 4 | 9 / 9 | 18.68 | 12.78…25.03 | 8.42…34.48 | — |
| expert | 5 | 8 / 9 | 30.95 | 25.88…38.88 | 12…54.4 | — |
| expert | 6 | 7 / 8 | 22 | 14.18…27.2 | 12.92…28.37 | — |
| expert | 7 | 6 / 8 | 18.19 | 16.97…19.52 | 10.23…39.4 | — |
| expert | 8 | 4 / 7 | 17.24 | 15.35…22.65 | 12.77…22.65 | — |
| expert | 9 | 2 / 5 | 24.08 | 22.8…25.35 | 22.8…25.35 | — |
| expert | 10 | 1 / 4 | 20.28 | 20.28…20.28 | 20.28…20.28 | — |
| expert | 11 | 0 / 1 | not measured | not measured | not measured | — |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 10 | 10 | 0 | 0 | 0 | 3 × 1, 5 × 9 | stomp × 8, riot_cop × 1, swat × 1 | 0 |
| average | 10 | 10 | 0 | 0 | 0 | 5 × 4, 7 × 1, 9 × 2, 10 × 2, 13 × 1 | stomp × 3, rocket × 2, shield_robot × 2, robot_thug × 1, sentry_turret × 1, swat × 1 | 0 |
| expert | 10 | 10 | 0 | 0 | 0 | 3 × 1, 5 × 1, 7 × 1, 8 × 2, 9 × 1, 10 × 3, 11 × 1 | sentry_turret × 4, riot_cop × 1, robot_gunner × 1, shield_robot × 1, stomp × 1, swat × 1, war_cannon × 1 | 0 |

## Timeouts

Runs that reached the wave time limit.

| Outcome | novice | average | expert |
| --- | --- | --- | --- |
| timeout | 0 | 0 | 0 |

## Survival by wave band

Each wave contributes once to each available median. Damage/s needs a timed wave. Repair/s is the configured rate when repair is active. HP coverage counts waves sampled by the bot. Repaired HP sums positive HP steps. The share undone uses waves with positive damage. Multipliers include stat cards taken before the wave.

| Profile | Waves | HP rows / observed | Damage | Damage/s | Repair/s | Minimum HP (% of capacity) | Repaired HP | Damage undone (%) | Guard deflects | Cover ticks | Rolls | damage × | guard_meter × | hp_max × | regen × | speed × |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1–10 | 48 / 48 | 19.54 | 1.15 | 10 | 67.12 | 0 | 0 | 7 | 0 | 2 | 1 | 1 | 1 | 1 | 1 |
| novice | 11–20 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| novice | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| novice | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 1–10 | 75 / 75 | 19.2 | 1.04 | 10 | 71.2 | 0 | 0 | 6 | 1 | 3 | 1.1 | 1 | 1 | 1 | 1 |
| average | 11–20 | 3 / 3 | 18 | 0.79 | 11 | 76.41 | 0 | 0 | 1 | 3 | 5 | 1.375 | 1.1 | 1.1 | 1.1 | 1.1 |
| average | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 1–10 | 80 / 80 | 19.18 | 0.89 | 10 | 80.05 | 0 | 0 | 7 | 20.5 | 4 | 1.1 | 1 | 1 | 1 | 1 |
| expert | 11–20 | 1 / 1 | 110 | not measured | 11 | 0 | 0 | 0 | 2 | 7 | 1 | 1.1 | 1.1 | 1.1 | 1.1 | 1 |
| expert | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 0 | — | 62.36% | 18.68 (98) | 15.71 (72) |
| patrol_cop | 0 | — | 87.76% | 16.8 (154) | 21.54 (16) |
| riot_cop | 2 | — | 55.15% | 18.44 (88) | 16.07 (82) |
| robot_gunner | 1 | — | 20.92% | 18.78 (32) | 16.64 (138) |
| robot_thug | 1 | — | 20.76% | 19.52 (31) | 16.38 (139) |
| rocket_trooper | 2 | rocket × 2 | 58.15% | 18.68 (93) | 15.93 (77) |
| sentry_turret | 5 | — | 19.14% | 19.25 (28) | 16.53 (142) |
| shield_robot | 3 | — | 2.79% | 22.07 (4) | 16.84 (166) |
| swat | 3 | — | 47.52% | 17.97 (80) | 16.52 (90) |
| war_machine | 13 | stomp × 12, war_cannon × 1 | 13.43% | 24.77 (16) | 16.7 (154) |

## Moves

Uses count recorded activations by profile and wave number. The game omits zero counts. Times are medians in seconds, with timed wave counts in parentheses. Carry applies to all waves.

| Profile | Wave | Move | Enemy | Recorded uses | Observed waves | Uses per wave | With enemy s (n) | Without enemy s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | All | ohm_short_circuit | sentry_turret | 0 | 48 | 0 | — | 15.13 (38) |
| novice | All | tonnage_armour_crack | war_machine | 2 | 48 | 0.04 | — | 15.13 (38) |
| novice | All | kerf_blink_behind | shield_robot | 0 | 48 | 0 | — | 15.13 (38) |
| novice | All | overkill_carry | all waves | 0 | 48 | 0 | 15.13 (38) | — |
| novice | 1 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 15.12 (10) |
| novice | 1 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 15.12 (10) |
| novice | 1 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 15.12 (10) |
| novice | 1 | overkill_carry | all waves | 0 | 10 | 0 | 15.12 (10) | — |
| novice | 2 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 14.98 (10) |
| novice | 2 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 14.98 (10) |
| novice | 2 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 14.98 (10) |
| novice | 2 | overkill_carry | all waves | 0 | 10 | 0 | 14.98 (10) | — |
| novice | 3 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 17.23 (9) |
| novice | 3 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 17.23 (9) |
| novice | 3 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 17.23 (9) |
| novice | 3 | overkill_carry | all waves | 0 | 10 | 0 | 17.23 (9) | — |
| novice | 4 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | — | 15.15 (9) |
| novice | 4 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 15.15 (9) |
| novice | 4 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 15.15 (9) |
| novice | 4 | overkill_carry | all waves | 0 | 9 | 0 | 15.15 (9) | — |
| novice | 5 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | — | — |
| novice | 5 | tonnage_armour_crack | war_machine | 2 | 9 | 0.22 | — | — |
| novice | 5 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | — |
| novice | 5 | overkill_carry | all waves | 0 | 9 | 0 | — | — |
| average | All | ohm_short_circuit | sentry_turret | 17 | 78 | 0.22 | 19.13 (14) | 16.48 (52) |
| average | All | tonnage_armour_crack | war_machine | 11 | 78 | 0.14 | 20.5 (7) | 16.92 (59) |
| average | All | kerf_blink_behind | shield_robot | 2 | 78 | 0.03 | 20.87 (2) | 16.98 (64) |
| average | All | overkill_carry | all waves | 0 | 78 | 0 | 17.07 (66) | — |
| average | 1 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 14.71 (10) |
| average | 1 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 14.71 (10) |
| average | 1 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 14.71 (10) |
| average | 1 | overkill_carry | all waves | 0 | 10 | 0 | 14.71 (10) | — |
| average | 2 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 15.01 (10) |
| average | 2 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 15.01 (10) |
| average | 2 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 15.01 (10) |
| average | 2 | overkill_carry | all waves | 0 | 10 | 0 | 15.01 (10) | — |
| average | 3 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 17.04 (10) |
| average | 3 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 17.04 (10) |
| average | 3 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 17.04 (10) |
| average | 3 | overkill_carry | all waves | 0 | 10 | 0 | 17.04 (10) | — |
| average | 4 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 14.32 (10) |
| average | 4 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 14.32 (10) |
| average | 4 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 14.32 (10) |
| average | 4 | overkill_carry | all waves | 0 | 10 | 0 | 14.32 (10) | — |
| average | 5 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 22.33 (6) |
| average | 5 | tonnage_armour_crack | war_machine | 8 | 10 | 0.8 | 22.33 (6) | — |
| average | 5 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 22.33 (6) |
| average | 5 | overkill_carry | all waves | 0 | 10 | 0 | 22.33 (6) | — |
| average | 6 | ohm_short_circuit | sentry_turret | 2 | 6 | 0.33 | 19.37 (3) | 22.28 (3) |
| average | 6 | tonnage_armour_crack | war_machine | 0 | 6 | 0 | — | 20.82 (6) |
| average | 6 | kerf_blink_behind | shield_robot | 0 | 6 | 0 | — | 20.82 (6) |
| average | 6 | overkill_carry | all waves | 0 | 6 | 0 | 20.82 (6) | — |
| average | 7 | ohm_short_circuit | sentry_turret | 1 | 6 | 0.17 | 21.95 (3) | 14.58 (2) |
| average | 7 | tonnage_armour_crack | war_machine | 0 | 6 | 0 | — | 16.25 (5) |
| average | 7 | kerf_blink_behind | shield_robot | 0 | 6 | 0 | — | 16.25 (5) |
| average | 7 | overkill_carry | all waves | 0 | 6 | 0 | 16.25 (5) | — |
| average | 8 | ohm_short_circuit | sentry_turret | 7 | 5 | 1.4 | 20.55 (4) | — |
| average | 8 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 20.55 (4) |
| average | 8 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 20.55 (4) |
| average | 8 | overkill_carry | all waves | 0 | 5 | 0 | 20.55 (4) | — |
| average | 9 | ohm_short_circuit | sentry_turret | 4 | 5 | 0.8 | 20.66 (2) | — |
| average | 9 | tonnage_armour_crack | war_machine | 1 | 5 | 0.2 | — | 20.66 (2) |
| average | 9 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | 23.85 (1) | 17.47 (1) |
| average | 9 | overkill_carry | all waves | 0 | 5 | 0 | 20.66 (2) | — |
| average | 10 | ohm_short_circuit | sentry_turret | 3 | 3 | 1 | 16.6 (1) | — |
| average | 10 | tonnage_armour_crack | war_machine | 2 | 3 | 0.67 | 16.6 (1) | — |
| average | 10 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | — | 16.6 (1) |
| average | 10 | overkill_carry | all waves | 0 | 3 | 0 | 16.6 (1) | — |
| average | 11 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | — | 16.72 (1) |
| average | 11 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 16.72 (1) |
| average | 11 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | 16.72 (1) |
| average | 11 | overkill_carry | all waves | 0 | 1 | 0 | 16.72 (1) | — |
| average | 12 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | 17.88 (1) | — |
| average | 12 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 17.88 (1) |
| average | 12 | kerf_blink_behind | shield_robot | 2 | 1 | 2 | 17.88 (1) | — |
| average | 12 | overkill_carry | all waves | 0 | 1 | 0 | 17.88 (1) | — |
| average | 13 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | — | — |
| average | 13 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | — |
| average | 13 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | — |
| average | 13 | overkill_carry | all waves | 0 | 1 | 0 | — | — |
| expert | All | ohm_short_circuit | sentry_turret | 24 | 81 | 0.3 | 19.33 (14) | 18.52 (52) |
| expert | All | tonnage_armour_crack | war_machine | 16 | 81 | 0.2 | 29.05 (9) | 18.17 (57) |
| expert | All | kerf_blink_behind | shield_robot | 0 | 81 | 0 | 22.82 (2) | 18.52 (64) |
| expert | All | overkill_carry | all waves | 0 | 81 | 0 | 18.71 (66) | — |
| expert | 1 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 16.31 (10) |
| expert | 1 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 16.31 (10) |
| expert | 1 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 16.31 (10) |
| expert | 1 | overkill_carry | all waves | 0 | 10 | 0 | 16.31 (10) | — |
| expert | 2 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 14.38 (10) |
| expert | 2 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 14.38 (10) |
| expert | 2 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 14.38 (10) |
| expert | 2 | overkill_carry | all waves | 0 | 10 | 0 | 14.38 (10) | — |
| expert | 3 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 19.7 (9) |
| expert | 3 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 19.7 (9) |
| expert | 3 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 19.7 (9) |
| expert | 3 | overkill_carry | all waves | 0 | 10 | 0 | 19.7 (9) | — |
| expert | 4 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | — | 18.68 (9) |
| expert | 4 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 18.68 (9) |
| expert | 4 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 18.68 (9) |
| expert | 4 | overkill_carry | all waves | 0 | 9 | 0 | 18.68 (9) | — |
| expert | 5 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | — | 30.95 (8) |
| expert | 5 | tonnage_armour_crack | war_machine | 12 | 9 | 1.33 | 30.95 (8) | — |
| expert | 5 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 30.95 (8) |
| expert | 5 | overkill_carry | all waves | 0 | 9 | 0 | 30.95 (8) | — |
| expert | 6 | ohm_short_circuit | sentry_turret | 3 | 8 | 0.38 | 18.66 (4) | 22.6 (3) |
| expert | 6 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 22 (7) |
| expert | 6 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | — | 22 (7) |
| expert | 6 | overkill_carry | all waves | 0 | 8 | 0 | 22 (7) | — |
| expert | 7 | ohm_short_circuit | sentry_turret | 3 | 8 | 0.38 | 18.84 (4) | 14.23 (2) |
| expert | 7 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 18.19 (6) |
| expert | 7 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | — | 18.19 (6) |
| expert | 7 | overkill_carry | all waves | 0 | 8 | 0 | 18.19 (6) | — |
| expert | 8 | ohm_short_circuit | sentry_turret | 5 | 7 | 0.71 | 17.24 (4) | — |
| expert | 8 | tonnage_armour_crack | war_machine | 0 | 7 | 0 | — | 17.24 (4) |
| expert | 8 | kerf_blink_behind | shield_robot | 0 | 7 | 0 | — | 17.24 (4) |
| expert | 8 | overkill_carry | all waves | 0 | 7 | 0 | 17.24 (4) | — |
| expert | 9 | ohm_short_circuit | sentry_turret | 6 | 5 | 1.2 | 24.08 (2) | — |
| expert | 9 | tonnage_armour_crack | war_machine | 1 | 5 | 0.2 | — | 24.08 (2) |
| expert | 9 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | 25.35 (1) | 22.8 (1) |
| expert | 9 | overkill_carry | all waves | 0 | 5 | 0 | 24.08 (2) | — |
| expert | 10 | ohm_short_circuit | sentry_turret | 5 | 4 | 1.25 | — | 20.28 (1) |
| expert | 10 | tonnage_armour_crack | war_machine | 3 | 4 | 0.75 | 20.28 (1) | — |
| expert | 10 | kerf_blink_behind | shield_robot | 0 | 4 | 0 | 20.28 (1) | — |
| expert | 10 | overkill_carry | all waves | 0 | 4 | 0 | 20.28 (1) | — |
| expert | 11 | ohm_short_circuit | sentry_turret | 2 | 1 | 2 | — | — |
| expert | 11 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | — |
| expert | 11 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | — |
| expert | 11 | overkill_carry | all waves | 0 | 1 | 0 | — | — |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| effect_overkill_carry | waves survived | not measured | 2 (15) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| effect_overkill_carry | wave s | not measured | 18.71 (12) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| ghost_dent | waves survived | 3.5 (6) | 1 (3) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| ghost_dent | wave s | 25.88 (4) | 19.95 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_kerf | waves survived | 4 (10) | 5.5 (4) | 3 | -1 | -2…0 | not measured (3, all offered) | too few pairs |
| ghost_kerf | wave s | 20.13 (8) | 17.5 (4) | 3 | 5.33 | 0.91…7.07 | not measured (3, all offered) | too few pairs |
| ghost_ohm | waves survived | 2 (11) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | wave s | 22.05 (10) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_tonnage | waves survived | 3 (15) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| ghost_tonnage | wave s | 18.42 (14) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| master_kerf | waves survived | 2 (1) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| master_kerf | wave s | 17.3 (1) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| master_ohm | waves survived | 1 (5) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| master_ohm | wave s | 20.28 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_10 | waves survived | 3 (23) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_10 | wave s | 18.3 (23) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_25 | waves survived | 2 (8) | 4 (2) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_25 | wave s | 22.28 (7) | 22.42 (2) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 3 (12) | 3 (16) | 8 | 1 | 0…3 | 7 (6, all offered) | noise |
| stat_guard_meter_10 | wave s | 18.8 (11) | 17.13 (14) | 6 | -1.68 | -16.22…5.95 | not measured (4, all offered) | too few pairs |
| stat_guard_meter_25 | waves survived | 1.5 (6) | 3 (8) | 3 | -3 | -5…0 | not measured (5, all offered) | too few pairs |
| stat_guard_meter_25 | wave s | 19.81 (3) | 18.9 (7) | 1 | 22.86 | not measured | not measured (3, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 2.5 (20) | 1 (4) | 0 | not measured | not measured | 2 (7, all offered) | insufficient data |
| stat_hp_max_10 | wave s | 16.95 (15) | 21.18 (4) | 0 | not measured | not measured | 15.41 (7, all offered) | insufficient data |
| stat_hp_max_25 | waves survived | not measured | 3 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_25 | wave s | not measured | 19.3 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_10 | waves survived | 2 (16) | 3 (6) | 4 | 0 | -2…3 | not measured (3, all offered) | too few pairs |
| stat_regen_10 | wave s | 19.13 (13) | 16.12 (5) | 3 | 6.91 | -16.97…12.12 | not measured (2, all offered) | too few pairs |
| stat_regen_25 | waves survived | 2 (3) | 3.5 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | wave s | 22.69 (2) | 22.79 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | waves survived | 2.5 (14) | 0 (9) | 9 | 2 | 0…4 | not measured (3, all offered) | too few pairs |
| stat_speed_10 | wave s | 19.12 (12) | 19.85 (4) | 4 | -2.78 | -4.65…2.2 | not measured (1, all offered) | too few pairs |
| stat_speed_25 | waves survived | not measured | 2.5 (10) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_25 | wave s | not measured | 19.52 (7) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_chainsaw | waves survived | not measured | 1.5 (8) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_chainsaw | wave s | not measured | 15.35 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | waves survived | 6 (3) | 2 (18) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | wave s | 22.2 (3) | 20.08 (15) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | waves survived | 3.5 (2) | 3 (8) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_flamethrower | wave s | 30.25 (2) | 18.56 (8) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_gatling | waves survived | 1 (5) | 2 (3) | 3 | -1 | -4…0 | not measured (2, all offered) | too few pairs |
| weapon_gatling | wave s | 41.15 (2) | 22.82 (3) | 1 | 25.81 | not measured | not measured (0, all offered) | too few pairs |
| weapon_gloria | waves survived | 2.5 (2) | 2.5 (18) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_gloria | wave s | 20.83 (2) | 17.63 (15) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | not measured | 2 (17) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_hand_cannon | wave s | not measured | 20.83 (14) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_katana | waves survived | 1.5 (2) | 4 (18) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_katana | wave s | not measured | 19.25 (18) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_machine_pistol | waves survived | not measured | 4 (16) | 0 | not measured | not measured | 2 (6, decliners) | insufficient data |
| weapon_machine_pistol | wave s | not measured | 19.35 (16) | 0 | not measured | not measured | 9.64 (6, decliners) | insufficient data |
| weapon_pistol | waves survived | 7 (5) | 2.5 (10) | 3 | 3 | 0…5 | not measured (4, all offered) | too few pairs |
| weapon_pistol | wave s | 17.42 (5) | 17.13 (7) | 3 | 1.42 | -12.57…4.2 | not measured (4, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | 1 (1) | 4.5 (12) | 0 | not measured | not measured | 1 (6, decliners) | insufficient data |
| weapon_plasma_rifle | wave s | 17.88 (1) | 22.1 (12) | 0 | not measured | not measured | 9.73 (6, decliners) | insufficient data |
| weapon_plasma_sword | waves survived | 3.5 (2) | 2 (11) | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| weapon_plasma_sword | wave s | 17.25 (2) | 23.22 (6) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_rocket_launcher | waves survived | 0.5 (4) | 2 (2) | 1 | -3 | not measured | not measured (0, all offered) | too few pairs |
| weapon_rocket_launcher | wave s | 20.28 (1) | 16.72 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | not measured | 1.5 (8) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| chainsaw | wave s | not measured | 15.35 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | waves survived | 6 (3) | 2 (18) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | wave s | 22.2 (3) | 20.08 (15) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | waves survived | 3.5 (2) | 3 (8) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| flamethrower | wave s | 30.25 (2) | 18.56 (8) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| gatling | waves survived | 1 (5) | 2 (3) | 3 | -1 | -4…0 | not measured (2, all offered) | too few pairs |
| gatling | wave s | 41.15 (2) | 22.82 (3) | 1 | 25.81 | not measured | not measured (0, all offered) | too few pairs |
| gloria | waves survived | 2.5 (2) | 2.5 (18) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| gloria | wave s | 20.83 (2) | 17.63 (15) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| hand_cannon | waves survived | not measured | 2 (17) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| hand_cannon | wave s | not measured | 20.83 (14) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| katana | waves survived | 1.5 (2) | 4 (18) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| katana | wave s | not measured | 19.25 (18) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| machine_pistol | waves survived | not measured | 4 (16) | 0 | not measured | not measured | 2 (6, decliners) | insufficient data |
| machine_pistol | wave s | not measured | 19.35 (16) | 0 | not measured | not measured | 9.64 (6, decliners) | insufficient data |
| pistol | waves survived | 7 (5) | 2.5 (10) | 3 | 3 | 0…5 | not measured (4, all offered) | too few pairs |
| pistol | wave s | 17.42 (5) | 17.13 (7) | 3 | 1.42 | -12.57…4.2 | not measured (4, all offered) | too few pairs |
| plasma_rifle | waves survived | 1 (1) | 4.5 (12) | 0 | not measured | not measured | 1 (6, decliners) | insufficient data |
| plasma_rifle | wave s | 17.88 (1) | 22.1 (12) | 0 | not measured | not measured | 9.73 (6, decliners) | insufficient data |
| plasma_sword | waves survived | 3.5 (2) | 2 (11) | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| plasma_sword | wave s | 17.25 (2) | 23.22 (6) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| rocket_launcher | waves survived | 0.5 (4) | 2 (2) | 1 | -3 | not measured | not measured (0, all offered) | too few pairs |
| rocket_launcher | wave s | 20.28 (1) | 16.72 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | kerf s (n) | ohm s (n) | rivet s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 8 (10) | 2 (10) | 0 (10) | 13 (10) | not measured | not measured | 15.12 (10) |
| novice | 2 | 8.5 (10) | 2 (10) | 0 (10) | 14 (10) | not measured | not measured | 14.98 (10) |
| novice | 3 | 6.5 (10) | 2 (10) | 0 (10) | 13 (10) | not measured | not measured | 16.96 (10) |
| novice | 4 | 6 (9) | 2 (9) | 0 (9) | 14 (9) | not measured | not measured | 15.15 (9) |
| novice | 5 | 1 (9) | 0 (9) | 0 (9) | 8 (9) | not measured | not measured | 6.83 (9) |
| average | 1 | 7.5 (10) | 3 (10) | 0 (10) | 13 (10) | not measured | not measured | 14.71 (10) |
| average | 2 | 6.5 (10) | 2 (10) | 0 (10) | 14 (10) | not measured | not measured | 15.01 (10) |
| average | 3 | 5.5 (10) | 6 (10) | 0 (10) | 15 (10) | not measured | not measured | 17.04 (10) |
| average | 4 | 6.5 (10) | 3.5 (10) | 0 (10) | 14.5 (10) | not measured | not measured | 14.32 (10) |
| average | 5 | 2 (10) | 4.5 (10) | 0 (10) | 20 (10) | not measured | not measured | 19.1 (10) |
| average | 6 | 6.5 (6) | 2 (6) | 21.5 (6) | 36 (6) | not measured | not measured | 20.83 (6) |
| average | 7 | 8 (6) | 3 (6) | 15 (6) | 27.5 (6) | not measured | not measured | 14.65 (6) |
| average | 8 | 5 (5) | 6 (5) | 33 (5) | 35 (5) | not measured | not measured | 22.2 (5) |
| average | 9 | 6 (5) | 1 (5) | 26 (5) | 41 (5) | not measured | 1.41 (2) | 14.7 (5) |
| average | 10 | 5 (3) | 3 (3) | 26 (3) | 33 (3) | not measured | 0.03 (1) | 16.57 (3) |
| average | 11 | 4 (1) | 5 (1) | 24 (1) | 19 (1) | 5.5 (1) | not measured | 11.22 (1) |
| average | 12 | 0 (1) | 5 (1) | 36 (1) | 20 (1) | 5.5 (1) | 0.02 (1) | 12.37 (1) |
| average | 13 | 1 (1) | 1 (1) | 5 (1) | 6 (1) | 0.12 (1) | not measured | 14.33 (1) |
| expert | 1 | 9.5 (10) | 3 (10) | 0 (10) | 13 (10) | not measured | not measured | 16.31 (10) |
| expert | 2 | 8 (10) | 3 (10) | 0 (10) | 14 (10) | not measured | not measured | 14.38 (10) |
| expert | 3 | 8 (10) | 7 (10) | 0 (10) | 15.5 (10) | not measured | not measured | 20.11 (10) |
| expert | 4 | 9 (9) | 6 (9) | 0 (9) | 14 (9) | not measured | not measured | 18.68 (9) |
| expert | 5 | 3 (9) | 4 (9) | 0 (9) | 21 (9) | not measured | not measured | 29.05 (9) |
| expert | 6 | 7.5 (8) | 4 (8) | 1.5 (8) | 34.5 (8) | not measured | not measured | 22.3 (8) |
| expert | 7 | 6 (8) | 4 (8) | 0.5 (8) | 30 (8) | not measured | not measured | 18.48 (8) |
| expert | 8 | 5 (7) | 4 (7) | 1 (7) | 32 (7) | not measured | 0.03 (1) | 21.65 (7) |
| expert | 9 | 2 (5) | 4 (5) | 29 (5) | 37 (5) | not measured | 0.08 (1) | 25.35 (5) |
| expert | 10 | 1 (4) | 2.5 (4) | 44 (4) | 39.5 (4) | not measured | 0.02 (3) | 15.18 (4) |
| expert | 11 | 2 (1) | 1 (1) | 14 (1) | 22 (1) | not measured | 0.03 (1) | 15.72 (1) |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 3 | 5 | 2.21 | stat_hp_max_10 → weapon_pistol → stat_damage_10 → stat_guard_meter_10 | pistol | rivet | node tools/dev/run.mjs gauntlet --seed=3 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| novice | 8 | 5 | 2.21 | stat_hp_max_10 → ghost_tonnage → weapon_electro_baton → stat_regen_10 | electro_baton | rivet | node tools/dev/run.mjs gauntlet --seed=8 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| novice | 1 | 5 | 1.21 | ghost_tonnage → stat_hp_max_10 → stat_damage_10 → ghost_dent | none | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| average | 5 | 13 | 2.21 | stat_speed_10 → stat_guard_meter_10 → stat_damage_10 → ghost_kerf → weapon_pistol → ghost_ohm → weapon_plasma_sword → master_ohm → stat_hp_max_10 → stat_damage_25 → master_kerf → stat_regen_10 → weapon_plasma_rifle → stat_guard_meter_25 | pistol, plasma_rifle, plasma_sword | rivet | node tools/dev/run.mjs gauntlet --seed=5 --bot=average --pick=greedy --controls=wheel --waves=40 |
| expert | 3 | 11 | 2.21 | stat_hp_max_10 → weapon_pistol → stat_damage_10 → stat_guard_meter_10 → stat_regen_10 → ghost_tonnage → weapon_gloria → ghost_ohm → master_ohm → weapon_rocket_launcher → ghost_kerf | gloria, pistol, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=3 --bot=expert --pick=greedy --controls=wheel --waves=40 |
