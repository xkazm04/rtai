# features/fx/art: D4 FX sprite atlas (night lane d4-production)

`fx_atlas.png`: 2048 x 1024, **8 columns x 4 rows of 256 px cells**, ink-on-paper effects (flat paper and ink,
hatching, no glow), seen straight down. One uniform scale across the sheet (a 192 px window of the Codex sheet
per cell), so the frames of one animation keep their relative sizes; each sprite is centred in its cell.
At 80 px/m a cell spans 3.2 m; the FX system scales per effect. Muzzle flashes and the tracer point to **+x**.
Vermilion only in the muzzle flash cores and the explosion (danger); no teal. Master: `art_src/d4.manifest.json#d4n_fx`.

| Row | Cells 0-7 |
|---|---|
| 0 | `muzzle_1` (short 4-point), `muzzle_2` (long narrow), `muzzle_3` (shotgun fan), `tracer`, `impact_1`, `impact_2`, `debris_1` (concrete), `debris_2` (metal) |
| 1 | `expl_1` .. `expl_8`: one explosion, 8 frames, left to right |
| 2 | `smoke_1` .. `smoke_4` (sizes/shapes), `shock_1` .. `shock_4` (electroshock crackle, 4 frames) |
| 3 | `splat_1` .. `splat_4` (ink blood splat burst, 4 frames, cream sticker rim so it reads on charcoal), `spark_1`, `spark_2`, *(empty: the casing was rejected, a camera break)*, `flash_ring` (shockwave ring) |

UV of cell (c, r): `Rect2(c * 256, r * 256, 256, 256)` in pixels, `Rect2(c / 8.0, r / 4.0, 1 / 8.0, 1 / 4.0)` normalised.
