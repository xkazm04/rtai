# JOURNAL: d9 lane `seams`

Branch `d9-seams` (cut from main 3982af1a). Evidence: `C:\Users\kazda\kiro\gtai-masters\d9\seams\`.
Scratch: `C:\Users\kazda\kiro\gtai-d9\scratch\seams\` (film.sh, raw avi). APPDATA `gtai-d9/appdata/seams`.

## Iteration 1 (09:49-10:49)

Read: brief, AGENTS.md, decisions tail, view/city n8 REPORTs (the barrier FOUND), the city patch,
view's lying WIP. Registry (resolved through index.json): `depth-ordered-layered-art` (the order is a
measurement: I measured which node draws the corpse before choosing the fix, and judged the frame,
not the counter; "reading a zero as a clean picture": city's 0 crowd patches meant the wrong source,
not a clean frame), `engine-integration-safety` (judge by what the run said: every Godot run's log
grepped for SCRIPT ERROR, 0 each), `motion-quality-gating` / `generative-artifact-gating` (looked at
every still myself; boards labelled before/after), `vehicle-archetype-balance` and
`top-down-vehicle-handling-model` read by heading for item 3 (a bike is a sidegrade: lighter and
quicker to turn, lower top speed; acceptance by measured scenarios, not by feel).

- 09:55 FRICTION: city's `extra` patch applies clean on main; wired PropCrowdOccluders (finds
  CityOcclusion under the layer by type) -> 47 arena props fed, but `crowd 0 patches` and the frame
  unchanged. Debug logs: no dead at all in the city sim snapshot near the barrier.
- 10:00 MILESTONE (measured cause): hiding every dead CutRig at tick 880 emptied the frame: the two
  dead cops behind the barrier are still full RIGS (the n8 notes blamed the crowd atlas). Their
  ground point is north of the barrier (y 25416 vs edge 25473 px) and they fell south, so
  PropOcclusion's standing box (feet up the screen) never met the barrier.
- 10:02 MILESTONE item 1: `PropLying` boxes a dead rig from its ground point to its drawn head
  (+0.45 m); PropOcclusion redraws the prop over it, no silhouette. View-lab occlusion 2 -> 95
  body-frames hidden over 901 frames; 0 SCRIPT ERROR. City's `extra` seam kept and fed (the baked
  crowd walking behind a barrier is the same class of bug). Commit 38a90b52.
  Evidence: `kerb_corpse_before_after_tilt70_32ppm_seed5_f900.png` (+ `_crop3x`),
  `kerb_corpse_before_after_tilt70_48ppm_seed5_f900_crop2x.png`.
- 10:08 MILESTONE item 2 (quick half): the cream backing under the King's legs is NOT in the PNGs
  (ink outline only, checked); it is RivetPlan's `leg_rim` sticker halo, inherited by KingPlan.
  Off under every card view; `top` keeps it (`KingPlan.LEG_RIM_TOP`), so look goldens hold.
  Commit 493d845c. Evidence: `king_legs_rim_before_after_combo_64ppm_seed2_f150_x2.png`,
  `king_legs_rim_before_after_combo_32ppm_seed2_f150_x3.png` (+ full frame), filmed with
  `--boss=king --phase=3 --bot=boss --seed=2 --rigs --view=combo --boss-cam` (boss-cam only to
  frame him; the game keeps the follow camera).

DECISION item 1: fix the lying rig in PropOcclusion (PropLying) rather than city's crowd path, because
the measured source is the rig; city's `extra` list lands too (agreed seam, cheap: 47 rects/frame).
Rejected: a fixed 1 m lying square (view's WIP: missed the cop fallen 2.3 m from his ground point).
Off = `PropLying.ON` / `PropCrowdOccluders.ON` false.
DECISION item 2: drop the leg rim under card views (one bool, `KingPlan.LEG_RIM_TOP` for `top`).

### REQUESTs
- REQUEST to assets: `king_legs_55` and `king_legs_70` (the King's drawn legs under his approved 2.0x
  bust card; owner 2026-11-07 "redesign legs of the character"). One PNG per pitch, camera as
  `king_bust_card` at that pitch (p55 / p70), transparent or #00B140 chroma, INK OUTLINE ONLY (no
  cream/white rim, no backing), the King's palette (plum tights, gold riveted bands, gold sabatons, as
  the current leg parts; no teal, no police blue, no red). Layout: 5 columns = the bust card's five
  facings in its order (front, 3/4 front-right, right profile, 3/4 back-right, back; left is the
  mirror) x 5 rows: row 0 standing, rows 1-4 one walk cycle (contact, pass, contact other leg, pass).
  Cell width = the bust card's cell width at that pitch (p55 218 px, p70 246 px), so the legs scale
  with the bust; the hip line in the top ~12% of the cell (the bust's hem overlaps it), the soles on
  the bottom ~6%; squat, wide-set legs (a boss on a 2.0x bust: short stocky legs, not Rivet's long
  pistons). Why: under the card views the bust stands on his old top-down leg parts; they read as
  parts, not a figure.

- 10:13 MILESTONE item 6: release_compile defaultDir = %TEMP%/gtai-release-compile/<worktree>-<hash8>/<pid>,
  removed in a finally. Two passes in parallel: 599 loaded / 0 failed each, both dirs gone. 6e49a298.
- 10:15 MILESTONE item 4: planter_v3 55 cut with city_prop_cut.py (the library names the sheet
  planter_55_v3.png, the tool wants <id>_<pitch>.png: copied into a scratch lib dir, read-only on the
  library); byte-identical to n8 city's scratch cut; provenance line. 3272969d. FRICTION: no planter
  on the routes I filmed (King's boulevard at tilt, frame 80): in-game frame owed.
- 10:15 gates: unit no-arg 1696 passed / 0 failed (at 966a2a79, items 1, 2a). Lint 15/15 at each commit.
- 10:17 director reel top/tilt70/combo started headless (`scratch/seams/reels.sh`, logs in evidence/d9-seams/).

Item 3 scope (read, not started): traffic cars are uniform in the sim (car_hit.cpp push distance 2.2 m,
car_hull's six sample points; no per-car mass); CitySpawner picks `CAR_ART[_rng.randi_range(0, 11)]`
and vmax 9-13 from the spawner's one stream. A bike needs: a per-art hull (half length/width) and push
share in the native core AND sim_cars.gd/sim_body.gd (parity 1200 steps), a `bike` row in
vehicle_handling.json (mass, vmax, accel), the share drawn from its OWN rng stream so the main
spawner sequence (and the scenarios) do not move when the share is 0, VehicleCards.ROWS 9 -> 10,
and a flat top print (traffic atlas row 9) cut from the bike card's top facing.

- 10:20 FRICTION: my first reel run omitted `--fixed-fps 60`; headless frames outran the sim ticks
  and `--quit-after 14000` ended `top` at tick ~6300 (17/19 down, 0 SCRIPT ERROR). Harness error,
  not a regression: killed my own run (taskkill /T on its timeout.exe), re-running all three with
  `--fixed-fps 60` (as the n8 gates did).
- 10:24 ACK assets: `king_legs` 55 (B: side stride short, col 1 row 3 shows a sole) and 70 (B: drawn
  too tall, ~40 % of the figure vs the approved stubs ~16 %; v2 queued) are in the catalog,
  keyed/boss/king_legs_{55,70}.png in my layout (55: 1090x670, cells 218x134; 70: 1230x490, cells
  246x98; soles at 94 %, hip centred under the bust column). Thank you. I build 55 now; 70 waits for
  v2 (or a squash value). The 55 mock under the bust (library evidence/king_legs/) reads as one figure.

Plan, the King's drawn legs (it2): `KingLegsCard` (features/bosses/king/, <120 LOC), called from
KingArt.dress: when `art/p<pitch>/king_legs.png` exists, a Sprite2D sibling of the bust card (same
parent and scale; hframes 5, vframes 5; column = the bust card's facing frame, flip_h with it; row 0
standing, rows 1-4 the stride by the rig's walked distance like StreetQuestCards.PATROL_WALK),
offset (-cw/2, -ch*0.94) at the feet, z just under the bust; the leg part sprites (thigh, shin,
foot, both sides) hidden while it shows. Data row like STRIPS: [name, soles anchor 0.94,
squash_y 1.0 (70: ~0.7 until v2)]. Provenance per cut. Film combo 32/64 (standing + walking),
before = today's parts. Then the owner call on the overlap (REPORT call 1).

- 10:24 MILESTONE gates: director reel `--fixed-fps 60 --quit-after 14000` (headless) top 19/19,
  tilt70 19/19, combo 19/19 down, 0 SCRIPT ERROR each, clean logs (49281aeb). The first combo log
  had NUL bytes: my first (stopped) script's loop survived TaskStop and wrote the same file; combo
  re-run alone. Lesson: TaskStop does not stop a script's later loop iterations; kill by tree.
- 10:27 MILESTONE (partial) item 2b: KingLegsCard + art/p55/king_legs.png + provenance, shipped OFF
  (935fc30b). FINDING: the 2.0x bust card reaches the ground, so legs with their soles on the ground
  point stand hidden behind it; LIFT 0.5 (the bust raised by half the legs' cell) shows the drawn
  legs well (steel shins, gold sabatons, reads as his), BUT the press-plate arm parts stay at the old
  height: a plate hangs by his feet (masters `WIP_king_drawn_legs_lift0.5_combo_64ppm_seed2_f150_parts_vs_legs.png`).
  Fix next: raise the whole upper body (the rig's arm parts with the bust) by the same lift, then ON.
DECISION item 2b: ship the legs card OFF this iteration (a detached arm plate is worse than the old
legs); the bust's lift onto the legs is the owner's call 1 (default to build: 0.5 of the legs cell).

NEXT:
1. Reels done (19/19 x3). Re-run `scratch/seams/reels.sh` (--fixed-fps 60) after every gameplay-touching change.
2. Item 2 second half FIRST: KingLegsCard is in (OFF). Lift the arm parts with the bust (find where the
   rig's upper body is offset: RigTilt.body_lift / rig.body), set ON, film combo 32/64 standing + walking.
3. Item 3 sim bike (scope above): native C++ + GDScript twin (parity 1200 steps), vehicle tables,
   art id 9, its own rng stream for the share, flat top print for `top`.
4. Item 5: armed walk strips at 70 are in the catalog: cop_patrol_walk_armed_v2 (B, 20261107-1030)
   and cop_riot_walk_armed_v4 (A, 20261107-1050); build the grid as StreetQuestCards.PATROL_WALK.
5. The planter's in-game frame (find a planter: city_facades props); `node tools/evidence/run.mjs
   --no-bench` (scenarios, parity, top bit-identical) before the next REPORT update.

## Iteration 2 (10:28-11:28), BUILD

Read: JOURNAL it1, git log, d9-rivet JOURNAL (it3: RivetFrames in, nothing asked of seams), catalog
(king_legs 70 v2 not landed yet). Registry rules applied this iteration: depth-ordered-layered-art
(the legs card one z under the bust, the upper body as one lifted group so no part floats between
layers), engine-integration-safety (native and GDScript twin op-for-op; plain doubles, never Vector2
in the twin; parity with the new branch exercised, not just the old one), vehicle-archetype-balance
(the bike's mass ratio drives its push share, its hull and footprint from its drawn size),
generative-artifact-gating (looked at every frame and the plan print before landing it).

- 10:33 FRICTION: filmed the King with `res://boot/main.tscn` (no boss flags: ignored) then the arena
  without `--bot=boss --boss-cam` (a static frame: nobody moves). The it1 flags are in frames.json:
  `--boss=king --phase=3 --bot=boss --seed=2 --rigs --view=combo --boss-cam`. 4 min lost.
- 10:34 FINDING: the legs card is a child of the head (card's parent), so lifting the torso lifted the
  legs too (hidden behind the bust again). Fix: lift the torso first, then pin the legs to the ground.
- 10:35 MILESTONE item 2b: the King's drawn legs ON at 55 (7f522e54). KingLegsCard lifts the whole
  torso (head card + arm parts: the press plates sit at his sides) by LIFT 0.5 of the legs cell; RigTilt
  sets torso.position fresh each step, so no drift. Unit test: soles on the ground point, torso up.
  Masters: `king_drawn_legs_before_after_combo_64ppm_seed2_f150_x2.png`, the 64 px/m clip, a 4-beat
  grid, the 32 px/m before/after. 70 keeps the rim-stripped parts until king_legs_70 v2 (combo eases to
  55 at the engage, so the fight itself is on the drawn legs).
- 10:37 MILESTONE gates: director reel it2 (legs ON) top/tilt70/combo 19/19 down, 0 SCRIPT ERROR (bb2c1df8).
- 10:43 FRICTION: the worktree's native/godot-cpp submodule is empty; copied int-day's built copy
  (same pinned commit e103d348, read-only on int-day). Debug DLL 2 min, release ~8 min.
- 10:45 MILESTONE item 3 (sim): the bike in the native core and the GDScript twin (car_hit.cpp
  car_push / bike hull / footprint; CitySimCarPush). Parity: native == reference bit for bit over 1200
  steps with a QUARTER of the parity traffic bikes (city_parity sets share 0.25 from its own stream),
  planted mutation caught at step 629.
- 10:54 MILESTONE item 3 committed (e8c6ad01): constants via gen_constants (exact floats: hull 1.0 x
  0.375, footprint 1.25 x 0.625, reach 1.75 / 1.25, share 0.875 = 1400 / (1400 + 200)); the
  `bike` profile in vehicle_handling.json (mass 200, vmax 24; a hijacked bike drives on it);
  traffic.bike_share 0.06 from rng stream `city_bikes`; the 3 x 4 traffic atlases with the bike's plan
  print at cell 9 (tools/art/bike_top_print.py). Unit 1689/0 (--changed: full fast suite).
- 10:56 FINDING (filmed main scene seed 7, frames 420-480): the bike passes in traffic at tilt70 (card
  row 9) and in top (cell 9). Two faults: (1) in `top` the look's item shader re-inks the card's gold
  tank as RED (colour rule): the print becomes a cream/ink duotone (tool updated, lands after the
  evidence run); (2) the bike has NO RIDER at either pitch: a riderless bike in traffic reads as a bug
  at close range. REQUEST below; owner Call.

DECISION item 3: car vs car keeps its exact old code path (C++) and arithmetic (twin), so a city with no
bikes steps bit-identically; the bike's share comes from its own stream so the cars' spawn draws do not
move; scenarios that build their own CitySpawner (city_chase, streaming) get no bikes. Alternative one
value away: `traffic.bike_share` 0 = no bikes. Rejected: per-art hull tables in the sim (more parity
surface for one archetype).
DECISION item 3: the `top` print is the 70 card's tail facing (nearly plan at 70), turned nose to +x,
2.1 m at 80 px/m, cream/ink duotone. Rejected: an AI top-down image now (no image lock needed for a
REQUEST; the asset lane serves it better).

### REQUESTs
- REQUEST to assets: `bike_rider_55` and `bike_rider_70` (the sim bike in traffic carries no rider; a
  riderless motorbike reads as a bug). The same bike as bike_v3 (rows/cells as vehicle_cards.py BIKE:
  5 facings nose-to-camera .. tail, same cell size and ground centre) WITH a civilian rider seated
  (helmet, jacket in the street cast's muted palette; no teal, no police blue, no red, no vermilion), ink
  outline, transparent or #00B140. Plus `bike_rider_top`: the same bike and rider straight down, nose to
  +x, 2.1 m long, for the flat traffic atlas (cream/ink print like the cars). Why: owner Call 3 -> b
  (a sim bike); the bike now drives in traffic at 6 %.
- 11:03 GATE (e8c6ad01, share 0.06): lint 15/15, unit 1705/0, scenarios 52/52, parity bit-exact (bikes
  in it), release-compile 601/0, BUT selftest FAIL: top look goldens 2/11 within mean 4 (worst 14.56).
  Re-ran selftest alone with traffic.bike_share 0: look goldens 11/11 (worst 0.27). The bikes in
  traffic are what moves `top` (they replace cars in the golden frames).
DECISION item 3: the bike ships at traffic.bike_share 0 (binding: `top` look goldens must not move);
`--bikes=<share>` (boot: LaunchArgs -> CitySystem.bike_share) shows them for filming and the owner's
exe. Turning them on = one data value + a top look-golden rebaseline (owner Call). Rejected: moving the
goldens now.
- 11:06 MILESTONE item 3 art: the top print is a cream/ink duotone now (no red), 84a774a5. Filmed
  `--bikes=0.25` seed 7 (masters `sim_bike_top_vs_tilt70_32ppm_seed7_f420_x2.png`, two 4 s clips).
  FRICTION: the first `--bikes` read went through OS.get_cmdline_user_args in CitySpawner: the debt
  ratchet (direct_cmdline_reads 157 -> 158) failed the commit; moved to boot/world.gd via LaunchArgs.
- 11:05 item 5 scoping: street_walk.py cuts both armed sheets cleanly at 70 (scratch
  `gtai-d9/scratch/seams/cops/`: cop_patrol_walk_armed_70_v2 B -> 5 x 4 of 173 x 192, two-handed
  pistol; cop_riot_walk_armed_70_v4 A -> 5 x 4 of 148 x 192, baton + shield). NOTE the riot sheet's
  armband is orange (near vermilion: colour rule) -> check against cop_riot_card's before landing.

NEXT:
1. Re-run `node tools/evidence/run.mjs --no-bench` at the head (it2 close run below; expect selftest
   11/11 at share 0) and the reels (`scratch/seams/reels2.sh`) if gameplay code changed.
2. Item 5 armed cops walk (70): StreetWalkerCards.strip_of returns "" for cops unless down. Add a
   COP_WALKS {"p70": {"cop/head_cap": "cop_patrol_walk_armed.png", "cop/head_helmet":
   "cop_riot_walk_armed.png"}} used when a cop is alive, moving (speed_now > MOVING), not aiming, no
   c_recoil/strike, not hit; the held weapon part + RiotShieldCard must hide while the strip shows
   (check what _build's hid list covers). street_tone.py to match the card's navy. WALK_FILL per file.
   Film the city block `--arena=city --seed=5 --rigs --view=tilt70` 32/48 px/m, before = head cards.
3. Item 2: king_legs_70 v2 when it lands (art/p70/king_legs.png; the 70 strip ~40 % too tall: squash
   or wait). The planter's in-game frame (item 4) still owed.
4. Item 3 owner Call: bikes ON (0.06) needs a top look-golden rebaseline; a rider (REQUEST above).
   After merge the Director must rebuild native (`just native`): project/native/bin is git-ignored.
5. REPORT.md: Calls 1 (legs lift), 3 (bike share/rider) updated with it2 evidence.
- 11:21 GATE (eac11147, share 0): lint, scenarios 52/52, parity bit-exact, selftest look goldens 11/11
  (worst 0.27), release-compile 601/0 PASS; unit 1705/0 but flagged by the tree-changed guard
  (FRICTION: I edited REPORT.md during the run; next time edit nothing in the worktree while it runs).
  Logs `evidence/d9-seams/evidence-it2-*.log`. REPORT updated (works 4-5, Calls 1 and 3).
- Item 5 detail for NEXT 2: StreetWalkerCards._build hides every CanvasItem under the rig (held
  weapon and shield parts included) and picks vframes by the file suffix: name the grids
  `cop_patrol_armed_walk.png` / `cop_riot_armed_walk.png` (must end `_walk.png`); release() restores
  the parts and drops back to the head card when strip_of returns "" (stopped, aiming, firing, hit).

## Iteration 3 (director it5, 11:24-12:24), BUILD

Read: JOURNAL it2, git log, d9-rivet JOURNAL (it6: no REQUEST to seams; a "grey blob" near Rivet in the
Servo fight is theirs to identify first), catalog: bike_rider 55/70 (A) + bike_rider_top_v1 (A) and
king_legs_70_v2 (B) have landed. Plan: item 5 (armed cop walk at 70) first, then the bike rider, then
king_legs 70.
Registry rules applied: depth-ordered-layered-art (one whole-figure card replaces head card + parts,
the parts hidden not freed, so a strike's swing still draws on the parts), sprite-and-atlas-production
(the grids keep street_walk.py's cell layout and the walk fill per file), motion-quality-gating (no swap
per shot: the grid holds through aim and fire), generative-artifact-gating (looked at both sheets cell
by cell before landing; the riot sheet's orange armband broke the colour rule and was greyed).
- 11:31 MILESTONE item 5 (49ad9fd6): StreetCopWalk; every living city cop at 70 (patrol cap, riot
  helmet) walks as its drawn armed grid (pistol two-handed / baton + shield), stepping by rig.phase,
  stand frame when still. Grids: cop_patrol_walk_armed_v2 (B) + cop_riot_walk_armed_v4 (A), toned to
  the cop cards' navy (street_tone.py); the riot armband orange -> steel grey (new
  tools/art/street_armband.py). StreetWalkerCards stays 200 lines (cop branch moved into strip_of).
  Masters: `cop_armed_walk_before_after_tilt70_48ppm_seed5_f400_x1.5.png`, `..._32ppm_seed5_f400.png`,
  before/after 8 s clips at 48. Unit 20/0 (--select), lint 15/15. FINDING: the SWAT cops (helmet +
  visor, pistol) still draw head card over parts: no armed SWAT sheet exists. 55 has no armed grids.
DECISION item 5: the grid holds through aiming and firing (the drawn arms already point the weapon
along the facing; a swap per shot flickers); a baton strike, a throw or a reload shows the parts.
Alternative one value away: StreetCopWalk.ENABLED false = head cards (before). Rejected: a grid only
while not aiming (city cops aim most of a fight: they would flicker between the two looks).
- REQUEST to assets: `swat_walk_armed_70` (the SWAT cop: helmet + visor, pistol held two-handed, as
  cop_patrol_walk_armed_70_v2's layout: 5 facings nose-to-camera .. back x 4 stride rows, contact/pass/
  contact/pass, same cell size, transparent or #00B140; NO orange/red armband: vermilion is reserved).
  Then the three armed walks at 55 (`cop_patrol_walk_armed_55`, `cop_riot_walk_armed_55`,
  `swat_walk_armed_55`) to the same layout, drawn as the 55 cop cards. Why: brief item 5; every city cop
  is armed from tick 60 and the SWAT and every 55 cop still glide on head cards over parts.
- 11:40 MILESTONE item 3 rider (f9f348b6): the sim bike carries a seated rider at both pitches (card row 9
  from bike_rider_70/55, A) and in `top` (cell 9 of the five traffic atlases from bike_rider_top_v1, A,
  cream/ink duotone). vehicle_cards.py BIKE_RIDER (False = riderless bike_v3), bike_top_print.py RIDER.
  Re-cutting the p70 atlas no longer reproduces rows 0-8 (the library moved since n8), so only row 9 was
  pasted into the committed atlases (rows 0-8 byte-identical). Masters `sim_bike_rider_top_vs_tilt70_
  32ppm_seed7_f420_x2.png`, `..._crop3x.png`, two 5 s clips. FRICTION: the first film showed the old
  riderless bike: a changed PNG needs `--import` before a non-editor run (3 min). FINDING: --ppm only
  works in the arena scene; the main scene films at 32 (my "64" capture was 32: deleted).
- 11:46 GATE evidence at f74bb3ed (items 5 + rider): lint 15/15, unit 1711/0, scenarios 52/52, parity
  bit-exact, selftest look goldens 11/11 (worst 0.27), release-compile 602/0: all PASS. Log
  `evidence/d9-seams/evidence-it3-f74bb3ed.log`. FRICTION: the first try refused a dirty tree (my own
  JOURNAL edit + the log written inside the worktree): logs now go to scratch, copied in afterwards.
- 11:52 MILESTONE item 2 at 70 (4aa2a0e0): king_legs_70_v3 (A; the assets lane's v3 drops v2's hip
  ring) under the 70 bust; KingLegsCard.LIFT is per pitch now {55: 0.5, 70: 0.74} (0.74 = sole line 0.94
  - the assets lane's 0.2 hem overlap); the 55 sheet swapped to king_legs_55_v2 (A, the profile strides;
  v1 B was in). Masters `king_legs70_before_after_tilt70_{64,32}ppm_seed2_f150_x{2,3}.png`, clips at 64
  (tilt70) and the 55 v2 combo clip. Before at 70 he was a bust with no legs at all.
  FINDING: a small dark disc with a cream rim shows under his boots at both pitches: the pelvis part,
  which stays at ground height (it was hidden behind the un-lifted bust). Fix next: KingLegsCard hides
  rig.pelvis_spr with the leg parts (after the reels: they reload scripts per view).
DECISION item 2 (70): LIFT 0.74 at 70 (the assets lane's mock overlap 0.2 read as the approved king_70
stubs); one value per pitch in KingLegsCard.LIFT. Rejected: v4 (B: hollow thigh tubes show under the hem).
- 11:55 GATE director reel it3 (at 4aa2a0e0: armed cops, rider, legs 70): top, tilt70, combo 19/19 down, 0 SCRIPT ERROR (`evidence/d9-seams/director-reel-it3-*.log`).
- 11:59 FIX (item 2): KingLegsCard.show_parts hides rig.pelvis_spr with the leg parts; the rimmed disc under the boots is gone at 55 and 70 (masters `king_pelvis_before_after_combo55_tilt70_64ppm_seed2_f150_x2.png`); unit test_king_legs_card 5/0.
- 12:05 FRICTION item 4 (planter's in-game frame): the King's boulevard "planters" are crate stacks in
  the arena; the streamed city paints planters sparsely (tile_painter) and none showed in the main scene
  (--view=tilt seed 7) or the arena block (--view=tilt seed 5) at frame 180. 6 min, no frame yet.

NEXT:
1. Item 4 in-game frame: `dev/showcase/d5_hero_run.gd` places a planter at (-9.6, 4.85): film it under
   `--view=tilt` (p55) at 32 and 64 (check its args), else find a planter tile in the streamed city
   (tile_painter's prop slots) and teleport there.
2. Item 5 follow-ups: when assets serve `swat_walk_armed_70` and the 55 armed walks (REQUEST it3), add
   rows to StreetCopWalk.WALKS + FILL (street_walk.py, street_tone.py; street_armband.py if orange).
   Judge a cop's baton strike swap (grid -> parts -> grid) in motion at 48 px/m; if it pops, consider a
   short hold or keeping the grid through the strike.
3. Item 2: the owner's Call 1 (lifts 55 0.5 / 70 0.74). Film the King walking at 70 across the ease to
   55 (combo, before the engage) to check the swap between the two leg sheets.
4. Item 3: bikes stay at share 0 (Call 3). The rider is in; nothing owed unless the owner turns them on
   (then rebaseline the top look goldens).
5. Re-run `node tools/evidence/run.mjs --no-bench` (logs to scratch, then copy in) at the head; the
   reels ran at 4aa2a0e0 (19/19 x3); bb7077f5 only hides the King's pelvis (render).
6. Rivet lane asked nothing of seams (its "grey blob in the Servo fight" is theirs to identify first).
- 12:01 GATE unit no-arg at cf2bae52 (incl. the pelvis fix bb7077f5): 1713 passed / 0 failed.
- 12:04 NOTE for NEXT 1: d5_hero_run draws the old flat props (features/city/art/props/), not the p55
  cards: dead end. Planters only dress PLAZA tiles (tile_painter.PLAZA_PROPS / PLAZA_SLOTS, 3 slots a
  tile): find a plaza tile in the streamed city (the baked chunk map) and start there under `--view=tilt`.

## Iteration 4 (director it6, 12:04-13:04), BUILD

Read: JOURNAL it3 + NEXT, git log, d9-rivet JOURNAL (no REQUEST to seams), library JOURNAL + catalog:
round 1310 served my it3 REQUEST: swat_walk_armed_70_v2 (B, row 5 mirror-fixed in post; a fresh
profile row 3 queued as round 1315), cop_patrol_walk_armed_55 (B), cop_riot_walk_armed_55 (B; v2 C);
swat_walk_armed_55 not graded yet. ACK assets' NOTE: the riot patch is hue 22 (not vermilion); the 55
riot sheet draws no band at all, so nothing to grey there.
Registry rules applied: sprite-and-atlas-production (street_walk.py's one cell per grid, the fill
measured per grid), generative-artifact-gating (looked at all 60 cells before and after the tone),
motion-quality-gating (before/after at the same seed and frame, the clips in motion),
depth-ordered-layered-art (a whole-figure card replaces head card + parts; parts hidden, not freed).
- 12:09 MILESTONE item 5 (ffbb9c44): SWAT at 70 + patrol and riot at 55 walk as drawn armed grids.
  Toned to their cards' navy (street_tone.py: swat hue -6.7 v x1.27; patrol55 royal -> navy v x0.62).
  StreetCopWalk.FILL is keyed `<art>/<file>` now: the 55 and 70 grids share file names (fill_of takes
  the resource path). FILL measured: swat70 1.14, patrol55 1.07, riot55 1.09. At 70 every city cop
  is now a drawn figure; at 55 only SWAT still draws head card over parts (swat_walk_armed_55 owed).
  Masters: `cop_armed_walk55_before_after_tilt_{48ppm_..._x1.5,32ppm_...}.png`,
  `swat_armed_walk70_before_after_tilt70_48ppm_seed5_f400_x1.5.png`, 6 s clips before/after.
  FRICTION: my first SWAT "before" came from the it3 mp4 (trimmed -ss 1: not frame-aligned, a different
  scene); re-filmed with only the SWAT row removed (3 min).
- 12:19 GATE evidence at 16eb6d86: lint 15/15, unit 1713/0, scenarios 52/52, parity bit-exact,
  selftest look goldens 11/11 (worst 0.27), release-compile 602/0: all PASS; director reels at
  16eb6d86 top/tilt70/combo 19/19 down, 0 SCRIPT ERROR (logs ran to scratch, copied in: no tree guard).
- 12:15 FINDING item 2 (NEXT 3 of it3): the King's 70 -> 55 leg-sheet swap never shows in play: under
  combo he engages at tick 1 seated in his car, the art key flips to p55 at tick 32 of the ease, and he
  is on foot only in phase 3 (at 55). Nothing owed.
- 12:22 MILESTONE item 4 filmed (6f28481c): city_frame focus 11 (a plaza, two planters, found by a
  scratch scan of CityGen chunks for prop 33) + `--view` let through (ViewMode reads it). v2 -> v3 pair at
  64 and 32 (masters `planter55_before_after_*`). FRICTION: city_frame's FOCI comment growth tripped
  the dev_loc debt ratchet (+5) and gdlint line length: folded into existing lines (net 0 lines).
- 12:26 MILESTONE item 5 (d6ffd600): the asset lane's fresh SWAT 70 profile row (round 1315, A, as
  trimmed cells) spliced into the keyed v2 sheet on the old row's foot line (scratch
  `cops2/splice_row.py`), re-cut; swat_walk_armed_55_v2 (B, interim) lands at 55 (FILL 1.07). Every
  living city cop now walks drawn at 55 and 70. Masters pair at 55 re-shot with SWAT in.

NEXT:
1. Round 1320 (assets: fresh rows patrol55 r3, riot55 r2/r3/r4, swat55 r2/r3/r4) as
   `<strip>_rfresh_cells/`: splice each fresh row with `scratch/seams/cops2/splice_row.py <keyed> <cells>
   <row> <out>` (one row per call, chain them), then street_walk.py + street_tone.py (refs: the p55
   cards), re-measure FILL, film seed 5 tick 400 at 48. Provenance line per file.
2. Judge a cop's baton strike swap (grid -> parts -> grid) in motion at 48 px/m (riot cops strike
   in the arena city block, seed 5); if it pops, hold the grid through the strike.
3. Item 4: owner eye on the v3 planter at 32 (dark mass); a value lift is a city-tool question.
4. Calls 1 and 3 stand (legs lift, bike share 0). Freeze 18:30: export RTAI.exe, REPORT final.
- 12:31 MILESTONE item 5 (e6ba3ec3): round 1320-1330 fresh rows landed at 55 (patrol r3 A, riot r3 A +
  r4 B, SWAT r2-r4 A), spliced with `scratch/seams/cops2/splice_row.py`, re-cut, re-toned; FILL patrol
  1.07, riot 1.09, SWAT 1.08. Masters 55 pairs (48 x1.5, 32) and the after clip re-shot. Seen: the SWAT
  55 fresh 3/4-toward row is ~8 % shorter than the front row (a small pop on that turn).
- 12:34 FINDING item 5 (NEXT 2): with a temporary log in StreetCopWalk.strip_of (reverted), 3600 ticks of
  the arena city block (seed 5, tilt70, windowed) had no cop strike, throw or reload, and the director
  reel (headless, tilt70) logged none either (whether the card views step headless is unchecked). The
  grid -> parts swap is rare in play; judging it in motion needs a staged melee (a riot cop next to
  Rivet). Not built.

NEXT (it5):
1. Item 5: a staged baton strike at 48 px/m to judge the grid -> parts swap (a dev flag or the reel's
   riot_cop chapter windowed: `--bot=reel --reel=director --view=tilt70`, ticks 5040+); if it pops,
   hold the grid through the strike (StreetCopWalk.strip_of: drop the strike_arm test).
2. Item 5 art: REQUEST to assets if wanted: swat_walk_armed_55 row 2 at the front row's figure height;
   cop_riot_walk_armed_55 row 2 (repeats).
3. Item 4: owner eye on the v3 planter at 32 (a dark mass); a value lift is city's tool.
4. Re-run `node tools/evidence/run.mjs --no-bench` (logs to scratch) at the head: d6ffd600 + e6ba3ec3 are
   art + FILL only since the it4 gate (16eb6d86); the reels if gameplay code changes.
5. Freeze 18:30: export RTAI.exe, REPORT final (Calls 1 and 3 stand).
- 12:40 FINDING (NEXT 1 tried): the director reel windowed at tilt70 48 px/m to tick 5700 (through the
  riot_cop chapter at 5040) with the temporary log (reverted): cops step every frame (COPDBG samples),
  but none strikes, throws or reloads. The grid -> parts swap is not seen in the judged scenes; leave
  the rule as built (drop NEXT 1 unless a staged melee shows it).
- 12:46 GATE evidence at 6110bbf9 (the 55 fresh rows, SWAT 55/70): lint 15/15, unit 1713/0, scenarios
  52/52, parity bit-exact, selftest look goldens 11/11, release-compile 602/0: all PASS
  (`evidence/d9-seams/evidence-it4-6110bbf9.log`). Gameplay code unchanged since the it4 reels (16eb6d86:
  19/19 x3), only art + FILL.
- REQUEST to assets: `swat_walk_armed_55` row 2 (3/4 toward), a fresh row at the front row's figure
  height: the round-1320 row 2 (A) draws ~8 % shorter than row 1 in the game grid (street_walk.py fits
  all 20 in one cell), so the SWAT shrinks on the front -> 3/4 turn at 55. And `cop_riot_walk_armed_55`
  row 2 (3/4 toward; repeats frame 1 as 3; your fresh try was C). Same layout and drop-in
  `<strip>_rfresh_cells/` names. Why: brief item 5; the 55 armed cops are what combo fights show.
- 12:48 ACK assets: rounds 1310-1330 consumed (swat 70 v2 + row 3, patrol/riot/swat 55 + fresh rows).

## Iteration 5 (director it7, 12:49-13:49), BUILD

Read: JOURNAL it4 NEXT, git log, d9-rivet JOURNAL (it10: **REQUEST to seams**: the Servo bay number
prints over every actor under a card view, servo_body_view.gd:39), library JOURNAL (it79: riot55 r2 and
patrol55 r2 NO GAIN after 3 tries, stopped; my it4 REQUEST rows are named faults, nothing new to splice).
Registry rules applied: depth-ordered-layered-art (a ground decal stays under the bodies; only what a
car would wrongly hide is lifted, and only where nothing stands), motion-quality-gating (before/after at
the same seed and frames, a clip in motion).
- 12:55 MILESTONE (rivet REQUEST, 3f4732db): `ServoDepotDraw.cover()` flags per frame the bays whose
  NUMBER a living fighter's body box meets; those marks draw in the ground pass (under bodies), the rest
  keep the apart pass over the vehicles band. Masters
  `servo_bay_number_under_bodies_before_after_combo_48ppm_x2_seed1_f480.png` + `_f400_500.mp4`: "4" now
  under Rivet's gun and legs, "3" still over the van. unit test_servo_depot_marks 4/0, `--changed` 1701/0,
  lint 15/15. FRICTION: my first cut tested the whole apron: Servo (beside the van) met bay 3's apron and
  dropped "3" under the van (the n8 regression); caught on the first still, narrowed to the glyph box (4 min).
  The misfilmed full-frame pair was deleted from masters.
- ACK rivet it10 REQUEST (Servo bay number over actors): served at 3f4732db, evidence above.
DECISION Servo bay marks: see docs/decisions.md (glyph box test; whole-apron and always-under rejected).
- 13:00 GATE director reel it5 at 3f4732db (Servo marks): top, tilt70, combo 19/19 down, 0 SCRIPT ERROR
  (`evidence/d9-seams/director-reel-it5-*.log`).
- 13:02 MILESTONE item 5 (ddef1441): the SWAT 55 walk's 3/4-toward facing (the round-1320 fresh row, my
  it4 finding) scaled 1.06 about each figure's sole by a new repo tool `tools/art/walk_facing_scale.py`
  (grid F:K; places by the scaled figure's measured sole, so no foot-line bob; fails if a figure leaves
  its cell). Measured first: helmet 52 px vs 57-61 in the other facings, head line 12 px under the
  front's (192 px cell); 1.06 splits the height (3 %) and helmet (10 %) gaps. FILL 1.08 -> 1.07 (mean
  figure height 177.3 -> 179.4 px). Masters `swat55_facing2_scale106_before_after_grid.png`. In game
  (seed 5 tilt 48 px/m, f0-460) no SWAT shows facing 2: the before/after film differs only by FILL's
  1 % step (`..._ingame_..._fill_only.png`, labelled as such). The 70 grids measured too: no facing
  outlier (the back rows run tall in every grid: a drawing convention, left).
  WITHDRAWN REQUEST to assets: `swat_walk_armed_55` row 2 (fixed in post, ddef1441). The riot 55 row 2
  request stays closed as your NO GAIN (3 tries).
- ~13:05 MILESTONE the combined clip owed by the brief: `gtai-masters/d9/seams/seams_d9_set_combined_52s.mp4`
  (10 captioned segments, items 1-5 + the Servo marks at 1/3 speed; one frame per segment looked at).
  frames.json: 15 entries, the clip first, the Servo pair second (the 32 px/m cop pair at 70 and the King
  f150-450 grid out of the list, files kept).
- ~13:09 GATE evidence at ddef1441 (Servo marks + SWAT 55 scale): lint 15/15, unit 1717/0, scenarios 52/52,
  parity bit-exact (planted caught), selftest look goldens 11/11 (worst 0.27) + block 5/5, release-compile
  602/0: all PASS (`evidence/d9-seams/evidence-it5-ddef1441.log`; ran to scratch, copied in).
- ~13:10 FINDING + fix (item 5): the riot 55 profile column (the round-1330 fresh row 3, A) is the same
  fault: head line 24 px vs 13 and 19 on its neighbour facings. Scaled 1.06 with walk_facing_scale.py
  (head line -> 13), FILL 1.09 -> 1.08 (mean 174.55 -> 176.75 px); test_street_cop_walk pins 1.08.
  Patrol 55 measured: no outlier. Masters `riot55_facing3_scale106_before_after_grid.png`.
- 13:15 MILESTONE (0d8842bf): the riot 55 profile scale landed and filmed in play: seed 5 tilt 48 px/m f62,
  a riot cop walking in profile beside a SWAT, before visibly smaller, after the same height
  (`riot55_facing3_scale106_before_after_tilt_48ppm_seed5_f62_x3.png`, `..._f20_140.mp4`). test_street_cop_walk
  6/0. frames.json: in at 3 (the riderless bike clip out, file kept). DECISION line in docs/decisions.md.

NEXT (it6):
1. Gates at the head (0d8842bf: art + FILL + one test value since the it5 gate at ddef1441): `node
   tools/evidence/run.mjs --no-bench` (logs to scratch, no worktree writes while it runs). Reels only if
   gameplay code changes (it5 reels at 3f4732db: 19/19 x3).
2. The SWAT 55 facing-2 fix is not yet seen in play (no SWAT turned to it at seed 5 f0-460): try seed 5
   past f460 or another seed under `--view=tilt` at 48 px/m; or the director reel windowed at combo.
3. Riot 55 row 2 still repeats a frame (assets: no gain in 3 tries). A post option to judge: copy row 2
   frame 1 from row 1/3 shapes is not honest; leave as named fault unless assets retry.
4. Owner Calls 1-3 stand. Read d9-rivet and assets journals for REQUESTs first.
5. Freeze 18:30: export RTAI.exe (`"$GODOT_BIN" --headless --path project --export-release windows-showcase
   ../build/export/windows/RTAI.exe`), REPORT final by 18:40.
- 13:25 GATE evidence at 407cc4f8 (the riot 55 scale in): lint 15/15, unit 1717/0, scenarios 52/52, parity
  bit-exact, selftest look goldens 11/11, release-compile 602/0: all PASS
  (`evidence/d9-seams/evidence-it5b-407cc4f8.log`). NEXT 1 of it6 is done.
- NOTE to assets (your 13:03 check, "the cells delivered to d9-seams are within 2.5 %: nothing owed"):
  agreed for each fresh row against the row it replaced. My finding is against the NEIGHBOURING FACINGS:
  swat_walk_armed_55 row 2 and cop_riot_walk_armed_55 row 3 were drawn ~6 % small against rows 1/3 and
  2/4 (head line + head width). I scaled them 1.06 in post (ddef1441, 0d8842bf), so nothing is owed. A check
  you could add: each row's passing-frame height against the strip's other rows, not only its old self.
- 13:29 MILESTONE (NEXT 2 of it6 done): the SWAT 55 facing-2 fix seen in play. A temporary push_warning in
  StreetWalkerCards.place (reverted, tree clean) logged the SWAT draws on column 2: the crosswalk SWAT at
  seed 5 turns through it in frames 1-12. Before/after at frame 2 (48 px/m, tilt, x3):
  `swat55_facing2_scale106_before_after_tilt_48ppm_seed5_f2_x3.png`: after, his helmet line meets his
  neighbours'. Caveat: the before ran the old grid at FILL 1.07 (my swap script's FILL sed was a no-op),
  a 1 % step on every SWAT, not on this facing's 6 %. The earlier "fill_only" still deleted from masters.
  FINDING: cross-actor size comparisons in play are confounded by StreetCrowdCards.SCALE_VAR (0.16 per
  actor); judge a facing fix on the same actor before/after only.

NEXT (it6), replaces the list above:
1. Read d9-rivet + assets journals for REQUESTs first (none open to seams at 13:29).
2. Gates are green at 407cc4f8 (code since: none; only JOURNAL/REPORT). Re-run evidence + reels only
   after a code change.
3. Weakest left: riot 55 row 2 repeats a frame (assets: no gain x3, named fault); the 55 planter reads as
   a dark mass at 32 px/m (city's tool; owner eye); Call 2's corpse "through" the barrier (sim, not built).
4. Owner Calls 1-3 stand. Freeze 18:30: export RTAI.exe (`"$GODOT_BIN" --headless --path project
   --export-release windows-showcase ../build/export/windows/RTAI.exe`), REPORT final by 18:40.
- 13:32 FINDING: the 70 armed grids measured the same way (head line + head width per facing): no scale
  outlier. SWAT 70's spliced profile row (round 1315) has head width 63 px vs 61-67 on the other facings;
  its head line (24-30) moves with the stride bob, as drawn. Nothing to scale at 70.

## Iteration 6 (director it8, 13:33-14:33), BUILD

Read: JOURNAL it5 NEXT, git log, d9-rivet JOURNAL (it13: no REQUEST to seams), library JOURNAL (13:24: no
open REQUEST; my swat55 r2 REQUEST withdrawn, ACKed). Registry rules applied: depth-ordered-layered-art
(the print's value steps, not hue, separate layers: leaf over soil over rim), generative-artifact-gating
(all 10 cells looked at before/after the lift; a palette guard on the reserved vermilion),
motion-quality-gating (before/after the same scene, seed and frame, at 32 and 64 px/m).
- 13:45 MILESTONE item 4 quality (36d9b37b): the planter's dark mass at 32 px/m (NEXT 3 of it5) measured: the
  world print's density (0.93 - lum) * 1.25 put planter_v3's leaves (lum 0.46) in the mid wash and its soil
  (0.20) in the dark wash, so leaves, soil and rim printed as one block; the p70 (n8) strip prints the same.
  New tool `tools/art/planter_value_lift.py` lifts leaf V**0.58 and soil V**0.45 at half chroma (leaf
  lum 0.46 -> 0.61, soil 0.25 -> 0.45) on both strips. FRICTION (3 min): the first stronger soil lift
  turned the brown orange: 82 px at 55 over the vermilion plate's 0.26 threshold (offline check of the
  shader's formula); the soil now loses half its chroma and the tool fails above density 0.2 (max 0.07).
  Filmed city_frame focus 11 at tilt70 and tilt, 32 and 64 px/m: the two rosettes read light in every
  box. Masters `planter_value_lift_before_after_p70_p55_{32ppm_cityframe11_x3,64ppm_cityframe11}.png`.
  test_prop_cards 13/0, lint 15/15. Provenance: 2 lines. DECISION in docs/decisions.md.
  Still: at 32 px/m the box's rim and inner ink stroke stay dark (the props' 4 px inner stroke over a
  ~1 m box); left.
- 13:50 GATE evidence at b2b5c9b9 (planter lift): lint 15/15, unit 1717/0, scenarios 52/52, parity bit-exact,
  selftest look goldens 11/11 (worst 0.27) + block 5/5, release-compile 602/0: all PASS
  (`evidence/d9-seams/evidence-it6-b2b5c9b9.log`). Reels not re-run: art only since the it5 reels.
- 13:52 MERGE SEAM check (this lane's job): `git merge-tree d9-seams d9-rivet` at d9-rivet's head: one
  conflict only, JOURNAL.md (add/add, both lanes' journals: the Director keeps both). Files both lanes
  touched: docs/decisions.md, steam/ai-provenance/2026-11.jsonl (append-only, auto-merged) and
  project/features/arena/prop_occlusion.gd (disjoint hunks: rivet's hip from RigCastShadows.hip_px, my
  PropLying corpse box; compatible: the corpse box reads the rig's head part, not the hip). A scratch
  merge commit (not a branch) is checked out at `scratch/seams/mergetrial` for lint/unit/release-compile/
  scenarios.
- 13:59 GATE on the trial merge (d9-seams 6fba6bcd + d9-rivet head; scratch commit a24ae125, not a branch;
  native DLLs copied from this worktree): lint 15/15, unit 1730/0, release-compile 605/0, scenarios 52/0;
  director reel top / tilt70 / combo 19/19 down, 0 SCRIPT ERROR, 2 engine ERROR lines each (a shader
  sampler note and the exit leak, both in my it5 baseline too). Logs `evidence/d9-seams/director-reel-merge-it6-*.log`,
  `mergetrial-it6-gates.txt`. Filmed the merge: King fight combo 64 px/m seed 2 f150/f250 (King on drawn
  legs, Rivet's drawn figure, the kerb line under the King): masters `merge_trial_seams_rivet_king_combo_64ppm_seed2_f150_f250.png`.
  The two lanes merge clean today but for the JOURNAL add/add (keep both).
- 14:05 FINDING + fix (2ef868fc), from the trial-merge film: the King's gold press plates (his arm parts,
  shown at his hips under the lifted bust) still drew Rivet's cream sticker rim (RigBuild HALO_ARM on every
  arm part): the same white edge the owner named on his legs. `BodyPlan.arm_rim` (default true); KingPlan
  sets it off under a card view; `top` and Rivet keep it. test_king_plan_legs +4 asserts. Filmed combo
  seed 2 f150 at 64 and 32 px/m (before = arm_rim forced true, the same frames): masters
  `king_arm_rim_before_after_combo_{64,32}ppm_seed2_f150_x3.png` (in frames.json at 8, the SWAT facing
  still out, file kept). FRICTION (1 min): restoring my temporary "before" edit with `git checkout --`
  also dropped the uncommitted fix line; re-added by hand before the commit (diff checked). Use a sed
  toggle back, never checkout, on a file with uncommitted work.
- Cleaned: the trial-merge worktree removed (`git worktree remove`, pruned), PNG sequences deleted.
- 14:16 GATE evidence at 2ef868fc (arm rim): lint 15/15, unit 1717/0, scenarios 52/52, parity bit-exact,
  selftest look goldens 11/11 + block 5/5, release-compile 602/0: all PASS
  (`evidence/d9-seams/evidence-it6b-2ef868fc.log`). Director reels at 2ef868fc running (scratch
  `director-reel-it6-*.log`).
- 14:18 GATE director reel it6 at 2ef868fc: top, tilt70, combo 19/19 down, 0 SCRIPT ERROR, 2 engine ERROR
  lines each (the baseline shader-sampler note + exit leak) (`evidence/d9-seams/director-reel-it6-*.log`).

NEXT (it7):
1. Read d9-rivet + assets journals for REQUESTs first (none open to seams at 14:18).
2. Gates green at 2ef868fc (evidence + reels). Re-run only after a code change.
3. Re-run the trial merge near the freeze if d9-rivet moves a lot (recipe: `T=$(git merge-tree --write-tree
   d9-seams d9-rivet | head -1)`; `git commit-tree $T -p d9-seams -p d9-rivet`; `git worktree add --detach
   <scratch> <sha>`; `git lfs pull`; copy `project/native/bin`; lint, run_unit, release_compile, scenarios,
   `scratch/seams/reels_merge.sh`; then `git worktree remove --force`). Watch: a dead Rivet behind a kerb
   barrier (PropLying boxes from the hidden head part; rivet draws a DEATH sprawl cell): film it once merged.
4. Weakest left: riot 55 row 2 repeats a frame (named fault); the planter's rim/inner stroke at 32 px/m stays
   dark (the props' 4 px inner stroke); Call 2's corpse "through" the barrier (sim, not built).
5. Owner Calls 1-3 stand. Freeze 18:30: export RTAI.exe (`"$GODOT_BIN" --headless --path project
   --export-release windows-showcase ../build/export/windows/RTAI.exe`), REPORT final by 18:40.

## Iteration 7 (director it9, 14:19-15:19), BUILD

Read: JOURNAL it6 NEXT, git log, d9-rivet JOURNAL (it16: no REQUEST to seams), library JOURNAL (it85: no
open REQUEST; OFFER cop_patrol_walk_armed_55_rfresh235_cells = row 2 copy-by-example B + row 5 A;
round 1525 = riot 55 row 2 copy-by-example, running; `cop_riot_walk_armed_55_rfresh234_cells/` already
on disk, not graded yet). Registry rules applied: sprite-and-atlas-production (a splice must keep the
sheet's own registration: the library hangs every figure from one head line), motion-quality-gating
(measured per frame, then filmed before/after at the same seed and frames in motion),
generative-artifact-gating (every recipe reproduced byte-exact before changing one input; all 80 cells
looked at old vs new on one contact).
- 14:21 ACK assets: OFFER cop_patrol_walk_armed_55_rfresh235_cells taken (rows 2 and 5 new to the game).
- 14:23 FINDING (my it4 splice): every library-drawn walk row, fresh strips included, has all four
  figure tops on one line (top offset 0; the passing frames' feet rise 4-26 px). My scratch
  `cops2/splice_row.py` stood the trimmed rfresh cells on the band's foot line instead, so a spliced row
  dipped the head at each passing frame. Measured in the shipped grids (head-top spread per facing over
  4 frames): SWAT 55 3/4-toward 7 px, SWAT 70 profile 5, riot 55 profile 3, patrol 55 profile 2; with
  the rfresh235 rows the patrol's 3/4-toward and back would have dipped 9 and 8.
- 14:26 MILESTONE (d84ad031): `tools/art/walk_splice_rows.py` (repo) hangs each fresh row from the head
  line (foot line minus the tallest fresh figure). All four recipes (patrol 55, riot 55 + profile 1.06,
  SWAT 55 + 3/4 1.06, SWAT 70) first reproduced byte-exact with the old splice (scratch `it9/build.sh old`),
  then rebuilt: every spliced facing's head spread 0-2 px. Patrol 55 takes rfresh235 rows 2 and 5;
  FILL patrol 55 1.07 -> 1.08 (mean figure 178.0 -> 175.8 px), the others unchanged at 2 dp. SWAT 55/70
  back rows keep a 3-5 px spread: the library's own post-fixed row 5, not a splice (left).
  Provenance: 4 lines. test_street_cop_walk + walker cards 14/0, lint 15/15.
- 14:29 FRICTION (8 min): my "before" grids came from `git show HEAD:<png>`: Git LFS pointer text, not
  PNGs. The import failed (ERR_FILE_CORRUPT), the two before-films logged 12820 / 4039 errors (void,
  deleted), and the 4 `.import` files were left `valid=false` even after the new PNGs came back (the
  import cache kept the failed attempt). Fixed: `.import` restored from git, the 6 `*_armed_walk.png-*.md5`
  cache entries removed, re-import 0 ERROR. Old grids now via `git show <rev>:<png> | git lfs smudge`.
  LESSON: in this repo a PNG at a past revision needs `| git lfs smudge`; check `head -c 8` is `\x89PNG`.
- 14:32 MILESTONE (a3ff1c51), quality raise beyond the brief (n8 street's crowd, on main, no lane owns it
  today): the head-line audit of all 17 walk grids found no other splice fault (elder 10 px, hood 7 px
  are drawn bobs, head UP at the passing frames, natural). But the library has two fixed ped sheets the
  game never took: jogger 70 v3 (B; the camera-fixed v2 regen + row 4 by example) and shopper 70 v3 +
  rall rows (every facing alternates). Looked: the game's jogger walk was a shallower camera than her
  still card (long legs, small head), so she changed shape on starting to jog; v3 matches the still
  (scratch `it9/jog_contact.png`). Shopper rall: frames 1/3 now swap the stride; watch point: its
  profile row sits at a slightly shallower camera than its other facings. WALK_FILL = still mean
  height / walk mean height (checked: reproduces 1.11 / 1.08 on the old grids): jogger 1.12, shopper
  1.09. Unit 20/0, lint 15/15, provenance 2 lines.
- 14:35 MILESTONE (a1580b10): riot 55 row 2 from the library's rfresh234 (cop_riot_walk_armed_55_v3b, A,
  copy by example): frame 3 now plants the other boot (my named fault since it4, closed). Looked old vs new
  row 2 (scratch `it9/riot_r2_ab.png`); rows 3/4 of rfresh234 are byte-identical to rfresh; FILL stays
  1.08. ACK assets: OFFER rfresh234 taken (v3b, the pick).
- 14:34 FILMED the board A/B (`res://dev/showcase/street_crowd.gd`, windowed d3d12, 64 px/m, --fixed-fps
  60 --write-movie: works with -s): --heavy tilt70 / tilt, --cops tilt, peds tilt70, before = the HEAD~
  grids via lfs smudge + the old FILLs, 0 ERROR in all 8 runs, the tree restored and re-imported (0 ERROR).
  The board walks east-west only, so it shows the profile facings (SWAT 70 5 px -> 0). The arena city
  block (seed 5) cops stand in a line from tick ~60 (stand frame): no stride to judge there; those two
  arena films deleted. Masters: 4 board clips + peds close-up + 3 cell contacts; frames.json 15 (riot
  profile-scale still and the 32 px/m kerb duplicate out, files kept).
- 14:39 FINDING (next job): the game's ped walks trail the library: hat, hood, punk, elder at v1, cap
  and worker at v2, while the library has v2/v3 cells and is fixing row 2 of cap/punk/hat/hood/suit/
  worker/elder now (rounds 1535/1540).
- REQUEST to assets: when rounds 1535/1540 are graded, name ONE game-ready `<strip>_cells/` folder per 70
  ped walk (cap, elder, hat, hood, punk, suit, worker) and per unarmed patrol walk (55 and 70), with the
  keyed base sheet it splices on and each row's library id/round/prompt_hash (I splice on the head line
  with tools/art/walk_splice_rows.py, cut with street_walk.py; same layout as delivered). Why: the city
  crowd walks two-pose shuffles on several of these; the owner judges the crowd at 32 px/m.
- 14:44 GATE director reel it7 at defce5b3 (art since it6: the walk grids + WALK_FILL): top, tilt70, combo
  19/19 down, 0 SCRIPT ERROR, 2 engine ERROR lines each (the baseline shader-sampler note + exit leak)
  (`evidence/d9-seams/director-reel-it7-*.log`).
- 14:44 GATE evidence at defce5b3: lint, scenarios 52, parity bit-exact, selftest goldens 11/11 (worst
  0.27) + block 5/5, release-compile 602/0 PASS; unit 1717/0 but FAIL-flagged "tree changed during run":
  FRICTION (mine, 1 min): I edited JOURNAL/REPORT while it ran. Re-run on a clean tree below; never edit
  the worktree during an evidence run (write notes to scratch, paste after).
- 14:52 GATE evidence it7b at f7b133ff (clean tree): lint 15/15, unit 1717/0, scenarios 52, parity
  bit-exact, selftest goldens 11/11 (worst 0.27) + block 5/5, release-compile 602/0: all PASS
  (`evidence/d9-seams/evidence-it7b-f7b133ff.log`).
- 14:54 MILESTONE (a95de60e): quest 1's walking patrol cops (StreetQuestCards.PATROL_WALK) take the
  library's cop_patrol_walk v4 (A at 55 and 70; a whole sheet, cut straight, no splice): every facing
  alternates (v1 repeated rows 2/4; the 3/4-away row was the 1-2-1-4 --copy). Toned to the card's
  navy as before; mean figure height 55 176.8 -> 178.7, 70 171.8 -> 171.5 px (no FILL table here: the
  walk cell keeps the standing card's height). Unit test_street_quest_cards 8/0, lint 15/15 (one gdlint
  line-length fix on the comment). Masters `quest_patrol_walk_v1_vs_v4_p55_p70_cells.png`; provenance 2.
- 14:58 MERGE SEAM vs d9-rivet head (3c9def9a): `git merge-tree` conflicts in JOURNAL.md only (add/add);
  shared + auto-merged: docs/decisions.md, provenance, prop_occlusion.gd, tools/debt/baseline.json (new
  since it6: both lanes moved the baseline; after the merge run `node tools/debt/debt.mjs --update`).
- 15:11 GATE evidence it7c at a8940e1b (quest patrol v4 + docs): lint 15/15, unit 1717/0, scenarios 52,
  parity bit-exact, selftest goldens 11/11 + block 5/5, release-compile 602/0: all PASS
  (`evidence/d9-seams/evidence-it7c-a8940e1b.log`).
- 15:03 FILMED quest 1 Line Stopped `res://dev/frames/quest1_clip.gd -- --ppm=48 --view=tilt70|tilt
  --ticks=600-760` (1920x1080, d3d12), before (v1 via lfs smudge) / after v4: 4 runs, 0 SCRIPT ERROR,
  import 0 ERROR, tree restored. Masters `quest1_patrol_walk_v1_vs_v4_tilt70_tilt_48ppm_t660-722_strip.png`
  (rows: before 70, after 70, before 55, after 55; every 4th clip frame).
- 15:04 FINDING (pre-existing, n8 street code, NOT from today's art; same in before and after): in that
  clip the patrol cop flips between the STANDING card and a walk frame every few frames (a stutter).
  Cause read in `StreetQuestCards.walk_facing` (street_quest_cards.gd:95-117): `_moving` is the step
  since the previous RENDER frame > MOVING_PX (0.2 px); a frame drawn with no sim tick in between (the
  clip tool's sampling; and in play any display faster than the 60 Hz tick, e.g. 144 Hz) has step 0 ->
  the standing card. Unconfirmed in a 60 fps windowed run (the clip's per-file tick spacing is 2).
  Fix idea (next): hold `_moving` for ~0.15 s (9 ticks) after the last step (or judge moving by walked
  px per second, not per frame), test: two frames with no step between steps stay walking.

NEXT (it8), replaces the list above:
1. Read d9-rivet + assets journals for REQUESTs first; assets owes the answer to my 14:39 REQUEST (one
   game-ready cells folder per 70 ped walk + key/round/hash): splice each with
   `tools/art/walk_splice_rows.py <keyed> <cells> <out> 1 2 3 4 5`, cut `street_walk.py ... 192`, FILL =
   still mean h / walk mean h (scratch `it9/build.sh` + the mean-height snippet in JOURNAL it7), film
   `res://dev/showcase/street_crowd.gd -- --view=tilt70 --ppm=64` (+ --write-movie) before/after.
2. The quest patrol stand/walk stutter (15:04 FINDING): confirm at --fixed-fps 60 windowed and with the
   clip; fix with a hold; unit test; film before/after.
3. Gates green at a95de60e (evidence it7c) / f7b133ff (it7b) + reels it7 at defce5b3. Re-run after code.
4. Freeze 18:30: export RTAI.exe (`"$GODOT_BIN" --headless --path project --export-release windows-showcase
   ../build/export/windows/RTAI.exe`), REPORT final by 18:40. Owner Calls 1-3 stand.
- Registry rules applied it7: sprite-and-atlas-production (a splice keeps the sheet's own registration;
  one cell per grid; FILL measured per grid against its still card), motion-quality-gating (per-frame
  head-line measure, then before/after films at the same seed/frames: board, quest 1),
  generative-artifact-gating (every recipe reproduced byte-exact before changing an input; all cells
  looked at old vs new), depth-ordered-layered-art (no layer change: whole-figure grids only).
- Session end 15:12: all committed; scratch avi/PNG sequences deleted (masters hold the mp4s and stills).

## Iteration 8 (director it10, 15:13-16:13), BUILD

Read: JOURNAL it7 NEXT, git log, d9-rivet JOURNAL (it17: no REQUEST to seams; its baton REQUEST went to
assets), library JOURNAL it85 (15:00: my 14:39 REQUEST served: `deliveries/seams_ped_walk_cells_it85.md`
+ `.json`, 10 folders; named weak row elder 70 row 4). Registry rules applied: sprite-and-atlas-production
(fresh rows hung from the sheet's own head line; one cell per grid; FILL rescaled by measured mean figure
height), motion-quality-gating (old vs new grids on one contact, then a before/after film in motion at
the same frames with every facing walking), generative-artifact-gating (each base re-cut and compared
with the game grid first: suit and worker byte-exact, the jogger byte-exact from the it7 source sheet;
the others were older v1/v2 bases in the game, so they upgrade whole).
- 15:14 ACK assets: the ped walk cells manifest taken for cap, elder, hat, hood, punk, suit, worker,
  jogger. NOT taken: the patrol 70/55 folders (v3 + row 2 v4): quest 1 already walks the whole v4 sheet
  (A, a95de60e), which alternates every row.
- 15:17 MILESTONE (c159e9d5): the eight 70 ped walk grids rebuilt (scratch `it10/build.sh`, splice only
  the fresh rows: cap 2, elder 1 2, hat 2 4, hood 2, punk 2, suit 2, worker 2 4 5, jogger 2). Looked at
  every cell old vs new (scratch `it10/contact_*.png`): frames 1/3 now swap the leading leg in the
  facings where the old rows repeated them (cap 3/4 toward, hat profile, ...). Head-line spread <= 2 px
  except elder 3/4 away 7 and hood 3/4 away 6 (drawn bobs: head UP at the passing frames). WALK_FILL =
  old FILL x old mean h / new mean h: elder 1.07 -> 1.08, hat 1.07 -> 1.06, punk 1.00 -> 1.01, worker
  1.11 -> 1.13 (cap, hood, suit, jogger hold). Unit 1701/0 (--changed ran the full set), lint 15/15,
  import 0 ERROR, provenance 8 lines.
- 15:20 MILESTONE (324dac8a): the crowd board's `--spin` (dev): 16 walkers in 16 headings, so every
  facing walks (the board was east-west only). FILMED before (old grids + old FILLs, re-import) / after,
  64 px/m tilt70, 183 frames each, 0 SCRIPT ERROR; tree restored, import 0 ERROR. Masters
  `crowd_walk_cells_it85_before_after_spin_tilt70_64ppm.mp4` (+ `_cycle.png`, `_old_vs_new_grids_p70.png`);
  frames.json: it replaces the jogger/shopper board still (the clip covers both).
- FRICTION (2 min): the pre-commit hook (lint) blocked the --spin commit: gdformat, a 100-col line and
  the debt ratchet (dev_loc +8). Squeezed to +6 and accepted with a recorded reason.
- 15:27 FINDING (corrects my it7 15:04 FINDING): the quest 1 clip at tilt70/tilt 48 px/m, ticks 600-760,
  is PIXEL-IDENTICAL with and without a hold (0 differing pixels over 81 frames, both pitches): the clip
  tool steps the sim between every saved frame, so it never draws a frame with no step. What I read as
  a stand/walk flip in it7 was the walk's passing frame (feet together), which looks like the standing
  card at 48 px/m (strip `it10/q1/strip_20.png`: 5 clip frames contact, 5 passing, as one stride frame =
  0.35 m at ~1.2 m/s = ~17 ticks). The code path is still real: `_moving` was the step since the last
  RENDER frame, and World._process steps the 60 Hz sim from delta, so on a display over 60 Hz most
  frames have no step and would draw the standing card.
- 15:35 MILESTONE (90e9a69c): StreetQuestCards.HOLD_FRAMES 4: a cop stands only after 4 frames with no
  step (the hold rides in the walk memory's Vector4: x, y, facing angle, frames since the last step).
  Unit: a frame with no step between steps keeps walking and its facing; 4 still frames stand. Full unit
  1718/0, lint 15/15. NOT filmed in the case it fixes: `--autostart --fixed-fps 240` on the main scene
  opened the city drive, not quest 1 (capture deleted, 594 MB); the quest clip shows no change (above).
- 15:43 GATE evidence it8 at 90e9a69c: lint 15/15, unit 1718/0, scenarios 52, parity bit-exact, selftest
  goldens 11/11 (worst 0.27) + block 5/5, release-compile 602/0: all PASS
  (`evidence/d9-seams/evidence-it8-90e9a69c.log`).
- 15:38 LOOKED: the asset lane's named weak row (elder 70 row 4, 3/4 away) in the new grid: frame 3
  plants the centre foot where frame 1 plants lower-left: a small alternation, not a repeat; kept.
- 15:46 GATE director reel it8 at 90e5a006 (code since it7: StreetQuestCards hold, the crowd grids):
  top, tilt70, combo 19/19 down, 0 SCRIPT ERROR, 2 engine ERROR lines each (the baseline shader-sampler
  note + exit leak) (`evidence/d9-seams/director-reel-it8-*.log`).
- 15:45 DECLINED the standing OFFER swat_walk_armed_70_v2_rfresh13_cells (row 1 B): the game's SWAT 70
  toward row already alternates and is toned to the cop navy; the offered row is narrower (the asset
  lane's own named fix). The rfresh35 patrol 55 offer was superseded by rfresh235 (taken it7).
- 15:47 Masters: combined clip now `seams_d9_set_combined_58s.mp4` (+ the crowd before/after, 6 s);
  frames.json 15 entries; board avi captures deleted.

NEXT (it9), replaces the list above:
1. Read d9-rivet + assets journals for REQUESTs first (none open to seams at 15:13).
2. (done 15:59, see below) The patrol hold is filmed at 240 Hz.
3. Weakest left: SWAT 55/70 back rows' 3-5 px head move (drawn), elder 3/4 away weak alternation (asset
   named), the planter's dark inner stroke at 32 px/m, Call 2's corpse "through" the barrier (sim).
4. Gates green at 90e9a69c (evidence it8) + reels it8 at 90e5a006. Re-run after code.
5. Freeze 18:30: export RTAI.exe (`"$GODOT_BIN" --headless --path project --export-release windows-showcase
   ../build/export/windows/RTAI.exe`), REPORT final by 18:40. Owner Calls 1-3 stand.
- Registry rules applied it8: sprite-and-atlas-production (splice on the head line, FILL by measured mean
  height), motion-quality-gating (grids old/new, then every facing filmed in motion with --spin; the
  hold judged by a pixel diff before claiming a visible change), generative-artifact-gating (base re-cut
  vs the game grid before splicing; the asset lane's weak row looked at), depth-ordered-layered-art (no
  layer change).
- Session end 15:48: all committed; scratch avi deleted (masters hold the mp4s and stills).
- 15:59 FILMED + CONFIRMED the hold in play: `res://boot/quest1.tscn --fixed-fps 240 -- --autostart
  --view=tilt70 --ppm=48` (capture 1280x800: the local override.cfg), before = HOLD_FRAMES 1 (the old
  rule; const edited and restored from git), after = 4. Before: in 16 consecutive frames the patrol cop
  draws the standing card on 12 and the walk frame only on the 4 frames with a sim tick (a hard flicker
  at any display rate over 60 Hz); after: the walk frame on every frame. Masters
  `quest1_patrol_hold_before_after_240hz_tilt70_48ppm_quarter_speed.mp4` (every frame at 60 fps) +
  `_16frames.png`; frames.json: replaces the old SWAT 70 armed walk still. 0 SCRIPT ERROR both runs.
  FRICTION (3 min, mine): deleted the first captures before checking the clip (an fps filter had
  dropped 3 of 4 frames, hiding the flicker); re-shot. LESSON: build `setpts=N/60/TB` from a 240 fps
  capture, and keep the source until the master is looked at.
- 16:01 AUDIT (read only): the other render-frame-keyed path in features is `combat/weapons/art/
  held_muzzle.gd` (a muzzle light on only in the frame it was lit: at 240 Hz the flash lasts a quarter
  as long as at 60). The rivet lane owns the held weapons: NOTE to rivet (not a REQUEST; judge it if
  you film above 60 Hz). Crowd walkers judge motion by rig speed (no such issue).

NEXT (it9) addendum: item 2 is done (filmed 15:59). Start at item 3 (weakest left) after reading the
journals; gates last green at 90e9a69c (evidence it8) + reels it8; the it8 commits after that are docs only.
- Session end 16:02: all committed; scratch captures deleted (masters hold the mp4s and stills).

## Iteration 9 (director it13, 16:01-17:01), BUILD

Read: JOURNAL it8 NEXT + addendum, git log, d9-rivet JOURNAL (it20 15:30-15:58: the baton smear; no REQUEST
to seams), the library JOURNAL (it91 16:02: "No open REQUEST"; its it88 NEXT offers the King and patrol cop
portraits to the game lanes). Main has not moved (merge-base = main 0bea8b93).
- 16:05 DECLINED (for seams) the portrait offer: the HUD's `king` portrait is the shipped p55 bust card
  frame 0 by the owner's d8 verdict ("the King as built"; portraits.json `source`), so a fresh drawn King
  portrait is an owner call, not a seam; the cop portrait has no slot in portraits.json today. Left for the
  hud lane / the owner.
- 16:06 MERGE SEAM vs d9-rivet head bd526bf9 (rivet moved 20+ commits since my it6 trial): conflicts now
  JOURNAL.md (add/add) and tools/debt/baseline.json (both lanes accepted a dev_loc rise from 18799: seams
  +6 the crowd board --spin, rivet +66 FireStills). Resolution for the Director: keep both accepted lines,
  chain them (18799 -> 18805 -> 18871), total 18871; then `node tools/debt/debt.mjs --update`.
  Scratch trial merge commit ab6b34f2 (detached, `scratch/seams/mergetrial9`, not a branch): the
  pre-commit lint passed on it, 15/15 over 1222 files.
  FRICTION (2 min, mine): a Python regex backreference in a heredoc wrote \x01 into the baseline; the
  pre-commit hook (debt-ratchet JSON parse) stopped the commit; fixed by hand.
- 16:11 GATE on the trial merge ab6b34f2 (native DLLs copied from this worktree): unit 1735/0,
  release-compile 605/0, director reel top / tilt70 / combo 19/19 FULLY down, 0 SCRIPT ERROR, 0 p_frame,
  the 2 known ^ERROR lines each (`evidence/d9-seams/mergetrial-it9-*.log`, `director-reel-merge-it9-*.log`).
  Scenarios on the merge running.
- 16:11 FILMED the merge (film9.sh, 1280x800, d3d12, 0 SCRIPT ERROR both): the King fight combo 64 px/m
  seed 2 f250 (--boss-cam to frame him) and the city block tilt70 32 px/m seed 5 f900. LOOKED: the King's
  drawn legs stand over the floor marking (feet in front of it), his press plates carry no rim, Rivet's
  drawn figure and shadow beside him; the city block's armed cops, shields and the crossing read; no
  seam. Still `merge_trial_it9_seams_rivet_bd526bf9_king_combo_64ppm_seed2_f250_city_tilt70_32ppm_seed5_f900.png`
  (masters; not in frames.json: not a before/after). Rivet at 1.1 m reads small beside the cops: that
  is the rivet lane's own Call 1, not a seam. Avi deleted.
- 16:14 SEAM READ (closed): when a body behind a kerb barrier makes PropOcclusion redraw the barrier, the
  bodies in front of it are lifted by FRONT_DZ. Rivet's drawn figure is `rig.head_card` (RivetFrames),
  a child of his rig, so it rides the lift; his held views map through RigDepthSort.rig_of. No change.
  Still unfilmed (no staging flag): a DEAD Rivet behind a barrier (PropLying boxes from the hidden parts'
  head; the parts plan is 1.8 m against the 1.1 m drawn sprawl, so the box runs long: a harmless extra
  redraw of the barrier, never a short box, unless his drawn sprawl points another way than the parts).
- 16:16 MEASURED + CLOSED (REPORT does-not list): the SWAT back row's head move is a regular two-per-stride
  bob, 3 px = 1.6 % of the figure at 55, 5 px = 2.8 % at 70 (cell tops 2/7/3/7), about a walking head's
  rise and fall, ~1.6 px at 32 px/m: not a fault. Every other SWAT row is 0-1 px (the head-line splice).
- 16:17 MEASURED (REPORT): the planter's print density (0.67 mean) is mid-pack among the 70 props
  (0.42-0.86); lifting it alone breaks the set. Left.
- 16:18 NOTE to assets (not a REQUEST): your it88 portrait offer says "the game still shows the old d5 King
  portrait (grey design)". It does not: the HUD's `king` portrait (data/tables/portraits.json) is the
  shipped p55 bust card frame 0, by the owner's d8 verdict; the d5 portraits under
  `features/characters/art/d5/portraits/` are read only by a dev showcase (`dev/showcase/d5_dialogue_run.gd`).
  A swap to portrait_king_55_b is an owner call (and the hud lane's slot), not a seam; seams does not take it.
- 16:18 Not built (decided): Call 2's option (a corpse stopped at a wall). A view-side redirect of the drawn
  fall would have to match city's crowd-atlas corpse at the 90-tick swap (StreetCrowdCorpse.fall_cell),
  a new jump seam across street, city and the arena's props; the owner has not picked it.
- 16:12 GATE scenarios on the trial merge: 52 passed (`evidence/d9-seams/mergetrial-it9-scenarios.log`).
  Rivet's branch touches no native/ or sim code (diff vs the merge base), so parity carries over.
  Scratch worktree removed (`git worktree remove --force`).
- 16:17 FILMED (evidence gap closed: item 3 had only 32 px/m films + a 3x crop): the sim bike at a REAL
  64 px/m in the city drive, `res://boot/main.tscn -- [--view=tilt70] --seed=7 --rigs --bikes=0.25`
  (`--ppm` is an arena flag: the drive's zoom is camera.json `on_foot` ppm, set to 64 for the take and
  restored from git; tree clean after). 0 SCRIPT ERROR both. LOOKED: card row 9 (rider, tank, wheels)
  reads clean at 64 in tilt70, the top print reads as a bike from above.
- 16:18 FINDING (pre-existing, not the bike's): the bike drives THROUGH the idle Rivet; while they overlap
  the depth order flips (bike over him, then him over the bike). By code: the city sim's player body
  (`CitySimBody`) resolves people only, no car step reads BD_*, and nothing in features/bodies or
  features/player checks a car. So every car does it. Not fixed (sim, both twins, moves parity/scenarios/
  goldens): REPORT does-not + Call 4. Masters `sim_bike_rider_tilt70_vs_top_64ppm_seed7_bikes025_f380-500.mp4`
  (frames.json entry 15, replacing the older 32 px/m drawn-legs still that entry 11 covers at 64) +
  `_f430-485_x12.png`. Avi deleted.
- 16:22 DECISION seams/traffic-yields (Call 4 option b, built OFF): sim traffic brakes for Rivet on foot through
  the obstacle feed both sim twins already brake for (set_obstacles: 12 m look-ahead, stop 5.5 m short, overtake
  mid-block after 2.5 s, CitySimCarPass). His ground point goes FIRST in the feed (the sim keeps the first
  OBST_MAX = 24 points, so his is never the one cut), in the boot adapter `CityVehicleWorld.set_obstacles`
  (`yield_to_rivet`, `--traffic-yields`); driving, the point is his car's centre, already a hull point.
  Why there: no native change (parity untouched), and the first try in VehicleService/VehicleContacts pushed
  both files and the test file past the 200-line soft cap (debt ratchet files_past_soft_cap 67 -> 69), so
  it moved to boot (148 -> 158 lines) with its own test file. Rejected: a sim-side body-vs-car contact
  (both twins, a native rebuild, the knockdown rules; option c), and ON by default (moves scenarios and the
  city traffic for top; the owner's call).
- 16:24 MILESTONE (0a950b56): `CityVehicleWorld.with_rivet` + `yield_to_rivet` (default false) +
  `--traffic-yields` (LaunchArgs.KNOWN_FLAGS). Unit `test_city_vehicle_world_yield` 4/4 (off = the feed
  untouched, on = him first, kept under a full cap, default off) + test_vehicle_service + test_city_sim_pass
  18/18; lint 15/15.
- 16:27 FILMED before/after, `res://boot/main.tscn -- --view=tilt70 --seed=7 --rigs --bikes=0.25
  [--traffic-yields]`, 64 px/m (camera.json on_foot 64 for the take, restored), 720 frames, 0 SCRIPT ERROR.
  LOOKED: before, the van and then the bike drive through the idle Rivet; after, the van stops ~3 m short of
  him and waits (he stands in a junction, where nothing overtakes), the bike queues behind it. Masters
  `traffic_yields_to_rivet_before_after_tilt70_64ppm_seed7_bikes025_f300-720.mp4` (frames.json entry 4,
  replacing the 55 armed-walk still: entry 3 covers armed walk) + `..._f300-660_strip.png`. Avi deleted.
- 16:31 MUTATE (`tools/mutate/mutate.mjs --file=boot/city_vehicle_world.gd --tests=test_city_vehicle_world_yield
  --max=8`): the sample of 8 from 101 landed only on the file's older lines (car/people queries), none on the
  new ones: 0/7 killed, says nothing about the change (the tool has no line filter). Hand-planted the four
  faults that matter instead (below).
- 16:36 PLANTED by hand (each restored from git, tree clean after), `--select=test_city_vehicle_world_yield`:
  flip `on` -> 3 fail; `off` adds him last -> 1 fails; default true -> 1 fails; drop the prefix -> fails by
  a compile error (its unused parameters are warnings-as-errors), not an assertion. 4/4 caught. Not
  unit-covered: the wiring line in `set_obstacles` (the film shows it).
- 16:35 GATE evidence it9 at 0a950b56: lint 15/15, unit 1722/0, scenarios 52, parity bit-exact (planted
  mutation caught at step 629), look goldens 11/11 (worst 0.27) + block 5/5, release-compile 602/0: all PASS
  (`evidence/d9-seams/evidence-it9-0a950b56.log`). `top` holds: the flag is off by default.
- 16:39 MERGE SEAM re-check vs d9-rivet 5af5db29 (after my boot/ edits): still only JOURNAL.md (add/add) and
  tools/debt/baseline.json (resolution above: keep both accepted lines, chain, then --update).

NEXT (it10), replaces the lists above:
1. Read d9-rivet + assets journals for REQUESTs first (none open to seams at 16:39).
2. Gates green at 0a950b56 (evidence it9) + the trial merge it9 (ab6b34f2: unit 1735/0, release-compile 605/0,
   scenarios 52, reels 19/19 x3). Reels it9 on 5fa6baee: see the line below (running at 16:38).
3. Freeze 18:30: export RTAI.exe (`"$GODOT_BIN" --headless --path project --export-release windows-showcase
   ../build/export/windows/RTAI.exe`), REPORT final by 18:40. Owner Calls 1-4 stand (4 is new: traffic and
   Rivet on foot; b is built behind `--traffic-yields`).
4. If time: a last trial merge near the freeze (recipe it6 NEXT 3 + the baseline resolution); a scenario for
   the yield (cars stop short of the on-foot point, like scenario_vehicle_yield) if Call 4 goes to b.
5. Weakest left: elder 3/4-away walk (asset-named), the corpse-at-a-wall option (Call 2), Rivet's 1.1 m
   size beside the cops (rivet's Call 1, not mine).
- Registry rules applied it9: depth-ordered-layered-art (the front lift read for Rivet's drawn card: it is the
  rig's child), motion-quality-gating (the bike and the yield judged in motion at a real 64 px/m, before/after
  at the same seed and frames; the bob measured per frame before calling it a fault), engine-integration-safety
  (the yield in the adapter over an existing feed both twins read: no native change, parity re-run; off by
  default), vehicle-archetype-balance / top-down-vehicle-handling-model (the bike's handling untouched; the
  yield reuses the sim's car-following distances: 12 m look-ahead, 5.5 m stop), generative-artifact-gating
  (no new art this iteration).
- 16:40 GATE director reel it9 at 5fa6baee (code since it8: CityVehicleWorld.yield_to_rivet, off): top, tilt70, combo 19/19 FULLY down, 0 SCRIPT ERROR, 0 p_frame, the 2 known ^ERROR lines each (`evidence/d9-seams/director-reel-it9-*.log`).
- 16:45 MILESTONE (NEXT 4 done early): `scenario_traffic_yields_rivet` on the real World (seed 53): Rivet stands
  in an east-bound lane mid-block, one sim car at 12 m/s from 24 m behind, 12 s, two arms. Measured: n8 (off)
  closest 0.10 m (straight through him); yield (on) 2.44 m (it stops, then pulls round him in the next lane).
  Pass bar: n8 under 1.0 m (the scene really sends it through) and yield over 1.5 m (hull half width 0.95 +
  a person 0.4: no overlap). FRICTION (1 min, mine): my first bar (2.5 m) was a guess and failed at 2.44 m,
  a clean pass round him; set from the geometry instead, the measure written into the const's comment.
  Scenarios 53 passed (`evidence/d9-seams/scenarios-it9-traffic-yields.log`), lint 15/15.

NEXT (it10) addendum: item 4's yield scenario is DONE (5076c02b). Gates last green: evidence it9 at 0a950b56
(all PASS) + reels it9 at 5fa6baee + scenarios 53/53 at 5076c02b (the only change since 0a950b56 is that
scenario + docs). Start at item 1 (journals), then a last trial merge near the freeze, then the exe at 18:30.
- Session end 16:48: all committed; scratch avi deleted (masters hold the mp4s and stills); frames.json 15.

## it10 (16:49-17:49, iteration 16 by the Director's count)
- Read: JOURNAL NEXT it10, git log, d9-rivet JOURNAL (it21 16:40: REQUEST to assets rivet_walk_70; no REQUEST to
  seams), the asset lane's JOURNAL (it91-92: no REQUEST open; seams declined the portraits, noted). None open to seams.
- 16:52 PROBE (temporary Log line in KingLegsCard.step, reverted from git, never committed): the King fight
  `--boss=king --phase=3 --bot=boss --seed=2 --rigs --view=combo`, 900 frames. THREE rigs run the legs card: the
  King (card scale 0.555 at 55) and two at 0.205. The 0.205 ones are the gang: `KingArt.dress` runs for every court
  rig (KingRigs._place) and `KingLegsCard.step` never checked whose card it was.
- 16:54 FILMED phase 1 (gang alive), combo, `--boss-cam --ppm=64` and 32, seed 2, f200: the four bodyguards stand on
  small copies of the King's drawn legs, torsos lifted. Mine since it2 (7f522e54); every King take since was phase 3,
  after the gang falls. Fixed first as a guard (d561498d: art_dir "king" only; test fails with the guard out).
- 16:59 LOOKED at the fix before/after (`king_gang_own_legs_before_after_combo_64ppm_seed2_phase1_f200.png`,
  `..._32ppm_..._x3.png`): the "after" is WORSE: on their own gang_parts legs the bodyguards sprawl grey top-down limb
  parts with a pale rim (the owner's "white background" again), detached feet at 64 px/m; on the drawn legs they
  read as upright figures, the purple-and-gold bands matching their visor band.
DECISION seams/gang-legs: the gang stands on drawn legs (the King's sheet until its own lands), by decision now, not
by accident: `KingLegsCard.SHEETS` art_dir -> sheet (`{"king": "king_legs", "gang": "king_legs"}`, 6220e46f). Why: at
32 and 64 px/m the parts legs break the figure the owner asked to be redesigned on the King. Rejected: the parts
(d561498d's guard; drop "gang" from SHEETS), the rim strip alone on the gang's parts (still top-down limbs under an
upright card). Alternative one value away. REPORT Call 5.
- REQUEST to assets: `gang_legs_55` and `gang_legs_70`, the King's bodyguards' drawn legs, COPY BY EXAMPLE of
  king_legs_55_v2 (55) and king_legs_70_v3 (70): the SAME canvas, the same 5 x 5 cell layout (55: 1090x670, cells
  218x134; 70: 1230x380, cells 246x76), the same facings order, standing row + 4-frame walk, the same hip line and
  sole line, so they drop in at the King's scale and lift. Only the dress changes: the gang's heavy steel bot legs
  (gunmetal grey steel shins and thighs, black joints, ONE thin gold ring at each knee and ankle like their gold
  knuckle rings; no plum tights, no royal gold bands, no rivet rows: those are the King's), INK OUTLINE ONLY, no
  cream/white rim or backing, no teal, no police blue, no red. Why: since it2 the four bodyguards stand on the
  King's own legs (filmed it10, phase 1, combo); their own top-down parts legs sprawl with a pale rim. When served
  A/B I swap `KingLegsCard.SHEETS["gang"]` to "gang_legs" (one value), with a provenance line.
- 17:05 PROBE + FINDING (motion-quality-gating): the King's drawn boots skate at 55. His legs card stepped by the
  parts' gait phase (RigGait: one cycle per `stride` world px); the probe in the real fight (phase 3, combo, seed 2)
  measured 64 world px per gait cycle, card scale 0.54-0.56 at 55. The 55 sheet's profile column draws contact
  rows 180/173 px wide with a 64 px boot: two heel-to-heel steps of 116 = 232 cell px per cycle = ~125 world px.
  So the drawn legs cycled twice per drawn stride of ground: boots running at 2x the ground speed. At 70 the drawn
  cycle (~80 cell px x 0.71 = 57) is close to the gait's 64.
- 17:12 MILESTONE (f99bf5d6): `KingLegsCard.CYCLE_CELL` {55: 232, 70: 80} + `walk_row`: the legs card keeps its own
  phase (meta on the legs sprite) advanced by the ground walked / (cycle x card scale); `{}` = the old gait phase.
  MEASURED in the real fight, same 349 walking frames (782 px): a new pose every 17.4 px (7.7/s) before, 26.1 px
  (5.2/s) after; the drawn quarter cycle is ~31 px. PLANTED by hand: phase x2 -> the walk-row test fails; 55 cycle
  115 -> the cycle test fails; a constant step -> compile error (unused var). Clip
  `king_legs_stride_before_after_combo_64ppm_seed2_phase3_f200-420_x2.mp4` (frames.json 9). LOOKED: same frame,
  same pose set; after, the steps are slower and heavier, the boot stays planted while the floor passes.
  FRICTION (1 min): a `Dictionary.get` into a typed float parameter is a warning-as-error (Variant); typed local.
  `tools/godot/check.mjs` on any King script FAILS by a depended-script chain under --check-only (king_art.gd
  unchanged fails the same): not a signal; the unit load is.
- 17:14 REPORT items 24-25 + Call 5, two decision lines (298af5a1). frames.json 15: in the stride clip (9) and the
  gang pair (10); out the King 70 legs film (8 covers 70) and the arm-rim still (both still cited by REPORT).
- FRICTION (1 min): evidence run refused the tree: its own log was written under evidence/ (untracked). Log to
  scratch, copy in after (as rivet did).
- 17:22 GATE director reel it10 at 298af5a1 (code since it9: KingLegsCard SHEETS + walk_row): top, tilt70, combo 19/19
  FULLY down, 0 SCRIPT ERROR, the 2 known ^ERROR lines each (`evidence/d9-seams/director-reel-it10-*.log`).
- 17:22 GATE evidence it10 at 298af5a1: lint, scenarios 53, parity bit-exact (mutation caught at 629), look goldens 11/11
  (worst 0.27) + block 5/5, release-compile 602/0 PASS; unit 1726/0 but marked FAIL "tree changed during run" because
  I appended to JOURNAL.md while it ran (mine, 0 min lost: re-run on the clean tree below).
  (`evidence/d9-seams/evidence-it10-298af5a1-dirty.log`)
- 17:31 GATE evidence it10 CLEAN at a9b978d8: lint 15/15, unit 1726/0, scenarios 53, parity bit-exact (mutation caught
  at 629), look goldens 11/11 (worst 0.27) + block 5/5, release-compile 602/0: all PASS
  (`evidence/d9-seams/evidence-it10-a9b978d8.log`). `top` holds (no legs sheet at 90; goldens did not move).
- 17:34 MEASURED the stride at 70 (tilt70 King fight, never eases; same temporary probe, reverted from git): same 379
  walking frames (817 px), a pose every 17.0 px (7.6/s) before, 14.6 px (8.9/s) after = the sheet's drawn quarter cycle
  (80 x 0.713 / 4 = 14.3). A small change at 70 (the 55 one was 2x). The 70 cycle rests on an ESTIMATED boot length
  (~55 cell px from the passing rows' foot band): unfilmed at 70 after f99bf5d6 (NEXT 5).

NEXT (it11), replaces the lists above:
1. Read d9-rivet + assets journals for REQUESTs (none open to seams at 17:25). Watch assets for `gang_legs_55/70`
   (REQUEST it10): when A/B, drop the PNGs in as art/p<pitch>/gang_legs.png (same layout as king_legs), set
   `KingLegsCard.SHEETS["gang"] = "gang_legs"` (one value), provenance lines, film phase 1 combo 64 + 32 px/m
   (`res://dev/arena/arena.tscn -- --boss=king --phase=1 --bot=boss --seed=2 --rigs --view=combo --boss-cam --ppm=64`;
   --boss-cam only to frame them) and re-check `CYCLE_CELL` against its profile column if its stride differs.
2. Gates last green: evidence it10 (clean run at a9b978d8, see the line below) + reels it10 at 298af5a1 (19/19 x3).
3. Freeze 18:30: export RTAI.exe (`"$GODOT_BIN" --headless --path project --export-release windows-showcase
   ../build/export/windows/RTAI.exe`), REPORT final by 18:40. Owner Calls 1-5 (5 is new: the gang's legs).
4. A last trial merge vs d9-rivet near the freeze (it9 recipe: conflicts JOURNAL.md add/add and
   tools/debt/baseline.json: keep both accepted lines, chain, `node tools/debt/debt.mjs --update`).
5. Weakest left: the King's 70 stride is measured close (drawn ~57 vs gait 64 world px per cycle) but unfilmed after
   f99bf5d6 at 70 (tilt70, before the ease); elder 3/4-away walk (asset-named); Call 2's corpse-at-a-wall.
- Registry rules applied it10: motion-quality-gating (the stride measured in the real fight as ground px per drawn pose
  before/after, same frames; the gang judged in motion at 32 and 64 before calling the fix good: it was worse),
  depth-ordered-layered-art (the legs card under the bust's hem for every court rig that has a sheet),
  generative-artifact-gating (the gang's parts legs' pale rim is the owner's "white background" again: why the
  drawn sheet wins), engine-integration-safety (view only: no sim, parity/goldens re-run; `top` has no sheet).
- Session end 17:32: all committed; scratch avi/png/probe logs deleted; frames.json 15.

## it11 (director iteration 17), 17:34-18:30, BUILD to the freeze
- Read: JOURNAL NEXT it11, git log, d9-rivet JOURNAL (it22: walk at 55, no REQUEST to seams), the asset lane's
  JOURNAL (it94 17:26: **DELIVERED gang_legs_55 + gang_legs_70 to seams**, A, round 20261107-1820, note
  `deliveries/seams_gang_legs_it94.md`). ACK assets: received, landed (b026010d), filmed. None other open.
- 17:36 LOOKED at gang_legs_55 on magenta: 25 steel poses, ink only, no rim/backing (the 1.7 % near-white
  opaque pixels are steel highlights, the King's sheet has 1.1 %). Import settings identical to king_legs.
- 17:38 MILESTONE (b026010d): `art/p55|p70/gang_legs.png` + `KingLegsCard.SHEETS["gang"] = "gang_legs"`
  (one value back: "king_legs"); test: the gang's sheet is not the King's and is a drop-in on his canvas at
  55 and 70; PLANTED "king_legs" -> caught. Provenance lines (round, prompt_hash cb240ad99625 / bb13015c638d).
  FILMED phase 1, combo, seed 2, 64 and 32 px/m, f200 + clip f150-420 (before = the King's sheet): LOOKED:
  after, the bodyguards' legs carry their torsos' steel (grey, thin gold rings), the purple-and-gold is the
  King's alone; at 32 px/m the steel reads darker but stays a leg shape. frames.json 9 replaced.
- 17:48 GATES at b026010d: evidence all PASS (lint 15/15, unit 1727/0, scenarios 53, parity bit-exact, mutation
  caught at 629, look goldens 11/11 worst 0.27 + block 5/5, release-compile 602/0); director reel top / tilt70 /
  combo 19/19 FULLY down, 0 SCRIPT ERROR, known engine ERROR lines only (`evidence/d9-seams/*-it11-*`).
  Logged to scratch during the run (it10's lesson), copied in after.
- 17:50 FILMED at 70 (tilt70, never eases, 64 px/m, seed 2): the gang phase 1 (before/after still: stubby
  foreshortened steel legs under the steel torso, consistent) and the King's 70 stride phase 3 (CYCLE_CELL {}
  vs 80; clip f120-480). LOOKED: same frames, slightly different poses, boots planted; matches it10's
  measure (a pose every 17.0 px before, 14.6 after). NEXT 5 closed. frames.json 8/9 notes cite both.
- 17:52 EXE `build/export/windows/RTAI.exe` exported (exit 0, 28 s) at b51247bb; smoke the King phase 1 combo
  600 frames: exit 0, 0 SCRIPT ERROR.
- 17:53 TRIAL MERGE vs d9-rivet e2400dc4 (scratch worktree, detached, 2c84666c): conflicts only JOURNAL.md and
  the debt baseline (rivet +69 now: chained 18799 -> 18805 -> 18874); debt --check ok. Gates running.
DECISION seams/gang-legs (it11): Call 5 default moves from (a) the King's legs to (c) the gang's own steel legs,
because filmed they keep the royal dress the King's and match the steel bodies; (a) and (b) one value away.
Logged in docs/decisions.md.
- Registry rules applied it11: generative-artifact-gating (looked at the served sheet on a contrasting ground for
  rim/backing before landing), depth-ordered-layered-art (same z, hip and sole lines as the King's: a drop-in),
  motion-quality-gating (judged in motion at 32/64, 55 and 70, before/after by the one value), sprite-and-atlas-
  production (same canvas/cell layout, import settings diffed), engine-integration-safety (view only; parity,
  goldens, replay re-run green).
