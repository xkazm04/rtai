# Crowd pop at rank 17

Slot 15 kept its shoes on the same pixel row after the anim fix. Restoring its live build also needs the two people-writer changes in [NEED-gfx.md](NEED-gfx.md).

## Cell audit at 64 px/m

Each view has eight looks and 25 frames per look. The before capture used a2e7b603b. The audit read the finished GPU atlas, checked all four outer texel lines at alpha greater than zero, and rendered its cells on the real city mesh. A separate, padded CutRig rendered the same look, facing and clip time at the same display zoom. Height and feet use the inclusive nontransparent bounds relative to the same actor point. The audit uses the baker's canonical actor ID of −1. The native switch fixture independently exercises slot 15.

| Look | Tilt70 before, clipped / 25 | Tilt70 height ratio before → after | Top before, clipped / 25 | Top height ratio before → after |
|---|---:|---|---:|---|
| coat-hat | 21 | 0.369–0.880 → 1.000–1.000 | 1 | 0.974–1.043 → 1.000–1.000 |
| jacket-hair | 21 | 0.750–0.919 → 1.000–1.010 | 1 | 0.974–1.043 → 1.000–1.000 |
| coat-hood | 21 | 0.369–0.899 → 1.000–1.000 | 1 | 0.974–1.043 → 1.000–1.000 |
| hoodie-cap | 21 | 0.468–0.882 → 1.000–1.000 | 1 | 0.974–1.043 → 1.000–1.000 |
| vest-hair | 21 | 0.467–0.950 → 1.000–1.000 | 1 | 0.974–1.043 → 1.000–1.000 |
| patrol | 21 | 0.397–0.882 → 1.000–1.000 | 1 | 0.987–1.038 → 1.000–1.000 |
| riot | 21 | 0.643–0.882 → 1.000–1.000 | 1 | 0.987–1.032 → 0.989–1.010 |
| overalls-bald | 21 | 0.403–0.882 → 1.000–1.000 | 1 | 0.974–1.043 → 1.000–1.000 |

Clipping fell from 168 to zero at tilt70 and from eight to zero from above. The final maximum height and feet error are each one pixel. Horizontal bounds differ by up to three pixels across the full audit. The old tilted death cells were post-stamped from separate artwork, which accounts for the largest pre-fix ratio differences. The p70 bake now poses the live bullet fall. Its long rightward silhouettes are sampled at 40 px/m horizontally and 64 px/m vertically. Other standing and top poses use the 64 px/m camera grid. Full per-cell measurements are in [audit_before.json](audit_before.json) and [audit_after.json](audit_after.json).

## Quad size and consumers

- CharacterRigs.bake_crowd and baked_cell build the atlas and select the clip/row. Quad extent comes from CityCharacters.bake, which passes CrowdAtlas.cell_world_px() to both backends. See `project/features/characters/character_rigs.gd:66` and `project/boot/city_characters.gd:61`.
- The GDScript writer uses person_px on both heading axes. The native writer multiplies both axes by person_px_. They both draw CrowdLayers' centered unit quad. The original 128 / 1.5 reciprocal was correct. The old 0.55 actor origin on a centered quad displaced the feet by 4.27 world pixels. The top edge also removed part of every standing p70 silhouette. See `project/features/city/sim/sim_render.gd:67`, `native/sim_core/src/render.cpp:59`, `native/sim_core/src/render.cpp:77` and `project/features/city/view/crowd_layers.gd:124`.
- CrowdBaker reads CrowdAtlas for tile extent, capture scale and clip anchor. StreetCrowdCorpse reads that same anchor when stamping legacy corpse artwork. CrowdAtlas.configure_material passes the inverse transform to crowd_atlas_vertex.gdshaderinc. Traffic uses the shader's identity defaults. StreetWalkerCards and the atlas use StreetCrowdCards.body_scale for the per-actor build.
- Atlas rim readback and the selftest accent audit read CELL_PX. Far-cop row diagnostics and the rig stress bench read cell IDs. The experimental noir crowd print replaces the vertex shader and needs the shared include, as specified in the gfx handoff. City chunk hashing consumes GTCH bytes. Sim parity and replay consume snapshots. None of those digests takes atlas pixels.
- Storage grew from 3200 × 1024 to 4000 × 1280 RGBA8, or 12.5 to 19.53125 MiB. The 25-column layout, eight rows and clip IDs are intact.

## Native film

At seed 5 the focus moved across a fixed group of 17 people. The native writer and the real nearest-rig selector kept slot 15 rigged at ticks 31 and 32, then baked it at tick 33. Each take changed only that slot's look. Removing the people bodies with the shadow pass still present provided the background for the frame bounds.

| Slot 15 look | Live height | Original atlas | Anim atlas | With gfx slot | Foot y, live / original / anim / gfx |
|---|---:|---:|---:|---:|---|
| Hat | 115 | 88 | 101 | 115 | 145 / 154 / 145 / 145 |
| Riot cop | 118 | 90 | 104 | 118 | 148 / 156 / 148 / 148 |
| Overalls | 122 | 90 | 107 | 122 | 148 / 156 / 148 / 148 |

The original top edge cuts the hat crown, helmet dome and balding head flat. The anim frames recover all three contours. With the gfx slot, the hat keeps its full width and the other two silhouettes differ by one pixel in width. The 10-second tilt70 movie shows the crowd walking both ways across the pavement at 32 px/m. Slot 15 leaves its rig at tick 93. The movie uses the anim branch's native writer.

Masters are under `C:/Users/kazda/kiro/gtai-masters/n19/anim/crowd-pop/`. The three switch sheets are `coat-hat-switch.png`, `riot-switch.png` and `overalls-bald-switch.png`. The movie is `crowd-ring-32ppm.mp4` (960 × 480, 150 frames at 15 fps). Per-arm source frames, ring telemetry and `switch-bounds.json` sit beside them.

## Reproduction

Use the lane APPDATA and GODOT_BIN. The film wrapper runs tools/dev/run.mjs with D3D12 on the secondary monitor.

```text
node tools/art/crowd_pop.mjs crowd_pop_audit --windowed --check --out=<absolute JSON path>
node tools/art/crowd_pop.mjs crowd_pop_ring --windowed --out=<absolute frame directory>
```

Add --motion for the 600-tick walk or --slot-preview for the two-line gfx integration preview. Omit --check to record a failing layout.

## Look goldens

Both sites passed all 16 stored frames before the layout change. Thirteen exceeded tolerance afterwards. Hiding only RL_PEDS at the same fixed ticks changed 33,922–75,649 screen pixels in those frames. Only those 13 images received the engine's 320 × 200 bilinear reduction. The per-frame filenames, submitted people counts and isolation measurements are in [look_goldens.json](look_goldens.json).

Re-blessed files

- `d1-32ppm.png`
- `d1-48ppm.png`
- `d4-32ppm.png`
- `d4-48ppm.png`
- `d5-48ppm-ov.png`
- `auto-48ppm-ov.png`
- `auto-56ppm-ov.png`
- `auto-64ppm-ov.png`
- `block-d4-32ppm.png`
- `block-d4-48ppm.png`
- `block-auto-64ppm-ov.png`
- `block-d4-48ppm-night.png`
- `block-auto-64ppm-ov-night.png`

## Changed files

- Runtime geometry and appearance live in `project/features/characters/crowd_atlas.gd`, `crowd_baker.gd`, `crowd_atlas.gdshader`, `crowd_atlas_vertex.gdshaderinc`, `street_crowd_corpse.gd`, `street_crowd_cards.gd` and `street_walker_cards.gd`.
- The two showcase scenes and scripts are `crowd_pop_audit` and `crowd_pop_ring` under `project/dev/showcase/`. The film launcher is `tools/art/crowd_pop.mjs`. The new resources include their Godot UIDs.
- Regression coverage lives under `project/tests/unit/` in `test_crowd_cell_layout.gd`, `test_street_dead_heading.gd`, `test_ghost_sheet.gd` and `test_tonnage_stride.gd`. The 13 updated references are listed above.
- `docs/decisions.md` records the layout choice. `tools/debt/baseline.json` accounts for the two GPU measurement fixtures. This directory contains the two audits, the per-frame golden checks and the gfx handoff.

## Verification

- The quick gate passed with `--no-godot`. The full pre-commit lint passed all 19 checks. The changed-suite runner selected the full fast suite and passed 2,980 tests with two skips and zero failures. All 16 look goldens passed their final GPU comparison.
- The headroom regression failed with the old layout. The stage provided 46.93 world px above the actor against the test's 64.70 px minimum. The new tilt70 stage provides 70.24 world px and the same assertion passes.
- `b472095b6` — Match crowd atlas headroom, projection and foot anchors to the live rig.
- `595b5a652` — Cover ghost sheet rebinding and Tonnage midpoint boundaries.
- The full GhostSheet run at `a2e7b603b` killed **60/(60+24)**, with three invalid mutants and zero timeouts. The follow-up tests exercise the midpoint entry and exit, its sixth-step and pitch guards, grid rebinding, initial standing cell, outline sync, fallback octant and left-grid boundaries. Two surviving initializers are overwritten by the constructor on every path.
- The GhostDrawn run restricted to lines 111 and 193 killed **1/(1+0)**. The operator removed the frame display at line 111. It generated no mutant on line 193.
