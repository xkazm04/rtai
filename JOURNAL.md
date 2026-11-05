# JOURNAL: lane held (d7, 2026-11-05)

Branch `d7-held`, cut from main `1028c15d`. Evidence: `evidence/` + `C:\Users\kazda\kiro\gtai-masters\d7\held\`.

## Iteration 1 (15:13-16:13, BUILD)

- 15:13 START. Read brief, git log. No `d7-calls` JOURNAL yet (no `REQUEST held: cast-1 landed`), so
  holds are built on main's Rivet (1.2x); merge cast-1 when it lands.
- 15:15 SURVEY. Held view: `RivetHeldView` (features/player/rivet_held_view.gd) places the weapon
  sprite on the gun claw; `RigGrip` (features/characters/rig_grip.gd) poses both arms per Kind
  (ONE_HAND, TWO_HAND_LONG, SHOULDER, HIP, THROWN) only *while aiming*; `MeleeSwing` drives the blade
  angle. `rivet_arsenal.json` grip classes: katana/plasma_sword are under `two_hand_long` (the long
  gun class!), electro_baton under `one_hand`; there is no blade class. That is the root of the
  owner's "katana not natural": a sword gets a rifle's draw/kick/move numbers and no hold of its own.
- 15:20 DECISION hold table as data: `project/data/tables/held_classes.json` (+ schema, `HeldTable`):
  blade, sidearm, long_gun, tube, heavy, chainsaw, thrown. RigGrip reads its poses from the rows
  (the night's SHAPE/GUN_SIDE constants moved into data unchanged). `rivet_arsenal.json` keeps the
  sim-facing draw/stow/kick/move per grip class (untouched: no replay change). Also in docs/decisions.md.
- 15:20 MILESTONE two-hand blade grip deleted (owner pick combat-notes-1 A): `--two-hand-grip`,
  `RigGrip.melee_hilt`, `CutRig.two_hand_melee/hilt_dir`, `MeleeSwing.two_handed`, test + probe.
- 15:22 DECISION look-4 over cast-3: `held_size_ref` 0 (guns keep class size). docs/decisions.md.
- 15:28 MILESTONE commits 728e1f99 (hold table + blade guard + grip deletion), 60c959dc (look-4).
  Unit 1093/0, lint 13/13.
- 15:35 FRICTION main checkout `C:\Users\kazda\kiro\gtai` has a stale class cache (214 parse errors
  in a run): never use it for "before" renders. Made a detached worktree `../d7-held-before` at
  1028c15d (native bin copied in, imported) for befores.
- 15:40 FRICTION/fix: first blade build took the blade's angle from the claw sprite (IK forearm);
  at the low guard the forearm runs nearly across the body, so the katana lay across Rivet's front
  (`dev/held/hold_probe.gd` showed it). Fix: `RigGrip.blade_angle` = aim line (or facing) turned in
  by wrist_rad; that is also the line MeleeSwing's arc is measured from, so the swing is unchanged
  in shape. Probe still: blade guard reads as "a robot holding a katana"; the old rifle hold of the
  katana (off torch arm under the blade) is visibly wrong next to it.
- Registry rules applied: `realtime-combat-semantics` not consulted yet (no time this iteration);
  the swing keeps anticipation/smear/follow-through (MeleeSwing untouched apart from the grip).
- DEBT: `rivet_held_view.gd` at 300 lines (hard stop). Split the placement into a helper next.
- 15:38 MEASURE gates on 4d184d95 code: lint 13/13; unit 1093/0 (`evidence/held-it1-unit.log`, incl.
  test_held_classes 7 tests with 3 planted faults); director reel `--rigs --bot=reel --reel=director
  --loadout=pistol` 7200 ticks: 19/19 chapters down incl. plasma_sword_deflect and electro_baton,
  0 SCRIPT ERROR (`evidence/held-it1-reel-director.log`).
- 15:41 MILESTONE blade evidence in gtai-masters/d7/held: `blade_hold_ab_48ppm_target.png` (target
  r2_w7 beside before/after, ticks 510 + 600), `blade_hold_ab_32ppm_city.mp4` (21 s real time),
  `blade_hold_ab_64ppm_slow.mp4`, `blade_hold_probe_rig_idle_aim.png`; frames.json written. Looked
  at each: at tick 600 the before is a stick out of the chest; the after is a guard with the blade
  crossing forward, like the target's second panel. Weak: at 32 px/m the claw-on-hilt is 3-4 px; the
  hold reads by the blade's angle and place, not by a visible grip (new claw art would help).
- 15:43 READ d7-calls JOURNAL: REQUEST held, cast-1 landed at 16272697 (+ 66bf4fbe cast-8/9). Their
  FINDING: with cast-1 the pistol looks long at 32 px/m. On this branch look-4 already ships
  held_size_ref 0, so guns draw at class held_scale (larger than main's 0.81x). Class sizes vs the
  1.1x Rivet = brief item 3: judge per class after the merge.
- 15:44 SURVEY long gun (next): target r2_w5 holds every gun on the centre line ahead of the chest,
  both claws on it, barrel straight up the aim. Ours: the line starts 0.42 out toward the gun
  shoulder (RigGrip's helmet clearance), the stock beside the helmet. Plan: long_gun `across` toward
  0 with `gun_reach` far enough out that the stock clears the helmet ahead (test_rivet_aim_clear
  measures the gap; it must become "ahead of" rather than "beside").
- 15:47 MERGE d7-calls cdaaec62 (cast-1 16272697 Rivet 1.1x, cast-8/9 66bf4fbe) into d7-held. One
  conflict: both lanes keep a root JOURNAL.md (add/add); kept ours (the calls journal stays on
  d7-calls; the Director should move each lane's journal under docs/ at merge). decisions.md merged
  clean.
- 15:49 MEASURE merged tree 83fea366: unit 1095/0. Sizes on the 1.1x Rivet with look-4 class sizes
  (`sizes_after_cast1_48ppm_sheet.png`, frames.json entry 2): the Gatling reads heavy at the hip,
  the katana reads, the pistol reads large and pale in the claw (one_hand held_scale 1.5): a size call.
- 15:50 DEBT paid: `RivetHeldView._reload_k` moved to `ArsenalTable.reload_phase` (held view 300 -> 286
  lines). Unit 1094/1: `test_noir_shadows` (known flake) failed twice then passed 2/2 twice alone; 2/2
  on main.
- NEXT (iteration 2, in order):
  1. Long gun hold toward r2_w5: the line on the centre ahead of the chest, both claws on it
     (long_gun `across` -> ~0, `gun_reach` so the stock sits ahead of the helmet); rework
     test_rivet_aim_clear from "beside" to "clear of" the helmet. Probe first
     (`dev/held/hold_probe.gd -- --holds=long_gun --aim --weapon=plasma_rifle`), then city A/B with
     `../d7-held-before` (detached at 1028c15d, native bin copied, imported) as the before.
  2. Wire `stride_k` / `lean_px` from held_classes.json into the walk (they are data only so far) for
     the heavy class; then heavy, sidearm (size: one_hand held_scale 1.5 looks large at 1.1x), chainsaw.
  3. Off-claw art: at 32 px/m the claw-on-hilt is 3-4 px; Codex claw-sheet under image.lock if a
     closed claw around a grip is needed (arms/claws only, never guns).
  4. Read registry `realtime-combat-semantics` + `depth-ordered-layered-art` before the heavy class.
  5. REPORT calls so far: (a) blade wrist_rad 0.45 (alt 0 = straight ahead), (b) look-4 over cast-3,
     (c) pistol class size on the 1.1x Rivet.
- 15:55 FINDING (long gun probe, `long_gun_probe_offarm_now_vs_centre.png`): in every two-claw hold
  (long_gun, tube, heavy) Rivet's off arm ends in the torch tool, which sticks out diagonally past
  the weapon instead of closing on the foregrip; that, more than the line's place, is what reads as
  "not natural" (the owner's cast-3 note). A centre-line variant (across 0) barely changes it; data
  restored, nothing shipped. So NEXT item 1 starts with the off arm: an off claw part (Codex claw
  sheet, arms/claws only, under image.lock) shown while a two-claw weapon is held, or the torch tip
  hidden and the forearm end-capped as a stopgap; then the centre line toward r2_w5.
- 15:56 FRICTION: frames.json had not been written (an `rm -rf` of a busy scratch dir, the shell's cwd,
  failed and short-circuited the `&& cat >`). Written now with 6 entries. Lesson: never chain
  output after `rm` of a dir the shell may sit in; cd out first.
- 15:58 MEASURE blade on the merged 1.1x Rivet (`blade_hold_on_cast1_48ppm_sheet.png`, frames.json
  entry 2; 0 script errors): the guard still reads; the katana is long beside the smaller body but
  reads as a sword. Keep the blade size; judge again in the sizes pass (NEXT 2).

## Iteration 2 (15:56-16:56, BUILD)

- 15:56 START. Read JOURNAL, git log. Item: the long-gun off arm (iteration 1's FINDING).
- 15:58 SURVEY. Only the gun side (L) has a hand part; the off side (R) is `r_forearm`, the torch
  tool: its art spans 350 px against an IK forearm of 182*arm_k, so RigGait.place draws it about
  twice the arm's length past the hand point. That is why the torch overshoots the barrel.
- 16:00 DECISION off claw from existing art, no Codex round: `r_forearm_grip` / `claw_grip` are
  `l_forearm` / `claw_closed` mirrored across their length (PIL, parts.json pivots mirrored, a
  `derived` note in each entry; also in `art/d5/rivet` because test_rig_plans checks every plan
  part in each Rivet art folder). Why: the jaw art already exists and the image lock + moderation
  cost an iteration; a drawn claw-around-a-grip can still replace `claw_grip` later as one file.
- 16:01 FRICTION first try: claw on the IK hand point, turned along the line: it floated an open
  pincer a gun-width above the barrel. Two causes: the drawn weapon hangs off the gun claw's
  GRIP_U point, about 120 px off RigGrip's IK line; and a pincer along the barrel grips nothing.
- 16:03 MILESTONE `RigOffClaw` (features/characters/rig_off_claw.gd): the off hand's IK target
  is the wrist beside the drawn barrel (through the grip point toward the aim), the claw turned
  ACROSS_RAD 1.25 so its jaws straddle the barrel, z over the weapon. Probe: reads as a claw
  clamping the foregrip from the off side, the plain forearm running back to the off shoulder.
  `--torch-off-arm` is the A/B's before. DECISION in docs/decisions.md.
- 16:05 FRICTION unit run: 14 failing, script errors: ghost/King/d5 forms build on RivetPlan with
  their own art folders (no claw_grip). Fix: `RigOffClaw.has_art` gates the part; `holds` keys on
  the side's grip sprite. test_rig_grip's off-claw test re-measured on the drawn line (the jaws,
  0 px off it); new test_rig_off_claw (planted: the IK-line hand misses the barrel by 212 px).
  `-gselect=test_rig_` 0 failing.
- Registry rules applied: none read this iteration (time); the motion stays RigArm's IK, the fire
  recoil still pulls both hands back along the line (OFF_RECOIL), so kick reads in both claws.
- 16:08 MILESTONE commit 2f4d3f1d (off claw). Unit 1097/2: test_d5_provenance (the d5 copies had no
  provenance line; 4 lines added, passes alone) and test_noir_shadows (known flake, passes alone).
  FRICTION: python text-mode writes on Windows left CRLF in edited .gd/.json (git normalises on
  commit); write with newline='\n'.
- 16:12 EVIDENCE gtai-masters/d7/held: `long_gun_offclaw_ab_64ppm_target.png` (r2_w5 beside
  before/after at 3 s and 18 s), `long_gun_offclaw_ab_32ppm_city.mp4` (25 s, 0 script errors both),
  `long_gun_offclaw_ab_64ppm_slow.mp4`; frames.json now 10 entries. Looked: at 64 px/m the aimed
  frames now show the off arm going to the gun with a claw on it (before: the torch hung free or
  jutted past). At 32 px/m it is a few pixels. Still short of r2_w5: the gun sits beside the gun
  shoulder, not ahead on the centre line, and the pale claw blends into the pale body.
- 16:14 MEASURE director reel on 2f4d3f1d (`--rigs --bot=reel --reel=director --loadout=pistol`,
  7200 ticks, headless): 19/19 chapters down, 0 SCRIPT ERROR (`evidence/held-it2-reel-director.log`).
- 16:16 DECISION sidearm size: one_hand held_scale 1.5 -> 1.2 (docs/decisions.md; owner call).
  `sidearm_size_ab_48ppm_sheet.png`: at 1.5 the pistol was as long as the forearm; at 1.2 it reads
  as a pistol in a claw. test_held*/test_rivet_* pass.
- 16:19 PROBE + REJECT long-gun line forward toward r2_w5 (across 0.2, gun_reach 0.6, off_reach 0.95):
  the probe still looked closer to the target, but filmed at 64 px/m it hung the gun detached below
  the body and off the aim in two of four frames (`long_gun_line_forward_rejected_64ppm.png`).
  Data restored. The centre-line hold needs the carry (RivetCarryAngle) and the beside-the-helmet
  shift reworked with it, not just three numbers. FRICTION: the first probe after a data edit
  printed 11 SCRIPT ERRORs once (not reproducible on rerun; likely a cache reload).
- 16:24 MILESTONE f9810099 the class walk: `RigGrip.walk` feeds held_classes.json stride_k into
  RigGait's stride and lean_px into RigPose's body lean (back, against the weight) while the weapon
  is out. Test in test_rig_grip (planted: stowed = plain walk). Evidence `heavy_walk_ab_64ppm.mp4`:
  SUBTLE (cadence only; the 10 px lean barely shows). Stronger is a data value per row.
- 16:26 frames.json 13 entries, all files present. d7-calls has 6 new commits (look group incl. "the
  Gatling at true width", Dent ghost powers): merge after the head gates finish.
- 16:33 MEASURE gates on f9810099: lint 13/13; unit 1100/0 (`evidence/held-it2-unit-head.log`);
  scenarios exit 0 (`evidence/held-it2-scenarios.log`).
- 16:30 MERGE d7-calls 41079a05 (look group 42feb65c incl. the Gatling at true width; Dent ghost
  powers e419a047) -> 9ee6746e. JOURNAL.md conflict: kept ours. Merged tree: lint 13/13, unit
  1106/0 (`evidence/held-it2-unit-merged.log`).
- 16:34 LOOK the Gatling on the merged tree (`gatling_hold_merged_48ppm_strip.png`, frames.json
  14 entries): reads heavy at the hip with the off claw on it. Unverified: in one frame the tracers
  run opposite the barrel (probably a cop's shots).
- NEXT (iteration 3, in order):
  1. Off-claw art: the pale mirrored claw blends into the pale body at 32-64 px/m. Either a drawn
     "claw closed around a grip" part (Codex claw sheet under image.lock, arms/claws only) or a darker
     tone on `claw_grip` (cheap first try). Re-film the long-gun A/B at 32 px/m.
  2. The centre-line long-gun hold toward r2_w5: a real rework of RivetCarryAngle + the
     beside-the-helmet shift together with across/gun_reach (the 3-number try failed, 16:19).
  3. Chainsaw class end to end (both claws at the hip: the off claw on the top handle, fore_u 0.3);
     it already gets the off claw (HIP kind), so film it and check the grind judder.
  4. Heavy walk: strengthen if the owner wants it felt (lean_px 10 -> 25?); film at 64 px/m first.
  5. Read registry `realtime-combat-semantics` + `depth-ordered-layered-art` (still owed).
  6. REPORT calls so far: (a) blade wrist_rad 0.45; (b) look-4 over cast-3; (c) sidearm held_scale
     1.5 -> 1.2 (`sidearm_size_ab_48ppm_sheet.png`); (d) the off claw on two-claw weapons vs the
     torch (`--torch-off-arm`; `long_gun_offclaw_ab_*`); (e) heavy walk strength.
  7. By 19:30: export RTAI.exe per the int-day recipe in docs/decisions.md; REPORT.md at 19:40.
