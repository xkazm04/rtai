# Combat gauntlet loop

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
- **Combat telemetry.** Deflects, rolls, shots and form seconds are per-wave medians with a count of measured observations. Hit rate is total hits divided by total shots from rows measuring both. Missing observations and undefined rates display as `not measured`. Measured zeroes contribute normally.
- **Unusual winning runs.** Within each profile's deepest wave, rank up to three runs by the rarity of their ordered card sequence, acquired weapon set and dominant measured ghost form. Each available signature scores `log2(measured runs / runs sharing the signature)` bits. Average its scores, keep positive values and break ties by seed. The report includes the picks and a paste-ready command with the run's controls and batch settings.

## Tune

Run `propose` anywhere in the checkout. Run `apply` and `confirm --revert` on the dedicated branch whose name starts with `n22-tune`. Keep one output directory per batch. The before batch and the plan can travel together to the tune checkout.

```powershell
node tools/gauntlet/tune.mjs propose --batch=build/gauntlet/before/batch.json --out=build/gauntlet/before/plan.json
node tools/gauntlet/tune.mjs apply --plan=build/gauntlet/before/plan.json
# Run the same batch recipe, seeds, profiles, controls and pick mode into build/gauntlet/after.
node tools/gauntlet/tune.mjs confirm --before=build/gauntlet/before/batch.json --after=build/gauntlet/after/batch.json --plan=build/gauntlet/before/plan.json
```

**Measurements.** The default timing target is 15 s for `average`. A median strictly below 12 s or above 18 s is a miss. Set `--target-s` and `--profile` to change that timing comparison. The other comparisons use all available profiles. The plan records every miss, its measurements and either the selected edit or the reason it was skipped.

| Measured miss | Candidate edit |
|---|---|
| Wave time outside the band | Scale HP for the robot most often present in timed rosters of that wave. Street timing can also adjust the opening budget or its per-wave growth. The production spawner takes archetype HP for robot bodies. The timing measures the whole wave. |
| Expert median depth at or below novice depth | Aim for a gap of at least one wave. Ease pressure if both profiles recorded deaths, otherwise increase it. Try the budget or a robot observed in the final wave. |
| A named killer accounts for over half of all recorded deaths | Reduce the matching attack damage. For a small ranged attack, victim runs recording deflections can support raising guard capacity. Unknown attributions remain in the denominator. A timeout cannot identify an attacker. Set the fraction with `--killer-share=0.5`. |
| A take-versus-decline difference clears the report's CI and A/A floor | Use the card's recorded weapon ref. A stronger pick gets lower cadence or damage, a weaker pick gets higher cadence or damage. Cards without an eligible knob remain in the miss list. |

The plan ranks wave-time errors relative to the timing target, killer shares relative to their threshold and profile gaps relative to one wave. Offer survival differences are scaled by the decliners' median survival (at least one wave), and offer timing differences by the timing target. The largest eligible misses get up to `--max=6` edits. One card can generate two measured outcomes and one edit.

**Numeric limits.** `tools/gauntlet/knobs.json` lists the table, JSON pointer, kind and bounds of each knob. It covers enemy HP and damage, enemy weapon damage, player weapon damage and firing rate, guard numbers and the two wave-budget integers. The gun's `rof_hz` is the inverse of its firing interval. An unresolved pointer, changed array-row identity or pending knob is reported and skipped. Mechanics, skills and weapon effects need a separate proposal.

On the first proposal, `tools/gauntlet/baseline.json` records the date, Git SHA and first value of every resolved knob. Later proposals append only newly available IDs. Commit a new baseline or its additions by path before applying. A value must satisfy its catalog bounds and stay within **0.8–1.25×** its current table value and **0.5–2×** its first value. Integer steps round in the proposed direction within that intersection. For example, an integer budget of 2 has no legal step. A zero baseline stays zero.

**Apply and undo.** Apply checks the working tree and index for changes outside `evidence/` and `build/`. It checks the starting values, byte-identical canonical JSON round trip and table schemas, then commits one numeric edit per commit. Commit trailers identify the plan, knob and night. A night runs from noon UTC to the next noon, so a run crossing midnight uses one allowance. A second plan on the same branch cannot change that knob again that night, even after a revert. Repeating an interrupted apply recognizes its existing commits.

Confirmation matches the before batch to the plan by SHA-256. It pairs accepted runs, including alive caps, by seed, profile, controls and pick mode. Wave timing needs seconds in both runs. Offer confirmation keeps the same takers, decliners and offer waves across both batches. For each change, the A/A floor comes from pairing adjacent seed ranks within the before-batch groups and taking the larger absolute endpoint of their CI95.

For time and offer effects, the confirming number is the median paired reduction in absolute distance from target. Its CI95 uses the repo's 4,000-resample paired bootstrap. For killer share and profile spread, 2,000 seeded bootstrap draws resample whole before/after pairs and recompute the proportions or profile medians. Improvement is positive. Both the aggregate change and the entire interval must clear the A/A floor in the same direction for `kept` or `reverted`. Fewer than six A/A pairs or two comparison pairs yields `too few pairs`. With adequate coverage, an interval that fails to clear the floor yields `noise`. The ledger gives the actual left and right seed lists for each before-batch group. Several edits confirmed by one batch share the same experiment.

`tune-ledger.json` and `tune-ledger.md` appear beside the **after** batch. Each row records the old, new and baseline values, original miss, measured outcomes, paired improvement, CI95, A/A floor, verdict and commit SHAs. Plain `confirm` writes verdicts. Add `--revert` to undo committed `reverted`, `noise` and `too few pairs` edits in reverse order. Undo allows its named plan, batches and ledger files alongside the evidence and build directories. Git needs a clean index. An empty apply SHA means the branch has no commit for that edit. A revert SHA identifies an executed undo. To undo one edit manually, use `git revert --no-edit <apply-sha>` on the tune branch.

## Proposals (TODO)
