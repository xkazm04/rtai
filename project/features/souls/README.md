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

The spectral HUD portrait uses `features/hud/art/ghost_chips/<id>_spectral.png` when supplied and otherwise uses the original chip.

`--ghost-look=legacy|spectral` overrides every form, including in `ghost_review.tscn`. Without the flag, each form uses its `look` in `ghost_forms.json`. Missing and unknown looks select `legacy`. A form lane switches its row to `spectral` only after its body, flight and all attacks are complete and filmed in both tilts (70 and 55 degrees).

Use `--view=tilt70` for the 70-degree art and `--view=tilt` for the 55-degree art. For a matching pair of review PNGs, give both runs the same `--shot-tick` and a different absolute `--shot=<path.png>`. The arena saves the rendered frame and exits.

- `GhostLook.of(form_id: StringName) -> StringName` returns `GhostLook.LEGACY` or `GhostLook.SPECTRAL`. `GhostLook.spectral(form_id) -> bool` selects a rig's legless build. Tests use `override_for_test(look)` (empty selects rows) and `reset_for_test()`.
- `GhostHoverRow.of(form_id) -> GhostHoverRow` reads a cached, shared tuning row. Treat it as read-only. In `ghost_hover.json`, `height_m` is the rest height, `bob_m` the bob amplitude and `bob_ticks` its period. `bank_deg` caps roll and `bank_per_dps` converts yaw rate in degrees/second to degrees of roll. `lag_ticks` sets the critically damped follow delay. `lean_deg` is the forward pitch at `top_mps`.
- `tail.anchor_m` uses body axes (+x forward, +y right). `length_m` and `width_m` set the resting length and root width. `stretch_k` adds metres per m/s, `swing_k` sets turn lag from 0 to 1, `segments` counts links and `fray` varies their widths from smooth (0) to ragged (1). `shadow.radius_m` sets the ground radius, `alpha` sets centre opacity, and `shrink_k` is the scale lost per metre of lift.
- `GhostHover.new(row)` takes a fresh pose. `step(at_px: Vector2, facing: float, ticks: int)` accepts a ground point in world pixels and a facing in radians. It interpolates the endpoint over whole sim ticks. Read `lift_m`, `bank` (radians, positive right), `lean` (radians), `lag_px`, `speed_mps` and `yaw_rate_dps`.
- `GhostTail.new(row.tail).step(root_px, facing, speed_mps, lift_m, ticks)` follows the rotated anchor in ground-space pixels. Its raised root descends to a ground-level tip. `GhostShadow.new(row.shadow).step(ground_px, lift_m)` draws ink at the true ground point. The camera squashes the shadow by the view's ground factor.
- `GhostFlight.make(form_id) -> GhostFlight` builds a shadow and tail with their own hover state. `step(at_px, facing, ticks)` drives all three. `body_offset() -> Vector2` adds world-pixel lag and projected height, `body_scale() -> Vector2` gives unitless scale and `body_rotation() -> float` gives extra yaw in radians. Zero ticks hold the pose.

`GhostFlight.set_emerge(k: float)` sets the visible fraction of a transformation. At 0 the body is grounded and the tail is retracted into its socket. At 1 it has its full hover pose, ribbon and light pool. The form view follows the real midpoint on entry and exit.

### Tilted pose sheets and overlays

Set `drawn.own_body = true` when a rig supplies its own spectral body. This removes the shared sprite immediately. The rig controls its parts' visibility, combat feeds continue, and its flight mount still steps. The default is false, including for forms that use a standing legacy cell until their pose sheets arrive.

In `art/view/<art>/`, a spectral form can supply `<card>_spec_hover.png`. Use five facing rows in the legacy order (toward, three-quarter toward, profile, three-quarter away, away). Pose cells are square. Their side is the PNG height divided by five, and the width divided by that side gives the column count. Two columns support idle and cruise. Four can hold Tonnage's carry, cruise, armed and recoil. The optional `<card>_spec_hover_left.png` follows the legacy left-sheet layout with three left-facing rows and the same columns. Without it, the left facings mirror.

Set `drawn.pose` before the rig steps. The default `-1` selects column 0 below 0.5 m/s and column 1 at or above it, using `flight.hover.speed_mps`. An explicit zero-based index is clamped to the sheet. A one-column sheet always shows column 0. `<card>_spec_act.png` uses four columns (wind-up, strike, follow, hit) and the same five facing rows, with an optional three-row `<card>_spec_act_left.png`. Active combat cells take priority. Each missing spectral sheet falls back independently to the standing legacy walk cell or the legacy act sheet. Spectral Ohm starts an instant bolt on strike (`instant_windup == 0`), while a delayed cast displays its real wind-up.

After `drawn.step(...)`, `drawn.sprite() -> Sprite2D` returns the current sprite, or null when the rig draws its own parts. An overlay can follow its texture, frame, flip and transform. Dent continues to receive `DentBody.step(...)` on its flight mount and can hide that sprite itself. For shards over the ribbon, read `flight.tail.points() -> PackedVector2Array` and `flight.tail.half_widths() -> PackedFloat32Array` after the flight step. Both arrays run root to tip with one entry per cross-section, in world canvas pixels before camera zoom. The centres include the projected lift. Each half-width measures from the centre to the drawn edge. Use the overlay node's `to_local(point)` to place a shard.

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


Each form lane tunes its own hover row. `start_lift_m` sets the acceleration lift and stop dip,
`cruise_bob_k` scales bob amplitude at full speed, and `sway_m` sets lateral drift.
`shadow.pool_m` and `pool_alpha` set the ground light radius and centre opacity.
`tail.strands` counts flame tongues, `spread_m` widens the plume behind its socket, and signed
`rise_m` lifts or drops its middle in tilted views. `curl_m` is the lateral wave amplitude,
`flow_ticks` its period, and `wisps` the maximum number of detached filaments. All animation
uses flight ticks and shared fixed-seed noise. The tail overlay reads the same posed centreline.

For tilted legacy cells, `fade_from` is the belt height measured up from the cell bottom as a
fraction of cell height. `belt_width_k` is the ribbon root width as a fraction of cell width.
The belt follows the actual cell transform through lean, recoil and lunge. Set `fade_from` to
zero for a new legless body. Spectral pose and act sheets and form-owned art use the row's
body-frame anchor directly.
