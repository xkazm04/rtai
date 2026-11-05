# JOURNAL: d7-calls (day run 2026-11-05)

## Iteration 2 (BUILD, 15:12-16:12)
- 15:12 Started. No JOURNAL from iteration 1 and no commits past main 1028c15d: starting fresh. Worktree was not
  imported; first `--import` run (evidence/import-it2.log).
- Registry rules applied (generated-asset-world-scale): sprites draw at true scale (size_m = px / 120); a size change
  re-captures the quest 1 sprites rather than a draw_k fudge.
- 15:14 MILESTONE cast-1 16272697: `RivetPlan.FORMS[FORM_BASE].x` 0.97 -> 0.89 (1.1x the crowd span). The old size is
  the new row `FORM_WIDE` (0.97, same arms and legs); back = FORM_BASE.x 0.89 -> 0.97. Ghost plans that hang off
  FORM_BASE (DentPlan, HaulerLook's base) follow; the Hauler tank keeps its absolute size (BODY_SIZE_K 1.2).
- REQUEST held: cast-1 landed at 16272697 (`project/features/characters/rivet_plan.gd` only). Held guns follow
  plan.size_k (`rivet_arsenal.json held_size_ref` 1.2), so guns now draw 0.74x the class held_scale (was 0.81x).
  File split for look-8 (my item 4): I touch `print_part.gdshader`, `part_materials.gd` (the ink / print) and
  `look_d5_part.gdshader`; you own the poses, the held parts, `rivet_arsenal.json` sizes and the cut_rig hold code.
  Tell me in your JOURNAL if you need any of mine.
- 15:21 DECISION cast-8 + cast-9 together: the plain head keeps the core tan (HEAD fill 2 = the core sticker with
  `core_tan`), exactly n5-cast's Call 9 A state (torso, pelvis and helmet at tan 0.6). The owner's "plain cream head"
  reads as "no visor"; a cream head on a tan torso would be a third look nobody judged.
- 15:22 MILESTONE 66bf4fbe cast-8 (HEAD_LOD_FILL 4 -> 2) + cast-9 (CORE_TAN 1.0 -> 0.6), quest 1 sprites re-captured
  at the new size (peek r 50 -> 46 px with the body), CastFlags `--rivet-form=wide --rivet-visor --rivet-tan=1` =
  the old defaults in every rig path (unit test_cast_flags). Evidence `M/frames/cast-1-8-9-city-ab-32-48ppm.png`
  (same tick 420, city block, flags vs none): 32 px/m shows all three; 48 px/m only the size (art tier above
  ~42 px/m, so the head and tone calls do not show there; the brief's "48 px/m for the head and tone" cannot show them).
- FINDING: with cast-1 the pistol in Rivet's claw looks long against his smaller body at 32 px/m (held guns follow
  size_k: 0.74x). The held lane owns held sizes; noted for them.
- FRICTION: `node tools/evidence/run.mjs` refuses a dirty tree (untracked JOURNAL) -> `--allow-dirty`.
- 15:45 MILESTONE cast group gated on 66bf4fbe: evidence run (no bench) lint 13/13, unit 1091/0, scenarios 51,
  parity exact, look goldens 11/11 worst 0.27 + block 5/5 worst 0.22 (no re-bless needed: Rivet is a small part of
  the golden frames); director reel headless 19/19 chapters down, 0 SCRIPT ERROR (evidence/).
- FRICTION: `--write-movie build/x.avi` (relative) fails silently (ERR_CANT_OPEN, resolves against project/);
  use an absolute path. The headless reel never quits by itself: pass `--quit-after 7000`.
- 16:00 MILESTONE look group 42feb65c (+ decision 18137e62): look-3 ink FX (`--fx-colour=on` = colour), look-5 alley
  print off (`--alley-print=on` = before), look-7 paper disc (`--pickup-disc=off` = ring), look-12 shard.png,
  look-14 flame tongues, look-18 cross_k 1.0. Unit 1091/0, lint 13/13, after-reel 0 SCRIPT ERROR. Evidence
  `M/frames/look-3-12-14-reel-ab-32ppm.png`, `M/look-reel-{before,after}-32.mp4`, `M/frames/look-5-alley-ab-32ppm.png`.
- FINDING look-14: the ink flame tongues print vermilion + cream (danger ink: fire is danger, on doctrine); the
  colour cone was yellow-orange. Reads as a strong burst in motion.
- FINDING look-5: at 32 px/m, tick 600, the alley A/B barely differs. Not yet understood: check at 48 px/m (the
  alley's default zoom) and whether the print zone needs Rivet inside its fade.
- NEXT (iteration 3): (1) full gates on 42feb65c (look goldens may move with ink FX? they have no FX, expected
  stable) + reel 19/19; (2) look evidence still owed: the shard in flight (homing_shard chapter, tick 4710-4790,
  pick a frame with the round mid-air), the Gatling held (`--loadout=gatling` or the pit), a pickup on the floor
  (disc vs `--pickup-disc=off`), alley at 48 px/m; check each against the reel and raise a call if one reads worse;
  (3) item 3 Dent: draft `build/patch/ghost_locks.gd` is ready (GhostLocks: on/done/plant_ignore, allows,
  next_after, first); wire into GhostForms (press_next/press_transform/switch_to -> LOCKED), `unlock` field in
  GhostFormDef + ghost_forms.json (dent "dent_act") + schema, Quest1Session sets `pilot.ghosts.forms.locks.on`,
  HUD locked chip, scenario with planted fault, `collect_call_city.json ghost_cars []`, `dent.ride 0` + tether
  check; (4) look-8 tan ink; (5) 20-30 s city clips per group, combined clip, exe by 19:30, REPORT.
- 16:04 MEASURE selftest on 42feb65c (look group): look goldens 11/11 worst 0.27, block 5/5 worst 0.22, same as the
  cast commit: no golden moved, no re-bless (evidence/selftest-it2-look.log). Scenarios and parity still to run on it.

## Iteration 4 (BUILD, 16:06-17:06)
- 16:06 Started. Iteration 3 left no journal lines; picked up NEXT (3) Dent. Registry rule applied
  (realtime-combat-semantics): a locked action answers (Q refused, HUD padlock), never silently.
- 16:10 FRICTION: ran the full scenario suite in the background on 42feb65c while editing the tree; Godot
  loads scenario scripts lazily, so the run mixed my mid-edit Dent files (3 quest1 fails were mine). Deleted
  that log; never edit the tree under a running gate.
- DECISION ghost-powers-3 steering: ride 0 with the old fixed 14 m reticle made the car overshoot the guards
  (quest 1 Dent scenario 0 strikes). Standing, the car now drives to the aimed point at the cursor reach
  (`PlayerCommand.aim_m`; pad = 14 m as before); the seize keeps the 14 m line. One data value back: ride 1.
- DECISION ghost-powers-5: `unlock` per ghost in ghost_forms.json (dent `act_dent`), GhostLocks behind
  GhostForms, on only in Quest1Session (`ghost_locks`, `acts_done`); `--ghosts-free` = old default; quest 1
  ghost_cars [] (fit kept as Quest1GhostStreet.CARS for the quest 1 scenarios that need cars).
- 16:50 MEASURE: lint 13/13, unit 1097/0, scenarios quest1_* 7/7 (incl. new quest1_dent_lock with planted
  fault caught), ghost_attacks 1/1 (Dent blast_gap_m >= 5). Evidence evidence/*-it4-*.log.
- 16:53 MILESTONE e419a047 Dent (ghost-powers-3 + ghost-powers-5), gated as above. Not yet filmed.
- FINDING: n6's `M/frames/dent-ride-ab-32ppm.png` (masters n6/ghost-powers) shows ride 0's stand-off with the
  old fixed point; the reach steer is new and needs its own clip.
- NEXT (iteration 5): (1) Dent evidence: `--arena=city --bot=ghosts --ghost=dent` before (`../d7-held-before`
  or `-- ` with dent.ride 1 restored in a scratch copy) vs after at 32 px/m (tether visible? car responsive?
  Rivet clear?), a 64 px/m close-up of the tether; quest 1 HUD still with the padlock chip (game window,
  title -> Start, G taps) vs `--ghosts-free`; 20-30 s clip in M/. If the tether is thin at 32 px/m, widen it
  in DentView (view only). (2) Full scenario suite + parity on e419a047 (only quest1_* and ghost_attacks ran
  here) via `node tools/evidence/run.mjs --allow-dirty --no-bench`, and the director reel 19/19
  (`--quit-after 7000`). (3) look evidence still owed (shard in flight, Gatling held, pickup disc, alley at
  48 px/m). (4) look-8 tan ink (print_part.gdshader / part_materials.gd; held lane owns poses and sizes).
  (5) frames.json, combined clip, exe by 19:30, REPORT by 19:40 (calls: Dent reach steer vs fixed point;
  quest 1 without ghost cars; look picks that read worse).
- 16:27 MEASURE full evidence on e419a047 (+ journal 41079a05): lint 13/13, scenarios 52/52, parity exact
  (planted caught at 629), look goldens 11/11 worst 0.27 + block 5/5 worst 0.22 (no golden moved: no re-bless),
  unit 1096/1 = `test_noir_shadows` (known flake; 2/2 twice alone). Director reel headless 19/19 chapters down,
  0 SCRIPT ERROR. Evidence evidence/evidence-it4-e419.log, unit-it4-noir-shadows-alone.log, reel-director-it4-dent.log.
- 16:28 MILESTONE Dent evidenced (M = gtai-masters/d7/calls): `frames/ghost-powers-3-dent-ride-ab-32ppm.png`
  (n6 ride clip vs ours, `--arena=city --bot=ghosts --ghost=dent`), `dent-standoff-city-32ppm.mp4` (15 s),
  `frames/ghost-powers-3-dent-tether-32ppm.png`, `dent-standoff-city-64ppm-halfspeed.mp4`,
  `frames/ghost-powers-5-hud-lock-ab.png` (GhostFormHud alone via a scratch -s script in build/patch).
  Looked at each: the tether reads at 32 px/m as a teal line Dent -> car; the car rams the cop group by the
  ambulance and blows about 13 m from Rivet; padlock chip reads at once.
- FINDING: at 64 px/m the camera stays on Dent, so the ram and the blast leave the frame (riding kept the car in
  frame: the owner's trade-off in the call text). Call candidate: camera lead toward the seized car while Dent
  steers (view only).
- FINDING: quest 1's opening voice lines fold the ghost card to one chip for the first ~25 s, so the padlock is
  first seen when the card unfolds (after the lines) - not a bug, the compact rule.
- FRICTION: quest1_shipped_main.gd takes no user args through `-s`; the HUD still came from a scratch scene.
- 16:30 look-8 started. Registry rule applied (sprite-and-atlas-production / depth-ordered-layered-art: separate a
  held prop from the body by value, keep the ink rim). Target r1_w1: the guns' plates ~ (176,160,128), ink grips.
- DECISION look-8: PartKind.GUN + print_part `gun_tan` (paper -> GUN_TAN_HI, mid -> GUN_TAN..DK) and `gun_ink_hi`
  0.95 on guns. FINDING on the way: at 48 px/m the pistol art posterized to solid ink, so the first version (tan
  wash only) changed one highlight dot; 0.86 still mostly ink; 0.95 reads tan with ink grip, like the sheet.
  `--gun-grey` = before. Melee in the claw keeps PART (pilot.wielding()).
- REQUEST held: look-8 touches your `project/features/player/rivet_held_view.gd` in two lines only: `_swap`'s
  `_sprite.material = PartMaterials.get_mat(_print_kind(), false, 0)` and the back tank's material
  (`PartKind.GUN`), plus a new 4-line `_print_kind()` at the end of the file (299 lines now on my branch). Keep them
  when you merge; everything else in that file stays yours.
- 16:44 FINDING look-8 at 32 px/m (`M/frames/look-8-gun-tan-ab-32ppm.png`, director reel tick 450): the tan pistol
  stays apart from Rivet's cream core and collar (no merge), but loses most of its ink silhouette and reads paler
  on the grey concrete than the grey print did. Pick kept (the owner's tan); CALL for REPORT: tan (built) vs grey
  (`--gun-grey`), and a middle option = `gun_ink_hi` 0.86 (more ink, less tan) - one shader value.
  At 48 px/m (`look-8-gun-tan-ab-48ppm.png`) the tan reads like the weapon sheet, with ink grip and details.

## Iteration 5 (BUILD, 16:42-17:42)
- 16:42 Started (restart for the 18:40 report). Uncommitted: iteration 4's look-8 (sound, gates not yet run).
- FINDING look-8 in my own still (dev arena `res://dev/arena/arena.tscn -- --bot=reel --reel=director
  --loadout=pistol --ppm=32 --shot=<abs png> --shot-tick=450`; the game path ignores --shot): with
  gun_ink_hi 0.95 the tan gun lost the grey print's ink rim and the grip/muzzle marks: a tan blob.
- DECISION look-8 (brief: "ink outline kept"): guns draw their own ink outline from the alpha edge at every
  zoom (`gun_edge` 2.2 screen px). FRICTION: the limbs' radius (TEXTURE_PIXEL_SIZE / px_scale) was sub-pixel on
  the held gun (its texel density is not the body's px_scale): radius from the screen-space UV step (dFdx/dFdy).
  `gun_ink_hi` 0.95 -> 0.90 so grip and muzzle stay ink. Result reads like the weapon sheets (tan plates, ink grip,
  ink outline), a value step below the light-tan body: no merge at 32 or 48 px/m.
- 16:50 MILESTONE 83fe0d5c look-8, lint 13/13, unit 1097/0, director reel at 32 px/m every chapter down
  (rocket and flamethrower print tan too). Evidence M/frames/look-8-gun-tan-ab-32ppm.png, -ab-48ppm.png,
  look-8-gun-tan-closeup-steps.png (grey | 0.95 | final), M/look-8-gun-tan-reel-32ppm.mp4 (30 s).
- REQUEST held: look-8 landed at 83fe0d5c: `print_part.gdshader`, `part_materials.gd`, `cast_flags.gd`, and the
  two material lines + `_print_kind()` in your `rivet_held_view.gd` (as at 16:44). Your off-claw-blends finding:
  a gun is now tan + ink, so a pale claw on it separates better; `claw_grip` tone is yours.
- 17:00 MEASURE full evidence on 83fe0d5c (`evidence/evidence-it5-look8.log`): lint 13/13, unit 1097/0, scenarios
  52/52, parity exact (planted caught at 629), look goldens 11/11 worst 0.27 + block 5/5 worst 0.22: no golden
  moved by look-8 either, so no re-bless for any of my calls.
- 17:05 MILESTONE look group in motion (owed since iteration 2), all at 32 px/m, M/frames:
  look-7-pickup-disc-ab-32ppm.png (`--armory`, plain arena; the city hub's react-line cops stand on the armory
  row and hide it), look-12-shard-ab-32ppm.png and look-18-gatling-ab-32ppm.png (range station
  `--weapon=<id> --bot=range`; before = weapon_art.json flipped in the tree for the run, then `git checkout`).
  Looked at each: the paper disc separates every pickup at once (the dashed ring nearly vanishes on the grey);
  the lozenge reads as a clean cream dart with an ink shadow, plainer than the barbed arrow but not weaker;
  the Gatling is visibly slimmer. None reads worse: no "worse in motion" call needed.
- FINDING look-8 x Gatling: below `held_small_below_ppm` 56 the held gun is `parts.small` (held_small.py's
  pre-inked silhouette); the Gatling's small art is 63 % near-black, so it prints ink, not tan, at 32 px/m (the
  pistol 38 %, rocket 33 %: tan). Not fixed (late, and the small parts are the held lane's re-tone): a call.
- MILESTONE combined clip `M/today-defaults-city-32ppm.mp4` (28 s, city block, director reel: pistol, machine
  pistol, rocket, flamethrower; every chapter of the 6900-tick run down, 0 SCRIPT ERROR). frames.json 14 entries.
- 17:07 MILESTONE exe: `build/export/windows/RTAI.exe` (windows-showcase; boots: no args = armory 16 weapons,
  `-- --bot=reel --reel=director --loadout=pistol`, `-- --arena=city --bot=ghosts --ghost=dent`, all 0 SCRIPT
  ERROR) and `build/export/windows-quest1/RTAI.exe` (windows-slice, quest 1: boots to the title, 0 SCRIPT ERROR).
  Logs evidence/export-it5*.log, exe-boot-it5-*.log. FINDING: headless exe reel with --quit-after 3000 logged
  only 3 chapters down (headless frame pacing; the windowed dev reel downs all 19).
- 17:09 look-5 at 48 px/m (`M/frames/look-5-alley-ab-48ppm.png`, `--start=alley`): the pale paper is a clear
  value step at the alley's own zoom (at 32 px/m it was small). REPORT call 6 filled in.
