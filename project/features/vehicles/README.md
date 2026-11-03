# features/vehicles

The player's cars: arcade top-down handling, enter / exit / hijack, crashes and run-overs.
Depends only on `core/` and WorldContext (LAY-05); the city is reached through the
`VehicleWorld` port, which the composition root implements over the bubble sim
(`boot/city_vehicle_world.gd`).

| File | What |
|---|---|
| `vehicle_service.gd` | `VehicleService` (WorldSystem, 60 Hz): `try_enter(at)`, `exit()`, `driving`, `cars`, `spawn_parked()`, `soul_hijack(id)`, `soul_hijack_traffic(slot)` |
| `vehicle_body.gd` | `VehicleBody`: one car and its handling step (steering slew, grip, drift with hysteresis, handbrake, reverse, speed cap, grip-limited and slip-restoring yaw, impact spin) |
| `vehicle_profile.gd` | per-archetype numbers from `data/tables/vehicle_handling.json` |
| `vehicle_damage.gd` | damage rules + the mass-based impulse (two damage states, then a wreck) |
| `vehicle_contacts.gd` | hull vs solid cells, car vs car (three circles per car), car vs people; `hull_points()` = what traffic brakes for |
| `vehicle_cues.gd` | render cues read off the cars after each tick: `crash`, `hit_metal`, `car_wreck` (explosion), `tyre_screech`, `horn` -> `FxTriggers.fire` (fx_triggers.json cue kind `vehicles`; the audio lane hears the same ids) |
| `vehicle_skids.gd` | tyre marks: inked dashes from both rear wheels while a car slides (render only) |
| `vehicle_fire.gd` | a wreck burns for 24 s: the top-down fire loop (`features/fx/art/fx_fire.png`) on its engine bay, on the emissive canvas above the smoke (render only); a held `fire` light off the day grade. The burn time and the fire's place are the sim's (`VehicleContacts.BURN_S` / `NOSE_M`): a person within `FIRE_R` 1.2 m of a burning wreck's fire dies (`pedestrian_struck(slot, true)`, the same event as a run-over) |
| `vehicle_traffic.gd` | the sim traffic the service rammed: render state on custom.y, D2+ taken over as a body |
| `vehicle_world.gd` | the port (an empty world in tests) |
| `vehicle_view.gd` | draws the service cars with the crowd car layer's mesh + look material, one MultiMesh per damage atlas; wrecks print `art/traffic_atlas_wreck.png` (n-d4's burnt wrecks packed in the traffic atlas layout, cell = art id; built by masters `day-d5/vehicles/build_wreck_atlas.py`) |

Input (TickInput): bit `BIT_USE` (0) enter/exit on the press, bit `BIT_HANDBRAKE` (1), `move_y < 0`
throttle (`> 0` brake, then reverse), `move_x` steer.

Traffic yields: every tick the service hands the sim its cars' hull circles
(`CitySimBackend.set_obstacles`, native + GDScript twin); tier-A civilian traffic brakes for them
like for a car ahead. Police cars ignore them (cops ram). A car that stood 2.5 s behind one,
mid-block, pulls out into the oncoming lane when it is clear and returns 7 m past it
(`CitySimCarPass` / native `car_pass.cpp`, flag `F_PASSING`); cars queued behind a service car honk
after about 1 s (`VehicleCues`, render only).

Events (emitter here): `vehicle_entered`, `vehicle_exited`, `vehicle_hijacked`, `pedestrian_struck`.
The camera rig eases to `car` (48 px/m, look-ahead) on `vehicle_entered`.

States (`VehicleBody.State`, also the sim's custom.y on the cars layer): 0 intact, 1 d1, 2 d2,
3 hijacked (Gearbox's teal plate), 4 wreck.

Evidence: `tests/scenarios/scenario_vehicle_drive.gd` (feel route + trace),
`scenario_vehicle_carnage.gd` (hijack + rams + crash cues), `scenario_vehicle_yield.gd` (a parked
car in a lane: obstacles on vs blind; queued time, cars that pass, horns), `dev/showcase/vehicle_frame.tscn` (frames in the real game at
32 / 48 px/m; `--scene=carnage|yield`, `--blind`, `--cue-shots`, `--clip`, `--soul`, `--look=`).
