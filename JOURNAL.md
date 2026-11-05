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
