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
- 17:11 FINDING Dent camera: the lead the 16:28 finding asked for already exists as the dev flag `--cam=car`
  (DentView.follow_cam via TonnageHook: midpoint of Rivet and the seized car, 1 s hold on the blast). At 64 px/m
  with it the tether, the ram into the cops and the blast stay in frame (`M/dent-carcam-city-64ppm.mp4`,
  `M/frames/ghost-powers-3-dent-carcam-64ppm.png`). Not made the default (not an owner pick; at 32 px/m the
  default framing already holds the blast): REPORT call 2 option B with the flag.
- 17:16 MILESTONE ghost-powers-5 live: `dev/ghost-forms/quest1_forms_main.gd` (real input events on the shipped
  boot/quest1.tscn; `Quest1Session.ghost_locks` defaults true) recorded: G at frame 520 goes Tonnage -> Kerf
  (Dent skipped), and the unfolded card (frame 920) shows Dent's slot as the dimmed padlock.
  `M/frames/ghost-powers-5-quest1-live.png`, `M/quest1-dent-locked-live.mp4` (12 s). Replaces the scratch-scene
  HUD still as the lead evidence. frames.json 15 entries, all present.
- 17:17 city director reel on 83fe0d5c: 19/19 chapters down, 0 SCRIPT ERROR (`evidence/reel-director-city-it5.log`).
  REPORT status complete (all calls built, gated, filmed; exe exported at ecb8a675, project tree unchanged since
  83fe0d5c: only docs commits after it, so the exe is current).
- 17:19 FINDING/FIX: proofreading the REPORT's exe lines, `--ghosts-free` turned out dead in the game:
  quest1_game reads it via `LaunchArgs.has()`, which answers only for KNOWN_FLAGS (boot logs others as unknown).
  2a28d331 adds it + the cast old-default flags to KNOWN_FLAGS, unit case with a planted fault (removed -> 1
  failing), unit 1098/0, lint 13/13, CORRECTION line in decisions. Lesson: an exe flag is not proven until it
  is seen working in the exe (the scenarios set `Quest1Session.ghost_locks` directly, so they never saw it).
- 17:22 exes re-exported on 2a28d331 (showcase + quest 1 slice); quest 1 boots with `-- --ghosts-free`, no unknown
  arg, 0 SCRIPT ERROR; showcase boots to the armory.
- NEXT (any later session, freeze 18:30): (1) if the branch is unchanged, nothing to build: the REPORT is complete
  and the exes current (2a28d331). (2) If time: the Gatling's dark small art (REPORT call 8) is the weakest
  look (held lane's held_small.py, or a per-weapon gun_ink_hi via a GUN_DARK kind + a weapon_art.json flag:
  schema, test, re-film). (3) Re-run the scenario suite if anything under project/ moves; re-export both exes
  (`--export-release windows-showcase ../build/export/windows/RTAI.exe`, `windows-slice
  ../build/export/windows-quest1/RTAI.exe`) and boot-test them.
- 17:25 MEASURE scenarios on 2a28d331: 52 ran, 0 failed (evidence/scenarios-it5-flags.log). Session ends here.

## Iteration 5b (BUILD, 17:26-18:26; freeze 18:30)
- 17:26 Started. Tree clean at 339397ef; branch complete per NEXT. Held lane: no new REQUEST for calls (their
  17:09 merge took ecb8a675; exe at 5bbc95b5). Picked NEXT (2): the Gatling's dark small art (REPORT call 8).
- Rules applied (sprite-and-atlas-production / motion-quality-gating): fix at the asset that is drawn at the
  judged zoom, judge at 32 and 48 px/m in the game path, same tick before/after, keep the old art one git show away.
- FINDING root cause (two): `held_small.py` EDGE 9 part px inked the ~14 px barrels solid (63 % near-black), and
  the 4 px transparent gaps between barrels let the print's `gun_edge` probe (held textures: no mipmaps) ink the
  whole bundle. Fixing only the edge (3 px) changed nothing at 32 px/m: the gaps did it.
- DECISION per-weapon `EDGE_OF {"gatling": 3}`, `CLOSE_OF {"gatling": 6}` (closing fills the barrel gaps with
  the body's median steel before the re-tone). Gatling only; pistol re-run byte-identical; the tool reproduces
  the old Gatling with the old values. FRICTION: combo_clip.gd is melee-only (6077 SCRIPT ERROR with a gun, not
  my change); the plain `dev/arena/arena.tscn -- --loadout=gatling --ppm=<p> --shot=<abs> --shot-tick=120` works.
- 17:36 MILESTONE 6179bf2d. 48 px/m: tan steel bundle inside one ink outline (was ink/cream stripes). 32 px/m:
  only a sliver of tan (the ~6 px bundle loses 2.2 px outline per side). Probe gun_edge 1.4: tan reads at
  32 px/m but the outline breaks and every gun changes: not built, a call. Lint 13/13, unit 1098/0.
  Evidence M/frames/look-8-gatling-small-ab-32ppm.png, -ab-48ppm.png, look-8-gatling-edge-steps-32ppm.png.
- REQUEST held: 6179bf2d regenerates `gatling/held_small.png` via `tools/art/held_small.py` (new per-weapon
  EDGE_OF / CLOSE_OF; Gatling only, every other small art unchanged). Neither file is in your diff; if you
  re-run held_small.py for any weapon, keep those two dicts.
- 17:37 MEASURE scenarios on 6179bf2d: 52 ran, 0 failed, 0 SCRIPT ERROR (evidence/scenarios-it5-gatling.log).
- 17:38 MILESTONE Gatling in motion: `--loadout=gatling --weapon=gatling --bot=range` 18 s at 32 and 48 px/m
  (M/look-8-gatling-range-{32,48}ppm.mp4, 0 SCRIPT ERROR); firing close-up M/frames/look-8-gatling-firing-48ppm-
  closeup.png: tan steel bundle, ink outline, casings. frames.json: + the 48 A/B and the 48 clip; dropped the
  cast quest 1 sprite still and the Dent 64 half-speed clip from the list (files kept: REPORT cites them). 15 entries.
- 17:39 exes re-exported on 6179bf2d (showcase + quest 1 slice, exit 0); headless boots 0 SCRIPT ERROR, 0 unknown
  arg; showcase logs "Rivet holds the table gatling". REPORT: row, gates, exe line, "does not work", call 8 (A built,
  B gun_edge 1.4, C old art), next steps. f41346c2.
- READ held JOURNAL 17:41: they merged d7-calls up to 339397ef (exe acb70e5f); my 6179bf2d REQUEST is new for them.
- 17:42 full evidence run (--no-bench) on f41346c2 started (last one was on 83fe0d5c).
- 17:47 MEASURE full evidence run on f41346c2 green (evidence/evidence-it5b-head.log): lint 13/13, unit 1098/0, scenarios 52, parity exact (planted 629), goldens 11/11 worst 0.27 + block 5/5 worst 0.22. No re-bless.
- 17:52 MEASURE city director reel on a4af468e (`res://dev/arena/arena.tscn -- --arena=city --bot=reel --reel=director --loadout=pistol`, --fixed-fps 60 --quit-after 7000): 19/19 chapters down, 0 SCRIPT ERROR. FRICTION: without the scene path the args go to the boot scene (unknown launch arg).
- 17:58 MILESTONE Gatling in the city block (`res://dev/arena/arena.tscn -- --arena=city --loadout=gatling --ppm=<p>
  --shot=<abs> --shot-tick=150`), before = the 2a28d331 art swapped in, then restored and re-imported (md5 checked):
  M/frames/look-8-gatling-city-ab-48ppm.png (ink bar with cream dashes -> tan steel, one ink outline: clear win),
  -city-ab-32ppm.png (broken dashes -> a clean ink rod with a tan sliver: cleaner, still mostly ink = call 8).
  frames.json lead Gatling entry now the city pair (game-city). FRICTION: the weapon PNGs are Git LFS:
  `git show <sha>:<png> > file` writes the pointer text (Godot: ERR_FILE_CORRUPT, .import goes valid=false); use
  `git show <sha>:<png> | git lfs smudge > file`. The first before pair was void and discarded.
- 18:00 Session wrap. Branch head is docs-only since 6179bf2d (the last project/ change); exes exported on
  6179bf2d are current; full evidence run green on f41346c2; city reel 19/19 on a4af468e.
- NEXT (any later session, freeze 18:30, report 18:40): (1) nothing owed: REPORT complete, exes current. (2) If
  `project/` moves: gates, re-export both exes (`--export-release windows-showcase ../build/export/windows/RTAI.exe`,
  `windows-slice ../build/export/windows-quest1/RTAI.exe`), boot-test, update the REPORT exe sha. (3) Only on the
  owner's call 8 B: a per-weapon gun outline (new appended PartKind + a weapon_art.json value, set from HeldLod or
  WeaponArt.make_held, NOT rivet_held_view.gd: it is at 299 lines and the held lane's file). (4) Old weapon PNGs:
  `git show <sha>:<png> | git lfs smudge`.

## Iteration 6 (BUILD, 17:59-18:30; freeze 18:30)
- 17:59 Started. Tree clean at 18b94432; NEXT says nothing owed. Held lane: no new REQUEST for calls.
- GAP the combined defaults clip (17:04, director reel) has no Gatling chapter, so the 6179bf2d Gatling art was
  filmed only in the arena (range) and as city stills. Filled it with a city-block clip, no project/ change.
- 18:01 MILESTONE `M/look-8-gatling-city-32ppm.mp4` (25 s, `res://dev/arena/arena.tscn -- --arena=city
  --loadout=gatling --weapon=gatling --bot=gunplay --ppm=32`, --fixed-fps 60 --quit-after 1500, 0 SCRIPT ERROR,
  5 kills). Looked at a 4-tile grid + a 3x crop at ticks ~810-870 (`M/frames/look-8-gatling-city-firing-32ppm-x3.png`):
  the Gatling reads as a long tan-and-ink rod with casings flying; blood red, cops blue. The vermilion streak there
  is an incoming enemy round (non-Rivet tracers have a VERMILION core, gun_fx_art.gd:92): danger colour, per verdict.
  frames.json: + the clip (index 2), - look-8-gun-tan-closeup-steps.png (file kept: REPORT cites it). 15 entries.
- NEXT (any later session): nothing owed; exes current on 6179bf2d (branch head docs-only since). See iteration 5b NEXT.
- 18:04 MEASURE arena director reel on fcaec312 (project/ = 6179bf2d; `res://dev/arena/arena.tscn -- --bot=reel
  --reel=director --loadout=pistol`, headless --fixed-fps 60 --quit-after 7000): 19/19 chapters, every one fully
  down, 0 SCRIPT ERROR, 0 unknown arg (evidence/reel-director-arena-it6.log). Combat holds in both the arena and the city.
- 18:07 PROOF exe (6179bf2d): `RTAI.exe -- --arena=city --loadout=gatling --weapon=gatling --bot=gunplay --ppm=32`
  headless 600 ticks: exit 0, 0 SCRIPT ERROR, 0 unknown arg, Rivet holds the gatling (5 "spawn in a building,
  dropped" lines are the same in the dev run: pre-existing). Line added to REPORT's exe section.
- NEXT (any later session): nothing owed. Branch head docs-only since 6179bf2d; exes current; arena + city reels
  19/19; full evidence green on f41346c2. Owner verdicts on REPORT's calls drive the next lane day (call 8 B first
  if picked: per-weapon gun outline, see iteration 5b NEXT (3)).

## Iteration 7 (BUILD, 18:08-18:30; freeze 18:30)
- 18:08 Started. Tree clean at 705784fa; NEXT says nothing owed. Exes (17:39) are on 6179bf2d = the last project/ commit: current.
- 18:10 CHECK evidence folder: frames.json 15 entries, every file present; the 20 files outside frames.json are all
  cited in REPORT, JOURNAL or decisions.md (kept).
- 18:13 CHECK merge readiness: d7-held merged d7-calls bf7386aa (1550dfb0, after 6179bf2d), so it holds every
  project/ change here. `git merge-tree --write-tree d7-calls d7-held` (4a34d9ef): conflicts only JOURNAL.md and
  REPORT.md (root, each lane keeps its own). Noted in REPORT for the Director.
- NEXT (the next lane day): nothing owed today. Owner verdicts on REPORT's calls; call 8 B first if picked (per-weapon
  gun outline, iteration 5b NEXT (3)). If project/ moves: gates, re-export both exes, update the REPORT sha.
- 18:12 REQUEST held (FYI, no action needed from calls): your 1550dfb0 merged 6179bf2d (Gatling tan steel) after
  your exe (acb70e5f) and after your last full evidence run (65c15aa0); if time allows before 18:30, a unit run and an
  exe re-export on 4a34d9ef carry it. Otherwise the Director's merge carries it: my exe on 6179bf2d already shows it.
