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
- 18:25 junction look goldens re-run on 6fb10e9a (the legs): 11/11, worst mean 0.57. NEXT (1) is now block only.

## Iteration 6 (18:26-19:26)

- 18:26 Read JOURNAL, git log. No REQUESTs from n5-look. image.lock free.
- MILESTONE 18:29 block look goldens bisected and blessed (commit 618d6eb8). A throwaway worktree at main a1275c82
  (copy this worktree's `.godot` + native DLLs in, then `--import` takes 15 s, not 4 min) passes block 5/5, but with
  the far share already at 1.1-2.0 % (limit 2 %) from an edge speckle along the buildings. My head failed 4/5 at
  2.0-2.9 %. The head-vs-main diff mask holds only bodies (slim cops, hybrid Rivet, a corpse): so the cast change
  tipped an already-marginal frame. Blessed once, unblessed re-run 5/5, decisions line.
  - FRICTION: `git worktree remove` fails with "Permission denied" when the tool's cwd sits inside that worktree;
    run it from the lane cwd.
- MILESTONE 18:33 brutality A/B at 64 px/m (`--bot=reel --reel=director --loadout=pistol
  --chapter=katana,chainsaw,electro_gun,flamethrower,riot_cop`, 2000 frames): main (throwaway worktree) vs head,
  5/5 chapters down on both, identical sim, 0 script errors. Katana and chainsaw splits cut the slim cop parts
  cleanly (blue torso half, legs half), the electro skeleton flash and the charred corpse, the burn, the riot cop
  with his shield all read. `frames/brutal-ab-64ppm.png`, clips `cast-{before,hybrid}-brutal-64.mp4`.
- MILESTONE 18:36 react board A/B (owed since iteration 2): `react_board_run.gd -- --zoom=2 --every=4` on main and
  on head, 481 frames each, 0 script errors. Every family (stagger, knockdown, melee spin/fold, electro, burning,
  round/melee/blast deaths) reads at the same frame; the cops now sit on the ped footprint.
  `frames/react-board-ab-64ppm.png`, `cast-react-board-ab-64ppm.mp4` (side by side). NEXT items 2 done.
- 18:40 TRIAL (rejected, not committed): Rivet's limb tone. `PartMaterials.LIMB_FILL` (the 32 px/m flat sticker,
  0.40) and a new `LIMB_WASH` (full-art wash, shader default 0.24) are Rivet-only knobs (only his plan sets
  `limb_lod`). Tried 0.55/0.36 and 0.62/0.45 toward r2_c6's mid-grey metal (`frames/rivet-limb-tone-trial.png`
  in masters). At 64 px/m the change is barely visible (the piston art is mostly line-and-cream, not mid tone); at
  32 px/m the sticker limbs darken a little on the slab but would lose value contrast on grey asphalt, where the
  iteration 5 clip already called them faint. Not clearly better -> reverted. The one-value lever stays
  `LIMB_FILL` if the owner wants heavier limbs.
- 18:44 WATCH: at 32 px/m Rivet's core sticker (helmet + torso, `lod_fill` 2: cream, only marks with d >= 0.40
  print ink) is noisier on the hybrid art than on the d4 box helmet: the plate seams, bolts and the tan belt band
  alias into ink specks inside the collar ring (8x zoom looks like a blot; 1x in the city clips reads as a cream
  disc with marks). Measured: ink share 0.54 helmet / 0.43 torso vs 0.43 / 0.30 on the d4 parts. A mid-tone lift
  of the art (`gtai-masters/n5/cast/tools/core_lift.py`, d below 0.75 x 0.3) did not visibly clear it, and no
  interior alpha holes, so the speckle is the minified seams. A real fix is a simplified core LOD part (seams
  thinned or dropped) or a minified-texture fetch in the sticker: the second is the print shader (n5-look).
- 18:46 gates on 850c543a (`node tools/evidence/run.mjs --no-bench`): lint 13/13, unit 940/0, scenarios 46/0,
  parity exact (1200 steps, planted mutation caught at 629), selftest with the junction look goldens 11/11 (worst
  mean 0.57). Bench not run (CONTENDED machine, not needed for render-only art).
- MILESTONE 18:51 Rivet's core sticker fixed at 32 px/m (commit fa395f74). The speckle was the thin plate seams and
  the inner mid tones (belt band, helmet back box) crossing the core sticker's d >= 0.40 ink threshold.
  `tools/art/rivet_seam_thin.py --mid=0.75` moves only those pixels (more than 10 px inside the alpha edge) to d 0.38
  along their hue; outline, bold marks, vermilion and alpha are kept, and the D5 set stays full detail. 32 px/m: a
  cream plate with the helmet outline again; 64 px/m nearly unchanged. Look goldens unmoved (junction 11/11,
  block 5/5). Provenance lines x2, decisions line. `frames/rivet-core-seams-ab.png`.
  - Registry rules applied (`sprite-and-atlas-production`, `shader-budget-authoring`): fix the source art for the
    LOD it actually prints at instead of adding a shader branch the look lane owns; keep the alpha as the
    silhouette authority (the D5 overlay's lock).
- MILESTONE 18:56 the proof clips on the finished cast, 32 px/m, 0 script errors:
  `cast-director-ab-32.mp4` (main | n5-cast side by side, 30 s; claw combo, pistol, machine pistol identical tick
  for tick) and `cast-city-ab-32.mp4` (15 s). Still: `frames/director-final-ab-32ppm.png`.
  - FRICTION: iteration 2's director args (`--reel=director --loadout=pistol`, no `--bot=reel`) now play the hub;
    the working args are `--bot=reel --reel=director --clean --rigs`. Chapter 4 on differs from the before clip
    (it carried `--loadout=pistol`); the brief's first three chapters match.
- 18:57 `frames/cast-ingame-vs-r2c6.png` re-shot on the finished cast. Scale and the cop footprint match; the
  open gaps are the camera (target 3/4, game plan view) and Rivet's pale thin limbs on dark asphalt.
  frames.json 15 entries, all files exist.

NEXT (iteration 7):
1. Rivet's limbs on dark asphalt at 32 px/m (the weakest read left): the sticker limb is a 3-5 px pale rod with a
   1.3 px outline. Darker LIMB_FILL was rejected (asphalt contrast). Try instead a slightly heavier drawn limb at the
   sticker LOD only: arm_w/leg_w are rig-wide, so look for a LOD-gated width (RigLimbs) or ask n5-look for a
   thicker `sticker_edge` on LIMB parts (their shader; a REQUEST line in their JOURNAL). Judge on asphalt AND slab.
2. Held guns read large on the slimmer Rivet (weapon_art.json metres, the look lane's data): Call for the owner
   with `frames/director-hybrid-64ppm.png`; or a REQUEST to n5-look.
3. The crowd (brief item 4) is the footprint authority and unchanged; confirm with `dev/bench/rig_footprint.gd`
   on the head and write `evidence/n5-cast/footprint-after.json` (cops, Rivet, peds) for the REPORT table.
4. Start REPORT.md (due 08:40): what works with evidence paths (frames.json), Calls for the owner (held-gun size;
   limb weight at 32 px/m with the one-value levers; 3/4 vs plan camera), what does not.
- 19:00 footprint on the head (`dev/bench/rig_footprint.gd`, `evidence/n5-cast/footprint-after.json`), plan view:

  | who | shoulder span | torso depth | bbox length x width | vs iteration 2 |
  |---|---|---|---|---|
  | ped (coat / jacket / hoodie), the authority | 0.83 m (0.82-0.84) | 0.52 m | 0.69 x 1.34 m | unchanged |
  | cop (patrol, SWAT; riot 1.39 m long with the shield) | 0.90 m (1.08x ped) | 0.51 m | 1.01 x 1.45 m | was 1.31 m span |
  | Rivet (hybrid) | 1.00 m (1.20x ped, 1.11x cop) | 0.54 m | 1.47 x 1.51 m | was 1.14 m span, 1.68 x 1.97 m |

  Rivet's span came out 1.00 m, not the 0.92 m planned in iteration 4: the hybrid torso's shoulder plates (330 part
  px) are wider than the d4 torso the size_k was derived on. His bbox width is 1.04x a cop's, so he still reads
  "only slightly larger"; kept. One-value lever if the owner wants exactly 1.1x the crowd:
  `RivetPlan.FORMS[FORM_BASE].x` 0.97 -> 0.89 (re-bless the look goldens after). Call for the owner in REPORT.
  Brief item 4 (the crowd on one footprint): the three peds sit within 0.82-0.84 m, no change needed.
- 19:03 REPORT.md drafted (marked DRAFT; the REPORT phase rewrites it at 08:40). Every cited path checked to exist.
  NEXT (iteration 7) item 4 is started; items 1-3 stand, plus: film the Hauler (and Gearbox if reachable) on the
  hybrid base (brief item 3, "keep their own body plan unless that breaks"), not yet done.
- MILESTONE 19:02 the Hauler on the hybrid base (`dev/ghost-powers/powers_clip.tscn -- --cops --every=4`, real
  city, 32 px/m, 0 script errors): the tank keeps its own size (BODY_SIZE_K) and the d5 arm profile, and now
  carries the hybrid helmet and torso inside the collar, which read as a cream plate. Transform, drive-through,
  knockdowns and stomp all play. `frames/hauler-on-hybrid-32ppm.png` (masters). Nothing broke, so no change.
  Gearbox not checked (no dev clip found in a quick look; `features/souls/power_table.gd` is the place to start).

NEXT (iteration 7), final for this session: (1) Rivet's limbs on dark asphalt at 32 px/m (see the 19:00 NEXT
item 1); (2) Gearbox on the hybrid base; (3) a main-side Hauler still at the same ticks for the pair (throwaway
worktree at a1275c82: copy `.godot` and the native DLLs in, `--import` takes 15 s); (4) the held-gun size REQUEST
to n5-look or a Call; (5) keep the REPORT draft current. Session state 19:03: head = this commit, tree clean,
image.lock untouched this session, no Godot process of mine running, throwaway worktree removed.
- 19:06 Gearbox read, not filmed: `powers.json` gearbox is a remote car hijack; Rivet stays on foot as the base
  (hybrid) plan, his move scaled by `rivet_move_k`. No own body plan, so nothing for this lane to keep or break;
  NEXT item (2) shrinks to "film it once for the REPORT".
- REQUEST 19:08 to n5-look (held-weapon art is yours): Rivet is slimmer now (shoulder span 1.14 -> 1.00 m, arms
  0.85x long, drawn thin), but held guns are sized in metres in `weapon_art.json` (pistol 0.7 m, machine pistol
  0.9 m), so at 64 px/m they read about a forearm-and-a-half long against his piston arms
  (`gtai-masters/n5/cast/cast-hybrid-director-64.mp4`, `frames/director-final-ab-32ppm.png`). If you agree, a
  uniform held-scale factor on Rivet's carry (or a smaller held length per weapon) would restore the hand-to-gun
  ratio of the approved combat night. If you decide to keep them, I will list it as a Call for the owner in REPORT.
  Grips follow the new hand joints; nothing on my side blocks either choice.

## Iteration 7 (21:42-22:42), resumed after the 19:12 stop

- 21:43 Read JOURNAL, git log, the diff. The four uncommitted rig files are NEXT item 1 (Rivet's limbs on dark
  asphalt): a LOD-gated cream leg rim (BodyPlan.leg_rim, RigBuild.HALO_LEG, CutRig.LEG_RIM_W 0.9) under the
  thigh, shin and foot, Rivet only. Plan: finish (lint), judge at 32 px/m on asphalt and slab, commit or revert.
- 21:46 lint failed on one 101-char comment line in cut_rig.gd (that was the stop's gdlint failure); rewrapped,
  lint 13/13. Unit 940/0. The 19:11-19:13 legrim A/B already in masters (`frames/rivet-legrim-ab-32ppm.png`,
  `cast-legrim{,-before}-city-32.mp4`): legs read as pale pistons on asphalt and slab. Decided: FINISH and commit.
  - FRICTION: ran look_golden without `--fixed-fps 60` first: the fight runs in wall time and every frame "fails"
    (means 2-7, Rivet dead in one). With `--fixed-fps 60`: junction 11/11 (worst mean 0.57), block 5/5.
- 21:50 director reel on 85b912e5 (`cast-legrim-director-32.mp4`, 1800 frames, 0 script errors) vs
  `cast-final-director-32.mp4` (fa395f74): every kill chapter identical tick for tick; on the pale arena slab the
  rim is nearly invisible (cream on pale grey), so it only shows where it is needed (asphalt). Item done.
- DECISION 21:56 Rivet's size kept at size_k 0.97 (1.00 m span, 1.20x ped, 1.11x cop). New `RivetPlan.FORM_TRIM`
  (0.89 = exactly 1.1x ped) and `cast_lineup.gd -- --form=<id>` render both; beside r1_c7 at 64 px/m
  (`frames/rivet-size-call-64ppm.png`): A's core is clearly larger than the cop's like the chart; B's core is
  cop-sized. REPORT Call 1 now carries this still. frames.json: + legrim A/B, + size call; dropped
  `rivet-legs-motion-32ppm` (superseded, file kept: REPORT cites it) and `city-hybrid-ab-32ppm` (file deleted).
  Unit 940/0, lint 13/13.
- 22:02 `frames/cops-vs-r2c5-64ppm.png` (the react board's cop columns beside r2_c5; the target composite owed for
  the cops): footprint and slimness track; the gap is colour mass (target navy cap, sleeves, trousers; game black
  ink limbs, cream cap disc, bright blue pads). Not changed tonight: the black-limb cop is the approved built look
  and a recolour needs every reaction re-checked and a golden bless. REPORT "open" updated.
- 22:06 scenarios 46/0 on 29a853be.
- MILESTONE 22:08 navy cops toward r2_c5. `cop_navy.py` (masters tools) recolours the cop limb ink fill and the
  patrol cap crown navy in D4 and D5 (D5 darker, since look_d5_part lifts it; the first D5 pass merged sleeves with
  the pads). Lineup A/B `frames/cop-navy-ab.png` (32 and 64 px/m), react board on the navy cops
  `frames/react-board-navy-64ppm.png` (481 frames, 0 script errors, every family reads, blood still red). Look
  goldens within tolerance (junction 11/11 worst mean 0.91, block 5/5): no bless. Unit 940/0, lint 13/13.
  DECISION: r2_c5 (2026-11-04) supersedes d5-cast's cream "T1" cap crown (owner review was pending). 18
  provenance lines (prior line + this edit, new sha256). Registry rule applied (`sprite-and-atlas-production`):
  recolour the source parts in both tiers, alpha untouched, instead of a shader swap that the D5 overlay would hide.
- 22:11 the navy cops in the live game, 32 px/m, 0 script errors: city block (`cast-navy-city-32.mp4`,
  `frames/city-navy-ab-32ppm.png`): on dark asphalt the whole cop reads as a blue figure where before only the pads
  and a cream cap dot showed; the cap dot was the stronger head mark (REPORT Call 4). Director reel
  (`cast-navy-director-32.mp4`, `frames/director-navy-ab-32ppm.png`): identical sim, every kill chapter reads, navy
  corpses in red pools. frames.json 15 (all files exist): + cops-navy-vs-r2c5, city-navy, cop-navy-ab,
  director-navy; dropped cops-vs-r2c5 (kept on disk, REPORT cites it), core-seams, react-board mp4, legs-ab.
  REPORT: sections 2/3 and the gates updated, Call 4 (navy vs cream cap).

NEXT (iteration 8):
1. Riot helmet and SWAT head vs r2_c5: the riot dome is still d5-cast's cream T1 dome with a blue band; r2_c5 has a
   navy helmet. Same `cop_navy.py` approach on `head_helmet` (both tiers) if it reads better at 32 px/m; keep the
   SWAT head (already dark). Judge on asphalt and slab; react board + director reel after.
2. The cop torso centre prints cream at 64 px/m (the vest/shirt plate) where r2_c5 is navy with a dark belt: check
   whether it is the art or the print's flat-tint (look lane) before touching it.
3. Held-gun size: n5-look took it with their held-weapon redraw (their JOURNAL 19:15); re-check their branch's
   `weapon_art.json` and our director 64 px/m clip once they land it.
4. A 64 px/m close-up clip of the navy cops in the director reel (only 32 px/m filmed tonight).
5. Keep REPORT current (rewritten at 08:40). Full `tools/evidence/run.mjs --no-bench` on the head.
Session state 22:13: head = this commit, tree clean, image.lock untouched, no Godot process of mine running.
- MILESTONE 22:17 NEXT 1 done: riot helmet navy (cop_navy.py now takes a part list; run each part once). Lineup
  `frames/riot-helmet-navy-ab.png`, react board re-shot (0 script errors), goldens 11/11 (worst 1.07) and 5/5,
  unit 940/0. 2 provenance lines, decisions line. REPORT Call 4 widened to the helmet.
- 22:25 `tools/evidence/run.mjs --no-bench` on cc4cb843: lint 13/13, unit 940/0, scenarios 46/0, parity exact
  (mutation caught at 629), selftest with goldens 11/11 (worst 1.07) and block 5/5. Note for d5-city (not mine):
  the selftest says the debt rows blood_flicker_cop_block_64, blood_flicker_cop_vermilion_32 and
  blood_flicker_vehicles_vermilion_32 are no longer seen. Bench not run (render-only art, CONTENDED machine).
- 22:27 the navy cops at 64 px/m in the director reel (`cast-navy-director-64.mp4`, 1200 frames, 0 script errors,
  `frames/director-navy-64ppm.png`): navy cops and riot shields read, navy corpses in red pools, Rivet's vermilion
  collar the one warm accent. NEXT 4 done. frames.json 15, all files exist.

NEXT (iteration 8), replaces the 22:13 NEXT:
1. The cop torso centre prints cream at 64 px/m (the shirt/vest plate) where r2_c5 is navy with a dark belt: check
   if it is the art (`art/cop/torso.png`, `art/d5/cop/torso.png`) or the print's flat tint (n5-look) before touching
   it; if art, `cop_navy.py` with a torso rule, then react board + goldens + director reel.
2. Held-gun size: n5-look took it with their held-weapon redraw (their JOURNAL 19:15); re-check their branch and our
   director 64 px/m clip once they land it.
3. A city clip of the navy cops at 64 px/m on asphalt (32 px/m done) and quest 1 once (live path not filmed tonight).
4. Keep REPORT current (rewritten at 08:40).
Session state 22:28: head = this commit, tree clean, image.lock untouched, no Godot process of mine running.
- 22:29 NEXT (iteration 8) item 1 checked against tonight's frames: the "cream torso centre" was the patrol cap and
  riot helmet crowns seen from above (plan view: the head sits over the torso), and both are navy now
  (`frames/riot-helmet-navy-ab.png`, `frames/director-navy-64ppm.png`); the torso art is already navy (48,64,96).
  Item 1 is closed; iteration 8 starts at item 2 (held-gun size with n5-look) and item 3 (64 px/m city, quest 1).
- 22:31 masters cleaned: 5 superseded frames and 7 superseded clips (iterations 2-5) deleted, none cited by
  frames.json or REPORT; kept `frames/director-hybrid-64ppm.png` (my REQUEST in n5-look's JOURNAL) and the legrim
  clips (the before sources of tonight's pairs). Two Godot processes on the machine are not mine (all my runs were
  foreground and exited): left alone. Session end; NEXT is the 22:27 entry (item 1 closed at 22:29).

## Iteration 8 (22:29-23:29, BUILD)
- 22:29 read JOURNAL, log, n5-look JOURNAL. Their REPLY: held-gun size answered on n5-look 01cd19f2
  (`held_size_ref` 1.2: our 0.97 Rivet carries 0.81x guns after the merge); nothing for this lane. Their NOTE: the
  director reel needs `--loadout=pistol` or every chapter fires the base pistol; my iteration 6-7 director checks
  (`--bot=reel --reel=director --clean --rigs`) lacked it, so chapters 4+ did not exercise their weapons.
- MILESTONE 22:37 the full director reel WITH `--loadout=pistol` on e0da3ad8 (7200 ticks, 32 px/m, 0 SCRIPT ERROR):
  all 16 chapters n/n down (claw 2/2, pistol 2/2, machine pistol 4/4, rocket, flamethrower, electro, molotov,
  katana, chainsaw, plasma deflect, hand cannon, plasma rifle, ray, shard, riot cop, mini nuke 4/4). Contact sheet
  one frame per chapter `frames/director-loadout-16ch-32ppm.png`: navy slim cops, red blood and gibs, blasts,
  scorch; Rivet reads in every chapter. Clip of the weapon chapters `cast-loadout-weapons-32.mp4` (rocket ..
  katana, 37.5 s); the 2-min full file deleted (log kept the telemetry).
- 22:42 quest 1 on the slim cast (`quest1_clip.gd -- --ppm=32 --rigs --cam=fight --ticks=13560-13860`, 46 s, exit
  0, 0 SCRIPT ERROR, log "cast rigs: true"): Dock 9 fight `cast-quest1-dock9-32.mp4` (5 s) + still
  `frames/quest1-dock9-32ppm.png`. Rivet with Gloria reads as the cream hybrid with the vermilion collar, the quest's
  cops are the navy slim rigs and die in red. Note: quest 1's rigs stay behind the dev flag `--rigs` (rivet-arsenal
  Call 1), so the default quest 1 still draws the sprite cast; nothing of mine changes that.
- 22:47 the navy cops on dark asphalt at 64 px/m in the city block (`cast-navy-city-64.mp4`, 15 s,
  `--bot=reel --arena=city --loadout=pistol,machine_pistol --clean`, 0 SCRIPT ERROR; still
  `frames/city-navy-64ppm.png` t=3/7/11/14 s). Cops read as navy figures with blue pads and navy crowns, riot shields
  as cream arcs, corpses in red pools; Rivet is the pale hybrid with the vermilion collar, a touch larger than a cop.
  First take had the debug HUD (no --clean): re-shot. NEXT items 2-3 of iteration 7 are done.
- 22:58 frames.json 15 (all exist): + director-loadout-16ch, city-navy-64, quest1-dock9; dropped (files kept, REPORT
  cites them) director-final-ab, brutal-ab, cast-city-ab. REPORT: proof section + Call 3 (held guns answered by
  n5-look 01cd19f2). Rings around the city cops at 64 px/m = ArenaFloorView target markers (proving block only,
  `arena_floor_view.gd` 71), not cast art: left alone.
- 23:14 REPORT Call 2 (limb weight) had no still: new `RivetPlan.FORM_HEAVY` (arm_w 1.0, leg_w 1.2, base otherwise)
  and `frames/rivet-limb-call-ab.png` (cast_lineup walk + stand, 64 and 32 px/m, A built vs B). Standing, the legs
  hide under the body and only the arms differ; walking, B's legs reach a pedestrian's leg width. DECISION: keep A
  (lean pistons as r2_c3; the owner asked for slimmer), decisions line. Base unchanged: no golden moves. Lint 13/13,
  unit 940/0. frames.json 15 (+ limb call; hauler-on-hybrid dropped, file kept: REPORT cites it).
- 23:19 scenarios on 2c447d27: 46 ran / 0 failed (2 min 38 s). Gates this session: lint 13/13, unit 940/0,
  scenarios 46/0; parity and the look goldens not re-run (no sim or base-rig change since cc4cb843's full
  evidence run).

NEXT (iteration 9):
1. Run `node tools/evidence/run.mjs --no-bench` once on the head (last full run cc4cb843; only FORM_HEAVY data and
   docs since).
2. Weakest remaining gap vs r2_c3: Rivet's tone. The target hybrid is a warm tan-grey metal with rust; ours prints
   cream-white with grey hatching (the D4 item print's cream; LIMB_FILL trial at 18:40 rejected). Try a warm tan
   only on the D5 (close-up) parts first, the way cop_navy.py did navy (both tiers, alpha kept), judge at 64 px/m on
   slab and asphalt; keep the cream at 32 px/m if the tan loses value on asphalt. Owner call if it is a fork.
3. Rivet's welder-visor head: at 64 px/m the head is a round cream disc in the collar ring; r2_c3's head is a boxy
   visor with two eye slits. A head part redraw (Codex, under image.lock, from r2_c3 + ref-4) if 2 does not cover it.
4. Keep REPORT current (rewritten at 08:40); frames.json is 15, all files exist.
Session state 23:20: head = this commit, tree clean, image.lock untouched, no Godot process of mine running.

## Iteration 9 (22:52-23:52, BUILD)
- 22:52 read JOURNAL, log, n5-look JOURNAL (no REQUEST to n5-cast; they did not touch the part shaders). Evidence
  gate `tools/evidence/run.mjs --no-bench` started on c714f3f3 (NEXT 1).
- 22:56 NEXT 2 (Rivet's tone) diagnosed: the art is already tan (D4 torso mean (183,159,135), D5 (170,145,122)), but
  both part prints throw the hue away: print_part snaps to cream/ink by luminance, look_d5_part maps luminance to a
  violet-grey steel ramp. So the fix is a print value, not a recolour (cop_navy.py worked only because the cop blue
  has its own branch). r2_a5 (the look target at game zoom) shows Rivet cream-white, r2_c3 (the body target, close)
  tan metal: keep cream at 32 px/m, warm tan only in the D5 close-up tier.
  Registry `shader-budget-authoring` applied: no new pass or fetch; one uniform and three mixes in the existing D5
  overlay branch, a second shared material pair (batching kept: one pair for all warm rigs).
  Built: `BodyPlan.d5_warm` (0 = violet steel), `RivetPlan.D5_WARM` 1.0 / `static var d5_warm` (A/B), RigDetail
  materials [plain, tint] x [violet, warm], look_d5_part `warm` + WARM_HI/MID/LO halfway between the violet steel's
  values and r2_c3's sampled tan. `cast_lineup.gd -- --warm=<f>` for the A/B.
- 23:00 evidence gate on c714f3f3 GREEN: lint 13/13, unit 940/0, scenarios 46, parity exact (mutation caught at
  629), selftest goldens 11/11 (worst 1.06), block 5/5, world lock 0.00 %. (My warm edits landed in the tree while
  it ran; the selftest after the commit gives the same numbers.) NEXT 1 done.
- MILESTONE 23:03 NEXT 2 done, 5ae6aa3f: Rivet's D5 steel warm tan. Lineup A/B (`cast_lineup.gd -- --warm=0|1`,
  `frames/rivet-warm-lineup-ab-64ppm.png`): tan limbs separate from the pale slab better. Live city 64 px/m same
  ticks (`cast-warm-city-64.mp4`, 0 script errors; `frames/rivet-warm-ab-vs-r2c3-64ppm.png` beside r2_c3): tan
  limbs and core, value held on asphalt, cream rim still outlines him. Still lighter than r2_c3 on purpose (middle
  ground). Also: the D5 hit flash printed vermilion; now cream (react board 64 px/m, 481 frames, 0 vermilion px,
  0 script errors, every family reads). Goldens unmoved, lint 13/13, unit 940/0. DECISION x2 in decisions.md;
  REPORT Call 5.
- 23:06 combat check at 64 px/m (`cast-warm-director-64.mp4`, `--bot=reel --reel=director --clean --rigs`, 1200
  frames, 0 script errors): claw 2/2, pistol 2/2, machine pistol 4/4, identical to `cast-navy-director-64.mp4`.
- MILESTONE 23:12 NEXT 3 done without Codex, 0bcc34c6: the helmet art was already the boxy welder plate; what was
  missing was the visor. `helmet_visor.py` (masters tools) paints a dark band + two cream eye slits on the front
  panel in both tiers, alpha kept. At 64 px/m: a dark visor bar with two pale spots (`frames/rivet-visor-ab-64ppm.png`
  beside r2_c3); at 32 px/m no visible change (`cast-visor-city-32.mp4`, tick 420 crop). 2 provenance lines,
  goldens unmoved, unit 940/0. Originals in `masters:n5/cast/scratch/helmet-orig/`.
  Registry rules applied (`sprite-and-atlas-production`): source-part edit in both tiers with alpha locked;
  (`shader-budget-authoring`) for the warm ramp: no new pass, no extra fetch, one more shared material pair.
- 23:15 frames.json 15 (+ warm vs r2_c3, visor, warm lineup; dropped from the list, files kept: cast-director-ab-32
  mp4, lineup-hybrid-ab, city-navy-ab-32 (REPORT cites them)). REPORT: section 3 + Call 5.
- 23:16 scenarios on 0bcc34c6: 46 ran / 0 failed. frames/cast-ingame-vs-r2c6.png re-shot on 0bcc34c6 (was fa395f74, pre-navy).
- 23:18 TRIAL (rejected, not committed): cop crowns in bright police blue, as the helmets of r2_c6 and r2_a5
  (`cop_crown_hi.py` in masters tools on the LFS pre-navy originals, `git show <rev>:<png> | git lfs smudge`).
  Live city 32 px/m, same ticks (`frames/cop-crown-trial-32ppm.png`): the bright crown merges with the bright
  upper-arm sleeves (upperarm.png carries the cop_blue_hi, not the torso) into one blue cluster; navy keeps the head a
  distinct dark centre. Reverted (git checkout of the 4 files + re-import). REPORT Call 4 gains option C.
  FRICTION: `git show rev:file.png` yields the LFS pointer; pipe it through `git lfs smudge`.
- 23:21 new unit test `test_only_rivet_prints_warm_close_up_steel` caught King and the thugs inheriting d5_warm from RivetPlan.build(FORM_OPEN); both set 0 now (DECISION). Unit 941/0.
- 23:27 evidence gate on 2f833a0b: lint 13/13, unit 940/1 (the 1 = `test_noir_shadows` "Parameter t is null", the
  known flake: 2/2 alone, twice; the standalone suite at 23:21 on the same tree was 941/0), scenarios 46, parity
  exact (mutation caught at 629), selftest goldens 11/11 (worst 1.06), block 5/5. REPORT gates updated.

NEXT (iteration 10):
1. Calls 1-5 in REPORT stand; nothing is blocked on them. Call 5 (warm tone) is new tonight.
2. If time: the full r2_c6 cop read (bright helmet over a navy body) needs navy upper-arm sleeves (`upperarm.png`,
   `upperarm_endon.png` carry the cop_blue_hi) plus bright crowns; trial C showed crowns alone merge with the
   sleeves. Build it only as an A/B still for Call 4 (the targets disagree: r2_c5 navy, r2_a5 bright shirts).
3. Rivet's core at 64 px/m is still lighter than r2_c3 (warm 1.0 is the halfway ramp on purpose); if the owner
   wants more, edit WARM_* in look_d5_part, judge on asphalt.
4. After n5-look lands print changes on main, re-check the warm ramp and the visor at 64 px/m on the merge.
5. REPORT rewrite at 08:40; frames.json 15, all files exist.
Session state 23:28: head = this commit, tree clean, image.lock never taken, no Godot process of mine running.
- 23:33 NEXT 2 (iteration 10) done early as a still only: option D = bright crowns (`cop_crown_hi.py`) + navy sleeves
  (D4/D5 `upperarm`, `upperarm_endon`: pixels with b-max(r,g) >= 40, g >= r, L > 90 -> (58,72,104) x min(1.15, L/150)),
  installed temporarily, city 32 px/m filmed (780 frames, 0 script errors), 8 files reverted with git checkout +
  re-import (tree clean). `frames/cop-crown-sleeve-trial-32ppm.png` beside r2_c6: D gives the r2_c6 hierarchy (a
  bright head dot over a navy body) but the cops read quieter on asphalt. Not built (an owner fork): REPORT Call 4
  option D. frames.json 15 (D replaces the C still in the list; C's file kept, REPORT cites it).
Session state 23:35: head = this commit, tree clean, image.lock never taken, no Godot process of mine running.
NEXT (iteration 10) is the 23:27 list; its item 2 is now done (Call 4 option D).
- 23:40 quest 1 at 64 px/m on head 9f195730 (`quest1_clip.gd -- --ppm=64 --rigs --cam=fight --ticks=13560-13860`,
  151 frames, exit 0, 0 SCRIPT ERROR): `cast-quest1-dock9-64.mp4` + `frames/quest1-dock9-64ppm.png`. The warm tan
  limbs and core and the visor's dark front edge read in the live quest path; navy cops die in red. frames.json 15
  (+ this; cops-navy-vs-r2c5 dropped from the list, file kept: REPORT cites it).
Session end 23:42: head = this commit, tree clean, image.lock never taken, no Godot process of mine running. The
  quest PNG frames (`gtai-n5/scratch-cast/q1/`, 153 files) are scratch, delete them next session if still there.
NEXT (iteration 10) is the 23:27 list (item 2 done at 23:33).

## Iteration 10 (23:35-00:35, BUILD)
- 23:35 read JOURNAL, log, n5-look JOURNAL (no REQUEST to n5-cast). Brief items 1-5 and iteration 9's NEXT are done;
  the crowd (brief item 4) had no evidence of its own, only the footprint table: picked it as the weakest item.
  Deleted the stale quest scratch (`scratch-cast/q1` was already gone).
- 23:40 crowd in the live game: quest 1 `--rigs --ppm=48 --stills=900,...` (0 SCRIPT ERROR) -> composite beside
  r1_c6 with the plan-view lineup `frames/crowd-quest1-vs-r1c6-48ppm.png`. Footprint holds (peds 0.83 m, the
  authority; no rig scale change needed).
- MILESTONE 23:42 2d6bb3b8: `cast_lineup.gd -- --crowd` (Rivet, patrol, the six ped looks) and `--road` (asphalt).
- 23:44 FINDING: at 32 px/m every ped look prints as a dark mass (slab and asphalt); r2_a5/r2_c6 peds are the palest
  figures (pale tops, dark hair). Our peds and the navy cops share one dark value at game zoom.
  Diagnosis by trials (all reverted, tree clean): (a) `ped_pale.py` (masters tools) lifted the coat/vest fills
  +42 L: no visible change at 32 px/m, the hat art (161 px) covers the torso (133 px); (b) a render-only
  `BodyPlan.head_k` 0.72 for peds: the head shrinks but more dark leg shows; (c) ped hip_z 0.97 (straighter
  standing legs): the two dark knee lobes ahead of the chest shrink a little. Cause = the ped art from above (dark
  trousers ahead of the chest, oversized heads, dark sleeves), not one print value. The fix is a new ped part
  sheet (Codex, r2_a5 + r1_c6 refs): pale shoulders, small dark heads, legs tucked under. Not started tonight:
  under an hour left, and it touches every ped reaction, corpse and gib cut (depth before breadth).
  Evidence `frames/crowd-value-vs-r2a5.png`. REPORT section 5 + open item.
  Registry `sprite-and-atlas-production` applied: judge the part at its minified size (the 32 px/m print sees an
  ~11 px mip average, so a fill lift under an occluding head is invisible); originals kept
  (`masters:n5/cast/scratch/ped-orig/`).
- 23:50 frames.json 15 (+ crowd-value-vs-r2a5, crowd-quest1-vs-r1c6; dropped from the list, files kept, REPORT cites
  them: riot-helmet-navy-ab, cop-navy-ab).
- 23:50 unit on 2d6bb3b8: 941/0.
- 23:52 more trials toward pale peds, all reverted (tree clean, re-imported): (d) a vermilion marker on the D4 coat
  torso showed that, from above at 32 px/m, only the torso's rim shows around the head, and that rim is mostly
  outline ink; (e) `ped_thin_outline.py` (masters tools, outline kept at 4 px) + the +42 L lift + head 0.72 + ped
  leg_w 0.7 together: marginal (`frames/crowd-trials-32ppm.png`, REPORT cites it). DECISION in decisions.md: keep
  the shipped ped art; the fix is a new ped part sheet. Scratch lineups deleted.
  FRICTION: a `-s` main script cannot touch HumanPlan (it needs the Log autoload): a dev flag that sets a HumanPlan
  static must go through the run node (cast_lineup_run.gd), as quest1_clip does.

- 23:55 Codex job `ped_pale_a` (55 s, under image.lock, released): an edit of `d4/chars/sheets/ped_a.png` with an
  r2_a5 crop + r1_c6 as refs: a pale trench-coat torso, a charcoal jacket over a white shirt, a dark hat 132 px
  (was 161), hair, a pale hood; anchor cell unchanged. Cut by `cut_ped_sheet.py` (masters tools; factor 1.024 from
  the shipped coat) to `gen/r4/cut/`, installed as a TRIAL by `install_ped_sheet.py` (D4 parts + parts.json, the
  same-named D5 overlays moved aside): at 32 px/m still dark (`frames/crowd-sheet-trial-32ppm.png`). Reverted (git
  checkout of art/ped and art/d5/ped, re-import). No provenance line: nothing shipped.
- 23:58 CORRECTION of the 23:44 diagnosis: a trial with the ped legs hidden (leg_w 0.01) left the two dark lobes
  ahead of the chest in place, so they are not the knees; a thinned outline on the cream upper arms changed nothing
  either. The lobes are not identified yet. REPORT section 5 and the decisions line corrected. All trials
  reverted, tree clean, re-imported, scratch deleted.

- 00:02 NEXT item 1 started: D4 part markers (solid vermilion, one part per run, `cast_lineup.gd -- --crowd`, each
  reverted with git checkout + `--import`; tree clean): thigh = the lobes' edges, foot_flat = their tips,
  upperarm_endon = the patches beside the head, pelvis a sliver below, shin specks, forearm / upperarm /
  foot_toeoff nothing. The lobes' dark interior is above the thighs and unassigned (the 23:58 "not the legs" was too
  strong: the legs make the lobes' outline, something else fills them). Still `frames/crowd-part-markers-32ppm.png`.
  Note: 64 px/m shows the D5 overlay on top, so D4 markers only read at 32 px/m. REPORT and the decisions line
  corrected again.

- 00:06 more markers (each reverted; tree clean): every D4 ped body part vermilion at once (heads kept) turns the
  lobes fully red, so they are ped body art, not a post or shadow pass; forearm_endon alone = the hand circles at
  the sides. No single part fills the lobes, so the interior is an overlap (thigh under something drawn above it
  for the standing pose). Still `frames/crowd-part-markers-b-32ppm.png`. Halos are cream silhouettes (rig_build
  `_halo`), not the cause.

- 00:09 inverse markers (all D4 ped parts vermilion except one; reverted, tree clean, re-imported): except thigh =
  only the lobes' top edges dark; except shin = dark specks; except pelvis or torso = lobes fully red. No single
  part fills the lobes: they need several leg parts dark at once. Lead (unproven): at 32 px/m the thin leg parts are
  mostly mip-blended edge texels, and print_part prints `c.a < alpha_cut` texels as ink dots ("translucent =
  shadow ink"), so overlapping thigh/shin/foot edges ahead of the chest stack into two ink lobes. Still
  `frames/crowd-part-markers-c-32ppm.png`.

- 00:10 lead disproved: print_part's translucent ink-dot branch set to discard (trial, reverted): lobes unchanged.
- 00:12 RESOLVED: `RigGait.step` calls `_solve_leg` on every pose, so the 23:58 leg_w 0.01 trial did hide thigh and
  shin; it exposed the dark shoes underneath (foot_flat 143 x 71 px, pushed ahead by `HumanPlan` foot_fwd 10 and
  not scaled by leg_w), which kept the lobes. So the lobes ARE the standing leg stack (thigh over shin over shoe),
  each covering part of the area, which is why no single marker filled them. The 23:58 "not the legs" was wrong;
  REPORT section 5 and the decisions line corrected.

- 00:13 NEXT 1 trial (reverted): ped foot_fwd 10 -> 3 and leg_w 0.8, `cast_lineup -- --crowd [--walk]`
  (`frames/crowd-feet-trial-32ppm.png`): standing, the lobes shrink a little; walking, built or trial, the peds
  read as figures with dark trouser legs striding, as r2_a5's running peds do. So the dark standing blob mostly
  matters for idle crowds; the pale-top read still needs the torso to show past the head (r4 sheet + smaller head).

- 00:14 the whole package as one trial (r4 sheet in D4 with its D5 overlays aside, ped head 0.75, foot_fwd 3,
  leg_w 0.8; all reverted, tree clean, re-imported): coat-hood and vest show more cream, coat-hat darker (the r4 hat
  is dark), jacket and hoodie unchanged; overall still dark (`frames/crowd-package-trial-32ppm.png`). NO-GO for value
  tweaks: at 32 px/m a ped is ~26 px across, and from straight above the art is mostly dark head, legs and shoes;
  r2_a5 is a 3/4 view where the shirt faces the camera (the known camera gap). A pale crowd from above needs a
  ped redraw for the plan view (light shoulders as the widest shape, hair/hat small, shoes small) or an owner call
  that dark-on-cream peds are fine at game zoom.

NEXT (iteration 11):
1. The crowd's value: the package of value tweaks is a no-go (00:14). Either a plan-view ped redraw (Codex from
   r1_c6 + r2_a5: light shoulders widest, small head, small shoes; all six looks, D4 + D5) as a full item with the
   react board, corpses, gibs and goldens, or leave it as REPORT Call 6 (pale vs dark crowd) if the time goes to
   the weakest cast item instead. Call 6 is written (00:16, 4453e747).
2. With a redraw: judge the react board, ped corpses and gib cuts, the city at 32 px/m, the goldens (one re-bless with a dated
   line), provenance lines for shipped parts.
3. Calls 1-6 in REPORT stand. REPORT rewrite at 08:40; frames.json 15, all files exist.
Session end 00:17: head = this commit, tree clean, image.lock released, no Godot process of mine running.

## Iteration 11 (00:17-01:17, BUILD)
- 00:17 read JOURNAL, log, n5-look JOURNAL (no REQUEST to n5-cast; no locks held). NEXT 1: the crowd's value.
  Picked the plan-view proportions as data before any redraw: the earlier trials changed one or two values at a
  time; a plan view needs all of them together. Measured the D4 ped parts: heads 124-161 px across a 133 px deep,
  213 px wide torso (a head is about 0.4 of the span from above, ours about 0.75), the head placed 0.22 of the
  depth forward (it overhangs the coat's front), the standing knees bent forward (hip_z 0.86 of the leg) and the
  143 px shoes pushed 10 px ahead. print_part inks anything below lum ~0.58 at 32 px/m, so the grey coat fills
  (~145) print black.
- 00:30 TRIAL (all together): new `BodyPlan.head_k` and `foot_k` (render scale of the head and the shoe cells,
  1 = the art), and `HumanPlan` PED_HEAD_K 0.62, PED_HEAD_DX 0.12, PED_FOOT_K 0.7, PED_FOOT_FWD 0, PED_HIP_Z 0.98,
  plus `ped_pale.py` (+42 L on low-saturation fills above L 90) on the D4 ped torsos and grey sleeves.
  `cast_lineup.gd -- --crowd [--road] [--walk]`, before (clean tree) and after, 0 SCRIPT ERROR:
  standing, coat-hat, coat-hood, vest and overalls now read as pale tops with small dark heads, on slab and on
  asphalt; jacket and hoodie stay dark (their fills are below the lift's L 90: a mix of pale and dark, as r2_a5's
  crowd). Walking is unchanged (dark trouser legs striding, as r2_a5's runners). 64 px/m (D5): smaller heads,
  coats show. `scratch-cast/i11/crowd-planview-ab-vs-r2a5.png`. GO: building it as the item.
  Registry `sprite-and-atlas-production` applied again: judged at the minified size; the head scale is a render
  value (art kept, one constant back).
- MILESTONE 00:27 64efadb6: plan-view peds built (the 00:30 trial values, a unit test
  `test_ped_plan_view_head_and_feet` pins head < 0.5 of the span, the standing shoe inside the chest, cop head 1.0).
  Unit 941/0 before the new test, the new test 3/3 alone; lint 13/13. React board before/after at 64 px/m
  (`react_board_run.gd -- --zoom=2 --every=4`, 481 frames each, 0 SCRIPT ERROR): cower, trip, every ped death and
  corpse still read, cops unchanged; the standing coat ped reads as a pale figure with a small head.
  `M/frames/react-board-planview-ab-64ppm.png`, `M/cast-react-board-planview-ab-64ppm.mp4`,
  `M/frames/crowd-planview-ab-vs-r2a5.png`. Gib cuts copy each sprite's global transform (gib_cut.gd), so the
  head scale carries into the splits.
- 00:29-00:33 EVIDENCE GATE on 25eec84a (`node tools/evidence/run.mjs --no-bench`): lint 13/13, unit 942/0 (marked
  FAIL only for "tree changed during run": my own REPORT/decisions edits while it ran; FRICTION, do not edit
  tracked files during the gate), scenarios 46, parity exact (mutation caught at 629), selftest junction 9/11 and
  block 4/5: d1@48, d4@64, block d4@48 over the far share only (2.11-2.22 % vs 2 %, means <= 2.33 vs 4). Diff mask
  looked at (`M/frames/golden-diff-planview-peds.png`): peds and ped corpses, plus the usual speckle; nothing else.
- MILESTONE 00:36 91aac1aa: goldens re-blessed once (junction 11 + block 5, dated decisions line), REPORT section 5
  and Call 6 rewritten (A = built pale-topped crowd, B = the dark crowd, one set of constants + the art back).
- 00:37 live game: city block `film.sh cast-peds-city-32 32 900 --bot=reel --arena=city
  --loadout=pistol,machine_pistol` (0 SCRIPT ERROR), A/B against `cast-navy-city-32.mp4` (same sim):
  `M/cast-peds-city-ab-32.mp4`, `M/frames/city-peds-ab-32ppm.png` (t=3/8/13 s + x3 crops): the coat ped is a pale
  figure with a small dark head where it was a dark disc. The arena city block has few peds (mostly cops).
- 00:38 COMBAT CHECK director reel headless (`--fixed-fps 60 --quit-after 7200 ... --bot=reel --reel=director
  --loadout=pistol`) on 91aac1aa: 16 chapters started, 16 down (claw_combo 2/2, pistol 2/2, machine_pistol 4/4 ..
  mini_nuke 4/4), 0 SCRIPT ERROR. frames.json 15 (+ crowd-planview-ab-vs-r2a5, react-board-planview-ab,
  city-peds-ab; dropped from the list, files kept as REPORT cites them: crowd-value-vs-r2a5, rivet-warm-lineup-ab,
  rivet-legrim-ab).
- 00:40 quest 1 live path: `quest1_clip.gd -- --ppm=48 --rigs --stills=900,1500` on HEAD and on the 9f2aac24 ped
  files (checked out, rendered, restored to HEAD, re-imported; tree clean), 0 SCRIPT ERROR:
  `M/frames/quest1-peds-ab-48ppm-vs-r1c6.png` (x3 crops under r1_c6): the coat ped shows pale shoulders, the hat
  peds a smaller head. DECISION (kept): jacket and hoodie stay dark; r1_c6 is a mixed crowd too (a dark suit and a
  leather jacket among mid and light clothes).
- 00:42 FINDING, closed: tick 1500 showed lone ped shoes and, at 1100, legs stretched into long dark bars. Cause:
  stills mode steps the sim thousands of ticks with no frame drawn (quest1_clip_rec.gd: "a still jumps the sim"),
  so the rigs do not step and the planted feet stay where they were. A per-tick clip window
  (`--ticks=1000-1200`, 101 frames, 0 SCRIPT ERROR) has no stray feet. Not a game bug; quest stills with moving
  peds are not motion evidence. `M/frames/quest1-ped-stills-artefact-48ppm.png`. The baked far-crowd atlas
  (`build/evidence/crowd-atlas.png`) follows the new peds (paler ped rows).
- 00:46 the crowd's kill scene: `react_board_run.gd -- --zoom=2 --every=4 --board=street` on HEAD and on the
  9f2aac24 ped files (restored, re-imported, tree clean), 240 frames each, 0 SCRIPT ERROR:
  `M/frames/street-board-planview-ab-64ppm.png`, `M/cast-street-board-planview-ab-64ppm.mp4`. Flee, the kill and
  the corpse read as before; running peds keep their dark striding legs, heads smaller, a few more cream tops.
  REPORT section 5 cites every A/B.
- 00:53 EVIDENCE GATE on 1d4abaa6 (`node tools/evidence/run.mjs --no-bench`, no edits during the run): lint 13/13,
  unit 941/1 = the known flake `test_noir_shadows` ("Parameter t is null"; 2/2 alone, twice), scenarios 46, parity
  bit-exact (mutation caught at 629), look goldens 11/11 + block 5/5 (worst mean 0.00), world lock holds. REPORT
  gates line added.
  Registry rules applied this iteration (`sprite-and-atlas-production`, `motion-quality-gating`): judge parts at
  their minified size; judge motion from per-tick frames, not from stills that jump the sim (the stray shoes).

NEXT (iteration 12):
1. The crowd item is built and evidenced (64efadb6 .. 1d4abaa6). Open: a plan-view ped part sheet (Codex, r1_c6 +
   r2_a5 refs, under image.lock) would sharpen the 64 px/m close-up, where the D5 ped art is still 3/4-view art
   scaled; do it only as a full item (six looks, D4 + D5, react + street boards, goldens, provenance lines).
2. Weakest items left: Call 1 (Rivet 1.20x vs the planned 1.1x) and Call 2 (limb weight) wait on the owner; the
   camera gap (3/4 targets vs plan view) is a Call, not a fix. Consider the patrol cop's 32 px/m read on asphalt
   beside the new pale peds (the cops are now the darker figures, as in r2_a5).
3. REPORT rewrite at 08:40 (draft current to 1d4abaa6; Calls 1-6 stand, Call 6 now A = built pale crowd).
   frames.json 15, every file exists.
- 01:03 the 64 px/m live close-up: quest 1 `--rigs --ppm=64 --ticks=900-1800` (one tick per frame, 451 frames) on
  HEAD and on the 9f2aac24 ped files (restored, re-imported, tree clean): `M/cast-quest1-peds-ab-64.mp4` (15 s,
  before | after, centre crop). 0 SCRIPT ERROR both; the after run exited 1 on a `WASAPI: GetBufferSize` audio
  device error only (FRICTION: the shared machine's audio device, not the game). The quest camera stays tight on
  Rivet at the payphone, so only one ped crosses the frame edge (smaller head, a lighter top): weak close-up
  evidence; the react and street boards carry the 64 px/m judgement. Not in frames.json.
  Two Godot processes running at 00:54 (PIDs 10744, 40076) belong to the n6 ghost-forms lane: left alone.
Session end 01:05: head = this commit, tree clean, image.lock and bench.lock never taken, no Godot process of mine
  running, scratch deleted (masters keeps only frames.json files and files REPORT cites). NEXT is the 00:53 list.

## Iteration 12 (session 01:03 - 02:03), BUILD
Read: JOURNAL NEXT (00:53 list), git log, REPORT, frames.json; looked at cast-ingame-vs-r2c6, city-navy-64ppm,
crowd-planview-ab-vs-r2a5, react-board-planview-ab-64ppm, cops-navy-vs-r2c5-64ppm. Item: NEXT 1, the plan-view ped
part sheet (the open item of the crowd). Two Godot processes running at 01:03 (PIDs 27076, 51308) are not mine: left alone.
- 01:05 FINDING (not cast): the dark rings round every cop in `--arena=city` frames are the arena's dummy range rings
  (`arena_floor_view.gd` `_ring`, dev range instrumentation); absent in the city and quest paths. Not touched.
- 01:06 RE-TRIAL of the iteration 10 r4 sheet (`gen/r4`, ped_pale_a: front-facing lapels, a dark hat) on top of the
  iteration 11 plan-view values (head_k 0.75 for its 0.82x heads), `cast_lineup -- --crowd [--road|--walk]` before
  (HEAD) and after: at 32 px/m the dark r4 hat and charcoal jacket read DARKER than the built pale crowd; 64 px/m only a
  little richer. NO-GO, reverted (git checkout, re-import, tree clean). `M/frames/crowd-r4-sheet-retrial-ab.png`.
- 01:07 Codex job `ped_plan_a` (58 s, under image.lock, released; `masters:n5/cast/gen/r5/jobs.json`): an edit of
  d4 `ped_a.png` with r2_a5 crop + r1_c6 as refs, asking for a PURE plan view: the coat and the jacket as shoulder
  ovals with a collar ring round the neck hole (no lapels, buttons or shirt front), a pale felt hat seen as two
  circles, a dark hair crown, a pale hood; heads ~0.8 of the old art. Came back clean, anchor cell kept.
  Cut by `cut_ped_sheet.py` (factor 1.024), the enclosed neck holes filled with a dark neck tone (else the ground
  shows through under the smaller head), the torsos rescaled to the shipped 213 px width.
  DECISION: keep the ped footprint (the cast's size authority, 0.83 m) rather than take the cut's 229 px (7.5 %
  wider, which would shift the whole ladder: cops 1.08x -> ~1.0x, Rivet 1.20x -> ~1.12x). `rig_footprint.gd` after:
  ped shoulder 0.83 m, torso depth 0.50 m (was 0.52).
  DECISION: D4 only. The five parts' D5 overlays are removed (RigDetail.has_part skips a part with no D5 mirror, the
  d4-production route), so at 64 px/m these five parts show the new flat-fill art in the D4 print; a D5 hatched
  restyle of the r5 sheet (slice_d5 alpha lock) is the follow-up if the close-up wants the hatching back.
  `PED_HEAD_K` 0.62 -> 0.75 keeps the rendered head size on the 0.8x art.
- 01:10 lineups before/after (`cast_lineup -- --crowd`, slab / road / walk, 32 and 64 px/m, 0 SCRIPT ERROR): the
  coat+hat ped is now a pale figure with a pale hat ring at both zooms (was a dark disc with a cream rim), the jacket
  a mid grey at 64 px/m (dark at 32), the hood ped pale; hoodie, vest and overalls unchanged (not on this sheet).
  Unit 942/0, lint 13/13.
- 01:14 react board (`react_board_run.gd -- --zoom=2 --every=4`, 481 frames) and street board (`--board=street`,
  241 frames), 0 SCRIPT ERROR both; before = the right half of iteration 11's A/B clips (HEAD's ped art, same
  ticks): `M/cast-react-board-r5peds-ab-64ppm.mp4`, `M/cast-street-board-r5peds-ab-64ppm.mp4`, stills
  `M/frames/react-board-r5peds-ab-64ppm.png`, `M/frames/street-board-r5peds-ab-64ppm.png`. Cops identical; every
  ped reaction, death and corpse reads; the coat ped's corpse now shows the pale coat and hat. Flee and the kill
  read as before. Gib cuts copy each sprite's texture and transform, so they carry the new parts.
- MILESTONE f4910eca: plan-view ped sheet r5 built (5 parts D4, D5 entries dropped, PED_HEAD_K 0.75, 5 provenance
  lines). Registry `sprite-and-atlas-production` applied: judged at the minified size (32 px/m) first; the art's
  scale is held to the footprint, not to the generated size.
- 01:19 EVIDENCE GATE on b722cb84 (`node tools/evidence/run.mjs --no-bench`, no edits during it): lint 13/13, unit
  942/0, scenarios 46, parity bit-exact (mutation caught at 629), look goldens 11/11 (worst 0.83) and block 5/5 (worst
  0.86), world lock holds. The goldens did not move past tolerance: NO re-bless (none needed).
- 01:20 final lineups (torsos at 213 px) beside r2_a5: `M/frames/crowd-r5-ab-vs-r2a5.png`. Live city block
  `film.sh cast-r5peds-city-32 32 900 --bot=reel --arena=city --loadout=pistol,machine_pistol` (0 SCRIPT ERROR), A/B
  against iteration 11's `cast-peds-city-32.mp4` (same sim, tick for tick): `M/cast-r5peds-city-ab-32.mp4`,
  `M/frames/city-r5peds-ab-32ppm.png`: the crosswalk ped is paler with a small head (the arena block has one ped).
- 01:21 COMBAT CHECK director reel headless (`--fixed-fps 60 --quit-after 7200 ... --bot=reel --reel=director
  --loadout=pistol`): 16 chapters started, 16 down (claw 2/2, pistol 2/2, machine pistol 4/4 .. mini nuke 4/4), 0
  SCRIPT ERROR.
- 01:22 decisions line, REPORT section 5 (+ gates line, open item, Call 6 back-out), frames.json 15 (+ crowd-r5,
  city-r5peds, react-board-r5peds at the top; dropped from the list, files kept as REPORT cites them:
  crowd-planview-ab-vs-r2a5, city-peds-ab-32ppm, react-board-planview-ab-64ppm).
- 01:24 FINDING + fix cc744d85: `PED_HEAD_K` is plan-wide, so f4910eca's 0.62 -> 0.75 (to keep the r5 heads' size)
  also grew the old bald, beanie and cap heads 21 %. Fixed at the art: the r5 heads re-cut from the sheet at factor
  1.2385 (= 1.024 x 1.21, the old heads' sizes: hat 155, hair 128x121, hood 140x134) and PED_HEAD_K back to 0.62.
  New masters tool `cut_ped_sheet2.py` (explicit factor, cell:role[:width], neck holes filled). Lineup check
  (before / f4910eca / cc744d85): the old-art heads back to the iteration 11 size, the r5 heads unchanged. Unit
  942/0; provenance hashes of the three heads updated.
- 01:24 Codex job `ped_plan_b` (59 s, under image.lock, released; `masters:n5/cast/gen/r6`): an edit of the r5
  sheet for the other looks: a charcoal hoodie (hood lying flat on the back), a cream striped knit vest, warm-grey
  overalls with dark straps, a pale knit beanie, a dark flat cap (no blue, no red). Cut at 1.024 (torsos fitted to
  the shipped widths 214/218/215) and 1.2385 (heads).
- 01:26 TRIAL all five: the vest ped reads pale with a dark hair crown (gain), beanie and cap fine; the charcoal
  hoodie prints as a solid dark slab at 32 and 64 px/m and loses the pale crescent that marked its head. DECISION:
  keep the iteration 11 hoodie torso (one file back; the r6 cut stays in `gen/r6/cut/torso_hoodie.png` if wanted),
  build vest, overalls, beanie and cap. Three-way board (before / trial with hoodie / built):
  `M/frames/crowd-r6-ab-32-64ppm.png`.
- MILESTONE 0bcd2ce9: r6 parts built (vest, overalls, beanie, cap; the vest's D5 overlay dropped; 4 provenance
  lines). Unit 942/0, lint 13/13. React board re-shot on the final parts (481 frames, 0 SCRIPT ERROR):
  `M/cast-react-board-r5peds-ab-64ppm.mp4` and its still now show r5 + head fix + r6 (the board's peds are the coat
  and jacket looks); every reaction, death and corpse reads, cops identical.
  Now from straight above: coat, jacket, vest, overalls, felt hat, hair, hood, beanie and cap are plan-view art;
  the hoodie torso, the bald head, the limbs and the shoes are still the 3/4-view art.
- 01:35 EVIDENCE GATE on eec9e750 (no edits during it): lint 13/13, unit 942/0, scenarios PASS, parity PASS, look
  goldens 11/11 (worst 0.92), block 5/5 (worst 0.96): no re-bless. Director reel on the final parts: 16/16 chapters
  down, 0 SCRIPT ERROR. REPORT gates line updated. frames.json 15 (+ crowd-r6-ab-32-64ppm), every file exists.
  Registry rules applied (`sprite-and-atlas-production`, `generated-asset-world-scale`): judge each generated part at
  32 px/m first and keep the footprint, not the generator's size (torsos fitted to the shipped widths, heads to the
  old heads' size so one render scale serves the whole plan); a part that loses its read at game zoom is not shipped
  even when the sheet is better art (the hoodie).

NEXT (iteration 13):
1. The crowd item's art is now plan-view for coat, jacket, vest, overalls and five heads (f4910eca, cc744d85,
   0bcd2ce9). Open: (a) a plan-view hoodie that keeps a pale head mark (a pale-grey hood ring on a mid-grey hoodie,
   not charcoal; the r6 cut is `masters:n5/cast/gen/r6/cut/torso_hoodie.png`); (b) the D5 tier: the new parts have no
   D5 hatching, so at 64 px/m they are flat fill beside hatched limbs; a D5 restyle (Codex edit of r5/r6 in the d5
   hatched style, sliced with the D4 alpha lock like slice_d5.py) would match; (c) the street board and quest 1 at
   48 px/m: the street board IS re-shot on the final parts (01:37, below); quest 1 at 48 px/m is not.
2. Calls 1-6 stand; REPORT section 5 current to eec9e750. REPORT rewrite at 08:40.
Session end ~01:40: tree clean after this commit, image.lock and bench.lock released / never taken, no Godot process
  of mine running, scratch-cast/i12 deleted.
- 01:37 street board re-shot on the final parts (`--board=street`, 241 frames, 0 SCRIPT ERROR): `M/cast-street-board-r5peds-ab-64ppm.mp4` and its still now show r5 + r6; flee, the kill and the corpse read as
  before. Scratch `i12b` deleted. Session end 01:38: tree clean, no lock held, no Godot process of mine running.
- 01:39 NEXT 1(a) taken now: Codex job `ped_plan_c` (51 s, under image.lock, released; `masters:n5/cast/gen/r7`), an
  edit of r6 changing only the hoodie cell: a mid warm-grey hoodie with a wide cream hood ring. Lineup trial (built vs
  r7, slab, asphalt, 64 px/m; `M/frames/crowd-r7-hoodie-ab.png`): the hoodie ped reads as pale shoulders with a dark
  head at 32 px/m on slab and asphalt, like r2_a5's crowd, where the built one was a dark slab with a cream crescent.
  The jacket keeps the crowd mixed. GO.
- MILESTONE 1d9c3c53: r7 hoodie built (D4; the hoodie had no D5 overlay; provenance line). Unit: one run 941/1 = the
  known flake `test_noir_shadows` ("Parameter t is null"), then the suite 942/942 twice. Street board on r7 (241
  frames, 0 SCRIPT ERROR): flee, the kill and the corpse read; mixed values.
  Now every ped torso (coat, jacket, hoodie, vest, overalls) and the hat, hair, hood, beanie and cap heads are
  plan-view art; the bald head, limbs and shoes are the 3/4-view art. NEXT 1(a) closed; 1(b) D5 hatching stands.
- 01:49 EVIDENCE GATE on 5cf7cafe (r7 hoodie): lint 13/13, unit 942/0, parity PASS, look goldens 11/11 (worst 1.00),
  block 5/5 (worst 1.08), no re-bless; scenarios FAIL 1/46 = `scenario_corpse_horde`. That scenario times the headless
  sim step (early vs late windows, Time.get_ticks_usec) and the r7 change is one PNG + parts.json (render only); another
  lane's Godot (PID 55216, ~500 MB, not mine) was running. Re-run of the scenario suite alone at 01:53: 46 ran, 0
  failed. FRICTION: corpse_horde's step-cost check is contention-sensitive like the city_chase nav budget; treat a
  lone failure under load as CONTENDED and re-run it alone. REPORT gates line updated.

NEXT (iteration 13), replaces the 01:35 list:
1. The crowd: every ped torso and five heads are plan-view art (f4910eca, cc744d85, 0bcd2ce9, 1d9c3c53). Open:
   (b) D5 hatching for the new parts (Codex restyle of r5/r6/r7 cells in the d5 hatched style, sliced with the D4
   alpha lock like slice_d5.py; judge at 64 px/m beside the hatched limbs); (c) quest 1 `--rigs` at 48 px/m and the
   city block at 32 px/m re-shot on the final parts (render only; lineups, react and street boards are done);
   (d) the bald head and the shoes are still 3/4-view art.
2. Calls 1-6 stand; REPORT section 5 is current to 5cf7cafe. REPORT rewrite at 08:40. frames.json 15, all exist.
Session end 01:54: tree clean after this commit, image.lock released (3 jobs tonight: r5, r6, r7), bench.lock never
  taken, no Godot process of mine running, scratch i12/i12b/i12c deleted.

## Iteration 13 (session 01:54 - 02:54), BUILD
- 01:55 read JOURNAL, log, REPORT, n5-look JOURNAL (no new REQUEST to cast). No locks present. Plan: NEXT 1(c) first
  (the live city block at 32 px/m and the r2_c6 still composite re-shot on the final ped parts r5+r6+r7; the r2_c6
  composite is the brief's item 5 still and dates from 23:16, before the plan-view peds), then 1(b) D5 hatching.
- 01:56 NEXT 1(c): live city block on the final parts (`film.sh cast-r7-city-32 32 900 --bot=reel --arena=city
  --loadout=pistol,machine_pistol`, 0 SCRIPT ERROR). A/B against e1f848a5's `cast-navy-city-32.mp4` (same sim, pre
  plan-view peds) at t=3/8/12 s: `M/frames/city-r7peds-ab-32ppm.png`; the bottom-right sidewalk ped is pale, the cops
  are identical. `M/frames/cast-ingame-vs-r2c6.png` re-shot on 1d9c3c53 (brief item 5's still; the 23:16 one predated
  the plan-view peds), cropped clear of the HUD.
- 02:00 quest 1 `--rigs --ppm=48 --ticks=900-1800` (451 frames, exit 0, 0 SCRIPT ERROR). FINDING: walking peds on the
  pale slab print as dark blobs. Cause: the jacket and hoodie looks wear the `_dark` sleeves (fill L 48, near-ink),
  and walking arms swing out as the widest shapes. The r7 hoodie body is mid warm grey (L 164) but its sleeves stayed
  black. DECISION: the hoodie wears the existing `_grey` sleeves (`RigVariant.HOODIE_SLEEVE`); the jacket keeps `_dark`
  as the crowd's one dark look (the mixed-crowd decision, r1_c6's dark suit). Lineups A/B (slab, road, walk, 32 and 64
  px/m): `M/frames/crowd-hoodie-sleeve-ab.png`. Quest 1 A/B (same ticks): `M/frames/quest1-hoodie-sleeve-ab-48ppm.png`,
  `M/cast-quest1-hoodie-sleeve-ab-48.mp4`: the walking hoodie ped is pale arms round a dark head (the dark flat cap at
  head_k 0.62 covers most of the narrow torso: kept, a dark head on pale shoulders as in r2_a5).
- MILESTONE 15feca4a: hoodie sleeves. Lint 13/13, unit 942/0.
- 02:09 NEXT 1(b): Codex job `ped_plan_d5` (61 s, under image.lock, released; `masters:n5/cast/gen/r8`): a restyle edit
  of a sheet I composed from the ten installed D4 plan-view parts (`make_sheet.py`, x1.8, `layout.json`), with the
  shipped D5 cop torso, cap, ped thigh and upperarm as the style ref. The parts came back registered, hatched lower-left,
  and grainy, but warmer. First install: the hair heads printed VERMILION specks at 64 px/m (warm chroma; red is blood
  only) and the cap went mid grey. Fix at the art (`install_d5.py`): per part, Y mean/std and mean chroma matched to the
  D4 part, the D4 alpha and size. Re-check: 0 vermilion px in all three 64 px/m lineups. Board:
  `M/frames/crowd-d5-hatch-ab-64ppm.png`.
- MILESTONE 093f4b73: D5 hatching for the ten plan-view ped parts (10 provenance lines). Lint 13/13, unit 942/0.
  React board (481 frames) and street board (241), 64 px/m, 0 SCRIPT ERROR, A/B against the iteration 12 clips:
  `M/cast-react-board-d5peds-ab-64ppm.mp4`, `M/cast-street-board-d5peds-ab-64ppm.mp4`, still
  `M/frames/react-street-d5peds-ab-64ppm.png`. Every reaction, death, corpse, burn and blood frame is identical in place.
  The hoodie ped reads pale where it was black.
  Registry rules applied (`sprite-and-atlas-production`): restyle tiers keep the base tier's silhouette (alpha lock)
  and its value (the generator's colour drift is corrected at the art, not in the shader, which is the look lane's).
  Judged at the tier's own zoom (64 px/m) and checked that 32 px/m is unchanged (D4 untouched).
- 02:31 EVIDENCE GATE started on 093f4b73 (`tools/evidence/run.mjs --no-bench`).
- 02:21 GATE on 5faaf0aa: lint 13/13, scenarios 46, parity exact (mutation caught at 629), block goldens 5/5 (worst
  1.36), world lock holds; unit 942/0 but flagged FAIL because I edited REPORT.md during the run (my error); selftest
  FAIL = "look goldens: no result (exit 1)": the look golden scene wrote look-d1-32ppm.png and stopped. Re-run alone
  (`look_golden.tscn -- --out=res://../build/evidence`, 22 s, exit 0): 11/11 within tolerance (worst mean 1.20, d1
  48 px/m; d5-64 0.68), no re-bless needed. FRICTION: a transient look-golden exit under load; re-run the whole gate
  on a clean tree (below).
- 02:29 EVIDENCE GATE on d6d89921 (clean tree, no edits during it): lint 13/13, unit 942/0, scenarios 46, parity exact
  (mutation caught at 629), look goldens 11/11 (worst 1.20), block 5/5 (worst 1.36), world lock holds. ALL PASS, no
  re-bless.
- 02:30 COMBAT CHECK director reel headless (`--fixed-fps 60 --quit-after 7200 ... --bot=reel --reel=director
  --loadout=pistol`): 16/16 chapters down (claw 2/2, pistol 2/2, machine pistol 4/4 .. mini nuke 4/4), 0 SCRIPT ERROR.
  frames.json 15 (+ cast-ingame-vs-r2c6 re-shot, crowd-d5-hatch, quest1-hoodie-sleeve, react-street-d5peds,
  city-r7peds at the top; dropped from the list, files kept as REPORT cites them: city-r5peds, cop-crown-sleeve-trial,
  quest1-dock9-32, crowd-r5, react-board-r5peds).
- 02:31 NEXT 1(d) judged: the bald head is already plan-view art (a grey skull disc, two ears, a nose nub) and so is the
  shoe (a dark capsule with a cream toe); no redraw. The bald head was the last ped head without a D5 overlay: Codex
  job `ped_bald_d5` (45 s, under image.lock, released; `masters:n5/cast/gen/r8b`), the same r8 pipeline (x3 single-part
  sheet, install_d5.py with the value/chroma lock). Lineup at 64 px/m: hatched lower-left, paler like every D5 part,
  0 vermilion px: `M/frames/crowd-bald-d5-ab-64ppm.png`.
- MILESTONE f5733b83: D5 bald head (provenance line). Lint 13/13, unit 942/0, street board 241 frames 0 SCRIPT ERROR
  (`M/cast-street-board-d5peds-ab-64ppm.mp4` re-cut on it), look goldens alone 11/11 (worst 1.20).
  Now every ped torso and head is plan-view art with a D5 overlay; the limbs and shoes keep the d5-cast art.

NEXT (iteration 14), replaces the 01:49 list:
1. The crowd item is complete at both tiers (plan-view D4 + D5 for the five torsos and six heads; the hoodie on grey
   sleeves). What's left is judgement, not missing parts: (a) the jacket's `_dark` sleeves keep it the one dark look
   (`RigVariant.crowd` index 1); if the owner wants a paler crowd, `_grey` there is one value (Call 6 note);
   (b) the hoodie's dark flat cap is the largest head (162x151, head_k 0.62) and reads as a black disc at 32 px/m; a
   beanie-size cap (resize the D4 + D5 parts and parts.json) is a cheap trial if the walking hoodie ped still reads heavy.
2. Weakest item now, from tonight's composites: Rivet vs r2_c3 at 32 px/m (the cream figure with the vermilion collar
   ring; Calls 1, 2 and 5 hold the forks). And the cops' dark rings in `M/frames/cast-ingame-vs-r2c6.png` are a
   gameplay overlay, not rig art (not my lane).
3. Calls 1-6 stand; REPORT section 5 and the gates line are current to f5733b83. REPORT rewrite at 08:40. frames.json 15.
- 02:37 NEXT 1(b) of the 02:35 list taken: hoodie cap at the beanie size (D4 + D5 PNGs x0.846, parts.json size/pivots
  scaled). Lineups slab/road/walk at 32 and 64 px/m (built vs trial, 0 SCRIPT ERROR): `M/frames/crowd-cap-size-ab.png`.
  At 32 px/m the hoodie ped shows more pale hoodie round a smaller dark head (slab and road); at 64 px/m it matches the
  other heads. GO. Unit 942/0, look goldens alone 11/11 (worst 1.21). Provenance hashes of the two cap files updated.
- 02:44 EVIDENCE GATE on 621c0d3f (clean tree): ALL PASS: lint 13/13, unit 942/0, scenarios 46, parity exact, look
  goldens 11/11 (worst 1.21), block goldens 5/5 within mean 4 (worst 1.38). No re-bless this iteration. REPORT gates line updated.
  NEXT 1(b) of the 02:35 list is DONE (621c0d3f). The 02:35 NEXT list otherwise stands; next is item 2, Rivet vs r2_c3 at 32 px/m.
Session end 02:46: tree clean after this commit, image.lock released (2 jobs this session: r8, r8b), bench.lock never
  taken, no Godot process of mine running, scratch-cast/i13 deleted.

## Iteration 14 (session 02:45 - 03:45), BUILD
- 02:46 read JOURNAL, log, REPORT Calls, n5-look JOURNAL (no new REQUEST to cast). No locks present. Start at NEXT 2
  (Rivet vs r2_c3 at 32 px/m).
- 02:48 FINDING at 32 px/m: Rivet's collar is the D1 sticker (`lod_fill` 1) = one flat vermilion ring that reads like
  a UI reticle; r2_c3's collar is a vermilion/black hazard band, and r2_c6/r2_c7 at game scale draw it as an orange
  band with a few dark gaps. The collar art already has 14 slanted stripes (prints at 48 px/m and up).
  Trials (cast_lineup slab/road 32 px/m, lossless, and the live city `--bot=reel --arena=city` A/B at t=4/8/12 s):
  (a) the art's stripes (`vr > gate`, gate 62 and 30): mipmapped they mottle into a dark ring with red specks in the
  live print: REJECTED; (b) procedural UV-angle breaks: 14/0.4 muddy, 8/0.35 a dashed ring (vermilion halved),
  6/0.3 stays a vermilion ring at 1x with a hazard rhythm up close. DECISION: 6 breaks at ink 0.3
  (`PartMaterials.COLLAR_LOD_FILL` 3; 1 = the old flat ring), decisions line. 48 px/m checked: already the art tier,
  identical before/after.
- 03:00 checks: director reel headless 16/16 down, 0 SCRIPT ERROR; director first chapters (0-1140) and city 900
  ticks at 32 px/m filmed after and before (flag flipped, same ticks): `M/cast-collar-director-ab-32.mp4`,
  `M/cast-collar-city-ab-32.mp4`, still `M/frames/collar-hazard-ab-vs-r2c7-32ppm.png` (with r2_c7 + r2_c6 crops),
  trials `M/frames/collar-ticks-lineup-32ppm.png`, `M/frames/collar-trials-city-32ppm.png`. Lint 13/13, unit 945/0
  (+ test_collar_sticker: the material's fill, core/limb unchanged, ink share < 0.5, 4-8 breaks). Look goldens alone:
  junction 11/11 (worst 1.21), block 5/5 (worst 1.38), no re-bless. frames.json 15 (2 new on top; dropped from the
  list, files kept for REPORT: city-navy-64ppm, rivet-size-call-64ppm).
  Registry rules (`shader-budget-authoring`): one atan per collar pixel, only inside the existing sticker branch, no
  new pass or fetch. print_part.gdshader is the part print (n5-look has not touched it on its branch: no conflict).
- MILESTONE 4f9a2ead: the hazard collar at 32 px/m (above).
- 03:10 EVIDENCE GATE on 4f9a2ead (clean tree): ALL PASS: lint 13/13, unit 945/0, scenarios 46, parity exact (mutation
  caught at 629), look goldens 11/11 (worst 1.21), block 5/5 (worst 1.38), world lock holds. No re-bless.
- 03:12 TRIAL, reverted on purpose (git checkout of the three files, nothing committed): the welder visor at 32 px/m.
  r2_c7 reads a dark visor slot on Rivet's head at game scale; ours is a cream head. Measured (helmet 207x150 BOX-
  minified to the ~16 px it covers at 32 px/m, the shader's d): the visor column already prints ink (d 0.61-0.75 over
  the sticker hi 0.40), but it is 2 px and sits against the 1.3 px sticker outline, so it merges into one thicker front
  edge; the back plates and hose (d 0.74-0.95) print ink too. Patch tried: `PartKind.HEAD` (lod_fill 4: cream helmet,
  ink only in the visor UV band 0.74-0.90). Lineup slab/road/walk at 32 px/m: no visible change, because the edge
  pass inks the back rim anyway: `M/frames/visor-sticker-trial-32ppm.png`. Not built. A visor that reads at 32 px/m
  needs a bigger head or a visor drawn wider than the art (a design call, not a print fix). The patch is
  `scratch-cast/i14/visor_patch.py` if wanted.
- 03:16 REPORT: section 3 bullet (hazard collar), Call 7 (collar A hazard breaks / B flat ring), gates line for
  iteration 14.
- 03:13 FINDING: every 32/64 px/m lineup shows a teal pixel cluster at Rivet's torch tip. Source: `rivet/r_forearm.png`
  (D4 = D5 file) carries a cyan flame tip (414 px over the shader's teal gate). It predates this lane (F-09 D4 art,
  95f55fb2, 745 px) and survived my piston-arm redraw. rivet-motion flagged it on 11-03 ("teal is for souls only");
  n-visual had called it allowed. DECISION: follow the owner's standing verdict and r2_c3 (a pale tip): recolour to a
  cream ramp (`masters:n5/cast/tools/torch_cream.py`, 1483 px over two passes, sat cut 0.25 then 0.08 for the pale cyan
  highlights). Lineups slab/road 32 and 64 px/m: the tip prints the limb grey at 32 and cream at 64, no teal:
  `M/frames/rivet-torch-cream-ab.png`; director reel 0-1140 at 32 px/m, same sim: `M/frames/rivet-torch-cream-director-32ppm.png`
  (clip `M/cast-torch-director-32.mp4`). Lint 13/13, unit 945/0. Provenance lines 1050/1058 updated (sha + note).
  Not touched: the 1 px teal in the helmet art (25,51) and in the D5 claw (171,56), both below a printed pixel.
- 03:23 EVIDENCE GATE on f7cc15b5 (clean tree): ALL PASS: lint 13/13, unit 945/0, scenarios 46, parity exact (mutation
  caught at 629), look goldens 11/11 (worst 1.22), block 5/5 (worst 1.38), world lock holds. No re-bless. REPORT gates
  line updated. frames.json 15 (+ rivet-torch-cream-ab; dropped from the list, file kept as REPORT cites it:
  director-loadout-16ch-32ppm; every listed file exists).

NEXT (iteration 15), replaces the 02:35 list:
1. Rivet vs r2_c3 at 32 px/m, what's left after the collar and the torch: (a) the welder visor cannot read at 32 px/m
   at today's head size (the 2 px visor merges with the sticker outline; trial reverted, JOURNAL 03:12); the option is a
   design call: a visor drawn wider than the art in the sticker tier, or a larger head (Rivet's size_k is Call 1);
   (b) the claw art's rust specks print vermilion at 64 px/m (`M/frames/rivet-torch-cream-ab.png`, the claw tips); the
   verdict keeps vermilion for danger, objectives and the collar. Measured at 03:24 on the art (px over verm_gate 62,
   alpha > 0.45): D5 claws 3.9-4.4 % (rust, d5 close-up tier only; from 24d2e20a, d5-close), D5 pistol 1.9 %, D5 hose
   0.9 %; D4 and D5 helmet 6.4 % (the orange hose arc, 0bcc34c6 kept it), torso 2.2 % (rust); limbs <= 0.4 %; D4
   claws 0. Judge the D5 claws at 64 px/m in motion first, then decide between the torch_cream approach (rust hue -> brown below `verm_gate`) and leaving
   it as r2_c3's rust (r2_c3 shows orange rust specks all over).
2. Calls 1-7 stand (7 = the hazard collar, new). REPORT section 3 and the gates line are current to f7cc15b5. REPORT
   rewrite at 08:40. frames.json 15 (every file exists).
3. Scratch kept: `scratch-cast/i14/visor_patch.py` (the reverted visor trial).
Session end 03:26: tree clean after this commit, image.lock and bench.lock never taken, no Godot process of mine
  running, scratch-cast/i14 renders deleted (visor_patch.py kept).
- 03:27 NEXT 1(b) judged, NO CHANGE: director reel claw combo at 64 px/m (360 ticks, live D5 tier, 0 SCRIPT ERROR), 4 frames
  at t=1-4 s: the claws print pale with no visible vermilion specks; the only vermilion on Rivet is the collar band.
  The rust that measured 3.9-4.4 % in the D5 claw art does not survive the live print at game zoom. Board:
  `M/frames/claw-rust-check-64ppm.png` (clip deleted). NEXT 1(b) is closed; NEXT 1(a) (visor, a design call) and 2-3
  stand.
Session end 03:28: tree clean after this commit, no Godot process of mine running (the two running at 03:24 are
  n5-look's scenarios), locks never taken.
- 03:27 quest 1 live path for the collar (`quest1_clip.gd -- --ppm=32 --rigs --cam=fight --stills=13600,13660,13720`,
  after and before by flag, 0 SCRIPT ERROR both): the objective marker is itself a flat vermilion ring, so the old
  collar was the same mark as an objective; the hazard breaks set Rivet apart and the vermilion still reads.
  `M/frames/collar-vs-objective-quest1-32ppm.png` (frames.json 15, second; dropped from the list, file kept:
  quest1-dock9-64ppm cited by REPORT). REPORT Call 7 cites it. This supports the 4f9a2ead decision.
Session end 03:30: tree clean after this commit, no Godot process of mine running, locks never taken, scratch-cast/i14
  renders deleted (visor_patch.py kept).
- 03:30 REPORT Call 8 (the visor at 32 px/m: A as built, B a wider sticker-tier visor, C a larger head) with the
  trial still. NEXT 1(a) is now Call 8 and waits for the owner. Session end.

## Iteration 15 (session 03:29 - 04:29), BUILD
- 03:29 read JOURNAL, log, REPORT; n5-look JOURNAL has no new REQUEST to cast; no locks. The brief's list is done;
  the weakest open item vs the targets is Rivet's head at game zoom (Call 8, the visor that does not read at 32 px/m).
  Per "decide, never block": build my pick (B, a sticker-tier visor wider than the art) behind a flag.
  `scratch-cast/i14/visor_patch.py` was gone (scratch cleaned), so rebuilt from the shader.
- 03:31 BUILD: `PartMaterials.PartKind.HEAD` (appended, enum keys stable) for Rivet's helmet (the core rig only;
  humans keep PART heads), `HEAD_LOD_FILL` 4 = print_part's new lod_fill 4: the cream core sticker + an ink slot over
  the helmet front (UV.x > `visor_x0` 0.66, |UV.y - 0.5| < `visor_hy` 0.25; the art faces +x). 2 = as built.
  Trials on cast_lineup 32 px/m slab/road/walk: full slot to the front edge (built) vs an inset slot with a cream gap
  (x 0.60-0.82): the inset's gap is under a pixel and reads weaker. 64 px/m lineups: pixel-identical (the art tier).
  Registry rule (`shader-budget-authoring`): one compare per pixel inside the existing sticker branch, no fetch, no pass.
- 03:35 live director reel 0-1140 at 32 px/m (`--bot=reel --reel=director --loadout=pistol`, film.sh, 0 SCRIPT ERROR
  both), after and before by flag: `M/cast-visor-director-ab-32.mp4`; crops at t=4..18 s show the dark slot on the
  head's facing side in every after tile. Still `M/frames/rivet-visor-slot-ab-32ppm.png` (lineup x6 + live crops +
  r2_c7's Rivet). Lint 13/13, unit 948/0 (+ test_head_visor_sticker).
- MILESTONE 26c1e08a: Rivet's welder visor reads at 32 px/m (Call 8 B built; revert = HEAD_LOD_FILL 2.0).
- 03:47 EVIDENCE GATE on e7c055be (clean tree): ALL PASS: lint 13/13, unit 948/0, scenarios 46, parity exact (mutation
  caught at 629), look goldens 11/11 (worst 1.22), block 5/5 (worst 1.38), world lock holds. No re-bless (Rivet's head
  at 32 px/m moved too few pixels to shift a golden mean). (Two earlier starts refused a dirty tree: my scratch dir and
  REPORT; scratch now lives in `gtai-n5/scratch-cast/i15`, outside the worktree.)
- 03:48 COMBAT CHECK director reel headless (`--fixed-fps 60 --quit-after 7200 --bot=reel --reel=director
  --loadout=pistol`): 16/16 chapters down (claw 2/2, pistol 2/2, machine pistol 4/4 .. mini nuke 4/4), 0 SCRIPT ERROR.
- 03:49 city block on e7c055be (`film.sh cast-visor-city-32 32 900 --bot=reel --arena=city --loadout=pistol,machine_pistol`,
  0 SCRIPT ERROR): `M/frames/cast-ingame-vs-r2c6.png` re-shot (tick 720, same as before, + a Rivet x4 inset).
- 03:50 quest 1 Dock 9 (`quest1_clip.gd -- --ppm=32 --rigs --cam=fight --stills=13600,13660,13720`), after and before by
  flag, 0 SCRIPT ERROR both: `M/frames/visor-slot-quest1-ab-32ppm.png`. The slot sits on the side Rivet faces (the
  64 px/m art visor is at the same place, `M/frames/rivet-visor-ab-64ppm.png`). All three live paths checked.
  frames.json 15 (+ rivet-visor-slot-ab and visor-slot-quest1-ab on top; dropped from the list, files kept as REPORT
  cites them: collar-ticks-lineup-32ppm, crowd-r7-hoodie-ab). REPORT: section 3 bullet, section 4 composite, Call 8
  (B built), gates line for iteration 15.
- 03:52 FINDING (scope check for the visor): KingPlan and ThugPlan are built from `RivetPlan.build()`. Thugs drop the
  collar (PART heads, no slot), but King keeps the collar core, so 26c1e08a put a dark slot on his symmetric star crown
  at 32 px/m (no visor in his art). FIX 18b74bd8: `BodyPlan.head_visor` (Rivet true; King and thug false), the HEAD kind
  only when set; unit 949/0 (+ only-Rivet test); Rivet's lineup pixel-identical to 26c1e08a. Decisions line.
  - FRICTION: one unit run without GODOT_BIN exported printed "exit -1 ... (948 passed)" from the cached evidence; the
    count in that line is stale when the exits are -1. Always export GODOT_BIN in the same command.
- 04:05 EVIDENCE GATE on c3a9ebf2 (clean tree, nothing touched during the run): ALL PASS: lint 13/13, unit 949/0,
  scenarios 46, parity exact (mutation caught at 629), look goldens 11/11 (worst 1.22), block 5/5 (worst 1.38). No
  re-bless. (The 18b74bd8 run had all green results but the unit step was flagged "tree changed during run" because I
  appended to JOURNAL mid-gate; re-run clean.) REPORT gates line and Call 8 updated.

NEXT (iteration 16), replaces the 03:26 list:
1. Calls 1-8 stand; Call 8 is now B built (visor slot at 32 px/m, `PartMaterials.HEAD_LOD_FILL` 4, Rivet only via
   `BodyPlan.head_visor`; revert = 2.0). REPORT sections 3/4, Calls and the gates line are current to c3a9ebf2.
   REPORT rewrite at 08:40. frames.json 15 (every file exists).
2. Weakest left vs the targets, all judgement or owner calls, no missing parts: (a) Rivet at 32 px/m is a cream figure
   while r2_c6/r2_c7 draw him tan-grey with dark limbs (his 56+ px/m tone is Call 5; a 32 px/m warm sticker would be
   new: try `lod_fill` 2's CREAM -> a pale tan for Rivet's core only, judged on slab and asphalt, only if the
   vermilion collar still leads); (b) the cops read as bright-blue pad clusters at 32 px/m vs r2_c6's navy bodies
   (Call 4 options C/D, owner's pick).
3. Cheap polish if time: a 1 px cream eye glint inside the visor slot at 32 px/m (r2_c3's two slits) was not tried;
   it likely mottles at ~16 px heads. Judge at x1 before building.
Session end 04:06: tree clean after this commit, no Godot process of mine running, locks never taken, scratch renders
  deleted (`gtai-n5/scratch-cast/i15` keeps logs only).
- 04:07 NEXT 3 TRIAL, reverted on purpose (git checkout of print_part.gdshader, nothing committed): two cream eye glints
  in the visor slot (UV.x 0.76-0.86, |UV.y-0.5| = 0.12 +- 0.05). Lineup slab/road 32 px/m: one cream pixel each; at x7
  they read as r2_c3's slits, at 1x they speckle the slot and break its shape, and 1 px features shimmer as Rivet turns
  (`motion-quality-gating`: judge at game zoom in motion; a 1 px mark fails). Not built. Still
  `M/frames/visor-glint-trial-32ppm.png` (top x7, bottom x1). NEXT 3 closed; NEXT 1-2 stand.
Session end 04:09: tree clean after this commit, no Godot process of mine running, locks never taken.

## Iteration 17 (session 04:19 - 05:19), BUILD
- 04:19 read JOURNAL, log; tree dirty: iteration 16 had built NEXT 2(a) (Rivet's tan core sticker, `core_tan` in
  print_part + `PartMaterials.CORE_TAN` 0.6 + test_core_tan_sticker) and filmed it (cast-tan*-city/director mp4,
  `M/frames/rivet-core-tan-ab-vs-targets-32ppm.png`, `rivet-core-tan-lineup-32ppm.png`) but never journalled or
  committed it. Judged the stills: 0.6 separates Rivet's core from the cream slab, keeps the vermilion collar the lead,
  1.0 goes muddy on asphalt. KEEP, finish and commit (not revert).
- 04:22 FINDING: as left, the tan sat on `PartKind.CORE`, which King (collar core) shares: his cream core would turn
  tan too, against `d5_warm = 0` on KingPlan ("Rivet's own read"). FIX: `PartKind.TAN_CORE` (appended), gated by
  `BodyPlan.core_tan` (Rivet true; King, thug false), `PartMaterials.is_core()` helper. Rivet's lineup after the scope
  fix matches the 0.6 trial (scratch i17/check.png, 0 / 0.5 / built / 1.0, slab and road). Lint 13/13, unit 954/0.
  Registry rule (`shader-budget-authoring`): one mix in the existing sticker branch, no fetch, no pass.
- MILESTONE 3ceb3e30: Rivet's core sticker prints tan at 32 px/m (revert = CORE_TAN 0.0). Decisions line.
- 04:31 EVIDENCE GATE on 08b1f7bc (clean tree): ALL PASS: lint 13/13, unit 954/0, scenarios 46, parity exact
  (mutation caught at 629), look goldens 11/11 (worst 1.22). No re-bless. Bench skipped (other lanes' Godot running).
  COMBAT CHECK director reel headless (`res://dev/arena/arena.tscn -- --bot=reel --reel=director --clean --rigs
  --loadout=pistol`, 7200 frames): 16/16 chapters down, 0 SCRIPT ERROR. (FRICTION: without the scene path the args
  are ignored by boot and nothing runs; always pass `res://dev/arena/arena.tscn`.)
- 04:33 clean live A/B: re-filmed the before clip at CORE_TAN 0 by a local edit, reverted with git checkout (never
  committed); the iteration 16 before clip carried the telemetry HUD. `M/cast-tan-director-ab-32.mp4` (19 s),
  `M/cast-tan-city-ab-32.mp4` (15 s), crops `M/frames/rivet-core-tan-director-crops-32ppm.png`. Honest read: on the
  grey concrete and asphalt the change is quiet (warm beige for white); it matters most on the cream slab, where the
  cream core had vanished. Deleted the six single tan clips (both sides live in the A/B clips) and the i16/i17 scratch
  renders. frames.json 15 (+3 tan on top; dropped from the list, files kept: crowd-r6-ab, city-r7peds-ab,
  crowd-quest1-vs-r1c6). REPORT: section 3 bullet, Call 9, gates line for iteration 17.
- 04:36 quest 1 Dock 9 (`quest1_clip.gd -- --ppm=32 --rigs --cam=fight --stills=13600,13660,13720`), after and before
  (CORE_TAN 0 by a local edit, reverted by git checkout), 0 SCRIPT ERROR both: lossless crops x4
  `M/frames/rivet-core-tan-quest1-ab-32ppm.png`. The tan core separates the body from the cream limb rims and the
  outline; the collar still leads. All three live paths checked. frames.json 15 (quest 1 A/B second; lineup ladder
  dropped from the list, file kept for REPORT). REPORT section 3 and Call 9 cite it.
- 04:39 brief item 5's still re-shot on d2b91a42: `M/frames/cast-ingame-vs-r2c6.png` (city `--arena=city
  --loadout=pistol,machine_pistol`, tick 720, frame from the MJPEG AVI (not lossless; correction 04:52), same crop x1.78 + Rivet x4; 0 SCRIPT ERROR).
  Rivet's tan core and visor slot are in the in-game panel now. frames.json entry updated.
- 04:40 checks on the tan: the hit flash (`tint`, print_part line 128) still forces cream over the tan core after the
  sticker branch, so the flash still reads; D-Noir (dev-only) replaces the colour wholesale, unaffected.

NEXT (iteration 18), replaces the 04:06 list:
1. Calls 1-9 stand. Call 9 is new (Rivet's tan core at 32 px/m, built A = CORE_TAN 0.6, 3ceb3e30; B cream = 0.0,
   C full tan = 1.0). REPORT sections 3/4, Calls and the gates line are current to 08b1f7bc (+ docs commits after it).
   frames.json 15, every file exists. REPORT rewrite at 08:40.
2. Weakest left vs the targets (judgement or owner calls; no missing parts): (a) the cops read as bright-blue pad
   clusters at 32 px/m vs r2_c6's navy bodies (Call 4 C/D, filmed, the owner's pick); (b) at 32 px/m Rivet reads as a
   collar ring with cream rods, where r2_c6 draws a lanky upright figure (Call 7's flat-vs-hazard collar; a thinner
   collar band at 32 px/m is untried: `print_part` COLLAR branch could ink the ring's inner half, judged on the
   director reel and the slab lineup, only if the vermilion still leads).
3. If nothing in 2 is buildable without the owner: re-run the gate on the final tree before the 08:30 freeze.
Session end 04:40 (premature, see 04:45): tree clean after this commit, no Godot process of mine running, locks never taken, scratch
  `gtai-n5/scratch-cast/i17` keeps logs only (renders deleted).
- 04:42 NEXT 2(b) TRIAL, reverted on purpose (git checkout of print_part.gdshader, nothing committed): a thinner
  collar band at 32 px/m. Trial uniforms in the COLLAR branch: below UV radius `collar_r0` (ring spans 0.30-0.49) the
  collar either drops out (discard) or prints ink. cast_lineup slab and road 32 px/m, off | r0 .38 drop | .38 ink |
  .41 drop: dropping shows the torso's ink outline under the collar, not the tan core, and the vermilion thins to
  1-2 px that specks at 1x (.41 worst); ink makes a heavier dark ring. None reads more like r2_c6's upright figure,
  and the specks fail `motion-quality-gating` (1 px marks shimmer in motion). Not built. Still
  `M/frames/collar-thin-trial-32ppm.png` (not in frames.json; REPORT Call 7 may cite it). NEXT 2(b) closed: the ring
  read is the collar's size vs a ~20 px body, a proportion question tied to Call 1, not a print fix.
- 04:44 the power forms and the tan: the Hauler is Rivet's own rig scaled (hauler_look), so it carries the tan core by
  design (Rivet's read, like the collar). `dev/ghost-powers/powers_clip.tscn -- --cops --every=4` (real city,
  32 px/m, 0 SCRIPT ERROR): transform, drive-through and stomp play; the tank's plate prints tan inside the hazard
  collar, the teal soul glow stays distinct. `M/frames/hauler-tan-core-32ppm.png` (ticks 250, 440, x3). No change
  needed. The 48 px/m claim holds: the sticker threshold is parts_flat_below 0.13 screen px per part px (~42 px/m).
Session end 04:40 (premature, see 04:45): tree clean after this commit, no Godot process of mine running, locks never taken, scratch
  `gtai-n5/scratch-cast/i17` keeps logs only. NEXT (iteration 18) as written above; 2(b) is closed (see 04:42).
- 04:45 (session continues; the "session end" lines above were early) MERGE CHECK for the Director: `git merge-tree
  --write-tree --name-only HEAD n5-look` (cb34af73): code, data and art merge clean; conflicts only in JOURNAL.md,
  REPORT.md (add/add) and 16 look goldens both lanes re-blessed. REPORT "Merge note for the Director": take either
  side's goldens, gate the merged tree, re-bless once with one decisions line. No n5-look REQUEST to cast.
- 04:47 merge check widened: d6-combat-notes, d6-perf-city, n6-ghost-powers, n6-ghost-forms conflict with n5-cast only
  in JOURNAL/REPORT. Semantic: n6's DentPlan is built on RivetPlan.build() but has no collar and raw parts, so it gets
  neither the visor slot nor the tan (both gated on the collar core); n6's set_tint edit still calls get_mat(kind)
  and takes TAN_CORE. REPORT merge note extended.
- 04:48 measured the tan against r2_c3 (pixels, lit 60-95 % of each box): fig 2 shoulder plates (189,156,128) sat 0.32;
  built 0.6 = (219,200,172) sat 0.21; 1.0 = (204,178,144) sat 0.29; r2_c3's ground (133,117,103). C (1.0) is the
  closer colour, A (0.6) the lighter sticker for our dark asphalt / cream slab. Kept A (judged in motion on both
  grounds), numbers added to REPORT Call 9 for the owner.
- 04:49 timestamps in this iteration corrected to the real clock (several were written ahead of it).
- 04:51 Call 9 three-way, lossless (quest 1 Dock 9 ticks 13600/13660, CORE_TAN 0 / 0.6 / 1.0 by local edits, each
  reverted by git checkout, 0 SCRIPT ERROR all three) beside r2_c3: `M/frames/rivet-core-tan-call9-3way-32ppm.png`.
  CORRECTION: the iteration 16 note "1.0 goes muddy on asphalt" came from compressed mp4 crops; lossless, 1.0 reads
  cleanly and is the closest colour to r2_c3. Kept 0.6 built (no late flip of a gated value with 20 min left), put C
  to the owner as a real option; decisions correction line, REPORT Call 9 updated. frames.json 15 (3-way on top,
  replacing the 2-way quest 1 still, file kept as REPORT cites it).
NEXT (iteration 18) addition: if the owner has not answered Call 9 by the next BUILD session, consider building C
  (CORE_TAN 1.0): judge in motion on the director reel and the city at 32 px/m, lossless frames, then gate.
- 04:52 director reel 32 px/m, CORE_TAN 0.6 vs 1.0 (local edits, reverted by git checkout, 0 SCRIPT ERROR both), AVI
  frames t=4/10/16 s: `M/frames/rivet-core-tan-director-a-vs-c-32ppm.png` (not in frames.json). On the grey concrete
  the two differ only slightly (1.0 a touch warmer); neither is muddy. CORRECTION: Godot's .avi movie writer is MJPEG,
  so AVI frames are not lossless (green fringes on the collar); only the quest1_clip PNG stills are. The r2_c6
  composite's "lossless" note fixed in JOURNAL and frames.json. For the next session's Call 9 C check, judge on
  quest1_clip PNG stills or a PNG-sequence capture, not AVI/mp4.
Session state 04:53: tree clean after this commit, no Godot process of mine running, locks never taken, scratch i17
  holds logs only.
- 04:57 report-phase prep: all 105 `M/` paths REPORT cites exist; frames.json 15, every file exists. Masters files
  cited nowhere (REPORT, frames.json, JOURNAL): cast-before-city-32, cast-before-director-32 (halves of the
  cast-city-ab-32 / cast-director-ab-32 proof clips), cast-legrim-before-city-32, cast-legrim-city-32 (~85 MB). Kept
  (masters evidence, not scratch); the 08:40 REPORT phase may cite or drop them.
Session end 04:57: tree clean after this commit, no Godot process of mine running, locks never taken, scratch
  `gtai-n5/scratch-cast/i17` logs only. NEXT (iteration 18): the 04:40 list + the Call 9 C addition (04:51).
- 05:01 EVIDENCE GATE on 1474c61c (head, clean tree): ALL PASS: lint 13/13, unit 954/0, scenarios 46, parity exact
  (mutation caught at 629), look goldens 11/11 (worst 1.22). REPORT gates line now names the head.
Session end 05:02: tree clean after this commit, no Godot process of mine running, locks never taken.

## Iteration 18 (session 05:02 - 06:02), BUILD
- 05:02 read JOURNAL, log, REPORT; tree clean, no Godot of mine running. NEXT 2(a) (cop navy vs bright pads) is the
  owner's pick (Call 4 C/D, both filmed); 2(b) closed. Took the NEXT addition: build Call 9 C.
- 05:04 live city A | C (`film.sh ... --bot=reel --arena=city --loadout=pistol,machine_pistol --clean`, 900 frames,
  CORE_TAN 0.6 / 1.0 by local edit, 0 SCRIPT ERROR both; the first pair lacked `--clean` and carried the telemetry
  HUD, re-filmed). `M/cast-tan-city-ac-32.mp4` (single clips deleted, both sides live in it); crops x4 t=4/8/12 beside
  r2_c3 `M/frames/rivet-core-tan-city-ac-vs-r2c3-32ppm.png`. In motion: C a touch warmer, no muddying, the collar
  still leads. With the lossless quest 1 three-way (04:51) C is closer to the target and reads cleanly. DECISION:
  build C. Registry `motion-quality-gating`: judged at game zoom in motion, not from one still.
- 05:09 COMBAT CHECK director reel headless at 1.0 (`res://dev/arena/arena.tscn -- --bot=reel --reel=director --clean
  --rigs --loadout=pistol`, 7200 frames): 16/16 chapters n/n down, 0 SCRIPT ERROR. Lint 13/13.
- MILESTONE 550b000d: CORE_TAN 0.6 -> 1.0 (Call 9 C built; revert = 0.6). Decisions line.
- 05:13 EVIDENCE GATE on 550b000d: ALL PASS: lint 13/13, unit 954/0, scenarios 46, parity exact (mutation at 629),
  look goldens 11/11 (worst 1.22), no re-bless. Bench skipped (other Godot processes running).
- 05:15 REPORT section 3 bullet, Call 9 (C built, A/B one constant), gates line for iteration 18. frames.json 15 (new
  city A | C still on top; director-crops still dropped from the list, file kept, REPORT cites it).
- 05:16 brief item 5's still re-shot on 550b000d: `M/frames/cast-ingame-vs-r2c6.png` (target r2_c6 | city C side of
  `M/cast-tan-city-ac-32.mp4` t=12 s, tick 720, x1.78 | Rivet x4; mp4 frame, not lossless). frames.json entry
  updated. Quest 1 at 1.0 is covered by the 04:51 lossless three-way (C column); the hit flash and the Hauler take
  the same sticker path as at 0.6 (04:40, 04:44), only the mix weight changed.
- 05:23 lossless motion check of C (iteration 17's note: AVI is MJPEG): Godot PNG-sequence capture (`--write-movie
  f.png`), director reel claw combo 0-420 at 32 px/m, `--clean --loadout=pistol`, at 1.0 and at 0.6 (local edit,
  reverted by git checkout; status clean after), 0 SCRIPT ERROR both. `M/cast-tan-director-ac-lossless-x4-32.mkv`
  (libx264rgb qp 0, x4 crop) and still `M/frames/rivet-core-tan-director-ac-lossless-32ppm.png` (ticks 60/200/330
  beside r2_c3). C's core is a distinct tan plate inside the collar, it holds beside the cop's blood, and the kills match frame for frame.
  PNG sequences (1.1 GB) deleted. frames.json 15 (new still second; the 0.6-era B|A|C still dropped from the list, file kept, REPORT cites it).
- 05:25 FINDING (Call 6, not built): in the live city at 32 px/m a standing pale-topped ped on the cream slab is a
  faint cream shape held only by its ink outline (`M/frames/ped-pale-on-slab-city-32ppm.png`, mp4 frame x2); r2_a5 keeps
  dark trousers and hair. The iteration 11 lineup judged it on slab with the outline; in the live city it reads weaker.
  Not reopened at 05:25 (a judged Call, ~30 min left); added to REPORT Call 6 as the cost of A, with the next trial
  named. CORRECTION 05:26: no middle value exists at 32 px/m (the print is two-tone, ink below lum ~0.58); REPORT
  now names a dark head mark on the slab as the next trial; walking peds already show dark legs.

NEXT (iteration 19), replaces the 04:40 list:
1. Calls 1-9 stand. Call 9 is now C built (550b000d, CORE_TAN 1.0; A = 0.6, B = 0.0). REPORT sections 3/4/5, Calls 6
   and 9 and the gates line are current to 0f6ce11a (docs commits after it touch no project file). frames.json 15,
   every file exists. REPORT rewrite at 08:40.
2. Weakest left vs the targets, all owner calls with evidence: (a) the cops' bright-blue pads at 32 px/m vs r2_c6's
   navy bodies (Call 4 C/D); (b) pale standing peds faint on the cream slab in the live city (Call 6 A's cost,
   `M/frames/ped-pale-on-slab-city-32ppm.png`; the 32 px/m print is two-tone, so no middle value exists). The
   coat-hat look got its dark crown (0f6ce11a, 05:28 entry); coat-hood is the palest look left (its hood is the
   head): a darker hood crown is the next trial, the same way (lineup lossless, then the live city).
3. Before the 08:30 freeze: re-run `tools/evidence/run.mjs --no-bench` on the final head.
Session state 05:28: tree clean after this commit, no Godot process of mine running, locks never taken, scratch
  `gtai-n5/scratch-cast/i18` holds logs and label files only (PNG sequences deleted).
- 05:28 NEXT 2(b) TRIAL then BUILT: `cast_lineup -- --crowd` slab 32 px/m lossless showed the two pale looks with no
  dark head mark: coat-hat (pale hat crown) and coat-hood (pale hood); jacket, hoodie-cap and vest-hair carry dark
  heads, overalls-bald a grey one. r1_c6 draws the crowd's heads dark from above. Trial: the hat's crown (flood from
  centre inside the inner ink ring, ~3800 px) x0.40 in D4 `art/ped/head_hat.png`: a 3-4 px ink head mark inside
  the pale brim at 32 px/m, on slab and asphalt (not a 1 px speck: `motion-quality-gating` holds). Applied to the D5
  hat too (64 px/m: a mid-grey hatched crown, the cap look's weight), so the zoom tiers agree. Live city
  (`film.sh cast-hat-city-32 ... --clean`, 0 SCRIPT ERROR) A | B: the faint ped of 05:25 was the coat-hat look and
  now reads (`M/cast-hat-city-ab-32.mp4`, still `M/frames/ped-hat-crown-ab-32ppm.png`). Script
  `masters:n5/cast/tools/ped_hat_crown.py`. Colour only: rig, parts geometry, gibs and reactions untouched (the
  director reel has no hat peds; 16/16 at 05:09 holds for the code). Rejected: the whole hat dark (a disc larger
  than every other head); a print rule (HEAD kind is shared with Rivet's visor slot). Coat-hood left pale.
- MILESTONE 0f6ce11a: the coat-hat ped's dark hat crown (revert = both PNGs from 550b000d). Decisions line.
- 05:37 EVIDENCE GATE on 0f6ce11a: lint 13/13, scenarios 46, parity exact, look goldens 11/11 (worst 1.13), no
  re-bless; unit 953/1 = the known flake test_noir_shadows ("Parameter t is null"); re-run twice (the `-gtest`
  filter ran the full suite): 954/0 both. REPORT section 5 bullet, Call 6, gates line; frames.json 15 (hat still on
  top; react-street-d5peds dropped from the list, file kept, REPORT cites it). Scratch renders deleted.
- 05:39 coat-hood, the palest look left: D4 and D5 `head_hood.png` fills above L 90 toward x0.5 (ramp 90-120; ink,
  face opening, alpha kept), mean L 140 -> 75. Lineup lossless slab/asphalt 32 px/m and 64 px/m (0 SCRIPT ERROR):
  a dark head mark like the hair looks, a hatched grey hood at 64. Every look now has a dark (bald: grey) head, as
  r1_c6. The live city clip (`film.sh cast-hood-city-32`) differed from its before by 0 px at t=2/6/10/14 (no
  coat-hood ped on screen): deleted, not evidence. Still `M/frames/ped-hood-dark-ab-vs-r1c6.png` (before rows from
  the hat-crown still, same lineup and crop).
- MILESTONE 551ed9c6: the coat-hood's dark hood (revert = both PNGs from 0f6ce11a). Decisions line.
- 05:46 EVIDENCE GATE on 551ed9c6: ALL PASS: lint 13/13, unit 954/0, scenarios 46, parity exact, look goldens 11/11
  (worst 1.21), no re-bless. REPORT section 5 bullet, Call 6, gates line. frames.json 15 (hood still second;
  quest1-hoodie-sleeve dropped from the list, file kept, REPORT cites it). Scratch renders deleted.
NEXT (iteration 19) amendment: 2(b) is done for the standing peds (hat crown 0f6ce11a, hood 551ed9c6). Next options
  there: film the crowd in quest 1 at 32 px/m (`quest1_clip.gd -- --ppm=32 --rigs --stills=900,1500`, the 00:40
  path) to see the dark heads in a real crowd, before | after 550b000d. REPORT current to 551ed9c6.
Session state 05:47: tree clean after this commit, no Godot process of mine running, locks never taken, scratch i18
  holds logs only.
- 05:48 quest 1 live path for the dark heads (`res://dev/frames/quest1_clip.gd -- --ppm=32 --rigs --stills=900,1500`):
  after on HEAD, before with the four hat/hood PNGs checked out from 550b000d (re-imported, rendered, restored with
  `git checkout HEAD --`, re-imported; tree clean), 0 SCRIPT ERROR both. Pixel diff located the one changed ped (the
  coat-hat look) at both ticks: before an all-pale outline on the slab, after a dark-headed figure. Lossless x5:
  `M/frames/ped-heads-quest1-ab-32ppm.png`. frames.json 15 (on top; quest1-peds-ab-48ppm-vs-r1c6 dropped from the
  list, file kept, REPORT cites it). NEXT amendment's quest 1 item done.
Session end 05:50: tree clean after this commit, no Godot process of mine running, locks never taken, scratch i18
  logs only. NEXT (iteration 19): the 05:27 list as amended at 05:46; REPORT current to 551ed9c6.

## Iteration 19 (05:50-06:50, BUILD)
- 05:51 read JOURNAL, log, n5-look JOURNAL (no REQUEST to n5-cast). No locks present; other Godot processes (not
  mine) and three 650-830 MB Python jobs running: bench skipped. Gate `tools/evidence/run.mjs --no-bench` on HEAD
  started (scratch `gtai-n5/scratch-cast/i19/gate-head.log`).
- 05:53 Plan: Call 4 is the weakest read left vs r2_c6 (bright-blue pads where r2_c6 has navy bodies). Option D
  (bright crowns + navy sleeves) was only filmed on asphalt (23:33); r2_c6's cops stand on the cream slab. Built the D
  parts in scratch (`i19/d`: crowns from the pre-navy originals 29a853be / cc4cb843~1 via `cop_crown_hi.py`, sleeves
  via the 23:33 rule now saved as `masters:n5/cast/tools/cop_sleeve_navy.py`) for a lossless lineup A | D on slab and
  road after the gate.
- 05:56 GATE on 52065472 (`--no-bench`): lint 13/13, scenarios 46, parity exact (mutation at 629), look goldens 11/11
  (worst 1.21), block goldens 5/5; unit 954 passed 0 failed but flagged FAIL by the tree-change check: my own JOURNAL
  append at 05:53 landed during the run (FRICTION: never edit tracked files while the gate runs). Re-gate at the end.
- 05:57-06:00 Call 4 D trial on the slab: `cast_lineup` (slab, `--road`; 32 and 64 px/m) on HEAD (A) and with the 8
  D PNGs installed (re-import, render, `git checkout HEAD --` the two cop art dirs, re-import, tree clean), 0 SCRIPT
  ERROR all four. Lossless x4: on the cream slab A's two bright sleeve blobs read as a backpack behind a navy head; D
  is r2_c6's cop, one bright head over a navy body. On the road D is quieter but the cream rim and the head dot hold.
- 06:00 DECISION: build D (the iteration 10 hold was judged on asphalt only; r2_c6 stands its cops on the slab, and
  r2_a5 too has bright helmets). Revert = the 8 PNGs from 6812dcdd. Registry `motion-quality-gating`: judged in motion
  in the live city before building (`film.sh cast-call4d-city-32 32 900 --bot=reel --arena=city
  --loadout=pistol,machine_pistol --clean`, 0 SCRIPT ERROR; A side = the after half of `cast-hat-city-ab-32.mp4`, the same
  sim, its cops unchanged since): `M/cast-call4-city-ad-32.mp4`, crops `M/frames/cop-call4-city-ad-32ppm.png`. Each cop
  counts as one figure with one bright head; A's clusters show two to three bright dots per cop.
- 06:00 COMBAT CHECK on D: director reel headless (`--bot=reel --reel=director --clean --rigs --loadout=pistol`, 7200
  frames) 16/16 chapters n/n down, 0 SCRIPT ERROR. React board 64 px/m (`react_board_run.gd -- --zoom=2 --every=4`,
  481 frames, 0 SCRIPT ERROR): flinch, knockdown, the corpse poses, burn (charred) and electro read; the cop corpses
  keep the bright head dot (sheet looked at, frames deleted).
- MILESTONE 2329c483: Call 4 D built (bright crowns `cop_crown_hi.py`, navy sleeves `cop_sleeve_navy.py`, D4 + D5).
  Decisions line. Still `M/frames/cop-call4-d-lineup-vs-r2c6-32ppm.png` (slab, road x4, 64 px/m x2, beside r2_c6).
- 06:06 EVIDENCE GATE on 2329c483: ALL PASS: lint 13/13, unit 954/0, scenarios 46, parity exact, look goldens 11/11
  (worst 1.32), block 5/5 (worst 1.52), no re-bless. Bench skipped (contended).
- 06:08 brief item 5 composite re-shot on 2329c483 (`M/frames/cast-ingame-vs-r2c6.png`, from the D city clip t=12 s).
  REPORT section 2, section 4, Call 4 (D built, A = revert) and the gates line. frames.json 15 (the two Call 4 stills on
  top; torch-cream and visor-slot-quest1 dropped from the list, files kept, REPORT cites them).
- 06:09 FINDING after D: at 32 px/m the riot head (~5 px) printed two 1 px bright slivers around its navy band, the
  patrol cap one bright dot. Trial E: the D4 `head_helmet.png` band painted the crown blue inside the crown's width,
  ink outside (`masters:n5/cast/tools/riot_band_hi.py`; the first pass let a bright bar cross the ink ring, fixed by
  the per-row crown span). Lineup slab / road 32 px/m and 64 px/m (0 SCRIPT ERROR): one solid bright dot like the
  patrol, r2_c6's plain helmets; 64 px/m (D5) keeps the band, pixel-identical. Still
  `M/frames/riot-crown-plain-ab-32ppm.png`. DECISION build (revert = D4 head_helmet.png from 2329c483).
- MILESTONE f4381f32: the riot crown plain bright at 32/48 px/m. Decisions line. Filming the director reel to the
  riot_cop chapter (tick 5040) at 32 px/m for the live path.
- 06:20 EVIDENCE GATE on f4381f32: ALL PASS: lint 13/13, unit 954/0, scenarios 46, parity exact, look goldens 11/11
  (worst 1.33), block 5/5 (worst 1.53), no re-bless.
- 06:15-06:27 live path for the riot crown: director reel filmed to tick 5460 at 32 px/m on f4381f32 and with the
  2329c483 helmet checked out (re-import, film, `git checkout HEAD --`, re-import; tree clean), 0 SCRIPT ERROR both.
  HONEST READ: in the riot_cop chapter before | after differ by only 4 px (>40) around the cop: the head printed as a
  bright dot in both there (cause not isolated; the variant is picked per actor in `rig_variant.gd`, 6 = riot with
  `head_helmet`). The gain is in the standing poses (the lossless lineup). Combat unchanged: the cop blocks, falls and
  gibs as before. `M/cast-riot-director-ab-32.mp4` (82-91.5 s), still `M/frames/riot-crown-director-32ppm.png`;
  the single before clip deleted.
- 06:26 REPORT section 2 (D and the riot crown bullets), Call 4 (revert names both commits), gates line. frames.json
  15: Call 4 lineup, the r2_c6 composite, Call 4 city, the riot lineup on top; every file exists.

NEXT (iteration 20), replaces the 05:27 list as amended:
1. Calls 1-9 stand; Call 4 is now D built (2329c483 + f4381f32; A = the 8 PNGs from 6812dcdd). Call 9 C built.
   REPORT current to f4381f32. REPORT rewrite at 08:40 (say Call 4 D in the summary).
2. Weakest left vs the targets: the D cops are quieter on dark asphalt (one bright head dot). If the owner's frames show
   them lost, the next trial is a lighter navy torso fill at 32 px/m only (the body must stay darker than the crown).
   Also open: why the director reel's riot head printed bright before f4381f32 (4 px diff); check which variant/tier
   that actor uses (`rig_variant.gd` index, LOD) before claiming the live gain.
3. Before the 08:30 freeze: re-run `tools/evidence/run.mjs --no-bench` on the final head; never edit tracked files
   while it runs (05:56 FRICTION).
Session state 06:27: tree clean after this commit, no Godot process of mine running, locks never taken, scratch i19
  holds logs, lineup renders and the D part PNGs (no PNG sequences).
- 06:28 the riot chapter's 4 px diff, likely cause: x10 crops of the head at t=84.1 s show the same dark stripe across
  the bright dome before and after, along the aim line: in the aiming pose the held gun arm lies over the head's
  centreline, where the band ran (the band runs along the facing axis), so the band was hidden there anyway. The
  plain crown shows in the standing and unarmed poses (lineup, crowd cops). NEXT 2's open question is answered by
  this read; a lossless capture would confirm it.
Session end 06:29: tree clean after this commit, no Godot process of mine running, locks never taken.
- 06:30 the 64 px/m live close-up of D (`film.sh cast-call4d-city-64 64 900 --bot=reel --arena=city
  --loadout=pistol,machine_pistol --clean`, 0 SCRIPT ERROR) beside the A-era `cast-navy-city-64.mp4` (same sim, older
  Rivet): `M/cast-call4-city-ad-64.mp4`, still `M/frames/cop-call4-city-ad-64ppm.png`. Navy bodies under bright
  hatched heads; the riot heads keep their band at 64 (D5), as built. Single clip deleted. REPORT section 2 cites it.
Session end 06:31: tree clean after this commit, no Godot process of mine running (the two running since 06:26/06:28
  are not mine), locks never taken.

## Iteration 20 (06:31-07:30, BUILD)
- 06:31 read JOURNAL, log, n5-look JOURNAL (no REQUEST to n5-cast). No locks present. NEXT 2 judged on the D city
  frames (`M/frames/cop-call4-city-ad-32ppm.png`): the D cops still read as blue figures with one bright head on
  asphalt, so the lighter-navy trial is not needed (no build). The black rings round the cops in the `--arena=city`
  frames are the arena's dummy target rings (`arena_floor_view.gd:71`, dev scene), not cast art; quest 1 has none.
- 06:35 merge-tree re-check: n5-look e3883935 = lane docs + the 16 look goldens (as at 04:50); d6-combat-notes,
  d6-perf-city, n6-ghost-powers bf7b1107, n6-ghost-forms e865146d = lane docs only (both n6 lanes merge n5-cast in).
- 06:37 EVIDENCE GATE on 7005b5c8 (`--no-bench`, tree untouched during the run): ALL PASS: lint 13/13, unit 954/0,
  scenarios 46, parity exact (629), look goldens 11/11 (worst 1.33), block 5/5 (worst 1.53). Bench skipped (other
  lanes' Godot processes running).
- 06:37 FINDING (quest 1 Dock 9 stills, `--rigs --cam=fight`, 32 px/m): the heat patrol (`cast_view.gd:52`,
  `_sprite("cop")` even under `--rigs`) is the pre-slim cop sprite, 1.85 x 3.23 m with black sleeves: twice the rig
  cops' width in the same frame. Default quest 1 also draws Rivet from `cast_rivet.png` = d5-cast's size_k 1.2 form
  with a teal torch tip (off doctrine). Both are captures the art README says to redo when the parts change.
- 06:38-06:42 re-captured both with `dev/showcase/rivet_sprite.gd` (`--kind=cop`, `--kind=rivet`, 0 SCRIPT ERROR),
  matted with a crop symmetric about the rig root (new `masters:n5/cast/tools/matte_centred.py`, the body stays at the
  sprite centre as `_sprite` assumes), cream rim r 5; peek cut r 50 (`rivet_peek.py`). Sizes: cop 1.45 x 2.83 m,
  Rivet 2.37 x 2.07 m, peek 0.97 m. `test_quest_art` pinned the cop at 1.85 x 3.23 and asserted Rivet's frame is
  shorter than the cop's (true again after both re-captures); now checks the cop at true scale. Lint 13/13, unit 954/0.
- DECISION (docs/decisions.md): re-capture, not host the rigs in the default quest view (rivet-arsenal Call 1).
  Registry `generated-asset-world-scale`: the sprites draw at true scale (size_m = px / 120), no draw_k.
- MILESTONE b68665b1: quest 1's cast sprites from the slim rigs. Evidence (same sim, before = 7005b5c8 files checked
  out, re-import, render, `git checkout HEAD --`, re-import, tree clean): `M/frames/quest1-sprites-ab-32ppm.png`
  (default quest, tick 13660 + x3 crop, tick 900), `M/frames/quest1-patrol-sprite-ab-32ppm.png` (`--rigs`, x4),
  `M/cast-quest1-sprites-ab-32.mp4` (10 s, Dock 9 ticks 13560-14160, 0 SCRIPT ERROR both). Honest gap: the
  120 px/m capture has no 32 px/m stickers, so the sprite Rivet is paler than the rig Rivet (no tan core, no slot).
- 06:46 COMBAT CHECK on b68665b1: director reel headless (`--bot=reel --reel=director --clean --rigs
  --loadout=pistol`, 7200 frames): 16/16 chapters n/n down, 0 SCRIPT ERROR (the arena does not draw these sprites).
  frames.json 15 (the two quest stills on top; crowd-d5-hatch and rivet-visor-64 dropped from the list, files kept).
- 06:50 64 px/m close-up, same sim (before = 7005b5c8 files, restored, tree clean, 0 SCRIPT ERROR both):
  `M/cast-quest1-sprites-ab-64.mp4` (10 s), still `M/frames/quest1-sprites-ab-64ppm.png` (frames.json 15:
  riot-crown-director dropped from the list, file kept). The hybrid reads with the helmet in the collar; no teal.
  Checked the dock guards (`dock_guard`, 0.9 m x GUARD_DRAW 1.7): drawn silhouette 1.06 x 1.52 m = the cop rig's
  1.01 x 1.45 m bbox, already on the footprint: no change.
- 06:56 EVIDENCE GATE on 84ed1bd1 (`--no-bench`): ALL PASS: lint 13/13, unit 954/0, scenarios 46, parity exact,
  look goldens 11/11 (worst 1.33), block 5/5 (worst 1.53), no re-bless.
