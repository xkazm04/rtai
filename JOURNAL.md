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
