# Gauntlet run report

30 of 30 runs accepted. Average-profile waves 5 (19 s), 6 (21.25 s), 8 (22.93 s), 9 (19.87 s) fell outside 12–18 s for ordinary waves and 25–30 s for boss waves.

Live gauntlet batch · n26-pressure @ bf32bfd1aa2b (dirty) · 2026-11-23T14:41:30.533Z.

Stalled runs by profile: novice 0, average 0, expert 0.

Capped alive by profile: novice 0, average 0, expert 0.

## Death-wave score

Censored runs contribute their last reached wave as a lower bound to the median and spread.

| Profile | Target | Median wave | P25–P75 | Min–max | Deaths / censored |
| --- | --- | --- | --- | --- | --- |
| novice | 6 | 5 | 5–5 | 3–5 | 10 / 0 |
| average | 12 | 7.5 | 5–10 | 5–10 | 10 / 0 |
| expert | 20 | 8.5 | 5–10 | 5–10 | 10 / 0 |

## Profile separation

Targets require a median gap of 3 waves and a later death on at least 75% of shared seeds with the same controls and pick policy. Unresolved censored pairs stay in the denominator.

| Profiles | Observed median gap | Later / shared seeds | Confirmed later share | Unresolved | Verdict |
| --- | --- | --- | --- | --- | --- |
| novice → average | 2.5 | 6 / 10 | 60% | 0 | below target |
| novice → expert | 3.5 | 7 / 10 | 70% | 0 | below target |
| average → expert | 1 | 3 / 10 | 30% | 0 | below target |

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
| average | 1 | died on 5 | 0 | 1 |
| average | 2 | died on 5 | 0 | 1 |
| average | 3 | died on 10 | 0 | 1 |
| average | 4 | died on 5 | 0 | 1 |
| average | 5 | died on 10 | 0 | 1 |
| average | 6 | died on 5 | 0 | 1 |
| average | 7 | died on 9 | 0 | 1 |
| average | 8 | died on 10 | 1 | 2 |
| average | 9 | died on 6 | 0 | 1 |
| average | 10 | died on 9 | 0 | 1 |
| expert | 1 | died on 10 | 1 | 1 |
| expert | 2 | died on 5 | 0 | 1 |
| expert | 3 | died on 10 | 0 | 1 |
| expert | 4 | died on 5 | 0 | 1 |
| expert | 5 | died on 5 | 0 | 1 |
| expert | 6 | died on 7 | 0 | 1 |
| expert | 7 | died on 8 | 0 | 1 |
| expert | 8 | died on 10 | 1 | 2 |
| expert | 9 | died on 9 | 0 | 1 |
| expert | 10 | died on 9 | 0 | 1 |

## Wave time

Seconds per observed wave. The target is 15 s ±20% for ordinary average-profile waves. Every 5th wave targets 25–30 s. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Median s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 10 / 10 | 15.12 | 13.43…15.98 | 10.6…16.68 | — |
| novice | 2 | 10 / 10 | 14.98 | 12.18…16.88 | 11.57…17.68 | — |
| novice | 3 | 9 / 10 | 15.47 | 12.82…17.47 | 8.43…31.15 | — |
| novice | 4 | 9 / 9 | 15.03 | 11.93…21.37 | 10.33…24.47 | — |
| novice | 5 | 0 / 9 | not measured | not measured | not measured | — |
| average | 1 | 10 / 10 | 14.71 | 12.52…17 | 10.72…21.13 | within target |
| average | 2 | 10 / 10 | 15.01 | 13.12…18.4 | 8.95…21.1 | within target |
| average | 3 | 10 / 10 | 16.42 | 11.15…23.3 | 6.23…26.65 | within target |
| average | 4 | 10 / 10 | 13.81 | 10.95…15 | 8.17…17.05 | within target |
| average | 5 | 6 / 10 | 19 | 17.68…27.13 | 16.28…28.25 | miss |
| average | 6 | 5 / 6 | 21.25 | 21…28.3 | 16.22…33.65 | miss |
| average | 7 | 5 / 5 | 17.62 | 14.08…19.62 | 13.03…19.73 | within target |
| average | 8 | 5 / 5 | 22.93 | 18.73…25.3 | 18.3…26.68 | miss |
| average | 9 | 2 / 5 | 19.87 | 17.25…22.48 | 17.25…22.48 | miss |
| average | 10 | 0 / 3 | not measured | not measured | not measured | not measured |
| expert | 1 | 10 / 10 | 16.31 | 13.4…18.35 | 13.02…22.67 | — |
| expert | 2 | 10 / 10 | 14.38 | 12.08…17.35 | 11.57…22.1 | — |
| expert | 3 | 10 / 10 | 19.07 | 17.7…21.78 | 6.93…60.62 | — |
| expert | 4 | 10 / 10 | 17.66 | 11.2…21.18 | 8.42…27.88 | — |
| expert | 5 | 7 / 10 | 29.35 | 20.5…36.07 | 12…52.93 | — |
| expert | 6 | 7 / 7 | 23 | 16.28…25.83 | 14.77…27.2 | — |
| expert | 7 | 6 / 7 | 18.47 | 16.52…21.43 | 10…43.65 | — |
| expert | 8 | 5 / 6 | 19.12 | 18.85…25.45 | 17.38…48.1 | — |
| expert | 9 | 2 / 5 | 28.68 | 27…30.35 | 27…30.35 | — |
| expert | 10 | 0 / 3 | not measured | not measured | not measured | — |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 10 | 10 | 0 | 0 | 0 | 3 × 1, 5 × 9 | stomp × 8, riot_cop × 1, rocket × 1 | 0 |
| average | 10 | 10 | 0 | 0 | 0 | 5 × 4, 6 × 1, 9 × 2, 10 × 3 | stomp × 5, sentry_turret × 2, swat × 2, contractor × 1 | 0 |
| expert | 10 | 10 | 0 | 0 | 0 | 5 × 3, 7 × 1, 8 × 1, 9 × 2, 10 × 3 | rocket × 3, sentry_turret × 2, war_cannon × 2, contractor × 1, shield_robot × 1, stomp × 1 | 0 |

## Timeouts

Runs that reached the wave time limit.

| Outcome | novice | average | expert |
| --- | --- | --- | --- |
| timeout | 0 | 0 | 0 |

## Survival by wave band

Each wave contributes once to each available median. Damage/s needs a timed wave. Repair/s is the configured rate when repair is active. HP coverage counts waves sampled by the bot. Repaired HP sums positive HP steps. The share undone uses waves with positive damage. Multipliers include stat cards taken before the wave.

| Profile | Waves | HP rows / observed | Damage | Damage/s | Repair/s | Minimum HP (% of capacity) | Repaired HP | Damage undone (%) | Guard deflects | Cover ticks | Rolls | damage × | guard_meter × | hp_max × | regen × | speed × |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1–10 | 48 / 48 | 19.2 | 1.11 | 10 | 62.26 | 0 | 0 | 7 | 0 | 2 | 1 | 1 | 1 | 1 | 1 |
| novice | 11–20 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| novice | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| novice | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 1–10 | 74 / 74 | 16.2 | 0.96 | 10 | 73.37 | 0 | 0 | 6 | 0 | 3 | 1.1 | 1 | 1 | 1 | 1 |
| average | 11–20 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 1–10 | 78 / 78 | 18.6 | 0.92 | 10 | 80.72 | 0 | 0 | 8 | 23.5 | 4 | 1.1 | 1 | 1.1 | 1 | 1 |
| expert | 11–20 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 2 | — | 58.44% | 18 (93) | 15.93 (75) |
| patrol_cop | 0 | — | 92.37% | 16.73 (156) | 18.81 (12) |
| riot_cop | 1 | — | 54.54% | 17.47 (87) | 16.28 (81) |
| robot_gunner | 0 | — | 22.16% | 19.62 (31) | 16.12 (137) |
| robot_thug | 0 | — | 20.27% | 21.25 (27) | 16.12 (141) |
| rocket_trooper | 4 | rocket × 4 | 57.7% | 18 (91) | 15.98 (77) |
| sentry_turret | 4 | — | 19.97% | 21.22 (26) | 15.96 (142) |
| shield_robot | 1 | — | 2.61% | 27 (3) | 16.8 (165) |
| swat | 2 | — | 48.97% | 17.62 (81) | 16.68 (87) |
| war_machine | 16 | stomp × 14, war_cannon × 2 | 10.92% | 26.23 (13) | 16.52 (155) |

## Moves

Uses count recorded activations by profile and wave number. The game omits zero counts. Times are medians in seconds, with timed wave counts in parentheses. Carry applies to all waves.

| Profile | Wave | Move | Enemy | Recorded uses | Observed waves | Uses per wave | With enemy s (n) | Without enemy s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | All | ohm_short_circuit | sentry_turret | 0 | 48 | 0 | — | 15.07 (38) |
| novice | All | tonnage_armour_crack | war_machine | 2 | 48 | 0.04 | — | 15.07 (38) |
| novice | All | kerf_blink_behind | shield_robot | 0 | 48 | 0 | — | 15.07 (38) |
| novice | All | overkill_carry | all waves | 0 | 48 | 0 | 15.07 (38) | — |
| novice | 1 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 15.12 (10) |
| novice | 1 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 15.12 (10) |
| novice | 1 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 15.12 (10) |
| novice | 1 | overkill_carry | all waves | 0 | 10 | 0 | 15.12 (10) | — |
| novice | 2 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 14.98 (10) |
| novice | 2 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 14.98 (10) |
| novice | 2 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 14.98 (10) |
| novice | 2 | overkill_carry | all waves | 0 | 10 | 0 | 14.98 (10) | — |
| novice | 3 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 15.47 (9) |
| novice | 3 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 15.47 (9) |
| novice | 3 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 15.47 (9) |
| novice | 3 | overkill_carry | all waves | 0 | 10 | 0 | 15.47 (9) | — |
| novice | 4 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | — | 15.03 (9) |
| novice | 4 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 15.03 (9) |
| novice | 4 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 15.03 (9) |
| novice | 4 | overkill_carry | all waves | 0 | 9 | 0 | 15.03 (9) | — |
| novice | 5 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | — | — |
| novice | 5 | tonnage_armour_crack | war_machine | 2 | 9 | 0.22 | — | — |
| novice | 5 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | — |
| novice | 5 | overkill_carry | all waves | 0 | 9 | 0 | — | — |
| average | All | ohm_short_circuit | sentry_turret | 17 | 74 | 0.23 | 19.73 (13) | 15.28 (50) |
| average | All | tonnage_armour_crack | war_machine | 13 | 74 | 0.18 | 19 (6) | 15.93 (57) |
| average | All | kerf_blink_behind | shield_robot | 0 | 74 | 0 | 22.48 (1) | 16.6 (62) |
| average | All | overkill_carry | all waves | 0 | 74 | 0 | 16.92 (63) | — |
| average | 1 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 14.71 (10) |
| average | 1 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 14.71 (10) |
| average | 1 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 14.71 (10) |
| average | 1 | overkill_carry | all waves | 0 | 10 | 0 | 14.71 (10) | — |
| average | 2 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 15.01 (10) |
| average | 2 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 15.01 (10) |
| average | 2 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 15.01 (10) |
| average | 2 | overkill_carry | all waves | 0 | 10 | 0 | 15.01 (10) | — |
| average | 3 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 16.42 (10) |
| average | 3 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 16.42 (10) |
| average | 3 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 16.42 (10) |
| average | 3 | overkill_carry | all waves | 0 | 10 | 0 | 16.42 (10) | — |
| average | 4 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 13.81 (10) |
| average | 4 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 13.81 (10) |
| average | 4 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 13.81 (10) |
| average | 4 | overkill_carry | all waves | 0 | 10 | 0 | 13.81 (10) | — |
| average | 5 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 19 (6) |
| average | 5 | tonnage_armour_crack | war_machine | 9 | 10 | 0.9 | 19 (6) | — |
| average | 5 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 19 (6) |
| average | 5 | overkill_carry | all waves | 0 | 10 | 0 | 19 (6) | — |
| average | 6 | ohm_short_circuit | sentry_turret | 2 | 6 | 0.33 | 21 (3) | 24.77 (2) |
| average | 6 | tonnage_armour_crack | war_machine | 0 | 6 | 0 | — | 21.25 (5) |
| average | 6 | kerf_blink_behind | shield_robot | 0 | 6 | 0 | — | 21.25 (5) |
| average | 6 | overkill_carry | all waves | 0 | 6 | 0 | 21.25 (5) | — |
| average | 7 | ohm_short_circuit | sentry_turret | 3 | 5 | 0.6 | 19.62 (3) | 13.56 (2) |
| average | 7 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 17.62 (5) |
| average | 7 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 17.62 (5) |
| average | 7 | overkill_carry | all waves | 0 | 5 | 0 | 17.62 (5) | — |
| average | 8 | ohm_short_circuit | sentry_turret | 3 | 5 | 0.6 | 22.93 (5) | — |
| average | 8 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 22.93 (5) |
| average | 8 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 22.93 (5) |
| average | 8 | overkill_carry | all waves | 0 | 5 | 0 | 22.93 (5) | — |
| average | 9 | ohm_short_circuit | sentry_turret | 6 | 5 | 1.2 | 19.87 (2) | — |
| average | 9 | tonnage_armour_crack | war_machine | 2 | 5 | 0.4 | — | 19.87 (2) |
| average | 9 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | 22.48 (1) | 17.25 (1) |
| average | 9 | overkill_carry | all waves | 0 | 5 | 0 | 19.87 (2) | — |
| average | 10 | ohm_short_circuit | sentry_turret | 3 | 3 | 1 | — | — |
| average | 10 | tonnage_armour_crack | war_machine | 2 | 3 | 0.67 | — | — |
| average | 10 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | — | — |
| average | 10 | overkill_carry | all waves | 0 | 3 | 0 | — | — |
| expert | All | ohm_short_circuit | sentry_turret | 13 | 78 | 0.17 | 24.78 (13) | 17.88 (54) |
| expert | All | tonnage_armour_crack | war_machine | 19 | 78 | 0.24 | 29.35 (7) | 18.11 (60) |
| expert | All | kerf_blink_behind | shield_robot | 0 | 78 | 0 | 28.68 (2) | 18.35 (65) |
| expert | All | overkill_carry | all waves | 0 | 78 | 0 | 18.8 (67) | — |
| expert | 1 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 16.31 (10) |
| expert | 1 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 16.31 (10) |
| expert | 1 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 16.31 (10) |
| expert | 1 | overkill_carry | all waves | 0 | 10 | 0 | 16.31 (10) | — |
| expert | 2 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 14.38 (10) |
| expert | 2 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 14.38 (10) |
| expert | 2 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 14.38 (10) |
| expert | 2 | overkill_carry | all waves | 0 | 10 | 0 | 14.38 (10) | — |
| expert | 3 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 19.07 (10) |
| expert | 3 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 19.07 (10) |
| expert | 3 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 19.07 (10) |
| expert | 3 | overkill_carry | all waves | 0 | 10 | 0 | 19.07 (10) | — |
| expert | 4 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 17.66 (10) |
| expert | 4 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 17.66 (10) |
| expert | 4 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 17.66 (10) |
| expert | 4 | overkill_carry | all waves | 0 | 10 | 0 | 17.66 (10) | — |
| expert | 5 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 29.35 (7) |
| expert | 5 | tonnage_armour_crack | war_machine | 15 | 10 | 1.5 | 29.35 (7) | — |
| expert | 5 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 29.35 (7) |
| expert | 5 | overkill_carry | all waves | 0 | 10 | 0 | 29.35 (7) | — |
| expert | 6 | ohm_short_circuit | sentry_turret | 3 | 7 | 0.43 | 25.31 (4) | 19.25 (3) |
| expert | 6 | tonnage_armour_crack | war_machine | 0 | 7 | 0 | — | 23 (7) |
| expert | 6 | kerf_blink_behind | shield_robot | 0 | 7 | 0 | — | 23 (7) |
| expert | 6 | overkill_carry | all waves | 0 | 7 | 0 | 23 (7) | — |
| expert | 7 | ohm_short_circuit | sentry_turret | 1 | 7 | 0.14 | 21.43 (3) | 16.52 (3) |
| expert | 7 | tonnage_armour_crack | war_machine | 0 | 7 | 0 | — | 18.47 (6) |
| expert | 7 | kerf_blink_behind | shield_robot | 0 | 7 | 0 | — | 18.47 (6) |
| expert | 7 | overkill_carry | all waves | 0 | 7 | 0 | 18.47 (6) | — |
| expert | 8 | ohm_short_circuit | sentry_turret | 3 | 6 | 0.5 | 19.12 (5) | — |
| expert | 8 | tonnage_armour_crack | war_machine | 0 | 6 | 0 | — | 19.12 (5) |
| expert | 8 | kerf_blink_behind | shield_robot | 0 | 6 | 0 | — | 19.12 (5) |
| expert | 8 | overkill_carry | all waves | 0 | 6 | 0 | 19.12 (5) | — |
| expert | 9 | ohm_short_circuit | sentry_turret | 4 | 5 | 0.8 | 27 (1) | 30.35 (1) |
| expert | 9 | tonnage_armour_crack | war_machine | 1 | 5 | 0.2 | — | 28.68 (2) |
| expert | 9 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | 28.68 (2) | — |
| expert | 9 | overkill_carry | all waves | 0 | 5 | 0 | 28.68 (2) | — |
| expert | 10 | ohm_short_circuit | sentry_turret | 2 | 3 | 0.67 | — | — |
| expert | 10 | tonnage_armour_crack | war_machine | 3 | 3 | 1 | — | — |
| expert | 10 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | — | — |
| expert | 10 | overkill_carry | all waves | 0 | 3 | 0 | — | — |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| effect_overkill_carry | waves survived | not measured | 1.5 (16) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| effect_overkill_carry | wave s | not measured | 17.77 (13) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| ghost_dent | waves survived | 1.5 (6) | 1 (3) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| ghost_dent | wave s | 20.5 (3) | 17.25 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_kerf | waves survived | 4 (10) | 3 (5) | 4 | -0.5 | -2…0 | not measured (3, all offered) | too few pairs |
| ghost_kerf | wave s | 20 (8) | 19.73 (5) | 4 | 2.28 | -1.33…5.7 | not measured (3, all offered) | too few pairs |
| ghost_ohm | waves survived | 2 (10) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | wave s | 20.74 (9) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_tonnage | waves survived | 3 (16) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| ghost_tonnage | wave s | 17.92 (16) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_10 | waves survived | 3 (23) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_10 | wave s | 17.62 (23) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_25 | waves survived | 1 (9) | 4 (2) | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| stat_damage_25 | wave s | 17.98 (6) | 22.77 (2) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 2 (15) | 3 (12) | 5 | -2 | -5…2 | not measured (4, all offered) | too few pairs |
| stat_guard_meter_10 | wave s | 18.73 (13) | 16.8 (11) | 4 | -1.35 | -27.13…1.77 | not measured (3, all offered) | too few pairs |
| stat_guard_meter_25 | waves survived | 0 (5) | 1 (10) | 3 | -5 | -5…0 | 5 (6, all offered) | noise |
| stat_guard_meter_25 | wave s | 20.56 (2) | 16.87 (8) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 3 (19) | 1 (5) | 0 | not measured | not measured | 2 (8, all offered) | insufficient data |
| stat_hp_max_10 | wave s | 17.25 (15) | 18.17 (5) | 0 | not measured | not measured | 6.2 (8, all offered) | insufficient data |
| stat_hp_max_25 | waves survived | 2 (1) | 3 (3) | 1 | -1 | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_25 | wave s | 22.71 (1) | 19.93 (2) | 1 | 5.33 | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_10 | waves survived | 2 (16) | 3 (6) | 3 | 0 | -2…4 | not measured (3, all offered) | too few pairs |
| stat_regen_10 | wave s | 19.61 (14) | 15.13 (6) | 3 | 10.87 | -9.65…12.32 | not measured (3, all offered) | too few pairs |
| stat_regen_25 | waves survived | 0 (3) | 3 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | wave s | 34.61 (1) | 19.66 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | waves survived | 2 (14) | 2 (10) | 9 | 0 | -3…4 | not measured (3, all offered) | too few pairs |
| stat_speed_10 | wave s | 17.47 (13) | 20 (6) | 5 | -1.05 | -5.87…0.07 | not measured (2, all offered) | too few pairs |
| stat_speed_25 | waves survived | not measured | 1 (9) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_25 | wave s | not measured | 17.68 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_chainsaw | waves survived | not measured | 1 (9) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_chainsaw | wave s | not measured | 18.92 (6) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_electro_baton | waves survived | 6 (3) | 3 (16) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | wave s | 18.85 (3) | 19.26 (13) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | waves survived | 4 (1) | 3 (7) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_flamethrower | wave s | 37 (1) | 17.91 (7) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_gatling | waves survived | 1 (4) | 1 (2) | 2 | 0 | 0…0 | not measured (2, all offered) | too few pairs |
| weapon_gatling | wave s | 43.65 (1) | 24.74 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gloria | waves survived | 2 (2) | 2.5 (18) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_gloria | wave s | 23.04 (2) | 17.28 (16) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | not measured | 2 (19) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_hand_cannon | wave s | not measured | 21.34 (14) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_katana | waves survived | 2 (1) | 4 (18) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_katana | wave s | 39.23 (1) | 18.75 (18) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_machine_pistol | waves survived | not measured | 2.5 (18) | 0 | not measured | not measured | 2 (6, decliners) | insufficient data |
| weapon_machine_pistol | wave s | not measured | 19.52 (17) | 0 | not measured | not measured | 12.03 (6, decliners) | insufficient data |
| weapon_pistol | waves survived | 4 (5) | 2 (12) | 3 | 5 | 0…5 | not measured (5, all offered) | too few pairs |
| weapon_pistol | wave s | 15.6 (4) | 17.54 (8) | 3 | 2.73 | -7.98…3.39 | not measured (5, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | not measured | 5 (12) | 0 | not measured | not measured | 1 (6, decliners) | insufficient data |
| weapon_plasma_rifle | wave s | not measured | 19.12 (12) | 0 | not measured | not measured | 7.3 (6, decliners) | insufficient data |
| weapon_plasma_sword | waves survived | 2 (1) | 1 (11) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| weapon_plasma_sword | wave s | 17.77 (1) | 26.01 (6) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_rocket_launcher | waves survived | 0 (4) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_rocket_launcher | wave s | 25.45 (1) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | not measured | 1 (9) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| chainsaw | wave s | not measured | 18.92 (6) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| electro_baton | waves survived | 6 (3) | 3 (16) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | wave s | 18.85 (3) | 19.26 (13) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | waves survived | 4 (1) | 3 (7) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| flamethrower | wave s | 37 (1) | 17.91 (7) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| gatling | waves survived | 1 (4) | 1 (2) | 2 | 0 | 0…0 | not measured (2, all offered) | too few pairs |
| gatling | wave s | 43.65 (1) | 24.74 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gloria | waves survived | 2 (2) | 2.5 (18) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| gloria | wave s | 23.04 (2) | 17.28 (16) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| hand_cannon | waves survived | not measured | 2 (19) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| hand_cannon | wave s | not measured | 21.34 (14) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| katana | waves survived | 2 (1) | 4 (18) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| katana | wave s | 39.23 (1) | 18.75 (18) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| machine_pistol | waves survived | not measured | 2.5 (18) | 0 | not measured | not measured | 2 (6, decliners) | insufficient data |
| machine_pistol | wave s | not measured | 19.52 (17) | 0 | not measured | not measured | 12.03 (6, decliners) | insufficient data |
| pistol | waves survived | 4 (5) | 2 (12) | 3 | 5 | 0…5 | not measured (5, all offered) | too few pairs |
| pistol | wave s | 15.6 (4) | 17.54 (8) | 3 | 2.73 | -7.98…3.39 | not measured (5, all offered) | too few pairs |
| plasma_rifle | waves survived | not measured | 5 (12) | 0 | not measured | not measured | 1 (6, decliners) | insufficient data |
| plasma_rifle | wave s | not measured | 19.12 (12) | 0 | not measured | not measured | 7.3 (6, decliners) | insufficient data |
| plasma_sword | waves survived | 2 (1) | 1 (11) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| plasma_sword | wave s | 17.77 (1) | 26.01 (6) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| rocket_launcher | waves survived | 0 (4) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| rocket_launcher | wave s | 25.45 (1) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | rivet s (n) |
| --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 8 (10) | 2 (10) | 0 (10) | 13 (10) | 15.12 (10) |
| novice | 2 | 8.5 (10) | 2 (10) | 0 (10) | 14 (10) | 14.98 (10) |
| novice | 3 | 7 (10) | 2 (10) | 0 (10) | 12 (10) | 15.8 (10) |
| novice | 4 | 6 (9) | 2 (9) | 0 (9) | 12 (9) | 15.03 (9) |
| novice | 5 | 2 (9) | 0 (9) | 0 (9) | 8 (9) | 6.97 (9) |
| average | 1 | 7.5 (10) | 3 (10) | 0 (10) | 13 (10) | 14.71 (10) |
| average | 2 | 6.5 (10) | 2 (10) | 0 (10) | 14 (10) | 15.01 (10) |
| average | 3 | 6.5 (10) | 3.5 (10) | 0 (10) | 12 (10) | 16.41 (10) |
| average | 4 | 6.5 (10) | 2 (10) | 0 (10) | 12 (10) | 13.81 (10) |
| average | 5 | 2 (10) | 3 (10) | 0 (10) | 17.5 (10) | 17.73 (10) |
| average | 6 | 5 (6) | 3 (6) | 0 (6) | 28 (6) | 21.13 (6) |
| average | 7 | 10 (5) | 4 (5) | 0 (5) | 25 (5) | 17.62 (5) |
| average | 8 | 6 (5) | 3 (5) | 0 (5) | 35 (5) | 22.93 (5) |
| average | 9 | 6 (5) | 1 (5) | 32 (5) | 27 (5) | 17.25 (5) |
| average | 10 | 2 (3) | 2 (3) | 23 (3) | 21 (3) | 17.98 (3) |
| expert | 1 | 9.5 (10) | 3 (10) | 0 (10) | 13 (10) | 16.31 (10) |
| expert | 2 | 8 (10) | 3 (10) | 0 (10) | 14 (10) | 14.38 (10) |
| expert | 3 | 7 (10) | 7 (10) | 0 (10) | 12 (10) | 19.06 (10) |
| expert | 4 | 8 (10) | 4 (10) | 0 (10) | 12 (10) | 17.66 (10) |
| expert | 5 | 2 (10) | 6.5 (10) | 0 (10) | 17.5 (10) | 27.79 (10) |
| expert | 6 | 8 (7) | 7 (7) | 0 (7) | 28 (7) | 23 (7) |
| expert | 7 | 6 (7) | 7 (7) | 0 (7) | 27 (7) | 17.07 (7) |
| expert | 8 | 8 (6) | 3 (6) | 4 (6) | 34 (6) | 18.98 (6) |
| expert | 9 | 6 (5) | 3 (5) | 34 (5) | 42 (5) | 27 (5) |
| expert | 10 | 0 (3) | 0 (3) | 24 (3) | 31 (3) | 18.32 (3) |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 3 | 5 | 2.21 | stat_hp_max_10 → weapon_pistol → stat_damage_10 → stat_guard_meter_10 | pistol | rivet | node tools/dev/run.mjs gauntlet --seed=3 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| novice | 8 | 5 | 2.21 | stat_hp_max_10 → ghost_tonnage → weapon_electro_baton → stat_regen_10 | electro_baton | rivet | node tools/dev/run.mjs gauntlet --seed=8 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| novice | 1 | 5 | 1.21 | ghost_tonnage → stat_hp_max_10 → stat_damage_10 → ghost_dent | none | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| average | 3 | 10 | 2.21 | stat_hp_max_10 → weapon_pistol → stat_damage_10 → stat_guard_meter_10 → stat_regen_10 → ghost_tonnage → weapon_gloria → ghost_ohm → weapon_rocket_launcher | gloria, pistol, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=3 --bot=average --pick=greedy --controls=wheel --waves=40 |
| average | 5 | 10 | 2.21 | stat_speed_10 → stat_guard_meter_10 → stat_damage_10 → ghost_kerf → weapon_pistol → ghost_ohm → weapon_plasma_sword → stat_hp_max_10 → weapon_gatling | gatling, pistol, plasma_sword | rivet | node tools/dev/run.mjs gauntlet --seed=5 --bot=average --pick=greedy --controls=wheel --waves=40 |
| average | 8 | 10 | 2.21 | stat_hp_max_10 → ghost_tonnage → weapon_electro_baton → stat_regen_10 → ghost_ohm → stat_guard_meter_25 → stat_speed_10 → weapon_gatling | electro_baton, gatling | rivet | node tools/dev/run.mjs gauntlet --seed=8 --bot=average --pick=greedy --controls=wheel --waves=40 |
| expert | 1 | 10 | 2.21 | ghost_tonnage → stat_hp_max_10 → stat_damage_10 → ghost_dent → weapon_flamethrower → weapon_gatling → weapon_katana → ghost_kerf → weapon_pistol | flamethrower, gatling, katana, pistol | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=expert --pick=greedy --controls=wheel --waves=40 |
| expert | 3 | 10 | 2.21 | stat_hp_max_10 → weapon_pistol → stat_damage_10 → stat_guard_meter_10 → stat_regen_10 → ghost_tonnage → weapon_gloria → ghost_ohm → weapon_rocket_launcher | gloria, pistol, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=3 --bot=expert --pick=greedy --controls=wheel --waves=40 |
| expert | 8 | 10 | 2.21 | stat_hp_max_10 → ghost_tonnage → weapon_electro_baton → stat_regen_10 → ghost_ohm → stat_guard_meter_25 → stat_speed_10 → weapon_gatling | electro_baton, gatling | rivet | node tools/dev/run.mjs gauntlet --seed=8 --bot=expert --pick=greedy --controls=wheel --waves=40 |
