# Combat gauntlet loop

## Speed

The shared-machine pit measurement was **13.6 simulated seconds per wall second per Godot**, CONTENDED, with about **4 seconds of boot time**. Use this as a pit planning estimate. Record contention, tick budget and boot time separately when measuring the seeded street.

## Test player

The same `GauntletBot` emits packed `TickInput` for a live simulation or recording. Give it a `BotView`, the session's `PlayerActions`, a shipped `BotProfile` and the run seed. It creates a private RNG registry so playing back the recorded input without the bot preserves the world's RNG checkpoints.

| Profile | Reaction ticks | Aim error ±° | Large tells read | Guard lead ticks | Roll chance | Cover reach (m) | Offensive form chance |
|---|---:|---:|---:|---:|---:|---:|---:|
| Novice | 30 | 14 | 30% | 5 | 30% | 2 | 25% |
| Average | 16 | 7 | 65% | 10 | 60% | 4 | 55% |
| Expert | 8 | 3 | 90% | 18 | 95% | 7 | 90% |

The brain reads Rivet's position, facing, health, settled form, form selection and availability, roll readiness, held slots and their reach. The adapter supplies wave state, forward movement, nearby cars, solid rectangles, hostiles and incoming enemy rounds. Positions, radii and reach use metres. Each body and round keeps its id while visible. An empty tell means idle. The other tell values are `small`, `large` and `melee`.

A target's score is its archetype weight divided by distance, with an additive bonus during a large windup. Acquiring a new target costs the profile's reaction time. A small incoming round can trigger a held guard when it will intersect Rivet from the front. A large round takes priority. The bot rolls across its path or moves behind reachable solid cover. A nearby heavy or an unavoidable blast can trigger Tonnage. Kerf targets isolated shooters, Ohm targets groups and Dent uses nearby cars. The bot cycles and transforms with the same press edges the player uses.

The pit adapter follows the west-door waypoints from the hub and reads the pit's standing wave members. The street pilot `GauntletTestPlayer` binds the same view to the session's hostile roster and advances east between fights. Both read the current ghost locks, cooldowns and madness budget each tick. The adapter reads round size from `Shot.size`. Guard input is available when its action bit exists.

Bonus ids are opaque. Pass the offered ids to `BotPick.pick(offered, wave)` and supply the catalog indexed by id when constructing the picker. Random mode draws from a separate seeded stream. Greedy mode adds the kind base and its ref preference from `test_player.json`. For example, Tonnage scores 9 (ghost 5 plus 4), damage scores 7 (stat 4 plus 3) and pistol scores 4 (weapon 3 plus 1). Ties keep offer order.

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

Wave seconds in the pit run from spawn to clear or death. A tick-limited attempt retains its status and observed counters and omits its final duration. The pit measures the enemy roster at spawn, damage, actual shots, rolls, held guard and cover decisions, and settled seconds in each ghost form. Hit counts, deflections and killer attribution require other observers. The current street interface binds the pilot, writes a wave-zero result and exits before the first step.

`--from` reads the JSON files in a directory or its `runs/` subdirectory without launching Godot. It applies the selected profiles and any explicit seed range or controls filter. With `--profile=all` it also accepts human runs. Supply the original runner, pick policy and wave cap when importing loose files for replay. The wire format carries the seed, profile and controls. Offline Git metadata and table hashes describe the importing checkout.

The committed fixtures are synthetic. Their pistol takers survive two more waves and have six-second shorter later waves in the matched comparison. A deliberately incomplete average run exercises rejection. For a human trajectory the seed reopens the same initial world and replay also needs the original inputs.

`batch.json` records the revision, branch, dirty flag, CLI settings, SHA-256 of each available input table, and the weapon refs used to interpret offers. Its manifest retains every attempted run, including invalid or failed files and their reasons. Live entries carry elapsed wall time, launcher exit and log paths. Raw imported files have no launch timings. Only valid results feed the report. A mixed offline import succeeds and lists rejections. A live failure sets a nonzero exit after every remaining job finishes.

The summary pools measured wave seconds per profile and takes the median. Each run contributes one deepest-wave value. For speed, the pit records the full run's simulated time including travel. When a producer supplies only wave durations, a complete set of reached-wave durations gives observed combat seconds. The batch sums available run times. Live wall time covers the whole batch including boot and failures. The ratio needs a timed result for every job and a measured wall interval.

### Seeds per night

At the measured 13.6 simulated seconds per wall second, a run lasting `W` waves of 15 s takes about `4 + 15 × W / 13.6` wall seconds including boot. With one serial job, an eight-hour night gives the following planning ceilings. Divide available wall seconds by three run times for complete three-profile seed sets.

| Target waves per run | Wall s per run | Single-profile runs in 8 h | Seeds run on all three profiles in 8 h |
|---:|---:|---:|---:|
| 5 | 9.51 | 3,026 | 1,008 |
| 10 | 15.03 | 1,916 | 638 |
| 20 | 26.06 | 1,105 | 368 |

The 2,400-tick pit window takes an estimated `4 + 40 / 13.6 = 6.94` wall seconds per full run. At the ten-wave target, one hour buys about 239 single-profile runs or 79 complete seed sets. These are extrapolations from the pit measurement. Street travel, imports, launcher checks, contention and early deaths change observed throughput.

## Report

```powershell
node tools/gauntlet/report.mjs --batch=build/gauntlet/fixture-batch/batch.json --out=build/gauntlet/fixture-batch
node tools/gauntlet/report.mjs --batch=build/gauntlet/street/batch.json --baseline=build/gauntlet/before/batch.json --out=build/gauntlet/comparison
```

The command writes Markdown and a self-contained HTML file with inline SVG timing charts. The default output directory is beside the batch. A baseline adds the earlier median, its measured sample count, and the change to each profile/wave row, including waves seen in only one batch.

- **Wave time.** Each dot is a median. Bars span p25 to p75 and the table also shows the minimum and maximum. The median averages the middle pair for even counts. Quartiles use the repo's sorted rank at `floor(n × q)`. The average profile misses its 15 s target below 12 s or above 18 s. Counts show timed and observed waves separately.
- **Deaths and enemy presence.** Death frequencies include the wave and the attributed killer when available. Unknown killers have their own count. Enemy time share uses waves with both a duration and a measured roster. A wave counts toward every enemy present, so shares can exceed 100% in total. Compare the median seconds in measured waves containing each enemy with the median in measured waves without it.
- **Offers.** Each card or weapon ref compares runs that took it to runs that received an offer and never took it. Index each run at its first take or, for decliners, first offer. Measure confirmed later waves survived and the median of later measured wave durations. Entering the next wave confirms a clear. Counting the final wave needs a clear status or a post-wave offer and no death. One run has one observation per item and outcome. The two group medians use all eligible observations.
- **Paired differences.** Match takers and decliners within profile, controls and pick wave. Sort each side by seed and select evenly spaced ranks from the larger side without replacement. Bootstrap the median of take-minus-decline differences with the repo's seeded `bootCi` (4,000 samples). The A/A comparison repeats the matching on even versus odd decliner seeds, falling back to all exposed seeds if necessary. Its floor is the larger absolute CI95 endpoint. An interval touching zero or a difference no larger than the floor earns `noise`. Each interval needs at least two matched pairs. A `higher` or `lower` label describes an association in these runs.
- **Combat telemetry.** Deflects, rolls, shots and form seconds are per-wave medians with a count of measured observations. Hit rate is total hits divided by total shots from rows measuring both. Missing observations and undefined rates display as `not measured`. Measured zeroes contribute normally.
- **Unusual winning runs.** Within each profile's deepest wave, rank up to three runs by the rarity of their ordered card sequence, acquired weapon set and dominant measured ghost form. Each available signature scores `log2(measured runs / runs sharing the signature)` bits. Average its scores, keep positive values and break ties by seed. The report includes the picks and a paste-ready command with the run's controls and batch settings.

## Tune (TODO)

## Proposals (TODO)
