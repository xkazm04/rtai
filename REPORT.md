# RTAI · Arena guards at the north wall

| Revision | Value |
|---|---|
| Branch | Current bake-off checkout. Run `git branch --show-current` for its blind identifier. |
| Base | 97d8f349818942502ae3927ff8dc9e814ff87399 |
| Final gameplay SHA | a48a797e1651074a1fc21b03d1e9023758b6ce7b |
| Final code and test SHA | f08ae9135ea219611af1bebc54b88de26fca8210 |
| Delivery SHA | `git rev-parse HEAD` after the final journal commit |
| Local time | 17:47 start · 19:53 build verified and report complete |

## What works

**Four guards crossed the street-fight wall.** On base, IDs 3001–3004 spent tick 650 against its north face at y = 530.25 m. With routing, their bodies cleared the south face through the west door on ticks **188, 247, 290 and 316**. The crossing threshold is y = 531.75 m, including the 0.45 m body radius. The blind masters contain **north-wall.mp4** and **north-wall-t450.jpg**. Both show the same camera, seed and tick on each side at 32 px/m. White markers identify the four guards. See `evidence/guard-wall/media.json`, `evidence/guard-wall/street-before.json` and `evidence/guard-wall/street-after.json`.

**Two rifle brains shared the bug.** The claw station creates Fighters. The pistol encounter runs their approach in GuardTell, and the default rifle encounter runs it in GuardBrain. Outside 12 m, they walked directly toward Rivet and collision pushed them back. Inside 12 m, they could hold position with a wall across their line. The shared approach now follows cached bends when blocked, then hands movement and attack range back to the rifle brain. Replayable fixed-target numbers come from `project/tests/integration/test_arena_guard_wall.gd`.

| Fixed target and measurement | Base | With routing |
|---|---:|---:|
| Default rifle guard, crosses the far face with a clear line | Still at spawn after 900 ticks | Tick 205 |
| Telegraphing rifle guard, same setup | Still at spawn after 900 ticks | Tick 205 |
| Open street, both rifle brains, first stationary tick | 162 | 162 |
| Open street, final coordinates and range | (532.048, 524.000) m · 11.952 m | Identical |

The independent EnemyPit motor already walked all five shipped bodies within 0.3 m of the patrol goal behind the same wall. Patrol cop took 361 ticks, riot cop 410, SWAT 339, robot thug 494 and robot gunner 530 on both revisions. No actor crossed a solid segment in the tests. See `project/tests/unit/test_enemy_motor_wall.gd`, `evidence/guard-wall/red.log` and `evidence/guard-wall/green.log`.

**400-guard approach cost, CONTENDED.** Each cold run stepped 400 rifle guards for 360 ticks on the city proving block. The table gives the median of three means, in microseconds per guard per tick. Timing includes the movement decision and excludes stage collision, which still ran after each tick. The direct control used the same build with guard routing disabled. Each run created a fresh map.

| Street | Direct control, µs | Routed, µs | A* searches per 144,000 guard-ticks with routing |
|---|---:|---:|---:|
| Clear | 0.95 | 1.69 | 0 |
| Wall | 0.88 | 1.92 | 3 |

The grid covers the authored arena plus a 4 m border. Paths share a cache keyed by starting cell for the current destination cell, including failed searches. Guard IDs stagger clearance checks over 15 approach ticks. The observed maximum was three searches on any tick. The separate 400-actor city riot uses the city simulation. Its benchmark was excluded by the brief. See `evidence/guard-wall/cost.json`, `project/dev/arena/guard_pursuit_cost.gd` and `project/dev/bench/bench_driver.gd`.

**Determinism.** For the first 650 ticks, the headless street run matched its independently rendered movie on all fighter IDs, positions, HP and alive flags. This covered 17,356 observations before and 17,626 after. Both runs use the existing arena scene with fixed FPS 60 and seed 20261109. The live gunplay bot reacts to combat, so Rivet's later positions differ between revisions. The fixed-target test holds Rivet still. Both sides used the refreshed CitySim DLL. Its SHA-256 and the capture hashes are in `evidence/guard-wall/media.json`.

**Snapshot gate passed on f08ae9135ea2.** `gate: PASS; build/gate/f08ae9135ea2/gate.json`. All 55 scenarios passed, including the city fight and replay. GUT passed 2,948 tests and skipped two. Native and GDScript matched for 1,200 steps, and the planted parity fault was caught at step 629. Both sets of look goldens passed (11/11 and 5/5). Release compile loaded 738 resources with zero failures. All 19 lint checks passed, including debt. The committed copy is `evidence/guard-wall/gate.json`.

The delivery gate uses the final journal commit. From the delivered checkout, read its result with the following command.

```powershell
Get-Content (Join-Path (Join-Path build/gate (git rev-parse --short=12 HEAD)) gate.json)
```

**Mutation score of 62.5%.** Two test files killed 20 of 32 deterministically sampled faults in the route map (105 available). Twelve survived, zero timed out and zero were invalid. Seven survivors changed how an actor starting in a partly occupied cell finds its nearest walkable cell. See `evidence/guard-wall/mutation.json`.

Launch the headless street from either revision with APPDATA set to the checkout's isolated directory. Replace OUT with an absolute output directory. Run the reducer from the delivered checkout against either capture.

```powershell
node tools/dev/run.mjs arena --fixed-fps=60 --quit-after=701 --arena=city --crowd=120 --bot=gunplay --weapon=pistol --reach=6 --seed=20261109 --ppm=32 --silent --film-dir=OUT
node evidence/guard-wall/measure-street.mjs OUT/probe.json
```

## What does not

The 1 m grid conservatively treats tiles touched by a prop as occupied. A walkable gap smaller than the grid may have no route. A stationary unreachable target is held until the situation changes. Outside the arena's mapped area, guards use their ordinary approach.

## What blocked or slowed you

- About 3 minutes, CONTENDED, to refresh 1,261 stale imported assets before the base capture.
- About 2 minutes, CONTENDED, to correct typed fixture construction and packed-array return warnings and rerun the checks.
- About 5 minutes, CONTENDED, to investigate the first 400-guard probe. It found 400 searches on the first tick. The shared cell cache reduced that to three searches across the run.
- About 4 minutes, CONTENDED, to resolve the dev-line ratchet and keep the lane’s sibling-scan setting out of the tooling suite's synthetic Git fixtures.
- About 21 minutes, CONTENDED, for the first gate to expose a stale pre-cop-sight CitySim DLL. The updated native runtime arrived in this checkout during that run. The verification snapshot uses the refreshed copy.
- About 7 minutes, CONTENDED, to isolate the player-bot test and repeat both headless and rendered captures with the refreshed DLL.

## Calls for the owner

The current setting lets a guard resume its weapon's existing stand-off once it has a clear approach. The controlled rifle test and the marked street clip show where the guards stop. `ArenaStage.ROUTE_GUARDS` selects the previous behaviour when false.

## Merge notes

- Replay, parity, bake and look goldens retain their original hashes. Schema and balance table keys are unchanged.
- Accepted 80 dev lines for the repeatable headless cost measurement, from 22,644 to 22,724. See `tools/debt/baseline.json`.
- The city-fight scenario still runs its normal combat, replay, and pit checks with mobile guards. It now tests player close-in with a working and a disabled bot against identical defenders holding cover. Previously the broken bot reached wave six because its opponents approached. See `project/tests/scenarios/scenario_rivet_city_fight.gd`.
- Outside combat and arena, the claw station opts its manually constructed guards into pursuit in `project/features/player/arena_claw_cops.gd`. The decision is in `docs/decisions.md`. Engine still captures are recorded in `steam/ai-provenance/2026-11.jsonl`.

## Next steps

If arenas add narrow doors or partially occupied spawn cells, extend the entry-cell cases identified by mutation testing.
