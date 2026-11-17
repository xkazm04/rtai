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

