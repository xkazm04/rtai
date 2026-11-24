# Gauntlet run report

30 of 30 runs accepted. Average-profile waves 5 (21.02 s), 6 (22.55 s), 7 (20.62 s), 8 (24.73 s), 9 (27.56 s), 10 (20.92 s) fell outside 12–18 s for ordinary waves and 25–30 s for boss waves.

Live gauntlet batch · n27-pressure @ a3b3f14660a2 (dirty) · 2026-11-24T01:57:19.023Z.

Stalled runs by profile: novice 0, average 0, expert 0.

Capped alive by profile: novice 0, average 0, expert 0.

## Death-wave score

Censored runs contribute their last reached wave as a lower bound to the median and spread.

| Profile | Target | Median wave | P25–P75 | Min–max | Deaths / censored |
| --- | --- | --- | --- | --- | --- |
| novice | 6 | 5 | 5–5 | 3–5 | 10 / 0 |
| average | 12 | 5 | 5–5 | 3–11 | 10 / 0 |
| expert | 20 | 9 | 9–9 | 5–10 | 10 / 0 |

## Profile separation

Targets require a median gap of 3 waves and a later death on at least 75% of shared seeds with the same controls and pick policy. Unresolved censored pairs stay in the denominator.

| Profiles | Observed median gap | Later / shared seeds | Confirmed later share | Unresolved | Verdict |
| --- | --- | --- | --- | --- | --- |
| novice → average | 0 | 3 / 10 | 30% | 0 | below target |
| novice → expert | 4 | 9 / 10 | 90% | 0 | separated |
| average → expert | 4 | 7 / 10 | 70% | 0 | below target |

## Waves per run

A timed-out wave can clear later. Active counts include each started roster still fighting at death.

| Profile | Seed | Outcome | Timed-out waves | Active waves at death |
| --- | --- | --- | --- | --- |
| novice | 1 | died on 5 | 0 | 1 |
| novice | 2 | died on 5 | 0 | 1 |
| novice | 3 | died on 5 | 0 | 1 |
| novice | 4 | died on 5 | 0 | 1 |
| novice | 5 | died on 4 | 0 | 1 |
| novice | 6 | died on 5 | 0 | 1 |
| novice | 7 | died on 5 | 0 | 1 |
| novice | 8 | died on 5 | 0 | 1 |
| novice | 9 | died on 3 | 0 | 1 |
| novice | 10 | died on 5 | 0 | 1 |
| average | 1 | died on 3 | 0 | 1 |
| average | 2 | died on 5 | 0 | 1 |
| average | 3 | died on 11 | 0 | 1 |
| average | 4 | died on 5 | 0 | 1 |
| average | 5 | died on 5 | 0 | 1 |
| average | 6 | died on 5 | 0 | 1 |
| average | 7 | died on 5 | 0 | 1 |
| average | 8 | died on 10 | 0 | 1 |
| average | 9 | died on 3 | 0 | 1 |
| average | 10 | died on 5 | 0 | 1 |
| expert | 1 | died on 10 | 0 | 1 |
| expert | 2 | died on 9 | 0 | 1 |
| expert | 3 | died on 9 | 0 | 1 |
| expert | 4 | died on 5 | 0 | 1 |
| expert | 5 | died on 9 | 0 | 1 |
| expert | 6 | died on 9 | 0 | 1 |
| expert | 7 | died on 8 | 0 | 1 |
| expert | 8 | died on 10 | 0 | 1 |
| expert | 9 | died on 9 | 0 | 1 |
| expert | 10 | died on 9 | 0 | 1 |

## Wave time

Seconds per observed wave. The target is 15 s ±20% for ordinary average-profile waves. Every 5th wave targets 25–30 s. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Median s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 10 / 10 | 14.64 | 13.77…15.47 | 12.83…15.67 | — |
| novice | 2 | 10 / 10 | 14.61 | 13.9…17.25 | 11.27…23.05 | — |
| novice | 3 | 9 / 10 | 18.85 | 14.3…19.93 | 12.53…27.77 | — |
| novice | 4 | 8 / 9 | 16.37 | 16.13…19.95 | 14.93…22.37 | — |
| novice | 5 | 0 / 8 | not measured | not measured | not measured | — |
| average | 1 | 10 / 10 | 14.06 | 12.3…19.75 | 10.78…24.87 | within target |
| average | 2 | 10 / 10 | 15.04 | 11.93…17.93 | 8.43…20.3 | within target |
| average | 3 | 8 / 10 | 16.34 | 12.42…17.52 | 7.52…25.12 | within target |
| average | 4 | 8 / 8 | 15.77 | 12.55…19 | 10.85…22.97 | within target |
| average | 5 | 2 / 8 | 21.02 | 17.75…24.3 | 17.75…24.3 | miss |
| average | 6 | 2 / 2 | 22.55 | 20.22…24.88 | 20.22…24.88 | miss |
| average | 7 | 2 / 2 | 20.62 | 15.73…25.5 | 15.73…25.5 | miss |
| average | 8 | 2 / 2 | 24.73 | 23.22…26.23 | 23.22…26.23 | miss |
| average | 9 | 2 / 2 | 27.56 | 27.32…27.8 | 27.32…27.8 | miss |
| average | 10 | 1 / 2 | 20.92 | 20.92…20.92 | 20.92…20.92 | miss |
| average | 11 | 0 / 1 | not measured | not measured | not measured | not measured |
| expert | 1 | 10 / 10 | 16.62 | 15.23…22.77 | 10.22…35.48 | — |
| expert | 2 | 10 / 10 | 14.16 | 12.08…18.78 | 10.02…20.55 | — |
| expert | 3 | 10 / 10 | 17.92 | 13.27…24 | 6.43…32.37 | — |
| expert | 4 | 10 / 10 | 20.18 | 11.47…29.78 | 7.55…30.67 | — |
| expert | 5 | 9 / 10 | 28.72 | 26.47…32.1 | 13.92…32.37 | — |
| expert | 6 | 9 / 9 | 21.88 | 19.22…23.22 | 12.93…34.72 | — |
| expert | 7 | 9 / 9 | 18.4 | 13.17…23.3 | 8.53…33.73 | — |
| expert | 8 | 8 / 9 | 21.63 | 17.9…29.17 | 10.87…30.15 | — |
| expert | 9 | 2 / 8 | 35.69 | 35.27…36.12 | 35.27…36.12 | — |
| expert | 10 | 0 / 2 | not measured | not measured | not measured | — |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 10 | 10 | 0 | 0 | 0 | 3 × 1, 4 × 1, 5 × 8 | stomp × 8, riot_cop × 2 | 0 |
| average | 10 | 10 | 0 | 0 | 0 | 3 × 2, 5 × 6, 10 × 1, 11 × 1 | stomp × 6, rocket × 2, sentry_turret × 1, shield_robot × 1 | 0 |
| expert | 10 | 10 | 0 | 0 | 0 | 5 × 1, 8 × 1, 9 × 6, 10 × 2 | shield_robot × 3, rocket × 2, sentry_turret × 2, stomp × 1, swat × 1, war_cannon × 1 | 0 |

## Timeouts

Runs that reached the wave time limit.

| Outcome | novice | average | expert |
| --- | --- | --- | --- |
| timeout | 0 | 0 | 0 |

## Survival by wave band

Each wave contributes once to each available median. Damage/s needs a timed wave. Repair/s is the configured rate when repair is active. HP coverage counts waves sampled by the bot. Repaired HP sums positive HP steps. The share undone uses waves with positive damage. Multipliers include stat cards taken before the wave.

| Profile | Waves | HP rows / observed | Damage | Damage/s | Repair/s | Minimum HP (% of capacity) | Repaired HP | Damage undone (%) | Guard deflects | Cover ticks | Rolls | damage × | guard_meter × | hp_max × | regen × | speed × |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1–10 | 47 / 47 | 20.4 | 1.03 | 10 | 68.03 | 0 | 0 | 6 | 0 | 2 | 1 | 1 | 1 | 1 | 1 |
| novice | 11–20 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| novice | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| novice | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 1–10 | 56 / 56 | 19.2 | 1.03 | 10 | 71.66 | 0 | 0 | 6 | 1 | 3 | 1.1 | 1 | 1 | 1 | 1 |
| average | 11–20 | 1 / 1 | 100.85 | not measured | 11 | 0 | 0 | 0 | 2 | 0 | 4 | 1.1 | 1.1 | 1.1 | 1.1 | 1 |
| average | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 1–10 | 87 / 87 | 19.94 | 0.97 | 10 | 80.37 | 0 | 0 | 6 | 16 | 4 | 1.1 | 1 | 1 | 1 | 1 |
| expert | 11–20 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 0 | — | 57.19% | 19.01 (86) | 15.4 (75) |
| patrol_cop | 0 | — | 92.51% | 16.42 (151) | 20.43 (10) |
| riot_cop | 2 | — | 54.34% | 19 (83) | 15.44 (78) |
| robot_gunner | 0 | — | 21.99% | 23.22 (29) | 16.08 (132) |
| robot_thug | 0 | — | 20.26% | 21.42 (28) | 16.25 (133) |
| rocket_trooper | 4 | rocket × 4 | 56.73% | 18.93 (86) | 15.4 (75) |
| sentry_turret | 3 | — | 19.96% | 23.22 (26) | 16.03 (135) |
| shield_robot | 4 | — | 2.79% | 27.32 (3) | 16.69 (158) |
| swat | 1 | — | 50.39% | 18.71 (78) | 15.45 (83) |
| war_machine | 16 | stomp × 15, war_cannon × 1 | 10.16% | 26.76 (12) | 16.32 (149) |

## Moves

Uses count recorded activations by profile and wave number. The game omits zero counts. Times are medians in seconds, with timed wave counts in parentheses. Carry applies to all waves.

| Profile | Wave | Move | Enemy | Recorded uses | Observed waves | Uses per wave | With enemy s (n) | Without enemy s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | All | ohm_short_circuit | sentry_turret | 0 | 47 | 0 | — | 15.4 (37) |
| novice | All | tonnage_armour_crack | war_machine | 2 | 47 | 0.04 | — | 15.4 (37) |
| novice | All | kerf_blink_behind | shield_robot | 0 | 47 | 0 | — | 15.4 (37) |
| novice | All | overkill_carry | all waves | 0 | 47 | 0 | 15.4 (37) | — |
| novice | 1 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 14.64 (10) |
| novice | 1 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 14.64 (10) |
| novice | 1 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 14.64 (10) |
| novice | 1 | overkill_carry | all waves | 0 | 10 | 0 | 14.64 (10) | — |
| novice | 2 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 14.61 (10) |
| novice | 2 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 14.61 (10) |
| novice | 2 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 14.61 (10) |
| novice | 2 | overkill_carry | all waves | 0 | 10 | 0 | 14.61 (10) | — |
| novice | 3 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 18.85 (9) |
| novice | 3 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 18.85 (9) |
| novice | 3 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 18.85 (9) |
| novice | 3 | overkill_carry | all waves | 0 | 10 | 0 | 18.85 (9) | — |
| novice | 4 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | — | 16.37 (8) |
| novice | 4 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 16.37 (8) |
| novice | 4 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 16.37 (8) |
| novice | 4 | overkill_carry | all waves | 0 | 9 | 0 | 16.37 (8) | — |
| novice | 5 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | — | — |
| novice | 5 | tonnage_armour_crack | war_machine | 2 | 8 | 0.25 | — | — |
| novice | 5 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | — | — |
| novice | 5 | overkill_carry | all waves | 0 | 8 | 0 | — | — |
| average | All | ohm_short_circuit | sentry_turret | 14 | 57 | 0.25 | 25.87 (6) | 15.42 (41) |
| average | All | tonnage_armour_crack | war_machine | 6 | 57 | 0.11 | 20.92 (3) | 15.88 (44) |
| average | All | kerf_blink_behind | shield_robot | 0 | 57 | 0 | 24.12 (2) | 16.03 (45) |
| average | All | overkill_carry | all waves | 0 | 57 | 0 | 16.65 (47) | — |
| average | 1 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 14.06 (10) |
| average | 1 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 14.06 (10) |
| average | 1 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 14.06 (10) |
| average | 1 | overkill_carry | all waves | 0 | 10 | 0 | 14.06 (10) | — |
| average | 2 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 15.04 (10) |
| average | 2 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 15.04 (10) |
| average | 2 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 15.04 (10) |
| average | 2 | overkill_carry | all waves | 0 | 10 | 0 | 15.04 (10) | — |
| average | 3 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 16.34 (8) |
| average | 3 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 16.34 (8) |
| average | 3 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 16.34 (8) |
| average | 3 | overkill_carry | all waves | 0 | 10 | 0 | 16.34 (8) | — |
| average | 4 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | — | 15.77 (8) |
| average | 4 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 15.77 (8) |
| average | 4 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | — | 15.77 (8) |
| average | 4 | overkill_carry | all waves | 0 | 8 | 0 | 15.77 (8) | — |
| average | 5 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | — | 21.02 (2) |
| average | 5 | tonnage_armour_crack | war_machine | 2 | 8 | 0.25 | 21.02 (2) | — |
| average | 5 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | — | 21.02 (2) |
| average | 5 | overkill_carry | all waves | 0 | 8 | 0 | 21.02 (2) | — |
| average | 6 | ohm_short_circuit | sentry_turret | 3 | 2 | 1.5 | 24.88 (1) | 20.22 (1) |
| average | 6 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 22.55 (2) |
| average | 6 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 22.55 (2) |
| average | 6 | overkill_carry | all waves | 0 | 2 | 0 | 22.55 (2) | — |
| average | 7 | ohm_short_circuit | sentry_turret | 2 | 2 | 1 | 25.5 (1) | 15.73 (1) |
| average | 7 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 20.62 (2) |
| average | 7 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 20.62 (2) |
| average | 7 | overkill_carry | all waves | 0 | 2 | 0 | 20.62 (2) | — |
| average | 8 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | 24.73 (2) | — |
| average | 8 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 24.73 (2) |
| average | 8 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 24.73 (2) |
| average | 8 | overkill_carry | all waves | 0 | 2 | 0 | 24.73 (2) | — |
| average | 9 | ohm_short_circuit | sentry_turret | 4 | 2 | 2 | 27.56 (2) | — |
| average | 9 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 27.56 (2) |
| average | 9 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | 27.32 (1) | 27.8 (1) |
| average | 9 | overkill_carry | all waves | 0 | 2 | 0 | 27.56 (2) | — |
| average | 10 | ohm_short_circuit | sentry_turret | 2 | 2 | 1 | — | 20.92 (1) |
| average | 10 | tonnage_armour_crack | war_machine | 4 | 2 | 2 | 20.92 (1) | — |
| average | 10 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | 20.92 (1) | — |
| average | 10 | overkill_carry | all waves | 0 | 2 | 0 | 20.92 (1) | — |
| average | 11 | ohm_short_circuit | sentry_turret | 2 | 1 | 2 | — | — |
| average | 11 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | — |
| average | 11 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | — |
| average | 11 | overkill_carry | all waves | 0 | 1 | 0 | — | — |
| expert | All | ohm_short_circuit | sentry_turret | 22 | 87 | 0.25 | 21.42 (20) | 18.67 (57) |
| expert | All | tonnage_armour_crack | war_machine | 11 | 87 | 0.13 | 28.72 (9) | 18.9 (68) |
| expert | All | kerf_blink_behind | shield_robot | 0 | 87 | 0 | 35.27 (1) | 19.49 (76) |
| expert | All | overkill_carry | all waves | 0 | 87 | 0 | 19.77 (77) | — |
| expert | 1 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 16.62 (10) |
| expert | 1 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 16.62 (10) |
| expert | 1 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 16.62 (10) |
| expert | 1 | overkill_carry | all waves | 0 | 10 | 0 | 16.62 (10) | — |
| expert | 2 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 14.16 (10) |
| expert | 2 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 14.16 (10) |
| expert | 2 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 14.16 (10) |
| expert | 2 | overkill_carry | all waves | 0 | 10 | 0 | 14.16 (10) | — |
| expert | 3 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 17.92 (10) |
| expert | 3 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 17.92 (10) |
| expert | 3 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 17.92 (10) |
| expert | 3 | overkill_carry | all waves | 0 | 10 | 0 | 17.92 (10) | — |
| expert | 4 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 20.18 (10) |
| expert | 4 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 20.18 (10) |
| expert | 4 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 20.18 (10) |
| expert | 4 | overkill_carry | all waves | 0 | 10 | 0 | 20.18 (10) | — |
| expert | 5 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 28.72 (9) |
| expert | 5 | tonnage_armour_crack | war_machine | 10 | 10 | 1 | 28.72 (9) | — |
| expert | 5 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 28.72 (9) |
| expert | 5 | overkill_carry | all waves | 0 | 10 | 0 | 28.72 (9) | — |
| expert | 6 | ohm_short_circuit | sentry_turret | 3 | 9 | 0.33 | 21.11 (6) | 21.95 (3) |
| expert | 6 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 21.88 (9) |
| expert | 6 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 21.88 (9) |
| expert | 6 | overkill_carry | all waves | 0 | 9 | 0 | 21.88 (9) | — |
| expert | 7 | ohm_short_circuit | sentry_turret | 2 | 9 | 0.22 | 19.77 (5) | 12.12 (4) |
| expert | 7 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 18.4 (9) |
| expert | 7 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 18.4 (9) |
| expert | 7 | overkill_carry | all waves | 0 | 9 | 0 | 18.4 (9) | — |
| expert | 8 | ohm_short_circuit | sentry_turret | 8 | 9 | 0.89 | 21.63 (8) | — |
| expert | 8 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 21.63 (8) |
| expert | 8 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 21.63 (8) |
| expert | 8 | overkill_carry | all waves | 0 | 9 | 0 | 21.63 (8) | — |
| expert | 9 | ohm_short_circuit | sentry_turret | 5 | 8 | 0.63 | 36.12 (1) | 35.27 (1) |
| expert | 9 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 35.69 (2) |
| expert | 9 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | 35.27 (1) | 36.12 (1) |
| expert | 9 | overkill_carry | all waves | 0 | 8 | 0 | 35.69 (2) | — |
| expert | 10 | ohm_short_circuit | sentry_turret | 4 | 2 | 2 | — | — |
| expert | 10 | tonnage_armour_crack | war_machine | 1 | 2 | 0.5 | — | — |
| expert | 10 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | — |
| expert | 10 | overkill_carry | all waves | 0 | 2 | 0 | — | — |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| effect_overkill_carry | waves survived | not measured | 3 (13) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| effect_overkill_carry | wave s | not measured | 15.68 (12) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| ghost_dent | waves survived | 0.5 (4) | 0 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_dent | wave s | 27.56 (2) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_kerf | waves survived | 2 (12) | 2 (3) | 1 | 0 | not measured | not measured (2, all offered) | too few pairs |
| ghost_kerf | wave s | 18.85 (9) | 19.69 (2) | 1 | 3.58 | not measured | not measured (2, all offered) | too few pairs |
| ghost_ohm | waves survived | 2 (10) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| ghost_ohm | wave s | 19.52 (7) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| ghost_tonnage | waves survived | 3 (14) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| ghost_tonnage | wave s | 18.44 (14) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| master_ohm | waves survived | 2 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| master_ohm | wave s | 29.32 (2) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| master_tonnage | waves survived | 1.5 (10) | 0 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| master_tonnage | wave s | 22.3 (7) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_10 | waves survived | 3 (23) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| stat_damage_10 | wave s | 19.39 (22) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| stat_damage_25 | waves survived | 1 (7) | 0 (1) | 1 | 1 | not measured | not measured (4, all offered) | too few pairs |
| stat_damage_25 | wave s | 16.67 (7) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 2 (13) | 3 (13) | 5 | -1 | -5…2 | not measured (5, all offered) | too few pairs |
| stat_guard_meter_10 | wave s | 20.28 (12) | 16.13 (11) | 3 | -4.31 | -7.01…-1.75 | not measured (3, all offered) | too few pairs |
| stat_guard_meter_25 | waves survived | 0 (4) | 1 (11) | 3 | -4 | -6…0 | 4 (6, all offered) | noise |
| stat_guard_meter_25 | wave s | not measured | 16.42 (7) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 3 (16) | 1 (7) | 0 | not measured | not measured | 2 (8, all offered) | insufficient data |
| stat_hp_max_10 | wave s | 17.83 (12) | 14.95 (5) | 0 | not measured | not measured | 17.05 (6, all offered) | insufficient data |
| stat_hp_max_25 | waves survived | not measured | 2 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_25 | wave s | not measured | 23.57 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_10 | waves survived | 2 (11) | 3 (9) | 2 | 1 | 0…2 | not measured (1, all offered) | too few pairs |
| stat_regen_10 | wave s | 19.88 (10) | 15.18 (8) | 1 | 4.97 | not measured | not measured (1, all offered) | too few pairs |
| stat_regen_25 | waves survived | 0 (4) | 2 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | wave s | 22.76 (1) | 19.86 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | waves survived | 2 (13) | 2.5 (8) | 6 | 0.5 | -1…2 | not measured (3, all offered) | too few pairs |
| stat_speed_10 | wave s | 16.92 (11) | 26.18 (6) | 4 | -6.86 | -15.28…2.03 | not measured (1, all offered) | too few pairs |
| stat_speed_25 | waves survived | not measured | 1 (7) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_25 | wave s | not measured | 14.9 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_chainsaw | waves survived | 0 (2) | 1.5 (6) | 1 | 0 | not measured | not measured (1, all offered) | too few pairs |
| weapon_chainsaw | wave s | not measured | 20.22 (5) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_electro_baton | waves survived | 6 (3) | 2 (14) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | wave s | 24.59 (3) | 20.18 (12) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | waves survived | not measured | 1.5 (8) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | wave s | not measured | 23.44 (8) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gatling | waves survived | 2 (1) | 2 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gatling | wave s | 28.11 (1) | 18.46 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gloria | waves survived | 3 (3) | 2 (16) | 1 | 0 | not measured | not measured (1, all offered) | too few pairs |
| weapon_gloria | wave s | 14.18 (3) | 16.62 (14) | 1 | -15.25 | not measured | not measured (1, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | not measured | 2 (13) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_hand_cannon | wave s | not measured | 24.88 (9) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_katana | waves survived | not measured | 2 (19) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_katana | wave s | not measured | 19.99 (19) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_machine_pistol | waves survived | not measured | 2.5 (18) | 0 | not measured | not measured | 5 (6, decliners) | insufficient data |
| weapon_machine_pistol | wave s | not measured | 19.7 (16) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| weapon_pistol | waves survived | 4.5 (4) | 2 (11) | 4 | 2 | -1…6 | not measured (5, all offered) | too few pairs |
| weapon_pistol | wave s | 16.18 (4) | 16.92 (9) | 4 | -3.68 | -13.09…3.95 | not measured (5, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | not measured | 1 (15) | 0 | not measured | not measured | 1 (6, decliners) | insufficient data |
| weapon_plasma_rifle | wave s | not measured | 19.95 (13) | 0 | not measured | not measured | 15.29 (6, decliners) | insufficient data |
| weapon_plasma_sword | waves survived | 1 (1) | 1.5 (8) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_plasma_sword | wave s | 10.87 (1) | 24.71 (4) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_rocket_launcher | waves survived | 1 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_rocket_launcher | wave s | 27.8 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | 0 (2) | 1.5 (6) | 1 | 0 | not measured | not measured (1, all offered) | too few pairs |
| chainsaw | wave s | not measured | 20.22 (5) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| electro_baton | waves survived | 6 (3) | 2 (14) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | wave s | 24.59 (3) | 20.18 (12) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | waves survived | not measured | 1.5 (8) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | wave s | not measured | 23.44 (8) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gatling | waves survived | 2 (1) | 2 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gatling | wave s | 28.11 (1) | 18.46 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gloria | waves survived | 3 (3) | 2 (16) | 1 | 0 | not measured | not measured (1, all offered) | too few pairs |
| gloria | wave s | 14.18 (3) | 16.62 (14) | 1 | -15.25 | not measured | not measured (1, all offered) | too few pairs |
| hand_cannon | waves survived | not measured | 2 (13) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| hand_cannon | wave s | not measured | 24.88 (9) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| katana | waves survived | not measured | 2 (19) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| katana | wave s | not measured | 19.99 (19) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| machine_pistol | waves survived | not measured | 2.5 (18) | 0 | not measured | not measured | 5 (6, decliners) | insufficient data |
| machine_pistol | wave s | not measured | 19.7 (16) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| pistol | waves survived | 4.5 (4) | 2 (11) | 4 | 2 | -1…6 | not measured (5, all offered) | too few pairs |
| pistol | wave s | 16.18 (4) | 16.92 (9) | 4 | -3.68 | -13.09…3.95 | not measured (5, all offered) | too few pairs |
| plasma_rifle | waves survived | not measured | 1 (15) | 0 | not measured | not measured | 1 (6, decliners) | insufficient data |
| plasma_rifle | wave s | not measured | 19.95 (13) | 0 | not measured | not measured | 15.29 (6, decliners) | insufficient data |
| plasma_sword | waves survived | 1 (1) | 1.5 (8) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| plasma_sword | wave s | 10.87 (1) | 24.71 (4) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| rocket_launcher | waves survived | 1 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| rocket_launcher | wave s | 27.8 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | ohm s (n) | rivet s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 9 (10) | 3 (10) | 0 (10) | 13 (10) | not measured | 14.64 (10) | not measured |
| novice | 2 | 9.5 (10) | 2 (10) | 0 (10) | 14 (10) | not measured | 14.61 (10) | not measured |
| novice | 3 | 5 (10) | 2 (10) | 0 (10) | 14.5 (10) | not measured | 16.96 (10) | not measured |
| novice | 4 | 5 (9) | 2 (9) | 0 (9) | 14 (9) | not measured | 16.42 (9) | 4.65 (1) |
| novice | 5 | 2 (8) | 2 (8) | 0 (8) | 11 (8) | not measured | 8.33 (8) | 7.1 (1) |
| average | 1 | 8.5 (10) | 3 (10) | 0 (10) | 13 (10) | not measured | 14.05 (10) | not measured |
| average | 2 | 9.5 (10) | 1.5 (10) | 0 (10) | 14 (10) | not measured | 15.04 (10) | not measured |
| average | 3 | 8 (10) | 3.5 (10) | 0 (10) | 13 (10) | not measured | 16.34 (10) | not measured |
| average | 4 | 7 (8) | 2 (8) | 0 (8) | 15 (8) | not measured | 15.77 (8) | not measured |
| average | 5 | 2 (8) | 3.5 (8) | 0 (8) | 12.5 (8) | not measured | 16.31 (8) | 1.13 (2) |
| average | 6 | 6 (2) | 0.5 (2) | 24.5 (2) | 33.5 (2) | not measured | 22.55 (2) | 0.02 (1) |
| average | 7 | 5 (2) | 4 (2) | 21.5 (2) | 29.5 (2) | not measured | 17.06 (2) | 7.1 (1) |
| average | 8 | 2.5 (2) | 4.5 (2) | 22 (2) | 37 (2) | not measured | 21.18 (2) | 7.1 (1) |
| average | 9 | 3.5 (2) | 3.5 (2) | 23 (2) | 39.5 (2) | 0.02 (1) | 24 (2) | 7.1 (1) |
| average | 10 | 1.5 (2) | 1.5 (2) | 15 (2) | 27.5 (2) | 0.02 (1) | 15.57 (2) | 0.57 (1) |
| average | 11 | 2 (1) | 4 (1) | 29 (1) | 42 (1) | 0.03 (1) | 18.27 (1) | not measured |
| expert | 1 | 10.5 (10) | 4 (10) | 0 (10) | 13 (10) | not measured | 16.62 (10) | not measured |
| expert | 2 | 7.5 (10) | 3 (10) | 0 (10) | 14 (10) | not measured | 14.16 (10) | not measured |
| expert | 3 | 8 (10) | 5 (10) | 0 (10) | 15 (10) | not measured | 17.92 (10) | not measured |
| expert | 4 | 8 (10) | 8 (10) | 0 (10) | 15 (10) | not measured | 20.19 (10) | not measured |
| expert | 5 | 1 (10) | 6 (10) | 0 (10) | 21.5 (10) | not measured | 24.42 (10) | 6.35 (3) |
| expert | 6 | 5 (9) | 4 (9) | 0 (9) | 28 (9) | not measured | 21.88 (9) | 7.1 (1) |
| expert | 7 | 5 (9) | 4 (9) | 0 (9) | 27 (9) | not measured | 18.4 (9) | 7.1 (2) |
| expert | 8 | 4 (9) | 8 (9) | 0 (9) | 34 (9) | 0.07 (1) | 17.9 (9) | 7.1 (4) |
| expert | 9 | 4.5 (8) | 2.5 (8) | 7 (8) | 26 (8) | 0.02 (1) | 14.7 (8) | 7.1 (5) |
| expert | 10 | 0.5 (2) | 1 (2) | 19 (2) | 27 (2) | 1.77 (1) | 18.25 (2) | 0.39 (2) |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 2 | 5 | 2.21 | ghost_tonnage → ghost_ohm → master_tonnage → weapon_chainsaw | chainsaw | rivet | node tools/dev/run.mjs gauntlet --seed=2 --bot=novice --pick=greedy --bot-salt=1 --controls=wheel --waves=40 |
| novice | 3 | 5 | 2.21 | stat_hp_max_10 → weapon_pistol → stat_damage_10 → stat_guard_meter_10 | pistol | rivet | node tools/dev/run.mjs gauntlet --seed=3 --bot=novice --pick=greedy --bot-salt=1 --controls=wheel --waves=40 |
| novice | 8 | 5 | 2.21 | stat_hp_max_10 → ghost_tonnage → weapon_electro_baton → stat_regen_10 | electro_baton | rivet | node tools/dev/run.mjs gauntlet --seed=8 --bot=novice --pick=greedy --bot-salt=1 --controls=wheel --waves=40 |
| average | 3 | 11 | 2.21 | stat_hp_max_10 → weapon_pistol → stat_damage_10 → stat_guard_meter_10 → stat_regen_10 → ghost_tonnage → weapon_gloria → ghost_ohm → weapon_rocket_launcher → master_ohm | gloria, pistol, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=3 --bot=average --pick=greedy --bot-salt=1 --controls=wheel --waves=40 |
| expert | 1 | 10 | 2.21 | ghost_tonnage → stat_hp_max_10 → master_tonnage → stat_guard_meter_10 → stat_regen_10 → stat_damage_10 → weapon_gatling → stat_damage_25 → ghost_ohm | gatling | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=expert --pick=greedy --bot-salt=1 --controls=wheel --waves=40 |
| expert | 8 | 10 | 2.21 | stat_hp_max_10 → ghost_tonnage → weapon_electro_baton → master_tonnage → ghost_ohm → stat_damage_10 → master_ohm → weapon_rocket_launcher → ghost_kerf | electro_baton, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=8 --bot=expert --pick=greedy --bot-salt=1 --controls=wheel --waves=40 |
