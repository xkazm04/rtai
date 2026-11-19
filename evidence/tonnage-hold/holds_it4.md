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
