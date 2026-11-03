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

## Iteration 1, continued (20:56-21:20)
- The clock read 20:56 after the proportions commit, so I carried on with NEXT.
- Look goldens: the evidence run at 0287cec passed them unblessed (11/11, worst 0.42; block 5/5)
  and parity was exact. Its unit and scenario FAILs came from my edits landing mid-run ("tree
  changed during run"). Scenarios re-run alone: exit 0 at bf41369.
- FRICTION (shared env): `test_save_slots` fails 13-46 asserts with error 16, even run alone.
  project.godot sets `use_custom_user_dir` ("RTAI Uprising"), so every lane's worktree writes
  the same %APPDATA% save dir and concurrent gate runs collide. Not this lane's code (the rig is
  view-only). For the Director: re-run it on a quiet machine before calling it red.
- MILESTONE bf41369, twin-stick hips: `RigHips` (the hips' yaw follows the walk, folds on a
  backpedal past 105 deg, clamps at `hip_twist_max` 70 deg, spring k 140). Rivet only
  (`hip_follow` 1). The strafe foot gauge went 0.4 -> 148 part px (test_rig_hips: the planted
  locked rig has to measure narrower). Clips `clips/strafe-hips-{32,48,96}ppm.mp4`.
  Honest read: from straight above the torso hides most of the legs, so the hips help a little
  and the stride has to get visible (item 3).
- MILESTONE 02524d3, claw combo as data: `data/tables/rivet_melee.json` (+ schema),
  `MeleeTable`/`MeleeHit`/`MeleeCombo` in features/player. Buffered chain at `cancel_ticks` 4,
  `combo_window_ticks` 12, the finisher ends the chain. The shock numbers are in the table; its
  logic comes next. Not wired into quest 1 (its replay log has no combo; the arena plugs it in).
- MILESTONE a692b60, strike pose: `RigClips.strike()` (windup anticipation twist, ease-out
  extension on the active frames, smoothstep recovery); hit 1 claw, hit 2 torch arm (twist
  mirrored), hit 3 both hands. Clip `clips/combo-claw-{48,96}ppm.mp4` on a 3-dummy line.
- Feel numbers (measured, data-true at 60 Hz; not input latency):
  - claw lands at 5 ticks = 83 ms after the press;
  - a mashed chain lands at 0 / 267 / 533 ms;
  - the chain recovers at 56 ticks = 0.93 s;
  - the finisher knocks back 2.5 m.
  Input-to-motion latency is NOT measured yet (it needs the live input path).
- REQUEST 1 -> gunplay: the shared hit flash (`RigClips.hit` -> `set_tint`) paints a struck
  ped/cop vermilion-red. That breaks "red is blood only". Your hit-feel module should own a
  non-red flash (cream/white).
- Registry applied (motion-quality-gating): craft, responsiveness and integrity are reported
  separately; the dimensions are defined by what is visible (gauge, landing tick); no latency
  number was made up.
- Owner page `gtai-masters/eve/rivet-motion/frames.json`: 10 entries.
- NEXT (iteration 2):
  1. answers.json (rivet-motion-1).
  2. Charged shock: `MeleeShock` (hold to charge from `charge_min` to `charge_full`; release =
     stun scaled by charge, chain hops to metal within `chain_radius_m`) + a test with a planted
     fault + a clip.
  3. Sprint (held key, above 5 m/s, owner C19) and dodge roll (i-frames, recovery) in a
     `PlayerMotion` + table rows. The sprint key needs an input_actions row (shared file: a
     minimal change, logged).
  4. Visible stride: try `gait_scale` > 1 for Rivet and a feet-ahead lean at run; measure the
     foot reach past the torso silhouette at 32 px/m.
  5. `arena_stations/rivet-motion.json` once the arena lane's station schema exists (check
     their branch or docs; otherwise propose one).
  6. Melee weapons framework (`melee_weapons.json`: baton, katana) on MeleeCombo rows.

## Iteration 1, last entries (21:16-21:22)
- MILESTONE a6f231c: `MeleeShock` (charge, scaled stun, metal-only chain) + test_melee_shock
  (4/4, planted zero-radius fault caught). Scenarios exit 0 on the combo tree (a692b60).
- Stride probe (`dev/rivet_motion/stride_probe.gd`, headless; evidence/rivet-motion/stride-probe.txt):
  max foot reach from the body centre, in m:

  | gait_scale | walk 1.6 m/s | run 4.5 m/s | sprint 5.6 m/s |
  |---|---|---|---|
  | 1.0 | 0.53 | 0.73 | 0.73 |
  | 1.3 | 0.68 | 0.92 | 0.92 |
  | 1.6 | 0.83 | 1.12 | 1.12 |

  At 1.0 the feet stay inside Rivet's idle footprint half-length (~0.84 m with the arms). That
  is why the legs barely read from above. The stride also stops growing past RUN_SPEED (5 m/s),
  so a sprint shows a faster cadence but no longer reach; the sprint pose needs its own
  stride/lean.
  A torso half-length measure was tried and dropped: it grew with distance travelled, so it was
  not trustworthy.
- NEXT (adds to the list above): try Rivet `gait_scale` 1.3 (+ a sprint stride band above
  5 m/s) and judge it in a 32 px/m clip against the hips A/B. Footfalls stay world-planted (no
  skating by construction); check the cadence still reads natural. If the look is a fork, ASK it
  (rivet-motion-2: stride 1.0 / 1.3 / 1.6 clips).
