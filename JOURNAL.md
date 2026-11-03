# JOURNAL: lane rivet-motion (branch e-motion), evening run 2026-11-03

## Iteration 1 (20:50-21:35, BUILD)
- Read: brief, AGENTS.md, d5-cast REPORT (size_k 1.2 hunched guard, rig_footprint.gd), RivetPlan,
  BodyPlan, RigArm, T2 concept. answers.json empty at 20:50.
- Registry: not read this iteration (time); owed next iteration before the locomotion design
  (`realtime-combat-semantics`, `motion-quality-gating`).
- Measured T2 by eye on the 1104x1472 image: shoulder to wrist ~390 px, hip to sole ~480 px
  (arm:leg ~0.8), claw ~130 px (~0.27 of the leg), forearm about a third of the torso width.
  The day rig: upper 159 + fore 182 = 341 vs thigh 166 + shin 137 = 303 (1.13).
- MILESTONE: `RivetPlan.ARMS` [arm_k, hand_k, arm_w] per form; BodyPlan gains `hand_k`, `arm_w`;
  RigArm thins the arm segments and scales the claw. Default (base) = T2 ratio (0.72, 0.78, 0.8);
  `mild` (0.85, 0.9, 0.9) and `day` (the day's arms) kept as A/B forms. King (open form) unchanged.
  Guard and hang targets scale about the shoulder so the guard stays inside the shorter reach.
  Sim untouched (radius 0.6 m), so replay/parity cannot move. Look goldens may move (Rivet in frame).
- Footprint (rig_footprint.gd, headless): day 1.90 x 2.05 m, mild 1.72 x 2.01, base 1.68 x 1.97;
  cop 1.27 x 1.88, ped 0.69 x 1.34. Width is now the torso + hose, not the arms.
- Evidence: `gtai-masters/eve/rivet-motion/frames/rivet-proportions-vs-t2-128ppm.png` (T2 beside
  day | mild | T2-ratio | cop | ped, idle and walk-in-place), 32/48 px/m crops; dev scene
  `project/dev/rivet_motion/lineup.gd`.
- ASK rivet-motion-1 written 21:13 (A = T2 ratio default, B = mild, C = keep). Switching = edit
  `RivetPlan.ARMS[FORM_BASE]` (one row).
- FRICTION: `--check-only` on a dev script fails on autoloads (`Log`) - expected; the windowed run
  was fine.
- Gates at 5dc151c + test fix: lint 13/13 (pre-commit hook), unit 538/538 (after updating
  `test_rivet_plan_is_the_cutout_lanes` to pin the day form's 159 and the base's scaled length),
  scenarios exit 0 (19 incl. the 60 s replay). Look goldens / evidence run NOT run this iteration:
  Rivet's arms are in the look golden frames, so they may need a dated re-bless (next iteration).
- Owner page: `gtai-masters/eve/rivet-motion/frames.json` (4 entries so far).
- Found for item 2: the sim side already does twin-stick (TopDownMover faces the aim at
  `turn_dps`, strafe_scale slows off-facing moves) and RigGait already steps the feet along
  `vel_in`. What is missing is the HIPS: the pelvis and the knee poles stay on the aim facing, so a
  strafe crosses the legs and a backpedal reads as a forward walk.
- NEXT: (1) re-read answers.json (rivet-motion-1). (2) Run `node tools/evidence/run.mjs --no-bench`
  to see whether the look goldens moved; if so, re-bless once with a decisions.md line.
  (3) Item 2: add `CutRig.hip_yaw` (Rivet-only via `BodyPlan.hip_follow`, default 0 so cops and
  peds stay byte-identical): target = wrap(vel angle - facing), folded by PI when |x| > 100 deg
  (backpedal), clamped to `hip_twist_max` (~70 deg), springed; pelvis.rotation += hip_yaw, the
  knee pole in `_solve_leg` rotated by hip_yaw. Then a 32/48 px/m clip of Rivet circle-strafing
  a fixed aim point (dev scene in `project/dev/rivet_motion/`, `--fixed-fps 60`), plus the turn
  rate number. (4) Locomotion clips (item 3), registry subjects first.
