# JOURNAL - n8 lane `vehicles` (branch n8-vehicles)

## Iteration 1 (2026-11-06 20:26 - 21:26), BUILD

Read: AGENTS.md, the vehicle feature (vehicle_view.gd, README), KingCarStack / KingCarWalls (the
throne-car slice stack), ViewMode + view.json (tilt70 art p70; combo art p70 -> boss_art p55 at
swap_deg 62.5), crowd_layers.gd (the sim traffic draws on the crowd's car MultiMesh), the library
catalog (vehicle class) and the keyed sheets. Other lanes' journals at 20:35: only street had one
(no REQUEST to vehicles).

Library state, vehicle class (best non-C per id): 70: van A, delivery_truck A, depot_van A, bus A,
sedan B, police_car B, parked_pickup B, taxi B, ambulance B. 55: all B (sedan, police_car, van,
delivery_truck, depot_van, parked_pickup, taxi, ambulance, bus). Bike: C everywhere (brief: build
it ourselves, no REQUEST). Every vehicle has a 70 twin already, so no 70 REQUEST is needed.

Registry rules applied (sprite-and-atlas-production, depth-ordered-layered-art): one atlas per
pitch, a fixed cell with the pivot (ground centre) at the cell centre so every view and its mirror
share one anchor; scale fixed per vehicle from one reference measure (the side view = the
collision footprint length) not per view; per-view bbox centre dropped by half the lifted body
height = the ground centre (a box projects centrally symmetric about its centroid).

DECISION (also docs/decisions.md): rotation set (5 drawn + 3 mirrored, card turned by the rest
<= 22.5 deg) over a slice stack. Why: the painted views keep wheels/glass/doors/lamps at the right
pitch and it is one MultiMesh instance per car. Cross-fade at the boundaries = VehicleCards.BLEND_DEG
(0 now). To measure against a slice stack on the sedan in the next iteration (the brief's call).

MILESTONE 21:05: `tools/art/vehicle_cards.py` cuts art/p70 + art/p55 `traffic_cards.png` (rows =
sim car art id 0-8: sedan x3 + grey sedan by value gain, taxi, van, pickup, ambulance, police;
cols = the 5 views, 64 px/m, 448 px cells). `VehicleCards` (MultiMesh + cell shader, mirror by UV
flip) draws every service car and every sim traffic car under a tilt with art for the pitch;
VehicleView hides the flat body layers (ours + the crowd's) only then, the ground shadows stay.
Frames (scratch, the vehicle_frame showcase, `--view=tilt70`): the parked sedan, the driven sedan
and moving traffic draw as cards.

FRICTION: `tools/godot/check.mjs` on a script that reaches ViewMode fails ("Identifier not found:
Log", the -s run has no autoloads); the real run is fine. The vehicle_frame showcase did not know
`--view=` (added, +2 dev lines, debt baseline accepted with a reason).

Known gaps (seen in the frames):
- the kerb-parked cars (ambulance, police, van, wreck) are the city floor's parked props, still
  flat top-down: find who draws them (city lane's floor?) and REQUEST or hook.
- the vehicle_frame showcase camera does not tilt the ground (the city reads top-down there):
  judge on `--arena=city --view=tilt70` instead.
- depth: the cards sit in the vehicles band over every person; a person in front of (south of) a
  car must draw over it.
- damage states (d1/d2/hijack teal) draw the intact card; wrecks only darkened.
- no 360 turn film yet; no look-shader print on the cards (the art carries its own ink + grain).

NEXT: (1) film a 360 turn at 32 and 64 px/m (a dev scene turning one sedan in place, tilt70) and
judge the swap pop; try BLEND_DEG 8; (2) slice-stack sedan prototype for the measured comparison;
(3) parked props in the floor; (4) depth vs people; (5) police/van/truck/depot/pickup checks
(delivery_truck + depot_van are not in the traffic art ids: where do they appear?); (6) damage at
height; (7) --arena=city and reel at tilt70 + combo, before/after stills to gtai-masters/n8/vehicles.

MILESTONE 21:15: `--arena=city --view=tilt70 --seed=7`, 300 frames, 0 SCRIPT ERROR: moving traffic
(an ambulance crossing) draws as the 70 card at full painted detail (scratch:
gtai-n8/scratch/vehicles/city/f00000298.png; not evidence yet, no before/after pair). Note: the
ambulance's amber light bar reads; check the catalog's "small red in the rear lamp clusters" fault
on its tail view (colour law) before calling it done; key that out in vehicle_cards.py if seen.
Gates this iteration: lint 15/15, unit test_vehicle_cards + test_vehicle_view 8/0. NOT yet run:
the full unit run, scenarios, evidence (next iteration, before calling item 1 done).

NEXT (iteration 2, in order): full unit + scenarios (top must stay bit-identical: cards only
under a tilt with art); the 360 turn dev scene (sedan in place, tilt70, 32 + 64 px/m, BLEND_DEG
0 vs 8) -> gtai-masters/n8/vehicles; before/after pair at tilt70 32 px/m (git worktree of main or
`--view=tilt70` before = main exe); the kerb-parked floor cars; depth vs people; ambulance tail red.

21:22 gate: `run_unit.mjs --fast` 1471/1471 passing, 0 SCRIPT ERROR (96 s). The full no-arg run,
scenarios and evidence are still owed (iteration 2, first thing).

## Iteration 2 (2026-11-06 20:45 - 21:45), BUILD

Read: JOURNAL, git log, the other lanes' journals (no REQUEST to vehicles; view's card-set
registration is for head/bust cards, not needed for the car atlas), the library catalog notes for
sedan/police_car/van 70 and the library JOURNAL tail.

20:47 gate: the full no-arg unit run 1487/1487 passing, 0 failed (89 s).

MILESTONE 20:50 item 1 (the 360 turn): `dev/showcase/vehicle_turn.tscn` turns the sedan, the police
car and the van in place over their collision footprints, one circle per 6 s (`--view=`, `--ppm=`,
`--blend=`, `--upright=`). Filmed at 32 and 64 px/m: gtai-masters/n8/vehicles/turn360_tilt70_{32,64}ppm.mp4.
Measured (contact sheets in the same folder):
- hard swap vs a 10 deg cross-fade: the fade ghosts two cars at 64 px/m. Hard swap kept.
- rigid turn vs an upright (yaw-shear) turn (`VehicleCards.upright_k`, new, default 0): upright keeps
  the wheels vertical (no roll at +-22 deg) but the three-quarter views stop tracking the heading
  (drawn ~40 deg on a 23 deg footprint), which misleads at speed (top-down-vehicle-handling-model:
  the player reads heading from the body's long axis). Rigid kept. DECISION in docs/decisions.md.
- the remaining pop is the art's 45 deg step plus the sedan/police side view drawn ~15 deg shallower
  than their other views (catalog B notes); at 32 px/m it reads as a small snap, at 64 a clear one.

MILESTONE 21:03 city before/after: `--arena=city --view=tilt70 --seed=7` 600 frames at 32 and 64 px/m,
before = this branch with art/p70/traffic_cards.png(+.import) moved aside (= main's flat car layer),
restored after (git status clean on the art). 0 SCRIPT ERROR in all four runs. Evidence:
city_tilt70_{32,64}ppm_ba_f500.png, city_tilt70_32ppm_ba_f300.png, city_tilt70_32ppm_before_after.mp4,
city_tilt70_64ppm_after.mp4, frames.json (9 entries). Looked at every still: the traffic sedan gains
body, glass and wheels at the footprint's length; amber lamps, no red.

Rules applied: sprite-and-atlas-production (one atlas per pitch, one anchor per cell, view + mirror
share it), depth-ordered-layered-art (cards in the vehicles band; people-in-front still owed),
motion-quality-gating + concept-scene-parity (judged in motion on the real city scene, same seed
before/after), generative-artifact-gating (B sheets used with the named fault logged + REQUEST),
top-down-vehicle-handling-model (heading must read from the long axis: why rigid over upright).

REQUEST to assets: sedan, 70, the side view (rotation 3) redrawn at the sheet's own steep camera
(~70-75 deg, the roof the largest plane, as van_70 A) - the catalog's B fix for sedan_70; the same
for police_car, 70. Why: the 360 turn snaps hardest at the side<->three-quarter swap because the
side view is ~15 deg shallower.
REQUEST to assets: sedan, police_car, van, 70, the four in-between rotations (nose at 22.5, 67.5,
112.5, 157.5 deg from nose-right, i.e. between each pair of the five drawn views), same camera,
same scale, one row. Why: 45 deg steps snap visibly at 64 px/m when a car turns; 22.5 deg halves
the snap (16 views with mirrors). Lower priority than the side-view redo.

FRICTION: `--arena=city` and `--ppm=` print "boot: unknown launch arg (ignored)" but the arena reads
them itself (ArenaArgs); harmless. Godot's movie writer keeps the "." in a name like u0.5_f.png.

MILESTONE 21:18 colour law: the atlases carried red-orange tail lenses (r > 1.8 g and 1.8 b): 2739 px
at p70, 4819 at p55, in the tail / three-quarter-away views of taxi, van, pickup, ambulance, police
(the ambulance looked amber at a glance; the numbers did not). `vehicle_cards.py` amber() turns them
amber keeping value; both atlases re-cut: 0 such px. Evidence pickup_tail_lamps_amber_ba.png.
