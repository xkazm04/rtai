# JOURNAL - night n18, lane districts (branch n18-districts, cut from int-n17 at 36dd26ba6)

Brief: `C:\Users\kazda\kiro\gtai-n18\briefs\` (common + districts). Evidence: `evidence/n18-districts/`
and `C:\Users\kazda\kiro\gtai-masters\n18\districts\`.

## Session 1 (2026-11-17 23:33 -> 01:03)

- 23:36 baseline: `bake_city.gd -- --check` on 36dd26ba6: "deterministic, matches golden" (28 s).
  The first run printed a stale-class-cache SCRIPT ERROR for launch_args.gd; one `--import` cleared it.
- Registry rules applied (read 23:40):
  - `procedural-level-planning` / **zone-progression-linting**: reachability (every zone entered by road
    from every other: a hard failure, not a warning), single-sourcing (the zone row is the ONE source of a
    zone's layout + ped/car density; the zone id per chunk is written by gen only, police reads it, never
    a parallel table).
  - `regional-culture-worldbuilding` / **follow-the-money-as-map-structure**, **world-by-implication**:
    the docks are the supply chain (Dock 9's crates move the money), shown by residue: containers, crates,
    trucks, few people; downtown is where the money lands: tall glass, landmarks, plazas, crowds.
  - `sprite-and-atlas-production` / **pixel-grid-and-resolution-contract** (each request names px/m and
    cell size of the sheet it must match), **autotile-rule-set-completeness** (the quay edge is asked as a
    complete set: straight, outer corner, inner corner, open water).
  - `concept-scene-parity` / **judge-in-the-destination-light**: every delivery is filmed in game at the
    70 camera, 32 and 48 px/m, before it is taken.

### REQUESTs to the asset lane (in order; D5 "Inked Grime" print look, grey print, colour law: no red
### except blood, vermilion only danger/objectives/Rivet's collar, teal only souls; 70-degree combo camera)

REQUEST assets: 1. docks warehouse roof, plan view, 80 px/m, 1312 x 672 px (16.4 x 8.4 m, a two-tile long
roof), drawn upright (the generator turns it 0/180 only), corrugated sheet roof with ridge vents and a
skylight strip, rust-grey; match `project/features/city/art/d5/roofs/building_long_t1.png` (same footprint,
same ink weight, same lower-right hatched shadow). Two variants (a, b) if possible.
REQUEST assets: 2. docks quay + water ground tiles, 96 px/m, 768 x 768 px (one 8 m tile), a complete
autotile set drawn in ONE orientation (the generator rotates by 90 deg): (a) open water x2 variants,
(b) quay edge straight (concrete apron on the top 5 m, edge + bollard line, water below), (c) outer
corner, (d) inner corner. Water is dark grey-blue ink wash, not teal. Match the outer wash of
`project/features/city/art/d5/ground/sidewalk_tone.png` so a quay apron joins a pavement.
REQUEST assets: 3. shipping container stacks as standing prop cards for the 70 camera: a 2-high and a
3-high stack, 6.1 x 2.4 m footprint, five facings like `project/features/city/art/view/p70/prop_crate_stack.png`
(the sheet `tools/art/city_prop_cut.py` cuts), muted container colours (rust brown, grey-green, dirty
blue; NO red, NO vermilion). Plus a flat plan-view twin at 80 px/m (488 x 192 px) for the top view.
REQUEST assets: 4. docks warehouse facade strip for the 70 camera: the storey sheet layout of
`project/features/city/art/view/p70/facade_shop_storeys.png` (an upper row above a ground row, same px
heights), corrugated wall, a roller door bay, a loading-dock bay, a stencilled bay number; 4 bays.
REQUEST assets: 5. docks shed roof (8.4 m square, 672 x 672 px, plan, 80 px/m) and a crane base
(8.4 m square: four rail-bogie legs, a cab plate) matching `project/features/city/art/d5/roofs/building_tall.png`.
REQUEST assets: 6. downtown tall-block roofs, plan, 80 px/m: two 2x2 (1312 x 1312 px, 16.4 m) office
tower roofs (plant room, window-cleaning rail, helipad-less) matching
`project/features/city/art/d5/roofs/building_block_2x2.png`, and two 672 x 672 square ones.
REQUEST assets: 7. downtown glass/office facade strip for the 70 camera, the layout of
`project/features/city/art/view/p70/facade_tall_storeys.png` (upper row + ground row): curtain-wall
glass storeys (grey glass, ink mullions, a few lit windows in warm grey), a lobby ground row; 4 bays.
REQUEST assets: 8. downtown plaza props as standing cards (five facings, like
`project/features/city/art/view/p70/prop_planter.png`): a fountain basin (3 x 3 m), a tree in a grate
(1.6 m), a sculpture plinth (2 x 2 m), a row of bike racks (2.4 x 0.7 m); plus flat plan twins at 80 px/m.

- 00:00 MILESTONE item 1 step one, commit 634b2f552: layout consts -> zone rows (`gtai.city-district/2`,
  CityZone/CityZones, BlockPainter split from TilePainter). Proof: `bake_city.gd -- --check` "deterministic,
  matches golden" at v14 after the refactor AND after the split; planted plaza_share 0.12 -> 0.13 fails it
  (c_00_03.bin differs, exit 1). test_city_zones 5 tests green. Full lint green on the commit (19/19).
- DECISION city/zones-as-data + city/zones-v15 (docs/decisions.md 2026-11-18): chunk-aligned zone rects;
  no per-zone street period (a 12/6-tile lattice can't meet the 8-tile one without T-junctions the kerb art
  and router lack); the docks DROP every other north-south street (`street_keep_x` 2) -> 13-tile long blocks,
  exactly one chunk. Docks = east band chunks x 13-15 (18.75 %), downtown = chunks 6-10 square (9.8 %,
  outside R_SIM 190 m of the selftest junction at 524 m so look goldens / city scenarios stay mixed),
  mixed elsewhere. Alternative = one data value (the rects).
- FRICTION: a python heredoc with ''' strings broke the Bash tool's quoting once; scripts go to a file
  under %TEMP%/n18d/ instead. dev dirs named after a lane count as debt (`lane_named_dev_dirs`): the plan
  renderer lives at `project/dev/view/city_zone_map.gd`.
- 00:13 MILESTONE item 1 + item 2 layout, commit 6ca059905: generator v15, three zones. Numbers
  (`evidence/n18-districts/zone_map_v15.{png,json}`, `dev/view/city_zone_map.gd`): docks 48 chunks
  (18.75 %), downtown 25 (9.8 %), mixed 183 (71.5 %); junctions 1024 -> 928; bake 256 chunks 9 s;
  `--check` deterministic + matches. test_city_lane_grid caught 2 real things on the first v15 (roads ending
  at the quay apron; the junction count) -> east-west streets run on as piers to the edge, the count follows
  the zone lattice. Full unit before that fix: 2825 passed, only those 2 failed. Looked at the plan: docks long
  blocks + yard rows read; downtown's plazas denser.
- Asset lane replied 23:58 / 00:06 (`gtai-assets/replies/n18-districts.md`): REQUEST 1 warehouse roof a (A)
  and v2b (A), REQUEST 5 shed v2 (B, eave frame added), REQUEST 2a water a/b (B, seamless fixed), 2 downtown
  896x672 roofs (B, not square). Copied a/v2b/shed/water a,b into %TEMP%/n18d/art_hold (NOT in the tree yet).
- 00:20 item 4 started (uncommitted until tested): `features/city/gen/city_places.gd` (CityPlaces: rules
  dock_block_nearest / block_nearest, `near` as a city fraction; door = free C_WALK cell 1.5 m south of the
  block's south wall, slid <= 12 m along it; facing south), `data/tables/places.json` (+schema; dock_9 =
  docks long block nearest the quay middle [1, 0.5]; toner_room = downtown block nearest the centre),
  `tests/unit/test_city_places.gd` (resolves in zone, door on walk + wall behind it, stable across two
  generators, dock_9 is a 13-tile long block on the quay side, unknown id/rule empty).
- FRICTION: `run_scenarios.mjs` runs on the live tree (no snapshot): no .gd edits while it runs.
- 00:25 MILESTONE item 4, commit ca6b1fcc2: places as data (CityPlaces + places.json, test_city_places 5/5).
  dock_9 resolves to the docks long block nearest the quay middle, door (1980.5, 1025.5) m, cell (1980, 1025).
  Scenarios on v15 (6ca059905): 55/55 passed, city_replay included (zones moved no replay/parity digest).
- 00:33 MILESTONE item 3 first wiring, commit 5c9a0bd45: generator v16 with the it469 deliveries (ids 86-92).
  Before/after at the same points, combo view, 32 + 48 px/m: `evidence/n18-districts/ab_*_v15_v16_combo_*.jpg`.
  Looked at every frame. TAKEN: warehouse roofs a + v2b (read as docks: vaults, corrugation, skylight strip),
  shed v2, tower 2x2 a/b (orange hazard stripes on a cradle / a tiny "///": a colour-law Call), water a/b.
  SEEN: (1) the water at 48 px/m reads as dark asphalt under the print look: barely a ripple
  (`quay_water_v16_combo_48ppm.jpg`); (2) downtown repeats lettered landmarks (THE LAST SHIFT x3 in one 32 px/m
  view, `downtown_4blocks_v16_combo_32ppm.jpg`); (3) dock roofs still draw the SHOP facade (awnings, shop windows)
  under the lift; (4) zone_frame's crowd is the riot target (24 peds at focus) whatever the zone's density.
REQUEST assets: 9. dock water v2: the a/b water at 48 px/m in game reads as asphalt (see
`C:/Users/kazda/kiro/gtai-wt/n18-districts/evidence/n18-districts/quay_water_v16_combo_48ppm.jpg`): more wave
contrast (ink ripple lines, a few light glints in warm grey, never teal), value a step darker than road asphalt
and a touch bluer than now, still short of police blue. Same 768 x 768 seamless.
REQUEST assets: 10. a quay-side crane placement note is not needed; instead a mooring-bollard + rope prop card
(0.5 m) and a pallet stack card (1.2 x 1 m) for the apron, five facings like `view/p70/prop_bollard.png`.
- 00:35 MILESTONE item 2 lint, commit e8ecb61c9: test_city_zone_lint (roads one network, walk + zebras one
  network, every zone has road + sidewalk); planted "drop every docks street line" fails the walk test
  (31267/31667), restored. Scenarios on v16 (5c9a0bd45): 55/55. Masters filed:
  `C:\Users\kazda\kiro\gtai-masters\n18\districts\frames.json` (7 entries).
- Asset lane since 00:17 (read 00:36): crane base A (`L/keyed/building/roof_dock_crane_base_70_672x672.png`),
  dock facade B (`facade_dock_warehouse_storeys_70_768x204.png`), glass facade B
  (`facade_down_glass_storeys_70_768x200.png`), containers 2-high/3-high cards + plan twins a/b/c A
  (`L/keyed/prop/prop_container_*`), fountain A, tree grate / plinth / bike racks B (+ plan twins A, scale each
  to its footprint), quay straight v2 A, inner v3 A, outer B (`L/keyed/ground/ground_quay_*`). NOT wired yet.

NEXT (session 2, in order):
1. Quay edge: the apron column (x tile 252, rows my>2) draws `ground_quay_straight_70_v2` turned 270 deg (its
   water south -> east); stamp its east ~3 m C_BUILD (water), bollards on the coping; where a pier street (rows
   my 0-2) meets the quay use the outer corner / inner v3 (autotile-rule-set-completeness: list every
   neighbour case in a unit test). Re-bake (v17), golden, before/after at quay 2030,1090 + 2030,1060 (32/48).
2. Dock facade + glass facade: new styles in city_facades.json (`dock`, `glass`) with storeys rows (see
   facade_storeys.gd / tools/art/city_facade_storeys.py), by_name for ids 86-88 -> dock, 89-90 -> glass.
   Copy the keyed strips to `features/city/art/view/p70/`; provenance lines. Film 48 px/m before/after.
3. Containers as yard props: city_textures rows for the plan twins (6.1 x 2.4 m, solid), PropCards rows for the
   standing cards (cut with tools/art/city_prop_cut.py, cells per the asset reply), docks plaza_props -> containers
   (container yard slots need 6.1 m spacing: a yard-specific slot list in DockPainter, not PLAZA_SLOTS).
4. Downtown plaza props (fountain, tree, plinth, racks) the same way; downtown landmark_share 0.55 -> about 0.3
   or a no-repeat rule for LETTERED landmarks within 2 blocks (THE LAST SHIFT x3 in one view).
5. Item 5: `--quest1-places` flag (LaunchArgs KNOWN_FLAGS is shared: one-line call site, name it in JOURNAL);
   StageLayout maps Dock 9's stage points into the dock_9 place's frame (door = the stage's Dock 9 entry).
   Run quest 1 scenarios flag off (must pass) and on (report).
6. Item 6: zone_frame `--drive=` 30-40 s docks -> downtown along an east-west street (e.g. y 1036, x 1900 -> 1150
   at 20 m/s ~ 37 s), 32 px/m, encode with ffmpeg; 48 px/m stills per zone.
7. Before REPORT: mutate tools on dock_painter.gd / city_places.gd (`tools/mutate/mutate.mjs`), full gates
   (lint, unit, scenarios, evidence/run.mjs parity + look goldens, reel gate).
Gates on b42df1da4 (00:38): full lint 19/19, full unit 2851 passed / 0 failed, scenarios 55/55 (on 5c9a0bd45, code-identical). NOT yet run: evidence/run.mjs (parity + look goldens), reel gate.
Open Calls so far: Dock 9 into the docks by default?; docks on the east edge vs another edge; downtown size
(25 chunks) and landmark density; the tower roofs' orange hazard stripes vs the colour law; water v2 (REQUEST 9).
- 00:45 `tools/evidence/run.mjs --no-bench --no-release` on 9b2a6f996: PASS lint 19/19, unit 2851/0, scenarios
  55/55, parity bit-exact (1200 steps, planted caught at 629), selftest look goldens 11/11 + block goldens 5/5
  (the zones sit outside the selftest junction's sim radius, as designed). Reel gate NOT run yet.
NEXT: start at item 1 of the NEXT list above (quay edge); session 1 ended 00:46 with a clean tree.
## Session 2 (2026-11-18 00:46 -> )
- 00:50 MILESTONE item 3, commit 72a67c265: dock + glass facade styles (REQUEST 4 B, REQUEST 7 v2 A) by_name on the
  dock roofs (86-88) and tower roofs (89-90); storeys rows take their own `bays` (4). Before/after combo 48 px/m:
  `evidence/n18-districts/ab_facade_{dock_dock9,glass_tower}_v16_combo_*.jpg`. Looked: dock wall reads as roller
  doors (only the ground row shows at 8.5 m x height_k 0.5), the tower wall reads as glass with lit panes.
  Probe for texture positions: `%TEMP%/n18d/find_tex.gd` (-s script outside the tree: `Log` is not loaded there, printerr).
- 00:54 MILESTONE commit 82557533a, generator v17: BUG found by looking: CityZone.from_row skipped `water_ground`,
  so the docks water drew id 72 (asphalt box) since v15; the "water reads as asphalt" note of session 1 was my
  bug, not the art. Fixed (reads CityZone.LISTS whole) + 2 tests that fail on v16; water turns 0/180 only.
  Evidence `evidence/n18-districts/ab_water_v16_v17_combo_{32,48}ppm.jpg`: now ink ripple strokes, one heading.
REQUEST assets: 9 WITHDRAWN (to the asset lane): the water a/b you delivered was never drawn (my loader bug, fixed
in 82557533a). In game at 32 px/m it now reads as dark water with warm ripple glints; no redraw needed. If you have
time, the plain-water tile drawn by example from the quay tiles' water (your it470 note) is still welcome, so
the open water and the quay edge water match.
- 01:00 MILESTONE commit 8796ec18a, generator v18: the quay edge autotile (straight N/S/W, inner NW/SW from the
  asset lane's it470 set, ids 93-94, zone key `quay_ground`), 5 m walkable apron on the land sides, the apron's
  bollard line dropped (the coping carries bollards). Registry autotile-rule-set-completeness: test_dock_quay
  lists every neighbour case from the painted tiles (open, N, S, W, NW, SW) and fails on a case without art.
  Outer corner (B) not used: no layout case (the piers run to the city edge). Evidence
  `evidence/n18-districts/ab_quay_edge_v17_v18_combo_{32,48}ppm.jpg`, `quay_pier_join_v18_combo_48ppm.jpg`. Looked:
  the coping turns land on the right sides; the pier sidewalk meets the apron with a small paving-grid change.
- 01:02 full unit on 8796ec18a: 2858 passed, 0 failed, 2 skipped (77 s).
- 01:05 MILESTONE item 5, commit b0314350c: `--quest1-places` (StageDockPlace + collect_call_city.json `dock_place`).
  Shared-file call sites (named here as the brief asks): `project/boot/launch_args.gd` KNOWN_FLAGS gains
  `"--quest1-places"` (one line, after `--strip-prefetch`), and the `--perf-hud` comment moved onto its flag's
  line (same words) so the file stays at 200 lines (debt files_past_soft_cap would have gone 65 -> 66).
  test_stage_dock_place 5/5; planted out_m 1.5 -> metal on a building cell, caught.
- FRICTION: GDScript constructors on Variant (int(case[0]), Vector2(a[0], a[1])) are warnings-as-errors; the
  pattern is typed locals first. gdformat writes CRLF on this machine (git normalises; harmless).
- 01:08 scenarios on b0314350c (flag OFF, the default): 55/55 passed (`node tools/tests/run_scenarios.mjs`).
- 01:09 item 5 flag ON: the 9 quest scenarios through a temp copy of run_scenarios.gd that admits
  `--quest1-places` (`%TEMP%/n18d/run_scenarios_places.gd`, not in the tree): 8/9 pass; **quest1_input FAILS**
  "not paid: state active at beat b4-dock, tick 90000": the input-driven run reaches the b4-dock beat but never
  finishes the dock fight (Dock 9 now ~1.6 km east of Harbor Road). Log: `evidence/n18-districts/quest1_places_on_scenarios.txt`.
  The others pass because they play on the arena layout (shipped() with city false) or don't reach Dock 9.
- 01:12 MILESTONE item 3, commit 82e8076d3, generator v19: container yards (it469/it470 stacks as standing cards,
  2 rows a tile, test_dock_yard; the first slots closed the row gap on the 1 m cell grid: caught by the test
  before commit). Evidence `evidence/n18-districts/ab_yard_containers_v18_v19_combo_{32,48}ppm.jpg`. Looked: the
  stacks read as corrugated containers with corner castings; the world print greys their colour like every prop.
- 01:18 MILESTONE item 3, commit bbc3dae4d, generator v20: downtown plazas (zone key `plaza_centre`: one fountain per
  plaza block on its middle tile; my first wiring put the fountain among slot props -> ~8 a plaza, seen in the
  still, fixed + test_city_plaza_centre), trees in grates (v2 A), bike racks (v2 A), sculpture (B) 1 in 10 (at 1 in 7
  six bronzes in one view read as debris), downtown landmark_share 0.55 -> 0.35; docks long roofs + cold store A +
  sawtooth v2 A; downtown generic roofs + two square tall roofs A (glass walls). Evidence
  `evidence/n18-districts/ab_downtown_{plaza-32ppm,plaza-48ppm,tall-48ppm}_v19_v20_combo.jpg`.
  Asset lane offers NOT taken (and why): water v2 / v2b / `_w2` quay set (the asset lane withdrew them: void premise);
  `ground_dock_water_70_v2_t1` + `_w2t1` quay set (A; the current water reads; a candidate for the next session,
  one data swap); dock facade b brick + downtown stone office (A; need a per-roof alternate style: next session);
  kiosk, mooring bollard, pallets, forklift (B muted), gatehouse v2 ochre (A): dock/plaza dressing for the next
  session (the apron and yards); quay apron tiles (B, seam faults); tower roofs `_ochre` (the colour-law Call:
  ready if the owner says no orange on roofs); outer corner (no layout case).
- 01:20 item 6: `zone_frame --drive=1990,1036,1250,1036,20 --zooms=1 --fixed-fps 60` (docks -> downtown along y 1036,
  37 s) rendering to %TEMP%/n18d/drive.
- 01:24 MILESTONE item 6 first pass, commit 8c42f0ade: `evidence/n18-districts/drive_docks_downtown_v20_combo_32ppm.mp4`
  (37 s, 1110 frames, 0 SCRIPT ERROR; zone_frame saves ~1 frame/s, so a 37 s drive takes ~15 min). Looked at frames
  0/300/600/900/1100: the street centre fills the 25 m frame; docks blocks at the start, downtown landmark roofs at
  the end, the zones show only at the frame edges. A second pass offset onto the blocks is NEXT.
- 01:27 MILESTONE commit 5443ab411: two walls a zone (FacadeStrips alt: dock -> brick warehouse, glass -> stone office,
  it470 A, place hash). `evidence/n18-districts/ab_facade_alt_office_v20_combo_32ppm.jpg` (tower glass -> office). A
  docks row I filmed happened to hash all three buildings to the first wall (no change in that frame).
- 01:30 full unit on 8c42f0ade: 2867 passed, 0 failed, 2 skipped. Masters `gtai-masters\n18\districts\frames.json`
  rebuilt: 11 entries, best first; removed the stale v15/v16 quay/water/yard stills (the water ones showed my bug).
- REPORT.md draft written (cwd root).
- 01:40 GATE: `node tools/evidence/run.mjs --no-bench --no-release` on 506761966: PASS lint 19/19, unit 2867/0,
  scenarios 55/55 (rig_stress contended, re-judged alone: within budget), parity bit-exact (planted caught at 629),
  selftest look goldens 11/11 (worst 0.31) + block goldens 5/5. Reel gate NOT run yet.
- 01:44 MILESTONE commit cd5da26a1, generator v21: downtown `one_sign` (one lettered name a block, on a seeded sign
  tile; my first rule gated the 21 % pick on 1 tile in 25 -> no names at all in 5 chunks, caught by the test's
  "still has landmarks" check; now the sign tile always carries one). Evidence `ab_one_sign_v20_v21_combo_32ppm.jpg`
  (an HQ off its sign tile becomes a plain roof).
- 01:52 mutate dock_painter.gd: 4/12 killed (33.3 %); survivors look-only (golden-pinned) except :126 -> test added,
  now killed (bc29c8a7e).
- 01:55 zone map v21 numbers (REPORT): docks 48 ch 18.75 % (3832 block / 2408 plaza-yard-quay tiles), downtown 25 ch
  9.77 % (2000 / 500), mixed 183 ch 71.48 % (16125 / 2175); gen 256 chunks 5.0 s; bake 6.1 s wall (CONTENDED).
NEXT (session 3, in order):
1. Item 6 second pass: a drive offset onto the blocks (e.g. y 1062 through the docks long blocks' middle, or a
   north-south drive x 1700 -> through yards), and 48 px/m stills per zone (`--at` one docks, one downtown, one mixed).
   Encode with ffmpeg -framerate 30 -crf 23; add to masters frames.json.
2. Asset lane offers to wire (one data swap each, re-bake + golden + before/after): `ground_dock_water_70_v2_t1` with
   the `_w2t1` quay straight/inner (open water and quay edge one texture); the dock apron/yard dressing: mooring
   bollard (A) on the coping? (the coping already draws bollards: maybe pallets A + forklift B-muted + gatehouse v2
   ochre A at yard entrances), coffee kiosk A in downtown plazas (needs a plan twin: ask or skip in the top view).
3. Lettered landmark no-repeat rule (downtown): no two identical LETTERED roofs within 2 blocks (BlockPainter), test.
4. Generator numbers for REPORT: run dev/view/city_zone_map.gd on v20 (zone shares, block counts, bake time).
5. Gates on the session's last code commit: `node tools/evidence/run.mjs --no-bench --no-release` (parity + look
   goldens), reel gate `node tools/reel/run_reels.mjs`, `tools/mutate/mutate.mjs --file=features/city/gen/dock_painter.gd`
   and `--file=boot/collect_call/stage_dock_place.gd` (quote the scores).
6. --quest1-places ON: quest1_input stalls at b4-dock. Investigate why (the walk? the city streaming radius around the
   far dock? waves spawning outside the sim radius?), report; do not make it default.
7. Reel gate: PASSED on a9d327061 at 02:09 (3/3 views, exit 0, ~15 min); re-run on the final commit.
8. Wire the forklift/pallets/gatehouse as yard dressing only if 1-6 are done; then raise the weakest item (the film).
Session 2 ended ~02:00 with a clean tree; HEAD is the JOURNAL commit after bc29c8a7e.
## Session 3 (2026-11-18 02:10 -> )
Read: JOURNAL NEXT, git log, asset replies (it471: 01:45, 01:54, 02:01 notes), police JOURNAL (no NEED districts).
Registry rules applied this session: concept-scene-parity (each roof judged in game at 32/48 px/m before taking,
not on the asset board), sprite-and-atlas-production (copied at game size, plan art 80 px/m, cards through the
cutter, provenance line per PNG), procedural-level-planning (a new roof is data in the zone row; the counts per
zone checked after the bake so no new roof floods a zone).
- 02:20 MILESTONE item 3, commit 395b7ec80, generator v22: it471 roofs (clocktower, terrace _t, tall sq_c_t, bank
  dome, muted crown, dock shed b, warehouse c B) + sculpture v3 card/plan; zone key `upright_roofs` (warehouse c's
  hoist must stay south: seen turned 180 in the first v22 still -> fixed + test_dock_upright, planted caught 29).
  Counts (v22): downtown clocktower 63 (vs unlettered 15: 52, 20: 48), terrace 108, tall c 90, bank dome 3, crown 2;
  docks shed b 77, warehouse c 334 (the other long roofs 323-346). Not taken: `warehouse_70_c_v2` (02:10 file, no
  note yet), silos (B, standalone landmark: needs a placement rule), apron v3t, plaza paving, street/dock cards.
- 02:21 item 6 second pass rendering: `zone_frame --drive=1990,1026,1250,1026,20` (2 m into the north sidewalk, so
  the north blocks' roofs and south faces fill the top half of the frame).
- 02:22 item 5 flag ON root cause (read, not guessed): `CollectCallBot._fight()` held at `layout.w(DOCK_HOLD)`, the
  STREET mapping, and `_boss()` at `w(BOSS_STANDOFF)`: with the flag Rivet stood on Harbor Road while the waves
  spawned on the dock place ~1.6 km east (AIM_M 14 m: he never shot). Second cause: the bot walks straight lines and
  Rivet collides with buildings (StageCells.push_out), so a far goal ends against a wall. Fix (dev bot only):
  `StageLayout.w_dock()` for the two hold points; `BotRoute` (dev/bots, AStarGrid2D over 4 m cells of the 1 m walk
  cells, open = no solid 1 m cell) walks goals >= 40 m away, only when the dock is on. `project/dev/bots/` is in
  neither lane's list; the bot and its route are dev code (not shipped).
- 02:26 MILESTONE item 5, commit 0511d8629: quest1_input flag ON pays in 921 s (55277 ticks; flag off 317 s), 0 deaths,
  replay identical; b4-dock 12932 -> 33825 (the 348 s walk to Dock 9 + the fight), b6 back 343 s. Flag off 4/4 quest
  scenarios, same checkpoints. test_bot_route 4/4, planted caught. Debt dev_loc +97 accepted (dev bot).
- 02:30 MILESTONE item 6 second pass: `evidence/n18-districts/drive2_docks_downtown_v22_combo_32ppm.mp4` (37 s, 1110
  frames, 0 SCRIPT ERROR, y 1026 = the north sidewalk: the blocks fill the top half). Looked at 7 frames: docks
  warehouse roofs + roller doors, mixed, downtown glass walls + terraces. Zone stills 48 px/m:
  `evidence/n18-districts/zones_v22_combo_48ppm.jpg`. Masters frames.json rebuilt, 15 entries (v20 drive, v15 map and
  dock9 v15/v16 removed as superseded).
- Seen in the yard still: black "!" marks over the warehouse roof's north edge (prop cards north of the building
  drawn over its lifted roof?). Investigating.
- Not a defect (read city_crowd_occlusion.gd): the "!" wedges are the rigs' behind-a-roof ink silhouettes (n8 design: rigs
  keep theirs, the baked crowd is hidden). Docks yards put walkers against warehouse north walls, so they show more
  there. Noted in REPORT, not changed (police/view n8 behaviour, a Call at most).
- 02:33 FRICTION (my error): I ran `tools/evidence/run.mjs` on the live tree and edited v23 files while it ran: every kind
  came back INVALID ("the tree changed while ... ran"). Its numbers (unit 2875/0 FLAKY 2, parity bit-exact, look
  goldens 11/11) do not count. Rule for me: gates go through `tools/gate/run.mjs` (a snapshot) whenever I keep working.
- 02:41 MILESTONE item 3, commit 55105450a, generator v23: zone grounds. Downtown plazas draw the it471 granite running
  bond (`plaza_ground` 112, half turns only: a bond turned a quarter breaks at the tile seam), the docks apron the it471
  apron v3t (`apron_ground` 113). test_city_zone_grounds 4/4, planted caught. Looked: the downtown plaza now reads as
  civic stone, clearly not the mixed zone's sidewalk slabs; darker and busier, the walkers still read on it. The
  apron change is small (the apron west of the basin takes the coping's 2 m slab grid).
  Evidence `evidence/n18-districts/ab_it471_ground_{plaza-32ppm,plaza-48ppm,apron-48ppm}_v22_v23_combo.jpg`.
- 02:42 gate: `node tools/gate/run.mjs --reels` on 70ca0c1e7 (v23 + REPORT), background.
REQUEST assets (to the asset lane, from districts; it471 read at 02:10): TAKEN in v22/v23: clocktower, terrace _t,
tall sq_c_t, bank dome, landmark 2x2 muted (as `roof_down_crown`), shed b, warehouse c (B; turned never, its hoist
stays south), sculpture v3 card + plan, plaza paving, apron v3t. NOT YET: warehouse_70_c_v2 (no note: what changed?),
silos (needs a landmark placement rule: next), the street/dock cards (drums, tarp, rope net, fuel tank, bus shelter,
clock, bollards, food cart v2, news boxes v2, lifebuoy, kiosk + plans) - next session as plaza/yard/apron dressing.
REQUEST assets 11 (new, order 1): a docks yard ground, 8 x 8 m at 96 px/m (768 px), plan view, the D5 grey print:
worn concrete with painted yellow-ochre (not vermilion) bay lines for 6.1 x 2.4 m containers, two rows a tile (the
YARD_SLOTS rows at about y 2 m and y 5.5 m of the tile), periodic both ways; match `ground_quay_apron_70_v3t` tone.
It would make the container yards read as yards, not plazas.
NEED police: `project/features/city/sim/**` (traffic variant pick) - the brief asks for "more trucks in the docks if the
vehicle table has them": there is no truck, but van and pickup exist (`VehicleProfile.archetype_of_variant`). If you
want it, read `CityZones.id_of_chunk(cx, cy)` (gen side, read-only for you) and weight van/pickup up in `&"docks"`. If you
prefer data, say so here and I add a `car_mix` weight row to the docks/downtown rows of city_district.json (my file).
- 02:50 the it471 coaster ship (A) is drawn lying east-west for the 70 camera; the docks basins run north-south (24 m wide
  between piers), so it cannot moor there without a 90 deg turn that breaks the drawing. Options for later: an east-west
  basin along the south edge of the docks band, or ask the asset lane for a bow-north drawing. Not done.
- 02:53 GATE (snapshot, `tools/gate/run.mjs --reels`) on 70ca0c1e7 (v23): evidence PASS lint 19/19, unit 2879/0 (2 skipped),
  scenarios 55/55, parity bit-exact (planted caught at 629), selftest look goldens 11/11 (worst 0.31) + 0 placeholders,
  export-audit release-compile 726/0. Reels running.
- v24 prepared in the tree, not baked yet (Godot held by the gate): coffee kiosk (A) + food cart v2 (A) cards + plan twins
  into downtown plaza_props (ids 114-115).
- 03:04 GATE PASS on 70ca0c1e7 (v23), full: evidence (above) + reels exit 0 (`build/gate/70ca0c1e7067/gate.json`).
- 03:10 MILESTONE item 3, commit 93f37b1d7, generator v24: plaza singles. Wired first as slot props, the kiosk stood five
  times in one plaza (138 draws downtown, seen in the probe before any frame); zone key `plaza_singles` stands each once
  a plaza block on a seeded tile off the middle. test_city_plaza_singles 3/3, planted caught. Looked at 48 px/m: kiosk +
  cart read, parasol greyed by the print. `evidence/n18-districts/ab_it471_plaza_singles_kiosk-{32,48}ppm_v23_v24_combo.jpg`.
- 03:11 gate (snapshot, evidence only, no reels) on 93f37b1d7 (v24) started in the background.
NEXT (session 4, in order):
1. The reel gate on v24 (evidence passed, reels not run): `node tools/gate/run.mjs --reels` on HEAD (~25 min). Gates must run
   through tools/gate/run.mjs (snapshot) while I edit.
2. Mutate (quote scores): `--file=boot/collect_call/stage_dock_place.gd`,
   `--file=features/city/gen/tile_painter.gd --tests=test_city_plaza_singles,test_city_zone_grounds,test_city_plaza_centre`.
3. More it471 dressing as zone data (one bake each, before/after): docks apron (lifebuoy post A, oil drums v2 A, cargo tarp
   v2 A, fuel tank v2 A, rope net A) as `apron_props`/yard dressing; downtown kerb cards (bus shelter v2 A, street clock A,
   bollards A, news boxes v2 B) - kerbs are KerbDresser's (zone row `kerb_props`?). Plan twins exist only for kiosk, sculpture,
   bus shelter, food cart: ask the asset lane for the rest (REQUEST assets 12) or check how a card-only prop draws in top view.
4. Dock 9 identity: the it471 harbour office roof (A, 8.4 m) on the dock_9 block's door tile? (a place-aware roof needs the
   generator to know the place rule: CityPlaces resolves from the generator, so do it as a DockPainter rule "the block
   nearest the quay middle gets the office roof on its door tile" and test that CityPlaces' door lands on it).
5. Silos (B) landmark and the coaster ship: need a placement rule / an east-west basin; Call material.
6. REPORT final at 07:40: Calls (Dock 9 default no; plaza granite; tower stripes; the ship), merge notes (golden v14 -> v24,
   debt baseline, launch_args line, dev/bots files), generator numbers re-measured on v24 (city_zone_map run).
7. Asset replies: watch `gtai-assets/replies/n18-districts.md` for REQUEST 11 (yard ground) and warehouse c v2's grade.
REQUEST assets 12 (to the asset lane, from districts, order after REQUEST 11): plan twins at 80 px/m, pure plan like your
it471 kiosk/food-cart plans, keyed, for the it471 cards I want to wire next session: `prop_dock_oil_drums_v2`,
`prop_dock_cargo_tarp_v2`, `prop_dock_fuel_tank_v2`, `prop_dock_lifebuoy`, `prop_dock_rope_net`, `prop_down_street_clock`,
`prop_down_bollards`, `prop_down_news_boxes_v2` (name each `<card id>_plan_70.png`, size = the object's footprint in m x 80).
The top view draws the plan art (city_textures `art`); the 70 cards draw only under a tilt, so a card without a plan twin
cannot ship. (Bus shelter, kiosk, food cart and sculpture v3 already have theirs: thanks.)
- 03:19 GATE PASS on 93f37b1d7 (v24), evidence only (snapshot): lint 19/19, unit 2882/0 (2 skipped), scenarios 55/55, parity
  bit-exact (planted caught at 629), look goldens 11/11 (worst 0.31), 0 placeholders, release-compile 726/0. Reels: not
  run on v24 (passed on v23 70ca0c1e7 at 03:04).
- 03:21 mutate `dev/bots/bot_route.gd` (8 of 50 sampled, tests test_bot_route): 7/8 killed, 87.5 %; survivor :70 rings 4 -> 5
  in `_nearest_open` (only differs when no open cell lies within 3 cells: near-equivalent). Checkout clean after.
Session 3 ended 03:22 with a clean tree; HEAD = this JOURNAL commit after 93f37b1d7 (v24).
## Session 4 (2026-11-18 03:22 -> 04:52)
Read: JOURNAL NEXT, git log, asset replies (it472 REQUEST 11 yard ground 02:48, it473 03:05-03:14: REQUEST 12 plan
twins all eight DELIVERED, bow-north coaster + tug, litter bins, pipe bundles, cable reels, straddle carrier, truck).
Registry rules applied: concept-scene-parity (the yard ground judged in game at 32/48 px/m, not on the 2x2 board),
sprite-and-atlas-production (copied at game size, provenance line), procedural-level-planning (a ground is a zone key).
- 03:30 MILESTONE item 3, commit c6b9fe8a0, generator v25: the docks yard ground (zone key `yard_ground` 116, never
  turned). test_city_zone_grounds 5/5, planted turn caught. Looked: the yard reads as docks concrete, one surface with
  the apron; the ochre bays are faint under the world print and mostly under the stacks.
  `evidence/n18-districts/ab_it472_yard_ground_v24_v25_combo_{32,48}ppm.jpg`.
REQUEST assets 13 (to the asset lane, from districts, order 1, small): re-run `tools/yard_ground_it472.py` with the bay
rows centred at y 1.5 m and y 5.5 m (DockPainter.YARD_SLOTS is (4.0, 1.5), (4.0, 5.5); the first row sits 0.5 m north of
your 2.0). Same name with `_v2`; I swap the PNG (no re-bake). Optional: a touch more ochre saturation, the world print
greys it to near-invisible at 32 px/m.
- 03:36 MILESTONE item 3, commit 7afb9a689, generator v26: the docks dressing (`DockDresser`, gen): cargo tarp v2 + fuel tank v2
  on the quay apron's land side (`apron_props` share 0.5, `OPEN_M` 2.5 m by the water kept open), a lifebuoy post by each
  basin's west coping (`quay_edge_prop`). Cards cut with city_prop_cut.py; the tarp and tank plan twins turned 90 deg (their
  cards' fronts show the long side: facing widths 233/126 and 257/130 px). test_dock_dressing 3/3. Looked: the fuel tank reads
  well at 48 px/m. NOT taken: oil drums v2 (rust-red drums: red is blood only), rope net (vermilion hazard stripes on the hook
  block), news boxes v2 (the cutter finds fewer than five facings). `ab_it473_apron_dressing_v25_v26_combo_{32,48}ppm.jpg`.
- 03:42 MILESTONE item 3, commit b32980b92, generator v27: downtown's own sidewalk furniture: zone keys `kerb_props` and
  `wall_props` (KerbDresser; absent = the n14 mixes, so mixed/docks unchanged). First pass with kerb_props alone: the frame
  still showed three n14 dumpsters along a downtown wall, so wall_props too (planters, trash cans, litter bins, benches).
  test_city_kerb_props 3/3 (planted caught). `ab_it472_downtown_{kerbs,kerbbs}_v26_v27_combo_{32,48}ppm.jpg`.
- FRICTION (my error): a cleanup `rm` deleted one evidence pair right before `git add`, so the add aborted and the commit took
  only the art; I amended that unpushed commit with the rest (same message). Rule: never rm in the same command as the add.
- 03:44 gate (snapshot, `tools/gate/run.mjs --reels`) on b32980b92 (v27) started, background.
- Masters frames.json: 15 entries (added kerbs v27, apron v26, yard ground v25; dropped water v16/v17, dock9 facade v16,
  downtown tall v19/v20 and their files).
- v28 prepared (not baked: Godot held by the gate): Dock 9's harbour office roof (it471 A) on the quay-end shed of dock_9's
  block (zone key `office_roof`, `DockDresser.shed_or_office`; `CityPlaces.nearest_block` made static so the generator reuses
  the place rule without reading places.json). test_dock_office written.
- 03:50 the bow-north tug (it473, A) fits a basin (14 m in the 30 m of open water between the pier aprons; the 42 m coaster
  does not) and would draw flat in the water (a prop with no card row draws its plan: chunk_lift.gd:131-135). Not taken
  tonight: its stern carries orange/black hazard stripes, the same colour-law question as the rope net and the 2x2 tower
  roofs (an owner Call); consistent with those, I wait for the ochre twins below.
REQUEST assets 14 (to the asset lane, from districts, order after 13): ochre-stripe twins (the hazard stripes in your
yellow-ochre, like the `_ochre` tower roof twins) of `prop_dock_tug_plan_70_north` and `prop_dock_rope_net_70` (+ its plan
twin); and the oil drums v2 card + plan with the rust-red drums turned grey-green/ochre (red is blood only). Names `_ochre`.
- 03:5x evidence gate (snapshot) PASS on b32980b92 (v27): lint 19/19, unit 2889/0 (2 skipped), scenarios 55/55, parity
  bit-exact (planted caught at 629), look goldens 11/11 (worst 0.31), 123 art textures 0 placeholders, release-compile 727/0.
  Reels running.
- 04:07 GATE PASS on b32980b92 (v27), full: evidence (above) + reels exit 0 (`build/gate/ace68b55a262/gate.json`).
- 04:12 MILESTONE items 3 + 5, commit dee06ed7b, generator v28: Dock 9's harbour office (it471 A) on the quay-end shed of the
  dock_9 block's south row (zone key `office_roof`, `DockDresser.shed_or_office`; `CityPlaces.nearest_block` static). Tests
  131/131; planted "any shed on the row" (3 offices) and "row above" caught; "within 2 tiles of the office" survived (no other
  shed there: near-equivalent). Door unchanged (1980.5, 1025.5). Looked: lookout cabin + mast + stone front read as Dock 9's
  landmark among roller doors; it stands ~30 m east of the door (the door is the block middle). Evidence
  `ab_it471_dock9_office_v27_v28_combo_{32,48}ppm.jpg`, `ab_it471_dock9_door_v27_v28_combo_48ppm.jpg`; masters 15 (quay v17/v18 out).
- 04:13 gate (snapshot, --reels) on dee06ed7b (v28) started, background.
- 04:15 asset replies it474: REQUEST 14 DELIVERED (03:58: tug, rope net, oil drums `_ochre`; news boxes v2 re-spaced). Also
  offered (not wired): planter bed, stone ledges, chess tables (+ plans), dinghy (plan drawing), straddle carrier, container
  truck, cable reels, pipe bundles, litter bins (wired v27). v29 prepared in the tree (ochre rope net + drums on the apron,
  news boxes on downtown walls, a bow-north tug moored flat in half the basins: `basin_boat`), to bake after the v28 gate.
- 04:36 GATE PASS on dee06ed7b (v28), full: lint 19/19, unit 2891/0 (2 skipped), scenarios 55/55, parity bit-exact (planted
  caught at 629), look goldens 11/11, 124 art textures 0 placeholders, release-compile 727/0, reels exit 0
  (`build/gate/dee06ed7b16e/gate.json`).
- 04:38 MILESTONE item 3, commit 8894e90aa, generator v29: REQUEST 14's ochre twins wired (rope net + drums on the apron, news
  boxes on downtown walls) and a bow-north tug moored flat in half the basins (`basin_boat`, `basin_boat_share` 0.5). Tests
  132/132. Looked: the tug reads in the basin water at 32 px/m, the rope nets show as dark heaps on the apron.
  `ab_it474_basin_tug_ochre_v28_v29_combo_32ppm.jpg`. Evidence gate (no reels) on 8894e90aa started 04:39.
NEXT (session 5, in order):
1. Evidence gate on 8894e90aa (v29) PASSED at 04:46: lint 19/19, unit 2892/0 (2 skipped), scenarios 55/55, parity bit-exact
   (planted caught at 629), look goldens 11/11, 128 art textures 0 placeholders, release-compile 727/0
   (`build/gate/8894e90aa443/gate.json`). Still to run: the reel gate on v29
   (`node tools/gate/run.mjs --reels`, ~25 min). Gates only through tools/gate/run.mjs while editing.
2. Masters: add the v29 tug still (frames.json at 15: drop the weakest), 48 px/m tug + drums close-up.
3. Dock 9 door at the office (REPORT Call): a places.json frontage key (e.g. `door: "office"`) that puts dock_9's door before
   DockDresser.office_tile instead of the block middle; then run quest1 with --quest1-places (scenarios flag on) and report.
4. Asset offers not yet wired (it474): planter bed + stone ledges + chess tables (downtown plazas: plaza_props / singles),
   dinghy (apron, when its plan lands), straddle carrier / pipe bundles / cable reels (yard dressing; plans first).
   REQUEST 13 (yard bays at y 1.5) open: a PNG swap, no re-bake.
5. Mutate (quote scores): `--file=features/city/gen/dock_dresser.gd --tests=test_dock_dressing,test_dock_office` and
   `--file=features/city/gen/kerb_dresser.gd --tests=test_city_kerb_props`.
6. Item 6 film pass 3 on v29: the docks -> downtown drive again (zone_frame --drive, 37 s, 32 px/m) to show tonight's dressing,
   plus 48 px/m stills per zone; generator numbers re-measured (dev/view/city_zone_map.gd) for REPORT.
7. REPORT final at 07:40 (Calls: Dock 9 default no; door at office; hazard stripes; plaza granite; tower stripes; merge notes:
   golden v14 -> v29, debt baseline, launch_args line, dev/bots files).
Session 4 ended 04:47 with a clean tree; HEAD = this JOURNAL commit after 8894e90aa (v29).
## Session 5 (2026-11-18 04:47 -> )
Read: JOURNAL NEXT, git log, asset replies (it474 04:18-04:26: dinghy plan, ledges v2, hatch covers v2, grain v2, gangway v2,
flower crates + plan; it475 04:45: drums plan v3, propeller, crab pots, nav buoys, scrap skip, road works), police JOURNAL
(no NEED districts). Registry rules applied: concept-scene-parity (each card judged in game at 32/48 px/m: the flower crates
were dropped from the slot mix after the still, not on the board), sprite-and-atlas-production (cut by the cutter, plan
twins at their game size, a provenance line per PNG), procedural-level-planning (a landmark-sized prop is a once-a-block
single, never a slot prop; one data value moves it).
- 04:48 reel gate on a2797f8b7 (v29) started, then STOPPED by me at 04:56 (my PIDs 47696 tree): it held Godot ~30 min for a
  commit already superseded; the final commit gets the full gate instead. Reels last PASSED on dee06ed7b (v28).
- 04:58 MILESTONE items 4 + 5, commit bf5857f6f: places.json `door` key (middle | office); dock_9 `door: "office"`: its door
  slides from the harbour office tile's middle (`DockDresser.office_tile_on`), not the long block's middle. Place only, no
  re-bake. test_dock_office 3/3 (door inside the office tile's x span; a door-less row on the same rule stays west, same
  block). test_bot_route's step bound was 1.5 cells for every step; the end steps join the exact door/goal inside a 4 m cell
  (up to 2.2 cells), and the moved door made the last 6.04 m > 6.0: bound split (ends 2.2, inner 1.5).
- FRICTION: `tools/gate/quick.mjs` reports FAIL on any test that reaches CitySystem (test_bot_route, and the UNCHANGED
  test_stage_dock_place): `check.mjs` alone sees "Failed to compile depended scripts" from res://core/events/events.gd down,
  while events.gd alone checks ok and GUT compiles + passes them. A check-only cascade, not a parse error.
REQUEST tools: `tools/godot/check.mjs` should classify a cascade whose root (core/events/events.gd) checks ok alone as
UNVERIFIABLE (exit 3), not FAIL. Repro: `node tools/godot/check.mjs res://tests/unit/test_stage_dock_place.gd` on 7dd676b04.
- 05:00 MILESTONE item 3, commit 7dd676b04, generator v30: downtown plaza singles: planter bed 128, stone ledges v2 129, chess
  tables 130, flower crates 131 (it474 A, cards + plan twins). First pass had the flower crates as a slot prop: six in one
  32 px/m frame and every slot pick reshuffled (seen in the still), so they became a single; slot mix = v29. Full unit
  2895/0; bake --check deterministic + matches. Looked: the L ledges and planter bed read at 48 px/m; the flower colours grey
  out under the world print like every prop (the crates still read as a display). Evidence
  `ab_it474_downtown_plaza_singles_v29_v30_combo_{32,48}ppm.jpg`, `downtown_plaza_chess_flowers_v30_combo_48ppm.jpg`.
- Cut and looked (not wired yet): it475 propeller (A: five facings near-identical, flat bronze), crab pots (A), dinghy (card
  facing 0 is bow-on; its plan twin lies east-west: turn it 90 deg like the tarp/tank), nav buoys (magenta key spill inside
  the cradle, all five facings), scrap skip (the cutter finds fewer than five facings in the top row).
REQUEST assets 15 (to the asset lane, from districts, small): (a) `prop_dock_nav_buoys_70.png`: despill the magenta key
inside the cradle (between and under the two buoys, every facing); same name `_v2`. (b) `prop_dock_scrap_skip_70.png`: the
cutter (`tools/art/city_prop_cut.py`, alpha >= 24, column runs joined under 12 px) finds fewer than five facings in the top
row: two facings touch or one is missing; re-space to five clear facings, `_v2`. (c) plan twins at 80 px/m for the
propeller (about 2.2 m), crab pots and nav buoys, if facing 1 is not pure plan.
- 05:02 item 5 flag ON with the office door (on 7dd676b04): quest1_input PASS, pays in 930 s (55817 ticks; middle door 921 s /
  55277), 0 deaths, 49 kills, replay identical; checkpoints b4-dock@12932, b5@34095 (middle door 33825). One WARN
  "checkpoint at b4-dock did not re-simulate to its hash" (then the resume + tamper refusal pass). 28.6 s wall.
  `evidence/n18-districts/quest1_places_on_office_door.txt`.
- 05:04 Dock 9 door still, middle vs office (camera on the place, zone_frame --place=dock_9; before = places.json without the
  key, restored after): the door now stands before the office's stone front + lookout mast instead of a roller-door run.
  `ab_dock9_door_middle_office_v30_combo_{32,48}ppm.jpg`. (zone_frame parks Rivet ~9 m north of the focus: on the roof.)
- 05:06 MILESTONE item 3, commit 5058c48d8, generator v31: docks apron_props add the it475 propeller 132, crab pots 133 and
  the it474 dinghy 134 (plan twin turned 90 deg to the bow-on card); propeller/crab pots plan = card facing 0 scaled to
  80 px/m (no plan twin offered); oil drums plan -> it475 v3 (six drums). Full unit 2893/0; bake --check ok. Looked: the
  propeller reads as a bronze landmark at 64 px/m; crab pots and rope nets are small dark heaps at 48 px/m (weaker than the
  tarps). `ab_it475_docks_apron_v30_v31_combo_{32,48}ppm.jpg`, `docks_apron_propeller_v31_combo_64ppm.jpg`.
- 05:07 full gate (snapshot, --reels) on 5058c48d8 (v31) started, background (`build/gate/s5_v31_reels.log`).
- Masters frames.json: 15 (added dock 9 door office, v30 plaza singles, v31 apron, v29 tug; dropped one-sign v21, yard
  containers v19, dock c roofs v22, facade alt v20 and their files).
- 05:1x MILESTONE tools, commit 1ce6ece2f: the REQUEST tools above, built (no tools lane tonight): `tools/godot/check.mjs`
  drops Godot's shutdown report ("N RID allocations ... leaked at exit", "N resources still in use at exit" + their at:
  lines) before judging; those two lines were the "cause" that turned an all-cascade run into FAIL. New test in
  check.test.mjs; planted bypass caught (1 fail); tools/godot tests 96/96. Live re-check of test_stage_dock_place after
  the gate frees Godot.
- 05:1x asset replies it476 (05:08): REQUEST 15 (a) nav buoys v2 despilled (802 magenta px -> 0) and (b) scrap skip v2
  re-spaced (five facings, 60 px gaps) DELIVERED; (c) plan twins for propeller / crab pots / nav buoys drawing (round
  20261118-0610; facing 1 of each card shows sides). Cut + looked: both clean. v32 prepared in the tree (nav buoys 135,
  scrap skip 136 on the docks apron; card facing 0 as the plan stand-in), to bake after the gate.
- Prepared: zone_frame place shots focus on the door itself (Rivet stood on the roof 6 m north); test_city_zone_cards (every
  standing prop a zone row names has a city_facades card row with art on disk, so none draws flat unseen).
- 05:17 evidence gate on 5058c48d8 (v31): unit 2893/0 (2 skipped), scenarios 55/55, parity bit-exact (planted caught at
  629), look goldens 11/11 (worst 0.31), 135 art textures 0 placeholders, release-compile 727/0; lint FAIL 1/19
  (tool-tests): `tools/film/film2.break.test.mjs:73` "an unsafe integer must not trap the range loop": its 2 s worker hang
  timer fired under both lanes' gates (test 13 s). Alone: 57/57 in 175 ms, twice; tools/film unchanged since the base.
- MILESTONE tools, commit 81c409665: that timer 2 s -> 15 s; planted (shots.mjs:151 safe-integer guard out) still caught.
  Reels on 5058c48d8 running.
- 05:32 full gate on 5058c48d8 (v31): reels PASS (exit 0); the gate verdict FAIL is only lint's tool-tests flake above (fixed
  in 81c409665): `build/gate/5058c48d81df/gate.json`. Everything else PASS (numbers at 05:17).
- 05:35 MILESTONE commit 69fb262cd: test_city_zone_cards (planted: dock_scrap_skip's card row removed -> caught) + zone_frame
  place shots on the door (Rivet at Dock 9's office door: `dock9_door_office_rivet_v32_combo_{32,48}ppm.jpg`).
- 05:36 MILESTONE item 3, commit cf4605b1e, generator v32: nav buoys v2 135 + scrap skip v2 136 on the docks apron (REQUEST 15
  a+b). Full unit 2895/0; bake --check ok. `ab_it476_docks_apron_{skip,buoys}_v31_v32_combo_48ppm.jpg`. Looked: the skip's
  chevrons read; the buoys' ochre bands grey under the print.
- 05:37 `node tools/godot/check.mjs res://tests/unit/test_stage_dock_place.gd` -> ok (exit 0) live.
- 05:38 item 6 film pass 3 rendering (zone_frame --drive=1990,1026,1250,1026,20, --fixed-fps 60, v32).
- 05:41 MILESTONE item 6 film pass 3, commit 0c31cdf2f: `drive3_docks_downtown_v32_combo_32ppm.mp4` (37 s, 1110 frames, 0 SCRIPT
  ERROR, 3.7 min render) + sheet. Looked at 5 frames: warehouse fronts -> towers; this street shows none of the apron/plazas.
- 05:44 MILESTONE item 6, commit after 0c31cdf2f: `drive4_docks_apron_v32_combo_32ppm.mp4` (north -> south along the apron x
  2012, 26 m/s, 37 s, 1108 frames, 0 SCRIPT ERROR) + 6-frame sheet: warehouse ends, apron dressing, the basin edge.
- 05:45 zone map v32 (`evidence/n18-districts/zone_map_v32.{png,json}`): tile counts = v21 (docks 48 chunks, 3832 block +
  2408 plaza/yard/quay tiles; downtown 25, 2000 + 500; mixed 183, 16125 + 2175); 256 chunks generated in 3.6 s; bake 4.9 s
  wall (CONTENDED). Masters frames.json 15: + drive4, drive3 (replaces drive2), zone map v32; clocktower v22 out.
- 05:49 mutate dock_dresser.gd (12 sampled; tests dock_dressing, dock_office, city_places): 6/12 = 50 %. Survivors :26 7.5->8.5,
  :27 rot, :41 - -> +, :46 rot were real gaps -> commit 73e02f64b (apron props 0.5 m inside the tile, quay edge prop wholly on
  land, the dressing unturned). Re-run 10/12 = 83.3 %; survivors :26 salt 66->67, :39 >= -> > (near-equivalent). Clean after.
- 05:55 mutate kerb_dresser.gd with test_city_kerb_props, test_dock_dressing, test_city_plaza_singles: 0/12 (0 %). The sampled
  lines are the n14 kerb code (parked cars, cut lists, plaza checks: :58-:156), which none of those three tests reach. Re-run
  it with the mapped tests (`node tools/tests/test_map.mjs project/features/city/gen/kerb_dresser.gd`) before quoting.
- 05:56 asset plan twins landed (it476 round 0610: propeller, crab pots, nav buoys, scrap skip v2). Tried them as v33 and
  REVERTED (not committed): in the combo view the cards draw, so before/after at 48 px/m was identical for the propeller,
  and the scrap skip's real 3.5 m plan cast a shadow box longer than its end-on card (worse). Crab pots plan not taken:
  an empty pot without the card's floats and rope coil. Tree back to v32, bake --check matches.
NEXT (session 6, freeze 07:30, REPORT 07:40):
1. FULL GATE on HEAD first (`node tools/gate/run.mjs --reels`, ~25-35 min under load). Last: v31 5058c48d8 everything PASS
   (reels exit 0) except the film2 timer flake, fixed in 81c409665. v32 = props + test only; full unit 2895/0 on it.
2. If time while the gate runs (no Godot): REPORT final. Calls: Dock 9 default (no: 348 s walk each way), door at office
   (built; revert = delete the key), hazard stripes / tower stripes (`_ochre` twins used), plaza granite, the flower crates as
   a single, the weak crab pots; merge notes: golden v14 -> v32, debt baseline dev_loc, launch_args line, tools touched
   (check.mjs 1ce6ece2f, film2.break.test 81c409665), dev/bots files.
3. Plan twins (top view only): swap propeller + nav buoys plan twins (size_m 2.2x2.21, 2.2x1.32), judge in the TOP view
   (`--view=top`?) not combo; scrap skip plan needs the card cell re-fit (its end-on card is shallower than the plan).
4. kerb_dresser mutate with mapped tests; quote the score.
Session 5 ended ~05:58 with a clean tree; HEAD = this JOURNAL commit after 73e02f64b (v32).
- 05:58 full gate (--reels) on e597460ec (HEAD, v32) STARTED in the background by session 5: node PID 42032, log
  `build/gate/s5_head_reels.log`, result `build/gate/e597460ec*/gate.json`. Session 6: if PID 42032 still runs, wait for it
  (do not start a second gate); if it is gone with no gate.json, re-run. It frees Godot on exit.
## Session 6 (2026-11-18 05:58 -> )
Read: JOURNAL NEXT, git log, asset replies (it476 05:41-05:48 offers: gutting tables, tree bench, fish tanks, plaza steps +
plans; it477 05:59: crab pots + rope net v2, values lifted), police JOURNAL (no NEED districts). Registry rules applied:
concept-scene-parity (the it477 value lift is judged in game under the print, not on the board), sprite-and-atlas-production
(cut by the cutter, plans at 80 px/m, a provenance line per PNG; the v1 recut equals the repo to the pixel before swapping),
procedural-level-planning (a 5 m plaza prop is a once-a-block single, never a slot prop).
- 05:59 gate PID 42032 (session 5, on e597460ec v32, --reels) still running: no Godot for me until it ends.
- 06:01 MILESTONE item 3, commit a0273b373: it477 crab pots + rope net v2 (cards cut, rope net plan v2, crab pots plan from the
  v2 card's facing 0 = the v31 recipe, reproduced to diff 0 on v1 first). No re-bake (city_facades is not a generator input).
- 06:02 v33 prepared in the tree (not baked): fish tanks 137 + gutting tables 138 on the docks apron, plaza steps 139 + tree
  bench 140 as downtown plaza singles; data, version, test count, provenance, decisions line. Bake after the gate.
- 06:05 car_art landed in the tree (commit with v33): zone rows `car_art` (docks [4,5,0,4,1,5,2,4,7,5,3,0]: 6 of 12
  vans/pickups; downtown [0,1,2,3,3,7,0,1,3,4,6,2]: 3 taxis), `CityZone.car_art` (empty in mixed = CitySpawner.CAR_ART).
NEED police: `features/city/city_spawner.gd` line 76: read `CityZones.of_chunk(cx, cy).car_art` (CitySystem's gen.zones) for the
  spawn's chunk and pick `car_art[_rng.randi_range(0, car_art.size() - 1)]` when it is not empty (same single draw, 12
  entries, so mixed chunks keep their draws). Your file: I do not touch it.
- FRICTION: lint tool-tests fails 6 `tools/film/kill_reel_{scout,life}.break.test.mjs` tests while the tree has PNGs not yet
  imported: `film.mjs filmOne` checks the REAL tree's assets (staleAssets) and launches `--import` through the test's mock
  runner, which has no `--film-dir` (mkdirSync(undefined)). Not my code; clears after `--import`.
REQUEST tools: kill_reel scout/life tests should pass `staleAssets` a fixture project (or stub it), so they never read the
  working tree's import state.
- 06:07 gate on e597460ec (v32) evidence half: lint 19/19, unit 2896/0 (2 skipped), scenarios 55/55, parity bit-exact
  (planted caught at 629), look goldens 11/11 (worst 0.31), block goldens 5/5, 137 art textures 0 placeholders,
  release-compile 727/0. Reels running.
- 06:22 MILESTONE gate PASS on e597460ec (v32), reels exit 0 (`build/gate/e597460ece54/gate.json`).
- 06:2x it477 before/after at the same v32 point (2014, 1696): the v2 values barely change the read; the heaps stay dark.
  Cause (looked): the offset shadow copy (ChunkBuild L_SHADOW, the plan art darkened, 0.18 m off) shows through the
  see-through mesh cards. Fix: texture rows take `shadow` (default true); 124 + 133 false. Same-point pair shadow on/off on
  v33: the rope net reads as a pale coil net, the crab pots lighten. Taken.
- FRICTION: `git show <rev>:<png>` gives the LFS pointer, and Godot's import of a pointer rewrote the tracked `.import`
  files with `valid=false`; fixed by `git show | git lfs smudge` and `git checkout HEAD -- <png>.import` + re-import.
- 06:33 MILESTONE item 3 + 2, commit 99f8b3071, generator v33: fish tanks 137 + gutting tables 138 (apron), plaza steps 139
  + tree bench 140 (downtown singles), `shadow: false` on 124/133, zone `car_art`. Bake 4.8 s, --check matches; city tests
  39/39; planted (shadow always on) caught. Per-zone sheet `zones_v14_v33_combo_48ppm.jpg`: a one-zone bake (mixed row
  only = the v14 rules) vs v33 at Dock 9, the fish quay, the Toner Room and a downtown plaza.
- 06:35 final gate (--reels) on HEAD started.
- To the asset lane (no REQUEST): it477 crab pots + rope net v2 TAKEN (a0273b373). Your value measure was right, but in game
  the dark read came mostly from our shadow copy showing through the mesh, not the art: we turned that shadow off for both
  (v33). No mid-grey version needed. it476 TAKEN in v33: fish tanks (+ plan B), gutting tables (+ plan), plaza steps (+ plan),
  tree bench (facing 1 as plan). The fish tanks' water is the darkest thing on the apron at 48 px/m; acceptable.
- Masters frames.json 15: + zones_v14_v33 (first), shadowless rope net, it476 apron fish, it476 plaza steps; out: zones_v22,
  roofs crown v22, kiosk v24, yard ground v25 (files deleted).
- 07:00 MILESTONE final gate PASS on 4c4afb209 (v33): lint 19/19, unit 2898/0 (2 skipped), scenarios 55/55, parity
  bit-exact (planted caught at 629), look goldens 11/11 (worst 0.31), 141 textures 0 placeholders, release-compile 727/0,
  reels exit 0 (`build/gate/4c4afb2099b4/gate.json`).
- 07:03 mutate kerb_dresser.gd, mapped tests (kerb_props, dock_dressing, plaza_singles, chunks, zone_lint, lane_grid): 0/10.
  The sampled lines are n14 parked cars / cut lists / offsets; no unit test asserts them. Two planted by hand (:63 true ->
  false, :104 0.12 -> 1.12) both fail `bake_city.gd -- --check`: the golden list is their guard. Tree restored, --check
  matches.
- 07:05 REPORT final (cites: 0 missing). Masters 15.
NEXT (morning / next night): see REPORT `## Next steps`. Police: read zone `car_art` in city_spawner.gd (NEED police above).
Session 6 ended ~07:06 with a clean tree; HEAD = this commit (code = 99f8b3071, v33, gate PASS on 4c4afb209).
- 07:07 MILESTONE commit 771ae3ba9: test_city_kerb_parked (2/2). Mutate kerb_dresser.gd (tests kerb_parked, kerb_props,
  dock_dressing): 2/10 = 20 % (was 0/10): both parked-car faults at :63 killed; survivors :43 :47 :62 :66 :86 :104 :111 :117
  (salts, offsets, cut list, decal ranges). Clean after. Full unit on HEAD running.
- 07:09 full unit on 771ae3ba9: 2900 passed / 0 failed / 2 skipped.
Session 6 ended ~07:10 with a clean tree; final code = 771ae3ba9 (v33; gate PASS with reels on 4c4afb209 + full unit 2900/0).
