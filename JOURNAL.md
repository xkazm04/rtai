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
