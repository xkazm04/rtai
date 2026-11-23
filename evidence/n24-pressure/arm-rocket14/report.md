# Gauntlet run report

15 of 15 runs accepted. Average-profile waves 5 (15.15 s), 6 (18.7 s), 7 (18.99 s), 8 (21.86 s), 9 (24.39 s), 10 (24.29 s) fell outside 12–18 s for ordinary waves and 25–30 s for boss waves.

Live gauntlet batch · detached @ a9e8adc78eac (dirty) · 2026-11-22T21:22:17.344Z.

Stalled runs by profile: novice 0, average 0, expert 0.

Capped alive by profile: novice 0, average 0, expert 0.

## Death-wave score

Censored runs contribute their last reached wave as a lower bound to the median and spread.

| Profile | Target | Median wave | P25–P75 | Min–max | Deaths / censored |
| --- | --- | --- | --- | --- | --- |
| novice | 6 | 5 | 5–5 | 5–6 | 5 / 0 |
| average | 12 | 6 | 5–11 | 5–12 | 5 / 0 |
| expert | 20 | 5 | 5–10 | 5–25 | 5 / 0 |

## Profile separation

Targets require a median gap of 3 waves and a later death on at least 75% of shared seeds with the same controls and pick policy. Unresolved censored pairs stay in the denominator.

| Profiles | Observed median gap | Later / shared seeds | Confirmed later share | Unresolved | Verdict |
| --- | --- | --- | --- | --- | --- |
| novice → average | 1 | 2 / 5 | 40% | 0 | below target |
| novice → expert | 0 | 2 / 5 | 40% | 0 | below target |
| average → expert | -1 | 1 / 5 | 20% | 0 | below target |

## Waves per run

A timed-out wave can clear later. Active counts include each started roster still fighting at death.

| Profile | Seed | Outcome | Timed-out waves | Active waves at death |
| --- | --- | --- | --- | --- |
| novice | 1 | died on 5 | 0 | 1 |
| novice | 2 | died on 5 | 0 | 1 |
| novice | 3 | died on 5 | 0 | 1 |
| novice | 4 | died on 6 | 0 | 1 |
| novice | 5 | died on 5 | 0 | 1 |
| average | 1 | died on 5 | 0 | 1 |
| average | 2 | died on 5 | 0 | 1 |
| average | 3 | died on 11 | 0 | 1 |
| average | 4 | died on 6 | 0 | 1 |
| average | 5 | died on 12 | 0 | 1 |
| expert | 1 | died on 5 | 0 | 1 |
| expert | 2 | died on 5 | 0 | 1 |
| expert | 3 | died on 10 | 0 | 1 |
| expert | 4 | died on 5 | 0 | 1 |
| expert | 5 | died on 25 | 0 | 1 |

## Wave time

Seconds per observed wave. The target is 15 s ±20% for ordinary average-profile waves. Every 5th wave targets 25–30 s. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Median s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 5 / 5 | 13.18 | 12.8…15.33 | 9.82…15.87 | — |
| novice | 2 | 5 / 5 | 15.1 | 14.75…18.98 | 11.67…24.35 | — |
| novice | 3 | 5 / 5 | 16.43 | 13.67…18.65 | 13.23…22.2 | — |
| novice | 4 | 5 / 5 | 12.75 | 11.72…18.65 | 11.65…24.8 | — |
| novice | 5 | 1 / 5 | 9.88 | 9.88…9.88 | 9.88…9.88 | — |
| novice | 6 | 0 / 1 | not measured | not measured | not measured | — |
| average | 1 | 5 / 5 | 12.93 | 11.03…13.4 | 10.28…18.97 | within target |
| average | 2 | 5 / 5 | 13.22 | 13.03…15.45 | 11.78…19.9 | within target |
| average | 3 | 5 / 5 | 15.82 | 15.08…20.93 | 9.72…24.12 | within target |
| average | 4 | 5 / 5 | 13.07 | 12.57…16 | 10.4…19.45 | within target |
| average | 5 | 3 / 5 | 15.15 | 10.03…19.38 | 10.03…19.38 | miss |
| average | 6 | 2 / 3 | 18.7 | 15.42…21.98 | 15.42…21.98 | miss |
| average | 7 | 2 / 2 | 18.99 | 18.07…19.92 | 18.07…19.92 | miss |
| average | 8 | 2 / 2 | 21.86 | 19.82…23.9 | 19.82…23.9 | miss |
| average | 9 | 2 / 2 | 24.39 | 17.48…31.3 | 17.48…31.3 | miss |
| average | 10 | 2 / 2 | 24.29 | 20.37…28.22 | 20.37…28.22 | miss |
| average | 11 | 1 / 2 | 17.6 | 17.6…17.6 | 17.6…17.6 | within target |
| average | 12 | 0 / 1 | not measured | not measured | not measured | not measured |
| expert | 1 | 5 / 5 | 15.83 | 15.55…15.85 | 14.55…16.83 | — |
| expert | 2 | 5 / 5 | 20.57 | 14.22…22.35 | 12.38…22.42 | — |
| expert | 3 | 5 / 5 | 18.22 | 13.02…21.2 | 8.57…26.33 | — |
| expert | 4 | 5 / 5 | 14.97 | 10.65…16.13 | 8.67…31.35 | — |
| expert | 5 | 2 / 5 | 9.9 | 6.17…13.63 | 6.17…13.63 | — |
| expert | 6 | 2 / 2 | 17.04 | 14.48…19.6 | 14.48…19.6 | — |
| expert | 7 | 2 / 2 | 15.24 | 13.82…16.67 | 13.82…16.67 | — |
| expert | 8 | 2 / 2 | 16.81 | 16.4…17.22 | 16.4…17.22 | — |
| expert | 9 | 2 / 2 | 24.31 | 21.28…27.33 | 21.28…27.33 | — |
| expert | 10 | 1 / 2 | 8.5 | 8.5…8.5 | 8.5…8.5 | — |
| expert | 11 | 1 / 1 | 18.5 | 18.5…18.5 | 18.5…18.5 | — |
| expert | 12 | 1 / 1 | 24.33 | 24.33…24.33 | 24.33…24.33 | — |
| expert | 13 | 1 / 1 | 26.2 | 26.2…26.2 | 26.2…26.2 | — |
| expert | 14 | 1 / 1 | 28.37 | 28.37…28.37 | 28.37…28.37 | — |
| expert | 15 | 1 / 1 | 12.48 | 12.48…12.48 | 12.48…12.48 | — |
| expert | 16 | 1 / 1 | 30.3 | 30.3…30.3 | 30.3…30.3 | — |
| expert | 17 | 1 / 1 | 30.32 | 30.32…30.32 | 30.32…30.32 | — |
| expert | 18 | 1 / 1 | 30.6 | 30.6…30.6 | 30.6…30.6 | — |
| expert | 19 | 1 / 1 | 25.98 | 25.98…25.98 | 25.98…25.98 | — |
| expert | 20 | 1 / 1 | 31.37 | 31.37…31.37 | 31.37…31.37 | — |
| expert | 21 | 1 / 1 | 31.82 | 31.82…31.82 | 31.82…31.82 | — |
| expert | 22 | 1 / 1 | 31.85 | 31.85…31.85 | 31.85…31.85 | — |
| expert | 23 | 1 / 1 | 38.03 | 38.03…38.03 | 38.03…38.03 | — |
| expert | 24 | 1 / 1 | 38.17 | 38.17…38.17 | 38.17…38.17 | — |
| expert | 25 | 0 / 1 | not measured | not measured | not measured | — |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 5 | 5 | 0 | 0 | 0 | 5 × 4, 6 × 1 | stomp × 4, robot_gunner × 1 | 0 |
| average | 5 | 5 | 0 | 0 | 0 | 5 × 2, 6 × 1, 11 × 1, 12 × 1 | sentry_turret × 2, stomp × 2, rocket × 1 | 0 |
| expert | 5 | 5 | 0 | 0 | 0 | 5 × 3, 10 × 1, 25 × 1 | contractor × 2, patrol_cop × 1, sentry_turret × 1, war_cannon × 1 | 0 |

## Timeouts

Runs that reached the wave time limit.

| Outcome | novice | average | expert |
| --- | --- | --- | --- |
| timeout | 0 | 0 | 0 |

## Survival by wave band

Each wave contributes once to each available median. Damage/s needs a timed wave. Repair/s is the configured rate when repair is active. HP coverage counts waves sampled by the bot. Repaired HP sums positive HP steps. The share undone uses waves with positive damage. Multipliers include stat cards taken before the wave.

| Profile | Waves | HP rows / observed | Damage | Damage/s | Repair/s | Minimum HP (% of capacity) | Repaired HP | Damage undone (%) | Guard deflects | Cover ticks | Rolls | damage × | guard_meter × | hp_max × | regen × | speed × |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1–10 | 26 / 26 | 18.33 | 0.98 | 10 | 54.64 | 0 | 0 | 6 | 0 | 2 | 1 | 1 | 1 | 1 | 1 |
| novice | 11–20 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| novice | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| novice | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 1–10 | 36 / 36 | 15.6 | 1.07 | 10 | 77.57 | 0 | 0 | 5.5 | 2 | 4 | 1.1 | 1 | 1 | 1 | 1 |
| average | 11–20 | 3 / 3 | 88.21 | 0.82 | 11 | 0 | 0 | 0 | 6 | 0 | 5 | 1.1 | 1.1 | 1.1 | 1.1 | 1.1 |
| average | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 1–10 | 35 / 35 | 16.8 | 0.86 | 10 | 83.2 | 0 | 0 | 6 | 34 | 6 | 1.1 | 1 | 1 | 1 | 1 |
| expert | 11–20 | 10 / 10 | 25.2 | 0.9 | 13.75 | 77.09 | 0 | 0 | 5.5 | 80.5 | 10 | 1.1 | 1.1 | 1.1 | 1.375 | 1.1 |
| expert | 21–30 | 5 / 5 | 56.67 | 1.51 | 13.75 | 48.48 | 0 | 0 | 8 | 94 | 11 | 1.375 | 1.375 | 1.1 | 1.375 | 1.1 |
| expert | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 2 | — | 67.56% | 18.22 (63) | 15.15 (37) |
| patrol_cop | 1 | — | 85.64% | 15.82 (88) | 21.11 (12) |
| riot_cop | 0 | — | 60.74% | 18.14 (58) | 15.39 (42) |
| robot_gunner | 1 | — | 36.6% | 21.63 (28) | 15.13 (72) |
| robot_thug | 0 | — | 37.28% | 24.12 (28) | 15.09 (72) |
| rocket_trooper | 1 | rocket × 1 | 69.58% | 18.65 (63) | 14.55 (37) |
| sentry_turret | 3 | — | 32% | 24.12 (24) | 15.24 (76) |
| shield_robot | 0 | — | 22.32% | 29.33 (14) | 15.68 (86) |
| swat | 0 | — | 55.03% | 17.83 (52) | 15.39 (48) |
| war_machine | 7 | stomp × 6, war_cannon × 1 | 9.66% | 13.63 (11) | 16.43 (89) |

## Moves

Uses count recorded activations by profile and wave number. The game omits zero counts. Times are medians in seconds, with timed wave counts in parentheses. Carry applies to all waves.

| Profile | Wave | Move | Enemy | Recorded uses | Observed waves | Uses per wave | With enemy s (n) | Without enemy s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | All | ohm_short_circuit | sentry_turret | 1 | 26 | 0.04 | — | 14.75 (21) |
| novice | All | tonnage_armour_crack | war_machine | 1 | 26 | 0.04 | 9.88 (1) | 14.93 (20) |
| novice | All | kerf_blink_behind | shield_robot | 0 | 26 | 0 | — | 14.75 (21) |
| novice | All | overkill_carry | all waves | 0 | 26 | 0 | 14.75 (21) | — |
| novice | 1 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 13.18 (5) |
| novice | 1 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 13.18 (5) |
| novice | 1 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 13.18 (5) |
| novice | 1 | overkill_carry | all waves | 0 | 5 | 0 | 13.18 (5) | — |
| novice | 2 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 15.1 (5) |
| novice | 2 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 15.1 (5) |
| novice | 2 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 15.1 (5) |
| novice | 2 | overkill_carry | all waves | 0 | 5 | 0 | 15.1 (5) | — |
| novice | 3 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 16.43 (5) |
| novice | 3 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 16.43 (5) |
| novice | 3 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 16.43 (5) |
| novice | 3 | overkill_carry | all waves | 0 | 5 | 0 | 16.43 (5) | — |
| novice | 4 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 12.75 (5) |
| novice | 4 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 12.75 (5) |
| novice | 4 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 12.75 (5) |
| novice | 4 | overkill_carry | all waves | 0 | 5 | 0 | 12.75 (5) | — |
| novice | 5 | ohm_short_circuit | sentry_turret | 1 | 5 | 0.2 | — | 9.88 (1) |
| novice | 5 | tonnage_armour_crack | war_machine | 1 | 5 | 0.2 | 9.88 (1) | — |
| novice | 5 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 9.88 (1) |
| novice | 5 | overkill_carry | all waves | 0 | 5 | 0 | 9.88 (1) | — |
| novice | 6 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | — | — |
| novice | 6 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | — |
| novice | 6 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | — |
| novice | 6 | overkill_carry | all waves | 0 | 1 | 0 | — | — |
| average | All | ohm_short_circuit | sentry_turret | 11 | 39 | 0.28 | 19.92 (7) | 15.15 (27) |
| average | All | tonnage_armour_crack | war_machine | 2 | 39 | 0.05 | 19.38 (5) | 15.82 (29) |
| average | All | kerf_blink_behind | shield_robot | 3 | 39 | 0.08 | 29.76 (2) | 15.63 (32) |
| average | All | overkill_carry | all waves | 0 | 39 | 0 | 15.91 (34) | — |
| average | 1 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 12.93 (5) |
| average | 1 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 12.93 (5) |
| average | 1 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 12.93 (5) |
| average | 1 | overkill_carry | all waves | 0 | 5 | 0 | 12.93 (5) | — |
| average | 2 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 13.22 (5) |
| average | 2 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 13.22 (5) |
| average | 2 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 13.22 (5) |
| average | 2 | overkill_carry | all waves | 0 | 5 | 0 | 13.22 (5) | — |
| average | 3 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 15.82 (5) |
| average | 3 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 15.82 (5) |
| average | 3 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 15.82 (5) |
| average | 3 | overkill_carry | all waves | 0 | 5 | 0 | 15.82 (5) | — |
| average | 4 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 13.07 (5) |
| average | 4 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 13.07 (5) |
| average | 4 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 13.07 (5) |
| average | 4 | overkill_carry | all waves | 0 | 5 | 0 | 13.07 (5) | — |
| average | 5 | ohm_short_circuit | sentry_turret | 1 | 5 | 0.2 | — | 15.15 (3) |
| average | 5 | tonnage_armour_crack | war_machine | 2 | 5 | 0.4 | 15.15 (3) | — |
| average | 5 | kerf_blink_behind | shield_robot | 1 | 5 | 0.2 | — | 15.15 (3) |
| average | 5 | overkill_carry | all waves | 0 | 5 | 0 | 15.15 (3) | — |
| average | 6 | ohm_short_circuit | sentry_turret | 0 | 3 | 0 | 15.42 (1) | 21.98 (1) |
| average | 6 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 18.7 (2) |
| average | 6 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | — | 18.7 (2) |
| average | 6 | overkill_carry | all waves | 0 | 3 | 0 | 18.7 (2) | — |
| average | 7 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | 19.92 (1) | 18.07 (1) |
| average | 7 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 18.99 (2) |
| average | 7 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 18.99 (2) |
| average | 7 | overkill_carry | all waves | 0 | 2 | 0 | 18.99 (2) | — |
| average | 8 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | 21.86 (2) | — |
| average | 8 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 21.86 (2) |
| average | 8 | kerf_blink_behind | shield_robot | 1 | 2 | 0.5 | — | 21.86 (2) |
| average | 8 | overkill_carry | all waves | 0 | 2 | 0 | 21.86 (2) | — |
| average | 9 | ohm_short_circuit | sentry_turret | 3 | 2 | 1.5 | 24.39 (2) | — |
| average | 9 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 24.39 (2) |
| average | 9 | kerf_blink_behind | shield_robot | 1 | 2 | 0.5 | 31.3 (1) | 17.48 (1) |
| average | 9 | overkill_carry | all waves | 0 | 2 | 0 | 24.39 (2) | — |
| average | 10 | ohm_short_circuit | sentry_turret | 3 | 2 | 1.5 | 20.37 (1) | 28.22 (1) |
| average | 10 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | 24.29 (2) | — |
| average | 10 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | 28.22 (1) | 20.37 (1) |
| average | 10 | overkill_carry | all waves | 0 | 2 | 0 | 24.29 (2) | — |
| average | 11 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | — | 17.6 (1) |
| average | 11 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 17.6 (1) |
| average | 11 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 17.6 (1) |
| average | 11 | overkill_carry | all waves | 0 | 2 | 0 | 17.6 (1) | — |
| average | 12 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | — | — |
| average | 12 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | — |
| average | 12 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | — |
| average | 12 | overkill_carry | all waves | 0 | 1 | 0 | — | — |
| expert | All | ohm_short_circuit | sentry_turret | 21 | 50 | 0.42 | 27.33 (17) | 15.84 (28) |
| expert | All | tonnage_armour_crack | war_machine | 1 | 50 | 0.02 | 12.48 (5) | 19.05 (40) |
| expert | All | kerf_blink_behind | shield_robot | 29 | 50 | 0.58 | 29.33 (12) | 16.13 (33) |
| expert | All | overkill_carry | all waves | 53 | 50 | 1.06 | 18.22 (45) | — |
| expert | 1 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 15.83 (5) |
| expert | 1 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 15.83 (5) |
| expert | 1 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 15.83 (5) |
| expert | 1 | overkill_carry | all waves | 0 | 5 | 0 | 15.83 (5) | — |
| expert | 2 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 20.57 (5) |
| expert | 2 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 20.57 (5) |
| expert | 2 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 20.57 (5) |
| expert | 2 | overkill_carry | all waves | 0 | 5 | 0 | 20.57 (5) | — |
| expert | 3 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 18.22 (5) |
| expert | 3 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 18.22 (5) |
| expert | 3 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 18.22 (5) |
| expert | 3 | overkill_carry | all waves | 0 | 5 | 0 | 18.22 (5) | — |
| expert | 4 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 14.97 (5) |
| expert | 4 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 14.97 (5) |
| expert | 4 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 14.97 (5) |
| expert | 4 | overkill_carry | all waves | 0 | 5 | 0 | 14.97 (5) | — |
| expert | 5 | ohm_short_circuit | sentry_turret | 2 | 5 | 0.4 | — | 9.9 (2) |
| expert | 5 | tonnage_armour_crack | war_machine | 1 | 5 | 0.2 | 9.9 (2) | — |
| expert | 5 | kerf_blink_behind | shield_robot | 1 | 5 | 0.2 | — | 9.9 (2) |
| expert | 5 | overkill_carry | all waves | 0 | 5 | 0 | 9.9 (2) | — |
| expert | 6 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 14.48 (1) | 19.6 (1) |
| expert | 6 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 17.04 (2) |
| expert | 6 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 17.04 (2) |
| expert | 6 | overkill_carry | all waves | 0 | 2 | 0 | 17.04 (2) | — |
| expert | 7 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | 16.67 (1) | 13.82 (1) |
| expert | 7 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 15.24 (2) |
| expert | 7 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 15.24 (2) |
| expert | 7 | overkill_carry | all waves | 0 | 2 | 0 | 15.24 (2) | — |
| expert | 8 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | 16.81 (2) | — |
| expert | 8 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 16.81 (2) |
| expert | 8 | kerf_blink_behind | shield_robot | 1 | 2 | 0.5 | — | 16.81 (2) |
| expert | 8 | overkill_carry | all waves | 0 | 2 | 0 | 16.81 (2) | — |
| expert | 9 | ohm_short_circuit | sentry_turret | 3 | 2 | 1.5 | 24.31 (2) | — |
| expert | 9 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 24.31 (2) |
| expert | 9 | kerf_blink_behind | shield_robot | 1 | 2 | 0.5 | 27.33 (1) | 21.28 (1) |
| expert | 9 | overkill_carry | all waves | 0 | 2 | 0 | 24.31 (2) | — |
| expert | 10 | ohm_short_circuit | sentry_turret | 2 | 2 | 1 | 8.5 (1) | — |
| expert | 10 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | 8.5 (1) | — |
| expert | 10 | kerf_blink_behind | shield_robot | 1 | 2 | 0.5 | — | 8.5 (1) |
| expert | 10 | overkill_carry | all waves | 0 | 2 | 0 | 8.5 (1) | — |
| expert | 11 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | — | 18.5 (1) |
| expert | 11 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 18.5 (1) |
| expert | 11 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | 18.5 (1) |
| expert | 11 | overkill_carry | all waves | 0 | 1 | 0 | 18.5 (1) | — |
| expert | 12 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 24.33 (1) | — |
| expert | 12 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 24.33 (1) |
| expert | 12 | kerf_blink_behind | shield_robot | 1 | 1 | 1 | 24.33 (1) | — |
| expert | 12 | overkill_carry | all waves | 0 | 1 | 0 | 24.33 (1) | — |
| expert | 13 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | — | 26.2 (1) |
| expert | 13 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 26.2 (1) |
| expert | 13 | kerf_blink_behind | shield_robot | 1 | 1 | 1 | 26.2 (1) | — |
| expert | 13 | overkill_carry | all waves | 0 | 1 | 0 | 26.2 (1) | — |
| expert | 14 | ohm_short_circuit | sentry_turret | 2 | 1 | 2 | 28.37 (1) | — |
| expert | 14 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 28.37 (1) |
| expert | 14 | kerf_blink_behind | shield_robot | 3 | 1 | 3 | 28.37 (1) | — |
| expert | 14 | overkill_carry | all waves | 0 | 1 | 0 | 28.37 (1) | — |
| expert | 15 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | — | 12.48 (1) |
| expert | 15 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | 12.48 (1) | — |
| expert | 15 | kerf_blink_behind | shield_robot | 2 | 1 | 2 | 12.48 (1) | — |
| expert | 15 | overkill_carry | all waves | 0 | 1 | 0 | 12.48 (1) | — |
| expert | 16 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 30.3 (1) | — |
| expert | 16 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 30.3 (1) |
| expert | 16 | kerf_blink_behind | shield_robot | 2 | 1 | 2 | 30.3 (1) | — |
| expert | 16 | overkill_carry | all waves | 0 | 1 | 0 | 30.3 (1) | — |
| expert | 17 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | 30.32 (1) | — |
| expert | 17 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 30.32 (1) |
| expert | 17 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | 30.32 (1) |
| expert | 17 | overkill_carry | all waves | 5 | 1 | 5 | 30.32 (1) | — |
| expert | 18 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | — | 30.6 (1) |
| expert | 18 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 30.6 (1) |
| expert | 18 | kerf_blink_behind | shield_robot | 1 | 1 | 1 | 30.6 (1) | — |
| expert | 18 | overkill_carry | all waves | 4 | 1 | 4 | 30.6 (1) | — |
| expert | 19 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 25.98 (1) | — |
| expert | 19 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 25.98 (1) |
| expert | 19 | kerf_blink_behind | shield_robot | 4 | 1 | 4 | 25.98 (1) | — |
| expert | 19 | overkill_carry | all waves | 4 | 1 | 4 | 25.98 (1) | — |
| expert | 20 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | 31.37 (1) | — |
| expert | 20 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | 31.37 (1) | — |
| expert | 20 | kerf_blink_behind | shield_robot | 1 | 1 | 1 | — | 31.37 (1) |
| expert | 20 | overkill_carry | all waves | 3 | 1 | 3 | 31.37 (1) | — |
| expert | 21 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | 31.82 (1) | — |
| expert | 21 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 31.82 (1) |
| expert | 21 | kerf_blink_behind | shield_robot | 2 | 1 | 2 | 31.82 (1) | — |
| expert | 21 | overkill_carry | all waves | 11 | 1 | 11 | 31.82 (1) | — |
| expert | 22 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 31.85 (1) | — |
| expert | 22 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 31.85 (1) |
| expert | 22 | kerf_blink_behind | shield_robot | 1 | 1 | 1 | 31.85 (1) | — |
| expert | 22 | overkill_carry | all waves | 8 | 1 | 8 | 31.85 (1) | — |
| expert | 23 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 38.03 (1) | — |
| expert | 23 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 38.03 (1) |
| expert | 23 | kerf_blink_behind | shield_robot | 3 | 1 | 3 | 38.03 (1) | — |
| expert | 23 | overkill_carry | all waves | 5 | 1 | 5 | 38.03 (1) | — |
| expert | 24 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 38.17 (1) | — |
| expert | 24 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 38.17 (1) |
| expert | 24 | kerf_blink_behind | shield_robot | 4 | 1 | 4 | 38.17 (1) | — |
| expert | 24 | overkill_carry | all waves | 7 | 1 | 7 | 38.17 (1) | — |
| expert | 25 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | — | — |
| expert | 25 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | — |
| expert | 25 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | — |
| expert | 25 | overkill_carry | all waves | 6 | 1 | 6 | — | — |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| effect_overkill_carry | waves survived | 8 (1) | 1.5 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| effect_overkill_carry | wave s | 31.59 (1) | 20.52 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| effect_overkill_carry_2 | waves survived | 4 (1) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| effect_overkill_carry_2 | wave s | 34.94 (1) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_dent | waves survived | 0 (5) | 3 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_dent | wave s | 31.37 (1) | 17.6 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_kerf | waves survived | 7 (3) | 1.5 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_kerf | wave s | 21.85 (2) | 28.55 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | waves survived | 2 (7) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | wave s | 22.18 (7) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_tonnage | waves survived | 3 (10) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| ghost_tonnage | wave s | 18.65 (10) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_10 | waves survived | 3.5 (12) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_10 | wave s | 17.18 (12) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_25 | waves survived | 2 (4) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_25 | wave s | 12.83 (4) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 5.5 (6) | 3 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_10 | wave s | 20.62 (5) | 16.93 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_25 | waves survived | 1 (4) | 5 (5) | 3 | -5 | -5…1 | not measured (3, all offered) | too few pairs |
| stat_guard_meter_25 | wave s | 19.38 (3) | 19.71 (4) | 1 | -1.52 | not measured | not measured (1, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 2 (11) | 1.5 (4) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_hp_max_10 | wave s | 18.27 (8) | 12.83 (4) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_hp_max_25 | waves survived | not measured | 3.5 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_25 | wave s | not measured | 21.5 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_10 | waves survived | 2.5 (6) | 2 (6) | 1 | 5 | not measured | not measured (1, all offered) | too few pairs |
| stat_regen_10 | wave s | 20.2 (6) | 19.45 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | waves survived | 6.5 (2) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | wave s | 30.32 (1) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | waves survived | 3 (6) | 0 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | wave s | 16.13 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_25 | waves survived | 0 (1) | 0.5 (8) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_25 | wave s | not measured | 12.83 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_chainsaw | waves survived | 3 (1) | 6 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_chainsaw | wave s | 38.03 (1) | 15.52 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | waves survived | 2 (1) | 2 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | wave s | 38.1 (1) | 18.76 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | waves survived | 12 (1) | 4 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | wave s | 30.46 (1) | 18.98 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gatling | waves survived | 8.5 (2) | 1.5 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gatling | wave s | 24.64 (2) | 28.55 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gloria | waves survived | 2.5 (2) | 3 (12) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gloria | wave s | 25.25 (2) | 16.22 (12) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | 6 (1) | 1 (9) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_hand_cannon | wave s | 31.83 (1) | 18.82 (8) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_katana | waves survived | not measured | 7.5 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_katana | wave s | not measured | 18.27 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_machine_pistol | waves survived | not measured | 3 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_machine_pistol | wave s | not measured | 20.83 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_pistol | waves survived | 7 (5) | 2 (7) | 3 | 5 | -1…5 | not measured (3, all offered) | too few pairs |
| weapon_pistol | wave s | 18.76 (5) | 15.13 (4) | 3 | 1.56 | -0.62…3.12 | not measured (3, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | 1 (1) | 3.5 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_rifle | wave s | 38.17 (1) | 15.52 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_sword | waves survived | 10.5 (2) | 0 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_sword | wave s | 23.68 (2) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_rocket_launcher | waves survived | 0 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_rocket_launcher | wave s | 29.6 (2) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | 3 (1) | 6 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| chainsaw | wave s | 38.03 (1) | 15.52 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | waves survived | 2 (1) | 2 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | wave s | 38.1 (1) | 18.76 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | waves survived | 12 (1) | 4 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | wave s | 30.46 (1) | 18.98 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gatling | waves survived | 8.5 (2) | 1.5 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gatling | wave s | 24.64 (2) | 28.55 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gloria | waves survived | 2.5 (2) | 3 (12) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gloria | wave s | 25.25 (2) | 16.22 (12) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| hand_cannon | waves survived | 6 (1) | 1 (9) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| hand_cannon | wave s | 31.83 (1) | 18.82 (8) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| katana | waves survived | not measured | 7.5 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| katana | wave s | not measured | 18.27 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| machine_pistol | waves survived | not measured | 3 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| machine_pistol | wave s | not measured | 20.83 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| pistol | waves survived | 7 (5) | 2 (7) | 3 | 5 | -1…5 | not measured (3, all offered) | too few pairs |
| pistol | wave s | 18.76 (5) | 15.13 (4) | 3 | 1.56 | -0.62…3.12 | not measured (3, all offered) | too few pairs |
| plasma_rifle | waves survived | 1 (1) | 3.5 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_rifle | wave s | 38.17 (1) | 15.52 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_sword | waves survived | 10.5 (2) | 0 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_sword | wave s | 23.68 (2) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| rocket_launcher | waves survived | 0 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| rocket_launcher | wave s | 29.6 (2) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | kerf s (n) | ohm s (n) | rivet s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 8 (5) | 2 (5) | 0 (5) | 13 (5) | not measured | not measured | 13.18 (5) | not measured |
| novice | 2 | 9 (5) | 3 (5) | 0 (5) | 14 (5) | not measured | not measured | 15.1 (5) | not measured |
| novice | 3 | 6 (5) | 3 (5) | 0 (5) | 12 (5) | not measured | not measured | 15.1 (5) | 7.1 (1) |
| novice | 4 | 6 (5) | 1 (5) | 0 (5) | 12 (5) | not measured | not measured | 12.75 (5) | not measured |
| novice | 5 | 3 (5) | 2 (5) | 0 (5) | 12 (5) | not measured | 4.53 (1) | 6.95 (5) | 0.52 (1) |
| novice | 6 | 3 (1) | 3 (1) | 2 (1) | 12 (1) | not measured | not measured | 14.27 (1) | not measured |
| average | 1 | 8 (5) | 2 (5) | 0 (5) | 13 (5) | not measured | not measured | 12.93 (5) | not measured |
| average | 2 | 4 (5) | 3 (5) | 0 (5) | 14 (5) | not measured | not measured | 13.22 (5) | not measured |
| average | 3 | 8 (5) | 6 (5) | 0 (5) | 12 (5) | not measured | 3.32 (1) | 13.83 (5) | 7.1 (2) |
| average | 4 | 6 (5) | 3 (5) | 0 (5) | 12 (5) | not measured | 7.3 (1) | 13.07 (5) | not measured |
| average | 5 | 1 (5) | 5 (5) | 0 (5) | 9 (5) | 5.5 (1) | 2.42 (1) | 6.85 (5) | 6.9 (2) |
| average | 6 | 12 (3) | 5 (3) | 30 (3) | 27 (3) | 5.5 (1) | not measured | 19.5 (3) | not measured |
| average | 7 | 6.5 (2) | 8 (2) | 28.5 (2) | 26.5 (2) | 5.5 (1) | 0.03 (1) | 12.68 (2) | 7.1 (1) |
| average | 8 | 8 (2) | 3 (2) | 33.5 (2) | 34 (2) | 5.5 (1) | 0.03 (1) | 19.09 (2) | not measured |
| average | 9 | 4.5 (2) | 6.5 (2) | 30 (2) | 49.5 (2) | 3.38 (1) | 0.75 (2) | 18.4 (2) | 7.1 (1) |
| average | 10 | 1 (2) | 12.5 (2) | 52 (2) | 50 (2) | 5.9 (1) | 0.05 (2) | 17.74 (2) | 7.1 (1) |
| average | 11 | 5.5 (2) | 8.5 (2) | 23.5 (2) | 35.5 (2) | 5.08 (1) | 0.03 (1) | 14.67 (2) | 7.1 (1) |
| average | 12 | 6 (1) | 3 (1) | 30 (1) | 37 (1) | 0.37 (1) | 0.3 (1) | 10.33 (1) | not measured |
| expert | 1 | 9 (5) | 3 (5) | 0 (5) | 13 (5) | not measured | not measured | 15.83 (5) | not measured |
| expert | 2 | 9 (5) | 5 (5) | 0 (5) | 14 (5) | not measured | not measured | 20.57 (5) | not measured |
| expert | 3 | 6 (5) | 5 (5) | 0 (5) | 12 (5) | not measured | 2.17 (1) | 18.22 (5) | 7.1 (1) |
| expert | 4 | 8 (5) | 3 (5) | 0 (5) | 12 (5) | not measured | 2.48 (1) | 14.97 (5) | 7.1 (1) |
| expert | 5 | 1 (5) | 13 (5) | 0 (5) | 15 (5) | 0.67 (1) | 5.45 (1) | 13.63 (5) | 7.1 (2) |
| expert | 6 | 8 (2) | 8 (2) | 25 (2) | 27.5 (2) | 2.03 (1) | not measured | 16.02 (2) | not measured |
| expert | 7 | 3.5 (2) | 7.5 (2) | 29 (2) | 31.5 (2) | 6.15 (1) | 0.17 (1) | 8.97 (2) | 6.22 (1) |
| expert | 8 | 4 (2) | 6 (2) | 29.5 (2) | 34 (2) | 2.75 (1) | 0.03 (1) | 15.42 (2) | not measured |
| expert | 9 | 4.5 (2) | 5.5 (2) | 30 (2) | 46 (2) | 5.5 (1) | 0.05 (2) | 18.14 (2) | 6.73 (1) |
| expert | 10 | 0.5 (2) | 3.5 (2) | 27.5 (2) | 25 (2) | 2.83 (1) | 0.03 (2) | 7.98 (2) | not measured |
| expert | 11 | 4 (1) | 8 (1) | 50 (1) | 49 (1) | 0.42 (1) | not measured | 10.98 (1) | 7.1 (1) |
| expert | 12 | 10 (1) | 15 (1) | 38 (1) | 54 (1) | 5.5 (1) | 0.03 (1) | 18.8 (1) | not measured |
| expert | 13 | 6 (1) | 10 (1) | 47 (1) | 37 (1) | 5.5 (1) | 0.17 (1) | 20.53 (1) | not measured |
| expert | 14 | 2 (1) | 11 (1) | 107 (1) | 809 (1) | 5.5 (1) | 0.07 (1) | 22.8 (1) | not measured |
| expert | 15 | 0 (1) | 5 (1) | 35 (1) | 239 (1) | 5.5 (1) | 0.03 (1) | 6.95 (1) | not measured |
| expert | 16 | 10 (1) | 9 (1) | 147 (1) | 2399 (1) | 5.5 (1) | 0.03 (1) | 24.77 (1) | not measured |
| expert | 17 | 5 (1) | 12 (1) | 81 (1) | 834 (1) | 5.5 (1) | 7.3 (1) | 17.52 (1) | not measured |
| expert | 18 | 9 (1) | 10 (1) | 131 (1) | 3002 (1) | 6.15 (1) | 0.62 (1) | 23.83 (1) | not measured |
| expert | 19 | 12 (1) | 9 (1) | 124 (1) | 1886 (1) | 6.47 (1) | 0.03 (1) | 19.48 (1) | not measured |
| expert | 20 | 4 (1) | 14 (1) | 109 (1) | 1825 (1) | 3.95 (1) | not measured | 20.32 (1) | 7.1 (1) |
| expert | 21 | 8 (1) | 10 (1) | 74 (1) | 787 (1) | 5.5 (1) | 7.3 (1) | 19.02 (1) | not measured |
| expert | 22 | 8 (1) | 11 (1) | 85 (1) | 1005 (1) | 7.88 (1) | 0.17 (1) | 23.8 (1) | not measured |
| expert | 23 | 8 (1) | 19 (1) | 80 (1) | 3027 (1) | 10.95 (1) | 0.55 (1) | 26.53 (1) | not measured |
| expert | 24 | 16 (1) | 16 (1) | 118 (1) | 3692 (1) | 11 (1) | 0.73 (1) | 26.43 (1) | not measured |
| expert | 25 | 2 (1) | 5 (1) | 33 (1) | 977 (1) | not measured | 0.3 (1) | 11.48 (1) | not measured |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 4 | 6 | 1.55 | stat_damage_10 → stat_speed_10 → stat_damage_25 → stat_guard_meter_25 → weapon_rocket_launcher | rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=4 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| average | 5 | 12 | 1.55 | stat_speed_10 → stat_guard_meter_10 → stat_damage_10 → ghost_kerf → weapon_pistol → ghost_ohm → weapon_plasma_sword → stat_hp_max_10 → weapon_gatling → ghost_tonnage → stat_regen_25 | gatling, pistol, plasma_sword | rivet | node tools/dev/run.mjs gauntlet --seed=5 --bot=average --pick=greedy --controls=wheel --waves=40 |
| expert | 5 | 25 | 1.55 | stat_speed_10 → stat_guard_meter_10 → stat_damage_10 → ghost_kerf → weapon_pistol → ghost_ohm → weapon_plasma_sword → stat_hp_max_10 → weapon_gatling → ghost_tonnage → stat_regen_25 → weapon_flamethrower → stat_regen_10 → weapon_rocket_launcher → ghost_dent → effect_overkill_carry → stat_damage_25 → weapon_hand_cannon → stat_guard_meter_25 → effect_overkill_carry_2 → weapon_chainsaw → weapon_electro_baton → weapon_plasma_rifle → stat_speed_25 | chainsaw, electro_baton, flamethrower, gatling, hand_cannon, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=5 --bot=expert --pick=greedy --controls=wheel --waves=40 |
