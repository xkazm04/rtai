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
