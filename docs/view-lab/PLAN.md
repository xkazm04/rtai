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
  the same canvas transform, so `get_global_mouse_position()` already lands on the ground plane.
  CORRECTION it7: the live aim (`LiveInput._aim`, `_reach_m`) reads the SCREEN offset from Rivet
  to the cursor, not the canvas one, so under a tilt it aimed and threw short off the ground by
  sin(p) in y (at 55: a cursor whose ground point lies 50.7 deg down-right aimed at 45 deg, 5.7 deg off;
  the reach north-south 18 % short).
  Fixed: `ViewMode.ground_of` divides the screen y by sin(p) (exact identity straight down).
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

MEASURED it7 (`dev/view/draw_order_probe.gd`, arena `--order-probe`, seed 2 King fight, 60 s at
32 px/m, a sample every 6 ticks; logs `evidence/view/it7/order_*.log`):

| View | Overlapping rig pairs | Reversed | Mixed (parts interleave) | Rig-vs-car pairs | Car reversed |
|---|---|---|---|---|---|
| top | 212 | 0 | 212 (harmless: no depth straight down) | 0 | 0 |
| tilt (55) | 304 | 48 (16 %) | 215 (71 %) | 391 | 2 (0.5 %) |

The car is sorted (KingCarStack.sort_rigs). Rig against rig is not: every actor rig draws at the
same z with its parts at their own offsets (0 to about 12), so two overlapping people interleave
part by part (a far thug's head over a near one's torso), and Rivet (ArenaRigs) against the gang
(KingRigs) falls to tree order. The fix is a z band per rig by ground depth (band height under the
body's screen height, PART_SPAN 16 z per band); it collides with the fixed z offsets laid over the
rigs (the held weapon at rigs + 60, KingAccents OVER_RIG_Z, the cards), which must ride the band
of their rig. That is the biggest code risk of the tilt: every overlay that sits "over the rigs"
today must become "over its own rig".

FIXED it9 (dd43e5e6 + 9c0a1215, `RigDepthSort`): per frame, far to near, each rig gets a depth
level (0 if it overlaps no farther body, else one over the highest farther body it overlaps), z =
base + level x 32, 2 levels max (the actors band is 100 wide). Rivet's held weapon and magazine
ride his level; the boss tell drops under the behind-car band. The it7 "16 % reversed" turned out
to be one bug: King's rigs north of the car's centre line ANYWHERE took the behind-car z; that rule
now holds only in the car's screen box (`KingCarStack.far_box`), for every rig. Same probe run:

| View | Overlapping rig pairs | Reversed | Mixed | Rig-vs-car pairs | Car reversed |
|---|---|---|---|---|---|
| tilt (55), it9 | 304 | 6 (2 %) | 13 (4 %) | 391 | 2 (0.5 %) |

Still owed if a tilt ships: KingAccents (chains, crown accents) at one fixed z over all King rigs;
the ghost and kill overlays at fixed z; the city's baked crowd is not in the sort; 3+ bodies deep
share the top level.

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

## Measured so far (iteration 5)

Facing cards, one per head (5 drawn facings in one image, 3 mirrored in code):

| Card | Image rounds | Generation | Fit work | Notes |
|---|---|---|---|---|
| Rivet head + collar (logo ref) | 1 | 61 s | pre-printed `--tan` | it4 |
| King bust (boss target ref) | 1 | 60 s | pre-printed `--snap` | it4; flat crown/ermine accents stand down |
| Gang head (one card, every thug) | 1 | 78 s | mirrored + frames reordered, `--snap` | it5 |
| Patrol cop head (cast target ref) | 1 | 56 s | unsnapped, prints through the part shader's cop blue | it5 |

Every round came back usable on the first try (4 of 4). The cast still without cards: riot
helmet, SWAT, the 6 ped heads, the robot thug, the other bosses = about 10 more rounds for the
current roster, one per head variant (`RigHeadCard.key_of`: art_dir/head first).

`top_lift` costs no art: a perspective eye (`eye_h_m`) reuses the 2.5D lifts radially. At 25 m and
32 px/m the gain is small (the car leans about 0.4 m at 7 m off-centre).

## Cost table draft (iteration 7, updated it12, for REPORT)

| | `top` (shipped) | `top_lift` (90, perspective eye 25 m, cast shadows) | `tilt` (55 + facing cards + cast shadows) | three-quarter per facing (not built) |
|---|---|---|---|---|
| Art per character | 0 | 0 | 1 card strip per head variant: 1 image round (56-78 s), 5 of 5 usable first try; still owed: SWAT, 6 ped heads, robot thug, other bosses (about 10 rounds) | every part x 8 facings x every clip: a redraw of the cast |
| Art per vehicle | 0 | 0 (the stack leans; cast shadow swept from code) | sprite stack from code (King's car: 18 slices, round wheels, raised cannon: 0 art); parked sedans still flat | per-facing sprites |
| Art per building / prop | 0 | 0 | south faces in code (arena props, city barriers); city buildings not done | per-facing |
| Aim | ok | ok (uniform zoom) | fixed it7 (`ground_of`), unit-tested, not mouse-tested live | same as tilt |
| Draw order | n/a | small (heights lean outward; unmeasured: the probe reads no lean straight down) | MEASURED + FIXED in the arena (it9): reversed 16 % -> 2 %, interleaved 71 % -> 4 %, car 0.5 %; owed: King accents, ghost/kill overlays, the city's baked crowd | same, harder |
| Occlusion | n/a | n/a | BUILT it15 for the arena's station props (`PropOcclusion`: the prop redrawn over a body behind it, an ink silhouette with a cream rim, a body in front lifted over it; 0 art). MEASURED: 176 body-frames in 60 s on the city block, 8 in 90 s of the King fight. Owed: the city chunks' own props and buildings (still flat under tilt), the baked crowd (not rigs) | same, more often (taller lift) |
| Streaming bubble | 1.0 | 1.0 | 0 extra chunks (it12, computed from code): residency is sim-driven, R_SIM 190 m around the focus; visible ground at 32 px/m grows 60 x 33.75 m -> 60 x 41.2 m (1/sin 55 = 1.22x) plus a 40 m roof's lift from south of the screen (cot 55 x 40 = 28 m), all inside 190 m. draw cost MEASURED it18 (bench lock, CONTENDED, exported bench, city drive_dense 32 px/m, 2 passes): avg frame 0.87 -> 1.00 ms (+15 %), draw calls 370 -> 573 (+55 %), visible actors 23.3 -> 28.6 (+22 %), 0 chunk failures (`evidence/view/it18/bench/`) | 0 chunks; 1.41x ground at 45 |
| Cast shadows (it12) | none | 0 art: a figure per body, the car and props swept (`RigCastShadows`); city sedans, buildings' own and the baked crowd not yet | same code, foreshortened on the ground; `tilt_noshadow` = without |  |
| What breaks if shipped today | nothing | nothing visible (city sedans and the baked crowd cast no figure shadow) | interleaved people in crowds, overlays over the wrong rig, flat city buildings (no occlusion there yet), uncarded heads read top-down | everything until redrawn |
