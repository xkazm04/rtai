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
- GATES r2 of record (clean tree 2813ef81, `evidence/r2/evidence-run.txt`, `node tools/evidence/run.mjs
  --no-bench`, exit 0): lint 13/13 (662 files), unit 732/732, scenarios 30/30, parity bit-exact
  (planted caught at 629), selftest look 11/11 + block 5/5 worst 0.00. No re-bless this round.
- 01:41 reel-0145-rocket-64ppm (64 px/m, 64 s, 3 fps sheet from 54 s, 12 frames). Craft: the
  orange streaks are the guards' rounds (danger vermilion, right); Rivet's rocket draws as a long
  white lance (the 3 m tracer) with no smoke trail, no flame, no blast ring caught; the
  signature kills happen at the frame edge or off screen (the guards stop at engage 12 m, the
  64 px/m frame is +-10 x 5.6 m). Tried a close-in option (`--reel-close-m=7`: the gun beat
  walks in on the guard): 1 shot, 2 kills, 28.8 damage taken: reverted, not debugged (NEXT 2).
- 01:45 reel-0145-city-rocket (`--arena=city`, 32 px/m, 73.5 s; 1/4 fps sheet, 19 frames):
  integrity holds (all beats, no camera break), but the look is wrong: on the city block the
  arena's fighters (claw cops, dummies, pit guards) draw as quest 1's round guard discs with a
  vermilion centre, NOT the cast rigs, although `--rigs` is passed (the arena view shows rigs).
  That breaks "cops are blue" and "vermilion only for danger" in the city clip. Also tall
  vermilion bars at the top edge of the junction frames (unknown source: objective markers?),
  and the 17 m/s top-speed snap is not located yet.
- REQUEST 5 -> gunplay (cc weapon-art): the rocket's flight reads as a white 3 m lance; the
  hit chain asks for a rocket body with a smoke trail and a blast flash/ring at impact
  (reel-0145-rocket-64ppm.mp4, 54-58 s).
- REQUEST 6 -> human-reactions (cc brutality): on `--arena=city --rigs` the hostiles are not on
  the cast rigs (quest 1 guard discs, vermilion centre), so neither the reactions nor the
  signature cut show in the city proving block (reel-0145-city-rocket.mp4). Whoever owns
  ArenaRigs on the city view tonight: tell me, or I take it as integration glue next round.

NEXT (iteration 2):
1. Merge round 3 (the five tips, brief order), the four gates under the private APPDATA,
   re-bless only if the look goldens move (decisions line).
2. Close-up pass that keeps the kill in frame: debug `--reel-close-m` (why the walk-in never
   fires: wall push, the guards' cover, or `_seen_since` reset), or capture at 48 px/m.
3. City block: find why `--rigs` does not draw the arena fighters on the city (ArenaGame
   `_add_view` adds ArenaRigs; on the city CityCharacters may hide it) and the 17 m/s snap.
4. The reel's weapon list grows: pistol and machine pistol beats (needs a deterministic weapon
   switch from gunplay/rivet-arsenal: REQUEST 3), riot shield and robot thug (enemy-ai has no
   night lane: check whether any lane brings them into the arena).
5. Final round prep: a `windows-showcase` export preset that includes dev/arena + dev/showcase
   (all shipped presets exclude dev/*), test whether the exported exe takes
   `res://dev/arena/arena.tscn` as its scene argument.
6. Bench in the arena fight and the riot (only the drive was benched in iteration 1).
- 01:50 checked reel-0145-rocket-64ppm 6-13 s (1 fps, 8 frames): the claw combo lands on the
  hub cops at close range and the finisher throws a cop about 3 m with a red trail into the pit
  wall line; strong read. frames.json now 6 entries (newest first), every file present.
  Scratch renders deleted; reels kept in gtai-masters/n4/showcase.
- 01:49 FIX (integration glue, NEXT 3 half done): on `--arena=city` CollectCallView draws through
  CityView and has no print stage, so `ArenaRigs.attach` returned false (`cast rigs: false` in
  the city film log) and the fighters stayed quest 1's vermilion guard discs. ArenaRigs now
  attaches to CityView's actor layer and takes its zoom. Proof (a still):
  `gtai-masters/n4/showcase/city-rigs-48ppm-0155.png` (tick 601: blue cop rigs round Rivet's rig
  at the junction). Arena scenarios 5/5, unit 732/732 after it. REQUEST 6 is withdrawn (glue).
  Left on the city: small vermilion squares and a bar from ArenaFloorView's props (lane marks),
  and the 17 m/s snap. The city reel is re-filmed next round.

## Iteration 2 (01:54 - 02:54), BUILD

- 01:55 read JOURNAL, git log, the five lanes' tips and JOURNALs. Replies: human-reactions
  answered showcase REQUEST 2 (flinch/stagger and deaths by kind live under `--rigs`) and fixed
  ArenaRigs on the city itself (39582854, same fix as my eb1c52f1); rivet-arsenal DECISION:
  number keys 1-4 select carry slots, wheel/d-pad cycle (input bits not bound yet); gunplay
  REQUEST 4 -> rivet-arsenal says how a live switch is done (`arena.gun = GunHand.make(...)`).
- MERGE round 3 (brief order): weapon-art ac581d9d, rivet-arsenal 8395e276, gunplay 01b034aa,
  human-reactions 8669b5d9, brutality d59f9c9c -> d1c2db74, 9c764635, 4d139f45, 6378b4ca,
  daa79fce. Conflicts: JOURNAL.md every time (kept ours); `arena_game.gd` bot switch (kept both
  the reel and gunplay's bot); `test_arena_hooks.gd` (kept ours, the stricter one-probe count);
  `arena_rigs.gd` twice: human-reactions' city attach (kept theirs, it replaces my eb1c52f1),
  rivet-arsenal's RivetHeldView added to `view.print_stage.actor_layer()` which is null on the
  city -> FIX (glue): it goes on the same layer as the rigs. brutality's field order: kept ours.
- GATES r3 first run (daa79fce): lint 13/13, unit 745/745, scenarios 32/32, parity exact, but
  selftest FAIL: NEW off-doctrine 32 px/m vermilion on vehicles 4 px and on cop 4 px, the 48
  px/m rows no longer seen. Reproduced on a second run (deterministic). The pixels sit on the
  junction's blood splat round Rivet (build/evidence/accent-32ppm.png looked at): the known
  gate-boundary flicker class moved from 48 to 32 px/m. Suspect: gunplay b3b3c92f (blood drops
  on their own canvas item, new this round); not bisected. DECISION (decisions.md): two dated
  debt rows (owner gunplay, max 12). REQUEST 7 below.
- FIX (own): the reel's gun beat now walks in on a guard farther than 6 m while it fires
  (`APPROACH_M`), so kills land inside a 64 px/m frame (NEXT 2 of iteration 1). Scenario green:
  pit_gun 12 kills, pit_melee 2, claw 15 hits / 4 kills, 0 deaths, damage taken 9.6.
- GATES r3 of record (clean tree d7632ac1, `node tools/evidence/run.mjs --no-bench`, exit 0):
  lint 13/13 (678 files), unit 745/745, scenarios 32/32, parity bit-exact (planted caught at
  629), selftest look 11/11 + block 5/5 (worst 0.02), accent audit green with the two rows.
- The 17 m/s top speed is in the plain arena run too (scenario telemetry 17.06), so it is not a
  city collision. The claw lunge is spread over windup+active (MeleeCombo.lunge_step_m), so the
  suspect is a one-tick collision push-out; not located yet.
- Registry applied: combat-pacing-and-dramatic-arc ("the opening is a gate of its own", beats
  mined from the curve): the reel's order stays an arc that builds (motion -> claw -> range ->
  melee line -> pit melee -> pit gun with the signature kills as the climax). Deviation: no
  tension curve is computed for the reel yet; its beats are scripted, not mined.
- 02:10 reel-0210-pistol (32 px/m, `--weapon=pistol`, gunplay's table pistol on the real fight,
  73 s). Looked at 1 fps from 53 s (12 frames) and 1/4 fps from 0 (12 frames). Good: blue cop
  rigs drop in red sprays, corpses keep their poses, Rivet's tracer is weapon-art's charcoal
  body with a light head; the guards' rounds are vermilion streaks (danger). Wrong:
  (a) the hub: human-reactions' `react_line` (y 2.5, x 6..13.5) and rivet-arsenal's
  `rivet_claw_cops` (y 3, x 2/6/10) spawn 0.5-1.1 m apart, so 7 cop rigs clump into one blob
  where the claw combo plays (frames 4-9 of the opening sheet); (b) every claw-cop death leaves
  a pool with straight vertical red streaks below it (the d5-combat drop spray along a vertical
  `dir`, human-reactions' REQUEST 1 -> gunplay, still open); (c) pit corpses thrown onto the
  pit's north wall line lie half inside the wall.
- REQUEST 7 -> gunplay: the accent audit's 32 px/m blood flicker moved with this round (two debt
  rows `blood_flicker_*_vermilion_32`, owner you, decisions.md); confirm it is your b3b3c92f or
  bisect it, and delete the rows when the audit is fixed.
- REQUEST 8 -> human-reactions, rivet-arsenal: your hub stations overlap (react_line y 2.5 x
  6..13.5 vs claw cops y 3 x 2/6/10; ArenaRivetBot walks y 1.45). Please agree a free spot
  between you (the hub is x -3..15, y -5..5; the melee line holds y -3); the reel films whatever
  you settle. reel-0210-pistol.mp4 0-40 s shows the clump.
