# features/souls: ghost powers (Hauler, Gearbox)

Rivet carries the souls of dead robots from his line (pitch section 4/5). Each soul is a power.
The soul **trail** stays off (owner verdict, 2026-11-03): powers are not the trail. Teal = souls.

## Data: `data/tables/powers.json` (`gtai.powers/1`)

- `rows`: one per power: `duration_s`, `cooldown_s`, `madness_cost`, `interrupt_on`
  (`car`, `hit`, `knocked_down`, `stunned`), `bark_on`/`bark_off` (voice ids, audio later),
  `action` (InputMap: `power_hauler` Q / LB, `power_gearbox` G / RB).
- `madness`: the Madness meter stub: a power adds its cost, the meter decays while no power runs,
  a power whose cost would pass `max` is refused.
- `hauler`, `gearbox`: each soul's tuning (doc strings in the table).

## Code

- `SoulPowers`: the framework. `try_activate(id)` -> `ok | active | busy | cooldown | madness |
  unknown`; `tick()` on the 60 Hz tick; `interrupt(reason)`; signals `started(id, bark)`,
  `ended(id, reason, bark)`. One power at a time.
- `HaulerForm`: listens to the framework. While on, `body_class` = `rivet_ghost`
  (bodies.json: 0.9 m, 600 kg, run line 3.0 m/s: knocks down humans AND robots, bosses block).
  Feed it to `RivetBody.body_class`. `step(dir)` = momentum + turn limit; `stomp(at, bodies)`;
  `ramming()`; `morph_k()` for the rig (RivetPlan.FORMS `hauler` row = the full tank scale).
- `GearboxLink`: `pick(rivet, reticle, cars)` soft lock; `link()`; `step(reticle)` drives the car;
  `contact()` wrecks above `crash_mps`; `rivet_move_k()` slows Rivet while linked (the cost).
  The host owns the real car (`VehicleService.soul_hijack_traffic(slot)`, the teal plate).

## Proof

- Unit: `test_soul_powers.gd`, `test_hauler_form.gd`, `test_gearbox_link.gd`.
- Scenario: `scenario_souls_powers.gd` (planted: class switch dropped, stomp radius 0, a car
  that cannot turn).
- Arena: `data/tables/arena_stations/ghost-powers.json` (the powers pad).

## Spectral look

`--ghost-look=legacy|spectral` overrides every form, including in `ghost_review.tscn`. Without the flag, each form uses its `look` in `ghost_forms.json`. Missing and unknown looks select `legacy`. A form lane switches its row to `spectral` only after its body, flight and all attacks are complete and filmed in both tilts (70 and 55 degrees).

- `GhostLook.of(form_id: StringName) -> StringName` returns `GhostLook.LEGACY` or `GhostLook.SPECTRAL`. `GhostLook.spectral(form_id) -> bool` selects a rig's legless build. Tests use `override_for_test(look)` (empty selects rows) and `reset_for_test()`.
- `GhostHoverRow.of(form_id) -> GhostHoverRow` reads a cached, shared tuning row. Treat it as read-only. In `ghost_hover.json`, `height_m` is the rest height, `bob_m` the bob amplitude and `bob_ticks` its period. `bank_deg` caps roll and `bank_per_dps` converts yaw rate in degrees/second to degrees of roll. `lag_ticks` sets the critically damped follow delay. `lean_deg` is the forward pitch at `top_mps`.
- `tail.anchor_m` uses body axes (+x forward, +y right). `length_m` and `width_m` set the resting length and root width. `stretch_k` adds metres per m/s, `swing_k` sets turn lag from 0 to 1, `segments` counts links and `fray` varies their widths from smooth (0) to ragged (1). `shadow.radius_m` sets the ground radius, `alpha` sets centre opacity, and `shrink_k` is the scale lost per metre of lift.
- `GhostHover.new(row)` takes a fresh pose. `step(at_px: Vector2, facing: float, ticks: int)` accepts a ground point in world pixels and a facing in radians. It interpolates the endpoint over whole sim ticks. Read `lift_m`, `bank` (radians, positive right), `lean` (radians), `lag_px`, `speed_mps` and `yaw_rate_dps`.
- `GhostTail.new(row.tail).step(root_px, facing, speed_mps, lift_m, ticks)` follows the rotated anchor in ground-space pixels. Its raised root descends to a ground-level tip. `GhostShadow.new(row.shadow).step(ground_px, lift_m)` draws ink at the true ground point. The camera squashes the shadow by the view's ground factor.
- `GhostFlight.make(form_id) -> GhostFlight` builds a shadow and tail with their own hover state. `step(at_px, facing, ticks)` drives all three. `body_offset() -> Vector2` adds world-pixel lag and projected height, `body_scale() -> Vector2` gives unitless scale and `body_rotation() -> float` gives extra yaw in radians. Zero ticks hold the pose.

In a form rig, use `GhostLook.spectral(id)` when building parts to omit legs, feet and their contact effects. The form view sets `rig.drawn.hover`, steps the flight and mounts the body above its tail. Read `rig.drawn.flight.hover.bank` and `lean` for additional body-part poses and `speed_mps` for flight effects. The host continues to call the rig's idle and attack updates with its gait speed at zero. A standalone view can place its own body like this:

```gdscript
var flight: GhostFlight = GhostFlight.make(&"kerf")
add_child(flight)
add_child(body)
var at: Vector2 = rivet.pos * SimConst.PX_PER_M
var facing: float = rivet.facing.angle()
flight.step(at, facing, steps)
body.position = at + flight.body_offset()
body.rotation = facing + flight.body_rotation()
body.scale = Vector2.ONE * PlayerScale.k() * flight.body_scale()
body.drawn.hover = true
```
