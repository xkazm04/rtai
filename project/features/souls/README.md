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
