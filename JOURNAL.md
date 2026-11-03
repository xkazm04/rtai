# JOURNAL: night lane d5-close (branch n-d5)

## Iteration 1 (2026-11-02, BUILD, 21:10 -> 22:40)

- 21:10 read: AGENTS, shaders README, d4 manifest, characters README, print_part, F-09b frames, concept.
  Base: ad2078b (F-14 merged). No build/evidence in this worktree yet.
- 21:20 Codex: 4 D5 Rivet sheets queued serially (edit of the D4 parts-v2 sheets = same layout, + the concept as
  style ref). Masters: gtai-masters/night/d5-close/gen/. Prompt: gen/_prompts/rivet_base.txt + one line per sheet.
- Plan for the swap (item 1): D5 parts are installed at features/characters/art/d5/rivet/ with the SAME file names,
  sizes and parts.json as art/rivet/, and their alpha is the D4 alpha (silhouette lock) so the 64 px/m switch can
  only change the inside of a part, never its outline or the sticker halo -> no shimmer at the switch by
  construction. The swap is a texture + material swap per sprite (no new nodes).
- 21:16 MILESTONE item 1: 4/4 D5 Rivet sheets accepted (0 rejected; layout and plan view held). slice_d5.py cuts
  the D5 sheet with the D4 sheet's geometry (stretch within 2.3%) and gives each part the D4 alpha.
- FRICTION: the project's default canvas filter is linear WITHOUT mips, so the detailed D5 art aliased into speckle
  (r1-r3). Fixed by sampling the D5 parts with mipmaps. Also, an early "steel lift" edit silently failed to apply
  (string mismatch); caught at 21:33 when a measurement did not move. Lesson: verify edits by measurement.
- 21:20 a texture swap at 64 px/m popped the tone and moved the outline by 1 px (switch56_panel.png). Replaced by
  OVERLAY sprites faded 56 -> 64 px/m: 0 changed px at 32/48/54/56 (measured).
- 21:33 MILESTONE item 1 gate: D5 at 64 px/m reads closer to the concept (lavender steel, rust, ink, off-register
  vermilion), and Rivet vs street dL is 0.192 vs D4 0.174.
- 21:25 MILESTONE item 2: look_d5.gdshader world layer + look_d5.params.json. REVERTED the first tuning (r7: the
  street hatch read as rain and hurt the dark field the characters sit on); the hatch now lives only in the mid wash.
- 21:30 MILESTONE item 3: 4 D5 landmark roofs (Codex, 0 rejected). REVERTED the vermilion fist mural: at 48 px/m
  it competed with the cops (7.2% vermilion) -> re-inked to wash + thin off-register edge (0.43%).
- 21:35 MILESTONE item 4: hero junction scene (d5_hero.gd), cam on the mural corner, + hatched cast-shadow
  proposal. Gap list in evidence/README.md.
- Shared files touched (minimal): docs/decisions.md (2 DECISION lines), features/characters/character_rigs.gd
  (+4 lines: the tier hook), cut_rig.gd (+is_tinted, +on_tint call), steam/ai-provenance (append-only).
- 21:37 item 5: portraits started (Rivet accepted).
- 21:42 FRICTION: a portrait chain started with a shell `&` looked dead (ps showed no codex) but ran, in parallel
  with the tracked re-launch: each portrait was generated twice (ledger 21:37-21:40), which briefly broke "one codex
  at a time". The installed files are the last writes, reviewed in item5_portraits.png. Cost: 3 extra images. Only
  use run_in_background from now on; check with `tasklist`, not ps.
- 21:41 MILESTONE item 5: 3/3 portraits accepted (0 rejected), installed at characters/art/d5/portraits (512 px).
- 21:42 hero scene + props (h9). Gap-6 cop D5 sheets + gap-5 bold Rivet re-ink queued (7 images).
- 21:45 MILESTONE gap 6: D5 cops (3 sheets, 0 rejected). FOUND: the cop head prints with palette swap 4
  (ink->vermilion); a D5 overlay would have blacked it out at 64 px/m -> overlays skip swapped parts (+ test).
- 21:48 REVERTED: bold-hatch re-ink of the 4 Rivet sheets (gap 5 attempt). The hatch still mipped away at 64 px/m
  and the wider rust diluted the collar. Kept the fine set; instead rust prints as dried rust (VERM->INK 0.42)
  and only coarse-mip-coherent vermilion (the collar) prints pure: 1614 -> 739 pure px at 96 px/m.
- 21:52 evidence tool (--no-parity --no-bench) all PASS at f2c7654. FRICTION: it refuses a dirty tree; the
  untracked evidence/*.png have to be moved aside for the run.
- 21:56 look_d5_shadow.gdshader: hand-hatched cast shadow (world-locked wobble, pressure, broken strokes).
- 21:57 peds D5 (gap 6b) in progress.
- 22:00 D5 peds (3 sheets, 0 rejected; -6% contrast on cream pavement at 64 px/m, kept). D5 sidewalk tile (seamless
  by a spliced D4 border; marginal gain). look_d5 tooth: the anisotropic fibres read as rain -> isotropic mottle.
- 22:05 hero scene shoots 96 px/m kill-cam; evidence/hero-d4d5-96ppm.png is the night's showcase frame.

## Summary (iteration 1)
- Images: 25 Codex (ledger: masters night/d5-close/gen/ledger.tsv). 0 rejected for camera breaks. In-engine
  rejections/reverts: vermilion fist mural (re-inked), 4 bold Rivet re-inks (reverted), the street hatch (r7),
  the fibre tooth (rain), the texture-swap tier (replaced by overlays).
- Gates: lint 13/13, unit 146/0, scenarios 8/0, evidence tool PASS (parity/bench not run: no native build here).

NEXT:
1. Visual-engine lane: read `project/assets/shaders/look_d5.params.json`. Drive look_d5's `amount` from zoom_amount
   and put the look_d5 layer over look_d4 in the city (it is only wired in dev/showcase today).
2. City lane: place a `look_d5_shadow` quad per building (offset 1.1 m down-right); decide on the D5 landmark roofs
   (`features/city/art/d5/roofs/`) and the D5 sidewalk tile. Nothing in the city uses them yet: data
   (city_textures.json) is not touched.
3. The D5 in-part hatch still mips away at 64 px/m (bold re-ink did not help). Try a hatch MASK channel: Codex
   draws hatch-only sheets, and look_d5_part re-draws them as screen-res strokes where the mask is set.
4. King/boss rigs: no rig parts in the project yet; the D5 portrait exists (characters/art/d5/portraits/king.png).
5. Owner review: portraits marked store-safe; D5 rust/vermilion budget on Rivet (739 pure px at 96 px/m).
- 22:09 selftest colour count at 48 px/m varies run to run on the same commit (65, then 73; 71 at f2c7654): noise
  of the windowed selftest, not a regression (the D5 tier is off below 54 px/m and the city references no D5 file).
- 22:10 look_d5 sparse street hatch at 64 px/m+ (kept: dL 0.091 -> 0.095). Final panels from h17. Deleted 16
  unreferenced frame rounds (484 MB -> 237 MB); kept every round cited in the ladder / README.
- UNMEASURED: motion shimmer (walk + zoom tween) of the D5 tier, and the GPU cost of the overlays + look_d5 layer.
  Both are in evidence/README.md with the next step.
- 22:14 MILESTONE tier-fade sweep (d5_sweep.gd): 0 up to 55 px/m, monotone ramp to 0.066 at 64+: no pop.
- 22:16 MILESTONE walk shimmer (d5_walk.gd): D5/D4 frame-to-frame change 1.06 total, 0.97 high-frequency = no shimmer. Still unmeasured: GPU cost.

## Iteration 2 (2026-11-02, BUILD, 22:14 -> )
- 22:14 read journal/log. All 5 items evidenced in iter 1; picking the weakest: item 4's hero frame was empty street
  next to the mock (gap 2).
- 22:17 Codex: 1 D5 soul sheet (d5_souls: 4 robot souls + 4 vapour wisps, teal only, layout template + mock soul
  trail crop + concept). 0 rejected (plan view held). Ledger total 26.
- 22:19 MILESTONE gap 2: hero scene street life (387e9fa). D5HeroExtras loads keyed sprites from masters
  borrowed/ via `--borrow=`: a cruiser + a dark sedan + muzzle flash/tracer/casings/ink splat from the d4-production
  lane's RAW sheets (read-only, not installed: their lane owns vehicles/fx), and the D5 soul trail. Rejected the grey
  sedan (vermilion tail lights = doctrine noise). Rounds h18 (flash hidden under the cop, souls small) -> h19 -> h20.
  Board: evidence/item4b_street_life.png (before h17 / after h20 at 32/48/64 + mock + concept).
- 22:27 MILESTONE: GPU cost measured (fae2c24, d5_cost.gd): 16 full rigs at 64 px/m, RTX 4090: D4 0.083 ms,
  +parts 0.137, +world 0.158 (runs 2-3); run 1 read 0.208/0.270/0.335 (kept as the spread).
  FRICTION: a parse error in a -s-loaded run script hangs the launcher (null node, no quit) until timeout: run new
  dev scenes with a short timeout first.
- 22:31 MILESTONE item 1 quality: look_d5_part form shade (screen-lit hatched lower-right band + cream lit rim).
  Rounds r14 (7 px, timid), r15 (9 px + STEEL_LO: dL 0.156 < D4 0.170 -> REJECTED), r16 kept (dL 0.170 = D4 at 64,
  0.189 at 96; 0 px at 32-56). Walk shimmer re-measured with tools/shimmer.py: 0.988 -> 1.018 high-frequency.
- 22:34 MILESTONE souls print A/B (h20 world print: teal fill lost; h21 look_d4_item ghost=1: dot mesh, REJECTED;
  h22 as drawn on the actor layer: matches the mock) -> as drawn is the hero default, `--soul-print` keeps the A/B.
  h23 = h22 pixel-identical (determinism). Unit 146/0 at a40ac96. Boards: item4 (h23), item4c, ladder +2 rows.
- 22:37 MILESTONE gap 3: look_d5 street hatch at 40% for the 48 px/m car camera (street_hatch_car); h24 vs h23:
  0 px at 32/64, street median unchanged, street HF +3%. Kept. Hero evidence frames now h24.
- 22:40 MILESTONE gap 4 (part): kerb shadow strips in the hero scene (look_d5_shadow, 0.18 m, tint 0.55). h25 (0.32 m,
  bold strokes) REJECTED: read as a hazard stripe. Kept h26; hero evidence frames now h26.
- 22:39 MILESTONE gap 4: rounded kerb corners (d5_hero_kerbs.gd, procedural, d5 tier). h27 had the hydrant on the
  arc and the kerb shadow running into the cut corner -> h28 fixed. Scenarios 8/0 at 92eb0e5. Hero frames now h28.
- 22:44 MILESTONE item 4: blocks filled with 12 D4 neighbour roofs (0.4 m alleys, cast shadows) + ground extended to
  +-28 m (h29). FRICTION again: a duplicate `var n` parse error = the launcher hangs/does nothing (exit 0!) - the
  shoot script greps SCRIPT ERROR, so watch for it. Item 4 board + hero frames now h29.
- 22:50 gates: evidence tool (--no-parity --no-bench) ALL PASS at 0c1c17a: lint 13/13, unit 146/0, scenarios 8/0,
  selftest ok (19 untracked evidence files moved aside for the run and restored).
- 22:52 MILESTONE: form shade over vermilion plates (verm_shade 0.7) + derivatives moved to uniform control flow.
  Fixed-mask dL at 64: D4 0.170 / D5 0.167 = marginal MISS (0.003 < 1 grey level), documented, kept for the visible
  gain on the cops. lit_k 0.75 had no effect (reverted). Hero frames now h31.
- 22:56 re-measured on 187b58d: unit 146/0; walk shimmer HF 1.022; GPU cost (high-baseline state) D4 0.209 /
  parts 0.273 / +world 0.338-0.357 ms. evidence/d5-cost.json = cost5.
- 22:54 EVALUATED, NO CHANGE: at 64 px/m the D4 mural looked like a stronger fist than the D5 grey-wash fist. Measured
  fist vs a ring around it (D5 fist mask): D4 -0.052, D5 -0.234 (a dark figure on a lighter ground, the strongest);
  a cream D5 fist (wash base 0.0) would be 0.006 = no figure. Kept the D5 mural as is. Eye impression was wrong.
- 22:55 street decals borrowed from d4-production's raw decal sheet (manhole, drain grate, skid marks, oil stain;
  the green puddle skipped: unkeyable). h32 had the grate under the soul trail -> moved (h33). Hero frames now h33.
- 22:58 MILESTONE item 5b: D5 loading illustration (Codex 1 image, 0 rejected, ledger 27) installed at
  features/menus/art/d5/loading_rivet.png + provenance + manifest. Store-safe (owner review pending).
- 22:59 gap 7: world layer on/off on the roof-heavy hero (h33nw = zoom_amount zeroed via a temporary params edit,
  restored, git diff clean): |diff| 0.013 at 64, roof HF -5% (ink ghost softens), the mural wash gains hatch. Kept.
  Item 1 gate board rebuilt from r19 (D4 vs D5 tier at 32/48: 0 px). Deleted frame scratch cost1, h30, r17, r17b.
- 23:03 MILESTONE: look_d5_soul.gdshader (soul print: two teal inks + cream rim + grain). h34 hard snap speckled at
  32 px/m (HF 0.0659 vs drawn 0.0613); h35 soft ramps still +6% -> the print rides the D5 tier fade (h37): 0 px vs
  drawn at 32/48, full print at 64/96. Hero default `--soul=d5`. Hero frames now h37.
- 23:04 gates: evidence tool ALL PASS at 68e85b4 (lint 13/13, unit 146/0, scenarios 8/0, selftest ok).

## Summary (iteration 2)
- Images: 2 Codex (d5_souls, d5_loading_rivet); ledger total 27. 0 rejected for camera breaks.
- Kept: hero street life (borrowed D4 vehicles/FX/decals + D5 souls), filled blocks, kerb shadows, rounded kerb corners,
  look_d5_part form shade (steel + vermilion), uniform-flow derivatives, look_d5 street hatch at 48, look_d5_soul,
  the D5 loading illustration, GPU cost + shimmer measured.
- Rejected/reverted: 9 px darkened form shade (contrast), ghost dot print for souls, bold 0.32 m kerb shadow (hazard
  stripe), lit_k 0.75 (no effect), cream mural fist (evaluated, no change), hard soul snap at 32 px/m.
- The dL miss was closed after this summary (23:05, r21: STEEL_HI +0.015 -> 0.1693 vs D4 0.1695).
- Shared files touched: none new this iteration (steam/ai-provenance append-only, art_src/d5.manifest.json).

NEXT:
1. Visual-engine lane: read look_d5.params.json (new: part.shade_px/shade_k/lit_k/verm_shade, world.street_hatch_car);
   drive look_d5 `amount` from zoom_amount in the city (still only wired in dev/showcase).
2. City lane: city_textures id 10 `curb_corner_tone` has no art; `dev/showcase/d5_hero_kerbs.gd` is the geometry
   (1.6 m quarter circle, ink kerb arc) and `_kerb_shadows` the 0.18 m look_d5_shadow strips. Fill blocks with
   neighbour roofs (0.4 m alleys) as in the hero scene; the pavement slab grid should curve at the arc.
3. FX lane: adopt `look_d5_soul.gdshader` (tier-faded) instead of look_d4_item's ghost dot screen for souls; the D5
   soul sheet is in masters gen/out/d5_souls.png (keyed cells in borrowed/).
4. When vehicles/fx/decals install their sprites, point D5HeroExtras at res:// and drop `--borrow`.
5. (done 23:05: STEEL_HI +0.015 restored dL parity at 64 px/m.) Next on Rivet: the in-part hatch still mostly mips
   away; the form shade carries the volume now.
6. Owner review: the loading illustration and portraits (store-safe marks), Rivet's lavender steel vs the concept's
   darker mauve (we keep it light for contrast on the charcoal street).
- 23:05 MILESTONE: dL parity restored at 64 px/m (r21, STEEL_HI +0.015: 0.1693 vs D4 0.1695); verm_shade 0.5 (r20)
  moved it only 0.0006 and was not kept. 0 px at 32-56.
- 23:06 hero final round h38 (steel lift; 0 px vs h37 at 32/48); item4 board + hero frames = h38.
- 23:07 gates ALL PASS at e8e128c. Ped contrast on pavement re-measured: 64 px/m D4 0.411 / D5 0.422 (was 0.408 before the form shade); 96: 0.409 / 0.406.
- 23:08 REVERTED: an inner kerb-stone joint arc at the rounded corners (h39) floats (the straight kerbs have no matching joint) and crosses the hydrant. Worse; reverted.
- 23:08 iteration 2 end: tree clean (21 untracked evidence PNGs by design), last gate run ALL PASS at e8e128c (later commits are docs only). NEXT above stands.

## Iteration 3 (2026-11-02, BUILD, 23:09 -> )
- 23:09 read journal/log/evidence. Weakest visible gap vs d4h2_mock now: colour temperature. Mock medians street
  78,67,68 / paper 246,223,195; ours 76,70,78 / 231,222,204 (cool violet-grey vs warm sepia).
- 23:12 MILESTONE: look_d5 `age` (aged paper, f871411): low-chroma print warms by an L-interpolated gain, x amount.
  h40 at 64: street 79,68,70 / paper 245,221,193 (= mock). 0 px vs h38 at 32 (d4 and d5 tiers), deterministic
  (d4 frames 0 px vs h38). Doctrine dE (tools/doctrine_de.py): verm-street 78.0 -> 74.6, teal-street 56.5 -> 57.5,
  paper-street dL 58.2 -> 59.4 at 64. Board evidence/item7_paper_age.png; hero frames now h40; ladder +1 row.
  FRICTION: shoot.sh needs `--borrow=C:/.../borrowed/` as arg 3 for the hero, or street life is missing.
- 23:14 MILESTONE: look_d5_shadow finer/darker hatch (5645ece). h40 stripes (hazard-stripe read) -> h41 period 4.5 /
  tint 0.42: printed FLAT by look_d4 (REJECTED) -> h42 period 5 / tint 0.36 / cov 0.42 kept: band mean L 0.441 ->
  0.381, stripe energy 0.202 -> 0.193 at 64 (0.269 -> 0.244 at 32). Board evidence/item8_shadow_hatch.png; hero = h42.
- 23:15 re-check after the aged paper (showcase r22 vs r21, full d5 stack, the d4/d5p tier mask): Rivet vs street dL
  0.166 -> 0.170 at 64, 0.183 -> 0.187 at 96 (street L 0.286 -> 0.282); d5 @32 0 px. No readability cost.
- 23:16 hero wall-side crate stacks (h44). h43 barrel_cluster REJECTED: the project's barrels print vermilion
  (doctrine noise beside the cops; the mock's are grey). Pure-vermilion px h42 -> h44 unchanged. Hero frames = h44
  (d4 and d4d5 both refreshed).
- 23:18 OWNER A/B (no change kept): Rivet steel lavender (kept) / halfway / concept mauve (concept body medians
  ~116,86,118 light, 68,41,83 mid). Rivet body vs street dL at 64/96: 0.166/0.183 / 0.115/0.129 / 0.065/0.075 (D4
  0.168/0.178). By eye mauve still reads (the cream rim does the silhouette) and is closer to the concept, but it
  fails the D4-parity gate by 61%. Temporary shader edits reverted (git clean). Board evidence/item9_steel_owner_ab.png.
- 23:18 NOTE (city/d4-production lanes): lamp_post reads as a spoon lying on the pavement at 48-64 px/m (the mock's
  lamp is a kerb base + curved arm + round head). Not D5 scope; on the gap list.
- 23:22 Codex: 1 D5 street decal sheet (d5_decals, 2x2 layout template + hero_48 + concept; 188 s). 0 rejected (flat
  marks; STRIKE spelled right; cream + ink only). Ledger total 28.
- 23:24 MILESTONE: D5 big street decals (300c1f7): union-fist stencil 2.8 m, STRIKE 4.4 m, chalk robot 2.4 m, scorch
  2.2 m at 96 px/m in features/city/art/d5/decals/, placed by dev/showcase/d5_hero_decals.gd (d5 tier). h45 had the
  chalk cramped between crosswalks -> h46 moved into the open lane by the fight. h46 vs h44: verm and teal px
  identical at 32-96, 1.1% of frame changed at 32. Board evidence/item10_street_decals.png. Hero frames = h46.
- 23:25 gates at 300c1f7: unit 146/0, scenarios 8/0 (exit 0).
- 23:28 MILESTONE: D5 landmark roofs lifted (2edef89). FOUND: vs d4h2_mock the D5 roofs went the WRONG way in tone
  (mock roof L ~0.59 / 44% paper; D4 bar 0.457 / 26%; D5 bar 0.381 / 16%). build_roofs.py gained a mid-tone density
  lift (d' = d**LIFT; ink, vermilion, the mural fist untouched; LIFT 1.0 rebuilds byte-identical). h47 1.4 timid,
  h48 1.8 KEPT (bar 0.439 / 25%, mural 0.471 / 28%: D4 tone parity with the grime kept), h49 2.2 lost the grime.
  h50 = h48 (0 px). Board evidence/item11_roof_lift.png. item3_roofs_gate.png rebuilt from h57 at 23:44.
  Hero frames = h50.
- 23:29 item4 board rebuilt from h50 (mock / 32 / 48 / 64 / 96 / concept). Side by side the biggest remaining gap is
  AT 32 px/m: cool grey vs the mock's warm sepia (and ink-heavy D4 roofs + a hard pavement grid: D4 lanes).
- 23:30 MILESTONE: look_d5 `age_floor` (9c98937), default 0 = off (h51 = h50, 0 px in every tier/zoom). A/B h51af at
  32 with 1.0 (params restored after, git clean): street 78,67,70 / paper 248,223,195 (mock 78,67,68 / 246,223,195),
  paper-street dL 60.6 (= mock), verm-street dE 74.8 (mock 62.6). Board evidence/item12_age_floor_32.png. Proposal
  for the visual-engine lane + owner (it changes the D4 gameplay frame, not mine to switch on).
- 23:32 MILESTONE: 128 px/m kill-cam in the hero scene (f9f956f). h52 used the hero camera and cut Rivet -> h53 frames
  the shot (KILL_CAM_M 6.6,-1.9) only at zoom 4; 32/64/96 0 px vs h50. D4 vs D4+D5 at 128 beside the concept:
  evidence/item13_killcam128.png; this is where D5 reads closest to the concept (part rust, hatch and form shade all
  survive at ~2.5x minification). hero-d4/d4d5-128ppm.png added.
- 23:33 gates: evidence tool (--no-parity --no-bench) ALL PASS at e0abd08 (lint 13/13, unit 146/0, scenarios 8/0,
  selftest ok); 30 untracked evidence PNGs moved aside and restored.
  FRICTION: run_unit.mjs without GODOT_BIN exported prints "exit -1 ... (146 passed)" = a stale count, not a run.
- 23:34 MEASURED zoom colour drift of the aged paper: paper dE 2.8 (32->48) / 7.6 (32->64), street 2.0 / 4.7; with
  age_floor 1: <= 0.6. Recommendation (gap 1): the visual-engine lane switches age_floor on.
- 23:35 MILESTONE test_look_d5_params.gd (836a1a5): keys are uniforms (planted typo caught), zoom blend 0 at 32 +
  monotone, age_floor off. Found while writing it: shadow.offset_m is placement data, allowlisted. Unit 149/0.
- README: gap list after iteration 3 (7 items, next step each).
- 23:36 PROPOSAL evidence for gap 2 (d4-production lane, no D4 art changed): the d**1.8 lift applied to temporary
  copies of the 4 D4 neighbour roofs (originals restored byte-for-byte, git clean, re-imported), round h54d4lift:
  OSHA at 32 px/m L 0.482 -> 0.538, paper 26% -> 38% (mock 44-49%); top-left neighbour 0.425 -> 0.477. Remaining ink
  mass = the roofs' thick hatched border ring. Board evidence/item14_d4_roof_lift_proposal.png.
- 23:38 REVERTED: softened D5 pavement joints (gap 3; density above 0.5 compressed x0.35 in the D5 sidewalk tile),
  h55 vs h53: dark px in the 64 px/m pavement strip 25.3% -> 23.9% only; the look_d4 print re-inks the joints. No
  visible gain; tile restored byte-identical (git clean). The joint weight has to be fixed in look_d4's print
  thresholds or in a thinner-jointed tile (city lane).
- 23:42 MILESTONE car-camera pan shimmer MEASURED (ecf5621, d5_pan.gd: hero junction at 48 px/m, camera panning 7.3 m/s
  = 5.84 px/tick, world-locked 480x320 crop, 40 ticks, with / without look_d5): frame change 0.00709 (D4) vs
  0.00696 (D5): the D5 world layer adds no swim (closes gap 3's "unmeasured in motion at 48").
  FOUND (visual-engine / d4 lane, NOT changed by me): look_d4.gdshader:96 multiplies the print by a 5% grain hashed
  on SCREEN pixels (hash(floor(FRAGCOORD.xy))), so on every camera move the static world re-rolls its grain: TV-static
  swim. Temporary edit to hash(floor(w)) (world-locked; reverted, git clean): pan frame change 0.00709 -> 0.00049
  (-93%), changed px/frame 10140 -> 991. One-token fix for that lane.
- 23:42 same pattern in my look_d5_part (6% screen grain on parts) -> locked to part space (5522ce5). Walk shimmer same
  session: D5/D4 total 1.084 -> 1.077, HF 1.029 -> 1.026. Hero h56: 0 px at 32/48 and in the d4 tier; grain pattern
  only at 64+ (mean L equal to 4 decimals). Hero frames = h56.
- 23:43 look_d5_soul grain locked to the sprite (fwidth-sized cells; derivative before the discard). h57 vs h56: 0 px
  at 32/48, teal px/mean unchanged at 64-128. Motion benefit NOT separately measured (same pattern as the part fix).
  All D5 shaders are now free of screen-locked noise (grep FRAGCOORD: only look_d5's world coordinate w). Hero = h57.
- 23:47 Codex: 1 Rivet expression sheet (2x2 layout + accepted portrait + concept, 93 s), 0 rejected. Ledger 29.
  MILESTONE item 5c: rivet_{neutral,angry,hurt,hopeful}.png (512 px) installed + provenance + manifest. Identity held,
  cream visor, no gore (hurt = dent + torn cable). At 64 px only angry (V slit) and the head tilts separate them.
  Board evidence/item5c_rivet_expressions.png.
- 23:49 Codex: 1 King expression sheet (87 s), 0 rejected; ledger 30. Installed king_{neutral,wary,furious,smug}.png.
  HONEST NAMING: the cell prompted "commanding" (megaphone raised) shows a sideways glance -> named "wary".
  install_expressions.py generalised (rivet re-install byte-identical). Board evidence/item5c_king_expressions.png.
- 00:00 Codex: 1 D5 union hall roof (LOCAL 9, the mock's landmark), 0 rejected; ledger 31. MILESTONE (commit above):
  built like the landmarks; at 1.8 it was DARKER than D4 (L 0.402 vs 0.501, ink 58% vs 42%: the art hatches the whole
  membrane) -> per-roof lift 2.6: paper 32% (= D4), L 0.431. The hero swaps neighbours that have D5 art and puts the
  union hall beside the mural (h59 parse error first: String(Variant) under warnings-as-errors hung the launcher
  to its timeout; fixed with a typed var). h60 = hero frames + item4 board. Board evidence/item15_local9.png.
- 00:01 gates: evidence tool (--no-parity --no-bench) ALL PASS at 5922a3d: lint 13/13, unit 149/0, scenarios 8/0, selftest ok (34 untracked evidence PNGs moved aside and restored).

## Summary (iteration 3, 23:09 -> 00:01)
- Images: 7 Codex (d5_decals, d5_rivet_expressions, d5_king_expressions, d5_roof_union_hall, then 3 finisher panels; ledger 27 -> 34,
  masters gen/ledger.tsv), 0 rejected for camera breaks. One cell honestly renamed (King "commanding" -> "wary").
- Kept: look_d5 aged paper (`age`, the mock's sepia at D5 zoom), `age_floor` proposal (off), finer/darker cast-shadow
  hatch, D5 street decals (stencil fist, STRIKE, chalk robot, scorch), D5 landmark roofs lifted to D4 tone (d**1.8),
  D5 LOCAL 9 union hall (d**2.6) beside the mural, wall-side crates, the 128 px/m kill-cam, Rivet + King dialogue
  expressions, part/soul grain locked to the sprite, test_look_d5_params.gd, the car-camera pan shimmer scene.
- Measured: doctrine dE after the warmth, Rivet dL with the full stack, zoom colour drift (paper dE 7.6 from 32 to
  64 tied to zoom; <= 0.6 with age_floor), pan swim (D5 adds 0; look_d4's screen grain = 93% of the pan swim).
- Rejected/reverted: denser flat shadow (h41), barrel_cluster (vermilion), D4->mauve steel (owner A/B only: -61%
  contrast), roof lift 2.2 (grime lost), softer pavement joints (look_d4 re-inks them), D4 roof lift (proposal only).
- Shared files touched: none (steam/ai-provenance append-only, art_src/d5.manifest.json).

NEXT:
1. Visual-engine lane: switch `world.age_floor` to 1 (or move the AGE gains into look_d4's palette): the gameplay
   frame then matches the mock's sepia (item12) and the zoom colour drift disappears. Wire look_d5 `amount` from
   zoom_amount in the city (still dev/showcase only).
2. Visual-engine lane: look_d4.gdshader:96 `hash(floor(FRAGCOORD.xy))` -> `hash(floor(w))` (-93% pan swim), and the
   same in look_d4_item (grain + the ghost halftone `dots(px, ...)`).
3. d4-production lane: the d**1.8 mid-tone lift on the D4 roof set (item14: OSHA paper 26% -> 38%); the remaining
   ink mass is the thick hatched roof border ring.
4. City lane: adopt the D5 decals (`city/art/d5/decals/`), the D5 landmark + union-hall roofs, kerb corners and
   kerb/building shadow quads (the hero scene is the reference); the lamp post reads as a spoon; pavement joints are
   weighted by look_d4's print thresholds, not the tile.
5. HUD lane: dialogue/phone UI can use `characters/art/d5/portraits/{rivet,cop,king}.png` + rivet_/king_ expressions
   (at 64 px only angry/furious and the tilts read).
6. Owner: Rivet steel (item9), age_floor (item12), store-safe marks on portraits/expressions/loading art.
- 00:04 Codex: 1 D5 finisher splash (Rivet's claw crushing a police drone, 78 s), 0 rejected; ledger 32. Installed
  features/combat/art/d5/finisher_drone.png (1920x1081) + provenance; not wired (combat lane). Board item5d_finisher.png.
NEXT (addendum): 7. Combat lane: flash `features/combat/art/d5/finisher_drone.png` full-screen for ~1 s on a finisher
(the D5 "finisher" venue); more panels (cop baton, King) follow the same prompt (gen/_prompts/finisher_d5.txt).
- 00:06 Codex: 2nd finisher panel (light bar off an empty cruiser), 0 rejected; ledger 33. Installed finisher_lightbar.png; board item5d_finisher.png shows both.
- 00:07 FINAL gates: evidence tool (--no-parity --no-bench) ALL PASS at 8d3a860 (lint 13/13, unit 149/0, scenarios 8/0, selftest ok); 36 untracked evidence PNGs restored. Parity/bench not run (no native build in this worktree). NEXT above (1-7) stands.
- 00:10 Codex: 3rd finisher (torch cuts a police robot K9), 0 rejected; ledger 34. Installed finisher_k9.png, IN-GAME ONLY (not store-safe: robot dog may read as animal harm; owner). FRICTION: gen.sh's limit grep matched '429' inside a token count (104292): false positive, checked the log.
NEXT (addendum): 8. Owner: store use of finisher_k9.png (marked in-game only).
- 00:11 FINAL (iteration 3 end): evidence tool ALL PASS at cd7a854 = HEAD before this line (lint 13/13, unit 149/0, scenarios 8/0, selftest ok); 36 evidence PNGs in place; tree clean. NEXT 1-8 above.

## Iteration 4 (2026-11-03, BUILD, 00:11 -> )
- 00:12 read journal/log/README gap list; 34 Codex images used (~16 left). All 5 items evidenced; weakest visible
  gap in my scope: gap 5 (roofs read flat vs the mock's raised slabs).
- 00:13 mock LOCAL 9 south edge profile (column median L): cream lip 0.85 -> solid ink foot 0.13-0.21 (~1.6x the
  lip width) -> hatch 0.46-0.58 -> pavement 0.75. Ours h60: lip 0.85 -> a 6 px roof outline 0.08-0.15 -> hatch.
- 00:16 MILESTONE gap 5: D5HeroParapets (67c4b77), a 0.22 m ink core outside the roofs' street-facing south/east
  edges (d5 tier). h61 (core on every edge, + an inner hatched parapet shadow on the roof): ink at 32 px/m
  23.5% -> 25.1% (mock 13.9%), the alleys printed as a black grid -> h62 street-facing edges only (24.6%) -> h63/h64
  inner shadow dropped (invisible over the roof art's own border hatch; 1.7% px / +0.5 pp ink at 32): 24.1%.
  Edge profile at 48 now lip 0.85 (9 px) -> ink 0.08 (15 px) -> hatch: the mock's ratio (1.7 vs 1.6).
  d4 tier 0 px; h64 = h63 0 px at every zoom (deterministic). Cost: +0.6 pp ink at 32 (our ink excess is the roofs,
  gap 2). Board evidence/item16_parapets.png; hero frames = h64; ladder +1 row.
- 00:19 REVERTED (h65): bolder pen lines + less grime on the D5 parts (ink_at 0.74 -> 0.66, grime 0.10 -> 0.05).
  Fixed-mask (h64 tier footprint) at 64 px/m: D5 dL 0.151 -> 0.138 (D4 0.161), HF 0.126 -> 0.132, ink 32% -> 37%;
  at 96: dL 0.181 -> 0.170. By eye heavier but not closer to the concept (its weight is the dark mauve volume,
  the owner's steel call, item9). Shader restored (git clean).
  FOUND: in the HERO pose Rivet's D5 dL at 64 is 0.151 vs D4 0.161 (-6%); the parity measured at 23:05 (0.1693 vs
  0.1695) is the showcase pose. At 96 the hero pose is above D4 (0.181 vs 0.178). Logged, not tuned (pose-dependent,
  within the form shade's lower-right band on the aiming arm).
- 00:22 Codex: 1 cop expression sheet (2x2 layout + accepted cop portrait + concept, 93 s), 0 rejected; ledger 35.
  MILESTONE (5a1c9aa): cop_{neutral,shouting,alarmed,suspicious}.png (512 px, 0.056 inset: no gutter). Visor hides
  the face in all four; at 64 px shouting (hand) and suspicious (crossed arms) separate best. Store-safe (owner).
  Board evidence/item5c_cop_expressions.png. Provenance dated 2026-11-03 (provenance.py DATE updated).
- 00:24 MILESTONE gap 8 (78956ae): D5DialogueRun, the dialogue close-up venue IN-ENGINE (hero junction at
  32/48 px/m + a cream ink-bordered panel, rivet_angry + cop_shouting at 200 px, placeholder ink bars, no strings).
  FOUND + fixed: the D5 portraits imported WITHOUT mipmaps -> aliasing at 512 -> 200 px (dotted hatch, stepped
  collar). Mipmaps on (16 .import): mean abs error vs a Lanczos 200 px reference 6.8 -> 4.6 (rivet), 7.2 -> 5.1
  (cop). By eye the no-mip frame is punchier but breaks up; the mipped one is softer. Next (HUD lane): ship a
  pre-scaled 256 px portrait set for crispness. Board evidence/item17_dialogue.png; ladder +1 row.
- 00:27 Codex: 1 D5 boss-arena floor (King's chop shop: 12 m square, layout template = 1.5 m scrap band, open
  floor, 6 m turntable + a 1 m scale anchor; hero_48 + concept refs; 88 s), 0 rejected (plan view held; a few
  edge-band crates show a hint of side face, edge clutter only, noted). Ledger 36. FRICTION again: gen.sh's limit
  grep matched '429' inside an exec file name: false positive, checked.
- 00:29 MILESTONE (bac376c): king_arena.png (1254 px = 104 px/m >= F-13's 96) + D5ArenaRun (d5_showcase.gd --arena):
  the D5 arena venue in-engine, Rivet vs 2 cops on the turntable at 32/48/64/96 px/m. a1 REJECTED: the raw cream
  crown stencil swallowed Rivet's cream rim (ground ring 44% cream, Rivet |dL| 0.077 at 64 vs ~0.15 on the street)
  -> tools/build_arena.py dims the crown x0.6 under a soft mask (DIM 1.0 = the raw file byte-identical): a2 |dL|
  0.134, the crown still reads as worn paint; a3 = plain asphalt around the arena (lane-marked road tiles read as a
  grid). D5 print vs D4 tier at 64: warm, grainy floor vs cool flat grey (closer to the concept). No vermilion or teal
  in the floor (doctrine). Board evidence/item18_arena.png; ladder +1 row.
- 00:31 gates at bac376c: lint 13/13, unit 149/0, scenarios 8/0 (exit 0).
- 00:33 Codex: 1 plan-view King sprite (chroma-green layout template + King turnaround TOP view + concept, 76 s),
  0 rejected (overhead held: crown ring on the head top, shoulders, cape behind; the megaphone bell shows a little
  interior = mild oblique, noted). Ledger 37. Keyed by tools/install_king_top.py (640 px).
- 00:35 MILESTONE (66a4734): King in the arena (static sprite proposal, drawn as is on the actor layer): a4 at
  2.8 m read SMALLER than Rivet -> a5 3.6 m dominates; a6 camera centred on the arena. Frame vermilion at 64 px/m
  0.49% -> 1.52% (96: 1.12 -> 3.20%), all on the cape and hem: King is the threat (doctrine OK). Rivet |dL| unchanged
  (0.133). Board evidence/item18_arena.png (rebuilt from a6); ladder +1 row.
- 00:36 REVERTED (a7): King through look_d5_part as a tier-faded overlay (like RigDetail). At 96 px/m the steel
  maps to near-white (the art's mid lavender reads as low density on the Rivet-tuned ramp: the form is lost), the
  megaphone's copper rust prints as pure vermilion, the cream rim prints as a dashed hatch. 0 px at 32/48 (tier).
  Worse than as drawn; scene restored to a6 (git clean). A King print needs its own ramp (or King parts drawn to the
  Rivet sheets' tone range). Ladder +1 row (a6 | a7).
- 00:39 Codex: 1 D5 phone frame (front-view UI art, chroma-green layout template + concept, 59 s), 0 rejected
  (flat green screen, vermilion only on the hazard tape). Ledger 38.
- 00:40 MILESTONE (05a7b45): the PHONE close-up venue in-engine: phone_frame.png (keyed, the screen is a hole;
  install_king_top.py generalised, the King re-key is byte-identical) and `d5_hero.gd -- --phone=cop_alarmed`
  (portrait behind the screen + a placeholder call strip). ph1 = ph2 0 px; regression: dlg2 = dlg3 0 px, h64 = h66
  0 px at 32/64/128. Board evidence/item19_phone.png; ladder +1 row.
- 00:42 MILESTONE: King's steel desaturated (a8). Measured at 96 px/m: King steel max-min 42 (a saturated mauve, L 153)
  vs Rivet's printed steel 9 (L 189). install_king_top.py DESAT 0.35 on everything not vermilion: King 15, L kept
  (the boss stays darker/heavier than Rivet), frame vermilion 3.40% -> 3.29% at 96 (cape and hem kept). By eye the
  crown ring loses its gold and keeps its outline. Consistent with the doctrine and the owner's steel A/B (item9).
  item18 board rebuilt from a8; ladder +1 row.
- 00:44 MILESTONE: King casts a hatched shadow (a9): look_d5_shadow now multiplies its alpha by the texture alpha, so
  a Sprite2D with it is a character-shaped shadow while Polygon2D quads sample white = unchanged (hero h67 vs h66:
  0 px at 32/48/64/96/128). The King shadow (0.7 m down-right, world layer under the print, d5 tier) gives the boss
  height like the roofs' cast shadows; d4 tier 0 px; d5 changed px 9129 at 64. Ladder +1 row (a8 | a9).
- 00:45 gates: evidence tool (--no-parity --no-bench) ALL PASS at 5e9533f (lint 13/13, unit 149/0, scenarios 8/0, selftest ok); 42 untracked evidence PNGs moved aside and restored.
- 00:48 MILESTONE item 1 quality: form-shade coverage shade_k 0.42 -> 0.26 (look_d5_part + params json). Fixed-mask
  Rivet vs street dL at 64 px/m: HERO pose 0.151 -> 0.164 (D4 0.161; 0.34 gave 0.158), SHOWCASE pose 0.166 -> 0.176
  (D4 0.168; the 23:05 parity had drifted to 0.166 with the later grain locks); 96: 0.183 -> 0.189 (D4 0.177).
  0 px at 32/48/54/56 (r40 vs r42). Walk shimmer D5/D4 total 1.084 -> 1.076, HF 1.029 -> 1.024. By eye the joint
  form shade still reads; the cop's vermilion shade hatch at 96 is a little lighter, still visible. Board
  evidence/item1c_shade_k.png; hero evidence frames = h69 (h66 + this); ladder +1 row.
- 00:50 MILESTONE: the arena's 128 px/m BOSS KILL-CAM (a10), framed between King and Rivet: the closest frame of the
  night to the concept (King's riveted steel, crown ring, inked cape folds, Rivet's rust and hatch, the worn crown
  stencil). Honest note: at 128 the shadow hatch (period 0.16 m in world space) is coarse and stripy, the same as the
  building shadows at that zoom; next: scale look_d5_shadow's period with zoom above 96 px/m. Frames
  evidence/arena-d4d5-{64,128}ppm.png; ladder +1 row.
- 00:52 MILESTONE: look_d5_shadow `zoom` uniform: above 64 px/m the world period shrinks (period / max(1, zoom/2)) so
  strokes stay ~10 screen px apart instead of 15-20 px stripes. 0 px at 32/48/64 (hero h69 vs h70, arena a10 vs a11);
  at 96/128 the building, kerb and King shadows read as pen hatch, not hazard stripes. Still world-locked (no pan
  swim); the period re-lays only while the zoom changes. The hero/arena scenes set it per tier. Hero frames 96/128
  = h70; arena 128 = a11. Ladder +1 row. (d5_hero_run.gd is 239 lines: over the ~200 guide, under the 300 stop.)
- 00:55 MILESTONE: the arena yard (a13): 4 D4 roofs left/right of the floor (0.6 m asphalt, 0.4 m alleys) with the
  hero's ink foot (d5 tier) so the 64 px/m frame reads as a chop-shop yard in a city block, not a floor in a void.
  d5 = a12 0 px (gdformat-only change, deterministic). Rivet |dL| at 64 0.133 -> 0.143 (the shade_k change). Boards
  item18_arena.png and night_iter4_summary.png rebuilt (a13 / h69 / h70); ladder +1 row.
- 00:56 EVALUATED, NO CHANGE (gap 3 pavement): mock pavement under LOCAL 9 median L 0.776 vs ours (D4, 32 px/m) 0.878:
  ours is not darker; the difference is the joint layout/weight (a tile question for the city lane). The D5 strip
  is dominated by the roof cast shadow (median 0.331) so it is not comparable. No experiment run.
- 00:56 RE-MEASURED item 1 switch on the final shaders (sweep2, d5_sweep.gd, 51-67 px/m): |D5 tier - D4| mean 0 at
  51/53/55, then 0.0002 / 0.0009 / 0.0019 / 0.0027 / 0.0030 / 0.0032 (iteration 1: 0.0001 ... 0.0030): monotone, no
  pop. Walk shimmer (walk5) HF 1.024.
- 00:58 Codex: 1 D5 boss intro card (King on his turntable, 71 s), 0 rejected; ledger 39. Installed
  features/combat/art/d5/boss_intro_king.png (1920 px) + provenance; not wired (combat/HUD lane: Events.boss_engaged,
  quest_rules 'boss-intro'). HONEST: the crown stencil printed vermilion, outside the prompt's vermilion list (King's
  mark; kept, owner review). Board evidence/item5e_boss_intro.png.
- 00:59 gates: evidence tool (--no-parity --no-bench) ALL PASS at 23fb4af (lint 13/13, unit 149/0, scenarios 8/0,
  selftest ok); 46 untracked evidence PNGs moved aside and restored. Parity/bench not run (no native build here).

## Summary (iteration 4, 00:11 -> 00:59)
- Images: 5 Codex (cop expressions, King arena floor, plan-view King, phone frame, boss intro card); ledger 34 -> 39
  (masters gen/ledger.tsv). 0 rejected for camera breaks (notes: edge-band crates / the megaphone bell show a hint of
  side; the boss card's crown stencil is vermilion).
- Kept: roof ink foot (raised-slab read, gap 5), cop expressions, the dialogue panel and phone close-up IN-ENGINE
  (portraits now mipmapped), the boss arena at 64 px/m (floor + crown dimmed + King sprite desaturated + King's
  hatched shadow + yard roofs) and its 128 px/m boss kill-cam, look_d5_shadow sprite alpha + zoom-capped strokes,
  form-shade coverage 0.26 (Rivet contrast parity in both poses), the boss intro card.
- Rejected/reverted: ink core in the alleys (black grid), inner parapet shadow (invisible), bolder part pen lines
  (h65), the cream crown under the cast (a1), King through look_d5_part (a7), King at 2.8 m (too small).
- Evaluated, no change: pavement darkness vs the mock (not darker; joint layout = city lane).
- Shared files touched: none (steam/ai-provenance append-only, art_src/d5.manifest.json, my D5 shaders/params).

NEXT (iteration 4; NEXT 1-8 of iteration 3 still stand):
9. Characters lane: King PARTS on the rig layout (layout-template technique; refs king_top.png + the turnaround),
   then a King-tuned part print (look_d5_part's ramp washes King's steel to white, a7).
10. Visual-engine / city: set look_d5_shadow `zoom` from the camera; put the 0.22 m roof ink foot (D5HeroParapets)
    on street-facing south/east roof edges in the city, not the alleys; decide on character/boss cast shadows.
11. HUD lane: dialogue/phone UI from item17/item19 (portraits mipmapped; a pre-scaled 256 px set would be crisper);
    the phone frame is features/menus/art/d5/phone_frame.png (screen = alpha hole, fractions in d5_dialogue_run.gd).
12. Combat lane: boss_intro_king.png on Events.boss_engaged (left third for the name); finishers as NEXT 7.
13. City lane: King's arena needs walls/doors in the same hand; keep its crown stencil dimmed (a1).
14. Owner: King steel (desaturated like Rivet's lavender, item9 logic), the boss card's vermilion crown, store-safe
    marks on the cop expressions, phone frame and boss card.
- 01:02 Codex: 1 D5 plan-view lamp post (chroma-green layout template: base disc, curved arm, head disc; hero_48 + concept;
  65 s), 0 rejected (overhead held, no colour). Ledger 40.
- 01:03 MILESTONE gap 4 (lamp): features/city/art/d5/props/lamp_post.png placed by D5HeroDecals (d5 tier) on the
  kerb at (3.2, -6.8) m with the arm over the street like the mock; the D4 lamp (the "spoon lying on the pavement")
  is hidden in the d5 tier. h71 vs h70: d4 tier 0 px at every zoom; d5 changed px 2059 / 4399 / 7440 / 13065 at
  32/48/64/96 (0 at the 128 kill-cam, off frame). Honest: printed, the head reads a little like a gear ring.
  Board evidence/item20_lamp.png; hero frames = h71; ladder +1 row.
- 01:03 deleted 16 uncited frame rounds of this iteration (h61-h63, h65, h67, a2, a4, a5, a7, a9-a12, ph1, r41, dlg3; ~330 MB; their A/B crops live in the ladder/boards). Kept every round a board or README cites.
- 01:04 RE-CHECKED item 2 readability with all of tonight's world additions (h71, Rivet's 3.6 m box, d4 vs d5 tier):
  32 px/m 4.4% of the box changes (kerb shadow, crosswalk decal edges), the street median Rivet stands on is identical
  (0.285 / 0.285); 48 px/m 15.0% (+ the car-camera street hatch), street median 0.285 -> 0.283. The ground under the
  cast is unchanged at gameplay zoom.
- 01:05 EVALUATED, NO CHANGE: steel saturation (max-min, median over violet mid tones) of the close-up family:
  phone frame 34, Rivet portrait 34, rivet_angry 39, loading art 24; the world King sprite 15 after its fix. The rule
  that falls out: WORLD sprites print to the cast's lavender-grey (B/W doctrine at gameplay zoom); CLOSE-UP art
  (portraits, phone, cards) keeps the concept's mauve. The phone stays as is. (Written into the README gap list for
  the owner.)
- 01:05 RE-MEASURED pan swim with tonight's additions (pan3, d5_pan.gd, 48 px/m, world-locked crop, 40 ticks):
  mean frame change D4 0.00706 / D5 0.00694 (iteration 3, pan1: 0.00709 / 0.00696). The ink foot, the D5 lamp and
  the shadow changes add no swim; the D5 layer still sits at or below D4 in motion.
- 01:07 Codex: 1 lamp redo (d5_lamp_b: same template, the head a PLAIN cream cap with one dot; 71 s), 0 rejected. Ledger 41.
- 01:08 MILESTONE: lamp head fixed (h72): the riveted head of h71 printed as a gear ring at 48-64; the plain cap reads
  as the mock's round lamp head. d4 tier 0 px; d5 changed 972 / 2094 / 3585 px at 32/48/64 vs h71. d5_lamp marked
  SUPERSEDED in the manifest (no game file). item20 board = h70 | h71 | h72; hero frames = h72; ladder +1 row.
- 01:09 FINAL gates: evidence tool (--no-parity --no-bench) ALL PASS at d5c2f3c (lint 13/13, unit 149/0, scenarios 8/0,
  selftest ok; the selftest colour count varies run to run as noted at 22:09); 47 untracked evidence PNGs restored.
NEXT (addendum, iteration 4 after 01:00): 15. City lane: the D5 plan-view lamp (features/city/art/d5/props/lamp_post.png,
  arm over the street from the kerb) replaces the D4 'spoon' (hero d5 tier, item20). Images tonight: 41 of ~50.
- 01:10 MEASURED item 1 "closer to the concept" (first numeric try; Rivet's largest tier-footprint blob in h72 vs the
  concept's Rivet scaled to the 96 px/m height, teal ghosts and cream paper masked out):
  red-lead share (rust + collar, r - max(g,b) > 40): concept 0.079 / D4 0.030 (64) 0.031 (96) / D5 0.097 / 0.106: D5 is
  closer (it overshoots by ~0.02-0.03). Ink share: concept 0.391 / D4 0.389 / 0.343 / D5 0.348 / 0.330: about level.
  Mean L: concept 0.274 / D4 0.460 / 0.477 / D5 0.449 / 0.471: both far (the lavender steel, owner choice item9).
  HF is not comparable (our mask includes the cream sticker rim and outline). Supports the eye judgement on rust and
  print, not on tone.
- 01:12 MILESTONE item 1: drier rust (rust_dry 0.42 -> 0.55, shader + params json; h73). Red-lead share on Rivet at
  64/96: 0.097/0.106 -> 0.088/0.098 (concept 0.079). Pure-vermilion px 729 -> 455 at 64: that is RUST leaving the
  pure gate (a 0.42 mix has red lead ~88 > 70, a 0.55 mix ~68), the collar plates print VERM unchanged; by eye the
  collar now stands out more against drier rust. dL 0.1709 -> 0.1692 (D4 0.161). 0 px at 32/48 and in the d4 tier.
  Board evidence/item1d_rust_dry.png; hero frames = h73; ladder +1 row.
- 01:12 walk shimmer on the final part shader (walk6): D5/D4 total 1.078, HF 1.026 (walk5 1.076 / 1.024): no shimmer.
- 01:13 FINAL gates: evidence tool (--no-parity --no-bench) ALL PASS at 3ff8c4c (lint 13/13, unit 149/0, scenarios 8/0,
  selftest ok); 48 untracked evidence PNGs restored. Boards item4 + night_iter4_summary rebuilt from h73 (arena a13
  predates the rust change: 485 px at 64 in the hero, a re-shoot would move the arena Rivet by the same amount).
NEXT (final, iteration 4): items 1-8 (iteration 3) and 9-15 above stand. Owner, in order: (a) age_floor (gameplay-zoom
  warmth), (b) Rivet/King steel (world lavender vs close-up mauve rule), (c) store-safe marks (portraits, expressions,
  loading, phone, boss card; k9 in-game only), (d) the boss card's vermilion crown.
- 01:14 arena re-shot on the final shaders (a14); arena frames, item18 and night_iter4_summary now a14 + h73 (all evidence on one shader state).

## Iteration 5 (01:15 -> 02:45), BUILD: raise the weakest item (item 3, landmark roofs vs the mock)
- 01:16 picked: item 3. Against d4h2_mock the D5 roofs were the furthest off at gameplay zoom: mural roof at 32 px/m
  L 0.487 / paper 0.28 (mock 0.589 / 0.41, D4 0.516 / 0.27), and the grey wash blotches print as camouflage.
- 01:19 Codex: d5_roof_mural_b (Image 1 = the D4 roof layout, Image 2 = NEW refs/mock_roofs.png = two crops of the
  mock, the hatching target; Image 3 = concept, line quality only): tone with pen lines only, no wash blotches. 104 s,
  0 rejected (plan view held, objects in place against the D4 layout). Ledger 42.
- 01:20 h74 (b as is, lift 1.0): FRICTION, the first shot forgot `--borrow=` (street life missing, cars/cops moved):
  re-shot. d4 tier 0 px. Too clean: L 0.617 / paper 0.54, the hatch vanishes in the print, the fist loses its mass
  (reads D3 clear line). REJECTED.
- 01:30 MILESTONE item 3 (h75): build_roofs.py b path: paper cleaned (d < 0.08 -> cream), pen lines weighted
  (gamma 0.7), the fist a light ink wash 0.18 (seeded from the iteration-1 fist, eroded 8 px, grown to the b ink
  outline) and the fist's OWN ink line re-printed vermilion 3 px down-right (the misprint; the first try with a
  shifted mask edge leaked outside the outline). Mural roof at 32 px/m: L 0.593 / paper 0.44 / ink 0.32 (mock 0.589
  / 0.41 / 0.27): tone now at the mock. HONEST: HF 0.113 < D4 0.125 < mock 0.163 (the membrane hatch prints as tone,
  not lines, at 32-48; at 64 the lines show). d4 tier 0 px at every zoom; d5 changed px 46861 / 91997 / 120133 at
  32/48/64. Board evidence/item21_mural_pen.png; ladder +1 row; old d5_roof_mural SUPERSEDED in the manifest.
- 01:26 Codex: d5_roof_bar_b (prompt roof_sign_b.txt = the b prompt + the sign's vermilion plate), 111 s, 0 rejected
  (lettering spelled right; the kegs show a hint of side, like the mock's barrels). Ledger 43.
- 01:33 MILESTONE (h76): bar roof on the b plate (same build path, mural byte-identical). Bar at 32 px/m: L 0.463 ->
  0.494, paper 0.27 -> 0.39, ink 0.47 -> 0.46, HF 0.132 -> 0.128 (D4 0.460 / 0.24 / 0.49 / 0.122); the diagonal
  membrane hatch survives at 32 on this roof. d4 tier 0 px; d5 changed 49064 / 26403 / 0 px at 32/48/64 (the bar is
  off frame at 64). Crops work/i5/bar_ab32.png.
- 01:29 Codex: d5_roof_union_hall_b (roof_sign_b.txt), 96 s, 0 rejected (LOCAL 9 / UNION spelled right, layout on
  the D4 union hall). Ledger 44.
- 01:38 MILESTONE (h78): union hall on the b plate. h77 (gamma 0.7) printed black speckle at 32 (ink 0.47, HF 0.152);
  h78 with gamma 1.0 (this plate is densely hatched already; now the script default `union_hall:1.0`, rebuild
  byte-identical): union hall at 32 px/m L 0.469 -> 0.518, paper 0.37 -> 0.43, ink 0.52 -> 0.45, HF 0.154 -> 0.144
  (D4 0.530 / 0.35 / 0.40 / 0.123); at 48 the diagonal membrane hatch reads like the mock's. d4 tier 0 px (h77).
  Crops work/i5/uh_ab32.png, uh_ab48.png. (The D5 crops include the D5-tier cast-shadow/ink-foot ring, so the ink
  share stays above D4 by construction.)
- 01:33 / 01:35 Codex: d5_roof_pension_bank_b (100 s) and d5_roof_hq_b (95 s), 0 rejected (plan view, layout and
  lettering held; HQ's vermilion plate is a little heavier than the others: owner). Ledger 46. Images tonight: 46.
- 01:40 MILESTONE: pension bank + HQ on the b plate. They are mostly off frame in the hero shot, so d5_hero.gd gained
  `--cam=<x>,<y>` (metres; s2b = 0,9.7 frames the two south roofs) and d5_showcase_run skips the Rivet crop when
  Rivet is off frame (was an exit 1 on a 0-px image). Determinism: s3 = s2b and h80 = h79, 0 px in every file.
  At 32 px/m (roof interior): HQ D4 0.473/0.29/0.48/0.126, old D5 0.459/0.27/0.48/0.133, b 0.502/0.39/0.44/0.119;
  PENSION D4 0.520/0.32/0.42/0.127, old 0.506/0.34/0.43/0.140, b 0.555/0.47/0.39/0.124 (L / paper / ink / HF).
  d4 tier 0 px. Crops work/i5/south_ab32.png. All five D5 landmark roofs are now on the pen-hatch plate.
- (timestamps above 01:30-01:38 were written ahead of the clock; the ledger times are the true ones: mural_b 01:19,
  bar_b 01:26, union_hall_b 01:29.)
- 01:44 FRICTION: the first --cam edit broke lint (line length; _initialize 42 > 40 lines) and then the typed parser
  (split() on a Variant from Dictionary.get). d5_hero.gd now parses --key=value into a typed dict (_args/_arg,
  unknown key -> exit 2, checked). Re-verified: h81 = h80 and s4 = s3 (0 px, all files), the dialogue path runs
  (dlg4, exit 0). gdformat wrote CRLF on Windows: normalised to LF before staging.
- 01:41 boards: item3_roofs_gate.png rebuilt from h81 + s4 (D4 vs D5 at 32/48, south roofs, the per-roof numbers);
  NEW night_iter5_summary.png (mock, hero 32/48/64/128 h81, arena a14, concept); evidence/hero-d4(d5)-*ppm.png =
  h81 (they were byte copies of h73). README: the D5 roofs paragraph. Arena a14 is unaffected (no landmark roofs).
- 01:43 REJECTED (experiment, reverted): a coarse ruled membrane hatch composited into the b roofs (period 12 art px
  = ~4 screen px at 32 px/m, hand-wobbled, broken strokes, ink 0.45, light membrane only, parapet clean;
  build_roofs.py D5_ROOF_RULE, default 0 = off). h82/s5 vs h81/s4 at 32: HF +0.006-0.008 on 4 roofs, but paper
  drops 0.08-0.13 (mural 0.44 -> 0.36: away from the mock) and the UNION HALL moires with its own hatch (L 0.518 ->
  0.433, ink 0.45 -> 0.53). By eye it prints as a grey screen tone, not pen lines. Rebuilt with RULE 0: tree clean
  (installed roofs = h81). Crops work/i5/rule_ab.png. The texture gap stays (needs coarser hatching in the ART).
- 01:46 gates: evidence tool (--no-parity --no-bench) ALL PASS at eb2a541 (lint 13/13, unit 149/0, scenarios 8/0,
  selftest ok); 50 untracked evidence PNGs moved aside and restored. FRICTION: the first run had no GODOT_BIN in
  that shell ("Godot not found"): my setup, re-run with it exported.
- 01:45 Codex: d5_roof_mural_c (the b prompt + "BOLD, WIDELY SPACED" membrane hatch, ~40 lines), 108 s, 0 rejected
  for camera. Ledger 47. Images tonight: 47 of ~50.
- 01:47 REJECTED c in-engine: h83 (gamma 1.0) 32 px/m L 0.411 / paper 0.21 / ink 0.57 / HF 0.192; h84 (lines
  thinned, gamma 2.2) 0.469 / 0.26 / 0.47 / 0.202. The hatch survives as lines (HF above the mock's 0.163) but the
  striped membrane takes the fist mural's figure/ground and the tone leaves the mock. The b plate (h81) stays:
  rebuilt, tree clean. Manifest keeps d5_roof_mural_c as REJECTED (no game file). Board item21 + 2 rows; ladder +1
  row (union / HQ / pension old vs b).
  CONCLUSION for the texture gap: at 32 px/m a roof can have the mock's tone OR visible hatch lines, not both, with
  the look_d4 print as it is (it fattens any line that survives the minification). The mock's hatch is thin AND
  visible because the mock is one painted frame, not a minified texture printed by thresholds. Next step: a look_d4
  roof print that keeps thin art lines thin (visual-engine lane) or 48 px/m roofs art at 1:1 screen scale.
- 01:50 / 01:52 Codex: d5_roof_osha_b (106 s) + d5_roof_tall_b (111 s) on new green-border layout templates of the D4
  roofs (gen/refs/roof_{osha,tall}.png), roof_sign_b.txt; 0 rejected (layout, OSHA lettering, the hazard band held;
  tall has no colour). Ledger 49. Images tonight: 49 of ~50: no more generation this session.
- 01:58 MILESTONE: the boss arena's yard prints D5 roofs: d5_arena_run.gd swaps a yard roof to
  features/city/art/d5/roofs/<name>.png in the "d5" tier when one exists (OSHA top-right, tall bottom-left;
  warehouse/long stay D4). The hero swaps OSHA/tall neighbours by its existing ResourceLoader.exists rule (h85).
  d4 tier 0 px in a15 (vs a14) and h85 (vs h81). At 64 px/m: OSHA L 0.441 -> 0.510, paper 0.33 -> 0.40, ink 0.55
  -> 0.44 (HF 0.120 both); tall 0.385 -> 0.471, 0.24 -> 0.36, 0.60 -> 0.50 (HF 0.134 -> 0.129). By eye the wash
  blotches are gone and the hatch reads as pen lines. evidence/arena-d4d5-{64,128}ppm.png = a15; ladder +1 row.
  .import files for the 2 new PNGs made from the bar's [params] (Godot filled uid/path on --import).
- 02:01 Codex: d5_roof_warehouse_b (105 s). REJECTED (my template error): the 1312x672 warehouse was squashed into the
  square layout template, so the plate would stretch 2x on x (anisotropic pen lines), and Codex dropped the
  corrugated ribs (it stops reading as a warehouse). Not installed; manifest REJECTED. Lesson: pad non-square
  roofs to a square template, never resize. Ledger 50. Images tonight: 50: generation done for the night.
- 02:02 boards: night_iter5_summary.png from h85 + a15; evidence/hero-d4d5-*ppm.png = h85 (the d4 frames are
  unchanged since h81, 0 px). README: OSHA/tall + the tone-vs-lines finding.
- 02:02 RE-CHECKED readability with the iteration-5 roofs (h85 vs h73, d5 tier): every changed px lies inside a roof
  rectangle (32 px/m: rows 0-361 and 706-800; the street band 361-706 and every actor 0 px; 1 stray px at 48). The
  pan-swim test (d5_pan.gd) crops kerb/pavement/street only, so roof swim is NOT measured (open; the roofs are
  mipmapped world sprites like the D4 ones).
- 02:05 MEASURED roof pan swim (closes the open item above): d5_pan.gd gained `--anchor=<x>,<y>` (metres, the
  world-locked crop centre; default unchanged). 48 px/m car pan, 40 ticks, crop on the mural roof (9.7,-8.5):
  mean frame change NEW roofs 0.00959 (overlay off) / 0.00964 (on) vs OLD D5 roofs 0.00814 / 0.00808 (pan6roofold,
  old plates rebuilt temporarily, then restored: tree clean): +18%. Split by pixel class (d5 series): paper px change
  0.0146 (new) vs 0.0145 (old), pen-line px 0.0036 vs 0.0035, i.e. the SAME per-pixel rate; the new roof just has
  more paper (45% vs 32% of px) and paper is where look_d4's SCREEN-locked grain re-rolls on every camera move.
  So the new art adds no aliasing; the +18% is the known look_d4 grain (iteration-3 NEXT 2: hash(floor(w)), -93%).
  Default-anchor crop (pan4) 0.00749 vs pan3 0.00706: that crop takes the mural roof's lower edge. Change maps
  work/i5/pan_changemaps.png.

## Summary (iteration 5, 01:15 -> 02:06)
- Weakest item raised: item 3 (D5 landmark roofs vs the mock at gameplay zoom). All 7 D5 roofs (mural, bar, union
  hall, HQ, pension bank + NEW OSHA and tall) are now a pen-hatch plate (the mock's diagonal membrane hatch, no grey
  wash blotches). At 32 px/m the roof interiors went from darker than D4 to at or above D4 and toward the mock:
  mural L 0.487 -> 0.593 / paper 0.28 -> 0.44 (mock 0.589 / 0.41). The mural fist: a light ink wash with its own ink
  line misprinted vermilion. The boss arena's yard prints OSHA/tall in D5 (64 px/m: paper 0.33 -> 0.40, 0.24 -> 0.36).
- Images: 9 Codex (mural_b, bar_b, union_hall_b, pension_bank_b, hq_b, mural_c, osha_b, tall_b, warehouse_b);
  ledger 41 -> 50 = the night's budget. Camera-break rejections: 0. Rejected for other reasons: 2 (mural_c: the bold
  hatch takes the fist's figure/ground and the tone; warehouse_b: my squashed template).
- Rejected/reverted: h74 (b plate as is: too clean), the composited ruled hatch (screen tone + union hall moire),
  mural_c (bold hatch), warehouse_b. Kept: h75 mural, h76 bar, h78 union hall (gamma 1.0), s4 HQ/pension, a15 yard.
- Tools: d5_hero `--cam`, d5_pan `--anchor`, the off-frame Rivet crop skip; build_roofs.py b path (masters).
- Measured, no regression: d4 tier 0 px in every round; street band and actors 0 px (h85 vs h73); roof pan swim
  per pixel class identical to the old plates (the total +18% = more paper under look_d4's screen grain).
- Shared files touched: none (steam/ai-provenance append-only, art_src/d5.manifest.json, my dev/showcase scripts).

NEXT (iteration 5; NEXT 1-15 of iterations 3-4 still stand):
16. City lane: adopt the 7 D5 pen-hatch roofs (features/city/art/d5/roofs/, 672 px, D4 alpha = footprint lock) for
    the landmarks + OSHA/tall; for the warehouse (1312x672) pad the D4 roof to a square layout template, never
    squash (warehouse_b rejected for this).
17. Visual-engine lane: look_d4 roof print. At 32 px/m a roof holds the mock's tone OR visible hatch lines, not both
    (mural_c, the composited rule): look_d4's thresholds fatten any line that survives minification. A roof print
    that keeps thin art lines thin would close the texture gap (HF 0.11-0.14 vs the mock's 0.163).
18. Visual-engine lane: NEXT 2 (look_d4 grain on world coords) matters more now: the lighter roofs show more paper,
    and paper is where the screen-locked grain swims during a pan (+18% on the mural roof crop, per-px rate
    unchanged).
19. Owner: HQ's vermilion plate on "HQ" is heavier than the other signs; keep or thin.
- 02:07 FINAL gates (iteration 5): evidence tool (--no-parity --no-bench) ALL PASS at dd3f0f5 (lint 13/13, unit 149/0, scenarios 8/0, selftest ok); 50 untracked evidence PNGs moved aside and restored.
- 02:08 item4_hero_vs_targets.png rebuilt from h85 (all boards and evidence frames now on one state: h85 / s4 / a15). evidence/README.md: iteration 5 section, table rows, gap 2 updated.
- 02:09 MILESTONE (h86): the mural's vermilion misprint no longer prints on the laundry line under the fist (the
  rim stops 10 px above the fist's bottom; the clothesline outlines touched the dilated fill). d4 tier 0 px; d5
  changed 127 / 292 px at 32 / 64, all on the cloth tops. Vermilion share of the roof 0.68% -> 0.65%. Crop
  evidence/item21b_misprint_laundry.png. MISTAKE: I deleted frames/h85 while cleaning (boards cited it); the boards
  (item4, night_iter5_summary) and evidence/hero-*ppm.png are re-made from h86 (= h85 + this fix), README updated.
- 02:10 checked by eye at 48 px/m: HQ and pension b plates print clean (s4), no defects; ladder +1 row (h85 vs h86, HQ/pension at 48).
- 02:11 FINAL gates (iteration 5 end): evidence tool (--no-parity --no-bench) ALL PASS at b98bb9b (lint 13/13, unit
  149/0, scenarios 8/0, selftest ok); 51 untracked evidence PNGs moved aside and restored. Parity/bench not run (no
  native build in this worktree). Frame rounds kept: h81 (item3), h86 (hero frames, item4, summary), s4, a15.
NEXT (final, iteration 5): NEXT 1-19 stand. Images: 50 of ~50 used tonight, so no more Codex this night. If a later
  session has budget: a D5 plate for the warehouse (pad to a square template) and long/helipad (the arena's
  bottom-right and the hero's last D4 neighbour), same prompt (gen/_prompts/roof_sign_b.txt) and build path.

## Iteration 6 (2026-11-03, BUILD, 02:12 -> ), no image budget left (50/50): shader, tiles, compositing
- 02:12 read JOURNAL, git log. Weakest gap by eye at 32 px/m vs the mock: the pavement prints as a hard white slab
  grid with BLACK joints (gap 3); the mock's blocks are one cream surface with faint joints.
- 02:14 FRICTION (mine, again): h87a/b were shot without `--borrow=` (no cruiser/skids); re-shot. Control h87c (old
  tile) = h86 0 px in d4/d5 at 32/48: the scene is deterministic.
- 02:16 MILESTONE (h87d, 92068f9): D5 sidewalk tile with print-aware joints (masters tools/build_sidewalk.py,
  non-generative, seeded, byte-identical rebuild). The 4 px joints (L 0.05 at 96 px/m = 1.33 screen px of solid ink
  at 32 px/m) lifted to light-wash density (mean joint L 0.59), weight wanders along the joint (0.75-1.0) with rare
  gaps; the source tile's stain slabs lifted 60% toward the paper (they printed as grey squares once the grid went
  light). Tried: h87a joint 0.70 (the grid vanishes, the stain slabs read as camouflage blotches: rejected); h87b
  0.60 + gap period 8 (joints read DASHED at 48/64, stain square: rejected); h87d kept.
  Numbers (d5 tier, full frame): 32 px/m L 0.410 -> 0.426, px darker than L 0.35 0.682 -> 0.653 (mock 0.488 /
  0.515); 48: 0.390 -> 0.394; 64: 0.394 -> 0.398. Pavement strip at 48 px/m: L 0.569 -> 0.594, dark 0.413 -> 0.365
  (mock pavement 0.616 / 0.297); at 64: 0.624 -> 0.661, 0.345 -> 0.279.
  No regression: d4 tier 0 px at 32/48/64/96/128; the Rivet crops change only in their top rows (pavement at the
  crop edge), actors 0 px. Pan swim (d5_pan default anchor, 48 px/m, 40 ticks): pan7c (old tile) 0.00739 ->
  pan7d 0.00751 (+1.6%), per-class rate identical (paper 0.0144 / 0.0143, mid 0.0089 / 0.0087, ink 0.0036 /
  0.0036): more paper under look_d4's screen grain (gap 7), no new aliasing. Board evidence/item22_pavement_joints.png;
  ladder +1 row. (Iteration 3's h55 softened the joints by compressing density x0.35 and look_d4 re-inked them; the
  difference here is the joint's density lands in the light-wash step after minification, below line_ink.)
- CORRECTION to iteration 5: "Manifest keeps d5_roof_mural_c as REJECTED" is wrong: art_src/d5.manifest.json has no
  status field; mural_c and warehouse_b are listed like the others. Their rejection is recorded here and in the
  evidence README only.
- 02:19 MILESTONE (h88, 285cc30): D5 crosswalk (masters tools/build_crossing.py, non-generative edit of the D4
  road_intersection_tone): the zebra's wear holes (asphalt through the paint) printed as black dots at 32-64 px/m.
  Holes enclosed by paint: filled, the large ones shrunk 2 px to a flat paint/asphalt mix; the holes' anti-aliased
  rims (L ~0.7) included, or they print as rings (the first build did: caught by eye). d5_hero_run swaps a list of
  D5 ground tiles (D5_TILES). d4 tier 0 px at 32-128; changed px only on the bars (mask), 0 actor px.
- 02:22 REJECTED (h89 first try, not shot): a hard 1-px ridge for the road cracks: stair-stepped, broken lines.
- 02:24 MILESTONE (h89b, 51b96d4): D5 road tiles (road_straight_tone_b / _v_b) with thinned cracks (tools/
  build_road.py, grey-level 2x2 max filter on the line pixels only, paint excluded, 2 passes). The tiles' patch
  outline + cracks printed as solid ink at 32-48 px/m and repeated every 8 m. look_d4 prints anything darker than
  the asphalt as the street step OR solid ink, so a lighter crack vanishes at every zoom; a thinner one minifies away
  at 32 (the mock's street is clean) and stays a pen line at 64+. 1 pass (h89a) left a dotted patch outline at 32:
  2 passes kept. Pan (d5_pan --anchor=8,0.5 on the patch, 48 px/m, 40 ticks): mean change 0.00505 (old) / 0.00506
  (1 pass) / 0.00507 (2 passes); ink px flipping per tick 0.00116 / 0.00111 / 0.00102: thin lines do not flicker.
  (First pan try at --anchor=-16,0 was off screen: black crops, 0 change; re-run.) d4 tier 0 px at 32-128; no
  vermilion/teal px changed.
- 02:26 MILESTONE (h90, d8a5b9c): the intersection tile's crack thinned the same way (crossing, then road).
- Frame numbers, d5 tier, h86 (iteration 5 end) -> h90 (L / px darker than 0.2 / HF): 32 px/m 0.410 / 0.231 /
  0.071 -> 0.427 / 0.212 / 0.068; 48: 0.390 / 0.196 / 0.063 -> 0.396 / 0.183 / 0.062; 64: 0.394 / 0.190 / 0.061 ->
  0.401 / 0.177 / 0.061. Mock (1280 wide): 0.488 / 0.123 / 0.104. Toward the mock in tone and ink; NOT in HF: the
  mock's high frequency is fine paper/asphalt grain everywhere, ours was black grid and crack lines (now fewer).
  Grain is look_d4's (and screen-locked, gap 7). Boards evidence/item23_street_print.png; ladder +1 row.
- 02:27 boards: evidence/item4_hero_vs_targets.png and NEW night_iter6_summary.png from h90 (masters tools/
  boards_i6.py, so the boards are re-makeable); evidence/hero-d4d5-*ppm.png = h90 (hero-d4-* = h90's d4 frames, byte
  identical to the old ones). README: iteration 6 section, table rows, gap 3 closed for the D5 tier.
- 02:28 provenance: 4 lines appended (the sidewalk tile's correction line with the new sha; the D5 crosswalk and the
  two road tiles as by-code derivatives of the D4 tiles, model/prompt refs carried from their D4 lines).
- 02:29 gates: evidence tool (--no-parity --no-bench) ALL PASS at e94c9e2 (lint 13/13, unit 149/0, scenarios 8/0,
  selftest ok); 54 untracked evidence PNGs moved aside and restored.
- 02:30 MILESTONE (h91, 15adfae): kerb stone line (D5HeroKerbs._stone): the mock's kerb = a cream stone band with an
  inner line running along the straight kerbs AND round the corner; ours had only the edge outline. 0.04 m ink line
  0.3 m inside the street edge, one polyline per quadrant (straight -> arc r 1.3 m -> straight), shown in the d5
  tier. Iteration 2 (h39) reverted a corner-only arc because it floated; continuous, it reads as a kerb at 32/48/64
  (board evidence/item24_kerb_stone.png). Props draw over it (dumpster); the hydrant sits inside the arc.
  Pan (d5_pan default crop, 48 px/m): stone line off (width 0, pan9n) vs on (pan9s): mean change 0.00752 -> 0.00739,
  all ink flips 0.00266 -> 0.00278; flips in the line's band 0.0063 per px/tick vs the crop's existing ink edges
  0.0062 (= any line already in the world); 0.06 m (pan9w) 0.0053 but heavier than the mock's line: kept 0.04.
  d4 tier 0 px at 32-128, Rivet crops 0 px, no vermilion/teal px changed.
- 02:32 FRICTION/MISTAKE: a sed to wrap a long comment line in d5_hero_kerbs.gd replaced the wrong lines and deleted
  `const ARC_STEPS`; lint passed (gdlint does not resolve identifiers) and 15adfae was committed with a file that does
  not parse. Fixed in f8864e9; the fixed tree re-shot (h91b) = h91, 0 px in all 10 frames. Lesson: line edits by
  number only after printing those exact lines; run --check-only on a changed script before committing.
- 02:33 boards from h91: item4_hero_vs_targets.png, night_iter6_summary.png (tools/boards_i6.py), evidence/
  hero-d4d5-*ppm.png = h91 (hero-d4-* unchanged, byte identical); ladder +1 row; README rows + section.
- 02:34 (timestamps of the three entries above corrected to the clock; they were first written ahead of it.)
- 02:36 MILESTONE (h92b -> h92c; 72d2221, 55f54b8): bold centre dashes. Mock dashes ~0.4 m wide (18 px at its ~45
  px/m); ours 0.08 m (rows 380-388 of the 96 px/m tile), 2.7 px at 32 px/m. build_road.py `dash_px` (default 0: the
  old tiles rebuild byte-identically, checked) widens them about their centre with the paint median, wear bites
  kept. h92a 24 px: reads but lighter than the mock; h92b 36 px (0.375 m): the mock's read, BUT pure cream dashes
  merge with a cop's cream sticker rim where he stands on the line (48 px/m crop: rim p90 L 0.892 vs dash 0.871, dL
  0.021). h92c `dash_tone` 0.84: the dash prints as a light wash, dL 0.159 at 32 / 0.141 at 48; by eye still the
  mock's road graphic. KEPT h92c. d4 tier 0 px, Rivet crops 0 px; h92b changed 5-6 vermilion px (one column of the
  police barrier's stripe edge where the dash meets it). Provenance: 2 correction lines per step (new sha).
  Frame (d5, h86 -> h92c): 32 px/m L 0.410 -> 0.425, px darker than 0.2 0.231 -> 0.218, HF 0.071 -> 0.071.
  OPEN (owner, pre-existing in D4 and in the mock): the zebra bars are the same cream as the actors' rim; Rivet's arm
  over the crossing touches them. Not changed (the mock's zebra is cream); a toned zebra would be the same fix.
- 02:38 boards from h92c (item4, night_iter6_summary, NEW item25_road_dashes.png), evidence/hero-d4d5-*ppm.png =
  h92c (d4 frames unchanged); ladder +1 row; README rows + section.
- 02:41 gates: evidence tool (--no-parity --no-bench) ALL PASS at e89a39c (lint 13/13, unit 149/0, scenarios 8/0,
  selftest ok); 56 untracked evidence PNGs moved aside and restored.
- 02:43 REJECTED (h93, reverted, tiles byte-identical to 55f54b8): asphalt grain in the D5 road tiles (masters tools/
  build_grain.py: seeded light specks, 3% of the asphalt, L 0.53, mid-wash step). HF 32/48/64 0.0705/0.0630/0.0613 ->
  0.0721/0.0664/0.0636, but by eye the specks read as sprinkled salt, not the mock's grain: the mock's asphalt is a
  dense LOW-CONTRAST mottle, which one print step cannot hold. Crop masters work/i6/grain_rejected_h93.png; ladder row.
- 02:43 MILESTONE (f9f07fb): look_d5 `grain_floor` PROPOSAL, default 0. The tooth (world-locked mottle, already in
  look_d5) is scaled by amount = 0 at 32 px/m; grain_floor is its floor (like age_floor). Default: h94 = h92c, 0 px
  in all 10 frames; test_look_d5_params asserts it ships off (unit 149/0). A/B at 32 (params JSON restored byte-
  identically after each shot): street crop sd 0.0529 (off) / 0.0526 (0.5) / 0.0541 (1.0) vs mock 0.0567; street
  median 76,70,79 / 77,71,80 (grain 1.0) / 80,69,71 (grain 1.0 + age_floor 1.0) vs mock 81,70,72. Readability with
  both on (street band at 32): sticker rim vs street dL 0.575 -> 0.580, teal vs street dE 41.3 -> 41.6, vermilion
  vs street dE 76.6 -> 72.3 (the warmth; iteration 3 measured the same trend). By eye the both-on frame is the
  closest to the mock tonight. Board evidence/item26_grain_floor_32.png; ladder +1 row. World-locked by construction
  (w = FRAGCOORD + world_px), the same tooth whose pan swim was measured at 0 extra in iteration 3.
- 02:46 gap list after iteration 6 written (evidence/README.md, 7 items, next step each). Checked by eye before
  writing gap 5: the mock's stickers DO carry a thin dark line outside the cream rim (+ a soft shadow); ours go
  rim -> street. The rim halos are built in features/characters/rig_build.gd (characters lane, not mine): handed off.
- 02:49 OWNER A/B (h95zt, NOT committed; the intersection tile restored byte-identically, tree clean): zebra paint
  x0.84 (the dashes' tone). Rivet's rim and arms over the crossing separate from the bars at 32/48/64; the crossing
  still reads. Board evidence/item27_zebra_owner_ab.png; ladder row; README gap 4.
- 02:48 FINAL gates (iteration 6): evidence tool (--no-parity --no-bench) ALL PASS at 09acc5f (lint 13/13, unit
  149/0, scenarios 8/0, selftest ok); 58 untracked evidence PNGs moved aside and restored. Parity/bench not run (no
  native build in this worktree).

## Summary (iteration 6, 02:12 -> 02:50)
- No image budget left (50/50), so all of it is non-generative: print-aware GROUND for the D5 tier, the largest
  surface in the gameplay frame and the biggest by-eye gap to the mock at 32 px/m after iteration 5. The finding
  behind it: look_d4 prints anything darker than a surface as that surface's own step or solid ink, so a line is
  either solid ink at 32 px/m or gone; the tiles are now built for that (masters tools/build_sidewalk.py,
  build_crossing.py, build_road.py; deterministic, documented in their headers).
- Kept: pavement joints at light-wash density (h87d), clean crosswalk (h88), thinned road + junction cracks (h89b,
  h90), the kerb stone line (h91), bold centre dashes a step below the actors' rim (h92c), and look_d5 `grain_floor`
  as a default-off proposal (with `age_floor` the 32 px/m street median is 80,69,71 vs the mock's 81,70,72).
- Rejected: joints too light (h87a), dashed joints (h87b), a hard 1-px crack ridge, 1-pass cracks (h89a, dotted at 32),
  pure-cream bold dashes (h92b: merged with a cop's rim, dL 0.02), asphalt specks (h93: salt, not grain).
- Owner A/Bs: toned zebra (item27), grain_floor + age_floor (item26).
- Measured, no regression: d4 tier 0 px in every round at 32-128; actors 0 px (Rivet crops; changed px masked to
  ground); pan swim per pixel class unchanged on the pavement, ink flips DOWN on the road (0.00116 -> 0.00102), the
  kerb line flips like any existing ink edge (0.0063 vs 0.0062); readability with both floors on: rim dL 0.575 ->
  0.580, teal dE 41.3 -> 41.6.
- Frame (d5 tier, h86 -> h92c) at 32 px/m: L 0.410 -> 0.425, px darker than 0.2 0.231 -> 0.218 (mock 0.488 / 0.123).
- Mistakes: two hero rounds shot without --borrow (re-shot); a sed deleted `const ARC_STEPS` and 15adfae does not
  parse alone (fixed f8864e9, re-shot 0 px); journal times written ahead of the clock (corrected).
- Shared files touched: steam/ai-provenance/2026-11.jsonl (append only, 8 lines), the look_d5 params JSON + its unit
  test (mine), project/assets/shaders/README.md (one row).

NEXT (iteration 6; NEXT 1-19 of iterations 3-5 still stand):
20. City / d4-production lanes: adopt the 4 print-aware D5 ground tiles (features/city/art/d5/ground/) for the city,
    or apply the same build rules to the D4 set; the kerb stone line (D5HeroKerbs._stone: 0.04 m ink, 0.3 m inside
    the street edge, continuous) belongs in the kerb tiles.
21. Visual-engine lane + owner: `age_floor` + `grain_floor` at 1.0 (item26) = the mock's colour and street mottle at
    32 px/m with readability held; fix look_d4's screen-locked grain first (NEXT 2/18), the lighter ground shows more
    paper.
22. Characters lane: the mock's stickers carry a thin dark line OUTSIDE the cream rim (checked by eye); ours go rim ->
    street. An outer ink hairline in rig_build.gd's halo pass, A/B at 32 px/m on the crossing and pavement.
23. Owner: zebra cream (as the mock) or toned like the dashes (item27).
24. City: road paint (STRIKE) off the centre line; the bold dashes now show between its letters at 48 px/m.
- 02:51 FOUND + FIXED (h96, 70c20a6): the thinned road cracks also went faint at the 128 px/m kill-cam (the night's
  closest frame to the concept: a D5 regression up close, seen on a 96/128 check after the summary). D5HeroGround: a
  child overlay per road tile with the D4 tile's ORIGINAL crack pixels (masters tools/build_cracks.py; paint and the
  widened dashes excluded), alpha 0 at 56 px/m -> 1 at 96, d5 tier only. h96 vs h92c: 0 px at 32/48 in both tiers,
  d4 tier 0 px at every zoom; d5 changed 2518 / 7409 / 15666 px at 64 / 96 / 128 (Rivet crops: 24-29 px, all at the
  crop's left edge on street-luminance ground, not Rivet). Zoom sweep (temporary zoom list, restored; tree checked):
  fade vs full overlay changed px per m^2 3.95 / 2.59 / 2.29 / 2.04 / 1.98 / 1.87 / 1.47 / 0.86 / 0 at 48 / 56 / 60 /
  64 / 68 / 72 / 80 / 88 / 96 px/m: monotone, no pop. (My first "off" run set FADE_ON = 1000, which the clamp turns
  into alpha ~1 at every zoom, i.e. "always full": I read the numbers as that, which is the comparison wanted.)
  Provenance +3 lines. Boards item28_cracks_up_close.png, item4 + night_iter6_summary from h96; evidence/
  hero-d4d5-*ppm.png = h96 (hero-d4-* unchanged); ladder +1 row.
- 02:54 MILESTONE (h97, fff3ff6): the crosswalk's wear holes fade back in up close too (the intersection overlay =
  every changed px, build_cracks.py `all`; the road overlays rebuild byte-identically with the default rule). h97 vs
  h96: 0 px at 32/48 in both tiers, d4 0 px everywhere; d5 1964 / 2864 / 3078 px at 64 / 96 / 128 = the zebra's worn
  holes as in h86 at the kill-cam. Boards (item4, night_iter6_summary, item28) and evidence/hero-d4d5-*ppm.png = h97.
  The pavement joints stay light at every zoom (the mock's faint joint up close too).
- 02:55 gates: evidence tool (--no-parity --no-bench) ALL PASS at 0d045fa (lint 13/13 over 190 files, unit 149/0,
  scenarios 8/0, selftest ok); 59 untracked evidence PNGs moved aside and restored. Ladder +1 row (zebra at 128).
NEXT (addendum, iteration 6 after the summary): 25. City lane: the up-close fade (D5HeroGround: original crack and
  wear pixels as a world-locked overlay, alpha 0 at 56 px/m -> 1 at 96) is how the thin-at-gameplay / grime-up-close
  ground should ship; or a texture with hand-made mip levels (mip 0 = bold cracks, mip 1+ = thin), if the importer
  allows it.
- 02:56 MILESTONE (h98b): two more D5 lamps (SW at y 6.8, SE at 8.2) like the mock's lamps at the vertical road's
  block corners. h98 (all four corners) REJECTED: the NW head sat on STRIKE + the fist stencil, and the facing pairs
  read as a symmetric gate. d4 tier 0 px; d5 1866 px changed at 32 only (off frame at 48+); Rivet crops 0 px.
- 02:57 boards + evidence/hero-d4d5-*ppm.png = h98b (d4 frames unchanged). MEASURED the whole iteration in motion:
  d5_pan default crop, 48 px/m, 40 ticks: pan7c (iteration start: old tiles) vs pan10 (h98b): d5 series mean change
  0.00739 -> 0.00739, paper px rate 0.0144 -> 0.0143, ink px flips per tick 0.00284 -> 0.00278. No added swim.
- 02:59 REJECTED (h99m15 / h99m20, not committed; roofs restored byte-identically, tree clean): lighter pen lines on
  the mural plate (b gamma 0.7 -> 1.5 / 2.0), testing whether lighter lines land in the light-wash step as thin grey
  lines. Mural interior at 32 px/m (L / paper / ink / HF): 0.603 / 0.45 / 0.32 / 0.093 -> 0.635 / 0.49 / 0.26 / 0.094
  -> 0.648 / 0.50 / 0.23 / 0.095 (mock roof 0.594 / 0.36 / 0.25 / 0.163). The tone overshoots the mock, the props'
  hatch shading disappears, and HF does not move: iteration 5's conclusion stands (the roof texture gap needs a
  look_d4 roof print, NEXT 17). Crop masters work/i6/mural_gamma.png; ladder row.
- 03:00 FINAL gates (iteration 6 end): evidence tool (--no-parity --no-bench) ALL PASS at 1df4bae (lint 13/13 over 190
  files, unit 149/0, scenarios 8/0, selftest ok); 59 untracked evidence PNGs moved aside and restored; tree clean.
  Parity/bench not run (no native build in this worktree). Scratch deleted: frames/sw96on, sw96off (zoom sweep,
  numbers above), h91b (= h91); disk 226 GB free. Frame rounds the boards cite: h86, h87c/d, h88, h90, h91, h92b/c,
  h94, h94g10, h94both, h95zt, h96, h97, h98b; pans pan7c/d, pan8*, pan9*, pan10.
NEXT (final, iteration 6): NEXT 1-25 stand. Morning reading order: evidence/night_iter6_summary.png (h86 vs h98b at
  32/48 + mock + concept), item4_hero_vs_targets.png, the gap list after iteration 6 in evidence/README.md, then the
  owner A/Bs item26 (age_floor + grain_floor) and item27 (toned zebra). Images: 50 of ~50 used; none this iteration.
- 03:02 REJECTED (h100s35 / h100s40, params JSON restored byte-identically, tree clean): a finer building cast-shadow
  hatch (shadow period 5 -> 3.5 / 4.0 world px, cov 0.42 -> 0.32 / 0.30) to get closer to the mock's fine shadow hatch
  at 32 px/m (ours prints ~2 px strokes 5 px apart = broad stripes). By eye the change is marginal at 32 and 48: the
  look_d4 Sobel pass re-inks both sides of every stroke, so a finer pen hatch still prints as stripes; thinner lines
  would also add pan-swim risk. Kept period 5. Crop masters work/i6/shadow_ab.png. Same root cause as gap 2: the
  print fattens thin lines (NEXT 17 covers it).
- 03:04 MILESTONE (22eba5b): look_d5_print PROPOSAL, the root cause of tonight's two "thin lines fatten" rejections.
  look_d4's Sobel edge (|lum(x+1) - lum(x-1)|) is high on BOTH neighbours of a thin dark line, so a 1 px pen line
  prints ~3 px. look_d5_print = look_d4 verbatim + edge ink only where the pixel is no lighter than its 4-neighbour
  mean (dark_soft 0.04). Not default: d5_hero_run swaps it in with env D5_PRINT=thin; h101 (default) = h98b 0 px.
  32 px/m, D4 tier (h101 -> h101thin): frame L 0.438 -> 0.487 (mock 0.488), px darker than 0.35 0.65 -> 0.57 (mock
  0.51); mural roof L/paper/ink/HF 0.531/0.29/0.39/0.111 -> 0.595/0.34/0.29/0.111 (mock roof 0.594/0.36/0.25/0.163).
  D4+D5 tier: frame 0.425 -> 0.483, but the D5 mural goes 0.603 -> 0.667 (too light: the plates were lifted for the
  fattening print; they would need retuning). By eye (x2 crop of The Last Shift): crisper pen weight, the objects
  still defined by their ink fills. Pan 48 px/m (pan11thin / pan11thinR vs pan10 / pan11R): ink px flips 0.00278 ->
  0.00117 (junction), 0.00335 -> 0.00099 (mural roof); total change +12% / +12%, entirely the paper share (0.32 ->
  0.40, 0.58 -> 0.68) under look_d4's screen-locked grain (per-class rates equal: paper 0.0143 / 0.0143). Board
  evidence/item29_thin_print_proposal.png; shader README row; gap 2 updated. For the visual-engine lane + owner.
NEXT (addendum): 26. Visual-engine lane: A/B look_d5_print (dark-side edges) as the look_d4 print; it is the
  closest single change to the mock's 32 px/m tone tonight (D4 tier frame L 0.487 vs mock 0.488). Fix the screen
  grain first (more paper). If adopted, d5-close retunes the D5 roof line weight (build_roofs.py gamma) under it.
- 03:06 FOUND (h102thin; roofs restored byte-identically, tree clean): under look_d5_print the D5 mural with heavier
  plate lines (b gamma 0.7 -> 0.45) gives at 32 px/m L 0.643 / paper 0.44 / ink 0.24 / HF 0.105 (look_d4 now: 0.603
  / 0.45 / 0.32 / 0.093; mock roof 0.594 / 0.36 / 0.25 / 0.163). By eye the mock's fine diagonal membrane hatch shows
  across the roof while the tone stays light: the first time tonight a roof holds hatch AND tone (iteration 5's
  "tone OR lines" was the print, not the art). Not committed (depends on the print being adopted). Board
  evidence/item30_thin_print_roof.png; README gap 2; ladder row. NEXT 26 holds: print first, then the plate gamma.
- 03:06 MEASURED readability under look_d5_print (street band at 32 px/m, h101 -> h101thin): street L 0.294 = 0.294,
  sticker rim vs street dL 0.575 -> 0.576, vermilion dE 76.6 -> 76.7, teal dE 41.3 -> 41.4 (both tiers): the actor
  read is untouched (actors print on their own layer; the street keeps its tone).
- 03:07 PROPOSAL FRAME (h103all, nothing committed; params + roofs restored byte-identically, tree clean): h98b +
  D5_PRINT=thin + age_floor 1 + grain_floor 1 + D5 roof lines gamma 0.45 (union hall 0.65). 32 px/m whole frame L /
  dark / median RGB: h86 0.410 / 0.682 / 76,70,79 -> h98b 0.425 / 0.652 / 77,71,79 -> h103all 0.472 / 0.556 /
  87,75,76 (mock 0.488 / 0.509 / 96,84,83). By eye the closest frame to the mock tonight. Board
  evidence/item31_all_proposals_32.png; README section; ladder row.
- 03:08 FINAL gates (iteration 6 close): evidence tool (--no-parity --no-bench) ALL PASS at ebb322b (lint 13/13 over
  190 files, unit 149/0, scenarios 8/0, selftest ok); 62 untracked evidence PNGs moved aside and restored; tree clean.
NEXT (final, iteration 6, supersedes the earlier final NEXT): NEXT 1-26 stand. Morning order: evidence/
  item31_all_proposals_32.png (committed vs every open proposal vs the mock), night_iter6_summary.png, the gap list
  after iteration 6 (evidence/README.md), then the decisions: look_d5_print (NEXT 26), age_floor + grain_floor
  (NEXT 21), toned zebra (NEXT 23). Images: 50 of ~50 used; none this iteration.
- 03:09 look_d5_print at 48/64/128 (h101 -> h101thin, whole frame L / px darker than 0.35): 48 px/m d4 0.406 / 0.718
  -> 0.443 / 0.661, d5 0.396 / 0.712 -> 0.441 / 0.639; 64 d4 0.396 / 0.744 -> 0.429 / 0.688, d5 0.401 / 0.702 ->
  0.437 / 0.642; 128 d5 0.367 / 0.769 -> 0.378 / 0.749 (almost unchanged up close: lines are already wide there). By
  eye at 48/64: finer line weight like the mock, the union hall's dark membrane opens up; some thin outlines go
  grey (the roof dish). Board evidence/item29b_thin_print_48_64.png.
- 03:10 TUNE (h104ds10): look_d5_print dark_soft 0.04 -> 0.10 (committed; the proposal print only). D4+D5
  tier 32 px/m L 0.483 -> 0.474 (look_d4 0.425, mock 0.488), px darker than 0.35 0.552 -> 0.562; 48: 0.441 -> 0.435.
  By eye the thin outlines (crates, fan, dish) firm up and stay finer than look_d4. Board evidence/item29c_dark_soft.png.
  (item29/29b/30/31 were shot at 0.04; the tone numbers differ by <= 0.01.)
- 03:11 FINAL gates (session close): evidence tool (--no-parity --no-bench) ALL PASS at 3eb05cc (lint 13/13 over
  190 files, unit 149/0, scenarios 8/0, selftest ok); 64 untracked evidence PNGs moved aside and restored; tree clean.
  Session ends here (cap 03:42). NEXT: the final NEXT above (1-26) stands; nothing is half-done or uncommitted.

## Iteration 7 (2026-11-03, BUILD, 03:12 -> ), no image budget left (50/50): shader proposals, compositing
- 03:12 read JOURNAL, git log, evidence README gap list. Plan: complete the look_d5_print proposal (its only pan cost
  was look_d4's screen-locked grain), then the showcase's remaining in-scope gaps.
- 03:15 MILESTONE (56920ab): look_d5_print's 5% paper grain hashed on world pixels (hash(floor(w) + (17,5)), offset
  so it does not correlate with the world stipple) instead of FRAGCOORD. Same-commit A/B (the iteration-6 pan11thin
  rounds were shot at dark_soft 0.04, so a fresh control was shot with the line temporarily put back, file restored
  from a copy, diff checked): 48 px/m car pan, 40 ticks, D4+D5 tier: junction crop pan12ctl 0.00814 -> pan12thin
  0.00049 (-94%; what remains is Rivet's idle, the change map is otherwise white); mural roof crop (9.7,-8.5)
  pan12ctlR 0.01075 -> pan12thinR 0.00000. Shipped look_d4 for scale: 0.00739 / 0.00975 (pan10 / pan11R). Still
  frame tick 20: mean L identical to 4 decimals (0.4879, 0.6448), 0 px differ by > 0.06. So the proposal print now
  swims LESS than look_d4 on every crop instead of +12%. Default frames untouched (the shader loads only with
  D5_PRINT=thin). Board evidence/item32_print_world_grain.png; shader README row; ladder +1 row (label first written
  as 03:25, ahead of the clock: row cropped and re-added as 03:15). Metric script masters work/i7/pan_cls.py.
- 03:19 MEASURED the whole open proposal package in motion (params JSON temporarily age_floor 1 + grain_floor 1,
  restored from a copy, tree checked): D5_PRINT=thin + both floors, 48 px/m pan: junction pan13pkg 0.00049, mural
  roof pan13pkgR 0.00000 (both tiers), vs shipped look_d4 0.00739 / 0.00975. Floors verified active in the stills
  (tick 20 median RGB d4 78,72,81 -> 91,78,78; d5 80,72,78 -> 90,78,78). So NEXT 21's "fix the screen grain first"
  is now inside the package: look_d5_print + the two floors can be adopted together with no pan cost.
- 03:19 MILESTONE (0727aab, h106; gap 7): STRIKE (3.0 m, was 4.4) and the fist stencil (2.6 m, was 2.8) moved inside
  the west lane (x -1.85; lane -3.5..-0.2) of the hero scene. Before, a bold centre dash showed between STRIKE's
  letters and ran through the wrench, and the lamp head sat on the E. Control h105 = h98b (0 px at every zoom, both
  tiers). h105 -> h106: d4 tier 0 px everywhere; d5 11683 / 25646 / 43962 / 31087 / 0 px at 32 / 48 / 64 / 96 / 128
  (only the two decals and the dashes they uncover). By eye (work/i7/strike_ab.png = evidence/item33_strike_lane.png):
  the dashes run unbroken, the lamp head is clear, STRIKE still reads at 32 px/m (letters ~16 px tall). The faint
  wobbly contour under STRIKE is in the decal art (both rounds), not new. Ladder row (label first written 03:24,
  ahead of the clock; cropped and re-added as 03:18).
- 03:19 (same timestamp habit: the ladder label in the 03:15 entry was also ahead of the clock). Rule for the rest of
  the session: run date before writing any time.
- 03:28 MILESTONE (f145fa4; gap 5, PROPOSAL, default off): look_d5_halo.gdshader + dev/showcase/d5_hero_halo_ink.gd:
  the mock's thin ink line OUTSIDE the cream sticker rim (checked by eye on a x3 mock crop: dark contour beyond the
  cream, plus a soft drop shadow, not done). A ring-only pass on a child sprite of every CutRig halo; width in screen
  px from UV derivatives (holds under the limb halos' non-uniform scale and part rotation); z absolute below the
  lowest halo, so where halos overlap the cream covers the ring and only the silhouette's outer edge is lined. No
  characters-lane file touched (the dev scene swaps it in with D5_HALO=ink). h106 -> h107ink: 674 / 1107 / 1463 px at
  32 / 48 / 64 (both tiers alike; halos are off at 96+, so 0 px at 96/128). Where the ring landed at 32 px/m: 62 px
  over cream ground (zebra/pavement; L 0.86 -> 0.09: the rim now separates from a cream bar) and 612 px over street
  (L 0.28 -> 0.09: darker than the asphalt, like the mock's line). Motion: pan14ctl vs pan14ink (48 px/m, 40 ticks,
  look_d5_print so only actors change; Rivet's idle in the crop, ring present: 269 px differ at tick 0): mean change
  0.00049 = 0.00049, HF change 0.000538 = 0.000538, changed px/tick 991.6 vs 991.4: no added flicker. Board
  evidence/item34_halo_ink.png (the mock crop is at its own scale: its stickers are drawn larger and with a thicker
  rim than ours at 32 px/m). Ladder row. For the characters lane: the same pass in rig_build.gd _halo.
- 03:31 MILESTONE (493eb43, PROPOSAL option): look_d5_halo's soft drop shadow down-right (D5_HALO_SHADOW=1: 0.09 m
  offset, blur 0.4 x offset, ink 0.4; the same light as the buildings' cast shadows), drawn by the same ring sprite
  (z below every halo, so a character's own halos cover it). Refactor check: h108ink = h107ink, 0 px at 32-96.
  h108ink -> h108sh: 661 / 1669 / 3046 px at 32 / 48 / 64 (0 at 96+: halos off). Shadow at 32 px/m: street L 0.282
  -> 0.226 (a rough mock sample under its baton cop: open asphalt 0.345 vs under-right 0.285, the same ~0.06 step),
  cream ground 0.83 -> 0.62. By eye at 48: the cops and Rivet's arms sit on a soft shadow like the mock's stickers.
  Not measured in motion separately (same sprite as the ring, which adds 0; the shadow is a soft alpha). Board
  evidence/item34_halo_ink.png rebuilt with three columns + the mock; ladder row replaced (03:31).
- 03:32 PROPOSAL FRAME (h109all, nothing committed; roofs rebuilt with the defaults and params restored from a copy,
  git status of project/ clean; a default rebuild was checked byte-identical BEFORE the run): h106 + D5_PRINT=thin
  (now with world grain, dark_soft 0.10) + age_floor 1 + grain_floor 1 + D5 roof plate lines gamma 0.45 (union hall
  0.65) + D5_HALO=ink + D5_HALO_SHADOW=1. Whole frame L / px darker than 0.35 / median RGB (same script for all):
  32 px/m h86 0.410 / 0.682 / 76,70,79 -> h106 0.424 / 0.654 / 77,71,79 -> h109all 0.462 / 0.569 / 86,74,75; 48 px/m
  h106 0.394 / 0.715 -> h109all 0.424 / 0.651; mock 0.488 / 0.516 / 94,83,82 (this script; iteration 6 quoted
  96,84,83 from another crop/method). h109all is a touch darker than iteration 6's h103all (0.472) because of the
  dark_soft 0.10 tune and the drop shadows. By eye: warmer, lighter roofs with visible hatch, stickers lifted off
  the street; the closest frame to the mock tonight. Board evidence/item35_all_proposals_iter7.png (32/48/64 +
  mock + concept); ladder row.
- 03:33 evidence/hero-d4d5-*ppm.png and item4_hero_vs_targets.png = h106 (hero-d4-* unchanged: d4 tier byte-identical).
- 03:34 gates: evidence tool (--no-parity --no-bench) ALL PASS at 29d838a (lint 13/13 over 191 files, unit 149/0, scenarios 8/0, selftest ok); 68 untracked evidence PNGs moved aside and restored.
- 03:35 MEASURED the halo shadow in motion (closes the "not measured" in the 03:31 entry): pan14sh (D5_PRINT=thin,
  D5_HALO=ink, D5_HALO_SHADOW=1) vs pan14ink / pan14ctl, 48 px/m, 40 ticks. Whole crop identical to 5 decimals, so
  checked locally: the 612 px ever touched by ring or shadow, dilated 3 px (Rivet's idle does move there): mean change
  per tick ctl 0.00750 / ink 0.00749 / shadow 0.00748 (max tick 0.00888 / 0.00880 / 0.00880). Neither adds flicker.
- 03:37 REFACTOR (d5 dev, committed): the D5_PRINT / D5_HALO switches live in D5HeroHaloInk.dev_switches(), called by
  the hero AND the arena scene. Checked 0 px: h110sh = h108sh and a16 (default arena) = a15 at 32-128, both tiers.
- 03:37 MEASURED every open proposal UP CLOSE (a16all, the h109all set; roofs + params restored, project/ clean): the
  boss arena, whole frame L / px darker than 0.35: 64 px/m 0.378 / 0.562 -> 0.394 / 0.527; 96 0.348 / 0.534 -> 0.356 /
  0.517; 128 0.337 / 0.599 -> 0.343 / 0.588. Rivet crop: 64 0.352 -> 0.351, 96 0.335 -> 0.339, 128 0.342 -> 0.346.
  By eye: at 64 the floor and the OSHA roof a touch warmer and more open, at 128 almost identical (lines are wide
  there; halos are off at 96+). The package costs the D5 close-ups nothing. Board evidence/item36_arena_all_proposals.png.
- 03:39 REJECTED (h111wh15, nothing committed; print shader, roofs and params restored from copies, project/ clean):
  look_d5_print wash_hi 0.30 -> 0.15 on top of the h109all package, to close the whole-frame tone gap. Whole frame at
  32 px/m went to L 0.479 / dark 0.508 / median 97,84,85 (mock 0.488 / 0.516 / 94,83,82), a near match, BUT the
  street goes LIGHTER than the mock: street band median L 0.288 -> 0.332, mock 0.290 (west road 80,70,72; east
  80,69,71; same band method; my first single-patch mock sample of 0.345 was a light patch, not the street).
  Readability drops: rim vs street dL 0.610 -> 0.566, vermilion dE 77.5 -> 75.8, teal dE 57.6 -> 55.0. Wrong lever.
- 03:39 FOUND (the morning's key number): the h109all package already matches the mock per TONE CLASS at 32 px/m:
  street-tone share / median L 0.46 / 0.288 (mock 0.45 / 0.290), paper 0.32 / 0.856 (mock 0.33 / 0.867), solid ink
  < 0.18 share 0.14 (mock 0.12). Committed h106: street 0.46 / 0.294, paper 0.28, ink 0.20. So what the package
  fixes is ink weight (thin print) and paper share (lighter roofs), and the street needs no change. The remaining
  whole-frame L gap (0.462 vs 0.488) sits in the mid-tones and a paper 0.011 darker (age_floor's warm tint).
  Crops masters work/i7/washhi_ab.png; ladder row.
- 03:41 REJECTED (h112af06; params + roofs restored, project/ clean): age_floor 0.6 instead of 1.0 in the package.
  Per class at 32 px/m (whole-frame medians): paper colour h109all 244,220,192 = the mock's 245,222,195 to within 3;
  0.6 gives 238,220,196 (cooler) and paper L 0.855 (no lift); street 80,69,71 (mock 81,70,71) -> 79,69,74. So
  age_floor 1.0 is right and the paper L gap (0.856 vs 0.867) is not the tint. The remaining class gap is the
  MID-TONE share: L 0.42-0.70 px 0.08 (h109all) vs 0.11 (mock), h106 0.05. Gap 2 in the README corrected.
- 03:42 REJECTED (h113ss10; shader reverted to HEAD, roofs + params restored, project/ clean): a softer light/mid wash
  step in look_d5_print (step_soft 0.03 -> 0.10) for gap 2's mid-tone share. 32 px/m per class vs h109all: mid
  0.08 -> 0.09 (mock 0.11), paper L 0.856 -> 0.847 (mock 0.867, further away), paper 244,220,192 -> 241,217,190,
  street and readability unchanged (rim dL 0.610, verm 77.5, teal 57.6). Not worth it. The mid-tone gap is in the
  art (the mock's roofs carry soft grey shading at its resolution), not in the step width. Metric script masters
  work/i7/cls.py (per-class shares + the readability band).
- 03:43 MILESTONE: look_d5.params.json gains the iteration-7 proposal groups the visual-engine lane can read: "print"
  (look_d5_print: dark_soft 0.10) and "halo" (look_d5_halo: cut 0.3, line_px 1.0, shadow_a 0.4, shadow_m 0.09 m =
  placement, not a uniform), + the adoption note in _doc (with age_floor/grain_floor 1.0 and the roof plates at line
  gamma 0.45). test_look_d5_params.gd checks both groups against the real shader uniforms: unit 149/0. Only the
  "world" group is read by the dev scenes, so no frame changes.
- 03:46 FOUND + FIXED (c74aa1d): the look_d5_halo ring POPPED at the halo switch. Zoom sweep (temporary zoom list in
  d5_hero_run.gd, restored from a copy, tree checked), ring strength = summed |dRGB| vs the control per (px/m / 32):
  before 172 / 187 / 195 / 202 / 200 / 198 / 197 / 200 / 0 at 32 / 40 / 48 / 56 / 64 / 72 / 80 / 88 / 96+: a full
  1 px line up to 88 px/m, then nothing, where CutRig._on_view only loses a 2% halo sliver (halos shrink by
  hk = 1 - smoothstep(0.12, 0.3, SC * zoom) and hide below hk 0.01). Fix: a "fade" uniform (ring alpha and shadow)
  = (hk - 0.01) / 0.29 clamped, set by the dev helper from the zoom (CutRig's constants copied, noted). After: 172
  / 187 / 195 / 202 / 200 / 198 / 123 / 29 / 0: full strength through 72 px/m, graded out over 80-96. h114ink =
  h107ink at 32/48/64 (0 px). The same check the brief asks of the D5 tier switch, now applied to my proposal; I
  had claimed "halos are off at 96+, 0 px" without looking at the zooms in between.
- 03:47 board evidence/night_iter7_summary.png (h98b / h106 / h109all at 32, mock, h109all 48, a16all 128, concept + the per-class table); README row.
- 03:50 MILESTONE (proposal print, street_edge 1.0): the remaining solid-ink excess (0.14 vs the mock's 0.12) sat in the
  road band (ink share 0.114 vs 0.068; ink-density map masters work/i7/inkmap.png): the dark-side edge ink rings
  every cream dash and zebra bar on its asphalt side, and the mock paints its markings with no ring. look_d5_print
  gains street_edge: no edge ink on pixels already in the dark wash step (but not on solid ink). h109all -> h115se1
  (same package), 32 px/m: solid ink 0.14 -> 0.11 (mock 0.12), street share 0.46 -> 0.49 (mock 0.45; the rings
  become street), L 0.462 -> 0.468, paper unchanged, rim dL / verm / teal 0.610 / 77.5 / 57.6 unchanged. By eye: the
  crossing prints like the mock's (cream bars straight on asphalt); car, kerb, roof edges, shadow bands and the mural
  keep their lines (48 px/m x2 check). Arena (a16all -> a17se1): ink 0.136 -> 0.115 at 64, 0.127 -> 0.118 at 128,
  the turntable rim, hazard stripes and King's sprite keep their lines. Pan: pan15se / pan15seR = pan12thin /
  pan12thinR (0.00049 / 0.00000). Params JSON print.street_edge 1.0; unit 149/0. Board evidence/item37_street_edge.png;
  ladder row. (item29-32 and h109all/item35 were shot without it; h115se1 is the package's frame from here.)
- 03:51 boards item35_all_proposals_iter7.png and night_iter7_summary.png rebuilt from h115se1 (+ a17se1 for the arena kill-cam); gap list numbers updated (L 0.468, ink 0.11).
- 03:54 OWNER A/B (3963ef1, option default 0): look_d5_halo rim_px, extra cream rim width inside the ink ring (cream =
  print_part's halo cream x its mean grain 0.97), for the mock's relatively thicker rim (~4 px on a ~45 px cop vs
  our ~2 px on ~30 px at 32 px/m, by eye on x3 crops). First try did not compile (the uniform line was not inserted,
  my match string missed): those two rounds were deleted and re-shot. h116rim0 = h110sh (0 px at 32/48/64: the
  option off changes nothing); rim0 -> rim1 (D5_HALO_RIM=1): 1186 / 1925 / 2626 px at 32 / 48 / 64. By eye: bolder
  sticker read, closer to the mock's chunky rim, the ink line still separates; but more cream mass around every
  actor (busier at 48 where cops stand close to Rivet). A taste call, so not in the package. Board
  evidence/item38_rim_owner_ab.png; ladder row.
- 03:55 gates: evidence tool (--no-parity --no-bench) ALL PASS at f5145f8 (lint 13/13 over 191 files, unit 149/0, scenarios 8/0, selftest ok); 72 untracked evidence PNGs moved aside and restored.
- 03:56 TOOL (masters, outside git): tools/package_shot.sh <round> [hero|arena] shoots a scene with EVERY open proposal
  and restores project/ (refuses a dirty tree; checks the restore). h117pkg (from the committed files) = h115se1 at
  32-128 (0 px), so the package frame is reproducible from HEAD in one command.
- 03:57 FOUND (adoption condition): the package in the D4 TIER (D4 roofs/ground, h117pkg d4 frames) at 32 px/m per
  class: street 0.53 / 80,69,71, paper 0.32 / 245,220,192, solid ink 0.13 (h106) -> 0.07 (mock 0.12), mid 0.04 ->
  0.08, L 0.438 -> 0.475; readability the same as the D5 tier. By eye: warm and light like the mock, but the D4
  roofs' bold outlines and pipes print thin: the D4 art was drawn for look_d4's fattening print. So look_d5_print
  needs the D5 plates (or heavier D4 roof lines, d4-production) to keep the mock's ink weight; with them (D5 tier)
  ink is 0.11 vs 0.12. Board evidence/item39_d4tier_package.png. Gap list item 1 amended.
- 03:58 REJECTED (h118ds20; shader back to HEAD, roofs + params restored, project/ clean): dark_soft 0.10 -> 0.20 to
  give the D4 tier its ink back. D4 tier solid ink 0.07 -> 0.07 (no change: the extra edge ink lands as grey, not
  solid), paper 0.32 -> 0.29, L 0.475 -> 0.458; D5 tier paper 0.32 -> 0.29, L 0.468 -> 0.452. Worse on both tiers.
  The D4-tier condition stays an art fix (D5 plates or heavier D4 roof lines).
- 03:59 PROPOSAL for d4-production (no D4 asset committed; features/city/art/roofs restored with git checkout, tree
  clean): the D4-tier condition is an art fix. masters work/i7/d4_roof_lines.py weights the D4 roofs' dark lines
  (d' = d + k (1 - d) smoothstep(0.35, 0.75, d), vermilion kept, alpha kept). Under the package, D4 tier at 32 px/m:
  solid ink h117pkg 0.07 -> k 0.6 0.09 -> k 1.0 0.11 (mock 0.12; committed h106 0.13), L 0.475 -> 0.466 -> 0.461,
  paper 0.32 -> 0.31; readability unchanged; the D5 tier is unchanged (its frame roofs are all D5 plates). By eye at
  x2: the parapets and pipes print bold again under the warm, light tone. Board evidence/item40_d4_roof_lines.png;
  ladder row.

## Summary (iteration 7, 03:12 -> 04:00), no images (50/50 used)
- Theme: finish the open proposals as ONE package and measure it against the mock per tone class.
- Committed (default frames): STRIKE + the fist stencil inside the west lane (gap 7, h106; d4 tier 0 px).
- Committed proposals (default off, dev switches D5_PRINT=thin, D5_HALO=ink [+ D5_HALO_SHADOW=1, D5_HALO_RIM=1]):
  look_d5_print + world-locked grain (pan swim -94% / -100%) + street_edge (road paint without ink rings);
  look_d5_halo (ink line outside the sticker rim + soft drop shadow, fading with the halo: no pop, sweep-checked;
  rim_px owner option); params JSON "print" + "halo" groups (unit-tested against the uniforms); the arena scene
  honours the switches; masters tools/package_shot.sh reproduces the package frame from HEAD (h117pkg = h115se1).
- The number for the morning: with every proposal the 32 px/m D5-tier frame matches the mock per class: street
  80,69,71 (mock 81,70,71), paper 0.32 / 244,220,192 (0.33 / 245,222,195), solid ink 0.11 (0.12); pan 0.00049 vs
  shipped 0.00739; readability rim dL 0.610 / verm dE 77.5 / teal dE 57.6 (h106 0.604 / 81.2 / 56.9); neutral up close.
- Conditions found: in the D4 tier the package under-inks (0.07) unless the D4 roof lines are weighted (k 1.0: 0.11,
  item40); the remaining whole-frame gap is mid-tone share (0.08 vs 0.11), which lives in the art.
- Rejected (all restored, numbers above): wash_hi 0.15, age_floor 0.6, step_soft 0.10, dark_soft 0.20.
- Mistakes: two ladder labels written ahead of the clock (rows re-added); a shader edit that did not compile (rounds
  deleted, re-shot); a "0 px at 96" claim for the ring that hid a pop at 88 -> 96 (found by a sweep, fixed).
- Shared files touched: none outside my scope (look_d5* shaders, params JSON + its unit test, dev/showcase, shader
  README, evidence/). D4 roofs were modified only temporarily for item40 and restored from git.

NEXT (iteration 7; NEXT 1-26 of iterations 3-6 still stand, 21 and 26 are now one decision):
27. Visual-engine lane + owner: adopt the PACKAGE (item35 / night_iter7_summary) as one decision: look_d5_print as
    the world print (dark_soft 0.10, street_edge 1.0, world grain), look_d5 age_floor + grain_floor 1.0, look_d5_halo
    on the rig halos. Reproduce: masters tools/package_shot.sh. The params JSON has the values.
28. If adopted: d5-close rebuilds the D5 roof plates at line gamma 0.45 (union hall 0.65; one build_roofs.py env
    run) and commits them; d4-production weights the D4 roof lines (item40, k 1.0) or the city takes the D5 plates.
29. Characters lane: move look_d5_halo into rig_build.gd _halo (child ring sprite, z below the rig's halos, fade =
    (hk - 0.01) / 0.29); bake the same ring into the crowd atlas; owner decides rim_px (item38).
30. Next Codex budget: roof plates with a soft mid-grey shading layer under the pen hatch (the last per-class gap,
    mid-tones 0.08 vs 0.11), plates for the helipad / warehouse / long roofs, and King's rig parts.
- 04:00 scratch deleted (numbers in the entries above): frames/swh_ctl, swh_ink, swh_inkf, h112af06, h113ss10, h118ds20, h119d4l6, h116rim0, pan13pkg(R); ~330 MB; disk 223 GB free.
- 04:01 REJECTED (h120sht22; look_d5_shadow restored from git, roofs + params restored, project/ clean): a lighter
  building cast shadow between the strokes (tint 0.36 -> 0.22), testing whether the mock's extra mid-tone share sits
  in its hatched shadows. 56338 px changed at 32; per class: paper 0.32 -> 0.35 (mock 0.33), mid 0.08 -> 0.06 (mock
  0.11), street 0.49 -> 0.48, ink 0.11: the gaps print as paper, not mid. Mid-tones stay an art item (NEXT 30).
- 04:02 FOUND (where the mid-tone gap lives; masters work/i7/midmap.png): mid-tone (L 0.42-0.70) density maps, mock vs
  h117pkg at 32 px/m. The mock's mid-tones spread evenly over its roof INTERIORS (fine hatch averaging to grey at
  this scale): mid share top / road band / bottom 0.128 / 0.064 / 0.145. Ours sit in thick bands along the roof
  edges (ink foot, parapets, cast shadows) with paper-light interiors: 0.102 / 0.076 / 0.059 (the bottom row of roofs
  is mostly D4 neighbours). So the last per-class gap is gap 2 (roof texture, HF 0.11 vs 0.163) seen from the tone
  side: roof interiors need a fine hatch that greys out at 32 px/m.
- 04:02 REJECTED (h121p0, deleted; roofs + params restored, project/ clean): the D5 plates without the paper clean
  (D5_INK_P0 0.08 -> 0.0) inside the package: mid 0.08 -> 0.09, top-row mid 0.102 -> 0.111, but paper L 0.856 ->
  0.851 and frame L 0.468 -> 0.459. Same trade as step_soft: light hatch prints as an even darkening, not as the
  mock's grey hatch. NEXT 30 (plates with a fine interior hatch) stands; README gap 2 already says so.
- 04:06 OPTION, NOT IN THE PACKAGE (h122rule5 / h123pkg / a18rule; all restored, project/ clean): iteration 5's
  rejected ruled roof hatch (build_roofs.py D5_ROOF_RULE 0.5, period 12 art px) retried under the thin print. 32 px/m
  (D5 tier): by eye the roofs carry the mock's diagonal pen hatch across the membranes (masters work/i7/rule_ab.png);
  top-row mid share 0.102 -> 0.118 (mock 0.128), mural roof HF 0.135 -> 0.139, frame L 0.468 -> 0.461, paper 0.32 ->
  0.31, readability unchanged; pan 48 px/m unchanged (0.00049 / 0.00000; note this pan metric uses a pixel-snapped
  camera, so it catches screen-locked noise, not sub-pixel shimmer during zoom changes). BUT up close (arena 64 px/m,
  42223 px changed): an even, mechanical hatch over everything, across the OSHA sign plate. Helps at 32, hurts
  where D5 lives, so it stays an option (package_shot.sh env D5_ROOF_RULE=0.5, default 0). Needs a membrane mask
  (no signs/props) and a zoom fade (hand-made mips) first. h123pkg reproduces h122rule5 (0 px). Board
  evidence/item41_roof_rule_option.png; ladder row.
- 04:10 MILESTONE (6808d30 + provenance): the ruled roof hatch made adoptable. masters tools/build_rule_overlays.py
  bakes build_roofs.py's _rule (same seed, alpha 0.5, masked by each plate's luminance and alpha) as a transparent
  ink overlay per D5 plate: features/city/art/d5/roofs/rule/ (7 PNGs, 836 KB, + .import). D5HeroHaloInk.roof_rule()
  puts one as a child of each D5 roof sprite, d5 tier, ON only with D5_PRINT=thin (under look_d4 it fattened into
  tone, iteration 5), alpha 1 at <= 48 px/m -> 0 at 64. Default frames: h124 = h106 at 32-128, both tiers (0 px).
  Package with overlay (h124rf) vs without (h117pkg): 73387 / 64073 / 0 / 0 / 0 px at 32 / 48 / 64 / 96 / 128 (the
  64 px/m regression of item41 is gone). Fade sweep (temporary zoom list, restored; tree checked), strength per
  area: 6141 / 3676 / 1796 / 806 / 0 at 48 / 52 / 56 / 60 / 64: monotone, no pop. Per class at 32: L 0.468 ->
  0.459, paper 0.32 -> 0.30 (mock 0.33), mid 0.08 -> 0.09 (mock 0.11), ink 0.11, readability unchanged. By eye: the
  roofs carry the mock's diagonal pen hatch at 32 and 48 (work/i7/rulefade_ab.png). Provenance +7 lines (procedural,
  derived from the AI plates). package_shot.sh now shows it (D5_PRINT=thin turns it on). Board
  evidence/item42_roof_rule_fade.png; ladder row. The overlay lum mask comes from the committed plates (gamma 0.7),
  the baked h122rule5 from the gamma 0.45 build, so the two differ (80088 / 58684 px at 32 / 48).
- 04:11 boards item35 + night_iter7_summary rebuilt from h124rf (the package incl. the roof hatch overlays: 32 px/m L 0.459, dark 0.572, paper 0.30, ink 0.11, mid 0.09).
- 04:12 FINAL gates (iteration 7): evidence tool (--no-parity --no-bench) ALL PASS at 227dd01 (lint 13/13 over 191
  files, unit 149/0, scenarios 8/0, selftest ok); 76 untracked evidence PNGs moved aside and restored; tree clean.
  Parity/bench not run (no native build in this worktree).
NEXT (final, iteration 7; supersedes the NEXT 27-30 block above where they differ):
27. Visual-engine lane + owner: ONE decision on the package (evidence/item35, night_iter7_summary; reproduce with
    masters tools/package_shot.sh): look_d5_print as the world print (dark_soft 0.10, street_edge 1.0, world grain)
    + look_d5 age_floor/grain_floor 1.0 + look_d5_halo on the rig halos + the ruled roof hatch overlays
    (features/city/art/d5/roofs/rule/, fade 48 -> 64 px/m). Values in look_d5.params.json ("print", "halo").
28. If adopted: d5-close commits the D5 plates rebuilt at line gamma 0.45 (union hall 0.65) and rebuilds the rule
    overlays from them (tools/build_rule_overlays.py); d4-production weights the D4 roof lines (item40, k 1.0).
29. Characters lane: look_d5_halo into rig_build.gd _halo (+ the crowd atlas); owner: rim_px (item38).
30. Next Codex budget: lighter plate bases with a fine interior hatch (paper share 0.30 vs 0.33, mid 0.09 vs 0.11
    with the overlays), plates for the helipad / warehouse / long roofs, King's rig parts.
Morning reading order: night_iter7_summary.png -> item35 (package vs committed vs mock) -> item37/item42 (road
paint, roof hatch) -> item34/item38 (stickers) -> item39/item40 (D4-tier condition) -> README gap list after
iteration 7. Images: 50 of ~50 used; none this iteration.
- 04:13 the arena scene calls roof_rule too (committed). Default a19 = a16 (0 px at 32-128, both tiers). Package
  a19pkg vs a17se1: 33215 / 64765 / 0 / 0 / 0 px at 32 / 48 / 64 / 96 / 128: the yard roofs get the hatch at the
  gameplay zooms, the arena close-ups (64+) are untouched, so item36's "neutral up close" still holds.
- 04:13 scratch deleted (numbers logged above, no board cites them): frames/swr_ctl, swr_rf, pan15se(R), pan16rule(R), h114ink, h123pkg, h124 (= h106), a19 (= a16). Rounds the boards cite are kept: h105-h110sh, h115se1, h116rim1, h117pkg, h122rule5, h124rf, a16, a16all, a17se1, a18rule, a19pkg, pan12*, pan14*.
- 04:14 session close (cap 04:42): tree clean, last gate run ALL PASS at 227dd01 (later commits: the arena roof_rule hook, checked 0 px on default, lint ok; docs). The final NEXT (27-30 + reading order) above stands; nothing is half-done or uncommitted.

## Iteration 8 (04:15 -> cap 05:45), BUILD, no images (50/50 used)
- 04:15 read JOURNAL (iteration 7 NEXT 27-30), git log, evidence README gap list. Weakest item picked by eye at
  64-128 vs the concept (where D5 lives): the brief's "misregistered vermilion from the concept". look_d5_part only
  offsets vermilion that is already in the art (the collar, rust), so the concept's red misprint along EVERY
  segment's edge (work/i8/concept_leg.png) is missing.
- 04:17 control h125 (default shader + new code at fringe_k 0) = h106 at 32-128 (0 px).
- 04:19 REJECTED h126fr8 (band 2.5 screen px past mis_px, k 0.8): 1009-1043 px, invisible by eye: the art's ~7 part px
  outline (measured over the rivet parts) eats the band. REJECTED h127fr10 (5 screen px, k 1): visible at 64 but
  blotchy, and at 128 the outline (thicker in screen px) still eats it -> the band must be sized in PART px.
  REJECTED h128fa (14 part px, print-space direction, dry 0.2, k 0.9): faint everywhere.
- 04:21 h129fa22 (22 part px, k 1): at 128 the forearm / shoulder plates carry the concept's rust-red edge misprint;
  at 64 Rivet's red-lead share doubles (0.016 -> 0.029) and it is busy next to the collar -> fade it in by zoom.
- 04:22 MILESTONE (3f66c09, OPTION default 0): look_d5_part fringe_k / fringe_art 22 / fringe_fade (px_scale 0.2 ->
  0.3 = 64 -> 96 px/m) / fringe_dry 0.2; params JSON "part" + _doc (unit test: keys are uniforms, 149/0; lint 13/13).
  Default frames: h125 = h106, a20 = a16 (0 px at 32-128). With fringe_k 1: hero h130ff 0/0/0/3442/5765 px at
  32/48/64/96/128, arena a20ff 0/0/0/2862/3899. Fade sweep (temporary zoom list 64-96, restored, tree checked):
  strength per area 0 / 190 / 615 / 1011 / 1205 at 64 / 72 / 80 / 88 / 96: monotone, no pop. Doctrine: Rivet crop
  red-lead share 0.017-0.019 -> 0.027-0.030 at 96-128 (concept body region 0.039), PURE vermilion (dE < 40)
  unchanged 0.0055-0.0062: the collar stays the only pure vermilion; King is a plain sprite (unchanged); cops'
  steel parts get it too (gloves/guns: by eye negligible). By eye closer to the concept up close; a doctrine/taste
  call (more red on the hero), so OWNER A/B, not default. Board evidence/item43_fringe_owner_ab.png; ladder row.
- 04:24 CORRECTION: the three entries above first carried 04:20 / 04:30 / 04:36 and the ladder row "04:40", written
  ahead of the clock (the same mistake as iteration 7). Times fixed to the shell clock; the ladder row re-added.
- 04:29 MILESTONE (88c1e5e + uid): hatched cast shadows for props and parked cars in the D5 hero scene (new
  dev/showcase/d5_hero_prop_shadow.gd: one sibling sprite per prop with the prop's own silhouette, look_d5_shadow,
  offset down-right 0.12-0.45 m, under the prop on the world layer; d5 tier only; D5_PROP_SHADOW=0 off). Found by
  eye vs the mock at 32: every mock prop and car throws a pen-hatched shadow, ours none. h125 -> h131ps (tint 0.5)
  -> REJECTED h132ps7 (tint 0.7 / stroke 0.9: a solid black blob on the asphalt, the hatch is lost) -> h133ps
  (0.5, cone 0.2 -> 0.12 m: its square base alpha printed a box). 8637 / 13614 / 14853 / 19254 / 24443 px at
  32-128, d4 and d5p tiers 0 px; 32 px/m: ink 0.176 -> 0.179, L 0.423 -> 0.422, paper 0.286 -> 0.284. Package
  h134pkg (package_shot.sh, tree restored) vs h124rf: 8596 / 13465 / 14740 px at 32 / 48 / 64, ink 0.094 -> 0.097.
  Readability: actors untouched. d5_hero_run.gd is 256 lines (soft 200, hard 300; dev code). Board
  evidence/item44_prop_shadows.png; ladder row. Proposal for the city lane.
- 04:31 MILESTONE (a252a46): the mock's wall-side clutter on the hero scene's empty pavement strips: bench, planter,
  mailbox (bottom-left strip, empty before), vending machine (top-left, beside the crates); sizes from
  city_textures.json; neutral cream props only (barrel_cluster / barricade print vermilion = doctrine noise). Each
  gets the item44 shadow. h133ps -> h135cl: d5 7939 / 4212 px at 32 / 48 (d4 tier 6150 / 2867: the same props);
  d5 32 px/m L 0.422 -> 0.419, ink 0.179 -> 0.180, mid 0.048 -> 0.049. Actors untouched. Board
  evidence/item45_street_clutter.png; ladder row. d5_hero_run.gd now 261 lines (dev, under the 300 hard stop).
- 04:34 D5_FRINGE=<k> dev switch (d5_hero_halo_ink.gd dev_switches: fringe_k on the part overlays): D5_FRINGE=1 h136fe
  vs h135cl = 0/0/0/3442/5765 px (identical to the shader-edit round h130ff); no env h137 = h135cl (0 px).
  package_shot.sh passes it through: h138all (hero) and a21all (arena) = package + fringe, tree restored.
- 04:34 showcase frames evidence/hero-d4d5-*ppm.png and hero-d4-*ppm.png refreshed from h135cl (the committed default).
  Board evidence/night_iter8_summary.png. Per class at 32 px/m with THIS board's classes (paper L > 0.70, mid
  0.42-0.70, ink L < 0.15; not iteration 7's ink class): mock L 0.494 / paper 0.336 / mid 0.104 / ink 0.080;
  h106 0.423 / 0.286 / 0.048 / 0.176; h135cl 0.419 / 0.280 / 0.049 / 0.180; h138all 0.460 / 0.311 / 0.081 / 0.097.
- 04:39 MILESTONE (rig shadows commit): hatched cast shadows for the rigs up close. Found by eye in a21all: King casts a
  hatched shadow but Rivet and the cops float at 128 (their halos, and with them the look_d5_halo drop shadow, are
  gone from ~96 px/m); the concept grounds Rivet with a stippled shadow. New dev/showcase/d5_rig_shadow.gd
  (CanvasGroup on the world layer: each frame mirrors every visible rig part sprite, not halos / D5 overlays,
  0.45 m down-right) + assets/shaders/look_d5_shadow_group.gdshader (the merged alpha printed as look_d5_shadow's
  pen hatch: no seams where parts overlap). d5 tier, fades in 56 -> 64 px/m; D5_RIG_SHADOW=0 off. h135cl -> h139rs:
  0 / 0 / 6210 / 13965 / 27195 px at 32-128, d4 tier 0; arena a20 -> a22rs: 0 / 0 / 9666 / 23665 / 20886. Sweep
  54-64 px/m (temporary zoom list, restored, tree checked; D5_RIG_SHADOW=0 as control): strength per area 0 / 0 /
  130 / 876 / 2716 / 3555, monotone (the look_d4 print quantizes the low alphas, so most of the ramp lands 60-62).
  Package + fringe at 64 (h140all): the hatch sits with the soft halo shadow, actors still pop. Board
  evidence/item46_rig_shadows.png; ladder row. Proposal for the characters lane.
- 04:40 showcase frames refreshed: evidence/hero-d4d5-* and hero-d4-* from h139rs, arena-d4d5-64/128 from a22rs (rig shadows); night_iter8_summary.png rebuilt from h139rs / h140all / a23all (package + fringe + rig shadows).
- 04:42 GATES (iteration 8): evidence tool (--no-parity --no-bench) ALL PASS at b9468c7 (lint 13/13 over 193 files, unit 149/0, scenarios 8/0, selftest ok); 81 untracked evidence PNGs moved aside and restored. Parity/bench not run (no native build in this worktree). Gap list after iteration 8 written (evidence/README.md).
- 04:44 MEASURED (cost of the rig shadows; d5_cost_run.gd gained a "d5s" tier = d5 + D5RigShadow, and the shadow's
  script time): 16 full rigs at 64 px/m, RTX 4090, 240 frames. First version: script sync 1.71 ms/frame (a tree walk
  every frame) -> FIXED (part list cached per tier switch, halos skipped through a Dictionary, visibility checked per
  frame): 0.27 ms/frame; frames unchanged (h141rs = h139rs, a24rs = a22rs, 0 px at 32-128). Render cost, two
  runs after the fix (cost8b / cost8c / cost8d): d5 GPU median 0.338-0.339 -> d5s 0.409-0.518 (+0.07 to +0.18), p95
  0.34 -> 0.97-1.16 (spiky: the CanvasGroup's extra buffer pass, suspected, not proven), render CPU 0.25-0.26 ->
  0.33-0.34, script 0.27-0.28 ms. GPU baselines move between runs (d4 0.084 in cost8 / cost8d vs 0.208 in cost8b /
  cost8c: clock states), so only same-run deltas are quoted. evidence/d5-cost.json = cost8d (now with d5s; the
  shoot() split into _measure() for the 40-line limit, caught by the pre-commit lint). For the characters lane: build the shadow per rig in rig_build (no per-frame walk) and
  check the p95 spike with one CanvasGroup per rig layer vs per rig.
- 04:50 OPTION (820c5f2, owner A/B, default 0): look_d5_part dots_k / dots_period 3 - the concept's halftone stipple
  (gap list 5). h142dt (4 px screen over all mid-tones, d 0.16-0.70): REJECTED, an even mechanical screen over the
  whole robot. h144dt3 (3 px, d 0.26-0.74, x (0.45 + 0.55 shade): denser on the form-shade side, violet-grey dots,
  part space at 15 deg, the fringe's 64 -> 96 fade): by eye a fine print stipple in the shading, closer to the
  concept's dot screen. 0 / 0 / 0 / 5265 / 8154 px at 32-128 vs h141rs. Default h145 = h141rs (0 px); arena a25fd
  (D5_DOTS=1 D5_FRINGE=1) 0/0/0/7033/10036. D5_DOTS dev switch (PART_ENV table in d5_hero_halo_ink.gd). Params JSON
  part.dots_k 0 / dots_period 3 (unit 149/0).
- 04:50 SHIMMER at 96 px/m MEASURED (first time at 96: the walk scene hardcodes zoom 2.0 in _frame_at AND in the crop;
  first try at 3.0 changed only _frame_at, so the 120 px crop missed Rivet: walk8 discarded, re-shot with both + a
  180 px box, temporary, restored, tree checked). D5/D4 change over 40 walk ticks: options off total 1.176 / HF 1.131;
  dots + fringe on 1.150 / 1.106: no added shimmer. Note the D5 tier's own HF ratio at 96 (1.13) is higher than at
  64 (1.03, walk6): not a regression of tonight, just never measured; the characters lane may want to look at it.
  Board evidence/item47_dots_owner_ab.png; ladder row.
- 04:50 RE-CHECKED item 2 readability after iteration 8's scene additions (masters work/i7/cls.py, iteration 7's
  classes and street band): committed h106 -> h139rs / h145: rim dL 0.604, verm dE 81.2, teal dE 56.9 (identical),
  L 0.424 -> 0.420, ink 0.20, mid 0.05; package h124rf -> h140all: rim dL 0.610, verm dE 77.5, teal dE 57.6
  (identical), L 0.459 -> 0.455, paper 0.30, ink 0.11, mid 0.09 (mock L 0.488 / paper 0.33 / ink 0.12 / mid 0.11).
  The prop shadows and clutter cost no actor read; the frame darkens by 0.004 L.
- 04:51 TOOL (dev): d5_walk.gd --zoom=<z> (walk_zoom; the crop box scales with it). Default walk9_64 = walk6 (total 1.078 / HF 1.026); --zoom=3.0 walk9_96 = walk8_ctl (1.176 / 1.131). masters tools/shoot.sh usage line now says it passes scene args through. package_shot.sh passes D5_FRINGE / D5_DOTS / D5_RIG_SHADOW / D5_PROP_SHADOW through the environment.
- 04:52 EVALUATED, NO CHANGE (the D5 tier's walk HF 1.131 at 96 px/m; one term off at a time, temporary shader
  defaults, restored, tree checked): grime 0 -> 1.134, no hatch strokes (hatch_lo 2.0) -> 1.116, no form shade
  (shade_k 0) -> 1.123. No single print term drives it: the residual ~1.12 is the D5 art's own detail (rust, the
  steel ramp) moving with the limbs, which is the point of the tier, not aliasing. Nothing to fix in the print.
- 04:53 scratch deleted (numbers logged above, no board cites them): frames/h128fa, h129fa22, h131ps, h136fe, h137, h138all, a21all, h143, h145, swf_*, swr_*, walk8_*, walk9_*, walk10_*, cost8, cost8b, cost8c. Kept the rounds the boards cite: h125, h126fr8, h127fr10, h130ff, h132ps7, h133ps, h134pkg, h135cl, h139rs, h140all, h141rs, h142dt, h144dt3, a20, a20ff, a22rs, a23all, a24rs, a25fd, cost8d.
- 04:54 RE-CHECKED the car-camera pan after iteration 8's world additions (d5_pan, 48 px/m, 40 ticks, the default
  junction crop; the pan launcher takes no --borrow, so no parked cars: the first try passed it and exited, re-shot):
  committed pan17 d5 0.00732 (pan10, iteration 6: 0.00739); package pan17pkg 0.00049 (= pan14sh). The prop shadows'
  hatch is world-locked like the building shadows: no added swim.
- 04:58 gap 6 (cone shadow): the cone sprite is a flat square base plate with the cone on top, so its silhouette copy
  printed a box. D5HeroPropShadow.ROUND: a hatched capsule (Polygon2D, look_d5_shadow) from the prop's centre
  0.55 m down-right, radius 0.15 m, under the plate. Two broken rounds on the way, deleted: h146cone (typed-GDScript
  warnings as errors: float(Variant), the PackedVector2Array append/resize return values; the hero script failed to
  compile, every frame wrong; shoot.sh still printed "exit 0", so I now diff every round before reading it) and the
  first h147cone (identical counts for a different length = the capsule never drew: the name fallback overwrote the
  key before the ROUND lookup; fixed). h147cone vs h141rs: 291 / 592 / 1027 / 1079 / 1800 px at 32-128. By eye: at
  64 the capsule reads as the cone's height; at 32 it is a small hatched dash beside the cone (the plate covers its
  root), not worse than the box. Board evidence/item44b_cone_shadow.png (h125 none / h141rs box / h147cone capsule, 32
  x4 and 64 x2, + the mock's cone). Unit 149/0.
- 04:58 showcase frames evidence/hero-d4d5-* and hero-d4-* refreshed from h147cone (the committed default now); ladder row.

## Summary (iteration 8, 04:15 -> 04:58), no images (50/50 used)
- Theme: where the remaining differences were visible by eye but not in the tone table: up-close print traits of
  the concept, and grounding (every mock prop, car and actor sits on a pen-hatched shadow).
- Committed, default ON in the dev scenes (d5 tier): hatched prop + car cast shadows (item44, D5HeroPropShadow; the
  cone as a capsule past its base plate, item44b); the mock's wall-side clutter (item45: bench, planter, mailbox,
  vending machine); hatched rig cast shadows up close (item46; final form item46b: world-locked strokes, no
  CanvasGroup, 56 -> 64 px/m).
- Committed OPTIONS, default off (owner A/B; dev switches D5_FRINGE=1, D5_DOTS=1; params JSON "part"): look_d5_part
  fringe_k (item43: the concept's red misprint edge, 64 -> 96 px/m, pure vermilion unchanged) and dots_k (item47:
  the concept's halftone stipple in the shaded steel mid-tones). Together: the concept's riso-print signature.
- Measured: readability unchanged (rim dL 0.604 / verm dE 81.2 / teal dE 56.9 committed; 0.610 / 77.5 / 57.6
  package); pan swim unchanged (0.00732 committed, 0.00049 package); walk shimmer at 96 px/m with both options 1.106
  vs 1.131 without (no added shimmer; the tier's own 1.13 at 96 is the art's detail, decomposed); rig shadow cost
  +0.005 ms GPU median, p95 0.161, 0.29 ms script at 16 full rigs (the group version: +0.07..0.18 ms, ~1 ms p95; the
  first script version 1.71 ms, fixed).
- Tools: d5_walk --zoom; the cost scene's d5s tier; package_shot.sh passes the iteration-8 env through.
- Rejected: fringe bands sized in screen px (h126 invisible, h127 blotchy), 14 part px (h128 faint); prop shadow tint
  0.7 (h132ps7, blob); the 4 px even dot screen (h142dt, mechanical).
- Mistakes: journal times and a ladder label written ahead of the clock (fixed at 04:24); a walk round whose crop
  missed Rivet (hardcoded zoom; discarded, tool fixed); two broken cone rounds (a parse failure that shoot.sh did not
  flag; a lookup-order bug); a pre-commit lint block (function length) fixed by splitting.
- Shared files touched: none. Scope: look_d5* shaders + params JSON, dev/showcase, evidence/, masters tools.

NEXT (iteration 8; NEXT 27-30 of iteration 7 still stand):
31. Owner: two A/B options for the up-close tier, item43 / item43b (fringe, cool steel only) and item47 (dots);
    taken together they are the concept's print look. If yes: set part.fringe_k / dots_k to 1.0 in
    look_d5.params.json and the shader defaults. Reproduce: D5_FRINGE=1 D5_DOTS=1 package_shot.sh <round> [arena].
32. City lane: prop shadows (D5HeroPropShadow recipe: the silhouette offset for boxes, a capsule for props on flat
    plates, tint 0.5) and the pavement clutter density of the mock (item45).
33. Characters lane: rig cast shadows (D5RigShadow recipe: world-locked look_d5_shadow strokes only, tint 0 /
    stroke 1, no CanvasGroup; item46b) built in rig_build as part children (no per-frame copy).
34. If the image budget returns: King's rig parts and plates for the roof interiors with a fine mid-grey hatch
    (mid-tones, gap 2), as in NEXT 30.
Morning reading order: night_iter8_summary.png -> item46 / item44 (grounding) -> item43 / item47 (owner A/B) ->
night_iter7_summary.png and the iteration-7 order.
- 05:00 night_iter8_summary.png rebuilt from h147cone (committed) / h148all + a26all (D5_FRINGE=1 D5_DOTS=1 package_shot.sh: every proposal + both options + rig shadows); per class at 32 (this board's classes): h148all L 0.460 / paper 0.311 / mid 0.082 / ink 0.097 (mock 0.494 / 0.336 / 0.104 / 0.080). a23all deleted (superseded).
- 05:04 MILESTONE (f16de04): the rig shadow without the CanvasGroup (NEXT 33's question answered tonight). Temporary
  variants (file restored from a copy, tree checked): no group + tint 0.36 (a27nogroup, cost8nogroup): d5 -> d5s
  +0.012 ms GPU, p95 0.365 (no spike), but the tint stacks into darker patches where parts overlap (joints):
  REJECTED. No group + strokes only (tint 0, stroke 1; a28strokes): the strokes are world-locked, so overlapping
  sprites draw the same stroke pixels and nothing stacks: an even hatch, lighter than the group (no tint between
  strokes). Committed as the default (D5RigShadow extends Node2D, per-sprite look_d5_shadow, alpha via modulate;
  look_d5_shadow_group removed): cost8e d5 0.152 -> d5s 0.157 GPU median (+0.005), p95 0.161, script 0.29 ms (GPU
  baseline again different from earlier runs: only same-run deltas quoted). Frames: h149st vs h147cone 0 / 0 / 3368 /
  7287 / 14098 px at 32-128, d4 tier 0; a29st = a28strokes (0 px). evidence/d5-cost.json = cost8e. Board
  evidence/item46b_rig_shadow_nogroup.png; ladder row. Showcase frames from h149st / a29st; night_iter8_summary
  rebuilt from h149st / h150all / a30all (D5_FRINGE=1 D5_DOTS=1 package_shot.sh). NEXT 33 updated. Scratch deleted:
  h148all, a26all, cost8nogroup (superseded).
- 05:06 FINAL gates (iteration 8): evidence tool (--no-parity --no-bench) ALL PASS at 3f5af2e (lint 13/13 over 193 files, unit 149/0, scenarios 8/0, selftest ok); 84 untracked evidence PNGs moved aside and restored; tree clean. Parity/bench not run (no native build in this worktree).
- 05:09 FIX (da44a1a, option still default 0): found by eye at 128 in h150all: with D5_FRINGE=1 the cop's cream glove
  carried a red edge that reads as blood (all-ages / doctrine). The fringe now prints only where the source is cool
  steel (b >= r - 0.03). Rivet keeps it: red-lead share at 96 / 128 0.021 / 0.022 (ungated 0.028 / 0.030; off
  0.017 / 0.018; concept body 0.039). Default h154 = h149st (0 px, deleted); package + options h153all vs h150all
  0 / 0 / 0 / 2065 / 3495 px. Board evidence/item43b_fringe_steel_only.png; night_iter8_summary rebuilt from h149st /
  h153all / a31all. Deleted (superseded; the boards were built before): h150all, a30all, h154.
- 05:10 FINAL gates (iteration 8, after the fringe fix): evidence tool (--no-parity --no-bench) ALL PASS at 5d16b85
  (lint 13/13 over 193 files, unit 149/0, scenarios 8/0, selftest ok); 85 untracked evidence PNGs moved aside and
  restored; tree clean. NEXT 31 updated (item43b). The iteration-8 NEXT (31-34) and reading order above stand.
- 05:11 MEASURED the rig shadow in motion (temporary D5RigShadow.on_tier hook in d5_walk_run.gd, restored, tree
  checked; the D4 series has no shadow, so the ratio includes the shadow's own motion): walk D5/D4 HF at 64 px/m
  1.026 -> 1.054 (total 1.078 -> 1.113), at 96 1.131 -> 1.189 (1.176 -> 1.254). By eye (walk11_rs frames 10-12) the
  hatch is world-locked and steady; the extra change is the silhouette edge sweeping across fixed strokes as the
  limbs move (stroke ends appear/vanish at the edge). Modest, not aliasing; for the characters lane: if it reads
  busy in play, soften the shadow's edge (a 1-2 px alpha ramp) so strokes fade in rather than switch.
- 05:12 REJECTED + REVERTED (git restore, tree clean): the soft shadow edge for the rig shadow (look_d5_shadow soft_px 2,
  a 5-tap alpha blur + smoothstep, default 0 elsewhere). Walk D5/D4 HF 1.054 -> 1.054 at 64 px/m, 1.189 -> 1.188 at
  96; frames 0 / 0 / 591 / 991 / 1357 px at 32-128. The look_d4 print quantizes the shadow's alpha (as in the fade
  sweep), so the soft ramp prints as the same stroke switch. My 05:11 suggestion to the characters lane ("soften the
  edge") is therefore withdrawn: the lever would have to be in the print, not the shadow. Scratch deleted: walk11_*,
  walk12_*, h155soft.
- 05:12 session close (cap 05:45): tree clean; the last code commit (da44a1a) passed the full gate run at 5d16b85 (later
  commits are docs only, each passed the pre-commit lint). Nothing half-done or uncommitted. NEXT: the iteration-8 NEXT
  31-34 + reading order above (31 amended), on top of iteration 7's 27-30. Images: 50 of ~50 used; none this iteration.

## Iteration 9 (05:13 -> cap 06:43), BUILD, no images (50/50 used)
- 05:13 read JOURNAL (NEXT 31-34), git log, README gap list. Weakest open item that this lane can move without Codex:
  gap 2, mid-tones (mock 0.104 vs package 0.081 at 32 px/m, "the gap is the roof interiors").
- 05:15 DIAGNOSED (class maps, masters work/i9/classmap.png): the mock's mid-tones sit in its PAPER areas (roofs +
  pavements: mid 0.152 of the bright area vs package 0.102, committed 0.035). The plates themselves already have mid
  0.14-0.18 (plate-level); the print loses it: look_d4 / look_d5_print step ink density into paper / light wash
  (L ~0.77, still "paper") / mid wash (L ~0.44), so a mid tone survives only around the light/mid step. And the mock's
  VALUE STRUCTURE differs from ours: its membrane is a mid tan with cream props and cap; ours is cream on cream.
- 05:16 REJECTED (build_roofs.py first try, D5_ROOF_SHADE prop cast shadows down-right): invisible, the D5 plates
  already carry drawn hatched cast shadows, so a grey shadow lands on ink. Replaced, never shot.
- 05:20 NEW build_roofs.py option D5_ROOF_SHADE (masters, default 0 = the committed build): the MEMBRANE (inside the
  parapet, outside every filled pen outline) is toned to the mock's tan; props, cap and pen lines stay. Rounds (all
  package_shot.sh, hero, roof-area classes on a FIXED mask = i9pkg's bright areas, masters work/i9/roofcls.py):
  i9pkg (package v8 baseline, = h153all 0 px) paper 0.712 / mid 0.102 / dark 0.186 / L 0.695; mock 0.698 / 0.152 /
  0.149 / 0.725. Flat target (np.minimum): sh60 0.571 / 0.217 / 0.212, sh66 0.629 / 0.177, sh70 0.642 / 0.168, sh74
  0.651 / 0.163: mid reached, paper lost. By eye (work/i9/sh_board.png, m74_board.png): the mock's structure at 32
  (props pop), but at 64 the flat tone wipes the membrane's grime and the mural fist merges into the roof: REJECTED.
  Plate lines gamma 0.45 -> 0.6 (union hall 0.65 -> 0.8) alone (i9g6): dark 0.186 -> 0.173, mid 0.096: not the lever
  alone. Scaled paper (grime kept) + fist wash 0 (i9m74f): still flat at 64.
- 05:24 KEPT (as a PACKAGE component): D5_ROOF_SHADE_MOT=1 = the tone applied as 0.2-0.5 m blotches (seeded per roof),
  + fist wash 0 + lines gamma 0.6 / 0.8 (i9mot): roof areas 0.692 / 0.132 / 0.176 / L 0.688 (sum |err| vs mock 0.101 ->
  0.053); whole frame (cls.py) L 0.455 = 0.455, paper 0.30 -> 0.29, mid 0.09 -> 0.11 (mock 0.11), ink 0.11 = 0.11;
  rim dL 0.610 / verm dE 77.5 / teal dE 57.6 identical (actor read unchanged). Without the gamma change (i9mot45) the
  lines add dark (0.191): both needed. By eye: at 32 the mock's tan membrane with cream props; at 48/64 a weathered
  tan / cream roof (more "Inked Grime" than the clean v8 membrane); the fist takes the blotches as weathered paint,
  its outline holds at 32. Pan (48 px/m car, mural roof crop --anchor=9.7,-8.5, 40 ticks): 0.00000 v8 and v9 (the
  thin print's grain is world-locked; the crop checked by eye). Under the COMMITTED print (tools/roof_shot.sh i9cmot)
  it is small: roof mid 0.035 -> 0.044, frame L 0.420 -> 0.416 (darker, away from the mock): NOT a committed default.
  D4 tier 0 px everywhere. Arena (a32v9 vs a31all): the OSHA / tall roofs take the tone at 32-96 (71k-123k px), by
  eye not worse; the kill-cam 128 0 px.
- 05:27 TOOLS (masters): package_shot.sh = package v9 by default (membrane + gamma 0.6 / 0.8 + fist 0; the pre-v9
  package = D5_ROOF_SHADE=0 D5_ROOF_LIFT_B=0.45 D5_ROOF_LIFT_B_BY=union_hall:0.65 D5_FIST_WASH=0.18: i9pre = i9pkg 0
  px, i9v9 = i9mot 0 px at 32-128); a pan mode (package_shot.sh <round> pan [--anchor=x,y]); NEW roof_shot.sh (the
  committed scene with the caller's D5_ROOF* plates, restored after).
- FRICTION (fixed): the package restore step inherited the caller's D5_ROOF_LIFT_B / D5_FIST_WASH (twice "RESTORE
  FAILED", tree restored by hand both times, checked clean); it now unsets every D5_ROOF* / D5_FIST* / D5_INK*. And a
  Python-written line continuation left a literal "\n" in package_shot.sh, so two rounds shot the COMMITTED plates
  ("n: command not found", still "tree restored"): both deleted, line fixed, re-shot, verified byte-exact above.
- 05:30 Board evidence/item48_roof_membrane.png (mock / v8 / v9 at 32, roof crops 32 / 48 / 64, numbers); ladder row.
