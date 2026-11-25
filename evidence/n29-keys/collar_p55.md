# collar p55 rows (n29-04c): one row per image job

Brief `evidence/briefs/n29-04c-collar-rows-live.md`. Sheet `project/features/characters/art/view/p55/rivet_run8.png`
(8 facing rows x 8 cells). Round `C:/Users/kazda/kiro/gtai-art/rivet-n29/collar_p55_rows/` (STATE.md, scripts/).

IMAGES 5 returned (row3, row4, row3_b, row7 late, row6 relaunched); 6 jobs launched (the first row6 job returned nothing in 15 min).

Method: per row, image 1 = the row's 8 cells at 1.0 in 4x2 slots (384x512) on a 1536x1024 #00B140 key, image 2 = the p70
run row of the same facing, image 3 = a rigid p55 row 1 neck crop (nearest). The returned image is keyed, each cell
registered to the shipped cell by alpha IoU (shift +-8 px, scale 0.98-1.02), and only the neck band is pasted back: mask =
shipped orange + edited orange hulls, filled, dilated, feathered (sigma 1.2), only where the shipped alpha is non-zero; the
shipped alpha is kept (`scripts/comp_row.py`).

| Row | Facing | Result |
|---|---|---|
| 3 | right profile | FAILED: edit 1 kept the bulky twisted rope; retry (stronger prompt) muddier, stripes lost. Stays shipped. |
| 4 | back three-quarter | FIXED: a flat ring, straight vermilion/black diagonal stripes, dark outlined edges; shift 0, scale 1.0 in all 8 cells; collar orange 227,92,31 vs rigid rows 1/2/5 225-230,99-112,27-39 |
| 6 | left three-quarter | FAILED (03:42): still a rounded rope tube, no flat outlined ring. Stays shipped. |
| 7 | left profile | FAILED (03:42): stripes went greenish (teal tint), still rope-like. Stays shipped. |
| 8 | back-left three-quarter | FAILED (n29-04d, 2 images): edit 1 (jobs.json `row8`) turned the band into a knitted, textured red-orange scarf, stripes lost; retry (`row8_b`, image 3 = the committed rigid row 4 mirrored, same facing; prompt bans knit/weave/texture) gave bold orange/near-black stripes with a dark outline, but curved crescent stripes wrapping a rounded tube, the twisted rope again. Both composites proved 0 px changed outside the masks, alpha identical; neither installed. Stays shipped. |

Rows 1, 2, 5 were already rigid (n28 audit).

## Identity proof (row 4, `collar_p55_row4_proof.json`)
Shipped vs committed sheet: 29057 pixels changed, **0 changed outside the neck masks**, alpha identical over the whole sheet;
rows 1-3 and 5-8 bit-identical.

## Drift
Not re-measured in game this call (time). By construction unchanged: the alpha channel (silhouette, soles) is identical and
every changed pixel is inside the neck masks, so the planted-boot positions the n27 harness reads cannot move
(`evidence/n27-keys/p55_sprint_drift.md`, 3.83 cm at 64). The re-measure and the in-game before | after are in the round
STATE `Next`.

## Stills
`C:/Users/kazda/kiro/gtai-masters/n29/keys/collar/`: `collar_p55_row4_neck_3x.png` (shipped above, new below),
`collar_p55_row4_1x.png`, `collar_p55_row4_judge_4x.png`, `collar_p55_row3_rejected_3x.png`, `collar_p55_row3b_rejected_3x.png`, `collar_p55_row6_rejected_3x.png`, `collar_p55_row7_rejected_3x.png`.

## Row 8 (n29-04d, brief `evidence/briefs/n29-04d-collar-row8-live.md`)
IMAGES 2 (row8 04:55, row8_b 04:57; both returned in about 1 min). Composites `comp8/r8.png` (7155 px changed, 0 outside the masks) and `comp8/r8b.png` (7818 px changed, 0 outside the masks, shift 0/-1, scale 1.0-1.01, IoU 0.971-0.979), both alpha identical, in the round dir; rejected on the 4x/6x crops against rows 1, 2, 4, 5, so `p55/rivet_run8.png` is unchanged (sha256 faa5a151...). Stills: `collar_p55_row8_rejected_3x.png`, `collar_p55_row8b_rejected_3x.png`, `collar_p55_row8b_vs_row4_mirrored_6x.png` (top: the committed rigid row 4 mirrored, middle: the shipped row 8, bottom: the retry), `collar_p55_row8b_judge_4x.png`. Rows 3, 6, 7, 8 have each failed two image edits; the round STATE `Next` names a hand repaint (row 4 mirrored as the pattern, along the shipped collar centreline) as the remaining route.
