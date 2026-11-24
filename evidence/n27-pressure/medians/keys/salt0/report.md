# Gauntlet run report

30 of 30 runs accepted. Average-profile waves 5 (23.53 s), 6 (22.28 s), 7 (19.1 s), 8 (21.77 s), 9 (22.98 s) fell outside 12–18 s for ordinary waves and 25–30 s for boss waves.

Live gauntlet batch · detached @ e403c4a4024a · 2026-11-24T02:56:13.506Z.

Stalled runs by profile: novice 0, average 0, expert 0.

Capped alive by profile: novice 0, average 0, expert 0.

## Death-wave score

Censored runs contribute their last reached wave as a lower bound to the median and spread.

| Profile | Target | Median wave | P25–P75 | Min–max | Deaths / censored |
| --- | --- | --- | --- | --- | --- |
| novice | 6 | 5 | 5–5 | 3–5 | 10 / 0 |
| average | 12 | 6 | 5–10 | 5–10 | 10 / 0 |
| expert | 20 | 8.5 | 8–11 | 3–12 | 10 / 0 |

## Profile separation

Targets require a median gap of 3 waves and a later death on at least 75% of shared seeds with the same controls and pick policy. Unresolved censored pairs stay in the denominator.

| Profiles | Observed median gap | Later / shared seeds | Confirmed later share | Unresolved | Verdict |
| --- | --- | --- | --- | --- | --- |
| novice → average | 1 | 6 / 10 | 60% | 0 | below target |
| novice → expert | 3.5 | 9 / 10 | 90% | 0 | separated |
| average → expert | 2.5 | 7 / 10 | 70% | 0 | below target |

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
| average | 6 | died on 7 | 0 | 1 |
| average | 7 | died on 9 | 0 | 1 |
| average | 8 | died on 10 | 0 | 1 |
| average | 9 | died on 5 | 0 | 1 |
| average | 10 | died on 5 | 0 | 1 |
| expert | 1 | died on 9 | 0 | 1 |
| expert | 2 | died on 9 | 0 | 1 |
| expert | 3 | died on 11 | 0 | 1 |
| expert | 4 | died on 8 | 2 | 3 |
| expert | 5 | died on 12 | 0 | 1 |
| expert | 6 | died on 7 | 0 | 1 |
| expert | 7 | died on 8 | 0 | 1 |
| expert | 8 | died on 12 | 0 | 1 |
| expert | 9 | died on 3 | 0 | 1 |
| expert | 10 | died on 8 | 0 | 1 |

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
| average | 4 | 10 / 10 | 16.16 | 12.63…19.55 | 8.83…25.37 | within target |
| average | 5 | 5 / 10 | 23.53 | 17.7…24.5 | 17.63…25.05 | miss |
| average | 6 | 5 / 5 | 22.28 | 19.37…25.17 | 18.67…29.17 | miss |
| average | 7 | 4 / 5 | 19.1 | 16.25…32.87 | 12.92…32.87 | miss |
| average | 8 | 4 / 4 | 21.77 | 18.9…37.1 | 15.37…37.1 | miss |
| average | 9 | 3 / 4 | 22.98 | 17.67…23.85 | 17.67…23.85 | miss |
| average | 10 | 0 / 3 | not measured | not measured | not measured | not measured |
| expert | 1 | 10 / 10 | 16.31 | 13.4…18.35 | 13.02…22.67 | — |
| expert | 2 | 10 / 10 | 14.38 | 12.08…17.35 | 11.57…22.1 | — |
| expert | 3 | 9 / 10 | 19.7 | 18.05…21.78 | 6.93…36.67 | — |
| expert | 4 | 9 / 9 | 15.73 | 11.2…25.03 | 8.42…34.48 | — |
| expert | 5 | 9 / 9 | 29.05 | 25.2…36.07 | 12…38.88 | — |
| expert | 6 | 8 / 9 | 20.8 | 15.32…22 | 12.92…28.37 | — |
| expert | 7 | 7 / 9 | 18.22 | 11.8…20.73 | 10.23…26.75 | — |
| expert | 8 | 5 / 8 | 15.07 | 13.07…19.13 | 12.77…21.4 | — |
| expert | 9 | 3 / 5 | 22.8 | 13.37…25.35 | 13.37…25.35 | — |
| expert | 10 | 3 / 3 | 21.68 | 20.97…24.68 | 20.97…24.68 | — |
| expert | 11 | 2 / 3 | 25.67 | 16.93…34.4 | 16.93…34.4 | — |
| expert | 12 | 0 / 2 | not measured | not measured | not measured | — |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 10 | 10 | 0 | 0 | 0 | 3 × 1, 5 × 9 | stomp × 7, patrol_cop × 1, riot_cop × 1, swat × 1 | 0 |
| average | 10 | 10 | 0 | 0 | 0 | 5 × 5, 7 × 1, 9 × 1, 10 × 3 | stomp × 5, swat × 2, robot_thug × 1, rocket × 1, sentry_turret × 1 | 0 |
| expert | 10 | 10 | 0 | 0 | 0 | 3 × 1, 7 × 1, 8 × 3, 9 × 2, 11 × 1, 12 × 2 | sentry_turret × 3, shield_robot × 3, patrol_cop × 1, riot_cop × 1, robot_gunner × 1, swat × 1 | 0 |

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
| average | 1–10 | 71 / 71 | 18.22 | 0.96 | 10 | 71.2 | 0 | 0 | 6 | 0 | 3 | 1.1 | 1 | 1 | 1 | 1 |
| average | 11–20 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 1–10 | 82 / 82 | 18.12 | 0.89 | 10 | 81.4 | 0 | 0 | 6.5 | 19 | 4 | 1.1 | 1 | 1 | 1 | 1 |
| expert | 11–20 | 5 / 5 | 110 | 2.17 | 11 | 0 | 0 | 0 | 4 | 49 | 2 | 1.1 | 1.1 | 1.1 | 1.1 | 1 |
| expert | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 0 | — | 61.67% | 19 (99) | 15.4 (75) |
| patrol_cop | 2 | — | 88.23% | 16.8 (157) | 20.98 (17) |
| riot_cop | 2 | — | 55.49% | 18.44 (92) | 16.2 (82) |
| robot_gunner | 1 | — | 21.93% | 19.44 (34) | 16.53 (140) |
| robot_thug | 1 | — | 21.08% | 19.44 (34) | 16.73 (140) |
| rocket_trooper | 1 | rocket × 1 | 58.47% | 19 (95) | 15.85 (79) |
| sentry_turret | 4 | — | 21.51% | 20.86 (32) | 16.38 (142) |
| shield_robot | 3 | — | 4.06% | 24.68 (5) | 16.92 (169) |
| swat | 4 | — | 48.08% | 17.86 (84) | 16.78 (90) |
| war_machine | 12 | stomp × 12 | 13.37% | 24.68 (17) | 16.77 (157) |

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
| average | All | ohm_short_circuit | sentry_turret | 19 | 71 | 0.27 | 22.47 (12) | 16.92 (49) |
| average | All | tonnage_armour_crack | war_machine | 8 | 71 | 0.11 | 23.53 (5) | 17.07 (56) |
| average | All | kerf_blink_behind | shield_robot | 0 | 71 | 0 | 23.85 (1) | 17.65 (60) |
| average | All | overkill_carry | all waves | 0 | 71 | 0 | 17.67 (61) | — |
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
| average | 4 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 16.16 (10) |
| average | 4 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 16.16 (10) |
| average | 4 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 16.16 (10) |
| average | 4 | overkill_carry | all waves | 0 | 10 | 0 | 16.16 (10) | — |
| average | 5 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 23.53 (5) |
| average | 5 | tonnage_armour_crack | war_machine | 7 | 10 | 0.7 | 23.53 (5) | — |
| average | 5 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 23.53 (5) |
| average | 5 | overkill_carry | all waves | 0 | 10 | 0 | 23.53 (5) | — |
| average | 6 | ohm_short_circuit | sentry_turret | 3 | 5 | 0.6 | 19.37 (3) | 23.73 (2) |
| average | 6 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 22.28 (5) |
| average | 6 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 22.28 (5) |
| average | 6 | overkill_carry | all waves | 0 | 5 | 0 | 22.28 (5) | — |
| average | 7 | ohm_short_circuit | sentry_turret | 1 | 5 | 0.2 | 27.41 (2) | 14.58 (2) |
| average | 7 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 19.1 (4) |
| average | 7 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 19.1 (4) |
| average | 7 | overkill_carry | all waves | 0 | 5 | 0 | 19.1 (4) | — |
| average | 8 | ohm_short_circuit | sentry_turret | 6 | 4 | 1.5 | 21.77 (4) | — |
| average | 8 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 21.77 (4) |
| average | 8 | kerf_blink_behind | shield_robot | 0 | 4 | 0 | — | 21.77 (4) |
| average | 8 | overkill_carry | all waves | 0 | 4 | 0 | 21.77 (4) | — |
| average | 9 | ohm_short_circuit | sentry_turret | 7 | 4 | 1.75 | 22.98 (3) | — |
| average | 9 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 22.98 (3) |
| average | 9 | kerf_blink_behind | shield_robot | 0 | 4 | 0 | 23.85 (1) | 20.32 (2) |
| average | 9 | overkill_carry | all waves | 0 | 4 | 0 | 22.98 (3) | — |
| average | 10 | ohm_short_circuit | sentry_turret | 2 | 3 | 0.67 | — | — |
| average | 10 | tonnage_armour_crack | war_machine | 1 | 3 | 0.33 | — | — |
| average | 10 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | — | — |
| average | 10 | overkill_carry | all waves | 0 | 3 | 0 | — | — |
| expert | All | ohm_short_circuit | sentry_turret | 20 | 87 | 0.23 | 20.67 (20) | 17.35 (55) |
| expert | All | tonnage_armour_crack | war_machine | 11 | 87 | 0.13 | 25.54 (12) | 17.35 (63) |
| expert | All | kerf_blink_behind | shield_robot | 0 | 87 | 0 | 25.02 (4) | 18.17 (71) |
| expert | All | overkill_carry | all waves | 0 | 87 | 0 | 18.35 (75) | — |
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
| expert | 5 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | — | 29.05 (9) |
| expert | 5 | tonnage_armour_crack | war_machine | 8 | 9 | 0.89 | 29.05 (9) | — |
| expert | 5 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 29.05 (9) |
| expert | 5 | overkill_carry | all waves | 0 | 9 | 0 | 29.05 (9) | — |
| expert | 6 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | 20.62 (5) | 21.25 (3) |
| expert | 6 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 20.8 (8) |
| expert | 6 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 20.8 (8) |
| expert | 6 | overkill_carry | all waves | 0 | 9 | 0 | 20.8 (8) | — |
| expert | 7 | ohm_short_circuit | sentry_turret | 2 | 9 | 0.22 | 20.13 (4) | 11.8 (3) |
| expert | 7 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 18.22 (7) |
| expert | 7 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 18.22 (7) |
| expert | 7 | overkill_carry | all waves | 0 | 9 | 0 | 18.22 (7) | — |
| expert | 8 | ohm_short_circuit | sentry_turret | 6 | 8 | 0.75 | 15.07 (5) | — |
| expert | 8 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 15.07 (5) |
| expert | 8 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | — | 15.07 (5) |
| expert | 8 | overkill_carry | all waves | 0 | 8 | 0 | 15.07 (5) | — |
| expert | 9 | ohm_short_circuit | sentry_turret | 7 | 5 | 1.4 | 22.8 (3) | — |
| expert | 9 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 22.8 (3) |
| expert | 9 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | 25.35 (1) | 18.08 (2) |
| expert | 9 | overkill_carry | all waves | 0 | 5 | 0 | 22.8 (3) | — |
| expert | 10 | ohm_short_circuit | sentry_turret | 3 | 3 | 1 | 23.18 (2) | 20.97 (1) |
| expert | 10 | tonnage_armour_crack | war_machine | 3 | 3 | 1 | 21.68 (3) | — |
| expert | 10 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | 22.83 (2) | 21.68 (1) |
| expert | 10 | overkill_carry | all waves | 0 | 3 | 0 | 21.68 (3) | — |
| expert | 11 | ohm_short_circuit | sentry_turret | 1 | 3 | 0.33 | 34.4 (1) | 16.93 (1) |
| expert | 11 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 25.67 (2) |
| expert | 11 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | 34.4 (1) | 16.93 (1) |
| expert | 11 | overkill_carry | all waves | 0 | 3 | 0 | 25.67 (2) | — |
| expert | 12 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | — | — |
| expert | 12 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | — |
| expert | 12 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | — |
| expert | 12 | overkill_carry | all waves | 0 | 2 | 0 | — | — |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| effect_overkill_carry | waves survived | not measured | 3 (12) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| effect_overkill_carry | wave s | not measured | 18.84 (12) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| ghost_dent | waves survived | 1 (5) | 1 (3) | 1 | 1 | not measured | not measured (1, all offered) | too few pairs |
| ghost_dent | wave s | 25.88 (4) | 19.68 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_kerf | waves survived | 4 (11) | 2.5 (4) | 2 | -2 | -4…0 | not measured (3, all offered) | too few pairs |
| ghost_kerf | wave s | 19.52 (9) | 21.25 (4) | 2 | 3.35 | -0.38…7.07 | not measured (3, all offered) | too few pairs |
| ghost_ohm | waves survived | 2 (11) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| ghost_ohm | wave s | 21.89 (9) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| ghost_tonnage | waves survived | 3 (16) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| ghost_tonnage | wave s | 18.67 (15) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| master_ohm | waves survived | 1 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| master_ohm | wave s | 20.14 (4) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| master_tonnage | waves survived | 1 (9) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| master_tonnage | wave s | 19 (7) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_damage_10 | waves survived | 3 (23) | 1 (2) | 2 | 2.5 | 0…5 | not measured (3, all offered) | too few pairs |
| stat_damage_10 | wave s | 18.68 (23) | 10.42 (2) | 2 | 12.94 | 5.88…20 | not measured (3, all offered) | too few pairs |
| stat_damage_25 | waves survived | 1 (8) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_25 | wave s | 22.79 (6) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 2 (14) | 3 (15) | 6 | 1 | 0…4 | 9 (6, all offered) | noise |
| stat_guard_meter_10 | wave s | 19.37 (11) | 17.12 (13) | 4 | 1.37 | -4.17…5.95 | not measured (4, all offered) | too few pairs |
| stat_guard_meter_25 | waves survived | 0 (3) | 3 (10) | 3 | -3 | -5…0 | 5 (6, all offered) | noise |
| stat_guard_meter_25 | wave s | 38.88 (1) | 18.79 (8) | 1 | 22.86 | not measured | not measured (4, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 3 (16) | 1 (7) | 0 | not measured | not measured | 2 (8, all offered) | insufficient data |
| stat_hp_max_10 | wave s | 17.98 (14) | 17.56 (6) | 0 | not measured | not measured | 6.62 (8, all offered) | insufficient data |
| stat_hp_max_25 | waves survived | 2 (1) | 2.5 (4) | 1 | 0 | not measured | not measured (1, all offered) | too few pairs |
| stat_hp_max_25 | wave s | 29.54 (1) | 19.68 (4) | 1 | 10.23 | not measured | not measured (1, all offered) | too few pairs |
| stat_regen_10 | waves survived | 2 (13) | 3 (8) | 3 | 3 | 0…4 | not measured (2, all offered) | too few pairs |
| stat_regen_10 | wave s | 20.22 (10) | 15.15 (7) | 2 | 10.6 | 9.07…12.12 | not measured (1, all offered) | too few pairs |
| stat_regen_25 | waves survived | 1 (4) | 2 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | wave s | 22.69 (2) | 22.79 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | waves survived | 3 (13) | 2.5 (8) | 6 | 1.5 | 0…5 | not measured (3, all offered) | too few pairs |
| stat_speed_10 | wave s | 18.68 (11) | 21.51 (6) | 4 | -2.78 | -3.77…1.64 | not measured (1, all offered) | too few pairs |
| stat_speed_25 | waves survived | not measured | 1 (10) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_25 | wave s | not measured | 18.59 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_chainsaw | waves survived | 0 (1) | 1 (9) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_chainsaw | wave s | not measured | 15.15 (5) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_electro_baton | waves survived | 6 (3) | 2 (15) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | wave s | 20.67 (3) | 20.85 (12) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | waves survived | not measured | 3 (9) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | wave s | not measured | 19.31 (9) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gatling | waves survived | 1 (3) | 3 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gatling | wave s | 18.88 (2) | 19.52 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gloria | waves survived | 3 (3) | 3 (18) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_gloria | wave s | 20.97 (3) | 18.52 (15) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | not measured | 2 (16) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_hand_cannon | wave s | not measured | 20.97 (13) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_katana | waves survived | not measured | 4 (19) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_katana | wave s | not measured | 19.37 (19) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_machine_pistol | waves survived | 4 (1) | 4 (16) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| weapon_machine_pistol | wave s | 19.88 (1) | 19.13 (15) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| weapon_pistol | waves survived | 6 (5) | 3 (9) | 4 | 3 | 0…5 | not measured (4, all offered) | too few pairs |
| weapon_pistol | wave s | 17.7 (5) | 17.18 (8) | 4 | -0.8 | -12.57…4.2 | not measured (4, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | not measured | 4 (15) | 0 | not measured | not measured | 1 (6, decliners) | insufficient data |
| weapon_plasma_rifle | wave s | not measured | 20.67 (13) | 0 | not measured | not measured | 7.76 (6, decliners) | insufficient data |
| weapon_plasma_sword | waves survived | 3 (2) | 1 (10) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_plasma_sword | wave s | 17.91 (2) | 21.86 (5) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_rocket_launcher | waves survived | 0.5 (4) | 1 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_rocket_launcher | wave s | 22.98 (1) | 20.97 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | 0 (1) | 1 (9) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| chainsaw | wave s | not measured | 15.15 (5) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| electro_baton | waves survived | 6 (3) | 2 (15) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | wave s | 20.67 (3) | 20.85 (12) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | waves survived | not measured | 3 (9) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | wave s | not measured | 19.31 (9) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gatling | waves survived | 1 (3) | 3 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gatling | wave s | 18.88 (2) | 19.52 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gloria | waves survived | 3 (3) | 3 (18) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| gloria | wave s | 20.97 (3) | 18.52 (15) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| hand_cannon | waves survived | not measured | 2 (16) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| hand_cannon | wave s | not measured | 20.97 (13) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| katana | waves survived | not measured | 4 (19) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| katana | wave s | not measured | 19.37 (19) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| machine_pistol | waves survived | 4 (1) | 4 (16) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| machine_pistol | wave s | 19.88 (1) | 19.13 (15) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| pistol | waves survived | 6 (5) | 3 (9) | 4 | 3 | 0…5 | not measured (4, all offered) | too few pairs |
| pistol | wave s | 17.7 (5) | 17.18 (8) | 4 | -0.8 | -12.57…4.2 | not measured (4, all offered) | too few pairs |
| plasma_rifle | waves survived | not measured | 4 (15) | 0 | not measured | not measured | 1 (6, decliners) | insufficient data |
| plasma_rifle | wave s | not measured | 20.67 (13) | 0 | not measured | not measured | 7.76 (6, decliners) | insufficient data |
| plasma_sword | waves survived | 3 (2) | 1 (10) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| plasma_sword | wave s | 17.91 (2) | 21.86 (5) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| rocket_launcher | waves survived | 0.5 (4) | 1 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| rocket_launcher | wave s | 22.98 (1) | 20.97 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | ohm s (n) | rivet s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 8 (10) | 2 (10) | 0 (10) | 13 (10) | not measured | 15.12 (10) | not measured |
| novice | 2 | 8.5 (10) | 2 (10) | 0 (10) | 14 (10) | not measured | 14.98 (10) | not measured |
| novice | 3 | 6.5 (10) | 2 (10) | 0 (10) | 13 (10) | not measured | 16.96 (10) | not measured |
| novice | 4 | 6 (9) | 2 (9) | 0 (9) | 14 (9) | not measured | 15.15 (9) | not measured |
| novice | 5 | 1 (9) | 1 (9) | 0 (9) | 8 (9) | not measured | 6.43 (9) | 5.31 (2) |
| average | 1 | 7.5 (10) | 3 (10) | 0 (10) | 13 (10) | not measured | 14.71 (10) | not measured |
| average | 2 | 6.5 (10) | 2 (10) | 0 (10) | 14 (10) | not measured | 15.01 (10) | not measured |
| average | 3 | 5.5 (10) | 6 (10) | 0 (10) | 15 (10) | not measured | 17.04 (10) | not measured |
| average | 4 | 6 (10) | 4 (10) | 0 (10) | 14 (10) | not measured | 16.16 (10) | 6.42 (1) |
| average | 5 | 2 (10) | 5.5 (10) | 0 (10) | 20.5 (10) | not measured | 18.13 (10) | 4.98 (3) |
| average | 6 | 7 (5) | 2 (5) | 0 (5) | 34 (5) | not measured | 22.28 (5) | 0.03 (1) |
| average | 7 | 5 (5) | 3 (5) | 0 (5) | 30 (5) | not measured | 16.25 (5) | 0.02 (1) |
| average | 8 | 6 (4) | 6 (4) | 16.5 (4) | 34.5 (4) | 7.3 (1) | 18.13 (4) | not measured |
| average | 9 | 6 (4) | 2 (4) | 21.5 (4) | 36 (4) | 1.27 (2) | 15.51 (4) | 7.1 (1) |
| average | 10 | 0 (3) | 1 (3) | 8 (3) | 13 (3) | 0.02 (2) | 13.77 (3) | not measured |
| expert | 1 | 9.5 (10) | 3 (10) | 0 (10) | 13 (10) | not measured | 16.31 (10) | not measured |
| expert | 2 | 8 (10) | 3 (10) | 0 (10) | 14 (10) | not measured | 14.38 (10) | not measured |
| expert | 3 | 7.5 (10) | 7 (10) | 0 (10) | 13.5 (10) | not measured | 20.11 (10) | 7.1 (1) |
| expert | 4 | 7 (9) | 6 (9) | 0 (9) | 14 (9) | not measured | 15.73 (9) | not measured |
| expert | 5 | 3 (9) | 4 (9) | 0 (9) | 23 (9) | not measured | 25.88 (9) | 6.64 (2) |
| expert | 6 | 6 (9) | 6 (9) | 0 (9) | 33 (9) | not measured | 20.62 (9) | 7.1 (1) |
| expert | 7 | 6 (9) | 4 (9) | 0 (9) | 29 (9) | not measured | 18.75 (9) | not measured |
| expert | 8 | 4.5 (8) | 3.5 (8) | 29.5 (8) | 33 (8) | not measured | 17.23 (8) | 3.49 (2) |
| expert | 9 | 2 (5) | 4 (5) | 29 (5) | 38 (5) | not measured | 14.42 (5) | 4.71 (2) |
| expert | 10 | 2 (3) | 7 (3) | 39 (3) | 47 (3) | 0.3 (2) | 20.92 (3) | 7.1 (1) |
| expert | 11 | 7 (3) | 10 (3) | 39 (3) | 62 (3) | 0.76 (2) | 23.38 (3) | 7.1 (1) |
| expert | 12 | 0 (2) | 0.5 (2) | 11.5 (2) | 16 (2) | not measured | 13.17 (2) | 0.95 (1) |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 3 | 5 | 2.21 | stat_hp_max_10 → weapon_pistol → stat_damage_10 → stat_guard_meter_10 | pistol | rivet | node tools/dev/run.mjs gauntlet --seed=3 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| novice | 8 | 5 | 2.21 | stat_hp_max_10 → ghost_tonnage → weapon_electro_baton → stat_regen_10 | electro_baton | rivet | node tools/dev/run.mjs gauntlet --seed=8 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| novice | 1 | 5 | 1.21 | ghost_tonnage → stat_hp_max_10 → master_tonnage → stat_guard_meter_10 | none | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| average | 3 | 10 | 2.21 | stat_hp_max_10 → weapon_pistol → stat_damage_10 → stat_guard_meter_10 → stat_regen_10 → ghost_tonnage → weapon_gloria → ghost_ohm → weapon_rocket_launcher | gloria, pistol, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=3 --bot=average --pick=greedy --controls=wheel --waves=40 |
| average | 5 | 10 | 2.21 | stat_speed_10 → stat_guard_meter_10 → stat_damage_10 → ghost_kerf → weapon_pistol → ghost_ohm → weapon_plasma_sword → master_ohm → weapon_rocket_launcher | pistol, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=5 --bot=average --pick=greedy --controls=wheel --waves=40 |
| average | 8 | 10 | 2.21 | stat_hp_max_10 → ghost_tonnage → weapon_electro_baton → master_tonnage → ghost_ohm → stat_damage_10 → master_ohm → weapon_rocket_launcher → ghost_kerf | electro_baton, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=8 --bot=average --pick=greedy --controls=wheel --waves=40 |
| expert | 5 | 12 | 2.21 | stat_speed_10 → stat_guard_meter_10 → stat_damage_10 → ghost_kerf → weapon_pistol → ghost_ohm → weapon_plasma_sword → stat_hp_max_10 → master_ohm → ghost_tonnage → stat_damage_25 | pistol, plasma_sword | rivet | node tools/dev/run.mjs gauntlet --seed=5 --bot=expert --pick=greedy --controls=wheel --waves=40 |
| expert | 8 | 12 | 2.21 | stat_hp_max_10 → ghost_tonnage → weapon_electro_baton → stat_regen_10 → master_tonnage → stat_damage_10 → weapon_machine_pistol → weapon_gatling → stat_hp_max_25 → ghost_dent → ghost_ohm | electro_baton, gatling, machine_pistol | rivet | node tools/dev/run.mjs gauntlet --seed=8 --bot=expert --pick=greedy --controls=wheel --waves=40 |
