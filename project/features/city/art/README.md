# features/city/art: D4 "Ink and Hatch" world art (F-08)

One district's world art in the slice look (D4 hybrid: a hatched world, flat-wash streets). Game-ready files only;
the raw Codex sheets, prompts and the build scripts are masters (GIT-06 tier 1, see `art_src/d4.manifest.json`).
Every file has a line in `steam/ai-provenance/2026-11.jsonl`.

| Folder | What | Density | Size |
|---|---|---|---|
| `roofs/` | 10 district buildings as roofs seen from directly above (THE LAST SHIFT, helipad, HQ, OSHA, PENSION, LOCAL 9 UNION, the fist mural, the tower, the terrace row, the warehouse) | 80 px/m | 672 x 672, 1312 x 672 (the spike pack footprints) |
| `ground/` | road (3 variants), road vertical (3), kerb + pavement (3), intersection, roof edge, roof, pavement | 96 px/m | 768 x 768 = one 8 m tile |
| `props/` | 20 street props (lamp, signal, bench, bus stop, kiosk, payphone, planter, vending machine, mailbox, bin, hydrant, sign, dumpster, barrels, crates, fire escape, barricade, police barrier, cone, bollard) | 80 px/m | the spike pack sprite sizes |

- **Import:** Lossless (AST-01) with mipmaps on (AST-03: world art drawn below 1:1); the drawing node must use a
  `*_WITH_MIPMAPS` filter. Ground tiles are 768 px, so a renderer that scales tiles by texture width (as the spike's
  `district.gd` does) needs no change.
- **Road variants:** `<tile>_tone`, `_tone_b`, `_tone_c`; every variant's outer band is the same flat base wash, so
  any variant joins any other. The spike picks one per tile with `(ix + 2 * iy) mod 3`.
- **Colour doctrine:** the world is ink, wash and paper. Vermilion only on the explosive barrels, the barricade, the
  police barrier and the cone (the signal lamps are ink and paper since night iteration 4: one lit paper disc, two
  unlit ink - the accent audit flagged them). No teal.
- **lamp_post.png** (night iteration 4) is procedural, no AI pixels: the old in-line oval head read as a spoon at
  48-64 px/m; redrawn in the target's construction (dark round base, thin arm, a crook, a round paper head with a
  heavy ink ring) by `masters:night/d4-production/tools/lamp_redraw.py`, same 256 x 40 footprint.
- **Shader:** these assets are authored for `assets/shaders/look_d4.gdshader` (the tone budget). The pen work is in
  the art; the shader does not add it.

## Texel density and VRAM (input to F-13 / AST-06)

RGBA8 with mipmaps (x 4/3), one district's unique textures:

| Class | Authored | VRAM as authored | at 64 px/m | at 128 px/m |
|---|---|---|---|---|
| ground (13 tiles) | 96 px/m | 39.0 MB | 17.3 MB | 69.3 MB |
| roofs (10) | 80 px/m | 27.3 MB | 17.5 MB | 70.0 MB |
| props (20) | 80 px/m | 1.5 MB | 1.0 MB | 3.8 MB |

The Codex masters carry about 84 px/m of real detail for roofs (a 706 px roof of 8.4 m) and about 59 px/m for the
asphalt swatches (118 px/m for the 4 m pavement swatches). So the 64-96 px/m arm of F-13 is fed natively; a
128 px/m arm would be an upscale of these masters, not new detail.

## Post-processing after build_ground.py (night 2026-11-02, lane d4-production)

The shipped ground tiles are build_ground.py output **plus** these code-only passes (masters tools in
`gtai-masters/night/d4-production/tools/`, each logged per file in `steam/ai-provenance/2026-11.jsonl`). A re-bake
with build_ground.py alone undoes them; fold them in, or re-run them in this order:

| Order | Tool | Tiles | What |
|---|---|---|---|
| 1 | `paving_joints.py` | sidewalk, curb x3, curb_corner | slab joints 2 px of 140,132,128 (were a 4 px black grid) |
| 2 | `paving_calm.py` | sidewalk, curb x3 | 13 of 19 repeated crack squiggles and the dark "+" joint crosses removed |
| 3 | `lane_bold.py 6` | road_straight x3, road_straight_v x3, curb x3 | thin cream markings grown to 20 px (dashes) / 18 px (edge lines) |
| 4 | `marking_wear.py 0.006` | all road + curb + intersection | wear specks inside the paint filled, 0.6 % fine wear kept |
| 5 | `kerb_cream.py`, `kerb_ticks.py` | curb x3 | the kerb is one cream stone top (rows 288-307) with ink edges, ticks 128 grey |
| 6 | `paving_bond.py 128 286 grid2` | sidewalk (y_end 768), curb x3 | 2 m slabs: every other joint line removed, kept joints 128 grey |
| 7 | `build_corner.py` (KERB_CREAM) then 3 + 4 | curb_corner | rebuilt from the processed sidewalk so it matches the straights row for row |
| 8 | `patch_soft.py 0.5` | road_straight x3, road_straight_v x2 | closed asphalt-patch outlines 50 % toward the base (cracks keep ink) |
| 9 | `slab_grey_out.py` | sidewalk, curb_c (y_end 288) | the grey 1 m replaced-slab squares replaced by their 2 m slab partner cell |
| 10 | `paving_ink.py 64 3 [286 [286]]` | sidewalk, curb x3 (y_end 286), curb_corner (y_end, x_end 286) | the kept 2 m joints as 3 px ink 64,60,58 (a 2 px grey joint mipmaps to a pale hairline; 2 px ink breaks up at 32 px/m, 4 px prints a black window grid) |
| 10b | `paving_ink.py 64 3 --period=384` on the step-9 sidewalk (not on the step-10 one) | sidewalk (the plaza tile) | 4 m ink flags, 2 m joints stay 128 grey: the 2 m ink grid read as graph paper on wide plazas |
| 11 | `zebra_redraw.py 9 28 0.004 150` | road_intersection (after 3 + 4; run 4 again only on the old tile) | the junction zebras: old stripes removed + re-grained, 9 clean 0.29 m stripes a side (stripe ~ gap, band to 1.56 m), corners asphalt |
| 12 | `patch_clear2.py <patch_orig> <tile> <dst>` (road); `patch_clear2.py <tile> <tile> <dst> 1500 336` then `gutter_mend.py <tile> <dst> <dst> 424` (curb_b) | road_straight x3, road_straight_v x2, curb_b, curb_c | night iteration 18: the asphalt patches removed (outline, hatch, the hatched lips at the paint), filled from the tile's own asphalt; under n-visual's print they read as repeated dark boxes every 8 m. Masks come from `work/patch_orig/` (pre step 8). Supersedes step 8 on these tiles. Then `tick_mend.py` on road_straight_tone_b (`650,335,702,372,0,-160`) and road_straight_v_tone (`328,606,358,690,0,-120`): one outline tick each left beside a dash; and road_intersection (`550,445,614,500,120,-40`, then `609,465,616,475,0,-60`): an orphan hatched lip beside the zebras |

Roofs (`roofs/*.png`, all 17): `roof_lift.py 0.7 0.22 0.5` (wash greys toward the roof paper, ink kept). The flat
roof ground tiles (roof_tone, roof_edge_tone) take `flatroof_seams.py 0.6 0.35 0.50 0.58 [73]` instead (membrane
toward paper, seams toward ink; the edge tile's parapet rows 0-72 kept): a plain lift prints them as pavement.
