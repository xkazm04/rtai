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
- MILESTONE 10:50 guidance for a first-time player: ObjectiveHint (boot/collect_call) gives a
  goal point + prompt per beat state with the bound keys read from the InputMap; ObjectiveView
  draws the prompt strip under the beat panel and a vermilion ring (on screen) or edge arrow
  (off screen) at the goal. The input scenario asserts >= 10 distinct prompts (11 seen).
  Frames: masters/day-d5/slice-play/hints32/ (ticks 60..10400, 32 px/m).
- MILESTONE 10:47 exported exe re-exported (all of the above) and checked against the scenario's
  input log: `RTAI.exe --headless -- --replay=<log>` -> "replay: identical", exit 0; the same log
  with one input changed -> exit 1 ("state hash differs at tick 7620"); a missing file -> exit 2.
  So the exe's sim is the tested sim. frames.json (10 entries) + ladder.png in masters.
- MILESTONE 11:00 pause + settings (brief item 5): Quest1SettingsPanel in the pause card:
  master volume (AudioServer bus 0), reduced motion (whisper rings hold still; also
  `--reduced-motion`), keyboard rebinding for move/interact/melee/car (press Rebind, then a
  key; Esc cancels). PlayerSettings `gtai.player-settings/1` in user://settings.json, applied
  after the InputMap install. Unit 337/337, quest scenarios 3/3. Frame: masters pause32/.
- GATES at b8c7f61 (before settings): evidence/run.mjs --no-bench PASS (lint 13/13, unit 335,
  scenarios 9/9, parity exact + mutation caught, selftest goldens 11/11); copied to
  evidence/slice-play/ with the exe replay logs. No bench taken (lane changes no city cost).
- 11:00 gamepad aim follows the last-used device (LiveInput.note_event): a released right stick
  no longer snaps Rivet's facing to the resting mouse cursor. Unit 338/338.
- FRICTION: dev/frames/quest1_clip exits 0 even when a script fails to compile (one still was
  rendered from a broken objective_hint.gd before I caught it in the scenario); always run the
  input scenario first. Re-rendered the affected still.
- 11:03 Rivet in quest 1 drawn at d5-cast's base form scale: CastView.RIVET_FORM_K = 1.1/1.3
  (their RivetPlan FORMS base size_k 1.1 vs the night 1.3 the capture was taken at). The arm
  guard (guard_k 0.85) only comes with a re-capture (REQUEST 2 stays open; set the factor to 1.0
  when cast_rivet.png is re-captured from the base form). Before/after ticks 3000/7000 at 32
  and 48: masters rivet-{before,after}{32,48}/, side by side rivet-ab-48.png.
- 11:08 ANSWER to vehicles REQUEST 1: input_actions.json bits now follow the vehicles contract:
  bit 0 `car` (= VehicleService.BIT_USE, enter/exit edge; keys F / pad Y), bit 1 `handbrake`
  (Space / pad B; Space is also the on-foot melee), fire 2, melee 3, interact 4; move_x/move_y
  are the stick (move_y < 0 = up = throttle). Unit test pins bits 0/1.
  MERGE NOTE for the Director (city World, not done here to avoid a world.gd conflict with the
  vehicles lane): in `World._register_features(with_views)` add
  `var actions := PlayerActions.shipped(); actions.install(); var live := LiveInput.new(actions);
  live.viewport = get_viewport(); live.origin_px = <Rivet's screen px>; _loop.set_input(live)`.
  Quest 1's StagePilot will call `VehicleService.try_enter(at)` / `exit()` on the car press once
  quest 1 runs in the city (no cars on the invented stage; the press is logged and counted now).
- 11:12 failed card: if the contract ever fails, "The line went dead." with Retry from the last
  checkpoint / Quit (Quest1Game.restart drops the session and resumes); the input scenario
  checks Retry resumes b4-dock. (Death itself respawns at the Toner Room before the quest
  can see it, so rivet_wasted does not end the run.)
- NOTE: the timestamps on the 11:00-11:12 entries above were estimates written ahead of the
  clock; the real times were ~10:52-10:59. The clip v2 finished 11:02, the last commit 11:03.
- 11:04 objective edge arrow fixed (it sat on the beat panel and read backwards); re-exported;
  exe replays the input log identical. Clip v2 (`quest1-input-run-32ppm-v2.mp4`, current state:
  blue cops, hints, base-form Rivet) recorded; frames.json 11 entries + ladder.png refreshed.
  Frames looked at: every still listed in frames.json + clip v2 frame 700; 0 camera breaks,
  0 rejected. One frame set was re-rendered after a broken script (see FRICTION).

## State at the end of iteration 1 (HEAD after 0a8fda3)
- Exe: `build/export/windows/RTAI.exe` (git-ignored; rebuild with the export command in
  project/boot/README.md). Title -> quest 1 -> paid with keyboard+mouse or a pad; Esc pause
  with volume / reduced motion / rebinding; beat checkpoints + Continue; failed card + Retry.
- Brief items: 1 DONE (input table, controller, replay-safe); 2 PARTIAL (the quest HUD
  (boot/collect_call/view/hud_view.gd, d4 art, real state) kept, cop-blue pips, soul cards not
  drawn; not moved into features/hud); 3 PARTIAL (whispers beat-cued DONE, checkpoints DONE,
  respawn existed; the REAL ARENA is NOT done: quest 1 still plays on the invented arena with
  no collisions); 4 DONE (exe, title card, input scenario, clip = scripted pad, not human);
  5 PARTIAL (pause + settings DONE; per-control prompts are folded into the objective hints).
- NOT measured: performance (no bench this iteration; the slice adds no city cost).
  A human has NOT played the exe yet: every input-path proof is the scripted pad.

NEXT:
1. Run the exe by hand once (keyboard+mouse) end to end; fix whatever a human trips on
   (meet reach, aiming at Mertz's vent window, the walk distances).
2. Quest 1 in the real city (brief item 3, the big one): place the stage's markers on the
   generated city (CitySystem + CityView under Quest1Session), with collisions, so the owner
   plays in the D4/D5 city rather than the invented arena. Needs: a marker map from
   collect_call_places.json to city coordinates (d5-city?) and the city's walk collision.
3. After the merge: the World hookup for LiveInput (MERGE NOTE above) and StagePilot's car
   press -> VehicleService.try_enter/exit once quest 1 runs in the city.
4. Re-capture cast_rivet.png from d5-cast's base form when it merges; set RIVET_FORM_K = 1.0.
5. Move HudView/ObjectiveView into features/hud (scope) and load art by id from a table.
6. dev/frames/quest1_clip: fail with a non-zero exit when a script error is logged.
- FRICTION: editing JOURNAL.md while tools/evidence/run.mjs ran failed its "tree changed during
  run" guard (unit tests themselves 339/339). Re-ran the gate with the tree untouched.
- 11:22 GATES PASS at 36be941 (evidence/run.mjs --no-bench): lint 13/13, unit 339, scenarios
  9/9 (incl. scenario_quest1_input: paid via input events, replay identical, checkpoint
  round-trip + tamper refused, Retry, 11 prompts), parity exact + mutation caught, selftest
  goldens 11/11. Copied to evidence/slice-play/. Exe built at 0a8fda3 (code identical to HEAD).
- 11:12 scenario_quest1_keys: the keyboard path (the move_* and interact actions' InputEventKeys,
  digital): Rivet walks to the dumpster in 48 ticks and E hides him. Scenarios 10/10.
- 11:16 dev/frames/quest1_clip now exits 1 when any engine/script error is logged during a
  capture (tests/support ErrorCounter as a Logger); clean run 0, planted push_error -> 1
  ("10 engine/script error(s)"), plant reverted. Closes NEXT 6 / the FRICTION above.
- END of iteration 1 (real clock 11:13; the 11:12/11:16 stamps above were again written ahead,
  real ~11:10-11:11). Since the exe build (0a8fda3) only test and dev code changed (excluded
  from the export), so build/export/windows/RTAI.exe is current. No Godot process of mine runs.
  NEXT 6 is done; NEXT 1-5 stand as written above (1 = a human run of the exe; 2 = quest 1 in
  the real city with collisions, the largest gap against the brief).
- scenario_quest1_keys gains its TST-05 planted fault (no interact press -> Rivet stays in the
  open, caught). Scenario passes both halves.
- HUD: the d4 ammo ticket (features/hud/art/ammo_ticket.png) shows under the cash frame while a
  weapon is in hand (name; the rifle's magazine as inked digits); the cash frame's duplicate
  weapon line is gone. Frame: masters ammo32/still_7400_32.png (Gloria). The rifle-count state
  was NOT captured in a frame (unmeasured). Quest scenarios 4/4. Exe re-exported after this.
