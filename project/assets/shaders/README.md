# assets/shaders

Shared shaders.

## D4 "Ink and Hatch" print pass (F-08)

The slice look (owner decision 2026-11-02: D4 hybrid; fallback D3 Clear Line).

| File | Layer | What it does |
|---|---|---|
| `look_d4.gdshader` | full-screen pass over the world (ground, roofs, props, parked cars) | the tone budget: paper / light / mid / dark ink wash in flat steps; the art's own ink lines stay solid ink; hatching only in deep shadow; wobbly Sobel ink edges; flat off-register vermilion and teal plates |
| `look_d4_item.gdshader` | traffic, actors' fx, HUD, ghosts (above the world pass) | nearest-ink snap; steel prints one flat wash value; drop shadows a flat ink tint; `ghost = 1` prints on the teal plate |

- Set `world_px` on the world pass every frame to the camera's world offset in screen pixels
  (`(cam.position * cam.zoom.x).round() - viewport_size / 2`), so the grime and hatch are locked to the world.
- The pen work comes from the D4 art (`features/city/art/`), not from the shader. The colour doctrine
  (vermilion = threat, hazard, pickup, Rivet's collar; teal = the dead, the torch tip) lives in the assets.
- Cutout characters keep their own part print (`print_part`, ported with the rig in F-09); the cream sticker rim is
  the rig's halo, not painted into the parts.
- Ported from the spike's art-direction study (`gtai-spike/evolve/project-artdir`, `look.gdshader` mode 5 and
  `look_item.gdshader` mode 5, commit `821a3e7`) and tuned in the F-08 crop tests: `grime` 0.30, `wash_mid` 0.90,
  `step_hi` 0.84, `line_ink` 0.86; the item pass's shadows are a flat tint instead of the study's dot screen.

## D5 "Inked Grime" up close (d5-close night lane, 2026-11-02)

D5 is the Rivet-concept look (`pof games/gtai/art-direction/trivet/ref-4-rivet-concept.jpg`). Hand-drawn detail does
not survive on 32 px/m characters, so D5 lives up close and on big world surfaces only. At 32 px/m the frame is
exactly D4 (0 changed px, measured).

| File | Layer | What it does |
|---|---|---|
| `look_d5_part.gdshader` | the D5 character tier (`features/characters/rig_detail.gd`) | prints the D5 part art (`features/characters/art/d5/<char>/`) as one overlay sprite per part over the untouched D4 part, alpha = zoom fade (56 -> 64 px/m). Lavender-grey steel ramp (D4 wash ink, not a hue), hatch re-drawn at screen resolution in part space, rust only where it survives mip 3 (no speckle), an off-register vermilion plate; a form shade: a hatched band inside each part's lower-right edge and a cream lit rim on its upper-left, lit in SCREEN space (the roofs' and cast shadows' light) via the UV derivatives, so a rotating limb keeps the world's light |
| `look_d5.gdshader` | over the `look_d4` world print, under the actors | ink-pressure hatch in the mid wash (in patches), a sparse darker street hatch (full at 64 px/m, `street_hatch_car` 40% at 48), an isotropic paper-tooth mottle, off-register ink ghost and vermilion pass; `amount` from the zoom |
| `look_d5_shadow.gdshader` | a building's cast-shadow quad on the world layer, under the look_d4 print | light ink tint + world-locked, hand-wobbled pen strokes (the mock's hatched building shadows); also thin kerb shadows (0.18 m, tint 0.55, stroke 0.6) on the street side of kerbs facing down-right; a proposal for the city lane |
| `look_d5.params.json` | (data for the visual-engine lane) | `world` uniforms, `zoom_amount` stops (32 px/m: 0, 48: 0.35, 64: 1), `part` defaults, the tier zooms, `shadow` |

- The D5 part set is silhouette-locked to the D4 set (same names, sizes, pivots, alpha), so the tier never moves an
  outline or the sticker halo. Both D5 layers only re-print ink and vermilion that D4 already put there; the colour
  doctrine is unchanged.
- Rust prints as dried rust (vermilion toward ink); pure vermilion only where it is coherent at mip 5 (the collar,
  a cop's plate), so the collar stays Rivet's signature. Parts with a palette swap keep their D4 print.
- D5 parts sample with mipmaps (`TEXTURE_FILTER_LINEAR_WITH_MIPMAPS`). The project default (linear, no mips) turns
  the detailed art into speckle at 0.2 screen px per part px.
- Evidence: `gtai-masters/night/d5-close/` (`item1_gate.png`, `item3_roofs_gate.png`, `item4_hero_vs_targets.png`,
  `ladder.png`); scenes `dev/showcase/d5_showcase.gd` (A/B tiers) and `dev/showcase/d5_hero.gd` (junction hero shot).
