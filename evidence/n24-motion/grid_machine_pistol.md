# Machine pistol at tilt 70

The machine pistol uses its own four-column walk and eight-column run. Each facing pairs the shipped one-hand pistol stride with the machine pistol’s equipped card. The magazine hangs beneath the barrel. The opposite arm ends in the card’s blunt silver hose nozzle. The existing own-grid lookup selects both p70 sheets. P55 keeps the bare-claw and held-part fallback. This delivery targets the owner?s default tilt of 70 degrees.

## Stride and visual review

Travel is measured from the packed sole in 110 px standing-height space. The walk uses the lead contact over two columns. The run averages the absolute travel of both contact-to-push intervals. The run factor is capped at 1.00. Depth rows use 1.00.

| Facing | Walk / pistol (px) | Run / pistol / bare (px) | Run factor | Walk / run grade and observation |
|---|---:|---:|---:|---|
| Front | 17.3 / 18.7 | 3.7 / 2.8 / 3.3 | 1.00 | A / A. The squared twin-port muzzle faces the camera. The corrected near soles have a complete outline. |
| Front right | 22.7 / 26.3 | 44.7 / 47.5 / 47.0 | 0.95 | A / A. The short barrel angles down-right. The opposite hose stays visible beside the hip in both gaits. |
| Right profile | 42.3 / 44.0 | 58.3 / 67.2 / 67.5 | 0.86 | A / B. The magazine hangs below the level barrel. The sprint covers less ground per stance than the pistol donor. |
| Back right | 30.3 / 32.7 | 1.5 / 2.2 / 3.3 | 1.00 | A / A. The far hip hides the receiver while the angled muzzle and the separate hose stay readable. |
| Back | 17.0 / 18.3 | 3.2 / 3.2 / 3.7 | 1.00 | A / A. The muzzle rises at the right elbow. The left hose ends in a short connector. |
| Front left | 12.3 / 15.3 | 45.7 / 45.7 / 44.7 | 1.00 | A / A. The barrel points left and the magazine clears the lead boot throughout the stride. |
| Left profile | 31.3 / 30.0 | 57.5 / 63.5 / 63.0 | 0.91 | B / A. The silhouette of the two walk contacts is similar. The run alternates weight and keeps one blunt nozzle across the waist. |
| Back left | 10.7 / 13.3 | 52.3 / 29.7 / 46.5 | 1.00 | A / A. The rear-left run keeps the same two arms across all eight poses, including the flight and passing frames. |

The right and left profile walks give a 73.7 px cycle. Right-profile contact-to-passing travel is 21.0 and 27.0 packed texels.

At 32 px/m the profile sole drifted 0.97 / 1.73 cm walking and 5.45 / 7.42 cm running (mean / maximum). [All walk and sprint rows](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_machine_pistol_arena/rows_final/walk_run_rows_32.png) and [same-tick arena comparison](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_machine_pistol_32.png).

At 64 px/m the profile sole drifted 0.94 / 1.80 cm walking and 7.03 / 8.79 cm running (mean / maximum). [All walk and sprint rows](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_machine_pistol_arena/rows_final/walk_run_rows_64.png) and [same-tick arena comparison](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_machine_pistol_64.png).

## Drawing and capture

ImageGen produced sixteen initial sheets and six corrective sheets. The first front run clipped two boot soles. The front-right and back sprints needed the equipped gun angle and hose. The two left sprints picked up an extra donor claw. A final back-left pass used the accepted left run and back-left walk as examples of the plain nozzle. After the standard equipped-strip tone pass, each row’s opaque RGB mean matches its equipped facing within 0.3 per channel. [Row selections](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2310-n24motion/accepted_selections.json) and [corrective nozzle reference](C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2310-n24motion/nozzle_fix/jobs.json).

Generation took 6 min 33 s summed across five batches, with overlapping initial and corrective jobs. For a subsequent asymmetrical gun, I would include a clean free-arm example in the first sprint requests.

The ruler captures both drawn grids at 2.4 and 3.2 m/s. The arena footage uses real keyboard-equivalent walk and sprint input at 6.75 and 9.3 m/s. Both arena speeds select run8. The paired captures match world position, screen position, facing and tick at both zooms. [Machine-pistol arena clip](C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_machine_pistol_32.mp4).

## Verification

The changed unit suite reported 3,795 passed, zero failed and two skipped, including the every-weapon pitch sweep. Quick lint and formatting passed. The changed calibration lines have zero eligible operators under the 20-mutant cap.
