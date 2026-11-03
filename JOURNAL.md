# JOURNAL - night lane d4-production (branch n-d4)

## 2026-11-02 21:09 iteration 1, BUILD
- Read: AGENTS, manifest, shaders README, city_textures.json. State: vehicles 44-53, decals 54-64 and the
  kerb corner (10) are `art: null` (flat placeholder). Moving traffic uses the procedural `_body()` steel
  quad in `features/city/view/crowd_layers.gd` (rendering code, not my scope): parked vehicles take the
  table art; traffic needs a visual-engine change (request below once the atlas exists).
- Session stops 22:39 at the latest: plan = vehicles sheet (Codex) -> slice -> table -> before/after selftest.

## 21:30 MILESTONE vehicles (work order 1)
- 3 Codex sheets (d4n_veh_a/b/c), 31 cells, **0 rejected** (all straight down, nose +x). Build:
  `masters:night/d4-production/tools/build_vehicles.py` (key, fill enclosed key holes, one scale per vehicle across
  its damage states, letterbox to the table footprint, re-ink, vermilion only on the cruiser light bar,
  wrecks burnt darker), `build_traffic.py` (atlas), procedural teal hijack overlays.
- Wired ids 44-53 in `city_textures.json` (ids/footprints unchanged). Placeholders 22 -> 12.
- Evidence: `gtai-masters/night/d4-production/before_v|after_v/table-{32,48,64}ppm.png`, `extras-*` (damage
  states, wrecks), `selftest-*` (unchanged: the junction shows only moving traffic).
- Dev evidence rig added: `project/dev/showcase/asset_board.gd` (+ `_run`), `--page=table|extras`.
- **REQUEST visual-engine:** moving traffic still draws `crowd_layers.gd _body()` (steel quad). Wire
  `features/city/art/vehicles/traffic_atlas.png` (2x4 cells of 6.4x3.2 m, order in that README) as the RL_CARS
  texture with `variant -> cell` UVs; `traffic_atlas_hijack.png` for the hijacked state; damage states need a
  state hook. Car shadows can keep the blob or use the atlas alpha.

## 21:45 MILESTONE decals, kerb corner, FX atlas (work order 2 part, 3)
- Decals: 1 Codex sheet (d4n_decals), 16 cells, 0 rejected. 11 table decals (54-64) wired; dynamic: blood_s/m/l,
  scorch, scorch_b (not in the table, README in `features/city/art/decals/`). Puddle interior = translucent ink.
- Kerb corner (id 10): code only (`build_corner.py`: the curb() bands of build_ground along a rounded distance
  field). **City table placeholders now 0** (was 22). Evidence: `after_d/corner-{32,48,64}ppm.png` (joins both
  straights seamlessly), `after_d/table-*`.
- FX: 1 Codex sheet (d4n_fx), 32 cells, **1 rejected** (the casing: a cylinder with a side face). Atlas
  `features/fx/art/fx_atlas.png` 8x4 x 256 px, layout in that README. Ink splat burst got a cream sticker rim
  (ink on charcoal disappears otherwise).
- Running count: 5 Codex images, 1 cell rejected of 79.
- **REQUEST visual-engine / FX owner:** no FX system draws `fx_atlas.png` yet; no decal system spawns blood/scorch.

## 21:50 MILESTONE cream-coat ped (work order 4, part 1)
- Finding: at 32/48 px/m print_part's mid band is only d 0.36..0.40 (else cream / ink); the coat-hat look printed as
  one cream blob because the hat BRIM (not the coat) covers the figure. Re-toned the cream fill of `ped/torso.png`
  and `ped/head_hat.png` to a flat warm grey at d = 0.39 (`coat_value.py`); parts layout, pivots, alpha unchanged.
  Probes: d 0.38 (too subtle), d 0.60 (prints solid ink = same as the jacket, rejected for variety), 0.39 kept.
- Evidence: `before_c|after_c2/rig-{32,48}ppm*.png`, crowd atlas rows 0/2/3 (`work/peek_atlas3.png`).
- Affects looks 0 coat-hat, 2 coat-hood, 3 jacket-hat (hat brim), 7 coat-hair. Cops unchanged.

## 21:40 MILESTONE generic roofs (work order 2, roofs)
- 4 Codex sheets d4n_roofs_g1..g4 (2 roofs each), style anchor = shipped building_tall.png. **1 of 8 rejected**
  (g1 left: laundry hanging in side view). 7 shipped: `features/city/art/roofs/roof_*.png`.
- Evidence: `after_r/roofs-{32,48,64}ppm.png` (new roofs interleaved with the district set through look_d4).
- **REQUEST generator owner:** the generator only picks ids 14-23; to use the generic roofs append table rows
  (65+, size 8.4) and widen the pick (golden hashes will move: AST-12 re-bake).
- Street furniture: all 20 props are already D4 (F-08); nothing on old art found in the table.

## 21:50 MILESTONE 5 new pedestrian parts (work order 4, part 2)
- 1 Codex edit of the shipped d4 `ped_a` sheet (anchor kept = scale lock), 5 cells, 0 rejected:
  `torso_hoodie` (solid ink), `torso_overalls` (grey wash + ink straps), `head_cap`, `head_bald`, `head_beanie`.
  Sliced with the d4 slice_chars method (`slice_ped_d.py`), mid greys snapped to print density 0.39, entries merged
  into `ped/parts.json` (sizes/pivots from joints()).
- Evidence: `before_p|after_p/parts-{32,48,64}ppm.png` (dev/showcase/parts_board_run.gd: torso+head+halo printed
  through PartMaterials on pavement and asphalt; looks 5-8 are the new combos).
- **REQUEST characters owner:** `RigVariant.crowd()` has 8 fixed slots (= SimConst.CLIP_VARIANTS). Suggested:
  slot 3 jacket-hat -> hoodie-cap (`head_cap`, `torso_hoodie`), slot 7 coat-hair -> overalls-bald
  (`head_bald`, `torso_overalls`); or raise CLIP_VARIANTS to 10-12 for hoodie-beanie and overalls-cap too.
  The rig pool's prewarm must list the new parts.

## 22:00 MILESTONE pickup tokens (work order 5, pickups)
- 1 Codex sheet d4n_pickups, 8 tokens, 0 rejected. `assets/pickups/*.png` 128 px, README with the accent table.
- FRICTION: under the world pass (look_d4) at 32 px/m the Sobel ink edges fill the glyphs in (dark grey tokens);
  in the item pass (look_d4_item) they read cleanly. Evidence `after_k/pickups-{32,48,64}ppm.png` + `-2x` crops
  (dev/showcase/parts_board_run.gd --page=pickups). **REQUEST visual-engine:** draw pickups in the item pass.

## 22:05 MILESTONE HUD frames (work order 5, HUD)
- 1 Codex sheet d4n_hud, 9 elements, 0 rejected: cash panel, wanted panel + 3 pips, ammo ticket, soul card idle /
  active (teal), memo frame. `features/hud/art/` + README (socket centres, text areas, UI scale 0.5).
- Evidence: no HUD scene exists, so the frames are shown as a **Python composite mock** over the in-engine
  selftest frames (`after_h/hud-mock-{32,48}ppm.png`), labelled as such. Not an in-engine HUD.
- Gates: lint 13/13, unit 142/142, scenarios rc 0 (after parts + pickups).

## 22:15 raise quality: evidence gaps closed (FX, hijack, in-city)
- `dev/showcase/city_frame.tscn`: the real World + CitySystem + CityView, 3 fixed street foci, 32/48 px/m.
  Before (base table, 22 placeholders) vs after (0): `before_city|after_city/city-{0,1,2}-{32,48}ppm.png`.
  In the city now: D4 parked cars, drain grates, oil stain, manholes, lane arrows. The one placeholder left on
  screen is MOVING traffic (code, see the traffic-atlas request).
- `--page=fx` (atlas in the item pass) and `--page=hijack` (teal overlays over the cars): `after_x/`.
- `ladder.png` (night/d4-production) has a row per item: before | after | target crop.
- Note for the owner: the target frame paints the blood splat VERMILION; the brief asked for ink, I kept ink.
- 21:45 glass_shards decal: scatter scaled to 70 % inside its 3 m footprint (the full-size pile read as paper confetti). Before/after: `after_d|after_g/table-48ppm.png`.
- 21:50 FX atlas cell (6,3) filled: a casing redrawn LYING FLAT (master d4n_casing, 4 cells, 0 rejected; the mouth shows as a small ellipse, accepted). Own scale, documented in the FX README. Evidence `after_x2/fx-*`.
- 21:55 vehicles iteration 2: side-by-side with the target (`night/d4-production/target_compare.png`) showed the
  target's cars carry a far bolder outer outline. Added a 5 px inner ink stroke (texture px at 80 px/m; ~3 px at
  48, ~2 px at 32), footprints unchanged, all 39 vehicle files + atlases rebuilt. Before/after: `after_v|after_v2`.

## 22:00 SUMMARY iteration 1
- Codex: **15 images** (one at a time, no rate limit hit), 113 cells, **2 rejected** (FX casing standing upright;
  roof g1-left laundry in side view), both replaced. Masters + prompts + tools: `gtai-masters/night/d4-production/`
  (`gen/`, `tools/`, `work/`), ladder `ladder.png`, target crops `target_compare.png`.
- City texture table: placeholders 22 -> **0** (vehicles 44-53, decals 54-64, kerb corner 10).
- Native CitySim built in this worktree (`scons` debug + release) so parity/bench can run; build output is ignored.
- FRICTION (not mine, for the generator owner): text-bearing district roofs are drawn rotated, so `HQ` reads upside
  down in `after_v2/city-1-32ppm.png` (roof rotation in tile_painter). Suggest rot 0 for roofs with lettering.

## REQUESTS for the Director to relay
1. visual-engine: moving traffic -> `features/city/art/vehicles/traffic_atlas.png` (2x4 cells, 6.4x3.2 m, README);
   hijacked state -> `traffic_atlas_hijack.png`; damage states `<car>_d1/_d2` need a state hook.
2. visual-engine: draw pickups (`assets/pickups/`) and FX (`features/fx/art/fx_atlas.png`) in the item pass.
3. characters owner: RigVariant slots for the new ped parts (hoodie, overalls, cap, bald, beanie), see 21:50.
4. generator owner: table rows + pick range for the 7 generic roofs (`roof_*`) and the dynamic decals.
5. owner: blood is ink per the brief; the target frame paints it vermilion. Decide.

NEXT:
- If traffic gets wired, re-shoot `dev/showcase/city_frame.tscn` (before = `after_v2`) and tune car values against
  the moving-car item pass (steel_out) so parked and moving cars match.
- Apply the bold inner stroke test to props (F-08 art) at 32 px/m against target_compare; keep only if it reads better.
- A HUD scene would let the frames be judged in-engine (now only a composite mock).
- Fill more FX: shotgun shell + casing scatter are in `gen/out/d4n_casing.png` (unused cells 2-4).

## 22:00 GATES
- `tools/evidence/run.mjs` (after the native build): lint PASS, unit 142/142 PASS, parity PASS (bit for bit, mutation
  caught), selftest PASS (65 art textures, **0 placeholders**). scenario-tests FAILED once: rig_stress 200 people
  p50 1.022 ms > 1.0 ms while my asset board rendered at the same time; re-run alone: **8/8 PASS**, p50 0.467 ms.
  FRICTION: contention, not a regression; never render while gates run.
- bench FAILED first: `build/export/windows-bench/` did not exist in this fresh worktree (the runner does not
  create it). Created it (git-ignored) and re-ran the bench alone (result below).
- bench (exported release, 3 x 4 scenarios x 60 s, shared box at ~48 % CPU from other processes):
  run 1 (lane table) p99 8.92 ms, 1% low 48 fps, worst swap 126 ms: MISS p99 + swap.
  A/B (base ad2078b table, same box) p99 5.90 ms, 1% low 95 fps, worst swap 91 ms: MISS swap.
  run 2 (lane table) **p99 2.85 ms, 1% low 85 fps, worst swap 31 ms: PASS** (rc 0).
  Reading: the misses track machine load (the base table misses worst swap too); no reproducible regression from
  the 22 new textures. Still worth watching: every vehicle/decal id is now its own texture (the placeholders shared
  one per class), i.e. more 2D batch breaks; an atlas for vehicles + decals would remove that (visual-engine).
  `build/evidence/bench.json` is from the full run (export dir missing) -> stale FAIL; the passing standalone runs
  are in the bench runner's own output. Re-run `node tools/evidence/run.mjs` on an idle box in the morning.
- 22:28 `run.mjs --no-parity --no-bench` at HEAD: lint PASS, unit 142/142, **scenarios 8/8**, selftest PASS
  (0 placeholders). parity PASS earlier at the same code. bench.json stale (see above). Session ends here.
NEXT (morning, first thing): on an idle box run the full `node tools/evidence/run.mjs` so bench.json is current
(`build/export/windows-bench/` now exists in this worktree); then the NEXT list above.

## 2026-11-02 22:29 iteration 2, BUILD (raise the weakest item)
- Picked: HUD frames (only a Python composite mock existed). Built `dev/showcase/hud_overlay.gd` + `city_frame.gd
  --hud=0.5,0.4`: the frames in-engine over the real city at 32/48 px/m with sample digits (digits only, no UI words).
- In-engine finding: the bare cream frames melt into the cream pavement (cash + wanted panels at the top sit on the
  pavement in focus 0), and the README text area (x 130) overlapped the banknote glyph (ends x ~165).
- Fix: `tools/hud_plate.py` - a 5 px ink rim + 8,10 px charcoal drop shadow on the 6 frames (pips untouched), README
  sizes/offsets (+7 frame px) and text area x 185. Probe RIM 7 was too heavy (ate the torn-paper edge), 5 kept.
  Before/after: `after_hud|after_hud2/city-*-hud{50,40}.png`; ladder rows appended. Kept: reads better.
- MILESTONE HUD in-engine. Note for the HUD owner: UI scale 0.4 at 1280 x 800 reads and leaves more street.
- 22:40 MILESTONE props stroke (NEXT item from iteration 1). New board page `--page=props` (every table prop on road
  and pavement). `tools/props_stroke.py`: the vehicles' inner ink stroke at 4 px (3 px for textures < 64 px) on all
  20 F-08 props (80 px/m). Before/after `before_pr|after_pr/props-{32,48,64}ppm.png` + in-city
  `after_hud2` vs `after_pr_city` (city-0): bolder silhouettes on the paving (newsstand, vending, barrier, bollard now
  an ink ring, sign); on the charcoal road the stroke is invisible (ink on ink), neutral in the city frame. Kept.
  Originals: `masters:night/d4-production/work/props_orig/`.
- 22:44 MILESTONE cash token. In the 32 px/m item-pass board the old cash token (grey banknote bundle, hatched) was
  the muddiest glyph. Codex `d4n_cash` (image 16 of the night; refs: template, the d4n_pickups sheet as anchor, the
  target frame): 4 cash redesigns + 4 value tiers, all solid ink silhouettes. **1 of 8 rejected** (folded bill reads
  as an envelope). Probe of all candidates in-engine (`probe_cash/`), picked cell 1 (one ink note + vermilion strap)
  as `cash.png`; tiers `cash_coins`, `cash_bundle`, `cash_bag` added (optional). Before/after `after_k|after_k2`.
  Provenance: 4 new lines (cash) + 20 props + 6 HUD frames (`tools/prov_rev.py`: the file's last line + new sha + edit).
  Board pitch 2.0 -> 1.6 m so 15 tokens fit (dev only).
- 22:48 MILESTONE token family. Codex `d4n_tokens2` (image 17; anchor = d4n_cash), 8 cells, **0 rejected**. Probed
  all beside the old set in-engine (`probe_tok/`): weapon (pistol; the wrench + pistol glyph was busy), ammo, armor,
  keycard replaced; health kept (already reads); SMG, wrench, ammo box unused. Before/after `after_k2|after_k3`.
  The 11 tokens are now one solid-silhouette family; the item-pass request to visual-engine still stands.
- 22:55 REVERTED (never installed): damage-state soot wash (`tools/damage_soot.py`, mask = |dN - base| blurred).
  The Codex damage states are re-drawn, not registered pixel for pixel, so the mask covers most of the body and the
  wash prints as airbrush blotches (van_d2 grey all over): worse, against the "no airbrush" doctrine. Peek
  `work/dmg_soot_peek.png`. d1 stays subtle at 48 px/m (fine pen cracks); a real fix is a damage overlay drawn as
  bold ink (a crumple + crack decal set aligned per car) or smoke FX from the FX atlas on damaged cars (FX owner).
- 22:52 MILESTONE damage states read. Codex `d4n_dmg` (image 18): 8 bold ink damage marks, **0 rejected**.
  `tools/damage_marks.py` stamps them on the 18 shipped d1/d2 (registered by construction: windscreen found on the
  intact car; marks clipped inside the outer stroke; rotation from a crc32 of the name, no RNG): d1 star crack + 3
  holes, d2 shattered crack + 5 holes + scorched nose. Holes moved back to x 0.28 so they miss the cruiser light bar.
  Before/after `now_v|after_dm/extras-{32,48,64}ppm.png`: at 32 px/m every d1/d2 is now distinct from intact.
  Unused marks (scratch, dent, smudge) kept in `work/dmg/` for a dynamic decal set.
- 23:00 MILESTONE quiet paving (biggest gap vs the target frame, found by putting city-0 beside d4h2_mock).
  The sidewalk slab joints (4 px of 88,82,82 every 96 px) print as a heavy black grid through the world pass, so the
  pavement read as bathroom tiles and fought the people and props; the target's paving is quiet with thin joints.
  `tools/paving_joints.py` redraws only thin joint lines inside the paving interior (same colour is the asphalt, so:
  joint colour AND thin AND next to cream AND 6 px clear of the kerb, tile borders inside) as a 2 px centre line
  (mod 96 in {95, 0}, so tiles still join at seams). 5 tiles: sidewalk_tone, curb_straight_tone{,_b,_c},
  curb_corner_tone. Road tiles untouched (the first pass would have whitened ~2000 px of lane edges per road tile;
  caught on the counts, not shipped). Iterations, all looked at: v1 kerb ticks erased (fixed: paving interior mask);
  2x2 dark crossings left (fixed: wider cream reach); in-engine the crossings still printed as ink dots at 118 grey
  (gap at crossings did not help: line ends print too) -> tone probe 118 / 140 / 160 (`work/joint_tones.png`):
  **140 kept** (grid visible, dots nearly gone; 160 loses the grid). Left: faint dots at the 8 m tile seams and short
  dark joint stubs at the kerb (read as joints meeting the kerb).
  Before/after: `after_hud2|after_pr_city` vs `after_sw/city-*`, `after_pr|after_sw/props-*`, `after_sw/corner-*`.
  **For the F-08 / ground owner:** build_ground.py would regenerate the dark joints; set its joint colour to
  140,132,128 and 2 px if the ground is ever re-baked. Revert = this one commit.
- 23:00 paving follow-up: with the grid quiet, the darker grey slabs kept 4 px black borders and read as UI boxes
  (`after_sw/city-2-48ppm.png`). Paving threshold 0.7 -> 0.6 (grey slabs are lum 0.65-0.70; asphalt 0.33; kerb still
  protected by the 6 px interior margin): borders now the same thin grey (`after_sw2/`). Small ink "+" marks remain at
  grey-slab corners (print-pass edge response), accepted. Gates after the first paving commit: lint, unit 142/142,
  scenarios 8/8, parity, selftest (0 placeholders) all PASS.
- 23:05 MILESTONE dynamic decals from the spare d4n_dmg marks: `bullet_holes_s` (1.2 m), `bullet_holes_m` (1.6 m),
  `gouge` (1.6 m), `oil_splash` (1.2 m) in `features/city/art/decals/` (README rows, provenance). New board page
  `--page=decals` (every decal PNG on the road, `after_dd/decals-{32,48,64}ppm.png`). First sizes (0.8 / 1.2 m) made
  the holes vanish at 32 px/m; raised. FRICTION: new PNGs imported with mipmaps OFF by default (the 3 cash tiers too,
  committed that way at 22:44) -> fixed to match the folder; all my art folders now 0 mipmap-off imports.
- 23:07 REVERTED probe: grey paving slabs lerped 40 % to cream (`tools/paving_slabs.py`) to kill the "+" dots at their
  corners: no visible change (`probe_slab/`, `work/slab_ab.png`); the dots are the print pass on the slab corners.
  Not shipped.
- Codex tonight: **19 images** (15 iteration 1 + cash, tokens2, dmg in iteration 2; one at a time, no limit hit).
  Iteration 2 cells: 24, **1 rejected** (folded-bill cash token). Night total 137 cells, 3 rejected.

## 23:10 SUMMARY iteration 2 (raise the weakest items; all with before/after in-engine at 32/48, 64 on boards)
1. HUD in-engine (was a Python mock): `dev/showcase/hud_overlay.gd` + `city_frame --hud=`; frames plated (ink rim +
   shadow) because they melted into the cream pavement; cash text area fixed. UI scale 0.4 suggested.
2. Props: the vehicles' inner ink stroke on all 20 F-08 props (bolder on the paving, neutral on the road).
3. Pickups: one solid-silhouette token family; cash, weapon (pistol), ammo, armor, keycard redrawn; 3 cash tiers.
4. Vehicle damage states read at 32-48 px/m: bold ink crack / holes / scorch stamped (registered) on 18 d1/d2.
5. Quiet paving: slab joints thin mid-grey instead of a black grid (the largest gap vs the target frame), incl. the
   grey slabs. 5 ground tiles; roads untouched.
6. Dynamic decals: bullet holes x2, gouge, oil splash; board pages `props`, `decals`.
- Reverted / not shipped: damage soot wash (airbrush blotches), slab lightening (no effect).
- Summary sheets: `masters:night/d4-production/night_iter2_summary.png` (iteration-1 end vs now vs target),
  `target_compare_iter2.png` (target crops vs in-engine crops, iteration 1 and 2); ladder rows
  appended for every item. Gates at 23:02 (after paving): lint, unit 142/142, scenarios 8/8, parity, selftest PASS.

## REQUESTS (iteration 2 additions; iteration 1 list above still stands)
6. ground / F-08 owner: build_ground.py joint colour -> 140,132,128 at 2 px (else a re-bake brings the black grid back).
7. visual-engine: the print pass inks a "+" at grey-slab corners and at dense line crossings; a slightly higher edge
   threshold for low-contrast cream-on-cream edges would clean the paving further.
8. HUD owner: frames are plated now (+7 px offsets in the README); 0.4 UI scale at 1280 x 800 reads.
9. FX / decal owner: dynamic decals now include bullet_holes_s/m, gouge, oil_splash (README sizes).

NEXT:
- Owner review of the paving change first (biggest visual change of the night; revert = commits 0e96cb6 + 1629128).
- If traffic gets the atlas: re-shoot city_frame and compare parked vs moving cars.
- Font: the HUD digits use Godot's default font; a D4 hand-inked display font (OFL, owner OK) is the next HUD step.
- Unused masters for later: d4n_tokens2 SMG / wrench / ammo box, d4n_cash cash_b/c/d, d4n_casing cells 2-4.
- 23:07 MILESTONE tank_tracks decal: it drew the TREAD (cream link plates) and read as railway rails on the road;
  recoloured to the imprint (ink, alpha from luminance: plates = deep grooves) (`tools/track_imprint.py`).
  Before/after `after_dd|after_tt/decals-*`. Kept.
- 23:10 PROBE, NOT SHIPPED (owner decision): cop vermilion. The cop art is 38 % vermilion torso + 43 % upper arms, so a
  riot frame is dozens of vermilion bodies; the target's cop is ink and cream with vermilion only on the muzzle flash.
  Probe `tools/cop_accent.py`: torso vermilion -> ink-navy uniform, upper arms kept (`probe_cop/`, `work/cop_ab.png`):
  about half the vermilion, but the shoulders overlap into one central vermilion blob from above (reads as a bullseye).
  Mixed; the doctrine lists cops as a vermilion case. **Owner: full vermilion uniform (now) or an ink uniform with a
  small vermilion accent (cap band / armband, would need a redraw, not this recolour)?** Cop torso restored.
- 23:12 GATES at 10a529a (after every iteration-2 art commit incl. tank_tracks): `run.mjs --no-bench` rc 0: lint 13/13,
  unit 142/142, scenarios 8/8, parity bit-exact (mutation caught), selftest 0 placeholders. bench not re-run (shared
  box; see iteration-1 note); textures only changed, no new texture count in the city table.
- 23:12 pickups re-shot on the quiet paving (`after_k4/`): iteration-1 tokens -> iteration-2 family, ladder row
  `after_k|after_k4`. All 11 tokens read at 32 px/m on paving and asphalt (item pass).
- 23:14 hijack board re-shot (`now_x/hijack-*`): teal overlays still register on the stroked intact cars; damage
  states carry no overlay by design. Note: build_corner.py (iteration 1) takes the SHIPPED sidewalk_tone as its paving
  source, so a re-run keeps the new light joints.
- Session end for iteration 2. Branch n-d4, HEAD after this entry; tree clean; masters + tools in
  `gtai-masters/night/d4-production/` (tools added tonight: hud_plate, props_stroke, prov_rev, damage_soot (rejected),
  damage_marks, paving_joints, paving_slabs (rejected), track_imprint, cop_accent (probe)).

## 2026-11-02 23:11 iteration 3, BUILD (raise the weakest item)
- Re-read the journal, git log; put the latest city frame (`after_sw2/city-0-32ppm`) beside d4h2_mock again.
- 23:15 MILESTONE bold road markings (the biggest gap left vs the target). The tiles paint the lane dashes and edge
  lines cream, but only 8 px / 6 px wide (8 / 6 cm at 96 px/m): at 32 px/m the print pass inks both edges of a
  2-3 px band, so the markings printed as DARK lines (`before_ln/city-0-32ppm.png`). The target's dashes are bold
  cream. `tools/lane_bold.py`: every thin cream component (thickness <= 10 px, area >= 200; pavement, kerb top strip
  within 30 px of the pavement and the crosswalk bars excluded) grown by a 6 px disk inside the asphalt wash only
  (crack ink, lum < 65, runs through the paint), a +-1 px wobbly edge, re-worn with asphalt specks (seeded per
  file, tool-side). Dashes 8 -> 20 px, edge lines 6 -> 18 px. 10 tiles: road_straight{,_b,_c}, road_straight_v{..},
  curb_straight{..}, curb_corner. Intersection untouched (its crosswalk bars are already bold).
  First pass also widened the kerb's thin cream top strip (looked messy, caught in `work/lanes_peek.png`, fixed).
  Before/after `before_ln|after_ln/city-*-{32,48}ppm.png`: markings now read cream at 32 and 48 px/m, as the target.
  Kept. Commit 571460b. Gates at 571460b: `run.mjs --no-bench` rc 0 (lint 13/13, unit 142/142, scenarios 8/8,
  parity bit-exact, selftest 0 placeholders).
- 23:18 MILESTONE calm paving. Correction of an iteration-2 note: the "+" ink dots at the grey-slab corners are NOT
  the print pass, they are drawn in the texture (4 px dark joint crosses the joint script did not reach). And the 8 m
  tile repeat printed its crack squiggles as a regular grid of identical cracks along every street.
  `tools/paving_calm.py`: removed 13 of 19 cracks (slab content copied from a clean slab of the same tile) and
  redrew the 5 crosses as the thin 140-grey joint. sidewalk_tone (8 -> 3 cracks), curb_straight (5 -> 1),
  _b (4 -> 1), _c (2 -> 1). Hatch stains and grey slabs kept (they carry the hatch character).
  Before/after `before_cm|after_cm/city-*`: calmer pavement, the dots are gone, people and props read better. Kept.
  Commit 724e5d9.
- 23:22 MILESTONE clean road paint. In the junction (selftest frame) the crosswalk bars carried ~10 % asphalt wear
  blobs that print as ink dots (a leopard zebra), and my widened lanes ~4 %. The target's paint is clean cream.
  `tools/marking_wear.py`: dark blobs fully inside the paint (incl. their anti-aliased rim; runs reaching the paint
  border = cracks / edge notches stay) filled with the paint cream, re-specked at 0.6 % (1-2 px). 11 tiles (all
  road + curb + intersection). Iterations, all looked at: v1 treated the paving slabs as paint (joints split the
  pavement into < 40 000 px pieces; fixed by closing before sizing); v2 left the big blobs (a 1-px restriction line,
  removed); v3 left grey rings (fill threshold now cream - 18). Before/after `before_wr|after_wr/selftest-*`
  (junction crops `work/wr_ab_{32,48}.png`). Kept. Commit 08231f6. Note: the selftest crowd is not frame-identical
  between runs (the ground is what is compared).
- 23:24 REVERTED probe: grey paving slabs lerped 60 % to cream to break the 8 m repeat on wide plazas
  (`probe_slab3/`, `work/slab3_ab.png`): the print pass steps them to nearly the same grey; no visible gain. The real
  fix for plaza repetition is 2-3 sidewalk variants + a generator pick (REQUEST 10 below).
- 23:30 MILESTONE roofs toward paper. Measured in-engine: roof / pavement luminance 0.54 (city-1) - 0.60 (city-2);
  the target's roofs are 0.88 of its pavement ("dark streets against cream pavements AND roofs"). The roof art's
  wash greys (lum 0.3-0.8) print as the light / mid wash, so roofs read mid-grey. `tools/roof_lift.py`: wash greys
  lifted 70 % toward each roof's own paper cream (ink below lum 0.22 kept, full lift from 0.50). Probe s 0.5 changed
  the texture mean by only +0.035 (the ink dominates), s 0.7 / lo 0.22 kept: in-engine 0.61-0.67, hatch and ink
  detail intact, glass panes lose their grey (accepted). All 17 roofs (10 district + 7 generic) for one set.
  Before/after `after_wr|probe_roof/city-{1-48,2-32}ppm.png` (+ target crop `work/roof_ab.png`), board
  `before_rl|after_rl/roofs-{32,48,64}ppm.png`. Kept. Commit c133a77. Originals `work/roofs_orig3/`.
- 23:34 MILESTONE cream kerb. The straight kerb was a 13 px hatched "face" band + ink line + 7 px cream top + ink
  line: at 32 px/m a dark band with joint ticks, reading as a pipe with bolts. From straight above a kerb is its cream
  stone top; the target draws a cream band with an ink edge and the hatched gutter shadow on the road.
  `tools/kerb_cream.py` (straight x3): rows 286-287 ink, 288-307 kerb cream (the face hatch and the middle line
  gone), 308-309 ink and the gutter hatch kept, the 1.25 m joint ticks run through. Corner: `build_corner.py` gained
  KERB_CREAM (same rows at the seam, checked column by column) and is rebuilt from the calmed pavement, then
  lane_bold + marking_wear as the straights. Before/after `before_kb|after_kb/city-*`, `corner-{32,48,64}ppm.png`:
  the road edge is a cream kerb + dark gutter shadow, closer to the target; the corner joins both straights. Kept.
  Commit 84a1a2f. Gates at 16df2e5 (roof lift): run.mjs --no-bench rc 0 (lint, unit 142/142, scenarios 8/8, parity,
  selftest 0 placeholders).
- 23:39 MILESTONE 2 m slabs. With the cracks and crosses calmed, the pavement still read as graph paper at 32 px/m
  (a 1 m joint grid = a line every 32 screen px); the target lays large slabs. `tools/paving_bond.py`: two layouts
  probed in-engine on the same frames (`work/pave3_{2_32,0_48}.png`: 1 m grid | bond | 2 m):
  (a) 2 x 1 m running bond (alternate verticals dropped per row): along the kerb at 48 it looks like the target's
  long slabs, but on the wide plaza at 32 it reads as a BRICK WALL -> rejected; (b) 2 m square slabs (every other
  joint line both ways dropped; the gap takes the paving 3 px inside the slab so the grain continues; crossings
  dropped only when both lines go; the dark joint stubs at the kerb go with their joint): calmest, people and props
  read best, closest to the target's large slabs -> **kept**. Kept joints redrawn at 128 grey (fewer lines, so a
  touch firmer than 140). sidewalk_tone + curb_straight x3, corner rebuilt from it (build_corner + lane_bold +
  marking_wear). Bugs caught on the peeks: horizontal joints first filled from beside themselves (no change), and
  crossings on kept lines left dots. Before/after `after_kb|probe_g2/city-*`, `corner-*`. Commit b787142.
- 23:41 MILESTONE clean paint decals. road_arrow + stop_line carried diagonal hatch wear inside the cream that
  printed as a dark wavy stroke at 32 px/m (city-0 arrows). `tools/paint_decal_clean.py`: inside the alpha mask
  eroded 5 px (3 for the stop line; the ink outline stays) px darker than cream - 18 take the cream (15 % residue).
  Before/after `probe_g2|after_pd/city-0-32ppm.png`, board `after_pd/decals-*`: clean solid arrows. Commit e01bbb1.
  Gates at b787142 (2 m slabs): run.mjs --no-bench rc 0 (lint, unit 142/142, scenarios 8/8, parity, selftest).
- 23:44 MILESTONE dark glass. Target compare (`work/cars_vs.png`): the target's cars carry near-black glass, ours
  hatched dark grey that mipmaps to a pale wash at 32-48 px/m (the taxi read all cream). `tools/glass_ink.py` on the
  9 intact vehicles: areas inside the body (alpha eroded 6 px, so the outer stroke stays) with a 3 px local mean
  below lum 0.42, opened 2 px (thin seams excluded), saturated px (light bar) excluded, pulled 60 % to ink. The
  cruiser's black panels go darker too (its black-and-white read gets stronger), sedan_c's hatched roof reads black.
  Damage states untouched on purpose: pale crazed glass, so their ink cracks stay visible (intact = dark glass).
  Traffic atlases rebuilt (build_traffic.py from the new intact cars). Hijack overlays still register
  (`now_x|after_gl/hijack-48ppm.png`). Before/after `before_gl|after_gl/table-*`, `after_pd|after_gl/city-*`:
  bolder car silhouettes, closer to the target. Kept. Commit 3fb53b0.
- 23:45 MILESTONE kerb ticks. On the cream kerb the 1.25 m INK joint ticks read as a railway ladder at 32 px/m
  (`after_gl/city-1-32ppm.png`); `tools/kerb_ticks.py` redraws them inside the kerb band in the 128 joint grey (ink
  edges kept). Before/after `after_gl|after_tk/city-1-32ppm.png`. Kept. Commit 21f6ec9.
- 23:50 GATES at 21f6ec9 (every iteration-3 art commit): `run.mjs --no-bench` rc 0 - lint 13/13, unit 142/142,
  scenarios 8/8, parity bit-exact (mutation caught), selftest 0 placeholders. bench not re-run (textures only, no new
  texture ids; shared box, see iteration 1).

## 23:50 SUMMARY iteration 3 (raise the weakest items; every change before/after in-engine, 32 + 48, boards at 64)
Sheet: `masters:night/d4-production/night_iter3_summary.png` (end of iteration 2 | now, 3 city foci + junction,
target below). Ladder rows appended for every item.
1. Road markings bold cream (8/6 px -> 20/18 px): they printed as dark lines at 32 px/m. Biggest single gain.
2. Paving calmed: 13 of 19 repeated crack squiggles gone, the in-texture "+" crosses removed (iteration-2 note
   corrected: they were in the art, not the print pass).
3. Road paint wear: zebra + lanes lose the dense specks that printed as ink dots.
4. Roofs lifted toward paper (in-engine roof/pavement 0.54-0.60 -> 0.61-0.67; target 0.88).
5. Kerb is a cream stone top with ink edges (was a dark hatched band, "pipe with bolts"); ticks thin grey.
6. Pavement laid as 2 m slabs (was 1 m graph paper); the 2 x 1 running bond probed and rejected (brick wall).
7. Road arrow + stop line paint cleaned.
8. Near-black car glass on the 9 intact vehicles + traffic atlases (damage states keep pale crazed glass).
- Reverted / not shipped: grey-slab lightening (no visible change through the print pass), running bond.
- Codex images this iteration: **0** (all eight items were value / layout fixes on existing art, measured against
  the target). Night total stays 19 images, 137 cells, 3 rejected.
- Tools added (masters, outside git): lane_bold, paving_calm, marking_wear, roof_lift, kerb_cream, kerb_ticks,
  paving_bond, paint_decal_clean, glass_ink; build_corner gained KERB_CREAM + an output arg.

## REQUESTS (iteration 3 additions; the iteration 1 + 2 lists still stand)
10. generator owner: 2-3 sidewalk variants + a pick (as the road `_b/_c`) - one 8 m pavement tile repeats on wide
    plazas (grey slabs, stains, the 3 cracks) and no art-side tweak can hide a single-tile repeat.
11. visual-engine: buildings cast no shadow on the pavement; the target's hatched building shadow band (south/east)
    is the largest remaining difference in the frame after tonight's ground work.
12. visual-engine: the paper / asphalt temperature - the target is a warm sepia print, ours prints the asphalt
    lilac-grey (shader tint, not the texture: the tile is 88,82,82).
13. F-08 / ground owner: a re-run of build_ground.py would undo iteration 3 (markings, kerb, slabs, wear) - the
    masters tools above are the recipe; better to fold them into build_ground.py.
- 23:55 REVERTED probe: the flat-roof ground tiles (roof_tone, roof_edge_tone) lifted toward the roof paper
  (`tools/roof_lift.py` gained a paper arg). The print pass's tone steps leave no middle: s 0.3 prints the same grey
  (in-engine 179.6 vs 176.6), s 0.6 jumps to pavement paper (214.8 vs pavement 218.2) and the flat roofs read as
  plazas next to the street (`work/rt3_ab.png`: original | 0.3 | 0.6). The grey flat roof stays: it separates
  building from pavement. A middle value needs a shader step (visual-engine) or a hatch-based roof redraw.
- 23:50 HUD re-shot over the iteration-3 ground (`after_hud3/city-*-hud40.png`): frames still plated and readable.
- 23:52 MILESTONE soft asphalt patches. With the paint clean, the closed patch outlines (0.5-2 m, 1-2 per road tile)
  repeated every 8 m and printed as empty ink boxes (`after_hud3/city-0-32ppm.png`). `tools/patch_soft.py`: ink px
  bordering a CLOSED interior (the dashes count as walls, so the trench in tile b is found too) lerped 50 % toward
  the asphalt base; open cracks keep their ink (the grime stays). 5 road tiles (road_straight_v_tone_c has no closed
  patch). Before/after `after_hud3|after_pt/city-0-{32,48}ppm.png`: the patches fade to faint stains; the road reads
  like the target's clean asphalt with cracks. Kept. Commit cee3247.
- 23:53 checked at 64 px/m (`now3/table-64ppm.png`, `props-64ppm.png`): bold markings, dark glass and the 2 m slabs
  hold up close; nothing crude.
- 23:55 MILESTONE grey slabs out. Inside 2 m slabs the grey 1 m "replaced slab" squares read as missing-tile boxes
  and were the most visible 8 m repeat marker on the plaza (city-2 left half: a regular grid of grey boxes).
  `tools/slab_grey_out.py`: each grey cell replaced by its partner cell in the same 2 m slab (same rows, so the kept
  joints line up), its old border on the partner's side cleaned, kept joints redrawn. sidewalk (2), curb_c (1).
  Before/after `after_pt|after_go/city-2-32ppm.png`, `city-0-48ppm`. Kept. Commit e83f9ed. README recipe updated
  (`features/city/art/README.md`: the 9 ground passes in order, so a build_ground re-bake does not silently undo them).
- FRICTION: I edited the README while run.mjs ran -> unit-tests marked FAIL ("tree changed during run"), 142/142
  passed. Re-ran on a clean tree: green. Never touch the tree while the gates run (as with renders, iteration 1).
- 23:57 GATES at 2069509 (HEAD, every iteration-3 commit): `run.mjs --no-bench` rc 0 - lint 13/13, unit 142/142,
  scenarios 8/8, parity bit-exact (mutation caught), selftest 0 placeholders. bench not re-run (textures only).
- Final iteration-3 sheet: `masters:night/d4-production/night_iter3_summary.png` (end of iteration 2 | end of
  iteration 3 on 4 city frames, target below). Ladder `ladder.png` has a row per item (24 300 px tall now).
- Codex this iteration: 0 images (all items were measured value/layout fixes). Night: 19 images, 137 cells,
  3 rejected. Iteration-3 probes reverted: grey-slab lightening, running bond, flat-roof lift.
- 12. (numbers) visual-engine: shader WASH = (0.40, 0.37, 0.41) prints the asphalt 79,73,81 (lilac); the target's
  asphalt is 88,76,77 and its paper 197,173,152 (warm sepia), ours 223,214,197. A warmer WASH/CREAM is a shader call.

NEXT:
- Owner review first: iteration 3 changed the whole ground read (markings, kerb, 2 m slabs, calm paving, soft
  patches, no grey slabs) + roofs lifted + dark glass. Every change is its own commit, revert per commit if one is
  not wanted (571460b, 724e5d9, 08231f6, c133a77, 84a1a2f, b787142, e01bbb1, 3fb53b0, 21f6ec9, cee3247, e83f9ed).
- Owner decisions still open: cop uniform vermilion vs ink + accent (iteration 2), blood ink vs vermilion (iteration 1).
- If the generator gets sidewalk variants (REQUEST 10): rot90 / rot180 of sidewalk_tone keep the 2 m joint grid
  (768 = 4 x 192) and are a free first pair of variants.
- If visual-engine adds building shadows / warmer wash: re-shoot city_frame and re-judge the roof lift (it was tuned
  against the current tone steps).
- Fold the masters ground tools into build_ground.py (REQUEST 13) before anyone re-bakes the ground.
- 23:58 REVERTED probe: props contrast S-curve (`tools/props_contrast.py`, gain 1.6 on unsaturated px, vermilion
  kept). On the road the props pop more, but on the PAVEMENT (where props live) the lightened kiosk, vending machine,
  crates and newsstand melt into the cream paving; the mid-grey fills are what separate them from it
  (`work/pc_ab32.png`, `probe_pc/`). Worse where it matters: not shipped.
- 00:00 MILESTONE flat roofs cream with seams (follow-up to the 23:55 revert). `tools/flatroof_seams.py`: the roof
  membrane (lum >= 0.58) 60 % toward the roof paper, the hatched seam bands + ink (lum < 0.50) 35 % toward ink,
  roof_edge parapet rows 0-72 kept. First thresholds (0.60 / 0.64) cut through the membrane band (0.6-0.7) and
  speckled it; 0.50 / 0.58 kept. In-engine (`after_go|probe_fr/city-1-{32,48}ppm.png`, `work/fr_ab.png`): cream
  roofs with dark structure, distinct from the 2 m pavement grid (the plain lift read as plaza). **Judgment call,
  owner review**: revert = 032f96c. README recipe updated.
- 00:01 GATES at 032f96c (HEAD): `run.mjs --no-bench` rc 0 - lint 13/13, unit 142/142, scenarios 8/8, parity
  bit-exact (mutation caught), selftest 0 placeholders.
- Owner review sheet for iteration 3 only: `masters:night/d4-production/ladder_iter3.png` (23 rows: before | after |
  target per item, in commit order; add 032f96c to the NEXT revert list above).
- Session end for iteration 3 (stop time 00:41). Branch n-d4, tree clean after this entry; nothing pushed or merged.
- 00:02 `night_iter3_summary.png` rebuilt from the final frames (`probe_fr/` = HEAD 032f96c): end of iteration 2
  vs end of iteration 3 on 4 city frames + target. Checked city-2 at 48 px/m: the pavement is the 2 m grid
  (96 screen px), the 1 m look was a misread. Lane masters dir 852 MB (evidence + backups kept for revert).
- 00:03 no-op probe: patch_soft with the tile border as a wall (`edge` arg) to catch outlines running off the tile;
  it finds no new outline px. The strong outline left in city-2 at 48 px/m is road_straight_v_tone_c's hatched
  crack edge (part of the grime), not a patch. Nothing installed.

## 2026-11-03 00:04 iteration 4, BUILD (raise the weakest item; stop 01:33)
- Read: journal, log, iteration-3 sheet vs target. Source roofs checked 1:1 beside the target's roofs
  (`masters:work/i4_roof_vs.png`): the art itself matches the target style; their grey in-engine is the print pass
  (cast-shadow hatch prints as solid grey blocks), not a texture fix. FX atlas re-checked: splat cells are alpha 0
  outside the ink (the cream seen in a flat preview is transparent RGB), fine.
- 00:08 REVERTED probe: asphalt patches cleared further (`tools/patch_clear.py` from `work/patch_orig`: outline
  ring 85 % + interior hatch 70 % to the asphalt). In-engine (`probe_fr|probe_pt4/city-0-48ppm.png`,
  `work/pt4_zoom.png`) the boxes were already faint at HEAD; the change is barely visible. Not shipped.
- 00:11 MILESTONE D5 ink grime on the cars (the brief: push toward D5 where it survives, up close). The intact cars
  read factory-clean at 48-64 px/m. `tools/veh_grime.py`: on the light paint (lum > 0.55, unsaturated, inside the
  stroke) an ink stipple gathered in low-frequency dirt patches, weighted to the body edge (sills, bumpers), a 10 %
  dirt wash near the edge, 3 thin scratches; deterministic per file. v1 (6 scratches, 6 % interior stipple) read as
  hair and dust at 64; v2 (3 scratches, 3 %) kept. In-engine `before_gr|after_gr|after_gr2/table-{32,48,64}ppm.png`
  (`work/gr2_ab_64z.png`), city `probe_fr|after_gr_city/` (`work/gr_city32.png`, `gr_city48.png`): invisible at 32,
  light edge wear at 48, lived-in at 64; silhouettes and the cruiser's vermilion bar untouched. Damage states and
  wrecks untouched (they already carry the d4n_dmg marks). Traffic atlases rebuilt. 11 provenance lines
  (prov_rev.py now stamps today's date). Commit 54bf23f. Revert = that commit if the owner wants clean cars.
- 00:17 MILESTONE soul portraits (HUD soul cards were empty frames). Codex `d4n_souls` (image 20 of the night;
  template = 4 portrait guides, style ref = the D5 concept's teal soul ghosts), 4 busts, **0 rejected** (front-on is
  right for a HUD portrait; the straight-down rule is for world art). Gearbox (driver cap, steering wheel, worried),
  Sentry (dome, one lens eye), Hauler (huge shoulders, sleepy smile), Mop (drone cluster, brush). `tools/slice_souls.py`:
  key by RGB distance + un-mix, fit 220 x 350 inside the inner frame line; first cut left the smoke LILAC (un-mix
  drift) and overlapped the frame -> recoloured to a pure deep-teal / teal / cream ramp and shrunk. `_idle` = ink
  ramp (teal only on the active card, HUD README). Dev HudOverlay draws Gearbox active + Sentry idle. In-engine
  `before_soul|after_soul/city-*-hud{40,50}.png` (`work/soul_ab.png`): reads at UI 0.4. prov.py: d4n_souls master +
  8 lines (keeps logged dates now). Commit 5f1fc28.
  Note for the HUD owner: portraits are 220 x 350 at 2x, offset ((card_w - 220) / 2, 40) card px.
- 00:19 GATES at 0fe05ce (car grime + souls): `run.mjs --no-bench` rc 0 - lint 13/13, unit 142/142, scenarios 8/8,
  parity bit-exact (mutation caught at step 629), selftest 65 art textures, 0 placeholders.
- 00:23 MILESTONE FX atlas seen in the real FX system for the first time. visual-engine (`n-visual`) wired
  `data/tables/fx.json` to read `features/fx/art/fx_atlas.png`, but their branch does not ship the atlas, so it drew
  analytic placeholders. Scratch worktree `gtai-wt/scratch-d4fx` = n-visual detached (NO merge, no branch moved)
  + my atlas + my baked chunks / native bin copied in; their `dev/selftest/fx_showcase.tscn` (seed 91, fixed fps):
  `fx_engine_before|fx_engine_after/fx-{32,48,64}ppm-1-fx.png` (`work/fxe_ab_48.png`, `fxe_64_stack.png`). The
  layout matches their atlas blocks: explosion (ink comic burst + vermilion core), debris, impact, smoke, crackle,
  muzzle all read. Weakest: the ink splat (a ground FX, printed by look_d4) showed as a dark smear - its 5 px square
  rim is 0.45 screen px at 32 px/m (1.8 m per 256 px cell). `build_fx.py rim()`: round distance-field rim, specks
  < 40 px and sub-0.5 alpha fringes dropped (they left ghost rings); r 6 probed (rim eaten by the edge ink, grey),
  **r 11 kept**: cream-rimmed ink stickers at 48/64, a visible mottled splat at 32 (`work/splat_engine_ab2.png`:
  5 px | r 6 | r 11). Commit ac8fda9.
  For the Director: n-visual + n-d4 merged = the FX draw this atlas; nothing to change on their side.
- 00:25 MILESTONE bold electroshock. In the FX system at 32 px/m the crackle (1.6 m per cell) was a pale ghost:
  ~12 px bolts = 2 screen px. `build_fx.py bolden()`: cream bolt mask grown 4 px + a round 4.5 px ink outline.
  `fx_engine_rim11|fx_engine_shock/fx-{32,48,64}ppm-1-fx.png` (`work/shock_engine_ab.png`): crisp cream bolts at
  32/48. At 64 the bolts speckle - that is the FX fade dither (crackle `fade_from 0` = it dithers from its first
  tick), not the art. Commit 773d5cb.
- 00:29 Merge dry-run for the Director: in the detached scratch worktree at n-visual 15fd526,
  `git merge --no-commit n-d4` -> the ONLY conflict is `JOURNAL.md` (add/add, both lanes keep one at the root).
  Rendered the merged tree (my art + their renderer): `masters:night/d4-production/merged_fx/fx-*` (their
  fx_showcase: my ground, my FX atlas, their lights) and `merged_city/city-*-hud40.png` (my city_frame + HUD):
  cohesive, placeholders=0 in the texture table. The most visible placeholder left in the merged frame is still
  MOVING TRAFFIC (grey boxes; request 1 - `traffic_atlas.png` is ready). Merge aborted, scratch tree clean.
## REQUESTS (iteration 4)
14. visual-engine: crackle `fade_from` 0 -> ~0.5 (it dithers from its first tick, the bold bolts speckle at 64);
    debris 1.2 m / impact 0.9 m are specks at 32 px/m - 1.6 / 1.3 m would read (the art is bold enough at that size).
15. Director: the n-d4 / n-visual merge conflicts only in JOURNAL.md (keep both, e.g. move one to docs/journals/).
- 00:29 MILESTONE traffic light lamps in ink and paper. visual-engine's new accent audit (`n-visual`
  `data/tables/accent_debt.json`) carries ONE debt row, owned by this lane: `traffic_light.png` lit lamps painted
  vermilion (216 px at 32 px/m in the selftest junction; vermilion is for threats). `tools/lamp_paper.py`: the lamp
  nearest the pole = lit paper disc, the other two unlit ink discs with a cream glint, edge px blended by their
  vermilion share; 0 vermilion px left. Props board `before_lamp|after_lamp/props-{32,48,64}ppm.png`
  (`work/lamp_ab48.png`). Commit 0fa27c3. **For the Director:** after merging n-d4 + n-visual, delete the
  `traffic_light_lamps` row (the audit treats a row as debt to delete when fixed). Scan of all city art: the
  remaining accents are on doctrine (explosive barrels, police barrier / barricade / cone, cruiser light bar,
  hijack teal).
- 00:31 MILESTONE blood decals read on the asphalt. Decals board at 32 px/m: blood_s/m/l (dynamic) printed as faint
  grey smudges on the charcoal (hatched ink interior -> mid grey; no rim). `tools/decal_rim.py`: ink shrunk inward
  by rim + 2 px (the first cut clipped the rim at the texture border), specks dropped, round cream rim (4 / 6 / 6 px
  at 80 px/m). Rim alone (probe `after_blood`) read as lace around a grey blot; **solid flat ink + rim** kept
  (`after_blood2`), same read as the FX splat burst and the characters' sticker rim. `work/blood_ab32.png`
  (before | rim | rim + solid). Commit 6e36609. Scorch / oil stay rimless on purpose (burn and oil are dark on
  dark by nature).
- 00:36 MILESTONE lamp post (n-d5 journal 23:18: "reads as a spoon lying on the pavement at 48-64 px/m"). The old
  sprite had an in-line oval head = the spoon bowl; the target draws a dark round base, a thin arm, a crook and a
  ROUND head. `tools/lamp_redraw.py` (procedural, no AI pixels, same 256 x 40 footprint): ink base disc with a wash
  glint, cream arm with ink outline, a crook, a paper head (lit lamp = paper disc) with a 5 px ink ring - a first
  12 px head with a 3 px ring nearly vanished on the cream kerb at 32 (`after_lampp`), r 14 / ring 5 kept
  (`after_lampp2`). City `before_lampp|after_lampp2/city-*` (`work/lampp_ab2.png`, `lampp_ab32.png` 4x): reads as a
  street lamp at 32 and 48. Commit 3c65886. City README doctrine line updated (signal lamps no longer vermilion).
- 00:38 n-d5 request (journal item 3: "d**1.8 mid-tone lift on the D4 roof set, OSHA paper 26 -> 38 %") is covered
  by iteration 3's roof lift c133a77 (they measured the base roofs on their branch). Texture paper share
  (lum > 0.75), base | mine (c133a77) | base with d**1.8: OSHA 0.49 | 0.62 | 0.60, tall 0.44 | 0.59 | 0.56,
  HQ 0.46 | 0.60 | 0.57. d**1.8 lifts the mean more (0.72 vs 0.66) only because it also greys the ink, which the
  D4 read needs. No change.
- 00:38 GATES at e3f3b34 (every iteration-4 art commit): `run.mjs --no-bench` rc 0 - lint 13/13, unit 142/142,
  scenarios 8/8, parity bit-exact (mutation caught at step 629), selftest 65 art textures, 0 placeholders.
  bench not re-run (textures only, no new texture ids; the 8 soul PNGs are HUD-only).

## 00:43 SUMMARY iteration 4 (raise the weakest items; every change before/after in-engine)
Sheets: `masters:night/d4-production/night_iter4_summary.png` (8 items, before | after crops) and
`night_iter4_city.png` (end of iteration 3 vs HEAD art on 4 city frames). Ladder rows appended for every item.
1. D5 ink grime on the 9 intact cars + traffic atlases (invisible at 32, lived-in at 64). 54bf23f
2. Soul portraits for the HUD soul cards (Gearbox, Sentry, Hauler, Mop; teal ghosts in the D5 concept style + ink
   idle versions); dev HUD overlay draws them. 5f1fc28
3. FX atlas checked in the REAL visual-engine FX system (scratch worktree, no merge): layout fits their atlas
   blocks, everything reads; the splat got a round 11 px cream sticker rim (ac8fda9) and the electroshock bold
   bolts (773d5cb).
4. Traffic light lamps in ink and paper - clears the visual-engine accent-audit debt row owned by this lane. 0fa27c3
5. Blood decals: flat ink + cream sticker rim (were faint grey smudges on the asphalt). 6e36609
6. Lamp post redrawn in the target's construction (the n-d5 lane's "spoon" note). 3c65886
7. Merge dry-run n-d4 into n-visual: only JOURNAL.md conflicts; merged renders cohesive.
- Reverted / not shipped: asphalt patch clearing (no visible gain), props grime (props too small, noise).
- Answered: n-d5's roof-lift ask is covered by c133a77 (numbers above).
- Codex this iteration: **1 image** (d4n_souls, 4 cells, 0 rejected). Night total: 20 images, 141 cells, 3 rejected.
- Tools added (masters): veh_grime, patch_clear (probe), slice_souls, lamp_paper, decal_rim, lamp_redraw;
  build_fx gained rim() (round) + bolden(); prov.py keeps logged dates + d4n_souls; prov_rev stamps today.

NEXT:
- Owner review: iteration-4 commits each revert alone (54bf23f grime, 5f1fc28 souls, ac8fda9 + 773d5cb FX,
  0fa27c3 lamps, 6e36609 blood, 3c65886 lamp post). Iteration 3's list (above) still stands.
- Director, at merge: JOURNAL.md is the only n-d4 / n-visual conflict; after the merge delete visual-engine's
  `accent_debt.json` row `traffic_light_lamps` (fixed by 0fa27c3) and re-run their accent audit.
- visual-engine: wire `traffic_atlas.png` for moving traffic (the most visible placeholder left in the merged
  frame); crackle fade_from; debris / impact sizes (REQUEST 14).
- HUD owner: soul portraits 220 x 350 at 2x, offset ((card_w - 220) / 2, 40) card px; teal only on the active card.
- Owner decisions still open: cop uniform (n-visual has a cream-cop torso option now), blood ink vs vermilion
  (blood is ink with a cream rim now, consistent with the FX splat).
- If more time: Hauler's portrait is the smallest (wide body fit by width); the idle ink portraits are pale.
- 00:41 MILESTONE soul portraits refined (NEXT item from the summary). `slice_souls.py`: fit by height, a wide body
  may overflow the 220 px portrait area by up to 40 px with a 12 px alpha fade at the cut (Hauler was the smallest
  portrait: scale 0.555 -> 0.681); idle ink ramp (lum - 0.36) / 0.40 (was 0.30 / 0.50: read pale). Board
  `work/souls_peek3.png` (v1 vs v2), `souls_peek4.png` (final); in-engine `after_soul|after_soul2/city-*-hud{40,50}`
  (`work/soul2_ab.png`). 8 provenance lines. Commit 480ef6b.
- 00:42 props board re-read at 64 px/m (`after_lampp/props-64ppm.png`): no other prop misreads (street sign is a
  small pole + edge-on plate, acceptable straight down).
- 00:42 GATES at ca10764 (incl. the refined souls): `run.mjs --no-bench` rc 0 - lint 13/13, unit 142/142,
  scenarios 8/8, parity bit-exact, selftest 0 placeholders.
- 00:43 MILESTONE damage-state grime (a continuity gap my own 54bf23f opened: an intact car was grimy, its d1/d2
  states clean - a damaged car read cleaner). `veh_grime.py` now seeds by the base car name (sedan_d1 -> sedan;
  one scale per vehicle across states, so the dirt registers: `work/grime_dmg_peek.png`); applied to the 18 SHIPPED
  damage states (work/vehicles holds pre-marks copies - caught by a cmp before use). The marks stay on top (grime
  only touches light paint). Extras board `before_grd|after_grd/extras-{32,48,64}ppm.png` (`work/grd_ab_64.png`).
  18 provenance lines. Commit 1a78f7b.
- 00:46 hijack overlays re-checked over the grimed cars (`masters:now4_hijack/hijack-{32,48,64}ppm.png`): teal glass +
  dashed rim still register.
- 00:50 GATES at 37d64ff (HEAD, every iteration-4 commit): `run.mjs --no-bench` rc 0 - lint 13/13, unit 142/142,
  scenarios 8/8, parity bit-exact (mutation caught at step 629), selftest 65 art textures, 0 placeholders.
  bench not re-run (textures only, no new texture ids).
- Sheets final: `night_iter4_summary.png` (10 items), `night_iter4_city.png`; ladder 33 418 px tall.
- Codex night total unchanged since the summary: 20 images, 141 cells, 3 rejected (iteration 4: 1 image, 0 rejected).

NEXT (session end, iteration 4; supersedes the NEXT list in the 00:43 summary where they differ):
- Owner review: iteration-4 commits each revert alone: 54bf23f + 1a78f7b (car grime, intact + damage states; revert
  both together), 5f1fc28 + 480ef6b (soul portraits), ac8fda9 + 773d5cb (FX splat rim, bold crackle), 0fa27c3
  (signal lamps), 6e36609 (blood decals), 3c65886 (lamp post).
- Director at merge: JOURNAL.md is the only n-d4 / n-visual conflict; then delete accent_debt row traffic_light_lamps.
- Still blocked on code owners: traffic atlas wiring (visual-engine), generic roof pick + sidewalk variants
  (generator), RigVariant slots for the 5 new ped parts (characters), soul portraits in a real HUD (HUD owner).
- Open owner calls: cop uniform, blood ink (now with a cream rim) vs vermilion.
- Branch n-d4, tree clean after this entry; nothing pushed or merged; scratch worktree removed.
- 00:47 MILESTONE FX debris + sparks. Per-effect crops of the 48 px/m FX frame (`work/fx_small48.png`): spark burst =
  thin pale strokes (near invisible), debris = pale grey chunks; the rest read. `build_fx.py`: sparks
  bolden(grow 3, ink 3.5), debris outline() (round 3.5 px ink ring). Fresh scratch worktree at n-visual 76b0b31
  (detached, no merge; removed after): shipped atlas vs new in the same build,
  `fx_engine_sd_before|fx_engine_sd_after/fx-{32,48,64}ppm-1-fx.png`, crops `work/sd_ab.png`: debris clearly crisper,
  sparks a small gain (drawn tiny + fade-dithered by the FX table: REQUEST 14 applies). Commit f7ad91a.
- 00:52 GATES at eb0c2c0 (HEAD incl. f7ad91a): `run.mjs --no-bench` rc 0 - lint 13/13, unit 142/142, scenarios 8/8,
  parity bit-exact, selftest 0 placeholders. Add f7ad91a (FX debris / sparks) to the NEXT revert list above.
  Scratch worktree removed again; `git worktree list` shows only the lane worktrees. Tree clean after this entry.

## 2026-11-03 00:50 iteration 6, BUILD (raise the weakest item; stop 02:20)
- Read: journal, log, iteration-4 city sheet beside the target. n-visual still draws moving traffic as grey boxes
  (request 1 open). Biggest remaining gap in MY scope: the asphalt covers about half of every frame and prints as one
  flat wash (frame std 1.1 vs the target's 14). The shipped asphalt is one value band (lum 83-87), so look_d4 (asphalt
  density about 0.75 = the dark step) cannot show any grain.
- 00:57 MILESTONE asphalt aggregate. `tools/asphalt_grain.py` (procedural, asphalt pixels only, 2 px off markings,
  cracks and kerb; seeded per file). Probes in-engine, city_frame 32/48 (`work/ag1_ab.png`, `ag2_zoom.png`,
  `ag3_zoom.png`):
  v1 dark/pale +/-20: invisible (stays inside the dark step).
  v2 +/-45: dark specks cross line_ink + Sobel -> black pixel pepper (digital noise); rejected.
  v3 pale-only +40, 7 %: grey aggregate stipple, calm; uniform.
  v4 pale +46, 10 %, clumped by a 24 px mottle: worn patches and calmer areas like the target's asphalt. **Kept.**
  Checked in a scratch MERGE of n-visual b8ecb19 + n-d4 (their world-locked paper tooth, `git merge --no-commit`,
  only JOURNAL.md conflicts): `merged_ag0|merged_ag3|merged_ag4/city-*` (`work/ag34_merged.png`): no clash with their
  tooth. In-lane before/after `before_ag|after_ag/city-*` + boards `corner|decals` at 32/48/64
  (`work/ag_corner64.png`): no tile seams (corner and straights grain alike). 11 provenance lines. Commit 20bb95b.
  Ladder rows 3.
- 01:00 MILESTONE pavement de-tiled. sidewalk_tone is the ONLY pavement texture (8 m, 4 x 4 slabs), so its 3 crack
  squiggles + 5 hatch stains lined up in rows every 8 m at 32 px/m (wallpaper tell, city-2). `tools/sw_declutter.py`:
  2 cracks + 3 stains replaced by the same slab-relative pixels of a clean donor slab (joints byte-identical, checked).
  `after_ag|after_sw3/city-*` + `corner-64` (`work/sw_ab.png`). Commit d365cba.
- 01:00 GATES at d365cba: `run.mjs --no-bench` rc 0 - lint 13/13, unit 142/142, scenarios 8/8, parity bit-exact,
  selftest 65 art textures, 0 placeholders.
- 01:03 FINDING: main gained quest 1 (collect-call, 721fbbb) whose view (`boot/collect_call/view/`, DEVIATION GDS-08)
  draws every place and person as flat placeholder boxes with letters. That is the slice's biggest visible
  placeholder set now, and the art is in my scope (the view code is not).
- 01:10 MILESTONE quest 1 places in D4. Codex d4n_q1 (5 cells, **0 rejected**): TUCK-IN crate (robot-and-bolt
  stencil, vermilion bolt = objective), the sabotaged crate, taped cash, catwalk (tiles 4 m), dock gate.
  Procedural (no AI pixels, `tools/build_q1_floors.py`): Dock 9 floor (4 m slabs, bay line), Toner Room basement
  checker, vault-cage chain-link mesh (RGBA). `features/quest/art/collect_call/` + README (footprints = what the
  placeholder view draws). Evidence: quest 1's OWN frame grabber (`dev/frames/collect_call_frames.gd`, seeded) in a
  scratch worktree at main 721fbbb: `before_q1/` (main as is) vs `after_q1f/` (+ my art + a LOCAL view patch,
  `masters:night/d4-production/q1_view_art.patch`, not committed: view code is the quest owner's). Sheets
  `work/q1_ab_sheet.png`, `q1cast_ab_sheet2.png`. Through look_d4 at 32/48/64: new `--page=quest` board
  (`after_q1board3/`). Fixes found by looking: wheel-scuff arcs repeated per 8 m tile (removed), a 0.25 m cage mesh
  read as solid hatch (0.5 m kept), dock floor at density 0.50 sat on look_d4's mid step and printed as cloudy speckle
  (moved to 0.54: flat mid wash), 0.5 m checker busy behind the cast (1 m kept). Commits 153d91d, 6034c96.
- 01:17 MILESTONE quest 1 cast in D4 (from the package's owner-approved design notes). Codex d4n_q1cast: **4 of 6
  rejected** (Brass, Kilohm, Don Fax front views; Mertz's cap and face from the front). Retry d4n_q1cast2 with an
  explicit overhead construction per character + the camera reference: **0 of 6 rejected**. Juno, Brass, Kilohm,
  Don Fax, the dock guard (vermilion vest = threat), Mertz (vermilion gloves). 120 px/m, facing -y.
  FRICTION: at the gameplay footprints the thin robots and the guards read as specks next to the placeholder boxes
  (`after_q1e`); drawn at 1.5x (guard 1.7x) they carry the boxes' visual mass (`after_q1f`). README says so.
  Teal neutralised (doctrine); the package asks for teal robot eyes - **owner call**. Commits 3876da7, 9ce186d.
- Codex this iteration: 3 images (d4n_q1, d4n_q1cast, d4n_q1cast2), 17 cells, 4 rejected. Night: 23 images,
  158 cells, 7 rejected.
## REQUESTS (iteration 6)
16. quest 1 owner (via the Director): apply `masters:night/d4-production/q1_view_art.patch` (stage_view.gd +
    cast_view.gd, about +60 / -35 lines, compiles warnings-as-errors) or an equivalent once n-d4 is merged; then drop
    the placeholder labels that the art now carries (TUCK-IN, the cash box) per the GDS-08 deviation's re-check.
17. quest 1 owner: the quest view has no look_d4 pass (raw art at its own zoom); the D4 read is the board's.
- 01:21 GATES at 11928d4: `run.mjs --no-bench` rc 0 - lint 13/13, unit 142/142, scenarios 8/8, parity bit-exact,
  selftest 65 art textures, 0 placeholders.
- 01:23 MILESTONE fire FX seen from above. Quest 1's `fx_view._fire()` drew side-view flame tongues rising up the
  screen (a camera break in a top-down game). Codex d4n_fire (7 cells, **0 rejected**): 4-frame flicker loop (cream
  core, vermilion tongues licking outward, ink rim), 2 ember scatters, a wide crate/car fire. `features/fx/art/
  fx_fire.png` 4 x 2 cells, ONE scale, centroid-centred (the loop registers), README section. Quest grabber
  `after_q1f|after_q1h/06-crates-burning` (`work/q1fire_ab.png`), look_d4 board `after_q1board4/`. Commits 1ac7ff0,
  b57a535.
- 01:26 quest 1 HUD takes the existing D4 HUD frames (no new art): cash_frame, wanted pips as the heat pips, memo_frame
  as a 9-slice for the beat panel and the subtitles. Fixed by looking: the weapon word sat on the torn edge, the
  speaker name under the tape, the third subtitle line on the bottom edge (box 200 -> 236 px). HUD README. f89a5f4.
- 01:29 MILESTONE knocked-out guard + Mertz (Codex d4n_q1down, 2 cells, 0 rejected; the fallen hats are drawn a
  little oblique - accepted, noted). First in-view try (`after_q1j`): the bodies DOMINATED the fight and their
  vermilion vests broke the doctrine (a knocked-out guard is no threat). Fixed: vermilion re-inked to the mid wash
  (`build_q1cast.py quiet()`), drawn 1x at alpha 0.8 (`after_q1k`, `work/q1down_ab2.png`): the live threat reads
  first again. Commit dc9a895.
- 01:31 `q1_view_art.patch` final: stage_view + cast_view + fx_view + hud_view (+124 / -77), gdformat + gdlint clean,
  compiles warnings-as-errors, quest 1's frame grabber renders all 9 beats (`after_q1k/`, final before/after sheet
  `work/q1_final_ab.png`). Left as placeholders on purpose: Rivet ("R" box: the D4 Rivet rig belongs to characters /
  n-visual F-14), the patrol cops ("C": the cop rig), the arc ball and whisper rings (FX code).
- Codex this iteration so far: 5 images (q1, q1cast, q1cast2, fire, q1down), 26 cells, 4 rejected.
  Night: 25 images, 167 cells, 7 rejected.
- 01:33 MILESTONE payphone, vending machine, mailbox redrawn. Props contact sheet (`work/props_sheet.png`): the F-08
  payphone (quest 1's core objective) and vending machine were featureless bevelled boxes. Codex d4n_props2 (3 cells,
  **0 rejected**, anchored on the approved newsstand / dumpster / trash can): one bold top-down glyph each (handset +
  coiled cord, soda-can disc, envelope), the props' 4 px inner stroke (3 px mailbox), same footprints. Props board
  `before_pr2|after_pr2s/props-{32,48,64}ppm.png`, crops `work/props2_ab.png`; city `after_pr2_city/`; quest
  `after_q1l/`. Commit 58da0b0.
- 01:34 quest HUD: the stretched memo tape crossed the beat title; the memo frame got 18 px more paper on top
  (`work/q1_top_check.png`). Patch re-saved; final quest frames = `after_q1l/`.
- 01:34 FRICTION (mine): edited two README pointers while `run.mjs` ran -> unit-tests FAILED on "tree changed during
  run" (tests themselves 142/142). Same lesson as iteration 3: never touch the tree while the gates run.
- 01:36 GATES at 11cc7a3 (clean re-run): `run.mjs --no-bench` rc 0 - lint 13/13, unit 142/142, scenarios 8/8,
  parity bit-exact, selftest 65 art textures, 0 placeholders. bench not re-run (no new city texture ids; the city
  textures changed are the same count and size).
- Sheet: `masters:night/d4-production/night_iter6_summary.png` (7 items, before | after).
- 01:37 REVERTED (not shipped): the Robo-tazer arc ball drawn with the FX atlas crackle instead of its translucent
  vermilion halo (`after_q1m`, `work/q1ball_ab.png`): the crackle barely showed and the ball lost its vermilion danger
  ring. It read worse, so the original drawing stays.
- 01:37 quest patch drops the placeholder labels the art now carries ("PAYPHONE", "$1,500", "taped under"), as the
  GDS-08 deviation's re-check asks (`work/q1labels_ab.png`). Zone names and "PROJECT TUCK-IN" stay. Final patch +125 /
  -80 over 4 view files, lint clean; final frames `after_q1n/`.
- 01:39 quest patch: Harbor Road (a flat grey band) draws the city's D4 road tile (the band between its edge
  lines, scaled uniformly to the 5 m road), cycling road_straight_tone / _b / _c. A single tile repeated every
  5.3 m showed the same patch and cracks, so the variants cycle. Zone label drawn on top (`work/q1road_ab.png`).
  No new art. Final patch +149 / -81 over 4 view files, gdformat + gdlint clean; final frames `after_q1o/`.
- 01:42 GATES at cc3b37c (HEAD, every iteration-6 commit): `run.mjs --no-bench` rc 0 - lint 13/13, unit 142/142,
  scenarios 8/8, parity bit-exact (mutation caught at step 629), selftest 65 art textures, 0 placeholders. Bench
  not re-run: no new city texture ids, and the 3 redrawn props keep their sizes.
- Scratch cleanup: removed worktree `scratch-d4ag` (my n-visual+n-d4 merge probe, never committed). `scratch-q1`
  (detached at main 721fbbb, holds the uncommitted view patch) is KEPT so the Director / quest owner can look at it.
  Delete it with `git worktree remove --force ../scratch-q1` after the patch is taken. Superseded probe frames
  deleted from masters (ag1-3, q1 a-d/g/h, board 1).

## 01:42 SUMMARY iteration 6 (raise the weakest items; every change before/after in-engine)
Sheet: `masters:night/d4-production/night_iter6_summary.png` (8 rows, before | after). Ladder rows for every item.
1. Asphalt aggregate: pale clumped specks on the 11 road / kerb tiles. The asphalt printed as one flat wash (target
   std 14 vs ours 1.1). Dark specks turned into digital pepper, so pale only. 20bb95b
2. Pavement de-tiled: 1 crack + 2 stains per 8 m tile (was 3 + 5, in rows). d365cba
3. Quest 1 (collect-call, new on main) places in D4: TUCK-IN crates (intact / sabotaged), taped cash, catwalk, dock
   gate, Dock 9 floor, Toner Room floor, vault-cage mesh. 153d91d, 6034c96
4. Quest 1 cast seen straight down (owner design notes): Juno, Brass, Kilohm, Don Fax, dock guard, Mertz (+ knocked-out
   guard and Mertz, vermilion re-inked). 3876da7, 9ce186d, dc9a895
5. Fire FX seen from above (`fx/art/fx_fire.png`): quest 1 drew side-view flames (a camera break). 1ac7ff0, b57a535
6. Payphone, vending machine, mailbox redrawn with one bold top-down glyph each (handset, soda can, envelope). 58da0b0
7. Quest 1 HUD in the existing D4 frames, plus the Harbor Road on the D4 road tiles: both in the view patch only.
- Evidence rig: `dev/showcase/quest_board_run.gd` (`asset_board.gd --page=quest`, look_d4 at 32/48/64).
- Reverted / not shipped: dark asphalt specks (pepper), wheel-scuff arcs on the dock floor (tiling tell), 0.25 m cage
  mesh (solid hatch), arc ball with the atlas crackle (lost its danger ring), downed bodies in vermilion at 1.5x.
- Codex this iteration: **6 images** (q1, q1cast, q1cast2, fire, q1down, props2), 29 cells,
  **4 rejected** (q1cast: 4 front views). Night total: **26 images, 170 cells, 7 rejected**. No usage limit hit.

NEXT (session end, iteration 6):
- Owner review: iteration-6 commits each revert alone: 20bb95b (asphalt), d365cba (pavement), 153d91d + 6034c96 +
  3876da7 + dc9a895 (quest 1 art, all under `features/quest/art/collect_call/`), 1ac7ff0 (fire), 58da0b0 (props).
- Director: relay REQUEST 16 to the quest 1 owner: `masters:night/d4-production/q1_view_art.patch` (4 view files,
  +149 / -81, lint clean, renders all 9 beats) applies on main 721fbbb once n-d4 is merged (it loads n-d4 art).
  Before/after: `before_q1/` vs `after_q1o/`. The scratch worktree `gtai-wt/scratch-q1` holds it applied.
- Owner calls: teal robot eyes in the quest 1 design notes vs the D4 doctrine (ink now); blood ink vs vermilion; cop
  uniform (all still open).
- Still placeholders in quest 1 (not my scope): Rivet "R" box (Rivet rig), patrol cops "C" (cop rig), the arc ball and
  whisper rings (FX code; the arc-ball probe read worse).
- Earlier lists still stand: traffic atlas wiring (visual-engine), generic roof pick (generator), RigVariant slots for
  the new ped parts (characters), accent_debt row traffic_light_lamps to delete after the merge.
- If more time: the D4 Rivet rig in the quest view (characters owner).
- Branch n-d4, tree clean after this entry; nothing pushed or merged.
- 01:42 quest patch: the crate fire's translucent grey smoke discs replaced by the FX atlas smoke puffs (row 2, cells
  0-3, fading as they lift), a clear gain (`work/q1smoke_ab.png`). No new art. Final patch +156 / -82, lint clean, LF only,
  final frames `after_q1p/`. (Supersedes "after_q1o" and "+149 / -81" in the NEXT above.)
- 01:44 `git apply --check masters:night/d4-production/q1_view_art.patch` in a fresh detached worktree at main
  721fbbb: **applies clean** (check worktree removed again). It needs n-d4's art to be merged first.
NEXT (final, supersedes above where they differ): apply `q1_view_art.patch` after the n-d4 merge; final quest frames
`after_q1p/`; everything else as in the iteration-6 NEXT list. Tree clean; nothing pushed or merged.
- 01:45 `evidence/iter6/` (lane cwd, per the night brief): summary sheet, the quest 1 view patch, gate results at
  cc3b37c, index README. The full frame sets stay in masters. Shared-scope note: `evidence/` is a new top-level folder
  (the Director may move it to `docs/` or drop it at merge).
- 01:47 GATES at 6b954ad (HEAD incl. evidence/): run.mjs --no-bench rc 0, all 5 PASS (lint 13/13, unit 142, scenarios 8, parity bit-exact, selftest 0 placeholders). Session end for iteration 6; tree clean after this entry.
