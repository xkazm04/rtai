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
