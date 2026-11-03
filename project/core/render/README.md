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
| `print` (1, screen) | is the pass | `print_pass` 0, `print_overlay` 100 | `CityView` look rect, `LookOverlay` |
| `actors` (2, follows the camera) | `look_d4_item` | `actor_shadows` 0, `actors` 100, `vehicles` 200, `roof_occluders` 300 (reserved), `fx` 400 | `CrowdLayers`, `CharacterRigs`, the FX system |
| `light` (3, screen) | none (additive) | `grade` 0, `lights` 100 | `LightLayer` |
| `emissive` (4, follows) | none | `fx_emissive` 0 | the FX glow twin (emissive kinds) |
| `world_ui` (5, follows) | none | `world_markers` 0 | `WorldMarkers` (markers, the objective pointer) |
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

### Selftest sites (`--site=junction|block`)

`city_selftest.gd` SITES: `junction` (the riot junction every gate grew up on) and `block` (456, 428: a
street between two built blocks - roofs, their cast shadows, kerb props, pavements). `tools/selftest/run.mjs`
runs the look goldens and the accent gate at BOTH (block: d4 32 / 48 + auto 64, goldens
`tests/golden/look/block-*.png`, results in `<out>/block/`). Why: the junction alone never saw a prop's
vermilion (the plaza barrels, 4324 px) nor a roof or its shadow. Debt rows stay junction-measured.

### Cast shadows (`cast_shadows.gd`, `data/tables/cast_shadows.json`)

The `building_shadows` band is the height cue. The generator bakes every building / prop / parked-car
shadow as the silhouette offset a short way down-right (0.25 m buildings, 0.18 m the rest, ChunkBuild.add);
ChunkView draws those commands with ONE material on that band and adds the rest of the cast distance per
texture class (`offset_m - baked_offset_m`: buildings 1.1 m, the d5-close lane's proposal), so a longer
shadow needs no re-bake. The material is `shader` (n-d5's `look_d5_shadow`) when that file is in the tree,
else `cast_shadow.gdshader` (this lane's placeholder, the same uniforms, the wobble and gaps on the grime
lattice): a light ink tint plus world-locked 45-degree pen strokes that the look_d4 print inks. Roofs sit
on the band above, so a shadow only shows where it leaves its block: a 1.1 m hatched band on the pavement
down-right of every block, like the target frame. n-d5's shader takes a `zoom` uniform above 64 px/m
(stroke spacing); not fed yet (default 1 = right at 32-64 px/m). Frames `34-buildings/`.

### Aquatint (`aquatint`, look_d4)

The grime only moves the wash step edges, so a field that sits deep inside one step (the charcoal
street, t well above `step_hi`) printed flat. `aquatint` prints 1 px ink grains inside the washes
(scaled by smoothstep(step_lo, step_hi, t): paper stays clean), mean-preserving around a 35 % cover that
the same grime blotches push up and down: the target frame's grainy asphalt. The grain is the baked
lattice read at texel centres, world-locked like every other print hash. d1 0, d4 0.18, d5 0.26.

### Print inks (`look_profiles.json` `tones`)

The world and item prints' output inks are uniforms (`paper_tone`, `wash_tone`, `ink_tone`), filled from
palette.json tokens by `LookParams.add_tones` (`tones`: pass -> uniform -> token id; a profile row may set
the Vector3 itself to override). Re-toning the world is two hex values in palette.json, no shader edit.
The shader defaults are the pre-2026-11-03 cool inks, so a material that never gets a look keeps those.
`print_part.gdshader` (characters) still has its own ink / cream constants: the rigs' ink lines are
(23,19,27), the world's (27,21,23) - not visible apart at any zoom; pass the tones when that file is next
touched. 2026-11-03: `ink` #17131B -> #1B1517 and `wash` #665F68 -> #6C6161 put the street on the target
frame's warm charcoal (81,71,72 measured in both; was 75,70,78 lavender) at the same luminance.

### Print overlays: where D5 plugs in (`look_overlay.gd`, `look_profiles.json` `overlays`)

The d5-close lane builds D5 "Inked Grime" as a **second print layer over the untouched D4 print**
(`assets/shaders/look_d5.gdshader` + `look_d5.params.json`), not as re-tuned D4 uniforms. An
`overlays` row names the shader, its params file and key (`world`), the `base` profile under it
(`d4`), the looks it ramps by zoom (`zoom_looks`: `auto`) or pins at full (`full_looks`: `d5`) and
the `amount_ppm` stops (48 px/m: 0, 64 px/m: 1). A row is **live only when both files exist**
(`LookProfiles.overlays`): then `auto` and `d5` resolve to `d4`, and `CityView` puts one
`LookOverlay` (a viewport `BackBufferCopy` + a full-rect `ColorRect`) on the `print_overlay` band
and feeds it `amount` and `world_px` every frame; at amount 0 it is hidden (zero cost at 32 and
48 px/m). Without the files the placeholder `d5` row and the d4 -> d5 uniform blend stay in use,
so this branch renders exactly as before. The gameplay-zoom amount is one number: the brief says
pure D4 at 48 px/m (0, shipped); d5-close proposes 0.35 there (an owner call).

Cost (`dev/selftest/overlay_cost.gd`, 16 interleaved blocks of 30 frames, `d4` vs `auto` at 64 px/m, n-d5
157dec8's look_d5 copied in): **+0.90, +1.15, +1.51 ms GPU** (1280x800, RTX 4090, shared GPU), CPU flat.
Paid only at arena zoom (hidden at 32 and 48 px/m). It is a full-viewport BackBufferCopy plus a
noise-heavy fragment pass; before it ships on the Deck it needs a cheaper shader (fewer vnoise taps) or
a half-resolution pass - a note for the d5-close lane.

Goldens: a look an overlay covers gets its own golden files (`<look>-<ppm>ppm-ov.png`), so the
overlay path never diffs against the placeholder frames. After look_d5 lands, bless those once
(the `-ov` files are new; the d1/d4 goldens must still pass untouched).

### Moving traffic art (`crowd_layers.gd` `_plug_traffic`, `look_d4_item.gdshader` `cells`)

The car MultiMesh draws a steel placeholder quad until d4-production's
`features/city/art/vehicles/traffic_atlas.png` is in the tree (cells of 512 x 256 px = the
6.4 x 3.2 m quad of native `fill_render`, nose +x, cell = the sim car art id in `custom.x`: 0-7
civilian, 8 the police cruiser; the grid is read from the texture size, today 3 x 3, and an atlas
that is not whole cells or holds fewer than 9 keeps the placeholder with a warning). Then the
cars AND their drop shadows sample that cell: the cars through a second item-print material
(`CrowdLayers.car_print` = look_d4_item with `cells` = that grid; CityView gives it the look's item
uniforms on every look change and `world_px` every frame), the shadows tinted ink so they are
car-shaped. An unprinted look uses crowd_atlas.gdshader for the cell lookup. A file that does not
load (an LFS pointer) keeps the placeholder. `CrowdLayers.apply_print` owns every crowd layer's
material and leaves a layer someone else re-materialed (the baked crowd atlas) alone.

## The colour doctrine (`palette_tokens.gd`, `data/tables/palette.json`)

Base tokens (`paper` #F2E8D5, `paper_2`, `ink` #1B1517, `ink_2` charcoal, `wash` #6C6161, `steel`) and the two
accent inks: **vermilion** #E8502A (threat, cop, danger cue, pickup, objective, Rivet's collar, hit
flash) and **teal** #1FB5A8 (souls, the dead, the torch tip). Each accent lists the render layers it may
appear on: never `world` (ground, decals, shadows, props, roofs); a pickup or hazard in the world is
drawn on `fx` or `world_markers`. `classify()` uses the look_d4 plate gates, so "is this pixel an
accent" means exactly what the print pass means by it.

`dev/selftest/accent_audit.gd` (in the `selftest` evidence via `tools/selftest/run.mjs`, **gating** since
2026-11-03: see the debt table below) renders the junction at 32 / 48 / 64 px/m, pauses the tree and captures once per hidden layer:
`world` is absolute (the actors canvas hidden), the actor bands are what hiding them removes. Any accent
on a layer the table does not allow is listed as an offender. First run (2026-11-02): 0.95 % of the
frame vermilion at 32 and 48 px/m (all of it actors: the cops), 0.26 % at 64; one offender, 216 px of
vermilion on `world` at 32 px/m = the red lamps of `props/traffic_light.png` (an asset for d4-production).

**Gate.** `data/tables/accent_debt.json` (gtai.accent-debt/1) lists known debt: accent + layer + ppm up to
`max_px`, with the source and the lane that pays it off. An offender not in the table, or above its
`max_px`, or any off-doctrine crowd look fails the selftest evidence; a debt row no longer seen is
reported for deletion. Today: no rows. `traffic_light_lamps` (216 px at 32 px/m) was paid off on
2026-11-03 in code, by the rule below, not by a redraw.

**The world print carries no accent plate (2026-11-03).** palette.json allows neither accent on `world`,
so every look profile's world `verm` and `teal` are 0: an accent painted into a ground / decal / prop /
roof texture prints as its ink density (a red barrel or a lit lamp = a paper disc in an ink rim), never as
vermilion. Found with the audit moved off the junction (a plaza block, `31-block/`): barrel_cluster.png's
red barrels were 4324 / 5632 / 3916 px of world vermilion at 32 / 48 / 64 px/m, 20x the lamps, and the
junction never saw them. After: 0 / 0 / 0 there; the junction frames move only at the lamps (32 px/m
mean 0.02), every other look frame bit-identical (the actors, cars and FX print their accents in their
own passes). `test_look_profiles` ties it to palette.json. A world-side danger cue goes on `fx` or
`world_markers`, as the table always said.

The atlas crowd is one MultiMesh, so it is split **at the source** (`crowd_atlas_by_look`): each look's row of
the baked crowd atlas is classified texel by texel (raw, before the item print), with the HIT clip counted
apart (`hit_flash`: its first frame is a full vermilion flash, a danger cue). A pedestrian look with
vermilion outside the flash is an offender. 2026-11-02: all 6 pedestrian looks 0 (676-830 texels each in
the hit flash only), cops 24.7k-29.3k (+2.7-3.1k flash). The `fx` band now also hides the FxSystem.

## The 2D light model (`light_layer.gd`, `light_pool.gd`, `light_ink.gdshader`, `data/tables/lights.json`)

The `light` canvas (screen space, above the actors, below the world UI) holds two bands:

- `grade` (z 0): a full-screen rect, the time-of-day grade (`grade_ink.gdshader`, a lights.json
  `grades` row: `paper_level`, `gamma`, `accent_keep`). It reads the printed screen and re-prints each
  pixel at luminance `paper_level * l^gamma` with its hue kept, so night is the same black-and-white print,
  darker and harder: the cream paper sinks to a warm grey, the charcoal streets to near ink, ink stays
  ink. Pixels the palette gates (palette.json `verm_gate` / `teal_gate`) call an accent keep
  `accent_keep` of their value, so at night the spot colours (cops, threats, danger cues, souls) stand
  out of the darkened print. `day` is the identity (1 / 1 / 0) and HIDES the rect: the day print pays
  no screen read. `night` = 0.58 / 1.5 / 0.85. It replaced (2026-11-03) a flat multiply by #6E6878: a
  lavender cast (B > R) over the warm paper and charcoal (the tones re-warmed in iteration 11), lower
  contrast, and the accents dimmed below the gates with everything else. Frames `37-night` in
  `gtai-masters/night/visual-engine` (cmp-block / cmp-junction / cmp-lights at 32 / 48 / 64 px/m).
  Cost (`light_showcase.gd` `gpu_ms_night_grade_delta`, interleaved day / night blocks, 48 px/m,
  1280x800): RTX 4090 +0.04 ms; the 2-CU iGPU (`--gpu-index 1`) +0.46 / +0.46 ms (2 runs; the screen
  copy plus one full-screen pass), inside the Deck's 25 ms frame. Night only.
- `lights` (z 100): one MultiMesh of additive quads, `max_lights` (32) per frame. `light_ink.gdshader`
  cuts each light's radial (or cone) falloff into `steps` flat bands and draws every band edge as
  world-locked 45-degree pen hatching, so a light prints as a drawn patch of paper (or vermilion for
  danger: the blast's rim, fire, the siren) over the charcoal, never a soft 3D bloom. The first version
  used a random 2 px stipple; it read as a halftone glow and was replaced (frames `04-lights` vs
  `04b-lights-hatch` in `gtai-masters/night/visual-engine`).

Kinds: `muzzle_flash` (paper fan, 4 ticks), `explosion` (paper core, vermilion rim, 36 ticks),
`headlight` (paper cone, held), `siren` (vermilion / paper strobe at 2.5 Hz, held: red and blue are
off-doctrine and teal is the dead's), `fire` (vermilion / paper flicker at 2.5 Hz, held; it was 7 Hz =
7 saturated-red flashes a second). Photosensitivity: `max_flash_hz` 3 (WCAG 2.3.1 / Harding) and
`LightLayer.MAX_FLASH_HZ` cap every alternating kind at load (a faster row is clamped with a warning). Lights live on the 60 Hz tick:
`add(kind, pos_px, angle, tick)`, `move()`, `remove()`, and `CityView` calls `step(tick, world_px)` every
frame. When the budget is full a timed light evicts the oldest timed light; a held light is refused
(`dropped` counts both). The riot's shots light their muzzle through the FX feed (fx_triggers.json);
`dev/selftest/light_showcase.gd` places the full demo set.

Car lights (`features/city/view/city_headlights.gd`, lights.json `car_lights`, 2026-11-03): on a grade
listed in `grades` (night) the `max_cars` (6) cars nearest the focus within `radius_m` (40 m) carry a
`headlight` cone per `lamps_m` offset (2: the nose corners) and police cars a `siren` on the roof. Fed the
snapshot `CityFxFeed` already reads (once per sim tick: the rig pass's snapshot, no extra sim call), held
lights moved onto the picked cars, the rest released; by day it returns after one check once its lights
are released. At most 18 held lights of the 32: timed lights (muzzles, blasts) keep 14. Cost (editor
build, headless, 400-actor snapshot with 57 cars): 38 us per tick at night. Frames `38-car-lights`.

Street lamps (`features/city/view/city_prop_lights.gd`, lights.json `prop_lights` + kind `street_lamp`,
2026-11-03): on `night` the `max_props` (8) lamp posts nearest the focus within 32 m hold a 4.5 m paper
pool (2 bands) at the lamp head: `at_m` [1.05, 0] in the `lamp_post` sprite's frame (the oval at 83 % of
its width). Heads are read once per resident chunk from its draw commands (the baked shadow command
skipped) and cached until the chunk leaves; the nearest set is re-picked when the focus moved 2 m.
`max_lights` 32 -> 40 so 18 car lights + 8 lamps leave timed lights 14. Frames `39-street-lamps`.

Cost (`light_showcase.gd` -> `light-cost.json`, 48 px/m): CPU `step()` 70-168 us for 32-64 lights
(GDScript loop). GPU: two long back-to-back runs (no lights, then 32) gave -1.40 .. +1.32 ms (clock /
power-state drift and other lanes on the GPU). Since 2026-11-02 23:00 the probe interleaves 16 blocks of
30 frames (lights hidden / shown) and takes the median block: **+0.29, +1.13, +1.35 ms** GPU for the
full budget of 32 overlapping fires (1280x800, RTX 4090, GPU ~12-33 % busy with other lanes). Positive
in every run, still noisy: read it as "up to ~1.4 ms at the worst case". Fill rate is the cost (each fire
is a 336 px quad at 48 px/m): do not raise `max_lights`; for the Deck, measure there and expect to cap
fires at 8-16 or shrink their radius.

## The FX system (`fx_system.gd`, `fx_pool.gd`, `fx_ink.gdshader`, `data/tables/fx.json`)

Eight kinds as data: `muzzle`, `tracer`, `impact`, `explosion`, `smoke`, `debris`, `ink_splat` (blood
is ink) and `crackle` (the electroshock melee: paper bolts; teal stays the dead's). Each row sets the
shape, palette token, particle count, life in ticks, size, speed, spread, drag, growth and an optional
light kind (`muzzle` -> `muzzle_flash`, `explosion` -> `explosion`) that `FxSystem` adds to the
`LightLayer`. One pooled MultiMesh (`max_particles` 512) on the `fx` band of the actors canvas, a
per-frame spawn budget (`max_spawns_per_frame` 24); over either budget a spawn is dropped and counted.
Particles advance on the sim tick (`CityView` calls `fx.step(tick)`), spread by a hash of the spawn
serial (no RNG stream), and fade by a hard 2 px dither, never a soft alpha ramp.

Shapes are **placeholders** drawn analytically by `fx_ink.gdshader` (disc, streak, burst, splat,
bolt with an ink rim) while the FX sheet is absent. **The sheet plugs in as data**: `fx.json`
`atlas` names it (`res://features/fx/art/fx_atlas.png`, the d4-production 8 x 4 grid of 256 px
cells) and each kind's `atlas` block picks `cells` [first, count] with a `mode` (`pick`: one
cell by the particle seed; `anim`: a cell every `frame_ticks`, or spread over the life, holding
the last) and overrides any row field (`count`, `size_m`, `speed_mps`, `grow`, `drag`). When the
texture exists (`FxSystem.atlas_live`) the instance custom `.z` carries cell + 1 and the shader
samples the sheet with mipmaps, cut at alpha 0.5 and faded by the same dither; the cell keeps its
own inks (vermilion only in the muzzle cores and the blast, which the fx band allows). `casing` and
`spark` are sheet-first kinds (an ink streak / paper burst without it).

**Emissive kinds draw above the lights.** `muzzle`, `tracer`, `explosion`, `spark` and `crackle` have
`emissive: true`: `FxSystem.spawn` forwards them to `glow`, a twin FxSystem that `CityView` puts on the
`fx_emissive` band of the `emissive` canvas (layer 4, above `light` 3; `world_ui` moved to 5). A flash is
not lit by its own light: under the additive paper light the sheet's vermilion blast core printed peach
(only 73 % of its warm pixels passed the vermilion gate at 64 px/m), above it 96 % (frames
`gtai-masters/night/visual-engine/07-fx-atlas/ab3-{48,64}ppm.png`). Smoke, debris, impacts, splats and
casings stay lit (and take the night grade). Each twin has its own budgets.
Frames: `gtai-masters/night/visual-engine/05-fx` (`dev/selftest/fx_showcase.gd`); step cost 48 us
with 43 particles alive.

**Ground kinds lie on the street.** `ink_splat` and `casing` have `ground: true`: `FxSystem.spawn`
forwards them to `ground`, a twin on the **world** canvas's `ground_decals` band, so the print pass
inks them like a decal and they draw under the bodies, the shadows, the props and the roofs (on the
`fx` band a splat covered the dead body's torso: `10-fx-feed/crops-48ppm.png` vs `crops2-48ppm.png`).

### What fires the FX (`fx_triggers.gd`, `data/tables/fx_triggers.json`, `features/city/view/city_fx_feed.gd`)

A cue row names the fx kinds to spawn and an optional camera shake (`shake_near_m`: only cues that
close to the focus kick it, so a riot two blocks away does not shake the screen). Two sources:

- **`sim` cues, read from the sim** by `CityFxFeed`, which diffs the snapshot the rigs already take
  (no second native call): a projectile slot that appears is a `shot` (fired one observe later at
  its first position, once its heading is known: muzzle star + casing + the muzzle light + the
  `gunfire` shake when near), one that vanishes is a `projectile_end` (impact chips thrown back
  along the heading), a person whose mode turns dead is a `death` (an ink splat under the body).
  The first observe only primes. Render only: nothing is written back, so parity and replay are
  untouched, and no positional F-04 event was needed for the riot.
- **`event` cues** follow an Events signal: `player_hit` (sparks on Rivet + the `hit` shake), then
  `player_hit_<weapon>` when the table has one (`player_hit_robo_tazer`: the electroshock `crackle`;
  main's arena emits `player_hit(&"robo-tazer")`), and `rivet_kill` (`actor_killed` by Rivet: hit-stop).

The selftest junction (seed 91, 180 ticks) fires 11 shots, 9 ends, 9 deaths, 0 dropped
(`fx_cues` in its result JSON). Explosions, crackle and smoke have no sim source yet (no grenades,
no melee in CitySim): they stay API (`FxTriggers.fire`) until a system emits them.

## World-UI markers (`world_markers.gd`, `marker_shapes.gd`, `data/tables/world_markers.json`)

`CityView.markers` sits on the `world_markers` band of the `world_ui` canvas (above the lights,
unprinted). `add(kind, pos_px)` returns a handle (`move`, `remove`); `objective = handle` makes the
pointer follow it. Kinds are data: `objective` (vermilion diamond), `pickup` (vermilion ring),
`soul` (teal ring), each with an ink outline and a paper sticker rim like the characters', drawn at a
constant **screen** size at every zoom (32 / 48 / 64 px/m) and bobbing on the sim tick (still under
reduced motion). The pointer is a vermilion chevron pinned `margin_px` inside the screen edge along
the ray from the screen centre while the objective is off screen. The doctrine is enforced at load:
a kind whose token is an accent ink not allowed for its `use` (palette.json `uses`) is dropped.

## Camera feel (`camera_rig.gd`, `data/tables/camera.json`)

Modes `on_foot` 32, `car` 48, `arena` 64 px/m; `set_mode(id, tick)` eases the zoom over
`zoom_ease_ticks` (36) with a smoothstep, `snap(id)` jumps (boot, cuts). `listen(Events, clock)` drives the modes
from F-04 events: `vehicle_entered` -> `car`, `vehicle_exited` -> `on_foot`, `boss_engaged` -> `arena`
(the `auto` look reaches D5 on the way: blend 0.02 at 49 px/m, 0.84 at 60, 1.00 at 64),
`contract_completed` -> `on_foot`. Frames: `gtai-masters/night/visual-engine/42-arena`. In a car the camera leads the
velocity (`look_ahead_m_per_mps` 0.35, capped at 7 m, eased 6 % a tick). The velocity is the focus's
own motion: `CityView` calls `rig.follow(tick, focus)` every frame and the rig differences the focus
between the ticks it saw (frames with no new tick lead nothing; a jump faster than 90 m/s - a cut, a
respawn - leads nothing), so whatever moves `CitySystem.focus` (input, a car, a cutscene) feeds it.
Shakes by id (`gunfire`, `hit`,
`explosion`, `crash`: amplitude in screen px, linear decay over ticks, a tick-phase wobble, no RNG);
the strongest shake in progress wins. Hit-stops by id (`melee_hit` 4, `kill` 6, `boss_hit` 8,
`rivet_hit` 3 ticks): an `fx_triggers.json` row's `hitstop` names one (`player_hit` -> `rivet_hit`;
`rivet_kill` = `actor_killed` with Rivet's id as killer -> `kill`); `rig.hitstop(id, tick)` returns
its length (0 under reduced motion or within `hitstop_cooldown_ticks` 20 of the last stop) and
`FxTriggers` holds the clock for it (`SimClock.hold(seconds)`: that much frame time is not simulated,
so sim, FX, lights and shake all hold still; every tick is unchanged, so replays stay identical, and
headless runs have no views, so no hold). `reduced_motion` zeroes
shake and hit-stop, halves the look-ahead cap (7 -> 3.5 m: at 15 m/s the lead is 3.29 m vs 4.93 m in
engine, 47-reduced) and stretches the zoom ease 1.5x (wire it to the settings
feature when it lands). `CityView.rig` drives `zoom` and the camera offset every frame when set (the game
sets it, snapped to `car`); null keeps `zoom` fixed, which the selftests, goldens and benches rely on.
`world_px` is computed after the offset, every frame, so the print grain stays locked to the world.
Frames: `gtai-masters/night/visual-engine/06-camera` (ease 32.0 -> 35.0 -> 40.7 -> 46.0 -> 48.0 px/m at
9-tick steps; explosion shake offset 5.3 px).

## Plugging a view in (`print_stage.gd`)

`PrintStage` is the whole engine as one node, for any view that is not the city (quest stages, arenas,
interiors, menus over the world). The view adds it, sets `look_id` / `rig` / `clock`, and:

- draws its world as children of the stage, each top-level item on a world band
  (`z_index = RenderLayers.z(&"ground" | &"ground_decals" | &"props" | &"roofs")`): printed by `look_d4`;
- puts people / vehicles under `actor_layer()` on `actors` / `vehicles` with
  `material = item_material()`: printed by `look_d4_item` (accents kept where the doctrine allows);
- calls `place(focus_m)` once a frame: camera + rig (zoom ease, look-ahead, shake, hit-stop), the
  zoom-anchored `world_px`, the look for the zoom (`auto`: D4 -> D5 overlay), lights, FX, markers;
- uses `fx` / `fx_triggers` / `lights` / `markers` like `CityView` does.
- calls `listen(Events, clock, player_id, at)` once for the game feel: a CameraRig on the F-04 events
  (vehicles, `boss_engaged` -> arena 64 px/m, contract end) and the FX cues (hits, the weapon's own cue,
  the hit-stops on Rivet's hits and kills).

`tests/unit/test_print_stage.gd` audits the layers, the look by zoom and the world lock. Evidence:
`dev/selftest/print_stage_demo.tscn` draws quest 1's placeholder style (flat cream / ink shapes, one
vermilion fire barrel as a world prop, one vermilion threat as an actor) under one PrintStage:
`gtai-masters/night/visual-engine/44-print-stage` (the barrel prints cream - the world carries no accent
plate - and the threat keeps its vermilion). Main's quest 1 view (`boot/collect_call/view/`) draws with
its own `Ink` constants and camera today; moving it onto PrintStage is a few lines after the merge, and
`CityView` (which predates it and composes the same pieces) should move onto it too.

### What a flat tint prints as (D4, for every art and placeholder palette)

The world print reads density `d = (0.93 - luma) * 1.25` (`look_d4` `plates()`, luma = 0.299 R +
0.587 G + 0.114 B) and steps it at the d4 profile's thresholds (`look_profiles.json`; the grime moves
each edge by up to ~0.16 x `grime`, so stay ~0.05 clear of an edge or the fill prints mottled):

| prints as | density | flat grey (sRGB 0-255) at most, with the 0.05 margin |
|---|---|---|
| paper | < 0.19 | lighter than ~198 stays paper |
| first wash | 0.19 - 0.45 | 188 |
| mid wash | 0.45 - 0.68 | 135 |
| dark wash (charcoal) | 0.68 - 0.86 | 88 |
| + hatch | > 0.86 | 51 |
| solid ink line | > 0.90 | 43 |

Example: quest 1's placeholder `Ink.WASH` (12 % violet-black over cream) is luma 0.81 = density 0.15:
it prints as paper, so its zone floors vanish under the print (45-quest1). A zone that must read
needs <= ~188 grey (first wash) or real ground art.

## World lock (every print pass on `world_px`)

`CityView` computes `world_px` (the camera's world offset in screen px, after zoom ease, look-ahead and shake)
once a frame and hands it to every print shader: `look_d4` (its material), `look_d4_item` (the item
material), `light_ink` (`LightLayer.step`), `fx_ink` (`FxSystem.step` on all three twins) and `print_part`
(`PartMaterials.set_world_px`, from `CityCharacters._before_render` before its no-tick skip). Every per-pixel
hash reads `FRAGCOORD.xy + world_px`, so the paper tooth, grime, hatch, dot screens and fade dither move
with the world and never swim on a pan. Two checks: `test_shader_world_lock` (unit: no bare `FRAGCOORD` in any
`.gdshader`) and `dev/selftest/world_lock.gd` (in the selftest evidence: pan the paused junction by whole px
at 32 / 48 / 64 px/m; the frame must move rigidly, max 0.5 % of the overlap differing; 0.00 % on
2026-11-03, 0.60 / 0.23 / 0.52 % before the fix, 43 / 37 / 45 % with `--plant-unlocked`).

Zoom: a world point X prints at `X * zoom`, so while the rig eased the zoom the print slid by `X * dz` a
tick (~600 px at the block: the grime blotches and hatch re-rolled every tick of a 32 / 48 / 64 ease).
`CityView._print_px()` keeps an offset that moves by `-camera * dz` on each rig zoom step: the screen
centre keeps its print, the edges slide a few px a tick, pans stay exactly locked; with no rig the offset
is 0 (selftests and goldens bit-identical). Measured (`gtai-masters/night/visual-engine/43-zoom-swim`,
`swim_metric.txt`: consecutive mid-ease ticks warped onto each other, street, low-passed): residual
1.76 -> 0.89 (sigma 3), 1.50 -> 0.67 (6), 1.21 -> 0.54 (10). The 1 px grain still re-rolls during an
ease (any slide > 1 px does; constant-screen-size grain cannot avoid it); it settles when the ease ends.

## Per-pass cost (2026-11-02, RTX 4090 / 7800X3D, debug editor binary unless noted)

`dev/selftest/pass_cost.gd` measures the GPU cost of each pass in the real riot frame: interleaved
blocks that switch ONE pass off (print, actors, lights, FX) against `full`; run it with
`--gpu-index 1` (the 7800X3D's iGPU, the low-end proxy) and `--resolution 1280x800` (the Deck).
Shader rule from it: a noise term whose mask is exactly 0 on most pixels sits behind an `if` on that
mask (look_d4: 2 value-noise calls on a typical pixel instead of 9). Check that frames stay
bit-identical (render look_golden with the old and the new shader and diff the full-res PNGs).

| Pass | Cost | How measured |
|---|---|---|
| D4 world print (`look_d4`), low-end GPU | AMD Radeon iGPU (2 CU, below a Steam Deck), 48 px/m riot, 1280x800: 2.76-2.92 ms of a 6.06-6.12 ms frame before; 1.21-1.76 of 4.66-4.94 ms after the early-outs (3 interleaved pairs, bit-identical frames). 1920x1080: 5.31 -> 3.76 ms (1 run). Those frame totals carry ~1.5 ms of a measuring artifact (the print toggle broke the crowd atlas material until 1c7e3aa; the print deltas are like for like). After 1c7e3aa: frame 3.23-3.30 ms = print 1.56-1.61, full rigs 0.47-0.56, atlas crowd 0.09-0.15, lights 0.12-0.17, cars and FX under 0.15; at 1920x1080: frame 5.72-5.79 ms = print 3.07-3.18, rigs 0.54-0.61, crowd 0.19-0.25, lights 0.26-0.34 | `pass_cost.gd --gpu-index 1` (`evidence/pass-cost`) |
| D4 world print, grime lattice (`grime_lattice.gd`) | iGPU 1280x800 48 px/m, 2 runs each: print 1.67 / 1.61 -> 1.39 / 1.33 ms (-0.28, -17 %), frame 3.21 / 3.29 -> 3.08 / 3.01; 1920x1080: print 3.07 / 3.18 -> 2.60 / 2.70 ms, frame 5.72 / 5.79 -> 5.29 / 5.40. The two grime octaves sample a baked 128 x 128 value lattice (bilinear at i + smoothstep(f) = the same faded value noise) instead of 4 sin hashes each. Not bit-identical (8-bit lattice, tiling) but the goldens hold at worst mean 0.09 and the x8-amplified grime keeps its blotch scale. Bounds measured on the way: grime + paper tooth 0.43 ms, Sobel 0.18 ms. REJECTED: an integer hash for every `hash()` (+0.75 ms: 32-bit integer multiplies are slow on this AMD iGPU) | `pass_cost.gd` (`evidence/pass-cost/hash-ab`) |
| D5 overlay on the grime lattice (patch for n-d5) | iGPU 1280x800 64 px/m, interleaved, on top of the early-outs patch: +1.91 / +1.87 -> +1.25 / +1.39 ms (-0.57, -30 %). look_d5's vnoise() becomes one lattice fetch (`LookOverlay` sets `grime_tex`); the overlay frames move (mean 3.3, the stroke wobble and pressure patches re-laid) with the same character, no tiling seen. `evidence/pass-cost/look_d5-early-outs-lattice.patch` applies on n-d5 as is (it includes the early-outs) | `overlay_cost.gd` (`evidence/pass-cost/d5-lattice`) |
| D4 aquatint (`aquatint`, 2026-11-03) | iGPU 1280x800 48 px/m, interleaved on / off x2: print 1.35 / 1.38 -> 1.45 / 1.45 ms (+0.08 to +0.10), frame 3.04 / 3.05 -> 3.13 / 3.14. One lattice fetch at the pixel's texel centre, only where a wash prints (t > step_lo); the grime blotches set the grain cover. REJECTED on the way: the same grain from the sin `hash()` (diagonal streaks at 35 % cover, 30-mottle/cmp1x-d4-48ppm.png) and a smooth tone mottle (read as airbrushed clouds, not ink) | `pass_cost.gd` (`evidence/pass-cost/aquatint`) |
| Cast shadows (`cast_shadow.gdshader`, 2026-11-03) | iGPU 1280x800 48 px/m at a building block (the selftest scene moved to (456, 428), scratch), interleaved hatched vs the old flat tint x2: frame 3.80 / 3.78 -> 3.82 / 3.80 ms (+0.01 to +0.02, inside run-to-run noise). 2 lattice fetches, only on shadow pixels | `pass_cost.gd` (`evidence/pass-cost/cast-shadows`) |
| D4 world print, RTX 4090 | 0.39 ms of 0.86 ms at 1280x800, 0.85 of 1.49 at 1080p (before); after-runs were contended (other lanes on the GPU): judge on the iGPU | `pass_cost.gd` |
| Look resolve (`_update_look`) | one dictionary compare a frame; a held zoom or pinned id returns the cached object | code path |
| D5 print overlay (64 px/m only) | +0.90 .. +1.51 ms GPU (interleaved, 3 runs, shared GPU), 0 at 32 / 48 | `overlay_cost.gd` |
| Lights `step()` | 30-168 us CPU for 32-64 lights; GPU +0.29 .. +1.35 ms for 32 fires (interleaved, 3 runs, shared GPU) | `light_showcase.gd` |
| FX `step()` | 48 us CPU for 43 live particles; 135 us for 147 (3 twins). Skipped on frames with no tick and no spawn. A single-buffer upload (16 GDScript writes per particle) measured slower (192 us) and changed the picture: reverted | `fx_showcase.gd` |
| FX feed in the riot (shots, ends, deaths -> FX + lights) | avg frame +0.07 ms, p99 CPU +0.15 ms (was +0.35 ms avg before the no-tick skip) | `city_bench -- --fx-feed=off` A/B, 3 interleaved pairs x 20 s |
| Markers | a few `_draw` polygons a frame | code path |
| Chunk bands | 20 canvas items per chunk (was 8): see DEVIATION §20-draw | exported bench after item 1: p99 2.61 ms |
| Rig pass skip on no-tick frames | rig p50 0 ms, p99 0.559 ms (unchanged: tick frames) | exported bench after item 7a |
| Rig LOD tiers 4 full / 4 half / 8 quarter (was 6 / 10 / 0) | rig avg -21 % (0.39 -> 0.31 ms), p99 0.55-0.71 -> 0.40-0.57 ms, headless debug ; exported release riot: 0.457 -> 0.338 ms per tick, p99 0.501 -> 0.387 ms per frame (target 0.3: not met) | `rig_bench.gd`, 3 interleaved pairs (`evidence/rig-quarter`); `evidence/bench-*-quarter.json` |

The exported bench after items 4-6 (`evidence/bench-*-contended.json`) failed (p99 6.09 ms, worst swap
72 ms, one 3.6 s frame), but it ran at 99 % CPU with the n-d4 lane's own bench, two scenario runs and an
image job on the same machine; every hitch is `present`-attributed with about 0.3 ms of game + render
CPU. It is **not a valid measurement** either way: re-run on an idle machine, A/B against `ad2078b`.
A re-run once that bench finished passed the hard limits (p99 4.22 ms, 1% low 111 fps, worst swap
4.5 ms) with the machine still at 83-96 % CPU from other work (`evidence/bench-*-rerun.json`).
