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
