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

### MILESTONE: quest 1 arena, cops, cost (commits after 53b1ca4)
- `ArenaBodies` (features/bodies): Rivet vs every live CombatArena hostile after `arena.step`
  (quest 1's stage). SHARED: `boot/collect_call/collect_call_stage.gd`, 3 lines. Every arena hostile
  today is a human: a walk shoves; a run knocks the hostile back 1.6 m (the arena has no lying-down state;
  the combat lane owns that). Quest scenarios are unchanged (11436 / 2388 ticks). 2 unit tests.
- scenario_bodies_cop: a sprinted-into cop is knocked down once, lies 84 ticks (1.4 s), resumes
  as a cop (M_WALK) and never flees; overlap 0.00002 m. Planted fault: with down_s 0 the cop is re-tackled every
  tick (8 knockdowns), which fails the verdict, so it is caught.
- Body cost, CONTENDED (dev/bench/bodies_cost.gd: native, 300-person riot, 400 tier-A, Rivet
  sprinting circles, 23 knockdowns), 1800 steps x 2 runs:
  - p50: 0.072 vs 0.077 ms off, and 0.063 vs 0.065 ms.
  - p99: 0.303 vs 0.301 ms, and 0.289 vs 0.289 ms.
  - Within noise. FRICTION: `-s` scripts log "Identifier not found: Log"
    compile errors from depended scripts (no autoloads under -s). The measured classes ran.

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

### MILESTONE: run-in rule + section 20 bench (commits 3e0f344, e3956f1)
- A person RUNNING into Rivet (closing speed > tackle_mps) now follows the table's human ->
  rivet_base run result (`blocked`): the person takes the whole overlap (new spec slot BD_RUN_IN,
  set from the table by RivetBody). Parity is still exact.
  scenario_bodies_runin: a 4.5 m/s ped into a standing Rivet moves him 0.09 m (the glancing shoves after the
  ped steps aside). With the planted fault (rule off) he moves 0.61 m: caught.
- Bench, under the lock (`node tools/bench/run.mjs`, exported release, 3 runs x 4 scenarios x
  60 s), **CONTENDED** (7+ lanes on one machine):
  - p99 7.511 ms; 1 % low 62 fps; worst swap 216 ms.
  - Riot rigs p99 0.901 ms (this morning's idle figure: 0.407 ms).
  - MISSES p99CpuMs (7 ms) and worstSwapMs. I can't attribute these to bodies under contention: the CPU-only
    probe (bodies_cost.gd) shows the body within noise in the sim step. Re-run idle before the merge.
  - FRICTION: the export needed `build/export/windows-bench/` to exist (a fresh worktree).
  - Files: evidence/bench-*-bodies-contended.json + .txt.

### MILESTONE: look goldens re-blessed + final gates (commit 5352f06)
- The look-golden selftest failed with the body on (0/11, worst mean 23.04) and matched exactly with the
  body off (11/11, worst 0.00). The selftest's Rivet stands at the junction riot, and the rioters are now shoved
  off him. I compared old and new by eye: same city, camera and look; only the crowd positions differ.
  Re-blessed deliberately, with a decision line in docs/decisions.md. Block goldens 5/5, unchanged.
- Final `node tools/evidence/run.mjs --no-bench --allow-dirty` (dirty = only the uncommitted
  evidence/clip/ media + 2 quest JSONs). lint PASS, scenarios 12/12 PASS, parity exact PASS,
  selftest PASS (11/11 + 5/5). Unit tests: 332/333 in that run. The failure was
  test_noir_shadows.gd `test_only_shadow_commands_with_a_length_are_swept`, an engine
  "Parameter t is null" (the noir lane's test, untouched by me). Re-run twice straight after: 333/333 both
  times. FRICTION: that test is FLAKY under machine contention; reported, not fixed (not my scope).
- Clip media (59 MB) is not committed. It is in gtai-masters/day-d5/collisions/ and evidence/clip/.

### NEXT
1. REQUEST 1 (slice-play) through the Director: d-slice's quest1_session must read
   `city.body.pos` back into the pilot after each city step, or the pilot puts Rivet back inside people.
2. Re-run the section 20 bench on an idle machine: are the p99 CPU and worst swap misses contention or bodies?
3. A grace window after the get-up (no re-tackle for about 0.5 s) and a small recovery cost for Rivet after a
   tackle. Ask the owner first, from the clip (bodies-after-32ppm.mp4).
4. Arena knockdown state (a lying guard) with the d5-combat lane; then robots and bosses when the owner
   designs them (the bodies.json rows are ready; ArenaBodies.class_of needs a body class per fighter).
5. REQUEST 2 (vehicles): `city.body.on = false` while driving.

## Iteration 2 (12:42 - 14:12)

### MILESTONE: trial merges with d-slice and d-vehicles (commits 7312d63, 03463db)
- Scratch worktrees `../x-bodies-slice` and `../x-bodies-veh` (branches x-bodies-slice and x-bodies-veh,
  scratch only, never pushed). All notes and patches are in `evidence/merge/README.md`.
- `git merge-tree` against the other 5 game lanes: only JOURNAL.md and the 11 look goldens conflict
  (re-bless at the end).
- d-slice: the conflict is in collect_call_stage.gd. The resolution keeps their pilot, StageLines and
  `_collide_hostiles`, and adds the read-back (REQUEST 1, done as a merge patch), ArenaBodies, and a
  wall push-out.
  - Merged tree: scenarios 16/16 PASS.
  - Quest 1 to "paid": 11241 ticks with and without the read-back (Rivet never comes within 2.9 m of a city
    person on the bot's route).
  - Walk-in probe in the real quest session (5 city peds on his path):
    - with the read-back: walk overlap 0.0073 m, progress 10.59 m; sprint overlap 0.031 m, 5 knockdowns;
    - without it: walk 0.0103 m and progress 11.21 m (= the free walk, so his mass is ignored).
  - FRICTION (mine): I first copied a stale probe JSON (the planted run had written to the same
    evidence dir). I caught it when the numbers disagreed and re-ran 4 ways: deterministic.
- d-vehicles: native conflicts (SConstruct, generated constants, city_parity.gd). The resolution: union, regenerate
  with gen.mjs, keep both. No constant collides (M_DOWN 4, F_PASSING 8).
  - Native rebuilt. Parity is **exact over 1200 steps**, and the planted mutation is caught at 629. Scenarios 15/15 PASS.
  - REQUEST 2 as a merge patch: `_city.body.on = not in_car` in set_focus. Measured: 0 body knockdowns in
    vehicle_drive with and without it, so it is NOT shown necessary. It is kept as the contract.
  - FRICTION: the godot-cpp submodule is empty in fresh worktrees. I junctioned d-bodies' copy for the scratch build.

### FINDING: no tackle is possible in the merged quest today (commit c02f2c2)
- slice-play's Rivet tops out at combat.json `walk_mps` 3.0 m/s (TopDownMover has no sprint). The tackle line is
  his own speed into the body (body.cpp: not the closing speed, so an oncoming ped does not count) above
  `tackle_mps` 3.2. So in quest 1 a walk always shoves and nothing can knock anyone down.
  - On main's free-steer city (the clip), tackles work.
  - The walk-in probe shows that a 6 m/s move in the real quest session knocks down all 5 peds.
- New unit test `test_rivet_walk_speed_never_tackles`: combat walk_mps < bodies tackle_mps. If someone raises
  the walk past 3.2, every brush becomes a knockdown and this test names the two tables.
- **REQUEST 3 -> slice-play:** a held `sprint` action (about 6 m/s, a `run_mps` beside `walk_mps` in
  combat.json's rivet row, and TopDownMover's top speed while held). The owner's rule "running into someone is a
  tackle" needs a run. No bodies change is needed: the city body and ArenaBodies read his velocity.
- Arena note: ArenaBodies applies the 1.6 m knockback in one tick (a 51 px pop at 32 px/m). It cannot happen in
  quest 1 today (the 3.0 m/s cap). If a sprint lands, turn it into a slide over ticks, or give the arena a
  lying-down state (d5-combat).
- Unit: 333/334 on the first run; the failure was test_noir_shadows again (the flaky engine
  "Parameter t is null", not mine).
