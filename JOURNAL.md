# JOURNAL - lane vehicles (d-vehicles), day run 2026-11-03

## Iteration 1 (10:07 - 11:37, BUILD)

- 10:08 read: AGENTS.md, git log, sim (features/city/sim, native/sim_core), events registry, n-visual
  journal (custom.y contract: 0 intact, 1 d1, 2 d2, 3 hijacked).
- DECISION architecture: the player's cars live in a GDScript WorldSystem (`VehicleService`,
  features/vehicles) on the 60 Hz tick, NOT inside the native bubble sim. Why: parity stays exact by
  construction (the native/GDScript twins are untouched by driving), and handling iterates in data
  without a native rebuild. The sim is reached only through a port (`VehicleWorld`, LAY-05) that the
  composition root implements over the city sim. Rejected: a K_CAR with a "driven" flag inside both
  sims (free traffic avoidance + run-over, but every handling tweak = native + parity work).
- Live input is not wired in the game yet (`InputSource` returns an empty TickInput), so the car is
  driven by TickInput: bit 0 = USE (enter/exit edge), bit 1 = HANDBRAKE, move_y < 0 throttle,
  move_x steer. REQUEST 1 -> slice-play/input owner: map InputMap actions `use` and `handbrake` to
  TickInput bits VehicleService.BIT_USE (0) / BIT_HANDBRAKE (1).
- MILESTONE 10:30 handling model + damage + service + 16 unit tests green, lint 13/13.
  Shared-file changes (minimal): core/events/events.gd + data/schemas/events.json - wired
  vehicle_entered / vehicle_exited / vehicle_hijacked (already planned, emitter features/vehicles),
  added `pedestrian_struck(victim_id: int, killed: bool)` (emitter features/vehicles).
- REQUEST 2 -> d5-combat: actor_killed's only emitter is features/combat (its chokepoint contract).
  Please listen to Events.pedestrian_struck(victim_id, killed=true) and emit
  actor_killed(killer_id = RIVET_ID, victim_id, kind = &"run_over") (add `run_over` to the kind
  values), so blood fires on run-overs. Vehicles does not emit actor_killed itself.
- REQUEST 3 -> police/heat owner: raise heat on Events.vehicle_hijacked and on
  pedestrian_struck (seen or not is the heat ladder's call).
- MILESTONE 10:19 native `strike()` + render-only `set_car_state()` -> custom.y (native + GDScript
  twin, parity strikes two people every 97 steps: exact over 1200 steps, mutation caught at 629).
  godot-cpp was not built in any worktree: `scons` builds it in ~5 min (debug + release DLLs built
  here, git-ignored).
- MILESTONE 10:33 VehicleService registered in World after the CitySystem (boot/world.gd, minimal),
  `CityVehicleWorld` (boot) implements the port, `VehicleView` prints service cars with the crowd car
  layer's mesh + look material, one MultiMesh per damage atlas. scenario_vehicle_drive green.
- FRICTION 10:32 scenario_city_chase failed its 2 ms nav budget (13.6 ms) while my release DLL
  compiled in the background: CONTENDED, re-ran green once the build ended. Do not compile during gates.
- Feel findings from the traces (each fixed, decisions.md 2026-11-03 "vehicle handling feel"):
  1. full lock at 23 m/s spun the car into a wall (needed 46 m/s2 vs 18 grip) -> grip-limited yaw;
  2. one 22 m/s kerb hit wrecked the car (6 hull points summed) -> one hurt per tick, worst normal;
  3. post-handbrake slide lasted 2.5 s / 50 m -> slide_grip +50 %, then slip-restoring yaw +
     drift hysteresis: slip 90 -> 28 deg within 1 s, grip back at 1.2 s;
  4. rams never got past D1 -> ram_per_dv 5.5 (walls stay 3.5).
- Golden path (ai-registry racing-vehicles) APPLIED: speed-attenuated steering (low end 6 m/s, high
  fade above 60 % vmax, grip cap), slip-restoring yaw, drift hysteresis (enter drift_at, leave 0.6x),
  brake never crosses into reverse within a tick, walls reflect the normal only (glancing keeps
  speed), car = chain of 3 circles, damage once per pair per step (per-slot max), split by mass
  (dv per body), closing-speed threshold dv_min. DEVIATIONS: no load transfer (bounded-load-transfer:
  measured small elsewhere; not needed for the slice); no surface ladder (sidewalks drive like road;
  re-check when kerbs/grass get a grip row); no spin from off-centre contacts (no angular velocity
  state; impacts do not rotate cars yet); archetype stats are authored directly, no cost function
  (vehicle-archetype-balance) and no win-share harness. Steering is not shaped (no slew) because live
  input is not wired yet; the shaping stage belongs to the input pipeline (REQUEST 1).
- MILESTONE 10:47 carnage in the real game: hijack a taxi (driver thrown out), three rams, rammed
  sedan disabled at D2 (leaves traffic, coasts, d4 D2 art), player's taxi D1 -> D2. Frames
  masters/day-d5/vehicles/carnage-v2, drive frames-v2, clip drive-20s-48ppm-v2.mp4 (20.07 s).
  Rejected frames: 0 of 26 (every capture straight down). No AI images today: no provenance lines.
- PERF (CONTENDED, headless, native sim): VehicleService.step 41-45 us/tick average while driving,
  max 160-210 us (scenario_vehicle_drive summary). The city bench builds its own World without
  vehicles, so `just bench` cannot see this cost; not run (nothing of mine on its path).

### API for slice-play / missions (features/vehicles, `World.vehicles`)
- `VehicleService.try_enter(at: Vector2) -> int`: nearest empty service car within 3.6 m, else
  hijacks the nearest sim car (driver thrown out); returns the vehicle id or -1.
- `VehicleService.exit() -> Vector2`: gets out on the driver's side; returns where Rivet stands.
- `VehicleService.driving` (VehicleBody or null), `.cars` (all service cars), `spawn_parked(kind,
  at, head, art)`, `soul_hijack_traffic(slot)` (Gearbox: teal plate state on a sim car).
- Input: TickInput bit 0 USE (edge), bit 1 HANDBRAKE, move_y < 0 throttle, move_x steer.
- Events: vehicle_entered(id), vehicle_exited(id), vehicle_hijacked(kind), pedestrian_struck(slot,
  killed). The camera rig already eases to car / on_foot on entered / exited.

### REQUESTS
- REQUEST 4 -> d5-city: the sim now writes custom.y on the cars layer (0 intact, 1 d1, 2 d2,
  3 hijacked, 4 wreck; `SimConst.RL_CARS`, set by `set_car_state`). Please let the car material pick
  the body texture by it (traffic_atlas / _d1 / _d2 / _hijack, the same cell = custom.x; wreck can
  use _d2), e.g. three extra sampler uniforms in the cell shader, `floor(INSTANCE_CUSTOM.y + 0.5)`.
  Until then only D2+ is visible (those cars leave traffic as service bodies, drawn by VehicleView),
  and a soul-hijacked or D1 traffic car looks intact. features/vehicles/vehicle_view.gd is the
  reference (one MultiMesh per texture).
- NOTE -> d5-city: a soft white halo sits on the junction at the city start in on-foot -> car frames
  (frames-v2/050, carnage-v2/034); it is not from vehicles (no vehicles FX/light exists).
- MILESTONE 10:58 traffic shoves standing cars / wrecks (no more driving through them),
  `soul_hijack(vehicle_id)` for service cars, impact spin from off-centre hits (lever = the
  touching circle; capped 4 rad/s, bled 5 rad/s2; in the replay state). Unit 343 + 1, scenarios green.
- Bench: lock held by d5-combat 10:55 -> skipped the bench this iteration (and `just bench` does not
  include vehicles anyway: city_bench builds its own World).
- 11:01 a reused traffic slot starts a fresh damage book (art id per slot); VehicleView follows the
  crowd car material when the look swaps it; features/vehicles/README.md (API for slice-play).
- Gates at ca7078a: lint 13/13, unit 343 (+3 vehicle tests since), scenarios 10/0 incl.
  scenario_vehicle_drive + scenario_vehicle_carnage, parity exact (1200 steps, strikes in).
  `tools/evidence/run.mjs` not run this iteration (bench lock held by d5-combat since 10:55).

NEXT (iteration 2, in order):
1. Run `node tools/evidence/run.mjs` (bench under the lock; label CONTENDED). Bench does not include
   vehicles (city_bench builds its own World) - consider a drive48 variant with VehicleService.
2. When d5-city lands the custom.y pick (REQUEST 4): capture D1 / hijacked traffic frames; then
   consider keeping D2 traffic in the sim (decisions.md "vehicle carnage" re-check).
3. When d5-combat answers REQUEST 2: run-over -> actor_killed(run_over) -> blood; capture frames
   (vehicle_frame default route, tick 205).
4. Live input (REQUEST 1) - then steering shaping (slew, release faster than turn-in) belongs there.
5. Traffic is blind to the player's car (it shoves into it); a sim obstacle list for
   car_desired_speed would make it brake (native + parity work).
6. Explosions (stretch): wreck -> fire/explosion needs an FX source.
- FRICTION 11:08 the soul / noir captures came out with no hijack (Rivet walked off on foot): the
  dev capture set the route input after the bake/prewarm awaits and the world could tick in
  between, so the tick-30 USE press was missed. 20 frames REJECTED (soul-v1, noir-v1, deleted);
  the earlier good captures had won the race. Fixed in dc918c6 (input set at tick 0, logged).
  Also learned: a headless probe script that hits a parse error can hang until timeout (killed by
  timeout; no Godot of mine left running).
- MILESTONE 11:13 Gearbox slice frame: soul_hijack -> teal plate on Rivet's taxi (soul-v2);
  carnage under --look=noir (noir-v2): service cars print in the active look. frames.json now 14
  entries, ladder.png 1280 x 5512. Rejected frames today: 20 of 54 (all for the input race, none
  for camera breaks: every capture straight down).
- 11:14 bench lock taken (vehicles), `node tools/evidence/run.mjs` running (full, with bench).
- 11:17 `node tools/evidence/run.mjs` at dc918c6: lint PASS 13/13, unit PASS 345, scenarios PASS 10,
  parity PASS (exact, 1200 steps, mutation caught at 629), selftest PASS (look goldens 11/11 worst
  0.00, world lock 0.00 %). bench FAIL at export: `build/export/windows-bench/` did not exist in this
  worktree (environment). FRICTION: created the folder.
- 11:19 bench re-run SHORT FORM (`--secs=30 --runs=1`, exported release, windowed), CONTENDED, under
  the lock: PASS, p99 6.82 ms, 1 % low 83 fps, worst frame 50.6 ms, hitches >25 ms 72 (>50 ms 1),
  rigs p99 0.83 ms. Not a section-20 verdict (1 run, 30 s, shared GPU); it covers my native
  fill_render / strike changes only (the bench World has no VehicleService). Copied to
  evidence/vehicles/bench-short-contended.json. Lock released 11:19.
- NEXT (unchanged order above); add: run the full-length bench (3 x 60 s) once the machine is quiet.

## Iteration 2 (11:20 - 12:50, BUILD)

- 11:21 read: journal, git log, other lanes' journals. d-audio REQUEST 2 -> vehicles (fire horn /
  crash / tyre_screech / hit_metal through FxTriggers.fire); d-slice answered REQUEST 1 (bits 0/1 =
  car / handbrake in input_actions.json, LiveInput hookup in World is a Director merge note);
  d-city REQUEST 3 (cruiser vermilion) is done by d5-cast (40d1e40); REQUEST 4 (custom.y pick) still
  open. d-combat did not take REQUEST 2, but it does not need to: a lethal strike() sets the person
  M_DEAD, CityFxFeed fires the `death` cue, and d-combat's CombatBlood (boot/city_blood.gd) bleeds
  on that cue, along the body heading strike() sets = the hit direction. So run-overs will bleed
  after the merge with no new hook. (actor_killed run_over is still wanted for quest facts / heat.)
- MILESTONE 11:27 c4f6d46 VehicleCues: render-only cues read off the service cars after each tick:
  crash (8+ hp in a tick; spark + debris + crash shake), hit_metal, car_wreck (explosion + smoke +
  debris + explosion shake: the explosion stretch goal, with fx.json's existing kinds), tyre_screech
  (slide start above 7 m/s), horn (rammed traffic, every 45 ticks at most). New fx_triggers cue
  kind `vehicles` (schema enum + 5 rows; shared table, minimal). Ids = the audio lane's cue ids;
  their FxTriggers.sink hears them after the merge. Carnage scenario asserts a crash cue (4 crash,
  2 horn). Unit 350.
- 11:30 dev capture --cue-shots + a 4th ram that wrecks the taxi. carnage-v3 REJECTED (21 frames):
  the plan kept throttle after the wreck ejected Rivet, so he walked north through buildings onto
  a roof (on-foot movement does not collide: not vehicles' code; NOTE -> slice-play / player
  owner). Fixed the plan (neutral after 748); carnage-v4 good: 742 explosion, 766 Rivet thrown out
  at 32 px/m beside the pile-up.
- MILESTONE 11:35 fbf5871 traffic yields to service cars: sim input set_obstacles(xy) (native
  CityCore + binding + GDScript twin, OBST_MAX 24 in sim_constants.json); VehicleService hands the
  hull circles (3 per car, up to 8 cars) every tick through the port. Parity re-places an obstacle
  list every 40 steps: EXACT over 1200 steps, mutation caught at 629. Native rebuild 20 s (debug +
  release), sim_core tests 0 failed. decisions.md line "traffic yields to service cars".
- MILESTONE 11:41 cbc0e2d scenario_vehicle_yield (real World, 40 s, A/B): blind 4 rear-ends /
  46 hp lost / shoved 48 m; yield 0 / 0 / stays put. Real-game frames yield-v1 vs yield-blind-v1
  (tick 180, 32 px/m). Known limit: queued traffic waits behind a parked car (no going around).
- frames.json 14 entries (dropped 3 weaker drive frames for the wreck, the ejection, the yield
  pair); ladder.png rebuilt 1280 x 9242. Rejected today: 41 of 87 frames (all input-plan faults,
  0 camera breaks).
- CORRECTION to the 11:41 count: frames captured today 125 (54 iteration 1, 21 carnage-v3, 21
  carnage-v4, 21 carnage-v5, 8 yield); rejected 41 (20 input race, 21 carnage-v3 roof walk);
  carnage-v5 deleted as a duplicate of v4 (same deterministic ticks, nothing new: the rammer is a
  patrol cruiser and police ignore obstacles by design). 0 camera breaks.
- MILESTONE 11:44 run-over -> blood VERIFIED in a scratch merge d-vehicles + d-combat (local
  worktree, merge was clean apart from JOURNAL.md; deleted afterwards): drive route tick 205 shows
  red blood at the impact, the body slid on (runover-merged-combat/205 vs frames-v2/205).
  actor_killed stays combat's: events.json says the damage chokepoint is the only emitter, so
  vehicles does NOT emit it (REQUEST 2 stays open for quest facts / kill hit-stop / heat).
- MILESTONE 11:46 1e737c8 steering slew: per-archetype steer_in_s (0.14 hatchback .. 0.26 van /
  ambulance), release and counter-steer 2x faster; the wheel is replay state. golden path
  steering-feel-profile-shaping APPLIED (was deferred in iteration 1 for want of live input;
  slice-play's LiveInput now gives digital full lock). decisions.md line. Unit 353.
- FRICTION 11:45 test_noir_shadows failed once ("Parameter t is null", engine error), passed on
  the re-run with no change: the flake the audio lane also saw. Not vehicles' code.
- MILESTONE 11:50 75ee599 tyre marks (VehicleSkids, render only, VehicleView's child under the
  shadows): both rear wheels lay inked dashes while a car slides above 4 m/s; ring of 480, oldest
  fade. Frames skids-v1 (375 slide, 440 recover). Unit 356.
- 11:53 carnage-20s-48ppm.mp4 (20.03 s, CONTENDED: one frame per 4 ticks at 15 fps = real time):
  hijack, rams with sparks/debris + crash shake, the explosion, ejection to 32 px/m, the pile-up.
  Contact sheet (every 10th frame): 0 camera breaks. Temp PNGs deleted.
- Item 4 (heat): the hook is the events (vehicle_hijacked, pedestrian_struck); HeatMeter.raise_by()
  exists (features/police) but only the collect-call stage builds one, and "a human saw it" is the
  police owner's call: REQUEST 3 stands (police/heat owner: on vehicle_hijacked and on
  pedestrian_struck(killed) call heat.raise_by(1) when a human sees Rivet).
- REQUEST 5 -> slice-play (player/on-foot owner): on-foot movement does not collide with
  buildings in the city World (carnage-v3: held "up" walked Rivet onto a roof after a wreck threw
  him out). Vehicles only calls set_focus(door, false) on exit.
- REQUEST 2 (restated) -> d5-combat: run-over kills already bleed through the `death` cue. Still
  wanted: actor_killed(RIVET_ID, slot, &"run_over") from your chokepoint on
  Events.pedestrian_struck(slot, killed=true) (quest facts, kill hit-stop, heat), plus `run_over`
  in the kind values.
- 12:10 `node tools/evidence/run.mjs` at 75ee599 under the bench lock (vehicles, 11:54 - 12:10,
  released): lint PASS 13/13, unit PASS 356, scenarios PASS 11 (incl. vehicle_drive replay
  identical, vehicle_carnage, vehicle_yield), parity PASS (exact, 1200 steps, obstacles in,
  mutation caught at 629), selftest PASS (look goldens 11/11 worst 0.00, block goldens 5/5, world
  lock 0.00 %). bench FAIL on one rule only: over50.unexplained = 1 (one >50 ms hitch nobody
  explains), CONTENDED (six other lanes on the GPU); p99 6.37 ms, 1 % low 88 fps, rigs p99 0.76 ms.
  The bench World has no VehicleService; my only change on its path is a loop over 0 obstacles in
  car_desired_speed. Copied to evidence/vehicles/it2/ (+ vehicle-drive/-carnage/-yield.json).
- 12:14 yield pair at 48 px/m (--car-zoom): yield48-v1 vs yield48-blind-v1 (the shoved car lays
  tyre marks: parked cars hold the handbrake). frames.json 15 entries, ladder.png 1280 x 8442.
  Captured 16 more (8 + 8), rejected 0, camera breaks 0.

NEXT (iteration 3, in order):
1. Traffic stuck behind a stopped service car waits forever (no going around): give a waiting
   tier-A car a lane change or a creep-past after ~3 s (native + twin + parity), or let wrecks
   leave the lane sooner. Measure with scenario_vehicle_yield (add a "time queued" metric).
2. REQUEST 4 (d5-city, custom.y atlas pick) is still open after two iterations: D1 / hijacked
   traffic still looks intact. If d5-city cannot take it, ask the Director whether vehicles may
   ship it in the car cell shader (three samplers + floor(INSTANCE_CUSTOM.y + 0.5)).
3. Audio: the cue ids are in; after the merge, check the audio sink hears crash / tyre_screech /
   horn / hit_metal (d-audio FxTriggers.sink) and record a clip with sound.
4. Horn from queued traffic (VehicleCues + cars_near: a stopped car behind a service car honks).
5. Explosion art: car_wreck uses the D4 explosion kind (small starburst + light halo); ask
   d5-combat whether a D5 inked fireball / burning wreck sprite fits their FX sheet.
6. Full-length bench (3 x 60 s) once the machine is quiet; a drive48 variant with VehicleService.
- MILESTONE 12:15 b952920 wrecks keep smoking (`wreck_smoke` cue, fx smoke, every 75 ticks per
  wreck, 1.7 m ahead of the centre). Iterated in-engine on the same tick 900: every 40 ticks at the
  centre hid the wreck art (carnage-v6, REJECTED 11 frames, deleted); every 75 at the centre still
  covered the bodies (carnage-v7, REJECTED 11, deleted); nose offset keeps the dented rear halves
  readable (carnage-v8, kept). Unit 357, scenarios 11/11 at b952920. frames.json 15 (aftermath
  pair carnage-v4/900 -> carnage-v8/900), ladder 1280 x 8042.
- Day totals so far: 157 frames captured, 63 rejected (20 input race, 21 roof walk, 22 smoke too
  heavy), 0 camera breaks. No AI images (no provenance lines).
- 12:17 REQUEST 4 (custom.y atlas pick) still not in d-city (checked its shaders): NEXT 2 stands.
- 12:19 NEXT 1 scoped (not started: it does not fit safely before 12:50): cars do not use the
  per-slot `t1` timer (only people do), so a "blocked by an obstacle for 3 s" count needs no new
  state array; the go-around itself = a temporary lane offset to the oncoming lane while
  f < 12 m and the oncoming lane is clear (hash query), back once past. It has to respect the
  junction reservation (`_r.reserve`) and stay identical in car_drive.cpp / sim_cars.gd; parity
  then needs an obstacle in a lane with a car behind it (the current parity list puts points
  9 m ahead of cars, so it already exercises the trigger).
- Session end 12:20: tree clean, no Godot process of mine left, scratch worktree removed, bench
  lock released at 12:10. Masters: gtai-masters/day-d5/vehicles (frames.json 15, ladder.png,
  carnage-20s-48ppm.mp4, clip-carnage-sheet.png).

## Iteration 3 (12:18 - 13:48, BUILD)

- 12:19 read: journal, git log. Bench lock held by `collisions` (12:17), not needed yet.
- MILESTONE 12:27 dfb5f81 traffic passes a stopped service car (NEXT 1): a tier-A civilian car
  that stood 2.5 s behind an obstacle point in its own lane, mid-block (no junction planned), with
  the oncoming lane clear (no obstacle; no car from 8 m behind to 36 m ahead, hash query r=6),
  sets the new per-slot flag F_PASSING (8, sim_constants.json, regenerated) and steers to the
  oncoming lane line until every obstacle is 7 m behind; standing 6 s while passing aborts. Native
  car_pass.cpp (+ Car::ln, the per-step lane line car_steer reads) and GDScript twin
  CitySimCarPass (sim_cars.gd stays 194 lines). Native rebuild 29 s, sim_core tests 0 failed.
  Parity: obstacles now re-placed every 300 steps (was 40) so cars stand long enough to pull out;
  EXACT over 1200 steps, 6 pass starts counted with a temporary log (removed), mutation caught at
  629. scenario_vehicle_yield: new metrics queued_s / passed / first_pass_s and a MIN_PASSED 2
  assert. Same scenario with passing disabled (temporary native build, PASS_WAIT_S 1e9): queued
  80.5 s, passed 0 (the new assert FAILS it: the gate can fail); with passing: queued 13.6 s,
  passed 3 of 3, first at 9.25 s, rear-ends 0. Gates: lint 13/13, unit 357, scenarios 11/11.
  decisions.md line "traffic passes stopped service cars". Shared files touched (minimal):
  tools/gen_constants/sim_constants.json (+ generated sim_constants.h/.gd), native/SConstruct (CORE
  list), city_parity.gd (OBST_EVERY). MERGE NOTE: another lane adding a flag constant would collide
  on bit 8.
- 12:33 526151b dev capture: the yield scene parked on a junction crosswalk (seed 31), where the
  pass does not fire by design (mid-block only): 10 frames yield48-v2 REJECTED (scene, not camera)
  and deleted. Now parks 24 m into the straight like the scenario, Rivet on the kerb; shots at
  300..720. Captured pass48-v1 / pass32-v1 (real game) and nopass48-v1 / nopass32-v1 (same scene,
  temporary no-pass DLL; debug DLL rebuilt with 2.5 afterwards, release untouched). 40 frames,
  0 rejected, 0 camera breaks. Pair: 540 at 48 (three queue vs one past), 420 at 32 (pulling out).
- frames.json 15 (added the two pass pairs; dropped the on-foot frame and the 32 px/m yield pair,
  which the 48 one covers), ladder.png 1280 x 7564, now rebuilt by masters/.../ladder.py.
- MILESTONE 12:37 8dbf14b queued traffic honks (NEXT 4): VehicleCues checks every 15 ticks for a
  civilian sim car standing 0-13 m behind any service car in its path (cars_near 14 m, speed
  < 0.5, lateral < 2 m); 4 checks in a row (~1 s) = `horn` at the queued car's position, then
  every 6 checks (1.5 s) while it lasts; the wait resets when the queue clears. Render only (the
  yield scenario's sim metrics are unchanged to the digit; 6 horns in the yield arm, 0 blind).
  fx_triggers.json horn doc string updated (shared table, one string). Unit 359 (+2).
- 12:38 evidence run refused: dirty tree (journal timestamp fix). Committed, lock re-taken 12:39.
- 12:53 `node tools/evidence/run.mjs` at 27f4192 under the bench lock (vehicles 12:39 - 12:53,
  released): lint PASS 13/13, unit PASS 359, parity PASS (exact, 1200 steps, mutation at 629),
  selftest PASS (look goldens 11/11 worst 0.00, block goldens 5/5). scenarios FAIL 1 of 11:
  scenario_city_chase flow field max 6150 us > 2 ms budget (last field 135 us): a contention spike.
  Re-ran it alone twice: PASS (max 380 us, 144 us). Flow field is not vehicles' code. bench FAIL,
  CONTENDED (seven lanes, one GPU): p99 11.1 ms, 1 % low 43 fps, worst frame 2662 ms (a machine
  stall), >50 ms hitches 97 (7 unexplained); misses p99Cpu, low1Fps, worstSwap, over50.unexplained.
  At 12:10 the same gate gave p99 6.37 ms. The only vehicles change on the bench path is
  car_pass's early-outs per car (no obstacles in the bench World, so no hash query): not a
  verdict either way; re-run when the machine is quiet. Copied to evidence/vehicles/it3/.
- MILESTONE 12:57 d243679 rammed D1 and soul-hijacked sim traffic now SHOW their state (interim
  answer to REQUEST 4, inside features/vehicles): VehicleView lays the D1 / hijacked atlas cell
  over every sim car in VehicleTraffic.state at the sim's own car transform (CitySimRender: x axis
  head * CAR_L, y axis left normal * CAR_W, custom.x = variant). The city's write_render reads the
  same tick's state with no interpolation, so the overlay sits exactly on the crowd layer's car (no
  ghost edge at 48 px/m). One cars_near pass per frame, only while the book is non-empty.
  Frames: carnage-v9 vs carnage-v8 (same ticks): 260 the rammed sedan shows cracked glass and
  dents, 900 a second D1 car beside the wreck. Other diffs between v8 and v9 are light flicker
  (034 the halo moves) and the 060/360/660 full-frame diffs: not from this change (render-only,
  sim identical). Unit 359, vehicle scenarios 3/3. When d5-city's shader pick lands, the overlay
  draws the same cell twice (harmless; remove it then).
- 12:59 dev capture `--soul-traffic` (soul_hijack_traffic on every civilian car within 60 m at
  tick 30): soultraffic48-v1, the queued sedans and the van carry the teal plate, and the overlay
  follows the passing car through its turn (540). Brief item 5 now has traffic evidence, not
  only Rivet's own taxi.
- frames.json 15 (+D1 traffic pair, +soul traffic; dropped the noir carnage frame and the
  carnage-v2 450 frame), ladder 1280 x 7964. Frames this iteration: 72 captured (10 yield48-v2
  rejected: scene parked on a junction; 62 kept), 0 camera breaks.
- 13:02 carnage-20s-48ppm-v2.mp4 (20.07 s, CONTENDED capture, 1 frame per 4 ticks at 15 fps = real
  time): the same deterministic run as v1 with the D1 overlay on rammed traffic. Contact sheet
  (31 frames, clip-carnage-v2-sheet.png): 0 camera breaks; the wider opening frames are Rivet on
  foot at 32 px/m before the hijack. frames.json entry now points at v2 (v1 as before). Temp PNGs
  deleted.
- MILESTONE 13:07 cb21859 unit tests for CitySimCarPass on the reference sim: a car waits more
  than PASS_WAIT_S, pulls out more than 3 m, is back within 0.6 m of its lane 24 m past the
  obstacle (the lane change back takes ~17 m of travel); a second obstacle in the oncoming lane
  keeps it behind. (At 900 ticks the car had turned south at the next junction: assert at the
  moment it is past, not at the end.)
- MILESTONE 13:11 050b007 VehicleView tests: marked traffic gets one D1 and one hijacked instance,
  unmarked none, an empty book none; `car_xf` (now shared by service cars and the overlay) equals
  the native render rows. Headless MultiMesh does not keep instance data (reads back identity), so
  the transform is tested on the pure helper. Unit 364.
- FRICTION 13:11 I committed 050b007 with the unit run chained by `;` and it reported 3 failures:
  test_noir_shadows (the known engine flake) and test_city_streaming x2 ("stale bake generator
  v-1"): `user://test_tmp/city_chunks` is SHARED by every worktree (same project name = same user
  data dir), so two lanes running unit tests at once race on it. Re-run: 364 passed, 0 failed.
  Lesson: gate the commit with `&&`. REQUEST 6 -> Director / tests owner: per-worktree user dir
  for tests (e.g. `--user-data-dir` or a DIR keyed on the res:// path hash) to stop the race.

## Iteration 4 (15:41 - 17:00, BUILD)

- 15:41 read: journal, git log. The NEXT list is done except 5 (explosion art) and 6 (quiet bench).
  d-audio's three-way merge check (13:15) heard every vehicles cue (crash, car_wreck, hit_metal,
  horn, tyre_screech, thud) and says its REQUEST 2/4 to vehicles are done; d-slice's REQUEST 1
  (car key bits) is answered. Heat: HeatMeter exists only in the quest 1 stage (collect_call);
  the city World has none, so the emit-only hook (vehicle_hijacked / pedestrian_struck) stands.
- MILESTONE ac26e26 wrecks burn (NEXT 5, without new art): the explosion source exists (car_wreck),
  the burning wreck did not. VehicleFire (render only, VehicleView's child, moved by the
  composition root onto the emissive canvas just under the blast's glow twin): for 24 s after a
  car becomes a wreck the top-down fire loop (features/fx/art/fx_fire.png, the quest crate fire
  art, 4 frames at 10 fps off the wreck's own sim clock) plus an ember cell sit on the engine bay,
  shrinking over the last 6 s; a held `fire` light (lights.json) off the day grade only.
  Iterated in the real game (vehicle_frame carnage, same ticks): carnage-v10 (fire under the
  smoke on the actors band: only the light halo showed, pink smoke) REJECTED 20 frames; carnage-v11
  (emissive, day light on: the halo washed the smoke pink) REJECTED 20; carnage-v12 kept (inked
  flames in grey smoke, both wrecks). carnage-night-v1 (new dev flag `--grade=night`, 7c66762):
  the fire light makes the wrecks the brightest point on the street. 60 frames, 40 rejected,
  0 camera breaks. Colour: the fire art is vermilion; a burning wreck is a danger cue, which the
  doctrine keeps vermilion for. Unit 367 (+3: burn curve, which wrecks burn, one held light per
  burning wreck at night, none by day, freed when it goes out). Lint 13/13.
- frames.json 15 (aftermath pair now carnage-v9 -> carnage-v12 at tick 900; +night aftermath;
  dropped carnage-v4/766), ladder 1280 x 7964, crop-fire-v12.png (before/after crop, 2x).
- 15:59 gates at 080de9b (`node tools/evidence/run.mjs --no-bench`): lint 13/13, unit 367, scenarios
  11/11, parity EXACT (1200 steps, mutation caught at 629), selftest PASS (look goldens 11/11 worst
  0.00). Copied to evidence/vehicles/it4/. Bench SKIPPED: bench.lock taken by `d5-city` at 15:59
  (fresh) between my check and my noclobber create (the create refused, as designed).
- 16:00 carnage-20s-48ppm-v3.mp4 (20.0 s, CONTENDED capture, 287 frames over 1204 ticks at 14.35
  fps = real time): the wrecks now burn after the blast. Sheet clip-carnage-v3-sheet.png (32
  frames): 0 camera breaks. Scratch PNGs deleted.
- MILESTONE 0bfaaa1 wrecks print n-d4's burnt wreck art: car/van/pickup/cruiser_wreck.png were
  drawn last night but never wired (a wreck drew its d2 cell darkened to a lavender grey). Packed
  (no new art) into features/vehicles/art/traffic_atlas_wreck.png in the traffic atlas layout
  (cell = sim art id; van_wreck stands in for the ambulance), built by masters
  day-d5/vehicles/build_wreck_atlas.py; provenance line added (derived from d4n_veh_c). Import =
  the project defaults (lossless, no mips, fix_alpha_border). VehicleView has a WRECK layer;
  without the atlas it falls back to the old darkened d2. Unit 369 (+2). Frames carnage-v13 (900
  and the new 2400 burnt-out shot, f2259ec): the charred bodies read under the fire and smoke,
  where v12 showed pale lavender; 21 frames, 0 rejected, 0 camera breaks. crop-wreck-v13.png.
- frames.json 15 (aftermath -> carnage-v13/900 vs carnage-v9/900, +burnt-out 2400, clip -> v3;
  dropped pass32 420), ladder 1280 x 8364.
- 16:20 BENCH, full length (NEXT 6; `node tools/bench/run.mjs`, exported release build, windowed,
  3 runs x 4 scenarios x 60 s) at b079c4e under bench.lock (vehicles 16:07 - 16:20, released).
  CONTENDED (seven lanes, one GPU): p99 4.79 ms, 1 % low 131 fps, worst swap 14.0 ms, worst frame
  71.6 ms; >25 ms hitches 104, >50 ms 6 (present 4, outside 0, unexplained 2); rigs p99 0.88 ms.
  Misses only over50.unexplained (2). At 12:53 (contended) the same gate gave p99 11.1 ms and 7
  unexplained: this run is the better machine state, not a vehicles change (the bench World has
  no VehicleService; VehicleFire / the wreck atlas are not on its path). Per-scenario files of the
  last run + summary in evidence/vehicles/it4/bench/.
- REQUEST 7 -> d5-combat: car_wreck still fires the D4 `explosion` kind (paper puffs + vermilion
  rim). If your FX sheet gets a D5 inked fireball, the vehicles cue only needs the kind id in
  fx_triggers.json `car_wreck`; the burning wreck after it now uses features/fx/art/fx_fire.png.
- REQUEST 8 -> audio: a burning-wreck crackle loop. `VehicleView.fire.burning()` returns the ids of
  the burning wrecks each frame (positions: VehicleService.cars); 24 s per wreck, then smoke only.
- 16:25 gates at ac7827b (HEAD, after the wreck atlas; `run.mjs --no-bench`): lint 13/13, unit 369,
  parity EXACT (mutation at 629), selftest PASS (goldens 11/11 worst 0.00); scenarios 10 of 11:
  scenario_city_chase FAIL on its wall-clock nav budget, max field 6964 us > 2 ms with last field
  148 us and the sim outcome identical to the passing runs (cops 60.7 -> 6.5 m, 49 fields). The
  same contention spike as at 12:53. Re-ran it alone twice at 16:28: PASS (max 215 us, 183 us).
  Flow field is not vehicles' code. Copied to evidence/vehicles/it4/head/ (with the log).
  REQUEST 9 -> Director / city-nav owner: the chase gate judges the MAX of 49 wall-clock samples;
  on a seven-lane machine one descheduled field fails it. A p95 or "2 of 49 over" rule would keep
  the budget honest without the flake.
- Iteration totals: frames captured 101 (carnage-v10 20 + v11 20 rejected and deleted; v12 20,
  night 20, v13 21 kept) + 287 clip frames (assembled, scratch deleted); 40 rejected, 0 camera
  breaks. No new AI images (one provenance line for the packed wreck atlas). Bench 1 run (lock).

NEXT (iteration 5, in order):
1. (done 16:36 / 16:39, see below)
2. REQUEST 7 / 8 answers (D5 fireball kind, burning-wreck crackle) are one-line consumers here.
3. Fire as gameplay (stretch): a person or Rivet standing in a burning wreck's fire takes damage,
   a burning wreck can set the car it touches alight (chain wrecks). Sim-side, so: the service step,
   deterministic, a carnage scenario metric.
4. Bench a drive48 variant with VehicleService (the bench World has none today, so the vehicles
   draw cost - VehicleView, VehicleFire, skids - is not on any bench path).
5. Owner sync items: cop blue on the cruiser light bar and the service cruiser (d5-cast's art; the
   frames still show the vermilion bar), Rivet's size beside a car (d5-cast).
- 16:34 FRICTION: a temporary before-frame edit (`tex.append(null)`) left `burnt` unused = a parse
  error (warnings are errors), and the WINDOWED capture hung until my 400 s timeout instead of
  exiting. Restored the file at once; lesson (again): headless --import and grep SCRIPT ERROR
  before any windowed run. Retry pointed the path at a missing file (the fallback), checked the
  import, captured, `git restore`d: carnage-v13-noatlas (the old lavender d2 wreck) vs carnage-v13
  at 2400 = NEXT 1 done; crop-burnt-2400.png; frames.json 2400 entry now has its before. 21 more
  frames, 0 rejected, 0 camera breaks.
- 16:39 carnage-night-20s-48ppm-v1.mp4 (20.0 s, `--clip --grade=night`, CONTENDED capture, 287
  frames at 14.35 fps = real time): headlight cones, street lamps, and after the blast the two
  burning wrecks glow vermilion / paper. Sheet clip-carnage-night-v1-sheet.png (32 frames): 0
  camera breaks. Linked from the night frame entry (frames.json stays 15). Scratch deleted.
- Session end 16:41: tree clean after this commit, no Godot process of mine left, bench lock not
  held, scratch deleted. Masters: gtai-masters/day-d5/vehicles (frames.json 15, ladder.png 1280 x
  8364, carnage-20s-48ppm-v3.mp4, crop-fire-v12.png, crop-wreck-v13.png, build_wreck_atlas.py).

## Iteration 46 (16:39 - 17:00, BUILD; freeze 17:00)
- 16:39 read the JOURNAL tail + git log. d-audio answered REQUEST 8 on its side (fire bed proven on
  this lane's carnage route in a scratch merge; car_wreck cooldown 8 ticks). d-audio's five-way
  merge check FRICTION for the Director: the scenarios need the native DLL BUILT FROM d-vehicles
  (`CitySim::set_obstacles`); int-day's older DLL fails 3 vehicle scenarios.
- MILESTONE 16:43 e341b25, NEXT 3 (fire as gameplay), first half: `VehicleContacts.burn(b, world)`,
  called for every service car each tick in `_collide` (wrecks stand still, so it runs before the
  standing-car early return). A WRECK younger than BURN_S kills every living person within
  FIRE_R 1.2 m of its fire (NOSE_M 1.5 m ahead of the centre): `strike_person(slot, ZERO, true)` ->
  `pedestrian_struck(slot, true)`: the same event as a run-over (d5-combat's chokepoint maps it to
  actor_killed per REQUEST 2; vehicles still does not emit actor_killed itself).
  BURN_S / NOSE_M moved from VehicleFire (render) to VehicleContacts (sim); VehicleFire reads them,
  so the drawn fire and the lethal one cannot drift. Deterministic (sim tick, no RNG).
  Deviation: the kill reuses the run-over event, so downstream it reads as `run_over`, not as
  `burned`. A distinct cause needs an events.json change (a shared file), so it was not done in the
  last 20 minutes. Not yet: Rivet taking fire damage, wreck-to-wreck spread.
- REQUEST 10 -> d5-combat (with REQUEST 2): a `burned` kill kind. Vehicles can emit a
  `pedestrian_burned(slot)` (events.json) or pass a cause on pedestrian_struck, whichever your
  chokepoint prefers. Today a fire kill arrives as pedestrian_struck(slot, true).
  Unit test `test_a_burning_wreck_kills_whoever_stands_in_its_fire` (inside 1.2 m dies, 4 m lives,
  burnt-out kills nobody). Gates at e341b25: lint 13/13 (gd-size: service 200, contacts 200),
  unit 370/0, scenarios 11 ran 0 failed (replay_60s final cbeb734ff9b97c41, vehicle drive replay
  identical, rig_stress green). Native code untouched, so parity is unaffected (evidence run below).
  No new frame: the fire kill shows as d5-combat's blood, which is not on this branch's capture
  path. So it is evidenced by test only, not by a frame.
- 16:45 evidence run 1 (`run.mjs --no-bench`): unit marked FAIL ONLY because I committed the
  JOURNAL/README edits while it ran (the run's tree-changed guard; 370 passed, 0 failed). Own
  mistake: do not touch the tree during an evidence run. Re-ran at 2b62519 (tree clean, 16:46-16:49):
  lint 13/13, unit 370/0, parity EXACT (1200 steps, mutation caught at 629), selftest PASS (look
  goldens 11/11 worst 0.00, block 5/5); scenarios 10 of 11: scenario_city_chase FAIL on the
  wall-clock nav budget again (max field 6879 us, last 146 us, sim outcome identical: cops 60.7 ->
  6.5 m, 49 fields). Re-ran alone twice at 16:49: PASS (max 154 us, 141 us). The full scenario run
  at e341b25 (16:42) was 11/11. Same flake as 12:53 / 16:25 (REQUEST 9). Copied to
  evidence/vehicles/it5/ (with the scenario log). Bench not run (no time before the freeze).
- Iteration totals: 0 frames (the fire kill is evidenced by unit test + gates, not by a frame),
  0 rejected, no AI images, no provenance lines, no bench lock taken. No Godot process of mine left.

NEXT (after the 17:00 freeze / next session, in order):
1. Fire as gameplay, half 2: Rivet takes damage in a burning wreck's fire (on foot), and a burning
   wreck sets the service car it touches alight (chain wrecks). Both are sim-side in VehicleContacts
   (now at 200 lines: split the fire rules into a `vehicle_burn.gd` first). Add a fire-kill count
   to the carnage scenario metrics.
2. Frame the fire kill once d5-combat's blood is merged: a crowd person walking into the fire at
   48 px/m, before/after on carnage-v13's route.
3. REQUEST 10 (burned kill kind) and REQUEST 2 (run_over -> actor_killed) answers are one-line
   consumers here.
4. The Director's merge: use the native DLL built from d-vehicles (set_obstacles), per d-audio's
   five-way merge check. int-day's DLL fails 3 vehicle scenarios.
5. A drive48 bench variant with VehicleService (the vehicles draw cost is on no bench path).

## Iteration 47 (16:50-16:55, BUILD, 10 min to freeze)
- Did not start new code. A split of VehicleContacts into `vehicle_burn.gd` would need a full gate
  run (unit + scenarios + evidence takes 5-8 min on the contended machine), and that cannot finish
  and be checked before 17:00. Rule: nothing goes on the branch that has not passed the gates.
- Checked the handoff: `gtai-masters/day-d5/vehicles/frames.json` has 15 entries and every file
  exists. `ladder.png` is from 16:36. No Godot process of mine is running. The tree is clean at
  cd992e9 (the last gated evidence run is at 2b62519 and is in evidence/vehicles/it5/).
- 0 frames, 0 rejected, no AI images, no bench lock taken.
- NEXT: unchanged from iteration 46 (fire half 2 after splitting `vehicle_burn.gd` first; frame the
  fire kill once d5-combat's blood is merged; REQUEST 2/10 consumers; use d-vehicles' native DLL at
  merge; a drive48 bench variant with VehicleService).
