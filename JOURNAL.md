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
