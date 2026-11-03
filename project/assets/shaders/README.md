# assets/shaders

Shared shaders.

## grade_ink.gdshader (the time-of-day grade)

The `light` canvas' `grade` rect (core/render/light_layer.gd). Reads the screen (`hint_screen_texture`)
and re-prints it at luminance `paper_level * l^gamma`, hue kept; accent pixels (palette gates) keep
`accent_keep` of their value. Uniforms come from a lights.json `grades` row (+ the palette gates);
`day` is the identity and hides the rect. See core/render/README.md "The 2D light model".
`age` (0 = off) is the page age: the D5 overlay's aged paper, applied here first, to neutral pixels only
(`age_dark` / `age_light` = look_d5's mock-median gains), so the world and the actors above it warm
together; the rect draws when the grade is not the identity OR the age is > 0 (core/render/README.md
"Page age").

## D4 "Ink and Hatch" print pass (F-08)

The slice look (owner decision 2026-11-02: D4 hybrid; fallback D3 Clear Line).

| File | Layer | What it does |
|---|---|---|
| `look_d4.gdshader` | full-screen pass over the world (ground, roofs, props, parked cars) | the tone budget: paper / light / mid / dark ink wash in flat steps; the art's own ink lines stay solid ink; hatching only in deep shadow; wobbly Sobel ink edges; `aquatint` grain inside the washes; flat off-register vermilion and teal plates (0 in every shipped profile since 2026-11-03: the world carries no accent) |
| `look_d4_item.gdshader` | traffic, actors' fx, HUD, ghosts (above the world pass) | nearest-ink snap; steel prints one flat wash value; drop shadows a flat ink tint; `ghost = 1` prints on the teal plate |
| `cast_shadow.gdshader` | the `building_shadows` band of every chunk (ChunkView, under the world pass) | a shadow silhouette as a light ink tint + world-locked 45-degree pen strokes (lattice wobble and gaps) that the world pass inks; this lane's placeholder for n-d5's `look_d5_shadow` (same uniforms; `data/tables/cast_shadows.json` picks whichever is in the tree) |

- Set `world_px` on the world pass every frame to the camera's world offset in screen pixels
  (`(cam.position * cam.zoom.x).round() - viewport_size / 2`), so the grime, hatch and paper tooth are locked
  to the world. Every per-pixel noise in the world pass hashes `w = FRAGCOORD.xy + world_px`, never `FRAGCOORD`
  alone (the paper tooth did until 2026-11-03 and swam on pans). Checked in the selftest evidence by
  `dev/selftest/world_lock.gd` (pan the paused junction; the whole frame must move rigidly). The item
  (`look_d4_item`, CityView sets it) and part (`print_part`, `PartMaterials.set_world_px` every frame) shaders
  take the same `world_px` for their tooth, shadow dots and ghost dots.
- Set `grime_tex` on the world pass to `GrimeLattice.texture()` (`core/render/grime_lattice.gd`): the two grime
  octaves sample that baked value lattice (one bilinear fetch each) instead of 4 sin hashes each (-17 % print
  pass on the low-end GPU). Unset, the grime is a flat offset, not blotches.
- The output inks are uniforms (`paper_tone`, `wash_tone`, `ink_tone` on the world pass; `paper_tone`, `ink_tone` on
  the item pass), set from palette.json tokens by `LookParams` (look_profiles.json `tones`); the defaults are the
  pre-2026-11-03 cool constants. Every other world-pass uniform is a look-profile parameter too.
- The pen work comes from the D4 art (`features/city/art/`), not from the shader. The colour doctrine
  (vermilion = threat, hazard, pickup, Rivet's collar; teal = the dead, the torch tip) lives in the assets.
- Cutout characters keep their own part print (`print_part`, ported with the rig in F-09); the cream sticker rim is
  the rig's halo, not painted into the parts.
- Ported from the spike's art-direction study (`gtai-spike/evolve/project-artdir`, `look.gdshader` mode 5 and
  `look_item.gdshader` mode 5, commit `821a3e7`) and tuned in the F-08 crop tests: `grime` 0.30, `wash_mid` 0.90,
  `step_hi` 0.84, `line_ink` 0.86; the item pass's shadows are a flat tint instead of the study's dot screen.
