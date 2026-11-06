# JOURNAL - lane view (n7x-view), night 2026-11-06

## Iteration 2 (02:00-03:00), BUILD
Iteration 1 left only the moved King journal (`docs/view-lab/king-journal-at-branch-point.md`), so
this session did iteration 1's work first.

- READ: pitch.md camera (90 deg orthographic, "one sprite rotates freely"), the King lane's
  `king_target_vs_game_32ppm_it10.png` (the it7 file is gone; it10 is the same comparison): the
  target is three-quarter, the game is roofs and discs. Registry: depth-ordered-layered-art /
  measured-draw-order, concept-scene-parity / toolkit-fit-slice-before-the-look-is-chosen,
  sprite-and-atlas-production (cost the roster). How each is applied: docs/view-lab/PLAN.md.
- Render path: `--boss=king` runs `res://dev/arena/arena.tscn` -> CollectCallView -> PrintStage
  (camera in `PrintStage.place`); the city path is `CityView._place_camera`.
- MILESTONE 0d13ecde: `--view=<id>` (`data/tables/view.json`, `core/render/view_mode.gd`). Tilt =
  Camera2D zoom `(z, z sin p)`: the ground, decals, FX, lights, markers all foreshorten through
  one canvas transform, and the mouse's global position lands on the ground plane (aim
  unprojection is free for ground targets). `top` and `top_lift` = pitch 90 = `is_flat()`, the
  plain `Vector2.ONE * zoom`, bit-identical. Unit 1164/0 (4 new).
- FILM `evidence/view/it2/grid_t900.png` (32 px/m, seed 2, tick 900, top / 75 / 65 / 55): the
  ground squash alone is nearly invisible at 65-75 (sin 65 = 0.91). Heights are the work.
- MILESTONE a89c3b3d: `RigTilt` 2.5D cutout. The legs were already a 3D chain (RigGait hip_z,
  ik3 knee, foot lift), so each joint now draws lifted by its own height; body at hip height,
  torso +0.55 hip, head +0.45 hip. `hip_local` subtracts the lift so the feet plant unchanged.
  `evidence/view/it2/rivet_zoom.png` (48 px/m, top / 65 / 55, 3x nearest): Rivet stands, legs down
  to the feet; the head is still the top-down disc (needs the upright card). Unit 1164/0.
- DECISION view projection: one camera transform for the ground (zoom.y = sin p) + per-node height
  lifts; rejected a full-screen post-warp (would bend the print grain and the HUD) and a Node3D
  camera (no 3D path).
- MILESTONE 9161400e: `KingCarStack`, the throne-car as an 18-slice stack to a 1.45 m roof (black
  body, gold belt and sill, glass band with gold pillars, tyres, grille/lamps on the nose); roof,
  throne and King's rig lifted on top (to 0 through the step-down); the wreck too.
  FRICTION: per-slice ink outlines (2 px) covered each slice's ~1.8 px visible strip: the wall
  printed solid black. Ink now only on the foot and roof-line slices.
  Pixel check: `--view=top` seed-2 tick-900 frame md5 5db6f283... identical before/after all of
  this (bit-identical evidence for the default at the frame level). Unit 1164/0.
- MILESTONE 1bd33a5d: depth order vs the car (`KingCarStack.sort_rigs`): rigs north of the car
  (smaller ground y) get relative z -64, under the car. FRICTION: `show_behind_parent` did
  nothing (the rigs' parent is KingRigs, which draws nothing). Before/after at 48 px/m:
  `evidence/view/it2/sort_before_after_48.png`: the far riders now stand behind the body.
- FILM `gtai-masters/n7/view/king_views_top_tilt65_tilt55_32ppm_it2.mp4` (25 s, seed 2,
  --bot-human --boss-cam, top | tilt 65 | tilt 55, 0 SCRIPT ERROR each), frames.json (6 entries).
  LOOKED: at 32 px/m the gain is modest. Rivet stands a little, the car gets a thin dark wall
  (cos 65 x 1.45 m = 0.6 m of wall on screen), King's crown sits higher. The planters, Rivet's
  head (no visor face) and the gang heads still read as top-down. My verdict so far: the angle
  alone at 65 does not lift the game to "another level"; the faces (upright cards) and taller
  walls (55 or lower) are where the impression is. Not the owner's verdict.
- Rules applied (registry): toolkit-fit slice first (Rivet + the car, no backdrop work yet);
  measured-draw-order (depth = ground y; the count of sort failures per frame is NOT measured
  yet, only one before/after; next); cost the roster (PLAN cost table).

NEXT (iteration 3):
1. Upright head card for Rivet under tilt: the visor face from the logo
   (`git show main:steam/store/logo/rtai_logo_master.jpg`), 5 facings drawn + 3 mirrored, a
   billboard Sprite2D on the head node picked by (facing - camera) octant; image job under
   image.lock (copy gen.mjs to scratch); provenance line. Same for the King's chest/crown card.
2. Measure draw order: per frame over the 25 s seed-2 clip, count overlapping actor pairs drawn
   in the wrong ground-y order (KingRigs + Rivet's cast canvas are separate canvases: Rivet vs
   gang ordering is not sorted at all yet).
3. Add a `tilt45` pitch row for the stronger-angle study; lift the planters/plinths as stacks.
4. `top_lift` (cast shadows by height, wall extrusion, rim light).
5. Mouse aim under tilt: verify with a live exe run (global mouse pos lands on the ground).
6. Gates so far: lint 13/13, unit 1164/0 (on 9161400e); scenarios on 1bd33a5d see below.
- MILESTONE a53b2e85: `tilt45` row (data only) + arena props extruded under a tilt
  (`ArenaFloorView._prop`, `PROP_H_M` by kind; paint kinds 0). FRICTION: `Dictionary.get` returns
  Variant -> typed-arg warning-as-error broke arena_game's compile (caught by the 3 SCRIPT
  ERRORs in the shot log, fixed before commit). Still `props_top_vs_45.png`: the planters are
  boxes with a south face; the parked sedans are still flat.
  LOOKED at tilt 45 (`views_top_65_45_48.png`): taller car wall, Rivet stands clearly, but the
  top-down part art squashed to 71 % reads squat. The upright face/chest cards are the missing half.
- GATES at the session end: lint 13/13; unit 1164/0, 0 SCRIPT ERROR (a53b2e85, `unit-final.log`);
  scenarios 52 ran / 0 failed / 0 SCRIPT ERROR (started on 1bd33a5d, `scenarios.log`). `top` is
  md5-identical on the seed-2 tick-900 arena frame through every commit (5db6f283...).
  Director reel (`--bot=reel --reel=director --loadout=pistol --rigs`, headless, a53b2e85, switch
  off): 19/19 chapters fully down, 0 SCRIPT ERROR (`evidence/view/it2/director-reel.log`; exit 124
  = my 600 s timeout killing it after the last chapter, the reel does not quit itself).
  NOT RUN yet: evidence/run.mjs, parity.
- Evidence: `gtai-masters/n7/view/` frames.json (8 entries), raw renders deleted.

NEXT (iteration 3), revised (replaces the list above, in order):
1. Rivet's upright head card (the logo visor, 5 drawn + 3 mirrored facings) on the head node
   under tilt, picked by (facing - camera) octant; image job under image.lock (gen.mjs copied to
   scratch); provenance line. Then King's chest/crown card. Film before/after at 32 and 48.
2. Draw-order measurement (count wrong-order overlapping pairs per frame over the 25 s clip),
   including Rivet (cast canvas) vs the gang (KingRigs): not sorted against each other yet.
3. Contact shadows under lifted rigs; the parked sedans as stacks (vehicles class); occlusion
   silhouettes behind tall props.
4. `top_lift`. 5. evidence/run.mjs + parity with the switch off.

## Iteration 4 (02:54-03:54), BUILD
Iteration 3 left no journal entry and no commit, so this session picked up iteration 2's revised NEXT 1.
- IMAGE (image.lock, gen.mjs copied to scratch/view): round1 `rivet_head_facings` (ref: the
  owner logo; 61 s) and round2 `king_bust_facings` (ref: boss_king.jpg; 60 s). Both came back
  clean on chroma green, 5 facings in a row. Visor slit asked cream, not teal (teal = souls).
  Provenance: 2 lines in steam/ai-provenance/2026-11.jsonl.
- MILESTONE 8fd86e65: `RigHeadCard` upright facing cards + rows `tilt_cards`/`tilt55_cards`/
  `tilt45_cards` (view.json `cards`). Cutter `tools/art/cut_facings.py` (key, split, bottom-align,
  strip).
  FRICTION: (1) `bool(Variant)`/`float(Variant)` constructors are warnings-as-errors (twice; read
  typed vars instead). (2) Through the part shader, the logo's dark steel printed as a solid ink blob at
  48 px/m (the gameplay thresholds), and King's gold would print vermilion; both cards are now
  pre-printed in the cutter (--tan, --snap) and drawn raw. (3) KingAccents' flat star crown + ermine
  doubled the card; they now stand down under cards (the defeat crown fall stays).
  LOOKED (48 px/m, seed 2 tick 900, tilt55 vs tilt55_cards): the King reads as a crowned king with an
  ermine collar, chains and cape on the car; Rivet reads as the logo's tan helmet with the visor
  band and the vermilion hazard collar. At 32 px/m (clip): still readable, crown and helmet visible;
  the other two panels show discs. My verdict: this is the first change tonight that moves the
  impression, more than the angle itself. It is not the owner's verdict.
- Gates: lint 13/13; unit 1168/0, 0 SCRIPT ERROR (`evidence/view/it4/unit.log`); `top` md5
  5db6f283... unchanged on 8fd86e65. NOT RUN this session: scenarios, director reel, evidence/run.mjs.
- FILM `gtai-masters/n7/view/king_top_tilt55_tilt55cards_32ppm_it4.mp4` (20 s, seed 2, top |
  tilt55 | tilt55_cards, 0 SCRIPT ERROR each) + 2 stills. FRICTION: I overwrote frames.json by
  mistake (a Python `/c/` path read failed, so I assumed the file did not exist). gtai-masters is not
  git, so I rebuilt the 8 it2 entries from this journal, marked "rebuilt". Now 11 entries.
- Rules applied: toolkit-fit slice first (the hardest element: the character and the boss faces,
  before any backdrop); cost the roster (one 5-frame card per head, roughly 1 image round per character).

NEXT (iteration 5):
1. The card's hit flash (the card is not in rig.sprites; raw cards need a tint path) and the gang's
   head card (the gang share art_dir "gang": one round gives every thug a face).
2. Re-check the cards at tilt45_cards and tilt_cards (65); pick the pitch for the comparison set;
   the King on foot (phase 2-3) with the card; Rivet turning a full circle at 48 (octant pops?).
3. Scenarios + the director reel with the switch off (code touched cut_rig.gd and king_accents.gd).
4. (done it4: the clip re-encoded at crf 26, 44 MB)
5. Then `top_lift`, occlusion, the city block; the cost table and the exe by 08:30.

## Iteration 5 (03:10-04:10), BUILD
- GATES on f442aeba (switch off): scenarios 52 ran / 0 failed / 0 SCRIPT ERROR
  (`evidence/view/it5/scenarios.log`); unit 1170/0, 0 SCRIPT ERROR (`it5/unit.log`); lint 13/13.
- IMAGE round3 `gang_head_facings` (image.lock, 78 s; ref boss_king.jpg): clean on chroma, but
  the turned facings looked to screen LEFT (Rivet/King strips look right). FRICTION: flipping the
  sheet before the cutter also reversed the frame order (the cutter orders runs left to right);
  the cells are reversed back after the cut. Provenance line added.
- MILESTONE 07e7035f: gang head card (`gang` row, one card for every thug) + the card takes the hit
  flash (`RigHeadCard.on_tint` from `CutRig.set_tint`; it4 NEXT 1). LOOKED at 48 px/m
  (`it5/gang_card_zoom.png`): the four bodyguards read as boxy steel heads with black shades and
  gold chains (were grey discs). `top` md5 5db6f283 (32 px/m, seed 2, tick 900) unchanged on 07e7035f.
- FILM `--bot=rivet` (walk, strafe, sprint, roll, claw) 720 frames at 48 px/m, tilt55_cards and top
  (`it5/sheet_*.png`, 16 frames every 45): Rivet's card turns with him, no pops seen at 0.75 s
  spacing (NOT a frame-by-frame check). LOOKED: the blue cops next to him are still top-down
  caps on discs, so the cop (the most numerous enemy) gets the next card.
- NOTE for REPORT: the owner-accepted cast target `targets-2026-11-04/img/r2_c6_cast_ingame_scale_lanky.jpg`
  is itself drawn from a raised angle (about 70 deg: the cops' faces, the crates' south faces).
- IMAGE round4 `cop_head_facings` (image.lock, 56 s; ref targets-2026-11-04 r2_c6): cap, face,
  collar, badge, turned right, in order. Cut unsnapped: it prints through the part shader's cop blue
  (print_part.gdshader: blue-leading pixels -> cop_blue / cop_blue_hi), so raw = false.
- MILESTONE 2f5642e1: patrol cop card (`cop/head_cap`). FRICTION: the first cut gave EVERY cop the
  cap, including the riot cops: variants swap the head texture at runtime (`CutRig.apply_variant`)
  and leave `plan.head_part` alone. Rows now key on art_dir/<variant head> first
  (`RigHeadCard.key_of`), and `apply_variant` drops a built card (pooled rigs re-dress). FRICTION
  again: `pair[0] as Node2D` from an untyped Array = warning-as-error (2250 SCRIPT ERRORs in the shot
  log; fixed before commit). LOOKED (48 px/m, `it5/cop_card_48.png`): patrol cops read as officers
  with a cap and a face; riot cops (dome + shield arc) keep their head. Each further head variant
  is one more image round (riot helmet, SWAT, the 6 ped heads).
- MILESTONE 6115e51f + DECISION: `--view=tilt` = 55 deg with cards (the old 65 = `tilt65`). Grid
  `it5/pitch_grid_32.png` (top / 65 / 55 / 45 with cards, 32 px/m): 65 barely differs from top, 45
  squashes the ground to 71 % and the limbs read squat; 55 keeps the faces and a car wall.
  LOOKED, honestly: at 32 px/m the whole cast is small (Rivet about 40 px tall), and the car still
  reads mostly as its roof (the vermilion carpet dominates; 0.83 m of wall at 55).
- MILESTONE 9ea50921: `top_lift` = a straight-down PERSPECTIVE camera (`eye_h_m` 25 in view.json):
  no angle change, uniform zoom, every height leans out from the camera's ground point
  (`ViewMode.up_at/lift_at`, the eye set by `PrintStage.place`). The same 2.5D machinery (RigTilt,
  the car stack, the props swept to a leaning top) runs with a radial lift. Unit +2 (1173/0).
  LOOKED (`it5/toplift_cmp_32.png`): the car shows a leaning gold side strip; near the centre
  (Rivet) nothing changes. At 25 m the gain is small; 15 m is one data value away. NOT DONE for
  top_lift: cast shadows by height, rim light. `top` md5 5db6f283 unchanged on every commit.
- MILESTONE 12156b5a: King's on-foot cape drapes under a tilt (it was a flat vermilion sheet on
  the ground behind the upright card, `it5/king_onfoot` LOOKED at phase 3 tick 420, 48 px/m). Phase-3
  `top` frame md5 ea8e1054 identical with the file at HEAD vs the new file (checked by swapping the
  file for one shot).
- FILM `gtai-masters/n7/view/king_top_toplift_tilt55cards_32ppm_it5.mp4` (25 s, seed 2, full size
  3840x800, 0 SCRIPT ERROR each). FRICTION: the first encode scaled each panel to 640x400, i.e.
  16 px/m; deleted and re-encoded unscaled. LOOKED at 12 s (ram tell): tilt shows King's crowned bust
  on the car and Rivet's helmet face; top_lift a leaning gold side strip; top a crown on a disc.
- frames.json: 15 entries (5 new, the superseded it2 pitch study dropped and deleted). Raw .avi deleted.
- PLAN.md: measured card cost (4 rounds, 4 usable first try, 56-78 s each).
- CITY (`--arena=city --bot=rivet`, seed 2 tick 300, 32 px/m; `gtai-masters/n7/view/city_block_top_vs_tilt_32ppm_it5.png`):
  the tilt works in the city block: patrol cops and Rivet with faces, props standing. The 3 m high
  barriers printed as solid black slabs (south face = the ink fill darkened); MILESTONE c1a6b4d2:
  the face is the barrier's own concrete, shaded (`it5/city_wall_face_32.png`). The parked sedans
  are still flat. Streaming bubble: the tilt shows 1 / sin 55 = 1.22x the ground north to south
  (computed, not measured in chunks or frame time).
- GATE director reel (`--bot=reel --reel=director --loadout=pistol --rigs`, headless, switch off,
  started on 12156b5a): 19/19 chapters fully down, 0 SCRIPT ERROR (`it5/director-reel.log`; the reel
  does not quit itself, my 900 s timeout ends it). The code after it (c1a6b4d2: the city barrier face) only
  runs under a tilt.
- IMAGE round5 `cop_riot_head_facings` (57 s, image.lock): usable, facing right in order, BUT the
  clear face shield is green-tinted where the chroma shows through: the keyer will eat or spill it.
  Not cut, not in the game. Its out PNG is in scratch/view/round5/out/.

NEXT (iteration 6):
1. The riot card: cut round5 (key the visor carefully: lower tol or paint the shield opaque light
   grey before keying), row `cop/head_helmet`, provenance line; look at it in the pit at 48 px/m.
2. The car still reads as its roof at 32 px/m (the vermilion carpet dominates; 0.83 m of wall at
   55). Try: the hood cannon lifted to its height as a gold barrel (not a flat bar), the wheels as
   ellipses on the wall, the grille on the nose face; film before/after at 32.
3. Draw-order MEASUREMENT (still unmeasured): count wrong-order overlapping actor pairs per frame
   over the 25 s seed-2 clip (Rivet's cast canvas vs KingRigs are not sorted against each other).
4. top_lift: try eye_h_m 15 vs 25 (one data value), add cast shadows offset by height; the
   parked sedans as stacks (city); HUD world markers / FX at height check under tilt.
5. Mouse aim under tilt: a live exe check (cursor ground point vs the shot's landing).
6. The comparison set (work order 6): one seed, every view, 30-60 s hstack at 32 px/m (it5's
   clip is 25 s), 48 px/m close-ups, a stills grid; the cost table. Then freeze: evidence/run.mjs,
   parity, the exe (int-day recipe in docs/decisions.md), REPORT by 08:40.

## Iteration 7 (04:03-05:03), BUILD
Iteration 6 left no journal entry and no commit; this session worked it5's NEXT.
- MILESTONE 01115d6e: riot cop card (round5 cut). The clear visor let the chroma through; the
  cutter's new `--glass` fills the keyed holes enclosed by the part (scipy binary_fill_holes) with
  an opaque pale steel. Row `cop/head_helmet` (prints through the part shader's cop blue).
  LOOKED (pit --riot tick 700, 48 px/m, `evidence/view/it7/riot_card_48.png`): the shield cop
  reads as a blue dome helmet with a pale visor over a face. Provenance line added.
  FRICTION: the unit test asserted the riot helmet had NO card (it5's intent); updated (68ede04b),
  unit 1173/0, 0 SCRIPT ERROR (`it7/unit.log`). gdformat in the pre-commit hook caught a long line.
- MILESTONE 4a3370a7: the car's wheels are round (each tyre a vertical disc cut to its chord per
  stack slice, a gold hub on the face; was a 0.95 m block per slice = a black slab with a tall gold
  bar) + a contact shadow under the stack. LOOKED before/after at 48 and 32 (`it7/car_wheels_48_32.png`):
  the slab-and-bar was wrong, now round tyres; at 32 px/m small but visibly round.
- MILESTONE 173f2cc3: the hood cannon is a raised gold barrel (BARREL_M 0.45 over the roof: its
  shadow on the roof, mount post, ink edge, top highlight, the bore). LOOKED (`it7/car_cannon_48_32.png`):
  reads as a gun barrel at 48 and at 32 (was a flat gold bar). `top` md5 5db6f283 unchanged.
- MILESTONE 5f7b36ad: draw-order MEASURED (registry measured-draw-order; it5 NEXT 3).
  `dev/view/draw_order_probe.gd`, arena `--order-probe`: every 6 ticks, overlapping actor pairs
  (rig vs rig by ground point and body height, rig vs King's car footprint), the nearer must draw
  over (effective z, then tree order; rigs < 16 z apart interleave their parts = `mixed`).
  Seed 2 King fight, 60 s, 32 px/m, headless: tilt 304 rig pairs, 48 reversed (16 %), 215 mixed
  (71 %); car 391 pairs, 2 reversed. top: 212 pairs, 0 reversed, 212 mixed (harmless flat).
  So the car sort works, people against people do not. Fix designed, NOT built: a z band per rig by
  ground depth, but the overlays sit at fixed z "over every rig part" (kill FX +30/+40, held weapon
  +60, KingAccents 40, the mag floor -61): each would have to ride its own rig's band. Written in
  PLAN as the tilt's biggest code risk (cost table).
- MILESTONE 290d3a1d (BUG FOUND): the mouse aim was NOT unprojected. PLAN it1 claimed it was free
  through the canvas transform, but `LiveInput._aim/_reach_m` read the screen offset from the
  screen centre. Under tilt 55 a cursor whose ground point lies 50.7 deg off aimed at 45 deg, reach
  18 % short north-south. Fixed via `ViewMode.ground_of` (y / sin p; exact identity flat). Unit
  1174/0 (`it7/unit2.log`). NOT checked live with a real mouse (unattended run): unit test only.
  NOTE: origin_px is the screen centre in arena and quest1 (camera on Rivet); under --boss-cam
  the camera leads, so the mouse aim origin is off Rivet in every view, top too (pre-existing).
- FILM (work order 6, first cut): `gtai-masters/n7/view/king_top_toplift_tilt_32ppm_it7.mp4`, 45 s
  (2700 frames each, seed 2, --boss-cam, code at 290d3a1d), top | top_lift | tilt, 3840x800
  unscaled (each panel 32 px/m), 0 SCRIPT ERROR each, crf 26 = 113 MB. Stills: t12s (procession)
  and `king_p2_top_vs_tilt_32ppm_x2_it7_t34s.png` (phase 2 court, x2 crop). LOOKED at t34: under
  tilt the stalled car reads as a car seen from a raised angle (side wall, round wheels with gold
  hubs, the raised gold cannon, King's crowned bust); top shows a plum and gold rectangle.
  frames.json: 3 new entries first, the 3 superseded it2/it4 items dropped (files deleted); 15.
  Raw .avi deleted. FRICTION: the panel labels sit over the boss bar (y=36); move them lower next.
- MILESTONE cf2b4a25: `top_lift15` study row (eye 15 m). LOOKED (`it7/toplift_25_vs_15_32.png`):
  the props and the car lean more (25/15 = 1.67x by construction), still a modest gain; the white
  parked sedans are flat in every view (VehicleView MultiMesh + the native crowd traffic: a stack
  needs a lifted body layer + wall slices in both paths; not started).
- PROBE top_lift (`it7/order_top_lift.log`): 212 pairs, 0 reversed, 212 mixed, 0 car pairs. NOT a
  measurement of top_lift's lean: the probe takes body height from `lift_px`, which is 0 for a
  straight-down view, so it reduces to the flat test. top_lift draw order = UNMEASURED.

NEXT (iteration 8):
1. (DONE it7) Director reel on 4c03d511 (switch off): 19/19 chapters fully down, 0 SCRIPT ERROR
   (`evidence/view/it7/director-reel.log`; the reel does not quit itself, timeout 900 s ends it).
   Gates it7 all green with the switch off: lint 13/13, unit 1174/0, scenarios 52/0, reel 19/19.
2. Depth sort under tilt (the measured 16 % reversed + 71 % mixed): try a z band per rig by
   ground depth relative to the camera centre (`PART_SPAN` 16, bands of about 0.3 m, clamped),
   tilt only; then lift every fixed overlay z over the rigs (held +60, kill FX 30/40, KingAccents
   40, mag floor -61) by the band of its own rig, or cap the bands under 30 z. Re-run
   `--order-probe` (target: reversed and mixed near 0), film before/after at 48.
3. Parked/traffic sedans as stacks under tilt (VehicleView: a lifted body layer + dark wall
   slices from the shadow silhouette; the native crowd traffic path too).
4. Re-encode the comparison clip with the labels below the boss bar; a 48 px/m close-up clip
   (Rivet vs King phase 3); the stills grid. The it7 clip is the current best comparison.
5. Freeze prep: the exe export (int-day recipe in docs/decisions.md) EARLY (it8 or it9), check that
   `RTAI.exe -- --boss=king --view=tilt` reaches the arena; evidence/run.mjs; REPORT with the PLAN
   cost table (draft at the end of docs/view-lab/PLAN.md).
- PROTOTYPE (reverted, not committed): naive depth band (`RigTilt.depth_z`: z = round(ground dy
  from the camera centre / 0.3 m) x 16, clamped to 12 bands; set in CutRig.drive under a tilt and
  added in KingCarStack.sort_rigs). Probe, same run (`it7/order_tilt_band_proto.log`): rig pairs
  304, reversed 48 -> 44, mixed 215 -> 157, but car reversed 2 -> 190 (the band outweighs the car's
  BEHIND_Z -64 and the car itself has no band). So for it8: the car needs its own band (or the rig
  bands are taken relative to the car), and the remaining mixed pairs (157) say most overlaps sit
  within 0.3 m of ground depth, or Rivet's rig (ArenaRigs) is not getting a band: check which
  pairs stay mixed before tuning BAND_M.

## Iteration 9 (04:55-05:55), BUILD
Iteration 8 left no journal entry and no commit (as iteration 6); this session worked it7's NEXT.
Rules applied: registry `measured-draw-order` (probe before and after the sort, not eyeballed);
`concept-scene-parity` (the hardest element, the King and his car, judged in the live arena path).
- MERGE 3625f68a: `n7-king` (b2e71b83) merged with an ordinary merge, because King's lane landed
  art that changes the comparison (KingCape cloth cape, KingCarTrim bumpers/throne/crest/cannon,
  gang chains, gold megaphone). Conflicts: JOURNAL.md (kept ours), king_body_view.gd (straight
  down calls KingCarTrim.cannon / KingCape.draw exactly as n7-king; under a tilt the King lane's
  cannon is drawn lifted BARREL_M, and the cape drapes via KingCape.draw's new `up` argument).
  PROOF switch off: `top` seed 2 32 px/m frames md5-identical with n7-king's two files swapped in
  (tick 900 b5ed2b94, tick 2040 c66f823d). LOOKED at tilt 48 px/m: the cloth cape on King's
  card, the lifted gold barrel, the gold trim. NOT DONE: the bumpers and the throne back are drawn
  in the roof plane (they float at roof height / lie flat on the cape under a tilt).
- EXE (freeze prep, early): `windows-showcase` exported on 3625f68a to build/export/windows/RTAI.exe
  (0 errors, build/export-it9.log). Smoke headless `RTAI.exe --headless --fixed-fps 60
  --quit-after 5400 -- --rigs --boss=king --bot=boss --seed=2 --bot-human --view=tilt`: King down
  tick 4933, 0 SCRIPT ERROR (the King lane's top smoke is also 4933: the view does not touch the
  sim). Re-export at the freeze.
- MILESTONE dd43e5e6: depth sort under tilt (`RigDepthSort`, tilt-only node on the actor layer,
  attached in ArenaRigs.attach). Levels by overlap far to near, z = depth_base + level x 32,
  2 levels max; Rivet's held weapon + magazine ride his level. FOUND: the 48 reversed pairs were
  ALL gang adds vs Rivet: KingCarStack.sort_rigs put any King rig north of the car's centre line
  (anywhere on the map) at BEHIND_Z -64. Now only inside `KingCarStack.far_box` (the car's
  screen footprint north of its centre, widened by a body, up past the roof), for every rig.
  Probe seed 2 60 s 32 px/m: reversed 48 -> 6, interleaved 215 -> 13, car reversed 2 -> 2
  (`evidence/view/it9/order_tilt_sort.log`). Unit 1181/1181 0 SCRIPT ERROR (+test_rig_depth_sort).
- MILESTONE 9c0a1215: the boss tell view drops under the behind-car band under a tilt
  (`RigDepthSort.ground_dz`). LOOKED (tick 2200, 48 px/m, crop x2): I first misread the downscaled
  before/after as a regression; at full size it is the opposite: before, the tell rectangles print
  over the gang's bodies; with the sort the bodies stand over the ground zones. The tell drop
  changes nothing in that frame. `top` md5 c66f823d (tick 2040) unchanged.
- FILM `gtai-masters/n7/view/king_top_toplift_tilt_32ppm_it9.mp4` (45 s, 3840x800 unscaled, seed 2,
  0 SCRIPT ERROR each, on the merged art; tilt with the depth sort; labels below the boss bar).
  LOOKED at 34 s (x2 crop `king_p2_top_vs_tilt_32ppm_x2_it9_t34s.png`): top = plum and gold
  rectangle with a disc crest, Rivet a disc; tilt = King's crowned bust on the throne-car with a
  side wall, round gold-hubbed wheels, raised cannon, Rivet's visor and collar. frames.json 14
  (4 new; the it7 + it5 clips and stills superseded, deleted). Raw .avi deleted.
- TIMING: films are fast tonight (45 s of 32 px/m in about 2 min each).
- MILESTONE a974482f: King's throne back (King lane it15) stands under a tilt (`KingCarStack.throne`:
  the arch stacked 0.9 m in 7 slices, crest on top; was a flat thin arc on the cape). LOOKED 48 px/m
  x2 (`evidence/view/it9/throne_stand_48_x2.png`): a standing gold back with volume, but it covers
  more cape and reads partly as a gold crescent. `top` md5 b5ed2b94 unchanged.
- FILM `gtai-masters/n7/view/king_p3_top_vs_tilt_48ppm_it9.mp4` (phase 3, 20 s, 48 px/m, top | tilt,
  0 SCRIPT ERROR, on 9530f55d). LOOKED at 8 s: tilt = King upright with crown, ermine, chains and the
  draped cloth cape, the slam ring an ellipse, Rivet's visor + collar; top = cape + crown on a disc.
  frames.json 15.
- NOT DONE this session: the gates after the merge beyond lint + unit (scenarios, director reel,
  evidence/run.mjs have NOT run on the merge); the bumpers still float at roof height under tilt.

NEXT (iteration 10):
1. GATES on HEAD with the switch off (the merge brought King-lane code): scenarios
   (`run_scenarios.gd`), the director reel (`--bot=reel --reel=director --loadout=pistol --rigs`,
   headless, 900 s timeout; it does not quit itself), `node tools/evidence/run.mjs`. Log to
   evidence/view/it10/.
2. REPORT.md draft now (freeze 08:30, report 08:40): the question, the frames (frames.json order),
   the cost table (docs/view-lab/PLAN.md draft) updated with: draw order MEASURED and FIXED for the
   arena (16 % -> 2 % reversed), aim unprojection (unit only, not a live mouse check), the merge.
   Calls for the owner: top vs top_lift vs tilt (default: tilt 55 + cards, the it9 clips), pitch
   (55 vs 65/45: one data value), cards per head variant (cost: one image round each).
   Exe lines: `build/export/windows/RTAI.exe -- --rigs --boss=king --view=<top|top_lift|tilt>`.
3. Bumpers at ~0.4 m under tilt (draw them in the stack, not in the roof plane), then re-film tilt.
4. If n7-king lands more King art before 07:30: merge again (ordinary merge), re-run the top swap
   md5 proof, re-film the it9 clip. Re-export the exe at the freeze and smoke --view=tilt.
5. Weakest items to raise: top_lift (still a modest gain: cast shadows by height not built);
   the city's parked sedans flat under tilt.
