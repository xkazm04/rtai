# JOURNAL: lane n5-cast (branch `n5-cast`), night run 2026-11-04 -> 11-05

Evidence: `evidence/n5-cast/` (in git) and `C:\Users\kazda\kiro\gtai-masters\n5\cast\` (masters, outside git).

## Iteration 2 (16:43-17:43, the first real session; iteration 1 died on billing in 3 s)

- 16:45 Read TARGETS.md and the cast images (r2_c3 hybrid, r2_c5 cops, r2_c6/c7 at game scale, r1_c6 crowd,
  r1_c7 ladder), the d5-cast REPORT, and the rig code (BodyPlan, HumanPlan, RivetPlan, RigVariant, RigBuild,
  RigDetail). The other lane (n5-look) has no JOURNAL yet, so there are no REQUESTs for this lane.
- FRICTION: the worktree had no `.godot/`; the first headless run spent 300 s importing and was killed by my
  `timeout`. A plain `--headless --import` took ~4 min. Budget for it in every fresh worktree.
- Registry rules applied (`generated-asset-world-scale`):
  - "Size is not proportion": the cop got a uniform size cut (size_k) plus a separate limb-length factor,
    because its art has a broad torso relative to its limbs. A size cut alone left its legs 20 % short of a ped's.
  - "One authority per quantity": the ped is the footprint's authority; `COP_LIMB_K = PED_SIZE_K / COP_SIZE_K`.
- MILESTONE 17:00 measured today (`dev/bench/rig_footprint.gd`, now with the riot cop, SWAT, three peds and the
  torso span; `evidence/n5-cast/footprint-before.json`). Plan view, idle stance:

  | who | shoulder span | torso depth | bbox length x width | size_k |
  |---|---|---|---|---|
  | ped (coat / jacket / hoodie) | 0.83 m (26.6 px at 32) | 0.52 m | 0.69 x 1.34 m | 1.25 |
  | cop (patrol, riot, SWAT share one plan) | **1.31 m** (1.58x ped) | 0.74 m | 1.27 x 1.88 m | 1.45 |
  | Rivet | **1.14 m** (1.37x ped) | 0.74 m | 1.68 x 1.97 m | 1.2 |

  Lineup frames (new `dev/showcase/cast_lineup.gd`, standing and `--walk`, 32 and 64 px/m):
  `gtai-masters/n5/cast/scratch/before/`.
- DECISION 17:05 the human footprint = the crowd's: a 0.83 m shoulder span and a 0.52 m torso depth (cops may run up to
  about 1.1x for kit). Rivet = 1.1x that: about a 0.92 m shoulder span and a 0.57 m torso depth, and his idle bbox
  width should be at most about 1.1x a cop's.
  - The targets agree: in r2_c6, a car is ~70 px wide (1.8 m), so ~39 px/m, and a running civilian's torso is
    ~30 px (~0.77 m). The ladder (r1_c7) puts Rivet at ~1.1-1.2x a civilian.
- MILESTONE 17:08 cops slimmed in the plan: `HumanPlan.COP_SIZE_K` 1.45 -> 1.0 and `COP_LIMB_K` 1.25 (ped-length
  limbs). Measured: shoulder span 1.31 -> **0.90 m** (1.08x ped), torso depth 0.74 -> 0.51 m, bbox 1.27 x 1.88 ->
  1.01 x 1.45 m. Riot, SWAT and patrol all follow (one plan). The blue still reads at 32 px/m (`scratch/try2/`).
  New unit test `test_cast_footprint.gd`.
- MILESTONE 17:14 combat check in the live arena: the director reel's first 30 s (claw combo, pistol, machine pistol,
  the gib and riot-shield chapter) filmed at 32 px/m, before (main's cop constants) and after, 0 script errors in both.
  Kills, corpses, gibs and the riot shield all still read on the slimmer cops. Noted: the blood pool is now large next
  to the slimmer body (the pool is sized by `CombatBlood.kill_human`, not by the rig). That belongs to the combat lane's
  look; I left it as is.
  - Masters: `gtai-masters/n5/cast/cast-{before,after}-director-32.mp4`, `frames/director-slim-cops-ab-32ppm.png`,
    `frames/lineup-slim-cops-ab-64ppm.png` (beside r1_c7), `frames.json` (4 entries).
- Gates at 28becde8: lint 13/13, unit 940/0 (`test_rig_plans` updated for COP_LIMB_K, and the new
  `test_cast_footprint`). The scenarios were running at the session's end (they include the look goldens, which the
  cop change will move).
- 17:22 scenarios at 28becde8: 46 ran, 0 failed. The director scenario kills every chapter: claw 2/2, pistol 2/2,
  machine pistol 4/4, and the other 13 chapters 1/1.
- MILESTONE 17:23 look goldens: unblessed, 8 of 11 failed on the far-pixel share only (worst d5-64 mean 4.46). The
  d4-64 diff mask sits on the junction riot's cops. Re-blessed once (92e8c3fb), with a decisions line.
- MILESTONE 17:25 reactions at 64 px/m on the real rigs (`dev/human_react/react_board_run.gd --zoom=2 --every=4`, 0
  script errors): stagger, knockdown, melee spin and fold, electro, burning, and the round, melee, blast and electro
  deaths all read on the slim cops. Masters: `frames/react-board-slim-cops-64ppm.png`,
  `cast-after-react-board-64ppm.mp4`. Not filmed yet: the brutality signature splits (the gib cuts use the rig parts)
  and a 64 px/m before clip.

- 17:27 Rivet lanky trial 1, rig numbers only and not committed (`frames/rivet-lanky-trial1-64ppm.png` beside
  r2_c3). The numbers: size_k 1.2 -> 1.0, arm_k 0.72 -> 0.85, arm_w 0.8 -> 0.6, and a new `leg_w` 0.65. Rivet comes
  out near a cop's width with lean limbs, which is promising. Still missing: the plated torso and shoulders, the broad
  collar ring, and the arms hanging at his sides with the claw (the target), not held in the guard.
  - Committed: the `BodyPlan.leg_w` hook (default 1.0, so a no-op for every plan; `gib_cut` copies the sprite
    transforms, so it carries into the gibs). Unit 940/0.
  - Watch out: `test_hauler_form` asserts that tank.size_k / base.size_k = the body-table radius ratio. Changing the
    base size_k means scaling `FORM_HAULER`'s 2.6 with it (2.6 = 1.2 x 0.9 / 0.42).

NEXT (iteration 3):
1. Run `node tools/evidence/run.mjs --no-bench` on the committed head (parity should be exact: render only). If the
   block goldens fail, check them the same way as the look goldens.
2. Film the brutality signature splits on the slim cops (the brutality lane's dev board, or the director chapters
   katana and chainsaw at `--ppm=64`), and a react-board before clip (main's cop constants) to pair with
   `cast-after-react-board-64ppm.mp4`.
3. Rivet as the hybrid, first the rig: size_k 1.2 -> ~0.97 for a 0.92 m shoulder span (1.1x the ped), lanky limbs
   (a limb-length factor like the cops'), thinner arms (`arm_w`), and add a `leg_w` to BodyPlan (thigh and shin
   thickness, like `arm_w` in rig_arm.gd). Re-measure with `dev/bench/rig_footprint.gd` and look with
   `dev/showcase/cast_lineup.gd`.
4. Then the art: the D4 sheets are `gtai-masters/d4/cutout/parts-v2/rivet_{head,arms,legs,hands}.png` (layout-locked
   cells; the slicers are `d4/cutout/tools/slice_v2.py` and `night/d5-close/tools/slice_d5.py`). Codex edit of those
   sheets toward r2_c3 (lean piston limbs, a work-plated torso), under `gtai-n5/image.lock`, and copy gen.mjs into
   scratch. The D5 overlay must keep the D4 alpha (RigDetail silhouette lock): regenerate or drop the D5 rivet set.
