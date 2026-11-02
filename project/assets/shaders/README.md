# assets/shaders

Shared shaders.

## D4 "Ink and Hatch" print pass (F-08)

The slice look (owner decision 2026-11-02: D4 hybrid; fallback D3 Clear Line).

| File | Layer | What it does |
|---|---|---|
| `look_d4.gdshader` | full-screen pass over the world (ground, roofs, props, parked cars) | the tone budget: paper / light / mid / dark ink wash in flat steps; the art's own ink lines stay solid ink; hatching only in deep shadow; wobbly Sobel ink edges; flat off-register vermilion and teal plates |
| `look_d4_item.gdshader` | traffic, actors' fx, HUD, ghosts (above the world pass) | nearest-ink snap; steel prints one flat wash value; drop shadows a flat ink tint; `ghost = 1` prints on the teal plate |

- Set `world_px` on the world pass every frame to the camera's world offset in screen pixels
  (`(cam.position * cam.zoom.x).round() - viewport_size / 2`), so the grime, hatch and paper tooth are locked
  to the world. Every per-pixel noise in the world pass hashes `w = FRAGCOORD.xy + world_px`, never `FRAGCOORD`
  alone (the paper tooth did until 2026-11-03 and swam on pans). Checked in the selftest evidence by
  `dev/selftest/world_lock.gd` (pan the paused junction; the whole frame must move rigidly). The item
  (`look_d4_item`, CityView sets it) and part (`print_part`, `PartMaterials.set_world_px` every frame) shaders
  take the same `world_px` for their tooth, shadow dots and ghost dots.
- The pen work comes from the D4 art (`features/city/art/`), not from the shader. The colour doctrine
  (vermilion = threat, hazard, pickup, Rivet's collar; teal = the dead, the torch tip) lives in the assets.
- Cutout characters keep their own part print (`print_part`, ported with the rig in F-09); the cream sticker rim is
  the rig's halo, not painted into the parts.
- Ported from the spike's art-direction study (`gtai-spike/evolve/project-artdir`, `look.gdshader` mode 5 and
  `look_item.gdshader` mode 5, commit `821a3e7`) and tuned in the F-08 crop tests: `grime` 0.30, `wash_mid` 0.90,
  `step_hi` 0.84, `line_ink` 0.86; the item pass's shadows are a flat tint instead of the study's dot screen.
