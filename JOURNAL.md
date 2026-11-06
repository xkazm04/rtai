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
