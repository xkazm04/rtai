# Chainsaw at tilt 70

Rivet carries the saw in both hands. Its toothed bar extends ahead of his body through walking and sprinting. The equipped base and left strips supply the grip and layers. The shipped Gatling supplies the heavy-family legs. The own-grid lookup selects these two files at p70. P55 keeps the bare-claw and held-part fallback because a second pitch needs more than 15 minutes to draw and validate.

## Stride measurements

Distances below are horizontal stance travel in 110 px standing-height space. Walk measures the leading sole from contact in column 1 to the trailing position in column 3. Run averages contact-to-push travel for both feet. The run factor is capped at 1.00. Front, back and back-right are mostly depth motion and keep the unshortened run cadence.

| Facing | Walk / Gatling (px) | Run / Gatling / bare (px) | Run factor | In-game walk / run grade |
|---|---:|---:|---:|---|
| Front | 23.7 / 23.3 | 2.2 / 0.3 / 3.3 | 1.00 | A / A. The hands stay on the housing, and the bar clears the forward boot. |
| Front right | 10.0 / 11.7 | 38.7 / 44.7 / 47.0 | 0.82 | A / B. The run keeps the family's similar contact leads. Removing its backpack from the scale measurement brings the helmet back to the equipped size. |
| Right profile | 31.7 / 33.3 | 60.2 / 66.5 / 67.5 | 0.89 | A / A. Both outlines of the toothed bar remain visible in profile. |
| Back right | 6.3 / 7.3 | 2.2 / 2.0 / 3.3 | 1.00 | A / A. The near arm frames the handle and the bar remains forward. |
| Back | 13.3 / 14.7 | 3.2 / 4.0 / 3.7 | 1.00 | A / A. The back plate hides the body of the saw. The end of the bar remains visible on the right. |
| Front left | 13.0 / 11.7 | 39.7 / 43.0 / 44.7 | 0.89 | A / B. The two lead runs look similar in the heavy source. The corrected scale keeps the grip at the waist. |
| Left profile | 32.7 / 36.0 | 52.8 / 58.3 / 63.0 | 0.84 | A / A. The bar and both soles remain separate, with the top handle clearly visible. |
| Back left | 9.7 / 7.3 | 41.0 / 45.5 / 46.5 | 0.88 | A / A. The arm stays in front of the housing. The bar extends past the body as in the left equipped strip. |

Right and left walk half-cycles measure 31.67 and 32.67 cell px. The full walk cycle is 64.3 px. Contact-to-passing travel measures 18.5 and 28.0 packed texels on alternate right-profile boots.

The heavy donor's backpack enters the helmet-width sampling band. Five rows initially differed from the donor's median height by over 5%. The largest was the front-right run, 234 px versus 179 px. Matching the height of the corresponding packed donor row brought its scale to 0.765 of the first candidate. Both back and front-left walks and the front and front-left runs also received scale adjustments. [Row scale measurements](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2135-n24motion/scale_corrections.json)

## In-game review

At 32 px/m the profile sole's mean / maximum net drift was 1.44 / 3.15 cm walking and 3.89 / 8.98 cm running. At 64 px/m it was 1.53 / 2.46 cm and 4.05 / 9.51 cm respectively. The mean in-frame excursion on a held run drawing was about 60 cm. [32 px/m row inspection](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_chainsaw_arena/rows/walk_run_rows_32.png) ? [64 px/m row inspection](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_chainsaw_arena/rows/walk_run_rows_64.png)

The arena loop selects the saw on the wheel and records the same eight-direction path at 6.75 and 9.3 m/s. [32 px/m stills](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_chainsaw_32.png) ? [64 px/m stills](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_chainsaw_64.png) ? [60 fps arena comparison](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_chainsaw_32.mp4)

ImageGen produced all 16 rows in 3 min 1 s from the round manifest to the last result. On another heavy-family grid, I would compare packed row heights before the first import to catch the backpack bias earlier. [Prompts](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2135-n24motion/jobs.json) ? [Selected cells](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2135-n24motion/final_picks.json)

## Verification

The every-weapon and chainsaw stance checks passed. The first changed-suite run had 3,794 passes, one failure and two skips. Its only failure was the missing-grid fixture in `test_rivet_walk.gd` at line 82. It still expects the p70 chainsaw walk path to be empty. The same check applies at p55, which uses the fallback. The changed scripts passed lint and formatting. [Changed-suite output](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_chainsaw_arena/changed.txt)

After moving the missing-grid fixture to p55, unit-tests: 3795 passed, 0 failed, 2 skipped (GUT, headless). The changed-file lint and formatting checks passed. No mutation operators matched the changed runtime table entries.
