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
