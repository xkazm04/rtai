# JOURNAL: ghost-powers (branch e-powers)

## 2026-11-03 iteration 1 (20:53-21:38), BUILD

- 20:53 read: brief, collisions/vehicles/d5-cast reports (body classes, `soul_hijack_traffic`, `RivetPlan.FORMS`).
  answers.json empty.
- Registry applied: `ability-authoring-to-engine` (the three agreements: power ids/bark ids/actions are a closed
  namespace in powers.json, a strict schema, and runtime proof from the engine's own run: the scenario, not a summary);
  `realtime-combat-semantics` (reaction budgets: Hauler morph 0.4 s = bottom of the 0.4-1.5 s wind-up band).
  Deviation: the stomp has no wind-up yet (instant), outside the band; next iteration adds ~0.3 s telegraph.
- MILESTONE 837d778: framework (SoulPowers/PowerDef/PowerTable), HaulerForm, GearboxLink, powers.json + schema,
  bodies.json `rivet_ghost` live with 9 rules, RivetBody.body_class (minimal change in features/bodies, default
  unchanged), RivetPlan.FORMS `hauler` (2.6). 18 unit tests; full unit run 555/555.
- SHARED FILE a0b700e: `input_actions.json` +2 rows: power_hauler (bit 5, Q, joy 9 LB), power_gearbox (bit 6, G, joy 10 RB).
- MILESTONE b67c943: `arena_stations/ghost-powers.json` (hauler_pad, gearbox_pad on the pad rect). The arena lane's
  `arena_station.schema.json` and its lint hunk (`tools/lint/lint.mjs`) are byte-identical copies of e-arena a2467d8
  so the merge is clean. If arena changes either before 00:00, take theirs.
- MILESTONE ae1dbe7: `scenario_souls_powers`: tank at 4.2 m/s knocks down a human in the real city sim (base Rivet at
  the same speed: 0 knockdowns, planted), knocks down a robot (base: blocked), stomp 6/6 ring (r=0 planted: 0),
  Gearbox car turns onto a robot 17 m off-axis and wrecks at 14 m/s in 1.42 s (turn 0 planted: never reaches).
- FRICTION: GUT loads with return_value_discarded as error: `connect()` needs `@warning_ignore`, `append()` on
  Packed arrays too. `test_save_slots` fails a different case each run when other lanes run the suite at the same
  time (shared `user://test_save`), not this lane's code; the first full run was 555/555.
- ASK ghost-powers-1 (Gearbox control: aim-to-steer vs target-and-launch), default A.
