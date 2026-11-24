# Gauntlet run report

30 of 30 runs accepted. Average-profile waves 5 (23.38 s), 6 (21.4 s), 8 (23.32 s), 9 (27.32 s), 10 (20.92 s) fell outside 12–18 s for ordinary waves and 25–30 s for boss waves.

Live gauntlet batch · n28-combat @ 22033e2fea54 (dirty) · 2026-11-24T19:20:55.038Z.

Stalled runs by profile: novice 0, average 0, expert 0.

Capped alive by profile: novice 0, average 0, expert 0.

## Death-wave score

Censored runs contribute their last reached wave as a lower bound to the median and spread.

| Profile | Target | Median wave | P25–P75 | Min–max | Deaths / censored |
| --- | --- | --- | --- | --- | --- |
| novice | 6 | 5 | 5–5 | 3–5 | 10 / 0 |
| average | 12 | 5 | 5–5 | 3–11 | 10 / 0 |
| expert | 20 | 9 | 6–11 | 5–13 | 10 / 0 |

## Profile separation

Targets require a median gap of 3 waves and a later death on at least 75% of shared seeds with the same controls and pick policy. Unresolved censored pairs stay in the denominator.

| Profiles | Observed median gap | Later / shared seeds | Confirmed later share | Unresolved | Verdict |
| --- | --- | --- | --- | --- | --- |
| novice → average | 0 | 3 / 10 | 30% | 0 | below target |
| novice → expert | 4 | 8 / 10 | 80% | 0 | separated |
| average → expert | 4 | 6 / 10 | 60% | 0 | below target |

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
| average | 8 | died on 9 | 0 | 1 |
| average | 9 | died on 3 | 0 | 1 |
| average | 10 | died on 5 | 0 | 1 |
| expert | 1 | died on 13 | 0 | 1 |
| expert | 2 | died on 5 | 0 | 1 |
| expert | 3 | died on 9 | 0 | 1 |
| expert | 4 | died on 5 | 0 | 1 |
| expert | 5 | died on 9 | 0 | 1 |
| expert | 6 | died on 11 | 0 | 1 |
| expert | 7 | died on 8 | 0 | 1 |
| expert | 8 | died on 6 | 0 | 1 |
| expert | 9 | died on 12 | 0 | 1 |
| expert | 10 | died on 9 | 0 | 1 |

## Wave time

Seconds per observed wave. The target is 15 s ±20% for ordinary average-profile waves. Every 5th wave targets 25–30 s. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Median s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 10 / 10 | 14.64 | 13.77…15.47 | 12.83…15.67 | — |
| novice | 2 | 10 / 10 | 14.61 | 13.9…17.25 | 11.27…23.05 | — |
| novice | 3 | 9 / 10 | 18.85 | 14.3…19.93 | 12.53…27.77 | — |
| novice | 4 | 8 / 9 | 17.78 | 16.32…22.37 | 14.95…23.57 | — |
| novice | 5 | 0 / 8 | not measured | not measured | not measured | — |
| average | 1 | 10 / 10 | 14.06 | 12.3…19.75 | 10.78…24.87 | within target |
| average | 2 | 10 / 10 | 15.04 | 11.93…17.93 | 8.43…20.3 | within target |
| average | 3 | 8 / 10 | 16.34 | 12.42…17.52 | 7.52…25.12 | within target |
| average | 4 | 8 / 8 | 15.77 | 12.55…19 | 10.85…22.97 | within target |
| average | 5 | 2 / 8 | 23.38 | 17.75…29 | 17.75…29 | miss |
| average | 6 | 2 / 2 | 21.4 | 20.22…22.58 | 20.22…22.58 | miss |
| average | 7 | 2 / 2 | 16.87 | 15.73…18 | 15.73…18 | within target |
| average | 8 | 2 / 2 | 23.32 | 20.42…26.23 | 20.42…26.23 | miss |
| average | 9 | 1 / 2 | 27.32 | 27.32…27.32 | 27.32…27.32 | miss |
| average | 10 | 1 / 1 | 20.92 | 20.92…20.92 | 20.92…20.92 | miss |
| average | 11 | 0 / 1 | not measured | not measured | not measured | not measured |
| expert | 1 | 10 / 10 | 16.62 | 15.23…22.77 | 10.22…35.48 | — |
| expert | 2 | 10 / 10 | 14.16 | 12.08…18.78 | 10.02…20.55 | — |
| expert | 3 | 10 / 10 | 17.92 | 14.18…24 | 6.43…32.37 | — |
| expert | 4 | 10 / 10 | 20.18 | 12.12…29.78 | 8.55…30.67 | — |
| expert | 5 | 8 / 10 | 31.88 | 29.32…36.33 | 17.13…38.1 | — |
| expert | 6 | 7 / 8 | 17.35 | 12.93…24.17 | 10.88…34.72 | — |
| expert | 7 | 7 / 7 | 21.77 | 14.75…27.42 | 8.53…28.57 | — |
| expert | 8 | 6 / 7 | 22.57 | 14.18…32.1 | 10.87…37.27 | — |
| expert | 9 | 3 / 6 | 37.85 | 34.92…38.02 | 34.92…38.02 | — |
| expert | 10 | 3 / 3 | 28.22 | 18.73…37.28 | 18.73…37.28 | — |
| expert | 11 | 2 / 3 | 29.61 | 24.32…34.9 | 24.32…34.9 | — |
| expert | 12 | 1 / 2 | 36.85 | 36.85…36.85 | 36.85…36.85 | — |
| expert | 13 | 0 / 1 | not measured | not measured | not measured | — |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 10 | 10 | 0 | 0 | 0 | 3 × 1, 4 × 1, 5 × 8 | stomp × 8, riot_cop × 2 | 0 |
| average | 10 | 10 | 0 | 0 | 0 | 3 × 2, 5 × 6, 9 × 1, 11 × 1 | stomp × 6, rocket × 3, sentry_turret × 1 | 0 |
| expert | 10 | 10 | 0 | 0 | 0 | 5 × 2, 6 × 1, 8 × 1, 9 × 3, 11 × 1, 12 × 1, 13 × 1 | shield_robot × 5, sentry_turret × 3, rocket × 1, stomp × 1 | 0 |

## Timeouts

Runs that reached the wave time limit.

| Outcome | novice | average | expert |
| --- | --- | --- | --- |
| timeout | 0 | 0 | 0 |

## Survival by wave band

Each wave contributes once to each available median. Damage/s needs a timed wave. Repair/s is the configured rate when repair is active. HP coverage counts waves sampled by the bot. Repaired HP sums positive HP steps. The share undone uses waves with positive damage. Multipliers include stat cards taken before the wave.

| Profile | Waves | HP rows / observed | Damage | Damage/s | Repair/s | Minimum HP (% of capacity) | Repaired HP | Damage undone (%) | Guard deflects | Cover ticks | Rolls | damage × | guard_meter × | hp_max × | regen × | speed × |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1–10 | 47 / 47 | 22.8 | 1.09 | 10 | 68.03 | 0 | 0 | 6 | 0 | 2 | 1 | 1 | 1 | 1 | 1 |
| novice | 11–20 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| novice | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| novice | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 1–10 | 55 / 55 | 19.2 | 0.99 | 10 | 72.76 | 0 | 0 | 7 | 0 | 3 | 1 | 1 | 1 | 1 | 1 |
| average | 11–20 | 1 / 1 | 100.85 | not measured | 11 | 0 | 0 | 0 | 0 | 0 | 0 | 1.1 | 1.1 | 1.1 | 1.1 | 1 |
| average | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 1–10 | 81 / 81 | 16.8 | 0.87 | 10 | 83.2 | 0 | 0 | 7 | 16 | 5 | 1.1 | 1 | 1.1 | 1 | 1 |
| expert | 11–20 | 6 / 6 | 69.44 | 0.75 | 11 | 37.4 | 0 | 0 | 9.5 | 52 | 12 | 1.375 | 1.2375 | 1.175 | 1.1 | 1.05 |
| expert | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 0 | — | 57.66% | 19.01 (86) | 15.41 (74) |
| patrol_cop | 0 | — | 90.41% | 16.68 (148) | 22.88 (12) |
| riot_cop | 2 | — | 53.54% | 19.08 (80) | 15.46 (80) |
| robot_gunner | 0 | — | 21.76% | 21.77 (29) | 16.32 (131) |
| robot_thug | 0 | — | 20.37% | 22.58 (27) | 16.42 (133) |
| rocket_trooper | 4 | rocket × 4 | 59.05% | 19.02 (87) | 15.4 (73) |
| sentry_turret | 4 | — | 18.54% | 23.38 (24) | 16.37 (136) |
| shield_robot | 5 | — | 10.09% | 34.91 (10) | 16.66 (150) |
| swat | 0 | — | 53.31% | 19.08 (80) | 15.44 (80) |
| war_machine | 15 | stomp × 15 | 12.89% | 29.16 (14) | 16.37 (146) |

## Moves

Uses count recorded activations by profile and wave number. The game omits zero counts. Times are medians in seconds, with timed wave counts in parentheses. Carry applies to all waves.

| Profile | Wave | Move | Enemy | Recorded uses | Observed waves | Uses per wave | With enemy s (n) | Without enemy s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | All | ohm_short_circuit | sentry_turret | 0 | 47 | 0 | — | 15.43 (37) |
| novice | All | tonnage_armour_crack | war_machine | 2 | 47 | 0.04 | — | 15.43 (37) |
| novice | All | kerf_blink_behind | shield_robot | 0 | 47 | 0 | — | 15.43 (37) |
| novice | All | overkill_carry | all waves | 0 | 47 | 0 | 15.43 (37) | — |
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
| novice | 4 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | — | 17.78 (8) |
| novice | 4 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 17.78 (8) |
| novice | 4 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 17.78 (8) |
| novice | 4 | overkill_carry | all waves | 0 | 9 | 0 | 17.78 (8) | — |
| novice | 5 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | — | — |
| novice | 5 | tonnage_armour_crack | war_machine | 2 | 8 | 0.25 | — | — |
| novice | 5 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | — | — |
| novice | 5 | overkill_carry | all waves | 0 | 8 | 0 | — | — |
| average | All | ohm_short_circuit | sentry_turret | 11 | 56 | 0.2 | 22.58 (5) | 15.42 (41) |
| average | All | tonnage_armour_crack | war_machine | 7 | 56 | 0.13 | 20.92 (3) | 15.73 (43) |
| average | All | kerf_blink_behind | shield_robot | 0 | 56 | 0 | 24.12 (2) | 15.88 (44) |
| average | All | overkill_carry | all waves | 0 | 56 | 0 | 16.34 (46) | — |
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
| average | 5 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | — | 23.38 (2) |
| average | 5 | tonnage_armour_crack | war_machine | 5 | 8 | 0.63 | 23.38 (2) | — |
| average | 5 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | — | 23.38 (2) |
| average | 5 | overkill_carry | all waves | 0 | 8 | 0 | 23.38 (2) | — |
| average | 6 | ohm_short_circuit | sentry_turret | 2 | 2 | 1 | 22.58 (1) | 20.22 (1) |
| average | 6 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 21.4 (2) |
| average | 6 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 21.4 (2) |
| average | 6 | overkill_carry | all waves | 0 | 2 | 0 | 21.4 (2) | — |
| average | 7 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | 18 (1) | 15.73 (1) |
| average | 7 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 16.87 (2) |
| average | 7 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 16.87 (2) |
| average | 7 | overkill_carry | all waves | 0 | 2 | 0 | 16.87 (2) | — |
| average | 8 | ohm_short_circuit | sentry_turret | 2 | 2 | 1 | 23.32 (2) | — |
| average | 8 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 23.32 (2) |
| average | 8 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 23.32 (2) |
| average | 8 | overkill_carry | all waves | 0 | 2 | 0 | 23.32 (2) | — |
| average | 9 | ohm_short_circuit | sentry_turret | 2 | 2 | 1 | 27.32 (1) | — |
| average | 9 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 27.32 (1) |
| average | 9 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | 27.32 (1) | — |
| average | 9 | overkill_carry | all waves | 0 | 2 | 0 | 27.32 (1) | — |
| average | 10 | ohm_short_circuit | sentry_turret | 2 | 1 | 2 | — | 20.92 (1) |
| average | 10 | tonnage_armour_crack | war_machine | 2 | 1 | 2 | 20.92 (1) | — |
| average | 10 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | 20.92 (1) | — |
| average | 10 | overkill_carry | all waves | 0 | 1 | 0 | 20.92 (1) | — |
| average | 11 | ohm_short_circuit | sentry_turret | 2 | 1 | 2 | — | — |
| average | 11 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | — |
| average | 11 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | — |
| average | 11 | overkill_carry | all waves | 0 | 1 | 0 | — | — |
| expert | All | ohm_short_circuit | sentry_turret | 9 | 87 | 0.1 | 24.17 (19) | 18.9 (58) |
| expert | All | tonnage_armour_crack | war_machine | 16 | 87 | 0.18 | 31.65 (11) | 18.9 (66) |
| expert | All | kerf_blink_behind | shield_robot | 0 | 87 | 0 | 35.88 (8) | 19.02 (69) |
| expert | All | overkill_carry | all waves | 0 | 87 | 0 | 20.03 (77) | — |
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
| expert | 5 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 31.88 (8) |
| expert | 5 | tonnage_armour_crack | war_machine | 13 | 10 | 1.3 | 31.88 (8) | — |
| expert | 5 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 31.88 (8) |
| expert | 5 | overkill_carry | all waves | 0 | 10 | 0 | 31.88 (8) | — |
| expert | 6 | ohm_short_circuit | sentry_turret | 2 | 8 | 0.25 | 17.69 (4) | 17.35 (3) |
| expert | 6 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 17.35 (7) |
| expert | 6 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | — | 17.35 (7) |
| expert | 6 | overkill_carry | all waves | 0 | 8 | 0 | 17.35 (7) | — |
| expert | 7 | ohm_short_circuit | sentry_turret | 1 | 7 | 0.14 | 20.77 (4) | 23.3 (3) |
| expert | 7 | tonnage_armour_crack | war_machine | 0 | 7 | 0 | — | 21.77 (7) |
| expert | 7 | kerf_blink_behind | shield_robot | 0 | 7 | 0 | — | 21.77 (7) |
| expert | 7 | overkill_carry | all waves | 0 | 7 | 0 | 21.77 (7) | — |
| expert | 8 | ohm_short_circuit | sentry_turret | 3 | 7 | 0.43 | 22.57 (6) | — |
| expert | 8 | tonnage_armour_crack | war_machine | 0 | 7 | 0 | — | 22.57 (6) |
| expert | 8 | kerf_blink_behind | shield_robot | 0 | 7 | 0 | — | 22.57 (6) |
| expert | 8 | overkill_carry | all waves | 0 | 7 | 0 | 22.57 (6) | — |
| expert | 9 | ohm_short_circuit | sentry_turret | 3 | 6 | 0.5 | 38.02 (1) | 36.38 (2) |
| expert | 9 | tonnage_armour_crack | war_machine | 0 | 6 | 0 | — | 37.85 (3) |
| expert | 9 | kerf_blink_behind | shield_robot | 0 | 6 | 0 | 37.85 (3) | — |
| expert | 9 | overkill_carry | all waves | 0 | 6 | 0 | 37.85 (3) | — |
| expert | 10 | ohm_short_circuit | sentry_turret | 0 | 3 | 0 | 28.22 (1) | 28.01 (2) |
| expert | 10 | tonnage_armour_crack | war_machine | 3 | 3 | 1 | 28.22 (3) | — |
| expert | 10 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | 28.01 (2) | 28.22 (1) |
| expert | 10 | overkill_carry | all waves | 0 | 3 | 0 | 28.22 (3) | — |
| expert | 11 | ohm_short_circuit | sentry_turret | 0 | 3 | 0 | 29.61 (2) | — |
| expert | 11 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 29.61 (2) |
| expert | 11 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | 29.61 (2) | — |
| expert | 11 | overkill_carry | all waves | 0 | 3 | 0 | 29.61 (2) | — |
| expert | 12 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 36.85 (1) | — |
| expert | 12 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 36.85 (1) |
| expert | 12 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | 36.85 (1) | — |
| expert | 12 | overkill_carry | all waves | 0 | 2 | 0 | 36.85 (1) | — |
| expert | 13 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | — | — |
| expert | 13 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | — |
| expert | 13 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | — |
| expert | 13 | overkill_carry | all waves | 0 | 1 | 0 | — | — |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| effect_overkill_carry | waves survived | not measured | 1 (14) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| effect_overkill_carry | wave s | not measured | 18.42 (12) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_dent | waves survived | 0 (7) | 0 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_dent | wave s | 31.65 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_kerf | waves survived | 3 (8) | 2.5 (6) | 3 | 0 | -4…2 | not measured (4, all offered) | too few pairs |
| ghost_kerf | wave s | 18.85 (7) | 20.82 (5) | 3 | 3.58 | -1.33…6.03 | not measured (3, all offered) | too few pairs |
| ghost_ohm | waves survived | 2 (9) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | wave s | 16.87 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_tonnage | waves survived | 3 (14) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| ghost_tonnage | wave s | 19.49 (14) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| master_ohm | waves survived | 0 (1) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| master_ohm | wave s | not measured | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| master_tonnage | waves survived | 4 (2) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| master_tonnage | wave s | 26.54 (2) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_10 | waves survived | 3 (21) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_10 | wave s | 18.52 (20) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_25 | waves survived | 1 (9) | 1.5 (2) | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| stat_damage_25 | wave s | 18.31 (8) | 20.42 (1) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 2 (13) | 3 (13) | 5 | 2 | -4…5 | 6 (6, all offered) | noise |
| stat_guard_meter_10 | wave s | 20.28 (12) | 16.65 (11) | 3 | 0.78 | -1.75…1.55 | not measured (4, all offered) | too few pairs |
| stat_guard_meter_25 | waves survived | 0 (5) | 2 (10) | 4 | -2 | -6…1 | 4 (6, all offered) | noise |
| stat_guard_meter_25 | wave s | 27.06 (2) | 18.49 (8) | 1 | 10.59 | not measured | not measured (2, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 2 (19) | 1 (6) | 0 | not measured | not measured | 3 (8, all offered) | insufficient data |
| stat_hp_max_10 | wave s | 17.83 (12) | 13.75 (4) | 0 | not measured | not measured | 10.8 (6, all offered) | insufficient data |
| stat_hp_max_25 | waves survived | 4 (2) | 3 (2) | 1 | 3 | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_25 | wave s | 32.35 (2) | 17.47 (2) | 1 | 16.06 | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_10 | waves survived | 2 (15) | 3 (5) | 2 | 1 | 0…2 | not measured (2, all offered) | too few pairs |
| stat_regen_10 | wave s | 20.92 (13) | 14.92 (4) | 1 | 4.97 | not measured | not measured (2, all offered) | too few pairs |
| stat_regen_25 | waves survived | 0 (4) | 2 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | wave s | 34.69 (1) | 19.86 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | waves survived | 2 (13) | 1.5 (10) | 9 | 0 | -1…2 | not measured (3, all offered) | too few pairs |
| stat_speed_10 | wave s | 16.92 (11) | 26.84 (5) | 4 | -6.86 | -15.77…2.03 | not measured (1, all offered) | too few pairs |
| stat_speed_25 | waves survived | 1 (1) | 1 (7) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_25 | wave s | 24.32 (1) | 14.9 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_chainsaw | waves survived | not measured | 1 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_chainsaw | wave s | not measured | 20.22 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | waves survived | 2 (3) | 2.5 (16) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | wave s | 20.42 (3) | 20.61 (14) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | waves survived | 7 (1) | 1.5 (6) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_flamethrower | wave s | 28.22 (1) | 19.21 (5) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_gatling | waves survived | 1 (4) | 2 (3) | 2 | 1 | -2…4 | not measured (1, all offered) | too few pairs |
| weapon_gatling | wave s | 26.54 (2) | 18.46 (2) | 1 | 18.75 | not measured | not measured (0, all offered) | too few pairs |
| weapon_gloria | waves survived | 2 (2) | 2 (17) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_gloria | wave s | 20.21 (2) | 16.92 (15) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | not measured | 1.5 (14) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_hand_cannon | wave s | not measured | 27.23 (10) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_katana | waves survived | 2 (1) | 2 (18) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_katana | wave s | 35.88 (1) | 19.96 (18) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_machine_pistol | waves survived | not measured | 2.5 (16) | 0 | not measured | not measured | 4 (6, decliners) | insufficient data |
| weapon_machine_pistol | wave s | not measured | 19.4 (15) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| weapon_pistol | waves survived | 4.5 (4) | 2 (12) | 3 | 4 | 0…6 | not measured (5, all offered) | too few pairs |
| weapon_pistol | wave s | 16.18 (4) | 16.92 (9) | 3 | -3.63 | -3.74…3.95 | not measured (5, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | not measured | 1.5 (14) | 0 | not measured | not measured | 2 (6, decliners) | insufficient data |
| weapon_plasma_rifle | wave s | not measured | 20.27 (14) | 0 | not measured | not measured | 16.12 (6, decliners) | insufficient data |
| weapon_plasma_sword | waves survived | 1 (1) | 1 (9) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_plasma_sword | wave s | 10.87 (1) | 29.32 (5) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_rocket_launcher | waves survived | 1.5 (4) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_rocket_launcher | wave s | 33.82 (4) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | not measured | 1 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| chainsaw | wave s | not measured | 20.22 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | waves survived | 2 (3) | 2.5 (16) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | wave s | 20.42 (3) | 20.61 (14) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | waves survived | 7 (1) | 1.5 (6) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| flamethrower | wave s | 28.22 (1) | 19.21 (5) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| gatling | waves survived | 1 (4) | 2 (3) | 2 | 1 | -2…4 | not measured (1, all offered) | too few pairs |
| gatling | wave s | 26.54 (2) | 18.46 (2) | 1 | 18.75 | not measured | not measured (0, all offered) | too few pairs |
| gloria | waves survived | 2 (2) | 2 (17) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| gloria | wave s | 20.21 (2) | 16.92 (15) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| hand_cannon | waves survived | not measured | 1.5 (14) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| hand_cannon | wave s | not measured | 27.23 (10) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| katana | waves survived | 2 (1) | 2 (18) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| katana | wave s | 35.88 (1) | 19.96 (18) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| machine_pistol | waves survived | not measured | 2.5 (16) | 0 | not measured | not measured | 4 (6, decliners) | insufficient data |
| machine_pistol | wave s | not measured | 19.4 (15) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| pistol | waves survived | 4.5 (4) | 2 (12) | 3 | 4 | 0…6 | not measured (5, all offered) | too few pairs |
| pistol | wave s | 16.18 (4) | 16.92 (9) | 3 | -3.63 | -3.74…3.95 | not measured (5, all offered) | too few pairs |
| plasma_rifle | waves survived | not measured | 1.5 (14) | 0 | not measured | not measured | 2 (6, decliners) | insufficient data |
| plasma_rifle | wave s | not measured | 20.27 (14) | 0 | not measured | not measured | 16.12 (6, decliners) | insufficient data |
| plasma_sword | waves survived | 1 (1) | 1 (9) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| plasma_sword | wave s | 10.87 (1) | 29.32 (5) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| rocket_launcher | waves survived | 1.5 (4) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| rocket_launcher | wave s | 33.82 (4) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | ohm s (n) | rivet s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 9 (10) | 3 (10) | 0 (10) | 13 (10) | not measured | 14.64 (10) | not measured |
| novice | 2 | 9.5 (10) | 2 (10) | 0 (10) | 14 (10) | not measured | 14.61 (10) | not measured |
| novice | 3 | 5 (10) | 2 (10) | 0 (10) | 14.5 (10) | not measured | 16.96 (10) | not measured |
| novice | 4 | 5 (9) | 1 (9) | 0 (9) | 14 (9) | not measured | 19.15 (9) | not measured |
| novice | 5 | 2 (8) | 2 (8) | 0 (8) | 12.5 (8) | not measured | 9.4 (8) | not measured |
| average | 1 | 8.5 (10) | 3 (10) | 0 (10) | 13 (10) | not measured | 14.05 (10) | not measured |
| average | 2 | 9.5 (10) | 1.5 (10) | 0 (10) | 14 (10) | not measured | 15.04 (10) | not measured |
| average | 3 | 8 (10) | 3.5 (10) | 0 (10) | 13 (10) | not measured | 16.34 (10) | not measured |
| average | 4 | 7 (8) | 2 (8) | 0 (8) | 15 (8) | not measured | 15.77 (8) | not measured |
| average | 5 | 2 (8) | 5 (8) | 0 (8) | 12.5 (8) | not measured | 16.31 (8) | not measured |
| average | 6 | 5 (2) | 0.5 (2) | 24.5 (2) | 38 (2) | not measured | 21.4 (2) | not measured |
| average | 7 | 8.5 (2) | 3.5 (2) | 21.5 (2) | 27.5 (2) | not measured | 16.87 (2) | not measured |
| average | 8 | 3.5 (2) | 6 (2) | 22 (2) | 37 (2) | not measured | 23.33 (2) | not measured |
| average | 9 | 7 (2) | 5.5 (2) | 20.5 (2) | 38.5 (2) | 0.03 (1) | 31.9 (2) | not measured |
| average | 10 | 0 (1) | 0 (1) | 28 (1) | 38 (1) | not measured | 20.92 (1) | not measured |
| average | 11 | 0 (1) | 0 (1) | 7 (1) | 14 (1) | not measured | 10.28 (1) | not measured |
| expert | 1 | 10.5 (10) | 4 (10) | 0 (10) | 13 (10) | not measured | 16.62 (10) | not measured |
| expert | 2 | 7.5 (10) | 3 (10) | 0 (10) | 14 (10) | not measured | 14.16 (10) | not measured |
| expert | 3 | 7 (10) | 5 (10) | 0 (10) | 15 (10) | not measured | 17.92 (10) | not measured |
| expert | 4 | 8 (10) | 8 (10) | 0 (10) | 15 (10) | not measured | 20.19 (10) | not measured |
| expert | 5 | 1 (10) | 7 (10) | 0 (10) | 20 (10) | not measured | 30.48 (10) | not measured |
| expert | 6 | 5 (8) | 3 (8) | 0 (8) | 28 (8) | not measured | 18.84 (8) | not measured |
| expert | 7 | 6 (7) | 7 (7) | 0 (7) | 29 (7) | not measured | 19.77 (7) | 4.13 (1) |
| expert | 8 | 4 (7) | 5 (7) | 5 (7) | 34 (7) | not measured | 25.13 (7) | not measured |
| expert | 9 | 6 (6) | 5 (6) | 7.5 (6) | 37.5 (6) | not measured | 21.71 (6) | 7.1 (1) |
| expert | 10 | 2 (3) | 6 (3) | 127 (3) | 114 (3) | not measured | 21.12 (3) | 7.1 (1) |
| expert | 11 | 6 (3) | 10 (3) | 26 (3) | 55 (3) | not measured | 23.17 (3) | 7.1 (2) |
| expert | 12 | 12 (2) | 15.5 (2) | 102 (2) | 1173.5 (2) | not measured | 23.59 (2) | 7.1 (2) |
| expert | 13 | 11 (1) | 0 (1) | 105 (1) | 2310 (1) | not measured | 14.88 (1) | 7.1 (1) |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 3 | 5 | 2.21 | stat_hp_max_10 → weapon_pistol → stat_damage_10 → stat_guard_meter_10 | pistol | rivet | node tools/dev/run.mjs gauntlet --seed=3 --bot=novice --pick=greedy --bot-salt=1 --controls=wheel --waves=40 |
| novice | 8 | 5 | 2.21 | stat_hp_max_10 → ghost_tonnage → weapon_electro_baton → stat_regen_10 | electro_baton | rivet | node tools/dev/run.mjs gauntlet --seed=8 --bot=novice --pick=greedy --bot-salt=1 --controls=wheel --waves=40 |
| novice | 1 | 5 | 1.21 | ghost_tonnage → stat_hp_max_10 → stat_damage_10 → ghost_dent | none | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=novice --pick=greedy --bot-salt=1 --controls=wheel --waves=40 |
| average | 3 | 11 | 2.21 | stat_hp_max_10 → weapon_pistol → stat_damage_10 → stat_guard_meter_10 → stat_regen_10 → ghost_tonnage → weapon_gloria → ghost_ohm → weapon_rocket_launcher → ghost_dent | gloria, pistol, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=3 --bot=average --pick=greedy --bot-salt=1 --controls=wheel --waves=40 |
| expert | 1 | 13 | 2.21 | ghost_tonnage → stat_hp_max_10 → stat_damage_10 → ghost_dent → weapon_flamethrower → master_tonnage → weapon_gatling → stat_guard_meter_10 → stat_guard_meter_25 → stat_damage_25 → weapon_katana → weapon_rocket_launcher → stat_regen_10 | flamethrower, gatling, katana, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=expert --pick=greedy --bot-salt=1 --controls=wheel --waves=40 |
