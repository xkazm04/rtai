# Gauntlet run report

15 of 15 runs accepted. Average-profile waves 1 (10.88 s), 5 (13.82 s), 6 (21.5 s), 7 (21.52 s), 8 (22.7 s), 9 (19.47 s), 10 (18.5 s), 11 (19.03 s), 12 (24.72 s), 13 (20.98 s), 14 (24.62 s) fell outside 12–18 s for ordinary waves and 25–30 s for boss waves.

Live gauntlet batch · detached @ 032f6de91bb6 · 2026-11-22T20:06:58.455Z.

Stalled runs by profile: novice 0, average 0, expert 0.

Capped alive by profile: novice 0, average 0, expert 0.

## Death-wave score

Censored runs contribute their last reached wave as a lower bound to the median and spread.

| Profile | Target | Median wave | P25–P75 | Min–max | Deaths / censored |
| --- | --- | --- | --- | --- | --- |
| novice | 6 | 5 | 5–5 | 5–5 | 5 / 0 |
| average | 12 | 10 | 5–15 | 5–15 | 5 / 0 |
| expert | 20 | 12 | 5–12 | 3–32 | 5 / 0 |

## Profile separation

Targets require a median gap of 3 waves and a later death on at least 75% of shared seeds with the same controls and pick policy. Unresolved censored pairs stay in the denominator.

| Profiles | Observed median gap | Later / shared seeds | Confirmed later share | Unresolved | Verdict |
| --- | --- | --- | --- | --- | --- |
| novice → average | 5 | 3 / 5 | 60% | 0 | below target |
| novice → expert | 7 | 3 / 5 | 60% | 0 | below target |
| average → expert | 2 | 2 / 5 | 40% | 0 | below target |

## Waves per run

A timed-out wave can clear later. Active counts include each started roster still fighting at death.

| Profile | Seed | Outcome | Timed-out waves | Active waves at death |
| --- | --- | --- | --- | --- |
| novice | 1 | died on 5 | 0 | 1 |
| novice | 2 | died on 5 | 0 | 1 |
| novice | 3 | died on 5 | 0 | 1 |
| novice | 4 | died on 5 | 0 | 1 |
| novice | 5 | died on 5 | 0 | 1 |
| average | 1 | died on 15 | 0 | 1 |
| average | 2 | died on 10 | 0 | 1 |
| average | 3 | died on 5 | 0 | 1 |
| average | 4 | died on 5 | 0 | 1 |
| average | 5 | died on 15 | 0 | 1 |
| expert | 1 | died on 3 | 0 | 1 |
| expert | 2 | died on 32 | 0 | 1 |
| expert | 3 | died on 12 | 0 | 1 |
| expert | 4 | died on 5 | 0 | 1 |
| expert | 5 | died on 12 | 0 | 1 |

## Wave time

Seconds per observed wave. The target is 15 s ±20% for ordinary average-profile waves. Every 5th wave targets 25–30 s. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Median s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 5 / 5 | 11.22 | 9.97…13.23 | 8.03…13.48 | — |
| novice | 2 | 5 / 5 | 10.22 | 8.3…14.72 | 8.22…16.25 | — |
| novice | 3 | 5 / 5 | 10.42 | 9.88…16.7 | 7.02…22.52 | — |
| novice | 4 | 5 / 5 | 12.13 | 10.05…17.08 | 9.2…29.25 | — |
| novice | 5 | 0 / 5 | not measured | not measured | not measured | — |
| average | 1 | 5 / 5 | 10.88 | 10.78…13.33 | 9.18…14.72 | miss |
| average | 2 | 5 / 5 | 12.33 | 11.75…14.5 | 9.72…17.18 | within target |
| average | 3 | 5 / 5 | 14.25 | 9.4…16.1 | 8.68…24.07 | within target |
| average | 4 | 5 / 5 | 13.68 | 12.45…13.77 | 12.18…18.33 | within target |
| average | 5 | 3 / 5 | 13.82 | 6.05…24.62 | 6.05…24.62 | miss |
| average | 6 | 3 / 3 | 21.5 | 11.42…27.87 | 11.42…27.87 | miss |
| average | 7 | 3 / 3 | 21.52 | 12.97…36.48 | 12.97…36.48 | miss |
| average | 8 | 3 / 3 | 22.7 | 17.33…26.93 | 17.33…26.93 | miss |
| average | 9 | 3 / 3 | 19.47 | 19.03…20.35 | 19.03…20.35 | miss |
| average | 10 | 2 / 3 | 18.5 | 17.8…19.2 | 17.8…19.2 | miss |
| average | 11 | 2 / 2 | 19.03 | 14.43…23.63 | 14.43…23.63 | miss |
| average | 12 | 2 / 2 | 24.72 | 20.72…28.72 | 20.72…28.72 | miss |
| average | 13 | 2 / 2 | 20.98 | 17.52…24.43 | 17.52…24.43 | miss |
| average | 14 | 2 / 2 | 24.62 | 24.27…24.97 | 24.27…24.97 | miss |
| average | 15 | 0 / 2 | not measured | not measured | not measured | not measured |
| expert | 1 | 5 / 5 | 12.58 | 12.43…12.83 | 11.1…13.7 | — |
| expert | 2 | 5 / 5 | 16.25 | 13.3…17.27 | 11.73…23.52 | — |
| expert | 3 | 4 / 5 | 12.68 | 10.02…17.42 | 6.95…17.42 | — |
| expert | 4 | 4 / 4 | 10.82 | 10.8…17.72 | 10.42…17.72 | — |
| expert | 5 | 3 / 4 | 14.02 | 10.35…29.28 | 10.35…29.28 | — |
| expert | 6 | 3 / 3 | 16.08 | 10.53…43.12 | 10.53…43.12 | — |
| expert | 7 | 3 / 3 | 14.77 | 11.85…15.98 | 11.85…15.98 | — |
| expert | 8 | 3 / 3 | 16.72 | 15.4…19.18 | 15.4…19.18 | — |
| expert | 9 | 3 / 3 | 23.77 | 18.68…29.5 | 18.68…29.5 | — |
| expert | 10 | 3 / 3 | 26.15 | 16.87…37.47 | 16.87…37.47 | — |
| expert | 11 | 3 / 3 | 22.03 | 19.62…22.18 | 19.62…22.18 | — |
| expert | 12 | 1 / 3 | 21.12 | 21.12…21.12 | 21.12…21.12 | — |
| expert | 13 | 1 / 1 | 23.3 | 23.3…23.3 | 23.3…23.3 | — |
| expert | 14 | 1 / 1 | 25.45 | 25.45…25.45 | 25.45…25.45 | — |
| expert | 15 | 1 / 1 | 16.85 | 16.85…16.85 | 16.85…16.85 | — |
| expert | 16 | 1 / 1 | 25.1 | 25.1…25.1 | 25.1…25.1 | — |
| expert | 17 | 1 / 1 | 18.77 | 18.77…18.77 | 18.77…18.77 | — |
| expert | 18 | 1 / 1 | 21.73 | 21.73…21.73 | 21.73…21.73 | — |
| expert | 19 | 1 / 1 | 18.15 | 18.15…18.15 | 18.15…18.15 | — |
| expert | 20 | 1 / 1 | 11.87 | 11.87…11.87 | 11.87…11.87 | — |
| expert | 21 | 1 / 1 | 25.47 | 25.47…25.47 | 25.47…25.47 | — |
| expert | 22 | 1 / 1 | 32.83 | 32.83…32.83 | 32.83…32.83 | — |
| expert | 23 | 1 / 1 | 23.03 | 23.03…23.03 | 23.03…23.03 | — |
| expert | 24 | 1 / 1 | 23.48 | 23.48…23.48 | 23.48…23.48 | — |
| expert | 25 | 1 / 1 | 36.7 | 36.7…36.7 | 36.7…36.7 | — |
| expert | 26 | 1 / 1 | 26.52 | 26.52…26.52 | 26.52…26.52 | — |
| expert | 27 | 1 / 1 | 36.23 | 36.23…36.23 | 36.23…36.23 | — |
| expert | 28 | 1 / 1 | 33.75 | 33.75…33.75 | 33.75…33.75 | — |
| expert | 29 | 1 / 1 | 31.5 | 31.5…31.5 | 31.5…31.5 | — |
| expert | 30 | 1 / 1 | 24.4 | 24.4…24.4 | 24.4…24.4 | — |
| expert | 31 | 1 / 1 | 30.08 | 30.08…30.08 | 30.08…30.08 | — |
| expert | 32 | 0 / 1 | not measured | not measured | not measured | — |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 5 | 5 | 0 | 0 | 0 | 5 × 5 | stomp × 4, rocket × 1 | 0 |
| average | 5 | 5 | 0 | 0 | 0 | 5 × 2, 10 × 1, 15 × 2 | stomp × 3, war_cannon × 2 | 0 |
| expert | 5 | 5 | 0 | 0 | 0 | 3 × 1, 5 × 1, 12 × 2, 32 × 1 | rocket × 3, patrol_cop × 1, war_cannon × 1 | 0 |

## Timeouts

Runs that reached the wave time limit.

| Outcome | novice | average | expert |
| --- | --- | --- | --- |
| timeout | 0 | 0 | 0 |

## Survival by wave band

Each wave contributes once to each available median. Damage/s needs a timed wave. Repair/s is the configured rate when repair is active. HP coverage counts waves sampled by the bot. Repaired HP sums positive HP steps. The share undone uses waves with positive damage. Multipliers include stat cards taken before the wave.

| Profile | Waves | HP rows / observed | Damage | Damage/s | Repair/s | Minimum HP (% of capacity) | Repaired HP | Damage undone (%) | Guard deflects | Cover ticks | Rolls | damage × | guard_meter × | hp_max × | regen × | speed × |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1–10 | 25 / 25 | 7.2 | 0.43 | 10 | 91.6 | 0 | 0 | 7 | 0 | 1 | 1 | 1 | 1 | 1 | 1 |
| novice | 11–20 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| novice | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| novice | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 1–10 | 40 / 40 | 8.89 | 0.44 | 10 | 90.21 | 0 | 0 | 8 | 5 | 4.5 | 1.1 | 1 | 1.05 | 1 | 1 |
| average | 11–20 | 10 / 10 | 24.46 | 1.02 | 11 | 67.53 | 0 | 0 | 10.5 | 7.5 | 7 | 1.1 | 1.1 | 1.1 | 1.1 | 1.1 |
| average | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 1–10 | 38 / 38 | 3.6 | 0.31 | 10 | 95.83 | 0 | 0 | 6.5 | 29.5 | 4.5 | 1.1 | 1.1 | 1 | 1 | 1 |
| expert | 11–20 | 14 / 14 | 31.45 | 1.09 | 11 | 77.13 | 0 | 0 | 11.5 | 107.5 | 10 | 1.375 | 1.1 | 1.2375 | 1.1 | 1.1 |
| expert | 21–30 | 10 / 10 | 35.27 | 1.15 | 11 | 74.35 | 0 | 0 | 20.5 | 76.5 | 11.5 | 1.375 | 1.375 | 1.375 | 1.1 | 1.375 |
| expert | 31+ | 2 / 2 | 84.17 | 1.03 | 13.75 | 38.79 | 0 | 0 | 16.5 | 126.5 | 16 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 0 | — | 66.92% | 18.02 (78) | 13.41 (46) |
| patrol_cop | 1 | — | 79.94% | 15.05 (108) | 27.01 (16) |
| riot_cop | 0 | — | 71.5% | 19.18 (81) | 13.33 (43) |
| robot_gunner | 0 | — | 47.23% | 22.44 (46) | 13.41 (78) |
| robot_thug | 0 | — | 52.42% | 22.03 (51) | 13.3 (73) |
| rocket_trooper | 4 | rocket × 4 | 73.54% | 19.11 (82) | 13.27 (42) |
| sentry_turret | 0 | — | 48.67% | 22.87 (46) | 13.32 (78) |
| shield_robot | 0 | — | 34.56% | 24.4 (31) | 14.02 (93) |
| swat | 0 | — | 64.04% | 19.2 (71) | 13.7 (53) |
| war_machine | 10 | stomp × 7, war_cannon × 3 | 13.71% | 17.8 (15) | 16.25 (109) |

## Moves

Uses count recorded activations by profile and wave number. The game omits zero counts. Times are medians in seconds, with timed wave counts in parentheses. Carry applies to all waves.

| Profile | Wave | Move | Enemy | Recorded uses | Observed waves | Uses per wave | With enemy s (n) | Without enemy s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | All | ohm_short_circuit | sentry_turret | 2 | 25 | 0.08 | — | 10.82 (20) |
| novice | All | tonnage_armour_crack | war_machine | 2 | 25 | 0.08 | — | 10.82 (20) |
| novice | All | kerf_blink_behind | shield_robot | 0 | 25 | 0 | — | 10.82 (20) |
| novice | All | overkill_carry | all waves | 0 | 25 | 0 | 10.82 (20) | — |
| novice | 1 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 11.22 (5) |
| novice | 1 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 11.22 (5) |
| novice | 1 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 11.22 (5) |
| novice | 1 | overkill_carry | all waves | 0 | 5 | 0 | 11.22 (5) | — |
| novice | 2 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 10.22 (5) |
| novice | 2 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 10.22 (5) |
| novice | 2 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 10.22 (5) |
| novice | 2 | overkill_carry | all waves | 0 | 5 | 0 | 10.22 (5) | — |
| novice | 3 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 10.42 (5) |
| novice | 3 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 10.42 (5) |
| novice | 3 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 10.42 (5) |
| novice | 3 | overkill_carry | all waves | 0 | 5 | 0 | 10.42 (5) | — |
| novice | 4 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 12.13 (5) |
| novice | 4 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 12.13 (5) |
| novice | 4 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 12.13 (5) |
| novice | 4 | overkill_carry | all waves | 0 | 5 | 0 | 12.13 (5) | — |
| novice | 5 | ohm_short_circuit | sentry_turret | 2 | 5 | 0.4 | — | — |
| novice | 5 | tonnage_armour_crack | war_machine | 2 | 5 | 0.4 | — | — |
| novice | 5 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | — |
| novice | 5 | overkill_carry | all waves | 0 | 5 | 0 | — | — |
| average | All | ohm_short_circuit | sentry_turret | 15 | 50 | 0.3 | 21.52 (15) | 13.79 (30) |
| average | All | tonnage_armour_crack | war_machine | 2 | 50 | 0.04 | 17.8 (5) | 16.64 (40) |
| average | All | kerf_blink_behind | shield_robot | 28 | 50 | 0.56 | 20.72 (9) | 14.38 (36) |
| average | All | overkill_carry | all waves | 0 | 50 | 0 | 17.18 (45) | — |
| average | 1 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 10.88 (5) |
| average | 1 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 10.88 (5) |
| average | 1 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 10.88 (5) |
| average | 1 | overkill_carry | all waves | 0 | 5 | 0 | 10.88 (5) | — |
| average | 2 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 12.33 (5) |
| average | 2 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 12.33 (5) |
| average | 2 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 12.33 (5) |
| average | 2 | overkill_carry | all waves | 0 | 5 | 0 | 12.33 (5) | — |
| average | 3 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 14.25 (5) |
| average | 3 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 14.25 (5) |
| average | 3 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 14.25 (5) |
| average | 3 | overkill_carry | all waves | 0 | 5 | 0 | 14.25 (5) | — |
| average | 4 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 13.68 (5) |
| average | 4 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 13.68 (5) |
| average | 4 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 13.68 (5) |
| average | 4 | overkill_carry | all waves | 0 | 5 | 0 | 13.68 (5) | — |
| average | 5 | ohm_short_circuit | sentry_turret | 2 | 5 | 0.4 | — | 13.82 (3) |
| average | 5 | tonnage_armour_crack | war_machine | 2 | 5 | 0.4 | 13.82 (3) | — |
| average | 5 | kerf_blink_behind | shield_robot | 1 | 5 | 0.2 | — | 13.82 (3) |
| average | 5 | overkill_carry | all waves | 0 | 5 | 0 | 13.82 (3) | — |
| average | 6 | ohm_short_circuit | sentry_turret | 1 | 3 | 0.33 | 19.64 (2) | 21.5 (1) |
| average | 6 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 21.5 (3) |
| average | 6 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | — | 21.5 (3) |
| average | 6 | overkill_carry | all waves | 0 | 3 | 0 | 21.5 (3) | — |
| average | 7 | ohm_short_circuit | sentry_turret | 1 | 3 | 0.33 | 29 (2) | 12.97 (1) |
| average | 7 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 21.52 (3) |
| average | 7 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | — | 21.52 (3) |
| average | 7 | overkill_carry | all waves | 0 | 3 | 0 | 21.52 (3) | — |
| average | 8 | ohm_short_circuit | sentry_turret | 2 | 3 | 0.67 | 22.7 (3) | — |
| average | 8 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 22.7 (3) |
| average | 8 | kerf_blink_behind | shield_robot | 2 | 3 | 0.67 | — | 22.7 (3) |
| average | 8 | overkill_carry | all waves | 0 | 3 | 0 | 22.7 (3) | — |
| average | 9 | ohm_short_circuit | sentry_turret | 2 | 3 | 0.67 | 19.47 (1) | 19.69 (2) |
| average | 9 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 19.47 (3) |
| average | 9 | kerf_blink_behind | shield_robot | 4 | 3 | 1.33 | 19.69 (2) | 19.47 (1) |
| average | 9 | overkill_carry | all waves | 0 | 3 | 0 | 19.47 (3) | — |
| average | 10 | ohm_short_circuit | sentry_turret | 4 | 3 | 1.33 | 18.5 (2) | — |
| average | 10 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | 18.5 (2) | — |
| average | 10 | kerf_blink_behind | shield_robot | 3 | 3 | 1 | — | 18.5 (2) |
| average | 10 | overkill_carry | all waves | 0 | 3 | 0 | 18.5 (2) | — |
| average | 11 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 14.43 (1) | 23.63 (1) |
| average | 11 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 19.03 (2) |
| average | 11 | kerf_blink_behind | shield_robot | 1 | 2 | 0.5 | 14.43 (1) | 23.63 (1) |
| average | 11 | overkill_carry | all waves | 0 | 2 | 0 | 19.03 (2) | — |
| average | 12 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 24.72 (2) | — |
| average | 12 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 24.72 (2) |
| average | 12 | kerf_blink_behind | shield_robot | 4 | 2 | 2 | 24.72 (2) | — |
| average | 12 | overkill_carry | all waves | 0 | 2 | 0 | 24.72 (2) | — |
| average | 13 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | — | 20.98 (2) |
| average | 13 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 20.98 (2) |
| average | 13 | kerf_blink_behind | shield_robot | 5 | 2 | 2.5 | 20.98 (2) | — |
| average | 13 | overkill_carry | all waves | 0 | 2 | 0 | 20.98 (2) | — |
| average | 14 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | 24.62 (2) | — |
| average | 14 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 24.62 (2) |
| average | 14 | kerf_blink_behind | shield_robot | 7 | 2 | 3.5 | 24.62 (2) | — |
| average | 14 | overkill_carry | all waves | 0 | 2 | 0 | 24.62 (2) | — |
| average | 15 | ohm_short_circuit | sentry_turret | 2 | 2 | 1 | — | — |
| average | 15 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | — |
| average | 15 | kerf_blink_behind | shield_robot | 1 | 2 | 0.5 | — | — |
| average | 15 | overkill_carry | all waves | 0 | 2 | 0 | — | — |
| expert | All | ohm_short_circuit | sentry_turret | 44 | 64 | 0.69 | 23.48 (31) | 13.5 (28) |
| expert | All | tonnage_armour_crack | war_machine | 0 | 64 | 0 | 20.63 (10) | 18.15 (49) |
| expert | All | kerf_blink_behind | shield_robot | 55 | 64 | 0.86 | 25.27 (22) | 15.4 (37) |
| expert | All | overkill_carry | all waves | 110 | 64 | 1.72 | 18.15 (59) | — |
| expert | 1 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 12.58 (5) |
| expert | 1 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 12.58 (5) |
| expert | 1 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 12.58 (5) |
| expert | 1 | overkill_carry | all waves | 0 | 5 | 0 | 12.58 (5) | — |
| expert | 2 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 16.25 (5) |
| expert | 2 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 16.25 (5) |
| expert | 2 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 16.25 (5) |
| expert | 2 | overkill_carry | all waves | 0 | 5 | 0 | 16.25 (5) | — |
| expert | 3 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 12.68 (4) |
| expert | 3 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 12.68 (4) |
| expert | 3 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 12.68 (4) |
| expert | 3 | overkill_carry | all waves | 0 | 5 | 0 | 12.68 (4) | — |
| expert | 4 | ohm_short_circuit | sentry_turret | 0 | 4 | 0 | — | 10.82 (4) |
| expert | 4 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 10.82 (4) |
| expert | 4 | kerf_blink_behind | shield_robot | 0 | 4 | 0 | — | 10.82 (4) |
| expert | 4 | overkill_carry | all waves | 0 | 4 | 0 | 10.82 (4) | — |
| expert | 5 | ohm_short_circuit | sentry_turret | 2 | 4 | 0.5 | — | 14.02 (3) |
| expert | 5 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | 14.02 (3) | — |
| expert | 5 | kerf_blink_behind | shield_robot | 1 | 4 | 0.25 | — | 14.02 (3) |
| expert | 5 | overkill_carry | all waves | 0 | 4 | 0 | 14.02 (3) | — |
| expert | 6 | ohm_short_circuit | sentry_turret | 1 | 3 | 0.33 | 29.6 (2) | 10.53 (1) |
| expert | 6 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 16.08 (3) |
| expert | 6 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | — | 16.08 (3) |
| expert | 6 | overkill_carry | all waves | 0 | 3 | 0 | 16.08 (3) | — |
| expert | 7 | ohm_short_circuit | sentry_turret | 0 | 3 | 0 | 15.98 (1) | 13.31 (2) |
| expert | 7 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 14.77 (3) |
| expert | 7 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | — | 14.77 (3) |
| expert | 7 | overkill_carry | all waves | 0 | 3 | 0 | 14.77 (3) | — |
| expert | 8 | ohm_short_circuit | sentry_turret | 2 | 3 | 0.67 | 16.72 (3) | — |
| expert | 8 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 16.72 (3) |
| expert | 8 | kerf_blink_behind | shield_robot | 1 | 3 | 0.33 | — | 16.72 (3) |
| expert | 8 | overkill_carry | all waves | 0 | 3 | 0 | 16.72 (3) | — |
| expert | 9 | ohm_short_circuit | sentry_turret | 5 | 3 | 1.67 | 26.63 (2) | 18.68 (1) |
| expert | 9 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 23.77 (3) |
| expert | 9 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | 24.09 (2) | 23.77 (1) |
| expert | 9 | overkill_carry | all waves | 0 | 3 | 0 | 23.77 (3) | — |
| expert | 10 | ohm_short_circuit | sentry_turret | 5 | 3 | 1.67 | 21.51 (2) | 37.47 (1) |
| expert | 10 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | 26.15 (3) | — |
| expert | 10 | kerf_blink_behind | shield_robot | 1 | 3 | 0.33 | 37.47 (1) | 21.51 (2) |
| expert | 10 | overkill_carry | all waves | 0 | 3 | 0 | 26.15 (3) | — |
| expert | 11 | ohm_short_circuit | sentry_turret | 3 | 3 | 1 | 22.11 (2) | 19.62 (1) |
| expert | 11 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 22.03 (3) |
| expert | 11 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | — | 22.03 (3) |
| expert | 11 | overkill_carry | all waves | 0 | 3 | 0 | 22.03 (3) | — |
| expert | 12 | ohm_short_circuit | sentry_turret | 4 | 3 | 1.33 | 21.12 (1) | — |
| expert | 12 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 21.12 (1) |
| expert | 12 | kerf_blink_behind | shield_robot | 3 | 3 | 1 | 21.12 (1) | — |
| expert | 12 | overkill_carry | all waves | 6 | 3 | 2 | 21.12 (1) | — |
| expert | 13 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | — | 23.3 (1) |
| expert | 13 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 23.3 (1) |
| expert | 13 | kerf_blink_behind | shield_robot | 1 | 1 | 1 | 23.3 (1) | — |
| expert | 13 | overkill_carry | all waves | 0 | 1 | 0 | 23.3 (1) | — |
| expert | 14 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 25.45 (1) | — |
| expert | 14 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 25.45 (1) |
| expert | 14 | kerf_blink_behind | shield_robot | 1 | 1 | 1 | 25.45 (1) | — |
| expert | 14 | overkill_carry | all waves | 0 | 1 | 0 | 25.45 (1) | — |
| expert | 15 | ohm_short_circuit | sentry_turret | 2 | 1 | 2 | 16.85 (1) | — |
| expert | 15 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | 16.85 (1) | — |
| expert | 15 | kerf_blink_behind | shield_robot | 1 | 1 | 1 | — | 16.85 (1) |
| expert | 15 | overkill_carry | all waves | 0 | 1 | 0 | 16.85 (1) | — |
| expert | 16 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | 25.1 (1) | — |
| expert | 16 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 25.1 (1) |
| expert | 16 | kerf_blink_behind | shield_robot | 3 | 1 | 3 | 25.1 (1) | — |
| expert | 16 | overkill_carry | all waves | 0 | 1 | 0 | 25.1 (1) | — |
| expert | 17 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 18.77 (1) | — |
| expert | 17 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 18.77 (1) |
| expert | 17 | kerf_blink_behind | shield_robot | 3 | 1 | 3 | 18.77 (1) | — |
| expert | 17 | overkill_carry | all waves | 0 | 1 | 0 | 18.77 (1) | — |
| expert | 18 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 21.73 (1) | — |
| expert | 18 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 21.73 (1) |
| expert | 18 | kerf_blink_behind | shield_robot | 3 | 1 | 3 | 21.73 (1) | — |
| expert | 18 | overkill_carry | all waves | 0 | 1 | 0 | 21.73 (1) | — |
| expert | 19 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 18.15 (1) | — |
| expert | 19 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 18.15 (1) |
| expert | 19 | kerf_blink_behind | shield_robot | 1 | 1 | 1 | 18.15 (1) | — |
| expert | 19 | overkill_carry | all waves | 0 | 1 | 0 | 18.15 (1) | — |
| expert | 20 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 11.87 (1) | — |
| expert | 20 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | 11.87 (1) | — |
| expert | 20 | kerf_blink_behind | shield_robot | 2 | 1 | 2 | 11.87 (1) | — |
| expert | 20 | overkill_carry | all waves | 0 | 1 | 0 | 11.87 (1) | — |
| expert | 21 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 25.47 (1) | — |
| expert | 21 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 25.47 (1) |
| expert | 21 | kerf_blink_behind | shield_robot | 3 | 1 | 3 | 25.47 (1) | — |
| expert | 21 | overkill_carry | all waves | 0 | 1 | 0 | 25.47 (1) | — |
| expert | 22 | ohm_short_circuit | sentry_turret | 2 | 1 | 2 | 32.83 (1) | — |
| expert | 22 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 32.83 (1) |
| expert | 22 | kerf_blink_behind | shield_robot | 4 | 1 | 4 | 32.83 (1) | — |
| expert | 22 | overkill_carry | all waves | 0 | 1 | 0 | 32.83 (1) | — |
| expert | 23 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 23.03 (1) | — |
| expert | 23 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 23.03 (1) |
| expert | 23 | kerf_blink_behind | shield_robot | 4 | 1 | 4 | 23.03 (1) | — |
| expert | 23 | overkill_carry | all waves | 4 | 1 | 4 | 23.03 (1) | — |
| expert | 24 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 23.48 (1) | — |
| expert | 24 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 23.48 (1) |
| expert | 24 | kerf_blink_behind | shield_robot | 2 | 1 | 2 | 23.48 (1) | — |
| expert | 24 | overkill_carry | all waves | 11 | 1 | 11 | 23.48 (1) | — |
| expert | 25 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 36.7 (1) | — |
| expert | 25 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | 36.7 (1) | — |
| expert | 25 | kerf_blink_behind | shield_robot | 3 | 1 | 3 | 36.7 (1) | — |
| expert | 25 | overkill_carry | all waves | 10 | 1 | 10 | 36.7 (1) | — |
| expert | 26 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 26.52 (1) | — |
| expert | 26 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 26.52 (1) |
| expert | 26 | kerf_blink_behind | shield_robot | 5 | 1 | 5 | 26.52 (1) | — |
| expert | 26 | overkill_carry | all waves | 11 | 1 | 11 | 26.52 (1) | — |
| expert | 27 | ohm_short_circuit | sentry_turret | 2 | 1 | 2 | 36.23 (1) | — |
| expert | 27 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 36.23 (1) |
| expert | 27 | kerf_blink_behind | shield_robot | 3 | 1 | 3 | 36.23 (1) | — |
| expert | 27 | overkill_carry | all waves | 11 | 1 | 11 | 36.23 (1) | — |
| expert | 28 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 33.75 (1) | — |
| expert | 28 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 33.75 (1) |
| expert | 28 | kerf_blink_behind | shield_robot | 1 | 1 | 1 | 33.75 (1) | — |
| expert | 28 | overkill_carry | all waves | 15 | 1 | 15 | 33.75 (1) | — |
| expert | 29 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 31.5 (1) | — |
| expert | 29 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 31.5 (1) |
| expert | 29 | kerf_blink_behind | shield_robot | 2 | 1 | 2 | 31.5 (1) | — |
| expert | 29 | overkill_carry | all waves | 13 | 1 | 13 | 31.5 (1) | — |
| expert | 30 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 24.4 (1) | — |
| expert | 30 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | 24.4 (1) | — |
| expert | 30 | kerf_blink_behind | shield_robot | 5 | 1 | 5 | 24.4 (1) | — |
| expert | 30 | overkill_carry | all waves | 6 | 1 | 6 | 24.4 (1) | — |
| expert | 31 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 30.08 (1) | — |
| expert | 31 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 30.08 (1) |
| expert | 31 | kerf_blink_behind | shield_robot | 2 | 1 | 2 | 30.08 (1) | — |
| expert | 31 | overkill_carry | all waves | 12 | 1 | 12 | 30.08 (1) | — |
| expert | 32 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | — | — |
| expert | 32 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | — |
| expert | 32 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | — |
| expert | 32 | overkill_carry | all waves | 11 | 1 | 11 | — | — |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| effect_overkill_carry | waves survived | 4.5 (2) | 6 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| effect_overkill_carry | wave s | 30.08 (1) | 19.47 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| effect_overkill_carry_2 | waves survived | 7 (1) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| effect_overkill_carry_2 | wave s | 31.5 (1) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_dent | waves survived | 5.5 (4) | 4.5 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_dent | wave s | 22.97 (3) | 19.85 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_kerf | waves survived | 7 (5) | 3 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_kerf | wave s | 20.86 (4) | 29.5 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | waves survived | 6 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | wave s | 19.56 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_tonnage | waves survived | 4 (9) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| ghost_tonnage | wave s | 21.5 (9) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_10 | waves survived | 3 (12) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_10 | wave s | 16.11 (12) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_25 | waves survived | 1 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_25 | wave s | 12.18 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 4 (9) | 3 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_10 | wave s | 19.57 (7) | 11.2 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_25 | waves survived | 0 (4) | 4 (6) | 3 | 0 | -7…0 | not measured (3, all offered) | too few pairs |
| stat_guard_meter_25 | wave s | 25.1 (1) | 17.96 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 3 (11) | 1 (4) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_hp_max_10 | wave s | 19.8 (9) | 11.49 (4) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_hp_max_25 | waves survived | 18 (1) | 5 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_25 | wave s | 25.27 (1) | 20.72 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_10 | waves survived | 4 (6) | 2.5 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_10 | wave s | 22.4 (6) | 12.33 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | waves survived | 3 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | wave s | 26.11 (2) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | waves survived | 3 (9) | 0 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | wave s | 15.09 (8) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_25 | waves survived | 14 (1) | 1 (8) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_25 | wave s | 25.99 (1) | 14.13 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_chainsaw | waves survived | 3 (1) | 1.5 (6) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_chainsaw | wave s | 30.08 (1) | 18.3 (6) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_electro_baton | waves survived | 16 (1) | 6.5 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | wave s | 25.28 (1) | 19.25 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | waves survived | 6 (3) | 4.5 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | wave s | 24.43 (3) | 20.14 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gatling | waves survived | 5 (5) | 3 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gatling | wave s | 20.87 (5) | 29.5 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gloria | waves survived | 8 (2) | 3 (11) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gloria | wave s | 27.03 (2) | 16.03 (11) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | 10 (1) | 1 (9) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_hand_cannon | wave s | 30.79 (1) | 19.88 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_katana | waves survived | 5.5 (2) | 4 (7) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_katana | wave s | 27.61 (2) | 16.08 (7) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_machine_pistol | waves survived | 14 (2) | 4 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_machine_pistol | wave s | 21.26 (2) | 19.8 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_pistol | waves survived | 6 (7) | 2 (6) | 3 | 0 | 0…7 | not measured (3, all offered) | too few pairs |
| weapon_pistol | wave s | 16.48 (7) | 13.07 (5) | 3 | -2.72 | -3.22…1.7 | not measured (3, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | 13 (1) | 2 (7) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_rifle | wave s | 26.52 (1) | 18.23 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_sword | waves survived | 5.5 (4) | 0 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_sword | wave s | 19.47 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_rocket_launcher | waves survived | 1.5 (4) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_rocket_launcher | wave s | 29.75 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | 3 (1) | 1.5 (6) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| chainsaw | wave s | 30.08 (1) | 18.3 (6) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| electro_baton | waves survived | 16 (1) | 6.5 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | wave s | 25.28 (1) | 19.25 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | waves survived | 6 (3) | 4.5 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | wave s | 24.43 (3) | 20.14 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gatling | waves survived | 5 (5) | 3 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gatling | wave s | 20.87 (5) | 29.5 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gloria | waves survived | 8 (2) | 3 (11) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gloria | wave s | 27.03 (2) | 16.03 (11) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| hand_cannon | waves survived | 10 (1) | 1 (9) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| hand_cannon | wave s | 30.79 (1) | 19.88 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| katana | waves survived | 5.5 (2) | 4 (7) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| katana | wave s | 27.61 (2) | 16.08 (7) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| machine_pistol | waves survived | 14 (2) | 4 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| machine_pistol | wave s | 21.26 (2) | 19.8 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| pistol | waves survived | 6 (7) | 2 (6) | 3 | 0 | 0…7 | not measured (3, all offered) | too few pairs |
| pistol | wave s | 16.48 (7) | 13.07 (5) | 3 | -2.72 | -3.22…1.7 | not measured (3, all offered) | too few pairs |
| plasma_rifle | waves survived | 13 (1) | 2 (7) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_rifle | wave s | 26.52 (1) | 18.23 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_sword | waves survived | 5.5 (4) | 0 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_sword | wave s | 19.47 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| rocket_launcher | waves survived | 1.5 (4) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| rocket_launcher | wave s | 29.75 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | kerf s (n) | ohm s (n) | rivet s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 7 (5) | 1 (5) | 0 (5) | 13 (5) | not measured | not measured | 11.22 (5) | not measured |
| novice | 2 | 10 (5) | 1 (5) | 0 (5) | 14 (5) | not measured | not measured | 10.22 (5) | not measured |
| novice | 3 | 10 (5) | 1 (5) | 0 (5) | 12 (5) | not measured | not measured | 10.42 (5) | 7.1 (1) |
| novice | 4 | 7 (5) | 1 (5) | 0 (5) | 12 (5) | not measured | not measured | 12.13 (5) | not measured |
| novice | 5 | 0 (5) | 1 (5) | 0 (5) | 11 (5) | not measured | 5.25 (1) | 7.85 (5) | 4.85 (1) |
| average | 1 | 12 (5) | 3 (5) | 0 (5) | 13 (5) | not measured | not measured | 10.88 (5) | not measured |
| average | 2 | 12 (5) | 2 (5) | 0 (5) | 14 (5) | not measured | not measured | 12.33 (5) | not measured |
| average | 3 | 5 (5) | 3 (5) | 0 (5) | 12 (5) | not measured | 4.32 (1) | 14.25 (5) | 7.1 (1) |
| average | 4 | 7 (5) | 4 (5) | 0 (5) | 12 (5) | not measured | 0.98 (1) | 12.45 (5) | 5.02 (1) |
| average | 5 | 2 (5) | 2 (5) | 0 (5) | 21 (5) | 2.62 (1) | 4.13 (1) | 13.38 (5) | 7.1 (1) |
| average | 6 | 2 (3) | 8 (3) | 24 (3) | 31 (3) | 2.23 (1) | 0.03 (1) | 14.4 (3) | 7.1 (2) |
| average | 7 | 11 (3) | 7 (3) | 77 (3) | 36 (3) | 5.5 (1) | 0.03 (1) | 15.98 (3) | 7.1 (1) |
| average | 8 | 11 (3) | 9 (3) | 74 (3) | 72 (3) | 0.35 (1) | 0.7 (2) | 16.95 (3) | 7.1 (2) |
| average | 9 | 10 (3) | 8 (3) | 39 (3) | 61 (3) | 2.17 (2) | 3.49 (2) | 12.15 (3) | 4.85 (2) |
| average | 10 | 4 (3) | 8 (3) | 51 (3) | 54 (3) | 6.42 (2) | 2.29 (2) | 11.28 (3) | 3.56 (2) |
| average | 11 | 8.5 (2) | 11 (2) | 34.5 (2) | 184 (2) | 5.5 (2) | not measured | 9.98 (2) | 7.1 (1) |
| average | 12 | 19 (2) | 9.5 (2) | 62 (2) | 589.5 (2) | 5.5 (2) | not measured | 17.39 (2) | 3.67 (1) |
| average | 13 | 7.5 (2) | 7 (2) | 63 (2) | 802 (2) | 4.58 (2) | not measured | 12.84 (2) | 7.1 (1) |
| average | 14 | 8 (2) | 5.5 (2) | 102.5 (2) | 1137 (2) | 6.41 (2) | 0.3 (1) | 14.51 (2) | 7.1 (1) |
| average | 15 | 12.5 (2) | 9 (2) | 33.5 (2) | 596.5 (2) | 2.33 (1) | 0.53 (1) | 10.52 (2) | 7.1 (1) |
| expert | 1 | 12 (5) | 4 (5) | 0 (5) | 13 (5) | not measured | not measured | 12.58 (5) | not measured |
| expert | 2 | 12 (5) | 4 (5) | 0 (5) | 14 (5) | not measured | not measured | 16.25 (5) | not measured |
| expert | 3 | 7 (5) | 3 (5) | 0 (5) | 12 (5) | not measured | 3.63 (1) | 10.02 (5) | 10.28 (2) |
| expert | 4 | 3.5 (4) | 6.5 (4) | 0 (4) | 12.5 (4) | not measured | 7.03 (1) | 10.82 (4) | not measured |
| expert | 5 | 0.5 (4) | 9 (4) | 0 (4) | 15 (4) | 5.5 (1) | 7.3 (1) | 12.62 (4) | 7.1 (1) |
| expert | 6 | 4 (3) | 10 (3) | 17 (3) | 30 (3) | 5.5 (1) | 0.03 (1) | 10.58 (3) | 14.2 (1) |
| expert | 7 | 4 (3) | 3 (3) | 23 (3) | 33 (3) | 1.7 (1) | 6.5 (2) | 6.98 (3) | 7.1 (1) |
| expert | 8 | 8 (3) | 4 (3) | 31 (3) | 35 (3) | 4.88 (1) | 0.03 (2) | 13 (3) | 6.15 (1) |
| expert | 9 | 6 (3) | 5 (3) | 35 (3) | 51 (3) | 5.5 (1) | 0.07 (3) | 18.2 (3) | 6.78 (2) |
| expert | 10 | 3 (3) | 11 (3) | 30 (3) | 46 (3) | 5.5 (1) | 0.03 (3) | 19.02 (3) | 6.71 (2) |
| expert | 11 | 9 (3) | 7 (3) | 32 (3) | 54 (3) | 3.77 (2) | 4.65 (3) | 12.73 (3) | 7.1 (1) |
| expert | 12 | 18 (3) | 16 (3) | 35 (3) | 76 (3) | 3.99 (2) | 0.07 (3) | 21.18 (3) | 7.1 (1) |
| expert | 13 | 29 (1) | 14 (1) | 81 (1) | 115 (1) | 2.2 (1) | 0.57 (1) | 20.53 (1) | not measured |
| expert | 14 | 19 (1) | 11 (1) | 80 (1) | 95 (1) | 5.5 (1) | 0.17 (1) | 19.78 (1) | not measured |
| expert | 15 | 3 (1) | 7 (1) | 54 (1) | 48 (1) | 2.55 (1) | 0.63 (1) | 13.67 (1) | not measured |
| expert | 16 | 23 (1) | 22 (1) | 51 (1) | 71 (1) | 7.13 (1) | not measured | 17.97 (1) | not measured |
| expert | 17 | 20 (1) | 7 (1) | 20 (1) | 54 (1) | 5.5 (1) | 0.53 (1) | 12.73 (1) | not measured |
| expert | 18 | 6 (1) | 9 (1) | 46 (1) | 50 (1) | 5.5 (1) | 0.17 (1) | 16.07 (1) | not measured |
| expert | 19 | 8 (1) | 12 (1) | 37 (1) | 67 (1) | 5.5 (1) | 0.53 (1) | 12.12 (1) | not measured |
| expert | 20 | 9 (1) | 1 (1) | 12 (1) | 36 (1) | 3.05 (1) | 0.17 (1) | 8.65 (1) | not measured |
| expert | 21 | 30 (1) | 12 (1) | 30 (1) | 105 (1) | 5.5 (1) | 0.62 (1) | 19.35 (1) | not measured |
| expert | 22 | 21 (1) | 12 (1) | 32 (1) | 66 (1) | 5.5 (1) | 0.07 (1) | 27.27 (1) | not measured |
| expert | 23 | 20 (1) | 9 (1) | 27 (1) | 76 (1) | 5.5 (1) | 0.03 (1) | 17.5 (1) | not measured |
| expert | 24 | 14 (1) | 9 (1) | 28 (1) | 79 (1) | 5.5 (1) | 0.53 (1) | 17.45 (1) | not measured |
| expert | 25 | 20 (1) | 9 (1) | 29 (1) | 65 (1) | 5.5 (1) | 0.17 (1) | 31.03 (1) | not measured |
| expert | 26 | 22 (1) | 19 (1) | 36 (1) | 1832 (1) | 5.5 (1) | 0.18 (1) | 16 (1) | 4.83 (1) |
| expert | 27 | 28 (1) | 16 (1) | 84 (1) | 1448 (1) | 5.5 (1) | 0.2 (1) | 30.53 (1) | not measured |
| expert | 28 | 25 (1) | 11 (1) | 86 (1) | 2042 (1) | 2.3 (1) | 0.15 (1) | 24.2 (1) | 7.1 (1) |
| expert | 29 | 14 (1) | 10 (1) | 105 (1) | 2478 (1) | 6.57 (1) | 2.53 (1) | 22.4 (1) | not measured |
| expert | 30 | 4 (1) | 12 (1) | 58 (1) | 1065 (1) | 5.5 (1) | 0.03 (1) | 18.87 (1) | not measured |
| expert | 31 | 9 (1) | 20 (1) | 58 (1) | 966 (1) | 6.08 (1) | 0.93 (1) | 23.07 (1) | not measured |
| expert | 32 | 24 (1) | 12 (1) | 45 (1) | 1366 (1) | 1.93 (1) | 0.17 (1) | 16.15 (1) | not measured |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 3 | 5 | 1.55 | stat_hp_max_10 → weapon_pistol → stat_damage_10 → stat_guard_meter_10 | pistol | rivet | node tools/dev/run.mjs gauntlet --seed=3 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| novice | 1 | 5 | 0.88 | ghost_tonnage → stat_hp_max_10 → stat_damage_10 → ghost_dent | none | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| novice | 2 | 5 | 0.88 | ghost_tonnage → ghost_ohm → stat_regen_10 → stat_hp_max_10 | none | rivet | node tools/dev/run.mjs gauntlet --seed=2 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| average | 1 | 15 | 1.55 | ghost_tonnage → stat_hp_max_10 → stat_damage_10 → ghost_dent → weapon_flamethrower → weapon_gatling → weapon_katana → ghost_kerf → weapon_pistol → stat_speed_10 → stat_guard_meter_10 → stat_regen_10 → weapon_rocket_launcher → weapon_plasma_sword | flamethrower, gatling, katana, pistol, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=average --pick=greedy --controls=wheel --waves=40 |
| average | 5 | 15 | 1.55 | stat_speed_10 → stat_guard_meter_10 → stat_damage_10 → ghost_kerf → weapon_pistol → ghost_ohm → weapon_plasma_sword → stat_hp_max_10 → weapon_gatling → ghost_tonnage → stat_regen_25 → weapon_flamethrower → stat_regen_10 → weapon_rocket_launcher | flamethrower, gatling, pistol, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=5 --bot=average --pick=greedy --controls=wheel --waves=40 |
| expert | 2 | 32 | 1.55 | ghost_tonnage → ghost_ohm → stat_regen_10 → stat_hp_max_10 → stat_guard_meter_10 → weapon_machine_pistol → weapon_gatling → stat_damage_25 → stat_speed_10 → ghost_kerf → stat_damage_10 → weapon_pistol → stat_hp_max_25 → stat_guard_meter_25 → weapon_electro_baton → ghost_dent → stat_speed_25 → weapon_plasma_rifle → weapon_gloria → weapon_plasma_sword → weapon_hand_cannon → effect_overkill_carry → weapon_rocket_launcher → effect_overkill_carry_2 → weapon_flamethrower → stat_regen_25 → weapon_katana → weapon_chainsaw | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=2 --bot=expert --pick=greedy --controls=wheel --waves=40 |
