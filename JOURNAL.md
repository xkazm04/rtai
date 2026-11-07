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
