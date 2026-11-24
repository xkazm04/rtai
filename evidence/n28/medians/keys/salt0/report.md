# Gauntlet run report

30 of 30 runs accepted. Average-profile waves 5 (22.26 s), 6 (20.82 s), 8 (18.9 s), 9 (23.85 s), 10 (16.6 s), 11 (20.1 s) fell outside 12–18 s for ordinary waves and 25–30 s for boss waves.

Live gauntlet batch · n28-combat @ b7bc6b6e3dbb (dirty) · 2026-11-24T19:40:29.538Z.

Stalled runs by profile: novice 0, average 0, expert 0.

Capped alive by profile: novice 0, average 0, expert 0.

## Death-wave score

Censored runs contribute their last reached wave as a lower bound to the median and spread.

| Profile | Target | Median wave | P25–P75 | Min–max | Deaths / censored |
| --- | --- | --- | --- | --- | --- |
| novice | 6 | 5 | 5–5 | 3–5 | 10 / 0 |
| average | 12 | 8 | 5–10 | 5–12 | 10 / 0 |
| expert | 20 | 8.5 | 7–10 | 3–14 | 10 / 0 |

## Profile separation

Targets require a median gap of 3 waves and a later death on at least 75% of shared seeds with the same controls and pick policy. Unresolved censored pairs stay in the denominator.

| Profiles | Observed median gap | Later / shared seeds | Confirmed later share | Unresolved | Verdict |
| --- | --- | --- | --- | --- | --- |
| novice → average | 3 | 7 / 10 | 70% | 0 | below target |
| novice → expert | 3.5 | 8 / 10 | 80% | 0 | separated |
| average → expert | 0.5 | 5 / 10 | 50% | 0 | below target |

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
| average | 1 | died on 9 | 0 | 1 |
| average | 2 | died on 5 | 0 | 1 |
| average | 3 | died on 10 | 0 | 1 |
| average | 4 | died on 5 | 0 | 1 |
| average | 5 | died on 12 | 0 | 1 |
| average | 6 | died on 7 | 0 | 1 |
| average | 7 | died on 9 | 0 | 1 |
| average | 8 | died on 10 | 0 | 1 |
| average | 9 | died on 5 | 0 | 1 |
| average | 10 | died on 5 | 0 | 1 |
| expert | 1 | died on 10 | 1 | 2 |
| expert | 2 | died on 5 | 0 | 1 |
| expert | 3 | died on 11 | 0 | 1 |
| expert | 4 | died on 8 | 2 | 3 |
| expert | 5 | died on 10 | 0 | 1 |
| expert | 6 | died on 7 | 0 | 1 |
| expert | 7 | died on 8 | 0 | 1 |
| expert | 8 | died on 14 | 0 | 1 |
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
| average | 4 | 10 / 10 | 13.76 | 12.1…19.55 | 8.83…25.37 | within target |
| average | 5 | 6 / 10 | 22.26 | 17.7…25.05 | 17.63…28.85 | miss |
| average | 6 | 6 / 6 | 20.82 | 18.67…23.87 | 14.18…25.17 | miss |
| average | 7 | 5 / 6 | 16.58 | 16.25…21.95 | 12.92…23.93 | within target |
| average | 8 | 5 / 5 | 18.9 | 15.65…27.6 | 15.37…37.1 | miss |
| average | 9 | 3 / 5 | 23.85 | 17.47…25.22 | 17.47…25.22 | miss |
| average | 10 | 1 / 3 | 16.6 | 16.6…16.6 | 16.6…16.6 | miss |
| average | 11 | 1 / 1 | 20.1 | 20.1…20.1 | 20.1…20.1 | miss |
| average | 12 | 0 / 1 | not measured | not measured | not measured | not measured |
| expert | 1 | 10 / 10 | 16.31 | 13.4…18.35 | 13.02…22.67 | — |
| expert | 2 | 10 / 10 | 14.38 | 12.08…17.35 | 11.57…22.1 | — |
| expert | 3 | 9 / 10 | 19.7 | 18.92…21.78 | 6.93…36.67 | — |
| expert | 4 | 9 / 9 | 15.73 | 11.2…25.03 | 8.42…34.48 | — |
| expert | 5 | 8 / 9 | 29.85 | 25.88…36.07 | 12…38.88 | — |
| expert | 6 | 7 / 8 | 19.67 | 14.18…28.37 | 12.92…37.9 | — |
| expert | 7 | 6 / 8 | 18.87 | 18.17…22.83 | 10.23…32.38 | — |
| expert | 8 | 5 / 7 | 17.97 | 15.35…19.13 | 12.77…32.32 | — |
| expert | 9 | 3 / 5 | 22.8 | 17.88…25.35 | 17.88…25.35 | — |
| expert | 10 | 2 / 4 | 21.48 | 20.28…22.68 | 20.28…22.68 | — |
| expert | 11 | 1 / 2 | 22.53 | 22.53…22.53 | 22.53…22.53 | — |
| expert | 12 | 1 / 1 | 28.13 | 28.13…28.13 | 28.13…28.13 | — |
| expert | 13 | 1 / 1 | 20.58 | 20.58…20.58 | 20.58…20.58 | — |
| expert | 14 | 0 / 1 | not measured | not measured | not measured | — |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 10 | 10 | 0 | 0 | 0 | 3 × 1, 5 × 9 | stomp × 8, riot_cop × 1, swat × 1 | 0 |
| average | 10 | 10 | 0 | 0 | 0 | 5 × 4, 7 × 1, 9 × 2, 10 × 2, 12 × 1 | stomp × 3, shield_robot × 2, patrol_cop × 1, robot_thug × 1, rocket × 1, swat × 1, war_cannon × 1 | 0 |
| expert | 10 | 10 | 0 | 0 | 0 | 3 × 1, 5 × 1, 7 × 1, 8 × 2, 9 × 1, 10 × 2, 11 × 1, 14 × 1 | sentry_turret × 3, shield_robot × 2, riot_cop × 1, robot_gunner × 1, rocket × 1, stomp × 1, war_cannon × 1 | 0 |

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
| average | 11–20 | 2 / 2 | 65.08 | 1 | 11 | 33.41 | 0 | 0 | 1 | 33.5 | 5.5 | 1.375 | 1.1 | 1.1 | 1.1 | 1.1 |
| average | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 1–10 | 80 / 80 | 18.6 | 0.88 | 10 | 80.65 | 0 | 0 | 6 | 21.5 | 4.5 | 1.1 | 1 | 1 | 1 | 1 |
| expert | 11–20 | 5 / 5 | 93.48 | 2.49 | 11 | 32.01 | 0 | 0 | 3 | 7 | 2 | 1.1 | 1.1 | 1.375 | 1.1 | 1.1 |
| expert | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 0 | — | 62.54% | 19.13 (103) | 15.75 (74) |
| patrol_cop | 1 | — | 88.55% | 16.84 (160) | 22.68 (17) |
| riot_cop | 2 | — | 56.19% | 18.68 (94) | 16.25 (83) |
| robot_gunner | 1 | — | 24.64% | 19.52 (39) | 16.49 (138) |
| robot_thug | 1 | — | 23.55% | 20.1 (37) | 16.48 (140) |
| rocket_trooper | 2 | rocket × 2 | 59.31% | 18.92 (99) | 15.96 (78) |
| sentry_turret | 3 | — | 23.32% | 20.58 (35) | 16.38 (142) |
| shield_robot | 4 | — | 5% | 22.68 (7) | 16.9 (170) |
| swat | 2 | — | 48.69% | 18.11 (86) | 16.68 (91) |
| war_machine | 14 | stomp × 12, war_cannon × 2 | 12.98% | 25.05 (17) | 16.78 (160) |

## Moves

Uses count recorded activations by profile and wave number. The game omits zero counts. Times are medians in seconds, with timed wave counts in parentheses. Carry applies to all waves.

| Profile | Wave | Move | Enemy | Recorded uses | Observed waves | Uses per wave | With enemy s (n) | Without enemy s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | All | ohm_short_circuit | sentry_turret | 0 | 48 | 0 | — | 15.13 (38) |
| novice | All | tonnage_armour_crack | war_machine | 3 | 48 | 0.06 | — | 15.13 (38) |
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
| novice | 5 | tonnage_armour_crack | war_machine | 3 | 9 | 0.33 | — | — |
| novice | 5 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | — |
| novice | 5 | overkill_carry | all waves | 0 | 9 | 0 | — | — |
| average | All | ohm_short_circuit | sentry_turret | 12 | 77 | 0.16 | 19.37 (15) | 16.58 (52) |
| average | All | tonnage_armour_crack | war_machine | 9 | 77 | 0.12 | 20.02 (7) | 16.93 (60) |
| average | All | kerf_blink_behind | shield_robot | 0 | 77 | 0 | 23.85 (1) | 17.07 (66) |
| average | All | overkill_carry | all waves | 0 | 77 | 0 | 17.13 (67) | — |
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
| average | 4 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 13.76 (10) |
| average | 4 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 13.76 (10) |
| average | 4 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 13.76 (10) |
| average | 4 | overkill_carry | all waves | 0 | 10 | 0 | 13.76 (10) | — |
| average | 5 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 22.26 (6) |
| average | 5 | tonnage_armour_crack | war_machine | 7 | 10 | 0.7 | 22.26 (6) | — |
| average | 5 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 22.26 (6) |
| average | 5 | overkill_carry | all waves | 0 | 10 | 0 | 22.26 (6) | — |
| average | 6 | ohm_short_circuit | sentry_turret | 0 | 6 | 0 | 19.37 (3) | 22.28 (3) |
| average | 6 | tonnage_armour_crack | war_machine | 0 | 6 | 0 | — | 20.82 (6) |
| average | 6 | kerf_blink_behind | shield_robot | 0 | 6 | 0 | — | 20.82 (6) |
| average | 6 | overkill_carry | all waves | 0 | 6 | 0 | 20.82 (6) | — |
| average | 7 | ohm_short_circuit | sentry_turret | 0 | 6 | 0 | 21.95 (3) | 14.58 (2) |
| average | 7 | tonnage_armour_crack | war_machine | 0 | 6 | 0 | — | 16.58 (5) |
| average | 7 | kerf_blink_behind | shield_robot | 0 | 6 | 0 | — | 16.58 (5) |
| average | 7 | overkill_carry | all waves | 0 | 6 | 0 | 16.58 (5) | — |
| average | 8 | ohm_short_circuit | sentry_turret | 4 | 5 | 0.8 | 18.9 (5) | — |
| average | 8 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 18.9 (5) |
| average | 8 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 18.9 (5) |
| average | 8 | overkill_carry | all waves | 0 | 5 | 0 | 18.9 (5) | — |
| average | 9 | ohm_short_circuit | sentry_turret | 4 | 5 | 0.8 | 23.85 (3) | — |
| average | 9 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 23.85 (3) |
| average | 9 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | 23.85 (1) | 21.34 (2) |
| average | 9 | overkill_carry | all waves | 0 | 5 | 0 | 23.85 (3) | — |
| average | 10 | ohm_short_circuit | sentry_turret | 3 | 3 | 1 | 16.6 (1) | — |
| average | 10 | tonnage_armour_crack | war_machine | 2 | 3 | 0.67 | 16.6 (1) | — |
| average | 10 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | — | 16.6 (1) |
| average | 10 | overkill_carry | all waves | 0 | 3 | 0 | 16.6 (1) | — |
| average | 11 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | — | 20.1 (1) |
| average | 11 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 20.1 (1) |
| average | 11 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | 20.1 (1) |
| average | 11 | overkill_carry | all waves | 0 | 1 | 0 | 20.1 (1) | — |
| average | 12 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | — | — |
| average | 12 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | — |
| average | 12 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | — |
| average | 12 | overkill_carry | all waves | 0 | 1 | 0 | — | — |
| expert | All | ohm_short_circuit | sentry_turret | 39 | 85 | 0.46 | 21.29 (20) | 18.28 (52) |
| expert | All | tonnage_armour_crack | war_machine | 12 | 85 | 0.14 | 27.47 (10) | 18.19 (62) |
| expert | All | kerf_blink_behind | shield_robot | 0 | 85 | 0 | 22.61 (6) | 18.28 (66) |
| expert | All | overkill_carry | all waves | 0 | 85 | 0 | 18.88 (72) | — |
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
| expert | 4 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | — | 15.73 (9) |
| expert | 4 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 15.73 (9) |
| expert | 4 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 15.73 (9) |
| expert | 4 | overkill_carry | all waves | 0 | 9 | 0 | 15.73 (9) | — |
| expert | 5 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | — | 29.85 (8) |
| expert | 5 | tonnage_armour_crack | war_machine | 9 | 9 | 1 | 29.85 (8) | — |
| expert | 5 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 29.85 (8) |
| expert | 5 | overkill_carry | all waves | 0 | 9 | 0 | 29.85 (8) | — |
| expert | 6 | ohm_short_circuit | sentry_turret | 4 | 8 | 0.5 | 18.66 (4) | 19.67 (3) |
| expert | 6 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 19.67 (7) |
| expert | 6 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | — | 19.67 (7) |
| expert | 6 | overkill_carry | all waves | 0 | 8 | 0 | 19.67 (7) | — |
| expert | 7 | ohm_short_circuit | sentry_turret | 3 | 8 | 0.38 | 21.18 (4) | 14.23 (2) |
| expert | 7 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 18.87 (6) |
| expert | 7 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | — | 18.87 (6) |
| expert | 7 | overkill_carry | all waves | 0 | 8 | 0 | 18.87 (6) | — |
| expert | 8 | ohm_short_circuit | sentry_turret | 6 | 7 | 0.86 | 17.97 (5) | — |
| expert | 8 | tonnage_armour_crack | war_machine | 0 | 7 | 0 | — | 17.97 (5) |
| expert | 8 | kerf_blink_behind | shield_robot | 0 | 7 | 0 | — | 17.97 (5) |
| expert | 8 | overkill_carry | all waves | 0 | 7 | 0 | 17.97 (5) | — |
| expert | 9 | ohm_short_circuit | sentry_turret | 8 | 5 | 1.6 | 22.8 (3) | — |
| expert | 9 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 22.8 (3) |
| expert | 9 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | 25.35 (1) | 20.34 (2) |
| expert | 9 | overkill_carry | all waves | 0 | 5 | 0 | 22.8 (3) | — |
| expert | 10 | ohm_short_circuit | sentry_turret | 8 | 4 | 2 | 22.68 (1) | 20.28 (1) |
| expert | 10 | tonnage_armour_crack | war_machine | 3 | 4 | 0.75 | 21.48 (2) | — |
| expert | 10 | kerf_blink_behind | shield_robot | 0 | 4 | 0 | 21.48 (2) | — |
| expert | 10 | overkill_carry | all waves | 0 | 4 | 0 | 21.48 (2) | — |
| expert | 11 | ohm_short_circuit | sentry_turret | 5 | 2 | 2.5 | 22.53 (1) | — |
| expert | 11 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 22.53 (1) |
| expert | 11 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | 22.53 (1) | — |
| expert | 11 | overkill_carry | all waves | 0 | 2 | 0 | 22.53 (1) | — |
| expert | 12 | ohm_short_circuit | sentry_turret | 3 | 1 | 3 | 28.13 (1) | — |
| expert | 12 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 28.13 (1) |
| expert | 12 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | 28.13 (1) | — |
| expert | 12 | overkill_carry | all waves | 0 | 1 | 0 | 28.13 (1) | — |
| expert | 13 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 20.58 (1) | — |
| expert | 13 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 20.58 (1) |
| expert | 13 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | 20.58 (1) | — |
| expert | 13 | overkill_carry | all waves | 0 | 1 | 0 | 20.58 (1) | — |
| expert | 14 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | — | — |
| expert | 14 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | — |
| expert | 14 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | — |
| expert | 14 | overkill_carry | all waves | 0 | 1 | 0 | — | — |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| effect_overkill_carry | waves survived | not measured | 3 (12) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| effect_overkill_carry | wave s | not measured | 18.55 (12) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| ghost_dent | waves survived | 3.5 (6) | 2 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_dent | wave s | 23.39 (5) | 20.13 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_kerf | waves survived | 4 (10) | 5.5 (4) | 3 | -1 | -6…0 | not measured (3, all offered) | too few pairs |
| ghost_kerf | wave s | 20.13 (8) | 20.55 (4) | 3 | 3.8 | -3.65…7.07 | not measured (3, all offered) | too few pairs |
| ghost_ohm | waves survived | 2 (10) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | wave s | 21.89 (9) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_tonnage | waves survived | 3 (16) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| ghost_tonnage | wave s | 16.72 (14) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| master_ohm | waves survived | 2 (4) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| master_ohm | wave s | 20.28 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| master_tonnage | waves survived | 1 (9) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| master_tonnage | wave s | 15.65 (7) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_damage_10 | waves survived | 3 (26) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_10 | wave s | 18.4 (24) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_25 | waves survived | 1.5 (8) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_25 | wave s | 22.28 (7) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 3 (16) | 3 (12) | 4 | 2 | 0…4 | 6 (6, all offered) | noise |
| stat_guard_meter_10 | wave s | 19.75 (14) | 13.48 (10) | 2 | 5.26 | 4.57…5.95 | not measured (5, all offered) | too few pairs |
| stat_guard_meter_25 | waves survived | 0 (3) | 3 (10) | 3 | -3 | -5…0 | 5 (6, all offered) | noise |
| stat_guard_meter_25 | wave s | 38.88 (1) | 18.79 (8) | 1 | 22.86 | not measured | not measured (4, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 3 (18) | 1 (4) | 0 | not measured | not measured | 3 (7, all offered) | insufficient data |
| stat_hp_max_10 | wave s | 17.47 (15) | 21.18 (4) | 0 | not measured | not measured | 9.69 (7, all offered) | insufficient data |
| stat_hp_max_25 | waves survived | 3 (1) | 3 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_25 | wave s | 22.53 (1) | 19.3 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_10 | waves survived | 2 (16) | 3 (6) | 2 | 1.5 | 0…3 | not measured (3, all offered) | too few pairs |
| stat_regen_10 | wave s | 19.79 (13) | 12.1 (5) | 1 | 12.12 | not measured | not measured (1, all offered) | too few pairs |
| stat_regen_25 | waves survived | 2 (3) | 3 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | wave s | 22.69 (2) | 22.53 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | waves survived | 3 (14) | 2 (7) | 6 | 2 | 0…5 | not measured (3, all offered) | too few pairs |
| stat_speed_10 | wave s | 18.59 (12) | 20.73 (5) | 4 | -2.78 | -3.78…2.2 | not measured (1, all offered) | too few pairs |
| stat_speed_25 | waves survived | 1 (3) | 2.5 (6) | 1 | 0 | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_25 | wave s | 18.45 (2) | 17.63 (5) | 1 | 1.73 | not measured | not measured (0, all offered) | too few pairs |
| weapon_chainsaw | waves survived | not measured | 1.5 (8) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_chainsaw | wave s | not measured | 18.3 (7) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | waves survived | 6 (3) | 2 (17) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | wave s | 21.94 (3) | 18.96 (13) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | waves survived | 2 (1) | 3 (8) | 1 | -2 | not measured | not measured (1, all offered) | too few pairs |
| weapon_flamethrower | wave s | 26.41 (1) | 18.56 (8) | 1 | 9.38 | not measured | not measured (1, all offered) | too few pairs |
| weapon_gatling | waves survived | 0.5 (4) | 2 (3) | 1 | -1 | not measured | not measured (0, all offered) | too few pairs |
| weapon_gatling | wave s | 22.61 (1) | 22.82 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gloria | waves survived | 1.5 (4) | 3 (18) | 2 | -1.5 | -3…0 | not measured (2, all offered) | too few pairs |
| weapon_gloria | wave s | 16.19 (4) | 18.5 (15) | 2 | -4.2 | -6.07…-2.32 | not measured (2, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | not measured | 2 (16) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_hand_cannon | wave s | not measured | 20.28 (13) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_katana | waves survived | 2 (2) | 4 (18) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_katana | wave s | 19.79 (1) | 19.53 (18) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_machine_pistol | waves survived | not measured | 4 (15) | 0 | not measured | not measured | 6 (6, decliners) | insufficient data |
| weapon_machine_pistol | wave s | not measured | 19.7 (15) | 0 | not measured | not measured | 8.43 (6, decliners) | insufficient data |
| weapon_pistol | waves survived | 5 (6) | 3 (10) | 4 | 1.5 | 0…5 | not measured (4, all offered) | too few pairs |
| weapon_pistol | wave s | 17.56 (6) | 17.13 (9) | 4 | -0.42 | -12.57…4.2 | not measured (4, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | not measured | 4 (15) | 0 | not measured | not measured | 3 (6, decliners) | insufficient data |
| weapon_plasma_rifle | wave s | not measured | 20.87 (14) | 0 | not measured | not measured | 12.49 (6, decliners) | insufficient data |
| weapon_plasma_sword | waves survived | 3 (2) | 2 (9) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_plasma_sword | wave s | 17.41 (2) | 21.86 (5) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_rocket_launcher | waves survived | 1 (5) | 2 (1) | 1 | -2 | not measured | not measured (1, all offered) | too few pairs |
| weapon_rocket_launcher | wave s | 22.75 (2) | 18.35 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | not measured | 1.5 (8) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| chainsaw | wave s | not measured | 18.3 (7) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | waves survived | 6 (3) | 2 (17) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | wave s | 21.94 (3) | 18.96 (13) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | waves survived | 2 (1) | 3 (8) | 1 | -2 | not measured | not measured (1, all offered) | too few pairs |
| flamethrower | wave s | 26.41 (1) | 18.56 (8) | 1 | 9.38 | not measured | not measured (1, all offered) | too few pairs |
| gatling | waves survived | 0.5 (4) | 2 (3) | 1 | -1 | not measured | not measured (0, all offered) | too few pairs |
| gatling | wave s | 22.61 (1) | 22.82 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gloria | waves survived | 1.5 (4) | 3 (18) | 2 | -1.5 | -3…0 | not measured (2, all offered) | too few pairs |
| gloria | wave s | 16.19 (4) | 18.5 (15) | 2 | -4.2 | -6.07…-2.32 | not measured (2, all offered) | too few pairs |
| hand_cannon | waves survived | not measured | 2 (16) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| hand_cannon | wave s | not measured | 20.28 (13) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| katana | waves survived | 2 (2) | 4 (18) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| katana | wave s | 19.79 (1) | 19.53 (18) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| machine_pistol | waves survived | not measured | 4 (15) | 0 | not measured | not measured | 6 (6, decliners) | insufficient data |
| machine_pistol | wave s | not measured | 19.7 (15) | 0 | not measured | not measured | 8.43 (6, decliners) | insufficient data |
| pistol | waves survived | 5 (6) | 3 (10) | 4 | 1.5 | 0…5 | not measured (4, all offered) | too few pairs |
| pistol | wave s | 17.56 (6) | 17.13 (9) | 4 | -0.42 | -12.57…4.2 | not measured (4, all offered) | too few pairs |
| plasma_rifle | waves survived | not measured | 4 (15) | 0 | not measured | not measured | 3 (6, decliners) | insufficient data |
| plasma_rifle | wave s | not measured | 20.87 (14) | 0 | not measured | not measured | 12.49 (6, decliners) | insufficient data |
| plasma_sword | waves survived | 3 (2) | 2 (9) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| plasma_sword | wave s | 17.41 (2) | 21.86 (5) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| rocket_launcher | waves survived | 1 (5) | 2 (1) | 1 | -2 | not measured | not measured (1, all offered) | too few pairs |
| rocket_launcher | wave s | 22.75 (2) | 18.35 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | ohm s (n) | rivet s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 8 (10) | 2 (10) | 0 (10) | 13 (10) | not measured | 15.12 (10) | not measured |
| novice | 2 | 8.5 (10) | 2 (10) | 0 (10) | 14 (10) | not measured | 14.98 (10) | not measured |
| novice | 3 | 6.5 (10) | 2 (10) | 0 (10) | 13 (10) | not measured | 16.96 (10) | not measured |
| novice | 4 | 6 (9) | 2 (9) | 0 (9) | 14 (9) | not measured | 15.15 (9) | not measured |
| novice | 5 | 1 (9) | 1 (9) | 0 (9) | 8 (9) | not measured | 6.43 (9) | 5.57 (2) |
| average | 1 | 7.5 (10) | 3 (10) | 0 (10) | 13 (10) | not measured | 14.71 (10) | not measured |
| average | 2 | 6.5 (10) | 2 (10) | 0 (10) | 14 (10) | not measured | 15.01 (10) | not measured |
| average | 3 | 5.5 (10) | 6 (10) | 0 (10) | 15 (10) | not measured | 17.04 (10) | not measured |
| average | 4 | 6 (10) | 3.5 (10) | 0 (10) | 14 (10) | not measured | 13.76 (10) | 6.42 (1) |
| average | 5 | 2 (10) | 4 (10) | 0 (10) | 21 (10) | not measured | 17.69 (10) | 5.1 (3) |
| average | 6 | 7 (6) | 2.5 (6) | 0 (6) | 30 (6) | not measured | 19.02 (6) | 7.1 (1) |
| average | 7 | 5 (6) | 3 (6) | 0 (6) | 29.5 (6) | not measured | 16.41 (6) | 7.1 (1) |
| average | 8 | 4 (5) | 6 (5) | 33 (5) | 34 (5) | not measured | 18.9 (5) | 7.1 (1) |
| average | 9 | 4 (5) | 3 (5) | 4 (5) | 41 (5) | 2.77 (1) | 14.7 (5) | 7.1 (2) |
| average | 10 | 5 (3) | 4 (3) | 26 (3) | 33 (3) | 0.03 (1) | 16.57 (3) | 7.1 (1) |
| average | 11 | 2 (1) | 11 (1) | 24 (1) | 41 (1) | 7.3 (1) | 12.8 (1) | not measured |
| average | 12 | 0 (1) | 0 (1) | 10 (1) | 9 (1) | 0.02 (1) | 12.57 (1) | not measured |
| expert | 1 | 9.5 (10) | 3 (10) | 0 (10) | 13 (10) | not measured | 16.31 (10) | not measured |
| expert | 2 | 8 (10) | 3 (10) | 0 (10) | 14 (10) | not measured | 14.38 (10) | not measured |
| expert | 3 | 8 (10) | 7 (10) | 0 (10) | 15.5 (10) | not measured | 20.11 (10) | not measured |
| expert | 4 | 7 (9) | 6 (9) | 0 (9) | 14 (9) | not measured | 15.73 (9) | 2.03 (1) |
| expert | 5 | 3 (9) | 4 (9) | 0 (9) | 21 (9) | not measured | 25.88 (9) | 5.21 (2) |
| expert | 6 | 6 (8) | 4.5 (8) | 0 (8) | 29.5 (8) | not measured | 20.84 (8) | 0.02 (1) |
| expert | 7 | 5 (8) | 4 (8) | 0 (8) | 31 (8) | 7.15 (1) | 18.48 (8) | 7.1 (1) |
| expert | 8 | 3 (7) | 7 (7) | 1 (7) | 31 (7) | 0.07 (1) | 19.13 (7) | 7.1 (1) |
| expert | 9 | 2 (5) | 4 (5) | 29 (5) | 38 (5) | not measured | 22.8 (5) | 5.2 (3) |
| expert | 10 | 2 (4) | 7.5 (4) | 46 (4) | 50.5 (4) | 0.03 (3) | 21.45 (4) | 2.43 (2) |
| expert | 11 | 9.5 (2) | 1 (2) | 52.5 (2) | 57.5 (2) | 0.05 (2) | 19.09 (2) | not measured |
| expert | 12 | 1 (1) | 6 (1) | 146 (1) | 161 (1) | 0.03 (1) | 23.07 (1) | 5.03 (1) |
| expert | 13 | 3 (1) | 2 (1) | 106 (1) | 111 (1) | 0.03 (1) | 20.55 (1) | not measured |
| expert | 14 | 4 (1) | 16 (1) | 30 (1) | 46 (1) | 0.03 (1) | 27.12 (1) | 7.1 (1) |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 5 | 2.21 | ghost_tonnage → stat_hp_max_10 → master_tonnage → stat_damage_10 → weapon_katana | katana | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| novice | 3 | 5 | 2.21 | stat_hp_max_10 → weapon_pistol → stat_damage_10 → stat_guard_meter_10 | pistol | rivet | node tools/dev/run.mjs gauntlet --seed=3 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| novice | 8 | 5 | 2.21 | stat_hp_max_10 → ghost_tonnage → weapon_electro_baton → stat_regen_10 | electro_baton | rivet | node tools/dev/run.mjs gauntlet --seed=8 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| average | 5 | 12 | 2.21 | stat_speed_10 → stat_guard_meter_10 → stat_damage_10 → ghost_kerf → weapon_pistol → ghost_ohm → weapon_plasma_sword → master_ohm → stat_hp_max_10 → stat_damage_25 → stat_regen_10 → ghost_tonnage | pistol, plasma_sword | rivet | node tools/dev/run.mjs gauntlet --seed=5 --bot=average --pick=greedy --controls=wheel --waves=40 |
| expert | 8 | 14 | 2.21 | stat_hp_max_10 → ghost_tonnage → weapon_electro_baton → stat_regen_10 → master_tonnage → ghost_ohm → master_ohm → stat_guard_meter_10 → weapon_gatling → stat_damage_10 → stat_speed_10 → stat_hp_max_25 → weapon_pistol → ghost_dent → stat_speed_25 | electro_baton, gatling, pistol | rivet | node tools/dev/run.mjs gauntlet --seed=8 --bot=expert --pick=greedy --controls=wheel --waves=40 |
