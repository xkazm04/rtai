# Combat gauntlet loop

## Targets

The targets are the owner’s call. [targets.json](../tools/gauntlet/targets.json) sets the novice, average and expert death waves to 6, 12 and 20. An ordinary average-profile wave aims for 15 seconds. Every fifth wave is a boss wave and aims for 25–30 seconds. The report compares each pair of profiles. The pair is separated when the higher profile’s median is at least three waves deeper and it dies later on at least 75% of shared seeds.

**Score.** Record the wave Rivet dies on. A wave can reach its timer and call another roster into the same fight. A survivor at the 216,000-tick cap or the requested wave limit contributes its last reached wave as a censored lower bound. The report gives the median, spread, counts of deaths and censored runs, and the stopping reason for each seed. Confirmation uses paired death-wave differences and their same-seed null-salt floor. The ledger records both verdicts and identifies the deciding rule.

## A night with runs that end in death

Run the cycle from the lane. The tuner checks out the lane HEAD on a new tune branch in the OS temp directory. The director can keep working in the lane while the batches run. Kept commits stay on the tune branch for the director to merge.

```powershell
$lane = (Get-Location).Path
$tuneTree = Join-Path $env:TEMP 'gtai-n23-tune-1'
$cycleOut = Join-Path $lane 'evidence/n23-loop/cycle-1'
$cycle = @("--worktree=$tuneTree", '--branch=n23-tune-1', "--out=$cycleOut", '--profile=all', '--metric=death')
node tools/gauntlet/night.mjs @cycle --seeds=10 --jobs=1
```

Add `--waves=N` to bound all three batches at wave N. Set `--jobs=2` when the director allocates both slots. Each profile has its own same-seed, different-bot-salt floor, which needs at least six pairs. A death cycle proposes one edit and names the profiles it is intended to help. To keep the edit, at least one intended profile must clear the deciding improvement rule. Every selected profile needs a measurable floor. A paired change away from target or an increase in median distance from target greater than that profile’s floor vetoes the edit, including a move past the target.

To reuse the director’s measured controls, pass the two absolute manifest paths. The before manifest supplies seeds, first seed, pick policy, controls and wave limit. A kept after manifest can supply the next before on a worktree containing the kept tables. A fresh null batch is needed when those table hashes change.

```powershell
$before = Join-Path $lane 'evidence/n23-loop/base-street/batch.json'
$nullBatch = Join-Path $lane 'evidence/n23-loop/base-street-salt1/batch.json'
node tools/gauntlet/night.mjs @cycle "--before=$before" "--null=$nullBatch" --jobs=1
```

For a separately measured after, propose against the same before on the checkout with matching tables. Capture the set arguments as a PowerShell array. Each argument contains one final table value, including each member of a grouped edit.

```powershell
$plan = Join-Path $cycleOut 'plan.json'
$armOut = Join-Path $lane 'evidence/n23-loop/candidate-1'
node tools/gauntlet/tune.mjs propose "--batch=$before" "--out=$plan" --profile=all --metric=death
$sets = @(node tools/gauntlet/tune.mjs sets "--plan=$plan")
node tools/gauntlet/ablate.mjs --name=candidate-1 @sets -- --profile=all --pick=greedy --controls=wheel --seed0=1 --seeds=10 --jobs=1 "--out=$armOut"
node tools/gauntlet/night.mjs @cycle "--before=$before" "--null=$nullBatch" "--after-from=$(Join-Path $armOut 'batch.json')"
```

Match the original seed range, controls, pick, salt and wave limit. The cycle uses that exact plan, checks the predicted table hashes and applies it. If the tune branch already carries its apply receipt, the cycle goes straight to confirmation. An empty output directory also works when the tuner can reproduce the same edit from the before batch. Reports, the change ledger and `night.md` go under the cycle output. Source manifests stay in their original directories.

**Wall time on the merged street.** The serial smoke ran without a wave limit. For seeds 1 and 2, the measured engine wall times were 55.3 and 12.9 s for novice, 462.5 and 50.4 s for average, and 295.3 and 278.9 s for expert. The six runs total **19 min 15 s**. The checkpoint was assembled offline, so its batch wall field is empty. The individual launcher logs record elapsed time on their second line. [Smoke checkpoint](../evidence/n23-loop/street-smoke/completed-at-cutoff/batch.json) · [Per-seed timings](../evidence/n23-loop/street-smoke/logs/)

| Ten seeds × three profiles, one job | Batches to measure | Projected engine wall time |
|---|---:|---:|
| Fresh cycle | Before, null, after | 4 h 49 min |
| Kept after reused as before | Null, after | 3 h 13 min |
| Matching before and null supplied | After | 1 h 36 min |
| All three supplied | 0 | 0 engine minutes |

These projections scale the measured six-run total by five per 30-run batch. On that sample, an eight-hour night fits **one fresh cycle**, or **two cycles** starting with both controls measured and chaining a kept result. The latter schedule uses about 4 h 49 min of engine time. A third chained cycle brings engine time alone to just over eight hours. Allow extra time for imports, reporting and Git hooks. For a different wave limit or two jobs, use the completed manifests’ `speed.wall_s`. The cycle summary prints each measured batch duration and marks reused batches.

## Earlier timing-based night

1. **Measure.** The earlier timing cycle used a dedicated tune branch. Average, greedy, wheel, seeds 1–30 took 12 min 54 s with one Godot job on a contended machine. [Before batch](../evidence/loop/tune2-before/batch.json)
2. **Report.** The night runs `node tools/gauntlet/report.mjs --batch=build/gauntlet/night-2/before/batch.json`. Read the wave medians against 15 s and check how many runs contributed.
3. **Tune.** The night runs `tune.mjs propose` to record numeric steps in `plan.json`, then `tune.mjs apply` to commit each eligible knob on the tune branch.
4. **Confirm.** The night runs `batch.mjs` again with the same seeds, profile, pick policy and controls. This took 12 min 57 s. [Confirm batch](../evidence/loop/tune2-after/batch.json)
5. **Revert.** The night's `tune.mjs confirm --revert` step undoes edits whose improvement failed to clear the A/A floor or lacked enough pairs. The cycle took about 40 min (05:00–05:40), including about 10 min for five apply and five revert commits through the hook. [Ledger](../evidence/loop/tune2-after/tune-ledger.md) · [Lane report](../REPORT.md)
6. **Measure bonus choices.** Run `node tools/gauntlet/batch.mjs --pick=random --profile=all --controls=wheel --seeds=100 --jobs=1 --out=build/gauntlet/night-2/random`, then `node tools/gauntlet/report.mjs --batch=build/gauntlet/night-2/random/batch.json`. Thirty average seeds took 8 min 52 s. Matching by pick wave left 2–8 take/decline pairs for survival and 1–8 for wave time. The A/A floor needs six pairs. [Random batch](../evidence/loop/random-30/batch.json) · [Bonus comparisons](../evidence/loop/random-30/report.md)
7. **Propose.** Give the owner a measured observation and a change to pick. Film a seed that shows the behaviour.
8. **Morning.** Hand over the reports, ledger and films. For an eight-hour night with one job, estimate 40 min for one 30-seed tune cycle and about 30 min per profile for 100 random seeds (90 min for three), leaving time for the films.

## Speed

The director measured the real street with four lanes busy (CONTENDED). Using the final `tick N, segment` in each engine log for simulation time and the manifest's `wall_s` for elapsed time, budget **10.8 s fixed plus 0.028 wall s per simulated second**. That is about 35 simulated seconds per wall second during combat. A 200-sim-second ten-wave run takes about 17 wall seconds, or roughly 210 runs per wall hour with one job. The original expert seed 4 took 17.38 wall seconds for 200 simulated seconds. Long tick-cap runs include idle time. [Street batch and engine logs](../evidence/loop/batch-street-1/batch.json)

The pit measured 13.6 simulated seconds per wall second with about 4 seconds of boot time under contention.

## Test player

The same `GauntletBot` emits packed `TickInput` for a live simulation or recording. Give it a `BotView`, the session's `PlayerActions`, a shipped `BotProfile` and the run seed. It creates a private RNG registry so playing back the recorded input without the bot preserves the world's RNG checkpoints.

| Profile | Reaction ticks | Aim error ±° | Large tells read | Guard lead ticks | Roll chance | Cover reach (m) | Offensive form chance | Rest HP | Retreat HP |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Novice | 30 | 14 | 30% | 5 | 30% | 2 | 25% | 40% | 0% |
| Average | 16 | 7 | 65% | 10 | 60% | 4 | 55% | 75% | 25% |
| Expert | 8 | 3 | 90% | 18 | 95% | 7 | 90% | 95% | 45% |

The brain reads Rivet's position, facing, health, settled form, form selection and availability, roll readiness, held slots and their reach. The adapter supplies wave state, forward movement, nearby cars, solid rectangles, hostiles and incoming enemy rounds. Positions, radii and reach use metres. Each body and round keeps its id while visible. An empty tell means idle. The other tell values are `small`, `large` and `melee`.

A target's score is its archetype weight divided by distance, with an additive bonus during a large windup. Acquiring a new target costs the profile's reaction time. A small incoming round can trigger a held guard when it will intersect Rivet from the front. A large round takes priority. The bot rolls across its path or moves behind reachable solid cover. A nearby heavy or an unavoidable blast can trigger Tonnage. Kerf targets isolated shooters, Ohm targets groups and Dent uses nearby cars. The bot cycles and transforms with the same press edges the player uses.

The pit follows the west-door waypoints. On the street, the bot walks to the next block seam and chases an opponent along the guard map's corners when a prop blocks the approach. After two seconds without positional progress it can take a different corner, sidestep, or back out of a gap. A guard can pass the one-metre kiosk gap. Rivet needs 1.2 m, so a jam can trigger a route with his body clearance. After a clear the bot waits for its profile's rest fraction of current maximum HP. Below the retreat fraction it runs back along the retained street and resumes fighting at the rest threshold. Novice never retreats for repair.

A sentry's facing determines which side gets its armour reduction. The bot circles it in one direction, changing sides at a wall. A shell or completed stomp opens a sprint toward the war machine. On reading a new stomp it tries to leave the damage radius, rolls on a late read, or requests Tonnage when it cannot escape. Small shots can trigger guard while the stance is available. At range it selects the shortest carried gun that reaches and fires it. At close range it can draw a carried melee weapon. Ghost choices use the actual grants, cooldowns and madness budget.

Unlike a human player, the bot knows every living hostile's position, the exact velocity of each incoming round, the stomp clock and the street geometry. It can score an enemy behind a wall. Its reaction delay, missed reads and aim error come from a profile and seeded draws. It makes its card choice immediately. The results measure these three policies under combat pressure.

Bonus ids are opaque. Pass the offered ids to `BotPick.pick(offered, wave)` and supply the catalog indexed by id when constructing the picker. Random mode draws from a separate seeded stream. Greedy mode adds the kind base and its ref preference from `test_player.json`. For example, Tonnage scores 9 (ghost 5 plus 4), damage scores 7 (stat 4 plus 3) and pistol scores 4 (weapon 3 plus 1). Ties keep offer order.

### Street measurement

Seeds 1 through 5 each played once per profile with greedy picks, wheel controls and one job. Depth includes the last wave reached by a stalled run. Wave 5 seconds include completed waves only, with the clear count in parentheses. The merged baseline already granted equipment.

| Street bot | Stalls / 15 | Median wave reached, novice / average / expert | Average wave 5, s | Expert wave 5, s | Wave 5 timeouts / all timeouts |
|---|---:|---|---:|---:|---:|
| Merged baseline | 13 | 4 / 5 / 5 | 47.24 (4) | 37.74 (4) | 0 / 1 |
| Routing and repair | 0 | 5 / 16 / 16 | 54.65 (5) | 39.40 (4) | 2 / 8 |
| Machine tactics and wheel selection | 0 | 10 / 20 / 25 | 33.15 (5) | 35.10 (5) | 0 / 10 |

Average seed 1 advanced from a stall at wave 8 to a wave 22 timeout. All 15 final runs cleared the first war machine. All 14 runs that took a gun fired it, for 15,188 shots in total. Novice seed 5 reached wave 6 without taking a gun. Later waves still reached the 90-second limit, including wave 25 for three experts. [Merged baseline](../evidence/loop/street-merged-before/batch.json) · [Routing and repair](../evidence/loop/street-rest-before-fights/batch.json) · [Final batch](../evidence/loop/street-final/batch.json)

The second five-seed batch reproduced all 15 result files byte for byte. The average seed 1 result was 15,715 bytes with SHA-256 `2df4cd12fd47ed6d45f6f424f2452bba40ff0fdc519002385a563fd17ac732d8`. [Pairwise result digests](../evidence/loop/street-final/determinism.json) · [Independent average seed 1 result](../evidence/loop/repeat-average-1.json)

The machine observer counts ticks while the boss lives. Damage per second divides observed HP loss by that interval. Claw reach, held guard, active roll and cover decisions are independent fractions of the same ticks. On seed 2 the average bot got within claw reach more often. The expert spent much of this seed pursuing a machine wedged beside an alley wall, despite faster median wave clears across all five seeds. [Alley position and damage trace](../evidence/loop/probe-alley-expert-2.json)

| Seed 2, first machine | HP/s | In claw reach | Guard | Rolling | Cover |
|---|---:|---:|---:|---:|---:|
| Average before | 0.72 | 12.65% | 0.46% | 7.47% | 0.10% |
| Average after | 1.94 | 42.60% | 2.58% | 9.47% | 0.65% |
| Expert before | 1.50 | 26.31% | 0.12% | 11.89% | 0.91% |
| Expert after | 0.74 | 17.29% | 0.41% | 4.96% | 0.57% |

The original probes and final per-wave `machine` counters provide the tick counts for these comparisons. [Average before](../evidence/loop/probe-before-average-2.json) · [Expert before](../evidence/loop/probe-before-expert-2.json) · [Average after](../evidence/loop/street-final/runs/average-2.json) · [Expert after](../evidence/loop/street-final/runs/expert-2.json)

The changed-test run selected the full GUT suite and passed 3,509 tests, with two skipped. All 65 scenarios passed. The 60-second replay checked 3,600 ticks and 60 checkpoints and ended at `cbeb734ff9b97c41`.

On changed lines in `bot_brain.gd`, the seven mapped test files caught 18 of 20 valid mutations, up from 11 of 20. The repository's deterministic sampler selected the same 20 of 43 candidates in both runs. The operators and GUT oracle ran on a disposable source archive inside this lane because the standard CLI requires a second Git worktree. [Initial mutations](../evidence/loop/street-final/mutation-initial.json) / [Final mutations](../evidence/loop/street-final/mutation.json)

### Pit measurement

Run from the worktree root in PowerShell. Use a different output name for each seed/profile pair.

```powershell
$env:APPDATA = 'C:/Users/kazda/kiro/gtai-n22/appdata/loop'
$env:GODOT_BIN = 'C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
$outPath = Join-Path (Get-Location) 'build/loop/average-20261103.json'
node tools/dev/run.mjs bot_pit_probe --profile=average --seed=20261103 --ticks=2400 "--out=$outPath" "--result=$outPath"
```

The probe steps the arena's mixed pit waves at 60 Hz. Each wave's clear time runs from its spawn tick to its last kill. Attempts ending in death or at the tick limit retain a null clear time. The run totals include travel and inter-wave gaps. Shots and rolls count simulated discharges and roll starts. Guard ticks count held inputs. Cover ticks count decisions to move into or hold an occluded position. Form ticks count ticks starting in a settled ghost. The SHA-256 digest covers one little-endian 64-bit `TickInput.pack()` word per tick, including repeated inputs.

### Pit reference run

Each profile played seeds 20261103, 20261104 and 20261105 for 2,400 ticks each (40 simulated seconds per seed). The wave counts below follow seed order. Clear seconds are the mean across completed waves. Damage and counters are summed across the three seeds.

| Profile | Waves by seed | Clear (s) | Damage (HP) | Deaths | Guard ticks | Rolls | Cover ticks | Tonnage ticks | Kerf ticks |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Novice | 2 / 2 / 3 | 8.50 | 36.54 | 0 | 0 | 15 | 24 | 426 | 762 |
| Average | 3 / 3 / 3 | 6.98 | 16.02 | 0 | 0 | 24 | 163 | 457 | 660 |
| Expert | 4 / 4 / 4 | 5.84 | 4.14 | 0 | 0 | 23 | 177 | 426 | 1,686 |

Expert cleared the first wave faster and took less damage than novice on each seed with the original profile values. Ohm and Dent recorded zero ticks in these runs. These figures predate the guard action. After the interface merge, the same average seed 20261103 held guard for 142 ticks, started four rolls and fired 59 shots in 2,400 ticks with legacy controls. The probe observes guard inputs. Deflections need a hit-resolution observer.

Two independent average runs on seed 20261103 produced the same 2,058-byte JSON file. Both packed-input streams hashed to `2da4599f7139c68d62be3d1382f761f7fe06cd4cfb1ee44ad7fd3816f6cb8555`. The result file SHA-256 was `ad2a360aa3b1206277f7ee023ea8c2c1733215640f601fac4fa3f8bfa8c85a5a`.

## Batch

Set the two PowerShell environment variables in **Pit measurement** before live runs. From the worktree root, use one Godot job on the shared machine.

```powershell
node tools/gauntlet/batch.mjs --seeds=3 --seed0=20261103 --profile=all --pick=greedy --controls=wheel --waves=10 --out=build/gauntlet/street
node tools/gauntlet/batch.mjs --runner=pit --seeds=3 --profile=all --pick=random --out=build/gauntlet/pit
node tools/gauntlet/batch.mjs --dry-run --seeds=2 --profile=all --pick=greedy
node tools/gauntlet/batch.mjs --from=tools/gauntlet/fixtures --profile=all --pick=random --out=build/gauntlet/fixture-batch
node --test "tools/gauntlet/*.test.mjs"
```

`--seeds` counts consecutive seeds **per profile** from `--seed0` (default 1). The three bot profiles give nine jobs for three seeds. The default launcher is the street scene with legacy controls. Jobs default to one and are capped at two. The dry run prints the exact commands. Live runs write `runs/<profile>-<seed>.json` and per-job logs. The pit takes legacy controls, observes at most 2,400 ticks (40 simulated seconds), and stops at the first death or requested number of cleared waves. It makes no card offers. For the original input digest and detailed attempt logs, use the probe's `--out` option. The batch uses its `--result` option for the street wire format.

Wave seconds in the pit run from spawn to clear or death. A tick-limited attempt retains its status and observed counters and omits its final duration. The pit measures the enemy roster at spawn, damage, actual shots, rolls, held guard and cover decisions, and settled seconds in each ghost form. Hit counts, deflections and killer attribution require other observers. The street starts a cohort on entry to each block. It records completed wave durations, actual discharges, damaging contacts, damage taken and roll starts. A live cohort has a 90-second limit.

`--from` reads the JSON files in a directory or its `runs/` subdirectory without launching Godot. It applies the selected profiles and any explicit seed range or controls filter. With `--profile=all` it also accepts human runs. Supply the original runner, pick policy and wave cap when importing loose files for replay. The wire format carries the seed, profile and controls. Offline Git metadata and table hashes describe the importing checkout.

The committed fixtures are synthetic. Their pistol takers survive two more waves and have six-second shorter later waves in the matched comparison. A deliberately incomplete average run exercises rejection. For a human trajectory the seed reopens the same initial world and replay also needs the original inputs.

`batch.json` records the revision, branch, dirty flag, CLI settings, SHA-256 of each available input table, and the weapon refs used to interpret offers. Its manifest retains every attempted run, including invalid or failed files and their reasons. Live entries carry elapsed wall time, launcher exit and log paths. Raw imported files have no launch timings. A street run that reaches the tick cap alive counts as `capped` when its result is fresh, valid and matches the command. Every timed wave contributes, including on historical batches with the original cap verdict and result file. An untimed final wave contributes only to observed depth. A cap without usable evidence remains excluded. A mixed offline import succeeds and lists rejections. A live failure sets a nonzero exit after every remaining job finishes.

The summary pools measured wave seconds per profile and takes the median. Each run contributes one deepest-wave value. For speed, the batch uses producer ticks at 60 Hz, explicit simulated seconds, or the final street clock in the engine log. These include approaches and rests. A completed set of wave durations is a last fallback for loose results. The manifest sums measured simulation time and calculates throughput when it has a time for every job, including capped runs with a final clock.

### Seeds per night

At the street estimate above, one serial job can play roughly 1,680 runs or 560 complete three-profile seed sets in eight hours if runs average 200 simulated seconds. Deaths, timeouts, loading and machine contention change that figure. Six A/A pairs need at least 12 eligible before observations per knob within matching groups. The first street cycle got only 2 to 4 pairs per knob from ten seeds. At that coverage, budget at least 30 seeds per batch for the sparsest knob and allow 40 for headroom. At the measured 226 s before and 275 s after per ten average seeds, 30 seeds on both sides costs about 25 minutes and 40 costs about 33 minutes with one job. Inspect the ledger for actual counts because later waves can be rarer. [Before batch](../evidence/loop/tune1-before/batch.json) and [After batch](../evidence/loop/tune1-after/batch.json)

The 2,400-tick pit window takes about `4 + 40 / 13.6 = 6.94` wall seconds.

## Report

```powershell
node tools/gauntlet/report.mjs --batch=build/gauntlet/fixture-batch/batch.json --out=build/gauntlet/fixture-batch
node tools/gauntlet/report.mjs --batch=build/gauntlet/street/batch.json --baseline=build/gauntlet/before/batch.json --out=build/gauntlet/comparison
```

The command writes Markdown and a self-contained HTML file with inline SVG timing charts. The default output directory is beside the batch. A baseline adds the earlier median, its measured sample count, and the change to each profile/wave row, including waves seen in only one batch.

- **Wave time.** Each dot is a median. Bars span p25 to p75 and the table also shows the minimum and maximum. The median averages the middle pair for even counts. Quartiles use the repo's sorted rank at `floor(n × q)`. The average profile misses its 15 s target below 12 s or above 18 s. Counts show timed and observed waves separately.
- **Deaths and enemy presence.** Death frequencies include the wave and the attributed killer when available. A weapon identifies its carrier through the batch enemy catalog and, for shared weapons, the death-wave roster when it identifies one carrier. The enemy row retains the weapon and confirmed count. Timeout deaths, verified alive caps and stalls with unusable results have separate counts. A death missing its killer stays unattributed. Enemy time share uses waves with both a duration and a measured roster. A wave counts toward every enemy present, so shares can exceed 100% in total. Compare the median seconds in measured waves containing each enemy with the median in measured waves without it.
- **Offers.** Each card or weapon ref compares runs that took it to runs that received an offer and never took it. Index each run at its first take or, for decliners, first offer. Measure confirmed later waves survived and the median of later measured wave durations. Entering the next wave confirms a clear. Counting the final wave needs a clear status or a post-wave offer and no death. One run has one observation per item and outcome. The two group medians use all eligible observations.
- **Paired differences.** Match takers and decliners within profile, controls and pick wave. Sort each side by seed and select evenly spaced ranks from the larger side without replacement. Bootstrap the median of take-minus-decline differences with the repo's seeded `bootCi` (4,000 samples). The A/A comparison repeats the matching on even versus odd decliner seeds, falling back to all exposed seeds if necessary. Its floor is the larger absolute CI95 endpoint. An interval touching zero or a difference no larger than the floor earns `noise`. The effect interval needs two matched pairs and its A/A floor needs six. A `higher` or `lower` label describes an association in these runs.
- **Combat telemetry.** Deflects, rolls, gun rounds, damaging contacts and form seconds are per-wave medians with independent observation counts. There is no rate because `shots` counts gun rounds while `hits` includes all damage sources and counts a killing wound again. Missing observations display as `not measured`. Measured zeroes contribute normally.
- **Unusual winning runs.** Within each profile's deepest wave, rank up to three runs by the rarity of their ordered card sequence, acquired weapon set and dominant measured ghost form. Each available signature scores `log2(measured runs / runs sharing the signature)` bits. Average its scores, keep positive values and break ties by seed. The report includes the picks and a paste-ready command with the run's controls and batch settings.

## Tune

### Run a night

Use the lane command in [A night with runs that end in death](#a-night-with-runs-that-end-in-death). Add `--dry-run` to prepare the worktree and print the steps and absolute paths. Use a fresh output directory under the lane’s `evidence/n23-loop/`. A preview also accepts `build/n23/`. Omitting `--metric=death` selects the existing mixed-metric proposal. The default batch uses average, greedy, wheel and one job.

| Step | What it writes |
|---|---|
| Measure | `before/runs/` holds each result and `before/logs/` holds the launch and engine logs. `before/batch.json` records accepted runs, caps, failures, timing and table hashes. |
| Measure null | `null/batch.json` measures the same seeds with a different bot salt. |
| Report | `before/report.md` and `before/report.html` summarize the measured batch. |
| Propose | `plan.json` records the misses, skipped reasons, bounded edits and the before-batch hash. The plan names each proposed edit and its target. |
| Apply | One Git commit per eligible knob on the tune branch, with the measured reason and plan identifier. |
| Measure again | The same recipe writes `after/runs/`, `after/logs/` and `after/batch.json` with the tested values. |
| Confirm and revert | `after/tune-ledger.json` and `after/tune-ledger.md` record the paired evidence, seed splits and verdicts. Each rejected or inconclusive applied change gets a revert commit. |
| Compare and summarize | `after/report.md` and `after/report.html` compare timings with the before batch. `night.md` lists each action, knob values, first-night baseline, measured evidence and commit SHAs. |

To undo a kept change, copy its **Apply SHA** from `night.md` and run `git revert <sha>` on the tune branch. If a step fails, the command stops and preserves the earlier evidence and commits. A dry run with the same options prints the individual commands for recovery. To remove a clean worktree after a preview or merge, run `node tools/gauntlet/night.mjs "--worktree=$tuneTree" --branch=n23-tune-1 --remove`. Removal requires the branch tip to be reachable from the current lane HEAD. It removes the worktree, prunes its registration and deletes the branch.

### How a proposal selects edits

**Measurements.** The default timing target is 15 s for `average`. An ordinary-wave median strictly below 12 s or above 18 s is a miss. Boss waves use the interval in the targets file. The standalone `tune.mjs propose` accepts `--target-s`, `--profile` and `--min-n`. A wave needs at least three timed runs by default. A killer share needs at least five recorded deaths. Smaller samples appear in the plan and console as `too few runs`. The other comparisons use all available profiles.

| Measured miss | Candidate edit |
|---|---|
| Wave median above the upper bound | Reduce HP for the robot most often present in timed rosters of that wave. Street timing can also reduce the opening budget or its per-wave growth. The production spawner takes archetype HP for robot bodies. |
| Wave median below the lower bound | Increase the street's `budget.base` when eligible fast waves are confined to the opening half. If any eligible fast wave falls beyond half the deepest timed wave number (rounded up), increase `budget.per_wave`. Both edits give the spawner more budget for enemies and must fit the integer bounds. |
| Median death wave misses the profile target | Increase enemy damage when the median is too deep, or decrease it when deaths occur too early. Try the per-wave budget if the damage group is unavailable. A censored median below target needs enough observed deaths to establish the direction. |
| A named killer accounts for over half of all recorded deaths | Reduce the matching attack damage. For a small ranged attack, victim runs recording deflections can support raising guard capacity. Unknown attributions remain in the denominator. A timeout cannot identify an attacker. Set the fraction with `--killer-share=0.5`. |
| A take-versus-decline difference clears the report's CI and A/A floor | Use the card's recorded weapon ref. A stronger pick gets lower cadence or damage, a weaker pick gets higher cadence or damage. Cards without an eligible knob remain in the miss list. |

Death-wave misses have first choice of knobs. The remaining observations rank wave-time errors relative to the timing target and killer shares relative to their threshold. Offer survival differences are scaled by the decliners' median survival (at least one wave), and offer timing differences by the timing target. The largest eligible misses get up to `--max=6` edits. One card can generate two measured outcomes and one edit.

<a id="numeric-limits"></a>

**Numeric limits.** `tools/gauntlet/knobs.json` lists the table, JSON pointer, kind and bounds of each knob. The catalog covers enemy HP and damage, enemy weapon damage, player weapon damage and firing rate, guard numbers and the street budget, enemy cost overrides and live cap. Every pointer into an array names the stable row ID in `row`. Proposal and apply both check the indexed object's ID. The gun's `rof_hz` is the inverse of its firing interval. An unresolved pointer or changed array-row identity stops proposal and apply. Budget and cost baseline values are expressed in tiers. The tuner reads the table’s units per tier, rounds a step to the nearest table integer and reports a refused step when rounding leaves it unchanged. Mechanics, skills and weapon effects need a separate proposal.

On the first proposal, `tools/gauntlet/baseline.json` records the date, Git SHA and first value of every resolved knob. Later proposals append only newly available IDs. Commit a new baseline or its additions by path before applying. A value must satisfy its catalog bounds and stay within **0.8–1.25×** its current table value and **0.5–2×** its first value. Integer steps round to the nearest integer inside that intersection. For example, an integer budget of 2 has no legal step. A zero baseline stays zero.

**Apply and undo.** Apply checks the working tree and index for changes outside `evidence/` and `build/`. It checks the starting values, byte-identical canonical JSON round trip and table schemas, then commits each knob or named group once. The enemy damage group scales every catalogued enemy weapon damage, splash damage and production damage number, with limits checked for each member. Commit trailers identify the plan, knob and night. A night runs from noon UTC to the next noon, so a run crossing midnight uses one allowance. A second plan on the same branch cannot change that knob again that night, even after a revert. Repeating an interrupted apply recognizes its existing commits.

Confirmation matches the before batch to the plan by SHA-256. It pairs accepted runs, including alive caps, by seed, profile, controls and pick mode. Wave timing needs seconds in both runs. Offer confirmation keeps the same takers, decliners and offer waves across both batches.

With the default `--floor-mode=null-salt`, `night.mjs` immediately repeats the before batch on the same seeds with `--salt=1`. The bot resamples aim, defence, form use and random picks from the same distributions, preserving expected difficulty. Greedy picks keep their fixed ranking and the world keeps its seed. The batch records `args.salt` and forwards nonzero values as `--bot-salt=<n>`. Zero reproduces the original streams.

To measure the floor separately, repeat the before `batch.mjs` command with `--salt=1 --out=null`, then run `node tools/gauntlet/tune.mjs floor --before=before/batch.json --null=null/batch.json --out=floors.md`. Pass the same `--null` to `tune.mjs confirm`. The ledger shows both floors and the mode deciding each change. `--floor-mode=cross-seed` selects the original adjacent-seed comparison within each before group. Each floor uses the larger absolute CI95 endpoint.

Death-wave confirmation compares the mean paired wave difference, oriented toward the target, with the same-seed null-salt floor. Time and offer effects use the mean paired reduction in absolute distance from target. For killer share and historical spread metrics the bootstrap resamples whole pairs and recomputes the aggregate. The default point verdict keeps a gain when it exceeds the floor and the CI95 low exceeds zero. A loss uses the mirrored rule. Select the historical interval-above-floor rule with `--verdict=strict`. Fewer than six A/A pairs or two comparison pairs yields `too few pairs`. With adequate coverage, an inconclusive change yields `noise`. The ledger gives the actual left and right seed lists for each before-batch group. Several edits confirmed by one batch share the same experiment.

`tune-ledger.json` and `tune-ledger.md` appear beside the **after** batch for standalone confirmation. A night writes them under its own `after/` directory, including when it reuses an external after batch. Each row records the old, new and baseline values, original miss, measured outcomes, paired improvement, CI95, A/A floor, verdict and commit SHAs. Plain `confirm` writes verdicts. Add `--revert` to undo committed `reverted`, `noise` and `too few pairs` edits in reverse order. Undo allows its named plan, batches and ledger files alongside the evidence and build directories. Git needs a clean index. An empty apply SHA means the branch has no commit for that edit. A revert SHA identifies an executed undo. To undo one edit manually, use `git revert --no-edit <apply-sha>` on the tune branch.

## Replay and film a run from its seed

Choose a seed from the “Unusual winning runs” table in any report. The result file carries `seed`, `profile` and `controls`. Read the pick policy and any wave cap from the batch. On the same code and tables, replaying those settings gives a byte-identical result. All 15 repeats matched on night 1. [Unusual runs](../evidence/loop/street-final/report.md#unusual-winning-runs) · [Repeat digests](../evidence/loop/street-final/determinism.json)

For average seed 5, replace the output placeholder with an absolute path and run headless from the worktree root.

```powershell
node tools/dev/run.mjs gauntlet --seed=5 --bot=average --pick=greedy --controls=wheel --result=<absolute path>.json
```

Compare the new file with the original using `cmp "<absolute path>.json" "<batch>/runs/average-5.json"`. Exit 0 means every byte matched. [Original seed 5 result](../evidence/loop/street-final/runs/average-5.json)

For the five-wave film, prepare the scratch project described in the manifest's `capture_project` field. Copy `project.godot`, link the resource directories to this worktree with junctions and set the viewport to 1920 × 1080 in the scratch `override.cfg`. Run the recorded `flags` with your AVI, capture project and result paths. [Film manifest](../evidence/loop/film.json)

```powershell
& $env:GODOT_BIN --windowed --position 0,1440 --resolution 1920x1080 --rendering-driver d3d12 --fixed-fps 60 --write-movie "<source.avi>" --path "<capture project>" res://dev/test_player/gauntlet_bot_film.tscn -- --bot=average --pick=greedy --controls=wheel --seed=5 --waves=5 --pick-view "--result=<absolute result.json>"
```

The main scene uses 32 px/m. For 64 px/m, substitute the manifest's `closeup_scene`, `res://dev/test_player/gauntlet_bot_film_closeup.tscn`, and add `--quit-after 2565` before the scene. Encode with FFmpeg libx264, fast preset, CRF 18, yuv420p and AAC at 160 kbit/s. Captions read state after the tick and never feed input. Results with and without captions matched byte for byte on seeds 1 and 5. The complete seed 5 movie also matched its five-wave headless result. [Capture settings and comparisons](../evidence/loop/film.json)

## What the tuner may touch

Only the table numbers in `tools/gauntlet/knobs.json` are eligible. On an `n23-tune*` branch, each knob gets one step per night, within 0.8–1.25× its current value and 0.5–2× its write-once value in `tools/gauntlet/baseline.json`. Code edits and switching on mechanics are outside the tuner's scope. See [Numeric limits](#numeric-limits).

A tune branch has zero net table changes unless a change was kept. Only the owner or Director merges a kept change. The loop never merges the branch.

## What the owner sees in the morning, and what needs their pick

- Start with the lane's [REPORT.md](../REPORT.md) for the findings and open decisions.
- Open `night.md` at the root of the night's output and `after/tune-ledger.md`. For every kept or reverted knob they give the before, after and baseline values, the paired improvement and CI95, the A/A floor, and the apply and any revert commit SHAs. [Night output layout](../tools/gauntlet/night.mjs) · [Night 1 ledger](../evidence/loop/tune2-after/tune-ledger.md)
- Compare `before/report.html` and `after/report.html` for wave times against 15 s, deaths and killers, bonus take versus decline, rolls and time in each form. Read guard and cover use from each run's `guard_ticks` and `cover_ticks`. The reports mark missing guard deflects and list unusual runs to replay. [Before](../evidence/loop/tune2-before/report.html) · [After](../evidence/loop/tune2-after/report.html) · [Seed 5 counters](../evidence/loop/tune2-after/runs/average-5.json)
- Open `frames.json` in `C:\Users\kazda\kiro\gtai-masters\<night>\loop\` for the films and stills. [Night 1 film manifest](../evidence/loop/film.json)

Every proposal for a skill, weapon effect or combo needs the owner's pick. Flag any knob at 0.5× or 2× its baseline. The tuner stops at that bound. Changes to the loop's own rules also need the owner's decision. Night 1 left two calls open.

1. **Noise floor.** Pairing different before seeds (e.g. 1 with 3) gave A/A floors of 12.57–40.95 s. Same-seed repeats were byte-identical. The loop reverted two cuts despite paired improvements towards 15 s. For `war_machine.hp` (60 → 48), wave 20 improved by 13.7 s (CI95 4.75–19.08, 12 pairs). For `shield_robot.hp` (10 → 8), wave 13 improved by 3.7 s (CI95 1.72–6.6, 25 pairs). The recommended null-perturbation floor uses the paired spread from rerunning the same seeds with a neutral change. [Ledger and seed pairs](../evidence/loop/tune2-after/tune-ledger.md)
2. **Opening budget.** Waves 1–4 took 6.1–8.0 s against 15 s. `budget.base` is the integer 2. A 20% step gives no new integer and a rise to 3 is 50%, so the tuner cannot slow the opening waves this way. The owner can choose finer budget units or a one-unit step rule. [Wave times](../evidence/loop/tune2-before/report.md) · [Tune plan](../evidence/loop/tune2-before/plan.json)

## Proposals

Start with an observation in the night's report. Compare wave times with an enemy present and absent, name a frequent killer, check how a cooldown limits time in a form, or count the bonuses left late in a run. Cite the number and file, then describe what the player could do differently. The owner picks proposals. The loop never builds them. Timed parry is a non-goal in the design note.

Night 1's proposals use the original nine accepted runs in the first greedy tune batch. The report at commit `ca4e452ac` gives that sample. The refreshed report includes the tenth run, which reached the tick cap alive. [Lane proposals](../REPORT.md) · [First batch](../evidence/loop/tune1-before/batch.json) · [Refreshed report](../evidence/loop/tune1-before/report.md)

1. **Ohm short-circuit on machines.** Waves with a sentry turret took a median 38.3 s (99 waves), against 10.7 s without one (83 waves). Both street batches list `turret_gun` among the top killers. Let an Ohm pulse stun a sentry turret or shield robot for about 2 s. [First batch](../evidence/loop/tune1-before/batch.json) · [Street deaths](../evidence/loop/street-final/report.md#deaths-by-profile)
2. **Tonnage armour crack.** War-machine waves took 43.8 s against 26.0 s without the machine. The seed 2 probes measured 0.7–1.9 HP/s against it. On many later waves the median time in Tonnage was 7.1 s. Let a Tonnage hit during recovery from a stomp open the machine's armour for a few seconds. [First batch](../evidence/loop/tune1-before/batch.json) · [Seed 2 machine probes](#street-measurement) · [Form times](../evidence/loop/tune1-before/report.md#combat-telemetry)
3. **Kerf blink behind a shield.** Shield-robot waves took 41.2 s against 12.7 s without one, the widest enemy presence gap. End Kerf's blink-slice behind its target so the slice bypasses the shielded front. [First batch](../evidence/loop/tune1-before/batch.json)
4. **Overkill carry.** Late waves put ten or more low-tier humans alongside machines. Patrol cops appeared in 89% of timed wave seconds. The bot spent time finishing crowds and deep runs hit the 90 s timer. Let damage left over from a kill jump to the nearest enemy within 3 m. [Enemy time share](../evidence/loop/tune1-before/report.md#enemy-presence-and-wave-time) · [Seed 5 rosters and timeout](../evidence/loop/tune1-before/runs/average-5.json)
5. **Deeper bonus pool.** A clear gives one pick. By wave 25 the deepest greedy runs in the original sample had taken 24 of the 26 bonuses, leaving too few for a full three-card offer. Add second ranks of existing weapon effects. [Seed 5 picks](../evidence/loop/tune1-before/runs/average-5.json) · [Bonus table](../project/data/tables/gauntlet_bonuses.json)

## Where the test player is unlike a person

- The bot reads the sim directly. It knows enemy positions, tells and projectile paths. A person can misread a tell or lose sight of an enemy.
- It has no fatigue or tunnel vision. It gives wave 20 the same attention as wave 1.
- It has fixed habits. Greedy picks follow one value table. Tonnage's 20 s cooldown often leaves time for one cast in a wave. Longer waves can fit two (14.2 s in Tonnage on seed 5, wave 15). It never uses Dent because the street has no cars. [Seed 5 form times](../evidence/loop/tune1-before/runs/average-5.json) · [Cooldowns](../project/data/tables/powers.json)
- It knows the street geometry. It follows a route without pausing to look around or turning back out of curiosity.
- It rests and retreats to repair where a person might press. Most deep runs end at the 90 s wave timer. Cutting HP to help this bot may make the wave too easy for an aggressive player. [First street cycle](../evidence/loop/tune1-before/report.md#timeouts)

A change kept for this bot is a hypothesis about human play. Check it in a playtest.

## Known gaps after night 1

- **NEED street.** The street result omits `guard_deflects`. It records how long the bot held guard. A count of deflected shots needs a street observer. [Street result](../evidence/loop/tune2-after/runs/average-5.json)
- `hits` counts every damaging contact, including claws and blasts, and counts a killing wound again. `shots` counts gun rounds. These counters cannot give a hit rate. [Combat telemetry](../evidence/loop/tune2-after/report.md#combat-telemetry)
- Eight of the 30 confirm runs were still alive at 72,000 ticks. The cap censors “wave reached”. Their timed waves count and their recorded depth is a lower bound on how far they could go. [Confirm report](../evidence/loop/tune2-after/report.md)
- Mutation tests caught 18/20 faults. Flipping the view flag at `project/features/gauntlet/bot/gauntlet_bot.gd:29` and removing the street stats hook at `project/features/gauntlet/bot/gauntlet_bot.gd:34` both survived. No mapped test checks that the bot's roll, cover and form counters reach the street result. [Lane mutation record](../REPORT.md)
