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
