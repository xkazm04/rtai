# JOURNAL: lane `collisions` (branch `d-bodies`), day run 2026-11-03

Owner (11:30): "player should never in its basic form go 'through' any other character ... tackle
motion should happen with result based on character's size ... humans always weaker. Robots and
bosses we resolve in future."

## Iteration 1 (11:38 - 13:08)

### Scout (11:40)
- On main, Rivet is `CitySystem.target`. It is moved by the input axes (25 m/s free-steer) or set by a
  dev driver. On `d-slice`, `StagePilot` + `TopDownMover` set `city.target` (quest1_session).
  The sim had NO player body: peds only separated from each other (`_crowd`, 0.7 m, half push).
- Characters that move: sim peds (walk/flee/riot), sim cops (flow field), cars (vehicles lane),
  and the quest characters + boss/robots in `collect_call_stage` / `combat_arena` (not in the city sim).
- Measured BEFORE (scenario_bodies_crowd with the body off, which is today's game): worst Rivet-person overlap
  **0.770 m** (Rivet's centre sits on a ped: 0.42 + 0.35). After: **0.0003 m** (tol 0.02).

### MILESTONE: sim body, both runtimes, parity exact (commit 20f6a86)
- `native/sim_core/src/body.cpp` + `features/city/sim/sim_body.gd`, operation for operation.
  API: `set_body(spec)` (SimConst.BD_*, one call before step) and `body_result()` (BR_*: the resolved
  pos + knockdowns). New mode `M_DOWN` (=4) via tools/gen_constants (NAT-08).
- Per tier-A person: crowd separation, then the body push (mass share, plus a sidestep on a shove so the
  crowd parts instead of being bulldozed in a train: progress 59 % -> 97 %), then solid cells.
  Tackle when closing speed > tackle_mps: M_DOWN, slide sqrt(2*8*knockback), lie down_s. Then a
  ped flees from the hit point (rioters go back to the riot) and a cop resumes.
  After all actors: the body is pushed out of every remaining overlap (2 passes), then out of solids.
- Parity drives the body across the riot (walk + sprint legs): **exact** over 1200 steps,
  2 knockdowns in the run, and the planted mutation is still caught.
- FRICTION: my first GD edit also skipped downed peds in the bullet-hit test, and native did not.
  Parity caught it at step 329. Fixed.
- FRICTION: godot-cpp in this worktree was an empty submodule. I copied the built one from n-d5 (not
  committed: it is the submodule path). Native DLLs rebuilt (debug + release), git-ignored.

### MILESTONE: features/bodies (commit 8f0d261)
- `data/tables/bodies.json` (gtai.bodies/1) + schema. Classes: human 0.35 m / 75 kg,
  **rivet_base 0.42 m / 160 kg**, robot 0.5 / 300, boss 1.2 / 900, rivet_ghost 0.9 / 600 (reserved).
  - Why Rivet's radius: owner verdict 1, "only slightly larger than a human", gives 1.2x the human
    radius. Mass 160 kg (a machine): a human takes 68 % of an overlap, so Rivet keeps most of his speed.
    The radius is read from the table by class, never from the sprite (d5-cast rescales the art today).
  - tackle_mps 3.2 (a 1.4 m/s walk shoves; a 6 m/s sprint tackles).
  - rivet -> human: walk shove, run knockdown (1.6 m, 1.4 s). human -> human: shove/stagger.
    human -> rivet: shove/blocked.
  - Every pair with a robot or boss: blocked/blocked. **The owner designs robots and bosses later**: these rows are the
    neutral placeholder.
- `BodyTable`: the reader; it refuses radius/mass <= 0 and missing pairs.
- `BodyRule`.
- `RivetBody`: builds the spec from the table; a teleport > 30 m/s never tackles; emits the event.
- `BodyContact`: the same rule for bodies outside the sim (robots, bosses, quest people).
- SHARED-FILE CHANGES (all minimal):
  - `data/schemas/events.json` + `core/events/events.gd`: new
    `actor_knocked_down(attacker_id, defender_id, defender_class, at: Vector2)`, emitter
    features/bodies, wired.
  - `features/city/city_system.gd`: `var body: RivetBody`, set_body before the step and body_result after.
    It writes the resolved position back to target (and to focus when steered by input).
  - `boot/city_characters.gd`: 3 lines (the DOWN flag, no gun while down).
  - `dev/bench/city_bench.gd`: 1 line (`_city.body.on = rivet_on_foot`: no body in the car benches).
- Rig pose (in d5-cast's area, recorded here): `RigFeed.Flag.DOWN` (16). `RigClips.down`
  eases the existing sprawl channel to 0.9 in 0.22 s and back in 0.45 s (the get-up). While down, the baked crowd
  atlas shows the last (lying) frame of the DEATH clip. No new art.

### MILESTONE: proof (commits c3283b6, 3febc44, 53b1ca4)
- scenario_bodies_crowd: a walk through 15 standing peds.
  - Worst Rivet overlap 0.0003 m on every tick; people-people 0.006 m.
  - Progress 19.0 / 19.6 m; 0 knockdowns.
  - Planted faults, both caught: radius 0 (0.420 m), body off (0.770 m).
- scenario_bodies_tackle:
  - A sprint into a human: 1 knockdown, slide 1.93 m, got up, fled. Rivet kept
    99 % of his speed; overlap 0.00002 m.
  - A sprint into a robot (BodyContact): blocked, no overlap, and the robot did not move.
  - Planted faults, both caught: tackle off (0 knockdowns); a table without the
    rivet_base -> robot row (load error + 0.92 m overlap).
- test_body_table: 6 unit tests.
- Gates: lint 13/13, unit 331/331, scenarios all green
  (incl. replay_60s, city_replay identical, rig_stress), parity exact.
- Real city frames + clip: `dev/showcase/bodies_clip.tscn` (the real World + CityView + rigs, one
  tick per frame, so before and after land on the same tick).
  - 32 and 48 px/m, ticks 420/990/1050/1250; a 21.5 s clip; a side-by-side before/after clip.
  - 16 stills looked at, 0 rejected (all straight down).
  - Masters: gtai-masters/day-d5/collisions/ (frames.json, ladder.png, mp4s).

### Knowledge rules applied (ai-registry game-production)
- mass-based-arcade-collision:
  - Applied: the inverse-mass overlap split (the position repair); a closing-speed threshold that keeps ordinary bumping free;
    one knockdown per contact (a downed body cannot be knocked down again: dedup by state); a deterministic normal
    for coincident centres; a blocked body acts like a wall (normal speed removed, tangent kept).
  - DEVIATION: no velocity impulse for Rivet in the sim. His velocity belongs to the player controller, so the
    position repair slows him through a crowd instead. Re-check: when slice-play's TopDownMover lands, feed
    the resolved velocity back.
- realtime-combat-semantics:
  - Applied: dead wins over down (checked first everywhere). Down is a mode every gate reads: shots can still hit,
    scares skip it, the rig and the atlas read it. Timers are in seconds.
  - DEVIATION: no re-tackle grace after the get-up, and no recovery cost for Rivet. Re-check: the owner's
    feedback on the clip.
- agent-behaviour-authoring:
  - Applied: the get-up flee uses the stored hit point (sx, sy), not Rivet's live position
    (perception before decision). Down is a committed state (a scare cannot cancel it).
- `blocked` DEVIATION from the brief's "both stop, both pushed": under a held sprint, a mass split
  drove a robot along at about 2 m/s, which is a shove. Blocked now means the defender holds and the attacker
  stops at contact. Re-check: when the owner designs robots and bosses.

### REQUESTS
- REQUEST 1 -> slice-play: after `city.step`, read `city.body.pos` back into the pilot / mover.
  It is Rivet's resolved position. Without it the pilot puts him back inside people every tick and only
  the people move. It is one line where quest1_session copies the pilot position to `city.target`.
- REQUEST 2 -> vehicles: set `city.body.on = false` while Rivet drives, and true when he gets out (the bench already
  does this through rivet_on_foot).
- REQUEST 3 -> audio: `actor_knocked_down` is live (attacker_id, defender_id, defender_class, at).
- NOTE for the heat ladder: a tackled cop is still a cop. I added no heat rule; actor_knocked_down
  with a cop slot is the hook.
- NOTE for d5-cast: Rivet's body radius is 0.42 m in bodies.json whatever the sprite scale.
- NOTE: dev/noir/showcase_fight.gd sets rivet_on_foot = false but leaves the body on (a dev scene).
