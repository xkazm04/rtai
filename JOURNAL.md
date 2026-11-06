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
