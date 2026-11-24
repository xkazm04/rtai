# Kerf on gauntlet bosses

One deployed cut can take at most **10% of maximum HP**. On the 26 HP war machine this limits a rear cut to **2.6 HP**, down from 6. The uncapped cut uses 4 robot damage and the machine takes 1.5 times rear damage. A fresh machine already survived on this branch. The review frames show the same finishing opportunity at 6 HP.

**Wave 5 cleared in 15.49 s without Kerf, 13.20 s uncapped and 14.34 s capped.** All ten seeds cleared in each arm. The 25 to 30 s target exceeds the no-Kerf time on every seed. For this fallback, the balance budget is at most 2 s saved per deployment on average across paired clears, one fifth of the 10 s cooldown. This preserves a reason to spend the slot on the boss while leaving most of the fight to Rivet. The capped cut saved 1.15 s per wave, or 0.96 s per release.

Wave 10 cleared on 4/10, 3/10 and 3/10 seeds respectively. The capped survivors averaged 28.68 s, but none individually cleared in the 25 to 30 s band. On the three seeds that cleared in both the no-Kerf and capped arms, the saving averaged 3.42 s per wave, or 1.71 s per release. Deaths are included in HP and deployment statistics. A death before the boss falls has no boss time-to-kill or wave clear time.

## Paired experiment

Each arm starts directly on the corresponding seeded street block at its entrance, with a fresh world, full HP, pistol, both obtainable maximum-HP cards (137.5 HP) and ready cooldowns. Earlier damage, ammo use, offers and RNG draws from fighting earlier waves are skipped. The composer, spawn positions, armour, movement, damage, normal combat AI and 60 Hz pilot run live. The measured wave is the run limit, so no later wave joins it. Duration and boss time-to-kill start at the first spawn and end on the lethal simulation tick.

All arms use the expert wheel-control test player. Form use is set to 1.0 so every eligible opportunity is taken. While the boss lives, the probe gives the normal numbered-deploy spot search only that target. Range, sight, targeting, release and the 600-tick cooldown still apply. After its death the normal spot search can select an escort. The no-Kerf player owns no ghosts. The other arms own only Kerf, with a cap of 1.0 for the old behaviour and 0.10 for the shipped behaviour. No electro gun was equipped and no robot died to a full claw discharge in these 60 trials.

The JSON contains every roster and every release, including the tick, target and actual HP lost. Run the headless entry `res://dev/ghost-forms/boss_wave.gd` with `--fixed-fps 60` and user arguments `--seeds=10 --out=<absolute.json>`.

## Results

Intervals are two-sided 95% Student t confidence intervals for the seed mean. Time-to-kill uses recorded boss deaths. Wave times use clears only. For the other metrics each seed contributes one observation, including zeros.

### Wave 5

| Arm | Measure | n | Mean | Min | Max | 95% CI |
|---|---|---:|---:|---:|---:|---:|
| `no_kerf` | Wave clear (s) | 10 | 15.49 | 10.92 | 21.08 | 12.82 to 18.15 |
| `no_kerf` | Boss TTK (s) | 10 | 15.06 | 10.92 | 20.18 | 12.56 to 17.57 |
| `no_kerf` | Rivet HP lost | 10 | 40.45 | 3.04 | 107.81 | 18.31 to 62.59 |
| `no_kerf` | Kerf deploys | 10 | 0.00 | 0.00 | 0.00 | 0.00 to 0.00 |
| `no_kerf` | Total cut damage (HP) | 10 | 0.00 | 0.00 | 0.00 | 0.00 to 0.00 |
| `kerf_uncapped` | Wave clear (s) | 10 | 13.20 | 10.08 | 18.63 | 11.13 to 15.26 |
| `kerf_uncapped` | Boss TTK (s) | 10 | 12.74 | 9.47 | 18.37 | 10.64 to 14.84 |
| `kerf_uncapped` | Rivet HP lost | 10 | 43.02 | 3.60 | 124.80 | 13.55 to 72.49 |
| `kerf_uncapped` | Kerf deploys | 10 | 1.10 | 1.00 | 2.00 | 0.87 to 1.33 |
| `kerf_uncapped` | Total cut damage (HP) | 10 | 6.20 | 6.00 | 8.00 | 5.75 to 6.65 |
| `kerf_capped` | Wave clear (s) | 10 | 14.34 | 10.78 | 19.65 | 12.01 to 16.67 |
| `kerf_capped` | Boss TTK (s) | 10 | 13.72 | 10.18 | 19.42 | 11.49 to 15.95 |
| `kerf_capped` | Rivet HP lost | 10 | 43.26 | 3.60 | 124.80 | 13.96 to 72.55 |
| `kerf_capped` | Kerf deploys | 10 | 1.20 | 1.00 | 2.00 | 0.90 to 1.50 |
| `kerf_capped` | Total cut damage (HP) | 10 | 2.89 | 2.60 | 4.60 | 2.41 to 3.37 |

| Seed | No Kerf (s) | Uncapped (s) | Capped (s) |
|---:|---:|---:|---:|
| 1 | 16.27 | 10.32 | 10.78 |
| 2 | 11.12 | 11.27 | 12.38 |
| 3 | 20.08 | 16.33 | 18.93 |
| 4 | 19.03 | 18.63 | 19.65 |
| 5 | 21.08 | 15.83 | 17.43 |
| 6 | 13.87 | 12.27 | 14.20 |
| 7 | 16.45 | 12.58 | 13.32 |
| 8 | 10.92 | 10.08 | 10.85 |
| 9 | 11.62 | 10.88 | 11.70 |
| 10 | 14.42 | 13.77 | 14.13 |

### Wave 10

| Arm | Measure | n | Mean | Min | Max | 95% CI |
|---|---|---:|---:|---:|---:|---:|
| `no_kerf` | Wave clear (s) | 4 | 34.80 | 25.15 | 42.90 | 23.01 to 46.59 |
| `no_kerf` | Boss TTK (s) | 4 | 32.55 | 22.13 | 38.43 | 20.80 to 44.31 |
| `no_kerf` | Rivet HP lost | 10 | 120.39 | 75.21 | 137.50 | 103.55 to 137.24 |
| `no_kerf` | Kerf deploys | 10 | 0.00 | 0.00 | 0.00 | 0.00 to 0.00 |
| `no_kerf` | Total cut damage (HP) | 10 | 0.00 | 0.00 | 0.00 | 0.00 to 0.00 |
| `kerf_uncapped` | Wave clear (s) | 3 | 24.61 | 17.18 | 35.62 | 0.46 to 48.77 |
| `kerf_uncapped` | Boss TTK (s) | 3 | 20.50 | 13.00 | 33.62 | -7.82 to 48.82 |
| `kerf_uncapped` | Rivet HP lost | 10 | 107.12 | 14.19 | 137.50 | 69.97 to 144.26 |
| `kerf_uncapped` | Kerf deploys | 10 | 1.30 | 0.00 | 2.00 | 0.71 to 1.89 |
| `kerf_uncapped` | Total cut damage (HP) | 10 | 7.40 | 0.00 | 12.00 | 4.10 to 10.70 |
| `kerf_capped` | Wave clear (s) | 3 | 28.68 | 22.88 | 38.57 | 7.30 to 50.06 |
| `kerf_capped` | Boss TTK (s) | 3 | 26.21 | 17.95 | 37.42 | 1.20 to 51.21 |
| `kerf_capped` | Rivet HP lost | 10 | 125.19 | 68.30 | 137.50 | 108.74 to 141.65 |
| `kerf_capped` | Kerf deploys | 10 | 1.30 | 0.00 | 2.00 | 0.71 to 1.89 |
| `kerf_capped` | Total cut damage (HP) | 10 | 3.38 | 0.00 | 5.20 | 1.85 to 4.91 |

| Seed | No Kerf (s) | Uncapped (s) | Capped (s) |
|---:|---:|---:|---:|
| 1 | 37.10 | 35.62 | 38.57 |
| 2 | 34.05 | 17.18 | 24.58 |
| 3 | death at 23.33 | death at 15.43 | death at 15.43 |
| 4 | death at 28.25 | death at 14.83 | death at 14.83 |
| 5 | 25.15 | 21.03 | 22.88 |
| 6 | death at 29.92 | death at 17.10 | death at 17.10 |
| 7 | death at 18.27 | death at 22.13 | death at 22.13 |
| 8 | 42.90 | death at 15.47 | death at 15.47 |
| 9 | death at 35.95 | death at 16.07 | death at 16.07 |
| 10 | death at 25.50 | death at 29.80 | death at 29.80 |

## Review frames

Both captures use a real wave-5 boss slot and the numbered Kerf deploy. The target starts at 6 of its normal 26 HP. The frames are native viewport crops at the stated scale.

| Scale | Uncapped, 0 HP left | Capped, 3.4 HP left |
|---|---|---|
| 32 px/m | [Before](frames/kerf-before-32.png) | [After](frames/kerf-after-32.png) |
| 64 px/m | [Before](frames/kerf-before-64.png) | [After](frames/kerf-after-64.png) |
