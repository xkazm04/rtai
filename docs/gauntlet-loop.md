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

The pit adapter follows the west-door waypoints from the hub. Between waves, the street adapter should supply its own forward direction. The pit exposes all four ghost forms through the arena's normal lock state. A street adapter should expose only the forms unlocked and usable on that tick. Missing round size defaults to small. Guard is available when its action bit exists.

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

## Batch (TODO)

## Report (TODO)

## Tune (TODO)

## Proposals (TODO)
