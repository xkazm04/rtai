# d5-close evidence (night 2026-11-02, branch n-d5)

PNGs in this folder are left untracked (16 MB; the same files are in masters). Masters, raw sheets, prompts and every round's frames: `C:\Users\kazda\kiro\gtai-masters\night\d5-close\`
(`frames/r*` = A/B showcase rounds, `frames/h*` = hero rounds, `ladder.png`). All frames are in-engine, rendered with
Godot 4.7.2 on d3d12 from `dev/showcase/d5_showcase.gd` / `d5_hero.gd`. They are deterministic: fixed cast, fixed
tick count, no RNG.

| File | What |
|---|---|
| `item1_gate.png` | concept / D5 tier at 32, 48 (= D4) / D4 at 64 / D5 at 64 and 96 |
| `item3_roofs_gate.png` | the 4 landmark roofs, D4 vs D5, at 32 and 48 px/m |
| `item4_hero_vs_targets.png` | `d4h2_mock.jpg` / in-engine D4+D5 at 48 and 64 / the concept |
| `hero-d4-<ppm>ppm.png`, `hero-d4d5-<ppm>ppm.png` | the hero junction, before / after, at 32, 48 and 64 px/m |
| `ladder.png` | the night's iterations, including the reverted ones |

## Measurements
- D5 stack vs D4, same pose, changed pixels: **0** at 32, 48, 54 and 56 px/m (the tier fades in from 56 to 64 px/m;
  the world print is 0 at 32 px/m).
- Rivet against the street at 64 px/m (mean luminance minus the street median, 0.286): D4 **0.174**, D5 **0.192**
  (it was 0.114 before the steel lift: D5 read worse than D4 and was fixed). At 96 px/m: D4 0.192, D5 0.209.
- Roof vermilion share (pixels with r - max(g,b) > 70): D4 0 on all four. D5: mural 7.2% -> **0.43%** after the
  doctrine fix; bar 0.60%, HQ 0.26%, pension bank 0.48%.
- Roof mean luminance at 32 px/m: mural 0.497 -> 0.429, bar 0.449 -> 0.401 (street 0.287). D5 roofs are darker
  but stay well above the street.
- Codex: 11 images (4 Rivet sheets, 4 roofs, 3 portraits); 0 rejected for camera breaks. One in-engine rejection:
  the vermilion fist mural (re-inked).

## Gap list: in-engine vs `d4h2_mock.jpg` and the concept (next step for each)
1. **Building depth.** The mock's roofs cast hatched shadows and show a parapet wall; ours are flat squares. The
   hatched cast shadow in `d5_hero_run.gd` closes most of it, but its strokes are mechanical. Next: a world-locked
   wobbly hatch for cast shadows in look_d4/look_d5 (the city lane places a shadow quad per building).
2. **Street life.** The mock has cars, a hydrant, cones, a dumpster and the teal soul trail; the hero scene is empty.
   Next: put the existing D4 props, a parked cruiser and the ghost trail into the hero scene (assets exist).
3. **Asphalt texture.** The mock's street is cross-hatched; ours is a calm flat charcoal. That was kept on purpose:
   characters read on it, and the first look_d5 street hatch (r7) read as rain and was reverted. Next: test a very
   sparse wobbly hatch only at 64 px/m+, gated on the Rivet dL staying at or above 0.17.
4. **Pavement scale.** Our paving reads as big clean bathroom tiles; the mock's slabs are smaller, hatched and
   kerbed with rounded corners. Next: a D5 paving / kerb-corner pass (Codex, layout template from `t_ground`).
5. **Rivet vs the concept.** The concept's identity (visor, ID badge, posture) is a front view, and our camera
   only sees the top. Up close the D5 tier now carries the lavender steel, rust, ink and misregistration, but the
   in-part hatch mostly mips away at 64 px/m (parts are drawn ~5x minified). Next: re-generate the D5 sheets with
   coarser, bolder hatch (strokes 3x thicker) so it survives 0.2 screen px per part px; and the portraits carry the
   face.
6. **Cops and peds have no D5 tier.** Only Rivet has a D5 part set. Next: D5 restyles of `d4_cop_a/b/c` with the
   same slicer (`slice_d5.py`): 3 images, RigDetail picks them up by folder automatically.
7. **The world print layer is subtle.** look_d5 adds paper tooth, ink ghosts and a mid-wash hatch; on this scene
   there is little mid wash, so its main visible effect is grain. Next: tune it on a roof-heavy frame at 64 px/m,
   and hand `zoom_amount` to the visual-engine lane's profile table.
