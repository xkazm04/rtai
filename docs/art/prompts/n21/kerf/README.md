# Kerf · Swarf Ronin

The ten built-in image_gen masters are 1536 × 1024. Each shipped atlas uses
all twenty cells of one take. The six overhead parts come from a fifth master.

The archive is `C:/Users/kazda/kiro/gtai-masters/n21/kerf/`. Raw takes live in
`masters/<sheet>_take<N>.png`. The manifest records their SHA-256 hashes.

## References in input order

The archive's `masters/refs/` directory contains byte copies of the six originals.

| Sheet | Image 1 · character | Image 2 · style and layout | Image 3 · camera |
| --- | --- | --- | --- |
| Flight and action, 70° | R1 | R2 | R3 |
| Flight and action, 55° | R1 | R4 | R5 |
| Overhead parts | R1 | R6 | |

1. R1 — `C:/Users/kazda/kiro/gtai-masters/n21/concepts/kerf_b.png`
2. R2 — `C:/Users/kazda/kiro/gtai-masters/n20/dent/masters/dent_sp_fly_70_take1.png`
3. R3 — `C:/Users/kazda/kiro/gtai-art/library/refs/camera_guide_70.png`
4. R4 — `C:/Users/kazda/kiro/gtai-masters/n20/dent/masters/dent_sp_fly_55_take1.png`
5. R5 — `C:/Users/kazda/kiro/gtai-art/library/refs/camera_guide_55.png`
6. R6 — `C:/Users/kazda/kiro/gtai-masters/n20/dent/masters/dent_sp_top_take1.png`

## Flight at 70°

| Take | Visual review |
| --- | --- |
| 1 | Rejected. The front hover hangs both blade tips beside the ribbon and the three-quarter-away hover exposes the chest. The director approved cruise, turn and hit for possible reuse. |
| 2 | Rejected. The hover repeats the downward crescents. In the front cruise the cutters sit on either side of the helmet. |
| 3 | Rejected. The torso and lens read clearly, but both front hover tips hang below the chest. |
| 4 | Shipped all four rows. The revised hover lifts every visible tip above the helmet and shows the back slots in the three-quarter-away facing. The profile cruise folds the blades back, the turn banks the torso and the hit opens both arms. |

Takes 1–3 used `kerf_sp_fly_70.txt`. Take 4 used `kerf_sp_fly_70_raised.txt`,
which changes only the hover sentence. The far blade is occluded in profile hover.

## Action at 70°

| Take | Visual review |
| --- | --- |
| 1 | Shipped all four rows, **director ruling 11:59**. The three-quarter-away column shows the back best. The director accepted the blade droop in the short cock, recover and blink phases. |
| 2 | Rejected. The side blink trails the blades, but the front blink opens them downward. The director preferred take 1's back view. |
| 3 | Rejected. The front blink brings the tips together around the tail and the side cut hooks downward at its end. |

## Flight and action at 55°

Flight shipped take 1 of 1 using the revised hover prompt. All five hovers have
the raised crescent silhouette, with one visible blade in profile. The fourth
facing exposes the back plate. Action shipped take 1 of 1 under the same action
ruling. The cock crosses the torso, the cut extends beyond it and the blink
pulls the blades in. Both sheets retain the legless body and the full 4 × 5 grid.

## Packed scale and charge slots

The packed layout follows Dent's drawer. Pose is the column, facing is the row.
The table gives the horizontal width of the profile hover or cock helmet on
the shipped texture at alpha ≥ 128. Each scan is cell-relative and excludes
the helmet streamer. All four packs use `--k`.

| Atlas | Take | Scale | Cell, px | Profile scan x [start, end), y | Helmet, px | Median hover or cock height, px | Cells with three slots |
| --- | ---: | ---: | --- | --- | ---: | ---: | ---: |
| p70 flight | 4 | 1.64 | 482 × 429 | [236, 369), 122 | 90 | 423 | 16/20 |
| p70 action | 1 | 1.855 | 622 × 405 | [354, 473), 121 | 90 | 371 | 11/20 |
| p55 flight | 1 | 1.59 | 513 × 395 | [255, 389), 93 | 77 | 391 | 16/20 |
| p55 action | 1 | 1.36 | 449 × 310 | [268, 365), 95 | 77 | 282 | 13/20 |

Dent's packed profile hover heads measure 90 and 77 px respectively. At
32 px/m the front and rear views show two raised arms with a single trailing
ribbon. In profile the near blade and elbow overlap the far arm. Kerf's long
ribbon leaves him with a smaller on-screen helmet than Dent at equal hover height.

`ronin/cut.json` keys each atlas by its master sheet name. Pose and facing are
zero-based. Both slot centroids and the alpha-weighted centre are measured
relative to the top left of the cell in atlas pixels. The left-to-right slot
list contains the visible cores, including partially exposed lamps. An
occluded panel has an empty list. All four straight-toward and straight-away
flight hovers have three detected slots.

## Overhead parts

Take 1 of 1 ships. The wedge points down the page, the arm has a disc at each
end, the blade sweeps up from its elbow and the two tails retain punched holes.
All six parts share a scale of 165 / 201 from the tight head width, matching
Dent's 165 px overhead head. Shoulder, elbow and tail-root pivots lie on the
drawn joints and flat cuts. The 406 × 304 torso has three back slots. Their
pixel centres in page order are (180.92, 70.79), (204.74, 70.70) and
(228.45, 70.47). Its alpha-weighted centre is (202.22, 131.24).

## Rebuilding the proof boards

Run from the worktree root with Pillow, NumPy and OpenCV installed.

```powershell
py -3 -I tools/art/kerf_n21_cut.py C:/Users/kazda/kiro/gtai-masters/n21/kerf
```

The cutter floods magenta from the borders and grid gutters, recovers coverage
at the ink edge with Dent's matte, and assigns detached wisps to the nearest
silhouette. It writes tight cells to the archive's `cut/<master>/` folder,
then runs `ghost_pack.py` with the scales above. Reviewed sample positions
identify the visible lamps. The script finds the connected bright core of each
one on the packed texture and measures its centroid. Two shaded action panels
have lower colour thresholds to recover the lamp ends.

- `body_contact_sheet.png` shows the concept, all four packed sheets in master
  reading order and the six overhead parts on asphalt grey.
- `body_scale_32ppm.png` shows a p70 patrol cop, Kerf and Dent facing toward,
  profile and away at 1× and again at 3× nearest-neighbour. The Kerf factors
  are 86.4 / 423 at p70 and 86.4 / 391 at p55. Dent uses 86.4 / 223 and
  86.4 / 212. The patrol card uses its game cell width of 1.15 m × 32 px/m.
- `body_slots.png` marks the detected centroids on the four front and rear
  hovers and the overhead torso at 2×.
