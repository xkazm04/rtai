# Gauntlet run report

15 of 15 runs accepted. Average-profile waves 4 (27 s), 5 (12.77 s), 6 (24.48 s), 7 (21.25 s), 8 (24.88 s), 10 (7.97 s), 11 (33.8 s) fell outside 12–18 s for ordinary waves and 25–30 s for boss waves.

Live gauntlet batch · detached @ a9e8adc78eac · 2026-11-22T21:15:22.573Z.

Stalled runs by profile: novice 0, average 0, expert 0.

Capped alive by profile: novice 0, average 0, expert 0.

## Death-wave score

Censored runs contribute their last reached wave as a lower bound to the median and spread.

| Profile | Target | Median wave | P25–P75 | Min–max | Deaths / censored |
| --- | --- | --- | --- | --- | --- |
| novice | 6 | 5 | 5–5 | 4–6 | 5 / 0 |
| average | 12 | 5 | 3–5 | 3–12 | 5 / 0 |
| expert | 20 | 7 | 5–9 | 3–18 | 5 / 0 |

## Profile separation

Targets require a median gap of 3 waves and a later death on at least 75% of shared seeds with the same controls and pick policy. Unresolved censored pairs stay in the denominator.

| Profiles | Observed median gap | Later / shared seeds | Confirmed later share | Unresolved | Verdict |
| --- | --- | --- | --- | --- | --- |
| novice → average | 0 | 1 / 5 | 20% | 0 | below target |
| novice → expert | 2 | 3 / 5 | 60% | 0 | below target |
| average → expert | 2 | 3 / 5 | 60% | 0 | below target |

## Waves per run

A timed-out wave can clear later. Active counts include each started roster still fighting at death.

| Profile | Seed | Outcome | Timed-out waves | Active waves at death |
| --- | --- | --- | --- | --- |
| novice | 1 | died on 5 | 0 | 1 |
| novice | 2 | died on 5 | 0 | 1 |
| novice | 3 | died on 5 | 0 | 1 |
| novice | 4 | died on 6 | 0 | 1 |
| novice | 5 | died on 4 | 0 | 1 |
| average | 1 | died on 3 | 0 | 1 |
| average | 2 | died on 3 | 0 | 1 |
| average | 3 | died on 5 | 0 | 1 |
| average | 4 | died on 5 | 0 | 1 |
| average | 5 | died on 12 | 0 | 1 |
| expert | 1 | died on 3 | 0 | 1 |
| expert | 2 | died on 7 | 1 | 2 |
| expert | 3 | died on 5 | 0 | 1 |
| expert | 4 | died on 9 | 0 | 1 |
| expert | 5 | died on 18 | 1 | 2 |

## Wave time

Seconds per observed wave. The target is 15 s ±20% for ordinary average-profile waves. Every 5th wave targets 25–30 s. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Median s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 5 / 5 | 13.18 | 12.8…15.33 | 9.82…15.87 | — |
| novice | 2 | 5 / 5 | 15.1 | 14.75…18.98 | 11.67…24.35 | — |
| novice | 3 | 5 / 5 | 16.5 | 13.67…19.12 | 13.23…22.93 | — |
| novice | 4 | 4 / 5 | 12.99 | 11.65…14.45 | 11.12…14.45 | — |
| novice | 5 | 1 / 4 | 9.88 | 9.88…9.88 | 9.88…9.88 | — |
| novice | 6 | 0 / 1 | not measured | not measured | not measured | — |
| average | 1 | 5 / 5 | 12.93 | 11.03…13.4 | 10.28…18.97 | within target |
| average | 2 | 5 / 5 | 13.22 | 13.03…15.45 | 11.78…19.9 | within target |
| average | 3 | 3 / 5 | 13.23 | 9.72…15.82 | 9.72…15.82 | within target |
| average | 4 | 3 / 3 | 27 | 10.4…29.67 | 10.4…29.67 | miss |
| average | 5 | 1 / 3 | 12.77 | 12.77…12.77 | 12.77…12.77 | miss |
| average | 6 | 1 / 1 | 24.48 | 24.48…24.48 | 24.48…24.48 | miss |
| average | 7 | 1 / 1 | 21.25 | 21.25…21.25 | 21.25…21.25 | miss |
| average | 8 | 1 / 1 | 24.88 | 24.88…24.88 | 24.88…24.88 | miss |
| average | 9 | 1 / 1 | 16.35 | 16.35…16.35 | 16.35…16.35 | within target |
| average | 10 | 1 / 1 | 7.97 | 7.97…7.97 | 7.97…7.97 | miss |
| average | 11 | 1 / 1 | 33.8 | 33.8…33.8 | 33.8…33.8 | miss |
| average | 12 | 0 / 1 | not measured | not measured | not measured | not measured |
| expert | 1 | 5 / 5 | 15.83 | 15.55…15.85 | 14.55…16.83 | — |
| expert | 2 | 5 / 5 | 20.57 | 14.22…22.35 | 12.38…22.42 | — |
| expert | 3 | 4 / 5 | 13.51 | 13.02…18.22 | 8.57…18.22 | — |
| expert | 4 | 4 / 4 | 17.4 | 12.43…31.17 | 11.52…31.17 | — |
| expert | 5 | 3 / 4 | 18.23 | 5.47…29.18 | 5.47…29.18 | — |
| expert | 6 | 2 / 3 | 19.98 | 14.03…25.93 | 14.03…25.93 | — |
| expert | 7 | 2 / 3 | 17.48 | 15.63…19.33 | 15.63…19.33 | — |
| expert | 8 | 2 / 2 | 13.15 | 9.72…16.58 | 9.72…16.58 | — |
| expert | 9 | 1 / 2 | 16.73 | 16.73…16.73 | 16.73…16.73 | — |
| expert | 10 | 1 / 1 | 8.92 | 8.92…8.92 | 8.92…8.92 | — |
| expert | 11 | 1 / 1 | 26.55 | 26.55…26.55 | 26.55…26.55 | — |
| expert | 12 | 1 / 1 | 31.3 | 31.3…31.3 | 31.3…31.3 | — |
| expert | 13 | 1 / 1 | 27.17 | 27.17…27.17 | 27.17…27.17 | — |
| expert | 14 | 1 / 1 | 26.22 | 26.22…26.22 | 26.22…26.22 | — |
| expert | 15 | 1 / 1 | 26.87 | 26.87…26.87 | 26.87…26.87 | — |
| expert | 16 | 1 / 1 | 36.57 | 36.57…36.57 | 36.57…36.57 | — |
| expert | 17 | 0 / 1 | not measured | not measured | not measured | — |
| expert | 18 | 0 / 1 | not measured | not measured | not measured | — |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 5 | 5 | 0 | 0 | 0 | 4 × 1, 5 × 3, 6 × 1 | stomp × 3, rocket × 1, sentry_turret × 1 | 0 |
| average | 5 | 5 | 0 | 0 | 0 | 3 × 2, 5 × 2, 12 × 1 | rocket × 3, stomp × 2 | 0 |
| expert | 5 | 5 | 0 | 0 | 0 | 3 × 1, 5 × 1, 7 × 1, 9 × 1, 18 × 1 | rocket × 2, contractor × 1, shield_robot × 1, swat × 1 | 0 |

## Timeouts

Runs that reached the wave time limit.

| Outcome | novice | average | expert |
| --- | --- | --- | --- |
| timeout | 0 | 0 | 0 |

## Survival by wave band

Each wave contributes once to each available median. Damage/s needs a timed wave. Repair/s is the configured rate when repair is active. HP coverage counts waves sampled by the bot. Repaired HP sums positive HP steps. The share undone uses waves with positive damage. Multipliers include stat cards taken before the wave.

| Profile | Waves | HP rows / observed | Damage | Damage/s | Repair/s | Minimum HP (% of capacity) | Repaired HP | Damage undone (%) | Guard deflects | Cover ticks | Rolls | damage × | guard_meter × | hp_max × | regen × | speed × |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1–10 | 25 / 25 | 18 | 1.11 | 10 | 58.55 | 0 | 0 | 6 | 0 | 2 | 1 | 1 | 1 | 1 | 1 |
| novice | 11–20 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| novice | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| novice | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 1–10 | 26 / 26 | 16.81 | 1.17 | 10 | 76.56 | 0 | 0 | 5 | 1 | 4 | 1.05 | 1 | 1 | 1 | 1 |
| average | 11–20 | 2 / 2 | 77.72 | 1.34 | 11.25 | 17.76 | 0 | 0 | 9.5 | 22.5 | 22 | 1.1 | 1.1 | 1.1 | 1.125 | 1.1 |
| average | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 1–10 | 34 / 34 | 16.2 | 0.87 | 10 | 83.2 | 0 | 0 | 4 | 31 | 5.5 | 1.05 | 1 | 1 | 1 | 1 |
| expert | 11–20 | 8 / 8 | 45.72 | 1.44 | 13.75 | 46.08 | 0 | 0 | 7 | 112 | 13 | 1.1 | 1.1 | 1.1 | 1.375 | 1.1 |
| expert | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 1 | — | 58.58% | 16.08 (44) | 15.22 (34) |
| patrol_cop | 0 | — | 88.07% | 14.93 (70) | 17.48 (8) |
| riot_cop | 0 | — | 54.63% | 16.08 (40) | 15.22 (38) |
| robot_gunner | 0 | — | 25.03% | 25.21 (14) | 14.39 (64) |
| robot_thug | 0 | — | 26.84% | 22.87 (16) | 14.39 (62) |
| rocket_trooper | 6 | rocket × 6 | 55.66% | 16.54 (40) | 14.93 (38) |
| sentry_turret | 1 | — | 23.53% | 18.03 (16) | 14.65 (62) |
| shield_robot | 1 | — | 11.03% | 27.17 (5) | 15.1 (73) |
| swat | 1 | — | 50.95% | 16.35 (37) | 15.33 (41) |
| war_machine | 5 | stomp × 5 | 8.89% | 11.33 (8) | 15.59 (70) |

## Moves

Uses count recorded activations by profile and wave number. The game omits zero counts. Times are medians in seconds, with timed wave counts in parentheses. Carry applies to all waves.

| Profile | Wave | Move | Enemy | Recorded uses | Observed waves | Uses per wave | With enemy s (n) | Without enemy s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | All | ohm_short_circuit | sentry_turret | 0 | 25 | 0 | — | 14.39 (20) |
| novice | All | tonnage_armour_crack | war_machine | 0 | 25 | 0 | 9.88 (1) | 14.45 (19) |
| novice | All | kerf_blink_behind | shield_robot | 0 | 25 | 0 | — | 14.39 (20) |
| novice | All | overkill_carry | all waves | 0 | 25 | 0 | 14.39 (20) | — |
| novice | 1 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 13.18 (5) |
| novice | 1 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 13.18 (5) |
| novice | 1 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 13.18 (5) |
| novice | 1 | overkill_carry | all waves | 0 | 5 | 0 | 13.18 (5) | — |
| novice | 2 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 15.1 (5) |
| novice | 2 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 15.1 (5) |
| novice | 2 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 15.1 (5) |
| novice | 2 | overkill_carry | all waves | 0 | 5 | 0 | 15.1 (5) | — |
| novice | 3 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 16.5 (5) |
| novice | 3 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 16.5 (5) |
| novice | 3 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 16.5 (5) |
| novice | 3 | overkill_carry | all waves | 0 | 5 | 0 | 16.5 (5) | — |
| novice | 4 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 12.99 (4) |
| novice | 4 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 12.99 (4) |
| novice | 4 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 12.99 (4) |
| novice | 4 | overkill_carry | all waves | 0 | 5 | 0 | 12.99 (4) | — |
| novice | 5 | ohm_short_circuit | sentry_turret | 0 | 4 | 0 | — | 9.88 (1) |
| novice | 5 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | 9.88 (1) | — |
| novice | 5 | kerf_blink_behind | shield_robot | 0 | 4 | 0 | — | 9.88 (1) |
| novice | 5 | overkill_carry | all waves | 0 | 4 | 0 | 9.88 (1) | — |
| novice | 6 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | — | — |
| novice | 6 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | — |
| novice | 6 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | — |
| novice | 6 | overkill_carry | all waves | 0 | 1 | 0 | — | — |
| average | All | ohm_short_circuit | sentry_turret | 5 | 28 | 0.18 | 21.25 (5) | 13.23 (18) |
| average | All | tonnage_armour_crack | war_machine | 0 | 28 | 0 | 10.37 (2) | 15.45 (21) |
| average | All | kerf_blink_behind | shield_robot | 6 | 28 | 0.21 | — | 13.4 (23) |
| average | All | overkill_carry | all waves | 0 | 28 | 0 | 13.4 (23) | — |
| average | 1 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 12.93 (5) |
| average | 1 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 12.93 (5) |
| average | 1 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 12.93 (5) |
| average | 1 | overkill_carry | all waves | 0 | 5 | 0 | 12.93 (5) | — |
| average | 2 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 13.22 (5) |
| average | 2 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 13.22 (5) |
| average | 2 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 13.22 (5) |
| average | 2 | overkill_carry | all waves | 0 | 5 | 0 | 13.22 (5) | — |
| average | 3 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 13.23 (3) |
| average | 3 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 13.23 (3) |
| average | 3 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 13.23 (3) |
| average | 3 | overkill_carry | all waves | 0 | 5 | 0 | 13.23 (3) | — |
| average | 4 | ohm_short_circuit | sentry_turret | 0 | 3 | 0 | — | 27 (3) |
| average | 4 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 27 (3) |
| average | 4 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | — | 27 (3) |
| average | 4 | overkill_carry | all waves | 0 | 3 | 0 | 27 (3) | — |
| average | 5 | ohm_short_circuit | sentry_turret | 0 | 3 | 0 | — | 12.77 (1) |
| average | 5 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | 12.77 (1) | — |
| average | 5 | kerf_blink_behind | shield_robot | 1 | 3 | 0.33 | — | 12.77 (1) |
| average | 5 | overkill_carry | all waves | 0 | 3 | 0 | 12.77 (1) | — |
| average | 6 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | 24.48 (1) | — |
| average | 6 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 24.48 (1) |
| average | 6 | kerf_blink_behind | shield_robot | 2 | 1 | 2 | — | 24.48 (1) |
| average | 6 | overkill_carry | all waves | 0 | 1 | 0 | 24.48 (1) | — |
| average | 7 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 21.25 (1) | — |
| average | 7 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 21.25 (1) |
| average | 7 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | 21.25 (1) |
| average | 7 | overkill_carry | all waves | 0 | 1 | 0 | 21.25 (1) | — |
| average | 8 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 24.88 (1) | — |
| average | 8 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 24.88 (1) |
| average | 8 | kerf_blink_behind | shield_robot | 2 | 1 | 2 | — | 24.88 (1) |
| average | 8 | overkill_carry | all waves | 0 | 1 | 0 | 24.88 (1) | — |
| average | 9 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 16.35 (1) | — |
| average | 9 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 16.35 (1) |
| average | 9 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | 16.35 (1) |
| average | 9 | overkill_carry | all waves | 0 | 1 | 0 | 16.35 (1) | — |
| average | 10 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 7.97 (1) | — |
| average | 10 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | 7.97 (1) | — |
| average | 10 | kerf_blink_behind | shield_robot | 1 | 1 | 1 | — | 7.97 (1) |
| average | 10 | overkill_carry | all waves | 0 | 1 | 0 | 7.97 (1) | — |
| average | 11 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | — | 33.8 (1) |
| average | 11 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 33.8 (1) |
| average | 11 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | 33.8 (1) |
| average | 11 | overkill_carry | all waves | 0 | 1 | 0 | 33.8 (1) | — |
| average | 12 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | — | — |
| average | 12 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | — |
| average | 12 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | — |
| average | 12 | overkill_carry | all waves | 0 | 1 | 0 | — | — |
| expert | All | ohm_short_circuit | sentry_turret | 11 | 42 | 0.26 | 16.73 (11) | 16.34 (24) |
| expert | All | tonnage_armour_crack | war_machine | 0 | 42 | 0 | 18.23 (5) | 16.66 (30) |
| expert | All | kerf_blink_behind | shield_robot | 19 | 42 | 0.45 | 27.17 (5) | 15.84 (30) |
| expert | All | overkill_carry | all waves | 2 | 42 | 0.05 | 16.73 (35) | — |
| expert | 1 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 15.83 (5) |
| expert | 1 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 15.83 (5) |
| expert | 1 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 15.83 (5) |
| expert | 1 | overkill_carry | all waves | 0 | 5 | 0 | 15.83 (5) | — |
| expert | 2 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 20.57 (5) |
| expert | 2 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 20.57 (5) |
| expert | 2 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 20.57 (5) |
| expert | 2 | overkill_carry | all waves | 0 | 5 | 0 | 20.57 (5) | — |
| expert | 3 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 13.51 (4) |
| expert | 3 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 13.51 (4) |
| expert | 3 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 13.51 (4) |
| expert | 3 | overkill_carry | all waves | 0 | 5 | 0 | 13.51 (4) | — |
| expert | 4 | ohm_short_circuit | sentry_turret | 0 | 4 | 0 | — | 17.4 (4) |
| expert | 4 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 17.4 (4) |
| expert | 4 | kerf_blink_behind | shield_robot | 0 | 4 | 0 | — | 17.4 (4) |
| expert | 4 | overkill_carry | all waves | 0 | 4 | 0 | 17.4 (4) | — |
| expert | 5 | ohm_short_circuit | sentry_turret | 2 | 4 | 0.5 | — | 18.23 (3) |
| expert | 5 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | 18.23 (3) | — |
| expert | 5 | kerf_blink_behind | shield_robot | 1 | 4 | 0.25 | — | 18.23 (3) |
| expert | 5 | overkill_carry | all waves | 0 | 4 | 0 | 18.23 (3) | — |
| expert | 6 | ohm_short_circuit | sentry_turret | 0 | 3 | 0 | 19.98 (2) | — |
| expert | 6 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 19.98 (2) |
| expert | 6 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | — | 19.98 (2) |
| expert | 6 | overkill_carry | all waves | 0 | 3 | 0 | 19.98 (2) | — |
| expert | 7 | ohm_short_circuit | sentry_turret | 1 | 3 | 0.33 | 17.48 (2) | — |
| expert | 7 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 17.48 (2) |
| expert | 7 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | — | 17.48 (2) |
| expert | 7 | overkill_carry | all waves | 0 | 3 | 0 | 17.48 (2) | — |
| expert | 8 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 13.15 (2) | — |
| expert | 8 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 13.15 (2) |
| expert | 8 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | 13.15 (2) |
| expert | 8 | overkill_carry | all waves | 0 | 2 | 0 | 13.15 (2) | — |
| expert | 9 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | 16.73 (1) | — |
| expert | 9 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 16.73 (1) |
| expert | 9 | kerf_blink_behind | shield_robot | 2 | 2 | 1 | — | 16.73 (1) |
| expert | 9 | overkill_carry | all waves | 0 | 2 | 0 | 16.73 (1) | — |
| expert | 10 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 8.92 (1) | — |
| expert | 10 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | 8.92 (1) | — |
| expert | 10 | kerf_blink_behind | shield_robot | 1 | 1 | 1 | — | 8.92 (1) |
| expert | 10 | overkill_carry | all waves | 0 | 1 | 0 | 8.92 (1) | — |
| expert | 11 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | — | 26.55 (1) |
| expert | 11 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 26.55 (1) |
| expert | 11 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | 26.55 (1) |
| expert | 11 | overkill_carry | all waves | 0 | 1 | 0 | 26.55 (1) | — |
| expert | 12 | ohm_short_circuit | sentry_turret | 2 | 1 | 2 | 31.3 (1) | — |
| expert | 12 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 31.3 (1) |
| expert | 12 | kerf_blink_behind | shield_robot | 2 | 1 | 2 | 31.3 (1) | — |
| expert | 12 | overkill_carry | all waves | 0 | 1 | 0 | 31.3 (1) | — |
| expert | 13 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | — | 27.17 (1) |
| expert | 13 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 27.17 (1) |
| expert | 13 | kerf_blink_behind | shield_robot | 1 | 1 | 1 | 27.17 (1) | — |
| expert | 13 | overkill_carry | all waves | 0 | 1 | 0 | 27.17 (1) | — |
| expert | 14 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 26.22 (1) | — |
| expert | 14 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 26.22 (1) |
| expert | 14 | kerf_blink_behind | shield_robot | 4 | 1 | 4 | 26.22 (1) | — |
| expert | 14 | overkill_carry | all waves | 0 | 1 | 0 | 26.22 (1) | — |
| expert | 15 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | — | 26.87 (1) |
| expert | 15 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | 26.87 (1) | — |
| expert | 15 | kerf_blink_behind | shield_robot | 1 | 1 | 1 | 26.87 (1) | — |
| expert | 15 | overkill_carry | all waves | 0 | 1 | 0 | 26.87 (1) | — |
| expert | 16 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 36.57 (1) | — |
| expert | 16 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 36.57 (1) |
| expert | 16 | kerf_blink_behind | shield_robot | 1 | 1 | 1 | 36.57 (1) | — |
| expert | 16 | overkill_carry | all waves | 0 | 1 | 0 | 36.57 (1) | — |
| expert | 17 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | — | — |
| expert | 17 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | — |
| expert | 17 | kerf_blink_behind | shield_robot | 3 | 1 | 3 | — | — |
| expert | 17 | overkill_carry | all waves | 1 | 1 | 1 | — | — |
| expert | 18 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | — | — |
| expert | 18 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | — |
| expert | 18 | kerf_blink_behind | shield_robot | 3 | 1 | 3 | — | — |
| expert | 18 | overkill_carry | all waves | 1 | 1 | 1 | — | — |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| effect_overkill_carry | waves survived | 1 (1) | 3 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| effect_overkill_carry | wave s | not measured | 22.87 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_dent | waves survived | 1 (2) | 3 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_dent | wave s | 36.57 (1) | 16.35 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_kerf | waves survived | 10 (2) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_kerf | wave s | 22.01 (2) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | waves survived | 4 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | wave s | 23.82 (4) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_tonnage | waves survived | 2 (8) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| ghost_tonnage | wave s | 19.46 (8) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_10 | waves survived | 2 (10) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_10 | wave s | 15.45 (9) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_25 | waves survived | 2 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_25 | wave s | 10.77 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 1 (7) | 3 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_10 | wave s | 20.85 (3) | 15.45 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_25 | waves survived | 1 (3) | 0 (6) | 3 | 1 | 0…4 | not measured (3, all offered) | too few pairs |
| stat_guard_meter_25 | wave s | 13.65 (2) | 22.62 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 2 (11) | 1 (3) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_hp_max_10 | wave s | 16.23 (8) | 10.58 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_25 | waves survived | not measured | 2 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_25 | wave s | not measured | 20.88 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_10 | waves survived | 3 (3) | 2 (9) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_regen_10 | wave s | 26.87 (3) | 13.35 (6) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_regen_25 | waves survived | 3 (2) | 1 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | wave s | 27.17 (1) | 16.58 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | waves survived | 4.5 (6) | 1 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | wave s | 17.25 (6) | 29.18 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_25 | waves survived | not measured | 3.5 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_25 | wave s | not measured | 16.58 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_chainsaw | waves survived | not measured | 1 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_chainsaw | wave s | not measured | 19.19 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | waves survived | not measured | 3 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | wave s | not measured | 24.54 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | waves survived | 5 (1) | 4 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | wave s | 27.02 (1) | 20.62 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gatling | waves survived | 2 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gatling | wave s | 20.88 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gloria | waves survived | not measured | 3 (11) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gloria | wave s | not measured | 17.11 (11) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | not measured | 1.5 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_hand_cannon | wave s | not measured | 17.41 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_katana | waves survived | not measured | 2 (8) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_katana | wave s | not measured | 19.12 (7) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_machine_pistol | waves survived | not measured | 1 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_machine_pistol | wave s | not measured | 27.6 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_pistol | waves survived | 2 (6) | 2 (5) | 2 | -0.5 | -1…0 | not measured (2, all offered) | too few pairs |
| weapon_pistol | wave s | 19.69 (5) | 15.11 (4) | 2 | 3.66 | 0.74…6.58 | not measured (2, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | not measured | 1 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_rifle | wave s | not measured | 19.34 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_sword | waves survived | 7 (2) | 0 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_sword | wave s | 23.58 (2) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_rocket_launcher | waves survived | 3 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_rocket_launcher | wave s | 24.15 (2) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | not measured | 1 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| chainsaw | wave s | not measured | 19.19 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | waves survived | not measured | 3 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | wave s | not measured | 24.54 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | waves survived | 5 (1) | 4 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | wave s | 27.02 (1) | 20.62 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gatling | waves survived | 2 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gatling | wave s | 20.88 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gloria | waves survived | not measured | 3 (11) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gloria | wave s | not measured | 17.11 (11) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| hand_cannon | waves survived | not measured | 1.5 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| hand_cannon | wave s | not measured | 17.41 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| katana | waves survived | not measured | 2 (8) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| katana | wave s | not measured | 19.12 (7) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| machine_pistol | waves survived | not measured | 1 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| machine_pistol | wave s | not measured | 27.6 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| pistol | waves survived | 2 (6) | 2 (5) | 2 | -0.5 | -1…0 | not measured (2, all offered) | too few pairs |
| pistol | wave s | 19.69 (5) | 15.11 (4) | 2 | 3.66 | 0.74…6.58 | not measured (2, all offered) | too few pairs |
| plasma_rifle | waves survived | not measured | 1 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_rifle | wave s | not measured | 19.34 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_sword | waves survived | 7 (2) | 0 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_sword | wave s | 23.58 (2) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| rocket_launcher | waves survived | 3 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| rocket_launcher | wave s | 24.15 (2) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | kerf s (n) | ohm s (n) | rivet s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 8 (5) | 2 (5) | 0 (5) | 13 (5) | not measured | not measured | 13.18 (5) | not measured |
| novice | 2 | 9 (5) | 3 (5) | 0 (5) | 14 (5) | not measured | not measured | 15.1 (5) | not measured |
| novice | 3 | 5 (5) | 2 (5) | 0 (5) | 12 (5) | not measured | not measured | 15.83 (5) | 7.1 (1) |
| novice | 4 | 6 (5) | 3 (5) | 0 (5) | 12 (5) | not measured | 7.3 (1) | 11.65 (5) | not measured |
| novice | 5 | 2.5 (4) | 1 (4) | 0 (4) | 8.5 (4) | not measured | not measured | 6.03 (4) | not measured |
| novice | 6 | 10 (1) | 2 (1) | 4 (1) | 14 (1) | not measured | not measured | 14.88 (1) | not measured |
| average | 1 | 8 (5) | 2 (5) | 0 (5) | 13 (5) | not measured | not measured | 12.93 (5) | not measured |
| average | 2 | 4 (5) | 3 (5) | 0 (5) | 14 (5) | not measured | not measured | 13.22 (5) | not measured |
| average | 3 | 8 (5) | 4 (5) | 0 (5) | 12 (5) | not measured | 3.32 (1) | 15.65 (5) | 10.65 (2) |
| average | 4 | 6 (3) | 10 (3) | 0 (3) | 12 (3) | not measured | not measured | 27 (3) | not measured |
| average | 5 | 2 (3) | 4 (3) | 0 (3) | 5 (3) | 5.5 (1) | not measured | 7.27 (3) | not measured |
| average | 6 | 2 (1) | 8 (1) | 28 (1) | 29 (1) | 6.82 (1) | not measured | 17.67 (1) | not measured |
| average | 7 | 7 (1) | 7 (1) | 40 (1) | 32 (1) | 2.25 (1) | 0.03 (1) | 18.97 (1) | not measured |
| average | 8 | 2 (1) | 6 (1) | 46 (1) | 39 (1) | 5.5 (1) | 0.03 (1) | 19.35 (1) | not measured |
| average | 9 | 0 (1) | 4 (1) | 20 (1) | 22 (1) | 5.5 (1) | 1.13 (1) | 9.72 (1) | not measured |
| average | 10 | 4 (1) | 0 (1) | 32 (1) | 30 (1) | 2.38 (1) | 0.03 (1) | 5.55 (1) | not measured |
| average | 11 | 5 (1) | 27 (1) | 25 (1) | 44 (1) | 5.3 (1) | 7.3 (1) | 14.1 (1) | 7.1 (1) |
| average | 12 | 14 (1) | 17 (1) | 78 (1) | 87 (1) | not measured | 1.15 (1) | 20.38 (1) | 7.1 (1) |
| expert | 1 | 9 (5) | 3 (5) | 0 (5) | 13 (5) | not measured | not measured | 15.83 (5) | not measured |
| expert | 2 | 9 (5) | 5 (5) | 0 (5) | 14 (5) | not measured | not measured | 20.57 (5) | not measured |
| expert | 3 | 3 (5) | 5 (5) | 0 (5) | 12 (5) | not measured | 2.17 (1) | 14 (5) | 8.77 (1) |
| expert | 4 | 2.5 (4) | 7 (4) | 0 (4) | 12.5 (4) | not measured | 9.78 (1) | 13.36 (4) | 7.1 (1) |
| expert | 5 | 0 (4) | 7.5 (4) | 0 (4) | 15.5 (4) | 0.72 (1) | 7.3 (1) | 16.02 (4) | 4.27 (1) |
| expert | 6 | 4 (3) | 9 (3) | 4 (3) | 35 (3) | 3.47 (1) | 7.33 (1) | 25.93 (3) | 7.1 (1) |
| expert | 7 | 4 (3) | 2 (3) | 3 (3) | 31 (3) | 0.78 (1) | 7.07 (1) | 11.48 (3) | not measured |
| expert | 8 | 3 (2) | 6 (2) | 53 (2) | 44.5 (2) | 4.62 (1) | not measured | 10.84 (2) | not measured |
| expert | 9 | 6 (2) | 6 (2) | 29.5 (2) | 51.5 (2) | 5.5 (1) | 1.05 (1) | 13.69 (2) | not measured |
| expert | 10 | 1 (1) | 3 (1) | 40 (1) | 28 (1) | 2.68 (1) | 0.03 (1) | 6.2 (1) | not measured |
| expert | 11 | 7 (1) | 14 (1) | 12 (1) | 32 (1) | 5.5 (1) | not measured | 13.95 (1) | 7.1 (1) |
| expert | 12 | 11 (1) | 20 (1) | 63 (1) | 82 (1) | 5.5 (1) | 0.35 (1) | 25.45 (1) | not measured |
| expert | 13 | 2 (1) | 10 (1) | 155 (1) | 1789 (1) | 5.5 (1) | 1.35 (1) | 20.32 (1) | not measured |
| expert | 14 | 7 (1) | 14 (1) | 53 (1) | 202 (1) | 8.8 (1) | 0.17 (1) | 17.25 (1) | not measured |
| expert | 15 | 3 (1) | 12 (1) | 133 (1) | 871 (1) | 5.5 (1) | 0.45 (1) | 20.92 (1) | not measured |
| expert | 16 | 8 (1) | 8 (1) | 193 (1) | 2246 (1) | 5.5 (1) | 7.33 (1) | 23.73 (1) | not measured |
| expert | 17 | 17 (1) | 29 (1) | 118 (1) | 1277 (1) | 5.5 (1) | 7.3 (1) | 33.9 (1) | 7.1 (1) |
| expert | 18 | 1 (1) | 7 (1) | 0 (1) | 9 (1) | 4.68 (1) | not measured | 4.12 (1) | not measured |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 4 | 6 | 1.55 | stat_damage_10 → stat_speed_10 → stat_damage_25 → stat_guard_meter_25 → weapon_rocket_launcher | rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=4 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| average | 5 | 12 | 1.55 | stat_speed_10 → stat_guard_meter_10 → stat_damage_10 → ghost_kerf → weapon_pistol → ghost_ohm → weapon_plasma_sword → stat_hp_max_10 → weapon_gatling → ghost_tonnage → stat_regen_25 | gatling, pistol, plasma_sword | rivet | node tools/dev/run.mjs gauntlet --seed=5 --bot=average --pick=greedy --controls=wheel --waves=40 |
| expert | 5 | 18 | 1.55 | stat_speed_10 → stat_guard_meter_10 → stat_damage_10 → ghost_kerf → weapon_pistol → ghost_ohm → weapon_plasma_sword → stat_hp_max_10 → weapon_gatling → ghost_tonnage → stat_regen_25 → weapon_flamethrower → stat_regen_10 → weapon_rocket_launcher → ghost_dent → effect_overkill_carry | flamethrower, gatling, pistol, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=5 --bot=expert --pick=greedy --controls=wheel --waves=40 |
