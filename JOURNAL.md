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
