# Three pedestrian shock reactions

| Submission | Value |
|---|---|
| Branch | Current branch, resolvable with `git branch --show-current` |
| Starting revision | 97d8f3498189 |
| Final gameplay SHA | 0ecb743fb630 |
| Final submission SHA | Resolve `git rev-parse HEAD` in the delivered checkout |
| Start | 2026-11-18, 17:40 Prague |
| Done (evidence and report sealed) | 2026-11-18, 19:50 Prague |

The starting revision already contains a shock drawing for each of these three looks. The defect was visible after impact. Stunned pedestrians repeatedly returned to walking art, then remained in the shock pose after recovery. This change holds the arched figure, uses its own fall sheet for the knee catch and restores its walk.

## What works

| Result | Measurement | Evidence |
|---|---|---|
| Hat, elder and shopper stay rigid through a sustained electro hit | Each showed its own shock strip for 90 of the first 90 ticks after impact. Each showed it for 46 on the starting build. The worker reference showed 46 in both runs. | `evidence/shock-capture.json` |
| The current releases into a knee catch | Impact at tick 30. The hands brace at 123, the knees land at 128 and each walker regains its standing sprite at 140. The hat stays on. The cane and bag land beside their owners. | `evidence/ped-shock-frames.json` |
| Feet and props stay on the street | At 32 px/m the largest measured card offsets during the first 90 ticks were 9.73 px for hat, 12.33 for elder and 9.89 for shopper. The starting build reached 35.08, 35.39 and 34.57 px. During the knee catch all three anchors sit on their rig points to the 0.01 px recording precision. | `evidence/shock-capture.json` |
| Same-camera before and after | Four figures at 32 and 64 px/m. The pre-impact frames match pixel for pixel at both sizes. Four still sheets and a 4.30-second, 30 fps clip include a finished worker. | `evidence/ped-shock-frames.json`, `evidence/shock-capture.json` |
| Shock, jab and heavy resolve separately | All three looks select their own weapon-class strips. Two tests failed on the starting build with 12 failed assertions. Eight tests now cover full-rig routing, parts-only poses, release timing, direction, scale, the baton and a rig entering an existing stun. | `evidence/shock-red.txt`, `evidence/shock-green.txt` |
| City combat routes the wound | A shopper on screen took an uncharged electro round at tick 330, stayed alive at 0.4 HP through tick 412 and died to a second shot at 413. The four-person film uses the same fight-area and reaction routing. | `evidence/shock-capture.json`, `evidence/ped_shock_board.gd` |
| Human reaction scenario | Two deterministic runs produced digest 1400046892. The standalone stun cleared in 72 ticks. | `evidence/shock-capture.json` |
| Mutation test | 42 of 44 valid, completed mutations killed (95.5%). All 44 candidates ran. 2 survived, 0 were invalid and 0 timed out. | `evidence/shock-mutation.json` |
| Snapshot gate | Six evidence kinds passed, including 2948 unit and integration tests, 55 scenarios, 1,200 native parity steps, 16 golden frames and 737 release script loads. | `evidence/shock-gate.json` |

Gameplay gate verdict, with its path relative to this checkout.

> gate: PASS; build/gate/0ecb743fb630/gate.json

The final report and journal commits contain only evidence and prose. The submitting checkout also runs `node tools/gate/run.mjs --rev=HEAD` on its final commit. Its result is in the directory named for the first 12 characters of that commit under `build/gate/`.

**Rig cost, CONTENDED.** Eight rounds at each crowd size, 600 ticks per launch with 60 warm-up ticks. Each round has one changed run and two identical base runs. The paired delta is the changed run minus the mean of its two controls. The last column shows median absolute variation between those controls. The initial eight-pair study and all final measurements are in `evidence/shock-rig-pairs.json`.

| People | Percentile | Final median, ms CONTENDED | Median paired delta, ms CONTENDED | Base/base variation, ms CONTENDED |
|---:|---|---:|---:|---:|
| 50 | p50 | 0.884 | -0.030 | 0.051 |
| 50 | p99 | 5.754 | -0.410 | 1.857 |
| 200 | p50 | 0.870 | -0.046 | 0.020 |
| 200 | p99 | 5.801 | +0.879 | 1.559 |

Median cost fell at both sizes in all eight rounds. At 200 people the paired tail increase falls inside the variation between identical base runs. Pool growth was zero throughout.

## What does not

- The distant crowd maps all six pedestrian looks to the same HIT clip. At that distance the atlas cannot distinguish shock, jab and heavy. See `project/features/characters/crowd_atlas.gd`.
- Every base and final rig-bench run exceeded the 1 ms p99 hard limit CONTENDED. The 200-person tail cost remains unresolved. The snapshot gate also left its rig-stress budget unjudged after five minutes CONTENDED with eight other active runs.
- Two mutations survived, one in the parts-only arm reach between poses and one in the placed card's skew. The full suite also lists two pre-existing card and halo tests as pending. All eight new shock tests ran.
- Both standalone captures exited successfully with zero script errors. Godot reported 56 ObjectDB instances at process shutdown. See `evidence/shock-capture.json`.

## What blocked or slowed you

- About 2 minutes CONTENDED for the first asset import. Revision 75dc0cc96 had already added the three impact drawings after the report cited in the brief. The baseline replay located the dropped pose during the stun and the stale pose after recovery.
- About 4 minutes CONTENDED to move the capture fixture into the evidence directory and keep the benchmark worktree isolated during pre-commit checks.
- About 8 minutes CONTENDED for the first paired rig measurement. The 200-person median was higher in all eight initial pairs. The follow-up moves the lookup out of unwounded walking and repeats the measurements with an identical-base control.
- About 12 minutes CONTENDED to populate the detached code-gate checkout.
- About 17 minutes CONTENDED in the initial gate before its 11 native-binding failures were diagnosed. The lane debug DLL was refreshed after that snapshot was made. A fallback build stopped before linking when the new binary was found. All 27 tests in the affected files passed against the newer DLL. The retry copied and verified the refreshed binary. `evidence/shock-runtime.json` records the hashes and failures.

## Calls for the owner

The hat, elder and shopper briefly land on hands and knees after the current releases. The worker shows the original shorter hit in every comparison sheet. The fall and hold times are four named constants in `project/features/characters/street_ped_shock.gd`. Its ENABLED constant selects the sequence.

## Merge notes

The production changes affect character drawing and wound presentation. The gate uses the refreshed, ignored debug CitySim library already present in the lane. Clearing a finished reaction also clears the last blow class in `project/features/combat/react/human_react.gd`. This fixes the latched post-recovery frame for jab and heavy as well as shock. The 11 look goldens and five block goldens all matched without a re-bless. The source art, data schemas, native sim and debt baseline are unchanged. The comparison fixture, its evidence, the regression suite, the journal and the shared decision log are the supporting changes.

## Next steps

Review the clip and the native 32 px/m sheet in the assigned masters directory. An idle-machine repeat would resolve the 200-person p99 comparison.
