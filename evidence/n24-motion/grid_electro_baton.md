# Electro baton at tilt 70

Rivet carries the ribbed copper baton and its ivory electric crown on the equipped side in both gaits. The katana grid supplies the footfall order. The profile redraws put the baton behind the right-facing hip. The left-facing redraws lift the tip clear of the boots. Three generated rows had white margins that keyed out the pale head. Cropping to the green sheet before keying kept the head opaque. Matching the donor height scaled the back-right walk by 0.868 and the front-left run by 0.611. The own-grid lookup selects these two PNGs at p70. P55 uses the bare-claw legs and held-part fallback. Drawing and validating another pitch exceeds the 15-minute allowance.

## Stride and row review

Travel is measured in 110 px standing-height space. Walk follows the leading contact sole over two columns. Run averages contact-to-push travel for the two feet. Each run factor compares this row with bare run8, capped at 1.00. Depth-facing rows have too little horizontal travel for that comparison.

| Facing | Walk / family (px) | Run / family / bare (px) | Run factor | Walk / run grade and observation |
|---|---:|---:|---:|---|
| Front | 16.7 / 16.7 | 3.3 / 3.3 / 3.3 | 1.00 | A / A. The near hand keeps the head clear of the boot in both contacts. |
| Front right | 4.3 / 7.3 | 42.5 / 45.7 / 47.0 | 0.90 | B / B. The baton reads at both scales. The near and far lead boots look similar in the front diagonal. |
| Right profile | 35.7 / 34.7 | 64.8 / 67.3 / 67.5 | 0.96 | A / B. The head now trails the right-facing figure. The run shows more of the second fist and has the largest measured net contact drift. |
| Back right | 7.0 / 7.7 | 2.2 / 3.7 / 3.3 | 1.00 | A / A. The forearm crosses the near hip and the diagonally raised crown stays on the equipped side. |
| Back | 9.3 / 10.0 | 3.2 / 3.3 / 3.7 | 1.00 | A / A. The head peeks past the far right flank while the other hand hangs at the left. |
| Front left | 13.3 / 15.3 | 38.8 / 45.7 / 44.7 | 0.87 | A / B. The crown clears the soles. The run keeps the blade family's similar-looking contact silhouettes. |
| Left profile | 31.7 / 30.3 | 62.0 / 64.0 / 63.0 | 0.98 | A / A. The tip and the trailing sole remain separate as each boot changes from contact to passing. |
| Back left | 7.7 / 7.7 | 45.3 / 47.7 / 46.5 | 0.97 | A / A. The near forearm crosses the torso and the crown clears the ground through the flight frame. |

The two profile walks give a 67.3 px cycle. Alternate contact-to-passing distances on the right profile are 16.5 and 31.5 packed texels.

The ruler uses 2.4 and 3.2 m/s to isolate the walk and run grids. The arena comparison uses 6.75 and 9.3 m/s. [Arena film](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_electro_baton_32.mp4)

At 32 px/m the profile sole drifted 2.95 / 4.10 cm (mean / maximum) walking and 6.79 / 12.62 cm running. [All walk and run rows](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_electro_baton_arena/rows/walk_run_rows_32.png) and [same-tick arena comparison](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_electro_baton_32.png).

At 64 px/m the profile sole drifted 2.91 / 4.67 cm (mean / maximum) walking and 6.91 / 12.56 cm running. [All walk and run rows](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_electro_baton_arena/rows/walk_run_rows_64.png) and [same-tick arena comparison](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_electro_baton_64.png).

ImageGen made 25 row sheets in 7 min 58 s. On the next luminous weapon I would trim the sheet margins before the first cut and explicitly name the side of the profile carry. [Row prompts](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2206-n24motion/jobs.json) and [selected cells](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2206-n24motion/final_picks.json).

Nine corrective sheets address the electrical crown and profile carry. [Correction prompts](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2206-n24motion/fix1/jobs.json). The changed runtime lines have zero eligible mutation operators.

## Verification

unit-tests: 3795 passed, 0 failed, 2 skipped (GUT, headless). The every-weapon test covers both pitches. The quick lint and formatting checks passed.
