# d5-close evidence (night 2026-11-02, branch n-d5)

PNGs in this folder are left untracked (16 MB; the same files are in masters). Masters, raw sheets, prompts and every round's frames: `C:\Users\kazda\kiro\gtai-masters\night\d5-close\`
(`frames/r*` = A/B showcase rounds, `frames/h*` = hero rounds, `ladder.png`). All frames are in-engine, rendered with
Godot 4.7.2 on d3d12 from `dev/showcase/d5_showcase.gd` / `d5_hero.gd`. They are deterministic: fixed cast, fixed
tick count, no RNG.

| File | What |
|---|---|
| `item5_portraits.png` | the 3 D5 portraits at 512 px plus 128 and 64 px phone sizes |
| `item1_gate.png` | concept / D5 tier at 32, 48 (= D4) / D4 at 64 / D5 at 64 and 96 (rebuilt from r19, with the form shade) |
| `item3_roofs_gate.png` | iteration 5: the D5 pen-hatch roofs vs D4 in the hero junction at 32 and 48 px/m (h81) + the two south roofs (s4, `--cam=0,9.7`) + per-roof tone |
| `item4_hero_vs_targets.png` | `d4h2_mock.jpg` / in-engine D4+D5 at 32, 48, 64 and the 128 kill-cam (h106, iteration 7) / the concept |
| `item1c_shade_k.png` | iteration 4: Rivet's form-shade coverage 0.42 / 0.34 / 0.26 (kept) vs D4 at 64 (hero pose) + a cop at 96 |
| `hero-d4-<ppm>ppm.png`, `hero-d4d5-<ppm>ppm.png` | the hero junction (round h149st, iteration 8 = h106 + hatched prop/car shadows incl. the cone capsule (d5 tier) + wall-side clutter (both tiers) + rig shadows as world-locked strokes from 56-64 px/m (d5 tier); round h106, iteration 7 = h98b with STRIKE and the fist stencil inside the west lane; h98b, iteration 6 = h86 + the D5 ground tiles: print-aware pavement joints, clean crosswalk, thinned road cracks that fade back in up close, bold toned centre dashes, the kerb stone line + 2 more D5 lamps; h86, iteration 5 = h73 + the pen-hatch D5 roofs incl. OSHA/tall neighbours + the laundry-line misprint fix; h73 = h60 + the roof ink foot + form-shade 0.26 + finer shadow strokes at 96+ + the D5 lamp + drier rust; 128 = kill-cam), before / after, at 32, 48, 64, 96 and 128 px/m (the night's showcase: `hero-d4d5-128ppm.png`, the kill-cam) |
| `hero-pkg9-<ppm>ppm.png`, `arena-pkg9-{64,128}ppm.png` | NOT committed defaults: the same scenes with package v9 (every open proposal: look_d5_print thin, age/grain floors, halo line + shadow, roof membrane tone + lines gamma 0.6; the arena also with the owner A/B options fringe + dots), rounds i9mot / a32v9, at 32-128 px/m. Reproduce: masters `tools/package_shot.sh <round> [arena]` |
| `arena-pkg10-{64,128}ppm.png` | iteration 10: `arena-pkg9` + King through look_d5_ui at sharp 0 (`item52`; only King's pixels differ). Reproduce: `D5_UI_KING=0 D5_FRINGE=1 D5_DOTS=1 bash <masters>/tools/package_shot.sh <round> arena` (the d5 tier) |
| `item1b_form_shade.png` | Rivet at 64 px/m: D4 / D5 iter 1 / D5 + form shade, and the form shade at 96 |
| `item2b_street48.png` | 48 px/m crop: street hatch off (h23) / at 40% for the car camera (h24, kept) |
| `item4d_kerb_shadow.png` | kerb shadow strips at 64 and 32 px/m (h24 vs h26) |
| `item4e_kerb_corners.png` | rounded kerb corners at 32 (and 48 x2), h26 vs h28 |
| `item6_cop_shade.png` | cop at 96 px/m: D5 tier without / with the form shade on vermilion plates |
| `item5b_loading.png` | the D5 loading illustration at 960 and 480 px wide |
| `item4c_souls_print.png` | the D5 souls at 64 px/m: ghost print (rejected) / as drawn / look_d5_soul hard snap / look_d5_soul soft + tier fade (kept) |
| `item4b_street_life.png` | hero junction before (iter 1) / after street life (iter 2) at 32, 48, 64 + mock + concept |
| `d5-cost.json` | GPU/CPU render cost of the D5 tier, 16 full rigs at 64 px/m (tracked) |
| `item7_paper_age.png` | iteration 3: look_d5 aged paper, h38 vs h40 at 32/48/64 + mock + concept |
| `item8_shadow_hatch.png` | iteration 3: building cast-shadow hatch h40 (stripes) / h41 (flat, rejected) / h42 (kept), 64 and 32 |
| `item9_steel_owner_ab.png` | iteration 3, OWNER CHOICE: Rivet steel lavender (kept) / halfway / concept mauve at 64 and 96 + concept |
| `item10_street_decals.png` | iteration 3: D5 big street decals (stencil fist, STRIKE, chalk robot, scorch), h44 vs h46 at 32/48/64 + raw sheet + mock |
| `item11_roof_lift.png` | iteration 3: D5 roofs lifted toward the mock's cream: D4 / as built / 1.4 / 1.8 (kept) / 2.2 at 32 px/m (supersedes item3 for tone) |
| `item12_age_floor_32.png` | iteration 3, PROPOSAL: aged paper at 32 px/m (`age_floor`, default off) vs now vs the mock |
| `item13_killcam128.png` | iteration 3: the 128 px/m kill-cam, D4 vs D4+D5, beside the concept |
| `item14_d4_roof_lift_proposal.png` | iteration 3, PROPOSAL for d4-production: the D5 roof lift (d**1.8) on the D4 neighbour roofs at 32 px/m vs now vs the mock |
| `item5c_rivet_expressions.png`, `item5c_king_expressions.png` | iteration 3: Rivet (neutral, angry, hurt, hopeful) and King (neutral, wary, furious, smug) dialogue expressions at 512, 128 and 64 px beside the accepted portraits |
| `item15_local9.png` | iteration 3: the D5 LOCAL 9 union hall roof beside the mural (the mock's landmark), D4 vs D4+D5 at 32 and 48 (h60) |
| `item5d_finisher.png` | iteration 3: the two D5 finisher splash panels (`features/combat/art/d5/finisher_{drone,lightbar,k9}.png`; k9 in-game only) |
| `night_iter3_summary.png` | ONE SCREEN for the morning: iteration 2 end (h38) vs iteration 3 end (h60) at 32/48/64, the mock, the 128 kill-cam, the concept |
| `item16_parapets.png` | iteration 4: the roof "ink foot" (raised-slab read) vs the mock's LOCAL 9 edge, h60 vs h64 at 32/48/64 |
| `item5c_cop_expressions.png` | iteration 4: cop dialogue expressions (neutral, shouting, alarmed, suspicious) at 512/128/64 px |
| `item17_dialogue.png` | iteration 4: the D5 dialogue panel IN-ENGINE over the hero junction at 32/48 px/m + the mipmap A/B |
| `item18_arena.png` | iteration 4: the D5 boss arena (King's chop-shop floor + a plan-view King sprite) at 32/48/64/96, D4 tier, the rejected cream crown (a1), the concept |
| `item19_phone.png` | iteration 4: the D5 phone close-up in-engine (cop_alarmed behind the keyed phone screen) at 32/48 + the raw frame |
| `item5e_boss_intro.png` | iteration 4: the D5 boss intro card (King on his turntable; `features/combat/art/d5/boss_intro_king.png`, not wired) |
| `arena-d4d5-<ppm>ppm.png` | the boss arena at 64 and the 128 px/m boss kill-cam (a15, iteration 5: D5 OSHA + tall yard roofs) |
| `item1d_rust_dry.png` | iteration 4: Rivet at 96 px/m, rust_dry 0.42 (h72) vs 0.55 (h73, kept) |
| `item20_lamp.png` | iteration 4: at 48 and 64: the D4 lamp ('spoon', h70) / the first D5 lamp (riveted head = gear ring, h71) / the plain-cap D5 lamp (h72, kept) |
| `night_iter4_summary.png` | ONE SCREEN for the morning, iteration 4: mock, hero h64 at 32/48/64, the arena at 64, dialogue + phone close-ups, concept |
| `item21_mural_pen.png` | iteration 5: the mural roof D4 / D5 wash grime (h73) / pen-hatch b as is (h74, too clean) / b + ink weight + fist wash + misprint (h75, kept) at 32/48/64 + the mock roof + numbers; the rejected bold-hatch c (h83/h84) |
| `night_iter5_summary.png` | ONE SCREEN for the morning, iteration 5: mock, hero h86 at 32/48/64/128, the arena a15 at 64 and 128, concept |
| `item22_pavement_joints.png` | iteration 6: the D5 sidewalk tile's print-aware joints, h86 vs h87d at 32 (full frame) and pavement crops at 48/64 + the mock |
| `item23_street_print.png` | iteration 6: the D5 crosswalk (no black wear dots) and thinned road cracks, h87d vs h90 at 32/48/64 + the mock |
| `night_iter6_summary.png` | ONE SCREEN for the morning, iteration 6: iteration 5 end (h86) vs iteration 6 (h98b) at 32 and 48, the mock, the concept |
| `item24_kerb_stone.png` | iteration 6: the kerb stone line (continuous, 0.3 m inside the street edge), h90 vs h91 at 32/48/64 + the mock's kerb corner |
| `item25_road_dashes.png` | iteration 6: the mock's bold centre dashes, h91 / h92b cream (rejected: merges with the actors' rim) / h92c toned (kept) at 32 + the cop-on-dash contact at 48 |
| `item26_grain_floor_32.png` | iteration 6, PROPOSAL: look_d5 `grain_floor` (world-locked paper tooth at 32 px/m, default off) alone and with `age_floor`, vs as shipped and the mock + street crops |
| `item27_zebra_owner_ab.png` | iteration 6, OWNER A/B: the zebra cream (committed) vs toned x0.84 like the dashes (h95zt, not committed), Rivet over the crossing at 32/48/64 |
| `item28_cracks_up_close.png` | iteration 6: the road cracks at 128 / 96 / 48 px/m: h86 bold / h92c thinned, clean zebra (faint up close) / h97 the original cracks and zebra wear fading back in from 56 to 96 px/m, + the concept |
| `item29_thin_print_proposal.png` | iteration 6, PROPOSAL for the visual-engine lane: `look_d5_print` (look_d4 with edge ink on the dark side only) vs look_d4 at 32 px/m, D4 and D4+D5 tiers, + the mock and a x2 crop |
| `item29b_thin_print_48_64.png` | iteration 6: look_d4 (left) vs the look_d5_print proposal (right), D4+D5 tier at 48 (top) and 64 px/m (bottom) |
| `item29c_dark_soft.png` | iteration 6: the mural at 48 px/m, look_d4 / look_d5_print dark_soft 0.04 / 0.10 (kept: thin outlines keep their definition) |
| `item30_thin_print_roof.png` | iteration 6: the mural roof at 32 px/m: look_d4 / look_d5_print / look_d5_print + plate lines at gamma 0.45 (the mock's diagonal hatch AND a light tone) / the mock's LOCAL 9 roof |
| `item31_all_proposals_32.png` | iteration 6, FOR THE MORNING: 32 px/m h86 / h98b (committed) / h98b + every open proposal (look_d5_print, age_floor + grain_floor 1.0, D5 roof lines gamma 0.45; not committed) / the mock |
| `item32_print_world_grain.png` | iteration 7: the look_d5_print proposal's paper grain moved to world pixels; 48 px/m car pan (40 ticks) stills + change maps: look_d4 / print with screen grain / print with world grain, junction (0.00739 / 0.00814 / 0.00049) and mural roof (0.00975 / 0.01075 / 0.00000) |
| `item33_strike_lane.png` | iteration 7: STRIKE and the fist stencil inside the west lane instead of across the centre line (gap 7), h105 vs h106 at 48 and 32 px/m |
| `item34_halo_ink.png` | iteration 7, PROPOSAL for the characters lane: the thin ink line outside the cream sticker rim (look_d5_halo, D5_HALO=ink), h106 vs h107ink at 32 px/m x3 + the mock's stickers (at the mock's own scale) |
| `item35_all_proposals_iter7.png` | iteration 7, FOR THE MORNING (supersedes item31): committed h106 vs h106 + every open proposal (look_d5_print with world grain + street_edge, age_floor + grain_floor 1.0, D5 roof lines gamma 0.45, look_d5_halo line + shadow, the ruled roof hatch overlays; h124rf, not default) at 32/48/64 + the mock + the concept |
| `item36_arena_all_proposals.png` | iteration 7: the boss arena up close, committed (a16 = a15) vs every open proposal (a16all) at 64 and 128 px/m + the concept: no regression where D5 lives |
| `item37_street_edge.png` | iteration 7: look_d5_print `street_edge` (no edge ink on the dark wash step: road paint without ink rings, as in the mock), h109all vs h115se1 at 32 px/m x3 + the mock, and the arena at 64/128 (a16all vs a17se1) |
| `item38_rim_owner_ab.png` | iteration 7, OWNER A/B: the sticker rim as the rig draws it vs +1 px cream (look_d5_halo `rim_px`, D5_HALO_RIM=1; both with the outer ink line + shadow) at 32 x3 and 48, + the mock's stickers. Not in the package |
| `item39_d4tier_package.png` | iteration 7: the package in the D4 tier (D4 roofs) at 32 px/m, h106 vs h117pkg + a x2 roof crop: warm and light like the mock, but the D4 roof outlines print thin (solid ink 0.13 -> 0.07, mock 0.12) |
| `item40_d4_roof_lines.png` | iteration 7, PROPOSAL for d4-production: the D4 roofs with heavier lines (k 1.0) under the package, D4 tier 32 px/m x2: h106 / package / package + heavier lines (solid ink 0.13 / 0.07 / 0.11, mock 0.12) |
| `item41_roof_rule_option.png` | iteration 7, OPTION (not in the package): the ruled roof hatch under the thin print: the mock's diagonal membrane hatch at 32 px/m, but mechanical at 64 (across the OSHA sign plate). Needs a membrane mask + a zoom fade |
| `item42_roof_rule_fade.png` | iteration 7 (kept, in the package): the ruled roof hatch as zoom-fading overlays (`features/city/art/d5/roofs/rule/`, on with the thin print, gone at 64 px/m), h117pkg vs h124rf at 32 x2 and 48 + the mock roof |
| `item43_fringe_owner_ab.png` | iteration 8, OWNER A/B: look_d5_part `fringe_k` (the concept's off-register vermilion along each part's down-right edge, dried 0.2, fading in 64 -> 96 px/m) off vs on at 64 / 96 / 128 px/m (hero + arena kill-cam) beside the concept; pure vermilion unchanged, red-lead share 0.018 -> 0.030 (concept 0.039). Not default |
| `item43b_fringe_steel_only.png` | iteration 8 (da44a1a): the fringe option only on cool steel: the cop's cream glove got a red edge that read as blood (h150all vs h153all at 128), Rivet keeps it (h130ff vs h151fc) |
| `item44_prop_shadows.png` | iteration 8 (committed in the dev hero scene, d5 tier): hatched cast shadows for props and parked cars (look_d5_shadow on each prop's silhouette), h125 vs h133ps at 32 x2 / 48 / 64, the package h124rf vs h134pkg at 48, + the mock's car and crates; tint 0.7 rejected (blob) |
| `item44b_cone_shadow.png` | iteration 8: the traffic cone's shadow: none (h125) / its base plate's silhouette = a box (h141rs) / a capsule past the plate (h147cone, kept) at 32 x4 and 64 x2, + the mock's cone |
| `item45_street_clutter.png` | iteration 8 (dev hero scene): the mock's wall-side clutter on our empty pavement strips (bench, planter, mailbox, vending machine; neutral props only), h133ps vs h135cl at 32 + x2 crops + 48, beside the mock |
| `night_iter7_summary.png` | ONE SCREEN for the morning, iteration 7: h98b / h106 / h124rf at 32 px/m, the mock, h124rf at 48, the arena kill-cam with every proposal, the concept, + the per-tone-class table |
| `item46_rig_shadows.png` | iteration 8 (dev hero + arena scenes, d5 tier): hatched cast shadows for the rigs up close (first form: D5RigShadow + a CanvasGroup; superseded by `item46b`), a20 vs a22rs at 128 and 64, h135cl vs h139rs at 64 and 96, the package at 64, + the concept's ground shadow; fade 56 -> 64 px/m |
| `item47_dots_owner_ab.png` | iteration 8, OWNER A/B: look_d5_part `dots_k` (the concept's halftone stipple in the shaded steel mid-tones, 64 -> 96 px/m) off / rejected 4 px screen / on at 128 and 96, the arena with dots + fringe, the concept; walk at 96: no added shimmer. Not default |
| `item46b_rig_shadow_nogroup.png` | iteration 8 (kept): the rig shadow without a CanvasGroup, as world-locked strokes only (nothing stacks): group a24rs / no group + tint a27nogroup (rejected: stacks at joints) / strokes only a29st at 128, hero 64/96; cost +0.07..0.18 / +0.012 / +0.005 ms GPU |
| `night_iter8_summary.png` | ONE SCREEN for the morning, iteration 8: the mock / committed h149st at 32 / every proposal h153all at 32 and 64 (package + fringe + dots + rig shadows) / the arena kill-cam a31all / the concept + a per-class table (ink = L < 0.15 here, not iteration 7's class) |
| `ladder.png` | the night's iterations, including the reverted ones |

## Iteration 6 (02:12 -> ) in one screen (`night_iter6_summary.png`)
No image budget left (50/50): non-generative, print-aware edits of the GROUND, the largest surface in the gameplay
frame. The finding behind all three: look_d4 prints anything darker than its surface as either the surface's own
step or solid ink, so a line is either solid ink at 32 px/m or gone. The tiles are now built for that.
- **Pavement joints** (gap 3, `item22_pavement_joints.png`, 92068f9): the 4 px joints (L 0.05) printed as a black
  slab grid. The D5 sidewalk tile lifts them to light-wash density (they print as faint grey joints like the mock's),
  their weight wanders along the joint, and the source tile's stain slabs are lifted (they read as grey squares once
  the grid was light). Pavement strip at 48 px/m: L 0.569 -> 0.594, dark px 0.41 -> 0.36 (mock 0.616 / 0.30).
  Rejected on the way: joints too light (h87a: stain blotches), dashed joints (h87b).
- **Crosswalk** (`item23_street_print.png`, 285cc30): the zebra's wear holes printed as black dots; small holes filled,
  large ones a light paint/asphalt mix. Changed px only on the bars.
- **Road cracks** (51b96d4, d8a5b9c): the road tiles' patch outline and cracks (2-3 px ink, repeated every 8 m)
  thinned by 2 grey-level passes: gone at 32 px/m (the mock's street is clean), pen lines at 64+ (D5 up close).
  A hard 1-px ridge was rejected (stair-stepped). Pan at 48 px/m on the patch: ink px flipping per tick 0.00116 ->
  0.00102 (no flicker from the thin lines). Up close the thin cracks went faint at the 128 px/m kill-cam, so
  `D5HeroGround` (70c20a6, `item28_cracks_up_close.png`) fades the original crack pixels back in as a world-locked
  overlay, alpha 0 at 56 px/m -> 1 at 96: 0 px at 32/48, bold grime at 96-128, monotone over a 48-100 px/m sweep.
- **Kerb stone** (`item24_kerb_stone.png`, 15adfae + f8864e9): the mock's kerb is a cream stone band with an inner
  line that runs along the straight kerbs and round the corner. A thin (0.04 m) ink line 0.3 m inside the street edge,
  one polyline per quadrant (iteration 2's corner-only arc floated and was reverted). On a 48 px/m pan its ink px
  flip at 0.0063 per px/tick, the same as the crop's existing ink edges (0.0062).
- **Centre dashes** (`item25_road_dashes.png`, 72d2221 + 55f54b8): the mock's dashes are ~0.4 m cream bars; ours
  were 0.08 m and barely read at 32 px/m. Widened to 0.375 m. Pure cream (h92b) merged with a cop's cream sticker rim
  where he stands on the line (rim vs dash dL 0.02 at 48): the dash paint is toned x0.84 so it prints as a light
  wash, dL 0.16 / 0.14 at 32 / 48 (kept, h92c). The cream rim stays the street's only cream besides the zebra.
- **Gameplay-zoom grain, a proposal** (`item26_grain_floor_32.png`, f9f07fb): the mock's asphalt is a low-contrast
  mottle; ours prints flat. Specks in the tile read as salt (h93, rejected). look_d5's world-locked paper tooth is
  the right texture but scales with the zoom amount (0 at 32). `world.grain_floor` (default 0: h94 = h92c, 0 px)
  is its floor, like `age_floor`. With both at 1.0 the 32 px/m street median is 80,69,71 (mock 81,70,72; shipped
  76,70,79) and readability holds: rim vs street dL 0.575 -> 0.580, teal dE 41.3 -> 41.6, vermilion dE 76.6 -> 72.3.
  Visual-engine lane + owner decide (it changes the D4 gameplay frame).
- Whole frame, d5 tier (L / px darker than 0.2 / HF), h86 -> h92c: 32 px/m 0.410 / 0.231 / 0.071 -> **0.425 / 0.218 /
  0.071**; 48: 0.390 / 0.196 / 0.063 -> 0.396 / 0.188 / 0.063. Mock 0.488 / 0.123 / 0.104: closer in tone and ink, not in HF (the mock's high
  frequency is fine paper/asphalt grain; ours was grid and crack lines).
- No regression: d4 tier 0 px at 32-128 in every round; 0 actor px; no vermilion/teal px changed; pan swim per
  pixel class unchanged. Whole iteration, car-camera pan (48 px/m, default crop, 40 ticks): pan7c (iteration start)
  vs pan10 (h98b state): mean change 0.00739 -> 0.00739, ink px flips per tick 0.00284 -> 0.00278. Tools (masters): build_sidewalk.py, build_crossing.py, build_road.py (seeded/deterministic).

## Iteration 5 (01:15 -> 02:10, written 02:08) in one screen (`night_iter5_summary.png`)
- **Pen-hatch D5 roofs** (item 3 raised; `item21_mural_pen.png`, `item3_roofs_gate.png`; 5fa5d38 .. 8ab942a): the
  D5 roofs' grey wash blotches printed as camouflage and sat darker than D4. New Codex plates (Image 2 = crops of
  the mock as the HATCHING target) draw tone with pen lines only; `build_roofs.py` cleans the paper and weights the
  lines (gamma 0.7; union hall 1.0) so the hatch survives look_d4. Roof interiors at 32 px/m (L / paper):
  mural 0.487/0.28 -> 0.593/0.44 (mock 0.589/0.41), bar 0.463/0.27 -> 0.494/0.39, union hall 0.469/0.37 ->
  0.518/0.43, HQ 0.459/0.27 -> 0.502/0.39, pension 0.506/0.34 -> 0.555/0.47. The mural fist is a light ink wash
  with its own ink line misprinted vermilion 3 px down-right. NEW D5 OSHA and tall plates: the arena yard (a15) and
  the hero's neighbours print them in the d5 tier (64 px/m: OSHA paper 0.33 -> 0.40, tall 0.24 -> 0.36).
- **Rejected**: the b plate as is (too clean, the fist lost its mass), a composited ruled hatch (screen tone, union
  hall moire), a bold-hatch Codex plate (lines survive but take the fist's figure/ground and the tone), the warehouse
  plate (my template squashed a 2:1 roof).
- **No regression**: d4 tier 0 px in every round; street band and actors 0 px (h85 vs h73); roof pan swim per pixel
  class unchanged (the total +18% on the mural crop = more paper under look_d4's screen grain, gap 7).
- Codex: 9 images (ledger 50 = the night's budget), 0 rejected for camera breaks. Gates ALL PASS at dd3f0f5.

## Iteration 4 (00:11 -> ) in one screen (`night_iter4_summary.png`)
- **Roof ink foot** (gap 5, `item16_parapets.png`, 67c4b77): the mock draws each roof as a raised slab: cream lip ->
  a solid ink band ~1.6x the lip wide -> the hatched cast shadow (LOCAL 9 south edge, column-median L 0.85 / 0.13-0.21
  / 0.46-0.58). Ours had lip -> a 6 px outline -> hatch. `D5HeroParapets` adds a 0.22 m ink core outside the
  street-facing south/east roof edges (d5 tier): lip 9 px / ink 15 px at 48 px/m = the mock's ratio. Rejected on the
  way: the core in the 0.4 m alleys (h61: the blocks print as a black grid) and an inner hatched parapet shadow on the
  roof (h62: invisible over the roof art's own border hatch). Cost: ink share at 32 px/m 23.5% -> 24.1% (mock 13.9%;
  the excess is the roofs, gap 2). d4 tier 0 px; h63 = h64 0 px (deterministic).
- **Cop expressions** (`item5c_cop_expressions.png`): 1 Codex sheet, 0 rejected; `cop_{neutral,shouting,alarmed,
  suspicious}.png`. The visor hides the face in all four; at 64 px the hand (shouting) and crossed arms (suspicious)
  read best. Store-safe (owner review). The Rivet / King / cop expression set is complete.
- **Dialogue close-up in-engine** (gap 8, `item17_dialogue.png`, 78956ae): `d5_hero.gd -- --dialogue=rivet_angry,
  cop_shouting` puts two 200 px D5 portraits on a cream ink-bordered panel over the 32/48 px/m frame (placeholder ink
  bars, no strings: the HUD lane owns the text). FOUND: the portraits imported without mipmaps and aliased at 2.56x
  minification; mipmaps on: mean abs error vs a Lanczos 200 px reference 6.8 -> 4.6 (Rivet), 7.2 -> 5.1 (cop). The
  mipped panel is softer; a pre-scaled 256 px set would be crisper (HUD lane).
- **Boss arena at 64 px/m** (`item18_arena.png`, bac376c + 66a4734): King's chop-shop floor (1 Codex image on a layout
  template, 12 m at 104 px/m, `features/city/art/d5/arena/king_arena.png`) and a plan-view King sprite proposal
  (1 Codex image on a chroma-green template, `features/characters/art/d5/king/king_top.png`; no King rig exists).
  `d5_showcase.gd -- --arena`. The raw cream crown stencil swallowed Rivet's cream rim (a1: |dL| 0.077 vs ~0.15 on
  the street) -> dimmed x0.6 (`tools/build_arena.py`): 0.134. King at 2.8 m read smaller than Rivet -> 3.6 m.
  REVERTED: King through look_d5_part (a7: the Rivet-tuned ramp maps his steel to near-white, copper rust to pure
  vermilion). Frame vermilion at 64 px/m 0.49% -> 1.52% with King (his cape: the threat). King's raw steel was a
  saturated mauve (max-min 42 vs the printed cast's 9 at 96 px/m): desaturated x0.35 on install (a8, fade09c), L
  and vermilion kept.
- **Phone close-up in-engine** (`item19_phone.png`, 05a7b45): a D5 phone frame (1 Codex image, front-view UI art,
  keyed so the screen is a hole: `features/menus/art/d5/phone_frame.png`); `d5_hero.gd -- --phone=cop_alarmed`
  puts the portrait behind the screen with a placeholder call strip.
- **Rivet contrast parity in both poses** (`item1c_shade_k.png`, a6b9020): form-shade coverage 0.42 -> 0.26: fixed-mask
  dL at 64 px/m hero pose 0.151 -> 0.164 (D4 0.161), showcase pose 0.166 -> 0.176 (D4 0.168); 0 px at 32-56; walk
  shimmer HF 1.029 -> 1.024. The joint shade still reads.
- REVERTED: bolder part pen lines (h65, ink_at 0.66 / grime 0.05): Rivet dL 0.151 -> 0.138 at 64 px/m, noisier, not
  closer to the concept. FOUND: in the hero pose Rivet's D5 dL at 64 is 0.151 vs D4 0.161 (the 0.1693/0.1695 parity
  is the showcase pose); above D4 at 96.
- **Boss intro card** (`item5e_boss_intro.png`): 1 Codex panel, King on his turntable, left third calm for the name;
  1920 px in `features/combat/art/d5/` (not wired: `Events.boss_engaged`). The crown stencil printed vermilion,
  outside the prompt's vermilion list (King's mark; owner review).
- **Arena polish**: King's hatched cast shadow (look_d5_shadow now takes a sprite's alpha; hero 0 px), shadow strokes
  kept ~10 screen px above 64 px/m (`zoom` uniform; 0 px at 32-64), the 128 px/m boss kill-cam (the closest frame to
  the concept tonight), and D4 yard roofs with the ink foot around the floor (a13).
- **D5 lamp post** (`item20_lamp.png`, 934233c): the D4 'spoon' replaced in the hero's d5 tier by a plan-view lamp,
  arm over the street like the mock (d4 tier 0 px).
- **Item 1 gate, numerically (first try)**: Rivet (h72) vs the concept's Rivet scaled to the same height: rust/collar
  red-lead share concept 0.079, D4 0.030, D5 0.097 (64) / 0.106 (96) = D5 closer; ink share about level (0.39 / 0.39 /
  0.35); mean L concept 0.274 vs ours ~0.46 (the lavender steel, owner choice). Texture HF not comparable (rim).
  Then drier rust (rust_dry 0.55, 780beb2): red-lead share 0.088 at 64 (concept 0.079), the collar stands out more.
- Re-measured on the final shaders: tier-fade sweep 0 at 51-55 px/m then monotone (no pop); walk shimmer HF 1.024.
- Codex this iteration: 7 images (cop expressions, arena floor, King top view, phone frame, boss intro card, lamp
  post + its redo), 0 rejected for camera breaks (2 mild notes: edge-band crates and the megaphone bell show a hint of side); ledger
  total 41.

## Iteration 3 (23:09 -> 00:10) in one screen (`night_iter3_summary.png`)
- **Aged paper** (`item7_paper_age.png`, f871411): the mock is a warm sepia print, ours was a cool violet-grey. look_d5
  `age` warms only the low-chroma print, scaled by the D5 world amount. Medians at 64 px/m: street 76,70,78 ->
  **79,68,70** (mock 78,67,68), paper 231,222,204 -> **245,221,193** (mock 246,223,195). 0 px change at 32 px/m.
  Doctrine CIELAB dE (`tools/doctrine_de.py`): vermilion vs street 78.0 -> 74.6, teal vs street 56.5 -> 57.5. Rivet
  vs street dL (full stack) 0.166 -> 0.170 at 64 (the warm street is a hair darker).
- **Cast-shadow hatch** (`item8_shadow_hatch.png`, 5645ece): the 0.19 m bold strokes read as a hazard stripe at 64;
  period 5 / tint 0.36 / cov 0.42 reads as a hatched shadow (band L 0.441 -> 0.381, stripe energy -4% at 64, -9%
  at 32). A denser try (h41) was printed flat by look_d4 and rejected.
- Hero: wall-side crate stacks (h44); the project's `barrel_cluster` was rejected (it prints vermilion barrels).
- **Owner choice** (`item9_steel_owner_ab.png`): the concept's mauve steel is closer to the concept by eye and
  still reads (the cream rim carries the silhouette), but body vs street dL drops 0.166 -> 0.065 at 64 px/m
  (halfway: 0.115). Kept lavender (D4 parity: 0.168). Nothing committed for the A/B.
- **D5 street decals** (`item10_street_decals.png`, 300c1f7): 1 Codex sheet (0 rejected) -> 4 big decals at 96 px/m
  in `features/city/art/d5/decals/`: a stencilled union fist, STRIKE road paint, a chalk robot outline, a scorch.
  The large-surface D5 the brief asks for; they echo the mural roof. Vermilion/teal px identical at 32-96 px/m.
- **D5 roofs lifted** (`item11_roof_lift.png`, 2edef89): the D5 roofs were DARKER than D4 and further from the mock
  (mock roof L ~0.59 / 44% paper; D4 bar 0.457 / 26%; D5 bar 0.381 / 16%). A mid-tone density lift (d**1.8; ink,
  vermilion and the fist untouched) brings the bar to 0.439 / 25%, the mural to 0.471 (D4 0.501), grime kept.
- **Gameplay-zoom warmth, a proposal** (`item12_age_floor_32.png`, 9c98937): with the warmth only at D5 zoom, the
  32 px/m frame stays cool grey while the mock (which IS the gameplay frame) is sepia. `world.age_floor` (default 0,
  off: 0 px change) puts the aged paper at every zoom: at 32 px/m street 78,67,70 / paper 248,223,195 (mock
  78,67,68 / 246,223,195), paper-street dL 60.6 (= mock). The visual-engine lane and the owner decide.
- **Kill-cam at 128 px/m** (`item13_killcam128.png`, f9f956f): framed on the shot; the D5 tier's closest read of the
  concept (rust, hatch, inked joints, two-ink souls).
- Hero evidence frames are now h60 (h53 + part/soul grain locked to the sprite + the D5 LOCAL 9 union hall beside the
  mural, where the mock has its LOCAL 9 roof; 1 Codex roof edit, 0 rejected, per-roof lift 2.6: paper 32% = D4).
- **Rivet dialogue expressions** (`item5c_rivet_expressions.png`): 1 Codex sheet, 0 rejected, 4 x 512 px in
  `characters/art/d5/portraits/rivet_<expr>.png`; store-safe (owner review). At 64 px only angry and the tilts read.
  King: `king_{neutral,wary,furious,smug}.png` (1 sheet, 0 rejected; the cell prompted "commanding" shows a sideways
  glance and is named "wary"; cut to the template square so no gutter shows).
- **Finisher panels** (`item5d_finisher.png`): 3 Codex D5 comic splash panels (k9: in-game only, not store-safe) for the finisher moment, machines only
  (a police drone crushed, the light bar ripped off an empty cruiser, a police robot K9 cut by the torch), 1920 px in `features/combat/art/d5/`; not
  wired (combat lane).
- **Pan shimmer + screen-locked grain** (gap 7): the look_d5 world layer adds no swim on a 48 px/m camera pan; 93% of
  the pan swim comes from look_d4's screen-hashed grain (one-token fix for the visual-engine lane). The D5 part and
  soul shaders now hash their grain in sprite space.
- Codex this iteration: 7 images (decals, Rivet and King expressions, LOCAL 9 roof, 3 finisher panels), 0 rejected
  for camera breaks; ledger total 34.
- **Zoom colour drift, measured**: the zoom-tied warmth moves the paper by dE 2.8 (32 -> 48, the foot/car switch)
  and 7.6 (32 -> 64), the street by 2.0 / 4.7; with `age_floor` 1: <= 0.6. Hence gap 1's recommendation.
- New test `tests/unit/test_look_d5_params.gd`: every params key is a real uniform (a planted typo fails), the zoom
  blend is 0 at 32 px/m and monotone, age_floor defaults off. Gates: evidence tool ALL PASS at e0abd08 and again at
  5922a3d and 8d3a860 (the final tree: lint 13/13, unit 149/0, scenarios 8/0, selftest ok).

## Iteration 7 (03:12 -> 04:15) in one screen (`night_iter7_summary.png`)
No images (50/50 used). The open proposals were finished and measured as ONE package against the mock:
- **Committed, default frames**: STRIKE and the fist stencil inside the west lane (`item33`; d4 tier 0 px).
- **Committed, on with the thin print only**: the ruled roof hatch as zoom-fading overlays (`item42`; the mock's
  diagonal membrane hatch at 32/48, gone at 64, no pop).
- **Proposals (default off)**: look_d5_print + world grain (`item32`: pan 0.00814 -> 0.00049, roof -> 0) +
  street_edge (`item37`: road paint without ink rings); look_d5_halo, the ink line outside the sticker rim + a soft
  drop shadow (`item34`; fades with the halo, sweep-checked); rim width owner A/B (`item38`).
- **The package at 32 px/m** (`item35`, h124rf) vs the mock per tone class: street 80,69,71 (81,70,71), paper 0.30 /
  243,219,191 (0.33 / 245,222,195), solid ink 0.11 (0.12), mid 0.09 (0.11); readability held (rim dL 0.610);
  neutral up close (`item36`). In the D4 tier it needs heavier D4 roof lines (`item39`, `item40`).
- **Rejected** (restored, numbers in JOURNAL): wash_hi 0.15 (street lighter than the mock), age_floor 0.6,
  step_soft 0.10, dark_soft 0.20, shadow tint 0.22, no paper clean on the plates, the BAKED roof rule (`item41`).
- Reproduce the package from HEAD: masters `tools/package_shot.sh <round> [hero|arena]`.

## Iteration 10 (06:00 -> ) in one screen (`item50_ui_sharp.png`, `item50b_cards.png`, `item51_mip_audit.png`)
No images (50/50 used). The weakest item was 5 (the close-up portraits): they read soft in the dialogue and phone UI.
- **Proposal (HUD lane, default off): `look_d5_ui.gdshader`** for the mipmapped D5 UI art drawn at 0.3-0.85x: 4
  rotated-grid taps one mip finer + unsharp 0.5. Error vs a Lanczos reference: dialogue portrait 4.82 -> 2.53
  (200 px panel), 4.95 -> 2.82 (270 px, a 1080p panel), phone portrait 6.09 -> 4.77; works at any UI scale, unlike
  a pre-scaled set (the old NEXT 11). params JSON `ui` group; dev A/B `D5_UI=sharp` in `d5_hero.gd --dialogue / --phone`.
- **Guard (`item50b`)**: NOT for the 1920x1081 full-screen cards (finishers, boss intro, loading; no mipmaps): at a
  1280x800 window plain linear is best (3.00 vs 6.01 with the shader, 6.99 trilinear). `dev/showcase/d5_card.gd`.
- **Rejected**: the same sampling inside look_d5_part (`rgss`) for gap 5 (in-part hatch at 64 px/m): rig detail +7%,
  walk shimmer +4% HF, the rig 0.008 darker on the street; not kept.
- **Camera caveat (MEASURED)**: every dev scene snaps the world to whole screen px; the game camera
  (`city_view.gd:86`) does not. Snapped, a world-locked print does not change at all in a pan (all tonight's pan numbers);
  sub-pixel (`D5_SUBPX=1`), the 48 px/m pan over the mural roof flips 6.5% of px per tick under look_d4, 9.1% under
  the thin print and 14.5% with the package's ruled roof hatch overlays on (motion-compensated; `item53`). The
  overlays (1-px rules, no mipmaps) are most of it. A pixel-snapped world camera makes every print stable (0).
- **Rejected**: look_d5_ui on the roofs (`D5_UI_ROOF`): the package's roofs already match the mock's line energy at
  32 px/m (0.0926 vs 0.0935); sharper sampling overshoots (0.0982) and costs mid-tones.
- **Audit (`item51`)**: building_union_hall and the 4 street decals import without mipmaps (the other 6 plates and
  all D4 roofs with). Mips on the union hall: tone toward the mock, line energy away; on the decals they lose the
  spray dots and spatter. Imports kept; the city lane / owner sets one rule for D5 plates.

## Iteration 11 (`item54_rig_shadow_lock.png`)
- **Rig shadow strokes now RIG-locked (67c27a6, default; `D5_RIG_SHADOW_LOCK=world` = old)**: the world-locked
  strokes of item46b crawled under a walking shadow (a shower-door effect): in-shadow px flipping > 0.1 per tick at
  64 px/m 0.436, vs 0.184 rig-locked and 0.133 with no shadow. Stills: same density, stroke phase only. Script sync
  +0.0-0.03 ms (16 full rigs); GPU delta inside run noise. look_d5_shadow `anchor` (default 0: buildings, props unchanged).
- **NEXT 42 (sub-pixel camera) for the shadows**: the camera adds nothing to the rig shadow (world 0.437 / rig
  0.169 sub-px follow, same as fixed camera); prop shadows at 48 px/m sub-px: in-shadow flip 0.058 vs 0.045 without,
  mean change equal (0.0216 vs 0.0213). The pan claims for the shadows hold sub-pixel, with that small flip cost.

## Gap list after iteration 9 (package v9 = i9mot, vs `d4h2_mock.jpg`)
Iteration 9 had no image budget. It worked on gap 2 (mid-tones) with the existing plates (`item48_roof_membrane.png`).
1. **Mid-tones, closed at frame level for the package**: the mock's mid-tones sit in its paper areas, and its roof
   membrane is a mid tan with cream props (ours was cream on cream). The print keeps a mid tone only near look_d4's
   light/mid wash step, so the D5 plates now (package only) tone the membrane as 0.2-0.5 m tan blotches, fist wash 0,
   lines gamma 0.6 (union hall 0.8). Whole frame at 32 px/m: mid 0.09 -> 0.11 (mock 0.11), L 0.455 unchanged, ink 0.11;
   roof areas paper / mid / dark 0.712 / 0.102 / 0.186 -> 0.692 / 0.132 / 0.176 (mock 0.698 / 0.152 / 0.149). Actor
   read identical, pan 0.00000. NOT for the committed print (roof mid +0.009, frame darker): it rides with look_d5_print.
   Reproduce: `bash C:/Users/kazda/kiro/gtai-masters/night/d5-close/tools/package_shot.sh <round>` (v9 is the default;
   pre-v9: `D5_ROOF_SHADE=0 D5_ROOF_LIFT_B=0.45 D5_ROOF_LIFT_B_BY=union_hall:0.65 D5_FIST_WASH=0.18`).
   If the print is adopted, the committed plates become v9 with ONE command (masters, then commit the 7 PNGs):
   `D5_ROOF_LIFT_B=0.6 D5_ROOF_LIFT_B_BY=union_hall:0.8 D5_ROOF_SHADE=1 D5_ROOF_SHADE_MOT=1 D5_FIST_WASH=0 python tools/build_roofs.py`.
   Tried and rejected: the same tone on derived plates for the D4-only roofs (warehouse, long, helipad): under the
   thin print they already print mid-heavy and the tone lowers it (journal 05:37); lighter parapet-cap lines
   (`D5_ROOF_CAP_G` 1.6: roof dark 0.176 -> 0.172, no lever).
2. **Roof areas, what is left**: dark 0.176 vs the mock's 0.149, but most of that is the mask: our zebra (denser
   bars, street between them) falls inside the bright mask. Without the zebra box: v8 0.723 / 0.107 / 0.170, v9
   0.702 / 0.138 / 0.160 (paper / mid / dark), so 0.011 more dark than the mock, from our heavier parapet outlines. The membrane's hue is NOT a gap: its mid pixels' median is 174,154,138 vs the mock's 165,146,127 (r-b 36
   vs 38; a "violet-grey" impression by eye did not survive the measurement). Next: lighter parapet outlines on
   the next plates (Codex budget), judged on the same mask (masters work/i9/roofcls.py).
3. **Whole-frame L split** (package v9 0.455 vs mock 0.488 at 32 px/m; road = 41 px box blur of L below 0.40): road
   share 0.426 vs 0.366 (road L 0.313 vs 0.297), off-road L 0.560 vs 0.598. Re-weighted to the mock's road share, v9
   gives 0.470: about 0.015 of the gap is FRAMING, not the look. The roads are the same width (mock 247 px = 7.7 m if
   the mock is at 32 px/m, the art-direction camera; ours 253-262 px = 7.9-8.2 m); the mock's frame is 941 px = 29.4 m
   tall, our dev frames 800 px = 25 m, so the same road takes more of ours. (A 1672x941 render does not test it: the
   project's stretch mode keeps the vertical world extent and scaled px/m by ~1.18; discarded.) At a 1080p window
   the game shows 34 m at 32 px/m, so in play the road share sits nearer the mock's. The mock CROPPED to our 1280x800 framing (masters
   work/i9/mock_1280x800.png): L 0.475 / street 0.49 / paper 0.31 / ink 0.11 / mid 0.10 vs v9 0.457 / 0.50 / 0.29 /
   0.11 / 0.11: at equal framing the L gap is 0.018 (not 0.031), all of it paper tone (9.4) and about 0.024 is off-road tone (roof outlines and the building shadow strips, see 9.2).
   The committed frame (h149st) has road share 0.571 by this mask (its darker print joins pavements' edges into it).
4. **Paper highlights** (`item49`, in package v9): the print capped paper at CREAM (L 0.898); the mock's lit tops
   reach 0.90+ (0.128 of its off-road px, ours 0). look_d5_print `paper_hi` 1.0 prints sources lighter than cream
   lighter: 0.90+ bin 0 -> 0.044, paper median L 0.848 -> 0.852 (mock 0.867), mid and actors unchanged, no pan swim.
   Still open: our light-wash step (L ~0.75) holds 0.135 of the off-road px vs the mock's 0.034, but lightening it
   (wash_lo 0.22) costs the mid-tones (0.11 -> 0.08), and a soft ramp (look_d5_print `lo_soft` 0.10) gets closer
   to the mock's bin shape but darkens the paper median (0.852 -> 0.838) and blurs the roof blotches into smooth grey
   (rejected, journal). The light-tone spread is in the mock's ART (soft pencil greys), so it is for the next plates.
5. Items 1, 3-7 of iteration 8 stand.

## Gap list after iteration 8 (in-engine h139rs committed / h140all with every proposal, vs `d4h2_mock.jpg` and the concept)
Iteration 8 had no image budget. It worked where the remaining differences were visible by eye rather than in the
tone table: the up-close misprint (`item43`), grounding (prop, car and rig shadows: `item44`, `item46`) and the
mock's pavement clutter (`item45`). The iteration-7 list stands; changes:
1. **The package is still not adopted** (unchanged; NEXT 27). Reproduce it plus both owner options: `D5_FRINGE=1
   D5_DOTS=1 bash C:/Users/kazda/kiro/gtai-masters/night/d5-close/tools/package_shot.sh <round> [hero|arena]`
   (h153all / a31all, `night_iter8_summary`).
2. **Mid-tones** (unchanged, art): with this board's classes (`night_iter8_summary`), mock mid 0.104 vs package
   0.081 vs committed 0.049. The prop and rig shadows do not move it (0.048 -> 0.049): the gap is the roof interiors.
3. **Grounding** (NEW, closed in the dev scenes): every mock prop, car and actor sits on a pen-hatched shadow. Ours
   now do too: props and cars at every zoom (`item44`), rigs from 56 px/m where their halos go (`item46`). Next: the
   city lane gives props a shadow sprite (D5HeroPropShadow is the recipe), the characters lane moves D5RigShadow
   into CharacterRigs (one CanvasGroup per rig layer; the crowd atlas sprites already get it).
4. **The concept's red misprint** (NEW, owner A/B, `item43`): look_d5_part `fringe_k` 1.0 prints it along every
   steel segment's down-right edge from 64 to 96 px/m (cool steel only since `item43b`: never on cream gloves);
   Rivet's red share 0.018 -> 0.022 (concept body 0.039), pure vermilion unchanged. The colour doctrine says vermilion only on what matters, so the owner decides; default off.
5. **Up close, still open**: Rivet's steel value (concept mauve, darker; the owner kept lavender, `item9`); the
   concept's halftone stipple is now an owner A/B option (`item47`, `dots_k`, with the fringe = the riso-print
   signature); King has no rig (plan-view sprite). The D5 tier's own walk shimmer at 96 px/m (HF 1.13 vs D4) was
   measured for the first time tonight; at 64 it is 1.03.
7. **Cost** (NEW, measured): rig shadows as world-locked strokes without a CanvasGroup (`item46b`): +0.005 ms GPU
   median, p95 0.161, 0.29 ms script at 16 full rigs, 64 px/m, RTX 4090 (`d5-cost.json` "d5s"; the group version
   cost +0.07 to +0.18 ms with ~1 ms p95 spikes). The dev version mirrors a cached part list each frame; in production
   it belongs in rig_build (shadow sprites as part children, no per-frame copy). In motion (walk, D5/D4 HF) the
   shadow adds 1.026 -> 1.054 at 64 px/m and 1.131 -> 1.189 at 96: the silhouette edge sweeping over fixed strokes.
   A soft alpha edge does not help (tried, 1.054 / 1.188: the look_d4 print quantizes it), so it was reverted.
6. **Cones** (closed in the dev scene, `item44b`): a capsule shadow past the flat base plate instead of the plate's
   box. For the city lane: props on flat base plates need a shadow shape, not their silhouette.

## Gap list after iteration 7 (in-engine h106 committed / h115se1 with every open proposal, vs `d4h2_mock.jpg` and the concept)
Iteration 7 had no image budget; it finished the open proposals and measured them as one package. At 32 px/m the
package (`item35`, h115se1) matches the mock PER TONE CLASS: street median 80,69,71 (mock 81,70,71) at share 0.49
(mock 0.45), paper 0.32 / 244,220,192 (mock 0.33 / 245,222,195), solid ink 0.11 (mock 0.12; 0.14 before
`street_edge`, `item37`); committed h106 has ink 0.20 and paper 0.28. It pans
with no swim (48 px/m: junction 0.00049, roof 0.00000; shipped look_d4 0.00739 / 0.00975), keeps the actor read
(rim dL 0.610, vermilion dE 77.5, teal dE 57.6 vs h106 0.604 / 81.2 / 56.9), and is neutral up close (`item36`).
What still separates us, largest first:
1. **The package is not adopted** (all default-off): look_d5_print (dark-side edges + world grain + street_edge) with the
   ruled roof hatch overlays (`item42`), look_d5
   `age_floor` + `grain_floor` 1.0, the D5 roof plates' lines at gamma 0.45 (union hall 0.65; build_roofs.py env
   `D5_ROOF_LIFT_B=0.45 D5_ROOF_LIFT_B_BY=union_hall:0.65`), look_d5_halo line + shadow. Next: visual-engine lane +
   owner decide on `item35`; if the print is adopted, d5-close rebuilds the roof plates at 0.45 (one command) and the
   characters lane moves the halo pass into rig_build.gd `_halo`.
   CONDITION (`item39`): in the D4 tier (D4 roofs) the package under-inks at 32 px/m (solid ink 0.13 -> 0.07, mock
   0.12): the D4 roofs were drawn for look_d4's fattening print and their outlines go thin. Adopt the print with
   the D5 plates (D5 tier: 0.11) or with the d4-production lane's D4 roof lines weighted up: shown, `item40`, line
   weight k 1.0 (masters work/i7/d4_roof_lines.py) gives the D4 tier 0.11.
2. **Mid-tones**: the whole frame is still L 0.468 vs 0.488. Colour is matched (paper median 244,220,192 vs the
   mock's 245,222,195; street 80,69,71 vs 81,70,71, with `age_floor` 1.0; 0.6 was worse, h112af06). What is left is
   the mid-tone share (L 0.42-0.70): 0.08 vs the mock's 0.11 (h106 0.05): the print posterizes into paper / wash /
   ink steps where the mock keeps soft greys. Lifting the street is the WRONG lever (rejected h111wh15: street 0.332
   vs mock 0.290, readability down); so is a softer wash step (rejected h113ss10: mid 0.08 -> 0.09 but the paper
   darkens 0.856 -> 0.847). The mid-tones are in the mock's art (soft grey roof shading), so: next plates (Codex)
   with a mid-grey shading layer under the pen hatch, judged by these per-class numbers.
   Closest lever found: the ruled roof hatch under the thin print (`item41`: top-row mid 0.102 -> 0.118, mock
   0.128); mechanical at 64 px/m when baked, so it now ships as zoom-fading overlays (`item42`: full <= 48, gone at
   64, no pop). With it the package's paper share drops to 0.30 (mock 0.33): the next plates need a lighter base.
3. **Roof texture on the D4 neighbours**: the D5 plates show the mock's fine diagonal hatch under the thin print,
   but the D4 neighbour roofs (and the helipad, the arena's warehouse/long roofs) have no D5 plate. Next: Codex plates
   on the square-padded template (budget), or the d4-production lane's D4 set under the thin print.
4. **Stickers**: the outer ink line and drop shadow exist only on full rigs (`look_d5_halo`); baked crowd sprites
   (CrowdAtlas) would lack them. The mock's cream rim is also thicker than ours at 32 px/m. Next (characters lane):
   the halo pass in rig_build.gd + the same ring baked into the crowd atlas; a rim-width A/B at 32.
5. **Cream on cream** (owner, unchanged): zebra bars vs the sticker rim (`item27`); the outer ink line (`item34`)
   now separates the two where they touch, which may settle it without toning the zebra.
6. **Up close (D5 proper)**, unchanged since iteration 5: the 128 kill-cam and the arena at 64 are the closest
   frames to the concept; King needs a rig and a King-tuned part print.
Reproduce the package frame from HEAD: `bash C:/Users/kazda/kiro/gtai-masters/night/d5-close/tools/package_shot.sh <round> [hero|arena]`
(rebuilds the roof plates, sets the floors, shoots with D5_PRINT=thin D5_HALO=ink D5_HALO_SHADOW=1, restores the tree;
h117pkg = h115se1, 0 px).
Closed this iteration: gap 7 of iteration 6 (STRIKE on the centre line, `item33`), the "fix the screen grain first"
dependency of the floors (now inside look_d5_print, `item32`), gap 5's outer line (as a proposal, `item34`).

## All proposals together (`item31_all_proposals_32.png`, not committed)
The committed iteration-6 frame plus every open proposal (look_d5_print as the world print, `age_floor` and
`grain_floor` at 1.0, the D5 roof plates' lines at gamma 0.45, union hall 0.65) at 32 px/m. Whole frame L / px
darker than 0.35 / median RGB: h86 0.410 / 0.682 / 76,70,79; h98b 0.425 / 0.652 / 77,71,79; all proposals **0.472 /
0.556 / 87,75,76**; mock 0.488 / 0.509 / 96,84,83. By eye it is the closest frame to the mock tonight. Adopting it
is the visual-engine lane's and the owner's call (NEXT 21, 26).

## Gap list after iteration 6 (in-engine h98b vs `d4h2_mock.jpg` and the concept; next step each)
What changed: the GROUND now prints like the mock's at 32/48 px/m (faint slab joints, clean zebra, no repeating
cracks, bold dashes, the kerb stone). Whole frame at 32 px/m (d5 tier): L 0.410 -> 0.425, px darker than 0.2
0.231 -> 0.218 (mock 0.488 / 0.123). What still separates us from the target, largest first:
1. **Colour and grain at gameplay zoom** (was gaps 1 + 7): cool grey and a flat street vs the mock's warm sepia and
   mottled asphalt. Both fixes exist as default-off look_d5 proposals: `age_floor` + `grain_floor` at 1.0 give a
   street median of 80,69,71 (mock 81,70,72), with readability held (`item26`). Next: the visual-engine lane + owner
   switch them on (or move the gains into look_d4), and fix look_d4's screen-locked grain (gap 7) first, because
   the lighter ground now shows more paper, and paper is where that grain swims.
2. **Roof texture** (gap 2): at 32 px/m a roof keeps the mock's tone OR thin visible hatch lines, not both (HF
   0.11-0.14 vs the mock's 0.163). Root cause found: look_d4's Sobel inks BOTH sides of a thin line (1 px -> ~3 px).
   PROPOSAL `assets/shaders/look_d5_print.gdshader` (`item29`, 22eba5b) = look_d4 + edge ink on the dark side only:
   the D4 tier's 32 px/m frame goes L 0.438 -> 0.487 (mock 0.488), dark px 0.65 -> 0.57 (mock 0.51), the mural roof
   0.531 / 0.29 / 0.39 -> 0.595 / 0.34 / 0.29 (L / paper / ink; mock roof 0.594 / 0.36 / 0.25); on a 48 px/m pan ink
   flips -58 to -70%; actor read unchanged (rim dL 0.575 -> 0.576, teal dE 41.3 -> 41.4). HF does not rise (0.111). Next (visual-engine): adopt or reject it
   for look_d4 (numbers at dark_soft 0.04; the committed 0.10 keeps thin outlines firmer, 32 px/m L 0.474 vs 0.483,
   `item29c`); if adopted, the D5 roof plates need their line weight retuned (they were lifted for the fattening
   print and go too light: mural 0.603 -> 0.667). Retune shown (`item30`, not committed): plate lines gamma 0.7 ->
   0.45 under the thin print, mural L 0.643 / paper 0.44 / ink 0.24 / HF 0.093 -> 0.105: the first frame tonight where
   a roof shows the mock's fine diagonal hatch AND a light tone at 32 px/m. One D4 neighbour
   (helipad) and the arena's warehouse/long roofs have no D5 plate yet (Codex, square-padded template).
3. **The ground tiles are D5-tier only.** The 4 print-aware tiles (`features/city/art/d5/ground/`) are swapped in
   by the hero scene alone; the city and the D4 tier still print the black slab grid. Next (city / d4-production
   lanes): adopt them, or apply the same three build rules (masters `tools/build_sidewalk.py`, `build_crossing.py`,
   `build_road.py`) to the D4 set; they are deterministic and documented in their headers.
4. **Cream on cream** (OWNER): the zebra bars are the same cream as the actors' sticker rim (D4 and the mock alike);
   where Rivet's arm lies over the crossing the rim touches a bar. The dashes were toned a step down for this
   (`item25`); a toned zebra would leave the mock's look. Owner's call: `item27_zebra_owner_ab.png` (x0.84, the
   dashes' tone: Rivet's rim and arms separate from the bars, the crossing still reads; not committed).
5. **Characters at 32 px/m**: the mock's characters carry a dark outline OUTSIDE the cream rim; ours have the rim
   straight onto the street. At 32 px/m the rim still reads (rim vs street dL 0.58), but against the cream zebra and
   pavement only the inner ink line separates. Next (characters / visual-engine): an outer ink hairline on the rig's
   sticker pass, A/B at 32 on the crossing.
6. **Up close (D5 proper)**: unchanged since iteration 5: the 128 px/m kill-cam and the arena at 64 are the closest
   frames to the concept; King needs a rig and a King-tuned part print (gaps 8-9 of iteration 4).
7. **Street decals on the centre line**: STRIKE sits on the centre line, so a bold dash now shows between its letters
   at 48 px/m (reads as paint on paint). Next (city): place road paint inside a lane.

## Gap list after iteration 4 (what still separates in-engine from d4h2_mock and the concept, next step each)
Items 1-8 are the iteration-3 list with iteration-4 updates; 9-11 are new.
1. **Gameplay-zoom colour.** The mock (= the 32 px/m frame) is warm sepia; ours is cool grey at 32 and warms only
   with the D5 zoom. Zoom-tied warmth also DRIFTS while the camera zooms: paper dE 2.8 on the foot (32) <-> car (48)
   switch and 7.6 from 32 to 64 (street 2.0 / 4.7); with `age_floor` 1 the drift is <= 0.6 everywhere
   (`item12_age_floor_32.png`). Next: the visual-engine lane + owner switch `world.age_floor` to 1 (or move the
   gains into look_d4's palette). Recommended.
2. **D4 roofs are ink-heavy.** Mock roofs: mean L ~0.59, 44% paper. D4 neighbour roofs at 32 px/m: 0.498, 28%.
   The D5 landmarks are now at D4 parity (bar 0.439 / 25%) after the d**1.8 lift. Next (d4-production / city):
   the same mid-tone density lift (`build_roofs.py` LIFT) on the D4 roof set, gated against the grime/detail loss
   seen at 2.2. Tried on temporary copies (`item14_d4_roof_lift_proposal.png`, nothing committed): OSHA 0.482 ->
   0.538 L, paper 26% -> 38%. What is left is the roofs' thick hatched border ring (roof art).
   Iteration 5: the D5 roofs are now ABOVE D4 and at the mock's tone on the mural (pen-hatch plates, see above);
   OSHA and tall have D5 plates. Remaining: TEXTURE. At 32 px/m HF 0.11-0.14 vs the mock's 0.163: through look_d4
   a roof keeps the mock's tone OR visible hatch lines, not both (the print fattens any line that survives
   minification). Next (visual-engine): a roof print that keeps thin art lines thin; (city): adopt the 7 D5 plates,
   pad non-square roofs (warehouse) to a square template.
3. **Pavement grid.** Ours: a hard white slab grid with black joints; the mock: soft, irregular slab joints. Next:
   city lane's pavement tile (the D5 sidewalk tile helped only marginally). Iteration 3 tried softening the D5
   tile's joints (h55): the look_d4 print re-inks them (dark px 25.3% -> 23.9%), reverted. The joint weight lives in
   look_d4's print thresholds or needs a thinner-jointed tile.
   Iteration 6: CLOSED for the D5 tier by a print-aware tile (joints at light-wash density, `item22`); the crosswalk
   and road cracks too (`item23`). Next (city lane): adopt the 4 D5 ground tiles (`features/city/art/d5/ground/`) or
   apply the same build rules (masters tools/build_sidewalk.py, build_crossing.py, build_road.py) to the D4 set.
4. **Lamp post** read as a spoon lying on the pavement (mock: kerb base + curved arm + round head). Iteration 4: a D5
   plan-view lamp (`features/city/art/d5/props/lamp_post.png`, 1 Codex image) on the kerb with its arm over the
   street in the hero's d5 tier (`item20_lamp.png`); a first riveted head printed as a gear ring and was redrawn as a
   plain cap (h72). Next (city lane):
   adopt it for the D4 prop too (rotated so the arm reaches over the street) or redraw the D4 lamp to this plan.
5. **Parapets / building height.** The mock's roofs read as raised slabs. Iteration 4: the hero scene's ink foot
   (`D5HeroParapets`, `item16_parapets.png`) gives the lip -> ink -> hatch profile of the mock. Next (city lane): put
   the 0.22 m ink core in the roof/shadow quads of the city (street-facing south/east edges only, not the alleys).
6. **Rivet's steel** is light lavender (D4 contrast parity) vs the concept's dark mauve: owner choice
   (`item9_steel_owner_ab.png`: mauve costs 61% body contrast; the cream rim still carries the silhouette).
   Iteration 4 applied the same logic to the world King sprite (saturation 42 -> 15). The close-up art keeps the
   concept's mauve (portraits 34-39, phone 34, loading 24): world = printed lavender-grey, close-up = mauve.
7. **Screen-locked grain in look_d4 (found iteration 3, not mine to change).** `look_d4.gdshader:96` hashes its 5%
   print grain on screen pixels, so every camera move re-rolls the grain over the static world (TV-static swim).
   Car-camera pan test (`dev/showcase/d5_pan.gd`, 48 px/m, world-locked crop): frame change 0.00709 per tick; with
   the grain hashed on the world coordinate `w` (temporary edit, reverted) 0.00049 (-93%). The look_d5 layer adds 0
   (0.00696 vs 0.00709). Next (visual-engine lane): `hash(floor(FRAGCOORD.xy))` -> `hash(floor(w))`. The same
   pattern is in `look_d4_item.gdshader:28` (6% grain) and its ghost halftone `dots(px, ...)` (screen-locked dots on
   moving items, vehicles and ghosts): lock them to the sprite (as look_d5_part / look_d5_soul now do, 5522ce5 and
   the soul fix). The D5 shaders have no screen-locked noise left.
8. **Up close D5 works**: at 96-128 px/m (kill-cam, `item13_killcam128.png`) the part rust, hatch, form shade and the
   two-ink souls read like the concept. Iteration 4 put the dialogue panel (`item17_dialogue.png`) and a boss arena
   with a static King (`item18_arena.png`) in-engine. Still missing: a King RIG (the sprite is one static plan view;
   the characters lane needs King parts on the rig layout) and a King print ramp (look_d5_part's ramp is Rivet-tuned);
   the real dialogue/phone UI (HUD lane: mipmapped or pre-scaled portraits).
9. **King is a static sprite.** `king_top.png` is one plan view (desaturated to the cast's steel); a boss fight needs
   King PARTS on the rig layout (characters lane: the layout-template technique that made the Rivet D5 parts, with
   `king_top.png` + the turnaround as identity refs) and a King-tuned part print (look_d5_part's ramp washes his
   steel to white, a7).
10. **Shadow `zoom` and the city.** look_d5_shadow now needs the camera zoom (strokes ~10 screen px above 64 px/m)
    and takes a sprite's alpha (character shadows). Next (visual-engine / city lanes): set `zoom` from the camera
    wherever the shadow quads land; decide whether bosses (and cars) get a hatched cast shadow like King's.
11. **Arena floor = one asset.** `king_arena.png` is a single 12 m floor; a real arena needs its walls/edges and
    spawn doors in the same hand (city lane), and the crown stencil must stay dimmed (cream under the cast swallows
    the sticker rim, a1).

## Iteration 2 (22:14 -> 23:10) in one screen
- Best frame now: `hero-d4d5-<ppm>ppm.png` = round h38 (h33 + the soul print + the steel lift) (item4 board `item4_hero_vs_targets.png`): blocks filled with
  D4 neighbour roofs, rounded kerb corners + kerb shadows, a parked cruiser/sedan, the shot (flash, tracer,
  casings), ink splat, manhole/grate/skids/oil, the D5 teal soul trail, and the form-shaded D5 cast.
- Shader: look_d5_part form shade (steel and vermilion plates), derivatives moved to uniform flow; look_d5 street
  hatch at 40% for the 48 px/m car camera; look_d5_soul (new, tier-faded soul print). Params in look_d5.params.json (`shade_px`, `shade_k`, `lit_k`,
  `verm_shade`, `street_hatch_car`).
- Measured (was unmeasured): GPU cost of the D5 tier (`d5-cost.json`), walk shimmer re-run after each shader change.
- Rejected this iteration: 9 px form shade with steel darkening (contrast), look_d4_item ghost print for the souls
  (dot mesh), 0.32 m bold kerb shadow (hazard stripe), brighter lit rim (no effect), a cream mural fist (would kill the
  figure/ground), a hard-snap soul print (speckles at 32 px/m), an inner kerb joint arc (floats). Codex: 1 soul sheet + 1 loading illustration; 0 rejected (ledger total 27).
- Item 5b: a D5 LOADING illustration (`item5b_loading.png`, installed at `features/menus/art/d5/loading_rivet.png`,
  1920x1081): Rivet on a wet crosswalk under an ink union-fist mural, the teal souls rising, a cruiser; vermilion only
  on the collar, rust and the light bar; the left third left calm for loading text. Marked store-safe (owner review).
- The dL miss is CLOSED: STEEL_HI +0.015 (r21): cast vs street dL at 64 px/m D5 0.1693 vs D4 0.1695 (parity), 96: 0.190
  vs 0.181; 0 px at 32-56. (verm_shade 0.5 was tried first and moved it only 0.0006: the loss came from the
  derivative fix, not the vermilion hatch.)

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
   at 64 px/m; drawn as-is on the actor layer they match the mock's soul trail. Then `look_d5_soul.gdshader` (h37,
   the hero default; `--soul=<d5|raw|ghost>` keeps the A/B): snaps the art to two teal inks + the cream rim + grain.
   Crisper at 64 px/m, but at 32 px/m the snap busied the minified art (fine-detail energy 0.0613 drawn / 0.0659 hard
   snap h34 / 0.0650 soft h35), so it rides the D5 tier fade (`amount`, 56 -> 64 px/m): 0 px vs the art as drawn at
   32 and 48, the full print at 64 and 96. Next (fx lane): adopt look_d5_soul (or its idea) instead of the dot screen.
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
   0.181. A brighter lit rim (lit_k 0.75) did not move it (reverted). Closed by a +0.015 STEEL_HI lift (r21: 0.1693 vs
   D4 0.1695 at 64, 0.190 at 96).
6. **The whole slice cast now has a D5 tier** (Rivet, cops, peds). The ped costs 6% contrast on cream pavement at
   64 px/m (0.373 -> 0.351). Iteration 2 re-measure (a different mask: the tier footprint on the rows where the cream
   pavement dominates, so not comparable with 0.373/0.351): |dL| vs pavement at 64 px/m D4 0.411, D5 before the form
   shade 0.408 (r14b), with it 0.422 (r21); at 96: 0.409 / 0.399 / 0.406. The form shade closed the ped gap at 64. Next: King and the boss cast need rig parts first (they exist only in the spike).
7. **The world print layer is subtle** (its fibre tooth read as rain and was replaced by an isotropic mottle). look_d5 adds paper tooth, ink ghosts and a mid-wash hatch; on this scene
   there is little mid wash, so its main visible effect is grain. Iteration 2, on the roof-heavy hero frame (h33 vs
   h33nw = the same scene with zoom_amount zeroed, roof crop): mean |diff| 0.004 / 0.013 / 0.012 at 48 / 64 / 96,
   mean L -0.003, and the roofs' fine-detail energy DROPS 5% (0.140 -> 0.134 at 64: the off-register ink ghost
   softens the edges) while the mural's grey wash gains a pen hatch. Judged neutral-to-positive by eye on an
   already busy surface; kept. Next: hand `zoom_amount` to the visual-engine lane's profile table.

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
