# Tonnage right-profile hold measurements

Baseline at c07cab306. Leg 2 covers all 16 keys and the existing step-5 midpoint in 110 consecutive ticks at 32 px/m. Columns are one-based. The incoming and outgoing jumps are the stance contact displacements in the lowest four rows of the shipped sheet. C13 to C14 exchanges support (78 to 140 cell px). The measured timing table assigns that switch 25.9 cell px.

The table follows each over-bar key into the retimed film. The last column includes the entire duration of every new midpoint touching that original tick span, including the visible part of the final open hold. M1 is the existing C6 to C7 midpoint.

| Key | Before ticks | Ticks | Stance jump in / out (cell px) | Before ride | After key ticks | After key ride | Worst overlapping hold after |
|---|---|---:|---|---:|---|---:|---:|
| C9 | 244-248 | 5 | 5.5 / 13.5 | 9.186 | 244-246 | 4.179 | 4.285 |
| C10 | 249-253 | 5 | 13.5 / 10.5 | 9.205 | 250-252 | 5.010 | 5.010 |
| C11 | 254-259 | 6 | 10.5 / 14.5 | 12.014 | 255-257 | 4.261 | 7.093 |
| C12 | 260-266 | 7 | 14.5 / 18 | 13.384 | 262-265 | 7.033 | 7.093 |
| C13 | 267-275 | 9 | 18 / switch | 18.316 | 270-273 | 7.034 | 7.050 |
| C14 | 276-281 | 6 | switch / 5 | 11.289 | 278-281 | 7.026 | 7.029 |
| C2 | 289-296 | 8 | 11 / 25 | 15.504 | 292-295 | 7.105 | 7.121 |
| C3 | 297-305 | 9 | 25 / 20 | 18.395 | 300-303 | 7.108 | 7.121 |
| C4 | 306-310 | 5 | 20 / 4 | 9.175 | 307-310 | 7.034 | 7.034 |
| C6 | 315-320 | 6 | 13.5 / 22.5 | 11.263 | 318-321 | 6.370 | 6.370 |
| M1 | 321-325 | 5 | 22.5 / 22 | 9.157 | 322-325 | 6.327 | 6.370 |
| C10 | 336-340 | 5 | 13.5 / 10.5 | 9.179 | 338-339 | 2.065 | 6.311 |
| C11 | 341-346 | 6 | 10.5 / 14.5 | 11.271 | 342-344 | 4.942 | 7.047 |

At 32 px/m the worst completed ride fell from **18.395 to 7.121 px**, the mean from **8.911 to 5.005 px**, and mean absolute stance drift from **2.381 to 2.082 px**. Every retained completed key hold was equal or shorter. The worst new hold was the four-tick C2-to-C3 midpoint at ticks 296-299. The historical tool counts 22 and 33 completed holds. Its trailing open spans were 2.116 px before (two ticks) and 7.047 px after (four ticks).

## Cell construction and visual check

Each row lists the measured stance centre of the two source keys and the derived midpoint. The contact is the alpha >128 group in the lowest four rows. The C10 pair shares a combined 57 px contact. At the C13 handoff we followed the departing pad to the lifted C14 rear pad at x28. The newly planted C14 front pad is at x140.

| Transition | Endpoints, cell px | Midpoint, cell px |
|---|---:|---:|
| C1-C2 | 135.5 / 124.5 | 130.5 |
| C2-C3 | 124.5 / 99.5 | 112 |
| C3-C4 | 99.5 / 79.5 | 89.5 |
| C5-C6 | 75.5 / 62 | 69 |
| C6-C7 (existing) | 62 / 17.5 | 39.5 |
| C9-C10 | 134.5 / 121 | 127.5 |
| C10-C11 | 121 / 110.5 | 116 |
| C11-C12 | 110.5 / 96 | 103.5 |
| C12-C13 | 96 / 78 | 87 |
| C13-C14 | 78 / 28 | 53 |

At 64 px/m the C2-C4 piston moves from angled to upright with one visible sole. In C5-C7 the trailing leg extends as the front pad comes down. At C13-C14 the outgoing pad travels left under the housing before support changes. The first C10-C11 trial copied the transparent patch in C11's metal shaft. In the shipped midpoint, C10 supplies the metal inside the piston rim. Across all ten triplets the housing keeps its rivets, yellow stripe and continuous teal silhouette. I saw no doubled pad or detached limb. [The ten in-game triplets at 64 px/m](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/it4-midpoints-64ppm.png>).

## Coverage and reproduction

The other measured profiles have their own drawings. The p70 left has 16 keys with different stance positions (C3 at 73, C6 at 49.5). The p55 right and left have eight keys each (C3 at 80.5 and 90.5). The new atlas applies only to the specified 16-column p70 right film. Each control matched all 110 baseline crops byte for byte.

| Other profile at 32 px/m | Worst ride | Mean ride |
|---|---:|---:|
| p70 left | 18.401 | 9.504 |
| p55 right | 31.707 | 20.239 |
| p55 left | 31.587 | 18.364 |

The SHA-256 of each of the four original PNG files matched its committed LFS object. Together they contain 192 byte-identical cells (80 + 48 at p70 and 40 + 24 at p55). The original 163 by 1150 midpoint column matches the first column of the new atlas in every RGBA byte, SHA-256 `c8e24ba86d53123b812c67a3e835fed7e8f0e9a7474f6de8714f0e100aa72b55`. Repacking the shipped ten-column atlas reproduced SHA-256 `d4698d12b6b8fb4a8c10a608635aeeac30718e2897a141c9bbbf758f8f14cb4f`.

Film leg 2 at fixed 60 fps using the flags in [the step-5 reproduction](step5_32ppm.md). Run `python evidence/s15/tools/hold_ride.py <prefix> 2 110 0,45 70,150,190,222` for each arm. For left, use turn 180. For p55, use view tilt. To inspect contacts run `python evidence/it13/tools/foot_travel.py <sheet> 2 4 <columns> 5` for right sheets or row 1 and 3 rows for left. The stance-drift calculation uses the pairing in `evidence/it13/tools/ghost_slip.py`, subtracts each midpoint window's two contributions from its neighbours, and gives their sum to the inserted cell. It then normalizes to 235 cell px per cycle and scales by 3.3 / 190.5 at 32 px/m. The mean is over 16 and 25 matched stance pairs. [Raw leg-2 crops, cell logs and replay probe](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/raw/it4/>).

## P70 left profile, brief 09

At 32 px/m, leg 2 with turn 180 covered all 16 left keys across ticks 239–348. The worst completed hold fell from **18.401 to 7.018 px**, mean ride from **9.504 to 5.008 px**, and mean absolute stance drift from **3.342 to 2.440 px**. The detector closed 21 holds before and 33 after. The open tail covered two ticks and 2.118 px before, four ticks and 7.032 px after. The logged sprite changes agreed with every detector boundary in both left-profile films.

Every original over-bar occurrence is below. Each retained key in the film held for the same duration or less. Newly inserted midpoint rides ranged from 2.172 to 7.002 px across completed holds.

| Key | Before ticks | Before ride, px | After key ticks | After key ride, px |
|---|---|---:|---|---:|
| C9 | 244–248 | 9.183 | 244–246 | 4.464 |
| C10 | 249–253 | 9.212 | 250–252 | 4.722 |
| C11 | 254–259 | 11.722 | 255–257 | 4.440 |
| C12 | 260–266 | 13.750 | 262–265 | 6.879 |
| C13 | 267–275 | 18.401 | 270–273 | 6.911 |
| C14 | 276–281 | 11.344 | 278–281 | 6.938 |
| C2 | 289–296 | 15.731 | 292–295 | 6.993 |
| C3 | 297–305 | 18.389 | 300–303 | 6.995 |
| C4 | 306–310 | 9.165 | 307–310 | 7.018 |
| C6 | 315–322 | 16.241 | 318–321 | 6.448 |
| C7 | 323–329 | 13.559 | 326–329 | 6.466 |
| C10 | 336–340 | 9.152 | 338–339 | 2.160 |
| C11 | 341–346 | 11.409 | 342–344 | 4.784 |

The ten left drawings follow C1, C2, C3, C5, C6, C9, C10, C11, C12 and C13. Both directions use the same measured 16-key timing, so each left midpoint takes the existing window from the two adjacent keys. The measured left midpoint stance centres in that order are 31.5, 54.0, 78.0, 67.5, 35.0, 35.5, 47.0, 59.5, 74.5 and 109.5 cell px. At C6–C7 the drawing follows the departing pad from 49.5 toward the lifted pad at 20.5. At C13–C14 the departing pad travels from 83.5 toward 136 before the front pad lands.

For left-facing drift, reverse the contact displacement in the step-5 calculation. For successive contact x positions x and y, the signed displacement is x minus y. Apply the same stance-pair acceptance interval, 235 cell px per cycle and 3.3 / 190.5 display scale. The means cover 12 matched stance pairs before and 20 after.

I inspected each 64 px/m triplet with the in-game sprite and its teal outline isolated from the parked cars. C3–C4 lifts the front pad while the planted shaft straightens. The C10–C11 rear pad has a connected socket borrowed from C10. At C13–C14 the outgoing shaft crosses in front of the rear socket with clear ground between their rims. The crown rivets, yellow stripe and teal edge stay continuous across the ten midpoints. I saw no doubled limbs. [Ten left-profile triplets at 64 px/m](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/it4-left-midpoints-64ppm.png>).

All four original walk PNGs matched their committed SHA-256 at 4535fb7ef, covering 192 original cells. The 48-cell left p70 source hash is `18799100ed3ad58ac40cd6439ef17f5d7e66112e71dcf956d87975fed563c0eb`. The original right midpoint atlas also repacked byte-identically. All 64 ticks showing the same base key in both left-profile films produced byte-identical PNG crops. Running `python tools/art/tonnage_midpoint.py --left` reproduced the new atlas SHA-256 `e42ef33d328f769864f201d9336214024f8eb639f4a4d5df408ba777caa2cab3`. [Raw left-profile and diagonal films, sheet logs and capture probes](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/raw/it4-left/>).

### P70 three-quarter controls

Each 110-tick film used the same ground band, figure box and change threshold. Diagonal motion changes pixels in the box even while the sprite holds one key. The threshold closed 70–96 holds where the sheet log recorded 21. For the key-hold columns, sum the same per-tick ground shifts over each continuous logged key and exclude the open tail as in the profile measure. Each control visited all 16 columns.

| Facing (turn) | Detector worst / mean, px | Logged-key worst / mean, px |
|---|---:|---:|
| Left three-quarter toward (135°) | 4.304 / 0.460 | 17.529 / 7.687 |
| Left three-quarter away (−135°) | 5.394 / 0.337 | 21.042 / 10.438 |
| Right three-quarter toward (45°) | 4.306 / 0.639 | 16.392 / 8.021 |
| Right three-quarter away (−45°) | 5.211 / 1.381 | 21.886 / 10.679 |


## P70 three-quarter walks, brief 10

At 32 px/m, 110 ticks on leg 2 cover every original key and every added cell on all four rows. The fresh right baselines reproduced the brief 09 logged-key measurements. The before films use f63f8f094. A hold lasts as long as the logged sheet and column stay the same. The pixel-change threshold also responds to moving background in a diagonal crop. For each logged hold we sum the ground shifts from the historical 0–45 px band. Summary means cover 21 completed holds before and 71 after. The last open hold after is one tick (0 px) on each row.

| Facing | Worst ride before / after | Mean ride before / after | Mean stance drift before / after | Matched pairs before / after |
|---|---:|---:|---:|---:|
| Right toward | 16.392 / 3.902 | 8.021 / 1.140 | 8.930 / 2.799 | 12 / 53 |
| Right away | 21.886 / 5.079 | 10.679 / 1.439 | 8.010 / 2.114 | 13 / 52 |
| Left toward | 17.529 / 2.903 | 7.687 / 0.983 | 8.213 / 2.317 | 12 / 52 |
| Left away | 21.042 / 5.500 | 10.438 / 1.255 | 8.123 / 2.140 | 13 / 52 |

| Facing | Original key | Original ticks | Before ride | After key ticks | After key ride | Worst overlapping ride after |
|---|---|---|---:|---|---:|---:|
| Right toward | C9 | 244–248 | 9.155 | 246–246 | 0.000 | 2.322 |
| Right toward | C11 | 254–259 | 9.699 | 256–257 | 1.552 | 2.223 |
| Right toward | C12 | 260–266 | 10.693 | 262–263 | 3.036 | 3.036 |
| Right toward | C13 | 267–275 | 16.392 | 270–271 | 2.629 | 3.324 |
| Right toward | C14 | 276–281 | 9.597 | 278–279 | 2.596 | 2.596 |
| Right toward | C2 | 289–296 | 12.986 | 292–293 | 1.263 | 1.813 |
| Right toward | C3 | 297–305 | 15.730 | 301–301 | 0.000 | 2.615 |
| Right toward | C6 | 315–322 | 11.800 | 319–319 | 0.000 | 3.271 |
| Right toward | C7 | 323–329 | 10.618 | 326–326 | 0.000 | 3.902 |
| Right away | C9 | 244–248 | 10.684 | 246–246 | 0.000 | 2.563 |
| Right away | C10 | 249–253 | 10.055 | 251–251 | 0.000 | 2.659 |
| Right away | C11 | 254–259 | 12.534 | 256–257 | 1.806 | 3.165 |
| Right away | C12 | 260–266 | 16.123 | 262–263 | 3.268 | 3.268 |
| Right away | C13 | 267–275 | 21.886 | 270–271 | 2.525 | 3.472 |
| Right away | C14 | 276–281 | 12.325 | 278–279 | 2.091 | 2.417 |
| Right away | C2 | 289–296 | 17.278 | 292–293 | 2.652 | 3.059 |
| Right away | C3 | 297–305 | 20.746 | 301–301 | 0.000 | 4.117 |
| Right away | C4 | 306–310 | 10.002 | 308–308 | 0.000 | 3.715 |
| Right away | C6 | 315–322 | 16.724 | 319–319 | 0.000 | 3.800 |
| Right away | C7 | 323–329 | 15.009 | 326–326 | 0.000 | 5.079 |
| Right away | C10 | 336–340 | 10.682 | 338–338 | 0.000 | 3.018 |
| Right away | C11 | 341–346 | 13.448 | 343–344 | 2.670 | 3.205 |
| Left toward | C12 | 259–266 | 10.900 | 262–263 | 1.068 | 1.396 |
| Left toward | C13 | 267–275 | 11.388 | 270–271 | 1.067 | 2.021 |
| Left toward | C2 | 289–296 | 13.744 | 292–292 | 0.000 | 2.903 |
| Left toward | C3 | 297–305 | 17.529 | 301–301 | 0.000 | 2.681 |
| Left toward | C4 | 306–310 | 9.567 | 308–308 | 0.000 | 2.501 |
| Left toward | C6 | 315–322 | 14.531 | 318–319 | 1.352 | 2.277 |
| Left toward | C7 | 323–328 | 10.982 | 325–326 | 2.105 | 2.105 |
| Left toward | C11 | 341–346 | 10.538 | 343–344 | 2.447 | 2.447 |
| Left away | C9 | 244–248 | 11.350 | 246–246 | 0.000 | 2.399 |
| Left away | C10 | 249–253 | 10.000 | 251–251 | 0.000 | 3.165 |
| Left away | C11 | 254–259 | 11.959 | 256–257 | 1.799 | 3.165 |
| Left away | C12 | 260–266 | 15.481 | 262–263 | 2.434 | 2.626 |
| Left away | C13 | 267–275 | 21.042 | 270–271 | 1.846 | 2.345 |
| Left away | C14 | 276–281 | 11.394 | 278–279 | 1.454 | 1.666 |
| Left away | C2 | 289–296 | 18.540 | 292–293 | 2.361 | 2.368 |
| Left away | C3 | 297–305 | 20.945 | 301–301 | 0.000 | 3.521 |
| Left away | C4 | 306–310 | 9.664 | 308–308 | 0.000 | 2.700 |
| Left away | C6 | 315–322 | 17.678 | 319–319 | 0.000 | 2.954 |
| Left away | C7 | 323–329 | 15.173 | 326–326 | 0.000 | 5.500 |
| Left away | C10 | 336–340 | 10.263 | 338–338 | 0.000 | 3.762 |
| Left away | C11 | 341–346 | 13.099 | 343–344 | 3.298 | 3.298 |

The detailed table includes every original occurrence above 9 px. The last column counts the entire duration of each after-hold touching that interval. All retained original holds had equal or lower ride. All 29 same-key crops in each before/after pair were byte-identical (116 comparisons).

**Stance drift.** The lowest four rows identify each support using the historical alpha and horizontal pairing thresholds. Centre each contact relative to its own cell's feet. For a pair, add the measured two-axis contact displacement to the ground travel between its pose centres, then take the Euclidean length. At turn θ the screen-space ground vector per cell pixel is (cos θ, sin θ × sin 70°). Normalize the dwell to 235 cell px per cycle and convert to nominal 32 px/m with 3.3 / 190.5. Single midpoints on all 16 transitions still predicted over 3 px on all four rows. The shipped intervals divide the successive centre gaps into 4, 6, 4, 4, 4, 4, 2, 2, 4, 4, 4, 4, 4, 2, 2 and 2 parts. Both neighbours contribute dwell. The wrap from C16 to C1 follows the same rule.

**Art.** Each row has 40 new cells. The packer registers the roof and bends each shaft toward the matching sole on its neighbour. Each output takes colour from one shipped key. Four transparent pixels at each side isolate adjacent cells under linear filtering. The 64 px/m plates show all 160 cells beside their actual two source keys, with capture ticks. Right toward, the initially doubled C1–C2 front pad resolved to a single round sole after tracking local sole peaks. Right away, the C6–C8 outer piston extends below the hose with the near and outer rims separated. Left toward, C7–C9 carries the near piston across under the striped face. Left away, the C13–C15 outer pad extends right while the near shaft remains seated. The source keys alternate sharper and softer roof detail on some transitions, which remains visible. The final plates show continuous limb outlines and a single housing at each fraction.

- [Right toward triplets at 64 px/m](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/it4-diag-right-toward-midpoints-64ppm.png>).
- [Right away triplets at 64 px/m](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/it4-diag-right-away-midpoints-64ppm.png>).
- [Left toward triplets at 64 px/m](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/it4-diag-left-toward-midpoints-64ppm.png>).
- [Left away triplets at 64 px/m](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/it4-diag-left-away-midpoints-64ppm.png>).

The four original walk PNGs and the two shipped profile-midpoint PNGs match all six LFS SHA-256 objects at f63f8f094. This covers 192 original cells and all 80 prior midpoint atlas slots, including the 20 painted cells. The packer reproduced both previous midpoint files and both new atlases byte for byte. New right SHA-256 `5f8b6248ba90dba584cb6968f7f2de978cbccb1137319587cb45da8716edcc00`, left `3a133efd291c27793a73852ebf8d3cb4d46fa257013876302ab52ea4e04ed115`.

Repack with `python tools/art/tonnage_midpoint.py --diagonal` and repeat with `--left`. Use the leg-2 flags above, with turns 45, −45, 135 and −135 respectively. Run `python evidence/tonnage-hold/measure_rows.py <prefix> --pitch=p70 --turn=45 --steps=<raw>/steps.json` for the right-toward baseline. For the after film add `--divisions=4,6,4,4,4,4,2,2,4,4,4,4,4,2,2,2`. The engine logged its existing resources/pages-in-use messages at shutdown after recording tick 348. [Crops, per-tick sheet/phase logs, camera probes and timing tables](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/raw/it4-diag/>).

## Brief 10, p55 profiles at 32 px/m

Leg 2, turns 0 and 180, ticks 239–348 inclusive. Each consecutive run of the same logged texture and column is one hold. The prior left-profile pixel detector gave 18.364 px mean ride. The logged-key left baseline is 20.136 px. Both rows have 11 completed holds before and 37 after. The final partial holds ride 0 px before and 2.104/2.059 px after (right/left).

| Facing | Worst ride before / after | Mean ride before / after | Mean stance drift before / after | Matched pairs before / after |
|---|---:|---:|---:|---:|
| Right profile | 31.707 / 7.131 | 20.239 / 4.408 | 7.222 / 2.763 | 6 / 28 |
| Left profile | 31.587 / 7.105 | 20.136 / 4.378 | 6.853 / 2.655 | 6 / 28 |

| Facing | Original key | Original ticks | Before ride | After key ticks | After key ride | Worst overlapping ride after |
|---|---|---|---:|---|---:|---:|
| Right profile | C4 | 239–244 | 11.288 | outside clip | — | 7.131 |
| Right profile | C5 | 245–254 | 20.424 | 249–250 | 2.056 | 7.131 |
| Right profile | C6 | 255–264 | 20.478 | 259–260 | 2.131 | 4.954 |
| Right profile | C7 | 265–275 | 22.487 | 270–272 | 5.009 | 7.109 |
| Right profile | C8 | 276–281 | 11.259 | 277–280 | 7.066 | 7.109 |
| Right profile | C1 | 282–290 | 18.354 | 284–286 | 4.155 | 5.017 |
| Right profile | C2 | 291–301 | 23.422 | 295–296 | 2.053 | 5.086 |
| Right profile | C3 | 302–312 | 22.451 | 306–308 | 4.109 | 7.124 |
| Right profile | C4 | 313–327 | 31.707 | 319–321 | 4.121 | 7.124 |
| Right profile | C5 | 328–337 | 20.345 | 331–333 | 4.114 | 5.010 |
| Right profile | C6 | 338–347 | 20.415 | 342–343 | 2.988 | 4.133 |
| Left profile | C4 | 239–244 | 11.256 | outside clip | — | 7.066 |
| Left profile | C5 | 245–254 | 20.413 | 249–250 | 2.101 | 7.066 |
| Left profile | C6 | 255–264 | 20.422 | 259–260 | 2.048 | 5.035 |
| Left profile | C7 | 265–275 | 22.478 | 270–272 | 4.998 | 7.105 |
| Left profile | C8 | 276–281 | 11.252 | 277–280 | 7.105 | 7.105 |
| Left profile | C1 | 282–290 | 18.378 | 284–286 | 4.144 | 5.013 |
| Left profile | C2 | 291–301 | 23.256 | 295–296 | 2.091 | 4.963 |
| Left profile | C3 | 302–312 | 22.428 | 306–308 | 4.148 | 7.097 |
| Left profile | C4 | 313–327 | 31.587 | 319–321 | 4.150 | 7.097 |
| Left profile | C5 | 328–337 | 19.555 | 331–333 | 3.239 | 5.081 |
| Left profile | C6 | 338–347 | 20.468 | 342–343 | 2.912 | 4.255 |

The table includes all original holds above 9 px. In both films C4 was already on screen at the first baseline tick. Its shorter after-window falls before tick 239, so the last column gives the largest ride observed during those six ticks. All retained original keys had equal or lower ride.

| Filmed timing and art | Right worst / mean / drift (px) | Left worst / mean / drift (px) |
|---|---:|---:|
| 16 poses, original steps, cap off | 14.266 / 9.291 / 4.358 | 14.099 / 9.242 / 4.155 |
| 16 poses, even steps, cap 1 | 11.258 / 9.428 / 4.692 | 11.336 / 9.385 / 4.488 |
| 28 poses, original steps, cap off | 7.131 / 4.408 / 2.763 | 7.105 / 4.378 / 2.655 |

Each profile retains its eight drawn keys and gets 20 in-betweens. The first six key-centre intervals take three quarter poses each. C7–C8 and C8–C1 take one halfway pose each. The original step table supplies dwell from both neighbours. The p55 cycle stays 223.25 cell px. Across the final cycle all 28 stance pairs matched on each side.

At 64 px/m the near piston advances from C3 to C4 with a straight shaft seated in its housing. Both pads reach the wide C4–C5 support. At C7–C8 the left profile keeps the hose on its drawn side and the near and far feet stay distinct. Across all 40 drawings the housing has a single contour, the caster stays beneath it, and the rubber rims stay continuous. The raised in-between rims sit flatter than the tilted rims on some original keys. The script samples each facing's shipped piston, pad, caster and housing pixels.

[Right triplets at 64 px/m](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/it4-p55-right-midpoints-64ppm.png>) and [left triplets at 64 px/m](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/it4-p55-left-midpoints-64ppm.png>).

All eight prior walk, profile-midpoint and diagonal PNGs match their committed LFS SHA-256 objects. All 27 same-original-key crop pairs per p55 row were byte-identical (54 comparisons). Repacking all six supplemental PNGs reproduced their bytes. The new p55 right atlas SHA-256 is `ec0cf83ca908dda96d63972d14c7e230b4b9174144c2ab20f31742aa0d6f6033`; left is `44d8ec80d0db6246571e4e375d351998a18497fdc1f2c66f059cc04c81c420ce`.

Repack with `python tools/art/tonnage_midpoint.py --p55` and repeat with `--left`. For each capture run `python evidence/tonnage-hold/measure_rows.py <prefix> --pitch=p55 --turn=0 --steps=<raw>/steps.json` (left turn 180). For the final film add `--atlas=detail --divisions=4,4,4,4,4,4,2,2`. For the 16-pose trials give eight divisions of 2, `--atlas-file=<raw>/common16-pr.png` (left `common16-pl.png`) and use `even-steps.json` for the even trial. Each capture reached tick 348 before the engine’s resources/pages-in-use shutdown diagnostics. [Raw p55 captures, trial atlases and timing tables](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/raw/it4-p55/>).

## Brief 11, remaining eight walk rows before subdivision

Leg 2 at 32 px/m, ticks 239–348 inclusive, on 84aaf1131. Hold boundaries come from the logged texture and column, and each ride sums the measured ground-band shifts. Worst and mean cover completed holds. The open tail is reported separately. Stance drift uses the same two-axis displacement and 32 px/m conversion as brief 10. At ±90° the horizontal ground component is zero, so these two rows apply the historical support displacement gate along screen y. All eight baselines exceed 9 px.

| Pitch | Facing (turn) | Completed holds | Worst ride | Mean ride | Mean drift | Matched pairs | Open tail |
|---|---|---:|---:|---:|---:|---:|---:|
| p55 | right-toward (45°) | 11 | 26.089 | 16.687 | 10.519 | 5 | 0.000 |
| p55 | right-away (-45°) | 11 | 34.142 | 22.253 | 12.415 | 6 | 0.000 |
| p55 | left-toward (135°) | 11 | 25.883 | 15.232 | 10.554 | 5 | 0.000 |
| p55 | left-away (-135°) | 11 | 33.885 | 21.852 | 12.560 | 6 | 0.000 |
| p55 | toward (90°) | 11 | 17.101 | 11.961 | 22.637 | 8 | 0.000 |
| p55 | away (-90°) | 11 | 22.241 | 16.220 | 19.710 | 8 | 0.000 |
| p70 | toward (90°) | 21 | 12.016 | 6.454 | 10.556 | 16 | 1.698 |
| p70 | away (-90°) | 21 | 19.841 | 8.851 | 11.639 | 16 | 3.196 |

Reproduce with the brief 10 leg-2 flags, view `tilt` for p55 or `combo` for p70 and the turn in the table. Run `python evidence/tonnage-hold/measure_rows.py <prefix> --steps=<raw>/steps.json --pitch=<pitch> --turn=<turn>`. Every film recorded 110 consecutive samples. Godot issued the existing resources/pages-in-use diagnostics at shutdown. [Raw before/after films and capture probes](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/raw/it5/>).

### p55 after subdivision

| Facing | Worst before / after | Mean before / after | Stance drift before / after | Matches after | Open tail after | Identical base-key crops |
|---|---:|---:|---:|---:|---:|---:|
| right-toward | 26.089 / 2.995 | 16.687 / 1.085 | 10.519 / 2.305 | 46 | 0.000 | 19 |
| right-away | 34.142 / 3.708 | 22.253 / 1.405 | 12.415 / 2.066 | 48 | 0.000 | 19 |
| left-toward | 25.883 / 3.767 | 15.232 / 1.028 | 10.554 / 2.280 | 45 | 0.347 | 17 |
| left-away | 33.885 / 3.862 | 21.852 / 1.413 | 12.560 / 2.069 | 48 | 0.000 | 19 |
| toward | 17.101 / 2.434 | 11.961 / 0.862 | 22.637 / 1.955 | 52 | 0.000 | 19 |
| away | 22.241 / 3.354 | 16.220 / 1.147 | 19.710 / 2.007 | 51 | 0.000 | 19 |

Every original over-limit interval contains only shorter rides in its after-film. Each retained original key rode the same distance or less. The 10 prior walk PNGs matched their committed LFS SHA-256 objects. All 112 coincident original-key crop pairs were byte-identical. Each row adds 44 poses between its original key centres, taking dwell from both neighbours. Intervals per transition are 6, 8, 8, 8, 6, 6, 6, 4.

At 64 px/m I reviewed all 264 derived poses with their two original neighbours. On both toward diagonals C4–C5 initially left a second sliver below an outer rubber sole. Keeping the stance displacement clear of both original and destination soles removed it on both sides. The C3–C4 away diagonals show a single tilted rim on each extending piston, and the left hose remains on its drawn side. On straight toward the riveted sill stays level as the pad changes sides. On straight away the narrow side legs extend past the rear armour with continuous outlines. The small change in the original crown lighting at the donor handoff remains visible.

Repack the two pages with `python tools/art/tonnage_midpoint.py --fill p55 --page a` and `--page b` and repeat with `--left`. For the after films add `--atlas=fill --divisions=6,8,8,8,6,6,6,4` to the baseline measurement command. The two pages fit the texture-size limit.

- [right-toward at 64 px/m](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/it5-p55-right-toward-midpoints-64ppm.png>).
- [right-away at 64 px/m](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/it5-p55-right-away-midpoints-64ppm.png>).
- [left-toward at 64 px/m](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/it5-p55-left-toward-midpoints-64ppm.png>).
- [left-away at 64 px/m](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/it5-p55-left-away-midpoints-64ppm.png>).
- [toward at 64 px/m](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/it5-p55-toward-midpoints-64ppm.png>).
- [away at 64 px/m](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/it5-p55-away-midpoints-64ppm.png>).

| Atlas | Repacked SHA-256 |
|---|---|
| tonnage_walk8_fill_a.png | `0135bccd607af732d33e46306ef6a87282289c8cd0e617bb124a9f9298f89588` |
| tonnage_walk8_fill_a_left.png | `57e1a8b06e2c7d6e1ef1ee868d01d73ab92875e442f4fe0acc1d6b7db1aabdda` |
| tonnage_walk8_fill_b.png | `1981804d417956cf3d640341ca6e04226e235cef9bbb3856f9549d56174156bf` |
| tonnage_walk8_fill_b_left.png | `9d1581e0cd819ceb759683f1afee359f63fb57a35b714ae85de201b65143fd4c` |
