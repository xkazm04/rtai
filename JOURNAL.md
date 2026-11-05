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
