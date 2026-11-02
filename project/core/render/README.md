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

## The colour doctrine (`palette_tokens.gd`, `data/tables/palette.json`)

Base tokens (`paper` #F2E8D5, `paper_2`, `ink` #17131B, `ink_2` charcoal, `wash`, `steel`) and the two
accent inks: **vermilion** #E8502A (threat, cop, danger cue, pickup, objective, Rivet's collar, hit
flash) and **teal** #1FB5A8 (souls, the dead, the torch tip). Each accent lists the render layers it may
appear on: never `world` (ground, decals, shadows, props, roofs); a pickup or hazard in the world is
drawn on `fx` or `world_markers`. `classify()` uses the look_d4 plate gates, so "is this pixel an
accent" means exactly what the print pass means by it.

`dev/selftest/accent_audit.gd` (in the `selftest` evidence via `tools/selftest/run.mjs`, reported but not
gating) renders the junction at 32 / 48 / 64 px/m, pauses the tree and captures once per hidden layer:
`world` is absolute (the actors canvas hidden), the actor bands are what hiding them removes. Any accent
on a layer the table does not allow is listed as an offender. First run (2026-11-02): 0.95 % of the
frame vermilion at 32 and 48 px/m (all of it actors: the cops), 0.26 % at 64; one offender, 216 px of
vermilion on `world` at 32 px/m = the red lamps of `props/traffic_light.png` (an asset for d4-production).

## The 2D light model (`light_layer.gd`, `light_pool.gd`, `light_ink.gdshader`, `data/tables/lights.json`)

The `light` canvas (screen space, above the actors, below the world UI) holds two bands:

- `grade` (z 0): a full-screen multiply rect, the time-of-day grade. `day` is white (a no-op, the D4
  baseline); `night` (#6E6878) pushes the whole print toward the charcoal for later acts.
- `lights` (z 100): one MultiMesh of additive quads, `max_lights` (32) per frame. `light_ink.gdshader`
  cuts each light's radial (or cone) falloff into `steps` flat bands and draws every band edge as
  world-locked 45-degree pen hatching, so a light prints as a drawn patch of paper (or vermilion for
  danger: the blast's rim, fire, the siren) over the charcoal, never a soft 3D bloom. The first version
  used a random 2 px stipple; it read as a halftone glow and was replaced (frames `04-lights` vs
  `04b-lights-hatch` in `gtai-masters/night/visual-engine`).

Kinds: `muzzle_flash` (paper fan, 4 ticks), `explosion` (paper core, vermilion rim, 36 ticks),
`headlight` (paper cone, held), `siren` (vermilion / paper strobe at 2.5 Hz, held: red and blue are
off-doctrine and teal is the dead's), `fire` (vermilion flicker, held). Lights live on the 60 Hz tick:
`add(kind, pos_px, angle, tick)`, `move()`, `remove()`, and `CityView` calls `step(tick, world_px)` every
frame. When the budget is full a timed light evicts the oldest timed light; a held light is refused
(`dropped` counts both). Nothing emits lights from gameplay yet: there are no positional shot /
explosion events in the F-04 registry; `dev/selftest/light_showcase.gd` places the demo set.

Cost (`light_showcase.gd` -> `light-cost.json`, 48 px/m): CPU `step()` 70-168 us for 32-64 lights
(GDScript loop). GPU: **not reliably measured** - four runs gave deltas of +1.32, +0.05, +0.09 and
-0.87 ms because another lane was rendering on the same GPU. Re-measure on an idle GPU (and the Deck)
before raising `max_lights`; fill rate is the risk (each fire is a 336 px quad at 48 px/m).
