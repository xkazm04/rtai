# Gauntlet run report

9 of 9 runs accepted. Average-profile waves 1 (2.82 s), 2 (6.72 s), 3 (9.33 s), 4 (8.6 s) fell outside 12–18 s.

Live pit batch · n22-loop @ b6d34c5df345 (dirty) · 2026-11-21T00:34:09.954Z.

## Wave time

Seconds per observed wave. The target is 15 s. Average medians below 12 s or above 18 s are flagged. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Median s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 3 / 3 | 4.57 | 2.72…7.05 | 2.72…7.05 | — |
| novice | 2 | 3 / 3 | 9.18 | 4.97…9.7 | 4.97…9.7 | — |
| novice | 3 | 3 / 3 | 12.32 | 11.42…21.07 | 11.42…21.07 | — |
| novice | 4 | 0 / 2 | not measured | not measured | not measured | — |
| average | 1 | 3 / 3 | 2.82 | 2.1…5.02 | 2.1…5.02 | miss |
| average | 2 | 3 / 3 | 6.72 | 6.2…7.73 | 6.2…7.73 | miss |
| average | 3 | 3 / 3 | 9.33 | 2.72…10.5 | 2.72…10.5 | miss |
| average | 4 | 3 / 3 | 8.6 | 4.98…9.6 | 4.98…9.6 | miss |
| average | 5 | 0 / 2 | not measured | not measured | not measured | not measured |
| expert | 1 | 3 / 3 | 2.75 | 2.65…2.75 | 2.65…2.75 | — |
| expert | 2 | 3 / 3 | 4.92 | 3.93…4.98 | 3.93…4.98 | — |
| expert | 3 | 3 / 3 | 4.1 | 4.05…7.47 | 4.05…7.47 | — |
| expert | 4 | 3 / 3 | 8.85 | 6.45…10.52 | 6.45…10.52 | — |
| expert | 5 | 1 / 3 | 3.85 | 3.85…3.85 | 3.85…3.85 | — |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | No death recorded | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- |
| novice | 3 | 0 | 3 | — | — | 0 |
| average | 3 | 0 | 3 | — | — | 0 |
| expert | 3 | 0 | 3 | — | — | 0 |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- |
| contractor | 0 | 59.95% | 8.72 (16) | 4.94 (18) |
| patrol_cop | 0 | 37.63% | 4.78 (16) | 7.09 (18) |
| riot_cop | 0 | 64.07% | 6.72 (19) | 4.98 (15) |
| robot_gunner | 0 | 59.95% | 8.72 (16) | 4.94 (18) |
| robot_thug | 0 | 83.99% | 7.6 (24) | 2.78 (10) |
| swat | 0 | 63.38% | 4.98 (25) | 9.33 (9) |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. At least two pairs are needed for each interval. These observational comparisons can reflect the rest of the loadout.

No bonus offers were recorded.

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

No offers mapped to a weapon ref.

## Combat telemetry

Deflects, rolls, shots and seconds in each form are medians. Parentheses count observations. Hit rate pools hits and shots only across rows measuring both. A zero denominator has no rate.

| Profile | Wave | Guard deflects (n) | Rolls (n) | Shots (n) | Hit rate (shots) | dent s (n) | kerf s (n) | ohm s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | not measured | 0 (3) | 8 (3) | not measured | 0 (3) | 0 (3) | 0 (3) | 0 (3) |
| novice | 2 | not measured | 0 (3) | 20 (3) | not measured | 0 (3) | 0.2 (3) | 0 (3) | 0 (3) |
| novice | 3 | not measured | 0 (3) | 24 (3) | not measured | 0 (3) | 0 (3) | 0 (3) | 6.55 (3) |
| novice | 4 | not measured | 1 (2) | 11.5 (2) | not measured | 0 (2) | 0 (2) | 0 (2) | 0 (2) |
| average | 1 | not measured | 0 (3) | 6 (3) | not measured | 0 (3) | 0 (3) | 0 (3) | 0 (3) |
| average | 2 | not measured | 1 (3) | 16 (3) | not measured | 0 (3) | 0.02 (3) | 0 (3) | 0 (3) |
| average | 3 | not measured | 0 (3) | 18 (3) | not measured | 0 (3) | 2.35 (3) | 0 (3) | 0 (3) |
| average | 4 | not measured | 0 (3) | 15 (3) | not measured | 0 (3) | 3.18 (3) | 0 (3) | 0 (3) |
| average | 5 | not measured | 1 (2) | 9 (2) | not measured | 0 (2) | 1.49 (2) | 0 (2) | 0 (2) |
| expert | 1 | not measured | 0 (3) | 5 (3) | not measured | 0 (3) | 0 (3) | 0 (3) | 0 (3) |
| expert | 2 | not measured | 0 (3) | 11 (3) | not measured | 0 (3) | 0 (3) | 0 (3) | 0 (3) |
| expert | 3 | not measured | 0 (3) | 8 (3) | not measured | 0 (3) | 1.65 (3) | 0 (3) | 0 (3) |
| expert | 4 | not measured | 2 (3) | 11 (3) | not measured | 0 (3) | 1.07 (3) | 0 (3) | 0 (3) |
| expert | 5 | not measured | 0 (3) | 14 (3) | not measured | 0 (3) | 1.23 (3) | 0 (3) | 0 (3) |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 3 | 4 | 0.53 | none | none | kerf | node tools/dev/run.mjs bot_pit_probe --profile=novice --seed=3 --result=C:\\Users\\kazda\\kiro\\gtai-wt\\n22-loop\\build\\gauntlet\\replay\\novice-3.json |
| novice | 1 | 4 | 0.19 | none | none | tonnage | node tools/dev/run.mjs bot_pit_probe --profile=novice --seed=1 --result=C:\\Users\\kazda\\kiro\\gtai-wt\\n22-loop\\build\\gauntlet\\replay\\novice-1.json |
| expert | 2 | 5 | 0.53 | none | none | tonnage | node tools/dev/run.mjs bot_pit_probe --profile=expert --seed=2 --result=C:\\Users\\kazda\\kiro\\gtai-wt\\n22-loop\\build\\gauntlet\\replay\\expert-2.json |
| expert | 1 | 5 | 0.19 | none | none | kerf | node tools/dev/run.mjs bot_pit_probe --profile=expert --seed=1 --result=C:\\Users\\kazda\\kiro\\gtai-wt\\n22-loop\\build\\gauntlet\\replay\\expert-1.json |
| expert | 3 | 5 | 0.19 | none | none | kerf | node tools/dev/run.mjs bot_pit_probe --profile=expert --seed=3 --result=C:\\Users\\kazda\\kiro\\gtai-wt\\n22-loop\\build\\gauntlet\\replay\\expert-3.json |
