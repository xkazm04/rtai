# View lab: Rivet and the King from another angle (2D / 2.5D, no 3D runtime)

Lane `n7x-view`, night 2026-11-06. An experiment behind `--view=<id>`; the default `top` is the
owner's 90-degree orthographic camera (pitch.md) and stays bit-identical.

## The gap (looked at: `gtai-masters/n7/king/king_target_vs_game_32ppm_it10.png`)

The target is drawn from a raised three-quarter angle: King's face, crown and chest chains, the
limousine's grille, wheels and cannon, the gang's shades, Rivet's whole body. The game at 90 degrees
shows roofs and discs: the car a plum rectangle, King a crown on a disc, the gang thin grey limbs,
Rivet a cream ring. Most of the gap is the angle (no vertical faces exist on screen), the rest is
the drawing. The logo (Rivet's head at three-quarter, visor face) is never seen in today's game.

## Projection (one transform, everything inherits it)

screen = (x, y sin(p) - z cos(p)) for pitch p above the ground (90 = straight down).

- **Ground (y sin p):** the camera's zoom is `Vector2(z, z sin p)` (`ViewMode.zoom_of`), so the floor,
  decals, FX, lights and world markers foreshorten with no per-system work. The mouse goes through
  the same canvas transform, so `get_global_mouse_position()` already lands on the ground plane:
  aim unprojection is free while the aim target is on the ground.
- **Height (- z cos p):** a node at height z draws `ViewMode.lift_px(z)` up the screen (pre-zoom it
  is z cos p / sin p). Only things with height need code: the rig joints, the car's stack, walls.
- **Top / top_lift:** pitch 90, no transform at all (`is_flat()`); `top_lift` adds height cues only.

Pitch stills at 75 / 65 / 55 (`evidence/view/it2/grid_t900.png`): the ground alone changes almost
nothing (sin 65 = 0.91, a 9 % squash). The impression has to come from heights, so heights are
the work, not the camera.

## Cost per class under a tilt (how each keeps rotation free)

| Class | Technique | Facings | Art cost per item |
|---|---|---|---|
| Cutout characters (CutRig) | **2.5D cutout**: every joint lifted by its height. RigGait already solves legs as a 3D chain (hip_z, ik3 knee, foot lift), so legs stand up for free; body at hip height, torso and head above (`RigTilt`) | none (free rotation kept) | 0 new art; parts read foreshortened |
| Faces / chests | **Upright cards**: head (visor) and chest front drawn as billboards in 5 facings + 3 mirrored, picked by facing relative to the camera | 8 (5 drawn) | 2 cards x 5 facings per character, about 2 image rounds |
| Full redesign per facing | drawn character per facing x every clip | 8 x clips | prohibitive for the cast (sprite registry: cost the roster, not the best clip) |
| Vehicles (King's limo first) | **Sprite stack**: N horizontal slices, each lifted by its height; rotates freely at any pitch. Slices from code (box sections) or a Blender model rendered to PNG slices | none | one slice sheet per model (8-16 slices) |
| Buildings / props | south faces extruded at height, roofs lifted; actors behind a tall face get an ink silhouette | n/a | wall-face texture per material |
| Ground decals | inherit the ground transform | n/a | 0 |
| FX | muzzle / tracers at gun height (lift), shadows on the ground | n/a | code only |

## Draw order

Under a tilt, things nearer the camera (larger ground y) must draw over farther ones: sort actors
by ground y (`y_sort` on the actor canvas or z by ground y). Measured, not eyeballed (registry
`measured-draw-order`): count pairs of overlapping actor bounding boxes drawn in the wrong order
per frame over a seeded fight.

## Ranking (iteration 2, before the art round)

1. `tilt` at about 65 degrees with 2.5D rigs + upright head/chest cards + a stacked car: the main bet.
2. `top_lift`: cheapest, tells the owner what heights buy with no angle change.
3. A per-facing three-quarter redesign: shown as cost only (a labelled concept frame at most).

## Registry rules applied

- `concept-scene-parity` / `toolkit-fit-slice-before-the-look-is-chosen`: Rivet's rig and the King's
  car are built first under the tilt, before any backdrop or building work.
- `depth-ordered-layered-art` / `measured-draw-order`: the sort is derived from ground depth and the
  failures are counted per frame.
- `sprite-and-atlas-production` ("a character route is costed by its roster"): the 2.5D cutout keeps
  one art set per character; facings are bought only for two cards (head, chest).
