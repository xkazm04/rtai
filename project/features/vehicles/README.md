# features/vehicles

The player's cars: arcade top-down handling, enter / exit / hijack, crashes and run-overs.
Depends only on `core/` and WorldContext (LAY-05); the city is reached through the
`VehicleWorld` port, which the composition root implements over the bubble sim
(`boot/city_vehicle_world.gd`).

| File | What |
|---|---|
| `vehicle_service.gd` | `VehicleService` (WorldSystem, 60 Hz): `try_enter(at)`, `exit()`, `driving`, `cars`, `spawn_parked()`, `soul_hijack(id)`, `soul_hijack_traffic(slot)` |
| `vehicle_body.gd` | `VehicleBody`: one car and its handling step (grip, drift with hysteresis, handbrake, reverse, speed cap, grip-limited and slip-restoring yaw, impact spin) |
| `vehicle_profile.gd` | per-archetype numbers from `data/tables/vehicle_handling.json` |
| `vehicle_damage.gd` | damage rules + the mass-based impulse (two damage states, then a wreck) |
| `vehicle_contacts.gd` | hull vs solid cells, car vs car (three circles per car), car vs people |
| `vehicle_traffic.gd` | the sim traffic the service rammed: render state on custom.y, D2+ taken over as a body |
| `vehicle_world.gd` | the port (an empty world in tests) |
| `vehicle_view.gd` | draws the service cars with the crowd car layer's mesh + look material, one MultiMesh per damage atlas |

Input (TickInput): bit `BIT_USE` (0) enter/exit on the press, bit `BIT_HANDBRAKE` (1), `move_y < 0`
throttle (`> 0` brake, then reverse), `move_x` steer.

Events (emitter here): `vehicle_entered`, `vehicle_exited`, `vehicle_hijacked`, `pedestrian_struck`.
The camera rig eases to `car` (48 px/m, look-ahead) on `vehicle_entered`.

States (`VehicleBody.State`, also the sim's custom.y on the cars layer): 0 intact, 1 d1, 2 d2,
3 hijacked (Gearbox's teal plate), 4 wreck.

Evidence: `tests/scenarios/scenario_vehicle_drive.gd` (feel route + trace),
`scenario_vehicle_carnage.gd` (hijack + rams), `dev/showcase/vehicle_frame.tscn` (frames in the
real game at 32 / 48 px/m).
