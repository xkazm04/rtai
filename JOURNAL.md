# JOURNAL: night n8, lane `city` (buildings, roofs and props under the angled view)

Branch `n8-city`, worktree `C:\Users\kazda\kiro\gtai-wt\n8-city`. Evidence: `C:\Users\kazda\kiro\gtai-masters\n8\city\`.

## Iteration 1 (2026-11-06 20:27-21:27, BUILD)

Read: AGENTS.md, view.json, the tail of docs/decisions.md, docs/view-lab/PLAN.md (rows for buildings,
occlusion, streaming), the library catalog for `building` / `prop`, the four keyed facade sheets.

How the city draws (for the next session): `ChunkView` (features/city/view/chunk_view.gd) records each
chunk's draw list into RenderingServer items per band (ground, decals, building_shadows, props, roofs)
on the WORLD canvas (layer 0); every actor (people, cars, cards) is on the ACTORS canvas (layer 2),
always above the whole world. Buildings are 8.4 m (or 16.4 m) roofs, butt-joined 5 x 5 per block.
Before this lane every roof stayed flat on the ground under a tilt.

- MILESTONE 49af40fb: **facades.** Under a tilt (`ViewMode` not flat, not top_lift) `ChunkLift`
  (features/city/view/chunk_lift.gd) lifts every roof by its height (`ViewMode.lift_px`) and draws its
  south face from the ground line to the roof, tiled bay by bay from a style's wall strip, with ink
  edges (left, right, ground line). Buildings draw south edge last within a chunk quadrant (painter),
  so a front building covers the one behind. Heights and styles are data
  (`data/tables/city_facades.json`, `gtai.city-facades/1`): default tenement 14 m; tall 21, helipad 18,
  hq 17, the big blocks 10-16; warehouse / sawtooth / solar / long_t1 = shop style 8.5-10 m;
  `height_k` scales all (the owner call: true height vs shortened). Strips keyed by the view row's
  art (`res://features/city/art/view/<art>/facade_<style>.png`), `art_fallback` p70 -> p55 until the 70
  twins land. `top` builds no ChunkLift (null): its draw path is the old one, command for command.
- The strips: `tools/art/city_facade_cut.py` cuts the top-row pieces 1-3 wall bands from the library's
  `facade_kit_55_untapered` (tenement: plain, shutter, stoop+awning) and `facade_shop_55_untapered`
  (plain, loading door with danger stripes, personnel door + stair), 256 px per bay, side outlines cut
  so bays butt-join. Piece 4 (the corner) unused: corners are two straight segments by construction
  (the face is one straight run per building; neighbours' faces abut). Provenance: 2 lines appended.
- Combo: a live pitch redraws every chunk once the pitch has held 12 frames (`ChunkLift.stale`), so
  during the 1 s ease the roofs keep the old lift. Not filmed yet.
- Evidence (proof of draw, NOT yet the 32 px/m judgement): `it1_facade_block_edge_7ppm_tilt70_vs_tilt55.png`
  (window rows under the lifted roofs at a block's south edge; 70 shorter than 55, as geometry says),
  `it1_city_wide_14ppm_top_vs_tilt70.jpg`. frames.json written (2 entries).
- Gates: lint 15/15 (pre-commit, every commit). Unit: the schema change made `--changed` run the FULL
  suite: 1468 passed, 0 failed (66 s). New `tests/unit/test_chunk_lift.gd` (3 tests: flat view builds
  no lift, roofs last north to south, table heights/styles) 3/3, commit 522a6bc8. No mutation run yet.
- MILESTONE (evidence): the 32 px/m before/after, `it1_facades_32ppm_top_vs_tilt70.jpg` (`--bot=course`
  walks onto the hub's helipad block; frame 899): the faces read as brick buildings with windows and a
  shutter bay. THE PROBLEM IT SHOWS: at true heights (14-21 m) the roofs at 70 ride up 5-7.6 m over the
  whole north sidewalk, so Rivet and the arena barriers (actors canvas, above the world) draw ON the
  roof. Two levers, both next: (a) the height call: a shortened cut (`height_k` ~0.5: 7-10 m, lift
  2.5-3.8 m at 70, the sidewalk stays clear) - a data value; (b) occlusion (item 2).
- FRICTION: `--start=<area>` did not move the city hub's camera (identical frames for boulevard and
  alley); the arena hub's blocks sit under the dev panel. Next session: frame a block edge at 32 px/m
  by `--ppm=32` + a bot walk toward the bottom-left block, or the main boot city (`--seed=2`, Rivet at
  an intersection: corner blocks, no south face in frame at 32) - find a better framing first.
- FRICTION: `godot/check.mjs` on a `.gd` that names `Log` fails ("Identifier not found: Log", the -s
  run has no autoloads); the real run is fine (vehicles saw the same).
- The look_d4 print turns the brown brick into ink and cream (as every world texture): the face reads
  as dark window rows. Judge at 32-64 whether it needs a lighter cut (a paper-heavy re-tone).

Registry rules applied: depth-ordered-layered-art (one painter order per chunk: facade then roof, south
edge last; faces on the same canvas as roofs so the world stays one print), tiling-texture-acceptance
(bays cut inside the outlines so the seam is a pilaster, not a double ink line; a per-place hash picks
door bays only on the middle bay of about half the buildings, so no visible repeat along a street),
sprite-and-atlas-production (one strip per style, 3 cells, region draws, mipmapped import like the city
art), render-submission-economy (no new canvas items: faces go into the existing roofs-band quadrant
items; 3-5 extra rects per building), generative-artifact-gating (B sheets, the un-tapered keys, the
corner piece rejected per its note). Not yet read in full: concept-scene-parity, motion-quality-gating.

### DECISION
- [2026-11-06] DECISION city facades (n8 city): south faces are drawn on the world canvas in the
  roofs band (facade then roof per building, sorted by south edge), not as a band of their own under
  the actors: a front roof must cover the face behind it, and the actors canvas is above the whole
  world anyway. Consequence: an actor north of a building is NOT hidden by it yet (brief item 2,
  occlusion). Heights from `city_facades.json` (true heights, height_k 1); p70 draws the p55 strip
  squashed by the geometry until the 70 twins land.

### REQUESTs
- REQUEST to assets: facade_kit, 70, the 70 twin of facade_kit_55 (round 2021, parallel projection,
  the same three wall bays + corner, untapered), for the city's south faces at play pitch; today the
  55 wall is squashed to ~0.6 of its drawn height at 70.
- REQUEST to assets: facade_shop, 70, the 70 twin of facade_shop_55 (2021), same reason.
- REQUEST to assets: facade_tall, 55 + 70, a taller tenement wall bay set (5-6 storeys, same brick,
  same parallel projection, three bays) for the 17-21 m landmarks, which today stretch the 3-storey strip.
- REQUEST to assets: payphone, 70; crates, 70; lamp, 55 (a B or A; both lamp sheets are C/B) + 70;
  trash_can, 70; mailbox, 70; bench, 70: the props' 70 twins (barrier, dumpster, hydrant 70 exist).
- REQUEST to view: occlusion of the city's buildings (brief item 2). Actors are on the actors canvas
  above every roof, so a body north of a tall building draws over its roof. The city side can give
  `ChunkLift` a query (`occluder_at(ground_pos) -> Rect2` of the lifted face+roof covering a point);
  ask: does `PropOcclusion` take a city-side occluder provider, or shall I draw the silhouette cue
  myself (an ink outline of the hidden body over the roof)? I will build the provider either way.
- To vehicles (answering your journal's gap): the kerb-parked cars are the chunk draw list's
  `vehicle` class, drawn flat by `ChunkView` (this lane). I can give them a hook: under a tilt,
  ChunkLift asks a vehicles-owned function for a parked car's art per texture name (your p70 rotations)
  and draws it standing, in the props band. Tell me the function you want to own; until then they stay flat.

NEXT:
1. Film the same `--bot=course` frame 899 with `height_k` 0.5 and 0.7 (side by side with 1.0): pick the
   default for play visibility, record the owner call (true vs shortened, the still + exe line).
   Also 48 and 64 px/m (`--ppm=`) of the same spot.
2. Combo: film an engage; check the 12-frame settle redraw does not flash (chunks are released and
   re-sliced over a few frames: possibly holes). If it flashes, redraw in place instead.
3. Occlusion (item 2) per the view answer; payphone first for props (item 3): stand the props up from
   the library sheets (payphone_55 A from round 1920).
4. Check cross-quadrant order (a building straddling two 64 m quadrants draws in item order).

### 21:16 DECISION height_k 0.5 (default)
- Filmed `height_k` 1 vs 0.5, same `--bot=course` frame 899, tilt70, 32 px/m:
  `it1_height_k_1_vs_05_tilt70_32ppm.jpg`. At 0.5 the north sidewalk stays clear (Rivet and the
  barriers stand beside the roof edge, not on it); the faces become short brick strips (the helipad's
  is hidden by the block south of it). Default 0.5, true height one value away: an owner call (Calls
  for the owner: true height vs shortened cut; the still above; exe line
  `RTAI.exe res://dev/arena/arena.tscn -- --arena=city --bot=course --seed=2 --rigs --clean --view=tilt70`).
- Test updated (heights x 0.5), 3/3. The occlusion item (2) stays needed for the 17-21 m landmarks
  and for anyone walking in a roof's lift band.

NEXT (session 2, in order):
1. Full unit run + scenarios on this head; check `top` bit-identity (framemd5 of
   `--arena=city --bot=rivet --seed=2 --rigs`, `--quit-after 301`, vs main 8e9eeb78).
2. Occlusion: read view's answer to the REQUEST; build `ChunkLift.occluder_at()` either way.
3. Props stand up (payphone first: library payphone_55 A round 1920), then barriers, dumpsters,
   crates, hydrants, lamps (barrier/dumpster/hydrant have 70 twins: A).
4. Combo engage film (the settle redraw: holes?), 48/64 px/m close-ups, a 30-90 s set clip.

## Iteration 4 (2026-11-06 21:18-22:18, BUILD)

Read: JOURNAL, git log, the lane journals (view answered the occlusion REQUEST: PropOcclusion takes
no outside provider; the city draws its own cue in PropOcclusion's look, reading its public consts;
vehicles REQUESTs the kerb-parked cars hook into `ChunkView`, `VehicleParked` on n8-vehicles).
(Iterations 2-3 left no commits or journal lines: this session picks up from iteration 1's NEXT.)

- MILESTONE 877fc27d + follow-up: **building occlusion** (brief item 2). `CityOcclusion`
  (features/city/view/city_occlusion.gd), on the city's actors canvas at `roof_occluders`, made only
  when ChunkLift exists (a tilt), the view occludes and `city_facades.json` `occlude` is true (new
  key + schema; false = the old look, one value away). Each frame: every CutRig on the actors canvas,
  the resident chunks' buildings within 40 m; a body whose feet are north of a building's north edge
  and whose screen box (1.7 m upright: the cards stand, they are not foreshortened) meets the
  building's drawn area (ground rect grown up by its lift) is "behind" it.
  - First build redrew the building (ChunkLift.face + the roof texture) on the actors canvas over
    the body. FILMED and REJECTED: the redraw gets the actors' per-item print (look_d4_item), not the
    world's screen print, so the redrawn roof read lighter and lilac beside the world (cmp still in
    scratch, not kept) and it covered actor-canvas props lying in its area.
  - Built instead: a BackBufferCopy at the bottom of the actors canvas (z blood - 1) keeps the
    printed world before any actor draws; the node paints that copy (city_occlusion.gdshader,
    hint_screen_texture, nearest) back over only the body's patch (1.8 m wide: body + held weapon,
    cut to the building's drawn area), and its child inks the body there as PropOcclusion's
    silhouette + rim (its SILHOUETTE / RIM / SIL_W_M; widths scaled to the city's 32 px/m). Exact
    world pixels: no second print, no seam. Bodies in front whose box meets a hit building's area
    are lifted by PropOcclusion.FRONT_DZ, as the arena does.
  - Counts (Log at exit): `--arena=city --bot=course --seed=2 --rigs --clean --view=tilt70`
    1800 frames headless: 2002 body-frames hidden (Rivet + the riot cops along the helipad block's
    north sidewalk); `--bot=rivet` 900 frames: 0 (nobody walks a north sidewalk).
  - Known gaps: the baked crowd (multimesh peds) is not occluded (only rigs); a car card in front of
    the building inside a hidden body's patch would be painted over (patch is narrow; not seen yet);
    the arena city lets Rivet walk ONTO roofs (arena collision ignores the city), so on the course a
    body can stand inside a footprint: it is not counted (feet must be north of the north edge).
  - Test `test_city_occlusion.gd` (3: only buildings collected with the lift above them, the patch is
    the body inside the drawn area only, the silhouette at city scale).

- MILESTONE (evidence) occlusion at 32 px/m, same seed before (`occlude` false) / after:
  `gtai-masters/n8/city/it4_occlusion_32ppm_before_after_x3.png` (frames 640 and 690, x3) and
  `it4_occlusion_32ppm_before_after_full.jpg` (frame 690). Before: Rivet's legs and gun draw ON the
  union block's lifted roof. After: the roof covers everything below its north edge, the hidden legs
  read as the ink silhouette, head and chest stay above the edge. The frames differ ONLY in a
  ~60 x 15 px box at his feet (PIL bbox per frame 620-710): the rest is the world, bit-identical.
  Log: 144 body-frames hidden over 720 frames. Judged: it reads as "standing behind the block";
  the silhouette is a short dark bar at this size (legs only): fine at 32, judge at 48/64 next.
- MERGE 244e9fbd: n8-vehicles (VehicleParked, for its REQUEST to city); JOURNAL.md kept ours.
- The parked-car hand-off (vehicles' REQUEST): built in ChunkLift, not ChunkView (ChunkView stays at
  200 lines): `order()` (tilt only) leaves the carded parked cars out of the draw order and hands
  them to `VehicleParked.park(chunk.key(), cars)` as it orders the chunk; `make()` clears the registry;
  `count()` gives ChunkView the drawn length. Shadows keep drawing. Test in test_chunk_lift.gd.
  FILMED and found a REGRESSION: in `--arena=city` the flat cars vanished and NO card replaced them
  (only their shadows; `scratch/city/cmp_parked.png`): VehicleView exists only in the main city boot
  (boot/city_vehicle_world.gd), so in the arena nobody draws VehicleParked. DECISION: gated by
  `city_facades.json` `parked_cards` (default FALSE: no regression anywhere; the main city's cards
  are one value away). FRICTION: no way to ask VehicleParked whether a view draws it.
- REQUEST to vehicles: add `static var live: bool` (or `static func drawn() -> bool`) to
  VehicleParked, set true by VehicleView while it draws cards (false on exit). ChunkLift will AND it
  into the hand-off (`parked_cards` then defaults true): the main city gets cards, the arena city
  (no VehicleView) keeps its flat cars. Or put a VehicleView in the arena city.
