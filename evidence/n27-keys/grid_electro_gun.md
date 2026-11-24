# Electro gun at tilt 70: own walk and run grids

The electro gun now walks and runs on its own drawn p70 grids (`rivet_walk_eq_electro_gun.png`, 4 columns; `rivet_run8_eq_electro_gun.png`, 8 columns). Before, it borrowed the bare-claw legs with the thin held part on the palm. Each of the eight facings pairs the shipped plasma_rifle stride (long two-hand donor) with the electro gun as Rivet holds it on its equipped strip: the gold coil barrel with the claw tip on the near hand, the black hose and white nozzle on the free arm. The collar is the rigid orange and black hazard collar throughout. P55 keeps the fallback (next brief).

## Stride (110 px standing-height space)

Travel is measured from the packed soles. Walk = lead contact over two columns, run = mean of the two contact-to-push intervals. Run factor k = min(1, own / bare) where both are at least 12 px; depth rows stay 1.00.

| Facing | Walk / plasma_rifle (px) | Run / plasma_rifle / bare (px) | k | Walk / run grade, fixes |
|---|---:|---:|---:|---|
| Front | 17.7 / 18.0 | 2.3 / 2.7 / 3.3 | 1.00 | A / A. Muzzle faces the camera, both soles whole. |
| Front right | 5.3 / 9.3 | 42.0 / 45.8 / 47.0 | 0.89 | A / A. Barrel angles down-right, hose stays beside the hip. |
| Right | 48.0 / 45.7 | 58.5 / 65.8 / 67.5 | 0.87 | A / A. Level barrel, plain free-arm nozzle. Walk row 3 was generated late in the n26 round. |
| Back right | 29.3 / 31.7 | 1.3 / 2.2 / 3.3 | 1.00 | A / A. |
| Back | 20.3 / 20.3 | 2.7 / 4.3 / 3.7 | 1.00 | A / A. Claw tip at the right elbow, hose on the left. |
| Front left | 11.7 / 14.0 | 41.5 / 43.5 / 44.7 | 0.93 | A / A. |
| Left | 34.3 / 31.0 | 54.0 / 62.3 / 63.0 | 0.86 | A / A. Walk row 7 generated late, scaled by dome width. |
| Back left | 9.0 / 14.0 | 44.7 / 46.8 / 46.5 | 1.00 | A / A. |

Right and left profile walks give an 82.3 px cycle; right-profile contact-to-passing is 26.5 and 33.5 packed texels. Run k written for run rows 0, 1, 3, 4, 5 (`p70/electro_gun/<row>`). Thirteen of the sixteen rows were rescaled by row height to the plasma_rifle row before packing (`scale_corrections.json` in the round, factors 0.85 to 0.94); no other cut fix was needed.

Tone: after the equipped-strip tone pass every row's opaque RGB mean matches its equipped card within 0.3 per channel (`tone.json` in the round).

## Feet (tools/film/foot_slide.py on the right-profile lane, mean / max)

| ppm | Walk | Run |
|---|---|---|
| 32 | 0.79 / 1.22 cm | 3.86 / 8.68 cm |
| 64 | 0.49 / 0.96 cm | 4.12 / 9.64 cm |

Limits: walk mean <= 2 cm, run mean <= 7 cm at 32 px/m. Both met.

## Stills

- [Fallback | own grid, 32 px/m](C:/Users/kazda/kiro/gtai-masters/n27/keys/grid_electro_gun_32.png) and [64 px/m](C:/Users/kazda/kiro/gtai-masters/n27/keys/grid_electro_gun_64.png): sixteen same-tick pairs (8 facings walking, 8 sprinting), real input at 6.75 and 9.3 m/s.
- [Paired film, 32 px/m](C:/Users/kazda/kiro/gtai-masters/n27/keys/grid_electro_gun_32.mp4).
- [All walk and sprint rows in game, 32](C:/Users/kazda/kiro/gtai-masters/n27/keys/grid_electro_gun_arena/rows/walk_run_rows_32.png) and [64](C:/Users/kazda/kiro/gtai-masters/n27/keys/grid_electro_gun_arena/rows/walk_run_rows_64.png).

## Drawing

All 16 rows (8 walk, 8 run8) were generated with Codex image_gen in round `20261123-1559-n26keys` (n26 night, donor plasma_rifle; image 1 = the donor row, image 2 = the electro gun's equipped strip). Walk rows 3 and 7 were generated late and cut in this call. Images generated in this call: 0 (IMAGES 0). The last night's round used 16 jobs; per-job timing is in its gen.log files.
