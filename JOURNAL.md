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
