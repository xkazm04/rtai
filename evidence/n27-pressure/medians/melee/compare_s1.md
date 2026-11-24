# Gauntlet batch comparison

- **main** · a3b3f14660a2 (dirty) · 10 seeds (1–10) · novice, average, expert · --waves=40 · tick cap not recorded · pick greedy · controls wheel
- **melee** · 4a3ff4b0430b · 10 seeds (1–10) · novice, average, expert · --waves=40 · tick cap not recorded · pick greedy · controls wheel

## Profile results

A live run at its wave or tick limit contributes its last wave. `>=` marks a lower bound.

Median seconds per timed wave. Each band includes its boss waves. The boss column pools waves 5, 10, 15, and so on. Ordinary waves target 15 s for average (±20%). Boss waves target 25–30 s. Medians use waves with HP telemetry. Damage rate needs elapsed seconds. Repair share is repaired HP divided by damage taken on waves with positive damage. Killers count lethal hits.

| Arm | Profile | Runs | Lethal deaths | Censored | Timeouts (no result) | Wave timers (result) | Median | P25–P75 | Target | Miss | 1–4 (s) | 5 (s) | 6–10 (s) | 11–20 (s) | 21–30 (s) | 31–40 (s) | Boss waves (s) | Damage taken (HP/s) | Repair share | Top killers |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| main | novice | 10 | 10 | 0 | 0 | 0 | 5 | 5–5 | 6 | -1 | 15.4 | not measured | not measured | not measured | not measured | not measured | not measured | 1.03 | 0% | stomp × 8, riot_cop × 2 |
| main | average | 10 | 10 | 0 | 0 | 0 | 5 | 5–5 | 12 | -7 | 15.02 | 21.02 | 24.88 | not measured | not measured | not measured | 20.92 | 1.03 | 0% | stomp × 6, rocket × 2, sentry_turret × 1 |
| main | expert | 10 | 10 | 0 | 0 | 0 | 9 | 9–9 | 20 | -11 | 17.13 | 28.72 | 21.42 | not measured | not measured | not measured | 28.72 | 0.97 | 0% | shield_robot × 3, rocket × 2, sentry_turret × 2 |
| melee | novice | 10 | 10 | 0 | 0 | 0 | 5 | 5–5 | 6 | -1 | 15.43 | not measured | not measured | not measured | not measured | not measured | not measured | 1.09 | 0% | stomp × 8, riot_cop × 2 |
| melee | average | 10 | 10 | 0 | 0 | 0 | 5 | 5–5 | 12 | -7 | 15.02 | 23.14 | 23.24 | 38.13 | not measured | not measured | 24.73 | 0.98 | 0% | stomp × 6, rocket × 2, contractor × 1 |
| melee | expert | 10 | 10 | 0 | 0 | 0 | 9 | 8–9 | 20 | -11 | 18.04 | 30.18 | 20.57 | not measured | not measured | not measured | 28.72 | 0.91 | 0% | shield_robot × 5, sentry_turret × 3, rocket × 1 |

## Profile separation

Separation requires a confirmed median gap of 3 waves and a later death on 75% of shared, scored seeds with matching controls and picks. Two censored runs count in the denominator.

| Arm | Profiles | Observed gap | Later / shared seeds | Result |
| --- | --- | --- | --- | --- |
| main | novice → average | 0 | 3/10 (30%) | not separated |
| main | average → expert | +4 | 7/10 (70%) | not separated |
| melee | novice → average | 0 | 3/10 (30%) | not separated |
| melee | average → expert | +4 | 6/10 (60%) | not separated |
