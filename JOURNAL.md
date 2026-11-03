# JOURNAL - lane slice-play (branch d-slice), day run 2026-11-03

## Iteration 1 (10:07 - 11:37)

- 10:07 read: git log, AGENTS.md, features/quest README, boot/collect_call (stage, view, HUD),
  dev/bots (CollectCallBot, CollectCallPlay), core/replay (TickInput, SimLoop).
  Found: quest 1 already has a stage + a CollectCallView (PrintStage, D4 HUD art) driven by
  the bot; no player controller, no InputMap actions, TickInput unused by the stage.
- MILESTONE 10:20 bound input + player controller:
  - `data/tables/input_actions.json` (`gtai.input-actions/1`) + schema: every action's bit, keys,
    mouse, gamepad buttons/axes, the aim quantisation (8-bit heading above bit 16 of
    TickInput.buttons) and the movement feel (accel 30, brake 40 m/s2, turn 720 deg/s,
    strafe 0.85).
  - `features/player/`: PlayerActions (installs the InputMap at boot, rebindable later),
    LiveInput (InputSource: devices -> quantised TickInput, so the replay log carries it),
    PlayerCommand (decode, press edges), TopDownMover.
  - `boot/collect_call/stage_pilot.gd`: TickInput -> StageIntent (move_by from the mover,
    interact press, fire along the aim, electroshock jab: cone 1.6 m, 30-tick cooldown,
    car key stubbed). CollectCallStage gets `pilot` (null for the bot; hash unchanged then).
  - SHARED FILE NOTE: no `project.godot` [input] entries: the actions are registered at boot
    from the data table (PlayerActions.install) so the table is the one source and rebinding
    edits the InputMap. project.godot untouched so far.
- MILESTONE 10:25 the slice scene `boot/quest1.tscn` (Quest1Game + Quest1Card: title card
  start/quit + controls, pause on Esc/P/Start, paid card) on Quest1Session (World + stage +
  quest + pilot + LiveInput).
- MILESTONE 10:27 `tests/scenarios/scenario_quest1_input.gd`: the main scene, Start pressed,
  CollectCallInputDriver turns the bot's decisions into InputEventJoypadMotion / the interact
  InputEventKey -> paid +$1500, all 6 beats, 49 kills, 0 deaths, 11464 ticks (191 s), 1294
  input changes, recorded log replays identical. Bot scenario unchanged (passes).

## REQUESTS
- REQUEST 1 -> vehicles: the car key (`car` action, bit 3) is stubbed in StagePilot.drive
  (logs + counts). Proposal: `VehicleSeat.toggle(stage_or_world, rivet_pos: Vector2) -> bool`
  (true when Rivet got in/out). Tell me the name you expose and I will call it.
