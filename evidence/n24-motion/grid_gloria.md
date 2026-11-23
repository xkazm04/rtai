# Gloria at tilt 70

Rivet carries the broad, two-handed Gloria through four walking poses and eight running poses in each of eight directions. The equipped drawing supplies the grip and palette. The shipped one-hand pistol grids supply the step order. The native grid lookup already checks the current pitch before using the bare-claw fallback.

## Drawings and stance travel

Distances are horizontal cell pixels at 110 px standing height. Walk compares the leading sole in column 1 to the trailing sole in column 3. The two profile travels give a mean half-cycle of 43.33 px and a full cycle of 86.7 px. Run compares contacts 1 and 5 with push-offs 3 and 7 and averages their absolute travel. The family column measures the shipped p70 pistol with the same method. The run factor uses the bare run as its reference. Front, rear and rear-right have little sideways travel, so their small lateral shifts cannot determine cadence.

| Facing | Walk / family | Run / family / bare | Run factor | Walk / run grade and fixes |
|---|---:|---:|---:|---|
| Front | 18.0 / 18.7 | 1.7 / 2.8 / 3.3 | 1.00 | A / A. Both hands stay on the gun across the chest. |
| Front right | 25.0 / 26.3 | 47.8 / 47.5 / 47.0 | 1.00 | A / A. Barrel and both boots stay clear. |
| Right profile | 49.3 / 44.0 | 66.0 / 67.2 / 67.5 | 0.98 | A / A. Both first drafts retained an open claw. Both redraws use the equipped support arm. |
| Back right | 31.0 / 32.7 | 2.7 / 2.2 / 3.3 | 1.00 | A / A. Redrew the walk to remove the third arm. |
| Back | 18.3 / 18.3 | 3.3 / 3.2 / 3.7 | 1.00 | A / A. A direct retry supplied the walk. The run redraw tucks the free claw out of sight. |
| Front left | 27.7 / 15.3 | 43.5 / 45.7 / 44.7 | 0.97 | A / B. Removed a claw over the walking knee, then replaced column 3 alone to alternate the leading foot. Run contacts favour the same side, as in the pistol family. |
| Left profile | 37.3 / 30.0 | 58.0 / 63.5 / 63.0 | 0.92 | A / A. Redrew both carries to brace the weapon. The shorter run uses its measured cadence. |
| Back left | 11.0 / 13.3 | 46.5 / 47.0 / 46.5 | 1.00 | A / A. The near forearm crosses the stock. The forward boot sits higher than the other toe in column 1, so this measurement follows the leading sole on the left of the helmet to push-off on its right. |

Run and walk use the same 1.5× packing scale as their shipped equivalents. The right-profile walk travels 26.0 and 32.5 packed texels from contact to passing on alternate steps. Its cadence uses these separately. The 86.7 px whole-cycle value remains available to the other directions.

## In-game evidence

The owner film follows the same live wheel selection and input on King's Boulevard, through eight walking directions at 6.75 m/s and eight sprinting directions at 9.3 m/s. The two views retain native 32 px/m. Each half crops the arena camera around Rivet. [Side-by-side arena film](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_gloria_32.mp4)

The stills pair the same gameplay tick at both zooms. The movement rig captures also show the slower four-column walk that plays below the 2.5 m/s run threshold. [32 px/m arena stills](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_gloria_32.png) · [64 px/m arena stills](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_gloria_64.png)

At a 2.4 m/s walk, the right-profile sole's mean / maximum net drift was 1.13 / 2.05 cm at 32 px/m and 1.05 / 1.56 cm at 64 px/m. At a 3.2 m/s run it was 4.58 / 5.41 cm and 5.78 / 6.67 cm respectively. During a held run drawing the body still travels about 65 cm before the next drawing corrects the visible sole position. One arena prop obscures the feet at tick 670. The independent ruler captures keep both feet visible. [32 px/m ruler measurements](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_gloria_arena/final_rows_p70/turn_000/gloria_32/foot_slide.json) · [64 px/m ruler measurements](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_gloria_arena/final_rows_p70/turn_000/gloria_64/foot_slide.json)

The p70 rounds produced 26 images in 29 minutes 35 seconds of elapsed wall time, including ten corrective or alternate rows. One additional runner attempt timed out without an image. [All eight facings at 32 px/m](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_gloria_arena/final_rows_p70/walk_run_rows_32.png) · [All eight facings at 64 px/m](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_gloria_arena/final_rows_p70/walk_run_rows_64.png)

The selected source rows and corrected cell are recorded in the [art round](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-1948-n24motion/accepted_picks.json). For another two-handed weapon, specify the upper-body replacement from the first prompt and use a separate leg-only example for a repeated contact. The pistol family's free pincer survived several weapon-only edits.

## Verification

The changed suite passed 3,793 tests with zero failures and two skips. The quick gate passed formatting, lint, size and banned-API checks on all three changed scripts. Its standalone Godot parse reported 475 diagnostics. The same three files restored from HEAD produced the identical 475 diagnostics in the same order. The raw standalone run reports missing project autoloads including Log and LaunchArgs, followed by dependency cascades and an allocator shutdown error. [Changed-suite output](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_gloria_arena/final_rows_p70/changed.txt) ? [Quick gate on HEAD](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_gloria_arena/final_rows_p70/quick_head_baseline.txt)
