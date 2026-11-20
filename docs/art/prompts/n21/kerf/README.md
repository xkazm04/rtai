# Kerf · Swarf Ronin

The built-in image generator produced seven 1536 × 1024 masters. The six overhead
parts ship from top take 1. All three takes of each 70° sheet failed the blade
direction review. The 55° pair depended on acceptance of both 70° sheets.
Its two prompt files contain the prepared text and have no submissions.

The archive is `C:/Users/kazda/kiro/gtai-masters/n21/kerf/`. Raw takes live in
`masters/<sheet>_take<N>.png`. The manifest records their SHA-256 hashes.

## References in input order

The archive's `masters/refs/` directory contains byte copies of these six originals.

| Sheet | Image 1 · character | Image 2 · style and layout | Image 3 · camera |
| --- | --- | --- | --- |
| Flight and action, 70° | R1 | R2 | R3 |
| Flight and action, 55° (prepared) | R1 | R4 | R5 |
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
| 1 | The front hover hangs both blade tips beside the ribbon. The inner blade in the front turn also drops. |
| 2 | The hover repeats the downward crescents across the row. In the front cruise the cutters sit on either side of the helmet. |
| 3 | The torso, slit lens and divided back panel read clearly, but both front hover tips hang well below the chest. Selected for the scale proof. |

The proof atlas packs take 3 using `ghost_pack.py --k=1.8`. Each cell is
579 × 420 px. The widest continuous helmet section at the selected horizontal
scanline spans 91 px at alpha ≥ 128. The scan covers x = [313, 434) at cell
y = 71 in profile hover. Dent measures 90 px. The five Kerf hover figures have
a median alpha-bounds height of 416 px. Twelve of 20 proof cells contain three
detected slot cores. At 32 px/m the lens, shoulders and ribbon remain legible.
The blade tips hang below both elbows even at that size.

## Action at 70°

| Take | Visual review |
| --- | --- |
| 1 | The profile cut extends along the facing, but the front blink spreads its blades sideways and tips them toward the bottom of the picture. |
| 2 | The side blink trails the blades along the body. The front blink keeps the downward-facing open crescent silhouette. Selected for the action proof. |
| 3 | The front blink folds the arms closer, with their tips converging down around the tail. The side cut also hooks downward at its end. |

Take 2 packs with `--k=1.8` into 671 × 431 px cells. The profile cock scan spans
89 px at alpha ≥ 128, x = [395, 499) at cell y = 129. Twelve of 20 proof cells
contain three detected slot cores. Both proof atlases use a forced scale.

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

The cutter floods the connected magenta background from the borders and grid
gutters and recovers teal coverage at the ink edge with Dent's matte. It assigns
detached wisps to the nearest silhouette. The packed trial atlases and their
cell-relative measurements go to `cut/` in the archive. They use Dent's four
pose columns, five facing rows, horizontal alpha-mass seating and bottom pad.
The board transposes them to the original reading order. Slot centres come
from bright, connected pixels within reviewed chest and back panel windows.

- `body_contact_sheet.png` compares the plate, both rejected 70° trials and
  all six shipped parts on asphalt grey.
- `body_scale_32ppm.png` shows a p70 patrol cop, Kerf and Dent facing toward,
  profile and away at 1× and 3× nearest-neighbour. Kerf uses 86.4 / 416 game
  pixels per atlas pixel. Dent uses 86.4 / 223 at p70 and 86.4 / 212 at p55.
  The standing patrol card uses its game cell width of 1.15 m × 32 px/m.
  The empty Kerf positions on the p55 row mark the pending generation.
- `body_slots.png` marks the connected-component centroids on the two trial
  hovers and the shipped torso at 2×.
