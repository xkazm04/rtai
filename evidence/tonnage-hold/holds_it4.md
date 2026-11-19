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
