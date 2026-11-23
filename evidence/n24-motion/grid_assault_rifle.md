# Assault rifle at tilt 70

The two-hand plasma rifle supplies the leg poses. The equipped assault rifle supplies the wooden stock, rectangular magazine and perforated barrel shroud. The arena wheel uses the arsenal id `assault-rifle` and the packed art uses `assault_rifle`. Four rows needed scale corrections against the donor, the largest on the front-left run (195.5 to 173 packed px). The own-grid lookup selects these two PNGs at p70. P55 uses the bare-claw legs and held-part fallback. Drawing and validating another pitch exceeds the 15-minute allowance.

## Stride and row review

Travel is measured in 110 px standing-height space. Walk follows the leading contact sole over two columns. Run averages contact-to-push travel for the two feet. Each run factor compares this row with bare run8, capped at 1.00. Depth-facing rows have too little horizontal travel for that comparison.

| Facing | Walk / family (px) | Run / family / bare (px) | Run factor | Walk / run grade and observation |
|---|---:|---:|---:|---|
| Front | 17.3 / 18.0 | 1.7 / 2.7 / 3.3 | 1.00 | A / A. The stock stays at the near elbow. The magazine remains visible between both hands. |
| Front right | 11.7 / 9.3 | 44.5 / 45.8 / 47.0 | 0.95 | A / B. The muzzle rises slightly as on the equipped card. The near and far run contacts have similar silhouettes. |
| Right profile | 42.7 / 45.7 | 58.5 / 65.8 / 67.5 | 0.87 | A / A. The barrel and stock stay aligned through both contacts and the flight frames. |
| Back right | 30.7 / 31.7 | 2.2 / 2.2 / 3.3 | 1.00 | A / A. The elbow covers the stock while the perforated shroud projects past the front hand. |
| Back | 21.0 / 20.3 | 3.5 / 4.3 / 3.7 | 1.00 | A / A. The back hides the rifle body. The muzzle remains visible on the right. |
| Front left | 14.7 / 14.0 | 36.8 / 43.5 / 44.7 | 0.82 | A / B. The near arm crosses the stock and the muzzle points left. The two running leads look similar in the donor. |
| Left profile | 35.3 / 31.0 | 53.5 / 62.3 / 63.0 | 0.85 | A / A. The level barrel remains above the knees and both boots show clear contact and passing poses. |
| Back left | 10.3 / 14.0 | 44.8 / 46.8 / 46.5 | 0.96 | A / A. The torso occludes the grip and the left-pointing muzzle stays visible through the stride. |

The two profile walks give a 78.0 px cycle. Alternate contact-to-passing distances on the right profile are 20.5 and 29.5 packed texels.

The ruler uses 2.4 and 3.2 m/s to isolate the walk and run grids. The arena comparison uses 6.75 and 9.3 m/s. [Game-speed film](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_assault_rifle_32.mp4)

At 32 px/m the profile sole drifted 1.81 / 3.76 cm (mean / maximum) walking and 4.98 / 6.62 cm running. [All walk and run rows](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_assault_rifle_arena/rows/walk_run_rows_32.png) and [same-tick arena comparison](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_assault_rifle_32.png).

At 64 px/m the profile sole drifted 1.20 / 2.37 cm (mean / maximum) walking and 5.69 / 7.97 cm running. [All walk and run rows](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_assault_rifle_arena/rows/walk_run_rows_64.png) and [same-tick arena comparison](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_assault_rifle_64.png).

ImageGen made 16 row sheets in 2 min 47 s. All sixteen sheets passed the weapon and hand review on the first draw. For another rifle I would keep the stock, magazine and shroud separate in the prompt and match row heights before the first import. [Row prompts](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2221-n24motion/jobs.json) and [selected cells](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2221-n24motion/final_picks.json).

## Verification

unit-tests: 3795 passed, 0 failed, 2 skipped (GUT, headless). The every-weapon test covers both pitches. The quick lint and formatting checks passed.
