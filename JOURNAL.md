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

NEXT (iteration 11):
1. Assign the lobes' dark interior: markers still to run at 32 px/m: head_hat (and the head/torso HALO_BODY copies,
   rig_build.gd 42-43), torso_jacket for the jacket look, thigh at z (does a second thigh draw, e.g. the D5
   overlay at 32 px/m?), forearm_endon. Read rig_build.gd `_halo` and RigDetail's tier switch first.
2. Fix that part (art via the d4 chars sheets ped_b/ped_c + `cut_ped_sheet.py`/`install_ped_sheet.py`, or the ped
   rest pose), then re-try the r4 sheet (`gen/r4/cut/`) on top. Judge with `--crowd [--road]` at 32 px/m, then the
   react board, ped corpses and gib cuts, the city at 32 px/m, the goldens (one re-bless with a dated line), and a
   provenance line per shipped part.
3. Calls 1-5 in REPORT stand. REPORT rewrite at 08:40; frames.json 15, all files exist.
Session state 00:07: head = this commit, tree clean, image.lock released, no Godot process of mine running.
