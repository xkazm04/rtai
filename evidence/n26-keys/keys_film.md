# Keys in play

The take follows Rivet along the dev arena's firing range. The range supplies a hit-reporting dummy, the standard live player input and all four unlocked ghosts. A yellow sedan is parked in the back lane. The dev scene supplies Rivet's foot position to the arena vehicle service and follows its seat and door positions. The normal service decides whether the shared car/Dent press finds a seat, drives the sedan and completes the door walk.

For each key edge the scene duplicates the first keyboard event installed for that action by `PlayerActions.install()`, sets its pressed state, and passes it through `Input.parse_input_event()`. Godot flushes the event before `LiveInput` samples the fixed tick. The cap prints the same event's physical-key text and fades for 18 ticks after release. Only the analogue movement and aim sticks use `OpeningFilmPad`.

The arena does not mount the gauntlet HUD that normally registers `en.po`. The ghost cap now resolves the ghost msgid used by the gauntlet card against that same translation resource. Quick claw uses the prologue prompt. Sprint, Dash and Car use their translated action ids with display capitalization. The desktop HUD shows all four names in number-slot order, and the story strip still folds to the current or selected form. A separately rebound deploy command can still show its own binding.

## Inputs and observed results

Ticks are zero-based simulation ticks at 60 Hz. The intervals between releases follow the previous form's deployed cooldown from `ghost_attacks.json`. Dent, Kerf and Ohm set the three gaps to 480, 600 and 480 ticks. Each form has its own timer and apparition lifetime.

| Down | Up | Physical key | Action | Result |
| ---: | ---: | --- | --- | --- |
| 66 | 186 | Space | `sprint` | Sprint active at 100. Held for 2.00 s. |
| 200 | 206 | Shift | `dash` | Dash count rose to one at 200. |
| 260 | 266 | F | `melee` | Quick claw. The pilot and the 35 m dummy recorded a hit by 282. |
| 315 | 394 | 1 | `ghost_deploy_1` | Aimed Dent away from the sedan. Deployed `dent` at 394. |
| 509 | 874 | 2 | `ghost_deploy_2` | Deployed `kerf` at 874. |
| 989 | 1474 | 3 | `ghost_deploy_3` | Deployed `ohm` at 1474. |
| 1589 | 1954 | 4 | `ghost_deploy_4` | Deployed `tonnage` at 1954. |
| 2104 | 2110 | 1 | `car` | Began the door walk. Seated at 2117. Dent deployments stayed at one. |
| 2348 | 2354 | 1 | `car` | Stepped out at 2357. The sedan travelled 24.24 m. |

The scene records a deployment on entry into `GhostDeploy.Phase.ACTIVE`, checks the form on each release and checks the full ordered list at the end. Car entry and exit are observed from `VehicleService.driving`. The seat was occupied for 240 ticks (4.00 s), including acceleration and braking.

## Capture

The masters are in `C:/Users/kazda/kiro/gtai-masters/n26/keys/`. The keys film is one continuous take from `res://dev/controls/keys_film.tscn`, using `--view=tilt70 --ppm=32 --clean --car-doors`. The runner was `tools/dev/run.mjs` with its windowed runner callback supplying the engine switches `--position 0,1440 --rendering-driver d3d12 --resolution 1920x1080 --fixed-fps 60 --write-movie`. The capture project under `build/` mounted this worktree's resources and set its viewport to 1920×1080 before Movie Maker started, as in `tools/film/ghost_films.mjs`. FFmpeg encoded the AVI to H.264 with AAC audio.

The 64 px/m still uses the same scene and inputs with `--ppm=64 --shot-tick=368`. It shows Dent's 8 m aiming ring, ram path and held number key after 368 completed steps.

`ffprobe` on `keys_overlay_32.mp4` returned this video stream.

```text
codec_name=h264|width=1920|height=1080|r_frame_rate=60/1|duration=39.733333|nb_frames=2384
```

I inspected 17 frames extracted from the encoded MP4. Frames 30, 108, 204 and 264 show the opening walk, Space sprint, faint Shift dash trail and F claw at the dummy. Frames 367/398, 735/880, 1260/1481 and 1790/1962 show each numbered cap and its release effect. In 2107/2119 Rivet reaches the yellow sedan and disappears into its seat. Frame 2210 follows the car along the back lane. Frames 2351/2373 show the second car press and Rivet back on foot. The caps sit in the lower centre. The lower-left strip reads 1 Dent, 2 Kerf, 3 Ohm, 4 Tonnage, with no cycle arrow or chevron. The camera keeps Rivet or his occupied car centered. At frame 201 the fading Space cap and the new Shift cap both fit between the left strip and the right-hand HUD. The desktop strip ends at x=324 and the cap row begins at x=806 in the 1920 px frame.

The movie runner exited 0 with no script errors. Godot warned about the p70 Ohm hover sheet and reported resources still in use at shutdown. The earlier arena opening capture logs the same warnings. Ohm's apparition and electrical strike are visible at frame 1481.

One discarded 32 px/m take logged `tick 1637 | deployed tonnage` before its scripted key-up. The recorder rejected it with `tick 1954 | missing deploy tonnage | refusal`. No extra key-up appeared in the scripted input log. The unchanged retry deployed Tonnage at 1954 and completed the entire press log above.

## Gloria beside the pistol

`gloria_vs_pistol_64.png` uses the arsenal turn recorder with a fixed eastward aim. Both weapons stand at tick 60 and walk at tick 100 with the same foot position and facing in each pair. The turn tool maps `--pitch=p55` to `ViewMode.select("tilt")` and `--pitch=p70` to `tilt70`. The four panels preserve the captured 64 px/m scale.

Standing, Gloria looks like a long gun cradled in both claws, while the pistol sits in one. The visible gun lengths, measured rear to muzzle along the weapon axis at native scale, are approximately **80 vs 54 px at 70°** and **60 vs 38 px at 55°** (Gloria vs pistol). The 55° Gloria walk also draws the held part back toward Rivet's hip despite the rightward aim.

## Verification

The scene and script passed the Godot parse check. Full lint passed all 19 checks, including layers and formatting. The original film commit updated only the authorized dev line-count baseline. The HUD changes passed the quick gate. The final changed suite ran 4,002 passing tests, with zero failures and two skips. Its nine HUD tests include an actual draw that records the four names and their numbered labels after rebinding the cycle action.

Quest 1's Dent-lock scenario reads the widget in `scenario_quest1_dent_lock.gd:69` through `hud.locked.get(DENT, false)`. The headless scenario log includes both lines below.

```text
run_scenarios: [38/68] quest1_dent_lock ok, 0.6 s
run_scenarios: 68 ran, 0 failed
```
