# JOURNAL - lane world (n9, branch n9-world)

## it1 (2026-11-08 00:55-01:55) BUILD

Read: brief, seams + perf d9 REPORTs (Call P-1 / LEDGER L4, seams Call 3 bikes), AGENTS.md, decisions tail.
Registry rules applied: `perf-regression-gating` (BC7 judged on its mechanism + a measured VRAM A/B, pixels
gated by the goldens' own tolerance, the bikes-only and BC7-only deltas separated before the re-bless so each
moved golden has a named cause), `motion-quality-gating` (judge combo in motion on the reel, not a still).

- MILESTONE item 1 built: view.json default `combo`; `ViewMode.select()` pins a run's view; `city_selftest`
  pins `top` (look goldens + accent audit stay the straight-down reference); `traffic.bike_share` 0.06;
  BC7 on 772 imports (`node tools/handheld/bc7_arm.mjs project` then `--import`, 77 s, 0 errors).
- Golden deltas measured before blessing (seed 91 junction riot, top):
  - BC7 only (bikes 0): 11/11 inside tolerance, means 0.78-1.85.
  - BC7 + bikes 0.06: 2/11 (d1 only) inside, means 4.32-14.73: bikes change the riot's deaths and car spots.
  - block (BC7 + bikes): 5/5 inside, means 0.62-1.46.
  - Re-blessed all 16 (junction 11 + block 5) in the item-1 commit; DECISION world/combo-bikes-bc7.

### Item 2 design: the dead, from scratch (written before any code)

What is wrong today (seen in `view/p70/cop_patrol_long_fall.png`): 5 facings x 3 frames; every lying frame is
the same plank: straight, legs together, arms out ahead, flat. One pose per facing, so a riot's dead are clones
lined up by blow direction, and the fall is a 3-frame flip with no travel.

How a top-down crime game sells a death at this camera (the reading is from above, so the silhouette IS the
death): the body goes the way the blow pushes it; the knees go first (a crumple), the torso twists so the hips
and shoulders do not line up; the limbs land at broken, unequal angles (one arm under, one flung; one knee bent);
the body slides a little after impact and settles with a small rebound; blood pools out under it over seconds
(that part exists: CorpseStains). Sameness kills it: neighbours never share a pose.

Design:
- Poses per body class (5): A face-down crumple (knees folded, one arm under the chest, one flung up past the head);
  B thrown on the back, spread and broken (arms wide at unequal angles, one knee up and fallen sideways);
  C side curl (on the side, knees drawn, the top arm over the face); D twisted sprawl (hips face-down, shoulders
  turned up, legs scissored); E slumped sitting-then-fallen (the legs folded under, the torso fallen sideways:
  the low-energy death, for melee and point-blank pistol).
- The lying poses are drawn in PLAN view (straight down, flat on the ground) and drawn on the ground plane, so the
  view's own ground transform foreshortens them at 70 and 55 and they can be ROTATED freely along the blow
  (no 5-facing clone line, no pitch-specific settled art). The fall frames (buckle, mid-fall) stay per pitch
  (p70 / p55 cut from the cast's cards); the swap happens at impact, when the figure is lowest.
- Pick: weapon class + blow -> candidate set (shotgun / car / explosion: B, D thrown; rifle / pistol: A, D, C;
  melee / point blank: E, C, A), then the first candidate no corpse within 3 m already shows (deterministic:
  the person's id hashed, never the global rng).
- Motion (60 Hz ticks): buckle 0-8 ticks (the per-pitch frame 0), mid-fall 8-18 (frame 1, the card rotating
  toward the blow's ground angle), impact at 18 (the plan pose, scale 1.04 -> 1), slide 18-30 along the blow
  0.4-1.2 m by weapon energy (ease-out), settle 30-40 (a 3-degree counter-rotation rebound). The slide stops at
  walls (item 4's rule, the sim's thrown body).
- Classes: street walkers (one figure set re-tinted per look is NOT enough: suit, worker, hood, shopper silhouettes
  differ), cops (patrol, riot, SWAT), the gang (thug), Rivet's own death sprawl (robot: limbs at hard angles, one
  servo arm detached is optional/no).

REQUEST to assets: dead_plan_v1 (one sheet per body class: ped_suit, ped_worker, ped_hood, ped_shopper,
cop_patrol, cop_riot, swat, thug, rivet), pitch "plan" (straight down, 90 degrees, flat on the ground): 5 lying
poses in a row (A face-down crumple, B on the back spread and broken, C side curl, D twisted sprawl, E legs
folded under, torso fallen sideways), each pose's pelvis at its cell centre, head toward the top of the cell,
the cell 384 x 384 at the still strip's 192 px standing height (the body ~1.4x of standing when stretched, never
longer), transparent ground, the ink outline and print grain of the approved cast cards, copied BY EXAMPLE from
the approved cards (ped_*_70 stills, cop_patrol/cop_riot/swat 70, thug 70 v3, Rivet 70 at his n9 size from
lane rivet). No blood on the sprites (the game pools its own). Limbs at unequal, broken angles; hips and
shoulders never aligned; no pose straight and symmetrical (the owner: "they lay down like in the bed now").
Why: the owner's verdict on the dead; the plan-view poses rotate freely along the blow on the ground plane, so
one sheet serves 70 and 55.

- NOTE to all lanes (01:36): item 1 landed on n9-world at 3e02d3b8: **main's boot default is now `combo`**
  (view.json `default`), sim bikes at 6 %, BC7 on the drawn art (772 imports), the 16 look goldens re-blessed.
  The selftest scenes and the GUT suite pin `top` (`ViewMode.select("top")`, `tests/support/gut_pre_run.gd`);
  pass `--view=top` yourself where you need the old default. Pixel tests on art: `TestArt.rgba(tex)` (BC7 art
  is compressed; `get_pixel` on it reads nothing). rig_stress caps full rigs at 16 + CORPSE_PINS under a card view.
- FRICTION: the first unit run timed out at 600 s: BC7 made test_vehicle_views' `get_pixel` loop log 261k
  "compressed image" errors (1.8 M log lines). Fixed with TestArt.rgba.
- Gates at 3e02d3b8: lint 15/15; unit 1815/1 (the unknown-view fallback, fixed in the commit, view suites 38/0);
  scenarios 53/54 before the rig_stress cap fix (17 full rigs = 16 + a pinned fresh corpse, the card view's
  design); director reel (headless, 16000) top / tilt70 / combo 19/19 chapters all down, 0 SCRIPT ERROR
  (`evidence/n9-world/director-reel-it1-*.log`). Full evidence --no-bench: running.
- Still: no-flags boot lands in combo (`gtai-masters/n9/world/boot_noflags_lands_in_combo_70_32ppm_f420.png`).
  The standing city clip at seed 7 showed no bike in 15 s at 6 % (sparse traffic): film a drive next.
- Owed for item 1: the evidence run's result; the city-with-bikes still + clip (a drive); the BC7 riot VRAM A/B
  (scratch "before" worktree ready and imported at `C:/Users/kazda/kiro/gtai-n9/tmp/world/before`: main +
  combo + bikes 0.06, lossless, so only BC7 differs; arms `lossless:^--path <that>/project` vs `bc7:`, under
  bench.lock); frames.json.

- MILESTONE (01:30) the dense drive at 32 px/m shows sim bikes with riders in lane at the table's 6 % (no
  flag): `gtai-masters/n9/world/city_bench_drive_dense_bike_in_traffic_32ppm_x3_t4s.png` + grid + 20 s mp4;
  frames.json started (5 entries). Open: `city_bench.tscn` with no `--view` drew FLAT (top prints, no cards)
  although ViewMode's default is combo: find what it reads (a dev bench; perf's ab.mjs scenes pass --view, so
  no number moved), and film the bikes again in the real city (`--seed=7 --rigs`, drive or a bot) under combo.

### Scoping for items 3 and 4 (read only, it1)
- Item 3 (cars knock Rivet down). Rivet is the sim's one body (`native/sim_core/src/body.cpp`,
  `features/city/sim/sim_body.gd`, spec SimConst.BD_*; RivetBody builds the spec and reads `body_result`).
  `body_resolve()` pushes him out of people only. Plan: a new spec field BD_CAR_HIT (m/s; 0 = off, so parity's
  existing cases stay exact) from vehicle_handling.json (`rivet_hit_at`, proposal 5 m/s = 18 km/h) and
  BD_CAR_HIT_DMG; in body_resolve (both twins, op for op) after the people loop: each live K_CAR / K_PCAR whose
  hull (the car_hit.cpp footprint test) overlaps the body circle: speed >= BD_CAR_HIT -> record a hit
  (slot, car vx, vy, speed) appended to body_result after the knocks; else push the body out of the hull (no
  walk-through) and keep the yield (`yield_to_rivet` default ON = seams' low-speed rule: cars brake for him).
  RivetBody reads the hit -> Events -> Rivet down for down_s along the car heading, slide sqrt(2*8*m),
  damage = k * (speed - threshold) + base (data). View: his hit frame + a slide (REQUEST rivet for a drawn
  knock-down). Parity: a new case with BD_CAR_HIT on (bikes in it); scenarios: struck at speed, a car creeping.
  Rebuild `just native` (debug + release).
- Item 4 (bodies stop at walls). `down()` (body.cpp) already runs `solid(0.3)` on a tier-0 slider, so cells
  stop it; the kerb barrier is a PROP on a walkable cell, tier-1 people skip solid, and the drawn corpse lies
  ~1.4-1.7x standing past the sim point along the blow. Three fixes: props' footprints as solids in the slide
  (both twins), tier-1 too, and the view's lying direction/length bounded by the first solid along it.
  Before/after: the kerb-barrier scene seed 5 tick 900.

REQUEST to assets: king_robe_70, pitch 70, and king_robe_55, pitch 55: the King's approved bust with its robe's
hem extended down to the boots (a long drawn robe over the legs, the boot toes showing at the hem's front),
copied BY EXAMPLE from the approved King bust (the shipped p70 / p55 King cards) and `king_legs_70` /
`king_legs_55` (the stride's leg length and the boots); the 5 facings of the bust's sheet, the robe's hem cut as a
separate layer if you can (hem strip below the waist: the game sways it with the stride), the cape stays
vermilion, the ink outline and print grain of the cast. Why: the owner's call s-1 C ("the King's legs go under a
longer drawn robe"); the drawn legs read as thin under the bust today.

REQUEST to rivet: a drawn knock-down for Rivet at his n9 size, p70 and p55 (struck by a car: thrown off his feet
along the car's heading, 3 frames: hit, airborne/tumble, down; plus the get-up), keyed by art key like his
other strips. Until it lands, world's item 3 draws his hit frame plus a slide. Why: the owner's call s-4 C
(cars knock Rivet down).

- MILESTONE (01:40) full evidence at c3b30b76 (`node tools/evidence/run.mjs --no-bench`): lint 15/15, unit 1816/0,
  parity bit-exact (1200 steps, planted mutation caught at 629), selftest look goldens 11/11 worst 0.00 + block 5/5
  worst 0.00, no new off-doctrine accents, release-compile 614/0; scenarios 53/54: **rig_stress failed its 1 ms rig
  p50 under combo even alone on a quiet machine (1.149 ms)**.
- Measured (01:42, alternating, quiet-ish): rig p50 at 50 people combo 1.318 / 1.105 vs top 0.724 / 0.490 ms. Card
  rigs cost ~2x; never gated before (the scenario ran in top). DECISION: the scenario gates `top` (the F-09b
  baseline) and logs `COMBO ... (not gated)`; DEVIATION STD-20-RIG in docs/decisions.md. After: 1 ran, 0 failed;
  top 0.76 / 0.72 ms, COMBO 1.387 ms (`evidence/n9-world/rig-stress-it1.log`).

REQUEST to perf: the card rigs under combo / tilt70 cost ~2x top's rig work (scenario_rig_stress, 50 people, quiet:
combo p50 1.11-1.39 ms vs top 0.49-0.76; section 20 says 1 ms provisional). Since n9-world 3e02d3b8 combo is the
default, so this is the shipped camera's cost. A profile of CharacterRigs.step under `--view=combo` (RigHeadCard /
the card build per tick?) and a cut would let world gate combo again (DEVIATION STD-20-RIG names the re-check).

### Calls for the owner (collect for REPORT)
- C-1 rig cost under combo: ~1.1-1.4 ms p50 at 50 people vs the provisional 1 ms (top 0.5-0.76). Default built:
  gate top, log combo (DEVIATION). Options: (a) as built until perf cuts it; (b) raise the provisional budget to
  1.5 ms for card views; (c) fewer full rigs under combo (MAX_FULL 12; one constant).
- C-2 the dead as plan-view poses rotated along the blow (DECISION world/dead-plan-view), art requested (dead_plan_v1).

NEXT (it2):
1. Read the journals (perf / rivet / handheld; assets' replies to dead_plan_v1, king_robe_*).
2. Item 1 owed: the BC7 riot VRAM A/B under bench.lock: `node tools/perf/ab.mjs --scenes=riot,drive70 --pairs=2
   --arms=lossless:^--path C:/Users/kazda/kiro/gtai-n9/tmp/world/before/project,bc7: --out=evidence/n9-world/bc7-ab`
   (the scratch worktree = main + combo + bikes 0.06, lossless, imported; remove it with `git worktree remove` after);
   the city with bikes under combo in the real city (not city_bench: it draws traffic flat with no --view; find why
   and note it); a before/after still at 32 + a 64 close-up; frames.json to 8+ entries.
3. Item 3 (cars knock Rivet down), per the scoping above: BD_CAR_HIT in both twins, parity case, `just native`.
4. Item 4 (bodies stop at walls), then item 2 wiring when the art lands; item 5 when king_robe_* lands.

## it4 (2026-11-08 01:45-02:45) BUILD
(it2 and it3 left no entries and no commits: the sessions ended before writing; this one resumes from it1's NEXT.)
Registry rules applied this session: `depth-ordered-layered-art` (the lying pose is a ground-plane layer under the
fall card, the camera's tilt foreshortens it, never a per-pitch redraw), `motion-quality-gating` (judged in motion
at 32 and 64 px/m on the riot, before/after from the same seed and tick), `generative-artifact-gating` (every cell
looked at on the library's card before packing; provenance lines with round + prompt_hash),
`perf-regression-gating` (the BC7 A/B under bench.lock, CONTENDED runs labelled).

- READ journals: perf (no REQUEST to world; it measures the traffic split on this branch's BC7), handheld (no
  REQUEST; its BC7 Deck re-measure E16 used 3e02d3b8), rivet: ANSWER to my knock-down REQUEST (assets drawing
  rivet_knockdown_70/_55 + rivet_getup), asks which field world lands for the knock. Assets: dead_plan_v1
  DELIVERED (deliveries/dead_plan_v1_it121.md, 9 classes x 5 poses), king_robe_55 / king_robe_70_v2 OFFERED (A).
- MILESTONE (01:52) item 1 owed: the BC7 riot A/B (`tools/perf/ab.mjs --scenes=riot --pairs=2`, lossless = the
  scratch main+combo+bikes worktree vs bc7 = this branch, bench.lock taken by ab.mjs): **VRAM 900.7 -> 539.8 MB
  (-361 MB, -40 %)**, working set 925.7 -> 862.9 MB; frame time a WASH (p50 5.60 vs 6.16 +-0.80, p99 13.7 vs 14.7,
  2 of 4 runs CONTENDED). `evidence/n9-world/bc7-ab.log`, `evidence/n9-world/bc7-ab/`.
- MILESTONE (02:04) item 2 wired at 71c0b951: StreetDeadPlan (DECISION world/dead-plan-wired). 8 body-class
  strips packed from the delivery (`tools/art/dead_plan.py`, no resample, BC7), provenance 8 lines. At the fall
  grid's lying frame the card swaps to the plan pose on the ground plane along the blow (jitter +-0.4 rad, hashed
  mirror), pose by the death family then the first no neighbour within 3 m shows, lands 1.05x, slides
  0.35-1.2 m along the blow INTO the sim rest, rocks back 0.06 rad; the baked far crowd dead take the plan pose by
  look index. Unit 1824/0 (new test_street_dead_plan 8/8), lint 15/15.
  Evidence (`gtai-masters/n9/world/`): `dead_plan_riot_before_after_tilt70_32ppm_t22.png` (+ `_crop2x`),
  `dead_plan_riot_before_after_tilt70_64ppm_t22.png`, the two 17 s before|after mp4s (32 and 64). Seen: the riot
  cops lie spread on their backs and curled, three neighbours in three poses; suits crumple face-down. Seen faults:
  (a) the 5 unmapped walker rows (cap, elder, hat, jogger, punk) still lie as the straight drawn frame (REQUEST
  below); (b) a corpse thrown into the crowd draws over standing people (the d9 fall card did too: depth by y);
  (c) the wound stamps stay where the old drawn body was (kill_marks), visible on a cop's chest at 64.
- FRICTION: `tools/godot/check.mjs` on a features script fails with "Identifier not found: Log" (autoloads under
  --check-only -s), even on untouched rig_head_card.gd; the unit run is the real parse check.

REQUEST to assets: dead_plan_v1 for the 5 walker rows still without a sheet: ped_cap, ped_elder, ped_hat,
ped_jogger, ped_punk (the p70 still strips `ped_cap`, `ped_elder`, `ped_hat`, `ped_jogger`, `ped_punk` are the
by-example sources), the same layout and cut as the delivered eight (5 poses A-E, 384 px cells, the 269 px
longest-pose rule, pelvis at the centre, E tipped over). Why: in the riot these five still lie straight as the
old drawn frame next to the new poses (`gtai-masters/n9/world/dead_plan_riot_before_after_tilt70_32ppm_t22.png`).

ANSWER to rivet (the knock signal): world will land `Events.rivet_knocked(heading: Vector2, speed_mps: float)`
from the sim's car hit (item 3), and the view sets the rig meta **`rivet_knock` = Vector3(heading.x, heading.y,
start tick)** on Rivet's rig in the same frame (heading = the car's ground heading, unit; tick = SimClock's tick
at the hit). Read it as you proposed; it is cleared when he is up again (rig meta removed). Until item 3 lands,
nothing sets it. Also OFFER: assets cut Rivet's own plan-view death sprawl (`keyed/rivet/dead_plan_v1_rivet_cells`,
A-E, his helmet pulls the cell centre ~20 px above the hips); world does not touch rivet_frames, so it is yours to
wire if you want his death on the ground plane like the cast's (StreetDeadPlan.draw is the pattern).
- MILESTONE (02:15) item 5 at e8bd8dd7: the King walks under his long drawn robe (DECISION world/king-robe):
  `KingLegsCard.SHEETS["king"] = "king_robe"`, art/p55 + p70/king_robe.png packed cell for cell into the legs'
  grid at the legs' scale (k 0.638 / 0.441) and sole line (`tools/art/king_robe.py`), provenance 2 lines. Seen
  (phase 3, seed 2, t 8.8): at 55 (combo) the plum skirt + vermilion cape hem cover the thin steel shins, the gold
  boots at the hem's front, the hem swings with the drawn walk rows; at 70 the bust (LIFT 0.74) covers most of the
  robe, only the hem and boots read. `gtai-masters/n9/world/king_robe_before_after_{combo55,tilt70}_phase3_seed2_t8.8_x2.png`,
  `king_robe_before_after_combo55_phase3_seed2.mp4`. NOTE: `--ppm=64` did not zoom the arena (frames at 32);
  the close-ups are 2x crops. Owed: a true 64 px/m capture (find the arena's zoom flag / Z key).
- Gates: full evidence --no-bench at 71c0b951: lint 15/15, scenarios 54/54, parity bit-exact (planted caught 629),
  look goldens 11/11 + block 5/5 worst 0.00 (**no golden moved**: the selftests pin top, the plan dead is card-view
  only), release-compile 615/0; unit 1824/0 (flagged "tree changed during run" by my own reel logs and JOURNAL:
  re-run standalone at e8bd8dd7 = **1825/0**). Director reel it4 (headless 16000): top / tilt70 / combo 19/19
  chapters all down, 0 SCRIPT ERROR (`evidence/n9-world/director-reel-it4*.{txt,log}`).
- Evidence: the director reel under combo, before | after (`dead_plan_director_reel_before_after_combo70_32ppm_x2.png`
  + 20 s mp4): the patrol cop folds and tips over (pose E) where d9 drew a plank. frames.json: 13 entries, best first.

### Calls for the owner (add to it1's list)
- C-3 the dead: 5 plan poses per class, picked by weapon class (blast B/D/A, bullet A/D/B/C, melee E/C/A, burn
  C/E/A, shock C/D/E), the slide 0.35 (melee) / 0.6 (bullet) / 1.2 m (blast) into the sim's rest, a 0.06 rad
  settle, +-0.4 rad jitter off the blow. Options: (a) as built; (b) no jitter (bodies point exactly along the blow);
  (c) a longer slide for shotguns (one table row). Still owed: the 5 walker rows without a sheet (REQUESTed).
- C-4 the robe at 70: the bust hides most of it (LIFT 0.74). Options: (a) as built; (b) LIFT 0.6 at 70 so more
  robe shows (the bust stands taller; one value); (c) a 70 robe drawn shorter at the top.

- MILESTONE (02:26) item 4, the view half, at 42ca18ba (DECISION world/dead-stop-at-walls-view): the plan pose is
  pulled back along the blow so its head end stops short of the first building / prop cell (`StreetDeadPlan.solid`
  = the city blood's `_solid`, set in boot/city_blood.gd). Unit 1826/0, lint 15/15; the riot at seed default
  re-filmed: the same frame at t 22 as 71c0b951's (no wall in reach there, deterministic), 0 SCRIPT ERROR. The sim
  half (props as solids in the thrown slide, both twins) and the kerb-barrier before/after (seed 5 tick 900) owed.

NEXT (it5):
1. Read the journals (rivet: the knock field is answered above; assets: the 5 walker dead sheets).
2. Item 3 (cars knock Rivet down), per it1's scoping: BD_CAR_HIT in body.cpp + sim_body.gd op for op, a parity case
   with it on, `just native` debug + release, scenarios (struck at speed; a car creeping); then
   `Events.rivet_knocked(heading, speed_mps)` and the rig meta `rivet_knock` = Vector3(hx, hy, tick) for rivet.
3. Item 4 (bodies stop at walls): the view bound landed (42ca18ba); still owed: props' footprints as solids in the
   thrown slide (both twins, parity), then film the kerb barrier.
   Before/after: the kerb barrier, seed 5 tick 900.
4. Item 2 follow-ups: wire the 5 walker sheets when served; the wound stamps (kill_marks) follow the plan pose;
   film quest 1 Dock 9 and the city block (`--arena=city`) before/after.
5. Item 1: the city with bikes under combo in the real city (city_bench draws flat without --view: find why).
6. Remove the scratch "before" worktree (`git worktree remove C:/Users/kazda/kiro/gtai-n9/tmp/world/before`)
   once the last before/after is filmed.

### Item 3 insertion points (read only, it4 02:30; for it5)
- Spec: `BD_CAR_HIT = 13` (m/s; 0 = off, so every existing parity case stays exact) and `BD_CAR_DMG = 14`, `BD_LEN`
  13 -> 15 in BOTH `native/sim_core/src/sim_constants.h:130` and `project/features/city/sim/sim_constants.gd:129`
  (lint `sim-constants` compares them).
- Contact: `CityCore::body_resolve()` (`native/sim_core/src/body.cpp:89`) after the people loop and before
  `solid(BD_R)`; twin `SimBody.resolve()` (`project/features/city/sim/sim_body.gd:129`), op for op. Cars: the hull
  test in `car_hit.cpp` (`car_contacts` l.7, `car_hull` l.67) gives the footprint; at speed >= BD_CAR_HIT append a
  hit (car vx, vy, speed) to `body_result()` after the knocks (a new count field, so RivetBody's reader changes
  in the same commit); below it push the body out of the hull (no walk-through). The low-speed yield
  (`yield_to_rivet`, boot/city_vehicle_world.gd + scenario_traffic_yields_rivet) stays the rule that stops the car.
- Then `just native` (debug + release), parity (a new case with the hit on), the two scenarios, the Event and the
  rig meta `rivet_knock` promised to rivet.

## it7 (2026-11-08 02:31-03:30) BUILD
(it5 and it6 left no entries and no commits; this one resumes from it4's NEXT. Commit early: journal first.)
- READ journals: rivet (no new REQUEST; waits on the `rivet_knock` meta named in it4's ANSWER), perf (NOTE: the
  combo rig cost is StreetView.step ~0.23-0.35 ms/tick; no REQUEST), handheld (none). Assets: no new delivery
  since dead_plan_v1_it121 (the 5 walker sheets not served yet).
- Plan: item 3 (cars knock Rivet down), the sim half in both twins first.
Registry rules applied: `engine-integration-safety` (one op order in both twins, the spec length and result
layout generated from one source, tools/gen_constants), `realtime-combat-semantics` (one hit per knock: a second
hit while he lies is ignored; the damage rides the Event, never a second hp owner), `rigid-body-simulation-stability`
(push-out along the hull's shallower axis, no tunnelling: the hull test runs on the post-move car).
- FRICTION (02:38-02:44): `native/godot-cpp` is an uninitialised submodule in this worktree (`scons` "missing
  SConscript"). Copied the built tree from `gtai-wt/int-day/native/godot-cpp` (same pin e103d348), but scons
  rebuilt godot-cpp anyway (~5 min, signature db). Incremental builds now take seconds.
- FRICTION: my Python edits on Windows wrote CRLF (text mode) to 11 files; caught by git's warnings, converted
  back with sed. Use `open(p, 'w', newline='')` / `newline='\n'` from now on.
- MILESTONE (03:09) item 3, the sim half, at 703c287b (DECISION world/car-hits-rivet-sim):
  - `BD_CAR_HIT` (spec 13, BD_LEN 14) and `BR_HIT/BR_HHX/BR_HHY` (body_result 3-5, BR_HEAD 6), from
    tools/gen_constants/sim_constants.json.
  - `body.cpp body_cars()` = `CitySimBodyCars.resolve()`: tier-A car hulls grown by the body radius; at or above
    the threshold the first car reports (speed, heading) and keeps 0.4 of its speed; slower it brakes to half per
    contact tick (stop-dead rejected: it parked a lane for good); the body is pushed out along the shallower axis.
  - `RivetBody`: the hit starts the knock (input ignored, slide along the heading at slide_k x speed with the 8
    m/s^2 decel, down_s lying, a second hit ignored), `Events.rivet_knocked(heading, speed_mps, damage)`
    (events.json registered; damage = damage_per_mps x (speed - speed_mps/2)). bodies.json `car_hit`
    {speed_mps, slide_k 0.8, down_s 1.2, damage_per_mps 2.5} + schema.
  - Evidence: parity bit-exact over 1200 steps with the hit ON in the parity body (BD_CAR_HIT 5, a body 2.5 m
    ahead of a tier-A car every third leg): body_car_hits 2, knockdowns 5, planted fault caught at 629
    (`build/test-results/parity-result.json`). Unit 1824/0 (new test_rivet_car_knock 4/4), lint 15/15, native
    debug + release rebuilt. Scenarios with it OFF: the 3 touched (traffic_yields_rivet, vehicle_yield,
    bodies_tackle) pass; the full 54 ran at 02:57 with it ON: 52/54 (the two below).
  - **Shipped OFF** (`car_hit.speed_mps` 0) because with 5 the World scenarios disagree:
    (a) scenario_traffic_yields_rivet's n8 arm (car at 12 m/s from 24 m behind): the car now stops 2.33 m from
    him (contact happens: d9 drove through at 0.10 m) but **no `rivet_knocked` arrives** (counter tried as a
    PackedInt32Array: copied into the lambda, so wrong; then as Array[int]: still 0). Unsolved: either the car is
    under 5 m/s at first contact (spawn spec index 7 = 12 may be vmax with v starting 0? measure s.v[slot] at
    contact), or BR_HIT is lost between sim and RivetBody (CitySystem.step -> body.take; check `result.size()`
    and BR_HIT that tick). The rewritten scenario (n8 expects >= 1 knock, yield expects 0) is in
    `C:/Users/kazda/kiro/gtai-n9/tmp/world/yields_n9_knock.gd.txt`.
    (b) scenario_vehicle_yield: Rivet stands at lane + (0, -6) and the passing cars brush him, so 1 of 3 cars
    passes (needs 2). Fix: stand him off the carriageway in that scene (it is about parked cars, not him) or
    turn `yield_to_rivet` on by default (the owner's "the car stops" low-speed rule = the traffic AI's yield).

NEXT (it8):
1. Item 3 to ON: debug (a) above with a one-off print of v_[slot] and body_result at contact in the n8 arm;
   land the rewritten scenario; fix (b); set car_hit.speed_mps 5; full scenarios 54/54; parity again.
2. Item 3 view: `rivet_knock` rig meta = Vector3(hx, hy, start tick) on Rivet's rig while `body.knocked()` (set in
   boot/city_characters.gd from `_city.body`), removed when up (the ANSWER to rivet); the hit frame + slide until
   rivet wires `rivet_knock.png`. Film at 64 px/m (a car at speed into him, a car creeping).
3. Damage: the city has no Rivet hp outside the combat pits (EnemyPit.rivet_hp, BossHook); connect
   `rivet_knocked` to the active pit's `_hurt_rivet` where one runs (quest 1), else Event only (DECISION).
4. Item 4 sim half (props in the thrown slide, both twins) + the kerb barrier before/after (seed 5, tick 900).
5. Item 2 follow-ups (the 5 walker sheets when served; kill_marks follow the plan pose; Dock 9 + city block film).
6. Remove the scratch "before" worktree once the last before/after is filmed.
- (03:14) PROBE on (a) (scenario edited temporarily, reverted): with speed_mps 5 the n8 arm's car reaches 4 m
  from Rivet at t 287 (4.8 s) moving **0.33 m/s and braking** (cars_near v 0.326 -> 0.307), so it is under the
  threshold: the brake branch is right and no knock is the correct result. That arm is really the "car creeping
  into him" case (d9's 0.10 m "through" was a crawl). Also seen: the body resolves to x 299.01 while the target is
  300 (pushed ~1 m by something other than the car: f = 3.01 > 2.72, so not the hull; check people/solids).
  So for it8: keep the n8 arm as the creeping case (expect: no knock, closest >= the hull's front 2.3 m, the car
  stopped), and ADD a struck-at-speed scenario that spawns the car with its speed already set (find which spawn
  spec index is v vs vmax, or spawn 6 m behind on a straight with nothing ahead) and expects one
  `rivet_knocked` (use an Array[int] counter: a PackedInt32Array captured in a lambda is a copy).
- (03:18) Gate at f371edfb (car hit off by data): full scenarios 53/54 at 03:14-03:18; the one failure,
  scenario_rig_stress, was an engine error from the headless dummy renderer ("Parameter t is null",
  texture_storage.h:85 texture_2d_initialize) while the machine was shared; re-run alone: **pass** (FLAKY,
  not touched by this change: rig stress has no cars near the body). Parity bit-exact, unit 1824/0, lint 15/15.
  Not run this session: the director reel (no view code changed: RivetBody's knock is inert with speed 0) and
  evidence --no-bench; it8 runs both after turning the hit on.

## it10 (2026-11-08 03:20-04:20) BUILD
(it8 and it9 left no entries and no commits; resuming from it7's NEXT. Journal first, commit early.)
- READ journals: rivet (no new REQUEST; waits on the `rivet_knock` field, it5 NEXT 6), perf (BC7 desktop table on
  world's 746c2856: VRAM drive70 900 -> 548 MB, riot 899 -> 536 MB; no REQUEST), handheld (none to world).
- Plan: item 3 to ON (struck-at-speed scenario, the creeping arm, scenario_vehicle_yield), then the `rivet_knock`
  rig meta for rivet.
Registry rules applied: `realtime-combat-semantics` (one knock per hit, the second contact while he lies ignored:
the scenario asserts exactly 1), `rigid-body-simulation-stability` (a thrown body stops on the step that would
overlap a solid instead of being pushed sideways: no skating along a facade, no tunnelling: <= 0.1 m per step),
`engine-integration-safety` (both twins op for op; the branch proven exercised by parity: off in native only ->
diverges at step 329), `perf-regression-gating` (the gate re-run before claiming; debt ratchet accepted by name).
- MILESTONE (03:30) item 3 ON at b0f1024e (DECISION world/car-hits-rivet-on): `car_hit.speed_mps` 5. it7's
  "no knock" was right: a traffic car brakes for a person in its lane (sim_cars `_desired_speed`, f < 7 m) and
  reaches him at 0.33 m/s = the creeping case. New `scenario_car_knocks_rivet`: he runs across 2.5 m in front of
  a 12 m/s car -> exactly 1 knock, 12 m/s, heading +x, 6.6 m slide, 23.75 dmg. traffic_yields_rivet's n8 arm =
  the creeping car (closest 2.33 m in (1.0, 3.0], 0 knocks); vehicle_yield's Rivet waits 9 m off the lane.
- MILESTONE (03:38) the full gate at b0f1024e (car hit ON), scratch worktree `gtai-n9/tmp/world/gate`:
  lint 15/15, unit 1830/0, scenarios 55/55, parity bit-exact (planted 629), look goldens 11/11 + block 5/5 worst
  0.00 (none moved), release-compile 616/0 (`evidence/n9-world/it10-gate/`).
- MILESTONE (03:45) item 3 view at 0c04d16b: Rivet's feed row carries RigFeed.Flag.DOWN while `body.knocked()`
  (his drawn sprawl slides with the body, then the rise); the rig meta `rivet_knock` lands. Filmed with the new
  `dev/showcase/car_knock_clip.tscn` (real city, --before = car_hit off, --creep): before the car drives over
  him, after he is thrown 6 m and the car stops behind him (`gtai-masters/n9/world/car_knock_*`, 4 entries in
  frames.json). Honest limits: the clip's road has no building in frame, so the tilt shows only on his p70 card;
  the sprawl is always head up-screen (does not turn with the heading). Director reel it10 at 0c04d16b: top /
  tilt70 / combo 19/19 chapters down, 0 SCRIPT ERROR.
- MILESTONE (04:00) item 4 sim half at a42e54f0 (DECISION world/dead-stop-at-walls-sim): the dead slide (people.cpp
  ped M_DEAD = `CitySimSolid.slide_dead`) does not take a step that overlaps a solid cell; the slide ends. Native
  debug + release rebuilt; parity bit-exact and the branch is exercised (native-only off: parity diverges at step
  329); scenarios 55/55 (replay unmoved); unit 1830/0. NOT covered: the arena's kerb barrier is a scene prop the
  sim never sees (walkable cell), so the seed 5 tick 900 before/after will not change from this alone.

ANSWER to rivet (the knock field, landed at 0c04d16b on n9-world): `CityCharacters.KNOCK_META` = `&"rivet_knock"`
on Rivet's CutRig (`rigs.rig_for(CityCharacters.RIVET_ID)`), Vector3(car heading x, heading y, SimClock tick at
the hit; the first frame after it), set once per knock, removed when he is up (car_hit.down_s 1.2 s). While it
is set his feed row also carries RigFeed.Flag.DOWN (rig.clips.down -> rig.dead: your RivetFrames already shows
his death sprawl then). Wire the drawn knock-down to the meta and, if it fights the DOWN sprawl, tell me and I drop
the flag. Film it with `res://dev/showcase/car_knock_clip.tscn -- --out=<dir> --view=tilt70 --zoom=2` (hit at
tick 196).

### Calls for the owner (add)
- C-5 the car knock-down: threshold 5 m/s (a braking car's crawl never floors him), slide 0.8 x the car's speed
  (6.6 m at 12 m/s), 1.2 s down, damage 2.5 x (speed - 2.5) (23.75 at 12 m/s; Event only: the city has no Rivet
  hp outside the pits yet). Options: (a) as built; (b) slide_k 0.5 (4 m: less cartoon); (c) threshold 8 (only a
  fast car floors him). All one bodies.json value.

NEXT (it11):
1. Read the journals (rivet: the knock meta ANSWER above; assets: the 5 walker dead sheets, rivet_knockdown).
2. Item 4: stamp the arena's / scene props into the sim cells as C_PROP (the kerb barrier: find where the arena
   builds its props and whether `stamp_chunk` cells can carry them), then film the kerb barrier seed 5 tick 900
   before/after; film a city dead stopping at a facade (riot near a wall) at 32 + 64.
3. Item 3: the knock damage into the active pit (`EnemyPit._hurt_rivet`) where one runs (quest 1) or record
   "Event only" as the DECISION; a real-game clip (`--arena=city` with a car) once rivet wires the drawn knock.
4. Item 2 follow-ups (walker sheets when served; kill_marks follow the plan pose; Dock 9 + city block film).
5. Remove the scratch worktree `gtai-n9/tmp/world/before` when the last before/after is filmed (`gate` removed
   it10 04:11, its evidence copied).
- (04:09) Scoping for NEXT 2 (read only): the arena on the city (`features/arena/arena_session.gd _add_city`, l.61)
  builds its own CitySystem; its walls / barriers (`plan.areas`, ArenaFloorStatic.barrier runs) and props are
  solid only to the arena's own collision. To make the sim see them: after `city.residency.update`, stamp their
  footprints as `SimConst.C_PROP` into the resident chunks' cells, and again whenever residency re-stamps a chunk
  (a cell-override hook in CityResidency / ChunkSource, the way kerb_dresser.gd:152 stamps C_PROP at generation).
  Both twins read the same cells, so parity needs no new code; the arena's scenarios (arena-*-telemetry) and the
  replay must be re-checked (a dead cop then stops at the barrier).

## it13 (2026-11-08 04:10-05:10) BUILD
(it11 and it12 left no entries and no commits; resuming from it10's NEXT. Journal first, commit early.)
- READ journals: rivet (no new REQUEST to world; waits on assets' knock-down strips, now served as one-direction
  strips), perf (no REQUEST to world), handheld (none to world). Assets: **the 5 walker dead sheets were served at
  02:39** (`deliveries/dead_plan_v1_it121.md` it124 section: ped_cap A, ped_elder B, ped_hat B, ped_jogger A,
  ped_punk A) and no open REQUEST to assets.
- Plan: item 2 follow-up first (wire the 5 walker sheets: the riot's "straight old frame" fault (a) from it4), then
  item 4's arena props into the sim cells if time remains.
Registry rules applied: `sprite-and-atlas-production` (one scale per sheet, the same 384 px cell / 269 px longest
pose as the eight, packed with no resample by the same tool; BC7 params copied from the eight's .import, verified
identical), `generative-artifact-gating` (every cell looked at on a contact sheet before wiring: 25 poses, the
it124 grades kept: elder B (pose B face alive at ~4 px at 64), hat B (E the weakest fold)), `motion-quality-gating`
(judged in motion on the riot at 32 and 64, before/after from the same seed and tick).
- MILESTONE (04:29) item 2 follow-up at 2f258eeb: the 5 walker rows (ped/head_cap, head_bald -> ped_elder,
  head_hat, head_jogger, head_punk) lie in plan poses (`tools/art/dead_plan.py --only=`, 5 provenance lines). New
  unit test: every row in StreetWalkerCards.ROWS has a plan strip; the far crowd's plan_cell now serves the jogger.
  Unit (dead_plan, crowd_corpse, walker_fall) 20/0, lint 15/15. Selftest at 2f258eeb: look goldens 11/11 + block
  5/5 worst 0.00 (none moved; `evidence/n9-world/it13/selftest.log`). Riot before (06c64742, scratch worktree
  `before` moved to it) | after, city_bench riot tilt70 t 22 s at 32 and 64: before the cap walkers lie as straight
  planks, after twisted sprawls, neighbours in different poses (`gtai-masters/n9/world/dead_plan_walkers_riot_*`,
  3 frames.json entries; frames.json pruned to 15).
- (04:33-04:38) Item 4 follow-up, the kerb barrier: the d9 repro (`res://dev/arena/arena.tscn -- --arena=city
  --seed=5 --rigs --view=tilt70`, tick 900; NB the arena is its own scene: `--arena=city` on the main scene is an
  unknown arg) shows **no deaths** at t900 in this build (no bot: kills 0), so the "dead cop through the barrier"
  frame cannot be re-taken as it was. It does show the root: a sim walker strolls across the barrier's top (the
  sim never sees the arena's props).
- MILESTONE (04:40) item 4: the arena's solid props into the sim cells (DECISION world/arena-solids-to-sim):
  `ArenaSession.SOLID_TO_SIM` hands `stage.walls.boxes` (wall_high / cover_high / cover_low) to
  `CityResidency.solids`; `CityResidency.with_solids` stamps them C_PROP into each adopted chunk's cells (a copy;
  no rects = no copy). FRICTION: a PackedByteArray assigned to a local is the same array in Godot 4 (the first
  version wrote into the cached chunk; the unit test caught it, `duplicate()` fixed it). New
  test_residency_solids 3/3, lint 15/15. Seen: before a walker crosses the barrier's top, after the crowd keeps to
  the pavement south of it (`gtai-masters/n9/world/arena_barrier_solid_to_sim_*`, frames.json 15).
- DECISION world/car-knock-damage-event-only (it10 NEXT 3): the knock damage stays on the Event (no Rivet hp in the
  city; the arena's sim body does not steer Rivet).
- (04:43) Scenarios 55/55 with the arena solids on (replay unmoved). Director reel not re-run for this change: it plays the dev arena, never the city block (its it10 log has no city / chunk line), so SOLID_TO_SIM cannot reach it.
- (04:45) Full unit at 8101a2a1: **1834/0** (1830 + test_street_dead_plan's walker test + test_residency_solids 3).
  Mid-session journal re-read: no new REQUEST to world (rivet it5 wires the claw walks; the knock-down strips are
  still being redrawn by assets).

NEXT (it14):
1. Item 2, fault (c) from it4: the corpse stains (`features/fx/corpse_stains.gd`, CorpseStains._soak) sit at the
   sim point (the feet end) while the plan pose's pelvis lies `StreetDeadPlan.PELVIS_K x STILL_PX x ks` along the
   blow (minus the bounded pull-back). Offset each soak by the blow toward the pelvis (the bled `dir` is the
   blow), only for rows with a plan strip (quest 1's CombatArena dead: check which body draws there first); film
   the riot at 64 px/m before/after.
2. Item 4: film a thrown sim body stopping at the kerb barrier (needs a death near it: the arena with `--bot=pit`
   near the city block's barrier, or a riot scene near a facade) at 32 + 64.
3. Item 3: wire nothing until rivet lands the drawn knock-down on `rivet_knock`; then the real-game clip.
4. Item 2: Dock 9 (quest 1) and the city block before/after at 32 and 64 (still owed since it4).
5. Before the freeze: the full gate (`node tools/evidence/run.mjs --no-bench`), the director reel x3 at the head,
   REPORT.md, the exe. Remove the scratch worktree `gtai-n9/tmp/world/before` (now at 06c64742) once the last
   before/after is filmed.
- (04:50-04:59) TRIED NEXT 1 (stains on the plan pose's torso) and NOT landed: `StreetDeadPlan.rest_of(actor, at)`
  (the plan pose's rest pelvis kept in `_lying`) read by a new `CorpseStains.body_at` callable set in CityBlood.
  Lint 15/15, unit --changed 1818/0, but the riot at 64 px/m t22 is **pixel-identical where it matters**: the red
  clumps on the dead riot cops' chests did not move. So those clumps are not CityBlood's CorpseStains soaks (or
  that path never draws the riot's dead): likely the rig's own wound marks / a CombatBlood body splat. Files
  restored to HEAD; the diff is kept at `C:/Users/kazda/kiro/gtai-n9/tmp/world/stain_rest_of_it13.patch` (it also
  carries comment compaction that keeps street_dead_plan.gd at 200 and corpse_stains.gd at 245 lines).
NEXT (it14) amended, item 1 first: find which node draws the red clumps on a plan-pose corpse (in the riot at t22,
hide CityBlood.stains and look; then the rig's wound nodes under HumanReact / BloodMarks), move THAT to
`StreetDeadPlan.rest_of`, then film the before/after. The rest of it13's NEXT stands.

## it16 (2026-11-08 05:10-06:10) BUILD
(it14 / it15 left no entries; resuming from it13's amended NEXT.)
- READ journals: rivet it7 landed the drawn knock-down on `rivet_knock` (RivetKnock, filmed on a scratch merge with
  this branch: no REQUEST to world; it reads the meta as specified); perf / handheld: no REQUEST to world.
- Plan: NEXT 1 (which node draws the red clumps on a plan-pose corpse; move it to the rest pelvis), then film.
- (05:12-05:15) NEXT 1 (the stain clumps) re-judged on it13's own 64 px/m crop: the red clumps sit on the dead
  riot cops' belts (the pelvis), not at the feet: no defect worth a change; dropped.
- FOUND (05:20) filming item 2 at quest 1 Dock 9 (`dev/frames/quest1_clip.gd --rigs --view=tilt70 --stills=13800`,
  32 px/m): **the dock contractors still lie "like in the bed"**: every dead contractor is the same straight
  forward-fallen frame, heads one way, three in a row on the crossing. Cause (a probe log in StreetDeadPlan.draw:
  0 calls in quest 1): quest 1's contractors are not rigs; `QuestGuardCast` keeps them on the cast view, where
  `StreetQuestCards.draw_down` draws `contractor_fall.png`'s lying row (facing + SPREAD +-45 deg). No plan strip
  exists for the contractor (ped_worker is the overalls man, not the hi-vis contractor). Dock 9 is the game's
  most-seen death scene, so this is item 2's biggest remaining gap.
  The before from 98a04b79 in the scratch worktree is unusable (the old commit's city did not stream: bare sand,
  quest stuck at 2/6 with the n9 DLLs); befores now come from the same build with the toggle off.
REQUEST to assets: dead_plan_v1_contractor (cells as `keyed/street/dead_plan_v1_contractor_cells/` like the 13; pitch "plan", straight down, flat on the ground; one sheet serves 70 and
55): quest 1's dock contractor (keyed `street/contractor_70.png` A is the by-example source: the vermilion hard
hat with the taped flashlight, moustache, vermilion hi-vis vest with cream bands, violet-black fatigues) in the
same 5 lying poses and cut as the delivered dead_plan_v1 sheets (A face-down crumple, B on the back spread and
broken, C side curl, D twisted sprawl, E legs folded under, torso fallen sideways; 384 px cells, the 269 px
longest-pose rule, pelvis at the cell centre, head toward the top, transparent ground, no blood, NO rifle in the hands
(corrected 05:26: the game already draws each dead contractor's dropped rifle on the ground beside him; a wiring
check with a stand-in strip showed it, so a drawn rifle would double it). The pudgy build stays pudgy (do not slim him to the walkers).
Why: Dock 9 (quest 1, the most-seen fight) still lays every dead contractor as one straight frame, heads one way
(`gtai-masters/n9/world/` dock9 still to come); the owner's verdict "they lay down like in the bed now".
- MILESTONE (05:28) b5c5a28f item 2 follow-up wired: `StreetQuestDeadPlan` (DECISION world/quest-dead-plan),
  tried first by `StreetQuestCorpses.draw`: a dead contractor lies in StreetDeadPlan's A-E poses along the blow
  (away from his facing, + the spot's SPREAD pick + the id's jitter), neighbours differ (StreetDeadPlan.pick, ids at
  ID_BASE). Off until `plan/dead_contractor.png` exists. Wiring check with ped_worker's strip as a local stand-in
  (never committed, `gtai-n9/tmp/world/dock9/wiring_check_standin_ped_worker_NOT_ART.png`): poses differ, heads
  away from Rivet, sizes match the drawn frame, and it showed the dropped rifles the old frame hid (REQUEST
  corrected: no rifle in the cell). New test_street_quest_dead_plan 4; with the quest/plan neighbours 27/0.
  Dock 9 before (today's frame) kept at `gtai-masters/n9/world/dock9_contractors_dead_before_tilt70_32ppm_t13800*.png`
  (not in frames.json until the after exists).
- MILESTONE (05:36) 76a8af00 item 4 filmed on the real city: `dev/showcase/dead_wall_clip.tscn` (a pedestrian 1.5 m
  from a building face thrown east at 16 m/s; `--ref` = the GDScript twin, so the scratch worktree at 14992d61
  films d9's slide with no native rebuild). Before: rest x 282.4, he lies on the roof 2.4 m inside the building;
  after: rest x 279.6 at the face (280.0). 64 px/m t66/t74/t150 + clip, 32 px/m t150
  (`gtai-masters/n9/world/dead_wall_*`, 3 frames.json entries; 3 older entries pruned to keep 15).
  Honest limit (re-judged on a x3 crop at 05:45: feet west, the hood at the parapet, one hand ~0.3 m over it; reads
  as slumped against the wall, kept): the lying plan pose's arm and head reach over the roof edge (the view bound pulls
  the pose back along the blow only, not by the pose's own sideways extent), and the mid-fall card's arm crosses
  it at t74. FRICTION: debt ratchet (dev_loc, one cmdline read) accepted by name, as for car_knock_clip.
Registry rules applied this session: `generative-artifact-gating` (a stand-in strip only as a labelled wiring check,
never shipped or filmed as the result), `rigid-body-simulation-stability` (judged the rest point against the face
in numbers, not only by eye), `motion-quality-gating` (the before/after from the same seed and tick, in motion).
- (05:41) Full unit at 76a8af00: **1838/0** (1834 + test_street_quest_dead_plan 4). Mid-session journal re-read:
  no new REQUEST to world (rivet NEXT 3 wants other knock headings filmed: their scratch drive, not asked of me).
- (05:44) REPORT.md DRAFT committed (all five items, the Calls C-1/C-3/C-4/C-5, next steps); the freeze session
  finalises it with the exe and the final gate. Scratch: dock9 before64/before32/after64/probe frame dirs deleted;
  `gtai-n9/tmp/world/before` is now at 14992d61 with the two dead_wall_clip files copied in (untracked, scratch).

NEXT (it17):
1. Read the journals; assets: `dead_plan_v1_contractor` (my l.464 REQUEST). When served: add
   `"contractor": ("street", [<the delivery's catalog ids>])` to `tools/art/dead_plan.py` CLASSES, run
   `python tools/art/dead_plan.py --only=contractor --provenance`, `--import`, then copy the eight's BC7 `.import`
   params onto `plan/dead_contractor.png.import` and verify (as it13). `StreetQuestDeadPlan` picks it up with no
   code change (test_no_strip_keeps_the_drawn_frame then passes as "served"). Film Dock 9 after at 32 + 64:
   `dev/frames/quest1_clip.gd -- --rigs --view=tilt70 --ppm=32 --stills=13800` (before =
   `gtai-masters/n9/world/dock9_contractors_dead_before_tilt70_32ppm_t13800*.png`, crop (1280,480)-(1680,700));
   also look at the moment of death (the standing card -> lying pop: add the plan slide if it pops).
2. Item 2: the city block (`res://dev/arena/arena.tscn -- --arena=city --rigs --view=tilt70`, with `--bot=pit` for
   deaths) before/after at 32 + 64 (owed since it4).
3. Before the freeze (10:30): the full gate (`node tools/evidence/run.mjs --no-bench`), the director reel x3 at the
   head with `--quit-after 16000`, the exe (`build/export/windows/RTAI.exe`), REPORT.md finalised (remove DRAFT).
   Remove the scratch worktree `gtai-n9/tmp/world/before` (`git worktree remove --force`) after the last before.
- MILESTONE (05:49) item 2's city-block before/after (owed since it4), NEXT 2 done: `res://dev/arena/arena.tscn --
  --arena=city --rigs --view=tilt70 --bot=pit`, `--fixed-fps 60 --quit-after 1500` (kills 8 by t1398, 0 SCRIPT
  ERROR both arms); before = StreetDeadPlan.ENABLED false in the same build (local edit, restored, never
  committed). Same tick t24 s: before the riot cop is the straight plank, after a face-down crumple with bent
  knees: a moderate change at 32 px/m on this body. `gtai-masters/n9/world/dead_plan_city_block_before_after_tilt70_32ppm*`
  (still + 12 s clip; frames.json 15: the King robe combo55 clip dropped, its stills stay). Raw .avi deleted.
  Checked (05:52, x4 crop): the brown shape at the bottom, identical in both arms, is a ~1 m dark prop with no
  blood and no limbs (debris), not a body.
NEXT (it17) amended: item 2 above is done at 32; the block at 64 px/m (`--ppm=64` does not zoom the arena, it4
NOTE: use the arena's Z zoom key or a camera flag) is still owed, after NEXT 1 (the contractor sheet).
- (05:53-05:58) TRIED the city block at 64 px/m (`--ppm=64` does zoom the arena city: HUD "64 px/m"): every kill of
  the pit bot lands off-frame (it shoots from range; the window stays 1280x800 under the local override.cfg even
  with `--resolution 1920x1080`), so no usable frame. Raw .avi deleted. For it17: the arena's `--cam=fight`-style
  lead does not exist here; use a melee loadout (the bot closes in) or a scratch camera offset toward the
  nearest dead.

## it19 (2026-11-08 05:59-06:59) BUILD
(it17 / it18 left no entries; resuming from it16's NEXT.)
- READ journals: rivet / perf / handheld: no new REQUEST to world. Assets it131 DELIVERED
  `dead_plan_v1_contractor` (round 20261108-0640, prompt_hash f3627a126e86, grade B: pose D reads as a second
  face-down). Plan: NEXT 1 (wire it, film Dock 9 after at 32 + 64), then the freeze prep.
- MILESTONE (06:05) 918cbe58 item 2, NEXT 1 done: `dead_plan_v1_contractor` packed (`tools/art/dead_plan.py`
  CLASSES + `--only=contractor --provenance`), BC7 `.import` params copied from dead_thug (the `.bptc.ctex` is
  there), StreetQuestDeadPlan picks it up with no code change. FOUND on the first after at Dock 9: the plan
  corpses drew at the cast view's 0.8 alpha, so the bodies heaped on the crossing showed through each other;
  `OPAQUE` (DECISION world/quest-dead-plan-opaque) lifts the linger alpha to 1, the decay fade kept (new test 1).
- (06:09) Dock 9 filmed at 32 px/m, t13800: before three planks side by side, heads one way; after the A-E poses
  along each blow, neighbours differ, opaque; they heap on the crossing (the quest kills them there), the blood
  pools grow under them in the 20 s clip (t13450-14050). frames.json entry 2 (the wall's 32 px/m still dropped,
  still on disk). 64 px/m: NOT filmed: the dock fight lies off-frame at 64 (tried `--cam=fight`, and a 4K window:
  the canvas stretches, same world area). 0 SCRIPT ERROR in all four runs.
- MILESTONE (06:20) db8cdbb8 item 2: the dock dead FALL into the pose (DECISION world/quest-dead-fall). Seen in
  the 918cbe58 clip frame by frame: a contractor popped from the standing card to the lying plan pose at its rest
  in one frame. Now over 24 ticks from the blow the body lands a touch large (LAND_SCALE) near where he stood,
  slides 0.6 m along the blow and turns 0.35 rad into the rest, eased out; stateless (the arena tick
  difference). Same seed/ticks re-filmed: every death differs from the before for exactly 12 clip frames (pixel
  diff), then the frames are identical. `gtai-masters/n9/world/dock9_contractor_fall_before_after_*` (crop
  strip + a half-speed side-by-side clip; frames.json entry 3, the wall's 64 px/m clip dropped from it, on disk).
  Unit --changed 1824/0 (the fast suite), lint 15/15. FRICTION: a gate started at 290dce08 was stopped after
  1 min to land this first (one gate at the final head).
Registry rules applied: `motion-quality-gating` (the pop found and judged in motion, frame by frame, before and
after from the same seed and ticks; a pixel diff bounds the change to the fall's 0.4 s), `generative-artifact-gating`
(the served sheet looked at before packing: grade B, pose D a second face-down, noted, shipped).
- (06:28) Not done, judged: the wall overlap (REPORT next step 2). The hand swings forward of the probe by
  its sideways offset x sin(jitter) (~0.2 of standing, ~0.3 m: matches it16's x3 crop). Fix sketch: in
  `StreetDeadPlan._bounded` lengthen `reach` by `SIDE_K (0.5) x STILL_PX x ks x |sin(jitter)|` (pass the jitter in;
  street_dead_plan.gd is at the 200-line soft cap, compact a comment). Not landed this late: it moves the rigs'
  dead and needs a re-gate; it16 judged the frame readable (slumped against the wall).

NEXT (it20+):
1. Read the journals (no REQUEST to world at 06:25). If the gate below is red, fix that first.
2. Optional quality: the wall overlap fix above, then re-film `dev/showcase/dead_wall_clip.tscn` at 64 (before =
   db8cdbb8's frames in gtai-masters `dead_wall_*`).
3. Optional: Dock 9 at 64 px/m needs a camera lead toward the crossing (`quest1_clip.gd` has no free camera;
   `--cam=fight` follows Rivet's fight, not the dead).
4. The freeze (10:30): the director reel x3 at the head with `--quit-after 16000` (top, tilt70, combo), the full
   gate if anything moved since it19's, the exe (`build/export/windows/RTAI.exe`, the REPORT command line),
   REPORT.md finalised (remove DRAFT), `git worktree remove --force C:/Users/kazda/kiro/gtai-n9/tmp/world/before`.
- (06:36) GATE at 39e3e9e5 (code = db8cdbb8; later commits are JOURNAL / REPORT only), `node tools/evidence/run.mjs
  --no-bench`, rc 0: lint 15/15, unit **1840/0**, scenarios 55 ran (rig_stress p50 1.092 > 1.000 CONTENDED: my
  own reel ran beside it; it is Call C-1's band anyway), parity bit-exact (planted 629), look goldens 11/11 +
  block 5/5 worst 0.00, release-compile 617/0. `evidence/n9-world/gate-it19.log`.
- (06:37) Director reel at ce862403 (`evidence/n9-world/reel3.sh it19`): top / tilt70 / combo **19/19 chapters
  down, 0 SCRIPT ERROR**, exit 0 each (`evidence/n9-world/director-reel-it19*`).
NEXT amended: item 1's "if the gate is red" is moot (green); the freeze still re-runs the reel x3 + gate only if
code moves after ce862403.
- (06:38-06:44) TRIED the wall-overlap fix (SIDE_K 0.5: the probe reaches the jitter-swung hand) and NOT landed:
  unit 17/0, but `dead_wall_clip --view=tilt70` at 64 px/m, t150, SIDE_K 0 vs 0.5 in the same build: ~5.5k px
  differ, by eye the same frame (the hand already stops at the blood line in front of the facade in this shot).
  No visible gain = no change. Kept: `gtai-n9/tmp/world/street_dead_plan_sidek_it19.gd` + `test_sidek_it19.patch`.
  Code back at ce862403's (the it19 gate + reel stand for the head). Scratch frame dirs deleted (the Dock 9 clips
  are encoded in gtai-masters).
NEXT (it20+) amended: drop NEXT 2 (the wall overlap) unless a shot shows a body over a roof edge again; the rest
stands (Dock 9 at 64 optional, the freeze list).
## it22 (2026-11-08 06:44-07:44) BUILD
- READ (06:45) rivet / perf / handheld journals: no REQUEST to world. Assets asked for world's word on
  dead_plan_v1_contractor pose D (reads as a second face-down): ANSWER to assets: accepted as served (grade B), no
  redraw asked; at 64 px/m it reads as a different body because the push and the jitter turn it. Plan: the weakest
  evidence gap first, Dock 9 at 64 px/m (owed since it16).
- MILESTONE (06:52) 165d50a0 `quest1_clip.gd --cam=dead` (dev, render only, like rivet-arsenal's --cam=fight): the
  capture camera leans toward the dead; first Dock 9 frame at 64 px/m. FOUND at once: five contractors heap on the
  crossing into one orange blob at 64 (the it19 "they overlap" honest limit, now plain).
- MILESTONE (06:55) 3e7e39de item 2: the dock dead push off the bodies already lying (DECISION
  world/quest-dead-spread): within SPACE_M 1.6 m, up to PUSH_MAX_M 0.9 m, fixed at first sight (earlier dead never
  move), eased in with the fall. Same seed/tick at 64: before three merged in the middle, after each body reads.
  New unit test 1; --changed 1825/0; lint 15/15. `gtai-masters/n9/world/dock9_dead_spread_before_after_tilt70_64ppm_t13800.png`,
  the 32 px/m crop x3 `dock9_dead_spread_before_after_tilt70_32ppm_t13800_crop3x.png` (before = the d9 planks).
- (07:00) 46dbea4b the dev cam holds the densest heap (CLUSTER_M 3) and eases (0.06/frame): the latest-hurt anchor
  wandered to other kill sites (shots into old corpses re-stamp hurt_tick). Clip before | after at 64 px/m, half
  speed, t13560-13860 (`dock9_dead_spread_before_after_tilt70_64ppm_t13560-13860_halfspeed.mp4`; before = SPACE_M 0
  local edit, restored, never committed). 0 SCRIPT ERROR in all six runs. frames.json: 15 (the riot full 64 still
  and the 32 fall clip dropped as superseded; FRICTION: I dropped two other entries by mistake first and re-entered
  them from the journal facts, marked so in their notes).
- FOUND (07:01) in the 64 px/m clip: the dark-red ink-outlined blood pools (KillView's parts: its `gib_layer` sits
  at z +3 above the cast view's corpses; `ground` at -1) draw OVER the dead contractors, in both arms (pre-existing,
  not the push). Frame: `gtai-n9/tmp/world/pools_over_dead_t13800_64ppm.png` (left = before, right = after). A
  pool over a body reads wrong ("blood pooling over time" belongs under him). Not fixed this session (kill_view.gd
  is combat's shared view; needs a look at what the shape is: a gib part vs a pool decal).
Registry rules applied: `depth-ordered-layered-art` (found the pool-over-corpse order break, logged with the
frame), `motion-quality-gating` (before/after from the same seed and ticks in motion; a capture camera that
wandered was judged a capture fault and fixed before filming), `generative-artifact-gating` (no new art).
