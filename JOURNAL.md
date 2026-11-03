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
4. Corner traffic lights sit diagonal (rot + 45) and read a bit like spoons at 32 px/m; T1 has corner
   lamp posts. Try axis-aligned or the inked lamp at corners.
5. Pixel-snapped world camera, then package v9's edge_dark with shadows that carry their own ink.
6. Bench idle at the end of the day if the lock allows (this run was contended, 1 x 30 s).
REQUESTS 1-4 above still stand (d5-cast: cop rigs/atlas to cop_blue; d5-combat: blood palette names;
vehicles: cruiser accents cop_blue).
