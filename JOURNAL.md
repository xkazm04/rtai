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

MILESTONE 21:20 the kerb-parked cars, my side: `VehicleParked` (features/vehicles/vehicle_parked.gd)
is a per-chunk registry of the city's parked-car props (city_textures class "vehicle": 44-46 sedans,
47 taxi, 48 van, 49 pickup, 50 wreck = sedan card tinted, 52 ambulance, 53 police; 51 bus -> -1,
keeps its flat prop); VehicleView draws every registered car within 60 m of the player as a card.
VehicleCards.CAP 160 -> 256. Test test_vehicle_parked.gd (2), vehicle tests 11/0. Nothing registers
until the city view calls it, so nothing changes in any view yet.

REQUEST to city: hand the kerb-parked cars to VehicleParked under a tilt (merge n8-vehicles or
cherry-pick the VehicleParked commit). In `features/city/view/chunk_view.gd`:
  - `_slice()`: when `VehicleParked.carded()` and `VehicleParked.row(t) >= 0` and the command is NOT
    a shadow, skip the texture rect and append `Vector4(pos.x, pos.y, chunk.xf[o + 2], t)` to a
    per-chunk PackedVector4Array; when the chunk finishes (`activated += 1`) call
    `VehicleParked.park(_active, cars)` (a budgeted slice resumes: keep the array per _active).
  - `_release(key)`: `VehicleParked.unpark(key)`. `dispose()`: `VehicleParked.clear()`.
  The ground shadow commands keep drawing (the parked car's shadow). In `top` carded() is false:
  nothing changes (bit-identical). If you would rather I make the edit, say so in your JOURNAL and
  I will send it as a patch file you apply.

21:17 gate: scenarios 52 ran, 1 failed: scenario_rig_stress "200 people: rig p50 1.024 ms > 1.000 ms"
(wall clock, while my unit run and the other lanes loaded the machine; rigs are not this lane's
code). Re-run alone via `node tools/tests/run_scenarios.mjs --only=scenario_rig_stress
--quiet-wait=3`: 1 passed. The rest incl. the replay and vehicle drive ("replay": "identical") pass.
`top` bit-identity: by construction (VehicleView._draw_cards returns before touching any layer when
VehicleCards.atlas() is null, which it is in `top`), and the scenario goldens pass; a framemd5 of the
city block against main is still owed.

21:30 gate: director reel (`res://dev/arena/arena.tscn -- --bot=reel --reel=director --loadout=pistol
--rigs --view=<v>`, headless, --quit-after 14000) in `tilt70` and `top`: 19/19 chapters, every one
all down, 0 SCRIPT ERROR in both (run on bd11dd62; 1f34babb only lifts a wreck's fire under cards).
MILESTONE 21:29 item 3 started: VehicleFire.hood_lift() puts a wreck's fire on the bonnet (HOOD_H_M
1.0) when the cars draw as cards; ZERO otherwise (test). Not yet filmed.

NEXT (iteration 3, in order):
1. Film the fire on a card wreck (a dev scene or the vehicle drive with a wreck) at tilt70 32 + 64;
   then the damage states (d1/d2 draw the intact card today: darken/scuff the card by state, or
   cut damage cells) and skids (VehicleSkids on the ground: check they stay at the ground under the
   card, not the lifted body).
2. Depth vs people: a person south of a car must draw over the card. Plan: split VehicleCards into
   two MultiMeshes, `under` (z just below the actors band) for cars whose ground front edge is north
   of a nearby person's feet and overlapping on screen, `over` (today's band) for the rest; start with
   Rivet + the rigs near the camera (RigDepthSort is view's: REQUEST if a hook is needed).
3. Read n8-city's JOURNAL for the answer to the VehicleParked REQUEST; film the kerb rows when hooked.
4. Police light bar flash on the card (blue/amber lenses) for the police chase; the driven car /
   hijack at tilt70 (item 4); `--view=combo` boss fight check (King) with the p55 set.
5. A framemd5 of the city block in `top` against main (bit-identity, measured not argued).
6. Traffic density cost: bench under the bench lock (gtai-n5/bench.lock), tilt70 vs top.
7. Bike: no sheet (catalog C x4). Build from the three-quarter views mirrored or a side-view slice
   stack; it is not in the sim's car art ids yet, so find where a bike appears first.

## Iteration 3 (2026-11-06 21:36 - 22:36), BUILD

Read: JOURNAL, git log, n8-city/n8-view journals. City answered the VehicleParked REQUEST in kind
("tell me the function you want to own"): my iteration-2 REQUEST already names it
(`VehicleParked.park/unpark/clear/row/carded`); no new answer from city since. No REQUEST to vehicles.

MILESTONE 21:58 item 3 (damage at height): the cards wear their damage (commit 83ec4edf).
`VehicleCards.wear(state, id)` -> custom.z; the card shader paints in the card's own space:
D1 = ink dents at the nose end of the body (the drawn view's nose direction per column, mirrored
views flipped) + pale scratches along the body; D2 = deeper, spread over the body, paint dulled;
WRECK = burnt (desaturated, 0.56 value, soot) with dim amber embers, outline kept (0.42 lost the
form at 64 px/m: measured, raised). A per-car seed (id % 64) so two damaged cars differ. The sim
traffic marked D1 by VehicleTraffic now wears it too; the kerb wreck prop (id 50) wears WRECK.
Before this, every damage state drew the intact card.
MILESTONE 21:58 the cards draw north to south (`back_to_front`, ties in put order): before, the
put order (service cars, then traffic, then parked) decided who covered whom.
MILESTONE 21:59 the fire stands up: on a card the top-down burst draws 0.7 x 1.4 with its foot on
the bonnet (`VehicleFire.STAND`); `top` keeps the old centred square (same float ops).
Skids: VehicleSkids stays on the ground layer under the cards (checked on film: the drifting
police car's marks lie on the asphalt under the body, not lifted).
Evidence (gtai-masters/n8/vehicles, frames.json now 12): damage_tilt70_{32,64}ppm_before_after.mp4,
damage_tilt70_{32,64}ppm_ba_f{150,500}.png. Film scene: `dev/showcase/vehicle_states.tscn`
(`--wear=0` = the before). Looked at every still.

MILESTONE 22:05 depth vs people (c4e756df): the vehicles band (z 200) sits OVER the actors (100),
so a card painted over anyone standing just south of it (nearer the camera). `VehicleFront` buckets
the bubble's living people (people_near 48 m) + Rivet on foot on a 4 m grid; a card with a body
inside its front box (south by < 3.2 m, across < 2.6 m) goes to VehicleCards' `under` layer at
actors - 1 (a VehicleView child, as the crowd layers are). A body behind a car stays covered
(right). Both: the front body wins. Unit test. NOT FILMED: the yield scene's before/after differs
all over the frame (traffic timing), so it shows nothing clean; `--arena=city --rigs` gave the
hub (no traffic) - film owed: a dev scene with a rig walking past a parked card.

DECISION vehicles: damage on the cards is a shader wear on the one rotation art (not cut damage
cells): the library has no damaged vehicle sheets, and a wear keeps 55 and 70 consistent; cut
cells are a REQUEST away (wear level 0 = intact = the hook).
DECISION vehicles: a card with someone in front drops under the actors as a whole (two layers),
not a per-pair interleave with RigDepthSort (view's code); the rare front-and-behind case favours
the nearer body.

Rules applied: depth-ordered-layered-art (back-to-front by ground y; the under/over split by who is
in front), motion-quality-gating (judged the wear in motion through every view at 32 and 64),
generative-artifact-gating (no new AI art; the wear is procedural), sprite-and-atlas-production
(one atlas, the wear in the shader not new cells), top-down-vehicle-handling-model (dents at the
nose: the crash reads where it happened).

Gates: full unit 1494/0, 0 SCRIPT ERROR (22:03, on the depth commit's tree); lint 15/15 (hook, each
commit).

REQUEST to assets: fx_fire, 70 (and 55): a standing flame loop seen at the pitch (4 frames, a
flame rising from a car bonnet, + 2 smoke puff cells), same 2.5 m cells as features/fx/art/fx_fire.png
(4 x 2). Why: today's fire is the top-down burst stretched 0.7 x 1.4; it reads as fire at 32 px/m
but as a splash at 64.

22:10 gate: scenarios 52 ran, 0 failed (city replay, replay_60s, quest1, vehicle drive: identical).
22:16 the city at tilt70 64 px/m (main scene `-- --arena=city --view=tilt70 --seed=7 --ppm=64`,
600 frames, 0 SCRIPT ERROR): still city_tilt70_64ppm_it3_f300.png (frames.json 13).
FRICTION: `res://dev/arena/arena.tscn -- --arena=city` opens the arena HUB (no traffic): the city
block with traffic is the MAIN scene with `-- --arena=city` (boot warns "unknown launch arg", but
the arena reads it). Lost one 600-frame run to it twice.

NEXT (iteration 4, in order):
1. Director reel 19/19 in top and tilt70 on this head (headless, as iteration 2) - owed.
2. The depth film: a dev scene with a rig (or the crowd) walking north past a parked card, before
   (`--no-front` / VehicleFront.off) vs after, tilt70 at 32 + 64 px/m.
3. City REQUEST follow-up (VehicleParked hook) - read n8-city JOURNAL; film the kerb rows.
4. Police light bar flash on the card (blue/amber, the lens cells only) for the chase.
5. The driven car + hijack at tilt70 (vehicle_frame default scene), and `--view=combo` boss check.
6. A framemd5 of the city block in `top` vs main (bit identity, measured).
7. Traffic density cost under bench.lock (tilt70 vs top). 8. Bike.
