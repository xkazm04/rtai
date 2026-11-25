# p55 sprint collar per cell at 2x: row 3 cell 1 (n30-01)

Brief `evidence/briefs/n30-01-collar-cell-r3c1.md`. Sheet `project/features/characters/art/view/p55/rivet_run8.png`
(8 x 8 cells of 209 x 199 px, rows 1-based). Round `C:/Users/kazda/kiro/gtai-art/rivet-n30/collar_cells/` (`STATE.md`,
`jobs.json`, `refs/`, `out/`, `comp/`, `scripts/`). **IMAGES 1** (one job, no retry). Result: **row 3 cell 1 rigid,
installed** in `bf7b78fd6`.

## Method
- `scripts/cell_job.py <row> <col>`: the target cell at 2x **NEAREST** (exact pixel doubling, so 0.5 BOX undoes it)
  centred on a 1024 x 1024 `#00B140` canvas (offset 303, 313 in `refs/r3c1_2x.json`), row 4's cell of the same column
  (same gait phase) on the same canvas as image two, a 4x NEAREST crop of row 4's collar as image three; appends the job
  to `jobs.json`. The prompt names the fault (twisted rope / knitted scarf / rounded tube / crescent stripes), asks for
  image two's ring width at this scale, a crisp dark outline on straight top and bottom edges, straight parallel diagonal
  vermilion/near-black stripes, flat shading, every other pixel unchanged, no yellow/red/teal/green.
- `scripts/cell_comp.py <row> <col> <raw> <base> <out>`: key the green; place the raw on the job canvas by the best
  alpha IoU of identity / stretch / centre crop / bbox fit (the job came back **1254 x 1254**, not 1024: bbox fit, IoU
  0.983); cut the 2x cell, 0.5 BOX; register to the shipped cell by alpha IoU (shift +-6, scale 0.97-1.03), then
  +-2 px by seam cost as n29 `tp_comp.py`; mask = shipped rope hull | edited collar hull, filled, clipped to the
  shipped alpha; edited RGB inside the mask (alpha > 128, teal-cast px left as shipped); alpha kept. Writes the sheet,
  `<out>.json` proof, `<out>.cell.png`, `<out>.judge4x.png`. Self-test on the 2x ref itself: 7 edge px change, 0 outside
  the mask.

## Proof (`comp/r3c1.png.json`)
Alpha IoU 0.990, scale 1.0, alpha shift (0, 0), seam shift (0, 0), seam 25.2 (n29 row 8 transplant: 37-55), holes 0,
over head 6 px. Mask 520 px, all 520 edited (none kept as shipped). **Changed 520 px, changed outside the mask 0, alpha
identical, the other 63 cells bit-identical, teal in mask 0**; changes in y 87-114 of the cell (soles untouched).
Mask colours: orange median 247, 87, 4 (row 4 band 227-241, 85-92, 12-31: about 6 redder, 8 less blue), dark median
17, 3, 2 (row 4 band 19-36, 5-16, 3-12: slightly darker). Sheet sha256 `d8aa151a271e40f9e79b5df29f453e5c1914726d6f47ebd156b3d864050c599a`;
Godot `--import` reimported it, the `.import` did not change.

## What I saw
- 4x (`C:/Users/kazda/kiro/gtai-masters/n30/keys/collar/r3c1_4x.png`, shipped | candidate | row 4 cell 1): the soft
  orange rope with faint curved stripes is now a flat ring of constant width, dark outline on straight top and bottom
  edges, five straight parallel vermilion/near-black diagonal stripes: the same read as row 4. Helmet, visor, hose arm and
  fist untouched; no seam at either end. Minor at 8x only: under the ring's left end the old rope area is filled with the
  edit's muted shoulder tone, and the ring's right end keeps the rope's slight downward angle.
- 64 px/m (`C:/Users/kazda/kiro/gtai-masters/n30/keys/collar/r3c1_64_ingame.png`, before | after, 2x crop + 4x neck):
  `evidence/n29-keys/films/run_hands.py` runs `runs/r3c1_before_64` (HEAD `5114a4441`) and `runs/r3c1_after_64`. The
  harness shows sheet row 3 (0-based 2) at tick 88 (walk beat 0 at 6.75 m/s, **column 1**, the run8 sheet) and tick 1048
  (sprint beat 8 at 9.3 m/s, **column 5**, unchanged). Frame diff (threshold 8) over all 16 ticks: only tick 88 differs,
  653 px in x 917-978, y 437-463 (the neck); the other 15 ticks 0 px, so the import was fresh. The still is tick 88:
  after reads as a stiff striped collar, before as the soft scarf.

## Not done
Drift not re-measured (alpha identical, changes in y 87-114, so the sole band the n27 measure reads cannot move). The
other 25 cells (row 3 c2-c8, rows 6 and 7) are the round STATE `NEXT`.

## Commits
`bf7b78fd6` sheet + provenance line (`steam/ai-provenance/2026-11.jsonl`); hook lint 18 checks passed;
`node tools/gate/quick.mjs`: no changed .gd, no merge clash with n30-cast/combat/yard.

# n30-04: rows 3, 7, 6 by the same per-cell 2x route

Brief `evidence/briefs/n30-04-collar-cells.md`. Same round dir and scripts as above. **IMAGES 30** (the cap): 25 first
passes + 5 retries (r3c2b, r3c5b, r7c3b, r7c4b, r7c8b, r6c2b, r6c5b are the retries; r6c2/r6c5 second passes came from the
same 30). Row 8 touch-ups (cells 4 and 8) **not run**: no images left (jobs `r8c4`, `r8c8` with a touch-up prompt are ready
in `jobs.json`).

## Compositor changes (found by looking, not by the bars)
- **Visor guard.** The v1 hull (`collar_mask`) caught the visor glow as "orange", so r3c4, r7c1, r7c5, r7c6 re-rendered
  69-76 visor px (glow reshaped a little; every numeric bar still passed). `cell_comp.py` now removes the visor from the
  mask: yellow components (R > 200, G > 130, B < 90) of >= 20 px, plus >= 4 px pieces within 12 px of it and not below it
  (row 6's split visor), dilated 2 px. Proof key `visor_px_protected`. v1 kept as `scripts/cell_comp_v1.py`.
- **Row guard.** r3c5b's edited hull took a helmet crack at y 45-56 (56 px). The mask is now limited to the shipped rope
  rows +-4 (proof key `band_rows`).
- Every accepted cell was re-composited from the HEAD sheet with both guards (all bars pass again). r3c1 (shipped
  `bf7b78fd6`, v1) changes only y 87-114; its visor is y 78-84, so it was not touched.
- Bars on every accepted cell: changed outside the mask 0, alpha identical, the other 63 cells bit-identical, teal 0,
  alpha IoU 0.976-0.991. Placement stretch or bbox fit (raws 1024 or 1254 px), scale 1.0, alpha shift (0, 0).

## Row 3 (right profile), `0b1a1cd27`
| cell | raw | alpha IoU | mask px | changed (outside mask) | visor px protected | orange / dark median | verdict |
|---|---|---|---|---|---|---|---|
| 3.1 | `out/r3c1.png` | 0.99 | 520 | 520 (0) | - | [247, 87, 4] / [17, 3, 2] | shipped bf7b78fd6 (v1 compositor) |
| 3.2 | `out/r3c2b.png` | 0.988 | 531 | 531 (0) | 104 | [249, 96, 19] / [21, 8, 6] | accepted (retry; first pass arced up at the back, no end outline) |
| 3.3 | `out/r3c3.png` | 0.988 | 473 | 473 (0) | 106 | [242, 81, 5] / [20, 4, 2] | accepted |
| 3.4 | `out/r3c4.png` | 0.984 | 497 | 497 (0) | 104 | [248, 96, 18] / [21, 5, 5] | accepted |
| 3.5 | `out/r3c5b.png` | 0.986 | 513 | 513 (0) | 100 | [239, 78, 24] / [23, 5, 4] | accepted (retry; first pass still a shaded tube) |
| 3.6 | `out/r3c6.png` | 0.987 | 495 | 495 (0) | 103 | [247, 82, 7] / [16, 2, 2] | accepted |
| 3.7 | `out/r3c7.png` | 0.986 | 539 | 539 (0) | 111 | [245, 85, 7] / [22, 5, 3] | accepted |
| 3.8 | `out/r3c8.png` | 0.986 | 463 | 463 (0) | 109 | [226, 89, 13] / [21, 5, 4] | accepted |

## Row 7 (left profile), `47aed0529`
| cell | raw | alpha IoU | mask px | changed (outside mask) | visor px protected | orange / dark median | verdict |
|---|---|---|---|---|---|---|---|
| 7.1 | `out/r7c1.png` | 0.988 | 373 | 373 (0) | 85 | [248, 88, 9] / [26, 6, 6] | accepted |
| 7.2 | `out/r7c2.png` | 0.987 | 407 | 407 (0) | 85 | [240, 79, 6] / [10, 2, 1] | accepted |
| 7.3 | `out/r7c3b.png` | 0.982 | 280 | 279 (0) | 86 | [251, 73, 3] / [15, 6, 3] | KEPT SHIPPED (rope): first pass thin broken slivers, retry broken front end |
| 7.4 | `out/r7c4b.png` | 0.976 | 271 | 271 (0) | 84 | [244, 75, 11] / [20, 5, 3] | KEPT SHIPPED (rope): first pass blob on the chest, retry broken front end |
| 7.5 | `out/r7c5.png` | 0.981 | 299 | 299 (0) | 80 | [248, 79, 6] / [29, 9, 6] | accepted |
| 7.6 | `out/r7c6.png` | 0.981 | 366 | 363 (0) | 80 | [240, 75, 3] / [22, 6, 5] | accepted |
| 7.7 | `out/r7c7.png` | 0.98 | 355 | 355 (0) | 83 | [244, 100, 18] / [34, 13, 8] | accepted (front stripes a little amber: 17 px G>115, 1 px yellow) |
| 7.8 | `out/r7c8b.png` | 0.991 | 312 | 312 (0) | 91 | [248, 89, 9] / [20, 5, 3] | accepted (retry; first pass fragmented with a dark smear) |

## Row 6 (front-left three-quarter), `6ba1b9d68`
Reference row 4 of the same column throughout (r6c1 passed, so the mirrored row 2 fallback was not triggered).

| cell | raw | alpha IoU | mask px | changed (outside mask) | visor px protected | orange / dark median | verdict |
|---|---|---|---|---|---|---|---|
| 6.1 | `out/r6c1.png` | 0.985 | 396 | 396 (0) | 138 | [244, 89, 13] / [21, 3, 2] | accepted |
| 6.2 | `out/r6c2b.png` | 0.986 | 301 | 301 (0) | 123 | [251, 73, 8] / [5, 2, 1] | KEPT SHIPPED (rope): mostly dark ring + a dark bar climbing the right shoulder, twice |
| 6.3 | `out/r6c3.png` | 0.988 | 376 | 376 (0) | 116 | [240, 86, 17] / [25, 6, 3] | accepted |
| 6.4 | `out/r6c4.png` | 0.984 | 276 | 276 (0) | 123 | [248, 80, 4] / [22, 13, 13] | accepted |
| 6.5 | `out/r6c5b.png` | 0.988 | 425 | 425 (0) | 144 | [249, 86, 3] / [23, 5, 2] | accepted (retry; first pass lighter wedge + notch at the front end) |
| 6.6 | `out/r6c6.png` | 0.987 | 307 | 307 (0) | 93 | [228, 77, 5] / [31, 9, 3] | KEPT SHIPPED (rope): wedge/notch at the front end; no image left for a retry |
| 6.7 | `out/r6c7.png` | 0.984 | 367 | 367 (0) | 96 | [237, 85, 8] / [21, 4, 3] | accepted (finer stripes than row 4) |
| 6.8 | `out/r6c8.png` | 0.987 | 418 | 418 (0) | 112 | [244, 92, 31] / [17, 6, 5] | accepted |

Kept-shipped rows show the numbers of their last (rejected) composite.

## What I saw
- 4x judge per cell (`comp/r<r>c<c>.png.judge4x.png`, shipped | candidate | row 4): accepted cells are a flat ring of
  constant width, straight parallel vermilion/near-black stripes, dark outline top and bottom. In profile rows 3 and 7
  several rings follow the shipped rope's path and arc gently up at the back (constant width, not tapering: a ring seen
  slightly from above), so they are less straight than row 4's back three-quarter band. r6c7 and r6c8 have finer
  stripes than row 4. r7c7's front stripes are a little amber (17 px G > 115).
- Rejections were all at the FRONT end of the ring (under the chin / by the fist): broken slivers, wedges, notches, a dark
  bar onto the shoulder joint. That is where the rope crosses other parts and the 2x edit loses the band.
- Row contacts (4x, shipped above, new below): `C:/Users/kazda/kiro/gtai-masters/n30/keys/collar/row3_4x.png`,
  `row7_4x.png`, `row6_4x.png`. In rows 7 (c3, c4) and 6 (c2, c6) the kept rope cells will flicker against their rigid
  neighbours in the run cycle.
- In game 64 px/m (`evidence/n29-keys/films/run_hands.py`, runs under `.../collar/runs/`): row 3 = `r3_after_64` vs
  `r3c1_after_64`: only tick 1048 (row 3 c5) differs, 608 px in x 921-979 y 436-464; still `row3_64_ingame.png`.
  Rows 6+7 = `r67_after_64` vs `r3_after_64`: only ticks 568 (r7c6, 485 px), 1408 (r6c8, 601 px), 1528 (r7c8, 437 px)
  differ, all in the neck window (x 929-1002, y 436-479); tick 448 (r6c6, kept shipped) 0 px; still `row67_64_ingame.png`
  (before | after per tick). A before run from the start HEAD exists too (`runs/n3004_before_64`). Godot `--import`
  each time, the `.import` did not change; 0 SCRIPT ERROR.

## Drift
n27 setup (`build/h27/meas.py` on copies of the n27 v0.98 takes in `build/n30-04-drift/`) against the row 6 sheet
(`6ba1b9d68`): all 16 segments per zoom identical to the n27 measurements (`measurements.json` equal); p55 64 px/m sprint
profile 3.09 / 4.56, **mean 3.83 cm** (bar 3.83 +- 0.1), 32 px/m 2.31 / 3.00. Expected: alpha is identical.

## Next
Row 8 touch-ups (r8c4 notch, r8c8 streak: `python -I scripts/run_comp.sh` after `node ../../gen.mjs . r8c4,r8c8`; note the
mask is the collar hull, so the r8c8 streak right of the ring may fall outside it). Retry the kept cells r7c3, r7c4, r6c2,
r6c6 with a different reference (row 2 mirrored for row 6) or a front-end-only mask.

## n30-06 / n30-08: leftover cells and row 6 visor

Round `C:/Users/kazda/kiro/gtai-art/rivet-n30/collar_cells/` (`STATE.md`, n30-06 and n30-08 lines). n30-06 made the four leftover
cells (11 images); n30-08 installed them and fixed the visor (0 images).

### Leftover cells (commit `2641a10fe`, sheet e94deb4e)

| cell | raw | alpha IoU | mask px | changed (outside mask) | protect boxes | orange / dark median | verdict |
|---|---|---|---|---|---|---|---|
| 7.3 | `out/r7c3c.png` | 0.984 | 395 | 395 (0) | - | [248, 76, 3] / [18, 4, 2] | accepted (1st image; image two = accepted r7c2) |
| 7.4 | `out/r7c4d.png` | 0.986 | 360 | 360 (0) | 76,95,82,100 | [247, 79, 3] / [17, 3, 2] | accepted (2nd image; image two = accepted r7c3; r7c4c rejected: pale blob at the front end) |
| 6.2 | `out/r6c2d.png` | 0.983 | 432 | 432 (0) | 70,80,106,97;86,98,102,100 | [249, 77, 5] / [21, 10, 10] | accepted (2nd image; mirrored r2c2 + accepted r6c1; r6c2c rejected: brown rope left half, blob) |
| 6.6 | `out/r6c6d.png` | 0.989 | 437 | 437 (0) | 70,80,95,104 | [249, 86, 2] / [28, 7, 4] | accepted (2nd image; mirrored r2c6 + accepted r6c5; r6c6c rejected: M-shaped notch mid-ring) |
| 8.4 | `out/r8c4.png`, `out/r8c4b.png` | 0.985 / 0.981 | 522 / 505 | 520 / 504 (0) | - | - | KEPT SHIPPED: both raws keep the pink wedge / purple gap above the ring's left end (cell x ~100-107, y ~102-108, above the hull; an extra-mask trial there did not fix it) |
| 8.8 | `out/r8c8.png`, `out/r8c8b.png` | 0.983 / 0.974 | 514 / 533 (incl. extra 12) | 514 / 533 (0) | extra mask 123,89,124,94 | - | KEPT SHIPPED: the streak (cell x 123-124, y 89-94, 12 px) is outside the collar hull; with the declared extra mask both raws still paint it light (lum 145 / 139 vs 155-158) |

In game 64 px/m: `runs/n3008_after_64` vs `runs/r67_after_64`: only tick 448 (r6c6) differs, 586 px in x 941-997 y 442-470
(neck window); r6c2, r7c3, r7c4 are never shown by the harness. Still `.../collar/row67b_64_ingame.png`. n30-06's own run
`runs/n3006_after_64` is NOT valid: its `--import` did not re-import the sheet (`.godot/imported` ctex and `.md5` stayed at
11:33 with the old source md5), so it shows the old sheet (0 px diff everywhere). Re-run with a guard that aborts when the
imported `.md5` does not name the installed source (`build/n30-08/chain.sh`). `.import` unchanged, 0 SCRIPT ERROR.

### Row 6 visor (commit `68d873f9e`, sheet e39ae6e1)

Row 6's visor glow is orange, so n30-04's yellow-only visor guard missed it: the shipped r6c3, r6c5, r6c7, r6c8 had recoloured
visor glow / frame px. Re-compositing from the raws with `CELL_PROTECT` moved r6c3's and r6c8's seam-shift pick (0,0 -> 0,-1),
which redraws the whole band, so instead each cell keeps its accepted composite and takes the pre-n30 pixels inside the
declared boxes (`scripts/protect_restore.py`, proof `comp/n3008_proof.json`). Before = visor px differing from the pre-n30
sheet in the shipped cell, after = in the fixed cell.

| cell | protect boxes (cell x0,y0,x1,y1) | visor px before | after | collar px (unchanged) | band px in boxes |
|---|---|---|---|---|---|
| 6.3 | 76,83,97,103; 100,91,103,96 | 40 | 0 | 336 | 0 |
| 6.5 | 84,88,92,94 | 6 | 0 | 419 | 0 |
| 6.7 | 75,78,97,100 | 55 | 0 | 312 | 0 |
| 6.8 | 75,95,97,117; 98,104,102,111 | 39 | 0 | 379 | 0 |

140 px changed vs the shipped sheet, 0 outside the boxes, alpha identical, other cells bit-identical. 6x judge (shipped |
fixed | diff) `comp/n3008_judge_a.png`, `comp/n3008_judge_b.png`: the visor glow and frame are the original ones again, the
rings are untouched. In game: `runs/n3008b_after_64` vs `runs/n3008_after_64`: only tick 1408 (r6c8) differs, 65 px in
x 929-957 y 440-459 (visor window). Not checked: r6c6 (n30-06, protect 70,80,95,104) still differs from pre-n30 by 1 px at
x 100 y 100 next to the visor's right end.

Stills: `C:/Users/kazda/kiro/gtai-masters/n30/keys/collar/row6_4x.png`, `row7_4x.png` (pre-n30 above, final below; rows 6 and 7
are 8/8 rigid), `row67_64_ingame_final.png` (before `runs/n3004_before_64` | after `runs/n3008b_after_64`, ticks 448, 568,
1408, 1528), listed in `frames.json`.

Next: row 8 touch-ups r8c4 (notch) and r8c8 (streak) failed twice each by image edit; they need a hand fix of a few px or
another route.
