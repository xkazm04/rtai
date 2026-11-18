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
