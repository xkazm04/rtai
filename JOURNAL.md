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
- 02:15 reel-0215-pistol-64ppm (64 px/m, `--weapon=pistol`, 73 s). Looked at 2 fps from 53 s
  (12 frames): the walk-in works: the cop rigs fall in their sprays inside the frame; Rivet
  reads (white body, collar, claws), the held pistol is small but there; the guards' told line is
  a thin vermilion line (danger, right). frames.json now 9 entries (2 new on top), all present.
- MILESTONE 02:16 arena-fight bench tool: `dev/showcase/reel_frames.gd` (SceneTree: the arena
  scene in a real window, vsync off, the reel driving, per-frame wall time after 120 warmup
  frames -> p50/p95/p99/max + 1 % low JSON). Commit d1c68958.
- BENCH r3 (bench.lock held 02:15-02:30, CONTENDED: five other lanes render on the same GPU):
  - arena reel (`reel_frames.gd`, EDITOR binary not the export, 1920x1080, `--rigs --clean
    --weapon=pistol`, 75 s, 19471 frames): p50 2.96 ms, p95 7.67, **p99 13.66 ms, 1 % low 52
    fps**, max 72.7 ms. No before (first arena measure); the editor binary is slower than the
    release export, so this is an upper bound. `evidence/r3/reel-frames-pistol.json`.
  - city bench (`node tools/bench/run.mjs`, exported release, 3 x 60 s): drive p99 3.63 ms,
    1 % low 137 fps (record 3.56: flat, the drive doubling is still not bisected); drive48 p99
    3.39; **riot p99 9.91 ms, 1 % low 60 fps** (record 6.0 / 124): MISSES p99CpuMs. Blood is
    not it (77 us/frame, 0.08 ms; gunplay's split works); rigs p99 0.84 ms. Contention suspected
    (other lanes' captures), not proven: re-run alone before naming a code cause.
    `evidence/r3/bench-*.json`, `bench-r3.txt`.
- FRICTION: `tools/bench/run.mjs` fails "the given export path doesn't exist" in a fresh
  worktree: `mkdir -p build/export/windows-bench` first (lost one run).
- MILESTONE 02:32 the morning exe route works: release templates refuse a scene path ("compiled
  without support for path overrides"), so a `windows-showcase` preset with the feature tag
  `showcase` and `run/main_scene.showcase = res://dev/arena/arena.tscn` (DECISION in
  decisions.md; project.godot + export_presets.cfg, shared files, one line + one preset).
  `build/export/windows/RTAI.exe` (embedded pck, release DLL beside it) booted headless with
  `-- --bot=reel --rigs --weapon=pistol`: "arena open: 13 stations", "cast rigs: true", "Rivet
  holds the table pistol", reel beats ran. Commit 80dd992b. Play command for REPORT:
  `build\export\windows\RTAI.exe -- --rigs --weapon=pistol` (city: add `--arena=city`).
- 02:35 reel-0235-rocket-64ppm (`--weapon=rocket_launcher`, 64 px/m). Looked at 2 fps from 53 s
  (12 frames): the full rocket chain is in frame now: rocket body with grey smoke puffs, the ink
  blast ring, scorch star, red spray, the gib throws the helmet and parts (REQUEST 5 answered by
  gunplay's FightAreasArt; withdrawn). Craft note: the scorch star's grey reads a little flat
  against the grey pit floor.
- 02:35 reel-0235-city-pistol (`--arena=city`, 32 px/m). Looked at 1/6 fps (12 frames): the
  fighters are blue cop rigs on the city now (the 01:45 discs are gone). Wrong on the city:
  (a) the hub clump (REQUEST 8); (b) vertical red streaks under the claw-cop deaths; (c) the
  arena plan's walls draw as thick black bars across the junction's crosswalks and its lane marks
  as small vermilion squares and bars on the street (ArenaFloorView on the city). No night lane
  owns the arena floor: glue for me next round (hide the floor marks on `--arena=city`, keep the
  walls only if they collide).
- frames.json 11 entries (4 new this iteration on top), every file present.

NEXT (iteration 3):
1. Merge round 4 (five tips, brief order), the four gates under the private APPDATA, evidence
   run of record on a clean tree (logs to gtai-n4/scratch-showcase, then copy into evidence/rN).
2. Read the replies to REQUESTs 7 (gunplay: accent flicker rows) and 8 (human-reactions +
   rivet-arsenal: the hub station overlap); if no reply by round 4, move react_line myself to a
   spot that keeps `scenario_rivet_claw`, `scenario_human_react` and the reel green.
3. City glue: ArenaFloorView on `--arena=city` draws the arena walls over the crosswalks and the
   lane marks in vermilion; decide what the city proving block should show.
4. The reel's weapon list: switch weapons inside one reel once rivet-arsenal binds the carry-slot
   input bits (DECISION in their JOURNAL); until then one film per `--weapon=`. Machine pistol
   on the pit group next (`--weapon=machine_pistol`), then each signature weapon brutality has
   finished (rocket gib, hand cannon blowback).
5. Riot p99 9.91 ms / 1 % low 60 (record 6.0 / 124): re-run the riot alone under the bench lock
   when the machine is quieter; if it holds, bisect over round 3's merges.
6. The 17 m/s top speed in the plain arena reel: log per-tick moved_m > 0.2 with the beat and
   tick to name the cause.
- 02:40 reel-0240-mpistol (`--weapon=machine_pistol`, 32 px/m). Looked at 1 fps from 54 s (12
  frames, centre crop): the bursts read (several light-headed tracers at once), three cops drop
  in their sprays within about 2 s. Own defect: after the third kill the gun beat's walk-in pins
  Rivet against a crate for about 8 s while the last guard fires from off screen south (the
  `APPROACH_M` push has no way round props). Fix next: keep the strafe share while walking in,
  or step sideways when the walk-in does not close the gap for 30 ticks. frames.json 12 entries.
- FRICTION 02:45: a `reel_speed_probe.gd` (SceneTree, ArenaSession + the reel headless, print
  ticks moving > 0.15 m) never returned in 8 minutes (the scenario runner does the same work in
  about a minute; likely the SceneTree never got its quit, or EventBus/DataStore built bare stalls
  the session). Stopped (TaskStop, no Godot left), file deleted, not committed. NEXT 6 stands:
  do it as a scenario-style hook inside run_scenarios instead.
- 02:47 session end: all work committed; reels in gtai-masters/n4/showcase (12 frames.json
  entries); scratch sheets deleted. NEXT (iteration 3) list above stands, plus: fix the gun
  beat's crate pin (top of the list, it is the reel's own defect), then film the machine pistol
  again.

## Iteration 3 (02:48 - 03:48), BUILD

- 02:49 read JOURNAL, git log, the five lanes' tips and JOURNALs. REQUEST 8 answered by
  rivet-arsenal (claw cops y 3 -> 4.4, bot lane y 2.85, DECISION in their JOURNAL line 73).
- MILESTONE 02:58 merge round 4 (brief order): weapon-art 073780ed (conflict arena_game.gd:
  both bot switches kept), rivet-arsenal 39b89d53 (clean), gunplay 356a3a2d (conflicts fx_view +
  arena_rigs), human-reactions 2109c74b (conflict arena_rigs), brutality 55791625 (clean), then
  weapon-art again to 8ad641de (their molotov muzzle test fix). JOURNAL.md kept ours each time.
  - DECISION glue fx_view: weapon-art's cells own Rivet's flash + brass for a gun with art;
    gunplay's GunFx draws them otherwise and always its smoke, impacts, magazines, hostile stars
    (GunFxArt.draw_under/draw_over got a default-true shells/muzzle flag: a 3-line change in
    gunplay's file). Rejected: both (two flashes and two sets of brass per round).
  - arena_rigs: union of rivet-arsenal's clip counters + held view, the hidden set, human-
    reactions' looks; armed = table gun or own weapon, and not a pedestrian.
  - Native: human-reactions 698c9543 adds CityCore::scare. Our native/ source equals their tip,
    so I copied their two DLLs (built 02:41/02:44) into project/native/bin (read only from their
    worktree), then --import.
- GATES r4 (merged tree): lint 13/13; unit 772/773 (weapon-art's own test_fx_frames_resolve,
  fixed on their tip 8ad641de -> merged); scenarios 36/37: scenario_rivet_claw "expected 4 cops
  down" (3). Proof of cause: with human-reactions' station file removed it passes. react_dummy_4
  (13, 1.5) sits 2.9 m from spar_shock_1 (13, 4.4), inside the shock's 3 m chain radius.
  - Tried: y 0.5 (claw 8/10: Rivet's sprint/roll lane at y ~0 bumps the dummies), y 1.25 (same),
    only dummy_4 to x 11.5 (still 3 kills: so it is not only the chain), whole line 1.5 m west
    x -0.5..11.5 (rivet_claw + react_line green). Took the last (DECISION in decisions.md).
  - That move made scenario_brutality_kills' planted check miss ("1 % gib speed fault went
    unseen"; green at the old spot). The check compares only the final state after TICKS, and
    the faulty gib slot can recycle before then. Glue: the state is also written 30 ticks after
    the plant (clean and faulty alike). Green; commit 15a5a694.
- REQUEST 9 -> brutality: please confirm or replace my change to scenario_brutality_kills
  (15a5a694, the planted gib fault also judged 30 ticks after the plant). The final-state-only
  check went blind when another lane's hub station moved 1.5 m.
- REQUEST 10 -> human-reactions, rivet-arsenal: on the merged build the react_line had to move to
  x -0.5..11.5 (y 1.5) for scenario_rivet_claw; with dummy_4 alone at x 11.5 the claw still lost
  its fourth kill, so something besides the chain hop (the cops' walk at Rivet past the dummies?)
  ties the two stations. Please take the new spot into your branches or agree a better one.
- REQUEST 11 -> weapon-art, gunplay: both of you draw Rivet's muzzle flash and his brass; the
  merge now lets weapon-art own them when it has art for the gun (decisions.md). Agree on one
  owner and delete the other path (casings: WeaponCasings vs GunFx bits).
- 03:03 reel fixes (own): the gun beat side-steps off a prop (pinned < 0.3 m in 30 ticks ->
  50-tick side-step, alternating; telemetry reel_dodges = 1 in the scenario). Commit 47673e26.
- MILESTONE 03:14 weapon switch inside the reel (NEXT 4): ReelArsenal presses the next carried
  slot's `weapon_slot_N` bit every 2 pit kills when a --loadout is given (60 s gun beat);
  `--reel=pit` films only the pit's two beats. Without --loadout the reel and its scenario do
  not move. Commit 62f60be4.
- GATES r4c (tree 62f60be4, private APPDATAs): lint 13/13, unit 773/773, scenarios 37/37.
  Evidence run (--no-bench, caa641b2): lint, unit, scenarios PASS; parity bit-exact over 1200
  steps, planted mutation caught at step 629 (the scare is in both sides); selftest FAIL on the
  accent audit only: NEW 48 px/m vermilion on vehicles 8 px and blood on vehicles 16 px; round
  3's four debt rows not seen this time. Same flicker class as REQUEST 7 (it moves between zooms
  from run to run; gunplay measured 32 px/m clean on their HEAD and says the audit is not their
  gate). Logs in evidence/r4/.
- 03:15 reel-0315-arsenal (32 px/m, `--reel=pit --loadout=pistol,electro_gun,rocket_launcher,
  molotov`, 76 s). Looked at 0.4 fps from 15 s (24 frames on two sheets): the switch cycle works
  on film (pistol kills, then rocket smoke rings + scorch + gib throws, then molotov fire
  patches); six pit waves; sprays now fan off the blow (gunplay 356a3a2d). Wrong:
  (a) about 20 corpses heap at the pit's east door by 60 s (bodies never clear; the pile reads
      as a blob at 32 px/m);
  (b) a fan of red drops lands outside the pit's south wall on the cream paper margin (gib or
      spray thrown through the wall);
  (c) Rivet is small at 32 px/m among 25 bodies; the weapon he holds can't be read at this zoom.
- 03:20 reel-0320-arsenal-64ppm (64 px/m, same args). Looked at 0.2 fps from 15 s (12 frames):
  the launcher sits on Rivet's shoulder, the rocket blast is a big orange comic star with a cream
  core (orange, not red: fine), the molotov fire is orange flame cells, burnt kills leave grey
  ash-heap star stickers (eight of them litter the floor by 60 s), cop rounds are vermilion
  dashes (danger). Not seen on the sampled frames: the electro X-ray kill (sampling may miss
  it; next round: 2 fps over the electro turn).
- frames.json 14 entries (2 new on top), every file present.
- REQUEST 12 -> human-reactions (cc gunplay): the pit's corpses never clear; after six waves
  about 20 bodies lie piled at the east door (reel-0315-arsenal 55-75 s). A cap with a fade or a
  slide-off for the oldest body would keep the fight readable.
- REQUEST 13 -> brutality: gib throws (or their sprays) land outside the pit wall on the paper
  margin below the south wall (reel-0315-arsenal 45-75 s, the red fan below the frame's wall);
  stop gibs and drops at the arena walls.
- BENCH r4 (bench.lock held 03:21-03:35; CONTENDED: other lanes on the GPU; I filmed nothing
  during it). `node tools/bench/run.mjs`, exported release, 3 x 60 s: aggregate p99 10.09 ms,
  1 % low 70 fps, MISSES p99CpuMs (worst frame 63.5 ms, 2 hitches > 50 ms). My recompute from
  frame_ms per scenario: drive p99 5.73 ms / 1 % low 115 fps (r3 3.63 / 137, record 3.56),
  drive48 3.83 / 137, riot 7.23 / 101 (r3 9.91 / 60, record 6.0 / 124). Riot blood 60 us/frame
  (not it); rigs p99 0.89 ms. The drive moved the other way from the riot between rounds with
  no city-path code change in between except human-reactions' CityScare (inactive without
  gunfire) -> run-to-run contention is the leading explanation, still not proven.
  evidence/r4/bench-*.json, bench-r4.txt.
- 03:38 city glue (NEXT 3): on `--arena=city` ArenaFloorView draws only the props that collide
  (ArenaWalls.SOLID) and cones; the firing lines and door marks are gone from the street. The
  black wall bars stay: they are solid in the sim on the city too (hiding them would leave
  invisible walls). DECISION pending: should the city proving block build the pit's walls at
  all (a sim change; city scenarios to check)? evidence/r4/city-floor-glue.png. Commit 4045032b.
- Accent debt rows for this round's 48 px/m flicker committed (5faaceea); the selftest was NOT
  re-run on them (out of session time): first thing next round.

NEXT (iteration 4):
1. Re-run the selftest alone (`node tools/selftest/run.mjs` or `tools/evidence/run.mjs
   --no-bench`) to confirm the two new debt rows turn it green; delete round 3's four rows if
   they stay unseen twice.
2. Merge round 5 (brief order); read replies to REQUESTs 9-13. Watch for human-reactions and
   rivet-arsenal adopting the react_line spot (x -0.5..11.5) and brutality's view of the
   planted-check change.
3. Reel: film the electro turn at 64 px/m and look at 2 fps to find the X-ray kill; add the
   hand cannon (blowback kill) and the flamethrower: a second loadout run, e.g.
   `--loadout=hand_cannon,plasma_rifle,flamethrower,molotov`, or pickups on the way in.
4. Reel beats still missing from the brief: riot cop with a shield, robot thug. Look at
   enemy-ai's archetype spawns (the pit waves are patrol cops only) for a `--pit=` mix.
5. City reel again with the floor glue (`--arena=city`, 32 px/m), and decide the walls.
6. The 17 m/s snap in the plain reel (old NEXT 6): a scenario-side probe.
- 03:40 session end: all work committed; frames.json 14 entries; scratch sheets deleted.
- 03:44 GATES of record r4 (HEAD 6b1de248, evidence run --no-bench --no-parity): lint 13/13,
  unit 773/773, scenarios 37/37, selftest PASS (look goldens 11/11, block 5/5, the two new 48 px/m
  debt rows hold the flicker: 8 px <= 12, 16 px <= 24). Parity bit-exact from the 03:20 run (no
  sim change since). NEXT 1 done; evidence/r4/selftest-r4b.json.

## Iteration 4 (session 03:42-04:42)
- 03:42 read JOURNAL, git log, other lanes' JOURNALs. Replies: REQUEST 9 confirmed by brutality
  (cbb38461 takes the 30-tick planted check); REQUEST 10 taken by human-reactions (9503319e:
  react_line x -0.5..11.5 y 1.5); REQUEST 11 agreed by weapon-art and gunplay (weapon-art owns
  Rivet's flash + brass + magazine for a gun with art; GunFx the rest). REQUESTs 12 (corpse cap)
  and 13 (gibs past the pit wall) not answered yet.
- MERGE ROUND 5 (brief order, one at a time): weapon-art 934b7ded, rivet-arsenal 44f20481, gunplay
  743dd3f6, human-reactions 7683a343, brutality cbb38461 -> 90c56455. Conflicts: JOURNAL.md every
  time (kept ours); arena_rigs.gd x3 (held weapon on `layer` + weapon-art's WeaponMagView on the
  same layer; `hidden` + human-reactions' `crowd` both kept; const order); gun_fx_art.gd (our
  `shells` gate around gunplay's moved GunFxMarks.bit); arena_stations/human-reactions.json doc
  (kept ours, same coordinates). FRICTION: my first loop ran all five `git merge`s past the first
  conflict (the later four refused, nothing lost); merge one lane at a time from now on.
- GATES r5 (tree 90c56455, private APPDATA): lint 13/13 (727 files), unit 799/799.
- Scenarios r5 (90c56455): 38/39, FAIL scenario_rivet_katana ("dropped too few cops": claw_kills 3,
  hits 9); deterministic (same alone). Cause: rivet-arsenal 44f20481 aims a drawn melee weapon at
  the nearest live hostile within 2.6 m; on the merged build human-reactions' react_line dummies
  (never die, y 1.5) sit 1.35 m off the bot lane (y 2.85), closer than the claw cops (y 4.4), so
  the katana chopped dummies. Glue cd49e9fa: the aim skips station targets (ArenaTargets
  fighters). The five rivet_* scenarios green alone after it.
- Glue cd4b518f: one magazine per reload. weapon-art's WeaponMagView (under --rigs) drops the
  gun's own magazine and gunplay's GunFx dropped its ink stick too (weapon-art's REQUEST 5 ->
  gunplay, not answered on gunplay's tip). WeaponMagView.live counts views in a tree; FxView
  then skips GunFx's magazine bits for a gun with a `mag` part (the same rule as the brass).
  Without --rigs gunplay's stick still shows. A data change (mag_drop false) was rejected: it
  breaks test_gun_fx's magazine row and drops the stick on the plain arena.
- REQUEST 14 -> rivet-arsenal: your 5adbd26e RivetMagView (placeholder ink block) will be a THIRD
  magazine once merged: weapon-art's WeaponMagView landed (43a4e356) and the showcase build has
  it with one-magazine glue. Please retire RivetMagView or gate it off when WeaponMagView.live > 0.
- REQUEST 15 -> rivet-arsenal (cc human-reactions): take cd49e9fa (ArenaRivetBot._foe_aim skips
  ArenaTargets dummies) into your branch, or your next scenario_rivet_katana on a merged build
  fails again.
- DECISION reel riot/thug beats: the real fight (CombatArena + ArenaPit) has no riot shield block
  and no robot thug; both live only in enemy-ai's dev pit (EnemyPit, not an ArenaHook) and the
  owner's verdict says robots and bosses are resolved later. The reel does not fake them; the
  riot look exists only on the react_line dummy (render-side shield recoil). Candidate next: an
  arena `--riot` flag that dresses each pit wave's first guard in the riot look with gunplay's
  armored hp (a sim change behind a flag: the default reel and goldens do not move).
- Scenarios r5b (cd4b518f, the two glue fixes): 39/39 (evidence/r5/scenarios-r5b.log).
- MILESTONE 03:56 arena --riot (760b0616): ArenaPit.riot_hp (from wave 2, each wave's first guard
  takes gunplay's armored hp 2.5x: three pistol rounds, one hand-cannon round) and ArenaRigs
  dresses those ids in the riot look (RigVariant.crowd 6, the shield), so human-reactions'
  frontal shield recoil plays in a live pit fight. Off by default. test_arena_pit_riot 3/3.
  DECISION riot cop in the arena: armored hp + the shield look, the shield's block stays render
  only (no sim block in CombatArena; enemy-ai's EnemyPit shield is not in the real fight).
  Alternative: one data value (riot_hp) or a real block as an enemy-ai/gunplay item.
- 03:53-03:58 reel-0355-uniques (32 px/m, `--reel=pit --loadout=hand_cannon,plasma_rifle,ray_gun,
  mini_nuke`, 80 s, tree cd4b518f; first named 0410 from a wrong clock guess, renamed). The carry
  kept hand_cannon, ray_gun, mini_nuke (plasma_rifle shares the ray gun's slot class). Looked at
  0.4 fps from 15 s (24 frames), 1 fps over 48-60 s, and full frames at 36 s and 66 s:
  (a) the mini-nuke reads: a cream flash, ink shock rings, a cream mushroom ring, a 6 m patch of
      ORANGE flame stars with cream cores (not red; fine), ash stickers where the knot stood;
  (b) the second nuke (about 55 s) lands about 5 m from Rivet: its mushroom covers a quarter of
      the 32 px/m frame around him and he walks through it unharmed;
  (c) 62-75 s: no kill and no switch (the reel switched on kills only; one weapon could not
      score). Own fix: ReelArsenal switches after STALL_TICKS 480 without a kill as well;
  (d) corpses pile at the pit's south door, half over the wall onto the paper (REQUEST 12, 13
      still open).
- REQUEST 16 -> gunplay: the mini-nuke fires at any range: the reel's lob at a guard about 5 m off
  puts the blast and its quarter-frame mushroom on Rivet (reel-0355-uniques 54-58 s). A minimum
  lob range (the 12 m circle) or a refusal tell under it would keep it a long-range weapon.
- BENCH r5 (bench.lock held 03:59-04:11; CONTENDED: other lanes on the GPU/CPU; I ran no Godot of
  my own during it). Tree cd4b518f + the --riot commit (riot off in the bench). `node
  tools/bench/run.mjs`, exported release, 3 x 60 s: aggregate p99 10.77 ms, 1 % low 67 fps,
  worst frame 119 ms (1 hitch > 50 ms), MISSES p99CpuMs (r4: 10.09 / 70). My recompute from
  frame_ms (same method as r4): drive p99 3.33 ms / 1 % low 185 fps (r4 5.73 / 115; record
  3.56), drive48 2.73 / 187 (r4 3.83 / 137), riot 8.72 / 90 (r4 7.23 / 101; record 6.0 / 124).
  Rigs p99 0.94 ms. The drive is back at its record with no city-path change since r4, which
  supports the r4 reading that the drive swings were contention; the riot drifts the other way
  between rounds. Files: evidence/r5/bench-*.json, bench-r5.txt.
- Unit r5c (a4b33221: glue, --riot, stall switch): 802/802. Reel scenario green alone after the
  stall switch (evidence/r5/scen-reel-stall.log).
- 04:11-04:16 reel-0412-riot-64ppm (64 px/m, `--reel=pit --riot --loadout=hand_cannon,
  plasma_rifle,flamethrower,molotov`, 80 s). Looked at 0.4 fps from 15 s (24 frames) and a full
  frame at 54 s: the riot cop reads at 64 px/m (helmet, the shield's curved edge); the
  flamethrower's tank on Rivet's back and its orange tongues; ash stickers for burn kills; the
  hand cannon's flare. Wrong: (e) the gun beat's anchor is PIT_ENTRY's last point (the south
  door), so Rivet drifts out of the door and the fight spills onto the blank paper south of the
  pit: flame patches lie on paper (40-60 s). Own fix next: anchor the gun beat inside the pit.
  (f) a long vermilion line crosses the frame through Rivet at some shots (a cop's told line;
  fine by the palette, but it reads as a laser at 64 px/m).
- 04:16-04:21 reel-0417-city-riot (32 px/m, `--arena=city --reel=pit --riot --loadout=pistol,
  plasma_rifle,rocket_launcher,molotov`, 80 s; filmed on a4b33221, before the zone fix). Looked
  at 0.4 fps from 15 s (24 frames): the fight reads on the cream paving, rocket ring + gib, blood,
  molotov fire; no firing lines on the street (r4 glue holds); crowd 7 cowers. Wrong: (g) the
  pit's black wall bars stand on the plaza (solid in the sim; DECISION kept for now: removing
  them is a sim change to the city proving block, owner call); (h) the film log carries 4,646
  "Invalid polygon data, triangulation failed" errors: kill_char_fx._flakes 4,462,
  kill_mark_art.scorch 160, gun_fx_art._flash 26 (the arena 64 px/m film: 1). Tiny polygons
  (a char flake is about 1 px at 32 px/m) fail Godot's triangulation and are not drawn.
- REQUEST 17 -> brutality: KillCharFx._flakes draws 4-point quads about 1 px across at 32 px/m
  and Godot rejects most of them (4,462 errors in an 80 s city reel; the flakes do not draw);
  draw_primitive (no triangulation) or a minimum size would fix it. KillMarkArt.scorch fails
  160 times too (a small scorch_m). Log: gtai-n4/scratch-showcase/film-reel-0417-city-riot.log.
- REQUEST 18 -> gunplay: GunFxArt._flash (gun_fx_art.gd:159) fails triangulation 26 times in the
  same reel (a degenerate flare at 32 px/m, probably the pistol's side jets at a small age).
- GATES of record r5 (04:27, evidence run --no-bench --no-parity on 461819e7, private APPDATA):
  lint 13/13, unit 802/802, scenarios 39/39, selftest PASS (look goldens 11/11 worst 1.52, block
  5/5, no new off-doctrine accents; the 48 px/m debt rows hold). Parity not re-run: no city-sim
  or native change since r4's bit-exact run (ArenaPit is the arena's fight, not the city sim).
  FRICTION: the evidence run refuses a dirty tree; my first two tries wrote their own log into
  evidence/r5. Logs now go to gtai-n4/scratch-showcase and are copied in after.
- 04:23 replies seen on the lane tips (not merged yet): REQUEST 14 taken by rivet-arsenal
  (412e0906: RivetMagView draws only for a gun without weapon-art's mag part); REQUEST 15 taken
  (rivet-arsenal 1138f143 = my cd49e9fa; brutality 136a8e9a took the react_line spot); REQUEST
  16 taken by gunplay (c4a1aa7b: mini-nuke min_lob_m 13 m). New on the tips: weapon-art's weapon
  wall station (7629aae7) and jagged electro arcs; human-reactions' SWAT look and the robot
  thug's own parts (a27c786b: arena --rigs pit squads mix patrol, riot and SWAT by actor id:
  check against my --riot look next round); brutality's solo kill lab; rivet-arsenal's flamer
  sway.
- Session close: merge round 6 deferred to the next session (12-26 new commits per lane; the
  merge + gates do not fit before 04:42).

NEXT (iteration 5):
1. Merge round 6 (brief order, ONE lane at a time, stop at each conflict). Expect: arena_rigs.gd
   (human-reactions' squad looks vs my RIOT_LOOK/_pit_look: keep one rule; if their pit mix
   already dresses riot cops, --riot keeps only the armored hp), my cd49e9fa vs rivet-arsenal's
   1138f143 (identical hunk), fx_view/gun_fx_art (my mag glue vs gunplay's REQUEST 5 answer, if
   any). Gates under private APPDATAs; run the evidence run with logs OUTSIDE the tree (it
   refuses a dirty tree).
2. Re-film the uniques reel (the nuke now lobs >= 13 m; the stall switch; the zone fix) and the
   64 px/m riot reel; look at 1 fps over each weapon turn.
3. The robot thug beat: human-reactions' ThugPlan + art/thug parts exist now; still no thug in
   CombatArena (robots resolved later per the owner). Film the react_line / enemy rig fight
   thug as a dev-scene insert if the arena cannot host it.
4. Corpse cap (REQUEST 12) and gibs past the wall (REQUEST 13): check the tips for answers.
5. The final round plan (07:45-08:30): export `build/export/windows/RTAI.exe` with the release
   DLL; boot into the arena with every finished weapon (a default --loadout or pickups); write
   the exact play commands for the arena and the city block in REPORT.
- MERGE ROUND 6 started early (04:27-04:33, one lane at a time): weapon-art d33db75b, rivet-arsenal
  412e0906, gunplay acbb8c0c, human-reactions c819d6be, brutality 8218d423 -> f8c0f817.
  Conflicts: JOURNAL.md (ours, every lane); arena_rigs.gd x3 (consts: RIOT_LOOK + rivet-arsenal's
  THROW + FOCUS_REACH_M; gunplay's older focus hunk -> ours; human-reactions' squad looks vs my
  --riot look -> one rule, below); gun_fx_art.gd (gunplay's floor-mark doc + my shells/mags
  signature; their body-scorch filter kept); arena_stations/human-reactions.json doc (ours = the
  human-reactions tip's newer doc). Glue: arena_game._open hit 42 lines (their --crowd/--armored +
  my --riot): the dev flags move to _dev_fight (the pre-commit lint caught it).
  DECISION pit looks: human-reactions' patrol/riot/SWAT mix by actor id stays the default; under
  --riot the shield is worn only by the pit's armored riot cops, and the mix's other riot picks
  dress as patrol (a shield that dies to one pistol round would lie about the armor).
- Gates r6 (f8c0f817): running at session end (unit -> scratch-showcase/unit-r6.log, scenarios ->
  scen-r6.log); results below if they land before 04:42, else NEXT 1.

NEXT (iteration 5) supersedes the list above: 1 = read gtai-n4/scratch-showcase/unit-r6.log and
scen-r6.log (or re-run both), fix reds, copy to evidence/r6, then the evidence run (logs outside
the tree). Then NEXT 2-5 above.
- Unit r6 (f8c0f817): 820/821, FAIL test_gun_fx test_a_reload_drops_the_magazine_and_rows_differ
  (0 magazines, want 1). Cause: gunplay answered weapon-art's REQUEST 5 with GunFx.art_mags (no
  ink stick for a gun whose weapon-art row has a mag part); gunplay's older test assumed the
  pistol has none, true on their branch, not on the merged one. Glue: the test sets
  art_mags = {} (the fallback it means to test); test_gun_fx 9/9. My round-5 FxView mag glue is
  now redundant with gunplay's rule (both skip the same stick); remove it next round once the
  64 px/m reload shows one magazine.
- REQUEST 19 -> gunplay: take the one-line art_mags = {} in test_a_reload_drops_the_magazine...
  (showcase commit after c9a2f1a1), or it fails on every build with weapon-art's magazines.
- GATES r6 (f8c0f817 + the test_gun_fx glue): lint 13/13 (743 files), unit 820/821 before the
  glue (test_gun_fx 9/9 after it; the full suite not re-run), scenarios 39/39
  (evidence/r6/). Not run yet on r6: the full unit suite after the glue, the evidence run
  (selftest), parity (no native change in round 6), the bench, the reels.
- 04:36 session end: all work committed; scratch sheets deleted; frames.json 14 entries, every
  file present. NEXT (iteration 5): 1 = the full unit suite + the evidence run on HEAD (logs
  outside the tree), then re-film the uniques and riot reels on the round 6 build (nuke >= 13 m,
  SWAT/riot squad mix, weapon wall, jagged electro, flamer sway), the bench, then NEXT 3-5 of
  the 04:23 list.
- Glue: committed project/tests/unit/test_rig_variant_swat.gd.uid (Godot made it on import; human-reactions' a27c786b has the .gd without it). REQUEST 20 -> human-reactions: commit your own .uid for it; on a merge conflict the showcase takes yours.

## Iteration 5 (04:37-05:37)
- 04:38 read JOURNAL, git log, the lane tips. Unit r6 on HEAD c497bc60 (the test_gun_fx glue in):
  821/821 (scratch-showcase/unit-r6b.log). GATES r6 complete: lint 13/13, unit 821/821,
  scenarios 39/39.
- MILESTONE 04:43 the director cut (70a1e691), the 04:00 checkpoint's ask:
  `--bot=reel --reel=director --loadout=pistol`. ReelChapters = 16 chapters in the checkpoint's
  order (claw combo, pistol x2 cops, machine pistol on a group of 4, rocket, flamer, electro,
  molotov, katana, chainsaw, plasma sword deflect (the victim shoots, the batted round kills
  him), hand cannon, plasma rifle, ray gun, shards, riot cop (armored hp + shield look, machine
  pistol), mini-nuke on 4 at 15 m), 300-480 ticks each, 5940 ticks = 99 s. ReelDirector is a
  sim-side ArenaHook (CombatReel appends it to stage.hooks): at a chapter's tick it moves the
  last chapter's dead out of frame, stands Rivet on brutality's open solo-lab mark (-36, 2),
  hands him the weapon through RivetCarry.take (the pickup path), spawns the victims singly,
  holds their fire (except the deflect's shooter) and tethers them (1.8 m, the burning run).
  The inputs only read that state, so a director run replays. ReelCaption burns "NN  WEAPON"
  into the top-left corner (ink on cream). Headless: every chapter's victims down (2/2, 2/2,
  4/4, 1 each, riot 1/1, nuke 4/4).
  DECISION director: one mark for every chapter (the dead leave the frame at each chapter start;
  the blood and gibs stay on the floor) over a walk between marks: the checkpoint wants each
  kill isolated, and only (-36, 2) is checked open. Alternative = a mark per chapter (one const).
  Registry: combat-pacing-and-dramatic-arc applied as the checkpoint's order (light -> heavy ->
  the nuke finale; a beat of LOOK_TICKS 45 before each first shot so the victim reads first);
  motion-quality-gating (judge in motion, fixed-fps 60, look at frames of every chapter).
- 04:44 filming reel-0500-director (48 px/m, 5940 ticks).
- 04:44-04:49 reel-0500-director (48 px/m, 99 s, one run on 70a1e691, before the camera).
  Looked at 4 frames per chapter (scratch sheets). Right: every chapter's kill lands and the title
  card reads; claw combo blood fans, pistol two cops drop with sprays, machine pistol drops the
  group of 4, rocket gibs, flamer burns, electro X-ray frame, molotov ring of fire at 7 m (the
  bottle reached the victim on the held fire), deflect: the shooter dies on his own batted round.
  WRONG (mine): (a) the dead and the blood of every earlier chapter stay on the mark (moving a
  dead Fighter does not move its print or its blood), so from chapter 4 every kill plays on a
  gore carpet among old corpses: not isolated; (b) Rivet stands at the frame's left quarter with
  cream paper beyond the arena's west edge in frame; (c) the mini-nuke's blast lands at the
  frame's right edge (15 m), mostly out of frame. Fixes: c0bf84e2 (camera halfway to the
  victims: b and c) and 451f3cd5 (`--chapter=<id>` + evidence/cut.sh: one fresh run per
  chapter, concatenated: a clean floor per kill, and one chapter re-filmable alone).
  Unclear at 640 px: katana/chainsaw halves, hand cannon, ray gun dissolve: judge on the re-cut.
- MERGE ROUND 7 (04:51-04:53): weapon-art 583613dc, rivet-arsenal d58a5c44 (aed92d01), gunplay
  fa4c6cb6, human-reactions 1da7fd7d, brutality c4da86e2 -> 15b48cb4. Conflicts: JOURNAL.md
  (ours); test_gun_fx.gd (gunplay took REQUEST 19 with the same line: theirs);
  test_rig_variant_swat.gd.uid (human-reactions took REQUEST 20: theirs, uid://4ho61ofhybgt).
  REQUESTs 19 and 20 closed.
- 04:54 filming reel-0520-director (cut.sh, 16 fresh runs at 48 px/m) and gates r7 in parallel.
- GATES r7 (15b48cb4, private APPDATAs, parallel): unit 825/825, scenarios 41/41
  (scratch-showcase/unit-r7.log, scen-r7.log). Lint 13/13 (750 files) on every commit since.
- MILESTONE 05:05 reel-0520-director (cut.sh: 16 fresh runs at 48 px/m, fixed-fps 60, 107 s,
  title cards burned by ffmpeg; build 15b48cb4 + the director fixes c0bf84e2..scenario).
  scenario_showcase_director (new): all 16 chapters' victims down, replay identical, planted
  fault (buttons off) kills nobody, 11.7 s.
  Looked at 5 frames per chapter (+ a 6 fps strip for electro and plasma rifle). Reads well:
  clean floor per kill, Rivet on the left third, the title card; pistol two cops fall with
  sprays; machine pistol drops the group of 4 (they fall in one column: stiff but readable);
  rocket smoke trail -> scorch -> six parts thrown with blood trails; flamer jet -> body in
  flames -> char -> ash heap; electro arcs + one X-ray frame -> collapse; molotov ring of fire
  on the victim; katana lunge + cut + blood; chainsaw grind -> halves part up/down; deflect:
  the shooter's round goes back and he drops in blood; hand cannon blows him 6 m back on a long
  smear (the strongest gun chapter); ray gun glow -> pale husk; shards stick -> burst into parts;
  riot cop takes the machine pistol burst and drops; mini-nuke: lob, the comic blast star fills
  the right half, then a ring of fire round four charcoal shadows (the finale reads).
  Wrong: (i) plasma rifle: the bolt rings the chest, the hole shows as a dark disc, and the
  victim reads as still standing for the whole chapter (5 s; brutality's row says he "drops
  back along the shot"); (ii) the riot cop's shield is not readable at 48 px/m (a thin line in
  front of him; nothing blocks); (iii) a figure walks in at the frame's right edge about 5-6 s
  into several chapters (pistol, machine pistol, katana): an arena station actor, not mine to
  move: next cut I trim each chapter at 5 s or find it; (iv) the katana's halves land on
  Rivet's own feet (he lunges to 1.0 m): the cut reads better from 1.6 m (mine: BLADE_M).
- REQUEST 21 -> brutality (cc human-reactions): the plasma rifle `hole` kill does not read as a
  death at 48 px/m: in reel-0520-director chapter 12 (gtai-masters/n4/showcase, 31-36 s of the
  reel; scratch strip gtai-n4/scratch-showcase/sheets/strip-plasma_rifle.png) the victim keeps
  his standing silhouette with a dark disc on the chest for 5 s. A visible drop back along the
  shot (the body flat on the floor, legs toward Rivet) is what the row promises.
- REQUEST 22 -> human-reactions: the riot cop's shield (RIOT_LOOK on an ArenaPit.riot id) is a
  thin line at 48 px/m in reel-0520-director chapter 15; a shield that reads (a slab in front of
  the body, rounds sparking off it before the burst gets round) would sell the armored hp.
