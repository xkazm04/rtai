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

- 17:30 parity at 54465125: native == GDScript bit for bit over 1200 steps, and the planted mutation was caught at
  step 629 (render-only, as expected). Gates on this head: lint 13/13, unit 940/0, scenarios 46/0 (at 28becde8;
  leg_w is a no-op since), parity exact, look goldens re-blessed. Not run: the full `tools/evidence/run.mjs` and the
  bench.

- MILESTONE 17:34 city block (`--arena=city`), 15 s at 32 px/m, before and after, 0 script errors. At t=12 s
  (`frames/city-slim-cops-ab-32ppm.png`) the sim is identical and the cops now sit on the ped footprint inside their
  rings. `frames.json` has 10 entries and every file exists.

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
   - Pipeline notes (read 17:30): `slice_v2.py` assigns parts by TEMPLATE CELL (grid 3x2 per sheet; roles in
     `d4/cutout/tools/parts_v2.json`), so components can change shape. It re-measures the joints from the shapes
     (`slice.joints`) and rescales the whole sheet so the anchor torso spans 297 px. So a Codex edit that keeps every
     part in its cell (limbs horizontal, joint LEFT) re-slices without hand pivots.
     - The torso is `reuse_v1` (from v1). A work-plated torso needs that flag dropped and a torso cell.
     - The arms sheet cells: anchor, upperarm, forearm, forearm_torch, upperarm_endon, forearm_endon. The legs: anchor,
       thigh, shin, foot_flat, foot_toeoff. The hands: anchor, claw_open, claw_closed, claw_pistol, pistol, hose.
     - Copy slice_v2.py and slice.py into `gtai-masters/n5/cast/tools/`; never edit the d4 originals. Write the output
       to this worktree's `art/rivet/` (D4) and handle `art/d5/rivet/` (restyle with slice_d5's alpha lock, or delete
       the D5 rivet parts so RigDetail falls back to D4 per part).
   - Do not start a Codex job in the last 15 min of a session: a killed session leaves `gtai-n5/image.lock` held.


## Iteration 4 (17:35-18:35)

- 17:36 Read JOURNAL, git log, the r2_c3 target, trial 1 frames. Image lock free. No REQUESTs from n5-look.
- Registry rules applied (`generated-asset-world-scale`): "one authority per quantity" again, the ped's span is the
  footprint and Rivet's size_k is derived from it (0.92 / 1.14 x 1.2 = 0.97); "size is not proportion": separate
  leg_k / leg_w / arm_w factors on top of the uniform size cut. (`sprite-and-atlas-production`): parts generated
  as one layout-locked chroma sheet, cut per template cell, one scale per character via the anchor cell.
- MILESTONE 17:38 Codex job `rivet_hybrid_head` (78 s, under image.lock, released): an edit of the d4 rivet_head
  sheet with r2_c3 + the concept as refs. Came back clean: welder-visor helmet with a vermilion cable loop, a thicker
  hazard collar, a work-plated torso with shoulder plates, a narrower pelvis. Masters `gen/r1/`.
- MILESTONE 17:40 rig: size_k 0.97, ARMS 0.85/0.9/0.6, new LEGS [1.15, 0.65, 1.15], FORM_STOCKY for A/B, Hauler via
  BODY_SIZE_K. Measured: shoulder 0.92 m (1.1x ped), torso depth 0.60 m, bbox 1.38 x 1.53 m (cop 1.01 x 1.45).
  Unit 940/0 after fixing two test_rig_plans asserts (thigh_len now x leg_k; the day-arms A/B compares day legs).
  Commit 516475c9.
- FRICTION: a windowed run does not re-import changed PNGs; the first lineup still showed the old helmet. Run
  `--headless --import` after any art swap (about 1 min here, the cache was warm).
- MILESTONE 17:44 parts installed (sizes in decisions), provenance lines x8, commit a419cce0.
- MILESTONE 17:48-17:56 combat check: director reel 30 s at 32 px/m and 25 s at 64 px/m, city block 15 s at 32 px/m
  (`--bot=reel --arena=city --loadout=pistol,machine_pistol`, the iteration 2 args), 0 script errors in all three;
  the sim is identical to the before clips at the same tick. Claw combo, pistol and machine pistol kills all read;
  the grips and hose follow the new hand joints.
  - Noted for the owner: held guns are sized in metres (weapon_art.json: pistol 0.7, machine pistol 0.9 m, the look
    lane's data), so they now read large against the slimmer Rivet.
  - FRICTION: my first city clip forgot `--bot=reel --loadout`, and the sim looked diverged. Always copy the before
    clip's args (`gtai-n5/logs/cast/iter-002.jsonl` has them).
- 17:58 composites: `frames/lineup-hybrid-ab-64ppm.png` (with r2_c3), `cast-ingame-vs-r2c6.png`,
  `director-hybrid-ab-32ppm.png`, `city-hybrid-ab-32ppm.png`, `director-hybrid-64ppm.png`; frames.json 15 entries.
  r2_c6 check: car-to-figure scale and the Rivet:cop ratio match; the remaining gap is the camera (3/4 view vs plan).
- 18:00 scenarios at 433fc9a9: 46 ran, 1 failed = `scenario_city_chase` 2 ms nav budget (6.1 ms max, the known
  flake); re-run alone 18:14: 1 ran, 0 failed.
- MILESTONE 18:00 Codex job `rivet_hybrid_arms` (89 s, under image.lock, released): lean sleeve-and-rod pistons.
  Sliced (copy of slice_v2, `gen/r2/stage/`), installed by `tools/install_rivet_arms.py` (long parts rescaled to
  the d4 bone lengths), arm_w 0.6 -> 0.9. `frames/rivet-arms-ab-64ppm.png`. Commit 903bfd02.
  - FRICTION: my earlier 940/940 unit run had not seen the new helmet (no re-import), so
    `test_rivet_aim_clear` only failed after the import: it used the helmet texture WIDTH (front to back) as the
    half-width. Fixed to the height (across the barrel line); the planted fault is still caught. Unit 940/0.
- 18:10 look goldens at 903bfd02: junction 11/11 pass (means 0.10-0.58). Block site 1/5 (d4@48, auto@64 day and
  night, d4@48 night fail on the far share, means 1.9-3.0). The diff mask has blobs on Rivet and the cops (mine:
  the block goldens were NOT re-blessed for the slim cops in iteration 2), plus a thin speckle along building edges
  across the whole frame that may come from main (the block goldens were last blessed at 53f4c72f, before main's
  corpse decay and Rivet speed). NOT blessed: bisect first.

NEXT (iteration 5):
1. Block look goldens: in a throwaway worktree at main a1275c82 (budget the ~4 min import), run
   `look_golden.tscn -- --out=<dir> --site=block`. If main already fails 4/5 with the same edge speckle, bless on
   this branch with a decisions line naming both causes; if main passes, find what of mine moves the edges.
2. Rivet's legs sheet: Codex edit of `d4/cutout/parts-v2/rivet_legs.png` (cells: anchor, thigh, shin, foot_flat,
   foot_toeoff) in the r2 arms style, slicer copy + an install script like install_rivet_arms.py (bone lengths
   166/137 x leg_k), then leg_w 0.65 -> ~0.95. Then film `--bot=rivet` (walk, strafe, sprint, roll, claw combo) at
   48 px/m: not filmed yet on the hybrid.
3. The brutality signature splits on the slim cops and the hybrid (director chapters katana and chainsaw at 64 px/m)
   and a react-board before clip (still owed from iteration 2).
4. Calls for the owner (REPORT): held guns are metres-sized (pistol 0.7, machine pistol 0.9 m), so they now read
   large on the slimmer Rivet (frames/director-hybrid-64ppm.png); the camera gap vs r2_c6 (3/4 vs plan view).
5. The full `node tools/evidence/run.mjs --no-bench` on the head; parity should stay exact (render only).
- MILESTONE 18:18 `--bot=rivet` filmed on the hybrid at 48 px/m (`cast-hybrid-motion-48.mp4`, 25 s, 0 script
  errors): walk, sprint at the faster baseline and the claw combo kills read.
- MILESTONE 18:18 Codex job `rivet_hybrid_legs` (94 s, image.lock released): thigh, shin and feet as lean pistons in
  the arms' style; installed by `tools/install_rivet_legs.py` (bone lengths kept), leg_w 0.65 -> 1.0.
  `frames/rivet-legs-ab-64ppm.png`. The NEXT item 2 above is done except a 48 px/m motion clip on the new legs.
- 18:23 the piston legs at 32 px/m (`--bot=rivet`, `cast-hybrid-legs-motion-32.mp4`, 0 script errors,
  `frames/rivet-legs-motion-32ppm.png`): Rivet reads as the collar ring with thin ink limbs, lanky and clear on the
  slab, faint on dark asphalt. Watch item for the owner's eye: arm_w 1.0 / leg_w 1.2 are the one-value fixes.
- Session state 18:24: head 6fb10e9a + this JOURNAL commit. image.lock free; no Godot process of mine running.
  Gates: lint 13/13, unit 940/0 (6fb10e9a), scenarios 46 with 1 known flake (city_chase, green alone), junction
  look goldens 11/11 at 903bfd02 (not re-run after the legs), block look goldens 1/5 (bisect, NEXT 1). Parity and
  the full evidence run not re-run this session (render-only changes).

NEXT (iteration 5), updated: (1) block goldens bisect, then one bless covering the cops and Rivet, with a
decisions line; re-run junction goldens after the legs; (2) the brutality splits and react board on the slim cops
and the hybrid at 64 px/m (gib cuts use the new arm/leg parts: check the cut pieces look right); (3) the director
reel's 64 px/m close-up again on the final arms and legs, and the r2_c6 composite re-shot; (4) `tools/evidence/run.mjs
--no-bench` on the head; (5) the REPORT's Calls for the owner (held-gun size on the slimmer Rivet; limb weight at
32 px/m; the 3/4 vs plan camera gap).
