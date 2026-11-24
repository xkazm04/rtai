# Gauntlet batch comparison

- **main** · 22033e2fea54 (dirty) · 10 seeds (1–10) · novice, average, expert · --waves=40 · tick cap not recorded · pick greedy · controls wheel
- **combat** · b9df9127b760 (dirty) · 10 seeds (1–10) · novice, average, expert · --waves=40 · tick cap not recorded · pick greedy · controls wheel

## Profile results

A live run at its wave or tick limit contributes its last wave. `>=` marks a lower bound.

Median seconds per timed wave. Each band includes its boss waves. The boss column pools waves 5, 10, 15, and so on. Ordinary waves target 15 s for average (±20%). Boss waves target 25–30 s. Medians use waves with HP telemetry. Damage rate needs elapsed seconds. Repair share is repaired HP divided by damage taken on waves with positive damage. Killers count lethal hits.

| Arm | Profile | Runs | Lethal deaths | Censored | Timeouts (no result) | Wave timers (result) | Median | P25–P75 | Target | Miss | 1–4 (s) | 5 (s) | 6–10 (s) | 11–20 (s) | 21–30 (s) | 31–40 (s) | Boss waves (s) | Damage taken (HP/s) | Repair share | Top killers |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| main | novice | 10 | 10 | 0 | 0 | 0 | 5 | 5–5 | 6 | -1 | 15.13 | not measured | not measured | not measured | not measured | not measured | not measured | 1.15 | 0% | stomp × 8, riot_cop × 1, swat × 1 |
| main | average | 10 | 10 | 0 | 0 | 0 | 8 | 5–10 | 12 | -4 | 15.42 | 22.26 | 19.13 | 20.1 | not measured | not measured | 20.02 | 1.03 | 0% | stomp × 3, shield_robot × 2, patrol_cop × 1 |
| main | expert | 10 | 10 | 0 | 0 | 0 | 8.5 | 7–10 | 20 | -11.5 | 16.89 | 29.85 | 19.52 | 22.53 | not measured | not measured | 27.47 | 0.9 | 0% | sentry_turret × 3, shield_robot × 2, riot_cop × 1 |
| combat | novice | 10 | 10 | 0 | 0 | 0 | 5 | 5–5 | 6 | -1 | 15.13 | not measured | not measured | not measured | not measured | not measured | not measured | 1.15 | 0% | stomp × 8, riot_cop × 1, swat × 1 |
| combat | average | 10 | 10 | 0 | 0 | 0 | 8 | 5–10 | 12 | -4 | 15.42 | 22.33 | 19.13 | 17.3 | not measured | not measured | 20.5 | 1.03 | 0% | stomp × 3, rocket × 2, shield_robot × 2 |
| combat | expert | 10 | 10 | 0 | 0 | 0 | 8.5 | 7–10 | 20 | -11.5 | 17.18 | 30.95 | 19.33 | not measured | not measured | not measured | 29.05 | 0.89 | 0% | sentry_turret × 4, riot_cop × 1, robot_gunner × 1 |

## Profile separation

Separation requires a confirmed median gap of 3 waves and a later death on 75% of shared, scored seeds with matching controls and picks. Two censored runs count in the denominator.

| Arm | Profiles | Observed gap | Later / shared seeds | Result |
| --- | --- | --- | --- | --- |
| main | novice → average | +3 | 7/10 (70%) | not separated |
| main | average → expert | +0.5 | 5/10 (50%) | not separated |
| combat | novice → average | +3 | 7/10 (70%) | not separated |
| combat | average → expert | +0.5 | 4/10 (40%) | not separated |
