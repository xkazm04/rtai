# Hand cannon at tilt 70

The equipped strips supply the one-hand cannon's fluted barrel, round bore and free hand. The pistol family supplies the legs. Four redraws remove the far claw from the right-profile muzzle and keep the heavy round barrel through front-running poses. Six rows were scaled against the donor before import. In the right-profile walk, the trailing boot in column 3 is 11 packed texels above the leading toe. Following each sole separately gives 41.0 cell px from the first contact to the third column. The left profile gives 28.7 px. The own-grid lookup selects these two PNGs at p70. P55 uses the bare-claw legs and held-part fallback. Drawing and validating another pitch exceeds the 15-minute allowance.

## Stride and row review

Travel is measured in 110 px standing-height space. Walk follows the leading contact sole over two columns. Run averages contact-to-push travel for the two feet. Each run factor compares this row with bare run8, capped at 1.00. Depth-facing rows have too little horizontal travel for that comparison.

| Facing | Walk / family (px) | Run / family / bare (px) | Run factor | Walk / run grade and observation |
|---|---:|---:|---:|---|
| Front | 18.7 / 18.7 | 5.8 / 2.8 / 3.3 | 1.00 | A / A. The round muzzle and barrel flutes remain visible, including the front run's passing frames. |
| Front right | 21.0 / 26.3 | 48.3 / 47.5 / 47.0 | 1.00 | A / B. The cannon stays in the same hand. The free pincer opens as the arm swings, and the two running leads look similar. |
| Right profile | 41.0 / 44.0 | 61.5 / 67.2 / 67.5 | 0.91 | A / A. The far hand stays behind the torso. Both the muzzle and the two separate soles have clean silhouettes. |
| Back right | 31.3 / 32.7 | 0.7 / 2.2 / 3.3 | 1.00 | A / A. The cannon stays on the far side of the back plate. The free tool hand remains visible in front. |
| Back | 18.3 / 18.3 | 2.5 / 3.2 / 3.7 | 1.00 | A / A. The barrel clears the right shoulder in all contacts. The other hand stays on the left. |
| Front left | 12.7 / 15.3 | 40.7 / 45.7 / 44.7 | 0.91 | A / B. The cannon is raised across the left side as on the card. The two leads in the run have similar outlines. |
| Left profile | 28.7 / 30.0 | 53.2 / 63.5 / 63.0 | 0.84 | A / A. The heavy round bore stays clear of the forward boot and free hand through push-off. |
| Back left | 24.7 / 17.3 | 44.7 / 47.0 / 46.5 | 0.96 | A / A. The arm holds the muzzle left of the body through contact and flight. The raised boot was measured separately in the walk. |

On the right profile, the first leading sole is centred at x=114.5 in packed column 1 and the trailing sole at x=53.0 in column 3. The back-left boot is also raised. Measuring each sole at its own height gives 24.7 px for that walk and 17.3 px for the donor. [Profile measurements](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2232-n24motion/profile_boot_measurement.json) and [back-left measurements](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2232-n24motion/back_left_boot_measurement.json).

The two profile walks give a 69.7 px cycle. Alternate contact-to-passing distances on the right profile are 25.0 and 30.0 packed texels.

The ruler uses 2.4 and 3.2 m/s to isolate the walk and run grids. The arena comparison uses 6.75 and 9.3 m/s. [Game-speed film](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_hand_cannon_32.mp4)

At 32 px/m the profile sole drifted 0.98 / 1.39 cm (mean / maximum) walking and 7.04 / 10.94 cm running. [All walk and run rows](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_hand_cannon_arena/rows/walk_run_rows_32.png) and [same-tick arena comparison](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_hand_cannon_32.png).

At 64 px/m the profile sole drifted 0.87 / 1.91 cm (mean / maximum) walking and 7.80 / 11.99 cm running. [All walk and run rows](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_hand_cannon_arena/rows/walk_run_rows_64.png) and [same-tick arena comparison](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_hand_cannon_64.png).

ImageGen made 20 row sheets in 5 min 31 s. For another one-hand grid, I would specify the free wrist and muzzle in each profile and measure an elevated far sole before packing the calibration. [Row prompts](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2232-n24motion/jobs.json) and [selected cells](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2232-n24motion/corrected_picks.json).

[Four correction prompts](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2232-n24motion/fix1/jobs.json). No mutation operators matched the changed runtime lines.

## Verification

unit-tests: 3795 passed, 0 failed, 2 skipped (GUT, headless). The every-weapon test covers both pitches. The quick lint and formatting checks passed.
