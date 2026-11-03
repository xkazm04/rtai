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
