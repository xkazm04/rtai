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
