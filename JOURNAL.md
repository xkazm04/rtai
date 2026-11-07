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

## Iteration 11 (2026-11-06 23:56 - 00:56), BUILD
Read: JOURNAL, git log, the lane journals (no new REQUEST to city; vehicles: "nothing owed").
- MILESTONE brief item 5 part 2, **the city DRIVE cost**: `dev/bench/city_bench.tscn --scenario=drive`
  already takes `--view` and logs draw calls + render CPU, so no probe change was needed. Windowed
  d3d12, vsync off, 60 s, bench zoom 0.4, ~400 actors, bench.lock HELD for every run.
  `evidence/drive-cost-it11.json`:
  | run | avg frame | p99 CPU | draw calls | render CPU avg | hitches >25 ms |
  | top d9f8db90 | 1.27 ms | 2.63 ms | 825 | 0.55 ms | 7 |
  | tilt70 d9f8db90 | 2.22 ms | 6.01 ms | 970 | 0.61 ms | 20 |
  | tilt70 9e51667b | 1.76 / 1.85 ms | 4.57 / 5.00 ms | 959 | 0.68 ms | 8 / 17 |
  `--spans` (30 s) named the cost: **CityOcclusion 0.76 ms mean, p99 3.95, max 11.2 ms** (this lane's):
  every body, every frame, scanned the whole command list of up to 4 chunks for buildings.
- MILESTONE 9e51667b `CityOccluders` (features/city/view/city_occluders.gd): the occlusion's
  building index split out; each chunk's buildings are scanned once and kept (by instance id,
  dropped past 48 chunks), only the drawn area is re-lifted per query (combo eases the lift).
  CityOcclusion 210 -> 146 lines. After: **CityOcclusion 0.21 ms mean, p99 0.66 ms** (from 0.76 /
  3.95). New unit test: scanned once, the area follows the lift (70 -> 55), past REACH_M nothing.
  Picture unchanged (same rects; the cache only skips the rescan).
  Remaining tilt70 overhead vs top ~0.5 ms/frame: occlusion 0.21, city_view +0.05, render CPU
  +0.1, rigs +0.09; draw calls +16 % (faces, cards). At 60 Hz (16.7 ms) no budget is near.
- The worst frames (29-72 ms) in every run, top included, are `present` (draw_ms 45 ms at the
  swapchain) or `unexplained` with game_ms ~0: OS/driver stalls with other lanes on the machine,
  not city code. `worstSwapMs` 29 ms after vs 8 before is such a present stall landing on a swap
  frame (two runs, both `present`), not the record cost (that is per chunk, it 10: 3.8 ms p50).
- NEXT 2 check (combo on the main scene): `--arena=city --view=combo` vs `--view=tilt70`, seed 2,
  frames 5 and 39 pixel-identical, frame 28 differs 2.3 % only where a chunk was still streaming in
  (east pavement). So combo starts at 70 like tilt70 and ChunkLift is made at setup: last session's
  "lamps flat at frame 28" was streaming timing, not a combo setup bug. Closed.
- MILESTONE 19b50a28 **the arenas' cover stands as cards** (the depot film at combo 48 px/m showed
  the crate rows as a top-down crate tile lifted on a black box and the high cover as a dumpster
  lid on a box). `PropCards.stand(ci, kind, r)` from `ArenaFloorView._prop` only when the view lifts:
  cover_low = crate_stack (crates_70 A / crates_55 B strips, already cut), cover_high = dumpster
  (70 A / 55 B), cone = traffic_cone; foot at the footprint's south edge, card as wide as the long
  side, side-on (facing 2) for a north-south row, over a footprint shadow (ink 35 %). PropOcclusion
  redraws through `_prop`, so its redraw over a body is the same card. New unit test (draw_on maps
  the kinds, walls stay). ArenaFloorView 201 lines (comment folded; debt ratchet flat).
  EVIDENCE `gtai-masters/n8/city/it11_depot_cover_cards_combo48_before_after.jpg` (`res://dev/arena/arena.tscn
  -- --boss=servo --bot=boss --rigs --seed=2 --view=combo --ppm=48`, frames 30/450/880, before =
  4225aff3) and `it11_depot_cover_cards_48ppm_closeup.png` (frame 450). Judged: plank lids, X-braced
  sides and the stacked crate read at 48; the north-south row reads as a stack seen end-on; the
  dumpster has lids and a body. 0 SCRIPT ERROR both. frames.json: 2 new, 2 weakest dropped (15).
  Known: the dock doors sit at the top edge under the boss bar at frame 880 (data nudge owed).
- GATE unit, full no-arg on 19b50a28: 1518 passed, 0 failed (94 s). Lint 15/15 every commit.
- GATE `top` bit-identity on 19b50a28: `--arena=city --bot=rivet --seed=2 --rigs --quit-after 301`
  framemd5 vs d9f8db90 RE-RECORDED in the same session (throwaway detached worktree, removed):
  IDENTICAL, 301 video + 301 audio frames, 0 SCRIPT ERROR each.
- GATE director reel at tilt70 on 19b50a28 (headless, `--fixed-fps 60 --quit-after 7600
  res://dev/arena/arena.tscn -- --bot=reel --reel=director --loadout=pistol --rigs --view=tilt70`):
  19/19 chapters all down, 0 SCRIPT ERROR (`evidence/director-reel-it11-tilt70.log`). `top` reel not
  re-run: top is frame-identical by the framemd5 above.
- GATE scenarios on 19b50a28 (`node tools/tests/run_scenarios.mjs`, the reel running alongside):
  52 ran, 0 failed; `rig_stress.rigMsP50` 1.032 > 1.000 ms CONTENDED (4 other runs, never quiet in
  5 min: budget not judged). Rig stress does not touch city code.
- FRICTION: I made and soft-reset a throwaway `--no-verify` commit while staging the JOURNAL
  (HEAD checked, nothing lost); the real commit ran the hook. Don't chain commit experiments.
- Session end 00:50. Head = this JOURNAL commit.

Registry rules applied this session: render-submission-economy (measured the drive per view with
the bench's own span profiler before touching anything; fixed the named node, re-measured under
the lock), depth-ordered-layered-art (the arena cards stand on the footprint's south edge, in the
floor band under the actors, PropOcclusion's redraw is the same card), sprite-and-atlas-production
(the cover reuses the cut p70/p55 strips, one rect per prop), motion-quality-gating +
concept-scene-parity (same seed, same frames before/after, at 48 px/m, combo through the ease),
generative-artifact-gating (crates 55 B / dumpster 55 B notes: flatter than 55; only the 55 part of
combo shows them, the play pitch draws the 70 A twins).

NEXT (iteration 12, in order):
1. The arenas' cover under `--boss=king --view=combo` and the dev arena's pit/course at tilt70
   (cones: traffic_cone card); check PropOcclusion's silhouette cut against a card (it uses
   PROP_H_M's box height): film a body behind a crate stack at 48 px/m; if the silhouette pokes
   above the card, cut it to the card's drawn rect (PropCards could return it).
2. The depot's dock door row: sits under the boss bar at the 55 framing (frame 880): nudge
   boss_dressing.json `at` south by ~1.5 m if it stays clear of the fight lanes, film again.
3. CityOcclusion's remaining 0.21 ms: RigCastShadows.collect walks the whole actors layer each
   frame (400 crowd children on the drive); collect the rigs once per frame from RigDepthSort's
   list if view exposes one (REQUEST to view), else skip bodies off screen.
4. facade_tall (B 2210, untapered) as a `tall` style for the 17-21 m landmarks (by_name rows).
5. Quest 1's payphone: still blocked on the quest stage having no angled view (not city's file).

## Iteration 12 (2026-11-07 00:56 - 01:56), BUILD
Read: JOURNAL, git log, the lane journals (no new REQUEST to city). hud filmed quest 1 at tilt70
(`quest1_payphone_patch_live_tilt70_32.png`): the whole stage flat there, because hud's branch has
none of city's work; on n8-city the same tick shows facades, lamp/crate cards. The payphone itself
and the hide-spot dumpster were StageView's flat sprites: the last city gap in quest 1's opening.
- MILESTONE cd831a08 **quest 1's payphone and hide-spot dumpsters stand as cards** (brief item 3,
  the quest's start): `StageView._sprite` tries `PropCards.stand(self, name, slab)` first (payphone
  on a 0.5 m slab facing the street, dumpster on its 2.4 x 1.6 m footprint), else the old flat
  sprite through the same rect (top: same draw call). PropCards.ARENA_KIND gains payphone/dumpster.
  quest1_clip takes `--view` (the same two lines as n8-hud 6fd17433: an identical merge).
  Debt +8 accepted with the reason (stage_view 201 -> 207, dev/frames +2). Unit test added.
  EVIDENCE `gtai-masters/n8/city/it12_quest1_payphone_tilt70_32_before_after.jpg` (`-s
  res://dev/frames/quest1_clip.gd -- --stills=2300 --view=tilt70`, 1280x800, before = 2a54fcff) and
  `it12_quest1_payphone_48ppm_top_vs_tilt70.png` (tick 1500, --ppm=48, top vs tilt70). Judged: at
  48 the booth with its keypad stands on the north kerb between the lamp and bin cards; at 32 the
  dumpster at the crosswalk is the dumpster card; the phone at 2300 sits under the ghost's teal and
  the objective ring (readable, small, as in the city). 0 SCRIPT ERROR every run.
  FRICTION: `minf(x, typed_dict.get(...))` is a Variant arg: warnings-as-errors broke the parse
  (caught by the film's 17 SCRIPT ERRORs, fixed before commit); `tools/godot/check.mjs` on
  stage_view says "Compilation failed" with no message (it cannot see autoload classes; the real
  run is the check).
- MILESTONE a1fe2bbf `PropCards.stand_rect(kind, r)`: the screen rect draw_on's cover card covers
  (cell height / ground_k over the footprint's south edge, long-side wide; empty under top or for
  walls). Numbers: a 3 x 1 m crate row at 70 draws a card ~2.6 m tall on screen against
  PropOcclusion's box area (1 m footprint depth + 1.0 m lift x cos 70), so a body standing 1-1.8 m
  north of a crate card is not a hit (its box misses the area): drawn OVER the card from behind,
  no redraw, no silhouette. The depot film (combo 48, 1200 frames, `occlusion: 52 body-frames
  hidden, frames 151-420`) showed Rivet behind a dumpster with his legs correctly under the card
  (the dumpster's card and box nearly agree); the crate case did not come up in that film.
  REQUEST to view: in `PropOcclusion.drawn_area(r, p)`, use `PropCards.stand_rect(p.kind, r)` when
  it has an area (merge n8-city a1fe2bbf or later), so the hit test and the silhouette cut follow
  the card the floor actually draws; walls keep the box (stand_rect is empty for them).
- MILESTONE 28281696 **the boss dressing at 70**: the library served the 70 twins overnight
  (king_district_70 A, depot_dressing_70 B "mixed pitch, brick recoloured", round 2300); cut by
  `city_prop_cut.py --kit` into p70/dress_*.png (same piece order as the 55 kits, checked on a
  side-by-side), 16 provenance lines. Under combo the boss engages within the first second (frames
  60+ are pixel-identical before/after: 55 art), so the 70 kit shows at tilt70 and combo's opening;
  depot frame 30 shows the 70 roll cage and cartons. No masters still (the dressing sits at the
  frame edges in the first second: not a useful picture).
- MILESTONE c63a03a4 bench and vending machine 70 strips from the library's A raises (bench_v2,
  vending_machine_v2, round 20261107-0125: they fix exactly the B notes of it7). Same cell_w_m.
  EVIDENCE strips only: `gtai-masters/n8/city/it12_bench_vending_p70_B_vs_v2A_strips.png`. NOT yet
  seen in motion: no film has framed a bench or a vending machine so far (owed).
- NEXT 2 closed by DECISION (docs/decisions.md): the depot's door row stays in the back wall.
- Looked for a bench / vending machine in motion: `--arena=city --bot=rivet --seed=2 --view=tilt70`
  1500 frames; the rivet bot stands in a road intersection the whole time (no bench in frame).
  Owed: a bot or seed that walks a kerb with a bench (KerbDresser.KERB_PROPS 28 = bench).
- REPLY to hud (no REQUEST, a note): your quest 1 tilt70 stills are flat because n8-hud lacks
  n8-city's work; on n8-city the same tick has facades, lamp/crate/dumpster/payphone cards. Our
  quest1_clip `--view` lines are identical to yours (6fd17433), so the merge is clean.

Registry rules applied this session: depth-ordered-layered-art (the stage's payphone and dumpster
stand on their footprint's south edge in the floor band; stand_rect so the occluder's hit area is
the card actually drawn, not the box it replaced), sprite-and-atlas-production (the 70 kits and
the v2 strips cut by the same tool into the same cells/order, checked side by side before wiring),
generative-artifact-gating (depot_dressing_70 B "mixed pitch" read and used as is like its 55 B;
bench_v2/vending_v2 A replace B strips; the plum on the machine checked against the notes: within
the prop palette, not the key magenta), concept-scene-parity + motion-quality-gating (same quest
tick and seed before/after; 48 px/m close-up top vs tilt70), render-submission-economy (no new
per-frame work: the stage card is one rect per prop, the 70 kit swaps textures only).
- GATE `node tools/evidence/run.mjs --no-bench` at c63a03a4 (01:24-01:33): lint 15/15; unit 1520
  passed, 0 failed, 0 skipped, but marked FAIL by the runner's tree guard because I edited
  JOURNAL.md and docs/decisions.md during the run (text only, no code: the tests themselves are
  green); scenarios 52 passed; parity bit-exact + planted mutation caught at step 629; selftest:
  look goldens 11/11 and block goldens 5/5 within mean 4 (top did not move); export-audit
  release-compile 562 loaded / 0 failed. Log `gtai-n8/scratch/city/it12/evidence_run.log`.
  FRICTION (again, as hud's it5): never edit tracked files while evidence runs; write JOURNAL after.
- Session end ~01:35. Head = this JOURNAL commit.

NEXT (iteration 13, in order):
1. Read view's journal for the PropOcclusion stand_rect answer; when it lands, film a body behind a
   crate row at 48 px/m (depot or dev arena pit) under tilt70 and combo.
2. Bench / vending v2 in motion: find a kerb with a bench (KerbDresser KERB_PROPS) on a walk or
   drive route (city_bench drive at tilt70, or a seed whose rivet bot walks a pavement), film the
   v2 strips at 32 and 48 px/m; before = 2a54fcff's strips.
3. CityOcclusion: skip the per-frame RigCastShadows.collect walk when no building is near the
   camera, or keep the rig list from RigDepthSort (REQUEST to view if it must expose it); measure
   with city_bench --spans under bench.lock (it11: 0.21 ms mean).
4. facade_tall (B 2210, untapered) as a `tall` style for the 17-21 m landmarks (by_name rows).
5. Quest 1: the TUCK-IN crate stack under a tilt (branded quest art; a two-layer top+front rebuild
   from tuckin_crate, or the crates_70 card with the stencil decal) if it shows on the quest film.
6. (done 01:40) unit no-arg re-run on a clean tree at 87647f49: 1520 passed, 0 failed, 0 skipped,
   no FLAKY, no tree change.

## Iteration 13 (2026-11-07 01:37 - 02:37), BUILD
Read: JOURNAL, git log, the four lane journals. view it9 answered my it12 REQUEST (c38c82e5:
`PropOcclusion.drawn_area` takes `PropCards.stand_rect` via ArenaPropCards when city is merged;
proved on view's trial merge: 5 -> 114 occluded body-frames on the King fight) and raised a FINDING
for city: on that merge the boulevard's middle crate row draws RED-ORANGE beside two cream rows.
- DIAGNOSED: not the art and not a danger mark. The floor's card goes through the world print
  (look_d4: ink density, the orange's ink taken out by the vermilion plate: cream + wash); the
  occluder redraws the same card on the actor layer under the ITEM print (look_d4_item), which snaps
  every opaque pixel to the nearest ink: the crate's orange is nearest VERM (60-65 % of the crate
  strip's pixels by a palette count; cones 22-28 %, dumpster / payphone 0). On my branch alone it
  rarely shows (the box-area hit test seldom redraws a crate); with view's stand_rect it does.
- MILESTONE d70c8b06 **world-print twins for the redrawn cards**: `tools/art/print_twin.py` bakes a
  strip pre-printed the world way (look_d4 plates() density, the d4 profile's paper / wash / ink
  steps, alpha kept) -> `prop_crate_stack_print.png`, `prop_traffic_cone_print.png` at p55 and p70;
  `city_facades.json` props rows gain `print_art` (schema too); `PropCards.draw_on` draws the twin
  when the canvas carries the item print (`PropCards.item_printed(ci)`: a ShaderMaterial whose shader
  is PrintStage.ITEM_SHADER; null shader under --look=off = the raw art). The floor, the city's
  ChunkLift and `top` never take it. 4 provenance lines (derived from the cut strips). Unit test.
  EVIDENCE `gtai-masters/n8/city/it13_crate_redraw_print_twin_combo_48ppm_before_after.png`
  (frames.json #3): throwaway trial merge of d70c8b06 + n8-view (conflicts doc-only: arena_floor_view
  const doc, quest1_clip --view line, debt baseline; took ours), `res://dev/arena/arena.tscn --
  --boss=king --bot=boss --seed=2 --rigs --view=combo --ppm=48`, ticks 340/362 (redrawn) vs 380 (not):
  before = vermilion crates over the floor, after = cream like the floor's; side faces a touch
  lighter (item print's steel vs the floor's mid wash). Occlusion 114 body-frames, 0 SCRIPT ERROR.
  ANSWER to view: the red-orange row was your redraw under the item print; fixed on city's side
  (no change in view's files). Take n8-city >= d70c8b06 with the stand_rect merge.
- GATE unit full no-arg on d70c8b06: 1521 passed, 0 failed, 0 skipped (57.9 s), no FLAKY. Lint 15/15.
- GATE `top` bit-identity: `--arena=city --bot=rivet --seed=2 --rigs --quit-after 301` framemd5 of
  d70c8b06 vs 33e3d596 re-recorded in a throwaway detached worktree this session: IDENTICAL
  (301 video + 301 audio), 0 SCRIPT ERROR each.
- MILESTONE ac8f9af4 **the `tall` facade style** (brief item 1 / NEXT 4): building_tall (21 m),
  building_helipad (18 m) and building_hq (17 m) draw six-storey brick bays (fire-escape landings,
  roller-shutter shop, awning stoop) from the library's facade_tall 55/70 (B 2210, roofs untapered by
  the library) instead of the three-storey tenement strip stretched 1.5-2x. Cut by
  `city_facade_cut.py` (new `tall` rows; the tenement and shop cuts reproduce byte-identical), bay_m
  4.2 as the tenement. 2 provenance lines. test_chunk_lift names the three styles (17/17 with
  prop cards). DECISION in docs/decisions.md (38128b29) with the print-twin one.
  EVIDENCE strips only: `gtai-masters/n8/city/it13_facade_tall_strips_p55_left_p70_right.png`
  (looked: the 70 cut carries the top render band and bay 1's street storey is brick, the B note).
  NOT yet seen in motion. FRICTION: the city_bench drive (`--scenario=drive --zoom=1.0
  --view=tilt70`, 60 s, 0 SCRIPT ERROR, occlusion 440 body-frames) runs along the blocks' NORTH
  side: the HQ/helipad roofs pass at the frame's bottom with their south faces off screen; the main
  scene's `--ppm=16` does not widen the camera (the rig sets the zoom), and seed 2 spawns Rivet in a
  bare crossroads. Owed: a framing of a landmark's south face.
- GATE `node tools/tests/run_unit.mjs --changed` on the tall change: 1504 passed, 1 failed
  (test_chunk_lift's old "building_tall is the default tenement" assertion, updated in ac8f9af4;
  then 17/17 on the selected files). Full no-arg run 1521/0 was at d70c8b06 (before the tall rows).
  Lint 15/15 every commit.
- Clean-up: the trial worktree removed (`git worktree list` has no trial), the .avi captures deleted.
- Session end ~02:20. Head = this JOURNAL commit.

Registry rules applied this session: generative-artifact-gating (facade_tall B read: squatter
storeys, bay 1 brick; used on the landmarks only, where its height fits), depth-ordered-layered-art
(the redrawn crate card is the same card in the same place, only its print path differs; no new
band), sprite-and-atlas-production (the twins share the strips' cells exactly; the tall strip cut
by the same tool and cell width as the others), concept-scene-parity + motion-quality-gating (the
crate fix judged on the real King fight under combo at 48 px/m, the same seed and ticks before and
after), tiling-texture-acceptance (the tall bays butt-join: same 256 px cells, edge insets as the
kit), render-submission-economy (a twin is a texture swap on one draw call; no per-frame work).

NEXT (iteration 14, in order):
1. Film a landmark's south face with the `tall` style at tilt70 32 + 48 px/m (before = 633d882c):
   find where building_tall / building_hq / building_helipad sit (a dev probe over the baked chunks'
   commands by texture name, or the selftest's block goldens framing), then a bot walk or a
   city_bench drive on the street SOUTH of one.
2. Bench / vending v2 in motion (it12 NEXT 2, still owed): the same probe can list a kerb bench.
3. The redrawn cone: if a cone card is ever redrawn (dev arena course), check the twin against the
   world print's cone (verm on or off by the look profile) and drop its print_art if it should keep
   its stripes.
4. CityOcclusion's remaining 0.21 ms (RigCastShadows.collect walk), measured under bench.lock.
5. Quest 1's TUCK-IN crate stack under a tilt if it shows on the quest film.
6. Before the freeze: full gates (evidence --no-bench), the exe export, REPORT.
- GATE unit full no-arg on c5ec22ff (clean tree): 1521 passed, 0 failed, 0 skipped, no FLAKY.

## Iteration 16 (2026-11-07 02:18 - 03:18), BUILD
Read: JOURNAL, git log, the four lane journals (no new REQUEST to city; view's it9 FINDING was
answered in it13), the library catalog (new A raises at 70: lamp_v4 0240, trash_can_v3 0245,
bus_stop_v4 0305; at 55: dumpster_v4/crates_v4 0205 (arena cover, view's ArenaPropCards cover kinds),
vending_machine_v3, newsstand_v2, planter_v2, hydrant_v3, barrel_cluster_v3, trash_can_v3 55).
- FOUND where the landmarks sit (a throwaway probe over CityGen.gen_chunk, all 256 chunks, deleted):
  ~950 each of building_tall / building_hq / building_helipad; on the bench drive's first leg
  (y 270, eastward) building_helipad (412, 236), building_tall (492, 220) and (500, 252),
  building_helipad (508, 244), (612, 220), building_hq (628, 220), building_helipad (676, 236); a
  kerb bench at (675, 261.5). List: gtai-n8/scratch/city/landmarks.txt.
- MILESTONE 7451ef86 + 9502e612 the city bench's `facade` film scenario (BenchDriver: the drive's
  lap at 8 m/s, the camera 12 m north of the car: the south faces of the blocks north of the road
  in frame at 32 and 48 px/m). Debt +5 accepted with the reason. A film, not a bench.
- EVIDENCE (it13 NEXT 1 closed) the `tall` landmarks in motion: `--scenario=facade --zoom=1.0|1.5
  --view=tilt70`, ac8f9af4+ vs 633d882c (throwaway worktree, same scenario file): building_tall at
  (500, 252) between two tenements. Before: the tenement strip stretched (smeared bricks); after:
  fire-escape landings and stacked windows, the face ~1/3 taller than its neighbours'. LOOKED at
  32 and 48. `gtai-masters/n8/city/it16_facade_tall_48ppm_before_after.png` (frames.json #8) +
  `it16_facade_tall_32ppm_before_after.jpg`. 0 SCRIPT ERROR all runs.
- EVIDENCE (it12 NEXT 2 closed for the bench) bench_v2 in motion, 48 px/m x2, vs 28281696:
  before = a tall frontal slab like a crate, after = a low slatted bench under the steep camera.
  `it16_bench_v2_48ppm_before_after_x2.png` (frames.json #4). The vending machine v2 is still not
  filmed. FRICTION: a worktree checked out to an older commit keeps the newer imported textures
  when a png is replaced under the same name (the first before == after); run `--import` on the
  trial after every checkout.
- MILESTONE 522fc454 + bf831ee7 the lamp, trash can and bus stop 70 strips from the library's A
  raises (lamp_v4, trash_can_v3, bus_stop_v4), cut by city_prop_cut.py (from a scratch copy:
  the tool reads `<id>_<pitch>.png`, the raises are named `<id>_<pitch>_vN.png`); 3 provenance
  lines. A props row's `cell_w_m_<art>` overrides `cell_w_m` for that pitch's strip (one line in
  PropCards.make, schema too): the v4 lamp at the shared 1.15 m drew 1.3x a walker (squat), at
  1.7 m it had the old height but a 1 m plate; built 1.45 m (DECISION in docs/decisions.md).
  EVIDENCE `it16_lamp_busstop_v4_48ppm_before_after.png` (frames.json #5): the bus stop's ribbed
  grey roof and cream fascia replace the black slab (the clearest gain); the lamp shows its
  shade and globe. Dropped from frames.json: it10 night lamps (the lamp art changed), it12
  payphone 32 pair (the 48 pair stays).
- GATE unit `--changed` on the strips + cell width: 1505 passed, 0 failed, 0 skipped (50 s).
  Lint 15/15 every commit.
- GATE `top` bit-identity at bf831ee7 vs 94930301 (session start) re-recorded this session in a
  throwaway worktree (removed): `--arena=city --bot=rivet --seed=2 --rigs --quit-after 301`
  framemd5 IDENTICAL, 301 video + 301 audio, 0 SCRIPT ERROR each.

Registry rules applied this session: concept-scene-parity + motion-quality-gating (every pair from
the same scenario, seed and frame, before and after in throwaway worktrees, judged at 32 and 48
px/m with a walker in frame for scale), generative-artifact-gating (A raises read note by note;
the lamp's A grade did not settle its scale: judged against the cast in the scene, not the sheet),
sprite-and-atlas-production (the raises cut by the same tool into the same five-cell layout; a
pitch's own cell width instead of re-cutting the drawing), depth-ordered-layered-art (no new band:
the swapped strips stand where the old ones did), tiling-texture-acceptance (the tall bays read
butt-joined in motion at 48), render-submission-economy (texture swaps and one dictionary read
at build time; no per-frame work).

NEXT (iteration 17, in order):
1. The 55 raises for the boss arenas (55 first there): dumpster_v4 55 A and crates_v4 55 A are
   the arena cover kinds (cover_high / cover_low): cut them into p55 prop_dumpster /
   prop_crate_stack (+ re-bake the crate's print twin with tools/art/print_twin.py), film the King
   fight under combo at 48 vs today. Then hydrant_v3, newsstand_v2, planter_v2,
   vending_machine_v3, barrel_cluster_v3, trash_can_v3 at 55 (A).
2. The vending machine v2 at 70 in motion (a probe for a kerb vending_machine near the route).
3. The lamp at night with v4 (light_m checked against the new head's ground point; the it10
   night pair is stale).
4. CityOcclusion's remaining 0.21 ms (RigCastShadows.collect walk), under bench.lock.
5. Before the freeze: full gates (unit no-arg, scenarios, evidence --no-bench, reel tilt70),
   the exe export, REPORT (Calls: facade height, occlusion style, the lamp's 70 cell width).
- (03:04, after the NEXT above) MILESTONE 0ad898a9 NEXT 1's first half: the arena cover's 55
  strips from the library's A raises (dumpster_v4, crates_v4, round 20261107-0205), cut by
  city_prop_cut.py; the crate's world-print twin re-baked by print_twin.py; 3 provenance lines.
  EVIDENCE `gtai-masters/n8/city/it16_king_cover_crates_v4_combo48_before_after_x2.png` (not in
  frames.json, full at 15): `res://dev/arena/arena.tscn -- --boss=king --bot=boss --seed=2 --rigs
  --view=combo --ppm=48`, frame 6.3 s (combo at 55), 94930301-tree vs 0ad898a9: the two-plus-one
  stack with clear cream plank tops vs the flatter three-plus-one; the same footprint. 0 SCRIPT
  ERROR both. No dumpster in that frame: the dumpster v4 is NOT yet seen in motion (the depot
  fight `--boss=servo` has the cover_high dumpsters). The crate redraw (print twin) not re-checked
  on view's stand_rect merge. GATE unit --select prop cards / chunk lift / occlusion 21/0; lint 15/15.
NEXT (iteration 17) replaces NEXT 1 above: (a) film the dumpster v4 on the depot fight under combo
48 vs 94930301; (b) the remaining 55 raises (hydrant_v3, newsstand_v2, planter_v2,
vending_machine_v3, barrel_cluster_v3, trash_can_v3); NEXT 2-5 as above.
- (03:08) EVIDENCE NEXT (a) done: the dumpster v4 on the depot fight, `res://dev/arena/arena.tscn --
  --boss=servo --bot=boss --seed=2 --rigs --view=combo --ppm=48`, 6.3 s, 94930301 (throwaway
  worktree, re-imported, removed) vs 22024a9c: the lid stands open, the bags and the lift pockets
  read; before, two flat lids. `gtai-masters/n8/city/it16_depot_dumpster_v4_combo48_before_after_x2.png`.
  0 SCRIPT ERROR both.
- GATE unit full no-arg at 22024a9c: 1521 passed, 0 failed, 0 skipped, no FLAKY.
- Session end ~03:10. Head = this JOURNAL commit. NEXT (iteration 17): (b) the remaining 55 raises,
  then NEXT 2-5 of iteration 16.

## Iteration 19 (2026-11-07 03:10 - 04:10), BUILD
Read: JOURNAL, git log, the four lane journals (no new REQUEST to city), the library catalog (new
A at 55: hydrant_v3, newsstand_v2, planter_v2, vending_machine_v3, barrel_cluster_v3,
trash_can_v3; B: bench_v3 55 (twin of the 70 A), traffic_light_v3 55, lamp_v4 55; roof_dressing_v3
A at 55/70; depot_dressing_v3 70 B "no gain").
- MILESTONE 3ba29fd0 (it16 NEXT (b)): the hydrant, newsstand, planter, vending machine, barrel
  cluster and trash can 55 strips from the A raises, cut by city_prop_cut.py (scratch copy named
  `<id>_55.png`); 6 provenance lines. The newsstand's and machine's facing 0 now fill 0.75 of the
  cell (before 0.93 / 0.85), so `cell_w_m_p55` 3.15 / 1.37 keep the 70 strips' front-face ground
  width (2.37 m / 1.03 m). No new code (the it16 per-pitch key).
- EVIDENCE the 55 raises in motion: `res://dev/bench/city_bench.tscn -- --scenario=facade
  --zoom=1.5 --view=tilt --secs=24` (48 px/m), ca539e27 (throwaway worktree wt_before, imported)
  vs 3ba29fd0, 22.5 s: the wall-side vending machine reads as a machine (bottle rows, coin slot)
  where it was a cream slab with a dark lid; the corner planter shows its shrubs from above.
  `gtai-masters/n8/city/it19_vending_planter_v55_tilt48_before_after_x2.png`. At 13.5 s the wall
  bins show the rounder v3 rim. 0 SCRIPT ERROR both. The hydrant, newsstand and barrels were not
  in frame. The same drive at tilt70 (3ba29fd0) frames the 70 vending v2 against a wall (it16
  NEXT 2, it reads as a dark louvred box at 48: looked, not kept).
- EVIDENCE (it16 NEXT 3) the v4 lamp at night: `vehicle_frame.tscn -- --scene=yield --view=tilt70
  --grade=night --car-zoom`, tick 180: the pool sits on the pavement around the head and the upper
  post (light_m -0.45 still fits the v4 head; no change).
  `gtai-masters/n8/city/it19_lamp_v4_night_tilt70_48ppm_x2.png`. 0 SCRIPT ERROR.
- MILESTONE 5f35e2a4 the bench's 55 strip from bench_v3 (B, the 55 twin of the 70 bench_v2 A):
  combo's hard swap 70 -> 55 no longer turns the slatted scroll-end bench into the 2110 armchair
  bench. B note (views 1/5 near elevations) accepted at game size so the strip keeps one design.
- FOUND (all 17 prop strips, 55 | 70 side by side, scratch swap_pairs.jpg): the designs that still
  change in combo's swap are the bus stop (55 = the black slab, 70 = v4 ribbed roof + cream
  fascia) and the lamp (55 = slender swan neck, 70 = v4 fluted bronze with a bolted plate).
  Everything else keeps its design (crate stack differs in the stack only).
- DECISION traffic_light_v3 55 (B, the new pick) NOT cut: its view 1 puts the head in front of the
  pole (facing 0 fills 0.45 of a cell) while the props row's foot_m / mirror assume the post at -x
  and the head at +x in every view; no boss arena has traffic lights, so only `--view=tilt` on the
  city street would show it. Re-check when a 55 sheet with the 70's layout lands.
- DECISION roof_dressing_v3 (A, 55/70) NOT integrated: the baked roofs already paint their AC
  units, tanks, vents and hatches (seen in every drive frame); standing cards would double them.
  Re-check if the owner asks for rooftop silhouettes above the roof line.
- REQUEST to assets: bus_stop, 55, the 55 twin of bus_stop_70_v4 (A): the ribbed mid-grey roof and
  cream fascia at 55, because combo hard-swaps the 70 shelter into the 2000 black slab mid-fight.
- REQUEST to assets: lamp, 55, the 55 twin of lamp_70_v4 (A: fluted bronze pole, bolted 10-sided
  plate, curved arm, domed shade + cream globe), same reason (the 55 is a different slender lamp).
  Keep the arm to the right in views 1-4 as the 70 (the props row mirrors view 3 from it).
- REQUEST to assets: street_sign and bollard, 70 then 55, five rotations each: the two kerb props
  (KerbDresser.KERB_PROPS 36/37, 2 of 12 kerb picks) with no sheet, still drawn flat top-down
  under the angled view. Street sign: a 2.6 m grey pole with a blank cream blade sign (no
  letters); bollard: a 0.9 m dark iron post with a cream band, no hazard stripes.
- GATE unit full no-arg at 5f35e2a4: 1521 passed, 0 failed; lint 15/15 every commit. `top` cannot
  move: only p55 strips and a p55 width key changed (p55 is never drawn under top).
- (03:28) FINDING CityOcclusion's cost is not the per-rig building query: culling rigs whose feet
  are off screen (+3.5 m margin) measured 0.148 -> 0.147 ms mean, p99 0.483 -> 0.466 (city_bench
  `--scenario=drive --view=tilt70 --zoom=1.0 --secs=30 --spans`, bench.lock HELD, before =
  ca539e27 worktree). No gain, so REVERTED (not committed). What is left is the per-frame
  RigCastShadows.collect walk and the draw (~0.03 ms); at 0.15 ms of a 16.7 ms frame it is closed
  as not worth more code. The it11 0.21 ms was at zoom 0.4 with ~400 actors.
- MILESTONE combined clip of the set refreshed: `gtai-masters/n8/city/it19_city_set_tilt70_combo_56s.mp4`
  (facade drive tilt70 32 then 48 px/m, then the King fight under combo 48 px/m; 3ba29fd0..942fc2a9;
  0 SCRIPT ERROR x3), replaces the it7 clip in frames.json (#12).
- MILESTONE 678c7382 (it13 NEXT 5) quest 1's TUCK-IN crates stand under a tilt: PropBox (two
  layers: the flat stencilled crate art as the top lifted 1.0 m, a front face from the art's south
  band darkened and ink-ruled, a ground shadow); StageView's flat fallback line now calls
  PropBox.draw_on (same line count, debt unchanged). Two-layer REBUILD (not a stretch): the quest
  art has no sheet. EVIDENCE `gtai-masters/n8/city/it19_quest1_tuckin_crates_tilt70_32ppm_before_after_x2.png`
  (quest1_clip --stills=13700 --view=tilt70, ca539e27 vs 678c7382; frames.json #8, replacing the
  it11 depot combo pair, superseded by the v4 cover). Judged: the ten crates read as boxes on the
  dock, the south row in front of the north row's face. `top` quest stills at ticks 4000 and
  13700: pixel-identical to ca539e27. DECISION in docs/decisions.md.
- GATE unit full no-arg at 678c7382: 1523 passed, 0 failed (2 new tests), no FLAKY. Lint 15/15.

Registry rules applied this session: generative-artifact-gating (A raises used as is; bench_v3 B
used with its note read: views 1/5 accepted so one design spans the strip; traffic_light_v3 B and
roof_dressing_v3 A declined with reasons), sprite-and-atlas-production (same cut tool and cell
rule; per-pitch widths instead of re-cutting), depth-ordered-layered-art (PropBox draws shadow,
front, top in order and the stage's rows north to south so a south crate covers the north row's
face), concept-scene-parity + motion-quality-gating (same scenario/seed/tick before and after in a
throwaway worktree, judged at 32 and 48 px/m), tiling-texture-acceptance (not touched this
session), render-submission-economy (PropBox adds 3 draw commands per quest crate; the occlusion
cull measured and dropped because it bought nothing).

NEXT (iteration 20, in order):
1. Read the asset lane's answers to the it19 REQUESTs (bus_stop 55 + lamp 55 twins of the v4 70
   designs; street_sign + bollard 70/55). Cut what lands (city_prop_cut.py from a scratch copy),
   film combo's swap on the King fight (no design change at 70 -> 55).
2. Street sign / bollard: if the sheets land, add props rows (city_facades.json) and film a kerb.
3. The burning TUCK-IN crates (tuckin_crate_hit) under tilt70 at the sabotage tick (same PropBox
   path; check the fire FX sits on the lifted top, not the ground).
4. Before the freeze: evidence --no-bench, scenarios, the reel at tilt70 19/19, the `top`
   framemd5 on the city arena, the exe export, REPORT (Calls: facade height, occlusion style,
   lamp 70 width, the TUCK-IN two-layer box vs a drawn sheet).
- Session end ~03:45. Head = this JOURNAL commit.
- (03:46) EVIDENCE NEXT 3 done early: the burning TUCK-IN crates (tuckin_crate_hit, same PropBox
  path) at tick 16040 (fire at 16022), quest1_clip --stills=16040 --view=tilt70, ca539e27 vs
  678c7382: the fire bursts and smoke still cover the lifted crates (the lift is ~5 px at 32 px/m),
  no floating or gap; Rivet's fight beside them unchanged. 0 SCRIPT ERROR both.
  `gtai-masters/n8/city/it19_quest1_tuckin_burning_tilt70_32ppm_before_after_x2.png`.
- GATE scenarios at 408e72d6: `run_scenarios.gd` 52 ran, 0 failed, exit 0 (vehicle drive timing
  CONTENDED as labelled by the runner: other lanes on the machine).
- GATE `top` bit-identity at 408e72d6 vs ca539e27 (session start, throwaway worktree):
  `--arena=city --bot=rivet --seed=2 --rigs --quit-after 301` framemd5 IDENTICAL (617 lines each),
  0 SCRIPT ERROR each; the quest's `top` stills (4000, 13700) pixel-identical (above).
- GATE `node tools/evidence/run.mjs --no-bench` at 7b63bcb1 (03:48-03:56): lint 15/15, unit 1523/0,
  scenarios 52 passed, parity exact (1200 steps, planted mutation caught at 629), selftest (look
  goldens 11/11, block goldens 5/5, world lock 0.00 %), export-audit release-compile 563/0. PASS all.
- ANSWER to view (it11 trial-merge REQUEST, BossView.attach 41 lines once hud's bar.crest merges):
  done on this branch, `BossDressing.attach(...) -> void` (the returning call is `add()`), so
  BossView drops its `@warning_ignore` line (one line shorter; your `_dress` helper is not needed).
  GATE unit --changed 1507/0, lint 15/15; the depot fight `--boss=servo --view=combo --ppm=48`
  400 frames, 0 SCRIPT ERROR, the dressing draws (conveyor and CS belt seen).
- Session end ~04:02. Head = this JOURNAL commit. NEXT (iteration 20): as listed above (1: the
  asset lane's answers to the bus_stop/lamp 55 + street_sign/bollard REQUESTs; 2: their props rows;
  4: the freeze items: reel at tilt70 19/19, exe export, REPORT).

## Iteration 22 (04:02-05:02, BUILD)

Read: JOURNAL, git log, the other lanes' journals (no new REQUEST to city; view's it19 BossView
REQUEST answered last session), the library catalog (new since it19: bus_stop_v3 55 A, lamp_v5 55
B, street_sign 70 B + street_sign_v2 70 A / 55 B, bollard 70 A / 55 A, depot_dressing_v3 55 A,
traffic_light_v5 55 B, bench_v4 55 B). The assets lane served all four it19 REQUESTs.

- MILESTONE 2248587a the bus stop and lamp 55 strips from the 55 twins of the 70 picks
  (bus_stop_v3 A, lamp_v5 B: a little steep, a globe sliver, accepted at game size because it is
  the 70 lamp_v4's design and paint). Combo's hard swap 70 -> 55 now keeps one design for every
  prop strip (it19 FOUND: these two were the last that changed). Same cell widths and foot_m.
- EVIDENCE `city_bench --scenario=facade --zoom=1.5 --view=tilt --secs=24` (48 px/m), 937c4d54
  p55 strips vs 2248587a, frame at 10.5 s: the black-slab shelter becomes the ribbed grey roof
  with the cream fascia (as at 70); the lamp gets the bolted plate.
  `gtai-masters/n8/city/it22_busstop_lamp_v55_tilt48_before_after_x2.png` (frames.json #4).
  0 SCRIPT ERROR both. FRICTION: `git show <rev>:<png> > file` writes the LFS POINTER (pngs are
  LFS here): Godot then marks the texture `valid=false` in its .import (ERR_FILE_CORRUPT) and the
  run draws without it. Use `git show <rev>:<png> | git lfs smudge > file`. The first "before"
  was discarded for this reason; the .import files were restored from git and re-imported clean.
- MILESTONE a8b36021 the street sign and bollard stand up under a tilt (the last two KerbDresser
  kerb props that stayed flat): props rows street_sign (cell 0.9 m: the blade) and bollard (0.4 m,
  the flat footprint), strips from the REQUESTed sheets (street_sign_v2 70 A / 55 B, bollard
  70 A / 55 A), mipmapped (the importer defaulted to mipmaps off for the new files: set to true as
  every prop strip). Turn 0 like the other kerb props (blade face-on along the kerb). 6 provenance
  lines.
- EVIDENCE `city_bench --scenario=drive --zoom=1.0 --view=tilt70 --secs=30` (32 px/m), old table
  vs new table, the kerb props found by a frame diff (the facade route has none): before a flat
  disc / a flat diagonal blade, after the cast-iron post with its cream band and the pole with its
  blank blade. `it22_kerb_bollard_sign_tilt70_32ppm_before_after_x3.png` (frames.json #6).
  0 SCRIPT ERROR both. Judged: at 32 px/m they are small (13 x 25 px for the bollard) but read as
  posts standing on the pavement, not marks on it.
- MILESTONE 0a96d574 Servo's depot dressing at 55 from depot_dressing_v3 (A, the exact redraw
  with muted dark-brown brick; warm-red px on the bay pieces 6171 -> 4909): same 8 pieces in the
  same order, sizes within 1 px. EVIDENCE `res://dev/arena/arena.tscn -- --boss=servo --bot=boss
  --rigs --seed=2 --view=combo --ppm=48` frame 880: the three shutter bays draw with the brown
  brick, 0 SCRIPT ERROR. `it22_depot_bays_v3_combo48_frame880.png` (not in frames.json: a colour
  shift only).
- DECISION traffic_light_v5 55 (B) NOT cut: the current p55 strip already has the 70's layout
  (pole left, head right) and a sane pole; v5's pole is ~5.4x the flange (B note). bench_v4 55
  (B) NOT cut: the library keeps bench_v3 the pick (v4's end views overshoot to ~65-70).
- frames.json: the two new pairs in, the it7 dumpster (superseded by the v4 cover) and the it13
  crate print-twin detail out (15 entries).
- GATE `top` bit-identity at 0a96d574 vs the it19 baseline (408e72d6): `--arena=city --bot=rivet
  --seed=2 --rigs --quit-after 301` framemd5 IDENTICAL (617 lines), 0 SCRIPT ERROR. Lint 15/15
  every commit. Unit --select=test_prop_cards 11/0.

Registry rules applied: generative-artifact-gating (each sheet's grade and note read; A used as
is, two B's used for the design match with the fault named, two B's declined with reasons),
sprite-and-atlas-production (one cut tool, mipmaps on every card strip, cell widths from the
facing-0 fill), concept-scene-parity + motion-quality-gating (same scenario, seed and frame before
and after, the props located by a frame diff, judged at 32 and 48 px/m), depth-ordered-layered-art
(the new cards ride the existing roofs band by south edge), render-submission-economy (two more
card kinds, one textured rect each, no new pass).
- MILESTONE f07b348e the bench's 55 strip from bench_v5 (A: v3's views 2-4 exactly, views 1/5
  redrawn so the seat reads as a plane; dark iron as the 70). Same cell, 1 provenance line. Looked
  at the 55 v3 | v5 | 70 strips side by side (scratch lib22/bench_cmp.jpg); not filmed.
- GATE director reel at tilt70 on 0a96d574 (`--fixed-fps 60 --quit-after 7600 res://dev/arena/arena.tscn
  -- --bot=reel --reel=director --loadout=pistol --rigs --view=tilt70`, headless): 19/19 chapters
  down, 0 SCRIPT ERROR (`evidence/director-reel-it22-tilt70.log`). Unit full no-arg 1523/0 at
  196e0722. Scenarios `run_scenarios.gd` 52 ran, 0 failed (vehicle drive CONTENDED by the runner).
- MILESTONE 83c77181 REPORT.md draft (what works with evidence, gaps, Calls, next); the freeze
  session fills the exe and the final gates. DECISIONs in docs/decisions.md (one design per prop
  across the pitches; kerb sign and bollard cards).
- FOUND (04:29) the library's facade v2 sheets (0525 round: facade_kit_v2 70 A / 55 B, facade_shop_v2
  70 A / 55 A, facade_tall_v2 55 A, facade_tall_v3 70): exact redraws of the untapered keys with raw
  rectangular roofs and muted brick (kit 70 redcheck 434 -> 24 px). NOT cut this session:
  `city_facade_cut.py` holds hand-measured bay boxes and wall bands per sheet (STYLES /
  STYLES_70), so each sheet needs its boxes re-measured and the strip looked at bay by bay.
- Also new: roof_dressing_v4 55/70 (it19 DECISION stands: the baked roofs paint their dressing).

NEXT (iteration 23, in order):
1. The facade v2 sheets: measure each sheet's three wall-bay boxes and band (alpha runs on the top
   row, as the 55/70 originals), add them to STYLES / STYLES_70 pointing at the v2 files, cut, look
   at old | new strips side by side, film the facade drive at tilt70 32 px/m and `tilt` 48 px/m
   before/after (`git show <rev>:<png> | git lfs smudge` for a before, or a throwaway worktree).
   kit 55 is B: the bottom-row roof lips bow; we cut only the top-row walls, so it does not apply.
2. Film the bench v5 under `tilt` (facade drive, 48 px/m) if a bench is in frame.
3. Freeze items (08:30): evidence --no-bench, `top` framemd5, the exe export (int-day recipe),
   REPORT final (head, exe command lines).
- Session end ~04:40. Head = this JOURNAL commit.
- (04:30-04:48, NEXT 1 done early) MILESTONE e95c7cf6 + 52ebbc4a the facade v2 sheets: the
  tenement/shop 70 (A) and tenement/shop/tall 55 (kit B: bowed roof lips, not used by the
  top-row wall cut; shop/tall A) pieces measured with the cutter's alpha runs sit within 1 px of
  the untapered keys, so city_facade_cut.py keeps its boxes and points at the v2 files (the
  unchanged styles reproduce byte-identical). Looked at old | new strips: same crops, brick a
  touch browner, rust muted. Frame check `--scenario=facade --zoom=1.5 --view=tilt` (the shop face
  under its roof with the new 55 bus stop and lamp): `it22_facade_v2_busstop_lamp_tilt48_frame.png`.
  5 provenance lines. 0 SCRIPT ERROR.
- MILESTONE f9bbbe4f the tall 70 face from facade_tall_v3 (A, 0510, a new camera ~72-77):
  NEW boxes measured (bays (188,504) (616,926) (1034,1345), band 255-659: from under the cornice
  to the ground ink, as the old cut). FacadeStrips stretches each bay cell to the face's lift, so
  the drawing nearer the in-game face aspect distorts least: in game a tall bay is ~0.9 tall per
  unit width (21 m x height_k 0.5 at 70: lift = h * cos70 / sin70), v3 1.38, the 2210 cut 2.47.
  EVIDENCE `--scenario=facade --zoom=1.0 --view=tilt70 --secs=60` frame 29 s, 52ebbc4a (smudged)
  vs f9bbbe4f: six window rows, landings as grated floors from above, the shutter and door at the
  street storey. `it22_facade_tall_v3_tilt70_32ppm_before_after_x2.png` (frames.json #9; the it7
  p70 strips sheet dropped). Judged a modest gain (the world print greys both). 0 SCRIPT ERROR.
  The tall landmark is on the facade lap only at ~28-31 s of a 60 s run at zoom 1.0 (not in 24 s).
- GATE `top` framemd5 at 52ebbc4a IDENTICAL to the it19 baseline (617 lines). Unit
  --select=test_chunk_lift,test_prop_cards 17/0. Lint 15/15 every commit.
- FOUND: the same stretch argument applies at 55 (tall: in game ~1.75 per bay; the 55 v2 strip
  2.78): a steeper 55 tall sheet would not help there; the tenement/shop strips not measured.

NEXT (iteration 23, in order):
1. Film the bench v5 under `tilt` (facade drive 48 px/m) and the new 70 tenement/shop faces in the
   set clip; refresh the combined clip (30-90 s) with tonight's kerb sign/bollard and facades.
2. The flat hatched shadow beside the kerb street sign (the flat art's shadow): a small card-side
   ground shadow instead, if it reads wrong at 48 px/m (it22 48 px/m pair: a diagonal stroke).
3. Freeze items (08:30): evidence --no-bench, `top` framemd5, the exe export (int-day recipe),
   REPORT final (head, exe command lines).
- Session end ~04:52. Head = this JOURNAL commit.

## Iteration 25 (04:50-05:50, BUILD)

Read: JOURNAL, git log, the other lanes' journals (no new REQUEST to city), the library catalog
(nothing new for building/prop since the facade v2/v3 rounds cut in it22).
- DECISION (04:58) the kerb street sign keeps its flat art's hatched shadow this night (it22 NEXT 2,
  judged on the it22 48 px/m pair): the stroke starts at the card's foot and reads as the pole's
  cast shadow; its fault is the direction (up-right, where the bollard's falls down-right). The
  fix needs a shadow hook for card props in ChunkView._slice (the baked shadow command carries the
  bake's offset, not the foot) and chunk_view.gd sits at 200 lines; not worth the `top` risk this
  late. Stays in REPORT gaps.
- (05:00) REVISED the DECISION above: with time left the fix was small. MILESTONE 1f9ede57 the
  street sign casts a pole's shadow: props row `cast_m` 1.0 (schema'd), ChunkLift.takes(t, shadow)
  + draw(..., shadow) draw its baked shadow command as a 0.12 m hatched stroke from the card's foot,
  down-right (the bake's 0.18 m offset). ChunkView's line count unchanged (200); ChunkLift 195.
  Tried 0.2 m first: a ladder at 48 px/m (hatch rungs across), rejected. 1 unit test.
  EVIDENCE `city_bench --scenario=drive --view=tilt70 --secs=30` zoom 1.0 and 1.5, frame 21 s,
  before = the same tree without `cast_m` (the sign found by a frame diff, only 6 frames differ):
  `it25_street_sign_cast_tilt70_32ppm_before_after_x3.png` (frames.json, replacing the it10 kerb
  cars pair) + the 48 px/m close-up. 0 SCRIPT ERROR all runs.
- GATE `top` framemd5 at 1f9ede57's tree (`--arena=city --bot=rivet --seed=2 --rigs --quit-after
  301`): IDENTICAL to top22.md5 (617 lines), 0 SCRIPT ERROR. Unit --select=test_chunk_lift,
  test_prop_cards 18/0. Lint 15/15.
- FRICTION `tools/godot/check.mjs res://features/city/view/chunk_view.gd` reports "Failed to compile
  depended scripts" while the real runs load it clean (0 SCRIPT ERROR); chunk_lift.gd alone checks
  ok. Not chased (a -s parse of a file whose deps name autoloads); the runs are the proof.
- MILESTONE (04:54) the combined clip re-cut on 0a630cfe: `it25_city_set_tilt70_combo_55s.mp4`
  (facade drive tilt70 32 px/m 0-16 s + the tall landmark 26-33 s, the kerb at 48 px/m incl. the
  sign and bollard cards, the King fight combo 48 px/m), 33 MB, 0 SCRIPT ERROR x3; replaces the
  it19 clip (deleted) in frames.json and REPORT. Looked at 5, 30, 40, 50 s.
- MILESTONE 3fbd1a7a the cost refreshed at 0a630cfe under bench.lock (held 04:54-04:59; other
  lanes' Godot runs live: wall-clock): drive 1.04 (top) vs 1.28 ms (tilt70) per frame, p99 CPU 2.05
  vs 3.15, draw calls 823 vs 961; chunk record 0.80 vs 3.48 ms p50 sliced over 39 frames, no
  streaming frame over 1.72 ms. tilt70 had 6 frames over 25 ms (top 0), not attributed (not the
  chunk slice). `evidence/drive-cost-it25.json`, REPORT item 5.
Registry rules applied: render-submission-economy (the pole cast is one rect into the existing
shadow band, no new item or pass; measured the drive's draw calls), depth-ordered-layered-art (the
cast stays on the shadow band under every card), concept-scene-parity + motion-quality-gating
(same seed, scenario and frame before/after, one data value apart; judged at 32 and 48 px/m),
tiling-texture-acceptance (n/a this session: no strip changed).
- MILESTONE aa795463 + 0952dd47 the lamp post (cast_m 1.6) and traffic light (1.8) take the pole
  cast too (data only). EVIDENCE same drive at zoom 1.5 (48 px/m), HEAD vs HEAD+cast_m, located by
  frame diff: the corner lamp's flat silhouette streaked up-left to the corner and the traffic
  light's arm shadow floated up-right of its card as a separate hatched bar; after, a thin stroke
  from each post base, down-right with the cars' shadows. `it25_lamp_cast_tilt70_48ppm_before_top_
  after_bottom.png`, `it25_traffic_light_cast_tilt70_48ppm_before_after_x2.png` (named in the
  sign's frames.json note; frames.json stays 15). No blob for the globe/signal head (DECISION).
  GATE `top` framemd5 IDENTICAL after each (top25b, top25c vs top22.md5). Unit full no-arg at
  7d9b32a1: 1524 passed, 0 failed (no FLAKY). Lint 15/15 every commit.
- GATE scenarios (raw run_scenarios.gd) at 0d9002a1: 52 ran, 0 failed, exit 0 (vehicle drive
  CONTENDED, labelled by the runner).
- LOOKED the pole casts at 55 (`city_bench --scenario=drive --view=tilt --zoom=1.5`, 10 s, a
  crossroads with a traffic light and lamp at each corner): every cast falls from its post base
  down-right (flatter on the 55 ground), the four corners consistent. 0 SCRIPT ERROR. Not kept
  (no before; the 70 pairs carry the change).
- Session end ~05:30. Head = this JOURNAL commit. Tree clean.

NEXT (iteration 26, in order):
1. Director reel at tilt70 on HEAD (the pole cast touches ChunkView's shadow path; the reel's
   arena draws no streamed city, so expected 19/19, 0 SCRIPT ERROR), then `evidence/run.mjs
   --no-bench` (last PASS at 7b63bcb1).
2. Library check for new building/prop sheets (70 twins, traffic light 55 shorter pole); cut A's.
3. If time: a globe blob at the lamp cast's end and a head blob for the traffic light (one rect
   each in ChunkLift.draw's shadow branch, keyed by a second props field), judged at 48 px/m.
4. Freeze items (08:30): `top` framemd5, the exe export (int-day recipe), REPORT final (head, exe
   command lines, gates).
- (05:32) NEXT 1 part 1 done: GATE director reel at tilt70 on 9614fc50 (`--headless --fixed-fps 60
  --quit-after 7600 res://dev/arena/arena.tscn -- --bot=reel --reel=director --loadout=pistol
  --rigs --view=tilt70`): 19/19 chapters, every one all down, 0 SCRIPT ERROR, exit 0
  (`evidence/director-reel-it25-tilt70.log`). Left for iteration 26: evidence/run.mjs --no-bench.
- (05:41) GATE `node tools/evidence/run.mjs --no-bench` at 492f14f1: PASS (lint 15/15, unit 1524/0,
  scenarios 52, parity bit-exact + planted mutation caught, selftest look goldens 11/11 + block 5/5,
  export-audit release-compile 563/0). NEXT 1 done; iteration 26 starts at NEXT 2.

## Iteration 26 (05:42-06:42, BUILD)

Read: JOURNAL, git log, the other lanes' journals: view it13 (05:08) has a REQUEST to city
(`PropCards.stand_polys`) and a NOTE (the arena crate stack turns vermilion-orange under the King's
cone, f960 seed 2). Library: nothing new for building/prop since 0525 (all cut or judged in it22-25).
- MILESTONE 8c982682 + 55ede50c ANSWER to view's it13 REQUEST: `PropCards.stand_polys(kind, r) ->
  Array[PackedVector2Array]`, the cover card's opaque outline(s) in stand_rect's space. New
  `PropCardPolys` (82 lines): the strip cell's alpha traced once per (strip, facing) (BitMap 0.5,
  opaque_to_polygons epsilon 2 px) in the cell's unit square, mapped into the rect, mirrored (and
  reversed) with the facing, exactly view's prototype. stand_rect's body moved there too
  (`card_rect`), so prop_cards.gd stays 198 lines (the debt ratchet failed at 206).
  FRICTION 8c982682 was committed with a parse error (`rect` parameter shadowing the new `rect`
  function; my chained command did not stop on the test failure); fixed at 55ede50c, 20/0.
- ANSWER to view's NOTE (crate colour): the world-print twin (d70c8b06) was only drawn by
  `draw_on`; view's ArenaPropCards draws through `draw_named`, which skipped it, so PropOcclusion's
  item-print redraw snapped the orange crates to vermilion. `draw_named` now goes through the same
  `_draw_ci` (twin under the item print). Not a danger state: a bug, fixed at 8c982682.
- EVIDENCE trial merge (temp worktree %TEMP%/city-trial-it26, detached: 55ede50c + n8-view
  92a3de77; conflicts were comment-only in arena_floor_view.gd/quest1_clip.gd + JOURNAL/REPORT/
  baseline): view's repro `arena.tscn -- --boss=king --bot=boss --bot-human --seed=2 --boss-cam
  --ppm=64 --view=combo --rigs`, 1110 frames, before = the same tree with stand_polys renamed away.
  Frames differ only in a 48x96 px box around Rivet at the crates. LOOKED f1000/f1040/f1080: before,
  the black kite beside the top crate (f1000, f1080); after, gone, and at f1040 the ink stays inside
  the crates. `it26_card_outline_cut_king_combo_64ppm_before_after_x3.png` (frames.json #6, the
  it22 bus stop 55 pair dropped from frames.json, kept for REPORT). 0 SCRIPT ERROR both runs.
- EVIDENCE the crate colour (05:58), same repro, before = the trial tree with 0cb6aa27's
  prop_cards.gd: the whole crate stack vermilion-orange from f960 on; after (55ede50c) cream like
  the floor print. `it26_crate_print_twin_king_combo_64ppm_before_after_x3.png`, named in the it26
  frames.json entry's note. 0 SCRIPT ERROR. Raw .avi deleted.
- FRICTION (05:59) the `top` gate recipe of it19-it25 (`--write-movie ... -- --arena=city --bot=rivet
  ...` with no scene path) runs the BOOT scene: its log says `unknown launch arg --arena=city
  (ignored)`. Still a valid `top` check of the game's own start, but not of the city block. Found when
  my arena-scene run "DIFFERED" from top22.md5 (a different scene, not a regression).
- GATE `top` (06:00), both recipes, 301 frames, framemd5, 0 SCRIPT ERROR: the boot scene at
  55ede50c IDENTICAL to top22.md5; the city arena (`res://dev/arena/arena.tscn -- --arena=city
  --bot=rivet --seed=2 --rigs`) at 55ede50c IDENTICAL to the branch base 0bea8b93 (temp worktree,
  removed): no city change since the start of the night moved a `top` pixel of the city block.
  Unit full no-arg at 55ede50c: 1526 passed, 0 failed, no FLAKY. Lint 15/15.
- REPORT: occlusion item names the card outline + crate twin; Gates section at 55ede50c with both
  `top` recipes.
- MILESTONE 3703b010 (NEXT 3) the lamp's and traffic light's pole cast ends in a round ground blob
  for the globe / signal head: props row `cast_blob_m` (lamp 0.18, traffic light 0.15 m, schema'd),
  ChunkLift.draw adds one circle at the stroke's end and shortens the stroke by the radius (no
  doubled alpha); `_cast_px` now Vector2 (length, radius) so chunk_lift.gd stays 199 lines. 1 test.
  EVIDENCE `city_bench --scenario=drive --view=tilt70 --zoom=1.5 --secs=30` (48 px/m), 1500 frames,
  before = the same tree without `cast_blob_m`; contact sheets of every diff cluster at 30-frame
  steps: only the lamp casts change. Tried 0.22 m first: a ladle; cut to 0.18.
  `it26_lamp_globe_blob_tilt70_48ppm_before_after_x3.png` (f180, f330), named in the it25 sign
  entry's note in frames.json. LOOKED the traffic light under 55 (`--view=tilt --zoom=1.5
  --secs=10`, f300/f420): a small flattened blob at the stroke's end, reads as the signal head; no
  pair kept. 0 SCRIPT ERROR all runs.
- GATE `top` boot-scene framemd5 at 3703b010: IDENTICAL to top22.md5. Unit --select=test_chunk_lift,
  test_prop_cards 21/0. Lint 15/15.
- DECISION lines (pole cast blob, card outline for PropOcclusion) in docs/decisions.md; REPORT
  props + gaps updated.
Registry rules applied it26: depth-ordered-layered-art (the occluder's real silhouette bounds the
hidden body's ink; the blob stays on the shadow band under every card), render-submission-economy
(one circle per pole into the existing shadow band; the outline traced once per strip facing and
cached), concept-scene-parity + motion-quality-gating (same seed, scene and frames before/after, one
data value or one method apart; the outline judged on view's own repro at 64 px/m; the blob at 48
px/m over a 25 s drive), generative-artifact-gating (no new art), tiling-texture-acceptance (n/a).
- GATE (06:18) director reel at tilt70 on bf579226 (draw_on's refactor draws the arena cover):
  19/19 chapters, every one all down, 0 SCRIPT ERROR (`evidence/director-reel-it26-tilt70.log`).
  Scenarios (raw run_scenarios.gd) at bf579226: 52 ran, 0 failed, exit 0 (vehicle drive CONTENDED,
  labelled by the runner). Library re-checked 06:13: nothing new for building/prop since 0525.
- GATE (06:27) `node tools/evidence/run.mjs --no-bench` at 25c9be53: PASS (lint 15/15, unit 1527/0,
  scenarios 52, parity bit-exact + planted mutation caught, selftest look goldens 11/11 + block 5/5,
  export-audit release-compile 564/0).
- NOTE to view: `PropCards.stand_polys` is on n8-city from 55ede50c (8c982682 alone has a parse
  error); your it15 trial merge named city 814c0a4e, which predates it. Re-merge at 25c9be53 or later.
- Session end ~06:30. Head = this JOURNAL commit. Tree clean. Scratch: raw .avi deleted.

NEXT (iteration 27, in order):
1. Read view's journal: did its trial merge on city >= 55ede50c film the outline cut and the cream
   crates on the real code? Answer any new REQUEST to city.
2. Library check for new building/prop sheets (70 twins; the traffic light 55 is still v5 B).
3. (done 06:29, see below) the traffic light blob pair at 70.
4. Freeze items (08:30): `top` framemd5 (both recipes: boot scene vs top22.md5, and the city arena
   `res://dev/arena/arena.tscn -- --arena=city --bot=rivet --seed=2 --rigs` vs the branch base
   0bea8b93), evidence --no-bench, the exe export (int-day recipe), REPORT final (head, exe command
   lines, gates).
- EVIDENCE (06:29, NEXT 3 of it26 done in-session) the traffic light's head blob at 70:
  `city_bench --scenario=drive --view=tilt70 --zoom=1.5 --secs=10`, 600 frames, before = the same
  tree without `cast_blob_m`; LOOKED f300/f420: the cast ends in a small round head blob, the same
  down-right fall as the lamp's. `it26_traffic_light_head_blob_tilt70_48ppm_before_after_x2.png`
  (named in the it25 sign entry's frames.json note). 0 SCRIPT ERROR both. Raw .avi deleted.
- Session end 06:31. Head = this commit. Tree clean.

## Iteration 27 (06:31-07:31, BUILD)
Read: JOURNAL, git log, the lane journals. view filmed city's real stand_polys on its 05:56 trial
merge (MILESTONE 05:57: the occlusion cut and the cream crates on the real code): my it26 NOTE is
answered. No new REQUEST to city. Library (catalog 06:30): NEW `traffic_light_v6` 55 A (0735, the
asset lane's answer to city's "shorter pole" NEXT: v5's design with the poles cut to ~4.2x the flange).
- MILESTONE 6806351d the p55 traffic light strip from `traffic_light_55_v6` (A, prompt_hash
  570fd0647811; cut by tools/art/city_prop_cut.py through a scratch lib copy named
  traffic_light_v6_55.png; cell 137x256, facing0 0.87). LOOKED the strips stacked (old 55 / v6 /
  70): v6 sits between them, the flange and the head's top seen from above. EVIDENCE `city_bench
  --scenario=drive --view=tilt --zoom=1.5 --secs=10` (48 px/m), before = HEAD's 2000 B strip:
  f300/f420 differ only at the light; after, the head's top plane and the flange read as 55, the old
  read near side-on. `it27_traffic_light_v6_55_tilt_48ppm_before_after_x2.png`. 0 SCRIPT ERROR both.
  Provenance line. Lint 15/15; test_prop_cards + test_chunk_lift 21/0.
- FOUND the REPORT gap (the baked crowd is not occluded) in the riot at tilt70: cops and rioters on
  the north sidewalk draw over a building's lifted roof (`riot --view=tilt70 --zoom=1.0` f400).
- MILESTONE f14b97c9 + 60ff77fd + c78a59c3 `CityCrowdOcclusion`: CityOcclusion pastes the printed
  world over each multimesh ped/cop whose feet are north of a building, inside its drawn area (the
  rigs' rule and patch; no ink silhouette for the crowd; a lying body gets a 1.8 m square); the rigs
  in front of a building that hid a crowd body are lifted as for a hidden rig. Positions from the rig
  feed's per-tick snapshot (`CityFxFeed.last_snap`, new), else one own `snapshot()`.
  `CityOccluders.in_rect` lists the screen's candidate buildings once and keeps them until the view
  moves 8 m or a chunk streams (`stamped + dropped`). `CityOcclusion.CROWD` false = the old look.
  3 tests (`test_city_crowd_occlusion`).
  COST (CONTENDED: other lanes running, no bench lock taken): first cut 885-902 us/frame on the
  riot (in_rect walked every building of the 128 m chunks each frame: 400-750 us); with the kept
  candidates + a zone union pre-reject (a per-frame grid was slower: dictionary inserts) riot
  138-173, drive 150-205, the arena city on foot 66 us/frame. Tried RECT_SLACK_M 16: no better.
  EVIDENCE riot f300 (x2) + drive f600 (x3), before = CROWD false, same seed and scene:
  `it27_crowd_occlusion_riot_drive_tilt70_32ppm_before_after.png` (frames.json #4; the it1 facades
  true-height pair dropped from frames.json: iteration 1's look, superseded by it22/it25). LOOKED:
  riot, the roof's north half reads (its vent box) and the bodies are cut at its edge; drive, the
  walker standing on a roof gone. Left: riot bodies the sim leaves INSIDE a footprint still draw
  (their feet are south of the north edge: the in-front rule). 0 SCRIPT ERROR every run.
- FOUND (not city's change; pre-existing) a one-frame dark rect (ground drawn before the sidewalk)
  at the top edge of the riot at f569 in the BEFORE run too (CROWD false); with the crowd pass on
  it lasts 2 frames (f569-570). Isolated: patches discarded + snapshot -> still; a 200 us busy-wait
  instead -> not; no snapshot (last_snap) -> still 2 frames. Likely ChunkView's per-frame
  BUDGET_US slicing at the screen edge; NEXT, not fixed.
- GATE `top` (07:06): the city arena (`res://dev/arena/arena.tscn -- --arena=city --bot=rivet
  --seed=2 --rigs`, 301 frames) at c78a59c3 framemd5 IDENTICAL to the branch base (it26
  topbase_arena.md5). Unit full no-arg at f14b97c9: 1530 passed, 0 failed. Lint 15/15 every commit.
Registry rules applied it27: depth-ordered-layered-art (the crowd is ordered against the roofs by
the same feet-vs-north-edge rule as the rigs, so the two never disagree), render-submission-economy
(no new draw items: the crowd's patches join the rigs' patch list in one draw; the candidate list
kept across frames; the snapshot shared with the rig feed), motion-quality-gating + concept-scene-
parity (same seed and scene, one const apart; judged on the riot and the drive in motion, frame
diffs every 30 frames), generative-artifact-gating (traffic light v6: A, used as is, stacked against
the old 55 and the 70 before cutting), tiling-texture-acceptance (n/a).
- READ (07:11) the edge flash's cause: ChunkView._slice draws a chunk over several frames
  (BUDGET_US 1500, ground commands first), so a chunk activated while on screen shows its ground
  before its sidewalk items for a frame. Fix idea: keep a chunk's pooled items invisible
  (canvas_item_set_visible) until `activated`, only under a lifted view (under `top` the boot fill
  is visible progressively and the `top` framemd5 must not move). Not landed: no time to gate it.

NEXT (iteration 28, freeze session, in order):
1. (done 07:12) GATE director reel at tilt70 on 7d40e58d: 19/19 chapters, every one all down,
   0 SCRIPT ERROR, exit 0 (`evidence/director-reel-it27-tilt70.log`).
2. Freeze items (08:30): `top` framemd5 both recipes (boot scene vs top22.md5; the city arena vs
   it26/topbase_arena.md5), `node tools/evidence/run.mjs --no-bench`, scenarios, the exe export
   (int-day recipe in docs/decisions.md) to build/export/windows/RTAI.exe, REPORT final (head, exe
   command lines, gates).
3. Only if time before the freeze: the ChunkView edge flash (above), gated to lifted views, judged on
   the riot f560-575 with a framemd5 `top` check.
4. REPORT's combined clip (it25 set, 55 s) predates the crowd occlusion and the 55 traffic light:
   refresh only if the freeze leaves time.
- GATE (07:17) scenarios (raw run_scenarios.gd) at 6c653ec4: 52 ran, 0 failed, exit 0, 0 SCRIPT
  ERROR (vehicle drive timing CONTENDED, labelled by the runner). Scratch .avi deleted.
- Session end 07:18. Head = this commit. Tree clean. NEXT above (item 1 done; start at item 2).

## Iteration 30 (07:19-08:19, BUILD; the freeze session)
Read: JOURNAL, git log, the lane journals (no new REQUEST to city). Iterations 28-29 left no entries
(the runner's numbering; the it27 NEXT is current).
- GATE `top` (07:20) at 7a43f001, both recipes, 301 frames, framemd5, 0 SCRIPT ERROR: the boot
  scene (`-- --arena=city --bot=rivet --seed=2 --rigs`) IDENTICAL to top22.md5; the city arena
  (`res://dev/arena/arena.tscn -- --arena=city --bot=rivet --seed=2 --rigs`) IDENTICAL to
  it26/topbase_arena.md5 (the branch base 0bea8b93's).
- EXPORT (07:21) at 7a43f001: `"$GODOT_BIN" --headless --path project --export-release
  windows-showcase ../build/export/windows/RTAI.exe` exit 0 (RTAI.exe 282 MB + the sim DLL). Smoke:
  `RTAI.exe --quit-after 600 -- --arena=city --bot=course --seed=2 --rigs --clean --view=tilt70`
  exit 0, 0 SCRIPT ERROR, boots into the arena's city block. (The REPORT's old exe lines named
  `res://dev/arena/arena.tscn` on the command line: the release template refuses a scene path; the
  showcase preset's main scene IS the arena. Fixed in REPORT.)
- FOUND (07:23) the riot edge flash reproduces on HEAD: `city_bench.tscn -- --scenario=riot
  --view=tilt70 --zoom=1.0 --secs=11`, 620 frames: f569 the top strip's mean luma 158 -> 133
  (the sidewalk under a freshly sliced chunk's asphalt), f570 150, f571 back to 158.
- FRICTION (07:26) `node tools/evidence/run.mjs --no-bench` at 7a43f001 died at export-audit:
  `release_compile.mjs` rmSync EPERM on `%TEMP%/gtai-release-compile`, a fixed temp path every
  worktree shares (another lane's release-compile held it). lint/unit/scenarios/parity/selftest had
  run (07:19-07:25). Not city's tool; re-run at 07:30. NOTE for the Director: give the
  release-compile staging dir a per-worktree/pid name.
- FOUND + CLOSED (07:29) the riot "edge flash" is the BENCH's churn, not a game defect:
  `BenchDriver` (riot) calls `CityResidency.evict()` on a ring neighbour of the riot centre every
  CHURN_TICKS 180 so swaps keep happening; the evicted chunk on screen goes and ChunkView redraws it
  (dips at f389 and f569, 3 s apart). In play a chunk leaves only beyond R_DROP 330 m, off screen.
  TRIED (not landed) a `ChunkSwap` (items hidden until a chunk's draw list is whole; a live pitch's
  settle keeps the old chunk until the new is whole; + `ChunkItems`, the pool split out so
  chunk_view stays under 200 lines; 3 tests passed, fast suite 1517/0): on the bench the gap grew
  2 -> 3-4 frames (hidden while the 3-frame tilted slice records), and on the King's combo engage
  (`arena.tscn -- --boss=king --bot=boss --seed=2 --rigs --view=combo --ppm=48`, 240 frames) no
  pixel moved vs HEAD (the arenas do not stream chunks). Reverted; the draft is in
  scratch/city/it30/src/. Still `it30_riot_bench_churn_f568_f569_tilt70_32ppm.png` (masters, not in
  frames.json). REPORT gap closed.
- EXE smoke (07:33) `RTAI.exe --quit-after 400 -- --boss=king --rigs --view=combo` (king engaged in
  king_boulevard) and `--boss=servo` (engaged in depot): exit 0, 0 SCRIPT ERROR (only the usual
  "resources still in use at exit" line of a --quit-after). REPORT Exe section written.
Registry rules applied it30: motion-quality-gating (the flash measured as a per-frame luma series
over all 620 frames, before vs after, not one still; the "fix" rejected because the motion got
worse), concept-scene-parity (same seed, scene and frame count; one file apart), render-submission-
economy (n/a: nothing landed), depth-ordered-layered-art / tiling-texture-acceptance /
generative-artifact-gating (n/a: no new art).
- EVIDENCE (07:40) the combined clip refreshed: `it30_city_set_tilt70_combo_51s.mp4` (masters, 44 MB,
  labelled): facade drive tilt70 32 px/m 16 s (`city_bench --scenario=facade`), the riot's crowd
  behind the roofs 3 s (f395-565, between the bench churns), the 55 traffic light v6 at 48 px/m 5 s
  (`--scenario=drive --view=tilt --zoom=1.5`), the King fight combo 48 px/m 15 s, the city block with
  rigs tilt70 12 s (`arena.tscn -- --arena=city --bot=course --seed=2 --rigs --clean`). 0 SCRIPT
  ERROR x5. LOOKED at 5 frames across it. Replaces it25's clip in frames.json (file deleted).
- FRICTION (07:46) the second full evidence run died on the same EPERM (another lane's Godot held
  `%TEMP%/gtai-release-compile`, started 07:46:10). Ran `--no-release` instead and
  `release_compile.mjs` alone once the other one finished.
- GATE (07:53) `node tools/evidence/run.mjs --no-bench --no-release` at 7d73de04: PASS (lint 15/15,
  unit 1530/0, scenarios 52, parity bit-exact + planted mutation caught at 629, selftest goldens
  11/11 + block 5/5). release_compile at 7d73de04: 565 loaded, 0 failed. (An earlier run at
  927f40f3 marked unit FAIL only because I committed JOURNAL/REPORT mid-run: "tree changed during
  run", 1530/0.) Project tree unchanged since 7d40e58d, so the it27 reel (19/19 tilt70) and the
  07:21 exe cover the head.
- REPORT final (gates, exe lines incl. both boss arenas smoke-run, gap closed, next steps).
