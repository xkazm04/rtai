# JOURNAL - night n18, lane police (branch n18-police, cut from int-n17 at 36dd26ba6)

## Session 1 (2026-11-17 23:33 -> 01:03)

Read: brief, common rules, AGENTS.md, decisions tail, sim code (sim_people.gd cop(), sim_flow.gd,
native people.cpp/flow.cpp). No JOURNAL existed; no REQUESTs addressed to police yet.

Registry rules applied (item 1):
- `cross-runtime-rules-conformance`: "the arithmetic drifts" -> the new sight test is integers only
  (a cell walk between cell centres, no float DDA), so native and reference cannot drift on it;
  "a green suite versus a sensitive suite" -> parity is judged by its planted-mutation gate, and
  the new unit test is run red before the fix.
- `agent-behaviour-authoring`: "write the agent's knowledge model before its decision model" ->
  the cop's straight steer now depends on a named sense (line of sight on the cell map), not on
  distance alone; the same sense is the one heat (item 2) will use for "seen by a sim cop".

### Item 1: cop nav (n15 DEFECTS cop-on-wall)
Cause read in code: `sim_people.gd` cop() steers straight at the target when d <= FF_NEAR_M
(10 m) with no sight test; inside 7 m it stands (`_spd` 0). A wall inside 10 m pins him.
Repro (`tests/unit/test_city_cop_sight.gd`, CityWallMap = the flow-field test's wall, x 300..302,
gap y 320..327): BEFORE (int-n17 code) both wall cases FAIL, crossed tick -1 (never in 3000 ticks):
cop 9 m from target and cop 6 m (inside the stand-off). Confirms the scout's cause.
Fix: `see = d <= FF_NEAR_M and sight(...)`; flow field unless `see`; speed 3.4 unless (see and d <= 7).
AFTER: 9 m cop crosses at tick 617, 6 m cop at tick 615; in-sight cop still stands off at 7.0 m.
Native core tests: 0 failed (new chase(296.5, 305.5) check). Parity: bit for bit over 1200 steps,
planted mutation caught at step 629. city_sim_ref.gd hit the 200-line cap: tier pass moved to
`sim_tier.gd` (CitySimTier, no behaviour change, parity same).
MILESTONE item 1 code + tests.
FRICTION: Windows python text-mode writes CRLF; use newline='' (gate quick catches it).

### Item 2: heat as a sim input (in progress)
DECISION police/heat-input: the command is `CitySimBackend.set_heat(level, x, y)` (native
CityCore::set_heat + binding, reference CitySimFlow.set_heat), a sim input set before step() and
kept, like set_obstacles. Level -1 is the default and means "pre-n18 police" (every cop pursues
the step's target, as today), so every boot that never calls set_heat (quest 1, arena city, the
n15 street fight, parity, replay) is unchanged until it opts in. It needs no tape entry of its own:
CityHeat derives it each tick from replayed state and events (SIM-05 holds by construction) and
writes level + last-seen into the World state hash (write_state).
Sandbox source: `features/police/city_heat.gd` (CityHeat, a WorldSystem after CitySystem and
VehicleService): seen = a live sim cop within heat.json sight_m with CitySimBackend.sight to Rivet
(the item 1 sense); violence = pedestrian_struck(killed) or actor_killed by RIVET_ACTOR_ID; a tick
with violence while seen raises one level; HeatMeter drains unseen as on quest 1.
Cost note for item 7: cop_sees() scans sim.snapshot() each tick (GDScript); if it shows in the
bench, move "seen" into the native cop step (a counter) instead.

Item 3 design (next): the sim treats heat >= 0 as "living police". Heat 0: cops walk their
sidewalk like peds (ped_walk), no pursuit, no fire. Heat >= 1: the N cops nearest the last-seen
point (heat.json `investigate_cops`) are engaged (a flags bit), path on the flow field to the
step's target, which CityHeat passes as Rivet when seen, else the last-seen point; they search
`search_s` there (t1 timer) and drop back to walking. Seen again: re-engage (last-seen moves).
Gates on 1106c8b1b (item 1): full unit 2842 passed / 0 failed; scenarios 54/55, city_chase missed
the 2 ms nav budget on one 3.8 ms flow-field spike (last build 150 us; flow_build is untouched by
item 1) and passed when re-run alone at 00:18 -> CONTENDED noise, not the change.
Item 2 landed: set_heat on both backends + CityHeat on the sandbox boot (`boot/world.gd`, one
line). Tests `tests/unit/test_city_heat.gd` 6 pass (cop sees at 3 m, not beyond sight_m, not
through the wall; witnessed kill -> heat 1 + last-seen + sim heat_level 1; unwitnessed kill -> 0;
drain one level per drain_ticks unseen; struck survivor is no kill; native == reference clamp and
reset). Before: CityHeat/set_heat did not exist (the file fails to compile). Parity bit-exact,
city_replay + replay_60s identical with heat in the state hash.
MILESTONE item 2 (sim input + sandbox source). No clip yet: nothing reads the level until item 3.

### Item 1 film (00:25-00:41)
Before tree: `C:\Users\kazda\kiro\gtai-n18\police-before` (git worktree --detach at 36dd26ba6,
tools/dev/wt_init.mjs from this tree, then its own `scons` DLLs: film.mjs refuses --rev when native
differs). `film.mjs city --ppm=32 --stills=250,450,650,850,1150`, before (--tree=police-before) and
after (this tree at 39c831f52): both PASS, t650 IDENTICAL.
FINDING: the four cops at the wall's north foot in the n15 street fight are NOT city-sim cops. The
film's probe.json at t650 names them hostiles 3001-3004 (cop/head_cap, helmet, helmet, swat) at
y 530.3 with Rivet at 527.5,535.0: arena pit guards (Fighters), moved by the combat enemy AI
(`features/combat/ai/enemy_motor.gd` arrive(): a straight steer, no path round walls). The scout's
hypothesis (sim_people.gd) was a real defect too, proven by the unit repro (never -> tick 617/615),
but it is not the n15 frame. Count of cops reaching Rivet in the film: unchanged (0 of those 4
before and after, by eye at t650; no per-tick number: the probe logs only Fighters).
NEED director: `features/combat/ai/enemy_motor.gd` (no lane owns combat AI tonight): pit guards
need the same rule (straight only with sight on the arena/city solid cells, else a path round the
wall's end); the n15 defect stays OPEN there. Evidence filed: gtai-masters/n18/police/frames.json
(2 entries, the pair + probe).
FRICTION: a `-s` dev script cannot load the arena (its code names autoloads Events/Log at compile
time), so a headless sim-cop counter in the arena fight needs a scene entry; dropped tonight.
REQUEST tools: film_probe.gd could log the city sim's cops (slot, pos, mode) per tick next to the
Fighters, so "cops that reach Rivet" in an arena-city film is a number, not an eye count.

Gates on d66a666c1 (code = 39c831f52, items 1+2): lint 19/19 (at commit), full unit 2848 passed /
0 failed / 2 skipped, scenarios 55/55 (city_chase within budget this time), parity bit-exact +
mutation caught, native core tests 0 failed. Not run this session: evidence run.mjs (look goldens),
reel gate, debt standalone (debt-ratchet passed inside lint), bench.
Scratch films deleted; kept pair in gtai-masters/n18/police. Before-tree worktree
`C:\Users\kazda\kiro\gtai-n18\police-before` (detached at 36dd26ba6, own DLLs) KEPT for later
before/after films; remove with `git worktree remove` at the end of the night.

NEXT (session 2): item 3 (heat 1 investigate), per the design above:
1. heat.json + schema: `investigate_cops` (3), `search_s` (8), later `cars_*`, `roadblock_*`
   (schema gtai.heat/1 has additionalProperties false: add the keys to the schema; HeatMeter reads
   only its own keys).
2. Sim (native people.cpp/flow.cpp + reference sim_people.gd/sim_flow.gd, together): when
   heat_level_ >= 0, a cop not engaged walks like a ped (ped_walk path) and does not fire; engaged
   cops (a flags bit, set by a deterministic nearest-N pick to heat_x/y when the level rises or the
   point moves) pursue the step's target. CityHeat passes target = Rivet when seen, else last_seen
   -> CitySystem needs a separate pursuit target from focus (police own the call site; city_system
   step uses `target` for both the body and police: add a `police_target` used only in sim.step's
   tgx/tgy, default = target). heat_level -1 path must stay byte-identical (parity, replay).
3. Test first (fails before): CityWallMap-style open map, 6 cops, heat 1 at a point 30 m away:
   exactly investigate_cops reach it within N ticks, the rest keep walking; search_s later they
   disengage. Then parity, then a 32 px/m clip of the sandbox (film has no sandbox shot: check
   tools/film/shots.mjs, else REQUEST tools / a dev scene).
4. NEED director (unchanged): combat AI pit-guard nav (`enemy_motor.gd`) for the n15 frame.

## Session 2 (2026-11-18 00:47 -> )

Registry rules applied (item 3):
- `agent-behaviour-authoring` "coordination is a claim on a scarce resource, the registry owned by
  the contested resource": the last-seen point owns PT_FOOT<level> claims (F_ENGAGED), nearest cop
  first, lowest slot on a tie; no commander. "Every dispossessed holder falls back to a stated
  alternative": search over or heat 0 cancels every claim at once and they walk. "Commitment
  windows in seconds": search_s 10, the city drain 20 s/level, both in heat.json.
- `combat-pacing-and-dramatic-arc` "duration is a two-sided envelope": a heat-1 episode lasts
  20 s unseen (cops 40 m away arrive at 11.5 s, then search 10 s): long enough to see the answer,
  well under the ~45 s "spongy" ceiling.
- `cross-runtime-rules-conformance`: every new sim value is doubles (Vector2/3 are float32 in
  GDScript, so the reference keeps double scratch members, never vectors); the ladder gets its own
  native-vs-reference test because the parity gate runs at heat -1 only.

### Item 3: heat 1 investigate (52d03bdbd)
- Sim (native `police.cpp` + reference `sim_police.gd`/`sim_cops.gd`): heat 0 = cops walk the
  sidewalk at 1.4 m/s, no fire; heat 1-3 = foot_cops[level] 0/3/4/6 nearest the point engaged,
  flow field to the point (the field's goal is now the last-seen point under heat), search 10 s
  within 3 m, released; fire needs line of sight. heat -1 unchanged (parity gate bit-exact).
- Game: `CityHeatTune` reads heat.json `city`; `CityPatrol` keeps 10 foot cops in the sandbox
  bubble (FINDING: the sandbox street targets keep NO foot cops; they only came with a riot).
- Tests (`test_city_police_heat` 6, `test_city_police_parity` 1, `test_city_heat` +2): before =
  the files do not compile on 39c831f52 (no set_police/FS_ENGAGED) and, behaviourally, every cop
  pursued Rivet at any heat. Numbers: three nearest cops (~40 m) within 4 m of the point at tick
  691; at heat 0 a cop walks 7.0 m in 5 s and fires 0 rounds; Rivet behind the wall 15 m: 0 shots,
  in the open 5 m: > 0. Ladder parity: 1500 ticks bit for bit, up to 6 engaged.
- DECISION police/heat-ladder-1 (docs/decisions.md): city drain 20 s (measured: 6 s ended heat 1
  before anyone arrived).
- Gates on 52d03bdbd: lint 19/19, full unit 2857 passed / 0 failed / 2 skipped, parity bit-exact
  (1200 steps, mutation caught at 629), native core tests 0 failed.
FRICTION: a full unit run started while I was still editing went red on a half-written import;
re-run on a settled tree. Never edit project/ while a gate runs.

### Clip tool (799a958a4)
`project/dev/sim/heat_clip.tscn` (dev/police would be a new lane-named dev dir: the debt ratchet
refuses it): the real World + CitySystem + CityHeat + CityView at 32 px/m, camera on A (the
sandbox start junction); at --heat-at (180) it does what a witnessed kill at A does (level,
last-seen A) and moves Rivet 60 m south out of sight; PNG every 4 ticks + timeline.json (heat,
engaged, cops within 4 m of A, police cars stopped at A, every cop position). `--police=pre` =
set_heat -1 (the pre-n18 sim police, same patrol). Run Godot directly (tools/dev/run.mjs passes no
--rendering-driver/--resolution); ffmpeg for the mp4. Debt: dev_loc and direct_cmdline_reads
accepted with a reason (`--accept-regression`).
REQUEST tools: a `sandbox` shot in tools/film (film.mjs) for the streamed city with a heat plan, so
heat clips get the film kit's --rev snapshots, probe.json and compare.mjs instead of heat_clip.

### Item 3 film (e5a648203, patrol 16, drain 25 s)
Heat 1 living: raise t180; first cop within 4 m of A at t388 (3.5 s), 3 within 4 m at t808 (10.5 s),
claims cancelled at t1020 (10 s search), heat 0 at t1680 (25 s drain). Pre-n18: 0 cops within 4 m
all clip (every sim cop chases Rivet from tick 0, crime or not). First cut (52d03bdbd, patrol 10,
drain 20 s): only 1 of 3 engaged cops reached A before the drain (the nearest, 15.7 m, vanished at
t300-400 crossing the junction, most likely run over) -> DECISION retune (heat-ladder-2 line).
Evidence: gtai-masters/n18/police + evidence/n18-police (pair still t808, mp4 pair, timelines).

### Item 4: heat 2 cars (e5a648203, 20609876f, 2df162b6d)
- CityDispatch (game) + sim car stop/park/crew (native + reference). Tests: test_city_police_cars
  (4), test_city_dispatch (2), car ladder parity (1200 ticks bit for bit, 8 cops incl. crews).
  Numbers: a dispatched car 78 m off parks and unloads at tick 403; 2 cars sent by tick 183 on the
  road map (delay 180).
- FINDING (unit): crew out on the kerb side pressed into its own parked car forever (the flow field
  does not see cars) -> crew gets out on the side facing the point.
- FINDING (clip h2 at e5a648203): the foot search ended at t1020 and released both cars en route ->
  the search waits while a dispatched car is en route (20609876f; test red without: search clock
  121 ticks while the car drove).
- FINDING (headless sandbox trace, 20609876f): both dispatched cars stalled 63-70 m from A behind
  junction reservations held by promoted spawner police cars (now traffic under heat, never
  despawned) -> 2df162b6d: a dispatched car skips the reservation queue (siren), an idle police
  car stuck like traffic despawns. After: one car reaches 11 m from A by t1920 but crawls at
  ~0.9 m/s through a jam round A; the other still stalls 67 m out. Cause not proven; suspects:
  the engaged cops searching IN the junction (traffic brakes for people ahead, so the junction
  owner never clears) and pursuers having no following logic (they press into the car ahead).
  No dedicated unit test yet for the siren/idle rules (parity tests cover their bit-exactness).
- Heat 2 clip: NOT evidenced yet (item4_heat2_living_20609876f shows 0 cars at A, labelled a defect).

Gates on 2df162b6d: lint 19/19, full unit 2864 passed / 0 failed / 2 skipped, native core 0 failed,
parity bit-exact (1200 steps, mutation caught at 629), scenarios 55/55 (01:50, none CONTENDED).
FRICTION: a GDScript local named `free` (shadows Object.free) crashes `--check-only` with
0xC0000005 (tools/gate/quick.mjs reports `exit 3221225477`); GUT ran the file fine.
FRICTION: a mutation that leaves a local unused fails to parse (warnings are errors), so a
"red before" via deletion proves nothing; mutate with `(not x or true)` instead.

NEXT (session 3):
1. Heat 2 clip that works. Session-2 trace (reference sim, sandbox seed 18, heat 2 at START, throwaway
   GUT test, deleted): dispatched car 416 at (284.4,202) heading W pushes a STOPPED traffic car 2.2 m
   ahead (v 0, flags 0) at 0.9 m/s from t600 to t1350: that car queues for the junction west of it
   (x 264-271, y 200-207) whose reservation never frees; car 417 got through at t1050 and reached
   (242,270) by t1350. So the pursuer is not the blocker: a reservation held upstream is.
   Owner trace (same run, junction tile (33,25), jt 6433): the owner is traffic car 117 (flags 0,
   not promoted) at (266,192) heading S to turn W, v 0, inside a pile of 9 traffic cars all at v 0
   within 7 m (x 263-270, y 189-198) from t300 on; its stuck timer reaches 14.7 s at t1100, so only
   the 20 s stuck despawn frees the junction (~t1500). ORDINARY TRAFFIC GRIDLOCK, not a police rule.
   Plan: (i) a dispatched car stuck en route (v < 0.5 for heat.json city.bail_s, e.g. 4 s; stuck_
   counts since pursuers never `wait` under heat) parks where it is and its crew bails out on foot
   (car_unload's condition: within car_stop_m OR stuck_ > bail_s), test on CityRoadMap with a
   stopped traffic car ahead; (ii) check whether the pile-up also forms with heat -1 (pre-n18) on
   the same seed: if yes it is a traffic defect for the Director (car_hit/car_route are police-owned
   sim files, so I may fix it, but it moves the parity golden: decision line + re-bless).
   Then: prove the rest of the jam's cause with a headless trace (copy the session-2
   pattern: a throwaway GUT test building World + CitySystem(native) + CityHeat, force heat 2 at
   CitySystem.START, print K_PCAR slot/pos/v/dir and res_/owner per 120 ticks; delete it after).
   Suspects, in order: (a) engaged cops searching IN the junction (traffic brakes for people ahead
   and holds the reservation): snap the search amble to stay on walk cells, or let a car whose
   blocker is an engaged cop pass; (b) pursuers' missing follow logic (they press into the car
   ahead at ~0.9 m/s). Then re-film `heat_clip --level=2` living vs pre, number = cars stopped at A
   and crew within 4 m of A. Add a unit test for the siren rule (a dispatched car is never
   `waiting`) and the idle-car despawn.
2. Item 5 (heat 3): crews of heat-3 cars are squads: city.squad (4) per car, looks riot (crowd
   index 6) and SWAT (RigVariant.SWAT 8) via the spawn variant byte (feed.looks = sim variant;
   check by eye that a K_COP with variant 6/8 draws riot/SWAT in the atlas path: RigVariant.atlas_look
   prints SWAT as patrol at LOD 1). Roadblock: CityRoadblock (game) parks city.roadblock_cars (3)
   K_PCAR F_PARKED across the lane at the junction ahead of Rivet's heading (from last_seen's
   motion), spacing in heat.json; traffic already brakes for cars ahead; a parked car must not
   steer (skip car_steer when F_PARKED under heat). Tests + parity + clip.
3. Item 6 (quest 1 heat into the sim on the slice boot, then --sim-police flag) and item 7 (cost
   at heat 3, bench lock) after.
4. Not run this session: evidence run.mjs (look goldens), reel gate, bench. Run them on the next
   commit before the REPORT.
5. Before-tree worktree `C:\Users\kazda\kiro\gtai-n18\police-before` still KEPT (36dd26ba6).

### Item 4 continued (c19685d17, 02:00)
Owner trace done (see NEXT 1 above, now ACTED ON): under heat a dispatched car brakes like traffic
and, stuck city.bail_s 4 s, parks and its crew walks (test red before: no crew in 10 s, stopped
car rammed along; after: crew out at tick 478). DECISION police/heat-ladder-2-bail.
Heat 2 re-film (c19685d17): cops 16 -> 19 (crews out ~60 m off), max 4 foot cops within 4 m of A,
0 cars at A, claims cancelled ~t1600 (the 10 s search started by the foot cops), so crews never
reach A. Filed as item4_heat2_living_c19685d17 (labelled not-yet-working).
Gates on c19685d17: lint 19/19, full unit 2865 passed / 0 failed / 2 skipped, native core 0 failed;
parity bit-exact (1200 steps, mutation caught at 629), scenarios 55/55 (02:04, none CONTENDED).

NEXT (session 3, replaces the list above where it differs):
1. Heat 2: the search clock must also wait while a crew cop (F_CREW, engaged) is still farther than
   arrive_m from the point (like the en-route car rule); test on CityRoadMap (blocker + bail, foot
   cop already at the point, search_s 2: claims must hold until the crew arrives). Re-film heat 2;
   the number to show: crew within 4 m of A. Then (ii) of the old NEXT 1 (does the pile-up form at
   heat -1 on the same seed?).
2. Item 5 (heat 3 squads + roadblock), item 6 (quest 1), item 7 (cost) as planned above.
3. Not run yet: evidence run.mjs (look goldens), reel gate, bench.


## Session 3 (2026-11-18 02:04-03:34)

### MILESTONE item 4 heat 2 works (e7cb74202)
The search clock at the last-seen point also waits while an engaged crew cop (F_CREW) is farther
than arrive_m (native + reference; car rules split to `sim_police_cars.gd` / CitySimPoliceCars:
sim_police.gd hit the 200-line ratchet). Test `test_the_search_waits_for_a_crew_walking_to_the_point`
(CityRoadMap, foot cop at the point, a stopped car ahead of the dispatched car, search_s 2): before
-1 (crew released 2 s after the foot cop's search began, never within 4 m), after: foot cop + 2 crew
within 4 m at tick 1212. Parity bit-exact (1200 steps, mutation caught at 629), native core 0 failed.
Heat 2 re-film (heat_clip --level=2 --seconds=40, e7cb74202): both cars bail out ~t900-960 60-70 m
from A, all 4 crew within 4 m of A by t2244 (near A 7 = 3 foot + 4 crew; c19685d17: max 4, crew 0).
Known: a crew stuck forever would hold the search until the heat drains (bounded by drain_s).
Evidence: gtai-masters/n18/police item4_heat2_living_e7cb74202_32ppm{.mp4,_t2244.png}, timeline.

### MILESTONE item 5 heat 3 (eaf66ffb8, eebc2600e clip tool)
- Sim (native + reference): at heat 3 a dispatched car unloads city.squad (4) cops, looks
  city.squad_looks [6 riot, 8 SWAT] in turn (tune PT_SQUAD/V0/V1, PT_LEN 13). The sim's crowd clip
  table has 8 rows: a look past it renders as patrol 5 (native render.cpp read past the table before;
  only reachable now). Test `test_at_heat_3_a_car_brings_a_riot_and_swat_squad` (before: 2 cops,
  variant 7 = PT_CREW, ART_COP; after 4: {6: 2, 8: 2}).
- Game: `CityRoadblock` (features/police) parks city.roadblock_cars[3] (2) cruisers across the
  road 6 m past the first junction 25-90 m ahead of Rivet's heading, 2 s after the rise; F_PARKED
  holds them, traffic brakes behind. Tests test_city_roadblock (4): find() x 302 / y 324 on the
  cross map, two parked across (one per lane, 4 m apart) and still after 600 ticks, a westbound car
  stops at x 307.5 (block 302), none at heat 2. Parity: heat 3 1200 ticks bit for bit (squad 4).
- heat.json: squad 4, squad_looks [6, 8], roadblock_cars [0,0,0,2], roadblock_ahead_m [25, 90],
  roadblock_past_m 6, roadblock_delay_s 2 (+ schema). DECISION police/heat-ladder-3.
- Clip (heat_clip --level=3, 40 s): squad cops at A from t968, all 12 within 4 m by t2176, max 17
  cops within 4 m; block placed t524 at (268, 406) (it waits for the chunk to stream in); max 1
  traffic car stopped within 25 m of it in 30 s (thin traffic there). Heat 2 same seed: max 7.
  64 px/m close-up: SWAT (visor) and riot (shield) read. Evidence: gtai-masters/n18/police item5_*.
- FINDING (look, not fixed): in the heat 3 frame t2176 two peds lie dead beside a dispatched police
  car (bottom centre): likely run over by a dispatched car (sirens skip the junction queue; under
  heat they brake for people ahead, so maybe hit from the side at the turn). Check with a trace.
- FINDING (not mine, NEED districts? no: characters/view, no lane): sim cops carry art variant 7
  (ART_COP), but RigVariant.crowd(7) is the overalls-bald ped: the full rigs fall back to the actor's
  own cop pick (kind mismatch) but CrowdAtlas.cell_for(look_of) prints atlas row 7 for a LOD-1 cop,
  i.e. a far sim cop may draw as an overalls ped. Unverified by eye; check a far LOD-1 cop in a clip.

Registry rules applied (items 4-5):
- `agent-behaviour-authoring` "every dispossessed holder falls back to a stated alternative":
  the crews/squads and the roadblock all fall back to traffic/walking when the claims end (search
  over or heat 0), one release path. "Coordination is a claim on a scarce resource": the search
  clock is the point's claim; arriving crews hold it open (crew-wait) instead of a commander.
- `combat-pacing-and-dramatic-arc` "escalation must be legible": each level adds one visible
  thing (1 foot cops, 2 cars + crews, 3 squads in a different look + a roadblock), and every count
  is one data value. "Duration is a two-sided envelope": a heat 3 episode unseen lasts 75 s of
  drain; squads arrive 13-33 s after the raise, inside it.
- `cross-runtime-rules-conformance`: tune values cross as doubles (PT_SQUAD_V0/V1 are art ids
  stored as double, cast at spawn on both sides); the render guard is the same branch on both sides.

### MILESTONE item 6 part 1 (739a90264): quest 1's heat drives the city sim police
- `CityHeat.mount_quest(world, city, stage.heat)` (one call line in boot/collect_call/
  quest1_session.gd `_add_city`, outside both lanes' lists: named here) + `StagePolice.step_heat`
  (the stage's heat lines moved there; collect_call_stage.gd 262 -> 261). Quest mode: the stage's
  meter sets the level, the sim follows; last-seen starts at Rivet's start, moves on any sighting.
- heat.json city.quest1 true, quest1_patrol_cops 6, quest1_cars [0,0,0,0].
- FINDING (bisect on scenario quest1_input, 4 runs ~20-30 s each): connection with the city's cars
  2/3 + squads: FAIL "not paid: state active at beat b6-hot-walk, tick 90000"; cars 0 + patrol 0:
  pass; cars 0 + patrol 6: pass; cars 0 + patrol 6 + roadblock: pass. So the dispatched squads
  stop the bot finishing the heat 3 walk home. Cause inside (shot dead and retrying vs. blocked)
  not traced. DECISION police/quest1-heat.
- Test test_quest1_city_heat (the real Quest1Session on the city, 240 ticks): sim heat 2 = stage's,
  up to 4 city foot cops engaged; before (city.quest1 false): city_heat null (red, run).
- Quest scenarios 11/11 with it on (quest1_input 19 s).

### MILESTONE item 6 part 2 (b7f47254f, b1418a966)
- `--sim-police` (KNOWN_FLAGS; quest1_game.gd one line `StagePolice.sim_police = LaunchArgs.has(..)`,
  launch_args.gd one line: both outside the lists, named here; launch_args 200 -> 201 lines, debt
  accepted with reason). On: the stage's scripted patrols leave (patrol_pos cleared on the first
  tick), the city patrol keeps city.quest1_sim_police_cops (10), and a sim cop's sight is the
  patrols' sight while hot (StagePolice.seen). Test test_quest1_sim_police: 0 stage patrols, 10 sim
  cops after 240 ticks. quest1_input with the flag forced on: paid, 18.2 s (flag off 19.3 s).
- Quest 1 film (film.mjs quest1 --stills=300,600,1200, before = city.quest1 false): FINDING at
  739a90264: the sim cops saw Rivet through the dumpster hide and fired; people lay dead at t1200.
  Fix b1418a966: quest mode uses only the stage's sighting, and hidden = sim heat 0 (test
  test_quest_mode_a_hidden_rivet_is_heat_0_for_the_sim). After: fewer bodies, but one cop and one
  ped still lie at the left corner at t1200 (OPEN: not traced; the before has none).
  DECISION police/quest1-hide. Evidence item6_quest1_* in gtai-masters/n18/police.

### Item 7 cost (b7f47254f probe, CONTENDED: districts' gates and 5 Godot processes running, no bench lock)
`dev/sim/heat_cost.tscn` (headless, native, seed 18, heat 3 forced at t180, ticks 600-2400):
| arm | peds target | sim us/tick mean / p50 / p99 | CityHeat us/tick mean / p50 / p99 |
|---|---|---|---|
| pre-n18 police | 270 | 48.3 / 45 / 111 | 59.7 / 51 / 151 |
| living, heat 3 | 270 | 48.9 / 52 / 75 | 57.7 / 63 / 82 |
| pre-n18 police | 400 | 36.9 / 31 / 66 | 35.6 / 30 / 79 |
| living, heat 3 | 400 | 56.3 / 53 / 118 | 96.3 / 87 / 193 |
Read: the living police add ~0-20 us to the sim step; CityHeat's own step (cop_sees copies the
full snapshot every tick) is as large as the sim step: the cheap win is a sim-side "any cop sees"
query instead of a snapshot copy. All of it < 0.3 ms of the 16.7 ms tick. NOT judged: the bench's
section 20 numbers (bench lock not taken: other lanes' gates running). Files evidence/n18-police/cost/.

### Reply to districts (NEED police, their 02:5x line: more vans/pickups in the docks)
I prefer data: add the `car_mix` weight row to the docks/downtown rows of city_district.json (your
file); the car art pick is game side (`features/city/city_spawner.gd` `CAR_ART[_rng...]`, not the
sim), and I will read `CityZones.id_of_chunk` there when the row lands. It changes the spawner's RNG
draws, so the city replay digests move: one re-bless after the merge.

NEXT (session 4):
1. Gates on b1418a966 (running at session end: see the line below if it landed) + evidence run.mjs
   (look goldens) + reel gate (`node tools/reel/run_reels.mjs`) — never run yet this night.
2. Item 7 under the bench lock when nothing heavy runs (`node tools/bench/run.mjs`, section 20),
   at heat 3 if the bench can force it (else the probe at quiet). Cheap win: a sim "cop sees" query.
3. Trace the open findings: (a) the downed cop + ped at quest 1 t1200 (b1418a966 film), (b) the
   dead peds beside a dispatched car in the heat 3 clip (item5 pair t2176), (c) sim cop art variant 7
   = overalls in the crowd atlas (LOD 1 cops may draw as peds).
4. A 10-40 s quest 1 clip (film.mjs quest1 makes stills; quest1_clip.gd --ticks=<from>-<to> makes a
   clip) at heat with and without --sim-police for the REPORT Call.
5. districts' car_mix when their row lands.
6. REPORT.md: draft in the tree (uncommitted until the gates' line); finish Calls + merge notes.
Gates on b1418a966 (03:04): full unit 2876 passed / 0 failed / 2 skipped; parity bit-exact (1200
steps, mutation caught at 629); scenarios 55/55 (none CONTENDED this run); lint 19/19 (hook);
native core tests 0 failed (eaf66ffb8 build). Earlier on 739a90264: unit 2874/0, scenarios 55 ran
with rig_stress p50 CONTENDED (8 other runs). Reel gate: started 03:05 (result line below if it lands).
Reel gate on b1418a966 (03:04-03:19): top OK 315 s, tilt70 OK 299 s, combo OK 297 s (exit 0).
Still not run on this branch: tools/evidence/run.mjs (look goldens): session 4 NEXT 1.

## Session 4 (iteration 4, BUILD, 03:20-04:50)
Read: JOURNAL NEXT, git log -30, districts JOURNAL (no NEED police since the car_mix line, which I
answered in session 3; their row has not landed), no bench.lock present at 03:20.
- 03:21 gate (snapshot, `tools/gate/run.mjs --rev=HEAD`, evidence incl. look goldens) on 5a6139fbc
  started; unit 2878 / 0 failed.
- Item 7 cheap win (in the tree): `CitySimBackend.cop_sees(x, y, r)` (native flow.cpp + binding,
  reference CitySimFlow.cop_sees, op for op): CityHeat no longer copies the whole snapshot per tick
  to ask whether a cop sees Rivet. Test test_city_cop_sees: native == reference == the old snapshot
  walk (kept as the oracle) at every 20th tick of a heat 1 run, 8x6 points x 3 radii.
- Finding (c) traced (code, not yet by eye): every city foot cop carries art variant 7 (ART_COP,
  the spawner's since before n18, and CityPatrol/crews since n18). The full rig path falls back to
  a cop look on a kind mismatch (character_rigs.gd:194-196), but the LOD-1 baked crowd path
  (character_rigs.gd:135 `CrowdAtlas.cell_for(feed.look_of(i), ..)`, atlas_look(7) = row 7) does
  not: a far cop prints the overalls-bald ped. Pre-n18 (main's spawner already passes 7). The file
  is characters/ (no lane owns it tonight): NEED director, the one-line fix is the same fallback
  at :135 (`look_of` -> crowd_index_for when RigVariant.crowd(look).kind != the row's kind).
- 03:3x MILESTONE item 7 cheap win committed 05f0642c8: CityHeat us/tick at heat 3, 400 peds,
  interleaved A/B, 2 rounds each (before = the gate snapshot of 5a6139fbc, after = the tree; both
  CONTENDED: districts' gates running): mean 75.6/77.8 -> 52.4/57.8, p50 69/68 -> 48/49; sim
  step unchanged (34-40 us). The rest of CityHeat's ~50 us is GDScript->native call overhead
  (patrol counters, dispatch, roadblock, set_heat): not chased (< 0.4 % of the 16.7 ms tick).
  Files evidence/n18-police/cost/s4_{before,after}_r{1,2}_400.json.
- Gate on 5a6139fbc (snapshot, evidence incl. look goldens): PASS lint 19/19, unit 2876/0 (2 skip),
  scenarios 55/55, parity bit-exact (planted caught 629), selftest look goldens 11/11 (worst
  0.31), block goldens 5/5, export-audit 729/0 (`build/gate/5a6139fbcf6d/gate.json`).
- Finding (b) CLOSED (not a sim death): heat_clip numbers now carry bodies (sim M_DEAD), bodies
  within 4 m of a police car, and M_DOWN people. Heat 3 living at 05f0642c8, 40 s: at most 1 body
  in the whole run (t568-1448), 0 beside a police car, 0 down; at t2176 and t2400 (the frames with
  the lying peds beside the south police car and a riot cop lying by the circle) sim dead 0, down
  0. The lying figures are rig reaction poses (react_pose.gd families cower/cover/trip on the cast
  rigs, n17 npc-react's), drawn while the sim says alive. Pre-n18 police arm, same seed: up to 6
  bodies, up to 3 within 4 m of a police car (the pre-n18 pursuit drives through people).
  evidence/n18-police/s4/heat3_bodies.json.
- 03:46 Item 6 clip for the Call: quest1_clip.gd --ticks=120-1320 --ppm=32, flag off vs
  --sim-police (119 s each), hstack -> gtai-masters/n18/police/
  item6_quest1_simpolice_off_on_t120-1320_32ppm.mp4 (+ t1200 still), frames.json updated (15).
  Numbers from the HUD crops: the hide clears (HUD 2/6) at clip frame 318 off / 300 on (t756 /
  t720). Seen: the flag-off arm has the blue stage patrol by the dumpster at t720 and the
  left-corner bodies at t1200 (finding a); the --sim-police arm has neither.
- Finding (a) probe prepared: quest1_clip_rec.gd logs every 60 ticks "sim dead / killed, stage
  dead" (dev, render-free), to run once the gate frees Godot.
- 03:49 gate (snapshot) on a65570c92 started (native changed: cop_sees).
- REPORT.md updated (rows 6b/7, findings b closed / c NEED director, Calls 4-5, merge notes).
- Finding (c) re-checked: both LOD-1 paths would print atlas row 7 (overalls) for a variant 7 cop
  (character_rigs.gd:135 and native render.cpp frame_of `vr = variant_ < CLIP_VARIANTS ? ..`), but
  in the heat 3 frames (f_00272/f_00300, ~27 people on screen) every cop I can see draws blue.
  Either the full-rig selection takes every cop first or the trace misses a step. Unconfirmed;
  REPORT says so. A test would live in characters/ (not mine): NEED director.
- Finding (a) CLOSED (not a death): quest1_clip_rec's new probe line, flag off (city.quest1 true,
  the arm with the left-corner figures), t60-1320 every 60 ticks: sim dead 0, sim killed 0, stage
  hostiles dead 0 (evidence/n18-police/s4/quest1_flag_off_deaths_t60-1320.txt). The lying cop +
  ped at t1200 are rig reaction poses, as in (b). So the sim police kill nobody in quest 1's
  opening with the hide rule in place.
- Bench (item 7): the first try (--wait=10) sat 21 min in the queue behind districts' reel gate
  (its quiet wait restarts with each reel view) and was stopped at 04:19, lock released; re-run
  04:21 with --wait=0 under gtai-n18/bench.lock (CONTENDED by construction: 8 other Godot runs).
- Gate on a65570c92 (snapshot): PASS lint 19/19, unit 2878/0 (2 skip), scenarios 55/55, parity
  bit-exact (planted caught 629), look goldens 11/11 (worst 0.31), export-audit 729/0
  (`build/gate/a65570c927ae/gate.json`). 0022e89a5 after it only adds a dev log line + docs.

NEXT (session 5):
1. (done 04:34: bench exit 0, CONTENDED, heat -1 only; see the BENCH line below) a heat 3 bench needs city_bench.gd to mount CityHeat (--heat=<level>, REQUEST tools); build it if time allows.
2. Reel gate on HEAD (native changed since the last reel gate on b1418a966):
   `node tools/gate/run.mjs --reels` (~45 min with evidence).
3. Finding (c) by eye: a frame where some city cops are baked (LOD 1), e.g. heat_clip --level=3
   --zoom=0.5; if a cop prints as the overalls ped, NEED director with the frame.
4. A 64 px/m close-up for the item 6 Call (quest1_clip.gd --ppm=64 --ticks=600-1000, off/on).
5. districts' car_mix row (not landed at 04:20).
6. REPORT final at 07:40 (draft current at 0022e89a5).
- 04:34 BENCH (item 7) on 0022e89a5, `tools/bench/run.mjs --wait=0` under gtai-n18/bench.lock
  (released), exported release build, windowed, 3 runs x 4 scenarios x 60 s: exit 0 (section 20
  limits held). p99 3.291 ms, 1 % low 248 fps, worst swap 7.422 ms, worst frame 34.323 ms, hitches
  >25 ms 3 / >50 ms 0 (unexplained 0), vsync-on drive >25 ms 0, visible avg 47.9 / 10.5 / 281.0
  (drive/drive48/riot), rigs p99 0.834 ms. CONTENDED: up to 2 other runs during it.
  CAVEAT: dev/bench/city_bench.gd builds its own World with CitySystem only (no CityHeat), so the
  bench runs the sim at heat -1 (pre-n18 police): it shows the n18 native changes (sight rule,
  cop_sees) broke no section 20 limit, NOT the heat 3 cost. The heat 3 cost is the probe
  (sim step 34-40 us, CityHeat 55 us). A heat-3 bench scenario would need CityHeat mounted in
  city_bench.gd (dev/bench, no lane's file): REQUEST tools: a `--heat=<level>` bench flag.
  evidence/n18-police/s4/bench_0022e89a5_contended.txt.
NEXT (session 5, final order): the NEXT list above from item 2 (reel gate on HEAD first: native
changed since the last reel gate), then a heat-3 bench flag if time allows, REPORT final 07:40.

## Session 5 (iteration 5, BUILD, 04:50-06:20)
Read: JOURNAL NEXT, git log -30, districts JOURNAL (no new NEED police; car_mix row not landed), no bench.lock.
- 04:52 full gate with reels on 0e5d8cdad (snapshot, `tools/gate/run.mjs --rev=HEAD --reels`) started, background.
- 05:00 gate evidence half PASS on 0e5d8cdad: lint, unit 2878/0 (2 skip), scenarios 55/55, parity bit-exact (planted caught 629), look goldens 11/11 (worst 0.31), block goldens 5/5, export-audit 729/0; reels running.
- In the tree (not yet parse-checked: the gate holds this lane's one Godot): (1) the heat-3 bench
  flag (my own REQUEST tools from session 4, built here): `tools/bench/run.mjs --heat=0..3` passes
  `--heat=<n>` to every scenario; `dev/bench/city_bench.gd` mounts CityHeat via
  `BenchDriver.mount_heat` and pins the wanted level (last seen at the bench target when re-raised);
  the result JSON carries `heat`. city_bench's crowd log moved to `BenchStats.log_crowd` (stays
  under the 200-line soft cap). Node test runner_args: --heat parse + 4 malformed values, 7/7.
  (2) `dev/sim/cop_wall_trails.gd`: item 1's before/after as a picture: the reference sim's cop on
  test_city_cop_sight's wall map, 4 starts, trails at 16 px/m + ticks to cross, run in this tree
  and in police-before (36dd26ba6).
- Finding (c) chain completed in code: `boot/city_characters.gd:99` feeds `sim.get_variants()` as
  the rig feed's looks, so a cop's look is 7 and the LOD-1 cell is atlas row 7 (overalls-bald).
- 05:15 GATE PASS (full, with reels) on 0e5d8cdad: evidence half above + reels exit 0
  (`build/gate/0e5d8cdad55c/gate.json`). This covers cop_sees (native changed since the last reel gate).
- 05:18 MILESTONE 731b58e66: bench --heat and cop_wall_trails committed. Item 1 picture (reference sim,
  wall map, 4 cops, 1500 ticks): before 36dd26ba6 3 of 4 never cross (stuck 1.5-2.5 m off the wall's
  west face), after all 4 cross at 617 / 615 / 741 / 444 (the 11 m SW start crosses at 444 in both:
  it starts on the flow field). Filed gtai-masters/n18/police/item1_cop_wall_trails_before_after_16ppm.png
  (frames.json: top; dropped the superseded item6 t300 still). Looked: the before trails end at the
  wall face, the after trails run down the wall to the gap and up the east side.
  Headless 20 s riot sanity of --heat: heat 3 vs -1 actors 404.7 vs 399.8, sim step 0.106 ms both,
  crowd deaths 7 vs 17 (the living police kill fewer in the riot, as in session 4's body count).
- 05:20 bench --heat=3 under gtai-n18/bench.lock (taken 05:19, noclobber; 0 other console Godots), running.
- 05:36 FRICTION: the first `bench --heat=3` ran at heat -1: my python replace of runScenario in
  731b58e66 missed (escaped backslashes), so no scenario got `--heat`; the node summary said "heat 3"
  from the CLI alone. Caught by reading the result JSONs' new `heat` field (-1). As a heat -1 re-run it
  still counts (731b58e66, CONTENDED up to 1 other run, exit 0): p99 3.134 ms, 1 % low 264 fps,
  worst swap 9.487 ms, worst frame 40.5 ms, >25 ms 3, >50 ms 0; sim step drive 0.044 / drive48 0.051 /
  riot 0.103 ms per tick. Fixed in 6fced6b9c: exported `scenarioArgs` + a node test, and the bench
  fails when a scenario JSON reports another heat than asked. Re-run 05:38 under the lock.
- 05:53 MILESTONE item 7 bench at heat 3 (6fced6b9c, `bench/run.mjs --heat=3 --wait=2` under
  gtai-n18/bench.lock, released; every scenario JSON reports heat 3): exit 0, section 20 held:
  p99 2.389 ms, 1 % low 355 fps, worst swap 5.353 ms, worst frame 19.6 ms, hitches >25 ms 0;
  sim step per tick drive 0.041 / drive48 0.051 / riot 0.092 ms (heat -1 at 731b58e66: 0.044 /
  0.051 / 0.103); actors ~410 (heat -1: ~397). CONTENDED: 1 other run. Caveat: the heat 3 riot draws
  165 visible vs 281 (crowd leaves the riot centre once squads arrive): its frame numbers are lighter,
  not like for like. No heat.json cap needed. evidence/n18-police/s5/bench_heat3/.
- 05:55 Finding (c) by eye, heat_clip --level=3 --zoom=0.5 (16 px/m), t1440 crop at 2x: every figure
  I can name as a cop draws blue; the far figures are too small to name. Still unconfirmed; the NEED
  director line stays. Scratch deleted (nothing filed).
- 05:59 Item 6 Call close-up: quest1_clip.gd --ppm=64 --ticks=240-840, flag off vs --sim-police
  (~58 s each), hstack -> gtai-masters/n18/police/item6_quest1_simpolice_off_on_t240-840_64ppm.mp4
  + t720 still. Looked: off: a blue stage patrol crosses past the dumpster (t300) and stands beside
  it (t720), HUD 1/6; on: no patrol, HUD 2/6 Collect Call at t720. (A first try at t600-1200 was
  after the hide at heat 0, no police in frame: deleted.) frames.json 15: dropped the item6 t1200
  32 px/m still and the item4 t2244 still (their clips stay). Scratch renders deleted.

- 06:08 GATE PASS (evidence, no reels) on cd92fabc0: lint 19/19, unit 2878/0 (2 skip), scenarios
  55/55, parity bit-exact (planted caught 629), look goldens 11/11, export-audit 729/0
  (`build/gate/cd92fabc03cf/gate.json`). Reels last passed on 0e5d8cdad (05:15); since then only
  dev/, tools/bench and docs changed (no game path a reel plays).

NEXT (session 6, freeze 07:30, REPORT 07:40):
1. Final gate on HEAD (if HEAD moves past cd92fabc0 with code) (`node tools/gate/run.mjs --rev=HEAD --reels`; this session's commits after the
   0e5d8cdad gate are dev/bench, dev/sim, tools/bench and docs only: lint + node tests passed at commit).
2. REPORT final (draft current at session 5): add the gate line, check every cited path with
   `node tools/evidence/cites.mjs REPORT.md`, refresh `## Calls for the owner` order.
3. If time: finding (c) by a test-free probe (log per LOD-1 row: kind COP with look 7) instead of eyes;
   districts' car_mix row (not landed at 06:00).

## Session 6 (STABILIZE, 07:30-07:40)
- 07:31 HEAD 77ce22a5b is docs-only past the cd92fabc0 evidence gate (`git diff --stat cd92fabc0 HEAD`:
  JOURNAL.md, REPORT.md): the gate PASS stands for the final code. cites REPORT.md 5/5 ok; frames.json
  15 entries, every file present; no Godot process of mine running, no bench.lock.
- 07:35 REPORT final: title stamp, `## Next steps` added. No code change this session.

NEXT: lane done for n18. Morning: Director merges, re-blesses parity/replay once, runs the heat 3
bench quiet under the lock; finding (c) probe and quest 1 car ladder are the open items (REPORT Next steps).

## Session 7 (STABILIZE, 07:31-07:40)
- 07:32 Re-checked: `git diff --stat cd92fabc0 HEAD` = JOURNAL.md + REPORT.md only, so the cd92fabc0
  evidence gate PASS (and the 0e5d8cdad reel PASS) still covers the final code. cites REPORT.md 6/6 ok;
  frames.json 15 entries, 0 missing; no Godot process running, no bench.lock. No code change.

NEXT: lane done for n18 (unchanged from session 6). Morning: Director merges, re-blesses parity/replay
once, runs the heat 3 bench quiet under the lock; open items are in REPORT `## Next steps`.

## Session 8 (REPORT, 07:40-07:50)
- 07:42 HEAD 8ae396874 is docs-only past the cd92fabc0 evidence gate PASS (`git diff --stat cd92fabc0 HEAD`:
  JOURNAL.md, REPORT.md). No bench.lock, no Godot of mine running. masters/n18/police holds the 15 frames.json files.
- 07:45 REPORT: added `## What blocked me (and for how long)` (from the FRICTION lines), title stamp; cites re-run ok.
  No code change.

NEXT: lane done for n18. Morning: Director merges, re-blesses parity/replay once, runs the heat 3 bench
quiet under the lock; open items in REPORT `## Next steps`.
