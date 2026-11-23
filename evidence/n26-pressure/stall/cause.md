# Seed 9 left the street during a Kerf slice

Average-9 on `548989d7e` reproduced the archived result byte for byte (SHA-256 `a1cde113b3e069aabbc41ba47384b13ffe83169974a6e9f45f8ac20656af65f1`). On that revision the gauntlet supports transformations. Run from the revision after headless import with the lane's Godot and APPDATA.

```text
node tools/dev/run.mjs gauntlet --seed=9 --bot=average --pick=greedy --controls=wheel --waves=40 --result=<absolute-path>/average-9.json
```

## What happened

The wave 39 log starts at tick 76,379. On simulation tick **77,115** (session clock 77,116 after the step), Kerf blinked from (1255.326, −0.187) and cut a target at (1254.471, 5.487). The south wall spans Y=6 to Y=7. The ordinary slice placed Rivet at (1254.270, 7.600), a whole body radius outside the far face. Rivet's last incoming hit was at tick 77,107. Wave 40 started at tick 81,779 with 12 spawns delayed.

At tick 90,000 Rivet was **settled in base**, HP 137.5, at (1266.519, 7.600). He intended to advance on robot gunner #727, 2.231 m away across the wall. The gunner was at the road limit Y=5.55. The bot had no move opening or recovery intent. All 40 hostiles lacked sight to the squad target (Rivet). Patrol cops #745 and #755 held the two ranged tokens. Both melee tokens were free. The wall blocks both sides' firing lines. Changing form leaves Rivet on the same side of it. The run ended at tick 216,000.

[tick-90000.txt](tick-90000.txt) gives every hostile's state, HP, position, range to Rivet, sight, token type and ownership, token age, goal, stun deadline and last shot. The probe observed the running sim without sampling another input or spending an RNG draw.

## Why the bot pressed melee

On the input sample before the blink, the bot chose SWAT #748. Its aim after the profile error was (−0.014023, 0.999902). `BotViewArena.blink_clear` passed that floating-point heading to `KerfStage.pick` and approved #748's landing. The wheel input records one of 256 headings. Decoding this input produced (−0.024541, 0.999699), which selected rocket trooper #738 at the wall instead. The bot issued melee plus weapon-prev. The move-opening plan was NONE. [Input sample and candidates](blink-input.txt).

The bot now checks the heading the pilot will actually receive in both the ordinary slice preview (`project/features/gauntlet/bot/bot_view_arena.gd:96`) and the armoured-target opening (`project/features/gauntlet/bot/bot_arena_moves.gd:54`). Both use the production input codec.

Headless bot measurements now stop with a combat-freeze log and failure exit after 3,600 consecutive live combat ticks without actual HP loss. A blocked hit or overlapping spawn cannot restart the timer. A fresh block starts its own timer. The runner withholds the normal result on this exit so a batch cannot score a survival. Humans playing the street keep control.

## Regression tests

`node tools/tests/run_unit.mjs --select=test_gauntlet_kerf_wall --no-rerun` against the original landing and preview failed both behavioral assertions. The player lost sight of the next enemy across the wall, and the bot approved the dangerous recorded ray. The fixture unlocks Kerf through the pilot's test instance and uses wheel input. Its two target positions and tested aim reproduce the seed-9 sample. The bot test also slices the closer foe along a safe heading and verifies damage and sight to the remaining foe. The player test is pending only while the blink crosses the far face. The freeze clock has separate coverage in `test_gauntlet_enemy_damage.gd`.

## Shared landing and melee-lane handoff

A human with Kerf unlocked can reproduce the same crossing by slicing a target just inside the wall. `project/features/souls/kerf_behind.gd:19` computes a point beyond the target. A normal slice returns that point directly. `project/features/souls/kerf_stage.gd:125` resolves overlap at the destination alone. Once the destination is in the far half of the wall, `ArenaWalls.eject_circle` chooses the outside face. Rivet's radius is 0.6 m. A destination already beyond a thin wall can also pass straight through it.

**NEED melee.** Validate the actual travel segment before applying its path cuts or moving Rivet. The following minimal patch uses the existing landing clearance predicate. A blocked blink stays at its origin and can still hit its visible primary target. Clear blinks retain their existing landings.

```diff
--- a/project/features/souls/kerf_stage.gd
+++ b/project/features/souls/kerf_stage.gd
@@ -116,0 +117 @@
+	var walls: ArenaWalls = _walls(stage)
@@ -118 +119 @@
-		var blink: KerfBehind = KerfBehind.resolve(stage, target, num(&"behind_m"), _walls(stage))
+		var blink: KerfBehind = KerfBehind.resolve(stage, target, num(&"behind_m"), walls)
@@ -122,2 +123,6 @@
-		_cut_path(stage, from, to, target, blink.path_dir)
-	var walls: ArenaWalls = _walls(stage)
+		if KerfBehind._clear(stage, from, to, walls):
+			_cut_path(stage, from, to, target, blink.path_dir)
+		else:
+			to = from
+	elif not KerfBehind._clear(stage, from, to, walls):
+		to = from
```

## Unmodified lane HEAD

These four greedy, wheel-control runs on `6288453ee` died before the historical freeze. Their result files are under [head](head/).

| Profile | Seed | Death wave | Tick | Killer |
|---|---:|---:|---:|---|
| Average | 9 | 6 | 6,748 | sentry_turret |
| Average | 8 | 10 | 16,259 | contractor |
| Expert | 1 | 10 | 17,246 | rocket |
| Expert | 9 | 9 | 18,431 | shield_robot |


## Paired replay with transformations enabled

Replaying the same historical command with only the two bot prediction edits cleared wave 39 in 39.55 s and wave 40 in 35.73 s. The run exited 0 at tick **82,694**, segment 40. The original exited 1 at tick **216,000**, segment 39. The new freeze detector was absent from both historical runs. The fixed bot made progress by fighting through the street. [Before result](historical/average-9.json) · [After result](historical/average-9-bot-fix.json).

On the lane fix, the changed suite passed 3,991 tests with 3 skipped and zero failures. Both bot target-selection tests and the freeze clock passed. The player crossing remains marked pending for melee. The proposed patch passed a git application check only.
