# Gauntlet run report

20 of 20 runs accepted. Average-profile waves 1 (5.56 s), 2 (7.86 s), 3 (6.16 s), 4 (6.4 s), 6 (10.27 s), 7 (11.44 s), 9 (21.29 s), 10 (28.96 s), 11 (26.87 s), 12 (30.42 s), 13 (30.01 s), 14 (30.31 s), 15 (34.55 s), 16 (34.6 s), 17 (33.92 s), 18 (36.74 s), 19 (32.92 s), 20 (35.72 s), 21 (40.28 s), 22 (36.4 s), 23 (39.52 s), 24 (37.62 s), 25 (45.08 s), 26 (44.45 s), 27 (43.8 s), 28 (42.04 s), 29 (44.68 s), 30 (47.48 s), 31 (48.46 s), 32 (47.16 s), 33 (47.14 s), 34 (49.9 s), 35 (44.86 s), 36 (58.23 s), 37 (49.07 s), 38 (48.3 s) fell outside 12–18 s.

Live gauntlet batch · n23-loop @ 6f54e9ec7d6a (dirty) · 2026-11-22T01:50:35.055Z.

Stalled runs by profile: average 0.

Capped alive by profile: average 18.

## Death-wave score

Capped runs contribute their last reached wave as a lower bound to the median and spread.

| Profile | Target | Median wave | P25–P75 | Min–max | Deaths / capped |
| --- | --- | --- | --- | --- | --- |
| average | 12 | 35 | 35–36 | 34–39 | 0 / 18 |

## Profile separation

Targets require a median gap of 3 waves and a later death on at least 75% of shared seeds with the same controls and pick policy. Unresolved censored pairs stay in the denominator.

| Profiles | Observed median gap | Later / shared seeds | Confirmed later share | Unresolved | Verdict |
| --- | --- | --- | --- | --- | --- |
| novice → average | not measured | 0 / 0 | — | 0 | undetermined |
| average → expert | not measured | 0 / 0 | — | 0 | undetermined |

## Waves per run

A timed-out wave can clear later. Active counts include each started roster still fighting at death.

| Profile | Seed | Outcome | Timed-out waves | Active waves at death |
| --- | --- | --- | --- | --- |
| average | 1 | capped ≥ 34 | 0 | — |
| average | 2 | capped ≥ 35 | 0 | — |
| average | 3 | capped ≥ 36 | 0 | — |
| average | 5 | capped ≥ 37 | 0 | — |
| average | 6 | capped ≥ 35 | 0 | — |
| average | 7 | capped ≥ 34 | 0 | — |
| average | 8 | capped ≥ 36 | 0 | — |
| average | 9 | capped ≥ 36 | 0 | — |
| average | 10 | capped ≥ 39 | 0 | — |
| average | 12 | capped ≥ 35 | 0 | — |
| average | 13 | capped ≥ 37 | 0 | — |
| average | 14 | capped ≥ 36 | 0 | — |
| average | 15 | capped ≥ 34 | 0 | — |
| average | 16 | capped ≥ 35 | 0 | — |
| average | 17 | capped ≥ 35 | 0 | — |
| average | 18 | capped ≥ 36 | 0 | — |
| average | 19 | capped ≥ 35 | 0 | — |
| average | 20 | capped ≥ 35 | 0 | — |

## Wave time

Seconds per observed wave. The target is 15 s. Average medians below 12 s or above 18 s are flagged. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Median s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- |
| average | 1 | 20 / 20 | 5.56 | 5.1…6.3 | 3.98…9.7 | miss |
| average | 2 | 20 / 20 | 7.86 | 6.93…10.57 | 5.12…14.97 | miss |
| average | 3 | 20 / 20 | 6.16 | 5.68…7.15 | 2.73…10.15 | miss |
| average | 4 | 20 / 20 | 6.4 | 4.5…8.55 | 2.68…12.37 | miss |
| average | 5 | 20 / 20 | 15.31 | 12.37…20.23 | 9.4…30.63 | within 20% |
| average | 6 | 20 / 20 | 10.27 | 9.28…12.07 | 6.27…16.2 | miss |
| average | 7 | 20 / 20 | 11.44 | 9.2…16.43 | 6.53…23.5 | miss |
| average | 8 | 20 / 20 | 12.21 | 10.25…16.48 | 6.87…24.63 | within 20% |
| average | 9 | 20 / 20 | 21.29 | 15.03…25.72 | 8.35…47.75 | miss |
| average | 10 | 20 / 20 | 28.96 | 23.05…36.87 | 11.07…54.87 | miss |
| average | 11 | 20 / 20 | 26.87 | 19.62…30.42 | 12.88…39.73 | miss |
| average | 12 | 20 / 20 | 30.42 | 23.73…35.08 | 15.2…53.1 | miss |
| average | 13 | 20 / 20 | 30.01 | 26.02…37.37 | 17…55.33 | miss |
| average | 14 | 20 / 20 | 30.31 | 24.43…38.7 | 16.5…44.02 | miss |
| average | 15 | 20 / 20 | 34.55 | 28.78…51.8 | 8.18…62.5 | miss |
| average | 16 | 20 / 20 | 34.6 | 26.72…38.83 | 14.4…52.65 | miss |
| average | 17 | 20 / 20 | 33.92 | 28.38…39.38 | 21.83…43.58 | miss |
| average | 18 | 20 / 20 | 36.74 | 27.57…45.15 | 19.13…76.73 | miss |
| average | 19 | 20 / 20 | 32.92 | 26.95…38.95 | 19.02…54.12 | miss |
| average | 20 | 20 / 20 | 35.72 | 31.67…44.45 | 19.7…58.12 | miss |
| average | 21 | 19 / 20 | 40.28 | 29.98…45.12 | 22.88…58.45 | miss |
| average | 22 | 19 / 19 | 36.4 | 32.57…45.03 | 28.78…56.48 | miss |
| average | 23 | 18 / 19 | 39.52 | 30.85…47.13 | 23.1…60.5 | miss |
| average | 24 | 18 / 18 | 37.62 | 32.7…42.23 | 25.85…75.32 | miss |
| average | 25 | 18 / 18 | 45.08 | 37.47…52.02 | 33.27…68.02 | miss |
| average | 26 | 18 / 18 | 44.45 | 31.7…46.08 | 27.23…59.92 | miss |
| average | 27 | 18 / 18 | 43.8 | 36.93…53.68 | 20.25…61.47 | miss |
| average | 28 | 18 / 18 | 42.04 | 38.7…50.82 | 24.67…70.48 | miss |
| average | 29 | 18 / 18 | 44.68 | 38.63…50.37 | 23.83…58.75 | miss |
| average | 30 | 18 / 18 | 47.48 | 41.02…50.93 | 28.35…69.58 | miss |
| average | 31 | 18 / 18 | 48.46 | 44.72…52.75 | 36.48…58.33 | miss |
| average | 32 | 18 / 18 | 47.16 | 42.05…57.32 | 31.77…83.92 | miss |
| average | 33 | 18 / 18 | 47.14 | 39.7…48.95 | 29.53…67.72 | miss |
| average | 34 | 15 / 18 | 49.9 | 40.55…58.52 | 30.42…71.5 | miss |
| average | 35 | 8 / 15 | 44.86 | 43.72…67.95 | 37.8…70.02 | miss |
| average | 36 | 3 / 8 | 58.23 | 45.17…72.05 | 45.17…72.05 | miss |
| average | 37 | 1 / 3 | 49.07 | 49.07…49.07 | 49.07…49.07 | miss |
| average | 38 | 1 / 1 | 48.3 | 48.3…48.3 | 48.3…48.3 | miss |
| average | 39 | 0 / 1 | not measured | not measured | not measured | not measured |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| average | 20 | 2 | 0 | 18 | 0 | 21 × 1, 23 × 1 | not measured | 0 |

## Timeouts

Runs that reached the wave time limit.

| Outcome | average |
| --- | --- |
| timeout | 2 |

## Survival by wave band

Each wave contributes once to each available median. Damage/s needs a timed wave. Repair/s is the configured rate when repair is active. HP coverage counts waves sampled by the bot. Repaired HP sums positive HP steps. The share undone uses waves with positive damage. Multipliers include stat cards taken before the wave.

| Profile | Waves | HP rows / observed | Damage | Damage/s | Repair/s | Minimum HP (% of capacity) | Repaired HP | Damage undone (%) | Guard deflects | Cover ticks | Rolls | damage × | guard_meter × | hp_max × | regen × | speed × |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| average | 1–10 | 200 / 200 | 1.2 | 0.12 | 10 | 98.8 | 0.6 | 100 | 4 | 0 | 1 | 1 | 1 | 1 | 1 | 1 |
| average | 11–20 | 200 / 200 | 16.04 | 0.52 | 11 | 88.65 | 15.4 | 100 | 9 | 14 | 6 | 1.1 | 1.1 | 1.1 | 1.1 | 1.1 |
| average | 21–30 | 184 / 184 | 29 | 0.78 | 13.75 | 82.83 | 28.99 | 100 | 12 | 29.5 | 12 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |
| average | 31+ | 100 / 100 | 45.27 | 0.98 | 13.75 | 76.93 | 41.02 | 100 | 14.5 | 30 | 14 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 0 | — | 81.66% | 35.67 (497) | 17.83 (167) |
| patrol_cop | 0 | — | 92.47% | 34.05 (594) | 19.88 (70) |
| riot_cop | 0 | — | 83.43% | 35.72 (505) | 16.48 (159) |
| robot_gunner | 0 | — | 82.58% | 37.08 (468) | 12.35 (196) |
| robot_thug | 0 | — | 81.03% | 36.85 (463) | 12.62 (201) |
| rocket_trooper | 0 | — | 82.99% | 35.75 (496) | 14.57 (168) |
| sentry_turret | 0 | — | 79.14% | 38.48 (441) | 13.42 (223) |
| shield_robot | 0 | — | 82.7% | 39.84 (426) | 11.9 (238) |
| swat | 0 | — | 81.69% | 36.41 (492) | 17.57 (172) |
| war_machine | 0 | — | 21.41% | 35.87 (124) | 31.35 (540) |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ghost_dent | waves survived | 17 (20) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| ghost_dent | wave s | 40.24 (20) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| ghost_kerf | waves survived | 16 (20) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| ghost_kerf | wave s | 39.47 (20) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| ghost_ohm | waves survived | 15.5 (20) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| ghost_ohm | wave s | 42.81 (20) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| ghost_tonnage | waves survived | 22 (20) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| ghost_tonnage | wave s | 38.75 (19) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_damage_10 | waves survived | 22.5 (20) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| stat_damage_10 | wave s | 37.68 (20) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| stat_damage_25 | waves survived | 17 (18) | 5 (2) | 1 | 15 | not measured | not measured (5, all offered) | too few pairs |
| stat_damage_25 | wave s | 42.19 (18) | 39.8 (2) | 1 | -0.47 | not measured | not measured (5, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 25 (20) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_10 | wave s | 38.58 (20) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_25 | waves survived | 15 (19) | 10 (1) | 1 | 16 | not measured | not measured (4, all offered) | too few pairs |
| stat_guard_meter_25 | wave s | 40.87 (19) | 39.03 (1) | 1 | -1.87 | not measured | not measured (4, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 21.5 (20) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_hp_max_10 | wave s | 38.41 (20) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_hp_max_25 | waves survived | 12 (19) | 12 (1) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_hp_max_25 | wave s | 42.87 (19) | 39.03 (1) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_regen_10 | waves survived | 24.5 (20) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_regen_10 | wave s | 38.9 (20) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_regen_25 | waves survived | 11.5 (20) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| stat_regen_25 | wave s | 43.67 (20) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| stat_speed_10 | waves survived | 27 (20) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| stat_speed_10 | wave s | 36.52 (20) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| stat_speed_25 | waves survived | 13 (19) | 14 (1) | 1 | -2 | not measured | not measured (5, all offered) | too few pairs |
| stat_speed_25 | wave s | 44.27 (19) | 34.85 (1) | 1 | 4.18 | not measured | not measured (5, all offered) | too few pairs |
| weapon_chainsaw | waves survived | 22.5 (20) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_chainsaw | wave s | 39.75 (19) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_electro_baton | waves survived | 18 (20) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_electro_baton | wave s | 41.07 (20) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_flamethrower | waves survived | 20 (19) | 1 (1) | 1 | 13 | not measured | not measured (2, all offered) | too few pairs |
| weapon_flamethrower | wave s | 40.33 (19) | 34.4 (1) | 1 | 14.13 | not measured | not measured (2, all offered) | too few pairs |
| weapon_gatling | waves survived | 18 (19) | 14 (1) | 1 | 12 | not measured | not measured (4, all offered) | too few pairs |
| weapon_gatling | wave s | 41.8 (19) | 34.85 (1) | 1 | 2.43 | not measured | not measured (4, all offered) | too few pairs |
| weapon_gloria | waves survived | 20 (20) | not measured | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| weapon_gloria | wave s | 40.08 (20) | not measured | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | 23.5 (20) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| weapon_hand_cannon | wave s | 39.13 (20) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| weapon_katana | waves survived | 22 (19) | 15 (1) | 1 | 13 | not measured | not measured (2, all offered) | too few pairs |
| weapon_katana | wave s | 40.41 (19) | 35.08 (1) | 1 | -0.2 | not measured | not measured (2, all offered) | too few pairs |
| weapon_machine_pistol | waves survived | 25 (19) | 10 (1) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_machine_pistol | wave s | 39.18 (19) | 39.03 (1) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_pistol | waves survived | 20 (20) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_pistol | wave s | 40.77 (20) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | 19.5 (20) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_plasma_rifle | wave s | 40.24 (20) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_plasma_sword | waves survived | 20 (20) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| weapon_plasma_sword | wave s | 39.97 (20) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| weapon_rocket_launcher | waves survived | 23 (19) | 5 (1) | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| weapon_rocket_launcher | wave s | 39.83 (19) | 39.6 (1) | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | 22.5 (20) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| chainsaw | wave s | 39.75 (19) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| electro_baton | waves survived | 18 (20) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| electro_baton | wave s | 41.07 (20) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| flamethrower | waves survived | 20 (19) | 1 (1) | 1 | 13 | not measured | not measured (2, all offered) | too few pairs |
| flamethrower | wave s | 40.33 (19) | 34.4 (1) | 1 | 14.13 | not measured | not measured (2, all offered) | too few pairs |
| gatling | waves survived | 18 (19) | 14 (1) | 1 | 12 | not measured | not measured (4, all offered) | too few pairs |
| gatling | wave s | 41.8 (19) | 34.85 (1) | 1 | 2.43 | not measured | not measured (4, all offered) | too few pairs |
| gloria | waves survived | 20 (20) | not measured | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| gloria | wave s | 40.08 (20) | not measured | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| hand_cannon | waves survived | 23.5 (20) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| hand_cannon | wave s | 39.13 (20) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| katana | waves survived | 22 (19) | 15 (1) | 1 | 13 | not measured | not measured (2, all offered) | too few pairs |
| katana | wave s | 40.41 (19) | 35.08 (1) | 1 | -0.2 | not measured | not measured (2, all offered) | too few pairs |
| machine_pistol | waves survived | 25 (19) | 10 (1) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| machine_pistol | wave s | 39.18 (19) | 39.03 (1) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| pistol | waves survived | 20 (20) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| pistol | wave s | 40.77 (20) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| plasma_rifle | waves survived | 19.5 (20) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| plasma_rifle | wave s | 40.24 (20) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| plasma_sword | waves survived | 20 (20) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| plasma_sword | wave s | 39.97 (20) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| rocket_launcher | waves survived | 23 (19) | 5 (1) | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| rocket_launcher | wave s | 39.83 (19) | 39.6 (1) | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | dent s (n) | kerf s (n) | ohm s (n) | rivet s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| average | 1 | 4 (20) | 0 (20) | 0 (20) | 4 (20) | not measured | not measured | not measured | 5.56 (20) | not measured |
| average | 2 | 3 (20) | 0 (20) | 0 (20) | 6 (20) | not measured | 5.5 (1) | not measured | 7.86 (20) | not measured |
| average | 3 | 3 (20) | 0 (20) | 7 (20) | 5 (20) | not measured | 1.65 (1) | not measured | 6.16 (20) | not measured |
| average | 4 | 3 (20) | 0 (20) | 8.5 (20) | 6 (20) | not measured | 2.87 (1) | not measured | 6.4 (20) | not measured |
| average | 5 | 3 (20) | 4 (20) | 15 (20) | 27 (20) | not measured | 5.07 (1) | 5.96 (2) | 13.3 (20) | 7.1 (4) |
| average | 6 | 3 (20) | 1 (20) | 17.5 (20) | 17 (20) | not measured | 0.03 (1) | 6.04 (2) | 9.76 (20) | not measured |
| average | 7 | 2.5 (20) | 1 (20) | 21 (20) | 20 (20) | not measured | 4.64 (2) | 6.55 (3) | 9.66 (20) | 7.1 (1) |
| average | 8 | 4.5 (20) | 1 (20) | 33 (20) | 28 (20) | not measured | 0.35 (3) | not measured | 11.96 (20) | 7.1 (1) |
| average | 9 | 7 (20) | 2 (20) | 53.5 (20) | 68 (20) | not measured | 2.93 (5) | 7.3 (3) | 17.09 (20) | 7.1 (4) |
| average | 10 | 13.5 (20) | 8 (20) | 63.5 (20) | 100 (20) | not measured | 5.5 (4) | 2.86 (4) | 23.41 (20) | 7.1 (9) |
| average | 11 | 10 (20) | 5 (20) | 51 (20) | 124 (20) | not measured | 5.5 (5) | 7.3 (4) | 21.91 (20) | 7.1 (7) |
| average | 12 | 10.5 (20) | 4.5 (20) | 88 (20) | 143.5 (20) | not measured | 3.6 (7) | 7.3 (4) | 24.41 (20) | 7.1 (9) |
| average | 13 | 10.5 (20) | 5 (20) | 80 (20) | 190.5 (20) | not measured | 4.91 (6) | 7.3 (8) | 23.02 (20) | 7.1 (8) |
| average | 14 | 7.5 (20) | 4 (20) | 98.5 (20) | 592 (20) | not measured | 1.03 (4) | 7.3 (6) | 23.82 (20) | 7.1 (10) |
| average | 15 | 7 (20) | 7.5 (20) | 63.5 (20) | 823 (20) | not measured | 4.76 (6) | 7.3 (9) | 28.09 (20) | 7.1 (11) |
| average | 16 | 10.5 (20) | 5 (20) | 142 (20) | 2082.5 (20) | not measured | 5.33 (7) | 7.3 (8) | 21.12 (20) | 7.1 (9) |
| average | 17 | 8 (20) | 7 (20) | 94 (20) | 1226.5 (20) | not measured | 6.17 (6) | 7.3 (10) | 24.09 (20) | 7.1 (11) |
| average | 18 | 10 (20) | 8 (20) | 101.5 (20) | 1747 (20) | not measured | 5.5 (10) | 7.3 (9) | 23.32 (20) | 7.1 (10) |
| average | 19 | 14.5 (20) | 7 (20) | 122 (20) | 1730 (20) | not measured | 5.5 (9) | 7.3 (10) | 21.25 (20) | 7.1 (11) |
| average | 20 | 8.5 (20) | 11.5 (20) | 110 (20) | 1193.5 (20) | not measured | 5.5 (11) | 7.3 (12) | 23.8 (20) | 7.1 (10) |
| average | 21 | 14 (20) | 8 (20) | 121.5 (20) | 1903 (20) | not measured | 5.5 (14) | 8.13 (10) | 28.11 (20) | 7.1 (12) |
| average | 22 | 13 (19) | 11 (19) | 144 (19) | 1926 (19) | not measured | 5.5 (11) | 7.3 (10) | 24.78 (19) | 7.1 (12) |
| average | 23 | 14 (19) | 9 (19) | 86 (19) | 1400 (19) | not measured | 5.5 (10) | 7.3 (15) | 28.42 (19) | 7.1 (12) |
| average | 24 | 9 (18) | 9.5 (18) | 120.5 (18) | 1771.5 (18) | not measured | 4.92 (13) | 7.3 (15) | 23.95 (18) | 7.1 (13) |
| average | 25 | 10.5 (18) | 14.5 (18) | 103.5 (18) | 1771.5 (18) | not measured | 6.13 (14) | 7.3 (16) | 27.25 (18) | 7.1 (14) |
| average | 26 | 11 (18) | 11.5 (18) | 119.5 (18) | 2489 (18) | not measured | 4.63 (13) | 7.3 (17) | 25.52 (18) | 7.1 (12) |
| average | 27 | 13 (18) | 14 (18) | 129.5 (18) | 2472 (18) | not measured | 5.5 (17) | 7.3 (16) | 27.37 (18) | 7.1 (10) |
| average | 28 | 16 (18) | 13 (18) | 131 (18) | 2715.5 (18) | not measured | 5.5 (15) | 7.3 (15) | 28.2 (18) | 7.1 (8) |
| average | 29 | 15 (18) | 12.5 (18) | 128 (18) | 2797.5 (18) | not measured | 5.5 (18) | 7.3 (16) | 27.7 (18) | 7.1 (11) |
| average | 30 | 12.5 (18) | 16.5 (18) | 108.5 (18) | 2294.5 (18) | not measured | 5.5 (15) | 10.95 (18) | 29.35 (18) | 7.1 (9) |
| average | 31 | 16.5 (18) | 14 (18) | 129.5 (18) | 2298 (18) | not measured | 5.5 (15) | 7.3 (16) | 32.06 (18) | 7.1 (9) |
| average | 32 | 15.5 (18) | 13.5 (18) | 129 (18) | 2603 (18) | not measured | 6.45 (17) | 7.3 (16) | 30.41 (18) | 7.1 (7) |
| average | 33 | 14.5 (18) | 13.5 (18) | 167 (18) | 2843.5 (18) | not measured | 5.46 (14) | 7.3 (16) | 29.89 (18) | 7.1 (10) |
| average | 34 | 17 (15) | 16 (15) | 120 (15) | 2326 (15) | 0 (3) | 5.5 (14) | 7.3 (17) | 30.88 (15) | 7.1 (15) |
| average | 35 | 11 (8) | 17.5 (8) | 95 (8) | 2266 (8) | 0 (7) | 5.5 (13) | 7.3 (15) | 26.41 (8) | 7.1 (12) |
| average | 36 | 27 (3) | 18 (3) | 116 (3) | 3649 (3) | 0 (5) | 2.8 (8) | 7.8 (8) | 40.65 (3) | 0 (5) |
| average | 37 | 9 (1) | 20 (1) | 119 (1) | 2114 (1) | 0 (2) | 1.33 (3) | 7.3 (3) | 28.82 (1) | 0.97 (2) |
| average | 38 | 30 (1) | 24 (1) | 128 (1) | 2808 (1) | not measured | 10.05 (1) | 7.3 (1) | 30.95 (1) | not measured |
| average | 39 | not measured | not measured | not measured | not measured | 0 (1) | 0 (1) | 12 (1) | not measured | 7.1 (1) |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| average | 10 | 39 | 1.49 | stat_damage_10 → ghost_kerf → stat_damage_25 → stat_speed_10 → stat_regen_25 → stat_hp_max_25 → ghost_dent → weapon_plasma_rifle → weapon_rocket_launcher → weapon_gatling → weapon_hand_cannon → weapon_pistol → weapon_machine_pistol → stat_guard_meter_25 → stat_regen_10 → weapon_chainsaw → stat_guard_meter_10 → weapon_gloria → weapon_flamethrower → weapon_electro_baton → stat_speed_25 → ghost_tonnage → ghost_ohm → weapon_plasma_sword → stat_hp_max_10 → weapon_katana | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=10 --bot=average --pick=random --controls=wheel |
