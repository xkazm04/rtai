# REPORT - lane slice-play (branch `d-slice`), day run 2026-11-03

Mission: at 18:00 the owner double-clicks a Windows exe and plays quest 1 "Collect Call" from the
start to "paid" with keyboard and mouse (or a pad) in the D4/D5 city.

**Short version:** the exe is at `build/export/windows/RTAI.exe` (git-ignored, 193.7 MB, built
17:11 at `ebe1dd6`, with the native release DLL beside it). Double-click it to get the title card
(Start / Quit / Continue), then quest 1 on the **generated city** through to "paid". Every gate is
green at HEAD. **Nobody has played it by hand yet.** Every input-path proof so far is a scripted
pad sending simulated InputEvents.

Masters (outside git): `C:\Users\kazda\kiro\gtai-masters\day-d5\slice-play\` (written `M/` below).
Evidence in git: `evidence/slice-play/`. Detail: `JOURNAL.md`.

## What works (each claim has its evidence)

| # | Claim | Evidence |
|---|---|---|
| 1 | **Bound input as data.** `data/tables/input_actions.json` (`gtai.input-actions/1` + schema) holds the keys, mouse, pad buttons/axes, the action bits (bits 0/1 follow the vehicles contract: `car` F / pad Y, `handbrake` Space / pad B) and the movement feel (accel 30, brake 40 m/s², turn 720°/s, strafe 0.85). `PlayerActions` installs the InputMap from the table at boot, so `project.godot` has no `[input]` entries. `LiveInput` quantises the devices into `TickInput`, so the replay log carries the input. | `project/features/player/`, `project/data/tables/input_actions.json`; unit 359/0 `evidence/slice-play/unit-it53.log` |
| 2 | **Quest 1 plays to "paid" through bound input, deterministically.** `scenario_quest1_input` loads the main scene, presses Start, drives simulated pad InputEvents and reaches paid +$1500 with all 6 beats. The recorded log replays identical, a beat checkpoint round-trips through a file, a tampered tape is refused, and Retry resumes. `scenario_quest1_keys` covers WASD+E and has a planted fault that the test catches. | `evidence/slice-play/scenarios-it53.log` (10 ran / 0 failed, rc 0, at code `ebe1dd6`); `evidence/slice-play/quest1-input.json` |
| 3 | **Quest 1 runs on the generated city**, not the invented arena. It uses the real CityView, the crowd (300 people, crowd atlas + near rigs), parked cars, and collisions for Rivet and the hostiles against buildings, props and cars (`StageCells`). Place names are stencilled on the street. The Robo-tazer reaches Rivet. | frames.json entries 1, 4-10; `M/city32/`, `M/city32b/`, `M/city32c/`, `M/art32/`, `M/art48/` |
| 4 | **The exe is the tested sim.** `RTAI.exe --headless -- --replay=<gate log>` gives "replay: identical", rc 0. A tampered log gives rc 1, and a missing file gives rc 2. | `evidence/slice-play/exe-replay-identical.log`, `exe-replay-tampered.log`, `exe-built-at.txt` (= `ebe1dd6`) |
| 5 | **The exe boots straight into quest 1.** The export preset is `windows-slice` (custom feature `slice`, embedded pck). `project.godot` has one added line: `run/main_scene.slice`. The title card offers Start / Quit / Continue, Esc/P/Start pauses, there is a paid card, and a failed card offers Retry. | `project/export_presets.cfg`; frames `M/clip32v2/title.png`, `M/clip32v2/paid.png` |
| 6 | **The real HUD lives in `features/hud`.** `HudView` draws a `HudState`, which boot's `HudFeed` fills from the real game state. Art loads by id from `data/tables/hud_art.json`; an unknown id draws an ink placeholder and does not crash. The HUD shows cash, the d4 ammo ticket and digits, and wanted pips in cop blue. Soul cards are hidden (verdict 3). | `project/features/hud/`; `test_hud_art` (6 tests); `M/hud32/`, `M/ammo32/still_7400_32.png` |
| 7 | **Quest art loads by id**, from `data/tables/collect_call_art.json` (`ArtIds`, `QuestArt`), so another lane's art landing later is a table edit. | `project/core/data/art_ids.gd`, table + schema |
| 8 | **Beat-cued whispers, checkpoints and respawn.** Whispers are triggered by beats, not timers. Each beat b2..b6 writes a `gtai.checkpoint/1` save (seed + input tape + state hash; a resume must hit the hash). Respawn on death returns Rivet to the Toner Room inside the sim. | scenario log (item 2); `project/features/save/` (frozen since 11:45, see Merge notes) |
| 9 | **Teaching prompts.** `ObjectiveHint` shows a prompt per beat with the bound key (or the pad button, if a pad was used last), plus a goal ring or an edge arrow. The first minute teaches pause. | `M/hints32/`, `M/art32/still_600_32.png` |
| 10 | **Pause and settings**: master volume, reduced motion (also `--reduced-motion`), and keyboard rebinding saved in `user://settings.json` (`gtai.player-settings/1`). | `M/pause32/pause_32.png` |
| 11 | **Owner verdict 1 (Rivet too big)** is applied in the slice. Rivet is re-captured from d5-cast's base form (size_k 1.2) and drawn at true scale: 2.73 x 2.9 m, against the night rig's 3.1 x 3.9 m. | before/after `M/rbase-before48/` vs `M/rbase-after48/` (also 32), `M/rivet-base-ab.png`, `M/rivet-base/compare_old_new_cop.png` |
| 12 | **Verdict 6 (cops in blue)** is applied in quest 1. The cop sprite is recoloured to cop_blue `3A4766` and the pips use cop_blue_hi `4F86E0`. Both values are hard-coded until `palette.json` lands. | `M/before32/` vs `M/after32/` (also 48) |
| 13 | **The first frame after Start or Continue shows the street.** It used to be a cream void with floating props. | `M/start_before/` vs `M/start_after/continue_f1.png`; `M/cont_before/` vs `M/cont_after/` |
| 14 | **The light pool on Rivet in the first ticks is fixed** (`ebe1dd6`). The cause was CityView's `ViewPrewarm` leaking the explosion light through the FX glow twin. The fix is checked in frames on both Continue and Start. | `M/lightfix_before/` vs `M/lightfix/continue_f4.png`, `M/lightfix-ab-32.png`; Start: `evidence/slice-play/clip32v5_f1-6_crop.png` |
| 15 | **A 32 s clip of an input-driven run** at 32 px/m (960 frames, from a scripted pad, not a human). I looked at 15 sampled frames: all straight down, 0 rejected. | `M/quest1-city-input-run-32ppm-v5.mp4`, `M/clip32v5_sheet.png`, `evidence/slice-play/clip-v5.log` |
| 16 | **Frame cost of the slice** at Dock 9 on the city, 32 px/m, vsync off, 1422x800 window. **CONTENDED.** p50 1.81 ms, p95 5.65 ms, p99 11.95 ms, max 20.4 ms (one frame over 16.7 ms). Measured at `fe40b14`, before the later art changes. | `evidence/slice-play/slice-frames-32ppm.json` |
| 17 | **Gates at code `ebe1dd6`** (code is unchanged since then): lint 13/13 (369 files), unit 359/0, scenarios 10/10. The last full `tools/evidence/run.mjs --no-bench` pass (lint, unit, scenarios, parity exact + planted mutation caught, selftest look goldens 11/11) was at `162fbfa`. The only code change since then is the prewarm fix. | `evidence/slice-play/unit-it53.log`, `scenarios-it53.log`, `iter47-162fbfa/` |

`M/frames.json` has 15 entries. I checked every `file` and `before` in it, and all of them exist.
`M/ladder.png` is up to date.

## What does not work, or is not proven

- **No human has played the exe end to end.** The scripted pad passes, but a human may trip on things it handles easily: reaching the four allies at the street meet, aiming into Mertz's vent window, or getting around parked cars.
- **Places are not rooms.** The Toner Room and Dock 9 are stretches of street with a stencilled name, not built spaces.
- **The car key is still a stub.** `StagePilot` reads bit 0 `car` but does not call `VehicleService` yet. The two branches have not been merged.
- **Humans are drawn too large.** The guard and cast sprites still use 1.7x / 1.5x draw factors from the placeholder era, so next to the true-scale Rivet the humans are larger than true scale.
- **One frame of warm-up particles** appears at Rivet on frame 1 after Start or Continue. It is cosmetic, it existed before today, and I did not fix it.
- **The free-roam World does not use the new controller.** Its on-foot Rivet does not go through `TopDownMover` (vehicles' REQUEST 5), so it can still walk onto roofs.
- **`scenario_city_chase` is flaky under load.** It is the d4/city lane's test. Under the contended machine it failed its 2 ms wall-clock nav budget twice (2442 µs, 2002 µs). It passes when run alone and passed in every run since 16:38.
- **The bench is out of date.** It was not re-run after the Rivet re-capture or the HUD move, so the current cost is unmeasured.
- **Gamepad input is only proven with simulated events.** No physical pad was tested on this machine.

## What blocked me, and for how long

- **The shared `bench.lock`.** I rendered nothing while another lane held it:
  - 12:25 – 12:37 (`collisions`, then `d5-combat`);
  - 15:42 – 15:58;
  - 16:07 onwards;
  - 16:44 – 17:09 (`d5-combat`, then `d5-city`).

  The longest stretch was about 25 min, and it kept the light-pool fix unproven past the 17:00 freeze. The fix was frame-verified and committed at 17:10.
- **Two lock slips, both my error:**
  - a 5 s render at 15:45;
  - clip v4 rendering for 7 min (15:59 – 16:07) while another lane held the lock.

  Both are in JOURNAL. Since then every render checks the lock before it starts.
- **Silent hangs of new `-s` tools** (11:20 – 11:33, about 10 min). A SceneTree script that names game classes compiles before the `Log` autoload exists. The fix is to `load()` the tool's body in `_initialize`.
- **A gap from 13:12 to 15:40 with no commits or journal entries.** The lane did not run in that window, and at 15:41 I found an uncommitted fix from about 13:10. Because of this, the iteration numbers jump from 3 to 47.

## Merge notes for the Director

1. **Merge `d-cast` with or before `d-slice`.** Quest 1's Rivet sprite was captured from d-cast's `rivet_plan.gd` FORM_BASE.
2. **`project/features/city/view/view_prewarm.gd` (d5-city's file) carries the light-leak fix `ebe1dd6`.** The file was byte-identical on `d-city` when I made the change, so the merge should be clean.
3. **Autosave (`d-save`):**
   - The Continue, Retry, checkpoint-write, resume and paid-erase call sites are listed in JOURNAL iteration 3 ("MERGE NOTE -> autosave"); they are in `boot/quest1_game.gd` and `boot/collect_call/quest1_session.gd`.
   - Respawn does not touch the save.
4. **Shared files I changed:**
   - `project.godot`: one line, `run/main_scene.slice`;
   - `project/export_presets.cfg`: the `windows-slice` preset;
   - `docs/decisions.md`: decision lines.
5. **World hookup for LiveInput:** the snippet is in JOURNAL iteration 1 at 11:08. I did not apply it, to avoid conflicting with vehicles' `world.gd`.

## Next steps (in order)

1. The owner runs `build/export/windows/RTAI.exe` by hand at 18:00. Fix whatever a human trips on.
2. Merge `d-cast` with or before `d-slice`; point Continue and Retry at `core/save` once `d-save` lands.
3. Wire the car press to `VehicleService.try_enter/exit`, and move the free-roam World's on-foot Rivet onto `TopDownMover` plus cells. That re-blesses the 60 s replay golden, deliberately.
4. Build the Toner Room and Dock 9 as rooms: a plaza or an authored lot (REQUEST to d5-city).
5. Re-capture the guard and cast sprites at 1x from d5-cast's final human rigs.
6. Remove the one-frame warm-up particle burst on frame 1 after Start or Continue.
7. Re-bench the slice under `bench.lock`, on a quiet machine if possible.
