# JOURNAL - lane showcase (branch `n-showcase`), night 2026-11-04

Evidence: `evidence/` here; reels in `C:\Users\kazda\kiro\gtai-masters\n4\showcase\`.
Private APPDATA: `C:/Users/kazda/kiro/gtai-n4/appdata/showcase`.
Scripts: `evidence/gates.sh <round>` (the four gates, logs in `evidence/<round>/`),
`evidence/film.sh <name> <ppm> <frames>` (fixed-fps 60 capture of `--bot=reel --rigs --clean`
-> mp4 in the masters folder), `evidence/bisect_drive.sh <commit> <label> [prep]` (throwaway
worktree, export, drive bench 2 x 40 s).

## Iteration 1 (01:07 - 02:07), BUILD

- 01:07 read: AGENTS, the arena REPORT, the rivet-motion REPORT, decisions (bench lines 173, 180,
  227). Registry: applied `motion-quality-gating` in spirit (judge in motion, fixed-fps, look at
  every reel's frames); full golden-path read deferred to iteration 2 (time went to the build).
- 01:08 MERGE round 1: `git log main..n-<lane>` is empty for all five lanes (weapon-art,
  rivet-arsenal, gunplay, human-reactions, brutality): nothing to merge yet. Round 1 = the base.
- 01:10 GATES r1 (base 9ebc5918 + nothing merged, private APPDATA): lint 13/13 (630 files),
  unit 695/695, scenarios 28/28. Evidence run refused a dirty tree; re-run after the commit.
- MILESTONE 01:20: `CombatReel` (`project/dev/showcase/combat_reel.gd`, `--bot=reel` in the
  arena; one wiring line in `dev/arena/arena_game.gd`). Beats: walk a hub loop (300 t), strafe
  aiming north (240 t), the range dummies through ArenaRangeBot (540 t), pit wave 1 by melee
  (close in, jab every 32 t; 900 t), the pit by the gun (strafe, fire after 30 t in range;
  1200 t). 3180 ticks = 53 s. Headless run: 33 shots, 29 hits, 19 pit kills over 6 waves, 0
  deaths, 4.2 damage taken (`evidence/r1/reel-telemetry.json`).
- What the live game can show tonight (the base): walk, strafe, gloria shots, the electroshock
  jab, pit guards (GuardBrain, `--rigs` draws them as cops). NOT in the live game yet: the claw
  combo / PlayerMotion (rivet-motion's dev scenes only), the enemy-ai archetypes (riot shield,
  robot thug run only in `dev/enemy_ai/enemy_rig_fight_run.gd`), weapon switching. The reel gets
  those beats as the night lanes land them in the arena.
- 01:22 FIX (own defect, seen in the reel's frames): the walk beat at y -3 ran Rivet through
  rivet-motion's melee line (targets x 0/2/4, metal 6-14 on y -3) and the range-to-pit path cut
  through its west end. The hub loop moved to y 1.5-4; a new `melee_line` beat rounds the west
  end and jabs each dummy (60 t each). Reel now 6 beats, 3840 t = 64 s.
- MILESTONE 01:24: `scenario_showcase_reel` (every beat runs, melee and gun beats each drop pit
  guards, 0 deaths, replay identical, planted no-buttons fault kills nobody): 1 ran, 0 failed.
  Telemetry `evidence/r1/showcase-reel-telemetry.json` (45 shots, 32 hits, 13 pit kills: 2 by
  melee, 11 by gun).
- MILESTONE 01:14: reels `reel-0130.mp4` (32 px/m, 53 s) and `reel-0130-64ppm.mp4` (64 px/m,
  33 s), fixed-fps 60, `--rigs --clean`, in gtai-masters/n4/showcase; frames.json 2 entries.
  Frame sheets looked at (16 frames at 32, 9 + 8 at 64). What looks wrong:
  1. No melee swing exists: the jab kills with no arm motion (rivet-arsenal is replacing the
     jab with the claw combo in StagePilot, their DECISION live-melee).
  2. A jab kill: the cop drops straight into the generic sprawl, red blood; no flinch toward
     the hit, no stagger. Rifle kills at 32 px/m read only as the blood splash.
  3. Rivet hit by a guard round: his whole body fills solid vermilion for a frame or two
     (64 px/m, 27 s). Loud; the palette allows vermilion for danger, so it is legal, but the
     owner may read it as "Rivet turned red". Call for gunplay (HitFeel owner).
  4. The arena dummies (range, melee line) are drawn as cops with the ring and a number under
     `--rigs` (arena REPORT gap; no arena lane tonight). DEBT for the showcase: they read as
     victims, not dummies.
  5. At 64 px/m the pit guards shoot from off screen (no camera lead: arena-2 A placeholder).
- REQUEST 1 -> rivet-arsenal: the reel presses `melee` (press edge) once per 32 ticks on a pit
  cop and once per melee-line dummy; please keep the claw combo chaining on repeated press
  edges of the `melee` bit (no hold-only input), so the reel shows the full combo with no
  change on my side. Tell me in your JOURNAL if the combo needs a different press rhythm.
- REQUEST 2 -> human-reactions: the first thing the reel needs from you is a visible flinch /
  stagger toward the hit on the pit cops (GuardBrain contractors drawn by ArenaRigs as COP),
  and a death by damage kind (`shock` from the jab, `shot` from gloria). Clip to compare:
  `gtai-masters/n4/showcase/reel-0130-64ppm.mp4`, 26-28 s.
- REQUEST 3 -> gunplay: Rivet's own hit flash is a full-body solid vermilion fill
  (reel-0130-64ppm.mp4, 27 s). Consider a vermilion rim or a paper flash instead; your call,
  record it. Also: is the pistol / machine pistol selectable in the arena tonight? The reel
  needs a deterministic way to switch weapons (an input bit or a station tuning), not a poke
  at `arena.rivet.weapon`.
- MEASURE 01:20 drive bench bisect, CONTENDED (other lanes' Godot processes running; exported
  windows-bench per commit in throwaway worktrees, drive scenario 2 x 40 s each, bench.lock
  held; `evidence/bench-bisect/drive-bisect-r1.txt`, script `evidence/bench_round.sh`):

  | point | commit | drive p99 ms (run 1 / 2) | avg frame ms |
  |---|---|---|---|
  | day tree before any evening merge | 8f988db6 (ancestor of the day record a5019f2c, 4 small commits apart) | 4.066 / 4.155 | 1.067 / 1.074 |
  | + visual-fixes (12 m city) | 50e093bf | 5.448 / 3.225 | 1.138 / 1.032 |
  | + motion, gunplay, enemy, arena | a472e1ed | 5.084 / 3.675 | 1.134 / 1.022 |
  | merged main (+ powers, re-bless) | 9ebc5918 | 4.262 / 3.561 | 1.104 / 1.105 |

  Reading: tonight the DAY tree measures 4.1 ms, as slow as the tip; run-to-run spread (3.2-5.4)
  is larger than any step between commits, and the average frame is flat (1.02-1.14 ms
  everywhere). So the "drive p99 doubled" of the int-eve bench is not a code step visible at
  this resolution: it is machine load (the int-eve bench of record most likely ran contended
  too) or a cost under ~0.1 ms avg. Code check agrees: after the visual-fixes merge the only
  city-path change is `CityView.kick_px` (a zero vector add). Named cause: load, not code;
  re-check on an idle machine (the morning, after the lanes stop) with 3 x 60 s at 8f988db6 and
  the tip back to back.
- 01:22 MERGE round 2 (in brief order) of the lanes' first commits: weapon-art caff378f,
  rivet-arsenal 2df4f3b8, gunplay e816065e, human-reactions 69cd92e3, brutality a931e688.
  Conflicts: every JOURNAL.md (kept ours); `dev/arena/arena_game.gd` (rivet-arsenal's
  `--bot=rivet` and our `--bot=reel`: both kept); `dev/arena/arena_rigs.gd` (human-reactions'
  `react` ReactLink and brutality's `hidden` ids: both kept; ReactLink looks rigs up by fighter
  id, so brutality's skipped rigs do not shift it).
- GATES r2 (merged tree 4dd91db0): lint 13/13 (662 files), scenarios all pass, unit 730/732:
  `test_arena_hooks.test_the_stage_steps_and_reports_its_hooks` assumed the probe is the only
  hook; the shipped stations now bring brutality's and rivet-arsenal's hooks. FIX (merge glue):
  the test finds the probe by type; unit 732/732 after it.
- 01:27 FIX (own defect): the reel held the trigger; semi-auto magazine weapons (rocket: magazine
  1, reload 1.8 s) fired twice in the whole reel. The reel now pulses the trigger (6 on / 6 off
  ticks). Headless with `--sig-gun=rocket_launcher` (brutality's dev arg): 9 shots, 10 pit
  kills, 8 signature kills (style gib), 0 deaths; with `--sig-gun=pistol`: 23 shots, 14 kills.
  The claw combo is live (rivet-arsenal): 7 swings, 7 hits, 1 kill on the claw-cops station.
- Registry applied (motion-quality-gating): the reel findings keep craft, responsiveness and
  integrity apart; every frame sheet says its sampling (fps, start, count).
- 01:33 the reel now opens with rivet-arsenal's `ArenaRivetBot` (walk, strafe, backpedal, sprint,
  roll, claw combo on the claw-cops station in the hub), then a `go_range` beat round the melee
  line's east end (the old path cut through its metal dummies), range, melee line, pit melee,
  pit gun. 4410 t = 73.5 s. Scenario green: 29 claw swings, 4 claw kills, 13 pit kills, 0 deaths.
- GATES r2 evidence run (cf0ad514): lint PASS, scenarios 30/30, parity exact (planted caught at
  629), look goldens 11/11 + block 5/5 worst 0.00: NO re-bless needed this round. Unit 732/732
  but the row reads FAIL "tree changed during run" (my own JOURNAL/reel edits mid-run); re-run on
  a quiet tree next.
- 01:35 reel-0145-rocket (32 px/m, `--sig-gun=rocket_launcher`, pulse fix, old beat order):
  1 fps sheet from 40 s, 12 frames. Craft: the rocket reads (an orange streak); the signature
  gib reads even at 32 px/m (a dark scorch disc, a red burst, the helmet and blue chunks
  thrown). Missing: no blast flash or ring caught at 1 fps (check the 64 px/m pass); Rivet's
  held weapon is a long white stick (the weapon-art held sprites are not on the rig yet).
- City reel headless (`--arena=city --bot=reel --sig-gun=rocket_launcher`): all beats, 8
  signature kills, 3 claw kills, 0 deaths, BUT top speed 17.06 m/s (walk 4.5, roll about 8.7):
  a collision snap somewhere on the block; to find in the city clip. Five station spawns land
  in buildings and are dropped (incl. the arena's known `range/strafe_05m`).
- REQUEST 4 -> weapon-art: the reel shows Rivet holding a long white stick for the rocket
  launcher (reel-0145-rocket.mp4); when your held top-down sprites are ready, which lane puts
  them on the rig (arena_rigs / the cast rig's hand)? Tell me if it is glue I should wire.
