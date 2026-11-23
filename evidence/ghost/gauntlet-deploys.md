# Ghost deploys in the eight-wave street gauntlet

Each pair used the same seed, profile, greedy picks, wheel controls and eight-wave limit. The before run used the parent of the bot integration commit. The after run used the integrated bot. Both arms had identical tuning table hashes.

## Effects per recorded release

| Profile | Form | Before uses | After uses | After kills | Kills/use | Machine-seconds stunned | Stun s/use |
|---|---|---:|---:|---:|---:|---:|---:|
| average | kerf | 0 | 0 | — | — | — | — |
| average | ohm | 0 | 5 | 3 | 0.60 | 9.38 | 1.88 |
| average | tonnage | 0 | 20 | 45 | 2.25 | — | — |
| average | dent | 0 | 0 | — | — | — | — |
| expert | kerf | 0 | 0 | — | — | — | — |
| expert | ohm | 0 | 0 | — | — | — | — |
| expert | tonnage | 0 | 19 | 37 | 1.95 | — | — |
| expert | dent | 0 | 0 | — | — | — | — |

Across both profiles, Tonnage scored 82 kills in 39 stomps (2.10 per use). All five Ohm releases came from average seed 2. They killed three hostiles and held machines stunned for a combined 9.38 seconds. Both profiles picked Dent after wave 4 on seed 1 and recorded no ram. Their only Kerf pick came after the final fight on seed 1.

Totals sum the wave records. The integrated runs had no overlapping waves. Baseline average seed 2 timed out on wave 6, so its wave 6 and 7 observations overlap. An unfinished wave has no final tally. A dash marks an absent measurement or a rate with no releases. One machine stunned for one second contributes one machine-second.

## Paired outcomes

| Profile | Seed | Before | After | Ghosts picked before | Ghosts picked after |
|---|---:|---|---|---|---|
| average | 1 | cleared 8 | cleared 8 | tonnage (wave 1), dent (wave 4), kerf (wave 8) | tonnage (wave 1), dent (wave 4), kerf (wave 8) |
| average | 2 | died on 7 | cleared 8 | tonnage (wave 1), ohm (wave 2) | tonnage (wave 1), ohm (wave 2) |
| average | 3 | cleared 8 | cleared 8 | tonnage (wave 6), ohm (wave 8) | tonnage (wave 6), ohm (wave 8) |
| expert | 1 | tick cap on 8 | cleared 8 | tonnage (wave 1), dent (wave 4) | tonnage (wave 1), dent (wave 4), kerf (wave 8) |
| expert | 2 | died on 5 | died on 5 | tonnage (wave 1), ohm (wave 2) | tonnage (wave 1), ohm (wave 2) |
| expert | 3 | cleared 8 | cleared 8 | tonnage (wave 6), ohm (wave 8) | tonnage (wave 6), ohm (wave 8) |

## Wave records

A range groups consecutive waves with identical fields. The JSON preserves individual wave numbers and the original numeric precision.

| Profile | Seed | Arm | Wave | deploys | deploy_kills | deploy_stun_s |
|---|---:|---|---|---|---|---|
| average | 1 | before | 1–8 | — | — | — |
| average | 1 | after | 1 | — | — | — |
| average | 1 | after | 2 | tonnage 1 | tonnage 3 | — |
| average | 1 | after | 3–4 | tonnage 1 | tonnage 4 | — |
| average | 1 | after | 5 | tonnage 1 | tonnage 0 | — |
| average | 1 | after | 6 | tonnage 2 | tonnage 5 | — |
| average | 1 | after | 7 | tonnage 2 | tonnage 3 | — |
| average | 1 | after | 8 | tonnage 2 | tonnage 6 | — |
| average | 2 | before | 1–7 | — | — | — |
| average | 2 | after | 1 | — | — | — |
| average | 2 | after | 2 | tonnage 1 | tonnage 4 | — |
| average | 2 | after | 3 | tonnage 1 | tonnage 3 | — |
| average | 2 | after | 4 | — | — | — |
| average | 2 | after | 5 | tonnage 3 | tonnage 3 | — |
| average | 2 | after | 6 | ohm 2, tonnage 1 | ohm 2, tonnage 4 | ohm 4 |
| average | 2 | after | 7 | tonnage 1 | tonnage 2 | — |
| average | 2 | after | 8 | ohm 3, tonnage 1 | ohm 1, tonnage 1 | ohm 5.383 |
| average | 3 | before | 1–8 | — | — | — |
| average | 3 | after | 1–6 | — | — | — |
| average | 3 | after | 7 | tonnage 1 | tonnage 0 | — |
| average | 3 | after | 8 | tonnage 1 | tonnage 3 | — |
| expert | 1 | before | 1–7 | — | — | — |
| expert | 1 | before | 8 (unfinished) | — | — | — |
| expert | 1 | after | 1 | — | — | — |
| expert | 1 | after | 2–4 | tonnage 1 | tonnage 3 | — |
| expert | 1 | after | 5 | tonnage 2 | tonnage 2 | — |
| expert | 1 | after | 6 | tonnage 1 | tonnage 2 | — |
| expert | 1 | after | 7 | tonnage 2 | tonnage 3 | — |
| expert | 1 | after | 8 | tonnage 3 | tonnage 6 | — |
| expert | 2 | before | 1–5 | — | — | — |
| expert | 2 | after | 1 | — | — | — |
| expert | 2 | after | 2 | tonnage 2 | tonnage 6 | — |
| expert | 2 | after | 3 | — | — | — |
| expert | 2 | after | 4 | tonnage 1 | tonnage 3 | — |
| expert | 2 | after | 5 | tonnage 3 | tonnage 2 | — |
| expert | 3 | before | 1–8 | — | — | — |
| expert | 3 | after | 1–6 | — | — | — |
| expert | 3 | after | 7 | tonnage 1 | tonnage 1 | — |
| expert | 3 | after | 8 | tonnage 1 | tonnage 3 | — |

The batch command was `node tools/gauntlet/batch.mjs --seeds=3 --seed0=1 --profile=average --pick=greedy --controls=wheel --waves=8 --jobs=1 --out=<directory>`. The expert runs used `--profile=expert`. Exact revisions and result hashes are in [the paired data](gauntlet-deploys.json).
