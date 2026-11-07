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

22:20 gate: director reel on fbead9ab, `res://dev/arena/arena.tscn -- --bot=reel --reel=director
--loadout=pistol --rigs --view=<v>` headless: tilt70 19/19 chapters all down, 0 SCRIPT ERROR;
top 19/19 all down, 0 SCRIPT ERROR (logs evidence/n8-vehicles/director-reel-it3-*.log). NEXT item 1 done.
FRICTION: headless without `--fixed-fps 60`, `--quit-after 14000` counts frames, and frames outran
the 60 Hz ticks on the first top run (it quit at tick ~6000, chapter 17 of 19, looking like a
short reel). Use `--fixed-fps 60 --quit-after 7600`: one frame = one tick.

## Iteration 4 (2026-11-06 22:22 - 23:22), BUILD

Read: JOURNAL, git log, the other lanes' journals. city REQUEST to vehicles (n8-city JOURNAL ~171):
`VehicleParked.live` so ChunkLift hands kerb cars over only when a VehicleView draws them.
MILESTONE 22:30 answered (ee045433): `static var live` (true from VehicleView.setup, false on its
_exit_tree) + `static func drawn() -> bool` (live and carded()). ANSWER to city: AND `drawn()` in at
ORDER time (ChunkLift.order), not in `_setup`: ChunkLift is made inside CityView.setup, which runs
before CityVehicleWorld.make_view, so `live` is still false at `_setup`. Merge n8-vehicles at ee045433+.

MILESTONE 22:41 the depth film (NEXT 2, scene 35660255): `vehicle_frame --scene=depth` walks Rivet
(the city focus, axis 16 = 3.1 m/s) in loops round the parked sedan card, behind and in front;
`--no-front` = the before. Evidence: depth_tilt70_48ppm_ba_still.png + _before_after.mp4 (48, the
`--car-zoom` camera), depth_tilt70_32ppm_ba_still.png + mp4. Judged: before, the card's wheels and
sill cut through Rivet's head when he stands south of the car; after, he draws whole over it;
behind the car both agree (the card covers his feet). FRICTION: windowed `--clip` frames are
named tick>>1 and the 32 after-run caught odd ticks (clip-0003...): the 32 mp4 pairs by index (one
capture apart), the 48 pair is exact. No 64 px/m camera in vehicle_frame (on_foot 32, car 48).
MILESTONE 22:40 police light bar (NEXT 4, 6e497349): `VehicleCards.duty(art, speed)` adds SIREN
(bit 256 of the wear) to a police card moving > 1 m/s (sim police and service cruisers; kerb-
parked ones stay dark). The shader finds the lenses by colour in the bar band (cell top 45 %:
the amber tail lamps sit below, measured per cell on both atlases) and lights blue then amber at
2.2 Hz with a per-car phase; the lit lens spills a glow (16 taps on two rings). FRICTION: the
first amber test (r > .75, .4 < g < .75) never matched in the shader though it matched the PNG in
Python (cause not found; a hue test r > g + .2, b < .35 r works): judge shader colour tests on
film, never on the PNG alone. The first glow added light onto the cream roof (invisible): it now
mixes toward the hue and puts a halo in the air. Evidence: siren_tilt70_64ppm_before_amber_blue.png,
siren_tilt70_{32,64}ppm_before_after.mp4, siren_tilt70_32ppm_amber_blue.png.
DECISION vehicles: the light bar flashes on every moving police card, not only while wanted: the
sim has no per-car pursuit flag the view can read, and lights.json already gives every police car a
siren light at night. One value away: `VehicleCards.DUTY_SPEED` (raise it to silence patrols) or
gate `duty()` on a wanted level once Events carries one to the view.
Rules applied: depth-ordered-layered-art (the depth film judges the under/over split in motion),
motion-quality-gating (flash judged on film at 32 and 64), generative-artifact-gating (no new AI
art: the flash is a shader on the library cells), sprite-and-atlas-production (lens mask derived
from the cell, not a new atlas), top-down-vehicle-handling-model (a cop reads as a cop at speed).

22:52 GATE full unit on 6e497349: 1490 passed, 6 FAILED (test_vehicle_view x4, test_vehicle_cards,
test_vehicle_parked: "Unexpected Errors"): the glow passed the built-in TEXTURE to a shader function
(`ERROR: !actions.custom_samplers.has(tex_builtin)` headless). The d3d12 film hid it. FIXED 34018b19
(the taps inline in fragment()); the three files 17/0, picture re-filmed unchanged (mean diff ~1).
FRICTION: always run the vehicle unit tests after a shader edit, not just film it.
22:56 GATE `top` bit-identity (NEXT 6): main scene `--arena=city --bot=rivet --seed=2 --rigs`,
`--fixed-fps 60 --write-movie --quit-after 301`, framemd5 HEAD 34018b19 vs the merge base 0bea8b93
(a throwaway detached worktree under scratch, removed after; native DLLs copied in): IDENTICAL,
301 video + 301 audio frames, 0 SCRIPT ERROR each.
22:50 the driven car at tilt70 (NEXT 5, vehicle_frame route + carnage, 0 SCRIPT ERROR): the driven
sedan and the hijacked taxi are the same cards as traffic; the route's handbrake slide ends in a
kerb crash and a burning wreck with the standing flame on the bonnet (the route was laid for an
older start point). The hijack (driver thrown, Rivet in) reads; Rivet's side stays his frozen rig.
The kerb-parked cars in that frame are still FLAT props (city's hand-off is off by default until
it ANDs VehicleParked.drawn()): a top-down police car beside the cards reads wrong - city owns it.
22:58 GATE full unit on 34018b19: 1496 passed, 0 failed (the six vehicle failures fixed).
Not done this iteration: `--view=combo` boss check (no vehicle of mine is in a boss arena; the cards
are keyed by ViewMode.art so the 70 -> 55 swap is the same path as the atlas pick: not filmed),
traffic density cost under bench.lock (bench ~14 min, the machine was busy with my own gates).
23:03 GATE scenarios on 34018b19: 52 ran, 0 failed, 0 SCRIPT ERROR (exit 0).
Evidence json: evidence/n8-vehicles/iteration4.json. masters frames.json: 15 entries (depth 48 still +
clip, the siren still in the top five).

NEXT (iteration 5, in order):
1. Read director-reel-it4-tilt70.log (started 23:04 on 34018b19): want 19/19 down, 0 SCRIPT ERROR;
   run `top` too if time (`--fixed-fps 60 --quit-after 7600`).
2. Traffic density cost under bench.lock: tilt70 vs top on the city drive. tools/bench/run.mjs has
   no --view; cheapest honest probe = a `last_us` around VehicleView._draw_cards + the world's
   add_frame_probe (boot/world.gd, shared: check owner) or a dev scene timing cards.put/finish for
   N = 32/64/128 cars. Label CONTENDED without the lock.
3. If city merged ee045433 and ANDs drawn(): film the kerb rows as cards (main city, tilt70, 32/64).
4. The bike (no sheet, catalog C x4): find where a bike appears first in the sim art ids.
5. Light bar at 55 (`--view=tilt`): the p55 lens band check measured (all lenses y < 0.37) but
   not filmed. vehicle_frame has no 64 px/m camera: add `--zoom=` if needed for close-ups.
23:08 GATE director reel on 34018b19 (`--fixed-fps 60 --quit-after 7600`, headless): tilt70 19/19
chapters all down, 0 SCRIPT ERROR; top 19/19 all down, 0 SCRIPT ERROR (logs
evidence/n8-vehicles/director-reel-it4-*.log). NEXT 1 done.
23:06 the light bar on the 55 cards (`--view=tilt`, 64 px/m): amber and blue alternate, the blue
halo shows above the bar; masters siren_tilt55_64ppm_amber_blue.png (frames.json: replaced the
turn contact sheet). NEXT 5 done.
23:11 NOTE on the reel logs: the it4 logs (stdout + stderr, `2>&1`) end with Godot's exit report
("1 RID CanvasItem leaked, 713 ObjectDB instances leaked, 99/100 resources still in use"); the it3
logs have none of it, most likely because they did not capture stderr. Then the it3 "0 SCRIPT
ERROR" counted stdout only and was a weaker claim than it read; the it4 count includes stderr (0).
The arena reel never loads a vehicles class (no Vehicle* in dev/arena, features/combat), so the
exit leak is not this lane's; owed: the same reel on main to confirm it is pre-existing.
23:11 CHECKED: the same `top` reel on the merge base 0bea8b93 (throwaway worktree, removed) prints
the same exit report (1 RID, 710 ObjectDB, 98 resources; HEAD 713 / 99) and 19/19 chapters, 0
SCRIPT ERROR: the leak is pre-existing, not vehicles'. (The +3 / +1 on HEAD: not chased; the arena
loads no vehicles class.)

NEXT (iteration 5) stands as written above (the reel and the 55 bar are done): 2 traffic density
cost, 3 kerb rows as cards once city ANDs VehicleParked.drawn(), 4 the bike.

## Iteration 5 (2026-11-06 23:13 - 00:13), BUILD

Read: JOURNAL, git log, the lane journals. city merged 34018b19 and turned `parked_cards` on
(848ff5a5: kerb cars handed to VehicleParked per chunk only while `drawn()`), so NEXT 3 is filmable.
No new REQUEST to vehicles.

MILESTONE 23:20 the traffic card cost (NEXT 2). bench.lock taken (free; two other lanes' Godot
processes were running: GPU numbers are CONTENDED-ish, the script time is per-frame CPU on one
thread). New dev bench `dev/bench/vehicle_cards_cost.gd` (-s launcher + runner, windowed d3d12,
1280x800 at 32 px/m, 240 frames per N after 60 warm, headings turning every frame):
| view | cards | script p50 / p95 (us) | GPU p50 shown / hidden (ms) |
| tilt70 | 32 | 185 / 244 | 0.016 / 0.005 |
| tilt70 | 64 | 355 / 451 | 0.022 / 0.005 |
| tilt70 | 128 | 700 / 1499 | 0.025 / 0.006 |
| tilt70 | 256 | 1331 / 1475 | 0.024 / 0.005 |
| tilt (55) | 128 / 256 | 690 / 1398 | 0.026 / 0.028 |
| top | - | no card atlas: 0 cards drawn | - |
The GPU side is ~0.02 ms (the shot cost256.png confirmed the cards drew, ~45 on screen); the cost is
the GDScript put + depth sort + MultiMesh writes: ~5.3 us per card. Measured in the real city
(main scene, tilt70, `--bot=rivet --seed=2`, a temporary Log line, reverted): VehicleView put **130
cards every frame** (every car in the sim bubble, nearly all off screen), finish() alone ~320 us.
MILESTONE 23:25 the cull (git log "cards cull off-screen cars"): VehicleCards.cull +
VehicleCull.screen_m (the viewport's ground rect through the canvas transform, grown by one 7 m
cell). Same run: 1-4 cards a frame, finish ~20 us. tilt70 framemd5 cull ON vs OFF (900 frames,
city walk): IDENTICAL. `top` untouched (cards only exist under a tilt). Unit: test_vehicle_cull 4/0,
the vehicle files 21/0. Evidence: evidence/n8-vehicles/cards-cost-{tilt70,tilt,top}.json.
DECISION vehicles: cull to the screen, not a radius round the player (docs/decisions.md).
DECISION vehicles: no bike art: the sim has no bike (no art id, no profile, nothing native); the
four library sheets are C. Raised as a Call for the owner.
FRICTION: a headless main-scene run (`--headless -- --arena=city`) logs only boot (the city never
starts headless): count things in the real city windowed with `--fixed-fps 60 --quit-after`.
FRICTION: python `open(p, 'w')` on Windows writes CRLF; normalised with sed before commit. Use
newline='' next time.
SLIP: 6b8f9313 (docs/decisions.md only) was committed with --no-verify by mistake; lint re-run on
the head after it (see the gate line below).
Rules applied: motion-quality-gating (the cull judged by framemd5 over motion, not a still),
sprite-and-atlas-production (cost per card measured before shipping density), depth-ordered-layered-
art (the cull runs before the depth sort, so order is unchanged for what draws).
23:30 the cull on the DRIVE too: vehicle_frame route (car zoom 48 px/m, look-ahead camera, full
throttle, S-bend, handbrake slide, kerb crash), cull ON vs OFF: framemd5 IDENTICAL, 632 frames.
MILESTONE 23:33 the kerb rows as cards (NEXT 3), filmed on n8-city's head 7a5f9137 (a throwaway
detached worktree, removed after; city_facades.json parked_cards false = the before): at the
vehicle_frame start (48 px/m) the kerb ambulance, police car and taxi stand as the same cards as
traffic instead of flat top-down props; 0 SCRIPT ERROR both. masters kerb_cards_tilt70_48ppm_*.
FRICTION: main city `--bot=rivet --seed=2` spawns at a crossroads with no kerb cars in 7 s: use
vehicle_frame (it starts beside kerb cars) to judge parked cars.
MILESTONE 23:36 the standing fire (7a8e1419): the asset lane served my fx_fire REQUEST (70 B, 55 A,
keyed cells 1024x512 = the game sheet's grid). Under a tilt a wreck now draws the pitch's sheet
(art/<p70|p55>/fx_fire.png): the flame loop standing on the bonnet as drawn (no stretch; its base
at 0.88 of the cell), two smoke puffs rising and thinning half a cycle apart, embers, and the
dying-flame cell once it shrinks below half. Checked the cells: green 7 / 1 px, teal 4 / 31 px
(of 170k / 135k: invisible), pure red 671 / 17 px moved to the sheet orange (red is blood's);
provenance lines appended. `top` and pitch_art = false keep the burst. Film: vehicle_states
tilt70 32 + 64 (before = HEAD before the change), and the real city route's kerb crash at 48:
masters fire_tilt70_64ppm_closeup_*, fire_tilt70_{32,64}ppm_before_after.{png,mp4},
fire_in_city_crash_tilt70_48ppm.png. Judged: the old burst read as a splash on the bonnet; the new
one reads as a car on fire from 32 px/m, with smoke from the hood (brief item 3).
masters frames.json: 15 (fire close-up, kerb cards, fire in the city crash, fire clip in; the two
turn-compare stills and the 32 turn clip out: their DECISIONs stand on the files).
REQUEST to city: none new. ANSWER: the kerb cards read on your head (film above); nothing owed.
23:41 GATE full unit on 2252f1cd: 1501 passed, 0 failed. 23:47 GATE scenarios (same head): 52 ran,
0 failed, exit 0, 0 SCRIPT ERROR (vehicle drive replay identical, timing CONTENDED as labelled).
NOTE: I swapped the p70 atlas + re-imported at 23:44 while the scenarios ran (for the turn before
film); the scenarios run `top` (no p70 atlas read) and passed, but that overlap was careless.
MILESTONE 23:46 the redrawn side views (43abc325): the asset lane served my side-view REQUEST
(sedan_side_70 B ~47 deg, police_car_side_70 B ~52 deg; the sheets' own sides are ~35). The atlas
cutter takes keyed/vehicle/<id>_side_<pitch>.png when it exists (SIDE_REDO), scaled to the
footprint on its own; sedan rows 0 1 2 7 and police row 8 take it; the van (A) and the others keep
theirs. Film: vehicle_turn 64 px/m, the before = the same head with the previous atlas swapped in
(the masters iteration-1 clip had an older, brighter grade: not a clean A/B, not used). Judged at
the swap (frames 20/22/23/25): the last side frame now shows the roof plane, so the jump to the 3/4
is smaller, not gone (47-52 vs the 3/4s' 65-70). masters turn_side_redo_64ppm_swap_*.png,
turn360_tilt70_64ppm_side_redo_before_after.mp4 (frames.json: replace the iteration-1 turn clip
and the iteration-1 city 64 still).
Rules applied (this iteration, also): generative-artifact-gating (B sheets used with the notes'
faults measured in motion; C cells never; a red check on the fire cells), sprite-and-atlas-
production (one cutter, one anchor rule for the redraws, provenance per atlas sha),
concept-scene-parity (the kerb cards judged in the real city scene, not a lab).
23:52 GATE `top` bit-identity: main scene `--arena=city --bot=rivet --seed=2 --rigs`, 301 frames,
framemd5 HEAD f3762816 vs 97334804 (iteration 4's head, itself identical to the merge base; a
throwaway detached worktree, removed): IDENTICAL (301 video + 301 audio), 0 SCRIPT ERROR each.
23:51 the fire on the 55 cards (`--view=tilt`, 64 px/m): the 55 sheet's flame stands on the
bonnet; masters fire_tilt55_64ppm.png (not in frames.json: 15 already).
Director reel not re-run this iteration: the arena reel loads no vehicles class (iteration 4
finding); last 19/19 in top + tilt70 on 34018b19. Evidence json: evidence/n8-vehicles/iteration5.json.

## Calls for the owner (carry to REPORT)
- Bike: the sim has no bike; the four library bike sheets are C. Options: (a) no bike (built),
  (b) add a bike to traffic (sim work, not this lane) and build it then from the side view as a
  slice stack. See docs/decisions.md.
- Wreck fire size: the standing flame is the full 2.5 m cell (it covers the bonnet's width). See
  fire_tilt70_64ppm_closeup_*.png. One value: VehicleFire.FLAME_SCALE (1.0 built; 0.8 smaller).

NEXT (iteration 6, in order):
1. The 22.5-deg in-betweens (asset lane served: sedan_between_70 B, police_car_between_70 B,
   van_between_70 A, plus sedan/police_between_c_70 B single-drawing redos of cell C; the C in
   the four-cell sheets is WRONG for sedan/police: use the _c sheet for it). Design: atlas COLS 5 ->
   9 (5 drawn + 4 between, cols 5-8 = A B C D between drawn 0-1, 1-2, 2-3, 3-4); VIEW_DEG 22.5 for
   a row whose between cells are filled (a per-row flag the shader/put reads: e.g. a 1 px marker or
   a const PackedByteArray of the art ids 0 1 2 7 8 4), else 45 as now. vehicle_cards.py: a
   between sheet = 4 runs (views() with n=4); the _c override like SIDE_REDO; scale each by its
   own long axis? NO: by the set's k (the between C was under-turned, measured ~8-10 deg on screen
   vs ~21): judge on the turn film at 64. Check the shader's cols uniform and VehicleCardMesh.
2. Film the 360 turn before/after at 32 + 64; the city drive at 32.
3. Exe at the freeze (int-day recipe in docs/decisions.md), REPORT.
23:56 LOOKED at the in-between sheets (read-only, scratch between_look.png, deleted): van_between_70
(A) all four read right (nose down a little right; nose right a little down; nose right a little
up, rear doors a sliver; rear toward the camera turned ~15-20), one steep camera: START NEXT 1
WITH THE VAN (row 4). sedan_between_70: A, B, D read right; C is wrong (turned past the side, a
3/4-away), so take C from sedan_between_c_70 (one large drawing, nose right and up, under-turned
~8-10 deg on screen, camera ~47 like the side redo); police the same pattern. Expect the C cell to
snap more than the others; judge on the turn film at 64 before committing it.

## Iteration 8 (2026-11-06 23:55 - 00:55), BUILD

Read: JOURNAL (my NEXT for this session was written as "iteration 6"; the runner counts 8), git log,
the lane journals: no new REQUEST to vehicles. Took NEXT 1, the 22.5-deg in-betweens.
MILESTONE 00:18 8d139438 the nine-view p70 set. tools/art/vehicle_cards.py: BETWEEN = True, atlas
9 columns (4032 x 4032, 6.8 MB PNG in LFS; the p55 atlas stays 5 x 9), columns 5-8 = A-D for rows
0 1 2 7 (sedan_between_70 B, C from sedan_between_c_70 B), 8 (police_car_between_70 B, C from
police_car_between_c_70 B), 4 (van_between_70 A); taxi, pickup, ambulance have none (five views).
Scale: first try box geometry (target width L|cos| + W|sin|): A and D came out ~1.5x their
neighbours (the sheets' own 3/4 views are drawn ~2/3 of the box width): REJECTED, looked at the
preview. Then: A B D at the sheet's own k (the between sheets share the sheet's canvas: raw widths
272 / 334 / 369 / 500 / 527 run in order for the sedan), the C redo scaled to the mean of the side
and the 3/4-away widths. Runtime: VehicleViews (new, 50 lines: view_of(a, fine), nose_deg,
cols_of(tex) = atlas width / 448, FINE per art key, fine_rows); VehicleCards reads the grid when
the atlas changes (the combo swap re-reads it) and steps 22.5 on a FINE row; the shader's nose
angle knows columns 5-8 (the dents' crumple zone). Unit: test_vehicle_views 4 (the nine columns,
the rest <= 11.25 and nose_deg agrees, the p70 atlas really holds in-betweens in exactly the FINE
rows, a 5-column atlas has none) + test_vehicle_cards 9: 13/0.
FILM (vehicle_turn, tilt70, 400 frames, 64 and 32 px/m): before = this head with the HEAD atlas
swapped in (5 columns: identical to the old code path). framemd5: 392 of 400 frames differ, the 8
equal ones every 45 frames (the drawn views' own headings): the expected pattern. Judged the sedan
through one swap at 64 (frames 54-78, every 3): before the 3/4-toward drawing turns ~20 deg then
snaps to the nose view; after the A drawing takes over halfway, each jump is half, and the card
stays over its footprint (the flat footprint no longer shows at mid-turn). masters:
turn360_tilt70_{64,32}ppm_between_before_after.mp4, turn_between_sedan_64ppm_swap_before_after.png,
between_atlas_rows_sedan_van_police_p70.png (the nine views in angle order). frames.json 15 (the
side-redo turn clip, now superseded, and the 55 siren still out).
Seen, not fixed: the police C redo is a lighter, brighter blue than its neighbours (a colour pop
at ~22 deg past the side); the sedan's C is under-turned (as the catalog notes say).
FRICTION: the atlas PNGs are git LFS: `git show HEAD:<png>` gives the 132-byte pointer; use
`git show HEAD:<png> | git lfs smudge > file`. Importing the pointer left the .import at
valid=false and a stale .md5 that a plain --import did not clear: `git checkout` the .import, delete
`.godot/imported/<name>-<hash>.*`, then --import. The first "before" film drew no cards (caught by
looking at the strip, not by an exit code: the run printed one ERROR line, no SCRIPT ERROR).
FRICTION: gdformat on Windows rewrote vehicle_cards.gd with CRLF; sed 's/\r$//' before staging.
Rules applied: motion-quality-gating (judged on the 360 film through a swap, not on atlas stills;
framemd5 confirms where the two differ), sprite-and-atlas-production (one cutter, scale rule
measured and the rejected one recorded, provenance line with each sheet's round + prompt_hash,
the FINE list checked against the atlas by a test), generative-artifact-gating (B sheets used per
their notes: the cars' wrong C cells replaced by the _c redos, never integrated), depth-ordered-
layered-art (the in-betweens keep the ground-centre anchor, so the depth sort is unchanged).
DECISION vehicles: nine views a half turn on p70 (docs/decisions.md).
00:22 GATE full unit on 8d139438: 1505 passed, 0 failed (67.8 s), no FLAKY.
MILESTONE 00:26 a265dfba the police C graded to its neighbours. Measured the blue paint (b > r+25)
per cell of row 8: the C redo V 0.52 / S 0.85 against 0.34-0.35 / 0.53-0.74 beside it (the colour
pop I saw). vehicle_cards.py MATCH_C: the C redo's saturated pixels within 30 deg of the
neighbours' median paint hue take the neighbours' mean S and V (weighted by saturation). First
cut matched EVERY saturated pixel: the light bar's amber lens went towards red-orange (red is
blood's): caught on the film strip, narrowed to the paint hue; after: blue V 0.32 / S 0.63, the
amber lens mean (219,141,12) vs (219,142,11) before, 388 px both. Changed elsewhere: only the four
sedan C cells, mean delta 1.2 / 765 (the HSV round trip). framemd5 vs the unmatched film: only
frames 191-212 and 326-347 differ (the C window, both halves). Honest read: in the game's grade
the difference is small (the scene pulls the police blue dark); the drawing now measures in line.
masters police_c_match_64ppm_before_top_after_bottom.png (not in frames.json).
00:28 GATE `top` bit-identity: main scene `--arena=city --bot=rivet --seed=2 --rigs`, 301 frames,
framemd5 of HEAD a265dfba vs iteration 5's top_head.md5 (f3762816, itself identical to 97334804
and the merge base): IDENTICAL (301 video + 301 audio), 0 SCRIPT ERROR.
00:30 FILM the drive (vehicle_frame --clip --view=tilt70, the car camera at 48 px/m: full
throttle, the S-bend, the handbrake slide, the kerb crash and its standing fire): 0 SCRIPT ERROR,
301 frames; masters drive_tilt70_48ppm_nine_views.mp4 (no before: the turn films are the A/B).

## Calls for the owner (add to REPORT)
- Rotation set density: nine views a half turn on p70 (built) vs five (BETWEEN = False in
  tools/art/vehicle_cards.py, then re-cut). See turn360_tilt70_64ppm_between_before_after.mp4. Cost:
  the p70 atlas 4032 x 4032 (65 MB of VRAM uncompressed, lossless import) vs 2240 x 4032 (36 MB).
- The C in-between (just past the side view) is the weakest drawing (under-turned ~8-10 deg, a
  little smaller); a REQUEST for a third C could fix it, or FINE could skip column 7 only.

NEXT (iteration 9, in order):
1. The rows without in-betweens: taxi (3), pickup (5), ambulance (6) still turn through five.
   REQUEST to assets: taxi_between_70, parked_pickup_between_70, ambulance_between_70 (the four
   22.5-deg in-betweens of each 70 sheet; same scale family and canvas as the sheet; C = nose right
   and a little UP, ~22.5 past the side view, the angle both cars missed). Then add their rows to
   VehicleViews.FINE (the unit test checks the atlas against it).
2. The 55 set (boss arenas under combo): no 55 in-betweens; low priority (traffic is rare in a boss
   arena); leave five.
3. Exe at the freeze (int-day recipe in docs/decisions.md), REPORT.md by 08:40 with the Calls above
   and the earlier ones (bike, wreck fire size).
00:32 GATE scenarios on a265dfba: 52 ran, 0 failed, exit 0, 0 SCRIPT ERROR (vehicle drive replay
identical, timing CONTENDED as labelled). Evidence json: evidence/n8-vehicles/iteration8.json.
00:37 f29b7a0e a unit test that the card grid follows the atlas across a combined view's pitch swap
(nine columns -> five -> nine; VehicleCards.cols()). Vehicle files 18/0.
00:40 MUTATE features/vehicles/vehicle_views.gd at f29b7a0e (tests test_vehicle_views +
test_vehicle_cards, 10 sampled of 49): score 100 % = killed 10 / (10 + 0 survived), 197 s.
Session end 00:40; NEXT as written above (iteration 9: the REQUEST for the taxi / pickup /
ambulance in-betweens, then their FINE rows; exe + REPORT at the freeze).

## Iteration 11 (2026-11-07 00:43 - 01:43), BUILD

Read: JOURNAL, git log (iterations 9-10 left no commits or entries), the lane journals: no new
REQUEST to vehicles. The library has NEW bike sheets: bike_v3 70 B and 55 B (round 20261107-0035,
a geometry-guide method; "do not ask for more bike sheets" was kept: the asset lane made them on its
own). That reopens the bike (the brief's scope; my "no bike art" DECISION rested on all-C sheets).
REQUEST to assets: taxi_between_70, parked_pickup_between_70, ambulance_between_70: the four 22.5-deg
in-betweens of each 70 sheet (same canvas and scale family as the sheet; A between the nose view and
the 3/4 toward, B between the 3/4 toward and the side, C nose right and a little UP ~22.5 past the
side view (the cars' C was under-turned: the asked angle), D between the 3/4 away and the tail);
amber tails, no red. They complete the nine-view p70 set (VehicleViews.FINE rows 3 5 6).
FRICTION: keyed/vehicle/bike_{70,55}_v3.png carry the side view on an OPAQUE BLACK box (the post-fix
squash_facing.py lost its alpha); the green original (sheets/vehicle/) is clean. Keyed it here.
NOTE to assets (not a REQUEST): the keyed bike_v3 side views sit on black boxes (both pitches).
MILESTONE 00:55 b3d21e7d the bike as card row 9 (p70 + p55). vehicle_cards.py: BIKE = True, the
row cut from the green original with green_key (alpha by green excess over max(r, b), tol 24; spill
pixels go neutral grey: the first cut left 64 teal-ish px in the spoke gaps, teal is the souls',
now 4 / 13), side view scaled to 2.1 m, ground centre at the cell centre like the cars. The p55
atlas is 5 columns again when no row has in-betweens (the cutter now crops; the committed p55 was
already 5 wide). Rows 0-8 of both atlases re-cut BIT-EXACT against HEAD (0 px differ). Runtime:
VehicleViews.grid_of(tex, rows) (columns and rows from the atlas size), VehicleCardMesh.set_grid
sets both shader uniforms on both layers, VehicleCards keeps the grid (still 199 lines); BIKE_ART 9.
No sim bike: only the turn film draws row 9 (dev/showcase/vehicle_turn: the bike below the police
car). Unit: test_vehicle_views +3 (both atlases hold the bike row's five views after the nine, a
null atlas keeps (5, 9), both layers' shaders read the atlas rows): vehicle files 24/0.
FILM vehicle_turn tilt70 at 64 and 32 px/m, 400 frames, 0 ERROR: masters
turn360_tilt70_{64,32}ppm_with_bike.mp4, bike_turn_strip_tilt70_64ppm.png (in frames.json, the
superseded side-redo still out). LOOKED: the bike turns through all eight facings over its
footprint; the side views read best, the end views are long narrow strips (right for 70); no pop
worse than the cars'. Seen, not fixed: the showcase's grade pulls the mustard tank stripe to orange
(atlas 211,138,41 -> frame 179,85,21; the cars' amber lamps go the same way): the scene's, not the
art's; check it in the city grade before calling it vermilion.
DECISION vehicles: the bike as atlas row 9 (docs/decisions.md; supersedes "no bike art tonight").
Rules applied: generative-artifact-gating (B used with its named fix already applied by the asset
lane; the keyed sheet's defect found by looking and routed around, never integrated as is),
sprite-and-atlas-production (one cutter, rows 0-8 proven unchanged bit-exact, provenance with
round + prompt_hash per pitch, the grid read from the atlas not hard-coded), motion-quality-gating
(judged on the 360 film at both zooms), depth-ordered-layered-art (ground-centre anchor: the bike
sorts like a car).
01:00 GATES on b3d21e7d: full unit 1509 passed / 0 failed (48 s, no FLAKY); scenarios 52 ran, 0 failed,
exit 0, 0 SCRIPT ERROR (the exit leak report is the pre-existing one); `top` framemd5 (main scene
`--arena=city --bot=rivet --seed=2 --rigs`, 301 frames) vs top_head.md5: IDENTICAL (301 + 301).
MUTATE features/vehicles/vehicle_views.gd at 305fad98 (test_vehicle_views + test_vehicle_cards, 12
sampled of 52): 91.7 % = killed 11 / (11 + 1 survived); the survivor `a >= 0.0 -> a > 0.0` (line
27) is equivalent (at a = 0 the sign is never read: flip is false).
00:58 the bike on the 55 set (`--view=tilt`, 64 px/m): turns cleanly; masters
bike_turn_strip_tilt55_64ppm.png. Quest 1: collect_call_city.json ghost_cars is [] (owner call
d7 ghost-powers-5), so quest 1 draws no car today.
MILESTONE 01:12 54cc531b + 01:20 79c678ad a stage's cars stand as cards. FOUND: StageView._car
(boot/collect_call/view/stage_view.gd, which ArenaFloorView extends) printed every arena car flat
from the top-down traffic atlas under ANY view: the powers pad's gearbox cars and the Servo depot's
van (a judged boss arena: Dent seizes it and rams Servo). New VehicleStageCards
(features/vehicles): the stage's cars through VehicleCards (wear, duty), StageView keeps their flat
ink shadow and skips the flat body (2 hook lines + a field; no lane touched stage_view.gd tonight;
ArenaFloorView, which view edits, untouched). First cut was a child of the stage view: on the
printed arena path that is the WORLD canvas, and the print crushed the olive van to black hatched
ink (looked: servo frames 60/130/170); now it rides the PrintStage actor layer (the city's cars'
canvas), following the stage view's transform. The seized car's teal multiply (SOUL) turned the
olive van and its lamps green: SOUL = WHITE (the seize reads by Dent's halo and teal tether); the
teal value is one line away. `top` adds no node at all.
FRICTION: a windowed arena run reads the real mouse for Rivet's aim: two `top` films differed in 78
of 90 frames only round Rivet (I moved the cursor between runs). Film before and after
back-to-back, or use a bot. With the cursor matched: hook on vs off IDENTICAL (90 + 90).
FILMS (masters, in frames.json): servo_depot_van_combo_32ppm_{zoom_..png,..mp4} before top / after
bottom (`res://dev/arena/arena.tscn -- --boss=servo --bot=boss --servo-ghost=dent --view=combo
--ppm=32 --rigs --seed=2`; before = the hook line off); powers_pad_cars_tilt70_24ppm_{..png,..mp4}
(`-- --start=pad --view=tilt70 --ppm=24`). 0 SCRIPT ERROR in every run. Unit: test_vehicle_stage_cards
3 (top draws none, a tilt stands both cars, the sim-px scale) + dent quest / boss bot ghost: 12/0.
Seen, not fixed: the depot van's colour changes with the view (cream flat print, olive card: the
library van); the taxi's mustard reads orange in the arena (as on the turn film: the scene's grade,
not vermilion, but close: a Call). The stage cards have no front grid: always under the actors.
DECISION vehicles: stage cars as cards (docs/decisions.md, amended for the actor layer and SOUL).

## Calls for the owner (add to REPORT)
- Bike: now BUILT as card row 9 (bike_v3 B), but the sim has no bike: (a) leave it showcase-only
  (built), (b) a sim archetype with art id VehicleViews.BIKE_ART (sim work). See
  bike_turn_strip_tilt70_64ppm.png and turn360_tilt70_64ppm_with_bike.mp4
  (exe: `RTAI.exe res://dev/showcase/vehicle_turn.tscn -- --view=tilt70 --ppm=64` is a dev scene;
  the clip is the evidence).
- The depot van (Servo's arena) changes colour with the view: cream top-down print vs the library's
  olive van card. Options: (a) olive everywhere (built under the tilt), (b) a paint gain for the
  depot van's row (cream, value-only gains exist in vehicle_cards.py), (c) REQUEST a cream van sheet.

NEXT (iteration 12, in order):
1. If the asset lane served taxi/parked_pickup/ambulance_between_70: cut them (BETWEEN rows 3 5 6),
   add the rows to VehicleViews.FINE (test_vehicle_views checks the atlas), film the turn at 64.
2. The stage cards' depth: a VehicleFront grid from the arena's fighters (ArenaStage targets +
   Rivet) so a car with nobody in front draws OVER people behind it (now always under the actors).
   Needs the fighters' ground points each frame: read ArenaStage from VehicleStageCards (no edit
   to ArenaFloorView, which view owns tonight).
3. The director reel 19/19 in top + tilt70 on HEAD (last 34018b19; StageView changed this time:
   the reel runs on the arena) - RUN IT FIRST next session.
4. Exe at the freeze (int-day recipe in docs/decisions.md), REPORT.md by 08:40 with every Call in
   this JOURNAL (bike, wreck fire size, rotation density, the C in-between, the depot van colour).
01:27 GATE director reel on 5a5a5106 (`res://dev/arena/arena.tscn -- --bot=reel --reel=director
--loadout=pistol --rigs --view=<v>`, headless, --fixed-fps 60 --quit-after 7600): top 19/19 chapters
all down, 0 SCRIPT ERROR; tilt70 19/19 all down, 0 SCRIPT ERROR (evidence/n8-vehicles/
director-reel-it11-*.log). NEXT item 3 DONE.
01:29 GATE full unit on cf22afec: 1512 passed, 0 failed, no FLAKY. Evidence json:
evidence/n8-vehicles/iteration11.json.
Session end 01:30. NEXT for iteration 12 = items 1, 2, 4 of the NEXT above (3 done).

## Iteration 14 (2026-11-07 01:31 - 02:31), BUILD

Read: JOURNAL, git log (iterations 12-13 left no commits or entries), the lane journals: no new
REQUEST to vehicles. The asset lane SERVED my REQUEST: taxi_between_70 (B, all four right, ~1.6x
the sheet's scale, brighter yellow), parked_pickup_between_70 (A) + its _c (B, better turned,
flatter camera, heavier rust), ambulance_between_70 (B: use A and D; its B is a plain side view),
ambulance_between_b_70 (B, 0155) and ambulance_between_c_70_v2 (B, 0140); and unasked, for my
"weakest C" Call: sedan_between_c_70_v2 and police_car_between_c_70_v2 (B, 0145, turned ~20-25
by a turn reference). Looked at every sheet on a grey contact sheet before cutting.
MILESTONE 01:45 8c634dc8 every sim car turns through nine views on p70 (FINE rows 0-8).
vehicle_cards.py: REDRAWS (per sheet id, per slot: a one-drawing redraw or the row's own),
ROW_FIT (the taxi row sheet fitted to its neighbours like a redraw), FIT_BY = "area": the first
cut scaled redraws to the neighbours' mean WIDTH and the strip showed every C cell visibly small
(a car's screen width falls ~30 % from the side to the 3/4 away); by the inked area's square root
they sit at their neighbours' size (looked: p70_nine_view_rows_it14.png). Re-cut vs HEAD: only
col 7 of rows 0 1 2 7 8 and cols 5-8 of rows 3 5 6 changed; rows 4 and 9 and every drawn column
bit-exact; 0 red px. Provenance line with every round + prompt_hash. vehicle_turn --set=street.
FRICTION (cost ~15 min): the atlas is in git LFS: `git show HEAD:<png> > file` writes the POINTER;
Godot's import then fails ("Not a PNG file") and leaves the .import `valid=false`, and a later
--import does not retry (the cached md5 matches). Fix: `git cat-file blob HEAD:<png> | git lfs
smudge`, restore the .import from git, delete the cache's .md5, --import. My first before AND after
films were made on that broken state (empty cards / identical films): caught by looking, re-filmed.
Seen, not explained: in the turn film the VAN region differs before/after (both draw the same B
cell; the van's cells are bit-identical; sedan, police, bike regions identical at the same frame).
Small (a few px of scale/offset); not chased.
FILMS (masters, frames.json entry 4): turn360_tilt70_64ppm_street_between_before_after.mp4 (taxi,
pickup, ambulance: five views left, nine right), street_between_tilt70_64ppm_before_left_after_right.png,
turn360_tilt70_64ppm_cv2_before_after.mp4 (sedan/police C v2). LOOKED: at 200 deg the sedan C now
sits on its footprint (before: small, under-turned, the footprint showing past it).
GATES on 8c634dc8: lint 15/15; full unit 1512 passed / 0 failed, no FLAKY; `top` framemd5 (main
scene `--arena=city --bot=rivet --seed=2 --rigs`, 301 frames) vs top_head.md5: IDENTICAL (301 +
301), 0 SCRIPT ERROR; city tilt70 seed 7 900 frames 0 SCRIPT ERROR (the ambulance card on the road).
Rules applied: generative-artifact-gating (every B used per its note: the ambulance row B and the
C-grade C never integrated, the taxi spare C skipped, red lamp segments amber), sprite-and-atlas-
production (one cutter, unchanged cells proven bit-exact, provenance, FINE checked by the unit
test), motion-quality-gating (judged on the 360 film, before/after at 64 px/m),
depth-ordered-layered-art (ground-centre anchor kept: depth unchanged).
DECISION vehicles: every p70 row nine views, FIT_BY area (docs/decisions.md).

## Calls for the owner (add to REPORT)
- The pickup's C in-between: the row sheet's (built; design exact, ~30-35 deg past the side) vs
  the _c redraw (better turned ~15-18, flatter camera, heavier rust): PICKUP_C_REDO in
  tools/art/vehicle_cards.py, then re-cut. See turn360_tilt70_64ppm_street_between_before_after.mp4.
01:52 FILM the 32 px/m twin (vehicle_turn --set=street --ppm=32): masters
turn360_tilt70_32ppm_street_nine_views.mp4 (after only). FRICTION: the swapped-in "before" at 32
drew NO taxi at all (pickup and ambulance fine) although the 64 px/m before with the same HEAD
atlas drew it, and the arena films of iterations 11 showed HEAD's taxi: an artefact of the atlas
swap + reimport, not used as evidence. Next time film a before from a throwaway detached worktree
(LFS checkout + --import), not by swapping the atlas in place.
Not started (too big for the 30 min left; needs the cast's z on the print actor layer, a boss
arena re-film and the reel): the stage cards' front grid (NEXT 2 of iteration 11).
Evidence json: evidence/n8-vehicles/iteration14.json.

## Calls for the owner (carry to REPORT; with the earlier ones: bike, wreck fire size, rotation
## density, the depot van colour; "the C in-between is the weakest" is now answered by the C v2s)
- The pickup's C in-between (row C built vs the better-turned _c redraw), see above.

NEXT (iteration 15, in order):
1. The stage cards' depth: a VehicleFront grid from the arena's fighters (stage.arena.rivet,
   hostiles, boss: Fighter.pos in m, alive()) fed in VehicleStageCards._process; the cards' band
   over the actors and `cards.under` just under them ON THE PRINT ACTOR LAYER (find the cast's
   z there first: CastView / ArenaFloorView, view's files, read only). Film the Servo depot fight
   (combo, 32 px/m) hook on/off, the reel in both views, `top` identity (no node in top).
2. p55 in-betweens: none in the library (boss arenas park few cars); leave five unless the asset
   lane serves them unasked.
3. Exe at the freeze (int-day recipe in docs/decisions.md), REPORT.md by 08:40 with every Call.
01:58 GATE director reel on 8a4d1ff8 (`res://dev/arena/arena.tscn -- --bot=reel --reel=director
--loadout=pistol --rigs --view=<v>`, headless, --fixed-fps 60 --quit-after 7600): top 19/19 all
down, tilt70 19/19 all down, 0 SCRIPT ERROR, exit 0 each (evidence/n8-vehicles/director-reel-it14-*.log).
MILESTONE 02:04 edc95d54 the stage cards' front grid (iteration 11 NEXT 2), built and OFF.
VehicleStageCards.over: on a print the cards go to the vehicles band (z 200, over the actors at
100) and their under layer to actors - 1 (z_as_relative off), the front grid fed each frame with
the arena's living fighters (Rivet, hostiles, boss: VehicleStageCards.fighters). FILMED the Servo
depot (`res://dev/arena/arena.tscn -- --boss=servo --bot=boss --servo-ghost=dent --view=combo
--ppm=32 --rigs --seed=2`, 300 frames, over on/off, 0 SCRIPT ERROR both): with over ON the van
covers bay 3's marker, Dent's halo and the teal tether end (drawn in the actors band) - the very
cues the seize reads by since SOUL went WHITE. Worse at close range, so over = false (the picture
as before; the unit test runs both settings). Still: masters
servo_van_over_actors_left_under_right_over_combo_32ppm_f130.png (left today's, right over; not
in frames.json: a rejected option).
REQUEST to view: on the print actor layer, draw the soul-seize cues (the ghost's halo, the teal
tether, the bay markers: cast_view / stage overlays, actors band today) above the vehicles band
(z > 200), so a stage car can stand over the actors (VehicleStageCards.over = true) without hiding
them. Not urgent: the arena cars are parked; people walk round them.
GATE full unit on edc95d54: 1513 passed, 0 failed, no FLAKY. lint 15/15. `top` unaffected (no
node in top; the stage cards' code path returns before attach without a card atlas).

NEXT (iteration 15, replaces the NEXT above):
1. If view answers the REQUEST (seize cues over z 200): VehicleStageCards.over = true, re-film the
   Servo depot (combo 32 + 64 px/m) on/off, the reel in both views.
2. Raise the weakest item: the taxi's paint under the scene grade reads orange (atlas mustard
   211,138,41 -> frame ~179,85,21); measure it in the city tilt70 grade next to vermilion (Rivet's
   collar) and, if they collide, a value-only gain on row 3 in vehicle_cards.py (a Call if not).
3. Exe at the freeze (int-day recipe in docs/decisions.md), REPORT.md by 08:40 with every Call:
   bike (showcase only vs a sim archetype), wreck fire size, rotation density (nine views now on
   every p70 row), the depot van colour, the pickup C (row vs _c), stage cars over the actors.
Session end 02:06.

## Iteration 15 (2026-11-07 02:08 - 03:08), BUILD

Read: JOURNAL, git log, the lane journals: no new REQUEST to vehicles; view has not answered my
it14 REQUEST (seize cues over z 200), so NEXT 1 waits and over stays false. NEXT 2 taken.
MEASURED 02:12 the taxi prints as VERMILION under the angled view. The palette's own gate
(PaletteTokens.classify: r - max(g, b) >= 79, blood excluded) on the main scene `-- --arena=city
--view=tilt70 --seed=11 --rigs` frame 170 (32 px/m): 5,777 px, 5,695 of them on the taxi (median
160,75,5), the other 57 Rivet's collar. Cause: the car shader keeps the atlas colour; the city's
warm light/grade takes the sheet's mustard (202,138,38; hue 37) to (160,75,5) while the sedan only
dims evenly (183,171,149 -> 153,127,95).
MILESTONE ca7c255d the taxi row's saturated mid paint (hue 20-50, sat >= 0.35) turns 12 deg toward
yellow in the cutter (HUE_DEG / TAXI_HUE, tools/art/vehicle_cards.py), p70 and p55 (combo's hard
swap must not change its hue). TAXI_HUE 0 re-cuts HEAD bit-exact; +12 changes row 3 only. Filmed
+12 and +16 in the city: both 0 taxi vermilion px (p90 r-gb 87 -> 49 / 35); +16 reads olive, +12
a mustard cab yellow: built +12. 64 px/m art close-up (vehicle_turn --set=street): ink, roof sign,
checker, amber lamps unchanged.
MILESTONE 8db2a46d the amber lamps: the sheets' lens orange (~239,151,7) passes the gate even in
the atlas (ambulance row 3,610 px, police 3,405, others 40-800). Lit lenses (value >= 0.7, sat >=
0.8, hue 20-42) turn 10 deg toward yellow (LAMP_DEG) on every row but the police car's (its siren
shader's lens() finds the amber lens by colour, r > g + 0.2: a turned lens sits at 0.204, too
close). Atlas: every non-police row <= 42 gate px (ambulance 7). City seed 7 f180: frame 445 -> 147
(57 collar). The hue window stops at 42 so the taxi's turned highlights (hue ~49) are not turned
again (the first try at 50 hit 7,316 taxi px). Only police cars carry the siren bit (checked).
FRICTION: the main scene has no --ppm (the zoom is CameraRig's mode table): the city before/after
is 32 px/m only; the 64 px/m close-up is the ungraded turn film (it cannot show the grade's shift).
Checked: the it3 still city_tilt70_64ppm_it3_f300.png (main scene "--ppm=64") has the 32 px/m
framing, so it was 32 (not in frames.json; the frames.json 48/64 entries come from dev scenes that
read --ppm: vehicle_states, vehicle_frame, the arena).
EVIDENCE (masters, frames.json entry 2): taxi_paint_city_tilt70_32ppm_f170_before_left_after_right.png,
taxi_paint_city_tilt70_32ppm_before_left_after_right.mp4 (300 frames, in sync),
taxi_paint_turn_tilt70_64ppm_before_left_after_right.png, taxi_hue_options_city_tilt70_32ppm_crop2x_head_12_16.png,
amber_lamps_city_tilt70_32ppm_crop2x_before_left_after_right.png, amber_lamps_atlas_p70_ambulance_before_top_after_bottom.png.
(frames.json kept at 15: dropped damage_tilt70_32ppm_before_after.mp4, its 64 px/m twin stays.)
GATES: lint 15/15 (both commits); full unit on ca7c255d 1513 passed / 0 failed, no FLAKY; vehicle
tests on 8db2a46d 26/0; `top` framemd5 (`--arena=city --bot=rivet --seed=2 --rigs`, 301 frames) on
ca7c255d vs top_head.md5: IDENTICAL 301 + 301, 0 SCRIPT ERROR (8db2a46d is atlas-only: top never
reads the card atlas). City tilt70 seeds 2 7 11 23, 0 SCRIPT ERROR.
Rules applied: generative-artifact-gating (the colour law measured with the game's own classifier,
not by eye; the fix in the cutter, reversible by one constant), sprite-and-atlas-production (one
cutter, HEAD reproduced bit-exact at 0, changed rows named, provenance with sha), concept-scene-
parity (judged in the real graded city, not the ungraded turn rig), motion-quality-gating (a
300-frame before/after clip, same seed).
DECISIONS: the taxi hue, the lamp hue (docs/decisions.md).

## Calls for the owner (carry to REPORT)
- The taxi's paint: built +12 deg (mustard cab yellow; 0 vermilion px) vs +16 (olive) vs the
  sheet's (prints as vermilion beside Rivet's collar). TAXI_HUE in tools/art/vehicle_cards.py.
  See taxi_hue_options_city_tilt70_32ppm_crop2x_head_12_16.png.
- (withdrawn: the police car's parked amber lens; built in aaaaf876, see below.)
02:40 GATE director reel on 8db2a46d (`res://dev/arena/arena.tscn -- --bot=reel --reel=director
--loadout=pistol --rigs --view=<v>`, headless, --fixed-fps 60 --quit-after 7600): top 19/19 all
down, tilt70 19/19 all down, 0 SCRIPT ERROR, exit 0 each (evidence/n8-vehicles/director-reel-it15-*.log).
Caveat: the police edit (aaaaf876) landed on disk while the tilt70 run was going; the card shader
loads when the first car draws, so that run may have used either shader. Both are colour-only.
MILESTONE aaaaf876 the police bar's amber lens turns too (LAMP_DEG on every row) and the siren
shader's amber lens test loosens to r > g + 0.12 (was 0.2). Checked in Python BEFORE filming: the
new test on the new atlas finds the same lens (70: 2,842 -> 2,841 px; 55: 1,663 -> 1,664; blue
2,553 / 1,346 unchanged); police row gate px 3,405 -> 2. FILMED vehicle_states (`--view=tilt70
--ppm=64`, 300 frames, 0 SCRIPT ERROR both; the before = 8db2a46d's atlas + shader swapped in,
restored and re-imported after, cmp-checked): lit-amber and lit-blue px per frame equal within 1 %
through the whole flash cycle; looked: the amber phase lights the same lens, the tail lamps go
orange -> amber. Masters: siren_amber_lit_tilt70_64ppm_crop2x_before_left_after_right.png,
siren_blue_lit_tilt70_64ppm_before_left_after_right.png. Vehicle tests 26/0, lint 15/15.
Tried and dropped: a graded 48 px/m taxi close-up from vehicle_frame (--car-zoom): no taxi on its
fixed route (<= 4 taxi-coloured px in any frame).
GATE full unit on aaaaf876: 1513 passed, 0 failed, no FLAKY. Servo depot combo 32 px/m (seed 2,
300 frames) on aaaaf876: 0 SCRIPT ERROR, the van and the seize cues as before (looked at f130).
Evidence json: evidence/n8-vehicles/iteration15.json.

NEXT (iteration 16, in order):
1. If view answers the it14 REQUEST (seize cues over z 200): VehicleStageCards.over = true, re-film
   the Servo depot (combo 32 + 64 px/m) on/off, the reel in both views.
2. The rest of the colour audit at the angled view: the parked pickup's rust (row 5: 25,909 atlas
   px within 50 of the gate, 42 over it) and the fire (vehicle_states: the burning wreck dominates
   the frame's vermilion count, ~4,400 px at 64 px/m). Measure the fire in the graded city
   crash (vehicle_frame); fire may be allowed as danger, so read palette.json's accent uses first.
3. Exe at the freeze (int-day recipe in docs/decisions.md), REPORT.md by 08:40 with every Call:
   bike, wreck fire size, rotation density, the depot van colour, the pickup C (row vs _c), stage
   cars over the actors, the taxi paint (+12 built vs +16 vs the sheet's).
02:45 READ for NEXT 2 (palette.json): vermilion's layers are actors, fx, world_markers, hud; its uses
threat, danger_cue, pickup, objective, rivet_collar, hit_flash. NOT the vehicles layer: the taxi and
lamp fixes are what the table requires, not taste. VehicleFire draws on the vehicles band
(vehicle_view.gd: fire.z_index = car.z_index + 1), so the wreck fire's vermilion-gate pixels sit
on a layer the table does not allow. Options for NEXT 2: (a) the fire on the fx band (fx allows
vermilion, but a burning car is not one of its listed uses unless it counts as danger_cue); (b) the
fire's cores turned toward yellow in vehicle_fire's sheet cut (a LAMP_DEG-style turn); (c) a debt
row in accent_debt.json naming the fire. Measure first (vehicle_frame crash, graded); decide (b)
if its look survives at 64 px/m, else raise a Call.
Session end 02:46.

## Iteration 16 (2026-11-07 02:45 - 03:45), BUILD

Read: JOURNAL, git log, the lane journals. view ANSWERED my it14 REQUEST in part (n8-view it10,
1dd745b8): under a card view Dent's tether and the seized car's heat halo draw at vehicles + 1;
Dent's soul halo stays with the ghost body (feed it to VehicleFront: it is the player's form at
Rivet's position, which the front grid already gets); bay 3's marker is a ground mark (view
offers to move it to world_markers). No other REQUEST to vehicles.
MEASURED 02:50 NEXT 2, the colour audit at the angled view:
- the wreck fire (p70 fx_fire.png): 55,546 of 170,298 visible px pass the vermilion gate (p55
  44,354 of 135,283), all flame-loop cells, hue ~12, sat ~0.84. A hue turn toward yellow does not
  survive: +10 deg leaves 51,653, +25 deg 21,141; clearing them needs a yellow fire. Fire kills
  within FIRE_R (VehicleContacts.burn): a danger cue. Kept; a Call (palette.json's vermilion
  layers lack `vehicles`). The `top` fire (features/fx/art/fx_fire.png) is the same: 65,737 px.
- the city at tilt70 (main scene `-- --arena=city --view=tilt70 --seed=<2|7|11|23> --rigs`,
  frames 60/120/180, 32 px/m, 0 SCRIPT ERROR): per frame 81-196 gate px; 78 are Rivet's collar
  (the centre cluster, 232,80,42), the rest lit amber lenses the grade pushes over the gate (the
  ambulance's roof beacon 243,156,1 at seed 7 f180; a taxi's side lamp 217,128,0): they read
  amber to the eye (looked, crop x3). No pickup on screen in those 12 frames; its atlas row has 42
  px over the gate and 840 within 20 of it (130,697 within 40): not measured graded.
MILESTONE 47324e53 merge n8-view (JOURNAL.md ours; tools/debt/baseline.json: took view's, then
`--update --accept-regression` (the merged tree carries both sides' accepted dev lines: dev_loc
18157); lint 15/15).
MILESTONE f09f4456 VehicleStageCards.over = true. FILMED Servo depot (`res://dev/arena/arena.tscn
-- --boss=servo --bot=boss --servo-ghost=dent --view=combo --ppm=<32|64> --rigs --seed=2`, 300
frames each, over off/on, 0 SCRIPT ERROR all four): on, the van stands in front of its bay's
shutter (off: the shutter and the bay box drew over its roof), the tether and the heat halo over
the van (view's fix). First try on: Servo's arm went under the wreck at f240 (his centre lies past
the front box's HALF_M while his arm reaches over the car): a fighter wider than WIDE_M (0.6 m
radius; people 0.45) now adds its left and right edges to the front grid; re-filmed: the arm over
the wreck as with off. Kept cost: bay 3's number hides under the van parked on it.
Quest 1 (`-s res://dev/frames/quest1_clip.gd -- --stills=600,2400,6000,13700 --rigs --view=tilt70
--ppm=32`) on vs off: 4 stills pixel-identical, 0 SCRIPT ERROR.
Masters: servo_van_over_combo_{32,64}ppm_off_left_on_right.mp4, servo_van_over_combo_32ppm_f180_
crop2x_off_left_on_right.png (frames.json entry 4; dropped fire_tilt70_32ppm_before_after.mp4,
its 64 px/m close-up stays), servo_van_over_combo_64ppm_f120_off_left_on_right.png,
servo_wreck_boss_edges_combo_32ppm_f240_crop2x_off_left_on_right.png.
GATE unit (the --changed run fell back to FULL after the merge) on the merged tree + over: 1526
passed, 0 failed, no FLAKY. lint 15/15. Test: test_vehicle_stage_cards 6/0 (over on and off, the
wide fighter's edges).
REQUEST to view: move the Servo depot's bay markers (the box and its number, the seize's target)
to the world_markers canvas (your it10 offer), so a van parked on bay 3 no longer hides its
number now that VehicleStageCards.over is on (f09f4456).
DECISIONS: over on, the wreck fire's vermilion (docs/decisions.md).
Rules applied: depth-ordered-layered-art (the band order decided by filming both settings at
close range, the front box widened by the body's real radius, not a guessed constant), concept-
scene-parity (the real boss arena and quest 1, not a dev rig), generative-artifact-gating (the
fire's colour measured with the game's gate before and after a candidate fix, the fix rejected on
numbers), motion-quality-gating (300-frame on/off clips in sync).

## Calls for the owner (carry to REPORT)
- The wreck fire's colour: built = the sheet's red-orange cores (vermilion by the gate: a danger
  cue, it kills within FIRE_R) on the vehicles band. Options: palette.json lists `vehicles` for
  vermilion's danger_cue; or the fire on the fx band (z 400: over the roofs, a wreck behind a
  facade burns through it); or a yellow fire (+25 deg still fails the gate). See
  fire_tilt70_64ppm_closeup_before_top_after_bottom.png.
- Stage cars over the actors: built ON (servo_van_over_combo_32ppm_off_left_on_right.mp4, right);
  `VehicleStageCards.over = false` is the old look. Bay 3's number hides under a parked van until
  view moves the bay markers to world_markers.
03:10 GATES on f09f4456 (with the n8-view merge): director reel (`res://dev/arena/arena.tscn --
--bot=reel --reel=director --loadout=pistol --rigs --view=<v>`, headless, --fixed-fps 60
--quit-after 7600) top 19/19 all down, tilt70 19/19 all down, 0 SCRIPT ERROR, exit 0 each
(evidence/n8-vehicles/director-reel-it16-*.log). `top` bit-identity (`-- --arena=city --bot=rivet
--seed=2 --rigs`, 300 frames, framemd5): 300/300 video + 300/300 audio equal to top_head.md5, 0
SCRIPT ERROR: view's merge kept top too.
03:12 MEASURED the pickup rust graded: every 10th frame 0-180 of the four city seeds (76 frames):
all non-collar gate clusters are amber lenses (hue > 30); no rust cluster. Not a guarantee (the
pickup is variant 5 of 9 in traffic; not seen near the camera): closed unless one shows.
Evidence json: evidence/n8-vehicles/iteration16.json.
03:12 GATE scenarios (raw `run_scenarios.gd`, on f09f4456 + the merge): 52 ran, 1 failed:
scenario_rig_stress "200 people: rig p50 1.124 ms > 1.000 ms" (the wall-clock budget; ran while
other lanes' Godot runs loaded the machine). Re-run alone via `node tools/tests/run_scenarios.mjs
--only=scenario_rig_stress --quiet-wait=3`: 1 passed. Replay, vehicle drive ("replay":
"identical"), quest1 pass.
MILESTONE 03:17 brief item 5, the traffic density cost on the real drive (until now only the
synthetic card bench of 23:20). bench.lock taken by me (absent before; released by the script),
view's recipe (scratch/vehicles/it16/bench.sh): release export `windows-bench` of f09f4456 (with
the n8-view merge), `RTAI-bench.exe -- --scenario=drive_dense --secs=30 --zoom=<1.0|1.5>
--vsync=disabled --view=<top|tilt70>`, 2 runs each, alternated. evidence/n8-vehicles/bench-it16/:
| run | render CPU avg / p99 ms | draw calls | rig p50 / p99 ms | visible | p99 CPU ms | low 1 % fps |
| 32 px/m top 1 / 2 | 0.355 / 0.717, 0.360 / 0.786 | 371 / 371 | 0.444 / 1.00, 0.444 / 1.07 | 22.7 | 32.5 / 32.0 | 30.1 / 30.5 |
| 32 px/m tilt70 1 / 2 | 0.416 / 0.812, 0.370 / 0.759 | 361 / 363 | 0.581 / 1.44, 0.547 / 1.42 | 24.8 | 32.2 / 32.0 | 28.6 / 29.4 |
| 48 px/m top 1 / 2 | 0.325 / 0.699, 0.351 / 0.727 | 252 / 252 | 0.456 / 1.05, 0.478 / 1.26 | 9.8 | 32.1 / 32.2 | 29.2 / 29.1 |
| 48 px/m tilt70 1 / 2 | 0.326 / 0.686, 0.378 / 0.717 | 254 / 255 | 0.559 / 1.40, 0.606 / 1.41 | 10.9 | 32.1 / 32.1 | 29.7 / 29.9 |
Reading: the cards cost nothing visible on the drive: render CPU within run-to-run noise (+0.01 to
+0.06 ms), draw calls 10 FEWER at 32 px/m (the culled card MultiMesh vs the flat car layers) and +2
to +3 at 48; rig time +0.1 ms p50 / +0.4 ms p99 at 70 (two more people in view: the 70 view shows
more ground; view's it5 finding, not the cars). avg frame 16.7 ms in every run, 0 frames over
50 ms; the p99 ~32 ms / low 1 % ~30 fps are the vsync-off present stalls in BOTH views (the raw
frame_ms alternates ~2 / ~31 ms; view's note). Not CONTENDED by the lock rule (lock held), but
other lanes' Godot processes may have run: GPU-side numbers are not isolated.
MILESTONE 03:21 the combined clip of the set (the lane's evidence rule; none existed):
masters vehicles_set_tilt70_combined.mp4, 49 s, five captioned segments rendered fresh on
03862a1d (vehicle_turn --set=street tilt70 64 px/m; the city tilt70 32 px/m seed 7; vehicle_frame
--clip tilt70 48 px/m (its camera keeps the ground flat: noted in frames.json); vehicle_states
tilt70 64 px/m; the Servo depot combo 32 px/m with over on), 0 SCRIPT ERROR each. frames.json:
entry 1 (dropped depth_tilt70_48ppm_before_after.mp4; its still stays). Scratch frames deleted.

NEXT (iteration 17, in order):
1. If view moves the bay markers to world_markers (my it16 REQUEST): re-film the Servo depot f60
   (combo 32) and check bay 3's number shows over the parked van. Else nothing owed there.
2. Raise the weakest item. Candidates: (a) the drive film's flat ground: vehicle_frame's camera
   does not tilt the ground; film the driven car in the real tilted city instead (main scene
   `--arena=city --view=tilt70` has no car bot: check `--bot=` options for a driving bot, or REQUEST
   view); (b) the parked pickup under the grade (no pickup on screen in 76 frames: find a seed
   with one near the camera, measure its rust against the gate); (c) the depot van at 64 px/m
   under combo (Servo depot --ppm=64) close-up still for REPORT.
3. Exe at the freeze (int-day recipe in docs/decisions.md; the windows-bench export worked on this
   tree at 03:13), REPORT.md by 08:40 with every Call: bike (showcase only vs a sim archetype),
   wreck fire size, the wreck fire's vermilion (palette layer), rotation density (nine views),
   the depot van colour, the pickup C (row vs _c), stage cars over the actors (now ON), the taxi
   paint (+12 built vs +16 vs the sheet's).
Session end 03:22.
