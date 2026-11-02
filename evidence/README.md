# d5-close evidence (night 2026-11-02, branch n-d5)

PNGs in this folder are left untracked (16 MB; the same files are in masters). Masters, raw sheets, prompts and every round's frames: `C:\Users\kazda\kiro\gtai-masters\night\d5-close\`
(`frames/r*` = A/B showcase rounds, `frames/h*` = hero rounds, `ladder.png`). All frames are in-engine, rendered with
Godot 4.7.2 on d3d12 from `dev/showcase/d5_showcase.gd` / `d5_hero.gd`. They are deterministic: fixed cast, fixed
tick count, no RNG.

| File | What |
|---|---|
| `item5_portraits.png` | the 3 D5 portraits at 512 px plus 128 and 64 px phone sizes |
| `item1_gate.png` | concept / D5 tier at 32, 48 (= D4) / D4 at 64 / D5 at 64 and 96 |
| `item3_roofs_gate.png` | the 4 landmark roofs, D4 vs D5, at 32 and 48 px/m |
| `item4_hero_vs_targets.png` | `d4h2_mock.jpg` / in-engine D4+D5 at 48 and 64 / the concept |
| `hero-d4-<ppm>ppm.png`, `hero-d4d5-<ppm>ppm.png` | the hero junction, before / after, at 32, 48, 64 and 96 px/m (the night's showcase: `hero-d4d5-96ppm.png`) |
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
- Rust vs collar: Rivet's pure-vermilion px at 96 px/m 1614 -> 739 after the dried-rust print (the collar stays
  pure). D5 cops keep 95% of their pure vermilion at 64 px/m (4334 -> 4122 px in the fight crop).
- Codex: 25 images (4 Rivet sheets, 4 roofs, 3 portraits generated twice by a duplicate job, 3 cop sheets, 4 bold
  Rivet re-inks, 3 ped sheets, 1 sidewalk tile; masters `gen/ledger.tsv` has 25 lines); 0 rejected for camera breaks. In-engine rejections: the vermilion fist mural (re-inked) and the
  4 bold re-inks (reverted: no hatch gain at 64 px/m, the larger rust diluted the collar).
- Gates at f2c7654 (`node tools/evidence/run.mjs --no-parity --no-bench`): lint, unit 146/0, scenarios 8/0, selftest
  all PASS. Parity and bench were not run here (the native GDExtension is not built in this worktree).

## Gap list: in-engine vs `d4h2_mock.jpg` and the concept (next step for each)
1. **Building depth.** The mock's roofs cast hatched shadows and show a parapet wall; ours were flat squares.
   `look_d5_shadow.gdshader` (world-locked, hand-wobbled pen strokes) closes most of it in the hero scene. Next:
   the city lane places one shadow quad per building, offset from `look_d5.params.json` `shadow.offset_m`.
2. **Street life.** The mock has cars, a hydrant, cones, a dumpster and the teal soul trail; the hero scene is empty.
   Next: put the existing D4 props, a parked cruiser and the ghost trail into the hero scene (assets exist).
3. **Asphalt texture.** The mock's street is cross-hatched. A dense street hatch (r7) read as rain and was
   reverted; a sparse, patchy, darker one now prints from 64 px/m only (596e172; character dL vs surround 0.091 ->
   0.095, 0 px change at 32/48). Next: decide whether 48 px/m (car camera) gets a lighter version.
4. **Pavement.** Ours reads as clean tiles; the mock's slabs are worn, hatched and kerbed with rounded corners.
   A D5 sidewalk tile (`city/art/d5/ground/`, seamless via a spliced D4 border) helps only marginally at 64 px/m.
   Next: kerb-corner pieces and curb tiles in D5; that is where the mock's look comes from.
5. **Rivet vs the concept.** The concept's identity (visor, ID badge, posture) is a front view, and our camera
   only sees the top. Up close the D5 tier now carries the lavender steel, rust, ink and misregistration, but the
   in-part hatch mostly mips away at 64 px/m (parts are drawn ~5x minified). Next: re-generate the D5 sheets with
   coarser, bolder hatch (strokes 3x thicker) so it survives 0.2 screen px per part px; and the portraits carry the
   face.
6. **The whole slice cast now has a D5 tier** (Rivet, cops, peds). The ped costs 6% contrast on cream pavement at
   64 px/m (0.373 -> 0.351). Next: King and the boss cast need rig parts first (they exist only in the spike).
7. **The world print layer is subtle** (its fibre tooth read as rain and was replaced by an isotropic mottle). look_d5 adds paper tooth, ink ghosts and a mid-wash hatch; on this scene
   there is little mid wash, so its main visible effect is grain. Next: tune it on a roof-heavy frame at 64 px/m,
   and hand `zoom_amount` to the visual-engine lane's profile table.

## Not measured tonight (unmeasured is not zero)
- Motion shimmer of the D5 tier during a WALK: unmeasured. (The zoom tween IS measured: `dev/showcase/d5_sweep.gd`,
  mean |D5 - D4| over Rivet per zoom = 0 at 51/53/55, 0.003 at 57, 0.022 at 59, 0.046 at 61, 0.064 at 63, then
  0.066 / 0.066 at 65 / 67 px/m: a monotone fade with no step = no pop.) Next: a walk-cycle frame series with a
  frame-to-frame diff of the Rivet crop at 64 px/m.
- GPU cost of the D5 overlays (+1 sprite per part on up to 16 rigs) and the look_d5 layer: no bench run (no native
  build here). Next: `node tools/bench/run.mjs` with the D5 tier forced on.
