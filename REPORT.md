# REPORT - lane vehicles (`d-vehicles`), day run 2026-11-03

Branch `d-vehicles`, 63 commits on top of main (84 files under project/ + native/, +3827/-55).
The code was last changed at e341b25. That head was gated twice: at 2b62519 (it5) and at eb7d066
(it6, all green). Everything after it is docs. Full log: `JOURNAL.md`.
Frames for the owner: `gtai-masters/day-d5/vehicles/frames.json` (15 entries, all exist), plus `ladder.png`.

## What works in the real game (generated city, real World, real camera)
- **Driving at 48 px/m.** An arcade top-down model with mass, grip, a drift threshold and hysteresis, handbrake slides, reverse,
  per-archetype speed caps and steering slew. It runs on the 60 Hz tick. The 7 archetypes are JSON
  profiles. `VehicleService` is a GDScript WorldSystem, so the native/GDScript parity stays exact by
  construction.
- **Enter, exit and hijack.** You can enter an empty parked car. If you take an occupied sim car, its driver is thrown out.
  Rivet's rig hides while he drives, and the camera eases to car mode with the look-ahead.
- **Carnage.**
  - Car-car hits use mass-based impulses and damage accumulates: D1 -> D2 -> wreck, on the d4 atlases (`_d1/_d2/_hijack`).
    The burnt wreck uses n-d4's wreck art.
  - A wreck explodes (`car_wreck` cue), burns for 24 s, then smokes until it is cleared (45 s).
  - Run-overs emit `pedestrian_struck(slot, killed)`.
  - A burning wreck kills anyone standing in its fire.
- **Sim hooks.**
  - Native `strike()`, `set_car_state()` -> `custom.y` (0 intact, 1 d1, 2 d2, 3 hijacked, 4 wreck),
    and `set_obstacles()`: traffic yields to service cars and passes them. The GDScript twin matches.
  - Tyre marks, honking queues, and the Gearbox "soul-hijacked" teal state (`soul_hijack_traffic(slot)`).
- **API for slice-play.** See `project/features/vehicles/README.md` (`try_enter(at)`, `exit()`, `driving`,
  `spawn_parked`, `soul_hijack_traffic`; the events are `vehicle_entered/exited/hijacked` and `pedestrian_struck`).

## Gates at eb7d066 (evidence/vehicles/it6/, `run.mjs --no-bench`)
- Lint 13/13 over 358 files; unit 370 passed / 0 failed; scenarios 11/11.
- `replay_60s` identical, the vehicle drive replay identical, `rig_stress` green.
- Parity bit-exact over 1200 steps, with the planted mutation caught at step 629.
- Selftest look goldens 11/11 and block goldens 5/5, worst 0.00.
- `vehicle-carnage` and `vehicle-yield` match it5 exactly. `vehicle-drive` differs only in its wall-clock timing fields (CONTENDED).
- **PERF (CONTENDED, headless):** `VehicleService.step` takes about 40-80 us per tick on average while driving.
  The city bench builds a World without vehicles, so section 20 does not measure this cost: it is unmeasured there.

## For the merge (Director)
- **Use the native DLL built from d-vehicles** (`CitySim::set_obstacles`). int-day's older DLL fails
  3 vehicle scenarios.
- **`scenario_city_chase` can flake** on its wall-clock nav budget under contention: it judges the max of 49 samples.
  Run alone, it passes. See REQUEST 9.
- **Shared files touched (minimal):** `core/events/events.gd`, `data/schemas/events.json` (vehicle
  events + `pedestrian_struck`), and `boot/world.gd` (registers VehicleService).

## Open requests (relayed via JOURNAL)
- **1 -> input owner:** map `use` / `handbrake` to TickInput bits 0 / 1. Live input is not wired yet;
  the scenarios drive the car with TickInput.
- **2 + 10 -> d5-combat:** map `pedestrian_struck(slot, true)` to `actor_killed(kind=run_over)`, and later a
  `burned` kind. Run-over blood was verified in a scratch merge with d-combat.
- **3 -> heat owner:** raise heat on `vehicle_hijacked` and `pedestrian_struck`.
- **4 -> d5-city:** the car material should pick its atlas by `custom.y`. Vehicles draws an interim
  overlay for D1 and hijacked traffic.
- **5 -> slice-play:** on-foot movement does not collide with cars.
- **7 -> d5-combat:** a D5 inked fireball for `car_wreck`.
- **9 -> Director:** use a p95 rule for the chase gate.

## Known gaps and deviations
- No load transfer, no surface grip ladder, and no spin from off-centre impacts (decisions.md, vehicle handling feel).
- Rivet takes no fire damage, and fire does not spread from wreck to wreck.
- A fire kill reads as `run_over` downstream until REQUEST 10 lands.
- The fire kill is evidenced by a unit test only, not by a frame.
- The vehicles cost has no bench variant. No AI images were generated today; the one provenance line is for the packed wreck atlas.
