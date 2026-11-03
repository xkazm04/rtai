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
