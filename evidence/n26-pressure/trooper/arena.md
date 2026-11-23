# Rocket arena

Each cell counts damaging impacts / launches over three 30-second trials (seeds 1 through 3). In-window launches are followed through impact. Lead share is 0.8 and launch speed is 13 m/s in every arm.

| Rest (s) | Lead | Range (m) | Standing | Circle | Circle + dash |
|---:|---|---:|---:|---:|---:|
| 1.4 | linear | 10 | 42/42 | 0/42 | 0/42 |
| 1.4 | linear | 14 | 42/42 | 0/42 | 0/42 |
| 1.4 | orbit | 10 | 42/42 | 42/42 | 0/42 |
| 1.4 | orbit | 14 | 42/42 | 42/42 | 0/42 |
| 1.1 | linear | 10 | 48/48 | 0/48 | 0/48 |
| 1.1 | linear | 14 | 48/48 | 0/48 | 0/48 |
| 1.1 | orbit | 10 | 48/48 | 48/48 | 0/48 |
| 1.1 | orbit | 14 | 48/48 | 48/48 | 0/48 |

Both orbit arms advance to the gauntlet. Both linear arms missed the undashed circle at both ranges. The two orbit qualifiers triggered the sweep stop before the 0.9 s and 0.75 s rests.

Rivet circles at 9.3 m/s. At each real tracking-to-lock transition the harness records the line and waits 15 ticks. It then runs the shipped straight dash perpendicular to that line in the direction of travel (4.5 m in 10 ticks, quadratic ease-out, cooldown 40 ticks, zero invulnerability, hold-to-sprint enabled on this branch). Rivet resumes the circle at sprint speed, correcting radius by up to a quarter stride per tick. During probe development a direct radial return after the burst let the rocket hit again. The table measures the requested continuous circling path.

Reproduce an arm with `node tools/dev/run.mjs rocket_arena -- --rest=1.4 --model=orbit --lead=0.8 --out=<absolute-json-path>`. The JSON retains the hits, launches and accepted dashes per seed.
