# REPORT - lane vehicles (`d-vehicles`), day run 2026-11-03

Branch `d-vehicles` is 67 commits on top of main: 84 files under project/ + native/, +3827/-55.
The last code change is at e341b25. Everything after it is docs. The code was gated twice: at 2b62519 (it5) and at
eb7d066 (it6, all green). Full log: `JOURNAL.md`.
- **Masters dir** (outside git, `M/` below): `C:\Users\kazda\kiro\gtai-masters\day-d5\vehicles\`.
- **Frames for the owner:** `M/frames.json` has 15 entries, all `game-city` (real World + CityView), and every file exists
  (checked 17:31). Also `M/ladder.png`.
- **Images:** 0 frames rejected this session. The day total is 20, rejected at 11:08 (soul-v1/noir-v1, an input race,
  fixed in dc918c6).

## What works (each claim with its evidence)
- **Driving at 48 px/m.** Arcade top-down handling:
  - mass, grip, and a drift threshold with hysteresis;
  - handbrake slides and reverse;
  - a per-archetype speed cap, plus a steering slew per archetype;
  - the 60 Hz tick; 7 JSON profiles (sedan, taxi, van, pickup, cruiser, ambulance, hatchback).

  Evidence:
  - `evidence/vehicles/it6/vehicle-drive.json`, the fixed-route speed and slip traces (scenario `scenario_vehicle_drive`);
  - `M/drive-20s-48ppm-v2.mp4`, the 20 s clip;
  - `M/skids-v1/375-handbrake-slide.png`;
  - `evidence/vehicles/drive-sheet-v1.png`;
  - unit tests `project/tests/unit/test_vehicle_body.gd`;
  - `docs/decisions.md`, the "vehicle handling feel" and "steering slew" lines.
- **Enter, exit and hijack.**
  - You can enter an empty parked car.
  - If you take an occupied sim car, its driver is thrown out.
  - Rivet's rig hides while he drives, and the camera eases to car mode with the look-ahead.

  Evidence: `M/frames-v2/050-entered-easing.png`, `M/carnage-v2/034-hijack-driver-thrown.png` and `test_vehicle_service.gd`.
- **Car-car carnage.** Hits use mass-based impulses and the lever-arm spin. Damage accumulates D1 -> D2 -> wreck, on the d4
  `_d1/_d2/_hijack` atlases. The wreck explodes (`car_wreck` cue), burns for 24 s, then smokes until it is cleared (45 s).
  The burnt wreck uses n-d4's art.

  Evidence:
  - `evidence/vehicles/it6/vehicle-carnage.json`;
  - `M/carnage-20s-48ppm-v3.mp4`;
  - `M/carnage-v4/742-cue-crash.png`;
  - `M/carnage-v9/260-reverse.png` (before: `carnage-v8/`);
  - `M/carnage-v13/900-after-the-wreck.png`;
  - `M/carnage-v13/2400-burnt-out.png` (before: `carnage-v13-noatlas/`);
  - `M/carnage-night-v1/900-after-the-wreck.png`;
  - `evidence/vehicles/carnage-sheet-v2.png`.
- **Run-overs** emit `pedestrian_struck(slot, killed)`, and a burning wreck kills anyone in its fire.

  Evidence:
  - `M/runover-merged-combat/205-s-bend.png`, a scratch merge with d-combat that shows the blood;
  - the fire kill: unit test `test_vehicle_fire.gd` only, not a frame.
- **Sim hooks (native + GDScript twin).**
  - `strike()`;
  - `set_car_state()` -> `custom.y` (0 intact, 1 d1, 2 d2, 3 hijacked, 4 wreck);
  - `set_obstacles()`: traffic yields to service cars and goes around them.

  Evidence:
  - `evidence/vehicles/it6/vehicle-yield.json`;
  - `M/yield48-v1/180-yield-queued.png` (before: `yield48-blind-v1/`);
  - `M/pass48-v1/540-yield-t540.png` (before: `nopass48-v1/`);
  - `evidence/vehicles/it6/parity.json`.
- **Gearbox slice.** The "soul-hijacked" teal state works on Rivet's car and on traffic (`soul_hijack_traffic(slot)`).

  Evidence: `M/soul-v2/150-ram-approach.png` and `M/soultraffic48-v1/540-yield-t540.png`.
- **API for slice-play.** It is documented in `project/features/vehicles/README.md`:
  - calls: `try_enter(at)`, `exit()`, `driving`, `spawn_parked`, `soul_hijack_traffic`;
  - events: `vehicle_entered/exited/hijacked` and `pedestrian_struck`.

## Gates at eb7d066 (`node tools/evidence/run.mjs --no-bench` -> `evidence/vehicles/it6/`)
- **Lint** 13/13 over 358 files (`lint.json`). Re-run on ebb2ed9 at 17:22: still 13/13.
- **Unit** 370 passed, 0 failed (`unit-tests.json`).
- **Scenarios** 11/11 (`scenario-tests.json`, `.log`):
  - `replay_60s` identical;
  - the vehicle drive replay identical;
  - `rig_stress` green.
- **Parity** bit-exact over 1200 steps, with the planted mutation caught at step 629 (`parity.json`).
- **Selftest:** look goldens 11/11 and block goldens 5/5, worst 0.00 (`selftest.json`).
- **PERF (CONTENDED, headless):** while driving, `VehicleService.step` takes 80.4 us per tick on average, 179 us at most.
  Source: `service_us_avg/max` in `it6/vehicle-drive.json`; the earlier recorded averages range from 51 us (`evidence/vehicles/vehicle-drive.json`) to 224 us (`it2/`). That spread is
contention, not a budget verdict.
  The section 20 city bench builds no vehicles, so the vehicles cost is **unmeasured** there.
  - The one short bench under the lock (11:19, CONTENDED, 1 run of 30 s): PASS, p99 6.82 ms. This is recorded only in the JOURNAL
    11:19 entry.
  - It is not a section 20 verdict.
  - `evidence/vehicles/bench-short-contended.json` is the earlier 10:16 attempt, a failed export, kept as is.

## What does not work / known gaps
- **Live input is not wired.** `use` and `handbrake` are not mapped (REQUEST 1), so the scenarios drive the car through TickInput.
- **No consumers yet** for REQUEST 1-4:
  - no heat on a hijack or a run-over;
  - no `actor_killed(run_over)` on main;
  - the city car shader does not read `custom.y` yet. Vehicles draws an interim D1/hijacked overlay.
- **On foot, Rivet does not collide with cars** (REQUEST 5).
- **Missing handling:** no load transfer, no surface grip ladder.
- **Missing fire:** Rivet takes no fire damage, and fire does not spread from wreck to wreck.
- **The fire kill is unlabelled:** it reads as `run_over` downstream (REQUEST 10) and has no frame.
- **No bench variant for vehicles.** No AI images today; the one provenance line is for the packed wreck atlas.

## What blocked me, and for how long
- **The int-day DLL is too old.** It fails 3 vehicle scenarios, so I built my own native DLL from d-vehicles. No time lost after the build.
  **The Director must merge with the d-vehicles DLL** (`CitySim::set_obstacles`).
- **The `scenario_city_chase` wall-clock nav budget breaks under contention:**
  - 10:32 (13.6 ms vs 2 ms, during my DLL compile);
  - the it5 flake.

  Each cost one re-run, about 5 min. It passes when run alone. REQUEST 9 asks for a p95 rule.
- **Shared `user://test_tmp/city_chunks`:** two lanes running unit tests at once race on it (13:11), about 5 min to diagnose and re-run.
  The `test_noir_shadows` engine flake (11:45) cost about 2 min.
- **A parse error hung a windowed capture** (16:34) until my 400 s timeout, about 7 min. The cause was my own temporary edit.
- **The bench lock was held by other lanes** for most of the afternoon, so I took only one short bench. Not a hard block.
- **Nothing blocked me for more than 10 minutes.**

## For the merge (Director)
- **Use the d-vehicles native DLL.** Run the city_chase gate alone if it flakes.
- **Shared files touched (minimal):**
  - `core/events/events.gd` and `data/schemas/events.json` (vehicle events + `pedestrian_struck`);
  - `boot/world.gd` (registers VehicleService).

## Open requests (relayed via JOURNAL)
- **1 -> input owner:** map `use`/`handbrake` to TickInput bits 0/1.
- **2 + 10 -> d5-combat:** map `pedestrian_struck(slot, true)` to `actor_killed(kind=run_over)`, and later a `burned` kind.
- **3 -> heat owner:** heat on `vehicle_hijacked`/`pedestrian_struck`.
- **4 -> d5-city:** the car material picks its atlas cell by `custom.y`.
- **5 -> slice-play:** on-foot movement collides with cars.
- **7 -> d5-combat:** a D5 inked fireball for `car_wreck`.
- **9 -> Director:** a p95 rule for the chase gate.

## Next steps
1. **Merge:** use the d-vehicles DLL and re-run parity and scenarios on the merged main.
2. **Land REQUEST 1** (live input), so the owner can drive. This is the biggest gap between "works in scenarios" and "playable".
3. **Consumers for REQUEST 2/3/4:** run-over blood on main, heat on hijack, and the atlas picked from `custom.y` (then
   D2 traffic can stay in the sim; see decisions.md "vehicle carnage").
4. **Fire, half 2:** split out `vehicle_burn.gd` (`vehicle_contacts.gd` and `vehicle_service.gd` are at the 200-line limit), Rivet takes fire damage, and
   fire spreads from wreck to wreck. Frame the fire kill once d5-combat's blood is merged.
5. **A drive48 bench variant that includes VehicleService,** so section 20 measures the vehicles cost (uncontended if possible).
