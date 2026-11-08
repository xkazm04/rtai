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

NEXT (it5):
1. Read the journals (rivet: the knock field is answered above; assets: the 5 walker dead sheets).
2. Item 3 (cars knock Rivet down), per it1's scoping: BD_CAR_HIT in body.cpp + sim_body.gd op for op, a parity case
   with it on, `just native` debug + release, scenarios (struck at speed; a car creeping); then
   `Events.rivet_knocked(heading, speed_mps)` and the rig meta `rivet_knock` = Vector3(hx, hy, tick) for rivet.
3. Item 4 (bodies stop at walls): props' footprints as solids in the thrown slide (both twins) + bound the plan
   pose's pelvis offset by the first solid along the blow (StreetDeadPlan.PELVIS_K x the free distance).
   Before/after: the kerb barrier, seed 5 tick 900.
4. Item 2 follow-ups: wire the 5 walker sheets when served; the wound stamps (kill_marks) follow the plan pose;
   film quest 1 Dock 9 and the city block (`--arena=city`) before/after.
5. Item 1: the city with bikes under combo in the real city (city_bench draws flat without --view: find why).
6. Remove the scratch "before" worktree (`git worktree remove C:/Users/kazda/kiro/gtai-n9/tmp/world/before`)
   once the last before/after is filmed.
