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
