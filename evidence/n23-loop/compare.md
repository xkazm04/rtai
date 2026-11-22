# Gauntlet batch comparison

- **main** · 76111adecc00 · 20 seeds (1–20) · novice, average, expert · no wave limit · 72000-tick cap · pick greedy · controls wheel
- **street** · ccfc29df081a (dirty) · 10 seeds (1–10) · novice, average, expert · --waves=40 · tick cap not recorded · pick greedy · controls wheel
- **merged** · 548989d7e233 (dirty) · 10 seeds (1–10) · novice, average, expert · --waves=40 · 216000-tick cap · pick greedy · controls wheel
- **cycle1** · ccfc29df081a (dirty) · 10 seeds (1–10) · novice, average, expert · --waves=40 · 216000-tick cap · pick greedy · controls wheel
- **cycle2** · ccfc29df081a (dirty) · 8 seeds (1–8) · novice, average, expert · --waves=40 · tick cap not recorded · pick greedy · controls wheel

## Profile results

A live run at its wave or tick limit contributes its last wave. `>=` marks a lower bound.

Median seconds per timed wave. Each band includes its boss waves. The boss column pools waves 5, 10, 15, and so on. Ordinary waves target 15 s for average (±20%). Boss waves target 25–30 s. Medians use waves with HP telemetry. Damage rate needs elapsed seconds. Repair share is repaired HP divided by damage taken on waves with positive damage. Killers count lethal hits.

| Arm | Profile | Runs | Lethal deaths | Censored | Timeouts (no result) | Wave timers (result) | Median | P25–P75 | Target | Miss | 1–4 (s) | 5 (s) | 6–10 (s) | 11–20 (s) | 21–30 (s) | 31–40 (s) | Boss waves (s) | Damage taken (HP/s) | Repair share | Top killers |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| main | novice | 20 | 19 | 0 | 0 | 1 | 14 | 10–22 | 6 | +8 | 6.57 | 12.27 | 14.42 | 34.64 | 41.25 | not measured | 18.57 | not measured | not measured | stomp × 7, shield_robot × 6, rocket × 5 |
| main | average | 20 | 1 | 17 | 0 | 2 | >= 36 | 35–37 | 12 | >= +24 | 6.82 | 19.13 | 14.57 | 30.43 | 39.71 | 49.4 | 39.25 | not measured | not measured | shield_robot × 1 |
| main | expert | 20 | 0 | 17 | 0 | 3 | >= 37 | 36–38 | 20 | >= +17 | 6.67 | 23.23 | 13.93 | 29.38 | 37.91 | 43.48 | 39 | 0.51 | 100% | none |
| street | novice | 10 | 10 | 0 | 0 | 0 | 14 | 11–24 | 6 | +8 | 12.28 | 13.05 | 21.58 | 38.27 | 43.97 | not measured | 20.38 | 0.86 | 100% | shield_robot × 5, rocket × 3, stomp × 2 |
| street | average | 10 | 1 | 8 | 1 | 0 | >= 40 | 40–40 | 12 | >= +28 | 11.41 | 14.92 | 19.98 | 35.17 | 39.45 | 48.38 | 32.77 | 0.8 | 100% | shield_robot × 1 |
| street | expert | 10 | 0 | 10 | 0 | 0 | >= 40 | 40–40 | 20 | >= +20 | 11.36 | 18.25 | 20.56 | 33.69 | 39.12 | 45.23 | 36.32 | 0.61 | 100% | none |
| merged | novice | 10 | 10 | 0 | 0 | 0 | 12 | 10–13 | 6 | +6 | 12.1 | 16.87 | 22.68 | 27.74 | 38.02 | not measured | 19.23 | 0.61 | 100% | rocket × 5, shield_robot × 3, patrol_cop × 1 |
| merged | average | 10 | 0 | 10 | 0 | 0 | >= 40 | 40–40 | 12 | >= +28 | 11.41 | 14.43 | 21.51 | 28.04 | 29.77 | 37.85 | 26.03 | 0.53 | 100% | none |
| merged | expert | 10 | 0 | 10 | 0 | 0 | >= 40 | 40–40 | 20 | >= +20 | 11.22 | 20.79 | 19.26 | 26.5 | 27.69 | 32.6 | 24.02 | 0.39 | 100% | none |
| cycle1 | novice | 10 | 10 | 0 | 0 | 0 | 16 | 12–23 | 6 | +10 | 12.28 | 13.05 | 22.27 | 36.16 | 43.17 | not measured | 19.13 | 0.71 | 100% | shield_robot × 4, rocket × 2, stomp × 2 |
| cycle1 | average | 10 | 2 | 8 | 0 | 0 | >= 40 | 33–40 | 12 | >= +28 | 11.41 | 16.23 | 19.4 | 32.57 | 41.58 | 49.67 | 31.47 | 0.69 | 100% | shield_robot × 1, war_cannon × 1 |
| cycle1 | expert | 10 | 0 | 10 | 0 | 0 | >= 40 | 40–40 | 20 | >= +20 | 11.36 | 18.25 | 19.76 | 33.29 | 36.95 | 43.92 | 32.64 | 0.54 | 100% | none |
| cycle2 | novice | 8 | 8 | 0 | 0 | 0 | 13 | 12–25 | 6 | +7 | 12.38 | 11.93 | 22.12 | 37.72 | 40.88 | not measured | 18.56 | 0.69 | 100% | shield_robot × 4, stomp × 2, rocket × 1 |
| cycle2 | average | 8 | 1 | 7 | 0 | 0 | >= 40 | 40–40 | 12 | >= +28 | 11.31 | 18.42 | 20.43 | 35.96 | 38.28 | 50.51 | 39.18 | 0.73 | 100% | swat × 1 |
| cycle2 | expert | 8 | 0 | 8 | 0 | 0 | >= 40 | 40–40 | 20 | >= +20 | 11.22 | 18.03 | 19.47 | 34.29 | 40.9 | 45.48 | 37.48 | 0.57 | 100% | none |

## Profile separation

Separation requires a confirmed median gap of 3 waves and a later death on 75% of shared, scored seeds with matching controls and picks. Two censored runs count in the denominator.

| Arm | Profiles | Observed gap | Later / shared seeds | Result |
| --- | --- | --- | --- | --- |
| main | novice → average | +22 | 17/17 (100%) | separated |
| main | average → expert | +1 | 1/15 (6.67%) | not separated |
| street | novice → average | +26 | 9/9 (100%) | separated |
| street | average → expert | 0 | 1/9 (11.11%) | not separated |
| merged | novice → average | +28 | 10/10 (100%) | separated |
| merged | average → expert | 0 | 0/10 (0%) | not separated |
| cycle1 | novice → average | +24 | 9/10 (90%) | separated |
| cycle1 | average → expert | 0 | 2/10 (20%) | not separated |
| cycle2 | novice → average | +27 | 8/8 (100%) | separated |
| cycle2 | average → expert | 0 | 1/8 (12.5%) | not separated |
