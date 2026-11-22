# Gauntlet run report

6 of 6 runs accepted. Average-profile waves 1 (10.05 s), 5 (32.93 s), 6 (18.83 s), 7 (19.32 s), 8 (25.69 s), 9 (22.52 s), 10 (17.21 s), 12 (24.72 s), 13 (22.48 s), 14 (23.43 s), 15 (17.57 s) fell outside 12–18 s for ordinary waves and 25–30 s for boss waves.

Live gauntlet batch · n23-loop @ 4b8990a92541 (dirty) · 2026-11-22T05:02:01.557Z.

Stalled runs by profile: novice 0, average 0, expert 0.

Capped alive by profile: novice 0, average 0, expert 0.

## Death-wave score

Censored runs contribute their last reached wave as a lower bound to the median and spread.

| Profile | Target | Median wave | P25–P75 | Min–max | Deaths / censored |
| --- | --- | --- | --- | --- | --- |
| novice | 6 | 12 | 9–15 | 9–15 | 1 / 1 |
| average | 12 | 15 | 15–15 | 15–15 | 0 / 2 |
| expert | 20 | 15 | 15–15 | 15–15 | 0 / 2 |

## Profile separation

Targets require a median gap of 3 waves and a later death on at least 75% of shared seeds with the same controls and pick policy. Unresolved censored pairs stay in the denominator.

| Profiles | Observed median gap | Later / shared seeds | Confirmed later share | Unresolved | Verdict |
| --- | --- | --- | --- | --- | --- |
| novice → average | 3 | 1 / 2 | 50% | 1 | undetermined |
| novice → expert | 3 | 1 / 2 | 50% | 1 | undetermined |
| average → expert | 0 | 0 / 2 | 0% | 2 | undetermined |

## Waves per run

A timed-out wave can clear later. Active counts include each started roster still fighting at death.

| Profile | Seed | Outcome | Timed-out waves | Active waves at death |
| --- | --- | --- | --- | --- |
| novice | 1 | died on 9 | 0 | 1 |
| novice | 2 | censored at the wave limit 15 (≥ 15) | 0 | — |
| average | 1 | censored at the wave limit 15 (≥ 15) | 0 | — |
| average | 2 | censored at the wave limit 15 (≥ 15) | 0 | — |
| expert | 1 | censored at the wave limit 15 (≥ 15) | 0 | — |
| expert | 2 | censored at the wave limit 15 (≥ 15) | 0 | — |

## Wave time

Seconds per observed wave. The target is 15 s ±20% for ordinary average-profile waves. Every 5th wave targets 25–30 s. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Median s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 2 / 2 | 9.76 | 8.2…11.32 | 8.2…11.32 | — |
| novice | 2 | 2 / 2 | 12.63 | 11.37…13.9 | 11.37…13.9 | — |
| novice | 3 | 2 / 2 | 18.56 | 15.93…21.18 | 15.93…21.18 | — |
| novice | 4 | 2 / 2 | 11.72 | 9.98…13.45 | 9.98…13.45 | — |
| novice | 5 | 2 / 2 | 19.23 | 19.03…19.43 | 19.03…19.43 | — |
| novice | 6 | 2 / 2 | 23.43 | 23.33…23.52 | 23.33…23.52 | — |
| novice | 7 | 2 / 2 | 30.61 | 19…42.22 | 19…42.22 | — |
| novice | 8 | 2 / 2 | 23 | 20.55…25.45 | 20.55…25.45 | — |
| novice | 9 | 1 / 2 | 22.02 | 22.02…22.02 | 22.02…22.02 | — |
| novice | 10 | 1 / 1 | 21.32 | 21.32…21.32 | 21.32…21.32 | — |
| novice | 11 | 1 / 1 | 16.45 | 16.45…16.45 | 16.45…16.45 | — |
| novice | 12 | 1 / 1 | 16.42 | 16.42…16.42 | 16.42…16.42 | — |
| novice | 13 | 1 / 1 | 26.43 | 26.43…26.43 | 26.43…26.43 | — |
| novice | 14 | 1 / 1 | 28.95 | 28.95…28.95 | 28.95…28.95 | — |
| novice | 15 | 1 / 1 | 16.97 | 16.97…16.97 | 16.97…16.97 | — |
| average | 1 | 2 / 2 | 10.05 | 9.4…10.7 | 9.4…10.7 | miss |
| average | 2 | 2 / 2 | 13.35 | 11.87…14.83 | 11.87…14.83 | within target |
| average | 3 | 2 / 2 | 16.88 | 15.37…18.4 | 15.37…18.4 | within target |
| average | 4 | 2 / 2 | 12.42 | 11.97…12.87 | 11.97…12.87 | within target |
| average | 5 | 2 / 2 | 32.93 | 23.63…42.23 | 23.63…42.23 | miss |
| average | 6 | 2 / 2 | 18.83 | 17.22…20.45 | 17.22…20.45 | miss |
| average | 7 | 2 / 2 | 19.32 | 10.57…28.08 | 10.57…28.08 | miss |
| average | 8 | 2 / 2 | 25.69 | 22.25…29.13 | 22.25…29.13 | miss |
| average | 9 | 2 / 2 | 22.52 | 21.98…23.07 | 21.98…23.07 | miss |
| average | 10 | 2 / 2 | 17.21 | 16.35…18.07 | 16.35…18.07 | miss |
| average | 11 | 2 / 2 | 16.82 | 15.42…18.22 | 15.42…18.22 | within target |
| average | 12 | 2 / 2 | 24.72 | 13.73…35.72 | 13.73…35.72 | miss |
| average | 13 | 2 / 2 | 22.48 | 20.27…24.7 | 20.27…24.7 | miss |
| average | 14 | 2 / 2 | 23.43 | 22.3…24.57 | 22.3…24.57 | miss |
| average | 15 | 2 / 2 | 17.57 | 13.03…22.12 | 13.03…22.12 | miss |
| expert | 1 | 2 / 2 | 11.68 | 9.33…14.02 | 9.33…14.02 | — |
| expert | 2 | 2 / 2 | 15.17 | 13.37…16.97 | 13.37…16.97 | — |
| expert | 3 | 2 / 2 | 16.55 | 11.13…21.97 | 11.13…21.97 | — |
| expert | 4 | 2 / 2 | 12.84 | 11.33…14.35 | 11.33…14.35 | — |
| expert | 5 | 2 / 2 | 40.14 | 23.8…56.48 | 23.8…56.48 | — |
| expert | 6 | 2 / 2 | 22.32 | 17.52…27.12 | 17.52…27.12 | — |
| expert | 7 | 2 / 2 | 18.99 | 11.9…26.08 | 11.9…26.08 | — |
| expert | 8 | 2 / 2 | 23.23 | 15.07…31.4 | 15.07…31.4 | — |
| expert | 9 | 2 / 2 | 20.16 | 19.48…20.83 | 19.48…20.83 | — |
| expert | 10 | 2 / 2 | 12.05 | 9.9…14.2 | 9.9…14.2 | — |
| expert | 11 | 2 / 2 | 18.9 | 15.25…22.55 | 15.25…22.55 | — |
| expert | 12 | 2 / 2 | 18.63 | 16.22…21.03 | 16.22…21.03 | — |
| expert | 13 | 2 / 2 | 24.69 | 16.45…32.93 | 16.45…32.93 | — |
| expert | 14 | 2 / 2 | 17.93 | 15.22…20.63 | 15.22…20.63 | — |
| expert | 15 | 2 / 2 | 12.2 | 8.98…15.42 | 8.98…15.42 | — |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 2 | 1 | 0 | 0 | 1 | 9 × 1 | rocket × 1 | 0 |
| average | 2 | 0 | 0 | 0 | 2 | — | — | 0 |
| expert | 2 | 0 | 0 | 0 | 2 | — | — | 0 |

## Timeouts

Runs that reached the wave time limit.

| Outcome | novice | average | expert |
| --- | --- | --- | --- |
| timeout | 0 | 0 | 0 |

## Survival by wave band

Each wave contributes once to each available median. Damage/s needs a timed wave. Repair/s is the configured rate when repair is active. HP coverage counts waves sampled by the bot. Repaired HP sums positive HP steps. The share undone uses waves with positive damage. Multipliers include stat cards taken before the wave.

| Profile | Waves | HP rows / observed | Damage | Damage/s | Repair/s | Minimum HP (% of capacity) | Repaired HP | Damage undone (%) | Guard deflects | Cover ticks | Rolls | damage × | guard_meter × | hp_max × | regen × | speed × |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1–10 | 19 / 19 | 10.6 | 0.39 | 10 | 90.91 | 1.5 | 100 | 5 | 0 | 1 | 1 | 1 | 1.1 | 1 | 1 |
| novice | 11–20 | 5 / 5 | 20.23 | 1.23 | 11 | 70.21 | 33.36 | 100 | 7 | 0 | 3 | 1.375 | 1.1 | 1.1 | 1.1 | 1.1 |
| novice | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| novice | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 1–10 | 20 / 20 | 2.79 | 0.13 | 10 | 98.64 | 1.8 | 100 | 6 | 0.5 | 4 | 1 | 1 | 1.1 | 1 | 1 |
| average | 11–20 | 10 / 10 | 10.09 | 0.4 | 11 | 94.01 | 6.84 | 100 | 8 | 16 | 5 | 1.175 | 1.1 | 1.1 | 1.1 | 1.1 |
| average | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 1–10 | 20 / 20 | 1.44 | 0.11 | 10 | 98.8 | 2.04 | 100 | 5 | 22.5 | 4 | 1 | 1 | 1.1 | 1 | 1 |
| expert | 11–20 | 10 / 10 | 2.28 | 0.15 | 11 | 98.85 | 1.68 | 100 | 4.5 | 58.5 | 4.5 | 1.175 | 1.1 | 1.1 | 1.1 | 1.1 |
| expert | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 0 | — | 65.74% | 19.46 (54) | 16.45 (29) |
| patrol_cop | 0 | — | 78.22% | 16.97 (67) | 21.11 (16) |
| riot_cop | 0 | — | 79.19% | 20.27 (61) | 13.63 (22) |
| robot_gunner | 0 | — | 53.67% | 20.93 (40) | 14.83 (43) |
| robot_thug | 0 | — | 59.02% | 20.83 (45) | 15.16 (38) |
| rocket_trooper | 1 | rocket × 1 | 73.29% | 18.94 (60) | 14.02 (23) |
| sentry_turret | 0 | — | 44.83% | 18.22 (35) | 16.71 (48) |
| shield_robot | 0 | — | 32.29% | 21.51 (24) | 16.45 (59) |
| swat | 0 | — | 58.9% | 17.87 (48) | 18.07 (35) |
| war_machine | 0 | — | 21.23% | 18.55 (16) | 17.52 (67) |

## Moves

Uses count recorded activations by profile and wave number. The game omits zero counts. Times are medians in seconds, with timed wave counts in parentheses. Carry applies to all waves.

| Profile | Wave | Move | Enemy | Recorded uses | Observed waves | Uses per wave | With enemy s (n) | Without enemy s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | All | ohm_short_circuit | sentry_turret | 7 | 24 | 0.29 | 21.32 (9) | 17.47 (14) |
| novice | All | tonnage_armour_crack | war_machine | 4 | 24 | 0.17 | 19.23 (4) | 19 (19) |
| novice | All | kerf_blink_behind | shield_robot | 6 | 24 | 0.25 | 24.23 (4) | 19 (19) |
| novice | All | overkill_carry | all waves | 0 | 24 | 0 | 19.03 (23) | — |
| novice | 1 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | — | 9.76 (2) |
| novice | 1 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 9.76 (2) |
| novice | 1 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 9.76 (2) |
| novice | 1 | overkill_carry | all waves | 0 | 2 | 0 | 9.76 (2) | — |
| novice | 2 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | — | 12.63 (2) |
| novice | 2 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 12.63 (2) |
| novice | 2 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 12.63 (2) |
| novice | 2 | overkill_carry | all waves | 0 | 2 | 0 | 12.63 (2) | — |
| novice | 3 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | — | 18.56 (2) |
| novice | 3 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 18.56 (2) |
| novice | 3 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 18.56 (2) |
| novice | 3 | overkill_carry | all waves | 0 | 2 | 0 | 18.56 (2) | — |
| novice | 4 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | — | 11.72 (2) |
| novice | 4 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 11.72 (2) |
| novice | 4 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 11.72 (2) |
| novice | 4 | overkill_carry | all waves | 0 | 2 | 0 | 11.72 (2) | — |
| novice | 5 | ohm_short_circuit | sentry_turret | 2 | 2 | 1 | — | 19.23 (2) |
| novice | 5 | tonnage_armour_crack | war_machine | 3 | 2 | 1.5 | 19.23 (2) | — |
| novice | 5 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 19.23 (2) |
| novice | 5 | overkill_carry | all waves | 0 | 2 | 0 | 19.23 (2) | — |
| novice | 6 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 23.52 (1) | 23.33 (1) |
| novice | 6 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 23.43 (2) |
| novice | 6 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 23.43 (2) |
| novice | 6 | overkill_carry | all waves | 0 | 2 | 0 | 23.43 (2) | — |
| novice | 7 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 42.22 (1) | 19 (1) |
| novice | 7 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 30.61 (2) |
| novice | 7 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 30.61 (2) |
| novice | 7 | overkill_carry | all waves | 0 | 2 | 0 | 30.61 (2) | — |
| novice | 8 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 23 (2) | — |
| novice | 8 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 23 (2) |
| novice | 8 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 23 (2) |
| novice | 8 | overkill_carry | all waves | 0 | 2 | 0 | 23 (2) | — |
| novice | 9 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | — | 22.02 (1) |
| novice | 9 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 22.02 (1) |
| novice | 9 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | 22.02 (1) | — |
| novice | 9 | overkill_carry | all waves | 0 | 2 | 0 | 22.02 (1) | — |
| novice | 10 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 21.32 (1) | — |
| novice | 10 | tonnage_armour_crack | war_machine | 1 | 1 | 1 | 21.32 (1) | — |
| novice | 10 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | 21.32 (1) |
| novice | 10 | overkill_carry | all waves | 0 | 1 | 0 | 21.32 (1) | — |
| novice | 11 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | 16.45 (1) | — |
| novice | 11 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 16.45 (1) |
| novice | 11 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | 16.45 (1) |
| novice | 11 | overkill_carry | all waves | 0 | 1 | 0 | 16.45 (1) | — |
| novice | 12 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | 16.42 (1) | — |
| novice | 12 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 16.42 (1) |
| novice | 12 | kerf_blink_behind | shield_robot | 3 | 1 | 3 | 16.42 (1) | — |
| novice | 12 | overkill_carry | all waves | 0 | 1 | 0 | 16.42 (1) | — |
| novice | 13 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | — | 26.43 (1) |
| novice | 13 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 26.43 (1) |
| novice | 13 | kerf_blink_behind | shield_robot | 1 | 1 | 1 | 26.43 (1) | — |
| novice | 13 | overkill_carry | all waves | 0 | 1 | 0 | 26.43 (1) | — |
| novice | 14 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 28.95 (1) | — |
| novice | 14 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 28.95 (1) |
| novice | 14 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | 28.95 (1) | — |
| novice | 14 | overkill_carry | all waves | 0 | 1 | 0 | 28.95 (1) | — |
| novice | 15 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 16.97 (1) | — |
| novice | 15 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | 16.97 (1) | — |
| novice | 15 | kerf_blink_behind | shield_robot | 2 | 1 | 2 | — | 16.97 (1) |
| novice | 15 | overkill_carry | all waves | 0 | 1 | 0 | 16.97 (1) | — |
| average | All | ohm_short_circuit | sentry_turret | 11 | 30 | 0.37 | 18.22 (13) | 18.4 (17) |
| average | All | tonnage_armour_crack | war_machine | 4 | 30 | 0.13 | 20.09 (6) | 18.31 (24) |
| average | All | kerf_blink_behind | shield_robot | 17 | 30 | 0.57 | 22.21 (10) | 16.78 (20) |
| average | All | overkill_carry | all waves | 0 | 30 | 0 | 18.31 (30) | — |
| average | 1 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | — | 10.05 (2) |
| average | 1 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 10.05 (2) |
| average | 1 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 10.05 (2) |
| average | 1 | overkill_carry | all waves | 0 | 2 | 0 | 10.05 (2) | — |
| average | 2 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | — | 13.35 (2) |
| average | 2 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 13.35 (2) |
| average | 2 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 13.35 (2) |
| average | 2 | overkill_carry | all waves | 0 | 2 | 0 | 13.35 (2) | — |
| average | 3 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | — | 16.88 (2) |
| average | 3 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 16.88 (2) |
| average | 3 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 16.88 (2) |
| average | 3 | overkill_carry | all waves | 0 | 2 | 0 | 16.88 (2) | — |
| average | 4 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | — | 12.42 (2) |
| average | 4 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 12.42 (2) |
| average | 4 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 12.42 (2) |
| average | 4 | overkill_carry | all waves | 0 | 2 | 0 | 12.42 (2) | — |
| average | 5 | ohm_short_circuit | sentry_turret | 3 | 2 | 1.5 | — | 32.93 (2) |
| average | 5 | tonnage_armour_crack | war_machine | 4 | 2 | 2 | 32.93 (2) | — |
| average | 5 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 32.93 (2) |
| average | 5 | overkill_carry | all waves | 0 | 2 | 0 | 32.93 (2) | — |
| average | 6 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | 17.22 (1) | 20.45 (1) |
| average | 6 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 18.83 (2) |
| average | 6 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 18.83 (2) |
| average | 6 | overkill_carry | all waves | 0 | 2 | 0 | 18.83 (2) | — |
| average | 7 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 28.08 (1) | 10.57 (1) |
| average | 7 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 19.32 (2) |
| average | 7 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 19.32 (2) |
| average | 7 | overkill_carry | all waves | 0 | 2 | 0 | 19.32 (2) | — |
| average | 8 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | 25.69 (2) | — |
| average | 8 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 25.69 (2) |
| average | 8 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 25.69 (2) |
| average | 8 | overkill_carry | all waves | 0 | 2 | 0 | 25.69 (2) | — |
| average | 9 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | — | 22.52 (2) |
| average | 9 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 22.52 (2) |
| average | 9 | kerf_blink_behind | shield_robot | 1 | 2 | 0.5 | 22.52 (2) | — |
| average | 9 | overkill_carry | all waves | 0 | 2 | 0 | 22.52 (2) | — |
| average | 10 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | 17.21 (2) | — |
| average | 10 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | 17.21 (2) | — |
| average | 10 | kerf_blink_behind | shield_robot | 2 | 2 | 1 | — | 17.21 (2) |
| average | 10 | overkill_carry | all waves | 0 | 2 | 0 | 17.21 (2) | — |
| average | 11 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | 16.82 (2) | — |
| average | 11 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 16.82 (2) |
| average | 11 | kerf_blink_behind | shield_robot | 2 | 2 | 1 | 15.42 (1) | 18.22 (1) |
| average | 11 | overkill_carry | all waves | 0 | 2 | 0 | 16.82 (2) | — |
| average | 12 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 24.72 (2) | — |
| average | 12 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 24.72 (2) |
| average | 12 | kerf_blink_behind | shield_robot | 4 | 2 | 2 | 24.72 (2) | — |
| average | 12 | overkill_carry | all waves | 0 | 2 | 0 | 24.72 (2) | — |
| average | 13 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | — | 22.48 (2) |
| average | 13 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 22.48 (2) |
| average | 13 | kerf_blink_behind | shield_robot | 5 | 2 | 2.5 | 22.48 (2) | — |
| average | 13 | overkill_carry | all waves | 0 | 2 | 0 | 22.48 (2) | — |
| average | 14 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | 23.43 (2) | — |
| average | 14 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 23.43 (2) |
| average | 14 | kerf_blink_behind | shield_robot | 1 | 2 | 0.5 | 23.43 (2) | — |
| average | 14 | overkill_carry | all waves | 0 | 2 | 0 | 23.43 (2) | — |
| average | 15 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | 13.03 (1) | 22.12 (1) |
| average | 15 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | 17.57 (2) | — |
| average | 15 | kerf_blink_behind | shield_robot | 2 | 2 | 1 | 22.12 (1) | 13.03 (1) |
| average | 15 | overkill_carry | all waves | 0 | 2 | 0 | 17.57 (2) | — |
| expert | All | ohm_short_circuit | sentry_turret | 12 | 30 | 0.4 | 16.22 (13) | 16.45 (17) |
| expert | All | tonnage_armour_crack | war_machine | 1 | 30 | 0.03 | 14.81 (6) | 16.71 (24) |
| expert | All | kerf_blink_behind | shield_robot | 18 | 30 | 0.6 | 20.06 (10) | 14.71 (20) |
| expert | All | overkill_carry | all waves | 0 | 30 | 0 | 16.33 (30) | — |
| expert | 1 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | — | 11.68 (2) |
| expert | 1 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 11.68 (2) |
| expert | 1 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 11.68 (2) |
| expert | 1 | overkill_carry | all waves | 0 | 2 | 0 | 11.68 (2) | — |
| expert | 2 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | — | 15.17 (2) |
| expert | 2 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 15.17 (2) |
| expert | 2 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 15.17 (2) |
| expert | 2 | overkill_carry | all waves | 0 | 2 | 0 | 15.17 (2) | — |
| expert | 3 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | — | 16.55 (2) |
| expert | 3 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 16.55 (2) |
| expert | 3 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 16.55 (2) |
| expert | 3 | overkill_carry | all waves | 0 | 2 | 0 | 16.55 (2) | — |
| expert | 4 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | — | 12.84 (2) |
| expert | 4 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 12.84 (2) |
| expert | 4 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 12.84 (2) |
| expert | 4 | overkill_carry | all waves | 0 | 2 | 0 | 12.84 (2) | — |
| expert | 5 | ohm_short_circuit | sentry_turret | 6 | 2 | 3 | — | 40.14 (2) |
| expert | 5 | tonnage_armour_crack | war_machine | 1 | 2 | 0.5 | 40.14 (2) | — |
| expert | 5 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 40.14 (2) |
| expert | 5 | overkill_carry | all waves | 0 | 2 | 0 | 40.14 (2) | — |
| expert | 6 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | 17.52 (1) | 27.12 (1) |
| expert | 6 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 22.32 (2) |
| expert | 6 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 22.32 (2) |
| expert | 6 | overkill_carry | all waves | 0 | 2 | 0 | 22.32 (2) | — |
| expert | 7 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 26.08 (1) | 11.9 (1) |
| expert | 7 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 18.99 (2) |
| expert | 7 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 18.99 (2) |
| expert | 7 | overkill_carry | all waves | 0 | 2 | 0 | 18.99 (2) | — |
| expert | 8 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | 23.23 (2) | — |
| expert | 8 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 23.23 (2) |
| expert | 8 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 23.23 (2) |
| expert | 8 | overkill_carry | all waves | 0 | 2 | 0 | 23.23 (2) | — |
| expert | 9 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | — | 20.16 (2) |
| expert | 9 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 20.16 (2) |
| expert | 9 | kerf_blink_behind | shield_robot | 2 | 2 | 1 | 20.16 (2) | — |
| expert | 9 | overkill_carry | all waves | 0 | 2 | 0 | 20.16 (2) | — |
| expert | 10 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | 12.05 (2) | — |
| expert | 10 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | 12.05 (2) | — |
| expert | 10 | kerf_blink_behind | shield_robot | 2 | 2 | 1 | — | 12.05 (2) |
| expert | 10 | overkill_carry | all waves | 0 | 2 | 0 | 12.05 (2) | — |
| expert | 11 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 18.9 (2) | — |
| expert | 11 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 18.9 (2) |
| expert | 11 | kerf_blink_behind | shield_robot | 2 | 2 | 1 | 22.55 (1) | 15.25 (1) |
| expert | 11 | overkill_carry | all waves | 0 | 2 | 0 | 18.9 (2) | — |
| expert | 12 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 18.63 (2) | — |
| expert | 12 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 18.63 (2) |
| expert | 12 | kerf_blink_behind | shield_robot | 4 | 2 | 2 | 18.63 (2) | — |
| expert | 12 | overkill_carry | all waves | 0 | 2 | 0 | 18.63 (2) | — |
| expert | 13 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | — | 24.69 (2) |
| expert | 13 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 24.69 (2) |
| expert | 13 | kerf_blink_behind | shield_robot | 4 | 2 | 2 | 24.69 (2) | — |
| expert | 13 | overkill_carry | all waves | 0 | 2 | 0 | 24.69 (2) | — |
| expert | 14 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | 17.93 (2) | — |
| expert | 14 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 17.93 (2) |
| expert | 14 | kerf_blink_behind | shield_robot | 1 | 2 | 0.5 | 17.93 (2) | — |
| expert | 14 | overkill_carry | all waves | 0 | 2 | 0 | 17.93 (2) | — |
| expert | 15 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 8.98 (1) | 15.42 (1) |
| expert | 15 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | 12.2 (2) | — |
| expert | 15 | kerf_blink_behind | shield_robot | 3 | 2 | 1.5 | 15.42 (1) | 8.98 (1) |
| expert | 15 | overkill_carry | all waves | 0 | 2 | 0 | 12.2 (2) | — |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| effect_overkill_carry | waves survived | 0 (2) | 12 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| effect_overkill_carry | wave s | not measured | 18.97 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_dent | waves survived | 11 (3) | 5 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_dent | wave s | 23.63 (3) | 16.97 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_kerf | waves survived | 5 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_kerf | wave s | 18.22 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | waves survived | 13 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | wave s | 18.22 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_tonnage | waves survived | 14 (6) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| ghost_tonnage | wave s | 20.1 (6) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_10 | waves survived | 4.5 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_10 | wave s | 21.75 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_25 | waves survived | 7 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_25 | wave s | 18.22 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 10 (5) | 2 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_10 | wave s | 18.23 (5) | 33.83 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_25 | waves survived | 1 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_25 | wave s | 13.03 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 11 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_10 | wave s | 21.26 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_25 | waves survived | 2 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_25 | wave s | 17.67 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_10 | waves survived | 12 (5) | 6 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_10 | wave s | 18.14 (5) | 22.26 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | waves survived | not measured | 0 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | wave s | not measured | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | waves survived | 6 (5) | 0 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | wave s | 19.14 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_25 | waves survived | not measured | 11 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_25 | wave s | not measured | 23.63 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_chainsaw | waves survived | not measured | 8 (6) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_chainsaw | wave s | not measured | 20.6 (6) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_electro_baton | waves survived | 0 (3) | 9 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | wave s | not measured | 24.57 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | waves survived | 10 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | wave s | 23.82 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gatling | waves survived | 8 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gatling | wave s | 20.98 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gloria | waves survived | not measured | 12 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gloria | wave s | not measured | 20.49 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | not measured | 7 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_hand_cannon | wave s | not measured | 21.55 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_katana | waves survived | 8 (3) | 10 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_katana | wave s | 23.82 (3) | 18.14 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_machine_pistol | waves survived | 9 (3) | 13 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_machine_pistol | wave s | 18.22 (3) | 22.26 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_pistol | waves survived | 3 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_pistol | wave s | 20.27 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | not measured | 8 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_rifle | wave s | not measured | 19.24 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_sword | waves survived | 1 (2) | 4 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_sword | wave s | 18.77 (2) | 24.39 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_rocket_launcher | waves survived | 2 (2) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_rocket_launcher | wave s | 19.33 (2) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | not measured | 8 (6) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| chainsaw | wave s | not measured | 20.6 (6) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| electro_baton | waves survived | 0 (3) | 9 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | wave s | not measured | 24.57 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | waves survived | 10 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | wave s | 23.82 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gatling | waves survived | 8 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gatling | wave s | 20.98 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gloria | waves survived | not measured | 12 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gloria | wave s | not measured | 20.49 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| hand_cannon | waves survived | not measured | 7 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| hand_cannon | wave s | not measured | 21.55 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| katana | waves survived | 8 (3) | 10 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| katana | wave s | 23.82 (3) | 18.14 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| machine_pistol | waves survived | 9 (3) | 13 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| machine_pistol | wave s | 18.22 (3) | 22.26 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| pistol | waves survived | 3 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| pistol | wave s | 20.27 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_rifle | waves survived | not measured | 8 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_rifle | wave s | not measured | 19.24 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_sword | waves survived | 1 (2) | 4 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_sword | wave s | 18.77 (2) | 24.39 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| rocket_launcher | waves survived | 2 (2) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| rocket_launcher | wave s | 19.33 (2) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | kerf s (n) | ohm s (n) | rivet s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 7.5 (2) | 1.5 (2) | 0 (2) | 13 (2) | not measured | not measured | 9.76 (2) | not measured |
| novice | 2 | 6 (2) | 1 (2) | 0 (2) | 14 (2) | not measured | not measured | 12.63 (2) | not measured |
| novice | 3 | 5.5 (2) | 2 (2) | 0 (2) | 11 (2) | not measured | not measured | 16.66 (2) | 3.78 (1) |
| novice | 4 | 3.5 (2) | 1 (2) | 0 (2) | 12 (2) | not measured | not measured | 11.71 (2) | not measured |
| novice | 5 | 0 (2) | 2 (2) | 0 (2) | 22.5 (2) | not measured | 5.48 (1) | 9.39 (2) | 7.1 (2) |
| novice | 6 | 9 (2) | 2 (2) | 82.5 (2) | 801.5 (2) | not measured | not measured | 19.88 (2) | 7.1 (1) |
| novice | 7 | 3.5 (2) | 2 (2) | 182 (2) | 989 (2) | not measured | 7.3 (1) | 23.41 (2) | 7.1 (1) |
| novice | 8 | 11 (2) | 1 (2) | 132.5 (2) | 577 (2) | not measured | not measured | 19.45 (2) | 7.1 (1) |
| novice | 9 | 16.5 (2) | 6.5 (2) | 34 (2) | 69.5 (2) | not measured | 1.82 (1) | 14.63 (2) | 7.1 (2) |
| novice | 10 | 0 (1) | 3 (1) | 61 (1) | 56 (1) | not measured | 0.03 (1) | 21.27 (1) | 0.02 (1) |
| novice | 11 | 7 (1) | 2 (1) | 72 (1) | 43 (1) | 5.5 (1) | not measured | 10.95 (1) | not measured |
| novice | 12 | 4 (1) | 4 (1) | 56 (1) | 38 (1) | 5.5 (1) | 0.02 (1) | 10.37 (1) | 0.53 (1) |
| novice | 13 | 13 (1) | 3 (1) | 74 (1) | 100 (1) | 5.5 (1) | 2.07 (1) | 18.87 (1) | not measured |
| novice | 14 | 22 (1) | 3 (1) | 109 (1) | 99 (1) | not measured | 4.33 (1) | 24.62 (1) | not measured |
| novice | 15 | 1 (1) | 1 (1) | 30 (1) | 24 (1) | 5.5 (1) | 0.03 (1) | 11.43 (1) | not measured |
| average | 1 | 12.5 (2) | 1 (2) | 0 (2) | 13 (2) | not measured | not measured | 10.05 (2) | not measured |
| average | 2 | 9 (2) | 1 (2) | 0 (2) | 14 (2) | not measured | not measured | 13.35 (2) | not measured |
| average | 3 | 5 (2) | 4 (2) | 0 (2) | 11 (2) | not measured | not measured | 9.79 (2) | 7.1 (2) |
| average | 4 | 3.5 (2) | 1 (2) | 0 (2) | 16.5 (2) | not measured | 7.05 (1) | 8.89 (2) | not measured |
| average | 5 | 1.5 (2) | 8 (2) | 0 (2) | 26 (2) | not measured | 9.63 (1) | 19.03 (2) | 9.09 (2) |
| average | 6 | 6.5 (2) | 4 (2) | 44 (2) | 1097.5 (2) | not measured | 0.03 (1) | 15.27 (2) | 7.1 (1) |
| average | 7 | 9 (2) | 1 (2) | 142.5 (2) | 850 (2) | not measured | not measured | 19.32 (2) | not measured |
| average | 8 | 5 (2) | 4.5 (2) | 103 (2) | 777.5 (2) | not measured | 0.73 (1) | 21.77 (2) | 7.1 (1) |
| average | 9 | 13.5 (2) | 7 (2) | 60 (2) | 696 (2) | 3.27 (1) | 0.03 (1) | 14.9 (2) | 5.97 (2) |
| average | 10 | 1.5 (2) | 7.5 (2) | 48 (2) | 55.5 (2) | 4.17 (1) | 0.77 (1) | 8.04 (2) | 6.7 (2) |
| average | 11 | 9.5 (2) | 2 (2) | 78.5 (2) | 381 (2) | 3.09 (2) | 0.03 (1) | 13.7 (2) | 0.02 (1) |
| average | 12 | 5.5 (2) | 5 (2) | 106 (2) | 1018 (2) | 2.04 (2) | not measured | 15.59 (2) | 7.1 (2) |
| average | 13 | 13 (2) | 7.5 (2) | 58 (2) | 1504 (2) | 5.95 (2) | 2.18 (1) | 11.89 (2) | 7.1 (1) |
| average | 14 | 8 (2) | 5 (2) | 82 (2) | 829.5 (2) | 6.23 (1) | 2.62 (1) | 19 (2) | not measured |
| average | 15 | 1.5 (2) | 11 (2) | 49.5 (2) | 201 (2) | 2.85 (2) | 0.55 (1) | 10.9 (2) | 7.1 (1) |
| expert | 1 | 7 (2) | 2 (2) | 0 (2) | 13 (2) | not measured | not measured | 11.68 (2) | not measured |
| expert | 2 | 8.5 (2) | 1.5 (2) | 0 (2) | 14 (2) | not measured | not measured | 15.17 (2) | not measured |
| expert | 3 | 4 (2) | 11.5 (2) | 0 (2) | 15.5 (2) | not measured | 6.08 (1) | 9.96 (2) | 7.1 (1) |
| expert | 4 | 7.5 (2) | 1.5 (2) | 0 (2) | 12 (2) | not measured | not measured | 12.84 (2) | not measured |
| expert | 5 | 4 (2) | 18 (2) | 0 (2) | 38.5 (2) | not measured | 20.42 (1) | 22.61 (2) | 7.32 (2) |
| expert | 6 | 7 (2) | 5.5 (2) | 63 (2) | 314 (2) | not measured | 0.03 (1) | 16.91 (2) | 5.39 (2) |
| expert | 7 | 6 (2) | 2 (2) | 124.5 (2) | 750 (2) | not measured | not measured | 18.99 (2) | not measured |
| expert | 8 | 3.5 (2) | 3.5 (2) | 144.5 (2) | 727.5 (2) | not measured | 3.6 (1) | 17.89 (2) | 7.1 (1) |
| expert | 9 | 7.5 (2) | 6.5 (2) | 82.5 (2) | 180 (2) | 5.47 (1) | 0.03 (1) | 10.31 (2) | 7.1 (2) |
| expert | 10 | 4 (2) | 2.5 (2) | 38 (2) | 166.5 (2) | 2.58 (1) | 0.03 (1) | 10.16 (2) | 1.17 (1) |
| expert | 11 | 7.5 (2) | 4 (2) | 66.5 (2) | 269.5 (2) | 6.55 (1) | 7.3 (1) | 10.57 (2) | 2.8 (1) |
| expert | 12 | 6.5 (2) | 5.5 (2) | 63.5 (2) | 542 (2) | 5.5 (2) | not measured | 10.98 (2) | 4.3 (1) |
| expert | 13 | 6 (2) | 5.5 (2) | 123 (2) | 799.5 (2) | 3.63 (2) | 3.9 (1) | 15.56 (2) | 7.1 (1) |
| expert | 14 | 11 (2) | 3.5 (2) | 86.5 (2) | 349 (2) | 3.56 (2) | 0.03 (1) | 14.35 (2) | not measured |
| expert | 15 | 1 (2) | 5 (2) | 47.5 (2) | 50 (2) | 5.5 (2) | not measured | 6.54 (2) | 0.32 (1) |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 2 | 15 | 0.67 | ghost_tonnage → ghost_ohm → stat_regen_10 → stat_hp_max_10 → stat_guard_meter_10 → weapon_machine_pistol → weapon_gatling → stat_damage_25 → stat_speed_10 → ghost_kerf → stat_damage_10 → weapon_pistol → stat_hp_max_25 → stat_guard_meter_25 → weapon_electro_baton | electro_baton, gatling, machine_pistol, pistol | rivet | node tools/dev/run.mjs gauntlet --seed=2 --bot=novice --pick=greedy --controls=wheel --waves=15 |
| average | 1 | 15 | 0.67 | ghost_tonnage → stat_hp_max_10 → stat_damage_10 → ghost_dent → weapon_flamethrower → weapon_gatling → weapon_katana → ghost_kerf → weapon_pistol → stat_speed_10 → stat_guard_meter_10 → stat_regen_10 → weapon_rocket_launcher → weapon_plasma_sword → effect_overkill_carry | flamethrower, gatling, katana, pistol, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=average --pick=greedy --controls=wheel --waves=15 |
| average | 2 | 15 | 0.67 | ghost_tonnage → ghost_ohm → stat_regen_10 → stat_hp_max_10 → stat_guard_meter_10 → weapon_machine_pistol → weapon_gatling → stat_damage_25 → stat_speed_10 → ghost_kerf → stat_damage_10 → weapon_pistol → stat_hp_max_25 → stat_guard_meter_25 → weapon_electro_baton | electro_baton, gatling, machine_pistol, pistol | rivet | node tools/dev/run.mjs gauntlet --seed=2 --bot=average --pick=greedy --controls=wheel --waves=15 |
| expert | 1 | 15 | 0.67 | ghost_tonnage → stat_hp_max_10 → stat_damage_10 → ghost_dent → weapon_flamethrower → weapon_gatling → weapon_katana → ghost_kerf → weapon_pistol → stat_speed_10 → stat_guard_meter_10 → stat_regen_10 → weapon_rocket_launcher → weapon_plasma_sword → effect_overkill_carry | flamethrower, gatling, katana, pistol, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=expert --pick=greedy --controls=wheel --waves=15 |
| expert | 2 | 15 | 0.67 | ghost_tonnage → ghost_ohm → stat_regen_10 → stat_hp_max_10 → stat_guard_meter_10 → weapon_machine_pistol → weapon_gatling → stat_damage_25 → stat_speed_10 → ghost_kerf → stat_damage_10 → weapon_pistol → stat_hp_max_25 → stat_guard_meter_25 → weapon_electro_baton | electro_baton, gatling, machine_pistol, pistol | rivet | node tools/dev/run.mjs gauntlet --seed=2 --bot=expert --pick=greedy --controls=wheel --waves=15 |
