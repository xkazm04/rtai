# Gauntlet batch comparison

- **melee** · 4a3ff4b0430b · 10 seeds (1–10) · novice, average, expert · --waves=40 · tick cap not recorded · pick greedy · controls wheel
- **repair** · 4a3ff4b0430b (dirty) · 10 seeds (1–10) · novice, average, expert · --waves=40 · tick cap not recorded · pick greedy · controls wheel
- **budget** · 4a3ff4b0430b (dirty) · 10 seeds (1–10) · novice, average, expert · --waves=40 · tick cap not recorded · pick greedy · controls wheel

## Profile results

A live run at its wave or tick limit contributes its last wave. `>=` marks a lower bound.

Median seconds per timed wave. Each band includes its boss waves. The boss column pools waves 5, 10, 15, and so on. Ordinary waves target 15 s for average (±20%). Boss waves target 25–30 s. Medians use waves with HP telemetry. Damage rate needs elapsed seconds. Repair share is repaired HP divided by damage taken on waves with positive damage. Killers count lethal hits.

| Arm | Profile | Runs | Lethal deaths | Censored | Timeouts (no result) | Wave timers (result) | Median | P25–P75 | Target | Miss | 1–4 (s) | 5 (s) | 6–10 (s) | 11–20 (s) | 21–30 (s) | 31–40 (s) | Boss waves (s) | Damage taken (HP/s) | Repair share | Top killers |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| melee | novice | 10 | 10 | 0 | 0 | 0 | 5 | 5–5 | 6 | -1 | 15.13 | not measured | not measured | not measured | not measured | not measured | not measured | 1.15 | 0% | stomp × 8, riot_cop × 1, swat × 1 |
| melee | average | 10 | 10 | 0 | 0 | 0 | 8 | 5–10 | 12 | -4 | 15.42 | 22.26 | 19.13 | 20.1 | not measured | not measured | 20.02 | 1.03 | 0% | stomp × 3, shield_robot × 2, patrol_cop × 1 |
| melee | expert | 10 | 10 | 0 | 0 | 0 | 8.5 | 7–10 | 20 | -11.5 | 16.89 | 29.85 | 19.52 | 22.53 | not measured | not measured | 27.47 | 0.9 | 0% | sentry_turret × 3, shield_robot × 2, riot_cop × 1 |
| repair | novice | 10 | 10 | 0 | 0 | 0 | 5 | 5–5 | 6 | -1 | 15.25 | not measured | not measured | not measured | not measured | not measured | not measured | 1.15 | 0% | stomp × 8, patrol_cop × 1, riot_cop × 1 |
| repair | average | 10 | 10 | 0 | 0 | 0 | 5 | 5–9 | 12 | -7 | 15.42 | 29.38 | 19.76 | 39.38 | not measured | not measured | 28.85 | 1.01 | 0% | stomp × 5, shield_robot × 3, contractor × 1 |
| repair | expert | 10 | 10 | 0 | 0 | 0 | 9 | 5–9 | 20 | -11 | 16.67 | 33.98 | 22.7 | not measured | not measured | not measured | 34.33 | 0.93 | 0% | stomp × 3, sentry_turret × 2, shield_robot × 2 |
| budget | novice | 10 | 10 | 0 | 0 | 0 | 5 | 5–5 | 6 | -1 | 15.67 | not measured | not measured | not measured | not measured | not measured | not measured | 1.1 | 0% | stomp × 9, riot_cop × 1 |
| budget | average | 10 | 10 | 0 | 0 | 0 | 8.5 | 5–9 | 12 | -3.5 | 16.26 | 19.66 | 24.13 | not measured | not measured | not measured | 19.66 | 1.08 | 0% | shield_robot × 5, stomp × 2, rocket × 1 |
| budget | expert | 10 | 10 | 0 | 0 | 0 | 9 | 6–9 | 20 | -11 | 16.96 | 30.93 | 21.35 | 31.05 | not measured | not measured | 30.93 | 1.01 | 0% | shield_robot × 6, stomp × 2, rocket × 1 |

## Profile separation

Separation requires a confirmed median gap of 3 waves and a later death on 75% of shared, scored seeds with matching controls and picks. Two censored runs count in the denominator.

| Arm | Profiles | Observed gap | Later / shared seeds | Result |
| --- | --- | --- | --- | --- |
| melee | novice → average | +3 | 7/10 (70%) | not separated |
| melee | average → expert | +0.5 | 5/10 (50%) | not separated |
| repair | novice → average | 0 | 5/10 (50%) | not separated |
| repair | average → expert | +4 | 5/10 (50%) | not separated |
| budget | novice → average | +3.5 | 6/10 (60%) | not separated |
| budget | average → expert | +0.5 | 5/10 (50%) | not separated |
