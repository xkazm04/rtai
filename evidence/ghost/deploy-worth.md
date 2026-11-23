# What one ghost deploy bought in a pistol fight

Rivet walked a 5.5 m strafe circle on open ground and fired his pistol at the nearest living hostile. The two arms used the same initial formation, seed and 1,800-tick budget. Only the on arm pressed and released Q. Each trial ended at the last hostile kill, Rivet’s death, or 30 s. The tables give cumulative HP lost and elapsed seconds to clear. One ordinary human has 1.0 HP. A dash marks an unobserved clear. The outcome column records why.

The on arm cast at the first eligible opportunity. Kerf preferred a lethal cut, then the most HP removed. Ohm prioritized machines, then total bodies. Tonnage and Dent maximized bodies inside the footprint. Area casts searched the input word’s quantized bearings and reaches. While placing a cast, Rivet fired only when the pistol and deploy bearings agreed. The gun, enemies, cooldowns and projectile simulation ran normally.

Kills and living-machine stun time come from the wave deploy tally. Stun is measured in body-seconds, so two machines held for one second count as two. Damage counts actual hostile HP removed by the release, excluding overkill. An empty release reached no victim and still spent its cooldown. All per-use estimates pool effects over actual releases. A measured zero is printed as zero.

Both arms cleared every encounter on seeds 1 through 10. Each clear-time difference subtracts the pistol-only time from the deploy time. The paired 95% Student intervals use all ten differences for that encounter. Kerf and Dent each produced the same time saving on every seed, so their intervals collapse to a single value.

Reproduce from the worktree with `node tools/dev/run.mjs deploy_worth --out=<absolute-path-to-json> --seeds=10 --form=all`. The JSON includes every release tick and both arms’ pistol shot counts.

## Kerf

One shield robot and three patrol cops. The cooldown is 10 s, allowing at most 3 releases per 30 s trial.

| Seed | Clear s off | Clear s on | End off / on | HP lost off | HP lost on | Uses | Empty | Deploy kills | Stun body-s | Deploy damage |
|---:|---:|---:|:---|---:|---:|---:|---:|---:|---:|---:|
| 1 | 16.78 | 10.32 | clear / clear | 12.00 | 6.60 | 2 | 0 | 2 | 0.00 | 4.60 |
| 2 | 16.78 | 10.32 | clear / clear | 10.20 | 6.60 | 2 | 0 | 2 | 0.00 | 4.60 |
| 3 | 16.78 | 10.32 | clear / clear | 6.00 | 2.40 | 2 | 0 | 2 | 0.00 | 4.60 |
| 4 | 16.78 | 10.32 | clear / clear | 16.20 | 10.80 | 2 | 0 | 2 | 0.00 | 4.60 |
| 5 | 16.78 | 10.32 | clear / clear | 13.20 | 9.60 | 2 | 0 | 2 | 0.00 | 4.60 |
| 6 | 16.78 | 10.32 | clear / clear | 13.80 | 8.40 | 2 | 0 | 2 | 0.00 | 4.60 |
| 7 | 16.78 | 10.32 | clear / clear | 13.20 | 7.80 | 2 | 0 | 2 | 0.00 | 4.60 |
| 8 | 16.78 | 10.32 | clear / clear | 9.60 | 4.20 | 2 | 0 | 2 | 0.00 | 4.60 |
| 9 | 16.78 | 10.32 | clear / clear | 7.80 | 4.80 | 2 | 0 | 2 | 0.00 | 4.60 |
| 10 | 16.78 | 10.32 | clear / clear | 12.00 | 9.60 | 2 | 0 | 2 | 0.00 | 4.60 |

Across 20 releases (0 empty, at most 3 per 30 s trial), one Kerf deploy averaged **1.00 kills, 0.00 stun body-s and 2.30 HP of damage**.

Both arms cleared 10/10 seeds. Mean paired clear-time difference -6.47 s [-6.47, -6.47]. The on arm cleared faster on 10/10 seeds. Mean Rivet HP lost was 11.40 off and 7.08 on.

Kerf landed a kill with every release. All ten fights needed a second cast at tick 602.

## Ohm

One sentry turret, one shield robot and two SWAT. The cooldown is 8 s, allowing at most 4 releases per 30 s trial.

| Seed | Clear s off | Clear s on | End off / on | HP lost off | HP lost on | Uses | Empty | Deploy kills | Stun body-s | Deploy damage |
|---:|---:|---:|:---|---:|---:|---:|---:|---:|---:|---:|
| 1 | 21.13 | 8.03 | clear / clear | 11.40 | 0.00 | 2 | 0 | 3 | 4.00 | 7.20 |
| 2 | 21.13 | 8.03 | clear / clear | 12.00 | 0.00 | 2 | 0 | 3 | 4.00 | 7.40 |
| 3 | 20.88 | 8.03 | clear / clear | 7.80 | 0.00 | 2 | 0 | 3 | 4.00 | 7.20 |
| 4 | 21.13 | 8.03 | clear / clear | 15.00 | 0.00 | 2 | 0 | 3 | 4.00 | 7.20 |
| 5 | 21.13 | 8.03 | clear / clear | 12.00 | 0.00 | 2 | 0 | 3 | 4.00 | 7.20 |
| 6 | 21.13 | 8.03 | clear / clear | 15.60 | 0.00 | 2 | 0 | 3 | 4.00 | 7.20 |
| 7 | 20.88 | 8.03 | clear / clear | 13.20 | 0.00 | 2 | 0 | 3 | 4.00 | 7.40 |
| 8 | 20.88 | 8.03 | clear / clear | 10.20 | 0.00 | 2 | 0 | 3 | 4.00 | 7.20 |
| 9 | 20.88 | 8.03 | clear / clear | 7.80 | 0.00 | 2 | 0 | 3 | 4.00 | 7.20 |
| 10 | 20.88 | 8.03 | clear / clear | 12.00 | 0.00 | 2 | 0 | 3 | 4.00 | 7.20 |

Across 20 releases (0 empty, at most 4 per 30 s trial), one Ohm deploy averaged **1.50 kills, 2.00 stun body-s and 3.62 HP of damage**.

Both arms cleared 10/10 seeds. Mean paired clear-time difference -12.97 s [-13.07, -12.88]. The on arm cleared faster on 10/10 seeds. Mean Rivet HP lost was 11.70 off and 0.00 on.

Ohm bought the most time in these four encounters. Rivet and the two casts cleared the mixed squad about 13 seconds earlier.

## Tonnage

One war machine. The cooldown is 8 s, allowing at most 4 releases per 30 s trial.

| Seed | Clear s off | Clear s on | End off / on | HP lost off | HP lost on | Uses | Empty | Deploy kills | Stun body-s | Deploy damage |
|---:|---:|---:|:---|---:|---:|---:|---:|---:|---:|---:|
| 1 | 9.50 | 6.48 | clear / clear | 42.65 | 10.30 | 1 | 0 | 0 | 0.00 | 3.00 |
| 2 | 9.48 | 5.73 | clear / clear | 24.76 | 13.71 | 1 | 0 | 0 | 0.00 | 3.00 |
| 3 | 9.48 | 5.73 | clear / clear | 24.04 | 13.34 | 1 | 0 | 0 | 0.00 | 3.00 |
| 4 | 9.48 | 5.73 | clear / clear | 23.34 | 12.99 | 1 | 0 | 0 | 0.00 | 3.00 |
| 5 | 9.77 | 6.23 | clear / clear | 20.25 | 11.24 | 1 | 0 | 0 | 0.00 | 3.00 |
| 6 | 9.75 | 5.98 | clear / clear | 20.61 | 11.58 | 1 | 0 | 0 | 0.00 | 3.00 |
| 7 | 9.48 | 5.98 | clear / clear | 23.36 | 12.99 | 1 | 0 | 0 | 0.00 | 3.00 |
| 8 | 9.48 | 5.73 | clear / clear | 24.40 | 13.71 | 1 | 0 | 0 | 0.00 | 3.00 |
| 9 | 9.50 | 5.98 | clear / clear | 20.25 | 11.23 | 1 | 0 | 0 | 0.00 | 3.00 |
| 10 | 9.73 | 6.02 | clear / clear | 42.00 | 18.00 | 1 | 0 | 0 | 0.00 | 3.00 |

Across 10 releases (0 empty, at most 4 per 30 s trial), one Tonnage deploy averaged **0.00 kills, 0.00 stun body-s and 3.00 HP of damage**.

Both arms cleared 10/10 seeds. Mean paired clear-time difference -3.60 s [-3.77, -3.44]. The on arm cleared faster on 10/10 seeds. Mean Rivet HP lost was 26.57 off and 12.91 on.

Tonnage never landed the killing blow on the war machine. The pistol finished it earlier on all ten seeds.

## Dent

Five patrol cops in a loose line. The cooldown is 8 s, allowing at most 4 releases per 30 s trial.

| Seed | Clear s off | Clear s on | End off / on | HP lost off | HP lost on | Uses | Empty | Deploy kills | Stun body-s | Deploy damage |
|---:|---:|---:|:---|---:|---:|---:|---:|---:|---:|---:|
| 1 | 1.17 | 0.03 | clear / clear | 1.80 | 0.00 | 1 | 0 | 5 | 0.00 | 5.00 |
| 2 | 1.17 | 0.03 | clear / clear | 1.20 | 0.00 | 1 | 0 | 5 | 0.00 | 5.00 |
| 3 | 1.17 | 0.03 | clear / clear | 0.00 | 0.00 | 1 | 0 | 5 | 0.00 | 5.00 |
| 4 | 1.17 | 0.03 | clear / clear | 0.00 | 0.00 | 1 | 0 | 5 | 0.00 | 5.00 |
| 5 | 1.17 | 0.03 | clear / clear | 0.00 | 0.00 | 1 | 0 | 5 | 0.00 | 5.00 |
| 6 | 1.17 | 0.03 | clear / clear | 0.00 | 0.00 | 1 | 0 | 5 | 0.00 | 5.00 |
| 7 | 1.17 | 0.03 | clear / clear | 0.00 | 0.00 | 1 | 0 | 5 | 0.00 | 5.00 |
| 8 | 1.17 | 0.03 | clear / clear | 0.00 | 0.00 | 1 | 0 | 5 | 0.00 | 5.00 |
| 9 | 1.17 | 0.03 | clear / clear | 0.00 | 0.00 | 1 | 0 | 5 | 0.00 | 5.00 |
| 10 | 1.17 | 0.03 | clear / clear | 2.40 | 0.00 | 1 | 0 | 5 | 0.00 | 5.00 |

Across 10 releases (0 empty, at most 4 per 30 s trial), one Dent deploy averaged **5.00 kills, 0.00 stun body-s and 5.00 HP of damage**.

Both arms cleared 10/10 seeds. Mean paired clear-time difference -1.13 s [-1.13, -1.13]. The on arm cleared faster on 10/10 seeds. Mean Rivet HP lost was 0.54 off and 0.00 on.

Dent removed all five cops on the release tick in every trial.
