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
