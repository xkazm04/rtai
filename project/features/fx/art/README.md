# features/fx/art: D4 FX sprite atlas (night lane d4-production)

`fx_atlas.png`: 2048 x 1024, **8 columns x 4 rows of 256 px cells**, ink-on-paper effects (flat paper and ink,
hatching, no glow), seen straight down. One uniform scale across the sheet (a 192 px window of the Codex sheet
per cell), so the frames of one animation keep their relative sizes; each sprite is centred in its cell.
At 80 px/m a cell spans 3.2 m; the FX system scales per effect. Muzzle flashes and the tracer point to **+x**.
Vermilion only in the muzzle flash cores and the explosion (danger); no teal. Masters: `art_src/d4.manifest.json#d4n_fx` (+ `#d4n_casing` for the casing cell).

| Row | Cells 0-7 |
|---|---|
| 0 | `muzzle_1` (short 4-point), `muzzle_2` (long narrow), `muzzle_3` (shotgun fan), `tracer`, `impact_1`, `impact_2`, `debris_1` (concrete), `debris_2` (metal); both with a round 3.5 px ink outline so the chips read on the asphalt |
| 1 | `expl_1` .. `expl_8`: one explosion, 8 frames, left to right |
| 2 | `smoke_1` .. `smoke_4` (sizes/shapes), `shock_1` .. `shock_4` (electroshock crackle, 4 frames; bolts re-inked bold: cream grown 4 px + a 4.5 px round ink outline, so they read at 1.6 m per cell at 32 px/m) |
| 3 | `splat_1` .. `splat_4` (ink blood splat burst, 4 frames, a round 11 px cream sticker rim so it reads on charcoal: thinner rims vanish at the FX table size, 1.8 m per cell, under the look_d4 edge ink), `spark_1`, `spark_2` (strokes re-inked bold: cream grown 3 px + a 3.5 px ink outline), `casing` (a spent casing lying flat, nose +x; **own scale**: 160 x 64 px drawn at the cell centre, about 2 m at the cell's 3.2 m, so draw it at about 0.15 of a cell), `flash_ring` (shockwave ring) |

UV of cell (c, r): `Rect2(c * 256, r * 256, 256, 256)` in pixels, `Rect2(c / 8.0, r / 4.0, 1 / 8.0, 1 / 4.0)` normalised.

In-engine check (night iteration 4): the visual-engine FX system (`n-visual`, `data/tables/fx.json` reads this
atlas) was rendered with this sheet in a scratch worktree (`dev/selftest/fx_showcase.tscn`, 32 / 48 / 64 px/m):
`masters:night/d4-production/fx_engine_before` (their analytic placeholders) | `fx_engine_after` (this atlas) |
`fx_engine_rim11` (the thicker splat rim). The explosion, debris, impact, smoke, crackle and muzzle all read; the
cell layout matches their `atlas` blocks.

## `fx_fire.png`: fire seen from above (night iteration 6)

1024 x 512, **4 columns x 2 rows of 256 px cells, 2.5 m per cell** (102.4 px/m), one scale for every cell; each
sprite is centred on its alpha centroid, so the loop registers. A fire seen straight down is a ragged blob: a cream
core, flat vermilion tongues licking OUTWARD, an ink rim, soot curls. It never rises up the screen (quest 1's
placeholder drew side-view flame tongues, a camera break). Vermilion = danger. Master: `art_src/d4.manifest.json#d4n_fire`.

| Row | Cells |
|---|---|
| 0 | `fire_1` .. `fire_4`: one flicker loop (about 5 ticks per frame; offset the phase per instance) |
| 1 | `embers_1`, `embers_2` (alternate about every 8 ticks), `fire_wide` (cells 2-3, 5 x 2.5 m: a fire along a row of crates or a car) |

Quest 1 uses it for the burning TUCK-IN stack (`fx_view._fire()`): `fire_wide` at 2x over the stack + three loop
fires at 1.3x, and the smoke above it from `fx_atlas.png` row 2 cells 0-3 (fading as it lifts); see `features/quest/art/collect_call/README.md` and the lane masters' `q1_view_art.patch`.
