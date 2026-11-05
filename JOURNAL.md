# JOURNAL: lane ghost-forms (branch `n6-ghost-forms`), night 2026-11-04/05

Evidence: `C:\Users\kazda\kiro\gtai-masters\n6\ghost-forms\` (M:) and `evidence/` in this worktree (E:).

## Iteration 1 (23:50-00:50, BUILD)
- 23:50 read TARGETS.md (the ghosts section + the Tonnage concept), the eve ghost-powers REPORT, n5-cast and n5-look
  JOURNALs (no REQUEST to ghost-forms; n6-ghost-powers has no JOURNAL yet), `features/souls/**`, powers.json,
  RivetPlan.FORMS.
- 23:52 MERGE n5-cast tip `f96fe0dd` into this branch (clean): the slim hybrid Rivet is the base every
  transformation starts and ends on.
- 23:55 Tonnage part sheet job started (Codex image_gen, `M:gen/r1/jobs.json` `tonnage_parts`, refs: the Tonnage
  concept + n5-cast's hybrid head sheet for the ink/fill style), runner `M:gen/gen.mjs` (copy of gtai-art/gen.mjs,
  lock tag `ghost-forms`), under `gtai-n5/image.lock`.

### REQUEST 1 to n6-ghost-powers: the form interface (proposal, 23:58; ghost-forms builds to it now)
1. **Form ids:** `base`, `tonnage`, `dent`, `kerf`, `ohm`. Data: `data/tables/ghost_forms.json`
   (`gtai.ghost_forms/1`, owned by ghost-forms). Each form row names its cost row in powers.json by `power`:
   `tonnage -> hauler`, `dent -> gearbox` (the old ids stay as the power ids = the aliases until the morning merge,
   so saves, quest 1 and HaulerStage keep working), `kerf -> kerf`, `ohm -> ohm` (ghost-forms adds those two
   rows to powers.json: duration, cooldown, madness only; attack tuning blocks are yours).
2. **State machine:** `GhostForms` (`features/souls/ghost_forms.gd`, RefCounted, 60 Hz ticks):
   `base -> entering -> form -> exiting -> base`, and `form -> switching -> form'` (a teal flash, no base pass).
   Signals: `form_entering(from, to, ticks)`, `form_entered(id)`, `form_exiting(id, ticks)`,
   `form_exited(id)`. `current()` is the settled form id (`base` while a transformation runs = no attacks then);
   attacks may fire only while `settled()` is true and `current() != &"base"`.
3. **Anchors** (`anchor(id) -> Vector2`, metres in the body frame: +x = forward/facing, +y = right), from the
   form row's `anchors`: Tonnage `press_head`; Dent `hand_l`, `hand_r`; Kerf `emitter_l`, `emitter_r`, `lens`;
   Ohm `electrode_l`, `electrode_r`. World point = `pos + anchor.rotated(facing_angle)`.
4. **Footprint and speed:** each form row's `radius_m`, `body_class`, `top_mps`, `accel_mps2`, `turn_dps`.
   Tonnage keeps `rivet_ghost` (bodies.json) until a bigger class lands.
5. **Input:** Q / LB (`power_hauler`, bit 7) = transform into the selected ghost, or back to base;
   G / RB (`power_gearbox`, bit 8) = select the next ghost (in base), or switch straight to it (in a form).
   The attack inputs (melee/fire bits) belong to the ghost-powers lane while a form is settled.
   If you need another split, write a REQUEST; I will move the input to match.
- 00:00 FRICTION the n5-cast merge brought n5-cast's root JOURNAL.md and REPORT.md; this file replaces that
  JOURNAL on this branch (Director: take n5-cast's on the morning merge, move ours to docs/night/2026-11-05/ghost-forms/).
- 00:01 FIX (shared tool) `tools/lint/lint.mjs` runs gdformat/gdlint in chunks of 200 files: with 4 new .gd files
  the single command line passed Windows' 32 767-char limit and gdformat read as a silent FAIL on a clean tree.
  Every lane adding files will hit this; commit 19969979 is a clean cherry-pick.
- MILESTONE 00:02 873056e0 GhostForms state machine + `ghost_forms.json` (+ schema) + powers.json rows kerf/ohm +
  `SoulPowers.release()`. Unit `test_ghost_forms` 7/7 incl. the planted mid-transformation switch caught by check().
  Tuning (each form worth using; Rivet walks 6.75 m/s): Tonnage 4.2 m/s accel 5 turn 120, r 1.3 m, size 3.0,
  enter 0.9 / exit 0.7 s, cost 25 madness / 8 s / cd 20; Dent 7.0 accel 14, enter 0.6; Kerf 12.0 accel 40 turn
  720, enter 0.5, cost 20 / 6 s / cd 10; Ohm 4.5 accel 12, size 0.8, enter 0.7, cost 20 / 8 s / cd 14.
  switch_s 0.35. Registry rules applied: `motion-quality-gating` (judge the transformation in motion at game
  zoom, a key strip + a clip), `generated-asset-world-scale` (parts sized in metres against Rivet's footprint in
  the rig, not by the sheet's px), `sprite-and-atlas-production` (judge the part at its 32 px/m size: the print
  A/B below).
- 00:03 Tonnage sheet back (58 s, image.lock taken and released by the runner). Cut by `tools/art/ghost_parts.py`.
- MILESTONE 00:08 eb1e0136 TonnageRig (crown 2.3 m, legs out to the corners at 1.5 m, hazard brow, hoses, teal
  glow; stamp gait). DECISION raw art (print_parts off): the shared print inked the crown solid at 32 px/m
  (`M:frames/tonnage-print-ab-32ppm.png`). Composite beside the concept: `M:frames/tonnage-rig-vs-target-64-32ppm.png`.
  Judged: the top view matches the concept's top-right drawing (square slab, four corner feet, hoses); the body
  is gunmetal where the concept's ghost is teal all over; the teal is seams + glow (brief: "the machine body
  printed in the game's ink look, with teal soul seams and glow").
- MILESTONE 00:11 686dd22a GhostMorphFx + `forms_lineup --morph` (real GhostForms + SoulPowers): clips
  `M:tonnage-morph-32ppm.mp4` (5.5 s, x3 nearest), `M:tonnage-morph-64ppm-slow3x.mp4`; strips
  `M:frames/tonnage-morph-strip-32ppm.png`, `M:frames/tonnage-morph-64ppm-keys.png`. 0 SCRIPT ERROR, both Q
  presses `ok`. Judged: burst, seams, unfold and the collapse back read at 32 px/m. Weak: the steam puffs read as
  flat grey bubbles; the in-between pose (the collapsed press under the radial seams) is a clump, not a clear
  plate-folding read; the seams are radial lines, not along the plates.

### REPLY to n6-ghost-powers REQUEST 1 (00:14)
Adopt my REQUEST 1 above; the differences from yours:
- Base is `base` (not `rivet`). `GhostForms.form_id()` (= `current()`) returns the settled form, `base` during a
  transformation. Attacks only while `settled()` and `form_id() != &"base"`.
- SoulPowers' `started/ended` stay and still carry the POWER id (`hauler`, `gearbox`, `kerf`, `ohm`);
  `GhostFormTable.form_of_power(id)` maps it to the form id. Or listen to `GhostForms.form_entered(id)` /
  `form_exited(id)` (form ids).
- Anchors live in `ghost_forms.json` `anchors` (read `GhostFormDef.anchor(name)`): tonnage `press_head` (1.55, 0)
  (the brow's front edge on the 2.3 m crown; your slam centre may sit further ahead), dent `hand_l`/`hand_r`
  (0.42, -+0.36), kerf `emitter_l`/`emitter_r` (0.55, -+0.32) + `lens` (0.3, 0), ohm `electrode_l`/`electrode_r`
  (0.38, -+0.1). Tell me if you want other names; one data edit.
- Footprint: Tonnage's row says `radius_m` 1.3 (the drawn crown + feet are about 3.2 m across); its body class
  stays `rivet_ghost` (0.9 m in bodies.json) until one of us lands a bigger class: yours to pick if your slam
  needs it, I will match the row.
- Your `ghost_attacks.json` split is fine; I own powers.json rows (madness, duration, cooldown).

- 00:16 MERGE n6-ghost-powers 848b521c (385b710f): Tonnage's attacks, TonnageHook/TonnageView on `hauler_pad`,
  ghost_attacks.json. One conflict, `tools/lint/lint.mjs`: both lanes fixed the same chunked-gd bug; took theirs.
  Unit on the merge: 952/0 (`E/unit-iter1-merge.log`).
- 00:18 FINDING (for the live path, next session): the arena print path draws Tonnage's attack marks
  (TonnageView on the actor layer via TonnageHook.attach_view), but Rivet's body while transformed is still the
  HaulerLook-grown cut rig (cast_view.gd for quest 1's capture; the arena rig path not yet traced). To show
  TonnageRig live: a GhostFormView on the same actor layer (z beside TonnageView) that reads
  `stage.pilot.hauler.form.morph_k()` (or a GhostForms on the pilot), draws TonnageRig + GhostMorphFx at
  `arena.rivet.pos` facing `rivet.facing`, and the arena's Rivet rig feed skips Rivet while the form is big.
- MILESTONE 00:26 f9bc66f0 GhostFormHud (D5 card: four chips with each ghost's mark, the current form in teal,
  the selected ghost with the chevron + key hint, the cooldown ink sweep, the Madness bar with the selected cost
  notch). Evidence `M:frames/hud-base-tonnage-cooldown.png` (base, Tonnage on, Tonnage cooling). Unit 1/1.
  The first pass crowded the names (GAP 64 -> 84 px).
- 00:27 COMBAT CHECK started: director reel headless 7200 ticks (`E/director-reel-iter1.log`).

NEXT (iteration 2), Tonnage first (depth before breadth), then Dent:
1. Merge n5-cast's tip if it moved (expect a JOURNAL.md/REPORT.md conflict: keep ours), and n6-ghost-powers'.
2. Tonnage LIVE: GhostForms on StagePilot (Q = press_transform, G = press_next, replacing HaulerStage's own
   `try_activate(&"hauler")`; coordinate with ghost-powers, who own HaulerStage's attack logic: put GhostForms
   in front, keep `powers` shared, HaulerForm still listens to `started/ended` of `hauler`). Then the
   GhostFormView above (TonnageRig + GhostMorphFx, hide Rivet's rig while big, camera beat through the arena
   CameraRig budget), GhostFormHud on the arena HUD layer. Proof: 15-20 s clip at 32 px/m in `--arena`
   (walk, Q in, stamp, slam, Q out) and once in `--arena=city`; 64 px/m slow close-up; target composite.
3. Tonnage polish: steam as ink-rimmed lumpy puffs (not grey discs); seams along the crown's plate lines (not
   radial); the in-between pose as plates folding (crown halves + press head shut over the legs); stamp dust
   ring + teal glint on each `stamped`; the crown a touch lighter at 32 px/m (judge beside r2_a5).
4. A determinism scenario: GhostForms through enter/switch/exit inside the replay path (replay identical); the
   forms are input-driven, so a replay with Q/G presses must reproduce the history log byte for byte.
5. Dent: part sheet (crash-test dummy from above: target discs on head and shoulders, seatbelt harness, dented
   plates, teal seams), DentRig on the humanoid CutRig if the parts fit Rivet's part names (a new RivetPlan-like
   plan with art_dir `souls/dent`), stagger gait, the transformation through GhostMorphFx (shared), the G switch
   Tonnage <-> Dent through the teal flash.
- 00:28 COMBAT CHECK (partial) `E/director-reel-iter1.log`: `--quit-after 7200` counts engine frames, not sim
  ticks, so the run ended at sim tick ~2700: 8 of 16 chapters started, the 7 finished all down (claw_combo 2/2,
  pistol 2/2, machine_pistol 4/4, rocket_launcher 1/1, flamethrower 1/1, electro_gun 1/1, molotov 1/1),
  0 SCRIPT ERROR, exit 0. FRICTION: the reel needs `--quit-after` about 3x the tick count headless. Full re-run
  started (`--quit-after 24000`, `E/director-reel-iter1-full.log`).
- 00:30 unit `test_ghost_forms` 8/8: + determinism (one Q/G script run twice gives the same history tick for
  tick). Not yet in the replay path (GhostForms is not wired into the sim; NEXT item 4).
- 00:32 COMBAT CHECK (full) `E/director-reel-iter1-full.log` (`--quit-after 24000`, headless, on 513376e6 = the
  merged ghost-powers tree + all of this lane): 16 chapters started, 16 down (claw_combo 2/2, pistol 2/2,
  machine_pistol 4/4, rocket .. riot_cop 1/1, mini_nuke 4/4), 0 SCRIPT ERROR, exit 0. Combat holds.
- 00:33 MILESTONE morph v2 (GhostMorphFx): steam as lumpy cream puffs under one ink rim, shrinking (v1's fading
  puffs printed as grey discs); seams along the crown's plate grid (a cross + an inset square) instead of radial
  spokes. A/B `M:frames/tonnage-morph-64ppm-keys-ab.png` (v1 top, v2 bottom, same ticks); both clips and the
  32 px/m strip re-cut on v2. Still weak: the late steam lobes shrink to small ink rings (frame 3); the in-between
  pose is still the scaled-down press (no plate folding). frames.json 8 entries, every file checked present.
- 00:37 SCENARIOS on 58e885ac: 46 ran, 0 failed, exit 0, 0 SCRIPT ERROR (`E/scenarios-iter1.log`; replay identical
  where reported). Gates this session: lint 13/13, unit 952/0 (merge tree) + test_ghost* 11/11 after, scenarios
  46/0, director reel 16/16. Parity and the evidence runner not run (no native or sim change by this lane).
Session state 00:38: head = this commit, tree clean, no Godot process of mine running, image.lock released by the
  runner at 00:03 (one job, 58 s). NEXT (iteration 2) is the list above (00:27), item 3 now: the in-between pose as
  plates folding + stamp dust; steam and seams are done (v2).

## Iteration 2 (00:39-01:39, BUILD)
- 00:40 MERGE n5-cast 91aac1aa (18f49782: plan-view peds, re-blessed look goldens) and n6-ghost-powers b4634624
  (087898ae: Dent's attacks, DentView, DentBeat). JOURNAL.md/REPORT.md kept ours both times; lint 13/13 on both.
- MILESTONE 56406f67 GhostPilot (features/souls/ghost_pilot.gd) on StagePilot: one SoulPowers behind GhostForms,
  HaulerStage + DentStage `share()` it (their own activate/tick skipped; Dent's let-go never ends the form).
  Q = transform / back, G = pick next (base) / switch (form). Attacks only while settled (ghost-powers REQUEST 2
  items 1-3 done here: the Tonnage gate, Dent seize on fire, one power at a time). DentBeat re-timed: G at 40,
  Q at 42, fire at 80. test_hauler_stage waits enter_s before the stomp; new test_ghost_pilot 4/4 (enter/settle,
  switch + exit + check(), mid-morph refusal, Kerf faster than the walk). scenario_ghost_attacks 1/0.
  DECISIONs (decisions.md): the input (Q/G, rejected radial + key-per-form), one SoulPowers for every ghost.
- GhostFormView (features/souls/ghost_form_view.gd) attached by ArenaRigs (one line): TonnageRig + GhostMorphFx on
  the actor layer at Rivet's pose; Rivet's CutRig + RivetHeldView/WeaponMagView hidden while the big body stands in;
  the gait on sim ticks (lint SIM-01 caught a frame-delta read).
- 00:52 PROOF Tonnage live, `--bot=ghosts` windowed 1000 frames: arena 32 and 64 px/m and `--arena=city` 32 px/m,
  each 10/10 down, 0 SCRIPT ERROR (`E/ghosts-tonnage-live-32.json`, `-64`, `E/ghosts-tonnage-city-32.json`).
  M: `tonnage-live-arena-32ppm.mp4` (16 s), `tonnage-live-arena-64ppm-slow3x.mp4`, `tonnage-live-city-32ppm.mp4`,
  `frames/tonnage-live-before-after-target-32ppm.png` (ghost-powers' before at the same ticks | after | concept),
  `frames/tonnage-live-arena-64ppm-keys.png`, `frames/tonnage-live-city-wave2-32ppm.png`. First film showed Rivet's
  gun drawn on top of the press: fixed (held/mag views hidden while big). Judged: the press reads as a 3x body among
  the cops at 32 px/m and turns onto wave 2 in the city; the slam now lands ~54 ticks later than before (attacks
  wait for the settled form). Not done: the camera beat (GhostFormView.beat_zoom is computed, no host reads it yet).
- 01:00 unit gate on 94b7c56d: 955 passed, 4 failed assertions, all in ghost-powers' test_tonnage_attacks (the slam
  test pressed melee straight after Q): it now waits enter_ticks (the attacks wait for the settled form). Re-run
  test_tonnage* 2/2, test_ghost* 15/15.
- MILESTONE GhostFormView: the camera beat = one CameraRig shake at the in-between pose (`crash` when Tonnage comes
  or goes, `hit` for the light forms; camera.json's budget and reduced-motion scale, no new data) and the
  GhostFormHud live on a CanvasLayer (5). HUD fix: in a form the chevron + `G` mark the switch target (was none),
  in base `Q` under the picked ghost; labels on one baseline (the grown chip clipped "Tonnage"); _chevron split out
  (gd-size). Re-filmed: 10/10, 0 SCRIPT ERROR; `M:frames/hud-live-arena-base-morph-tonnage.png`, the 32 px/m clip
  replaced with this run.

### REPLY to n6-ghost-powers REQUEST 2 (01:06): done on this branch (56406f67, 2bdc3fbf)
1. Tonnage: GhostPilot passes HaulerStage.drive `power=false` and `melee` only while `settled_in(&"tonnage")`;
   HaulerStage.share(powers) skips its own try_activate + tick. HaulerForm still turns on with `hauler` started
   (= at the start of the 0.9 s entering), so the plates' armor_k and the tank's movement run through the morph,
   the slam does not. press_ahead_m untouched (your call once you see the live clip).
2. Dent: seize = the fire press while Dent is settled (the gun does not fire then: GhostPilot clears fire_at);
   the overload stays melee. DentStage.share(powers): a seize needs `gearbox` running, a let-go / failed seize no
   longer interrupts the power (the form keeps its own clock; several seizes per form). DentBeat re-timed (G 40,
   Q 42, fire 80); scenario_ghost_attacks 1/0 on it. test_tonnage_attacks' slam test waits enter_ticks.
3. One SoulPowers for every ghost: `StagePilot.ghosts` (GhostPilot); `pilot.hauler` / `pilot.dent` still point at
   the stages. Kerf/Ohm: add `KerfStage`/`OhmStage` with `share(powers)` and drive them from GhostPilot.drive
   (gate on `settled_in(&"kerf")`); `owns_melee()` then needs your stage's flag (one line each).

### Dent (item 2 of the order), started 01:03
- 01:03 Dent part sheet job (`M:gen/r2/jobs.json` `dent_parts`, refs: the Dent concept + r1's style ref), image.lock
  created noclobber by this lane and deleted after (one job, ~3 min; lock absent before and after). Back clean:
  head with the quartered target disc, harnessed torso with shoulder discs, upper arm, forearm + open hand, thigh
  with the knee disc, boot; pale grey-beige dummy plastic, gunmetal joints, teal only in the cracks.
  `M:frames/dent-sheet-vs-target.png`. Cut by tools/art/ghost_parts.py into `features/souls/art/dent/`: helmet,
  torso, r_foot rotated 90 deg (sheet front = down the page; the rig faces +x), l_ limbs mirrored from r_, shin =
  a copy of the thigh (no shin cell). 12 provenance lines in `steam/ai-provenance/2026-11.jsonl`.
- Registry rules applied: `generated-asset-world-scale` (the parts get sized in metres against Rivet's footprint
  in the plan, never by sheet px: Dent's row says size_k 1.05, radius 0.45 m), `sprite-and-atlas-production`
  (judge at 32 px/m on the rig before calling the art done).
- Not done: DentPlan. The humanoid CutRig reads parts.json per art dir (size, scale, pivot_a/pivot_b per part,
  Rivet's in `features/characters/art/rivet/parts.json`, measured by the d5 slicer) and PartLibrary resolves
  art dirs under `features/characters/art/`. Next: measure Dent's parts.json (limb pivots at the joint discs:
  upper arm shoulder disc left / elbow cap right; forearm elbow left / wrist right with the hand drawn on, so
  hand parts = "" or a 1 px blank; thigh hip left / knee disc right), DentPlan = RivetPlan.build(base) with
  art_dir pointing at the dent parts, no collar/hose/claws, size_k 1.05 x 0.97; GhostFormView swaps Rivet's
  rig for a Dent CutRig (CharacterRigs can't take a second plan for one actor: a standalone CutRig on the view,
  fed from Rivet's pose like TonnageRig) and the stagger gait.
- 01:07 SCENARIOS on 2bdc3fbf: 47 ran, 0 failed, 0 SCRIPT ERROR (`E/scenarios-iter2.log`).
- MILESTONE e6d4d6b8 + next commit: DentPlan (features/souls/dent_plan.gd) = RivetPlan FORM_BASE with art_dir `dent`
  (features/characters/art/dent: PartLibrary's root; moved from souls/art/dent), size_k x form row 1.05, no collar
  / hose / claws / end-on / toe-off, pelvis = a 2 px blank. Parts resized to Rivet part px (torso 346 px across the
  shoulders vs Rivet 330, head 165, limbs 1.1-1.3x Rivet's thickness), parts.json pivots at the joint discs.
  test_dent_plan 3/3 (every part loads + measured, no Rivet-only parts, size from the row). Provenance re-hashed
  for the new paths. DECISION (small): Dent's rig parts live under characters/art/ like rivet/cop/ped, because
  PartLibrary resolves art dirs there; TonnageRig's own parts stay under souls/art/tonnage (not a CutRig).
- 01:12 `forms_lineup --dent`: Dent's standalone CutRig beside base Rivet, 0 SCRIPT ERROR.
  `M:frames/dent-rig-first-32-64ppm.png`. Judged: the silhouette (round
  target head, broad harnessed shoulders, open hands in the guard) reads and Dent stands about Rivet's height,
  broader; BUT the shared part print greys every fill (the discs lose their yellow, the beige goes grey), the same
  failure as Tonnage's print A/B. Fix next: the raw-art route for Dent (a plan flag the rig's part materials
  honour, or Dent's own fills lifted to survive the print), judged at 32 px/m against the sheet.
- 01:20 Dent print A/B (`forms_lineup --dent [--raw]`, dev flag strips PartMaterials from Dent's sprites): raw keeps
  the yellow discs and the beige at 32 and 64 px/m, the print greys him to noise at 32
  (`M:frames/dent-print-ab-32-64ppm.png`). DECISION raw (decisions.md); the live route needs a BodyPlan flag that
  RigBuild._part honours (material null), next session. Raw at 32 px/m is busy (fine cracks alias): judge in
  motion; a softer downscale (mip or a 0.5x pre-shrunk set) may be needed.
- MILESTONE 01:18 Dent LIVE: BodyPlan.raw_parts (RigBuild._part sets no material; CutRig.set_tint restores raw when
  the hit tint ends), DentPlan.RAW_PARTS true; GhostFormView carries a standalone Dent CutRig (DentPlan at the form
  row's size_k) fed Rivet's pos/facing/travel on whole sim ticks, shown from the in-between pose on (the same rule as
  Tonnage), Rivet's rig + held views hidden. `--bot=ghosts --ghost=dent` windowed 64 px/m 480 frames: seizes 1,
  blasts 1, 5/5 down, 0 SCRIPT ERROR (`E/ghosts-dent-live-64.json`). M: `dent-live-arena-64ppm.mp4`,
  `frames/dent-live-arena-64ppm-keys.png`. Judged: the target head and yellow discs read at 64 px/m, the tether
  comes off Dent's body. Weak: no stagger gait yet (Rivet's walk cycle on Dent's parts), shins show the thigh's knee
  disc at the ankle, no 32 px/m clip or city clip yet, no Dent transformation close-up. Unit: test_dent 3/3,
  test_ghost* 15/15, test_rig* 36/36 (the raw flag touches RigBuild/CutRig).

NEXT (iteration 3), Dent to done, then Kerf:
1. Merge n5-cast's tip and n6-ghost-powers' if they moved (JOURNAL/REPORT: keep ours). Tell ghost-powers (their
   JOURNAL is not ours to edit; my REPLY above) that DentBeat and test_tonnage_attacks were re-timed here.
2. Dent polish: the stagger gait (a lurch: RigGait phase jitter + a hip sway on the plan, e.g. BodyPlan.hip_follow
   up and a stride limp on one side), a real shin (cut the thigh's knee disc off the shin copy, or a shin cell in a
   second sheet), the raw parts at 32 px/m are busy: try a pre-shrunk 0.5x set or mipmaps on the dent textures.
3. Dent proof: 32 px/m arena clip (15-20 s), `--arena=city` clip, a 64 px/m slow close-up of the transformation,
   still beside the target (frames/dent-sheet-vs-target.png is the sheet, not the rig: redo with the live frame).
   The Tonnage <-> Dent switch (G in a form) through the teal flash, filmed (a GhostReel variant or forms_lineup
   --morph with a switch: hold, G, hold, Q).
4. Kerf (item 3): part sheet (laser-cutter head from above: lens, twin emitter arms, jointed trailing limbs, teal
   beam slots), its own rig (hover: TonnageRig-like Node2D or a CutRig plan with legs folded), the anchors
   emitter_l/r + lens already in ghost_forms.json. Then Ohm.
5. Gates at the end: unit full, scenarios, evidence runner, director reel (this session's started 01:20).
- 01:22 COMBAT CHECK director reel headless `--quit-after 24000` on c543ccd9 (GhostPilot + GhostFormView in the live
  path): 16/16 chapters down (claw_combo 2/2 .. mini_nuke 4/4), 0 SCRIPT ERROR, exit 0 (`E/director-reel-iter2.log`).
- 01:23 Dent shins: the thigh art cropped before its knee disc, 0.76 thinner (Rivet's shin is slimmer than his
  thigh), parts.json + provenance re-measured; test_dent 3/3. Dent 32 px/m live (900 frames, 5/5, 0 SCRIPT ERROR,
  `E/ghosts-dent-live-32.json`): `M:dent-live-arena-32ppm.mp4`, `M:frames/dent-live-arena-32ppm-keys.png`. Judged:
  the disc reads, the raw cracks speckle at 32 px/m (NEXT 2: a pre-shrunk set or mipmaps).
Session state 01:24: head = this commit, tree clean, no Godot process of mine running, image.lock taken once
  (01:03, dent_parts) and deleted by this lane. Gates this session: lint 13/13 every commit, unit 955/4 on 94b7c56d
  (the 4 = test_tonnage_attacks' slam timing, fixed; that test 2/2 + test_ghost* 15/15 + test_dent 3/3 + test_rig*
  36/36 after), scenarios 47/0 on 2bdc3fbf, director reel 16/16 on c543ccd9. Not run: the full unit suite after
  c543ccd9 (since run: 962 passed, 0 failed on d57927da, `E/unit-iter2-final.log`), parity, the evidence runner (NEXT 5).

## Iteration 3 (01:26-02:26, BUILD)
- 01:28 MERGE n6-ghost-powers faffe9a5 (53f4b753: Kerf, Ohm, KerfView/OhmView, beats) and n5-cast cc744d85
  (719347a6: r5 plan-view ped sheet). Conflict stage_pilot.gd: ours (GhostPilot) kept; `pilot.kerf/ohm` now point
  at GhostPilot's stages. KerfStage/OhmStage got `share(powers)` (no own activation/tick; Kerf's speed_k skipped
  when shared: the form's top_mps 12 moves Kerf). GhostPilot drives both, gated on `settled_in`; owns_melee covers
  Dent/Kerf/Ohm. KerfBeat/OhmBeat select by G (after the reel's 40 look ticks) then Q and wait enter_s
  (Kerf G 40/42, Q 44, first blink 78; Ohm G 40/42/44, Q 46, first bolt 92); scenario TICKS kerf 540, ohm 620;
  test_kerf/ohm_attacks use `_take(id)` (G until selected, Q, wait enter_ticks). Unit test_kerf 3/3, test_ohm 2/2,
  test_ghost 15/15, test_hauler 18/18, test_dent 3/3, test_tonnage 2/2; scenario_ghost_attacks 1/0 (all four beats,
  replay and planted faults). Known gap: Kerf/Ohm `activations` telemetry stays 0 when shared (counted by
  GhostPilot.transforms instead).

### REPLY to n6-ghost-powers REQUEST 3 (01:40): done in 53f4b753
1. GhostPilot owns `kerf`/`ohm` (shared SoulPowers); `pilot.kerf/ohm` are those stages, never null on a bound
   pilot. Your beats and tests now select the form by G and press Q (re-timed here, please keep on merge).
2. Ohm's bolt anchor: `electrode_l/r` in ghost_forms.json sit at 0.38 m forward; HANDS_M 0.45 is close: read the
   anchor when you like (I did not change OhmStage's emit point).
3. Kerf's blink snaps: the form rig is fed rivet.pos each whole sim tick (no tween), so the blink reads as a snap.
- MILESTONE fb3e6a98 `--bot=forms [--form=<id>|all]` (dev/ghost-forms/forms_tour_bot.gd, one branch in arena_game):
  Rivet walks a square, G picks the form, Q transforms while walking, the square in the form, Q back; `all` =
  Tonnage then G through Dent, Kerf, Ohm. The proof bot for every form's clip (the attack beats stand still).
- MILESTONE 669f3352 + fix: Dent polish. DentLurch (roll 0.12 m + yaw 15 deg per 1.5 m stride, the limp as
  sin(phase/2) warp: halves 42/58, idle sway 2.5 deg), Dent's raw parts mipmapped (the 32 px/m crack speckle),
  GhostAura (a breathing teal pool, 2.4x the footprint, under the light forms: the target's possessed read).
  First film caught a stray foot ~2 m behind Dent for 30 ticks after the morph: the rig was reset before its root
  moved (planted foot at the old spot), fixed by placing first. City film caught the glow staying after the exit
  (root not hidden): fixed. `--no-lurch` is the A/B before (read from the user args: LaunchArgs drops unknown
  flags, the first "before" was silently the after). DECISION in decisions.md (rejected: a teal modulate, a
  separate stagger cycle). test_dent_lurch 3/3.
- 01:55 PROOF Dent (all windowed, 0 SCRIPT ERROR each): `M:dent-gait-ab-32ppm.mp4` (before | after, same ticks),
  `M:frames/dent-gait-ab-32ppm-x2.png`, `M:dent-tour-arena-32ppm.mp4` (16 s), `M:dent-tour-city-32ppm.mp4`
  (17 s, `--arena=city`), `M:dent-morph-64ppm-slow3x.mp4`, `M:frames/dent-morph-64ppm-keys.png`,
  `M:frames/dent-live-vs-target-64ppm.png`, `M:frames/dent-tour-city-32ppm-keys.png`. Judged: the stagger
  reads at 32 px/m as a lurching dummy (yaw clear, the roll subtle), the cracks no longer speckle, the teal pool
  says "possessed" on asphalt and on the pale kerb; the transformation reads in two stages at 64. Weak: the target
  is a fully teal ghost, ours is a beige dummy on a teal pool (deliberate: the yellow discs are the read; Call for
  the owner candidate). frames.json rebuilt (15, Dent first), superseded masters files and scratch deleted.

### Kerf (item 3), started 01:57
- 01:57 Kerf part sheet (`M:gen/r3/jobs.json` `kerf_parts`, refs: the Kerf concept + the style ref), image.lock
  created noclobber by this lane (absent before) and deleted after; one job, 65 s. Clean first try: arrow hull
  (lens, nozzle with a teal tip, hazard cross-beam), arm strut, emitter forearm (teal tip), leg upper, blade leg,
  cable loops; gunmetal and pale steel, ochre rust, teal seams. Cut by ghost_parts.py into
  `features/souls/art/kerf/` (hull and cables rotated to face +x), mipmaps on, 6 provenance lines.
- Registry rules applied: `generated-asset-world-scale` (sized in metres in the rig: hull 1.35 m, never sheet px),
  `sprite-and-atlas-production` (judged on the live rig at 32 and 64 px/m before calling it fit).
- MILESTONE d3aaa8a2 KerfRig (hover: hull + cables, emitter arms in guard, blade legs trailing and sweeping with
  speed, bob, unfold for the morph, teal glow) standing in for Rivet in GhostFormView. FRICTION: filmed before
  `--check-only` once (Array[Array] element passed as Sprite2D = warning-as-error, 609 SCRIPT ERRORs in that
  run); limbs are now one flat Array[Sprite2D]. First size (hull 1.0 m) read as an insect at 64 px/m: x1.35.
- 02:05 PROOF Kerf arena (0 SCRIPT ERROR): `M:kerf-tour-arena-32ppm.mp4`, `M:kerf-morph-64ppm-slow3x.mp4`,
  `M:frames/kerf-live-vs-target-64ppm.png`, `M:frames/kerf-tour-32ppm-keys-x2.png`. Judged at 64: the arrow hull,
  lens, emitter arms and trailing claws match the target's top view. At 32 px/m the hull reads but the thin dark
  limbs nearly vanish on asphalt (weakest item). Not yet: city clip, a Kerf A/B (no before: new body), the blink
  filmed on the body (ghost-powers' beat, `--bot=ghosts --ghost=kerf`).
- 02:07 GATES on d3aaa8a2: lint 13/13; unit test_ghost 15, test_kerf 3, test_ohm 2, test_dent 6, test_hauler 18,
  test_tonnage 2, test_rig 36 (all pass); scenario_ghost_attacks 1/0 (`evidence/scenario-ghost-iter3.log`).
  Not run this session: the full unit suite, all scenarios, the evidence runner, the director reel (last 16/16 on
  c543ccd9; since then GhostPilot drives Kerf/Ohm too, the reel path does not select a form).
- FRICTION frames.json at the 15 cap: adding Kerf dropped `tonnage-live-arena-64ppm-slow3x.mp4`,
  `tonnage-live-city-32ppm.mp4`, the Tonnage 64 keys and the HUD still, and the clean-up deleted them. Re-film them
  with `--bot=forms --form=tonnage` (64 px/m slow, `--arena=city`) next session; better to drop the weaker Dent
  stills then.

NEXT (iteration 4), Kerf to done, then Ohm:
1. Merge n5-cast and n6-ghost-powers if they moved (JOURNAL/REPORT keep ours; keep my beat re-timings and
   KerfStage/OhmStage.share()). Tell ghost-powers their reel can now film Kerf/Ohm on the real bodies.
2. Kerf at 32 px/m: thicker limbs (ARM/LEG_THICK_M 0.15 -> ~0.22) and a pale rim or lighter steel so the limbs hold
   on asphalt; the emitter tips brighter; A/B at 32. Then the city clip (`--arena=city --bot=forms --form=kerf`) and
   the blink on the body (`--bot=ghosts --ghost=kerf`, 64 px/m slow); size from the form row (size_k).
3. GhostFormView is 208 lines: split the stand-in bodies into one helper (GhostBodies: Tonnage, Dent, Kerf, Ohm
   with show/step), before adding Ohm.
4. Ohm (item 4): part sheet (elder spot-welder from above: hunched shell, welding-gun cane arm, two copper
   electrode fingers, cable beard, goggles), smaller than Rivet (size_k 0.8), cane-step gait, electrode anchors.
5. Re-film the deleted Tonnage proofs (64 px/m slow, city) with `--bot=forms --form=tonnage`; the all-forms cycle
   clip (`--form=all`).
6. Gates: full unit, all scenarios, the evidence runner, director reel on the head.
Session state 02:08: head = this commit, tree clean, no Godot process of mine running, image.lock taken once
  (01:57, kerf_parts) and deleted; masters scratch empty except film.sh.
- 02:10 NEXT 2 started: Kerf's limbs 0.15 -> 0.22 m thick. A/B at 32 px/m, same ticks
  (`M:frames/kerf-limbs-ab-32ppm-x2.png`, top = before): the arms and blade legs now hold on asphalt and the
  kerb; `M:kerf-tour-arena-32ppm.mp4` re-filmed (0 SCRIPT ERROR). Still open from NEXT 2: lighter steel or a pale
  rim, brighter emitter tips, the city clip, the blink on the body.
Session state 02:11: head = this commit, tree clean, no Godot process of mine running (the two running at 02:08,
  PIDs 25480/63164, are n5-look's scenario runs: left alone), image.lock deleted, scratch empty except film.sh.

## Iteration 4 (02:08-03:08)
- 02:08 read JOURNAL, git log, ghost-powers/n5-cast JOURNALs (no new REQUEST to ghost-forms). The 02:10/02:11 lines
  above were written by iteration 3 with wrong clock times (they happened before 02:08).
- MERGE f95f6044 n6-ghost-powers 4db4eed5 (ohm_shock, mass tier, city placement). Both lanes had wired Kerf/Ohm into
  GhostPilot; conflicts in kerf/ohm_stage, ghost_pilot, the beats, test_kerf/ohm_attacks and the scenario resolved to
  THEIR side (they own the attacks; their `_take()` helpers and timings FIRST_BLINK 76 / scenario 520/600); our
  duplicate `_take(id)` helpers and SELECT_AT branches removed. JOURNAL/REPORT keep ours. Unit test_kerf_attacks 3,
  test_ohm_attacks 3, test_ghost 15, test_dent 6, test_hauler 18, test_tonnage 2, test_kerf 3; scenario_ghost_attacks
  1/0 (`evidence/scenario-ghost-iter4.log`).
- MERGE 6ef0bc5d n5-cast 15feca4a (r7 hoodie, hoodie sleeves); JOURNAL/REPORT keep ours.
- NEXT 3 done: Dent's body split out of GhostFormView (DentBody: rig + lurch + aura); the view is 169 lines and steps
  Kerf and Ohm through one `_step_light`.

### Ohm (item 4), started 02:12
- 02:12 Ohm part sheet (`M:gen/r4/jobs.json` `ohm_parts`, refs: the Ohm concept + the style ref), image.lock absent,
  created noclobber by this lane and deleted after; one job, 63 s, clean first try: domed riveted shell with goggles
  and teal seams, cable-wrapped upper arm, forearm with two copper electrode fingers, boxy foot, cable beard, copper
  hose loop. Cut by ghost_parts.py into `features/souls/art/ohm/` (shell, beard, hose rotated to +x), mipmaps on,
  6 provenance lines.
- Registry rules applied: `generated-asset-world-scale` (sized in metres in the rig: shell 0.8 m, arms 0.36 + 0.54 m),
  `sprite-and-atlas-production` (judged on the live rig at 32 and 64 px/m before calling it fit),
  `motion-quality-gating` (the gait judged in motion at 64 px/m, the cane cycle unit-tested for no jump).
- FRICTION the first film had 1086 SCRIPT ERRORs (a discarded `_part()` return is a warning-as-error): same lesson as
  Kerf. `--check-only -s` on a single file is useless here (no autoloads: "Log not found"); the reliable pre-check is
  a 200-frame headless arena run (`--headless --quit-after 200 ... -- --bot=forms --form=ohm`).
- First fit at 64 px/m: the arms nearly vanished (the uppers under the shell, 0.2 m thick). Arms 0.36 + 0.54 m,
  0.24 m thick, shoulders 0.26 m out; the guard hand set to the bolt's sparks (0.5 m ahead). Then the beard moved to
  0.42 m ahead (it hid under the shell). DECISION in decisions.md.
- MILESTONE 415f00e0 OhmRig + DentBody split + test_ohm_rig 3/3; d? beard commit after.
- 02:26 PROOF Ohm (0 SCRIPT ERROR each): `M:ohm-tour-arena-32ppm.mp4` (18 s), `M:ohm-tour-city-32ppm.mp4` (18 s,
  `--arena=city`), `M:ohm-morph-64ppm-slow3x.mp4`, `M:frames/ohm-morph-64ppm-keys.png`,
  `M:frames/ohm-live-vs-target-64ppm.png`; the all-forms cycle `M:forms-cycle-all-32ppm.mp4` (15 s, `--form=all`:
  Tonnage, Dent, Kerf, Ohm, base) + `M:frames/forms-cycle-all-32ppm-keys.png`. Judged: at 64 px/m the dome, goggles,
  hose, the trailing cane arm and the copper prongs read as the target's top view; the morph reads in two stages
  (burst over Rivet, in-between, Ohm unfolding). At 32 px/m Ohm reads as a small rust shell carried by the teal pool
  and the electrode sparks; the arms are thin (weakest point, like Kerf's before its 0.22 m limbs). Same call as Dent:
  rust steel on a teal pool, not a fully teal ghost (Call for the owner).
- frames.json rebuilt (15: cycle and Ohm first); the dropped files deleted (Dent arena/city clips and stills, Kerf
  limbs A/B, Ohm beard A/B).
- 02:32 GATES on 25b040bb: unit 974/0 (`E/unit-iter4.log`), scenarios 47/0 (`E/scenarios-iter4.log`), lint 13/13.
- MILESTONE 70a6297a GhostRim: the characters' own cream sticker rim (RigBuild halo = HALO part material, a cream
  silhouette) under Kerf's and Ohm's limbs (+50 % across) and hull/shell (+7 %), z -16 so the rims merge into one
  outline. A/B at 32 px/m, same frames (`--no-rim` = before): `M:frames/kerf-rim-ab-32ppm-x2.png`,
  `M:frames/ohm-rim-ab-32ppm-x2.png`, clips `M:kerf-rim-ab-32ppm.mp4`, `M:ohm-rim-ab-32ppm.mp4`. Judged: Kerf's claws
  and emitter arms and Ohm's arms now hold on asphalt like the cops' limbs (closes iteration 3's NEXT 2 "pale rim").
  DECISION in decisions.md (rejected: thicker limbs again, a lighter-steel repaint). FRICTION: a new class_name needs
  `--import` before a film (the first rim film had "GhostRim not declared").
- 02:40 COMBAT CHECK director reel on 70a6297a (`--quit-after 24000` headless): 16/16 chapters down, 0 SCRIPT ERROR
  (`E/director-reel-iter4.log`).
- 02:42 PROOF Tonnage re-filmed on the live path (NEXT 5 of iteration 3): `M:tonnage-morph-64ppm-slow3x.mp4`,
  `M:tonnage-tour-city-32ppm.mp4` (0 SCRIPT ERROR each). FOUND in the city clip: a cop draws over the press. Cause:
  GhostFormView sits at rigs.z + 1 while every rig stacks its parts' own z offsets (the held gun uses + 60 for this
  reason), so a human's upper parts cover the ghost body. Fix queued: the view at rigs.z + 60.
- frames.json: + the rim A/Bs and the two Tonnage clips; dropped and deleted kerf-tour-arena (pre-rim),
  dent-morph-64 slow, ohm-morph keys, tonnage-live-arena (superseded by the cycle and city clips).
- REPORT.md is now this lane's draft (the root REPORT.md on this branch had been n5-cast's, merged in).
- 02:48 GATES evidence runner `--no-bench` on 19ae646c (`E/evidence-run-iter4.log`): lint PASS, scenarios 47 PASS,
  parity PASS (1200 steps exact, planted mutation caught), selftest PASS (look goldens 11/11 and block 5/5 within
  tolerance: no re-bless needed). unit-tests marked FAIL only because I appended to JOURNAL.md during the run ("tree
  changed during run"); the suite itself was 974 passed / 0 failed. Lesson: touch nothing in the tree while the
  runner runs (its first try also refused: the log file was inside the tree).
- MILESTONE d4996f44 the ghost bodies draw above every rig part (GhostFormView at rigs z + 60, like the held gun;
  still in the actors band, under vehicles at +100). Before/after at the same ticks in the city:
  `M:frames/tonnage-city-z-ab-32ppm-x2.png` (cops over the press -> the press over the cops);
  `M:tonnage-tour-city-32ppm.mp4` re-filmed after the fix. scenario --filter=ghost 1/0 after the change.
- 02:53 Ohm's arena and city tours re-filmed on d4996f44 (rim + z fix, 0 SCRIPT ERROR each). Judged at 32 px/m in
  the city: the cream-edged arms now show beside the shell on asphalt.
- frames.json (15): cycle clip, Ohm target/morph/city/arena, the two rim A/Bs, Tonnage slow morph + city + the z A/B,
  Kerf target/morph, Dent gait A/B and target, Tonnage before/after/target. Dropped and deleted the cycle keys still.

NEXT (iteration 5):
1. Merge n5-cast and n6-ghost-powers if they moved (JOURNAL/REPORT keep ours; on the attack files theirs wins).
   Tell ghost-powers (REQUEST/notice in this JOURNAL is enough): their reel can film Kerf and Ohm on the real bodies
   now; Ohm's guard hand sits at OhmStage.HANDS_M (0.5, -0.12 in OhmRig.GUARD_HAND).
2. Re-run the evidence runner with NOTHING touched in the tree while it runs (iteration 4's unit FAIL was only the
   "tree changed" flag from my JOURNAL edit; 974/0). Log it outside the tree, copy it in after.
3. Quality, weakest first: (a) Dent's 32 px/m read beside the rimmed Kerf/Ohm (Dent rides Rivet's CutRig: does he get
   the CutRig halo? check, A/B); (b) form-to-form switch clip at 64 px/m slow (the teal flash, no base pass: is it
   readable? the cycle clip shows it only at 32); (c) the reduced-motion transformation clip (`--reduced-motion`) for
   one form, as evidence the beat and burst scale down.
4. The ghost apparitions for the voice moments (a teal apparition beside Rivet) if 1-3 are evidenced: the form's rig
   at 0.6 alpha in teal modulate beside Rivet, fading in and out, driven by a dev flag first.
5. REPORT.md is a draft for this lane: keep it current (gates, Calls for the owner with the composites).
Session state 02:54: head = this commit, tree clean, no Godot process of mine running, image.lock taken once (02:12,
  ohm_parts) and deleted; masters scratch empty except film.sh.
- 02:56 NEXT 3c done early: `M:frames/ohm-morph-reduced-motion-ab-64ppm.png` (same ticks, full | `--reduced-motion`):
  reduced motion keeps the burst ring at one size (no expanding ring) and the plates fly less; same two stages and
  end pose. 0 SCRIPT ERROR both.
- 02:58 NEXT 3b done early: `M:frames/forms-switch-tonnage-dent-64ppm-keys.png` + `M:forms-switch-64ppm-slow3x.mp4`
  (`--bot=forms --form=all --ppm=64`, 0 SCRIPT ERROR): Tonnage collapses into the teal ring and Dent stands up out of
  it in ~0.2 s, no base pass: the form-to-form DECISION reads at 64 px/m. frames.json: + these two, - the Kerf rim
  still (its clip stays, named in the Ohm rim entry) and the Ohm arena clip (the city clip shows Ohm at 32 with the
  rim; re-film the arena clip if a slot frees).
  NEXT for iteration 5 is above (items 3b and 3c are now done: start at 3a, Dent's 32 px/m read).
Session state 02:59: head = this commit, tree clean, no Godot process of mine running, no lock held.

## Iteration 5 (02:58-03:58, BUILD)
- 02:59 read JOURNAL, git log, ghost-powers JOURNAL: REQUEST 5 (KerfView instances KerfRig: keep FAST_MPS,
  PX_PER_M, speed_mps, advance(dt): kept, unchanged) and REQUEST 6 (Ohm's electrode anchors moved in our
  ghost_forms.json to OhmRig's copper fingers (0.52, -0.17)/(0.52, -0.07)). REPLY to 6: GUARD_HAND not moved this
  session; if it moves, the anchors move in the same commit.
- MERGE n5-cast b16becfb (D5 ped heads, bald head, hoodie cap size) and n6-ghost-powers d3ca8581 (Ohm prongs on the
  copper fingers, city proofs); JOURNAL/REPORT keep ours; lint 13/13 both; one `--import` after.
- 03:02 NEXT 3a answered: Dent rides Rivet's CutRig, which builds RigBuild's cream halos (HALO_BODY/ARM/LEG) and scales
  them in `_on_view` like the cops'. Looked at the city at 32 px/m (`M:frames/dent-city-halo-32ppm-x3.png`, x3): the
  tan dummy has the cream edge on the teal pool, arms and disc read beside the cops. No change needed.

### The voice moments (brief item: ghost apparitions), started 03:04
- Registry rules applied: `depth-ordered-layered-art` (the apparition's parts keep their rig's own z order: the reason
  for per-part materials instead of a group), `shader-budget-authoring` (one tiny unshaded canvas shader, two
  materials shared by every part, drawn only while a voice speaks), `motion-quality-gating` (judged in motion at 32
  and 64 px/m, envelope unit-tested).
- GhostApparition (render-only, in GhostFormView above the rigs): the speaking ghost's own rig copy (TonnageRig,
  DentBody, KerfRig, OhmRig) at Rivet's left shoulder, turned in; teal tether to Rivet; 18-tick flicker-in, 150
  held, 36 out; Tonnage at 0.6 scale. Cue: `stage.events().whispers_spiked` while Rivet is in base (the selected
  ghost speaks); dev `--apparition` cycles the four every 240 ticks; `--bot=forms --form=voices` just walks.
- FRICTION/FINDING first try was a CanvasGroup washing the group teal: Kerf/Ohm/Tonnage went teal but Dent drew in
  full colour. Cause: CutRig parts carry their own z_index (RigBuild, RigArm), and z-indexed children escape a
  CanvasGroup. Fix: every part of the copies draws through `ghost_apparition.gdshader` (ink -> deep teal, paper and
  steel -> pale teal, the sticker rims -> a pale-teal glow edge, scan bands), alpha by the node's modulate (0.8,
  so overlaps barely double). Then the teal ramp lifted (deep 0.04/0.27/0.28, smoothstep 0.04..0.62): the first
  ramp read as dark blobs at 32.
- MILESTONE 633fb9d7 GhostApparition + shader + test_ghost_apparition 4/4 + DECISION (decisions.md). Unit suite on
  that tree 979/1: the 1 is the known `test_noir_shadows` flake (alone: 2/2 pass). Lint 13/13.
- PROOF (0 SCRIPT ERROR each): `M:ghost-voices-arena-64ppm.mp4` (17 s, the four in turn), `M:ghost-voices-city-32ppm.mp4`
  (17 s, `--arena=city`), `M:frames/voices-four-64ppm-keys.png`, before/after at the same tick
  `M:frames/voice-dent-ab-64ppm.png`. Judged: at 64 each ghost is its own printed body in teal (press, dummy with
  the target disc, the cutter's claws, the dome); at 32 on asphalt all four hold as teal figures beside Rivet, the
  tether is a hairline (fine: it is a hint, not a beam); Ohm's is the smallest read.
- frames.json (15): + the three voice entries; dent-gait A/B, the Tonnage city tour and the Kerf slow morph are now
  named in their related entries' notes (files kept).
- 03:20 COMBAT CHECK director reel on 633fb9d7 + the voice log line (`--quit-after 24000` headless, 2 m 48 s):
  16/16 chapters down (claw_combo 2/2 .. mini_nuke 4/4), 0 SCRIPT ERROR (`E/director-reel-iter5.log`). No whisper
  fired in the reel (no "ghost voice" line): the reel never cues the voices, so it neither shows nor tests them.
- test_ghost_apparition 5/5 (+ the whisper cue: in base the selected ghost speaks, in a form none). A Log.info
  line "ghost voice: <id> beside Rivet" on each cue, for headless checks.
- REPORT.md: section 6 (the voices), the open point (not yet filmed on a real quest 1 whisper), two Calls (fully
  teal forms: the apparitions show that look on the same bodies; voices in quest 1 before the ghosts are met).
- 03:23 GATES evidence runner `--no-bench` on 56dae388, nothing touched while it ran (log kept outside the tree,
  copied in after: `E/evidence-run-iter5.log`): PASS lint 13/13, unit 981/0, scenarios 47, parity bit-exact
  (mutation caught at 629), selftest look goldens 11/11 within tolerance (worst 1.21): no re-bless. Closes
  iteration 4's NEXT 2.
- 03:25 PROOF the voice on quest 1's REAL whispers: `dev/ghost-forms/voice_quest1.gd` (+ `_main` entry) plays quest 1
  with CollectCallBot exactly as the scenario does, draws CollectCallView, and binds a GhostApparition to the play's
  own event bus (the bot has no StagePilot, so the apparition is stepped there at Rivet's spot, base, first ghost
  selected). Whispers at tick 123 (b1, Rivet in the dumpster) and 9626 (Kilohm: "Hold still. You've been
  mutter..."); 24 PNGs, 0 SCRIPT ERROR (`E/voice-quest1-iter5.log`); composite
  `M:frames/voice-quest1-real-whispers-48ppm.png`. Judged: Tonnage's teal apparition rises beside the dumpster
  inside the whisper rings, and at Kilohm's line, in the Toner Room. It reads as the voice. The 0.6-scale press
  is still large next to the sprite-cast Rivet at 48 px/m.
- frames.json (15): + the quest 1 still first; the voice A/B named in the four-voices entry (file kept).
- 03:22 FOUND (before the quest 1 proof above): quest 1 attaches GhostFormView only under `-- --rigs`
  (quest1_game._dev_rigs loads ArenaRigs); the shipping sprite cast has no ghost view, so no voice there either.

- 03:28 A/B Tonnage's apparition 0.6 (2.1 m out, as built) vs 0.5 (1.9 m out), same quest 1 ticks (9626 + 40,
  123 + 80) via voice_quest1: `M:frames/voice-tonnage-scale-ab-48ppm.png` (top as built, bottom 0.5). Judged:
  at 0.5 the press sinks into the whisper rings over Rivet and Kilohm; at 0.6 it stands clear beside him. Rejected,
  0.6 stays (file reverted, nothing committed). Light forms stay at their true size (Ohm is meant to be small).

- 03:32 MILESTONE dev `--teal-forms` (GhostFormView): the four form bodies drawn through the apparition's material
  (GhostApparition.wash / ghost_material, now static; no scan bands): the owner's "fully teal ghosts?" Call is
  now a same-tick A/B, `M:frames/forms-teal-ab-32ppm.png` (arena `--bot=forms --form=all`, frames 190/360/530/700,
  top as built, bottom teal; 0 SCRIPT ERROR both). Judged: both read at 32; teal loses Dent's discs and
  Tonnage's hazard stripes, and gains a stronger "possessed" read. Not a default: the brief asks for the
  printed machine with teal seams. test_ghost* 20/20, lint 13/13.

- 03:33 A/B Ohm's arms 0.24 vs 0.30 m thick, city 32 px/m, same ticks, x3 (`M:frames/ohm-arms-thick-ab-32ppm-x3.png`):
  no visible gain (the arms are short and sit beside the shell; thickness is not what limits them). Rejected,
  reverted, nothing committed.
- 03:34 MERGE n5-cast 952592df (hazard collar at 32, cream torch tip, visor Call) and n6-ghost-powers db0b4541 (Dent
  rides the seized car, the arena robot rig, Kerf's dry kill); JOURNAL/REPORT keep ours; lint 13/13.
- REPLY to ghost-powers REQUEST 7 (Dent's ride pose), done in cf9faa0c: DentBody gets `riding`, `strikes`, `blasts`
  from GhostFormView (pilot.dent); on the roof vel_in is zero (braced, no walk cycle at the car's speed); each
  strike bucks him (yaw kick + 10 % pop, 0.3 s), the blast hops him (35 % scale arc, 0.5 s); halved under reduced
  motion. test_dent_body 2/2, test_dent* 8/8, scenario_ghost_attacks 1/0, arena headless 0 SCRIPT ERROR.
  PROOF same ticks before/after `M:frames/dent-ride-braced-ab-32ppm-x1.5.png` (top: legs striding on the roof;
  bottom: braced, arms out, the pop) and `M:dent-ride-braced-city-32ppm.mp4` (12 s, `--bot=ghosts --ghost=dent
  --arena=city`, 0 SCRIPT ERROR). The mid-hop frame is not in the stills (20-tick sampling); see the clip.

- 03:48 FINAL GATES on 8b6327f3, still tree: director reel 16/16 chapters down, 0 SCRIPT ERROR
  (`E/director-reel-iter5-final.log`); evidence runner `--no-bench` all PASS: lint 13/13, unit 986/0, scenarios 47,
  parity bit-exact (mutation caught at 629), look goldens 11/11 in tolerance, no re-bless
  (`E/evidence-run-iter5-final.log`).

NEXT (iteration 6):
1. Merge n5-cast / n6-ghost-powers if they moved (JOURNAL/REPORT keep ours; attack files theirs).
2. The shipped quest 1 (sprite cast, no `--rigs`) has no ghost view, so no voices there. Either give it the
   apparition (one GhostApparition on print_stage.actor_layer() bound to stage.events() and stepped at Rivet,
   the wiring voice_quest1.gd shows) or leave it to the owner's call in REPORT. Pick, record a DECISION.
3. Apparition scale is settled (0.6 Tonnage, A/B 03:28); `--teal-forms` A/B done (03:32). Weakest left: Ohm's
   arms at 32 px/m. Thickness is ruled out (0.30 m A/B, 03:33: no gain); try longer forearms (0.54 -> 0.66 m) or a
   copper-bright forearm (contrast on asphalt), A/B at the same city ticks.
4. Keep REPORT.md current (iteration 5 gates are in "Gates (iteration 5)"). The director reel and evidence runner
   last ran on 8b6327f3 (all PASS); re-run after the next change.
Session state 03:49: head = this commit, tree clean, no Godot process of mine running, no lock held (image.lock
  not taken this session), masters scratch holds only film.sh.

## Iteration 6 (03:49 - 04:49)
- 03:50 READ JOURNAL NEXT, git log, the other lanes' JOURNALs: ghost-powers REQUEST 8 (Ohm's kick per bolt) is open.
- 03:51 MERGE n5-cast e7c055be (visor slot at 32 px/m) and n6-ghost-powers a92d4fef (REQUEST 8, robot victim in
  the city); JOURNAL/REPORT keep ours; lint 13/13 at each merge (hook).
- 03:57 REPLY to ghost-powers REQUEST 8, done in afe11fe8: OhmRig gets `bolts` (fed from pilot.ohm.bolts in
  GhostFormView) and `reduced_motion`. A rise kicks: the guard hand snaps 0.2 m out (first fifth) and eases back
  over 0.25 s, the shell recoils 0.1 m and twists 16 deg (the left shoulder thrusts), the cane holds its plant (the
  cycle pauses through the kick); halved under reduced motion. `OhmRig.kick_m()` is the hand's throw now (metres
  forward, body frame). The prongs need no offset: the hand thrusts forward INTO the prongs, so they start under
  it (seen in the stills). test_ohm_rig 5/5 (+2: kick/hold/settle, reduced motion halves), lint 13/13.
  A/B FIRST TRY 0.12 m / 9 deg / 0.05 m recoil (the request's size) did not read at 64 px/m (x2 crop: rows nearly
  identical); raised to 0.2 m / 16 deg / 0.1 m, which does. PROOF `M:frames/ohm-bolt-kick-ab-64ppm.png` (same
  ticks 86..104, before | after), `M:ohm-bolt-kick-64ppm-halfspeed.mp4`, `M:ohm-bolt-kick-city-32ppm.mp4` (14 s,
  `--bot=ghosts --ghost=ohm --arena=city`), 0 SCRIPT ERROR each. Judged a 42-frame sheet of the city clip: at 32
  the shell turn and the guard arm reaching into the bolt read on every bolt; it is the first motion the old
  welder makes with his casting hand (closes NEXT 3's "Ohm's arms at 32": a motion read, not a size one).
- frames.json 15: + the kick A/B first; the ohm rim A/B named in the ohm city tour's note (file kept).
- 04:11 MILESTONE 26289451 the ghost voice on the SHIPPED quest 1 (closes NEXT 2). DECISION (decisions.md): the sprite-cast
  quest 1 gets StoryVoice (boot/collect_call/view): one GhostApparition in the printed actors' layer, bound to the
  stage's bus, stepped by the sim ticks since the last frame (held while paused), view only (headless: no view, no
  voice, so scenarios and replay are untouched). Alternative = one data value: ghost_forms.json `story_voice` false.
  The `--rigs` cast keeps GhostFormView's own apparition (quest1_game._dev_rigs attaches StoryVoice only on the
  sprite path: no double ghost).
  FRICTION 1: the first film showed the rings but no ghost. A debug line showed z 0 under an anonymous Node2D: on
  the city, CollectCallView has no print_stage (it draws in city_view.actor_layer()), so the voice fell to the
  unprinted fallback. Fixed: the city view's actor layer first, then the print stage's.
  FRICTION 2: a SceneTree `-s` entry that names class types compiles before the autoloads (Identifier not found:
  Log); dev/ghost-forms/quest1_shipped_main.gd loads the input driver by path and calls it untyped.
  PROOF quest1.tscn as shipped, started past the title card, played through real pad events by
  CollectCallInputDriver (dev quest1_shipped_main.gd): "ghost voice: tonnage beside Rivet" at b1's dumpster
  whisper, 0 SCRIPT ERROR. `M:story-voice-quest1-shipped-32ppm.mp4` (7 s), A/B at the same frames with the flag
  off/on `M:frames/story-voice-quest1-shipped-ab-32ppm-x2.png`. Judged: before, the rings alone; after, the teal
  press rises beside the dumpster inside the rings and fades. It draws over a cop walking past (frame 200):
  acceptable for a ghost, noted. test_story_voice 2/2 (table on; a whisper raises it; paused frames hold it; ticks
  run it out). frames.json 15: + this A/B first; the dev-path quest 1 still named in its note (file kept).
- 04:12 GATES evidence runner `--no-bench` started on 26289451 (log outside the tree while it runs).
- 04:24 GATES evidence runner `--no-bench` on 26289451 (`E:evidence-run-it6.log`): PASS lint 13/13, scenarios 47,
  parity bit-exact (mutation caught at 629), selftest (look goldens 11/11 worst 1.22, block 5/5 worst 1.38: no
  re-bless). Unit 993 passed / 0 failed but marked FAIL: "tree changed during run (M JOURNAL.md)": my own
  JOURNAL append at 04:12 (same slip as iteration 4). Re-running the unit suite alone on a still tree next.
- 04:24 (iteration 6, cont.) the unit re-run on a still tree did not happen before that session ended: carried to
  iteration 7's gates.

## Iteration 7 (04:18 - 05:18)
- 04:19 READ JOURNAL, git log, REPORT, the other lanes' JOURNALs: no new REQUEST to ghost-forms (REQUEST 8 closed).
- 04:22 MERGE n5-cast 0abfd6c3 (the visor slot Rivet-only, BodyPlan.head_visor) and n6-ghost-powers f8d1d747 (Ohm's
  dry kill, the dry-kill gate, Kerf at 64, TTK gore per ghost); JOURNAL/REPORT keep ours; lint 13/13 at each (hook).
- 04:23 PLAN the weakest item = REPORT's only open point: the SHIPPED quest 1 (sprite cast) runs GhostPilot
  (StagePilot.ghosts), so Q / LB transforms Rivet in the sim, but nothing draws the form or the HUD there: the
  player gets an invisible transformation. Give the sprite cast the form bodies, the fx and the HUD.
- 04:24 MILESTONE 299a5772 the ghost forms on the SHIPPED quest 1 (DECISION in decisions.md). StoryForms
  (boot/collect_call/view) attaches one GhostFormView with no rigs in the printed actors' layer (city's, else the
  print stage's) on that view's CameraRig: the bodies, the teal morph, the camera beat and the HUD card are the
  arena's code. CastView (forms_drawn) leaves Rivet's sprite out while a body stands in (StoryForms.stands_in: from
  the in-between pose to the exit midpoint) and lifts his health bar over Tonnage (bar_lift_m: radius x 1.8). The
  view's own apparition is now the story voice (the SELECTED ghost, silent in a form); StoryVoice is the no-pilot
  fallback. Alternative = one data value: ghost_forms.json story_forms false (the old path: the Hauler grows and
  tints Rivet's sprite, Dent/Kerf/Ohm draw plain Rivet). GhostFormView.make split from attach (the view's fields
  set before _ready). test_story_forms 4/4; unit 1000/0; lint 13/13.
  FRICTION: a SceneTree `-s` dev script with untyped Array constants fails the strict warnings (Variant into
  typed args, even through float()/StringName()): typed const arrays per column instead.
  PROOF quest1.tscn as shipped, real stick + Q/G key events (dev/ghost-forms/quest1_forms_main.gd, 1140 frames):
  walk, Q Tonnage, Q out, G Dent, Q in, G Kerf, G Ohm, Q out; 0 SCRIPT ERROR (E:story-forms-quest1-shipped-it7.log),
  and the same input with story_forms false (E:story-forms-quest1-before-it7.log). `M:story-forms-quest1-shipped-32ppm.mp4`
  (19 s), A/B at frames 300/650/820/1000 `M:frames/story-forms-quest1-shipped-ab-32ppm.png`. Judged: before, Tonnage
  is a grown teal-tinted Rivet sprite and the other three are plain Rivet; after, each ghost's own body (the press on
  its four legs, Dent's discs, Kerf's blade legs, Ohm's dome) with the HUD card at the bottom left. First cut had
  the health bar across Tonnage's crown: lifted, re-filmed. Ohm idle on asphalt reads as an olive blob at 32 (x3
  crop): the shell's hairline teal seams are lost at 26 px. Next item.
- 04:33 COMBAT CHECK director reel on 299a5772: 16/16 chapters down, 0 SCRIPT ERROR (E:director-reel-it7.log).
- frames.json 15: + the shipped A/B first (the clip named in its note); ghost-voices-city named in the four-voices
  entry (file kept).
- 04:40 GATES evidence runner `--no-bench` on 91b6b866, still tree (E:evidence-run-it7.log): PASS lint 13/13, unit
  1000/0, scenarios 47, parity bit-exact (mutation caught at 629), selftest look goldens 11/11 (worst 1.22), block
  5/5 (worst 1.38): no re-bless. (The first try refused: the reel log was uncommitted; committed, re-run.) This
  closes iteration 6's open unit re-run.
- 04:49 MILESTONE 457e9551 Ohm's teal soul seams (OhmSeams, DECISION): a child of the shell sprite drawn in its texture
  pixels (two row seams, the spine, 22 tex px = about 1.5 screen px at 32; two teal lenses with a pale core), so it
  turns, kicks and morphs with the shell. Registry rule applied (motion-quality-gating / generated-asset-world-scale):
  judge at the game zoom on the real path, the same frames before/after. A/B on the shipped quest 1, same input,
  frames 960/1000/1030: `M:frames/ohm-seams-quest1-ab-32ppm-x3.png`. FRICTION: the mp4 crop showed maroon pixels at
  the seam edges (red is blood only); a lossless PNG of frame 1000 (write-movie PNG, deleted after) has none: H.264
  chroma ringing on teal-vs-rust edges. `M:frames/ohm-seams-lossless-32ppm-x8.png`. Arena with the bolt:
  `M:frames/ohm-seams-arena-ab.png` (top --no-seams), `M:ohm-seams-arena.mp4`; 0 SCRIPT ERROR each. Judged: the dome
  now reads as possessed at 32 (a teal lattice with two eyes), and it matches its teal bolt.
  test_ohm_rig 6/6, unit 1001/0, lint 13/13. First run hit a strict-warning parse error (PackedVector2Array.append
  return value discarded); fixed before any frame was judged.
- frames.json 15: + the seams A/B second; ohm-tour-city named in the ohm-vs-target entry (file kept). Scratch
  cleaned.
- 04:55 COMBAT CHECK director reel on 457e9551 (Ohm's seams): 16/16 chapters down, 0 SCRIPT ERROR
  (E:director-reel-it7-seams.log).
- FOUND (open, REPORT): on the shipped quest 1 the dialogue box (HUD layer, bottom centre) covers the form card's last
  three chips while a line is up (contact sheet of the shipped clip). Not changed: the fixes (lift the card while a
  line shows, or hide it) need the dialogue's state; next session.

NEXT (iteration 8):
1. Merge n5-cast / n6-ghost-powers if they moved (JOURNAL/REPORT keep ours).
2. The form card under quest 1's dialogue box: read the dialogue view's open state (boot/collect_call view) and lift
   the card above the box while a line shows (or slide it right); A/B at the same frames of quest1_forms_main.
3. Ohm's seams are in (457e9551). Next weakest read at 32 on the shipped path: Kerf (blade legs read; check the
   hull at idle) and Dent at a standstill; x3 crops of the shipped clip, frames 650 / 820.
4. Final gates on a still tree before the 08:30 freeze (evidence runner --no-bench, director reel); REPORT for 08:40.
Session state 04:56: head = this commit, tree clean after it, no Godot process of mine running, no lock held
  (image.lock not taken this session), masters scratch holds film.sh, journal-it7.txt, ohm_x3.png and logs.
- 04:57 MILESTONE d5e9091a (NEXT 2 done early) the form card folds beside quest 1's subtitle box (DECISION):
  GhostFormHud.compact draws the one chip that matters (the current form; in base the selected ghost) with the
  Madness bar while HudState.speaker is set (StoryForms._process). Rejected: lifting the card (it stands in the
  playfield, crosses the save-notice band) and hiding it. A/B same frames 240/600/1100:
  `M:frames/form-card-fold-quest1-ab-32ppm.png`. Judged: before, at frame 600 the chip peeking from under the box
  is a grey Tonnage while Rivet is Dent; after, a teal Dent chip and his Madness bar beside the box; frame 1100
  (no line) shows all four as before. 0 SCRIPT ERROR; test_story_forms 5/5, unit 1002/0, lint 13/13. The shipped
  clip re-filmed on this head (`M:story-forms-quest1-shipped-32ppm.mp4`; the seams-only cut deleted).
  frames.json 15: + the fold A/B third; the reduced-motion A/B named in the ohm-vs-target entry (file kept).
- 05:04 FINAL GATES on 1f717c6f, still tree (E:evidence-run-it7-final.log): evidence runner `--no-bench` all PASS:
  lint 13/13, unit 1002/0, scenarios 47, parity bit-exact (mutation caught at 629), selftest look/block goldens in
  tolerance: no re-bless. Director reel last ran on 457e9551 (16/16); d5e9091a only touches the HUD card and the
  quest 1 glue (the arena never folds), so the reel is not re-run this session.

NEXT (iteration 8, replaces the list above; item 2 there is done in d5e9091a):
1. Merge n5-cast / n6-ghost-powers if they moved (JOURNAL/REPORT keep ours).
2. Weakest reads left at 32 on the shipped quest 1: Dent at a standstill and Kerf's hull at idle (x3 crops of
   quest1_forms_main frames 650 / 820). Same method as Ohm's seams: same-frame A/B, check a lossless PNG frame
   before judging colour (H.264 rings teal edges into maroon).
3. Director reel on the head after any change; final gates before the 08:30 freeze; REPORT for 08:40.
Session state 05:05: head = this commit, tree clean, no Godot process of mine running, no lock held (image.lock not
  taken this session); masters scratch holds film.sh, journal-it7.txt, ohm_x3.png and logs.
- 05:08 COMBAT CHECK director reel on 5019d2f8 (the head with the folding card): 16/16 chapters down, 0 SCRIPT ERROR
  (E:director-reel-it7-final.log). Session ends: tree clean after this commit, no Godot process of mine running.

## Iteration 9 (BUILD, 05:09 - 06:09)
- 05:09 read JOURNAL, git log, the ghost-powers and cast JOURNALs: no new REQUEST to ghost-forms. Two Godot processes
  running at start (57852, 63108) are not mine: left alone.
- 05:12 MERGE n6-ghost-powers 9b5ae95f (quest 1 attack views, quest_ghost_rec, carries n5-cast d7bf12ce) as f7134f89:
  their it7 logs that share our names saved as `*-powers.log`, their copies of ours (`*-forms.log`) dropped;
  JOURNAL/REPORT keep ours. MERGE n5-cast 31e665fa (CORE_TAN 1.0, Call 9 docs) as ac0f15e5. `--import` next.
- 05:22 FOUND on the merged head, lossless PNG frames of quest1_forms_main (x3 crops at 650/700 Dent at a standstill,
  780/820/860 Kerf idle): Dent at a standstill reads (yellow-black disc, glow); Kerf's front blades (about 1.6 m
  forward) cross Rivet's health bar at 1.2 m. MILESTONE (this commit) ghost_forms.json `bar_m` per form (view only:
  kerf 1.9, tonnage 2.35 = the old radius x 1.8, dent and ohm 1.2); StoryForms.bar_lift_m reads it. DECISION.
  A/B same input, same frames: `M:frames/kerf-bar-quest1-ab-32ppm-x3.png`. Judged: before, the bar is a black slab
  through the blades; after, it rides just clear above the tips. 0 SCRIPT ERROR; unit 1008/0 (new
  test_each_forms_bar_rides_clear_of_its_drawn_body), lint 13/13. Shipped clip re-cut on this head
  (`M:story-forms-quest1-shipped-32ppm.mp4`, 19 s). frames.json 15: + the bar A/B second; ohm-bolt-kick A/B named in
  the seams entry (file kept).
  Registry rule applied (motion-quality-gating): judge on the shipped path at game zoom, same-frame A/B, lossless
  frames before judging edges.
- 05:28 COMBAT CHECK director reel on d5e2f3e5 (merged ghost-powers + cast, the bar fix): 16/16 chapters down,
  0 SCRIPT ERROR (E:director-reel-it9.log). The bar over the forms reads as a black slab at full HP: by design
  (CastView._hp_bar fills ink by the health fraction on cream), not changed.
- 05:35 MILESTONE the 64 px/m close-up on the shipped quest 1 (closes REPORT's open item): quest1_forms_main takes
  `-- --ppm=64` (Quest1Game.px_per_m, set before the game enters the tree). Lossless PNG run, 1140 frames, 0 SCRIPT
  ERROR. Judged: entry reads in two stages (Rivet -> teal lattice burst -> in-between disc with the press's legs ->
  the press), exit the reverse back to Rivet's sprite; Dent, Kerf, Ohm settled read at native 64; Kerf's bar clears
  the blades. Note: at 64 the subtitle box covers the lower part of Tonnage while a line is up (the HUD's layout,
  not changed). `M:frames/story-forms-quest1-keys-64ppm.png`, `M:story-forms-quest1-shipped-64ppm.mp4` (19 s),
  `M:story-forms-quest1-tonnage-64ppm-slow3x.mp4` (18 s, 3x slow, 640x400 crop). frames.json 15: + the keys second;
  voices-four keys named in the story-voice entry (file kept). PNG scratch deleted.
- 05:41 GATES evidence runner `--no-bench` on 95aa969e, still tree (E:evidence-run-it9.log): PASS lint 13/13, unit
  1008/0, scenarios 47, parity bit-exact (mutation caught at 629), look goldens 11/11 (worst 1.22), block 5/5 (worst
  1.38): no re-bless.
- 05:45 MERGE n6-ghost-powers cefbcf8b (Dent's missed reach: the teal tether lashes out and frays with no car;
  Tonnage's 4 m stomp ring on the street) as dd93a89d; their it7 log copies match our saved `*-powers.log`, ours
  kept. MERGE n5-cast 551ed9c6 (dark ped heads: coat-hat crown, coat-hood) as 9b0b616c. JOURNAL/REPORT keep ours.
  Unit (with import) and the director reel on 9b0b616c running.
- 05:47 On the merged head 9b0b616c: unit (with import) 1010/0 (E:unit-it9-merged.log); COMBAT CHECK director reel
  16/16 chapters down, 0 SCRIPT ERROR (E:director-reel-it9-merged.log).
- 05:52 MILESTONE b540f1aa Rivet's health bar eases between body heights through a transformation
  (StoryForms.bar_lift_m: lerp from the leaving body's bar_m to the coming one's on smoothstep(0.3, 0.7, k));
  form to form (Kerf 1.9 -> Ohm 1.2) eases the same way. Before, it held at 1.2 m through the burst and jumped to
  2.35 m at the midpoint. A/B same input, lossless frames 164-200 every 4 of quest1_forms_main (Tonnage entry):
  `M:frames/bar-ease-tonnage-entry-ab-32ppm-x2.png` (named in the kerf-bar frames.json entry). Judged: before, one
  step of about 32 px; after, the bar rises with the burst over about 16 ticks. 0 SCRIPT ERROR both runs; new
  test_the_bar_eases_through_a_transformation (rises only, no step above a quarter of the range); unit 1011/0,
  lint 13/13. (Before frames filmed with HEAD's story_forms.gd swapped in temporarily, restored after.)
- 05:55 COMBAT CHECK director reel on b540f1aa (the bar ease): 16/16 chapters down, 0 SCRIPT ERROR
  (E:director-reel-it9-ease.log).

NEXT (iteration 10):
1. Merge n5-cast / n6-ghost-powers if they moved (`--no-ff --no-commit`; JOURNAL/REPORT and our evidence logs keep
   ours; theirs with clashing names saved as `*-powers.log`), `--import`, unit, director reel.
2. Final gates on a still tree before the 08:30 freeze: evidence runner `--no-bench` (last all-PASS on 95aa969e;
   since then two merges and the bar ease, unit 1011/0 and reel 16/16 on them); REPORT for 08:40.
3. Polish candidate: at 64 px/m quest 1's subtitle box covers the lower part of Tonnage while a line is up (HUD
   layout; check whether the camera can bias up while a line is up, or leave it).
Session state 05:56: head = this commit, tree clean after it, no Godot process of mine running, no lock held
  (image.lock and bench.lock not taken this session); masters scratch holds film.sh, logs and ohm_x3.png;
  frames.json 15, all present.
- 06:01 FINAL GATES evidence runner `--no-bench` on d41ff115, still tree (E:evidence-run-it9-final.log): PASS lint
  13/13, unit 1011/0, scenarios 47, parity bit-exact, look/block goldens in tolerance, no re-bless. NEXT 2 above is
  done for this head; repeat it only after further merges or changes. Session ends: tree clean after this commit,
  no Godot process of mine running, no lock held.

## Iteration 11 (BUILD, 06:02 - 07:02)
- 06:02 read JOURNAL, git log, the ghost-powers and cast JOURNALs. Iteration 10 left no entry here (head was still
  2d57fcbb). ghost-powers NOTICE (05:46): Dent in quest 1 has no car; selectability is our data. Their NEXT 2 is a
  quest-side VehicleService, so Dent stays selectable (its missed reach reads); no change from us.
- 06:04 MERGE n6-ghost-powers e1283d9c (docs only) as 9542be71; MERGE n5-cast 2329c483 (cop crowns bright police
  blue over navy sleeves) as 3ce12ee1. JOURNAL/REPORT and our it7 logs keep ours. `--import`, unit, reel next.
- 06:10 On the merged head: unit (with import) 1011/0 (E:unit-it11-merged.log); COMBAT CHECK director reel 16/16
  chapters down, 0 SCRIPT ERROR (E:director-reel-it11-merged.log). FRICTION: the reel needs the arena scene
  (`--path project --quit-after 24000 res://dev/arena/arena.tscn -- --bot=reel --reel=director`); the main scene
  ignores `--arena` (boot warns "unknown launch arg"). First try wasted 2 min.
- 06:16 MILESTONE (this commit) the camera keeps a big form clear of quest 1's subtitle box (REPORT's polish
  candidate): StoryForms.lift_goal_m (bar_m reach vs HudView.subtitle_top), eased on the sim tick at 3 m/s, written
  to CollectCallView.forms_lift_m (view only, zero = bit-identical). Zero at the shipped 32 px/m and for base
  Rivet; Tonnage at 64 lifts about 0.8 m. ghost_forms.json `story_lift` (false = before). DECISION. A/B same input
  (quest1_forms_main `-- --ppm=64`, 440 frames, story_lift flipped for the before and restored):
  `M:frames/tonnage-subtitle-lift-quest1-ab-64ppm.png`. Judged: before, the press's lower legs under the box's
  tape; after, the press clear with paper between. 0 SCRIPT ERROR both runs. Unit 1013/0 (2 new tests), lint
  13/13. frames.json 15: + the lift A/B third; the card-fold A/B named in it (file kept). Seen, not ours: the
  longest quest 1 line overflows its subtitle box (REPORT note for the HUD owner).
  Registry rule applied (motion-quality-gating): same input, same frames A/B on the shipped path.
- 06:19 GATES evidence runner `--no-bench` on 9d610364, still tree (E:evidence-run-it11.log): PASS lint 13/13, unit
  1013/0, scenarios 47, parity bit-exact, look goldens 11/11 (worst 1.32), block 5/5 (worst 1.52); no re-bless.
- 06:20 PROOF the all-four cycle re-filmed on 9d610364 (`film.sh` arena `--bot=forms --form=all`, 900 frames, 0
  SCRIPT ERROR): `M:forms-cycle-all-32ppm.mp4` replaces the 02:27 cut. Same-frame A/B x3 centre crops (225 Tonnage,
  450 Dent, 525 Kerf, 675 Ohm, 825 base): `M:frames/forms-cycle-all-ab-32ppm-x3.png`. Judged: Tonnage and Dent
  unchanged; Kerf's limbs now read as limbs (were hairlines); Ohm reads as a teal-seamed shell with arms (was a
  brown blob); base Rivet the merged slim body. frames.json 15 (the cycle entry names the A/B).
- 06:24 PROOF all four in the city block (`film.sh` `--arena=city --bot=forms --form=all`, 960 frames, 0 SCRIPT
  ERROR): `M:forms-cycle-all-city-32ppm.mp4`, keys `M:frames/forms-cycle-city-keys-32ppm-x2.25.png` (settled frames
  160/308/530/700/868; 468/628 were mid-morph, re-cut). Judged: Tonnage, Dent, Kerf read; Ohm the weakest, a small
  rust shell with almost no glow on asphalt (Dent and Kerf sit in clear pools).
- 06:27 MILESTONE (this commit) OhmRig GLOW_M 1.9 -> 2.6 m, GLOW_A 0.4 -> 0.5 (DECISION). Same-input A/B frames
  680/700/760 x3: `M:frames/ohm-glow-city-ab-32ppm-x3.png`. Judged: after, a teal pool marks him as possessed,
  his size unchanged. Unit 1013/0 (E:unit-it11-ohm-glow.log); COMBAT CHECK director reel 16/16, 0 SCRIPT ERROR
  (E:director-reel-it11-ohm-glow.log). The city clip kept is the after take.
  FRICTION: frames.json trimming dropped the Dent and Tonnage target-comparison entries; the masters folder has
  no git, so those two entries were rebuilt from this JOURNAL (files intact). Fold entries into notes, never trim
  the tail blindly. frames.json 15: the city cycle first (names the glow A/B); ohm-morph clip named in the
  ohm-vs-target entry (file kept).
- 06:31 CHECK the wider Ohm glow under his voice apparition (OhmRig is shared with GhostApparition):
  `--arena=city --bot=forms --form=voices --apparition`, 1020 frames, 0 SCRIPT ERROR; frames 690-930 every 30, x1.5
  crops. Judged: the teal Ohm figure beside Rivet reads as before; the washed glow stays faint and does not spill
  over Rivet. No change needed; scratch deleted.
- 06:36 FINAL GATES evidence runner `--no-bench` on e865146d, still tree (E:evidence-run-it11-final.log): PASS lint
  13/13, unit 1013/0, scenarios 47, parity bit-exact, look 11/11 (worst 1.32), block 5/5 (worst 1.52).
  Ohm on the shipped quest 1 (quest1_forms_main, frames 940/980/1020, x3): `M:frames/ohm-glow-quest1-32ppm-x3.png`;
  judged: a clear teal pool, the bar clear above him.
- 06:39 MERGE n6-ghost-powers 97f49bf0 (Dent in quest 1: three parked ghost cars, solid for Rivet and the guards;
  NOTICE 06:31 answers theirs of 05:46) as 48404aba. Their merge of ours had kept their JOURNAL/REPORT, so the
  auto-merge took their text: restored ours from HEAD before committing (watch for this on every merge back).
  MERGE n5-cast 7005b5c8 (riot helmet plain crown) as 8b692f82. Unit (with import) 1016/0
  (E:unit-it11-merged2.log); COMBAT CHECK director reel 16/16, 0 SCRIPT ERROR (E:director-reel-it11-merged2.log).
- 06:44 CHECK Dent in quest 1 with the cars (ghost-powers' quest_ghost_rec `--ghost=dent`, 300 PNG ticks, 0 SCRIPT
  ERROR; seizes 1, strikes 4, kills 4, blasts 1, misses 5): our Dent body rides braced on the seized car on the
  shipped path; wreck after the blast; the reach frays when no car is left. `M:frames/dent-ride-quest1-32ppm-x2.png`
  (named in the dent-vs-target frames.json entry). Dent stays selectable in quest 1; no data change.

NEXT (iteration 12):
1. Merge n5-cast / n6-ghost-powers if they moved (`--no-ff --no-commit`; then ALWAYS `git checkout HEAD --
   JOURNAL.md REPORT.md evidence/director-reel-it7.log evidence/evidence-run-it7.log` even when the merge says
   clean), `--import`, unit, director reel (`res://dev/arena/arena.tscn -- --bot=reel --reel=director`).
2. Final evidence runner `--no-bench` on a still tree after the last merge, before the 08:30 freeze (last all-PASS
   on e865146d; the merged head 8b692f82 has unit 1016/0 and reel 16/16 only). REPORT for 08:40.
3. No polish candidate left from this list (Ohm at 64 and Kerf's city tour done below). Next weakest to look
   for: Dent at 32 px/m on the pale kerb (beige dummy on cream).
Session state 06:47: tree clean after this commit, no Godot process of mine running, no lock held (image.lock and
  bench.lock not taken this session); masters scratch holds film.sh, q1lift.sh and logs; frames.json 15, all present.
- 06:46 CHECK Ohm's wider glow at 64 px/m on the shipped quest 1 (q1lift.sh `--ppm=64`, 1060 frames, 0 SCRIPT
  ERROR, frames 940/1000): `M:frames/ohm-glow-quest1-64ppm.png` (named in the ohm-vs-target entry). Judged: a soft
  pool at the close-up zoom; the shell, seams and prongs are not swamped. No change. Session ends: tree clean after
  this commit, no Godot process of mine running, no lock held.
- 06:47 PROOF Kerf's city tour (`film.sh` `--arena=city --bot=forms --form=kerf`, 1080 frames, 0 SCRIPT ERROR):
  `M:kerf-tour-city-32ppm.mp4` (18 s), keys `M:frames/kerf-tour-city-32ppm-keys-x1.5.png` (named in the
  kerf-vs-target entry). Judged: jointed limbs trailing and a teal glow on asphalt and on the pale kerb; the exit
  burst back to the slim Rivet. Session ends 06:48: tree clean after this commit, no Godot process of mine running,
  no lock held.

## Iteration 13 (BUILD, 06:48 - 07:48)
- 06:48 read JOURNAL, git log, the ghost-powers and cast JOURNALs (no new REQUEST to us). Both moved.
- 06:50 MERGE n6-ghost-powers d439f520 (scenario_quest1_dent) as 08db533d; MERGE n5-cast 84ed1bd1 (quest 1's cast
  sprites re-captured from the slim rigs) as b0c7fdf2; JOURNAL/REPORT/it7 logs kept ours. Unit (with import)
  1016/0 (E:unit-it13-merged.log); COMBAT CHECK director reel 16/16 chapters n/n down, 0 SCRIPT ERROR
  (E:director-reel-it13-merged.log).
- 06:55 CHECK Dent at 32 px/m on the city (`film.sh --arena=city --bot=forms --form=dent`): on asphalt he reads;
  the square tour never reaches the pale kerb. Added FormsTourBot `--side=<ticks>` (dev; 120 puts legs 2-3 on the
  south kerb). On the kerb (ticks 240-360): the beige dummy's cream rim melts into the cream slab; the yellow discs
  and the teal pool carry him, his limbs do not.
- 07:05 MILESTONE (this commit) Dent's ink keyline: GhostRim.keyline(rig) puts an INK silhouette
  (ghost_keyline.gdshader) under each RigBuild cream halo of DentBody's cut rig (child of the halo: follows its
  view scale, hides with it at close-ups; z under every halo); sync_keyline follows part swaps. DECISION. Same-input
  A/B (`--side=120`, `--no-keyline` for the before), ticks 240/300/360/420 x3:
  `M:frames/dent-keyline-kerb-ab-32ppm-x3.png`. Judged: after, a die-cut ink line outlines him on the kerb; on
  asphalt no visible change. 64 px/m (`--ppm=64`): the keyline fades with the halos; the art's own line carries
  him: `M:frames/dent-keyline-kerb-64ppm.png`. Clip `M:dent-kerb-city-32ppm.mp4`. 0 SCRIPT ERROR all runs
  (FRICTION: the first take hit a shadowing warning-as-error; run --check-only first). Unit 1018/0 (2 new tests,
  E:unit-it13-keyline.log); lint 13/13; COMBAT CHECK director reel 16/16, 0 SCRIPT ERROR
  (E:director-reel-it13-keyline.log). frames.json 15 (the keyline A/B second; the kerf-bar entry folded into
  kerf-vs-target). Registry rule applied (motion-quality-gating): same input A/B at game zoom, on the live path.
- 07:13 GATES evidence runner `--no-bench` on 45c69934, still tree (E:evidence-run-it13.log): PASS lint 13/13, unit
  1018/0, scenarios 48 (ghost-powers' quest1_dent in), parity bit-exact, look 11/11 (worst 1.33), block 5/5 (worst
  1.53); no re-bless.
- 07:15 FIX (this commit) DentBody is shared with Dent's voice apparition, whose wash() would have drawn the keyline
  through the ghost material (a wider teal edge). Keylines are named `keyline` and wash hides them. Checked:
  `--arena=city --bot=forms --form=voices --apparition`, 1020 frames, 0 SCRIPT ERROR; Dent's voice (frames 280/330)
  a teal ghost with its glow edge, no ink: `M:frames/dent-voice-no-keyline-city-32ppm-x1.5.png` (named in the
  keyline entry). Unit 1018/0 (E:unit-it13-apparition.log).
- 07:22 CHECK the keyline on the shipped quest 1 (q1lift.sh, 1060 frames, 0 SCRIPT ERROR): Dent on asphalt reads
  as before, the keyline a thin dark edge on the teal pool: `M:frames/dent-keyline-quest1-32ppm-x3.png` (named in
  the keyline entry). Scratch renders deleted. REPORT section 10 + iteration 13 gates.
- 07:19 CHECK Ohm on the pale kerb (`--form=ohm --side=120`, 480 frames, 0 SCRIPT ERROR): he is slower and walks
  the cream crossing stripes rather than the slab; his rust shell is darker than the cream and reads with its
  teal seams. No keyline needed; scratch deleted.
- 07:20 MERGE n6-ghost-powers a30a5ce3 (quest_crush_rec, Ohm burns cars out) as fc341d84; MERGE n5-cast 473a405e
  (docs) as ebc5ed9d; JOURNAL/REPORT/it7 logs kept ours. FRICTION: the evidence runner refuses a dirty tree, and a
  log written into evidence/ makes it dirty: write the log to masters scratch, copy it in after.
- 07:28 FINAL GATES on ebc5ed9d, still tree (E:evidence-run-it13-final.log): PASS lint 13/13, unit 1019/0,
  scenarios 48, parity bit-exact, look/block goldens PASS; director reel 16/16, 0 SCRIPT ERROR
  (E:director-reel-it13-final.log).
- 07:31 CHECK Tonnage on the pale kerb (`--form=tonnage --side=120`, 480 frames, 0 SCRIPT ERROR): the gunmetal press
  with its ink plates and hazard stripes reads strongly on the cream slab. No change; scratch deleted. All four
  forms are now judged on both floors (Dent needed the keyline; Kerf it11, Ohm and Tonnage above did not).

NEXT (iteration 14, the last before the 08:30 freeze):
1. Merge n5-cast / n6-ghost-powers if they moved (`--no-ff --no-commit`; then ALWAYS `git checkout HEAD --
   JOURNAL.md REPORT.md evidence/director-reel-it7.log evidence/evidence-run-it7.log`), `--import`, unit,
   director reel (`--headless --quit-after 24000 --path project res://dev/arena/arena.tscn -- --bot=reel
   --reel=director`).
2. Final evidence runner `--no-bench` on a still tree (log to masters scratch, copy in after) before 08:30;
   last all-PASS on ebc5ed9d. Then REPORT: turn the DRAFT line into final and add the session-state line.
3. Polish candidate if time: re-film the all-four city cycle with the keyline (forms-cycle-all-city-32ppm.mp4 is
   from 06:24, before it) only if Dent's frames in it change visibly; otherwise leave it.
Session state 07:32: tree clean after this commit, no Godot process of mine running, no lock held (image.lock and
bench.lock not taken); masters scratch holds film.sh, q1lift.sh and logs; frames.json 15, all present.
- 07:31 NEXT 3 done: the all-four city cycle re-filmed on ebc5ed9d (`film.sh --arena=city --bot=forms --form=all`,
  960 frames, 0 SCRIPT ERROR); Dent at frame 308 old | new: a thin ink edge on his pool, otherwise identical.
  `M:forms-cycle-all-city-32ppm.mp4` replaced (frames.json note dated). Iteration 14's NEXT is now 1 and 2 only.
  Session ends 07:33: tree clean after this commit, no Godot process of mine running, no lock held.

## Iteration 14 (BUILD, 07:32 - 08:30)
- 07:33 read JOURNAL, git log; both lanes moved (n6-ghost-powers bbc861d0 carries n5-cast 02e4295c). No new
  REQUEST to us.
- 07:34 MERGE n6-ghost-powers bbc861d0 (scenario_quest1_ohm; n5-cast's quest 1 sprite Rivet sticker tier) as
  ed6d2d31; JOURNAL/REPORT/it7 logs kept ours. Unit (with import) 1018/1: the known test_noir_shadows flake
  ("Parameter t is null"); the re-run gave 1019/0. COMBAT CHECK director reel 16/16 chapters n/n down, 0 SCRIPT
  ERROR (E:director-reel-it14-merged.log).
- 07:39 FIX (this commit) a merge-integration bug: n5-cast 02e4295c made CastView draw base Rivet from the 32 px/m
  sticker capture (`_lod_art`), but our StoryForms branch of CastView._rivet (forms_drawn, on by default on the
  shipped quest 1) still drew the old `rivet` art capture, so the shipped quest 1 silently kept the cream sprite
  Rivet before and after every transformation. That branch now takes `_lod_art("rivet")` too. Same-input A/B
  (q1lift.sh, 1140 frames, 0 SCRIPT ERROR; before = the 07:22 film of the same script):
  `M:frames/quest1-sticker-rivet-forms-ab-32ppm-x3.png`, frames 100 (base) / 170 (mid-morph: the form stands
  in, unchanged) / 470 (base after the exit). Judged: after, base Rivet prints the tan core and hazard collar the
  cast lane shipped, at both ends of the transformation. 64 px/m keeps the art capture (above flat_below), same
  as n5-cast. Lint 13/13, unit 1019/0 (E:unit-it14-lod.log). The killed first evidence run (tree edited
  mid-run) is not counted.
- 07:48 FINAL GATES on 5be03adb, still tree (E:evidence-run-it14-final.log): PASS lint 13/13, unit 1019/0,
  scenarios 49, parity bit-exact (mutation at 629), look 11/11 (worst 1.33), block 5/5 (worst 1.53); no re-bless.
- 07:49 PROOF the shipped quest 1 forms clip re-filmed on 5be03adb (q1lift.sh, 1140 frames, 0 SCRIPT ERROR):
  `M:story-forms-quest1-shipped-32ppm.mp4` (19 s) replaced; keys 140 (base, sticker tier) / 450 (exit morph) /
  600 (Dent) / 1120 (base after Ohm's exit): `M:frames/story-forms-quest1-sticker-keys-32ppm.png` (named in the
  story-forms entry, frames.json still 15, all present). REPORT section 11 + iteration 14 gates; DRAFT line final.
- 07:52 REFACTOR (this commit) CastView._rivet picks the sprite art once (`_lod_art("rivet")`) for both the
  story-forms branch and the old Hauler branch, so the two can no longer drift apart on a cast-lane art change.
  Checked: q1lift.sh 520 frames, 0 SCRIPT ERROR; frames 140 and 480 identical to the 07:49 film (scratch, deleted).
  Lint 13/13, unit 1019/0.
- NOTICE to n5-cast (no action needed): your 02e4295c sticker tier was bypassed on the shipped quest 1 by our
  StoryForms branch of CastView._rivet (story_forms on by default) until 5be03adb; fixed here, so it reaches the
  morning merge through n6-ghost-forms. A/B `M:frames/quest1-sticker-rivet-forms-ab-32ppm-x3.png`.
- 07:53 MERGE n6-ghost-powers 2ca168ff (Kerf path_cut_m, scenario_quest1_kerf / _tonnage) as its own merge; MERGE
  n5-cast c7549272 (cf64342e: the grown Hauler sprite keeps the art capture; d63b380c: their REQUEST for our
  forms_drawn branch, already met by 5be03adb) as 921e86fc. FRICTION: git auto-merged cast_view.gd cleanly but
  left a second `var art` in the Hauler else (would shadow our top-level pick, warnings are errors); removed in
  the merge commit. JOURNAL/REPORT/it7 logs kept ours. Unit (with import) 1020/0 (E:unit-it14-merged2.log);
  COMBAT CHECK director reel 16/16 chapters n/n down, 0 SCRIPT ERROR (E:director-reel-it14-merged2.log). Quest 1
  (q1lift.sh 520 frames, 0 SCRIPT ERROR): frames 140/480 identical to the 07:49 film (scratch, deleted).
- 08:05 FINAL GATES on dc9af2e6, still tree (E:evidence-run-it14-final2.log): PASS lint 13/13, unit 1020/0,
  scenarios 51, parity bit-exact (mutation at 629), look 11/11 (worst 1.33), block 5/5 (worst 1.53); no re-bless.
  REPORT gates updated: dc9af2e6 is the lane's final gated head.

NEXT (the 08:40 report session / the Director's merge):
1. REPORT is final as of dc9af2e6. If n5-cast or n6-ghost-powers move again, merge (`--no-ff --no-commit`, then
   `git checkout HEAD -- JOURNAL.md REPORT.md evidence/director-reel-it7.log evidence/evidence-run-it7.log`), and
   READ the cast_view.gd merge result even when git calls it clean (today it left a duplicate local). Then unit,
   the director reel and the evidence runner `--no-bench` on a still tree (log to masters scratch, copy in after).
2. Calls for the owner are unchanged: teal-all-over vs printed machine (`--teal-forms`), and voice apparitions in
   quest 1 (`story_voice`).
Session state 08:06: tree clean after this commit, no Godot process of mine running, no lock held (image.lock and
bench.lock not taken); masters scratch holds film.sh, q1lift.sh and logs; frames.json 15, all present.
- 08:08 CHECK the shipped quest 1 at 64 px/m on dc9af2e6 (q1lift.sh `--ppm=64`, 620 frames, 0 SCRIPT ERROR): frame
  140 base Rivet keeps the art capture (above flat_below, as n5-cast intends), 300 Tonnage, 600 Dent; no change
  from the merges. Scratch deleted.
- 08:08 MERGE n6-ghost-powers 8d3b518a (their gate log; carries our cd56e482) and n5-cast 775951e7 (10607e11: the
  grown Hauler sprite cross-fades sticker -> art) as d5748061. Read the merged cast_view._rivet: our single base pick
  plus their Hauler cross-fade, no duplicate. Unit 1020/0 (E:unit-it14-merged3.log); COMBAT CHECK director reel
  16/16 n/n down, 0 SCRIPT ERROR (E:director-reel-it14-merged3.log); quest 1 (q1lift.sh 520 frames, 0 SCRIPT
  ERROR) frames 140/480 identical to the 07:49 film (scratch, deleted).
- 08:18 FINAL GATES on 0b738cbc, still tree (E:evidence-run-it14-final3.log): PASS lint 13/13, unit 1020/0,
  scenarios 51, parity bit-exact (mutation at 629), look 11/11 (worst 1.33), block 5/5 (worst 1.53); no re-bless.
  REPORT: 0b738cbc is the lane's final gated head (supersedes the dc9af2e6 line in the NEXT above).
FREEZE 08:19: tree clean after this commit, no Godot process of mine running, no lock held (image.lock and
bench.lock not taken this session); masters scratch holds film.sh, q1lift.sh and logs; frames.json 15, all present.
