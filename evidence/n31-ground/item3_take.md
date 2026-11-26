# n31 item 3 part C, the prologue's print in play (stretch ON): builder n31-16

## A. The actors' print, before | after `b94e64c0e` (`PartMaterials.set_world_px(print_stage.world_px)`)

Tool: `project/dev/ground_n31/drift_probe.gd` (n31-07) with one new logged field, `part_world_px` (the static
`PartMaterials.world_px`, the uniform every part material draws its tooth and shadow dots from);
`tools/ground/drift/run_probe.mjs` gained `--tree=<dir>` to run in a snapshot. Before = snapshot of
`b94e64c0e~1` (`54995dd05`) with this probe copied in; after = the live tree at HEAD. Both `--bot --clip=play`
(the project stretch on, s = 1.35, 32 px/m, tilt 70), pilot bot, 2700 ticks. Numbers: `item3_actors_lock.json`.

| | print stage `world_px` over the sprint pan (ticks 2370..2700) | part uniform `world_px` over the same | gap stage vs part, all 105 captured frames, max / mean |
|---|---|---|---|
| before (`54995dd05`) | 1432.0, 487.0 px | **0.0, 0.0** (never set: stays at its default Vector2.ZERO) | 1616.7 / 496.4 px |
| after (HEAD) | 1432.0, 487.0 px | 1432.0, 487.0 px | **0.0 / 0.0** px |

Reading: before, Rivet's and every actor part's tooth and shadow dots sat on the screen (their uniform never
moved) while the floor and its print moved 1432 px; after, they take the same value as the floor print every
frame. The floor print still holds (after take, same run: print vs camera over the pan 0.00007 px, per 30
ticks max 0.0017 px). This is a logged-uniform proof, not an image phase measurement on Rivet's own dots:
the existing phase tool masks Rivet out (his box is the one place the pan hides the actors), and I did not
build a Rivet-only correlation in the time.

PrintStage hosts, and whether each feeds `PartMaterials.set_world_px`:
- `CollectCallView` (`collect_call_view.gd:166`): yes since `b94e64c0e`; the prologue (`PrologueView`) and the
  gauntlet (`GauntletView`) both extend it. With a `city_view` it returns early to the CityView path:
- `CityCharacters` (`city_characters.gd:68`, every frame, `_view.world_px`): yes (quest 1, arena city, gauntlet city).
- dev scenes that call `view.print_stage.place(...)` (`project/dev/cast/*`, `ghost-forms`, `prologue_yard/yard_camera.gd`,
  `selftest/print_stage_demo.gd`): not audited one by one in the time; they are dev-only and not owned-path shipping hosts,
  none edited. No shipping host is missing the line.

## B. Play take, stretch ON (prologue from the pilot's stand, 1920x1080 window, s = 1.35)

Entry: not from Start: the title/Start menu path was not driven. `project/dev/ground_n31/play_film.gd` builds the prologue
scene (`boot/prologue/prologue.tscn`) on the pilot `--bot`, tilt 70, ONE sim tick per frame, with the project
stretch left on (`canvas_items`, 1280x800 base in a 1920x1080 window, logged stretch 1.3502 x 1.3500); the opening
lines (the pilot stands until tick ~1140) run without a frame. Tool: `tools/ground/prologue_play_take.mjs`
(snapshot of the rev, probe copied in, snapshot-only `override.cfg` = window override 1920x1080 so the movie is
1920x1080 and the stretch stays on; a `viewport_*` override would make s = 1.0, the trap of `play_take.mjs`'s own
override). Side by side with `play_take.mjs --side`. Delivered size: ffprobe 1920x1080 for every take (no scaling
needed; the secondary screen's 2592x1458 target did not appear in the movie).

- `prologue_side_32.mp4` (masters `item3/`): main `ba8e470b0` | HEAD (`b94e64c0e` tree), 32 px/m, ticks 2150-3600, 1452 frames,
  60 fps, 24.2 s (ffprobe). Rivet: stands (2150-2200), walks 0.9 m/s (2210-2260), runs 4.5 -> 6.7 m/s (2300-2450), sprints
  6.7 m/s to the end. The pilot never stops again in this window: "stopping" is the first second only, not a
  braking stop.
- Print vs floor over the pan, from the per-frame log (render px, `ticks.jsonl` of each take):

| take | ticks | floor moved (px) | print moved (px) | print slid against the floor |
|---|---|---|---|---|
| main 32 px/m | 2300-2700 | -1405.7, -491.4 | -1041.0, -364.0 | **386.3 px** (per tick max 2.06, mean 1.23) |
| HEAD 32 px/m | 2300-2700 | -1405.0, -491.0 | -1405.0, -491.0 | **0.000 px** |
| main 32 px/m | 2300-3600 | 957.2, -144.6 | 709.0, -107.0 | 251.0 px net (the pan reverses) |
| HEAD 32 px/m | 2300-3600 | 958.0, -144.0 | 958.0, -144.0 | 0.000 px |
| main 64 px/m | 2300-2700 | -2811.4, -982.7 | -2082.0, -728.0 | **772.6 px** |
| HEAD 64 px/m | 2300-2700 | -2812.0, -983.0 | -2812.0, -983.0 | 0.000 px |

- The sides are not the same game: cops stand a little differently (other commits sit between `ba8e470b0` and HEAD),
  the HEAD 64 px/m take is a snapshot of `830858c2d` (n31-15's commit, cops only) and the 32 px/m one of `b94e64c0e`.
- Still pair (64 px/m): `item3/prologue_still64_main_ba8e470b0.png` and `prologue_still64_head.png`, made by
  `tools/ground/world_still.py` from the two movies: ticks 2450 and 2480, one world-anchored box (x2 nearest crop of a
  520 x 330 box at 700,700, moved by the logged canvas shift (-272, -98) px), Rivet is 150+ px above the box in both frames. The cracks hold
  still in both; on main the grime flecks and halftone differ between the halves, on HEAD they sit on the same floor spots. The movies are h264 so some
  noise remains; the numbers above, not the still, are the measurement.

## C. Quest 1 city (CityView), stretch on

`project/dev/ground_n31/quest1_drift.gd`: `boot/quest1.tscn`, Start pressed, the scripted pad
(`CollectCallInputDriver`) walks Rivet, one tick per frame, 899 ticks, stretch 1.35; logs the CityView `world_px`
and canvas origin per drawn frame (`item3_quest1_before.json`, `_after.json`). main `ba8e470b0` | HEAD:

| take | ticks | floor moved (px) | print moved (px) | print slid against the floor |
|---|---|---|---|---|
| main | 1-899 | -798.0, 50.7 | -591.0, 38.0 | **207.0 px** (per tick max 1.89) |
| HEAD | 1-899 | -797.0, 52.0 | -797.0, 52.0 | **0.0003 px** (per tick max 0.0014) |
| main | 600-899 | -668.4, 26.6 | -495.0, 20.0 | 173.4 px |
| HEAD | 600-899 | -668.0, 28.0 | -668.0, 28.0 | 0.0003 px |

(The two takes' Rivet paths differ by a few px: the sim differs; the quantity is drift against the floor of the same take.)
The first before run had stretch 1.0 (an `override.cfg` of an earlier tool in the cached snapshot): it showed 0.4 px and was
thrown away; the numbers above are from the rerun, stretch 1.3502 in the log.

## For the player

On a 1080p window the prologue's grime, halftone and Rivet's own tooth no longer swim over the floor when you run: they hold
on the ground like paint, where on main they crept against it by about a quarter of your running speed.
