# Rocket trooper on the street

Both orbit candidates failed the early-death requirement. Each killed novice seed 4 on wave 5 at tick 3778. The serialized run result was byte-identical at both rests. The 1.1 s expert batch stopped on that finding after one completed seed. The 1.4 s expert batch was unnecessary once the same lethal result recurred.

| Rest (s) and lead | Profile | Wave cap | Hits/troopers | Pooled rate | Mean wave rate | Rocket deaths before 6 | All killers before 6 | Median death wave (deaths only) | Alive at cap |
|---|---|---:|---:|---:|---:|---:|---|---:|---:|
| 1.4 linear | average | 12 | 20/90 | 0.222 | 0.217 | 0/10 | stomp 3 | 9 | 0 |
| 1.1 orbit | average | 12 | 17/83 | 0.205 | 0.217 | 0/10 | stomp 4 | 7 | 0 |
| 1.1 orbit | novice | 6 | 15/44 | 0.341 | 0.332 | 1/10 | riot_cop 1, rocket 1, stomp 8 | 5 | 0 |
| 1.1 orbit | expert (partial) | 6 | 4/8 | 0.500 | 0.583 | 0/1 | none | unreached | 1 |
| 1.4 orbit | average | 12 | 11/78 | 0.141 | 0.136 | 0/10 | stomp 4 | 7 | 0 |
| 1.4 orbit | novice | 6 | 16/44 | 0.364 | 0.400 | 1/10 | riot_cop 2, rocket 1, stomp 7 | 5 | 0 |
| 1.1 orbit | all observed | 6 / 12 | 36/135 | 0.267 | 0.272 | 1/21 | riot_cop 1, rocket 1, stomp 12 | 5 | 1 |
| 1.4 orbit | all observed | 6 / 12 | 27/122 | 0.221 | 0.233 | 1/20 | riot_cop 2, rocket 1, stomp 11 | 5 | 0 |

Greedy picks, wheel controls, salt 0, seeds 1 through 10, one process at a time. Each average arm could reach wave 12. Safety batches used wave 6. The 1.1 s arm came closer to the target of 0.5 hits per trooper in the average gauntlet at 17/83 (0.205). The 1.4 s arm recorded 11/78 (0.141), versus 20/90 (0.222) with shipped linear lead. Neither qualifying arena arm can achieve 0/30 early rocket deaths on these seeds.

A hit is a rocket impact that reduced Rivet's HP. The dev probe matches the damage signal to the round, then attributes it to the shooter's spawn wave, including late impacts and delayed spawns. Every logged trooper count was checked against that wave's result roster. Run serialization is unchanged. The JSON includes the original result SHA-256 for each seed.

The pooled rate divides total hits by total spawned troopers. The mean wave rate gives equal weight to every wave containing a trooper. Both include zero-hit waves. The all-observed rows pool the measured profiles at their respective wave limits. Survivors at the wave cap are censored and excluded from the death-only median.

Reproduce each arm with the listed rocket data and `node tools/gauntlet/batch.mjs --profile=<profile> --pick=greedy --controls=wheel --waves=<cap> --seeds=10 --jobs=1 --out=<directory>`. Each separate engine log contains one `rocket-probe` line per wave.


## Verification

The control configuration and the opt-in orbit model are committed at `82dbc7258`. The shipped linear control retains its original lock and sprint-distance tests. At 10 m over 30 seconds the orbit fixture requires at least 12 circling hits, 13 to 14 launches, every standing launch landing, zero dash hits, and an accepted dash 15 ticks after each lock. The signed-bearing test crosses the angle seam and checks changing range.

| Check | Result |
|---|---|
| Changed unit suite | 3,988 passed, 0 failed, 2 pending |
| Full unit and integration suite | 4,004 passed, 0 failed, 2 pending ghost-card tests |
| Full scenario suite | 68 passed, 0 failed, exit 0 |
| Quick gate and pre-commit lint | 7 changed scripts passed, all 19 lint checks passed |
| Mutation of all 25 lines in the new lead helper | 13 killed / (13 killed + 1 survived), 92.9%, zero timeouts or invalid mutants |

The Quest 1 tape checks and all three prologue scenarios passed. The prologue pilot finished in 9,835 ticks with zero deaths. The 60-second replay kept the pinned hash beginning `cbeb734ff9b97c41`. No golden or tape was edited. After the scenario summary, Godot logged shutdown cleanup errors about resources still in use and allocator pages.

The sole surviving fault inverted the table-error logging condition in `RocketLead.shipped_orbit()`. All arithmetic mutations of the orbit prediction were killed. The mutation runner used its worktree-local `--scratch` mode. Its later HEAD differs from the implementation commit only in director notes and briefs.
