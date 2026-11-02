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
| `hero-d4-<ppm>ppm.png`, `hero-d4d5-<ppm>ppm.png` | the hero junction (round h33, iteration 2), before / after, at 32, 48, 64 and 96 px/m (the night's showcase: `hero-d4d5-96ppm.png`) |
| `item1b_form_shade.png` | Rivet at 64 px/m: D4 / D5 iter 1 / D5 + form shade, and the form shade at 96 |
| `item2b_street48.png` | 48 px/m crop: street hatch off (h23) / at 40% for the car camera (h24, kept) |
| `item4d_kerb_shadow.png` | kerb shadow strips at 64 and 32 px/m (h24 vs h26) |
| `item4e_kerb_corners.png` | rounded kerb corners at 32 (and 48 x2), h26 vs h28 |
| `item6_cop_shade.png` | cop at 96 px/m: D5 tier without / with the form shade on vermilion plates |
| `item4c_souls_print.png` | the D5 souls at 64 px/m: world print / look_d4_item ghost print (rejected) / as drawn (kept) |
| `item4b_street_life.png` | hero junction before (iter 1) / after street life (iter 2) at 32, 48, 64 + mock + concept |
| `d5-cost.json` | GPU/CPU render cost of the D5 tier, 16 full rigs at 64 px/m (tracked) |
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
2. **Street life.** (Iteration 2 also fills the blocks like the mock: 12 D4 neighbour roofs at the locked 80 px/m,
   0.4 m alleys, each with the D5-tier cast shadow, h29; neighbours stay D4 in both tiers, only the 4 landmarks swap.)
   CLOSED in the hero scene (iteration 2, `item4b_street_life.png`, round h20): a parked cruiser and
   sedan, cop 2's muzzle flash + tracer + casings, an ink splat, a manhole, a drain grate, skid marks into the cruiser and an oil stain (h33), and the teal soul trail (1 new Codex D5 soul sheet).
   Vehicles/FX are the d4-production lane's raw D4 sheets, keyed into masters `borrowed/` and loaded by
   `d5_hero.gd -- --borrow=<dir>`; nothing is installed. Next: when the vehicles/fx lanes install their sprites,
   point D5HeroExtras at `res://` and drop `--borrow`; the D5 soul sheet goes to whoever owns the soul VFX.
   **Soul print finding (`item4c_souls_print.png`):** through the world print (look_d4) the pale teal souls lose their
   fill (cream bodies); through the game's ghost print (`look_d4_item` `ghost = 1`) they dissolve into a teal dot mesh
   at 64 px/m; drawn as-is on the actor layer they match the mock's soul trail. The hero scene now shows them as drawn
   (`--soul-print` = the A/B). Next (fx/visual-engine lane): a ghost print that keeps a flat pale-teal fill + teal ink
   instead of the dot screen, at least from 48 px/m up.
3. **Asphalt texture.** The mock's street is cross-hatched. A dense street hatch (r7) read as rain and was
   reverted; a sparse, patchy, darker one now prints from 64 px/m only (596e172; character dL vs surround 0.091 ->
   0.095, 0 px change at 32/48). Iteration 2 (`item2b_street48.png`, h23 vs h24): the car camera (48 px/m) now
   prints 40% of it (`street_hatch_car`): street median 0.286 unchanged, street high-frequency energy 0.0505 ->
   0.0520 (+3%), 0 px change at 32 and 64. Next: owner eye on a moving car frame (unmeasured in motion at 48).
4. **Pavement.** Ours reads as clean tiles; the mock's slabs are worn, hatched and kerbed with rounded corners.
   A D5 sidewalk tile (`city/art/d5/ground/`, seamless via a spliced D4 border) helps only marginally at 64 px/m.
   Next: kerb-corner pieces and curb tiles in D5; that is where the mock's look comes from. Iteration 2
   (`item4d_kerb_shadow.png`): a thin look_d5_shadow strip (0.18 m) on the street side of every kerb facing
   down-right gives the pavement a raised edge (h26). A 0.32 m strip with bold strokes (h25) read as a hazard stripe
   and was rejected. Rounded kerb corners (`item4e_kerb_corners.png`, h28): `D5HeroKerbs` cuts each junction corner
   to a 1.6 m quarter circle (asphalt-tone fill + ink kerb arc, printed by the world pass like the tiles); the kerb
   shadow stops at the arc and the hydrant moved onto the pavement (it is in both tiers). Next: the city lane owns
   corner tiles; this is the geometry to copy. The pavement grid still ends abruptly at the arc (no curved slab
   joints).
5. **Rivet vs the concept.** The concept's identity (visor, ID badge, posture) is a front view, and our camera
   only sees the top. Up close the D5 tier now carries the lavender steel, rust, ink and misregistration, but the
   in-part hatch mostly mips away at 64 px/m (parts are drawn ~5x minified). Next: re-generate the D5 sheets with
   coarser, bolder hatch (strokes 3x thicker) so it survives 0.2 screen px per part px; and the portraits carry the
   face. Iteration 2 (`item1b_form_shade.png`): instead of more art, look_d5_part now draws a screen-lit FORM SHADE
   (hatched lower-right band + cream upper-left lit rim per part): the joints read as volumes, like the concept's
   shading. Tried 3 settings: 7 px (too timid), 9 px + steel darkening (dL 0.156 < D4 0.170: rejected), 8 px with a
   lighter base: dL **0.170** at 64 (= D4; it was 0.180) and **0.189** at 96 (D4 0.181). 0 px change at 32-56 px/m.
   Walk shimmer (tools/shimmer.py, same metric both runs): D5/D4 high-frequency change 0.988 -> 1.018.
   Then (`item6_cop_shade.png`): the form shade also hatches vermilion plates (`verm_shade` 0.7: cop bodies, the
   collar) and its UV derivatives moved before any branch/discard (they were taken in non-uniform control flow,
   i.e. undefined). Pure vermilion px in the hero frame 8104 -> 7892 at 64 px/m, 14516 -> 14229 at 96 (h29 vs h31; cops stay vermilion); 0 px change
   at 32-56 px/m on the character tier. Cast vs street dL on a FIXED mask at 64 px/m: D4 0.170, D5 0.167 (r18/r19):
   a marginal MISS of 0.003 (under one 8-bit grey level; 0.002 of it is the derivative fix). At 96: D5 0.187 vs D4
   0.181. A brighter lit rim (lit_k 0.75) did not move it (reverted).
6. **The whole slice cast now has a D5 tier** (Rivet, cops, peds). The ped costs 6% contrast on cream pavement at
   64 px/m (0.373 -> 0.351). Next: King and the boss cast need rig parts first (they exist only in the spike).
7. **The world print layer is subtle** (its fibre tooth read as rain and was replaced by an isotropic mottle). look_d5 adds paper tooth, ink ghosts and a mid-wash hatch; on this scene
   there is little mid wash, so its main visible effect is grain. Next: tune it on a roof-heavy frame at 64 px/m,
   and hand `zoom_amount` to the visual-engine lane's profile table.

## Motion, and what is still unmeasured (unmeasured is not zero)
- Motion shimmer, MEASURED after all: `dev/showcase/d5_walk.gd` walks Rivet 40 ticks at 64 px/m and shoots each
  tick as D4 and as D5 from the same pose (a crop following him; both carry the same look_d5 world layer). Frame-to-
  frame change D5/D4 = 1.06 total, 0.97 for the high-frequency part: the D5 tier adds no shimmer. The zoom tween:
  `dev/showcase/d5_sweep.gd`, mean |D5 - D4| over Rivet = 0 at 51/53/55 px/m, then 0.003 / 0.022 / 0.046 / 0.064 /
  0.066 / 0.066 at 57-67 px/m: a monotone fade, no pop.
- GPU cost, MEASURED (iteration 2): `dev/showcase/d5_cost.gd` puts 16 full rigs (CharacterRigs.MAX_FULL: Rivet,
  7 cops, 8 peds) on screen at 64 px/m, walking, vsync off, 240 frames per tier after 30 warm-up frames, and reads the
  viewport's measured render time (`d5-cost.json`, frames `cost-<tier>.png` in masters `frames/cost3`). RTX 4090,
  d3d12, 1280x800, median GPU ms: D4 **0.083**, + D5 part overlays **0.137** (+0.054), + look_d5 world layer
  **0.158** (+0.075 total). Render CPU 0.127 -> 0.256 ms (the overlay sprites double the canvas items). Runs 2 and 3
  agree to 0.001 ms; run 1 read a higher baseline (0.208 / 0.270 / 0.335 = +0.127) and is kept as the spread.
  Re-run after the form shade (187b58d, runs cost4/cost5, `d5-cost.json` = cost5), in the high-baseline state:
  D4 0.209, + parts 0.273 (+0.064; was 0.270 before the shade's 3 extra taps), + world 0.338-0.357. Walk shimmer
  re-run (walk3): D5/D4 high-frequency 1.022. Not measured: a min-spec GPU, and the GDScript cost of RigDetail's per-frame material updates (not in render CPU).
