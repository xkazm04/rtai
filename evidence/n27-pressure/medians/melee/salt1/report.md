# Gauntlet run report

30 of 30 runs accepted. Average-profile waves 5 (23.14 s), 6 (20.97 s), 8 (25.5 s), 9 (29.8 s), 10 (31.73 s), 11 (38.13 s), 12 (60.98 s), 13 (37.5 s) fell outside 12–18 s for ordinary waves and 25–30 s for boss waves.

Live gauntlet batch · detached @ 4a3ff4b0430b · 2026-11-24T04:15:07.860Z.

Stalled runs by profile: novice 0, average 0, expert 0.

Capped alive by profile: novice 0, average 0, expert 0.

## Death-wave score

Censored runs contribute their last reached wave as a lower bound to the median and spread.

| Profile | Target | Median wave | P25–P75 | Min–max | Deaths / censored |
| --- | --- | --- | --- | --- | --- |
| novice | 6 | 5 | 5–5 | 3–5 | 10 / 0 |
| average | 12 | 5 | 5–5 | 3–14 | 10 / 0 |
| expert | 20 | 9 | 8–9 | 5–11 | 10 / 0 |

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
| average | 8 | died on 14 | 1 | 1 |
| average | 9 | died on 3 | 0 | 1 |
| average | 10 | died on 5 | 0 | 1 |
| expert | 1 | died on 9 | 0 | 1 |
| expert | 2 | died on 5 | 0 | 1 |
| expert | 3 | died on 9 | 0 | 1 |
| expert | 4 | died on 5 | 0 | 1 |
| expert | 5 | died on 9 | 0 | 1 |
| expert | 6 | died on 10 | 0 | 1 |
| expert | 7 | died on 8 | 0 | 1 |
| expert | 8 | died on 11 | 0 | 1 |
| expert | 9 | died on 8 | 0 | 1 |
| expert | 10 | died on 9 | 0 | 1 |

## Wave time

Seconds per observed wave. The target is 15 s ±20% for ordinary average-profile waves. Every 5th wave targets 25–30 s. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Median s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 10 / 10 | 14.64 | 13.77…15.47 | 12.83…15.67 | — |
| novice | 2 | 10 / 10 | 14.61 | 13.9…17.25 | 11.27…23.05 | — |
| novice | 3 | 9 / 10 | 18.85 | 14.3…19.93 | 12.53…27.77 | — |
| novice | 4 | 8 / 9 | 17.78 | 16.32…22.37 | 14.95…24.32 | — |
| novice | 5 | 0 / 8 | not measured | not measured | not measured | — |
| average | 1 | 10 / 10 | 14.06 | 12.3…19.75 | 10.78…24.87 | within target |
| average | 2 | 10 / 10 | 15.04 | 11.93…17.93 | 8.43…20.3 | within target |
| average | 3 | 8 / 10 | 16.34 | 12.42…17.52 | 7.52…25.12 | within target |
| average | 4 | 8 / 8 | 15.77 | 12.55…19 | 10.85…22.97 | within target |
| average | 5 | 2 / 8 | 23.14 | 17.75…28.53 | 17.75…28.53 | miss |
| average | 6 | 2 / 2 | 20.97 | 20.22…21.72 | 20.22…21.72 | miss |
| average | 7 | 2 / 2 | 15.78 | 15.73…15.82 | 15.73…15.82 | within target |
| average | 8 | 2 / 2 | 25.5 | 24.77…26.23 | 24.77…26.23 | miss |
| average | 9 | 2 / 2 | 29.8 | 27.32…32.28 | 27.32…32.28 | miss |
| average | 10 | 2 / 2 | 31.73 | 20.92…42.55 | 20.92…42.55 | miss |
| average | 11 | 1 / 2 | 38.13 | 38.13…38.13 | 38.13…38.13 | miss |
| average | 12 | 1 / 1 | 60.98 | 60.98…60.98 | 60.98…60.98 | miss |
| average | 13 | 1 / 1 | 37.5 | 37.5…37.5 | 37.5…37.5 | miss |
| average | 14 | 0 / 1 | not measured | not measured | not measured | not measured |
| expert | 1 | 10 / 10 | 16.62 | 15.23…22.77 | 10.22…35.48 | — |
| expert | 2 | 10 / 10 | 14.16 | 12.08…18.78 | 10.02…20.55 | — |
| expert | 3 | 10 / 10 | 20.37 | 16.22…30.13 | 6.43…38 | — |
| expert | 4 | 10 / 10 | 20.18 | 15.13…29.78 | 8.55…30.67 | — |
| expert | 5 | 8 / 10 | 30.18 | 25…32.15 | 17.13…32.37 | — |
| expert | 6 | 8 / 8 | 21.22 | 17.03…24.17 | 12.93…34.72 | — |
| expert | 7 | 8 / 8 | 19.08 | 14.75…28.48 | 8.53…33.27 | — |
| expert | 8 | 6 / 8 | 19.23 | 14.18…20.72 | 10.87…27.5 | — |
| expert | 9 | 2 / 6 | 34.23 | 32.77…35.7 | 32.77…35.7 | — |
| expert | 10 | 1 / 2 | 27.85 | 27.85…27.85 | 27.85…27.85 | — |
| expert | 11 | 0 / 1 | not measured | not measured | not measured | — |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 10 | 10 | 0 | 0 | 0 | 3 × 1, 4 × 1, 5 × 8 | stomp × 8, riot_cop × 2 | 0 |
| average | 10 | 10 | 0 | 0 | 0 | 3 × 2, 5 × 6, 11 × 1, 14 × 1 | stomp × 6, rocket × 2, contractor × 1, sentry_turret × 1 | 0 |
| expert | 10 | 10 | 0 | 0 | 0 | 5 × 2, 8 × 2, 9 × 4, 10 × 1, 11 × 1 | shield_robot × 5, sentry_turret × 3, rocket × 1, stomp × 1 | 0 |

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
| average | 1–10 | 56 / 56 | 18.32 | 0.98 | 10 | 74.15 | 0 | 0 | 7 | 0 | 3 | 1 | 1 | 1 | 1 | 1 |
| average | 11–20 | 5 / 5 | 84.4 | 0.63 | 11 | 18.91 | 0 | 0 | 6 | 40 | 7 | 1.1 | 1.375 | 1.1 | 1.1 | 1 |
| average | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 1–10 | 82 / 82 | 17.4 | 0.91 | 10 | 82.65 | 0 | 0 | 6.5 | 16 | 4.5 | 1.1 | 1 | 1.05 | 1 | 1 |
| expert | 11–20 | 1 / 1 | 110 | not measured | 11 | 0 | 0 | 0 | 11 | 0 | 15 | 1 | 1.375 | 1.1 | 1.1 | 1 |
| expert | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 1 | — | 61.1% | 19.55 (89) | 15.33 (72) |
| patrol_cop | 0 | — | 91.21% | 16.98 (150) | 24 (11) |
| riot_cop | 2 | — | 54.37% | 19.15 (81) | 15.46 (80) |
| robot_gunner | 0 | — | 25.49% | 23.26 (32) | 16.32 (129) |
| robot_thug | 0 | — | 22.76% | 22.1 (29) | 16.53 (132) |
| rocket_trooper | 3 | rocket × 3 | 57.27% | 18.93 (86) | 15.43 (75) |
| sentry_turret | 4 | — | 23.07% | 23.69 (28) | 16.32 (133) |
| shield_robot | 5 | — | 9.2% | 35.13 (8) | 16.97 (153) |
| swat | 0 | — | 51.25% | 19.01 (78) | 15.55 (83) |
| war_machine | 15 | stomp × 15 | 11.41% | 28.53 (13) | 16.66 (148) |

## Moves

Uses count recorded activations by profile and wave number. The game omits zero counts. Times are medians in seconds, with timed wave counts in parentheses. Carry applies to all waves.

| Profile | Wave | Move | Enemy | Recorded uses | Observed waves | Uses per wave | With enemy s (n) | Without enemy s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | All | ohm_short_circuit | sentry_turret | 0 | 47 | 0 | — | 15.43 (37) |
| novice | All | tonnage_armour_crack | war_machine | 1 | 47 | 0.02 | — | 15.43 (37) |
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
| novice | 5 | tonnage_armour_crack | war_machine | 1 | 8 | 0.13 | — | — |
| novice | 5 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | — | — |
| novice | 5 | overkill_carry | all waves | 0 | 8 | 0 | — | — |
| average | All | ohm_short_circuit | sentry_turret | 7 | 61 | 0.11 | 29.8 (10) | 15.42 (41) |
| average | All | tonnage_armour_crack | war_machine | 7 | 61 | 0.11 | 24.73 (4) | 16.03 (47) |
| average | All | kerf_blink_behind | shield_robot | 0 | 61 | 0 | 37.82 (6) | 15.82 (45) |
| average | All | overkill_carry | all waves | 6 | 61 | 0.1 | 16.67 (51) | — |
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
| average | 5 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | — | 23.14 (2) |
| average | 5 | tonnage_armour_crack | war_machine | 4 | 8 | 0.5 | 23.14 (2) | — |
| average | 5 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | — | 23.14 (2) |
| average | 5 | overkill_carry | all waves | 0 | 8 | 0 | 23.14 (2) | — |
| average | 6 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 21.72 (1) | 20.22 (1) |
| average | 6 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 20.97 (2) |
| average | 6 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 20.97 (2) |
| average | 6 | overkill_carry | all waves | 0 | 2 | 0 | 20.97 (2) | — |
| average | 7 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 15.82 (1) | 15.73 (1) |
| average | 7 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 15.78 (2) |
| average | 7 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 15.78 (2) |
| average | 7 | overkill_carry | all waves | 0 | 2 | 0 | 15.78 (2) | — |
| average | 8 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 25.5 (2) | — |
| average | 8 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 25.5 (2) |
| average | 8 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 25.5 (2) |
| average | 8 | overkill_carry | all waves | 0 | 2 | 0 | 25.5 (2) | — |
| average | 9 | ohm_short_circuit | sentry_turret | 2 | 2 | 1 | 29.8 (2) | — |
| average | 9 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 29.8 (2) |
| average | 9 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | 27.32 (1) | 32.28 (1) |
| average | 9 | overkill_carry | all waves | 0 | 2 | 0 | 29.8 (2) | — |
| average | 10 | ohm_short_circuit | sentry_turret | 2 | 2 | 1 | 42.55 (1) | 20.92 (1) |
| average | 10 | tonnage_armour_crack | war_machine | 3 | 2 | 1.5 | 31.73 (2) | — |
| average | 10 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | 31.73 (2) | — |
| average | 10 | overkill_carry | all waves | 0 | 2 | 0 | 31.73 (2) | — |
| average | 11 | ohm_short_circuit | sentry_turret | 3 | 2 | 1.5 | 38.13 (1) | — |
| average | 11 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 38.13 (1) |
| average | 11 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | 38.13 (1) | — |
| average | 11 | overkill_carry | all waves | 0 | 2 | 0 | 38.13 (1) | — |
| average | 12 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | 60.98 (1) | — |
| average | 12 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 60.98 (1) |
| average | 12 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | 60.98 (1) | — |
| average | 12 | overkill_carry | all waves | 0 | 1 | 0 | 60.98 (1) | — |
| average | 13 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | 37.5 (1) | — |
| average | 13 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 37.5 (1) |
| average | 13 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | 37.5 (1) | — |
| average | 13 | overkill_carry | all waves | 0 | 1 | 0 | 37.5 (1) | — |
| average | 14 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | — | — |
| average | 14 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | — |
| average | 14 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | — |
| average | 14 | overkill_carry | all waves | 6 | 1 | 6 | — | — |
| expert | All | ohm_short_circuit | sentry_turret | 9 | 83 | 0.11 | 20.64 (18) | 18.78 (55) |
| expert | All | tonnage_armour_crack | war_machine | 11 | 83 | 0.13 | 28.72 (9) | 18.73 (64) |
| expert | All | kerf_blink_behind | shield_robot | 0 | 83 | 0 | 30.31 (2) | 19.77 (71) |
| expert | All | overkill_carry | all waves | 0 | 83 | 0 | 20 (73) | — |
| expert | 1 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 16.62 (10) |
| expert | 1 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 16.62 (10) |
| expert | 1 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 16.62 (10) |
| expert | 1 | overkill_carry | all waves | 0 | 10 | 0 | 16.62 (10) | — |
| expert | 2 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 14.16 (10) |
| expert | 2 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 14.16 (10) |
| expert | 2 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 14.16 (10) |
| expert | 2 | overkill_carry | all waves | 0 | 10 | 0 | 14.16 (10) | — |
| expert | 3 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 20.37 (10) |
| expert | 3 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 20.37 (10) |
| expert | 3 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 20.37 (10) |
| expert | 3 | overkill_carry | all waves | 0 | 10 | 0 | 20.37 (10) | — |
| expert | 4 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 20.18 (10) |
| expert | 4 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 20.18 (10) |
| expert | 4 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 20.18 (10) |
| expert | 4 | overkill_carry | all waves | 0 | 10 | 0 | 20.18 (10) | — |
| expert | 5 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 30.18 (8) |
| expert | 5 | tonnage_armour_crack | war_machine | 10 | 10 | 1 | 30.18 (8) | — |
| expert | 5 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 30.18 (8) |
| expert | 5 | overkill_carry | all waves | 0 | 10 | 0 | 30.18 (8) | — |
| expert | 6 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | 22.1 (5) | 17.03 (3) |
| expert | 6 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 21.22 (8) |
| expert | 6 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | — | 21.22 (8) |
| expert | 6 | overkill_carry | all waves | 0 | 8 | 0 | 21.22 (8) | — |
| expert | 7 | ohm_short_circuit | sentry_turret | 1 | 8 | 0.13 | 19.77 (5) | 14.07 (3) |
| expert | 7 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 19.08 (8) |
| expert | 7 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | — | 19.08 (8) |
| expert | 7 | overkill_carry | all waves | 0 | 8 | 0 | 19.08 (8) | — |
| expert | 8 | ohm_short_circuit | sentry_turret | 3 | 8 | 0.38 | 19.23 (6) | — |
| expert | 8 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 19.23 (6) |
| expert | 8 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | — | 19.23 (6) |
| expert | 8 | overkill_carry | all waves | 0 | 8 | 0 | 19.23 (6) | — |
| expert | 9 | ohm_short_circuit | sentry_turret | 3 | 6 | 0.5 | 35.7 (1) | 32.77 (1) |
| expert | 9 | tonnage_armour_crack | war_machine | 0 | 6 | 0 | — | 34.23 (2) |
| expert | 9 | kerf_blink_behind | shield_robot | 0 | 6 | 0 | 32.77 (1) | 35.7 (1) |
| expert | 9 | overkill_carry | all waves | 0 | 6 | 0 | 34.23 (2) | — |
| expert | 10 | ohm_short_circuit | sentry_turret | 2 | 2 | 1 | 27.85 (1) | — |
| expert | 10 | tonnage_armour_crack | war_machine | 1 | 2 | 0.5 | 27.85 (1) | — |
| expert | 10 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | 27.85 (1) | — |
| expert | 10 | overkill_carry | all waves | 0 | 2 | 0 | 27.85 (1) | — |
| expert | 11 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | — | — |
| expert | 11 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | — |
| expert | 11 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | — |
| expert | 11 | overkill_carry | all waves | 0 | 1 | 0 | — | — |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| effect_overkill_carry | waves survived | 2 (1) | 1 (11) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| effect_overkill_carry | wave s | 49.24 (1) | 17.52 (11) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_dent | waves survived | 2 (6) | 0 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_dent | wave s | 29.75 (4) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_kerf | waves survived | 3 (9) | 3 (5) | 3 | -3 | -9…0 | not measured (3, all offered) | too few pairs |
| ghost_kerf | wave s | 18.85 (7) | 25.38 (4) | 3 | -0.66 | -9.98…3.58 | not measured (3, all offered) | too few pairs |
| ghost_ohm | waves survived | 2 (8) | 2 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | wave s | 24.12 (5) | 49.24 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_tonnage | waves survived | 3 (14) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| ghost_tonnage | wave s | 20.28 (14) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| master_tonnage | waves survived | 1 (11) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| master_tonnage | wave s | 26.74 (7) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_10 | waves survived | 3 (24) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_10 | wave s | 19.77 (21) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_25 | waves survived | 1 (7) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_25 | wave s | 15.81 (6) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 2 (15) | 3 (11) | 3 | 2 | -1…2 | not measured (5, all offered) | too few pairs |
| stat_guard_meter_10 | wave s | 19.99 (13) | 16.65 (9) | 1 | -1.75 | not measured | not measured (4, all offered) | too few pairs |
| stat_guard_meter_25 | waves survived | 0 (5) | 1 (9) | 3 | -4 | -6…0 | 4 (6, all offered) | noise |
| stat_guard_meter_25 | wave s | 38.13 (1) | 16.42 (7) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 3 (17) | 1 (6) | 0 | not measured | not measured | 2 (8, all offered) | insufficient data |
| stat_hp_max_10 | wave s | 17.83 (12) | 13.75 (4) | 0 | not measured | not measured | 17.48 (6, all offered) | insufficient data |
| stat_hp_max_25 | waves survived | 2 (1) | 3 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_25 | wave s | 26.74 (1) | 17.47 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_10 | waves survived | 3 (13) | 3 (7) | 2 | 1 | 0…2 | not measured (2, all offered) | too few pairs |
| stat_regen_10 | wave s | 20.82 (12) | 15.92 (6) | 1 | 4.97 | not measured | not measured (2, all offered) | too few pairs |
| stat_regen_25 | waves survived | 0 (3) | 2 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | wave s | 23.22 (1) | 19.86 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | waves survived | 2 (14) | 3 (7) | 6 | 0.5 | -1…2 | not measured (3, all offered) | too few pairs |
| stat_speed_10 | wave s | 16.92 (11) | 26.84 (5) | 4 | -6.86 | -15.77…2.03 | not measured (1, all offered) | too few pairs |
| stat_speed_25 | waves survived | 0.5 (2) | 1 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_25 | wave s | 20.57 (1) | 13.73 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_chainsaw | waves survived | not measured | 4 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_chainsaw | wave s | not measured | 21.29 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | waves survived | 7 (3) | 2 (14) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | wave s | 27.85 (3) | 20.61 (12) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | waves survived | 4.5 (2) | 1.5 (6) | 1 | 2 | not measured | not measured (1, all offered) | too few pairs |
| weapon_flamethrower | wave s | 32.83 (2) | 20.57 (5) | 1 | 16.98 | not measured | not measured (1, all offered) | too few pairs |
| weapon_gatling | waves survived | 2.5 (2) | 2 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gatling | wave s | 34.1 (2) | 18.46 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gloria | waves survived | 1 (4) | 2 (16) | 1 | -2 | not measured | not measured (1, all offered) | too few pairs |
| weapon_gloria | wave s | 19.25 (4) | 17.81 (14) | 1 | -6.65 | not measured | not measured (1, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | not measured | 2 (13) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_hand_cannon | wave s | not measured | 26.23 (9) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_katana | waves survived | 4 (1) | 2 (18) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_katana | wave s | 22.78 (1) | 19.96 (18) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_machine_pistol | waves survived | 0 (1) | 2 (15) | 0 | not measured | not measured | 9 (6, decliners) | insufficient data |
| weapon_machine_pistol | wave s | not measured | 19.26 (14) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| weapon_pistol | waves survived | 4.5 (4) | 2 (11) | 3 | 4 | 0…6 | not measured (5, all offered) | too few pairs |
| weapon_pistol | wave s | 16.18 (4) | 17.81 (10) | 3 | -3.63 | -3.74…3.95 | not measured (5, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | not measured | 4 (13) | 0 | not measured | not measured | 3 (6, decliners) | insufficient data |
| weapon_plasma_rifle | wave s | not measured | 20.22 (13) | 0 | not measured | not measured | 14.92 (6, decliners) | insufficient data |
| weapon_plasma_sword | waves survived | 1 (1) | 0 (8) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_plasma_sword | wave s | 10.87 (1) | 24.17 (3) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_rocket_launcher | waves survived | 1.5 (4) | 0 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_rocket_launcher | wave s | 32.27 (4) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | not measured | 4 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| chainsaw | wave s | not measured | 21.29 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | waves survived | 7 (3) | 2 (14) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | wave s | 27.85 (3) | 20.61 (12) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | waves survived | 4.5 (2) | 1.5 (6) | 1 | 2 | not measured | not measured (1, all offered) | too few pairs |
| flamethrower | wave s | 32.83 (2) | 20.57 (5) | 1 | 16.98 | not measured | not measured (1, all offered) | too few pairs |
| gatling | waves survived | 2.5 (2) | 2 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gatling | wave s | 34.1 (2) | 18.46 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gloria | waves survived | 1 (4) | 2 (16) | 1 | -2 | not measured | not measured (1, all offered) | too few pairs |
| gloria | wave s | 19.25 (4) | 17.81 (14) | 1 | -6.65 | not measured | not measured (1, all offered) | too few pairs |
| hand_cannon | waves survived | not measured | 2 (13) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| hand_cannon | wave s | not measured | 26.23 (9) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| katana | waves survived | 4 (1) | 2 (18) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| katana | wave s | 22.78 (1) | 19.96 (18) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| machine_pistol | waves survived | 0 (1) | 2 (15) | 0 | not measured | not measured | 9 (6, decliners) | insufficient data |
| machine_pistol | wave s | not measured | 19.26 (14) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| pistol | waves survived | 4.5 (4) | 2 (11) | 3 | 4 | 0…6 | not measured (5, all offered) | too few pairs |
| pistol | wave s | 16.18 (4) | 17.81 (10) | 3 | -3.63 | -3.74…3.95 | not measured (5, all offered) | too few pairs |
| plasma_rifle | waves survived | not measured | 4 (13) | 0 | not measured | not measured | 3 (6, decliners) | insufficient data |
| plasma_rifle | wave s | not measured | 20.22 (13) | 0 | not measured | not measured | 14.92 (6, decliners) | insufficient data |
| plasma_sword | waves survived | 1 (1) | 0 (8) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| plasma_sword | wave s | 10.87 (1) | 24.17 (3) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| rocket_launcher | waves survived | 1.5 (4) | 0 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| rocket_launcher | wave s | 32.27 (4) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | rivet s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 9 (10) | 3 (10) | 0 (10) | 13 (10) | 14.64 (10) | not measured |
| novice | 2 | 9.5 (10) | 2 (10) | 0 (10) | 14 (10) | 14.61 (10) | not measured |
| novice | 3 | 5 (10) | 2 (10) | 0 (10) | 14.5 (10) | 16.96 (10) | not measured |
| novice | 4 | 5 (9) | 3 (9) | 0 (9) | 14 (9) | 19.15 (9) | 4.65 (1) |
| novice | 5 | 2 (8) | 2 (8) | 0 (8) | 11.5 (8) | 8.75 (8) | 1.15 (2) |
| average | 1 | 8.5 (10) | 3 (10) | 0 (10) | 13 (10) | 14.05 (10) | not measured |
| average | 2 | 9.5 (10) | 1.5 (10) | 0 (10) | 14 (10) | 15.04 (10) | not measured |
| average | 3 | 8 (10) | 3.5 (10) | 0 (10) | 13 (10) | 16.34 (10) | not measured |
| average | 4 | 7 (8) | 2 (8) | 0 (8) | 15 (8) | 15.77 (8) | not measured |
| average | 5 | 2 (8) | 5 (8) | 0 (8) | 12.5 (8) | 16.31 (8) | 3.57 (2) |
| average | 6 | 7 (2) | 1 (2) | 24.5 (2) | 35.5 (2) | 20.97 (2) | not measured |
| average | 7 | 7.5 (2) | 1.5 (2) | 21.5 (2) | 31 (2) | 15.78 (2) | not measured |
| average | 8 | 7 (2) | 6 (2) | 95.5 (2) | 775 (2) | 21.95 (2) | 7.1 (1) |
| average | 9 | 8.5 (2) | 7.5 (2) | 54.5 (2) | 428 (2) | 26.25 (2) | 7.1 (1) |
| average | 10 | 2.5 (2) | 6 (2) | 139 (2) | 647 (2) | 28.19 (2) | 7.1 (1) |
| average | 11 | 6 (2) | 4 (2) | 146.5 (2) | 1840.5 (2) | 25.43 (2) | 7.1 (1) |
| average | 12 | 5 (1) | 13 (1) | 262 (1) | 3416 (1) | 46.78 (1) | 14.2 (1) |
| average | 13 | 6 (1) | 6 (1) | 251 (1) | 1320 (1) | 30.4 (1) | 7.1 (1) |
| average | 14 | 9 (1) | 8 (1) | 72 (1) | 795 (1) | 14.45 (1) | 7.1 (1) |
| expert | 1 | 10.5 (10) | 4 (10) | 0 (10) | 13 (10) | 16.62 (10) | not measured |
| expert | 2 | 7.5 (10) | 3 (10) | 0 (10) | 14 (10) | 14.16 (10) | not measured |
| expert | 3 | 7 (10) | 9 (10) | 0 (10) | 15 (10) | 20.37 (10) | 7.1 (1) |
| expert | 4 | 8 (10) | 8 (10) | 0 (10) | 15 (10) | 20.19 (10) | 7.1 (1) |
| expert | 5 | 1 (10) | 6 (10) | 0 (10) | 20.5 (10) | 25.11 (10) | 3.75 (2) |
| expert | 6 | 5 (8) | 4 (8) | 0 (8) | 28 (8) | 18.68 (8) | 7.1 (1) |
| expert | 7 | 6 (8) | 3.5 (8) | 0 (8) | 28 (8) | 19.09 (8) | 7.1 (2) |
| expert | 8 | 3 (8) | 3 (8) | 11 (8) | 31.5 (8) | 16.04 (8) | 4.62 (2) |
| expert | 9 | 4 (6) | 7 (6) | 7.5 (6) | 29.5 (6) | 19.84 (6) | 7.1 (3) |
| expert | 10 | 1 (2) | 4.5 (2) | 109 (2) | 654 (2) | 18.32 (2) | 4.11 (2) |
| expert | 11 | 11 (1) | 15 (1) | 28 (1) | 632 (1) | 17.67 (1) | 7.1 (1) |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 2 | 5 | 2.21 | ghost_tonnage → ghost_ohm → master_tonnage → weapon_gloria → stat_damage_10 | gloria | rivet | node tools/dev/run.mjs gauntlet --seed=2 --bot=novice --pick=greedy --bot-salt=1 --controls=wheel --waves=40 |
| novice | 3 | 5 | 2.21 | stat_hp_max_10 → weapon_pistol → stat_damage_10 → stat_guard_meter_10 | pistol | rivet | node tools/dev/run.mjs gauntlet --seed=3 --bot=novice --pick=greedy --bot-salt=1 --controls=wheel --waves=40 |
| novice | 8 | 5 | 2.21 | stat_hp_max_10 → ghost_tonnage → weapon_electro_baton → stat_regen_10 | electro_baton | rivet | node tools/dev/run.mjs gauntlet --seed=8 --bot=novice --pick=greedy --bot-salt=1 --controls=wheel --waves=40 |
| average | 8 | 14 | 2.21 | stat_hp_max_10 → ghost_tonnage → weapon_electro_baton → master_tonnage → stat_regen_10 → ghost_dent → stat_guard_meter_10 → weapon_flamethrower → weapon_rocket_launcher → weapon_gatling → stat_guard_meter_25 → effect_overkill_carry → stat_damage_10 → stat_speed_10 | electro_baton, flamethrower, gatling, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=8 --bot=average --pick=greedy --bot-salt=1 --controls=wheel --waves=40 |
| expert | 8 | 11 | 2.21 | stat_hp_max_10 → ghost_tonnage → weapon_electro_baton → master_tonnage → stat_regen_10 → ghost_dent → stat_guard_meter_10 → weapon_flamethrower → weapon_rocket_launcher → weapon_gatling → stat_guard_meter_25 | electro_baton, flamethrower, gatling, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=8 --bot=expert --pick=greedy --bot-salt=1 --controls=wheel --waves=40 |
