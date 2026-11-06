# d8-bosses JOURNAL (lane: bosses; branch d8-bosses)

## Iteration 1 (2026-11-06 14:09-15:09, BUILD)

- 14:10 Read: AGENTS.md, view.json (`tilt` is already pitch 55: no change), RigHeadCard, KingAccents,
  KingBodyView, the angle sheets (`king_55.png`) and NOTES.md. Other lanes' JOURNALs are empty so far.
- Registry rules applied (from the brief's slugs):
  - `concept-scene-parity`: the King's card is regenerated FROM the approved 55 sheet (image 1 = the
    sheet), so the in-game bust matches the concept the owner approved; judged in the live arena.
  - `generative-artifact-gating`: every generated strip is looked at, keyed, measured (frame count,
    bbox per frame) before it ships; the sheet's known defect (blood-red crown cap) is fixed in the prompt.
  - `sprite-and-atlas-production`: one strip per head variant, 5 drawn facings + 3 mirrored in code.
  - `depth-ordered-layered-art`: accents that stay drawn keep their z over the rig; the card replaces them.
  - `motion-quality-gating`: judged in motion (boss bot, fixed seed) at 32 and 64 px/m.
- 14:14 DECISION art keying: the shared `RigHeadCard.CARDS` belongs to `chars`, so the boss art per
  view lives in the bosses lane: `features/bosses/king/art/p<pitch>/` picked by the active view row's
  pitch (55 today; a 70 strip drops in beside it as `p70/`), swapped onto the built card by the King's
  own code. `top` draws no card at all, so it is untouched. Alternative (one data move away): a
  `card_set` per view row read by RigHeadCard (REQUEST to chars below).
- 14:15 Image round r1 started (King bust 55, gang head 55), lock taken by gen.mjs.

## REQUESTs
- REQUEST to chars (RigHeadCard owner): resolve card strips per view row (e.g. a `card_set` /
  pitch folder `art/view/p<pitch>/<name>.png`, fallback to today's path) so boss strips need no
  swap hook in the bosses lane. Until then bosses swap the King/gang card texture after `_build`.
- 14:20 MILESTONE King bust card (p55): Codex strip from king_55.png (85 s, usable first try), cut
  5 x 218x256 raw (no print snap: the wider palette survives), crimson cap -> plum (hue shift, 17k px).
  Width 1.5x the shared card (1.0 drew the bust narrower than his press arms at 64 px/m).
  The rig's shoulder megaphone part hides under the card (the card draws its own horn).
- 14:25 MILESTONE gang head card (p55): steel helmet, plum band, gold-framed shades, gold rope chain
  with an emerald medallion (71 s, first try); width 1.25. KingAccents skips its drawn gang chain
  when the court strip exists (the card wears it). Commit 3bf2f0d9.
- 14:30 MILESTONE King limbs (p55): a top-view part sheet (plate, piston, plum sleeve, thigh, shin,
  boot, horn; 87 s, first try) cut to today's part boxes (tools/art/king_parts_pitch.py, 19 parts)
  so the pivots hold; drawn raw, re-dressed each step (the rig swaps end-on / toe-off textures).
  The slam tell's drawn plates now use the engraved plate art and rise 5.5 m with the tell under
  a tilt (they lay flat at his feet before). Commit 3f2c7d68.
- Draw order measured by eye per frame in the 64 px/m slam strip: the plates (z 40, KingAccents)
  draw over the bust card (head z) - intended, the plates are raised in front of him; the cape fan
  (KingCape) still draws flat on the ground behind him under tilt: owed.
- FRICTION `node tools/godot/check.mjs` fails on unchanged files too ("Failed to compile depended
  scripts") in this worktree; used the live arena runs (0 SCRIPT ERROR) and GUT instead.
- 14:42 MILESTONE gang bodies (p55): a top-view gang part sheet (torso, sleeve, piston forearm,
  gold-knuckle fist / thigh, shin, gold-toe boot, buckled hips; 87 s, first try) cut to the gang's
  part boxes (`--set=gang`, 20 parts), plum-shifted. Commit 9660cbc2.
- 14:44 DECISION cape under tilt (A/B `KingArt.CARD_CAPE`, default true): with a court strip the bust
  card wears the cape and KingCape's drawn fan stands down (it lay flat on the ground under the
  tilt, a white-rimmed decal behind the upright bust). Cost: the drawn cape's sway and charge
  flare are gone under tilt. Owner call (still: gtai-masters/d8/bosses/call_cape_car_fan_vs_card_48.png).
  Commit 7d9251a0.
- 14:45 GATES on 7d9251a0: lint 15/15; unit 1413/1413 (full run); scenarios 51/52 raw, the one miss
  is city_chase's 2 ms wall-clock nav budget (5.1 ms with 4 lanes running; sim code, untouched here),
  re-run alone through run_scenarios.mjs: 1 passed. Director reel headless `--loadout=pistol --rigs`:
  tilt 19/19 down 0 SCRIPT ERROR, top 19/19 down 0 SCRIPT ERROR (needs --quit-after 8000: chapter 19
  starts at tick 6570). top is untouched by construction: every KingArt path returns at pitch >= 90.
- 14:47 READ chars 8e557502: RigHeadCard now resolves `features/characters/art/view/<ViewMode.art>/`.
  After the merge the court card strips can move there (file names king_bust_card.png /
  gang_head_card.png; rows: king anchor 0.80 width 2.4*1.5 = 3.6 bust raw; gang 0.84, 1.4*1.25 =
  1.75, raw) and KingArt keeps only the limbs + cape. Until then KingArt swaps on this branch.
  Fixed for view70's combo: the part cache is keyed by pitch (a live pitch re-asks). Known gap
  under combo: a card swapped once keeps its strip if the pitch moves mid-fight (fix = the merge above).
- 14:51 MILESTONE Servo (p55): a top-view part sheet from servo_55.png (95 s, first try; 9 parts in the
  asked order) cut to today's part sizes, head turned to the rig's front-down convention
  (tools/art/servo_parts_pitch.py); `ServoArt.path` picks p55 when present (two load lines in
  ServoRig, no growth). Kept main's art: the 2-row rack (layout differs), the drones and crates
  (ServoDraw). Commit a546faca. Still at 64 px/m: gtai-masters/d8/bosses/servo_tilt64_before_after.png.

NEXT (iteration 2, in order):
1. The throne-car as a sprite stack from art (item 2): slices from a simple Blender model rendered
   to PNG (or generated) with our gilded grille (not a maker's trade dress), amber tail lamps, drapes,
   the hood cannon, the throne; replace KingCarStack's code slices under a court pitch only. Film the
   procession and the ram.
2. Fold the court card strips into chars' `ViewMode.art` route once merged (rows in this JOURNAL,
   14:47) and keep KingArt for the limbs + cape; re-dress the card when the pitch moves (combo).
3. Servo: the 2-row rack in the new palette (cut the top two rows of the 3-row rack art), the drones
   (ServoDraw drone_tex/crate_tex through ServoArt); film the drone launch and the rotor dash at 64.
4. Close combat at 64 px/m: the King vs Rivet's claw and the katana chapter (`--loadout=katana`
   in the arena boss fight), Servo the same; check the hit flash on the raw parts (one frame of
   print-through possible when the flash ends: KingArt re-nulls on the next step).
5. A combined clip of the set (30-90 s) for frames.json; cape A/B clip for the call.
6. Rivet's claw / katana chapter 64 px/m checks; then the King's own cape motion under tilt if the
   owner keeps the drawn fan (CARD_CAPE false) - a draped, upright cape layer instead of the fan.
- 14:59 GATES on 1b42d66a: unit 1417/1417 (full run), lint 15/15 (pre-commit). Scenarios and the reel were
  run on 7d9251a0 (before Servo); Servo is p55-only, so top is unchanged by construction.
- 14:56 MILESTONE Servo's 2-row rack wing from the p55 3-row rack (bottom row cut), both wings match
  (11af64a8; still servo_tilt32_both_racks_after.png). NEXT item 3 shrinks to the drones/crates.
- Evidence: gtai-masters/d8/bosses/ frames.json (15 entries, best first), combined clip
  bosses_d8_it1_combined.mp4 (37 s). Raw avis deleted; scratch renders stay in gtai-d8/scratch/bosses.
- Calls for the owner (for REPORT): (1) CARD_CAPE: the card's cape only (default) vs the drawn fan
  under tilt (call_cape_car_fan_vs_card_48.png; `KingArt.CARD_CAPE = false`); (2) the bust's width
  1.5x (`KingArt.STRIPS["king"][2]`); (3) the emeralds key toward grey (the chroma despill clamps
  green): regenerate gem accents on magenta if the owner wants green gems.
- Watch item: an arm can cross the bust card at melee range (king_vs_katana_64_close.png frame 2):
  the rig's arm z draws over the card. Measure per frame next iteration (RigDepthSort is chars').

## Iteration 2 (2026-11-06 15:00-16:00, BUILD)

- 15:00 Read JOURNAL, git log, chars' JOURNAL tail (ViewMode.set_pitch + revision landed on chars).
  Registry rules applied this session: `concept-scene-parity` (the car's walls are cut FROM the
  approved king_car_55 sheet, not redrawn), `generative-artifact-gating` (sheet defects fixed in the
  cutter: red tail lamps -> amber, the maker-like slatted grille replaced by our sunburst),
  `depth-ordered-layered-art` (an ink pass under all slices, then the wall bands, then the roof plane),
  `motion-quality-gating` (judged in the live arena at 32 and 64 px/m, fixed seed 2).
- 15:05 DECISION throne-car stack from art: the walls are cut from the car sheet's side and rear
  views (tools/art/king_car_walls.py) and drawn as one texture row per lifted slice (KingCarWalls, 40
  slices: under 2 px a step at 64 px/m), instead of slices rendered from a Blender model. Why: the
  sheet IS the approved look (drapes, tassels, gilded wheels), the slices need only a wall per side,
  and a Blender model would be a second, unapproved design. Rejected: Blender slice renders (no time
  to model to the sheet's fidelity this session; the route stays open: the same three PNGs can be
  rendered from a model). The front wall is the rear band with OUR grille (a gilded sunburst under a
  plum crest, round cream lamps) painted over: the sheet's slatted temple grille is a maker's trade
  dress (LEG-02). Tail lamps amber (hue 28, red is blood only). Alternative one move away: delete
  art/p55/car/ and KingCarStack's code slices draw again.
- FRICTION `draw_texture_rect_region(..., transpose=true)` drew the end band 2.5 m long past the nose;
  the ends now draw under a frame turned a quarter (no transpose).
- 15:20 MILESTONE throne-car walls (p55): before/after at 64 px/m (scratch car/shots/ba64.png): the
  black walls with a gold belt and drawn tyres become the sheet's side (glass band, gold belt, plum
  drapes with gold tassels, gilded spoked wheels, gold bumpers) and our grille on the nose.
- 15:13 Image round r5 (lock: asset lane yielded after image.want; 97 s, first try): the car's roof
  as a top plan + the empty throne from behind and from the front, from king_car_55.png. Velvet came
  crimson (hue 348-351): shifted -24 deg, value x0.85 (the bust's -32 read violet on a big area).
- 15:20 MILESTONE car roof + throne (p55), commit c18af566: `KingCarWalls.roof` draws the plan over
  the car's footprint; KingBodyView's code roof moved verbatim into `KingCarTrim.roof` (top: same
  draw calls, same colours; KingBodyView 243 -> 235 lines, debt baseline tightened). The throne is an
  upright card (textured quad in the car frame, upright on screen): the back when the tail faces the
  camera, else the front; narrowed to 0.7 side-on; 3.0 m face-on (1.9 m hid behind the 1.5x bust,
  3.3 m towered). The hood cannon (and its coins) stand on the art's laurel ring (0.33; top 0.2).
- 15:22 MILESTONE Servo's flying drone (p55) from the r4 sheet (turned 180, today's size), through
  ServoArt; test_servo_art's "no p55 art" example moved to the crate. Commit 30282892. Seen in flight
  over the drop rings at 48 px/m (gtai-masters/d8/bosses/servo_tilt48_drones_x3.png, from the clip
  servo_tilt48_drones_rotor_dash.mp4: launch, drop rings, the rotor dash lane at 21 s).
- Provenance: 7 rows (roof, throne x2, walls x3, drone). Decision line in docs/decisions.md.
- Unit: --select test_king_car_walls,test_servo_art,test_king_art 14/14; --changed earlier caught
  the servo test (fixed). Lint 15/15 on every commit.
- 15:33 Evidence (gtai-masters/d8/bosses/, frames.json 15 entries, the 4 new car/drone entries first):
  king_car_64_t720_before_after.png, king_car_64_t600_before_after.png, king_car_tilt32_after.mp4 +
  king_car_tilt32_before.mp4 (procession and the ram's tell, seed 2, 15 s; before = art folder moved
  aside), king_car_tilt32_ram_before_after.png, servo_tilt48_drones_x3.png,
  servo_tilt48_drones_rotor_dash.mp4. Raw avis deleted.
- 15:35 GATE director reel headless `--loadout=pistol --rigs --quit-after 8000` on a412f1ad: tilt 19/19
  chapters fully down, 0 SCRIPT ERROR; top 19/19, 0 SCRIPT ERROR.
- 15:37 GATE top identity, measured: a detached worktree of 8b0f9031 (before this session) vs HEAD,
  same seed: King `--view=top` tick 720 at 32 px/m md5 a88c7d73... both; Servo `--view=top` tick 1140
  (drones up) at 48 px/m md5 d1c09fbf... both. (Also art present vs moved aside: identical.)
- 15:40 GATES on a412f1ad: scenarios 52/52 (run_scenarios.mjs, no contended miss this time); unit
  1421/1421 (full run); lint 15/15. Phase 2 (court on the stalled car) at 48 px/m looks right: the King
  on the gilded throne card, the car's art walls and roof (scratch car/shots/late.png).
- 15:46 Close combat (item 5), Servo: `--loadout=katana` at 64 px/m, ticks 400/900/1500/2100; the bot
  never closed to contact, nearest ~3 m at 2100 (gtai-masters/d8/bosses/servo_vs_katana_64_close.png):
  the p55 parts hold (no mush). A true contact frame for Servo is still owed (a scripted melee or
  `--bot=rivet` duel). frames.json: 15 entries (combined clip bosses_d8_it2_combined.mp4, 37 s).
- Calls for the owner (add to REPORT): (4) the throne card's size: 3.0 m face-on, towering a head over
  the crown like the sheet (`KingCarWalls.THRONE_W_M`; 2.3 hid behind the bust); (5) the hood cannon
  moved onto the roof art's laurel ring under tilt (0.33 of the car vs 0.2; view only, coins follow;
  `KingCarWalls.ART_MOUNT_K`); (6) the car's walls are flush art (the wheels painted), main's drawn
  tyres stood proud of the body: same seed side by side in king_car_64_t720_before_after.png.

NEXT (iteration 3, in order):
1. The gang on foot at 64 px/m vs the claw, and the King on foot at 64 (press slam) with
   the new car parked behind: one before/after per figure for REPORT.
2. The hood cannon barrel from art (a gilded barrel strip, top view, in the r5 palette), and the
   car's bumper protrusion (KingCarStack.bumpers are skipped under the art stack).
3. Servo contact frame at 64 (claw and katana); the crate (kraft box) in the 55 palette via ServoArt.
4. Fold the court card strips into chars' `ViewMode.art` route once merged (rows in 14:47 entry).
5. Watch item: the King's arm over the bust card at melee range (RigDepthSort, chars').
6. At the freeze (18:30): export build/export/windows/RTAI.exe (int-day recipe), REPORT.md.

## Iteration 5 by the runner (session 3; 2026-11-06 15:47-16:47, BUILD)

- 15:47 Read JOURNAL, git log, chars' JOURNAL tail. Rules applied: `depth-ordered-layered-art` (the
  crate: shadow, ink pass, face slices, lid art last), `concept-scene-parity` (kraft parcels are cubes
  on the Servo sheet), `motion-quality-gating` (judged in the live arena, seed 2, 32 and 64 px/m).
- 15:50 The r4 Servo sheet holds no loose crate, and today's crate.png is already kraft (212,151,93,
  tape 244,205,154): no recolour owed. What was wrong under tilt is the SHAPE: the landed CS crates
  (cover, obstacles) lay flat as floor tiles beside the depot's standing crate stacks.
- 15:57 MILESTONE CS crates stand up under tilt (ServoCrateStack, 1091a211 + 0fa4b259): a lifted
  prism (12 solid slices, shaded 0.58 -> 0.8, the tape down the near face), the crate art as the lid
  at 0.9 m, the "CS" stencil on the lid, a cast shadow through RigCastShadows.sweep (the arena props'
  sweep). ServoDraw 202 -> 195 lines (the stencil moved out; debt baseline tightened).
  GATE top identity measured: Servo `--view=top` tick 1800 at 64 px/m md5 b1f14925... with the HEAD
  ServoDraw and with the new one. Unit --select test_servo_crate_stack,test_servo_art 6/6; lint 15/15.
  Evidence: gtai-masters/d8/bosses/servo_crates_tilt64_before_after.png, _tilt32_before_after.png.
- 16:00 Servo contact frame at 64 px/m (owed): `--ghost=kerf --loadout=katana` brings the boss bot into
  melee range (BossBotGhost.hold_m; the plain bot holds HOLD_M 8 m). Tick 500: Rivet's katana at
  Servo's visor; the p55 parts hold (gtai-masters/d8/bosses/servo_vs_katana_64_contact.png).
- 16:03 FINDING: Servo had no lift at all under tilt (ServoRig draws a flat cutout): beside an
  upright Rivet and the standing crates he read as a floor decal.
- 16:07 DECISION + MILESTONE Servo stands under tilt (d5765239, fc539407): the upper body draws
  ServoArt.STAND_M = 1.6 m over the feet (view.lift_at), the legs and pad arms stretch up to it (pads
  at half height), his footprint (4.4 x 2.4 m) casts the props' swept shadow; on defeat the lift
  sinks to the floor (ServoFall.stand_k, exp(-dt/16)). ServoRig held at 288 lines (comments trimmed).
  Alternative one value away: STAND_M = 0. Decision line in docs/decisions.md.
  GATE top identity measured: `--view=top` tick 1800 64 px/m md5 b1f14925... = HEAD before the session.
  Unit `--changed` (ran the full suite): 1408 passed, 0 failed. Lint 15/15 per commit.
  GATE director reel headless tilt `--loadout=pistol --rigs --quit-after 8000` on d5765239: 19/19
  chapters fully down, 0 SCRIPT ERROR. Phase-3 headless (`--phase=3 --ghost=kerf`): servo defeated,
  0 SCRIPT ERROR (the kill_char_fx shader warning under --headless predates this lane).
- 16:15 Evidence (frames.json 15, new first): servo_stands_vs_katana_64_before_after.png,
  servo_stands_tilt48_katana.mp4 (15 s), servo_stands_tilt32_before_after.png (also shows the crates),
  servo_crates_tilt64_before_after.png. Looked at every frame.
- Calls for the owner (add to REPORT): (7) Servo's stand height `ServoArt.STAND_M` (1.6 m; 0 = the
  flat rig): see servo_stands_vs_katana_64_before_after.png; exe `RTAI.exe -- --boss=servo --view=tilt`.
- 16:20 Gang close-up at 64 px/m vs Rivet (phase 2, tick 1000): helmets, plum bands, gold-framed shades,
  rope chains and gunmetal bodies hold (gtai-masters/d8/bosses/gang_tilt64_close_vs_rivet.png).
  frames.json: 15 entries (servo_vs_katana_64_close.png replaced by the contact pair, file deleted).
- 16:22 MILESTONE dropped parcels fall as boxes under tilt (7fffea59): ServoCrateStack split into
  draw (shadow + box) and box (no shadow: the falling parcel keeps its own closing shadow), so a
  parcel no longer falls flat and pops into a standing box on landing. GATE top md5-identical at
  tick 1100 with parcels in the air (7189d363...), HEAD vs new. Unit --select (4 servo files) 13/13.
  Evidence: servo_parcels_falling_tilt64_before_after.png (replaces king_p3_64_f300 in frames.json).
- 16:24 Checked the windup at 48 px/m (clip frame 100): the dash lane's tell starts at his lifted
  front, the visor line sits on the lifted head. NEXT item 3 closed.

- 16:24 GATES on 7fffea59 (the code tip): unit full no-arg run 1424/1424; scenarios 52/52 (on fc539407,
  run_scenarios.mjs; 7fffea59 is render-only Servo); director reel headless `--loadout=pistol --rigs
  --quit-after 8000`: top 19/19 fully down 0 SCRIPT ERROR (7fffea59), tilt 19/19 0 SCRIPT ERROR
  (d5765239); lint 15/15 per commit; top md5 identity measured for every change (16:07, 16:22).
  NOT RUN this session: evidence --no-bench (owed at the freeze with the export).
NEXT (iteration 6, in order; freeze 18:30):
1. (done 16:22: parcels fall as boxes.) The slung parcel under a flying drone is still flat (it
   turns with the drone; ServoCrateStack is axis-aligned): a turned box if it reads flat at 64.
2. The hood cannon barrel from art (a gilded barrel strip in the r5 palette) and the car's bumpers
   (KingCarStack.bumpers are skipped under the art stack).
3. (done 16:24.) Servo's hit radius is on the ground under the lifted body: watch whether a katana
   hit reads as landing on his legs at 64 px/m (a hit spark at the lifted torso is view-only).
4. A combined clip of the it3 set (Servo standing, crates, gang at 64) for frames.json.
5. At the freeze (18:30): export build/export/windows/RTAI.exe (int-day recipe in docs/decisions.md),
   evidence --no-bench, REPORT.md with Calls 1-7 (JOURNAL).
