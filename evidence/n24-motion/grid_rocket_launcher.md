# Rocket launcher at tilt 70

Rivet holds the tube across his upper body in all eight facings. The equipped strip supplies its orange nose, open rear rim and grip. The plasma-rifle family supplies the walk and run timing. The existing own-grid lookup selects the new p70 files. At p55 the launcher continues to use the bare-claw and held-part fallback. A second drawn pitch with its own validation exceeds the 15-minute allowance.

## Stance travel

Measurements use packed alpha at a reference standing height of 110 px. Walk follows the leading sole in column 1 to the trailing position in column 3. Run averages the absolute contact-to-push distances for the two feet. The front, back-right and back rows have little horizontal travel. Their cadence stays at 1.00. The other rows use the measured ratio to the bare run, capped at 1.00.

| Facing | Walk / family (px) | Run / family / bare (px) | Run factor | In-game walk / run grade |
|---|---:|---:|---:|---|
| Front | 17.0 / 18.0 | 2.7 / 2.7 / 3.3 | 1.00 | A / A. The front run redraw separates the two contacts under the braced tube. |
| Front right | 6.7 / 9.3 | 46.8 / 45.8 / 47.0 | 1.00 | A / B. The run redraw removes the donor's open pincer. The two contacts have similar leads, as on the two-hand run. |
| Right profile | 46.7 / 45.7 | 61.3 / 65.8 / 67.5 | 0.91 | A / A. The orange nose stays ahead of the supporting hand through both steps. |
| Back right | 30.7 / 31.7 | 2.7 / 2.2 / 3.3 | 1.00 | A / A. The rear rim stays visible above the forearm without crossing the thigh. |
| Back | 20.0 / 20.3 | 3.5 / 4.3 / 3.7 | 1.00 | A / A. Both tube ends remain visible around the back plate. The feet alternate underneath. |
| Front left | 33.0 / 14.0 | 41.8 / 43.5 / 44.7 | 0.94 | B / B. A new walking contact separates the lead boots. Its torso rides slightly higher. The running row retains the family's similar leads. |
| Left profile | 37.3 / 31.0 | 58.8 / 62.3 / 63.0 | 0.93 | A / A. The open rear end stays on the near side and both profile feet clear the tube. |
| Back left | 6.3 / 14.0 | 47.3 / 46.8 / 46.5 | 1.00 | A / A. The barrel remains above the waist and the outer arm keeps the equipped overlap. |

The two profile half-cycles measure 46.67 and 37.33 cell px, giving an 84.0 px full walk cycle. The right-profile contact-to-passing travel measures 23.0 and 36.5 packed texels on alternate feet. Two experimental diagonal running contacts reduced the second foot's horizontal travel to under 5 px. The selected redraws restore the family's reach.

## In-game review

The ruler captures show all eight directions in a four-frame walk and an eight-frame run. At 32 px/m the profile sole's mean / maximum net drift measured 1.07 / 2.52 cm walking and 5.93 / 8.85 cm running. At 64 px/m the corresponding results were 1.38 / 3.06 cm and 6.27 / 9.11 cm. Within an individual held drawing the running sole's mean excursion is about 61 cm. [32 px/m row inspection](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_rocket_launcher_arena/rows_final/walk_run_rows_32.png) ? [64 px/m row inspection](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_rocket_launcher_arena/rows_final/walk_run_rows_64.png)

The paired arena views selected the launcher through the wheel and followed identical tick and position samples at 6.75 and 9.3 m/s. [32 px/m stills](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_rocket_launcher_32.png) ? [64 px/m stills](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_rocket_launcher_64.png) ? [60 fps arena comparison](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_rocket_launcher_32.mp4)

The built-in ImageGen tool produced 23 images in 11 min 6 s from the round manifest to the last result. These comprise 16 initial rows, four row redraws and three individual contact alternatives. For the diagonal runs, inspecting both stance distances alongside the contact silhouettes would have ruled out two alternatives earlier. [Prompts and selected cells](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2107-n24motion/final_picks.json)

## Checks

unit-tests: 3794 passed, 0 failed, 2 skipped (GUT, headless). The changed-file formatting and lint checks passed. The every-weapon suite exercises the measured walk contacts and all eight run factors. The mutation tool offers zero operators for the changed constant-table entries.
