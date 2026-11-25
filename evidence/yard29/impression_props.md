# impression-props (n29-08b, session 3 short call)

Cause: `PrologueYardOverprint._draw_pieces` lays the i55 impression (`ffffff8c`, rect y -1.1..34) over the world pass. The world pass prints the wrecks not named in `arched_line.over_print` (burnt_pickup, press_carcass, fallen_fridges, scrap_skip) under it, and the south fence (Rect2 y = yard end - 0.65, about 33.35..34) sits inside the rect.

Data fix (table only, no code): `over_print` gained `burnt_pickup`, `press_carcass`, `fallen_fridges`, `scrap_skip` (they draw over the impression in their own colours and are skipped in the world pass, so no double draw); `ground_impression.rect_m.size` y 35.1 -> 34.4 (ends 33.3, north of the fence at 33.35). Pin: `test_arched_line_lays_the_brown_tile_as_a_second_impression_and_raised_line_does_not`.

Not reachable by data: ground decals (stains, tyre marks, bay lines) printed in the world pass stay under the impression. Finding for a later call: they need the impression drawn BEFORE the decals (a code change in `prologue_floor.gd`/`prologue_yard_overprint.gd` order) or a lower tint.

After still: `evidence/yard29/impression_props_after_mid_32ppm.png` (seed 7, tick 300, mid camera). Seen: the skip, fridges and press carcass, the forklift and the south fence and gate read crisp in their own colours; tyre marks and bay lines are still soft (decals). No contrast table, pilots, before still, film: next session.

## Contrast table and pilots (n29-10, session 3, `impression-evidence`)
Pilots: `evidence/yard29/prologue-yard-pilots-props.json` (commit `f82ec8cac`, HEAD `7872773ed`, seeds 7, 3, 11, 21, 42 in one Godot process): ticks, deaths, min_hp, stuck and sha256 IDENTICAL to `prologue-yard-pilots-hall2.json` for all five (11701 / 11958 / 10392 / 12158 / 13278 ticks; deaths 0 / 1 / 0 / 0 / 1). Over-print is visual only.

Contrast at 32 px/m, mid camera (south fence: gate camera), tick 300, seed 7: mean |prop - floor ring| luminance (Rec.709 linear light), measured by `evidence/yard29/prop_contrast.py` (how the boxes are placed is in its docstring: row `at`/`size_m` projected with the yard_film camera, prop = art alpha pixels, ring = 1 m round the box minus the other placed pieces). Three looks: i20 = `c649a15d6`'s `arched_line`, before = `8b2ada27e`'s, after = HEAD (`b17d4a741`, span order landed). The two "before" rows were swapped into the `arched_line` row for the render (the yard_film `LOOKS` list takes no temp id) and the table restored byte for byte (`git diff` empty).

| prop | i20 | before (8b2ada27e) | after (HEAD) | after / i20 | before / i20 |
|---|---|---|---|---|---|
| forklift (burnt_pickup) | 0.1544 | 0.0914 | 0.0851 | 55 % | 59 % |
| scrap_skip | 0.2257 | 0.1302 | 0.1050 | 47 % | 58 % |
| fallen_fridges | 0.1451 | 0.1108 | 0.0426 | 29 % | 76 % |
| south fence | 0.0776 | 0.0477 | 0.0877 | 113 % | 62 % |

Verdict: the bar (each prop within 10 % of its i20 contrast) is met only by the south fence (113 %, it is crisp and dark again where the impression had hazed it to 62 %). The three wrecks are NOT within 10 %: 55, 47, 29 %. Reason, from the stills: the i20 wrecks were drawn in the world pass under the dusk grade, dark burnt brown (prop mean 0.074 / 0.081 / 0.053 against a ring of 0.23 / 0.31 / 0.20). Now they draw over the impression in their own colours: yellow forklift, white-grey scrap and fridge bank, mean 0.145 / 0.170 / 0.161. They are crisp and saturated (hue and chroma contrast up, see the stills) but their luminance sits nearer the lit floor, so the luminance metric says "less contrast than i20". The "before" haze and the "after" brightness are different failures: before the wrecks were washed toward the floor tint, after they are lifted by their own paint. The fridge bank is the worst (a pale bank on a pale ring, 0.0426). Not fixed here (the i55 tint was the owner's pick, lowering it is rejected; a grade on the over-print layer is a code change outside this call); decision for the owner: accept the own-colour wrecks, or give `over_print` props the dusk grade.

## Owner's alternative: `over_print_shade` (n29-13b, `overprint-shade`)
Code landed in `785d96bc9`: optional row key `over_print_shade` (0..1, absent = 1) multiplies the own-colour wrecks on the over-print layer (ground wrecks only; spans, debris and the ochre impression are untouched). No committed row carries it. No-change proof: mid still, 32 px/m, tick 300, `arched_line`, HEAD code vs the new code, key absent: max channel difference 0 (identical 1920x1080).

Contrast with a TEMPORARY key in `arched_line` (same method as above, mid camera, 32 px/m, tick 300; the table restored byte for byte, `git diff` empty), HEAD table rows:

| prop | i20 | today (1.0) | shade 0.6 | 0.6 / i20 | shade 0.5 | 0.5 / i20 |
|---|---|---|---|---|---|---|
| forklift (burnt_pickup) | 0.1544 | 0.0851 (55 %) | 0.1588 | 103 % | 0.1705 | 110 % |
| scrap_skip | 0.2257 | 0.1050 (47 %) | 0.1965 | 87 % | 0.2117 | 94 % |
| fallen_fridges | 0.1451 | 0.0426 (29 %) | 0.1320 | 91 % | 0.1446 | 100 % |

0.6 misses the 10 % bar on the skip (87 %); 0.5 puts all three within 10 % (110 / 94 / 100 %), the forklift at the edge. To adopt it the owner adds `"over_print_shade": 0.5` to `arched_line` (a tuned value between 0.5 and 0.6, e.g. 0.55, is one more still). Stills: `evidence/yard29/impression_props_shade_mid_32ppm.png` (today | shade 0.6, full frame) and `evidence/yard29/impression_props_shade_fridges_64ppm.png` (front camera 64 px/m, crop of the fridge bank and the belt, today | 0.6): the white fridge bank goes from pale-on-pale to a grey, readable bank with the same linework, the belt spans above stay as bright as before.
