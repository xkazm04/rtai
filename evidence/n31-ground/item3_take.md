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
