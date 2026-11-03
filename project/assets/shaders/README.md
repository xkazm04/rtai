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
| `look_d5_print.gdshader` | PROPOSAL, not used by default | look_d4 verbatim + THREE changes: the Sobel edge ink only on the dark side of an edge, so thin pen lines stay thin (look_d4 inks both sides: 1 px -> ~3 px); the 5% paper grain on world pixels (48 px/m pan: junction 0.00814 -> 0.00049, mural roof 0.01075 -> 0, `evidence/item32_print_world_grain.png`); no edge ink on the dark wash step (`street_edge`: cream road paint without an ink ring, as in the mock; 32 px/m solid-ink share 0.14 -> 0.11, mock 0.12, `evidence/item37_street_edge.png`). Dev A/B: `D5_PRINT=thin` with `dev/showcase/d5_hero.gd`; `evidence/item29_thin_print_proposal.png` |
| `look_d5_halo.gdshader` | PROPOSAL, not used by default | the mock's thin ink line OUTSIDE the cream sticker rim: a ring-only pass (width in screen px from UV derivatives) on a child sprite of each rig halo, z below every halo, so only the silhouette's outer edge gets it. Separates a character's rim from the cream zebra/pavement at 32-72 px/m, then fades with the halo's own shrink (CutRig hk) to 0 at 96 px/m (`fade` uniform: no pop at the halo switch). Dev A/B: `D5_HALO=ink` (`D5_HALO_PX` = width; `D5_HALO_RIM=1` = +1 px cream rim, owner A/B `item38`; `D5_HALO_SHADOW=1` adds the mock's soft drop shadow, 0.09 m down-right, ink 0.4) with `dev/showcase/d5_hero.gd` (`dev/showcase/d5_hero_halo_ink.gd`); `evidence/item34_halo_ink.png`. For the characters lane (rig_build.gd `_halo`) |
| `look_d5.gdshader` | over the `look_d4` world print, under the actors | ink-pressure hatch in the mid wash (in patches), a sparse darker street hatch (full at 64 px/m, `street_hatch_car` 40% at 48), an isotropic paper-tooth mottle, off-register ink ghost and vermilion pass, and the AGED PAPER (`age`: low-chroma pixels warm toward the mock's sepia, street 78,67,70 / paper 245,221,193 at 64 px/m; `age_floor` = the same warmth below the D5 zoom, default 0, a proposal for the D4 profile; `grain_floor` = the paper tooth below the D5 zoom, the mock's street mottle at 32 px/m, default 0, a proposal: `evidence/item26_grain_floor_32.png`); `amount` from the zoom |
| `look_d5_shadow.gdshader` | a building's cast-shadow quad on the world layer, under the look_d4 print | light ink tint + world-locked, hand-wobbled pen strokes (the mock's hatched building shadows); also thin kerb shadows (0.18 m, tint 0.55, stroke 0.6) on the street side of kerbs facing down-right; on a Sprite2D it takes the sprite alpha (a character's cast shadow, King in the arena); set `zoom` (camera zoom, 1 = 32 px/m) so strokes stay ~10 screen px apart above 64 px/m (no change at 32-64); a proposal for the city lane |
| `look_d5_soul.gdshader` | the teal souls on the actor layer (a proposal for the fx lane; used by dev/showcase/d5_hero_run.gd) | snaps the drawn soul to two teal inks + the cream rim + paper grain (soft ramps), faded in with the D5 tier (`amount`, 56 -> 64 px/m) because at 32 px/m the snap busies the minified art; replaces look_d4_item's ghost dot screen, which dissolves a drawn soul at 64 px/m |
| `look_d5.params.json` | (data for the visual-engine lane) | `world` uniforms, `zoom_amount` stops (32 px/m: 0, 48: 0.35, 64: 1), `part` defaults, the tier zooms, `shadow` (`offset_m` is placement data, the rest are uniforms: `tests/unit/test_look_d5_params.gd` checks it) |

- The D5 part set is silhouette-locked to the D4 set (same names, sizes, pivots, alpha), so the tier never moves an
  outline or the sticker halo. Both D5 layers only re-print ink and vermilion that D4 already put there; the colour
  doctrine is unchanged.
- Rust prints as dried rust (vermilion toward ink); pure vermilion only where it is coherent at mip 5 (the collar,
  a cop's plate), so the collar stays Rivet's signature. Parts with a palette swap keep their D4 print.
- No D5 shader hashes noise on screen pixels: grain is locked to the world (`w`), the part (part space) or the soul
  sprite. A screen-locked hash re-rolls on every camera move or walk step (`look_d4` line 96 still does: -93% pan
  swim when world-locked, measured with `dev/showcase/d5_pan.gd`).
- Zoom-tied warmth drifts while zooming (paper dE 2.8 from 32 to 48 px/m, 7.6 to 64); `age_floor` 1 removes it.
- D5 parts sample with mipmaps (`TEXTURE_FILTER_LINEAR_WITH_MIPMAPS`). The project default (linear, no mips) turns
  the detailed art into speckle at 0.2 screen px per part px.
- D5 landmark roofs (`features/city/art/d5/roofs/`, art, not a shader): since iteration 5 they are a PEN-HATCH plate
  (the mock's even diagonal membrane hatch, lower-right cast hatch, no grey wash blotches: those printed as
  camouflage). At 32 px/m the roofs sit at the mock's tone (mural L 0.593 / paper 0.44 vs mock 0.589 / 0.41; D4 0.516
  / 0.27); the hatch prints as tone at 32-48 and as lines from 64. The mural fist is a light ink wash with its own
  ink line re-printed vermilion 3 px down-right. OSHA and tall have D5 plates too (the boss arena's yard and the hero's
  neighbours swap them in the d5 tier). Tone and visible hatch lines do not both survive 32 px/m through look_d4 (a bold
  hatch plate was tried and rejected). Build: masters `tools/build_roofs.py` (board `item21_mural_pen.png`).
- Evidence: `gtai-masters/night/d5-close/` (`item1_gate.png`, `item3_roofs_gate.png`, `item4_hero_vs_targets.png`,
  `ladder.png`); scenes `dev/showcase/d5_showcase.gd` (A/B tiers) and `dev/showcase/d5_hero.gd` (junction hero shot).
