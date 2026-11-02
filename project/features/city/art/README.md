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
- **Colour doctrine:** the world is ink, wash and paper. Vermilion only on the signal lamps, the explosive barrels,
  the barricade, the police barrier and the cone. No teal.
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
