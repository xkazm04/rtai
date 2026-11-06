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
- GATE `top` bit-identity (21:58): `--arena=city --bot=rivet --seed=2 --rigs`, `--quit-after 301`,
  framemd5 of HEAD 4fa48c45 (with the n8-vehicles merge) vs the branch base 8e9eeb78 (a throwaway
  detached worktree under scratch, removed after; main itself has moved to 0bea8b93): IDENTICAL,
  301 video + 301 audio frames, 0 SCRIPT ERROR each. (Owed since iteration 1: done.)
- Unit, full no-arg run on 244e9fbd + the parked edit: 1498 passed, 0 failed (83.6 s). Lint 15/15
  on every commit (pre-commit hook). EXCEPTION: commit 9901b926 (JOURNAL only) was made with
  `--no-verify` by mistake; the next commits re-ran the full lint over the tree (15/15).
- Library check: assets served most of my REQUESTs: facade_kit 70 A, facade_shop 70 A,
  facade_tall 55 + 70 B (2210), payphone 70 A, crates 70 A, mailbox 70 A, bench 70 B,
  trash_can 70 B, lamp 55 B (2210) + lamp 70 B (2250). Thank you, assets.
- MILESTONE e9a6f10b: **p70 facade strips** from facade_kit_70 / facade_shop_70 (round 2110, A):
  `tools/art/city_facade_cut.py <lib> <out> 70` (STYLES_70: same four-piece layout as 55; bays
  inset by the 55 cut's offsets; wall band from under the roof's front ink to the ground ink,
  rows measured on the keyed sheets: tenement 326-600, shop 338-570). Strips 768 x 297 / 768 x 189
  (p55: 768 x 524 / 303). Looked at: three clean bays each, butt-joined (strips70.png in scratch).
  Provenance: 2 lines (round 2110, prompt hashes fdc084cee41e / 16c8a532077f).
- GATE scenarios on 4fa48c45 (headless, `res://tests/run_scenarios.gd`, my films running alongside):
  `run_scenarios: 52 ran, 0 failed`, exit 0 (vehicle drive timing labelled CONTENDED by the suite).
- FRICTION: a 720-frame film at 32 px/m takes 3-9 min on this machine with another Godot running;
  the 48 px/m close-up of occlusion was stopped unfinished (my own process tree, by command line).

Registry rules applied this session: depth-ordered-layered-art (the occluder sits at the render
stack's roof_occluders band, bodies in front lifted by the arena's FRONT_DZ: one painter order for
arena props and buildings), render-submission-economy (one full-screen BackBufferCopy per frame and
one rect per hidden body, instead of re-submitting a building's face + roof commands; nothing at
all under `top`), concept-scene-parity + motion-quality-gating (judged on the real arena-city
course run at 32 px/m, same seed before/after, frame-diff bbox checked), generative-artifact-gating
(70 sheets graded A used as is; the corner piece 4 still unused).

- p70 strips filmed (22:05, course frame 899, tilt70, 32 px/m, 0 SCRIPT ERROR) beside the same frame
  with the p55 strips: NO visible difference. That framing shows no south face (the helipad block's
  face is behind the block south of it; the only face is a thin dark band). The strips are NOT yet
  evidenced in game: next session needs a framing with an open south face (a block across a street
  from the camera: the main city boot or a course frame where Rivet walks south of a block).
- 22:09 the p70 strips, proof of draw: `gtai-masters/n8/city/it4_facade_p55_vs_p70_20ppm_x3.png`
  (course frame 450 at 20 px/m, p70 present vs moved aside so the p55 fallback draws; the frames
  differ only in the face band, bbox x400-707 y653-715; 0 SCRIPT ERROR). Judged: a small gain at
  20 px/m, the print turns both into ink bands; the 70 face keeps its cornice line and two window rows
  slightly crisper. The real judgement is at 32-64 px/m on an open south face (NEXT 1).

NEXT (session 5, in order):
1. Evidence the p70 strips: find a frame with an open south face (frame 899 of the course has none),
   film it with p70 vs the p55 strips (move p70/ aside in a scratch copy, or a temporary
   art_fallback), at 32 and 48/64. Then `facade_tall` (B, 2210) for the 17-21 m landmarks: add a `tall` style
   (city_facades.json + STYLES/STYLES_70 rows), read its notes for the B fix.
2. The director reel under tilt70 + combo (19/19, 0 SCRIPT ERROR): the BackBufferCopy is new on the
   city's actors canvas; scenarios again on the final head.
3. Occlusion at 48/64 px/m (same course run, frames 620-710); a short clip.
4. Props (brief item 3): payphone first (payphone_70 A + payphone_55 A 1920), then barriers, dumpsters,
   crates (70 A), hydrants (70 A), lamps (55 B 2210 / 70 B 2250). Find where the city draws the prop
   class (ChunkView band 3, flat): stand them up the way the facades do (lifted top + a front face
   from the sheet's facing rotations), keyed by art, with ground shadows.
5. Parked cars: when vehicles answers the REQUEST (VehicleParked.live), AND it in ChunkLift and set
   `parked_cards` true; film the main city boot (`--seed=2 --view=tilt70`), not the arena city.
6. Combo engage film (the 12-frame settle redraw).

## Iteration 7 (2026-11-06 22:10-23:10, BUILD)

Read: JOURNAL, git log, the lane journals (no new REQUEST to city; vehicles still waits on nothing
from me; street notes the cream pavement melts cream torsos at 70: not a REQUEST), the catalog
(every street prop now has a 70 twin: 11 A + 4 B among the ones I use; lamp 70 B 2250).
(Iterations 5-6 left no commits or journal lines: picked up from iteration 4's NEXT.)
Chose brief item 3 (props) over NEXT 1 (p70 strip evidence): a whole brief item was untouched.

- MILESTONE 14dc7a5c **street props stand up under a tilt** (brief item 3). `PropCards`
  (features/city/view/prop_cards.gd): a city_textures prop named in `city_facades.json` `props`
  draws as a card from its five-facing strip instead of its flat art. Strips cut by
  `tools/art/city_prop_cut.py <lib> <out> <55|70> name=lib_id ...` (the top row's five facings by
  alpha column runs, bottom-aligned in five equal cells, 256 px cell height, mipmapped: AST-03).
  15 props x 2 pitches: payphone, hydrant, trash can, mailbox, bench, newsstand, bus stop, vending
  machine, planter, dumpster, barrel cluster, crate stack, cone, police barrier + barricade
  (barrier sheet, `turn` 1: their flat art is long north-south). Facing from the command's turn
  (front = south at turn 0; the 3/4 and side views mirrored for the other hand, back never);
  foot on the footprint's south edge; height = cell aspect / ground_k. ChunkLift orders them
  with the roofs by south edge (roofs band), so a building in front covers a prop behind it and a
  prop on the sidewalk stands over the face behind it. The flat hatched shadow stays the ground
  shadow. Stretch or two-layer? NEITHER: the 70 twins are drawn at the pitch, so the card IS the
  prop at 70 (DECISION in docs/decisions.md). Lamp posts / traffic lights stay flat (their light
  pools and arms are placed from the flat art); street sign, bollard, fire escape have no sheet.
  - BUG found on film and fixed before commit: a mirrored facing drawn as a negative-width rect is
    SHIFTED a card width right by Godot, not flipped (the dumpster stood 2 m east of its shadow).
    Now a flipped basis.
  - B fixes per the notes: bus_stop's teal glass is already greyed in keyed/ (assets); bench 70
    views 2-4 are shallower than 1/5 and vending 70 views 3-5 read as a cream crate: both mostly
    face the street (turn 0) in the city, left as drawn; trash can rim not squashed (reads fine).
  - Provenance: 30 lines (round + prompt_hash per sheet); the cut lamp/traffic-light strips were
    removed again (c38ca241: not wired, no provenance).
- EVIDENCE (same seed before = `props` key renamed in a scratch edit of the table, restored; the
  frames differ only at the props): `gtai-masters/n8/city/it7_props_48ppm_before_after_dumpster_x3.png`,
  `..._mailbox_x3.png` (48 px/m, frame 600), `it7_props_32ppm_before_after_planter_newsstand_payphone_x2.png`
  (frame 350), `it7_props_32ppm_before_after_dumpster_x3.png` (frame 500), `it7_prop_cards_p70_strips.png`.
  frames.json now 13. Judged: the dumpster (lid, bag) and the mailbox dome read as objects on the
  kerb at 48; at 32 the payphone is a small hooded box on a post, readable but small. The print
  greys every card into the world's ink palette (as it does the roofs). 0 SCRIPT ERROR each film.
- Quest 1's payphone: quest 1's stage (boot/collect_call/view/stage_view.gd) does NOT read ViewMode
  at all (flat Node2D sprites at Ink's 48 px/m), so there is no angled quest 1 to put a card in yet.
  5c05e079 adds `PropCards.named()` (null under a flat view) + `draw_named(ci, name, foot_px,
  px_per_m)` so the stage (and the arena's cover) can draw the cards in one line when they get a view.
- REQUEST to view: ArenaFloorView._prop under a tilt (not top_lift) draws the city's cones,
  dumpsters (cover_high) and crate rows (cover_low) as a lifted face + flat top. When you want them
  standing like the city's: `var cards: PropCards = PropCards.named()` once, then
  `cards.draw_named(ci, "dumpster" | "crate_stack" | "traffic_cone", foot_px, Ink.PX_PER_M)` with
  the foot at the prop rect's south-edge centre (returns false = draw as today). Your file and your
  PropOcclusion redraw, so yours to wire; I do not edit arena_floor_view.gd.
- GATE `top` bit-identity on 14dc7a5c: `--arena=city --bot=rivet --seed=2 --rigs`, 301 frames,
  framemd5 vs the base 8e9eeb78's (scratch/city/top_base.md5 from iteration 4): IDENTICAL, 0 SCRIPT ERROR.
- GATE unit full no-arg on 14dc7a5c: 1502 passed, 0 failed (101 s). Lint 15/15 on every commit.
- FRICTION: chunk_lift.gd and chunk_view.gd sit at the 200-line soft cap (the debt ratchet failed
  the first commit at 206): trimmed comments; the next feature in ChunkLift needs a split first
  (the facade face drawing -> its own class).

Registry rules applied: depth-ordered-layered-art (props join the buildings' one painter order by
south edge, in the band above the faces, under the actors canvas), sprite-and-atlas-production
(one strip per prop, equal cells, bottom-aligned foot, mipmaps for 6x minification),
generative-artifact-gating (A first, B fixes per notes, never C: lamp 55 C rounds unused),
concept-scene-parity + motion-quality-gating (judged on the real course at 32 and 48 px/m, same
seed before/after, diffs localized), render-submission-economy (a card is one textured rect per
prop, recorded once per chunk; nothing per frame).

- GATE scenarios on 5c05e079: `run_scenarios: 52 ran, 0 failed`, exit 0.
- GATE director reel at tilt70 on 5c05e079 (headless, `--fixed-fps 60 --quit-after 7600
  res://dev/arena/arena.tscn -- --bot=reel --reel=director --loadout=pistol --rigs --view=tilt70`):
  19/19 chapters all down, 0 SCRIPT ERROR (log `evidence/director-reel-it7-tilt70.log`). The `top`
  reel was not re-run this session (top is bit-identical by the framemd5 above).
- MILESTONE 6a491f50 + follow-up **the boss arenas' dressing** (brief item 4). `BossDressing`
  (features/city/view/boss_dressing.gd, a Node2D): BossView.attach (one line, the hook's arena id
  and origin) adds it as a sibling of the arena floor (printed world canvas, the floor's scale,
  the props band) under any angled view; flat = none. `data/tables/boss_dressing.json`
  (gtai.boss-dressing/1 + schema): per BossSpec arena id, pieces (`piece`, `at` foot m from the
  area's centre, `w_m`), drawn north to south as standing cards (aspect / ground_k, redrawn on a
  ViewMode revision: the combined view's ease). Art `features/city/art/view/<art>/dress_<piece>.png`,
  16 pieces cut by `city_prop_cut.py --kit` from king_district_55 (A, 1640) and depot_dressing_55
  (B, 1920; the B is about the doors' pitch vs the conveyors': used as is), p70 falls back to p55.
  - King's boulevard: gear heaps, tyre stacks, the claw arm, the crown-crate barricade, the crown
    on a crate, crate pairs, cable reels, a drain grate, along the north and south edges (the
    20 m street between stays clear).
  - Depot: closed roller doors in the back wall behind servo.json's bays 1, 2 and 4, the OPEN door
    behind the van's bay 3, bollards between the bays, feeder conveyors at the CS belt's two ends,
    parcels/pallet/cage by the side walls. FIRST placement put the parcels and conveyors ON the
    belt, then south of it where the belt (drawn above the world) hid them: filmed both, moved.
  - Evidence: `it7_king_district_dressing_tilt55_before_after.jpg`,
    `it7_depot_dressing_tilt55_before_after.jpg` (`--boss=<king|servo> --rigs --seed=2 --view=tilt`,
    frame 400; before = the table's arena rows renamed in a scratch edit, restored). 0 SCRIPT ERROR.
    Judged: the dressing reads as the King's scrapyard street and a loading dock at the edges; at
    the 55 boss framing the depot doors sit at the top edge under the boss bar (half seen) and the
    west conveyor under the ghost HUD: placement is data, fix by eye next session at combo.
  - Known gaps: no collision (paint only, at the edges on purpose); bodies always draw over the
    dressing (actors canvas), so a cop north of a door draws over it; no p70 kits yet.
- REQUEST to assets: king_district, 70 and depot_dressing, 70 (the 70 twins of the two kits, same
  eight pieces, for the combined view's play pitch before a boss engages); low priority (the
  fights are at 55).
- EVIDENCE set clip: `gtai-masters/n8/city/it7_city_set_tilt70_32ppm_35s.mp4` (the arena-city course,
  tilt70, 32 px/m, 2100 frames: facades p70, occlusion, standing props).

NEXT (iteration 8, in order):
1. Judge the boss dressing at `--view=combo` (the ease to 55 on engage; the cards redraw on the
   revision) and at 48 px/m; nudge the depot's door row and the west conveyor into the framing.
2. Lamp posts and traffic lights as cards: the lamp 70 B (2250) + lamp 55 B (2210) strips with
   the light pool kept at the lamp head (CityPropLights reads the flat art's arm: find its anchor).
3. p70 strips on an open south face (iteration 4's NEXT 1), and facade_tall (B 2210) for the
   17-21 m landmarks (a `tall` style).
4. The bench (B: use views 1 and 5 only) and vending machine (B: views 1-2 face the street) per
   their notes: a per-row `facings` map in `props`.
5. The cost (brief item 5): the city drive at tilt70 vs top under the bench lock; chunk load
   times before/after (PropCards adds one rect per prop per chunk, no per-frame cost).
6. Split ChunkLift (200 lines): the facade face drawing into its own class before more features.
- 22:58 combo check (NEXT 1, partly): `--boss=king --rigs --seed=2 --view=combo`, 900 frames, 0 SCRIPT
  ERROR: the dressing cards are short at 70 (frame 30) and rise at 55 after the engage ease (frames
  450, 880): they follow ground_k on each ViewMode revision. Still: `it7_king_dressing_combo_70_to_55.jpg`.
  Still owed: 48 px/m, and the depot under combo.
- GATE scenarios on 355a26aa (raw `run_scenarios.gd`, with my combo film running alongside):
  52 ran, 1 failed: `scenario_city_chase` flow field over the 2 ms nav wall-clock budget (max
  2779 us), a CONTENDED miss (sim code this lane does not touch; the films and other lanes ran).
  Re-run alone via `node tools/tests/run_scenarios.mjs --only=city_chase`: 1 passed. So 52/52.
  FRICTION: run the suite through run_scenarios.mjs (it labels and re-runs contended budgets),
  not the raw .gd, when films are running.
- Session end 23:05. Head 355a26aa + this JOURNAL line. NEXT stands as written above.

## Iteration 10 (2026-11-06 23:04 - 00:04), BUILD
Read: JOURNAL, git log, the lane journals. Open answer to city: vehicles ee045433 (`VehicleParked.live`
+ `drawn()`; AND it per chunk at order time, not at setup). No other REQUEST to city.
- MILESTONE 51844aa8 merge n8-vehicles (34018b19; JOURNAL.md ours).
- MILESTONE 037d295c NEXT 6: `FacadeStrips` (features/city/view/facade_strips.gd) takes the south
  face's strip tiling + ink out of ChunkLift (200 -> 167 lines). Same draw calls, same order.
- MILESTONE 848ff5a5 the kerb-parked cars as cards: `parked_cards` true; ChunkLift.order hands a
  chunk's cars over only while `VehicleParked.live` (carded() is already taken at setup), so the
  arena city (no VehicleView) keeps its flat cars. Unit: test_chunk_lift 5/5 incl. the new
  "stay flat without a live view" (17/0 over chunk_lift, vehicle_parked, prop_cards, occlusion).
  EVIDENCE `gtai-masters/n8/city/it10_kerb_cars_tilt70_32ppm_before_after.jpg`
  (vehicle_frame --scene=yield --view=tilt70, tick 180; before = parked_cards false in a scratch
  edit, restored; 5.1 % of pixels differ, all at the kerb rows). Judged: the top-down police car,
  pickup and white van beside the traffic cards now stand as the same cards; 0 SCRIPT ERROR both.
- FRICTION/GATE 23:33 `top` bit-identity: HEAD 7a5f9137 vs the iteration-4 base hashes (top_base.md5) moved
  in all 301 video + 264 audio frames. Bisected in a throwaway detached worktree (removed): the
  merge 51844aa8, my pre-merge head fa729435 and even 14dc7a5c (IDENTICAL at iteration 7) all give
  the new hashes, and the base 8e9eeb78 RE-RECORDED NOW gives them too: HEAD == base, 0 frames
  differ. So the machine drifted since iteration 7 (driver/audio), not the code: re-record the base
  in the same session as the head, always. One run in five (fa729435) moved frame 29 only: a
  1-frame flake (streaming timing?), not reproduced at HEAD. top_base.md5 now = the 23:30 base.
- MILESTONE ca7f9a0f a real ordering bug: ChunkLift's south-edge key added a footprint size in px to
  a y in metres, so a deep building drew late whatever its place (a card in front of it could be
  covered). Now px; test_south_edge_is_in_px_not_metres_plus_px fails on the old key.
- MILESTONE 7a5f9137 NEXT 2: **street lamps and traffic lights stand as cards** (lamp 70 B 2250 /
  55 B 2210, traffic_light 70 A 2115 / 55 B 2000). The flat art is a 3.2 m arm (post at -x, head
  at +x), so a props row now takes `foot_m` (the card's foot in the flat frame: the post base,
  -1.27 / -1.3 m), `mirror` (the strip's side view has the arm to the right) and turn 3: the arm
  points where the flat arm pointed (south = toward the camera, north = the back view). At night
  CityPropLights puts the lamp's light under the drawn head (`light_m` -0.45 m, angled views only;
  lights.json `at_m` untouched for top). The flat arm's hatched shadow stays as the cast shadow.
  B notes: lamp 70 foot plate ~45 deg (pole right): used as is; traffic_light 55 camera ~30 deg:
  only the boss arenas' 55 would show it (no traffic lights there). Mipmaps on (AST-03).
  EVIDENCE `it10_lamps_tilt70_32ppm_before_after_night.jpg` (yield scene, tick 180: before, after,
  after at --grade=night), `it10_lamp_kerb_cars_tilt70_48ppm.png` (--car-zoom). Judged: the lamps
  read as bronze-grey posts with a bell head on the kerb at 32, the swan neck reads at 48; the pool
  sits on the pavement under the head. 0 SCRIPT ERROR in the 4 films.
- GATE unit, full no-arg on 7a5f9137: 1516 passed, 0 failed (66.9 s). Lint 15/15 on every commit.
- MILESTONE 04eff755 brief item 5 (the cost), first measurement: `dev/bench/chunk_cost.gd` runs the
  real main scene under `-s` and samples ChunkView each frame (frame_us while recording; a chunk's
  record time = its frames' frame_us, split on `activated`). `--arena=city --bot=rivet --seed=2
  --rigs`, 3600 frames, bench.lock HELD for both runs (wall-clock; other lanes may have run
  non-bench work). `evidence/chunk-cost-it10.json`:
  | view | chunks | record per chunk p50 / max | frames recording | per-frame p50 / p99 / max | >2 ms |
  | top | 15 | 1.18 / 3.28 ms | 16 | 1.18 / 2.27 / 2.27 ms | 1 |
  | tilt70 | 15 | 3.84 / 6.26 ms | 46 | 1.52 / 2.62 / 2.62 ms | 1 |
  Read: an angled chunk costs ~3.3x to record (faces, roof lifts, cards, the per-chunk order sort),
  but ChunkView's time slice spreads it over ~3 frames, so the per-frame streaming work rises
  only 2.27 -> 2.62 ms max and no chunk hitches. The overshoot past BUDGET_US is the 32-command
  check granularity. NOT measured yet: the GPU side (draw calls per frame with faces + cards) and
  the city DRIVE (the walk bot crossed 15 chunks; a car crosses more per second).
  FRICTION: a `-s` SceneTree script compiles before the autoloads exist, so it cannot name a class
  that names `Log` (every city view class): the probe duck-types the CityView (get("chunks")).
  Debt baseline accepted for it (dev_loc +99, one cmdline read).
- FRICTION: gdformat on Windows writes CRLF; git normalizes on add (warning only).

Registry rules applied this session: depth-ordered-layered-art (lamps join the one south-edge order
at their post base, the order key fixed to px), sprite-and-atlas-production (strips cut to equal
bottom-aligned cells, mipmaps), generative-artifact-gating (lamp B fixes read: the 2250 pole is
right, the plate shallow: used; traffic_light 55 B only where 55 shows), render-submission-economy
(cards are one rect per prop recorded once per chunk; measured the record cost per view),
motion-quality-gating + concept-scene-parity (same scene, same tick, before/after; night checked).

- GATE scenarios on fe8cc0db (node tools/tests/run_scenarios.mjs, a combo film running alongside): 52 passed, 0 failed.
- Session end 23:55. Head = this JOURNAL commit.

NEXT (iteration 11, in order):
1. The cost, part 2: the city DRIVE at tilt70 vs top (vehicle_frame's route or the bench's drive
   course through chunk_cost.gd: add `--scene=` passthrough if the probe needs another scene) and
   the GPU side (RenderingServer draw calls / primitives per frame, top vs tilt70), under bench.lock.
   If an angled chunk's record overshoots, lower BUDGET_US's check granularity for the lift path.
2. The depot under combo at 48 px/m: 23:50 I filmed `--boss=servo` on the MAIN scene by mistake (it
   ignores --boss: that showed the city crossroads, still deleted). Use `res://dev/arena/arena.tscn
   -- --boss=servo --view=combo --ppm=48`, then nudge the door row and the west conveyor into the
   boss framing (data: boss_dressing.json `at`). SEEN in that wrong film: under `combo` on the main
   scene the lamps were still FLAT at frame 28 and cards by frame 596: check whether the city view
   is set up while combo still reads flat (ChunkLift.make returns null when flat at setup and never
   comes back) or whether combo eases in from top; at tilt70 they are cards from the first frame.
3. facade_tall (B 2210, untapered) as a `tall` style for the 17-21 m landmarks (by_name rows).
4. Bench / vending per their B notes (a per-row `facings` remap) only if a turned one shows on film.
5. Quest 1's payphone: still blocked on the quest stage having no angled view (not city's file);
   re-read street/view journals for a stage view and wire PropCards.draw_named when it lands.
