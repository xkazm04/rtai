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
