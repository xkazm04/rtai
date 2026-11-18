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
