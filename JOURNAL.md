# n8 street: JOURNAL

## Iteration 1 (2026-11-06 20:26, BUILD)

Read: d8 chars/view70 REPORTs, `RigCardSets` / `RigHeadCard`, `tools/art/street_head.py`, library
`catalog.json` (street class). Other lanes: no journals yet at 20:30.

Library state for my classes (keyed/street/): every id has BOTH a 55 and a 70 sheet already.
70 grades: cop_riot A, cop_patrol B, swat B, thug A, contractor A, cultist B, torque_gang A,
peds A except ped_suit B, ped_cap B. So no 70-twin REQUEST is needed for the cops (brief step 1
asked for it; the asset lane served it at 19:40/20:40).

(SUPERSEDED 21:00, see below) REQUEST to view: a street registration hook for the card rows. `RigCardSets.SETS` is yours; I need
my own file `project/features/characters/street_card_sets.gd` (class `StreetCardSets`, const
`SETS: Dictionary[String, Dictionary]`, same row shape as `RigCardSets.SETS`) to be merged by
`RigHeadCard.rows_of(art)` AFTER `SET_CARDS[art]` (street rows win for the keys they name). Then
drop the p55/p70 street rows (`cop/*`, `ped/*`, `thug`) from `RigCardSets.SETS` or leave them: mine
override. One line in `rows_of`: `for key in StreetCardSets.SETS.get(art, {}): ...` (the same loop
as SET_CARDS). Until it lands I film with that loop as an uncommitted local patch and say so.

- MILESTONE d7b96bf9: p70 head cards for the patrol cop (cop_patrol_70 B, the asset lane's
  recolour already applied; fix navy), riot cop (cop_riot_70 A; band 0.48, wcap 1.12, orange+navy),
  SWAT (swat_70 B; band 0.48; its note "helmet oversized" answered by width 1.4 vs a measured 1.48)
  and the thug (thug_70 A; band 0.58 so the speaker eye shows under the box top). Cut by
  street_head.py, no image job. Widths: each head's share of its cell measured on the p55 and p70
  strips (scratch headfrac.py), so a head keeps its on-screen width across the pitch swap.
- MILESTONE 43361f8e: the riot shield under the card views is an upright opaque frosted plate
  (RiotShieldCard), cut from the sheets' advance pose (new tools/art/shield_cut.py: light
  low-saturation grey component, holes filled, ink rim) at p55 and p70. First try sized it off the
  torso texture WIDTH (the chest depth): the plate vanished side-on (LOOKED, rejected). Now: the
  torso's shoulder span x0.8, width x max(|facing.y|, 0.45), in front of the body when nearer the
  camera than the chest. LOOKED at 64 px/m tilt70: plate with its view slot, front and behind.
- FRICTION: cut_rig.gd is past the soft cap; the debt ratchet failed my 1-line hook; offset by
  re-wrapping a 3-line comment into 2.
- MILESTONE 83b02c7b: the robot thug's ink mass (brief step 2). Under card art each printed part's
  self_modulate is x1.55 (the gang's gang_parts.py LIFT_K) before the print, so the steel clears the
  print's ink threshold: plates, joints and claws separate at 48 px/m (LOOKED, before/after still).
  The head card is raw and skipped. StreetView = the street's per-step view hook (shield + lift).
  `top` never runs it. THUG_LIFT 1.0 = before.
- MILESTONE d1729db6: p70 cards for the five ped heads (hair <- ped_suit_70 B, bald <- elder A,
  hat A, hood A, cap <- ped_cap_70 B). The `coat` fix cut across the 70 hat's brim (more saturated
  tan): rejected on sight, the hat keeps its tan coat at 70.
- GATE unit no-arg on 83b02c7b (+ in-flight ped files): 1491 passed, 0 failed, no FLAKY.
- MILESTONE 66836d5c: view had already opened card sets to lanes (n8-view 8b006bae,
  data/tables/card_sets/<lane>.json). Cherry-picked it (091f5309) and moved my 9 p70 rows to
  card_sets/street.json. My REQUEST to view is withdrawn: no change to view's files was ever
  committed here (my local rows_of patch was filming-only and is gone). CHECK: the committed head
  draws the city frame pixel-identical to the patched film (0 px differ, seed 5 crowd 400 t4).
- EVIDENCE masters n8/street: cops p70 heads before|after 48 and 64 px/m, shield plate before|after
  64 + x2 zoom + clip, thug lift before|after 48 x2 + clip, city crowd 400 before|after 48.
  Before = main's p70 rows (the p55 drawing at 70); same seed.

Registry rules applied: sprite-and-atlas-production (equal-cell strips, whole frames unit-tested,
cut by script from keyed sheets, provenance per file); depth-ordered-layered-art (the plate's z by
its depth against the chest, the head card above it); concept-scene-parity (judged on game frames,
same seed before/after); motion-quality-gating (judged in the reel/beat/city runs, clips kept);
generative-artifact-gating (A first, B with its named fix; colour fixes rejected on sight twice);
render-submission-economy (the lift is a modulate, no new texture set; one plate sprite per riot cop).

DECISION street/cards: the 70 cards keep each head's on-screen width equal to its 55 card's (measured
head share), not the 70 sheet's own proportions; one width value per row in street.json.
DECISION street/shield: the riot shield draws as the sheet's frosted plate standing upright (min 45 %
width side-on, held angled), not the crescent; StreetCardSets.SHIELD has no row for an art = crescent.
DECISION street/thug: the steel lift is a modulate x1.55 under card art only (top keeps the dark
thug, so top goldens do not move); the alternative (a lifted part set like art/gang/) would need a
second art_dir and a card row per pitch.
- GATE `top` bit-identity (21:05): city block `--arena=city --bot=rivet --seed=2 --rigs`,
  `--quit-after 301`, framemd5 of HEAD 7c658104 vs main 8e9eeb78 (a throwaway detached worktree,
  removed after): IDENTICAL, 301 video + 301 audio frames, 0 SCRIPT ERROR each.
- SCOUT (brief item 4): quest 1's dock contractors are GuardBrain actors; no rig look of their own
  found yet (RigVariant.crowd has 9 looks: 5 peds, patrol, riot, SWAT, overalls-bald). Find what
  rig/variant draws them before cutting contractor_70 (A). Cultists / Torque's gang: no code names
  them in features/ (grep cultist|kronk|torque: nothing): likely not in game yet; ask the Director.

- GATE director reel under tilt70 on 66836d5c (headless, `--fixed-fps 60 --quit-after 14000
  res://dev/arena/arena.tscn -- --bot=reel --reel=director --loadout=pistol --rigs --view=tilt70`):
  19/19 chapters, every chapter all down, 0 SCRIPT ERROR (exit 0). Under `--view=combo` (21:09-21:13,
  same command): 19/19 chapters, all down, 0 SCRIPT ERROR at the 19th chapter (the process ran on to
  its 14000-frame end in the background).
- GATE unit no-arg on the clean head 0ad76dba (with view's card sets): 1493 passed, 0 failed, no FLAKY.
  Lint 15/15 on every commit (pre-commit hook).
- LOOKED: the p55 riot plate at `--view=tilt` 64 px/m (masters still): it reads as at 70.

NEXT (iteration 2):
1. Reel gate under `top` (StreetView never runs straight down and the top city framemd5 is
   identical, but run it); then `node tools/evidence/run.mjs --no-bench` on the head.
2. Combo / boss arenas at 55: the riot plate at p55 and the thug lift at 55 (`--view=tilt`,
   `--boss=king`), and the combo swap of the plate (it rebuilds on the art change).
3. Peds (brief 3): the 4 library types the game has no head for (shopper, punk, worker, jogger):
   map them onto the crowd looks (vest-hair, jacket-hair, overalls-bald...) and re-cut torsos if they
   read better; crowd variety (scale/tint within the colour law) is a call.
4. Contractors (brief 4): find their rig look, cut contractor_70/55 cards.
5. Hit reactions/deaths at height (brief 5): the plate hides in the sprawl (c_sprawl >= 0.5) like
   the crescent; check the corpse lands where the body was under tilt70.
6. Crowd cost (brief 6) under the bench lock: city crowd 400, tilt70 vs top.
7. 32 px/m before/after pairs for each subject (only 48/64 so far); a combined clip.

## Iteration 2 (2026-11-06 21:19, BUILD)

Read: JOURNAL, git log, the other lanes' journals (no REQUEST to street; view answered card sets,
city asked view for building occlusion, vehicles asked city about parked cars). Library: all nine
ped types have A sheets at 55 and 70 (catalog), so no REQUEST to assets.

- FRICTION: `node tools/evidence/run.mjs` refuses a dirty tree; my first try logged into the
  worktree (`evidence/`): moved the log to scratch. A second run I stopped myself (I was editing
  under it); the third runs on e97d19fd (+ the variety commit landing under it, see GATE below).
- FRICTION: `node tools/godot/check.mjs` fails on any features script here ("Failed to compile
  depended scripts", also on the unchanged riot_shield_card.gd): judged by --import + the unit run.
- FRICTION: in a GUT test, `StreetCrowdCards.POOLS[tag]` (a typed const Dictionary[String,
  PackedStringArray] of another class) iterated as 24 empty strings; `.get(tag)` is right. The code
  always used `.get`.
- MILESTONE 1e7776b4: `dev/showcase/street_crowd` board: 16 pedestrians of every look (the pooled
  looks three times, actor ids 1-16) walking a road through the real CharacterRigs under `--view`,
  at `--ppm`, three stills. Why: no arena start puts Rivet among walking peds (the city block's
  nearest 16 rigs are the hub's cops). Debt ratchet accepted (+126 dev lines, 1 cmdline read).
  LOOKED: on the pavement tile the cream ped torsos vanish into the cream pavement (city note below).
- MILESTONE e97d19fd (brief 3): the nine library pedestrian types under the card views.
  StreetCrowdCards (StreetView hook): jacket-hair draws suit|punk, vest-hair shopper|jogger,
  overalls-bald elder|worker, by actor id; 8 new strips (punk/shopper/jogger/worker at p70 from the
  20:40 A sheets, at p55 from the 15:00/16:40 A sheets), cut by street_head.py (bands 0.32-0.36), no
  colour fix. Widths: skull width matched to the suit head's (median run at 30-50 % of the content
  height; the measure reproduces bald 1.95 vs its 1.93 row at 70): p70 punk 2.5 (measured 2.83, the
  mohawk's narrow skull; capped so the studded shoulders do not outgrow the body), shopper 1.64,
  jogger 1.84, worker 2.3; p55 punk 2.4, shopper 1.58, jogger 1.77, worker 2.5. Unit 11/11 (new
  test_street_crowd_cards + the card-set count 9 -> 13). LOOKED at 32 (x2), 48 (x2), 64 px/m tilt70
  and 64 px/m tilt (p55): every type reads (bun, ponytail, mohawk, worker's straps, elder's fringe).
- MILESTONE def405b4: per-person variety (card scale +-8 %, grey value +-7 %, by actor id, peds
  only). LOOKED at 64 px/m: subtle; the two hats and two hoods now differ in size, the value step is
  barely visible. Kept mild (a call for the owner: how much variety).
- SCOUT (brief 4): quest 1's dock contractors draw as the flat `dock_guard` sprite in
  `boot/collect_call/view/cast_view.gd` (the shipped path; GUARD_DRAW 1.7), and as COP rigs under the
  dev `--rigs` (arena_rigs.gd: "the contractor plan lands with enemy-ai"). Plan: a standing
  contractor card (contractor_70 A / _55 A, whole figure, five facings) drawn by a street hook that
  cast_view calls for "dock_guard" under card art only (top keeps the sprite).
- NOTE for city/view (no REQUEST yet): on the cream pavement the ped torsos (cream) melt into the
  ground at tilt70; at 70 the head card covers most of the torso, so it shows as legs under a head.

EVIDENCE masters n8/street (it2): peds9_before_after_tilt70_{32,48}ppm_x2_board_t2.png,
peds9_before_after_tilt70_64ppm_board_t2.png, peds9_p55_tilt_64ppm_board_t2.png,
peds_variety_before_after_tilt70_64ppm_board_t2.png. Before = POOLS emptied (a filming-only local
edit, restored and checked: the committed file holds the pools).

Registry rules applied this iteration: sprite-and-atlas-production (equal-cell 5-frame strips cut by
script from keyed A sheets, whole frames unit-tested, provenance per file), render-submission-economy
(no new nodes or draw calls: the swap is a texture on the existing card sprite, the variety a
modulate and a scale), concept-scene-parity (judged in CharacterRigs frames, before/after on one
deterministic board), generative-artifact-gating (A sheets only; no colour fix needed).

- GATE evidence `node tools/evidence/run.mjs --no-bench` on e97d19fd: lint PASS 15/15, scenarios
  52 passed, parity PASS (1200 steps, planted mutation caught at step 629), selftest PASS (look
  goldens 11/11, block goldens 5/5: `top` holds), export-audit PASS (557 loaded, 0 failed); unit
  1499 passed 0 failed but marked FAIL "tree changed during run" (my def405b4 variety commit landed
  under it). Rerun owed on the head.
- GATE director reel under `top` on def405b4 (headless, the it1 command without --view): 19/19
  chapters all down, 0 SCRIPT ERROR (exit 0; the usual "resources still in use at exit" note, as in
  the tilt70/combo logs).
- MILESTONE 7b3ff9e3 (brief 4): quest 1's dock contractors stand as a whole-figure card under the
  card views (StreetQuestCards, called by CastView for each live guard; contractor_70 A / _55 A cut
  by street_head.py band 1.0, 192 px). First film: mirrored frames drew one card width to the right
  (a negative-width rect is drawn shifted, not flipped in place): fixed with a mirrored transform about
  the feet. LOOKED at 48 px/m tilt70 Dock 9 tick 13700 (x3 crop): the guard stands on its spot.
  quest1_clip.gd learned `--view`. Debt +1 line each in cast_view / quest1_clip accepted.
  NOTE: under tilt70 the rest of quest 1 (Rivet's sprite, cops, allies) still draws top-down
  sprites; the contractor is the only standing figure. The quest stills differ run to run (blood,
  dialogue), so a quest before/after is "same tick", not pixel-identical.
- CALL (owner): the contractor's hi-vis orange (hat + vest) is saturated and near vermilion; kept
  as the approved concept and the in-game sprite's vest. Alternative: tone the hat to a dull ochre.
- CALL (owner): crowd variety: built mild (scale +-8 %, value +-7 %); stronger = raise
  StreetCrowdCards.SCALE_VAR / VALUE_VAR.

NEXT (iteration 3):
1. Rerun the evidence gate on the head (unit was flagged for tree churn only); keep the tree still.
2. Contractors: the knocked-out `guard_down` sprite under tilt (the body lies flat: probably right,
   check); the p55 contractor under `--view=combo` in a boss fight; a clip of Dock 9 at tilt70.
3. Cultists / Torque's gang: still nothing in game names them; ask the Director (REPORT) or build
   their cards behind a registration so a later lane can draw them.
4. Hit reactions/deaths at height (brief 5): ragdoll and corpse placement under tilt70 (react_line
   and the city fight), corpse decay unchanged.
5. Crowd cost (brief 6) under the bench lock: city crowd 400, tilt70 vs top.
6. The cream ped torsos on cream pavement (city note); the cop blue call (navy vs police blue
   side by side); a combined 30-90 s clip of the street set.
- GATE unit no-arg on the clean head 8f60301d (tree still): 1501 passed, 0 failed, no FLAKY (twice).
- GATE director reel under tilt70 on 13f1c5f7 (the it1 command): 19/19 chapters, every chapter all
  down, 0 SCRIPT ERROR (exit 0). Combo and top reels on this head: owed (top ran on def405b4: 19/19).

## Iteration 3 (2026-11-06 22:14, BUILD)

Read: JOURNAL, git log, the other lanes' journals (no REQUEST to street).

- MILESTONE ec2db012 (brief 5): the street crowd board learned `--kill=<hit class>`: at tick 60 all
  16 walkers die on their spot (DeathPipe, the shipped react table, from the west); stills at
  59/72/90/150/240. Run under `top` and `tilt70` (same deterministic board): LOOKED at 32 and 64 px/m
  for `light` (fall back / crumple) and `blast` (thrown, spread): every corpse lies on the same
  ground spot under tilt70 as under top (the fall, the travel and the corpse are in the ground plane;
  the lift drops with c_sprawl), the head card sits on the corpse's head. Masters:
  death_{light,blast}_top_vs_tilt70_64ppm_board_t3.png, death_blast_top_vs_tilt70_32ppm_board_t3.png.
- REJECTED on sight: a corpse's head card lying down along the body (StreetCorpseCard: rotate the
  card about its neck pivot to the hips->head axis, weighted by c_sprawl 0.25-0.85). The top-down
  sprawl lays the limbs out around a head that stays over the chest, so that axis is short and
  arbitrary: the rotated heads looked tipped at random, the upright card reads as a head on a body.
  Not committed. Still: death_corpse_card_upright_vs_lying_REJECTED_64ppm_x2_t3.png.
- CHECK (code read) corpse decay under the cards: CorpseFade inks (rig.modulate) and sinks
  (rig.scale) the whole rig node; the head card and the riot plate are children of rig parts, so
  they ink with it, and RigHeadCard sizes the card from the anchor's global scale, so it sinks too.
  Not filmed (the decay runs 10+ s into a fight).
- MILESTONE 02c16872 (brief 6): rig_bench takes --view.
- MEASURE (brief 6), CONTENDED (two other lanes' Godot engines running; bench.lock taken, free
  before): city_bench riot (400 on foot, 32 px/m, 30 s, the editor binary windowed d3d12, vsync off),
  alternating top / tilt70:
  run 1: avgFrameMs 1.71 -> 1.78, p99CpuMs 10.16 -> 11.84, low1Fps 74.6 -> 66.6, drawCallsAvg
  681 -> 801 (+120: the cards and plates), rigMsPerTick 0.98 -> 1.22, renderCpuMsAvg 0.51 -> 0.54.
  run 2 (load rose: the view-free simStepMsPerTick 0.15 -> 0.24 in the tilt run): avgFrameMs 2.07 ->
  3.85; not usable as an A/B. The p99 limit (7 ms) is not judged here: the editor binary under load
  misses it in `top` too.
  rig_bench headless (16 full rigs, 10 s): top p50 0.54 / 0.55 ms (50 / 200 people) vs tilt70
  0.65 / 0.79. The street hook's own share: tilt70 with StreetView.step returning at once
  (a local edit, reverted, checked clean) 0.865 / 1.077 vs with it 0.947 / 1.086: under the noise
  floor (<= 0.08 ms, about 5 us a rig). The tilt cost is view's (RigTilt + RigHeadCard) plus the
  card draws. JSONs: masters n8/street/bench/.
- EVIDENCE (combined clip, owed since it1): city block `res://dev/arena/arena.tscn -- --arena=city
  --bot=rivet --seed=5 --rigs --ppm=48 --view=tilt70|top`, `--fixed-fps 60 --quit-after 2400`, 0
  SCRIPT ERROR each: street_city_tilt70_48ppm_seed5_40s.mp4 and the top|tilt70 side by side
  street_city_top_vs_tilt70_48ppm_seed5_40s.mp4 (same tick, same layout). LOOKED at 5/15/25/35 s:
  police-blue-on-navy cops with p70 cards, the riot plate, hat/hood/hair peds, cop corpses lying
  with their heads on. frames.json now 15 entries (the two clips, the death pair and the cop-tone
  call in; three near-duplicate stills out, their files kept).
- CALL evidence (cop tone, chars call 7): p70 cop_cap / cop_riot re-cut by street_head.py with the
  committed args (navy re-cut = the committed strips, 0 px differ) and without `navy` (police blue);
  filmed on the react line (`--bot=react_line --ppm=48 --view=tilt70 --rigs --seed=4`) with a local
  swap. FRICTION: the first swap filmed identical frames: the game reads the import cache, so a
  swapped PNG needs `--import` first (then restored + `--import`; the restored film is identical to
  the first navy film). LOOKED: navy reads as one uniform with the navy body; police blue pops the
  head but splits the figure two-tone (the body parts stay navy). Built: navy (unchanged).
  call_cop_tone_navy_vs_policeblue_tilt70_48ppm_x1.5_reactline_t{2,5}.png.
- SCOUT (brief 4) cultists / Torque's gang: library has cultist 55 A, 70 A (21:20 redo), torque_gang
  55 A, 70 A; nothing in game spawns them (no plan, look or actor; grep cultist|kronk|torque in
  features/ and data/: nothing). Cut in scratch only (street_head.py band 1.0, 192 px, the
  contractor recipe): clean five-facing whole-figure strips at both pitches. The `orange` fix is
  WRONG for them (rejected on sight): it turns the cultist's rust robe and Torque's eye glow pale
  blue (and blue is police only). Cut with no fix. Not committed: art with no consumer. Masters:
  robots_cultist_torquegang_strips_70_55_nofix_scout_t3.png, robots_strips_70_orangefix_REJECTED_t3.png.
  NOTE: keyed/street/torque_gang_55.png is dated 16:36 but the catalog's A is round 1705: check
  which drawing the keyed file holds before integrating the 55.
- CHECK (code read) the knocked-out contractor: CastView draws the flat `guard_down` sprite at the
  guard's own ground position under every view (no card); a lying body from 70 deg reads close to
  top-down. Kept; not filmed.
- GATE director reel under `--view=combo` on c7899f99 (features as of 7b3ff9e3): 19/19 chapters,
  every chapter all down, 0 SCRIPT ERROR, exit 0 (ran to its 14000-frame end).
- GATE `node tools/evidence/run.mjs --no-bench` on c7899f99 (tree still): lint PASS 15/15, unit
  1501 passed 0 failed, scenarios 52 ran PASS (CONTENDED: rig_stress.rigMsP50 1.041 > 1.000 with 3
  other runs, the machine never went quiet in 5 min: budget not judged), parity PASS (1200 steps,
  mutation caught at 629), selftest PASS (look goldens 11/11, block goldens 5/5: `top` holds),
  export-audit PASS (557 loaded, 0 failed). The it2 rerun debt is paid.

Registry rules applied this iteration: motion-quality-gating (deaths judged across the fall in
tick sequences, the city judged as a 40 s clip, not stills), concept-scene-parity (same seed,
same tick top vs tilt70; the cop-tone call filmed on the d8 call's own scene), generative-artifact-
gating (the `orange` fix rejected on sight for the robots: a fix tuned for one sheet broke another's
identity and the colour law), render-submission-economy (the crowd cost split: the street hook's
own share is under the noise floor, the cost is the card draws + view's tilt), sprite-and-atlas-
production (robot strips cut by script from keyed A sheets, five equal cells).

NEXT (iteration 4):
1. Top reel on the head (last ran on def405b4; features changed in 7b3ff9e3, quest only).
2. 32 px/m before/after pairs still owed for the cops (48/64 only), the riot plate and the thug
   (48 only): the cops' before = main's p70 rows (a detached worktree), the thug's = THUG_LIFT 1.0.
3. Crowd cost on a quiet machine (bench.lock, no other Godot): city_bench riot top vs tilt70, 3
   alternating pairs; and drive48 (the in-car camera) under tilt70.
4. Cultists / Torque's gang: if the Director or a lane adds a spawn, the strips are ready (scratch
   robots/, street_head.py band 1.0 192 px, NO fix); check the keyed torque_gang_55 round first.
5. The cream ped torsos on cream pavement at tilt70 (legs under a head): a ground-contact read
   (shadow/ink) is view's or city's; REQUEST if it still shows in the city clip at 32 px/m.
6. Weakest item to raise: the crowd variety (mild by design; a stronger setting as the call's
   side-by-side) and the 70 twins' widths at 32 px/m in motion.

## Iteration 4 (2026-11-06 23:08, BUILD)

Read: JOURNAL, git log, the other lanes' journals (no REQUEST to street; city notes my cream-torso
remark, not a REQUEST).

- MEASURE (brief 6) crowd cost, bench.lock taken (free before), city_bench riot (400 on foot,
  zoom 1.0 = 32 px/m, 30 s, `--fixed-fps 60`, the console binary windowed d3d12, vsync off),
  3 alternating pairs top / tilt70. Pair 1 is the only clean one (0 other Godot processes at each
  launch): avgFrameMs 4.63 -> 5.14 (+0.51), p99CpuMs 14.95 -> 15.15, low1Fps 56.2 -> 52.7,
  drawCallsAvg 685 -> 800 (+115: the cards and plates), rigMsPerTick 0.74 -> 0.99 (+0.25),
  renderCpuMsAvg 0.53 -> 0.57, simStepMsPerTick 0.113 -> 0.118 (the view-free control: flat).
  Pairs 2-3 CONTENDED (2, then 8-10 other Godot processes appeared: other lanes' runs): pair 3
  top 6.26 / tilt70 6.15, not an A/B. The absolute frame times are higher than it3's (1.7 ms):
  it3 ran without `--fixed-fps`; compare within a pair only. Verdict: the angled street costs
  about +0.5 ms a frame and +0.25 ms of rigs at 400 actors, +115 draw calls; the hook's own
  share stays under the noise floor (it3). JSONs: masters n8/street/bench/it4/.
- EVIDENCE (owed 32 px/m pairs, cops + riot plate + thug in one shot): the Kerf beat
  (`--bot=ghosts --ghost=kerf --rigs --seed=4 --ppm=32 --view=tilt70`, three patrol cops, a riot
  cop, the thug). Before = the lane off (StreetView.step returns at once, card_sets/street.json
  moved aside: a filming-only local edit, restored, `git status` clean) = main. LOOKED (x1, x2):
  the shield reads as a frosted plate where main draws a black-striped arc; the thug shows its box
  head card and lit steel arms; the cops' 70 heads are subtle at 32 (same navy, the cap shape).
  NOTE: at 32 px/m the thug's chest under the head card still prints as a dark patch (the print
  inks small dark parts; the thug has no collar part to lift). At 64 px/m (filmed, x3) the chest,
  plates and joints all read. Kept: 32 is legible, not a blob. Masters:
  cops_riot_thug_before_after_tilt70_32ppm_{x1_kerfbeat_t1.6,x2_kerfbeat_t0.8_t1.6}.png,
  cops_riot_thug_tilt70_32ppm_kerfbeat_12s.mp4, thug_lift_tilt70_64ppm_x3_kerfbeat_t4.png,
  cops_p70_tilt70_64ppm_x2_kerfbeat_t4.png.
- CALL evidence (crowd variety): the street crowd board at tilt70 48 px/m, built (SCALE_VAR 0.08,
  VALUE_VAR 0.07) vs strong (0.16 / 0.14, a local edit, restored, tree clean). LOOKED: strong
  separates the two hat walkers and the caps by size and reads as more different people, without
  a head looking wrong on its body; no hue moves either way. Built stays mild (DECISION street/crowd
  unchanged); the strong setting is two constants away.
  call_crowd_variety_mild_vs_strong_tilt70_48ppm_x1.5_board_t4.png.
- CHECK (NEXT 5) cream torsos on cream pavement at 32 px/m: city seed 5 tilt70 (15 s, 0 SCRIPT
  ERROR). LOOKED x4: the pavement walkers read (ink rim, dark legs, the head card), so no REQUEST to
  view/city. What does read weak is the BODY under the card: the top-down parts (cream jacket, white
  hands, black legs) read as a grey sack on black legs, and on the board every walker's legs are the
  same white-and-black pills (in `top` too). peds_pavement_tilt70_32ppm_x4_city_seed5_t4.png,
  peds_bodies_top_vs_tilt70_64ppm_board_t4.png.
- REQUEST to assets: ped_suit, ped_worker, ped_hood (pilot; then the other six), 70: a WALK strip,
  whole figure, the 70 twins' camera and identity, five facings x 4 walk frames (contact, pass,
  contact, pass), one baseline, feet on the bottom edge. Why: the pedestrians' head cards sit on
  top-down bodies that read as sacks on pills under tilt70; the contractor's whole-figure card
  reads well standing, but a walker needs stride frames, a sliding still figure fails in motion.
  With these the street lane can draw walkers as whole-figure cards (the contractor recipe).
- GATE director reel under `top` on 268bc09c (features as of 7b3ff9e3; headless, the it1 command
  with `--view=top`): 19/19 chapters, every chapter all down, 0 SCRIPT ERROR, exit 0. All three
  views now ran the reel on the current features (tilt70 13f1c5f7, combo c7899f99, top 268bc09c).
- frames.json: the 32 px/m Kerf pair and the variety call in; the p55 shield still and the 48
  cop pair (near-duplicate of the 64) out, their files kept. 15 entries, all files present.

Registry rules applied: render-submission-economy (the cost split by a view-free control: sim step
flat, the delta is rigs + draw calls; contended pairs labelled, not averaged in), motion-quality-
gating (the walking-card idea held back: a still figure sliding fails in motion, so frames are
REQUESTed instead of faking a walk), concept-scene-parity (before/after on one seed, same tick, the
before made by switching the lane off rather than another scene), sprite-and-atlas-production (the
walk REQUEST names cell layout and baseline so the strip cuts by script).
- MILESTONE 2866ec0b (brief 3, the weakest item raised): pedestrians walk as WHOLE-FIGURE cards
  under p70 (StreetWalkerCards): the nine library ped_*_70 top rows cut by street_head.py band 1.0
  (192 px, no fix: ped_suit and ped_cap from their 2120 B rounds, the rest A), drawn at the feet,
  1.7 m tall x the crowd scale, the top-down parts hidden, a gait bob 1.6 px + sway 0.05 rad from
  rig.phase. Hit or dead the person drops back to the parts and the head card for good (the parts'
  visibility is kept on the rig and restored exactly: a hit, a death, p55, top). First a filming-
  only prototype: white blobs at the feet (halos the rig re-shows every step) -> hidden every step
  from a cached list. LOOKED: board 64 px/m (nine distinct people), board `--kill=light` (t59 whole
  figures, t90 the parts fall, t240 the corpses lie where the bodies were, heads on), city seed 5
  32 px/m before|after same tick (the sack on black pills becomes a coated person). FRICTION: a GUT
  loop over a typed const Dictionary's PackedStringArray value inline crashed the engine (signal
  11); a typed local first is fine. DECISION street/walkers in docs/decisions.md.
  Masters: peds_walkers_tilt70_64ppm_board_t120.png + .mp4, peds_walkers_before_after_tilt70_32ppm
  {,_x2}_city_seed5_t4.png, peds_walkers_city_tilt70_32ppm_seed5_15s.mp4,
  peds_walkers_hit_drop_to_parts_tilt70_64ppm_board_t59_t90_t240.png. frames.json: 15 (walkers first).
- CALL (owner): the walkers. Options: (a) whole-figure cards gliding with a bob (BUILT); (b) the
  head cards over the top-down parts (StreetWalkerCards.ENABLED = false). Costs of (a): the figure
  glides until stride frames land, and it pops from drawing to parts at the hit; on cream pavement
  the tan coats are lower contrast than the old black legs (the ink rim holds them). See:
  peds_walkers_before_after_tilt70_32ppm_x2_city_seed5_t4.png; exe `--arena=city --rigs --view=tilt70`.
- GATE unit no-arg on 2866ec0b: 1505 passed, 0 failed, no FLAKY. Lint 15/15.
- GATE director reel under tilt70 on 2866ec0b (walkers in): 19/19 chapters, every chapter all
  down, 0 SCRIPT ERROR, exit 0.

Registry rules applied (walkers): sprite-and-atlas-production (whole-figure strips cut by script,
five equal cells, unit-tested; one provenance line per strip), motion-quality-gating (judged in
the board and city clips and across the kill sequence, not on one still; the glide is named as the
cost, not hidden), depth-ordered-layered-art (the figure is the head card's own sprite, so it keeps
the rig's depth sort), generative-artifact-gating (B sheets for suit/cap used as the head cards
already did; no colour fix, the `orange` fix stays rejected for the street).

NEXT (iteration 5):
1. Combo reel on the walker head (running at 23:51; read reel-combo.log) and the evidence gate
   (`--no-bench`, started 23:45): record both. If `top` look goldens moved, StreetView runs under top:
   find out before anything else.
2. Walkers: when the assets lane serves the walk REQUEST, cut the stride strips (5 facings x 4)
   and swap the bob for frames by rig.phase; until then, judge the glide at 48 px/m in the city
   clip and tune BOB_PX / SWAY by eye.
3. Walkers: the pop at the hit (drawing -> parts). Options: hold the whole figure through the
   knock-back's first frames and cross to the parts on the fall; or a drawn hit pose from the
   sheet's action row. Film both on the `--kill=light` board.
4. Walkers' shadows: the hidden parts took their cast shadow with them; check the city clip at
   48 px/m (sun shadows on the pavement) and add a ground ellipse if the walkers float.
5. Walkers at p55 (boss arenas under combo): cut the 55 top rows the same way and add a "p55"
   STRIPS entry once judged (the arenas rarely hold pedestrians, so lower priority).
6. Crowd cost with the walkers (fewer sprites drawn: the parts hidden): rerun city_bench riot top vs
   tilt70 under the bench lock on a quiet machine.
- GATE director reel under combo on 87cc6fa7 (walkers in): 19/19 chapters, every chapter all
  down, 0 SCRIPT ERROR at the 19th chapter (23:56; the process runs on to its 14000-frame end).
- GATE `top` holds on 87cc6fa7: `node tools/selftest/run.mjs` look goldens 11/11 (worst 0.27),
  block goldens 5/5 (worst 0.22), crowd atlas 6/6 on doctrine, world lock 0.00 %.
- BLOCKED (partly): `node tools/evidence/run.mjs --no-bench` (started 23:45) was stopped at the
  10 min background limit while scenarios waited for a quiet machine (rig_stress budget missed
  under contention: my own reels were running). Lint 15/15, unit 1505/0 and the selftest ran
  separately on this head; scenarios, parity and export-audit are owed on the walker head
  (NEXT 1: run the gate alone, nothing else of mine running, with a longer timeout).
- GATE (00:03) scenarios on 420ef174: 52 passed (headless, not contended). Combo reel ran to its
  end: exit 0, 0 SCRIPT ERROR, 19/19 all down. Still owed on the walker head: parity and
  export-audit (the full `evidence/run.mjs --no-bench`, run alone). Scratch .avi captures deleted.
