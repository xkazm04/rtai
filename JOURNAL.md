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
- 11:14 exe rebuilt at cdfb800 (replay identical, windowed boot clean). Full evidence gate last
  green at 36be941; since then: the keys scenario (+fault), the clip tool exit code, the ammo
  ticket; lint + all quest scenarios re-run green after each. NEXT unchanged (1 human run,
  2 quest 1 in the real city, 3 post-merge World/VehicleService hookup, 4 Rivet re-capture,
  5 HUD into features/hud).

## Iteration 2 (real clock 11:15 - )

- 11:16 read JOURNAL, git log; picked NEXT 2 (quest 1 in the real city), the largest gap.
- FRICTION 11:20-11:33: two runs of a new `-s` dev tool error-looped silently for 6.5 + 4 min:
  a `-s` SceneTree script that names game classes compiles before the `Log` autoload exists.
  Fix: the -s entry `load()`s its body in `_initialize` (the run_scenarios pattern):
  `dev/quest1_city_fit.gd` + `dev/quest1_city_fit_run.gd`. Also: always `| head` the first
  errors of a new tool before a long timeout.
- MILESTONE 11:35 quest 1 on the generated city (sim): `collect_call_city.json`
  (`gtai.collect-call-city/1`) lays the stage along one street, world = origin + stage * squash
  (276,265.85; 1 x 0.3; dev/quest1_city_fit found 4017 clear fits on 4 streets near the city
  start, 15 s). StageLayout.shipped(city) maps every place/actor/spawn/patrol/metal point;
  StageCells (CityGen chunks, CitySimSolid's solid rule) pushes Rivet out of buildings, props
  and parked cars; the CitySystem bubble follows Rivet (stage sets focus each tick), people only
  (no traffic, no city police). `Quest1Session.on_city` (static, default true; the bot scenario
  keeps the invented arena through CollectCallPlay). Input driver fixes for the city: stick
  floor past the dead zone, stand tolerance 0.15 m (it stalled 0.05 m short of Juno), and no
  wait for a tazer hit on the city (squashed vault metal is within the ball's chain reach, so
  the ball bursts short; a human still beats Mertz in his vent window). Commit 2092706.
- MILESTONE 11:38 the slice draws on the real CityView: CollectCallView.city_view puts the
  quest's props, cast and FX on CityView's actor layer; StageView.zones=false (no invented
  floors); CityView's camera follows the city focus = Rivet. Commit 23bc30b.
- 11:41 crowd: 120 people existed (counters) but ~3 per screen; 300 + CityCharacters (crowd
  atlas + near rigs, rivet_on_foot=false so Rivet is drawn once, by the quest cast). 42a304d.
- GATES PASS at 42a304d (evidence/run.mjs --no-bench): lint 13/13, unit 339, scenarios 10/10
  (scenario_quest1_input: paid on the CITY via input events, all 6 beats, checkpoint
  round-trip + tamper refused, Retry; replay identical), parity exact + mutation caught,
  selftest goldens 11/11. Copied to evidence/slice-play/iter2-42a304d/.
- 11:50 exe re-exported at 42a304d (`build/export/windows/RTAI.exe`); `RTAI.exe --headless --
  --replay=<the gate's city input log>` -> "replay: identical", rc 0.
- Frames (masters/day-d5/slice-play): city32/ (ticks 240, 2400, 7000, 8400, 10400), city48/
  (240, 7000), clip `quest1-city-input-run-32ppm.mp4` (32 s; 966 frames; scripted pad, NOT a
  human), contact sheet clip32city_sheet.png. Looked at: 7 stills + 6 clip frames; 0 camera
  breaks, 0 rejected. frames.json now 13 entries (city first; the arena ones marked as before);
  ladder.png +2 rows (arena vs city at ticks 240 and 7000). No bench (no lock taken; the city
  under quest 1 = the normal city bubble with 300 people, cost UNMEASURED).
- Known gaps (honest): Toner Room and Dock 9 are a street, not rooms; contractors and the boss
  do not collide with buildings (they come along the street); StageCells generates its own
  CityGen chunks (a first-touch hitch per chunk, ~3 chunks, unmeasured).
- 11:55 contractors and Mertz pushed out of solid cells after the arena step (a5e89c6); quest
  scenarios 4/4 (bot scenario on the arena unchanged: 11436 ticks, cash 1500).
- 11:57 (7495d70) city cells generated at load (2 chunks, 21-41 ms headless, logged), place
  names stencilled on the street in road paint (the places table's marker ids, r >= 3 m), and
  ObjectiveView reserves the subtitle band only while a line is on screen (the ring had turned
  into an edge arrow beside a visible Juno). Frame city32b/still_2600_32.png; the "before"
  still was overwritten in the same folder (seen, not kept).
- 11:59 (9774d03) the line hooks moved to StageLines; collect_call_stage.gd 255 -> 236 lines.
- GATES PASS at 9774d03 (evidence/run.mjs --no-bench): lint 13/13 (358 files), unit 339,
  scenarios 10/10, parity exact + mutation caught, selftest goldens 11/11. Copied to
  evidence/slice-play/iter2-9774d03/.
- 12:01 exe re-exported at 9774d03; `RTAI.exe --headless -- --replay=<gate's city input log>`
  -> "replay: identical", rc 0 (city cells 2 chunks, 12 ms in the release exe).
  frames.json 14 entries (masters). No bench this iteration (no lock taken): the slice's frame
  cost on the city with 300 people is UNMEASURED.

## State at the end of iteration 2 (HEAD 9774d03 + journal)
- The exe boots to the title card and plays quest 1 ON THE GENERATED CITY (D4 print, crowd,
  parked cars, collisions for Rivet and the hostiles) to paid with keyboard+mouse or a pad.
  Proofs: scenario_quest1_input (simulated pad events, paid, replay identical, checkpoints),
  scenario_quest1_keys (WASD+E), the city clip (scripted pad). A human has still NOT played it.
- Brief items: 1 DONE; 2 PARTIAL (HUD wired, not moved into features/hud); 3 DONE except
  places-as-rooms (Toner Room and Dock 9 are a street with a stencilled name); 4 DONE (exe,
  scenario, clip on the city); 5 PARTIAL (pause/settings DONE, prompts folded into hints).

NEXT:
1. A human run of the exe end to end (owner at 18:00, or the Director): watch the meet reach,
   Mertz's vent window, walking along the street with parked cars in the way.
2. Bench the slice under bench.lock (city + 300 people + quest + rigs), CONTENDED label.
3. Places: re-run dev/quest1_city_fit with a plaza block for the Toner Room / a wider fit for
   Dock 9, or ask d5-city (REQUEST) for an authored dock lot; give the vault metal its own
   offsets so the Robo-tazer ball reaches Rivet again (then the bot can wait for a hit again).
4. After the merge: StagePilot's car press -> VehicleService.try_enter/exit (cars are now
   parked right beside Rivet); the World LiveInput hookup (MERGE NOTE, iteration 1).
5. Re-capture cast_rivet.png from d5-cast's base form; RIVET_FORM_K = 1.0 (REQUEST 2).
6. HudView/ObjectiveView into features/hud, art by id from a table.
- 12:03 (603b852) Robo-tazer on the city: the ball homes on any metal within 14 m while Rivet
  is farther away, and the squash had put the (106,-10) post 0.3 m off the boss->Rivet line, so
  every ball burst on it (Mertz harmless). Metal now keeps its true offsets around Mertz's post
  (spawn `vault-cage`); the input driver waits for a tazer hit again (bot flag removed) and
  the run is paid, so the ball reaches Rivet on the city. Decision line updated.
- 12:05 (a1cf583) dev/bench/quest1_frames: the slice's frame time (windowed, vsync off, one
  tick per frame from tick 5800 = Dock 9). Headless smoke only so far (not a measurement).
  bench.lock held by `vehicles` (10-14 min old): bench skipped until it frees or goes stale.
- 12:05 exe re-exported (code = 603b852): replays the 12:03 input log identical, rc 0.
- GATES PASS at a1cf583 (lint 13/13 over 360 files, unit 339, scenarios 10/10, parity,
  selftest 11/11) -> evidence/slice-play/iter2-a1cf583/.
- 12:12 (adde04f) unit tests for StageCells and the city mapping: 344/344. One first draft put
  the test point 0.7 m deep in a parked car (one push-out pass does not clear that; Rivet moves
  cm per tick, so the test now overlaps the edge by 0.25 m like a real step).
- 12:15 BENCH under bench.lock (taken after vehicles and d5-combat released it; released
  right after): dev/bench/quest1_frames, Dock 9 fight on the city (from tick 5800, beat
  b4-dock), 1200 frames, one tick per frame, vsync off, d3d12, viewport 1422x800 (the window
  came up smaller than the 1920x1080 asked). CONTENDED: p50 1.81 ms, p95 5.65 ms, p99 11.95 ms,
  max 20.38 ms (one frame over 16.7). evidence/slice-play/slice-frames-32ppm.json.
- 12:16 (fe40b14) stencils only for places r >= 5 m (the vault cage's name sat unreadable
  under the crates); CollectCallView prewarms the CityView's chunks where Rivet stands (a
  Continue or Retry starts mid-street). The prewarm on resume is NOT verified in a frame.
  Frames: city32c/still_{7000,8200,8400}_32.png (Mertz venting, the tazer arcs reaching Rivet).
  REJECTED 1 frame: a still taken as the first capture after a camera jump to tick 8200 showed
  half the city unstreamed (cream void); re-taken after a 7000 warm-up. frames.json 15.
- 12:17 exe re-exported at fe40b14: replays the 12:03 input log identical (rc 0); windowed
  boot of the exe (--quit-after 180, d3d12) rc 0, no errors logged.
- GATE at fe40b14 (evidence/run.mjs --no-bench): lint 13/13, unit 344, parity, selftest PASS;
  scenarios 9/10: scenario_city_chase FAILED on its wall-clock nav budget (native flow field
  max 2442 us > 2 ms, one tick of 49). Isolated it passes twice (max 171 / 209 us); a second
  full suite failed it again (2442 us). My diff since the green gate at a1cf583 touches no
  features/ or native/ code, and city_chase runs before every quest scenario. Read as
  CONTENDED (seven lanes on one machine), NOT proven: Director, re-run it on a quiet machine.
  Evidence copied to evidence/slice-play/iter2-fe40b14/ (it records the FAIL).
- FRICTION: a wall-clock budget assert inside the scenario gate fails under shared-machine
  load; it is the d4/city lane's test, so I did not touch it.

## End of iteration 2 (real clock 12:25)
- Exe `build/export/windows/RTAI.exe` at fe40b14: title -> quest 1 ON THE GENERATED CITY
  (D4 print, crowd, parked cars, collisions for Rivet and the hostiles, place stencils) ->
  paid; keyboard+mouse or pad; pause/settings; checkpoints + Continue; Retry.
- Slice frame time on the city (Dock 9, CONTENDED): p50 1.81, p95 5.65, p99 11.95, max 20.4 ms.
- No Godot process of mine is running; bench.lock released.

NEXT:
1. A human run of the exe end to end (owner/Director): the street meet with the four allies,
   Mertz's vent window, parked cars in the way, Continue mid-street (prewarm unverified).
2. Director: re-run scenario_city_chase on a quiet machine (failed here only under load).
3. Places as rooms: a plaza block or authored lot for the Toner Room and Dock 9 (fit tool
   with a plaza constraint, or REQUEST d5-city).
4. After the merge: StagePilot's car press -> VehicleService.try_enter/exit (parked cars
   now stand beside Rivet); the World LiveInput hookup (MERGE NOTE, iteration 1).
5. Re-capture cast_rivet.png from d5-cast's base form; RIVET_FORM_K = 1.0 (REQUEST 2).
6. A city clip v2 at fe40b14 (the current one is 42a304d: no stencils, tazer bursting short).
- 12:25 clip v2 NOT recorded: bench.lock held by `collisions` (a render would skew their bench). Deleted my 2.6 GB of clip PNG scratch (mp4 + sheet kept).

## Iteration 3 (BUILD, 12:24 - 13:54)
- 12:26 read JOURNAL + git log. Picked brief item 2's open half (HUD into features/hud, art by
  id from a table: the lane rule "load art by id from the data tables, never by hard-coded
  texture paths" was broken by HudView's `HUD_ART + name + ".png"`).
- MILESTONE 12:31 (19eb758) the HUD lives in features/hud: `HudView` draws a plain `HudState`
  (`hud_state.gd`, words already translated), filled each frame by boot's `HudFeed`
  (`boot/collect_call/view/hud_feed.gd`), so features/hud reads no stage/quest internals
  (LAY-05). Art by id from `data/tables/hud_art.json` (+ schema `gtai.hud-art/1`) through
  `HudArt`: ids, authored size_px, the numeral strip's metrics and the memo 9-slice margin. An
  unknown id or failed load draws a 4x4 ink square and logs once (an art lane landing later
  cannot crash the scene). Heat pips stay `wanted_pip_police` (the blue pip art; a small mark,
  so the brighter cop blue is in doctrine). Soul cards not drawn (verdict 3).
  Tests: test_hud_art (6): every row loads at its size_px, the pips, the placeholder, digit
  metrics vs the strip, thousands, silent(). Gates: lint 13/13 (365 files), unit 350/350,
  scenarios 10/10 (city_chase passed this time).
- Frame check: hud32/still_7000_32.png (after) vs city32c/still_7000_32.png (fe40b14, before):
  the HUD is pixel-identical (a pure refactor, as intended).
- FRICTION/REJECTED: both 7000 stills (the iteration-2 city32c one and my first after) were a
  CREAM VOID behind the HUD: the stills tool steps 7000 ticks with no frame drawn, and ChunkView
  streams under a 1.5 ms/frame budget. city32c/still_7000 was never in frames.json (the
  42a304d city32/still_7000 there is fine; re-checked). Rejected 2 frames this iteration.
- CORRECTION to fe40b14's note: `CityView.prewarm()` (ViewPrewarm) warms pipelines and places
  the camera; it does NOT stream chunks. So a Continue/Retry mid-street drew its street in over
  several budgeted frames. Fix: `CollectCallView.fill_street()` loops `chunks.update()` until
  nothing is left to slice (resident chunks only; the sim's residency is not touched, so the
  replay is unaffected), called when the view comes up on the city; the stills tool calls it
  before each still.
- dev/frames/quest1_clip: `--save=<file>` (the game writes beat checkpoints there) and
  `--continue` (press Continue on the title, save continue_f1 / continue_f6, quit) so the
  Continue path can be checked in a real frame.
- MERGE NOTE -> autosave (d-save), the 11:45 brief item, recorded at 12:41: every place the
  slice touches features/save today, so the merge can point them at core/save `Save`:
  1. Title card Continue: `boot/quest1_game.gd:43`
     `card.continue_pressed -> restart(Checkpoint.load_file(save_path))`; the Continue button
     shows when `Checkpoint.load_file(save_path) != null` (`quest1_game.gd:48`, title).
  2. Failed card Retry: `quest1_game.gd:115` `card.show_failed(Checkpoint.load_file(save_path)
     != null)`; Retry emits the same continue_pressed path (restart from the last checkpoint).
  3. Beat checkpoint write: `quest1_game.gd:106-108` each frame
     `session.poll_checkpoint()` (`boot/collect_call/quest1_session.gd:105`: non-null once per
     new beat; carries quest, beat, tick, master_seed, state_hash and the InputTape history)
     -> `cp.save(save_path)`. These are quest 1's natural `autosavePoints` (one per beat).
  4. Resume: `Quest1Session.resume(Events, Data, cp)` (`quest1_session.gd:88`) replays the
     tape to cp.tick headless and refuses a state_hash mismatch (tamper refused, scenario).
  5. Paid: `quest1_game.gd:148` `Checkpoint.erase(save_path)` (a finished contract leaves no
     Continue).
  6. Respawn on death does NOT touch the save: `CollectCallStage._respawn()`
     (`boot/collect_call/collect_call_stage.gd:229`) puts Rivet back at the Toner Room in-sim
     (deterministic, in the replay). No change needed there for the merge.
  `save_path` defaults to `Checkpoint.DEFAULT_PATH`; tests and dev tools pass "" (no saves) or
  their own file. Since 11:45 I have not extended features/save (only read it).
- 12:38 GATE (separately): lint 13/13, unit 354, scenarios 10/10 at cbeada4. Exe re-exported
  at cbeada4 (12:39): `RTAI.exe --headless -- --replay=<gate's input log>` -> identical, rc 0.
- 12:39 Continue frames (masters cont_before/ vs cont_after/, 32 px/m, from a real tick-7000
  Dock 9 checkpoint written by the game through `--save`): before = frame 1 a cream void with
  the props floating (street in by frame 6); after = the whole street at frame 1 (16 chunk
  passes). The fill is VERIFIED in a frame now. FRICTION: d5-combat took bench.lock while my
  ~40 s `--save` stills run was already rendering (12:32); I rendered nothing more until it
  was released (12:37). The Continue captures ran with no lock held by anyone.
- Seen but not chased: a bright radial glow on Rivet in the tick-7000 stills after 42a304d
  (absent at 8400). The light layer's add/remove looks right; most likely a gameplay light (the
  scripted pad shocks there). UNVERIFIED.
- 12:41 (f29734c) prompts teach pause in the first minute ("Stay hidden. Let the sirens pass.
  [Escape] pauses.") and the Dock 9 prompt names the aim device ([mouse] / [R-stick]). With
  cbeada4 the prompts name the pad's buttons (A, X, RT, Start, L-stick) once a pad was used
  last (LiveInput.pad_last; a key or the mouse switches back; aim is unchanged). Unit 355.
- 12:45 (08181b4) the cast, stage and FX views load art by id from
  `data/tables/collect_call_art.json` (generic `core/data/art_ids.gd` ArtIds + QuestArt). The
  Rivet / peek / cop captures carry their drawn size (size_m x draw_k) in the table.
  REQUEST 2 -> d5-cast UPDATED: a Rivet re-capture at the base form is now a table edit (new
  file, its size_m, draw_k 1), no code. Unit 359, scenarios 10/10.
- frames.json (15): + cont_after/continue_f1 (before cont_before), the Dock 9 entry now the
  hud32 still (before city32), the arena v2 clip dropped. ladder.png + 1 row (Continue f1).

## Iteration 47 (BUILD, 15:40 - 17:00)
- 15:41 read JOURNAL + git log. Found work from 13:05-13:12 that was never journaled: clip v3
  (masters quest1-city-input-run-32ppm-v3.mp4, 13:03, already in frames.json), 69ee1cd
  (quest1_clip --continue steps one tick per frame after the press) and an UNCOMMITTED fix in
  quest1_session.gd (city.residency.update(focus) before tick 0). Its frames were already
  shot: masters start_before/continue_f1.png (the first frame after Start = a cream void with
  props floating) vs start_after/continue_f1.png (the whole street). Looked at both: VERIFIED.
- GATES on that diff: lint 13/13 (369 files), unit 359/359, scenarios 10/10 (quest1 input run
  paid, replay identical, checkpoint resume + tamper refused). Committed d0d092e.
- 15:43 exe re-exported at d0d092e: `RTAI.exe --headless -- --replay=<gate's input log>` ->
  "replay: identical", rc 0.
- MILESTONE 15:47 (77ccc39) verdict 1 in the slice: Rivet re-captured from d5-cast's base form
  (RivetPlan FORM_BASE: size_k 1.2, guard hands hunched as T2; d-cast 062939d). I copied
  d-cast's rivet_plan.gd into my tree for the capture only and restored it (not committed:
  d5-cast's file; after the merge the rig and the quest sprite agree). Sprite 328 x 348 px =
  2.73 x 2.9 m at 120 px/m (centred, the hands forward), drawn at true scale (draw_k removed);
  the night capture was 3.1 x 3.9 m drawn at 0.846. Side by side with the gun-out cop:
  masters rivet-base/compare_old_new_cop.png (old at its drawn size | new | cop): Rivet is now
  about 1.2x a cop's width, the arms no longer spread. The parts in the tree are the grimed D5
  ones, so the sprite also picks up the D5 hatching. Unit test now pins true scale for both
  captures and Rivet's frame shorter than the gun-out cop's. REQUEST 2 -> d5-cast: CLOSED here.
- FRICTION: the 15:45 capture (a ~5 s windowed render of one rig) ran while d5-combat held
  bench.lock (taken 15:42); I checked the lock in the same command instead of before it. Short,
  but it could have touched one of their frames. The in-game before/after stills wait for the
  lock to be released.
