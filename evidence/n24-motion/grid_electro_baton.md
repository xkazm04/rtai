# Electro baton at tilt 70

Rivet carries the ribbed copper baton and its ivory electric crown on the equipped side in both gaits. The katana grid supplies the footfall order. The profile redraws put the baton behind the right-facing hip. The left-facing redraws lift the tip clear of the boots. Three generated rows had white margins that keyed out the pale head. Cropping to the green sheet before keying kept the head opaque. Matching the donor height scaled the back-right walk by 0.868 and the front-left run by 0.611. The own-grid lookup selects these two PNGs at p70. P55 uses the bare-claw legs and held-part fallback. Drawing and validating another pitch exceeds the 15-minute allowance.

## Stride and row review

Travel is measured in 110 px standing-height space. Walk follows the leading contact sole over two columns. Run averages contact-to-push travel for the two feet. Each run factor compares this row with bare run8, capped at 1.00. Depth-facing rows have too little horizontal travel for that comparison.

| Facing | Walk / family (px) | Run / family / bare (px) | Run factor | Walk / run grade and observation |
|---|---:|---:|---:|---|
| Front | 16.7 / 16.7 | 3.2 / 3.3 / 3.3 | 1.00 | A / A. The near hand keeps the head clear of the boot in both contacts. |
| Front right | 4.3 / 7.3 | 42.5 / 45.7 / 47.0 | 0.90 | B / B. The baton reads at both scales. The near and far lead boots look similar in the front diagonal. |
| Right profile | 37.0 / 34.7 | 64.8 / 67.3 / 67.5 | 0.96 | A / B. The head now trails the right-facing figure. The run shows more of the second fist and has the largest measured net contact drift. |
| Back right | 7.7 / 7.7 | 1.2 / 3.7 / 3.3 | 1.00 | A / A. The forearm crosses the near hip and the diagonally raised crown stays on the equipped side. |
| Back | 9.3 / 10.0 | 3.3 / 3.3 / 3.7 | 1.00 | A / A. The head peeks past the far right flank while the other hand hangs at the left. |
| Front left | 13.3 / 15.3 | 38.8 / 45.7 / 44.7 | 0.87 | A / B. The crown clears the soles. The run keeps the blade family's similar-looking contact silhouettes. |
| Left profile | 31.7 / 30.3 | 62.0 / 64.0 / 63.0 | 0.98 | A / A. The tip and the trailing sole remain separate as each boot changes from contact to passing. |
| Back left | 7.7 / 7.7 | 45.3 / 47.7 / 46.5 | 0.97 | A / A. The near forearm crosses the torso and the crown clears the ground through the flight frame. |

The two profile walks give a 68.7 px cycle. Alternate contact-to-passing distances on the right profile are 15.0 and 28.5 packed texels.

The ruler uses 2.4 and 3.2 m/s to isolate the walk and run grids. The arena comparison uses 6.75 and 9.3 m/s. The Walk labels describe the input speed. At both speeds the live rig selects run8. The ruler captures the four-column walk at 2.4 m/s. [Arena film](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_electro_baton_32.mp4)

At 32 px/m the profile sole drifted 4.02 / 5.89 cm (mean / maximum) walking and 6.79 / 12.62 cm running. [All walk and run rows](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_electro_baton_arena/tone_review/rows_owner/walk_run_rows_32.png) and [same-tick arena comparison](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_electro_baton_32.png).

At 64 px/m the profile sole drifted 3.95 / 6.57 cm (mean / maximum) walking and 6.91 / 12.56 cm running. [All walk and run rows](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_electro_baton_arena/tone_review/rows_owner/walk_run_rows_64.png) and [same-tick arena comparison](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_electro_baton_64.png).

ImageGen made 25 row sheets in 7 min 58 s. On the next luminous weapon I would trim the sheet margins before the first cut and explicitly name the side of the profile carry. [Row prompts](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2206-n24motion/jobs.json) and [selected cells](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2206-n24motion/final_picks.json).

Nine corrective sheets address the electrical crown and profile carry. [Correction prompts](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2206-n24motion/fix1/jobs.json). The changed runtime lines have zero eligible mutation operators.

## Turn tone and back-right sprint

Five walk rows and the front and back sprints were redrawn from their accepted stride, equipped facing and the left-profile rust reference. After the equipped-strip tone pass, a smooth midtone correction brought those seven rows to the accepted walk rows’ mean of RGB (118.1, 76.9, 53.5). Dark ink and ivory highlights keep their contrast. The table includes pixels with alpha above 200. [All eight rows on grey, with the full back-right sprint](grid_electro_baton_tone.png)

| Row (zero-based) | Walk RGB before | Walk RGB after | Run RGB before | Run RGB after |
|---|---|---|---|---|
| 0 · Front | 114.1 / 86.2 / 63.2 | 118.2 / 76.9 / 53.5 | 108.6 / 82.7 / 61.3 | 118.2 / 76.9 / 53.4 |
| 1 · Front right | 113.0 / 86.0 / 64.0 | 118.1 / 76.9 / 53.5 | 115.9 / 82.9 / 59.4 | 115.9 / 82.9 / 59.4 |
| 2 · Right profile | 124.1 / 89.5 / 63.9 | 118.2 / 76.9 / 53.5 | 121.6 / 83.8 / 58.3 | 121.6 / 83.8 / 58.3 |
| 3 · Back right | 115.1 / 83.9 / 60.0 | 118.1 / 76.9 / 53.5 | 118.1 / 82.1 / 58.7 | 118.1 / 82.1 / 58.7 |
| 4 · Back | 120.5 / 92.7 / 69.1 | 118.2 / 76.9 / 53.4 | 116.5 / 89.2 / 61.3 | 118.2 / 76.8 / 53.4 |
| 5 · Front left | 112.9 / 76.6 / 52.1 | 112.9 / 76.6 / 52.1 | 121.7 / 84.8 / 60.7 | 121.7 / 84.8 / 60.7 |
| 6 · Left profile | 118.8 / 74.9 / 53.0 | 118.8 / 74.9 / 53.0 | 118.1 / 80.7 / 58.7 | 118.1 / 80.7 / 58.7 |
| 7 · Back left | 122.7 / 79.3 / 55.2 | 122.7 / 79.3 / 55.2 | 126.6 / 86.5 / 65.0 | 126.6 / 86.5 / 65.0 |

The back-right sprint redraw extends the tucked boots. All eight source cells use one scale from the tallest column (178/182), followed by the fixed right-side pack scale. Packed helmet widths across the upper dome measure 77.5–79.5 px. The vertical excursion falls from 31 to 19 px. The two signed stance travels are −1.00 and +1.33 px in 110 px figure space. This depth row keeps the default run factor of 1.00.

ImageGen produced seven tone sheets and one back-right sprint sheet in three batches, 3 min 2 s combined from prompt manifests to final outputs. A side-by-side run-row preview revealed the deep tuck that a colour check would have missed. [Tone references and prompts](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2251-n24motion/jobs.json) and [sprint correction](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2251-n24motion/pulse/jobs.json) and [front run at arena speed](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2251-n24motion/arena_front/jobs.json).

## Verification

unit-tests: 3795 passed, 0 failed, 2 skipped (GUT, headless). The every-weapon test covers both pitches. The quick lint and formatting checks passed.
