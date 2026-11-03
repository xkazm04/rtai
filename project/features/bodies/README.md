# features/bodies: no one walks through anyone

Owner rule (2026-11-03): Rivet in his base form never goes "through" another character. Walking into
someone shoves them aside; running into someone is a **tackle** whose result comes from the two
bodies' size classes. Humans always lose to Rivet. Robots and bosses have rows in the same table with
a neutral `blocked` rule until the owner designs them later in the story.

## Data: `data/tables/bodies.json` (`gtai.bodies/1`)

- `classes`: `human` (0.35 m, 75 kg), `rivet_base` (0.42 m, 160 kg), `robot` (0.5 m, 300 kg),
  `boss` (1.2 m, 900 kg), `rivet_ghost` (reserved: the bulky ghost form, no rules, unused).
  Rivet's radius is read from here, **never from his sprite**: `d5-cast` rescales the art, the body
  stays 0.42 m ("only slightly larger than a human": 1.2x the human radius, so two humans side by
  side are 1.4 m and Rivet plus a human 0.77 m).
- `tackle_mps` (3.2): a contact whose closing speed (the attacker's velocity along the line to the
  defender) is above this is a run (a tackle), else a walk.
- `rules`: attacker x defender -> `walk` and `run` results (`shove`, `stagger`, `knockdown`,
  `blocked`), `knockback_m`, `down_s`, `can_hurt` (false everywhere today: a tackle that kills
  nobody makes no blood). `flee_s`: how long a knocked-down ped flees after getting up.
- Mass split: on contact the defender moves `m_a / (m_a + m_d)` of the overlap, the attacker the rest
  (Rivet vs a human: the human takes 68 %, so Rivet keeps most of his speed through a crowd).

`BodyTable` (reader) refuses a class with radius or mass <= 0 and any non-reserved pair without a rule.

## The city sim (people): `RivetBody` -> `CitySimBackend.set_body / body_result`

The bubble sim (GDScript reference `features/city/sim/sim_body.gd` and native
`native/sim_core/src/body.cpp`, parity exact) has one player body circle per step:

1. `CitySystem.step` turns where Rivet wants to be (`target`) into the spec (`SimConst.BD_*`):
   position, velocity (displacement / TICK_DT; above 30 m/s is a teleport, never a tackle), radii,
   mass share, tackle speed, knock slide speed (`sqrt(2 * 8 * knockback_m)`: the sim slides at 8 m/s^2),
   `down_s`, `flee_s`.
2. In the step, every tier-A person (ped or cop) after its crowd separation is pushed out of the body
   by its mass share; a shove also steps it aside (the side it stands on), so a crowd parts instead
   of being bulldozed. Above the tackle speed it is knocked down: `M_DOWN`, slides along the hit
   normal, lies `down_s`, then a ped flees (`M_FLEE` from where it was hit, or back to the riot if it
   was a rioter) and a cop resumes. Downed people are not scared by gunfire (they stay down), can
   still be shot and run over, and draw the `hit` clip's last frame.
   A person RUNNING into the body (its own closing speed above the tackle speed) follows the
   table's human -> rivet_base run result: `blocked` sets `BD_RUN_IN`, and the person takes the whole
   overlap (a fleeing ped cannot shove Rivet).
3. After all actors moved, the body is pushed out of everything it still overlaps (two passes),
   then out of solid cells. `body_result()` returns the resolved position and the knockdowns
   `(slot, x, y)`; `RivetBody.take` writes Rivet back and emits `Events.actor_knocked_down`.

`RivetBody.on = false` while Rivet drives (no body in a car).

## Outside the city sim: `BodyContact`

`BodyContact.resolve(table, a, b, [a_pos, b_pos], a_vel)` is the same rule for two bodies that are
not sim people (robots, bosses, quest characters): a shove splits the overlap by mass; `blocked`
stops the attacker at contact and the defender holds (closing speed removed, tangent kept: it
slides along, like a wall), so a sustained sprint cannot push a robot along (a mass split would
drive it at about 2 m/s); `stagger` / `knockdown` push the defender clear and report the rule's
knockback for the caller's state.

## Quest 1's arena: `ArenaBodies`

`boot/collect_call/collect_call_stage.gd` calls `ArenaBodies.resolve(arena, rivet_vel)` after
`arena.step`: Rivet against every live hostile through `BodyContact`. Every arena hostile today is a
human (guards, quartermaster Mertz): a walk shoves, a run knocks back `knockback_m` (no lying state
in the arena yet). A robot or big-boss fighter needs its own class in `ArenaBodies.class_of`.

## Proof

- `tests/scenarios/scenario_bodies_crowd.gd`: a walk through 15 standing peds; worst Rivet overlap
  on every tick <= 0.02 m (measured 0.0003 m; before the body: 0.77 m); planted faults: radius 0,
  body off.
- `tests/scenarios/scenario_bodies_tackle.gd`: a sprint into a human (knockdown, slide, get-up, flee)
  and into a robot (`blocked`, no overlap); planted faults: tackle off, the robot row removed.
- `tests/scenarios/scenario_bodies_cop.gd`: a tackled cop lies 1.4 s and resumes as a cop (never
  flees); planted fault: down_s 0.
- `tests/scenarios/scenario_bodies_runin.gd`: a 4.5 m/s ped into a standing Rivet moves him
  0.09 m (rule off: 0.61 m, the planted fault).
- `dev/bench/bodies_cost.gd`: native riot step with the body on vs off (CONTENDED, within noise).
- `tests/parity/city_parity.gd` drives the body through the riot (walk and sprint legs): exact.
