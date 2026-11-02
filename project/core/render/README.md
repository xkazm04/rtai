# core/render

The visual engine's data-driven core. Render only: nothing here reads sim state it could change,
draws an RNG stream, or reads a frame delta.

## The render layer stack (`render_layers.gd`, `data/tables/render_layers.json`)

A 90-degree top-down city has no depth buffer for its 2D art, so draw order *is* the height
model. The stack is declared once as data, bottom up. A **canvas** is a Godot `CanvasLayer`
(its `layer` is its draw order); a **layer** is a z band inside a canvas.

| canvas (layer) | print pass | layer bands (z) | drawn by |
|---|---|---|---|
| `world` (0, camera space) | read by `look_d4` | `ground` 0, `ground_decals` 1, `building_shadows` 2, `props` 3, `roofs` 4 | `ChunkView` (one canvas item per band per 64 m quadrant) |
| `print` (1, screen) | is the pass | `print_pass` 0 | `CityView` look rect |
| `actors` (2, follows the camera) | `look_d4_item` | `actor_shadows` 0, `actors` 100, `vehicles` 200, `roof_occluders` 300 (reserved), `fx` 400 | `CrowdLayers`, `CharacterRigs`, the FX system |
| `light` (3, follows) | none (additive) | `lights` 0 (reserved) | the 2D light layer |
| `world_ui` (4, follows) | none | `world_markers` 0 (reserved) | markers, the objective pointer |
| `hud` (10, screen) | none | `hud` 0 (reserved) | `features/hud` |

Rules:

- **Ask, never hard-code.** `RenderLayers.canvas(&"actors")` for a `CanvasLayer.layer`,
  `RenderLayers.z(&"vehicles")` for a `z_index`. A new kind of thing gets a row in the table first.
- **A top-level item sits exactly on its band.** Its children are relative to it
  (`z_as_relative`) and stay within `BAND_SPAN` (100) steps, so a rig's arm (z +8) never climbs
  into the vehicles band.
- **Print follows the canvas.** Anything on `world` is printed by the full-screen `look_d4` pass
  (hatching, wash steps, Sobel ink). Anything on `actors` is printed per node by `look_d4_item`
  (nearest-ink snap). Roofs print with the world today; a roof that must cover actors goes on
  `roof_occluders` and prints as an item.
- **Order inside a band** is tree order (the crowd's `DRAW_ORDER`: car shadows, people shadows).
- `RenderLayers.audit(root)` lists every node not on a declared layer; `tests/unit/test_render_layers.gd`
  builds the real city scene (World + CitySystem + CityView + characters) and asserts it is clean.

Changes this made to the picture (2026-11-02, frames in `gtai-masters/night/visual-engine/01-layers`):
moving cars now draw **above** people (they were below), the full rigs draw in the people band
(they were under the MultiMesh crowd and the cars), and decals draw under building shadows,
which draw under props, which draw under roofs (the chunk overlay used to draw them in list order).

## Look profiles (`look_profiles.gd`, `look_params.gd`, `data/tables/look_profiles.json`)

Every print-pass parameter lives in one table, one row per art direction:

- `world`: every `look_d4.gdshader` uniform except `world_px` (ink steps, wash strengths, line and
  edge thresholds, hatch onset and pen period, grime, grit, the vermilion / teal plates and their
  misregistration shifts);
- `item`: the `look_d4_item.gdshader` uniforms (`shadow_k`, `steel_out`);
- `parts_flat_below`: the cutout part print's flat-sticker threshold (`PartMaterials.set_flat_below`).

| id | what |
|---|---|
| `d4` | Ink and Hatch, the target (the F-08 + f08b tuning, unchanged) |
| `d5` | Inked Grime, for up close: more grime and grit, more hatching at a wider pen, lower edge thresholds, stronger misregistration. Placeholder values until the d5-close lane delivers |
| `d1` | Riso Refined approximated on the D4 pass (flat fills, no grime, no misregistration, almost no hatching). The riso dot screen itself is not ported |
| `auto` (default) | the zoom blend: `d4` up to 48 px/m, smoothstep to `d5` at 64 px/m and above |
| `off` | the raw art, no print pass |

`CityView.look_id` picks one (`-- --look=<id>` at boot); every frame `_update_look()` resolves it at
the current px/m and pushes uniforms only when the result changed (a held zoom costs one dictionary
compare). A new direction is a new row; a new shader parameter is a new key in every row (the schema
requires all of them).

**Golden frames** (`dev/selftest/look_golden.gd`, part of `node tools/selftest/run.mjs` and so of the
`selftest` evidence): the selftest junction (seed 91) under `--fixed-fps 60`, so each frame is one
sim tick and the picture is deterministic; `d1` at 32/48, `d4` at 32/48/64, `d5` at 48/64, `auto` at
48/56/64, downscaled to 320x200 and diffed against `tests/golden/look/` (`.gdignore`d, so Godot does
not import them). Pass: mean abs diff <= 4/255 and <= 2 % of pixels off by more than 48/255. Two runs
on the RTX 4090 / d3d12 were bit-identical. Re-bless after an intended look change with
`godot --fixed-fps 60 --path project res://dev/selftest/look_golden.tscn -- --out=<dir> --bless`
and put the before/after frames in the commit message's evidence.
