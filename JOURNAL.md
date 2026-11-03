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
- 21:16 REJECTED frames: `king_showcase.gd -- --rivet-form=hauler` renders Rivet unchanged (base vs hauler frames
  differ only around King's idle; PIL diff bbox 675,185-991,513). RivetPlan.form is set before super._ready, so the
  showcase's Rivet must come from elsewhere (not RigPool.plan_of?). Not chased this session; frames deleted, none
  published. frames.json is empty on purpose: no power is shown in motion yet.
- Gates at f6d23a6: lint 13/13, unit 555/555 (first full run; later runs lose 1-11 save-slot cases to the shared
  user:// contention), scenarios 20/20 exit 0. No bench run (logic only, nothing on the frame path yet).

NEXT:
1. Re-read answers.json (ghost-powers-1). A dev scene `project/dev/ghost-powers/powers_pad.gd` on the real rig
   (start from `dev/showcase/rig_showcase_run.gd`): Rivet + a crowd + 2 robots (BodyContact) + 2 cars. Wire
   SoulPowers.tick, HaulerForm.step -> Rivet's velocity and `RivetBody.body_class`, and the rig scale =
   base * lerp(1, 2.6/1.2, morph_k) (find why --rivet-form did not reach the showcase Rivet first).
   Teal ghost tint on the tank's parts (souls' colour) via the part material.
2. Clips at 32 and 48 px/m (--fixed-fps 60, 10-20 s): Hauler morph + ram + stomp into a wave; Gearbox lock + drive
   into robots. Numbers: knockdowns per activation, time transformed, time to hit.
3. ASK ghost-powers-2 with those clips: the tank look (A scaled Rivet parts + teal, B scaled + armour plates,
   C new art: ask before generating) and duration/cooldown (8 s / 20 s now).
4. Stomp wind-up ~0.3 s (registry band), a stomp input (melee while transformed?), ram damage to cars through
   VehicleService; Gearbox through `VehicleService.soul_hijack_traffic(slot)` in the city block.
