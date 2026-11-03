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
- MILESTONE 10:30 export: preset `windows-slice` (custom feature `slice`, embedded pck) ->
  `build/export/windows/RTAI.exe` (+ the native DLL beside it); `project.godot` gets ONE line
  (SHARED FILE): `run/main_scene.slice="res://boot/quest1.tscn"`, so the slice exe boots
  straight into the title card while the normal main scene is unchanged. Exe headless smoke: rc 0.
  `--replay=<log>` / `--record=<log>` work in the slice scene (Quest1Game._replay, World exit).
- MILESTONE 10:33 checkpoints: `features/save/` Checkpoint (`gtai.checkpoint/1` v1: seed + input
  tape + state hash, tmp->rename) and InputTape. One per beat b2..b6; load = re-simulate and must
  hit the hash (exact or refused). Scenario: the b4-dock save round-trips through a file,
  resumes to b4-dock, a tampered tape is refused. Title card shows Continue when a save exists.
  Unit 335/335.
- MILESTONE 10:45 clip + doctrine:
  - clip: `masters/day-d5/slice-play/quest1-input-run-32ppm.mp4` (32 s, 30 fps, 1280 px; 12 s of
    the opening + 20 s of the Dock 9 fight), recorded windowed (d3d12) from boot/quest1.tscn
    with CollectCallInputDriver sending input events (a scripted pad, NOT a human). 960 frames
    looked at by sampling (title, 120, 600, 800, paid): 0 camera breaks rejected.
  - cops off vermilion in quest 1: cast_cop.png recoloured to cop_blue 3A4766 (d-city's WIP token
    value, hard-coded until palette.json lands); wanted pips -> new wanted_pip_police.png in
    cop_blue_hi 4F86E0; subtitle speaker names ink (vermilion is not for names). Before/after
    at ticks 240 and 7000, 32 and 48 px/m: masters/day-d5/slice-play/{before,after}{32,48}/.
  - NOT changed: Rivet's draw size in quest 1 (cast_rivet.png is a capture of the rig at true
    scale: body ~0.9 m, arm span 3.1 m). The rig proportions are d5-cast's; see REQUEST 2.
- REQUEST 2 -> d5-cast: when Rivet's rig is resized (owner verdict 1), quest 1's
  `features/quest/art/collect_call/cast_rivet.png` + `cast_rivet_peek.png` need re-capturing
  (dev/showcase/rivet_sprite.gd, 120 px/m) and `CastView.RIVET_SIZE` updating; tell me the new
  rig scale and I will re-capture, or do it in your lane.
