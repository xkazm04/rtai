# Squad AI cost on the proving block

## Why the contractor pit slowed

A2 cleared the pit in 17.67 s. With A3 behavior, two shooter slots and unlimited searches, the same five seeds took 22.33 s. Changing only the pit’s max_shooters from two back to three reduced that to 17.92 s. Restoring all A2 planning rules reproduced both A2 means. All temporary controls were removed. The game retains the A3 rows and two shooting tokens.

The handover’s contractor fixture reported 21.85 s in the pit and 21.17 s in the city. Its fixture selected the composition outside the game selector. Repeating the original scheduler through the game entry point gave 23.18 s and 23.14 s respectively.

### Unlimited searches

| Encounter | A1 clear s | Clear s | Change | A1 HP lost | HP lost | Change | Deaths |
|---|---:|---:|---:|---:|---:|---:|---:|
| city | 17.58 | 22.98 | +30.7% | 3.60 | 2.04 | -43.3% | 0 |
| pit | 14.53 | 22.33 | +53.7% | 7.32 | 7.56 | +3.3% | 0 |
| quest1 | 35.36 | 35.36 | +0.0% | 4.68 | 4.68 | +0.0% | 0 |

The unlimited run raised both per-tick ceilings by 100,000 in a temporary working copy. The table uses the final movement code. Against the earlier unlimited diagnostic, all pit and quest digests and three city digests matched. The city mean changed by 0.09 s.

### Production search budget

| Encounter | A1 clear s | Clear s | Change | A1 HP lost | HP lost | Change | Deaths |
|---|---:|---:|---:|---:|---:|---:|---:|
| city | 17.58 | 23.08 | +31.3% | 3.60 | 1.92 | -46.7% | 0 |
| pit | 14.53 | 21.34 | +46.8% | 7.32 | 6.12 | -16.4% | 0 |
| quest1 | 35.36 | 35.36 | +0.0% | 4.68 | 4.68 | +0.0% | 0 |

City and pit clear changes with the final budget differ from unlimited by +0.6 and -6.9 percentage points of A1. The original queue cost the pit 5.8 points. Lifting only the route cap left the pit at 23.18 s. Lifting only the cover cap gave 22.33 s. A delayed cover planner now retains its granted phase, so the same guards cease colliding every twelve ticks. It keeps the previous motion while waiting. A queued route follows cached bends or steers toward its destination.

Relative to A1, contractor city and pit are still 31.3% and 46.8% longer. With the full mixed roster, those changes are +41.4% and +41.9%. Both exceed the 25% reporting threshold.

### Controlled changes

Each row retains the preceding changes. The first control lifts both search ceilings. All other options, the bot and seeds stay fixed. Field effects depend on the shooter count and the preceding changes.

| Cumulative temporary change | City clear s | Pit clear s |
|---|---|---|
| A3, unlimited | 23.07 | 22.33 |
| Restore max_shooters 3 | 19.39 | 17.92 |
| Always try cover (cover_bias 0.65 to 1) | 20.62 | 17.42 |
| Use preferred_m ring (remove aggression 0.7 blend) | 20.27 | 17.42 |
| Allow six seconds blind (remove aggression shortening) | 21.07 | 18.42 |
| Disable 1.25 s peek returns | 21.10 | 17.67 |
| Require sight for a flank as in A2 | 20.66 | 17.67 |

## Headless cost

Each horde session uses the city or dev pit, calls ArenaPit.horde(), and lets the guards fight a strafing Rivet with his trigger released. After 600 active ticks the fixture removes surviving guards to advance each wave, through wave 10. The fixed 10- and 40-guard trials run 600 active ticks. Station sparring partners are excluded. Integer-microsecond samples are pooled across five seeds. Tick time sums hostile stepping and the squad pre-loop, including assignment. The timers exclude shots integration, rendering and the observer’s per-hostile bookkeeping. Rates include wave gaps. Sight counts cover perception and attack confirmation, with navigation clearance measured separately from target sight.

| Workload | Brain | Hostile µs mean / p99 / max | Tick µs mean / p99 / max | Routes/s (max/tick) | Cover/tick (max) | Sight/hostile (max) | Minimum cover slack | Worst seed / tick / alive |
|---|---|---|---|---|---|---|---|---|
| city_horde | guard | 3.21 / 14 / 12100 | 26.98 / 75 / 12158 | 2.91 (1) | 0.000 (0) | 0.068 (1) | 0 | 20261104 / 3616 / 10 |
| city_horde | squad | 26.19 / 107 / 13673 | 289.69 / 556 / 14953 | 18.93 (1) | 0.245 (1) | 1.065 (2) | 0 | 20261106 / 2388 / 10 |
| city_horde | mixed | 25.50 / 93 / 700 | 276.66 / 488 / 1039 | 16.14 (1) | 0.098 (1) | 1.076 (2) | 0 | 20261105 / 2687 / 10 |
| pit_horde | guard | 2.83 / 10 / 236 | 23.79 / 54 / 289 | 1.10 (1) | 0.000 (0) | 0.068 (1) | 0 | 20261106 / 4631 / 10 |
| pit_horde | squad | 22.50 / 76 / 13056 | 249.86 / 547 / 13565 | 14.68 (1) | 0.281 (1) | 1.125 (2) | 0 | 20261103 / 2927 / 10 |
| pit_horde | mixed | 24.23 / 70 / 21179 | 266.02 / 515 / 21409 | 10.66 (1) | 0.102 (1) | 1.124 (2) | 0 | 20261104 / 1407 / 8 |
| pit_10 | guard | 2.84 / 11 / 180 | 28.33 / 69 / 210 | 3.71 (1) | 0.000 (0) | 0.068 (1) | 1 | 20261103 / 278 / 10 |
| pit_10 | squad | 27.26 / 89 / 330 | 349.02 / 504 / 933 | 17.77 (1) | 0.355 (1) | 1.092 (2) | 0 | 20261106 / 518 / 10 |
| pit_10 | mixed | 25.93 / 79 / 792 | 325.85 / 483 / 1413 | 15.21 (1) | 0.121 (1) | 1.106 (2) | 0 | 20261105 / 620 / 10 |
| pit_40 | guard | 3.53 / 15 / 1537 | 141.07 / 375 / 1801 | 13.44 (3) | 0.000 (0) | 0.068 (1) | 4 | 20261105 / 123 / 40 |
| pit_40 | squad | 61.95 / 150 / 945 | 2865.21 / 3598 / 4610 | 85.30 (2) | 1.859 (4) | 1.036 (2) | 0 | 20261103 / 670 / 40 |
| pit_40 | mixed | 59.78 / 120 / 440 | 2724.58 / 3477 / 4037 | 61.28 (2) | 0.760 (4) | 1.034 (2) | 0 | 20261105 / 304 / 40 |

Slack is the minimum of ceil(alive / 12) + spawns − cover searches across individual ticks. Every squad and mixed tick also passed the stricter ceiling without the spawn allowance, two actual A* searches, and two target sight checks per hostile. The JSON includes every seed’s counters and worst-tick breakdown.

guard at 10 → 40 guards grew from 28.3 to 141.1 µs/tick (4.98×), or 3.8 µs/tick per additional guard.

squad at 10 → 40 guards grew from 349.0 to 2865.2 µs/tick (8.21×), or 83.9 µs/tick per additional guard.

mixed at 10 → 40 guards grew from 325.9 to 2724.6 µs/tick (8.36×), or 80.0 µs/tick per additional guard.

## Rendered frame gate

Six paired rounds per scene, 1080p D3D12, vsync disabled, 60 fixed ticks/s, window position 0,1440. The old arm used guard and old~aa repeated it. Complete frame gate file `build/perf/fight-gate/n19-a4b-complete/gate.json`. The accompanying JSON retains round-level measurements and intervals.

| Scene | Arm | p50 ms | p99 ms | Worst ms | Frames >25 ms | CPU s | Other busy cores |
|---|---|---|---|---|---|---|---|
| city | old | 4.84 | 9.14 | 39.34 | 3.00 | 15.76 | 3.13 |
| city | squad | 4.50 | 9.43 | 39.58 | 1.00 | 15.19 | 3.76 |
| city | mixed | 4.62 | 9.00 | 38.35 | 1.00 | 15.40 | 3.36 |
| city | old~aa | 4.94 | 9.53 | 40.56 | 3.00 | 16.12 | 3.34 |
| horde | old | 5.06 | 9.23 | 37.64 | 3.00 | 13.46 | 3.38 |
| horde | squad | 4.58 | 8.68 | 35.19 | 1.00 | 12.41 | 4.68 |
| horde | mixed | 4.43 | 7.64 | 35.58 | 3.00 | 12.52 | 4.85 |
| horde | old~aa | 5.07 | 9.31 | 34.46 | 3.00 | 13.30 | 2.74 |

The original city/old round 3 exited with Windows code −1073741819 before writing its frame sample. After the native riot, all four city arms of round 3 ran again on the same export in the original order. The table uses the replacement quartet and the gate’s summarise function. Original report build/perf/fight-gate/n19-a4b/gate.json. Replacement report build/perf/fight-gate/n19-a4b-city-retry-1/gate.json.

Each cell gives the median paired difference and the gate’s bootstrap 95% interval. The A/A row measures the noise floor. Negative values mean less time or fewer slow frames.

| Scene | Arm minus old | p50 ms | p99 ms | Worst ms | Frames >25 ms | CPU s |
|---|---|---|---|---|---|---|
| city | A/A | +0.04 [-0.01, +0.20] | +0.20 [+0.03, +2.32] | +1.01 [-10.59, +2.07] | +0.00 [-1.00, +1.00] | +0.13 [-6.66, +0.97] |
| city | squad | -0.38 [-0.50, -0.24] | -0.99 [-2.15, +4.78] | -0.16 [-0.59, +4.40] | -2.00 [-3.00, -2.00] | -1.36 [-5.75, +0.52] |
| city | mixed | -0.23 [-0.28, -0.12] | -0.04 [-1.11, +0.97] | -0.99 [-14.75, +4.81] | -2.00 [-3.00, -2.00] | -0.36 [-7.25, +0.00] |
| horde | A/A | +0.00 [-0.07, +1.32] | +0.08 [-0.25, +2.62] | -0.62 [-6.56, +11.26] | +0.00 [+0.00, +1.00] | -0.29 [-0.56, +1.16] |
| horde | squad | -0.89 [-0.96, +1.25] | -1.74 [-2.09, +1.21] | +0.93 [-8.51, +9.68] | -2.00 [-2.00, -2.00] | -2.06 [-2.39, +1.84] |
| horde | mixed | -0.76 [-0.93, -0.47] | -1.73 [-2.80, -0.74] | -1.39 [-11.18, +1.97] | +0.00 [+0.00, +0.00] | -1.38 [-2.14, +0.11] |

city completed 24 runs with 24 marked contended and 0 script errors.

horde completed 24 runs with 24 marked contended and 0 script errors.

The gate classified p99 in city as WASH for squad and WASH for mixed, using the measured A/A floor.

The gate classified p99 in horde as WASH for squad and WASH for mixed, using the measured A/A floor.

## Native 400-actor riot

The native city simulation uses no arena brain. The official headless bench ran one pass. A matched headless riot control used the A3 runtime at 8260146dc with the same bake, engine, camera and 60-second input under the same lock. Each side has one timing sample.

| Metric | A3 control | Final | Difference |
|---|---|---|---|
| p99CpuMs | 5.8820 | 6.9330 | +1.0510 |
| simStepMsPerTick | 0.1314 | 0.1188 | -0.0126 |
| actorsAvg | 399.7960 | 399.7960 | +0.0000 |
| worstSwapMs | 10.0060 | 10.8610 | +0.8550 |
| hitches25 | 2.0000 | 2.0000 | +0.0000 |
| hitchesOver50 | 0.0000 | 0.0000 | +0.0000 |
| over50.unexplained | 0.0000 | 0.0000 | +0.0000 |
| low1Fps | 114.5952 | 100.4117 | -14.1835 |

Riot p99 CPU time changed by +1.051 ms. The section 20 ceiling is 7 ms. Actor-count delta was +0.000. One pass per revision does not quantify run-to-run timing uncertainty.

bench (headless CPU only, no rendering, 1 consecutive runs x 4 scenarios x 60 s): p99 6.933 ms, 1% low 100 fps, worst swap 10.861 ms, worst frame 37.531 ms; hitches >25 ms 3, >50 ms 0 (unexplained 0, outside 0, present 0); vsync-on drive >25 ms: 0; visible avg 89.784 / 15.597 / 319.307 (drive/drive48/riot); rigs p50 0.732 / p99 2.601 ms per frame (riot, up to 20); CONTENDED: up to 2 other run(s) active during the bench (numbers are pessimistic)

## Regression checks

All 15 guard fight digests match A1. The JSON includes each encounter, seed and digest. The flag-off scenario artifacts were compared byte for byte to the pre-change captures.

~~~text
run_scenarios: [1/5] arena_city ok, 3.1 s
run_scenarios: [2/5] arena_pit ok, 2.7 s
run_scenarios: [3/5] arena_squad ok, 13.1 s
run_scenarios: [4/5] enemy_pit ok, 1.6 s
run_scenarios: [5/5] quest_collect_call ok, 3.7 s
run_scenarios: 5 ran, 0 failed
scenario-tests: 5 passed (headless)
unit-tests: 27 passed, 0 failed, 0 skipped (GUT, headless)
~~~

| Scenario artifact | SHA-256 | Identical to reference |
|---|---|---|
| arena-pit-telemetry | 2c9239521ac07d08e4855f9491220647e8674d772e5bfbb2fa8c15424c1c48eb | True |
| arena-city-telemetry | e2954a8fa9cd230b110dbef1acfaf892f39bd210f9c4cf8a78634bc90df1679a | True |
| enemy-pit | 55bec1d435d7d8d50367b7cebd97edbe5b93d689d15defa60ca4f67c5006a023 | True |
| quest-collect-call | 0be37fbda3bd56397ba4ebed391b7adca5787aa36b98948526fcd6597167f689 | True |
| arena-squad | 940b09ae5a45f925eb8065c3749c26340fb762a898270d07ef6d9ade16d44b6d | False |

The mixed scenario replayed all five city waves in 3071 ticks, with 180 FLANK ticks, 2 flanking shooters, 51.0% cover and 0.0% crowding. The separation-disabled control reached 7.7% crowding. The contractor-only spawn judge also ran with the armored wave override.

The unit and scenario processes reported ObjectDB and resource cleanup diagnostics at shutdown after their pass lines. The earlier scenario capture has the same shutdown diagnostic.

## Reproduction

Run from the worktree root. For the gate, the local position.mjs contains the following two lines. The lock owner and release time are recorded in the JSON.

~~~js
import { ENGINE } from '../../tools/perf/fight_gate.mjs';
ENGINE.push('--position', '0,1440');
~~~

For the targeted retry, the local round3.mjs loader changed the initial round index from 0 to 3 and the exclusive end from o.rounds to 3 + o.rounds. This preserves the gate’s order() rotation for the failed round. The position preload and all instrumented frame and CPU collection code are shared with the original launch.

~~~powershell
$env:APPDATA='C:/Users/kazda/kiro/gtai-n19/appdata/ai'
$env:GODOT_BIN='C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe'
node tools/dev/run.mjs fight_probe --all --seeds=5 --enemy-brain=<guard|squad|mixed> --out=<absolute.json>
node tools/dev/run.mjs squad_cost --seeds=5 --timeout=600 --out=<absolute.json>
node tools/tests/run_unit.mjs --select=test_squad_budget,test_arena_squad,test_enemy_ai,test_fight_probe
node tools/tests/run_scenarios.mjs --only=arena_pit,arena_city,arena_squad,enemy_pit,quest_collect_call
node --import ./build/a4b/position.mjs tools/perf/fight_gate.mjs --arms=old:--enemy-brain=guard,squad:--enemy-brain=squad,mixed:--enemy-brain=mixed --rounds=6 --out=build/perf/fight-gate/n19-a4b
node tools/bench/run.mjs --headless --runs=1
& $env:GODOT_BIN --headless --path project --fixed-fps 60 res://dev/bench/city_bench.tscn -- --scenario=riot --label=riot --secs=60 --zoom=1.0 --vsync=disabled --out=<absolute A3 control.json>
node --import ./build/a4b/round3.mjs --import ./build/a4b/position.mjs tools/perf/fight_gate.mjs --arms=old:--enemy-brain=guard,squad:--enemy-brain=squad,mixed:--enemy-brain=mixed --rounds=1 --scenes=city --no-export --wait=1 --out=<retry-dir>
~~~
