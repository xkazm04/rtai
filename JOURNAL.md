# JOURNAL - lane d5-city (branch d-city), day run 2026-11-03

Iteration 1 (09:04) died on a billing error before any turn; iteration 2 (10:04) is the first real session.

## 2026-11-03 iteration 2 (10:04 - 11:34)

- MILESTONE 10:20 item 1 doctrine: palette.json `blood` #A30509 / `blood_dark` #540005 (world, actors, fx),
  `cop_blue` #3A4766 (luma 0.28 = the charcoal's 0.29; actors, vehicles), `cop_blue_hi` #4F86E0 (badge,
  light bar); vermilion loses use `cop` and layer `vehicles`. Gates `blood_r` 0.30 / `blood_gr` 0.18 /
  `blue_gate` 0.08; PaletteTokens.classify order blood -> verm -> teal -> blue; count_inks().
  look_d4_item keeps blood and cop blue as chroma-gated plates (a nearest snap would turn mid greys navy);
  look_d4 gets a `blood` plate (profile key, 1 in every row). `noir` is now a look_profiles row (D4 under
  NoirLook, never in auto). accent_audit counts all four inks + "vermilion on cop"; accent_debt rows
  cop_vermilion_32/48/64 (owner d5-cast). Evidence `evidence/d5-city/01-doctrine/`: goldens 11/11 + 5/5
  worst 0.00 (bit-identical), audit junction cop 9412/9660/2060 px, block 10580/6964/2744 px.
  Gates: lint 13/13, unit 331/331, scenarios 8/0 (replay final cbeb734ff9b97c41).
- FRICTION: a parse error (Variant into maxi) hung the windowed accent_audit; killed my PIDs. Use
  `--headless --check-only -s <script>` before every windowed run (autoload errors there are expected).

- MILESTONE 10:33 item 2 (D5 earlier than 64 px/m?): ported d5-close's look_d5_print ("package v9")
  into look_d4 as keys (paper_hi, lo_soft, edge_dark, street_edge; d4 values = old print, goldens
  bit-identical) + row `d5c`. Real-city A/B at 32 px/m (focus 2): edge_dark thins pavement joints toward
  T1 but ERASES the hatched cast shadows (their strokes print through edge ink); street_edge drops car
  outlines on asphalt; paper_hi 0 px. Worse in-engine -> NOT adopted, auto unchanged (D5 overlay from
  48 -> 64 as merged). Pixel-snapped camera not built (moot until a v9 print is adopted).
  evidence/d5-city/02-d5c-print/.
- MILESTONE 10:38 item 3 prop shadows: cast_shadows.json by_name = D5HeroPropShadow lengths, parked cars
  0.18 -> 0.4 m. evidence/d5-city/03-prop-shadows/. Goldens re-blessed (mean <= 0.09).
- MILESTONE 10:43 item 3 roof plates: the 7 landmark roofs (ids 14-21 minus helipad) point at
  art/d5/roofs/ (n-d5's plates). Texture ids unchanged: bake --check matches, sim untouched.
  evidence/d5-city/04-d5-roofs/. SHARED-ish file: data/tables/city_textures.json (the city's table).
- MILESTONE 10:48 item 3 parapets: ChunkView draws every building silhouette again in solid ink 0.22 m
  down-right (cast_shadows.json parapet_core_m) on a 6th per-quadrant item at building_shadows z + 1.
  evidence/d5-city/05-parapets/.
- MILESTONE 10:52 doctrine: lights.json siren -> cop_blue_hi; grade_ink blue_gate (night keeps cop blue).
  evidence/d5-city/06-siren/ (light_showcase before/after, same scene).
- MILESTONE 11:03 item 3 zebras: junction box = procedural plain asphalt (id 72), 4 zebra decals (id 73)
  on the approach arms (tools/art/city_marks.py, no AI, so no provenance line). GENERATOR_VERSION 2,
  hashes re-baked. replay_60s cbeb734ff9b97c41 + parity unchanged. evidence/d5-city/07-zebras/.
- FRICTION: city_frame reads the BAKED chunks: a generator "before" frame needs a re-bake with the old
  painter (did it, restored, sha matched). The junction goldens' crowd moved with the zebras although no
  sim input changed: ChunkView.prewarm draws on a wall-clock budget while the World ticks, so more
  commands = capture on another tick. Pre-existing fragility of the look goldens (decisions.md).
- Proof so far: masters day-d5/d5-city/ladder.png (3 foci x before/after 32/48/64 + T1 + H2),
  frames.json (12 frames), 0 camera-break rejects. Bench NOT run this iteration (end-of-day item; lock).
- Gates at 77bac0d: lint 13/13, unit 335/335, scenarios 8/0, parity bit-exact, selftest 0 (debt only),
  bake --check deterministic.

- FRICTION 11:08 flaky unit test: `test_noir_shadows.test_only_shadow_commands_with_a_length_are_swept`
  failed 2 of 6 unit runs at 3bcd9a8 with an engine error `Parameter "t" is null` (no assert failed). It
  builds CityTextures (ResourceLoader.load_threaded_request with sub-threads) from the full table. The
  evidence run at 3bcd9a8 recorded unit FAIL for that reason (lint, scenarios, parity, selftest PASS).
  Main 089400e on a scratch worktree: 3/3 unit runs pass (325). Likely trigger: my art-path swap makes
  CityTextures thread-load the same d5/roofs files other tests load(). Fix (likely, not proven):
  CityTextures.load_threaded_request use_sub_threads false -> 4/4 runs pass, goldens bit-identical,
  prewarm 31 ms. If it recurs, look at ResourceLoader races on shared paths first.

- MILESTONE 11:15 evidence at 000087f (--no-bench): lint, unit 335, scenarios 8, parity, selftest all
  PASS -> evidence/d5-city/evidence-000087f/. Road share at 32 px/m (dark L, 41 px box blur < 0.40;
  evidence/d5-city/road-share.json): T1 0.35, H2 0.41, real city focus 0 street 0.63, 1 roofs 0.46,
  2 street 0.42, 3 junction 0.72 -> the city shows up to 2x T1's asphalt: the next big lever.

NEXT (iteration 3):
1. Dash-free arm variant: the lane dashes run through the zebra gaps (T1 stops them 1-2 m short): a
   procedural `road_arm` tile (dashes cut at the zebra) for the 4 arms, same tool.
2. Biggest remaining gap vs T1 at 32 px/m: far more asphalt than blocks (T1 is block-dominated). Measure
   road share per frame (n-d5 gap list 3 method) and decide with the owner: wider pavements / kerb props
   vs the sim's road width (sim data: a decisions line + re-bless).
3. D5 ground tiles: sidewalk_tone D5 TRIED 11:18 and REVERTED (evidence/d5-city/rejected-d5-sidewalk-32ppm.png):
   only id 13 swaps, so its thin grey 1 m joints patchwork against the kerb tiles' bold 2 m joints; it
   needs D5 kerb/corner tiles (7-10) in the same joint language first (Codex or a joint-redraw tool). Road b; check each in the real city; the D5 road b
   has a dark band under the dashes - likely reject. D5 lamp post (aspect 4.9:1 vs 6.4:1: needs size_m).
4. Roof clutter density toward T1 (work order item 4): count clutter per roof in T1 vs ours; generic roofs
   65-71 first; Codex plates only if needed (~30 images budget, one exec at a time).
5. Pixel-snapped world camera, then retry edge_dark ONLY together with shadows that carry their own ink
   (cast_shadow strokes printed as ink, not via Sobel) - the one way package v9 can reach 32 px/m.
6. End of day: bench with the lock (gtai-day-d5/bench.lock), idle if possible, D5 cost per pass.

## REQUESTS
- REQUEST 1 -> d5-cast: cop rig parts + cop crowd-atlas looks (patrol 29.3k, riot 24.7k vermilion texels)
  go cop_blue (#3A4766) / cop_blue_hi (#4F86E0) per palette.json; the item print already keeps both inks.
  Your `features/characters/print_part.gdshader` needs the same gates (look_d4_item.gdshader lines 55-59:
  blood r >= 0.30 and max(g,b) < 0.18 r; blue b - max(r,g) >= 0.08) or blue parts print as ink. When they
  land, delete accent_debt rows cop_vermilion_* (the selftest reports them as paid).
- REQUEST 2 -> d5-combat: blood in the world (ground_decals) now keeps its red under look_d4 (`blood`
  plate); paint pools/splats in palette `blood` / `blood_dark` (r >= 0.30, max(g,b) < 0.18 r).
- REQUEST 4 -> d5-cast / d5-combat: blood_dark (#540005) classifies as blood (r >= 0.30); use the
  palette names `blood`, `blood_dark`, `cop_blue`, `cop_blue_hi` (palette.json is live at e9b9323).
- REQUEST 3 -> vehicles (owner of art/vehicles/police*): cruiser vermilion is now an offender on `vehicles`;
  repaint body accents cop_blue, light bar cop_blue_hi.

## NEXT (stop 11:20, iteration 2 end)
Branch d-city at the commit after b6ea66f, tree clean, gates PASS at 000087f (evidence/d5-city/evidence-000087f).
Start iteration 3 with NEXT 1 (dash-free arm tile), then NEXT 2 (road share 2x T1: measure + owner call),
then NEXT 4 (roof clutter density). Masters + frames.json + ladder.png: gtai-masters/day-d5/d5-city/.
Requests 1-4 above are for the Director to relay. No bench run yet (lock protocol at the end of the day).

## 2026-11-03 iteration 3 (11:18 - 12:48)

- MILESTONE ed44ab0 NEXT 1 dash stop: `dash_eraser` decal (id 74, 4 x 0.6 m clean asphalt cut from
  road_straight_tone_c's band, feathered 0.12 m) on each arm's box-side half; dashes end 2.1 m short of
  the zebra (T1). One decal for all 6 road variants instead of 12 cut tiles. GENERATOR_VERSION 3,
  re-baked, bake --check ok; lint 13/13, unit 335/335, scenarios 8/0 (replay cbeb734ff9b97c41); look
  goldens 11/11 within tolerance (max mean 0.49), no re-bless. evidence/d5-city/08-dash-stop/ (no seam
  at 64 px/m). Masters: after-i3/.
- MILESTONE cd1f9dc wall-side clutter (work order item 3): KerbDresser puts one wall prop on 75% of kerb
  tiles (crate_stack, dumpster x2, vending, trash_can x2; barrel_cluster excluded = vermilion), flush to
  the building (0.3 m), clear of the lamp arm and the kerb prop (0.45 m), never facing a plaza block.
  First try (55%, no plaza check) put crates on the open plaza edge: rejected by eye, fixed. GENERATOR 4;
  replay cbeb734ff9b97c41 + parity unchanged; goldens re-blessed both sites (block: new dumpster + bin;
  junction: crowd tick shift only). city_frame focus 4 = street between building blocks.
  evidence/d5-city/09-wall-clutter/. Effect modest at 32 px/m (most foci face plazas).
- MILESTONE df7ebe2 the 48 px/m drive frame: dev/showcase/drive_shot.tscn wraps city_bench (drive) and
  saves 3 frames; no player car exists in this tree (the bench drives the focus). evidence/d5-city/10-drive/.
- MILESTONE proof refresh: masters ladder.png (4 foci x before 32 / after 32/48/64 + T1 + H2; copy
  evidence/d5-city/ladder-iter3.png), frames.json 15 entries. 0 camera-break rejects this iteration.
- OWNER CALL (for the 18:00 sync): road width. Kerb to kerb = 18 m of asphalt (8 m lane tile with 2 lanes
  + 5 m asphalt in each kerb tile, parked cars there) vs T1 ~10 m. At 48 px/m a street frame is almost
  all asphalt. What-if mock from real game pixels with the lane tile cut out:
  evidence/d5-city/11-road-width-mock/ (labelled concept). Narrowing is sim data (cells, traffic lanes,
  PERIOD 8 = 3 street tiles), touches vehicles/slice-play: not done unilaterally.
- BLOCKED 11:37 bench: bench.lock held by d5-combat (fresh). Skipped.
- REJECTED 11:50 D5 lamp post in the city (row 24 -> art/d5/props/lamp_post.png, 3.2 x 0.66 m): richer
  at 64 px/m (bolted base, pipe arm), but at 32 px/m the light grey pipe washes out on the paving where
  the D4 lamp's black pole + ball base read bold (T1's lamps are dark poles). Reverted (table untouched).
  evidence/d5-city/rejected/rejected-d5-lamp-{32,64}ppm.png. Retry only as a darker-inked variant or a
  zoom-tiered swap (D5 art from 48 px/m up).
- MILESTONE 145dae2 T1 street paint: the six road tiles draw `*_open` copies with the two solid edge
  lines painted out (mocked first on a real frame: the street reads as one 2-lane street, not a 4-lane
  highway); once the lines went, the 8 m zebras floated mid-asphalt inside the crossing street, so the
  zebra moved to T1's place: 17 m kerb to kerb (measured 16.75 m between the corner kerbs), 5.15-7.55 m
  from the box (the crossing street's kerb line is at 4.1 m, the corner rounding ends at 5.1 m); two
  dash erasers per arm. GENERATOR 5; replay unchanged; junction goldens re-blessed, block in tolerance.
  Provenance lines for the 6 derived tiles + road_box_plain + dash_eraser (the latter two lacked them).
  evidence/d5-city/12-open-roads/. Ladder refreshed (masters ladder.png, evidence ladder-iter3.png).
- CORRECTION: kerb to kerb is ~16.75-17 m of asphalt (measured), not 18 m as written above.
- MILESTONE 8209a4e plaza dressing: 3 fixed slots + 0.8 m jitter at 60% (was 2 random at 55%), list
  drops barrel_cluster (vermilion) and the lamp (a spoon lying on open paving). GENERATOR 6. Modest gain;
  T1 has no plazas (12% plaza share is a possible owner question). evidence/d5-city/14-plaza/.
- MILESTONE bench 11:50 (lock taken + released, CONTENDED, short 1 x 30 s): p99 5.47 ms, 1% low 127 fps,
  worst swap 10.7 ms; exit 1 on 2 unexplained >50 ms hitches (contended GPU, not re-run idle). D5 cost
  per pass at 64 px/m (16 rigs, GPU median): d4 0.068 -> +part overlays 0.269 -> +look_d5 world 0.447 ->
  +rig shadows 0.611 ms (total +0.54 ms). evidence/d5-city/13-bench/README.md. FRICTION: bench export
  failed until build/export/windows-bench/ existed (fresh worktree).
- FRICTION selftest: the block site's 64 px/m frame showed 4900 px cop vermilion (crowd moved with the
  generator) over the 3000 debt bound -> bound 6000 with the re-measure in the row (10cc4d8). Still d5-cast's.
- MILESTONE evidence at 10cc4d8 (--no-bench): lint, unit 335, scenarios 8, parity, selftest all PASS ->
  evidence/d5-city/evidence-10cc4d8/. Masters: ladder.png + frames.json (15) at after-final/ (8209a4e);
  drive frame drive/drive-final.720.png. 0 camera-break rejects; 1 change rejected by eye (D5 lamp).
- MILESTONE 4867336 the D5 lamp post, inked: an inked derivative of n-d5's lamp (metal through
  luma^1.8 * 170, cream head kept; city_marks.py inked_lamp + provenance) holds the D4 pole's read at
  32 px/m and adds the bolted base + pipe at 64. Goldens in tolerance, night lamp pools unchanged.
  evidence/d5-city/15-lamp/ (D4 / plain D5 / inked D5). Work-order item 3 is now fully in the generator.
- Proof at 4867336: masters ladder.png (copy evidence/d5-city/ladder-iter3.png), frames.json 15 entries.

- MILESTONE de53c3f no lane arrows (T1 has none; they were the biggest white marks after the zebras at
  32 px/m); road_arrow row kept for missions. GENERATOR 7. evidence/d5-city/16-no-arrows/.
- MILESTONE evidence at 750c089 (--no-bench): lint, unit 335, scenarios 8, parity, selftest all PASS ->
  evidence/d5-city/evidence-750c089/. Ladder + frames.json at de53c3f.

## NEXT (iteration 4)
Branch d-city at the commit after 750c089; gates PASS at 750c089 (evidence/d5-city/evidence-750c089).
1. OWNER CALL at 18:00 (put it on the sync page): road width ~17 m kerb to kerb vs T1 ~10 m
   (evidence/d5-city/11-road-width-mock/). If yes: sim data (PERIOD 8, 3 street tiles, kerb tiles with
   5 m asphalt + parking at v 4.45) -> a decisions line, replay/parity re-bless, and the vehicles +
   slice-play lanes must agree. Also ask: keep plazas (12% of blocks, T1 has none)?
2. Kerb/corner tiles (7-10) in the D5 joint language, then retry the D5 sidewalk (13); Codex budget
   untouched (0 of ~30 images used today by this lane).
3. (done de53c3f: lane arrows removed.)
4. Corner traffic lights: axis-aligned TRIED 12:22 and REVERTED (two corners then point their heads
   away from the junction; evidence/d5-city/rejected/rejected-axis-traffic-lights-32ppm.png). Next try:
   the inked D5 lamp at the corners as T1 has (its head over the crossing), traffic lights kept diagonal.
5. Pixel-snapped world camera, then package v9's edge_dark with shadows that carry their own ink.
6. Bench idle at the end of the day if the lock allows (this run was contended, 1 x 30 s).
REQUESTS 1-4 above still stand (d5-cast: cop rigs/atlas to cop_blue; d5-combat: blood palette names;
vehicles: cruiser accents cop_blue).

## 2026-11-03 iteration 4 (12:23 - )

- MILESTONE a4f3d56 pixel-snapped world camera (NEXT 5, work order item 2): CityView.snap_px rounds
  camera.position * zoom to whole screen px. Real-city pan (city_frame --pan=20, focus 1, 48 px/m,
  7.3 m/s): world-locked roof crop 0.02 mean / 0 % flips per frame snapped vs 6.9 / 8.2 % sub-pixel
  (8.6 / 11 % even with the sub-px step compensated: the print thresholds re-quantize). Same under
  --look=d5 (0.02 / 0 % vs 6.6 / 7.8 %). evidence/d5-city/17-snap-cam/ (swim-crop-3x.png shows it).
- MILESTONE bf43a68 D5 earlier than 64 px/m (work order item 2 decided with frames): d5_world overlay
  amount_ppm 32: 0.5, 48: 0.75, 64: 1 (was 0 to 48). Readability gate vs D4 (3 real foci, 32/48):
  edge energy 96-98 % of D4, ink +1 %, paper dE to T1 2.9-9.5 (D4 12.5-14). Full D5 at 32 rejected
  (orange paper, hatch patches on asphalt). Goldens re-blessed both sites; decisions line; README.
  evidence/d5-city/18-d5-earlier/. Package v9 (d5c) stays NOT adopted (erases hatched cast shadows).
- NOTE item 4 roof density: the 7 generic roofs (65-71) + long/warehouse already carry 10-15 clutter
  items per 8.4 m roof (T1: 6-8 larger items per block); masters roofs-i4/sheet-generic.png. No Codex
  plates needed for density; T1's roof items are larger/coarser, not more numerous. 0 Codex images used.
- MILESTONE f85bfc0 corner lamps (NEXT 4): two diagonal junction corners carry the inked D5 lamp
  (head at the kerb corner over the crossing, T1), two keep traffic lights. GENERATOR 8. First try
  read wrong by me (thought the head pointed into the block), flipped, then saw the flip WAS wrong
  (cream disc = head): reverted to 45 deg; rejected-flipped-zoom.png kept. Replay unchanged; goldens
  in tolerance (junction night +0.78: new lamp pools). evidence/d5-city/19-corner-lamps/.
- MILESTONE 9dddff4 H2 road paint: STRIKE + union fist stencil (d5 decals, rows 75-77) on 8% of lane
  tiles, 2.1 m off the centre dashes (1.85 touched them). Chalk robot REJECTED (grey smudge on asphalt,
  invisible on plaza paving). city_frame foci 5 (STRIKE) + 6 (fist under a roof row). GENERATOR 9.
  FRICTION: test_city_chunks pins the texture row count (75 -> 78): first unit run failed on it.
  evidence/d5-city/20-story-paint/ (before = f85bfc0 via a temporary checkout of 2 files + re-bake).
- FINDING item 4 (roof density vs T1), measured on T1's own scale: T1's sedan is 185 x 85 px = 4.9 x
  2.15 m -> T1 is ~38 px/m. T1 buildings span ~15 m, with 5-6 BIG items each (water tank 4.5 m across,
  AC units 2.2 m, skylights 3.4 m): ~0.03 items/m2. Ours: 8.4 m roofs with 10-15 items (tank 2.5 m,
  fans 0.85 m): ~0.17 items/m2, items about half T1's size. So T1 is NOT denser; it is coarser: fewer,
  2x larger items on 2x larger buildings. Toward T1 = 16.4 x 16.4 m (2 x 2 tile) roof plates at 80 px/m
  (1312 px, Codex, layout template with T1-scale items) + a 2 x 2 building in TilePainter._block.
  Scaling the 8.4 m plates 2x would halve texel density (80 -> 40 px/m, breaks the lock): not done.
- MILESTONE 12:57 evidence at 00ebb7c (--no-bench): lint, scenarios 8, parity, selftest PASS (look
  goldens 11/11 worst 0.78, block 5/5; no new off-doctrine accents with D5 at 32/48; world lock 0 %);
  unit 335/335 but the kind FAILED on "tree changed during run" (I wrote evidence/README.md mid-run).
  Re-stamp on a clean tree at the end.
- BLOCKED 12:50-13:00 bench: lock held by vehicles (12:38) then slice-play (12:53). Waiting.
- MILESTONE 13:03-13:10 (iteration 4, uncommitted at session end) T1-scale 2 x 2 roof: one Codex plate
  (layout template at 80 px/m, refs T1 + concept) over the block's 2 x 2 interior on 35% of blocks.
  Committed 2b2fa98 in iteration 5 after gates. evidence/d5-city/22-big-roof/ (1 reject: rotated 180).
- NOTE 13:04 bench overlay cost at 32/48/64 px/m committed 61dd3c4 (evidence/d5-city/21-overlay-cost).

## 2026-11-03 iteration 5 (15:40 - 17:00)

- MILESTONE 2b2fa98 2 x 2 roof gated + committed: lint 13/13, unit 335, bake --check, scenarios 8
  (replay unchanged), selftest PASS (goldens 11/11 worst 0.78, block 5/5, world lock 0 %).
- MILESTONE plate B (GENERATOR 11): Codex roof_2x2_b on layout template B (machine room, skylight strip,
  3.5 m tank, three fans in a row). Raw output pink-grey + a brown door -> masters tools/fit_roof.py
  transfers plate A's tone/tint (luma histogram match + A's luma->RGB LUT). 50/50 pick per block (salt
  62), upright only. city_frame focus 8 = block (9, 6). evidence/d5-city/23-big-roof-b/. Codex used: 2.
- FRICTION: first focus-8 pick was a plaza block (plaza check runs before the big-roof rows).
- MILESTONE 16:02 end-of-day bench (lock taken 15:59:40, released 16:02:41, CONTENDED): city bench PASS
  p99 3.16 ms, 1% low 266 fps, 0 hitches >50 ms (11:50 run failed on 2 unexplained). Overlay cost
  +0.875 ms at 32 (repeats 13:03's +0.9: real, not noise), +0.27 at 48, 64 contaminated (baseline
  6.8x). evidence/d5-city/24-bench-end/.
- FRICTION: scenario city_chase failed once on the 2 ms nav budget (max 26.9 ms) while d5-combat held
  the bench lock; re-run 8/8. Nav grid is unchanged by the 2 x 2 roofs (blocks stamped whole).
- MILESTONE plate C (GENERATOR 12): skylight grid + two tanks + big fan. Hash pick clustered (8/10 B
  in the frame window) -> A-B-C cycle per block row from a per-row random offset (no two neighbours
  share a plate; 27/32/32 over 256 blocks). city_frame focus 9. evidence/d5-city/25-big-roof-c/.
  Codex used today: 3.
- Proof: masters ladder.png = ladder-i5 (6 foci, row 6 = the 2 x 2 block), frames.json 15 entries.
- MILESTONE 16:15 evidence at 9df230f on a clean tree (--no-bench; bench taken 16:00, 24-bench-end):
  lint, unit 335, scenarios 8, parity (1200 steps + mutation caught), selftest PASS (goldens 11/11
  worst 0.78, block 5/5, 81 textures, world lock 0 %). evidence/d5-city/evidence-9df230f/.

## NEXT (after iteration 5, 16:15)
Branch d-city at the commit after 9df230f; all gates PASS there. Proof: masters ladder.png (6 foci) +
frames.json (15), evidence/d5-city/README.md index (add 22-25 if not yet).
1. OWNER CALLS at 18:00: road width ~17 m vs T1 ~10 m (11-road-width-mock); keep plazas (12%)?;
   2 x 2 roof share 35% (raise toward T1, where nearly every building is that coarse?).
2. Overlay cost at 32 px/m is +0.9 ms twice (2-3x 48 px/m): profile idle (crowd under the
   BackBufferCopy?). 64 px/m number of 16:02 is contaminated; re-measure idle.
3. Kerb/corner tiles (7-10) in the D5 joint language, then retry the D5 sidewalk (13).
4. More T1-scale plates (Codex budget: 3 of ~30 used): a 2 x 1 (16.4 x 8.2 m) for the long-building
   slots, so 8.4 m roofs stop dominating; same layout-template + fit_roof.py route.
REQUESTS 1-4 still stand (d5-cast cop_blue rigs/atlas; d5-combat blood names; vehicles cruiser).
- FINDING 26-whatif-share: 2 x 2 share 70% barely changes a street frame (the 2 x 2 is interior; the
  street sees the perimeter ring). Reverted + re-baked (bake --check alone does NOT rewrite chunks).
- MILESTONE b08a010 T1-scale long roof (plate 81, 16.4 x 8.4 m Codex, layout D) in the long two-tile
  slots (22/23/81, upright): city_frame focus 10 = the closest street-level frame to T1 so far.
  GENERATOR 13; block 32 px/m golden re-blessed (far 2.25 %). Codex used today: 4.
  evidence/d5-city/27-long-t1/.
- FRICTION: selftest "no result (needs a display)" = GODOT_BIN not exported in the shell.
- MILESTONE 16:36 evidence at bba930d on a clean tree (--no-bench): lint, unit 335, scenarios 8,
  parity, selftest all PASS -> evidence/d5-city/evidence-bba930d/. Ladder 7 foci (ladder-iter6.png,
  masters ladder.png); frames.json 15 entries. 0 camera-break rejects this session; 1 change
  rejected by eye earlier (rotated 2 x 2 plate); 1 what-if not adopted (70% share).

## NEXT (final, 16:40; supersedes the 16:15 NEXT)
Branch d-city at the commit after bba930d; all gates PASS at bba930d. The bench (PASS, CONTENDED) ran at
61e9222, before plates C and 81: re-bench idle if the owner wants the final number.
1. OWNER CALLS at 18:00: road width ~17 m vs T1 ~10 m (11-road-width-mock; the 48 px/m drive frame is
   mostly asphalt); keep plazas (12%)?; how coarse should rooftops go (2 x 2 at 35% of blocks + plate
   81 in a third of the long slots; focus 10 is the closest street frame to T1).
2. Perimeter coarseness: more T1-scale long plates (2-3 more on layout templates, fit_roof.py with a
   height arg), and consider long slots on the street-facing rows more often than 30%.
3. Overlay at 32 px/m: +0.9 ms twice; the shader-reading hypothesis (content-dependent branches) is in
   24-bench-end/README.md, test idle with hatch 0 / street_hatch 0.
4. Kerb/corner tiles (7-10) in the D5 joint language, then retry the D5 sidewalk (13).
Codex: 4 images used today by this lane (of ~30). REQUESTS 1-4 still stand (d5-cast cop_blue rigs and
atlas; d5-combat blood names; vehicles cruiser accents).
- BLOCKED 16:38 final re-bench: lock held by d5-cast (16:36, < 20 min); skipped. Bench of record = 16:00 at 61e9222.
- MILESTONE/FAIL 16:43 final bench at 1e7caef (lock 16:40:41-16:43:08, CONTENDED): exit 1 on p99 CPU
  8.7 ms (16:00 run at 61e9222 passed at 3.16 ms). Likely contention, NOT shown: idle re-run owed
  before merge (suspect if real: plate texture upload on chunk load). Overlay at 32 px/m now +0.51 ms
  on a 0.64 ms baseline: the earlier +0.9 was partly contention. evidence/d5-city/28-bench-final/.
  Per scenario: riot (stationary, no streaming) CPU p99 2.9 -> 8.7 like drive48 1.5 -> 8.4: points
  at machine load, not the plates (supporting, not proof).
## NEXT addendum (16:45): item 0 before anything else = idle re-bench at the branch head
  (`node tools/bench/run.mjs`, the full 3 x 60 s gate if the machine is quiet). Bench of record:
  16:00 PASS at 61e9222; 16:42 FAIL at 1e7caef (contended).
- BLOCKED 16:46 (iter 46) idle re-bench: lock held by d5-combat (written 16:43, < 20 min); skipped per
  the lock rule. The machine is not idle anyway (another lane is benching), so an idle number cannot be
  taken before the 17:00 freeze. Checked frames.json: 15 entries, every `file`/`before` exists (0 missing).
## NEXT (16:47, final for the day; supersedes earlier NEXTs on item order only)
0. Idle re-bench at the branch head after the run ends (`node tools/bench/run.mjs`, full 3 x 60 s,
   with no other lane on the GPU). Bench of record: 16:00 PASS at 61e9222 (CONTENDED); 16:42 FAIL p99 CPU
   at 1e7caef (CONTENDED; riot regressed as much as drive48, so most likely machine load). The branch
   should not merge on the FAIL alone. It also should not merge as "PASS" until the idle run is done.
1-4 as in the 16:40 NEXT (owner calls on road width / plazas / roof coarseness; more T1 long plates;
   overlay 32 px/m hatch test; kerb/corner tiles then the D5 sidewalk).
- MILESTONE 16:48 (iter 47) lint at the branch head 1a1a5c5: all 13 checks pass over 333 GDScript files.
  Since bba930d (unit 335, scenarios 8, parity, selftest PASS) only evidence/ and JOURNAL.md changed,
  so the code gates of record still apply to HEAD. Bench lock still held by d5-combat (16:43, < 20 min):
  the idle re-bench stays item 0 of the 16:47 NEXT. No code changes this iteration; lane frozen for 17:00.
- BLOCKED 16:54 (iter 48) idle re-bench: lock still held by d5-combat (written 16:43, < 20 min); skipped.
  Six minutes to freeze: no code change started (nothing could be evidenced before 17:00). Tree clean at
  1a017d6. The 16:47 NEXT stands unchanged: item 0 = idle re-bench at the branch head after the run.
- MILESTONE 17:09 (iter 49) re-bench at 7a8c8b1 (code = 1e7caef), lock 17:00:19-17:09:20, CONTENDED:
  ran the full 3-pass gate under a 540 s timeout, which was too short (export + 12 min); pass 3 was
  killed in `drive`, pass 1's JSON overwritten. Pass 2 is complete: worst p99 CPU 4.54 ms (drive),
  drive48 2.78, riot 2.06, 1% low 132 fps, worst swap 14.4 ms: inside every section 20 limit. The
  16:42 FAIL (drive48 8.37 / riot 8.71) on identical code was machine load. evidence/d5-city/29-bench-stabilize/.
- FRICTION 17:09 the full bench gate needs ~14 min wall; give it a >= 900 s timeout next time.
## NEXT (17:10, final; supersedes the 16:47 NEXT on item 0 only)
0. One idle full-gate bench (`node tools/bench/run.mjs`, 3 x 4 x 60 s, ~14 min, timeout >= 900 s) to
   turn "pass 2 inside limits, contended" into a gate verdict. Bench evidence: 24-bench-end (16:00 PASS
   at 61e9222), 28-bench-final (16:42 FAIL, load), 29-bench-stabilize (17:05 pass 2 inside limits).
1-4 unchanged (owner calls on road width / plazas / roof coarseness; more T1 long plates; overlay
   32 px/m hatch test; kerb/corner tiles then the D5 sidewalk).
- BLOCKED 17:11 (iter 50) idle full-gate bench: lock held by `collisions` (written 17:10, < 20 min);
  skipped per the lock rule. It could not finish before the 17:30 stop anyway (~14 min wall plus export).
  Checks done: frames.json has 15 entries and every `file` and `before` exists (0 missing). ladder.png is
  there (16:37). 29-bench-stabilize/ is committed (log + 4 scenario JSONs + README). No orphaned Godot
  from the iter-49 pass-3 kill: no processes with a d-city command line besides this shell. Tree clean,
  no code changed since bba930d, so the code gates of record (lint at 1a017d6; unit 335, scenarios 8,
  parity and selftest at bba930d) still apply to HEAD.
## NEXT (17:12, final for the session; same as the 17:10 NEXT)
0. One idle full-gate bench after the run ends (`node tools/bench/run.mjs`, timeout >= 900 s, no other
   lane on the GPU). Bench evidence: 24-bench-end PASS, 28-bench-final FAIL (load), 29-bench-stabilize
   pass 2 inside the limits (all CONTENDED).
1-4 unchanged (owner calls on road width / plazas / roof coarseness; more T1 long plates; overlay
   32 px/m hatch test; kerb/corner tiles then the D5 sidewalk).
- BLOCKED 17:13 (iter 51) idle full-gate bench: lock still held by `collisions` (17:10, < 20 min); skipped.
  `git diff bba930d HEAD -- project tools native` is empty and the tree is clean, so the code gates of
  record stand for HEAD. I did not re-run unit/scenarios: they would only load the CPU under another
  lane's bench, and they cannot change on identical code. No code change; the 17:12 NEXT stands as is.
- BLOCKED 17:18 (iter 52) idle full-gate bench: lock now held by `slice-play` (written 17:13, < 20 min);
  skipped. It could not finish before the 17:30 stop in any case (~14 min plus export). Still no diff
  under project/, tools/ or native/ since bba930d and the tree is clean, so the code gates of record stand
  for HEAD. I made no code change and did not re-run any gates (identical code; that would only load
  another lane's bench). The 17:12 NEXT stands unchanged: item 0 is one idle full-gate bench after the run.
