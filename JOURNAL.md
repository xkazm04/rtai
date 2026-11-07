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

## Iteration 5 (2026-11-07 00:05, BUILD)

Read: JOURNAL, git log, the four lane journals (no REQUEST to street), the assets JOURNAL: the walk
REQUEST is served for the pilot (ped_suit_walk_70_v2 A, ped_worker_walk_70_v2 B, ped_hood_walk_70 B;
rows 4-5 repeat frame 1 in worker/hood, row 5 mirrored in post by assets).
- GATE (owed from it4) on a21730cb (the walker head): parity native == GDScript 1200 steps, planted
  mutation caught at step 629, exit 0; release_compile 558 loaded, 0 failed. With it4's lint 15/15,
  unit 1505/0, scenarios 52/52, selftest goldens 11/11: the evidence gate's parts are all green on
  the walker head (run piecewise, not as one evidence/run.mjs: the machine was never quiet).
- MILESTONE afe22e3b (NEXT 2): suit, hood and worker walkers draw the library's stride frames under
  p70. tools/art/street_walk.py cuts a keyed 5 x 4 walk sheet into a game grid (5 facings across in
  RigHeadCard's order, 4 frames down), each figure at its drawn foot line and drift so the head
  stays steady (LOOKED at the cut: heads level across the four frames). StreetWalkerCards.WALKS
  picks the grid over the still strip; frame = floor(phase x 4) (one gait cycle = two steps: about
  15 ticks a frame at walking speed, 2 steps/s), the pass frame when standing; the bob and sway are
  off for them. FIRST CUT drew the three about 10 % smaller than their still twins (the grid's cell
  carries stride headroom) -> WALK_FILL per grid, measured (still figure height / walk figure height
  per cell, mean of facings: 1.06 / 1.07 / 1.11). FRAMES_ON false = the bob (before). LOOKED: board
  64 px/m before|after (clip), the suit over 24 ticks (contact -> pass -> other contact), the hood
  profile alternating arms and boots. Masters: peds_walk_frames_before_after_tilt70_64ppm_board.mp4,
  peds_walk_frames_suit_before_after_tilt70_64ppm_board_t100-123.png.
- REQUEST to assets: the other six walk strips at 70 (ped_shopper, ped_elder, ped_punk, ped_jogger,
  ped_hat, ped_cap), the ped_suit_walk_70_v2 recipe (name the pinned arm and the free arm per frame
  for the ones with a prop: shopper's bag, elder's cane). The away rows may be drawn as "frame 3 =
  frame 1" and mirrored in post (Codex repeats them anyway). The street lane cuts each by script the
  moment it lands (street_walk.py + one WALKS/WALK_FILL line).
- MEASURE (city, NEXT 2's "judge at 32"): city seed 5 tilt70 32 px/m 15 s with the stride frames,
  0 SCRIPT ERROR; the opening holds few pedestrians near Rivet (two at the edges), so the board is
  the evidence for the gait; no city still taken into frames.json.
- GATE unit no-arg on afe22e3b: 1507 passed, 0 failed, no FLAKY. Lint 15/15.
- MILESTONE c1e8cf2f (NEXT 3, the pop at the hit): `StreetWalkerCards.falls()`. Before, any
  reaction slot (rig.react != null, kept forever after the first flinch) dropped a walker to the
  top-down parts for good, so a grazed passer-by walked on as the sack on pills. Now a flinch keeps
  the figure (ReactPose moves the head, the card's parent, after the placement, and the hit flash
  tints it); a death holds the figure for DEATH_HOLD 0.3 of the family while it topples about its
  feet (DEATH_TIP 0.6 rad, eased, toward the hidden head's screen-x fall), then the parts take the
  fall and the corpse (it3's corpse stays). First cut held the figure still: it read as a freeze,
  then a bigger pop -> the topple. LOOKED `--kill=light` board 64 px/m before (hold 0) | after,
  ticks 58-80 every 2: before is a black ink tangle from the blow; after a person falls for ~9 ticks,
  then the swap. NOT SOLVED: the parts' corpse lies roughly north-south on screen, so the screen-x
  topple and the parts' fall still disagree at the swap (a visible jump at 64 px/m, small at 32).
  Masters: peds_walker_death_hold_before_after_tilt70_64ppm_board{_t58-80.png,.mp4}.
  DECISIONs street/walk-frames and street/walker-hit in docs/decisions.md.
- CALL (owner): the walker's death. Options: (a) hold + topple 0.3, then the parts (BUILT);
  (b) the parts from the blow (DEATH_HOLD = 0); (c) later: a drawn death strip per type (the
  library's action rows have one sprawl pose, not a fall). See the board clip above; exe
  `--arena=city --rigs --view=tilt70`.
- FINDING (NEXT 4, walkers' shadows): city seed 5 tilt70 32 px/m, x2 crop at t4 and t10: a hat
  walker on the cream pavement casts NO ground shadow while the patrol cop beside it casts the long
  RigCastShadows figure (masters peds_no_cast_shadow_vs_cop_tilt70_32ppm_x2_city_seed5_t4_t10.png).
  Not my hiding: the cast shadows are a separate Node2D (RigCastShadows, view's family) drawn per
  rig; its collect() reaches CharacterRigs/RigPool/CutRig at depth 2, so the pooled walker should
  be collected. Cause NOT found yet (no REQUEST to view until it is diagnosed).
- frames.json: the stride clip (#2) and the death-hold strip (#6) in; the two peds9 boards out
  (the walkers show all nine at 64 and 32 px/m), files kept. 15 entries, all present.

Registry rules applied (it5): sprite-and-atlas-production (the walk grid cut by script with a fixed
cell order and baseline, the size step measured per facing, not by eye; unit-tested grid shape),
motion-quality-gating (the gait and the death judged as tick strips and clips, the "freeze" first cut
rejected in motion, the remaining jump at the swap named), concept-scene-parity (before|after on one
board run, the before made by a one-constant switch), generative-artifact-gating (B strips used with
the library's own post fix; row 4's repeated frame accepted and named), render-submission-economy
(no new draw: the walker is the head card's own sprite, one texture swap).

NEXT (iteration 6):
1. Diagnose the walkers' missing cast shadow in the city (RigCastShadows draws per rig: is the
   walker rig in _rigs()? hip_h? z under the pavement?); fix on my side if it is mine, else a
   REQUEST to view with the cause.
2. When assets serve the six other walk strips: street_walk.py, one WALKS + WALK_FILL line each
   (measure the fill with the it5 snippet: still figure height / walk figure height per cell).
3. The death swap still jumps (the parts' corpse lies north-south, the topple is screen-x): tip
   toward the corpse's own head direction (RigTilt / DeathPose's fall axis), or end the hold
   earlier (0.2) and film both on the `--kill=light` board.
4. Walkers at p55 (boss arenas under combo): cut the 55 top rows, a "p55" STRIPS entry.
5. Crowd cost with the walkers under the bench lock on a quiet machine (city_bench riot, top vs
   tilt70), and the combo reel on this head.
- NEXT 1 lead (00:46): CrowdBaker bakes the far crowd by `rig.drive(TICK)` (crowd_baker.gd:100),
  and drive runs StreetView under a card view, so the baked atlas may hold walker cards (one frozen
  stride frame) and baked people cast no RigCastShadows shadow (it draws rigs only). Check first
  whether the shadowless walker is a baked sprite (CharacterRigs.MAX_FULL 16 per kind), then
  whether the bake should draw the walker figure (and which frame) or the parts.
- GATE director reel under tilt70 on c1e8cf2f (stride frames + the death hold; headless, the it1
  command): 19/19 chapters, every chapter all down (2/2, 4/4, 1/1 ...), 0 SCRIPT ERROR at the 19th
  chapter (the process runs on to its 14000-frame end). Unit no-arg 1507/0 was on afe22e3b; the
  `--changed` run on c1e8cf2f passed 1492/0 (its fast suite), lint 15/15. Owed: unit no-arg and the
  combo reel on c1e8cf2f, scenarios on the it5 head.
- GATE on c76be180 (code = c1e8cf2f): unit no-arg 1508 passed, 0 failed, no FLAKY; scenarios 52
  ran, 0 failed (headless; vehicle timings labelled CONTENDED by the runner); the tilt70 reel ran
  to its 14000-frame end, exit 0, 0 SCRIPT ERROR. Combo reel started 00:50 (reel_combo_it5.log).
- GATE director reel under combo on c1e8cf2f code: 19/19 chapters, every chapter all down, 0 SCRIPT
  ERROR at the 19th chapter (00:53; the process runs on to its end under a 14 min timeout). All
  three gate views of the it5 code: tilt70 19/19, combo 19/19; `top` untouched by it5 (the walker
  code returns at once without a card view; top reel last ran on 268bc09c) -> run the top reel and
  the selftest goldens first in it6 to keep the bit-identity claim current.

## Iteration 6 (2026-11-07 00:55, BUILD)

Read: JOURNAL, git log, the four lane journals (no REQUEST to street), the assets catalog: all six
walk strips served (ped_cap/elder/hat/jogger/punk/shopper_walk 70, all B, round 20261107-0005;
row-5 mirror post fixes applied by assets where the hand allows; the row-4 pilots for cap/punk C).
- MILESTONE 5f3727fe (NEXT 2): all nine walkers stride. street_walk.py cut the six; the size step
  measured per grid (still height / walk height per cell, mean of the facings; the snippet now kept
  in scratch/street/walk_fill.py; it reproduces it5's 1.06/1.07/1.11): cap 1.10, elder 1.07, hat
  1.07, jogger 1.11 (her shallower camera: the B note's "cut her cells to the cast's card height"
  is this step), punk 1.00, shopper 1.08. The shopper's B fix applied in the cut: row 4 frame 1
  swings the bag to her shoulder -> drawn as frame 3 (`street_walk.py --copy=3:0<2`, new flag).
  Elder rows 4-5 repeat frame 1 (no fix possible: the cane would change hands): a two-pose
  shuffle, kept. Provenance: six lines. LOOKED: the six grids on a contact sheet (identity, cane and
  bag in one hand, foot lines level), board 64 px/m before (c1e8cf2f) | after clip and a tick
  strip t100-120 (cap, jogger, elder, punk step; before they glide). Checked the facing direction
  of every grid column against its still twin by correlation (scratch/street/walk_dir.py): all 45
  columns agree, none mirrored; a runtime probe confirmed the same frame and flip in before and
  after for one jogger (the walk drawing is just more in profile than the still).
  Masters: peds_walk9_frames_before_after_tilt70_64ppm_board{.mp4,_t100-120.png},
  peds_walk9_city_tilt70_48ppm_seed5_12s.mp4 (+ _t8.png).
- FINDING WITHDRAWN (it5 NEXT 1, "walkers cast no shadow"): a probe inside RigCastShadows at city
  seed 5 lists both pooled pedestrians among its rigs (hip 236.7 x 0.125), and the x3 crop at 48
  px/m shows the hat and hood walkers' long cast shadows (faint on cream crosswalk and paving, read
  as absent at 32 px/m). The same with StreetWalkerCards.ENABLED false. No bug; no REQUEST to view.
  Master peds_cast_shadow_present_tilt70_48ppm_x3_city_seed5_t8.png; the it5 "no shadow" still
  deleted.
- GATE on 5f3727fe: lint 15/15; unit no-arg 1508 passed, 0 failed, no FLAKY.
- frames.json: the nine-walker board clip (#2) and the city clip (#3) in; the it5 three-walker clip
  and cops_p70_heads out (files kept). 15 entries.
- MILESTONE 325645a6 (NEXT 3, the death swap jump): StreetWalkerFall (new file, the cards file
  stays under 200 lines). Through the hold the figure follows the hidden parts' own head vector
  (feet -> head on screen): leans along it and shortens to its length (of the length at the blow,
  clamped 0.3-1.15), eased in. FOLLOW false = the it5 screen-x tip. LOOKED `--kill=light` board 64
  px/m ticks 58-82 every 3, before | after: the parts' corpses lie head SOUTH (toward the camera),
  so it5 tipped the figure sideways and then the corpse lay vertical (a direction change); now the
  figure crumples over its feet (the first half of a fall toward the camera) and the corpse
  extends below. NOT SOLVED: the head still crosses from above the feet to below them at the
  swap (a drawn fall per type would remove it). 3 unit tests (upright when not dying, the lean and
  length at the swap, a north fall shortens without a lean). DECISION street/walker-fall.
  Masters: peds_walker_death_follow_before_after_tilt70_64ppm_board{.mp4,_t58-82.png}.
- CHECKED (no change): the facing convention of the nine p70 strips and grids, at full size against
  Rivet's and the cop's d8 strips: every unflipped cell faces right (3/4 toward down-right, side
  right, 3/4 away up-right), as RigHeadCard.OCT_FLIP expects. A read at thumbnail size had
  suggested otherwise; it was wrong.
- MILESTONE aa9f60ef (NEXT 4): walkers under p55. The nine library ped_*_55 A top rows cut by
  street_head.py (band 1.0, 192 px, no colour fix; nine provenance lines), a "p55" STRIPS row;
  the bob (no 55 walk grids). LOOKED board 64 px/m `--view=tilt` t120 before | after: the head
  cards on black-and-white pill bodies become coated people; they read a little small beside the
  old oversized head cards (HEIGHT_M 1.7 is shared with p70; a p55 height is one constant away if
  the owner wants them bigger). DECISION street/walkers-p55.
  Master peds_walkers_p55_before_after_tilt_64ppm_board_t120.png.
- GATE director reel under tilt70 on abb17c2b (all nine stride; headless, the it1 command): 19/19
  chapters, every chapter all down (14 x 1/1, 2 x 2/2, 3 x 4/4), 0 SCRIPT ERROR, exit 0.
- GATE unit no-arg on aa9f60ef: 1511 passed, 0 failed, no FLAKY. Lint 15/15 (pre-commit).
- frames.json: the p55 board (#4) in, the death-follow strip replaces the it5 death-hold strip;
  15 entries. Scratch .avi captures deleted.
- MILESTONE 1c8b1431: p55 walkers stand 2.0 m (StreetWalkerCards.HEIGHT_BY_ART; p70 stays 1.7).
  LOOKED city seed 5 48 px/m t8, x2 crops of the hat and hood walkers beside a cop: p70 1.7 | p55
  1.7 | p55 2.0. At 1.7 the 55 drawings (longer legs, smaller heads, cells ~0.83 as wide) read
  about two-thirds of a cop and smaller than their p70 twins; at 2.0 the bulk matches p70 and the
  cops. Master peds_walkers_height_p70_p55_1.7_p55_2.0_48ppm_x2_city_seed5_t8.png.
- GATE director reel under combo on aa9f60ef (p55 walkers in): 19/19 chapters, every chapter all
  down (14 x 1/1, 2 x 2/2, 3 x 4/4), 0 SCRIPT ERROR, exit 0.
- GATE `top` holds on dce89b5b (it6 code but the p55 height): `node tools/selftest/run.mjs` exit 0,
  look goldens 11/11 (worst 0.27), block goldens 5/5 (worst 0.22), crowd atlas 6/6 on doctrine,
  world lock 0.00 %. (The it6 code reads WALKS / STRIPS / HEIGHT_BY_ART only under a card view.)
- MEASURE (brief 6) crowd cost with all nine walkers, CONTENDED (no bench.lock held by anyone, mine
  taken; 4 then 2 other Godot processes at launch): city_bench riot, 400 on foot, 32 px/m, 30 s, one
  pair top / tilt70: avgFrameMs 5.34 -> 6.42, p99CpuMs 16.8 -> 20.7, low1Fps 46.3 -> 34.7,
  drawCallsAvg 685 -> 797 (it4: 800, so the hidden parts saved no draw calls), rigMsPerTick 0.84 ->
  1.54 (it4 clean pair: 0.74 -> 0.99), simStepMsPerTick 0.126 -> 0.132 (the view-free control,
  flat). NOT a verdict: contended, one pair. If the +0.7 ms of rigs holds on a quiet machine, the
  suspect is StreetWalkerCards.step re-hiding every cached part each tick (cheap per call, ~20
  parts x 16 full rigs) -> hide once and re-hide only after RigHeadCard/RigBuild re-show.
  JSONs: masters n8/street/bench/it6/.

Registry rules applied (it6): sprite-and-atlas-production (the six walk grids cut by script with
the one fixed cell order; the library's B fix applied as a named, reproducible cut flag, not a hand
edit; the size step measured per grid; per-pitch height as data), motion-quality-gating (the gait
judged as a clip and a tick strip; the death judged as a tick strip with the remaining jump named),
concept-scene-parity (every before|after on one seeded run, the before made by one constant or the
previous commit's file), generative-artifact-gating (B sheets only with their named fix; the
elder's repeated away frames accepted and named; A sheets for p55), render-submission-economy
(the walker is still one sprite per person; the cost pair measured, labelled CONTENDED, and the
suspect named rather than guessed away), depth-ordered-layered-art (the card stays the head card's
own sprite: the rig's depth sort and the cast shadows unchanged, confirmed in the city crop).

NEXT (iteration 7):
1. Crowd cost on a quiet machine (bench.lock, 0 other Godot): 3 pairs city_bench riot top vs
   tilt70 (scratch/street/bench6/run.sh, set 3 pairs). If rigMsPerTick rises over it4's +0.25,
   make StreetWalkerCards.step hide the parts once (a dirty flag) and re-measure.
2. The death swap's remaining jump: try DEATH_HOLD 0.45 with the follow (the parts' head is then
   past the feet: the figure would shorten to MIN_LEN, then the corpse) and film the `--kill=light`
   board against 0.3; or a REQUEST to assets for a fall strip per type (5 facings x 3 frames).
3. 55 walk grids: REQUEST to assets (ped_*_walk_55, the 70 recipe) if combo's boss fights show
   pedestrians gliding at p55 (the King's street fight: film `--boss=king --view=combo --rigs`).
4. The thug / cultist / Torque's gang items stay as it3-it4 left them (no code names cultists or
   Torque's gang in features/); re-check the other lanes' journals for a REQUEST.
5. Freeze prep (08:30): the Windows export and the REPORT's calls (cop tone, crowd variety,
   walkers, the walker's death, the contractor's orange, p55 height).
- MEASURE rig_bench headless (16 full rigs, 540 ticks), CONTENDED (2-3 other Godot processes; both
  runs exit 1: the section-20 judge fails under load, top too): rigMsP50 top 0.746 / 0.750 ms
  (50 / 200 people) vs tilt70 0.969 / 1.085: ratio 1.30 / 1.45, it3's quiet pair 1.20 / 1.44. The
  nine walkers (stride frames, the fall follow) add no rig cost beyond the load noise; the riot
  pair's +0.7 ms of rigs above is most likely contention. NEXT 1 stays (quiet machine) but the
  "hide once" change is not justified by this data. JSONs: masters n8/street/bench/it6/.
- TRIED (NEXT 2 above), REJECTED: DEATH_HOLD 0.45 with the follow. `--kill=light` board 64 px/m
  ticks 64-92 every 4, 0.3 | 0.45: past ~0.35 the parts' head is below the feet, so the follow
  turns the drawing toward upside-down (the cap walker lies head-first with its face inverted)
  before the swap. Worse than 0.3; DEATH_HOLD stays 0.3. The remaining jump wants a drawn fall
  (REQUEST below), not a longer hold. Master (rejected evidence)
  peds_walker_death_hold_0.3_vs_0.45_REJECTED_tilt70_64ppm_board_t64-92.png (not in frames.json).
- REQUEST to assets: ped_<type>_fall_70 for the nine pedestrian types (low priority, after any
  REQUEST from other lanes): one row per facing (5), 3 frames each: knees buckling, falling
  toward the facing (mid-fall, ~45 deg), lying on the ground at the feet's spot; same identity,
  camera and palette as ped_<type>_70 A/B. The street lane plays it through DEATH_HOLD instead of
  the follow, so the figure ends where the parts' corpse lies.
- GATE scenarios on bc9e7c4f (the it6 code; headless): 52 ran, 0 failed, 0 SCRIPT ERROR, exit 0
  (vehicle timings labelled CONTENDED by the runner). Owed on the it6 head: parity and
  export-audit (no native or sim change in it6: view code only), the top director reel (the it6
  code returns at once without a card view; top goldens 11/11 above).
- Session end 01:41: tree clean, every change committed (5f3727fe, 325645a6, aa9f60ef, 1c8b1431
  + docs). NEXT (iteration 7) as listed above.

## Iteration 7 (2026-11-07 01:42, BUILD)

Read: JOURNAL, git log, the other lanes' journals (no REQUEST to street; view and hud note the
street draws top-down on their branches: street's work lives here until the Director merges).
bench.lock held by view at 01:42 (then free at 02:00 with 6 other Godot processes up: not quiet).

- The fall REQUEST (it6) served by assets while I read: ped_*_fall_70 for all nine types (B, round
  20261107-0137; named fix: the facing-camera and back corpses are drawn as tall as the standing
  figure, stretch them along the fall axis), plus v2 of suit (v1 stays the pick) and worker (v2
  supersedes: corpses 1.2x longer).
- MILESTONE 42b780f1 + the punk/shopper commit (NEXT 2 closed, brief 5): **pedestrians fall and lie
  as drawn under p70**. tools/art/street_fall.py (new) cuts a strip into 5 facings x 3 frames with
  each figure's FEET at the cell centre (standing/mid-fall: the bottom rows' centroid; lying: the
  body's end away from the facing's fall direction), drops loose specks and a neighbour row's reach
  (the hood's stray hand, named in its cut note), scales to the still strip's px/m, applies the B
  fix as `--stretch=1.5` (worker v2 1.25). StreetWalkerFall.FALLS/draw: dying or dead, the walker
  keeps its card: buckle -> mid-fall -> lying at FALL_AT 0/0.18/0.4 of the family, the facing row
  chosen from the blow's direction (RigHeadCard.frame_of, so 8 directions from 5 rows + mirror),
  the feet on the rig root (which carries the knock-back slide), the lying frame is the corpse (no
  swap to the parts: the jump is gone). CorpseFade's ink modulate is inherited; its sink is read
  back from rig.scale. DRAWN false = it6. 2 unit tests added (5/5).
  LOOKED: the 7 then 9 grids on contact sheets with the feet marked (all 45 cells; the suit's
  briefcase pulls the standing anchor ~0.2 m toward the case: accepted), the board `--kill=light
  --kill-spread` (new dev flag: walker i hit from i x 45 deg) at 64 and 32 px/m, ticks
  59/62/65/68/72/150, DRAWN false | true: before, every walker pops to the white-limbed parts at
  t68 and lies as an X; after, they buckle (t62-65), fall (t68) and lie as drawn people in eight
  directions, each at the spot it stood. Masters:
  peds_drawn_fall_before_after_tilt70_64ppm_board_t59-150.png (tick strip),
  peds_drawn_fall_before_after_tilt70_{32,64}ppm_board_t150.png,
  peds_drawn_fall9_tilt70_64ppm_board_spread_t150.png (all nine types).
  Provenance: 10 lines (9 + the worker v2); the prov script's stale date fixed to 2026-11-07.
  DECISION street/drawn-fall. FRICTION: `tools/godot/check.mjs` reports FAIL on any file in the
  CutRig dependency cycle (an untouched street_crowd_cards.gd too) with no root error; the GUT run
  is the real compile check. Debt ratchet: +4 dev lines accepted for --kill-spread.
- MILESTONE (punk/shopper commit): all nine types fall as drawn (punk, shopper B 0137; the worker
  from v2 0225, stretch 1.25 since v2 already lies 1.2x longer). LOOKED: the three new grids on a
  contact sheet (the shopper's olive fruits survive the key), the board t150: all 16 walkers lie as
  drawn people, none drop to the parts. Master peds_drawn_fall9_tilt70_64ppm_board_spread_t150.png.
- GATE unit no-arg on the nine-fall head: 1513 passed, 0 failed, no FLAKY.
- GATE director reel under tilt70 on the nine-fall head (the it1 headless command): 19/19
  chapters, all down (14 x 1/1, 2 x 2/2, 3 x 4/4), 0 SCRIPT ERROR (stopped after the 19th).
- GATE director reel under combo on the same code: 19/19, all down (same counts), 0 SCRIPT ERROR.
- LOOKED city block seed 5 tilt70 48 px/m 25 s with the Rivet bot (no regression in the walking
  crowd): no pedestrian dies in that run (the 4 deaths are cops, react ids 3000+), so the board
  stays the drawn-fall evidence. The dying cops still sprawl as white-limbed parts with the head
  card: the next drawn fall (REQUEST below). Capture deleted.
- MILESTONE (the FALLS generalisation): any rig with a FALLS row takes the drawn fall while down
  (StreetWalkerFall.down), not only pedestrians: a cop strip is one FALLS row ("cop/head_cap",
  "cop/head_helmet", "cop/head_swat") when it lands. Unit no-arg caught my first order (a bare
  rig has no plan): fixed, 1513/0; the board t150 is pixel-identical to the committed run.
- SKIPPED cop_patrol_v2 70 A (round 0150): its gain is the torso/legs value split; my patrol card
  cuts only the head band (cap, face, collar) and its own note says it was drawn from a target,
  not the 55 sheet (the cap and sleeves may not pair with cop_patrol_55). Kept the 1940 B card.
- frames.json: the drawn-fall tick strip (#2) and the 32 px/m pair (#3) in; the it6 death-follow
  strip and the it4 hit-drop-to-parts still out (files kept, superseded). 15 entries.
- REQUEST to assets: cop_patrol_fall_70, cop_riot_fall_70, swat_fall_70 (and cop_patrol_fall_55,
  cop_riot_fall_55, swat_fall_55 after, for the boss arenas): the ped_*_fall_70 recipe exactly (5
  rows = facings, 3 frames: knees buckling, mid-fall toward the facing, lying face down along the
  facing at the feet's spot; same identity, camera and palette as cop_patrol_70 (1940) /
  cop_riot_70 A / swat_70 A; police blue only on them). Please draw the facing-camera and back
  lying frames ~2x the standing height (the ped strips' named fix). The riot cop drops the shield
  beside him in frame 3; the patrol cop's pistol may fall beside the hand. The street lane plays
  them through StreetWalkerFall (one FALLS row each); cops die in every chase, and at 32 px/m their
  parts' corpse reads as a white cross.
- MILESTONE 235374e8: under p55 (combo's boss fights, `--view=tilt`) a dying walker falls as the
  p70 drawing at its p70 height (StreetWalkerFall.FALLBACK "p70"; "" = the hold and the parts), so
  combo's pitch swap no longer turns a drawn corpse back into the parts' cross. LOOKED the board
  `--view=tilt` 64 px/m t150: all 16 lie as drawn at the cast's size; tilt70 board t150 pixel-
  identical to the committed run. Master peds_drawn_fall_p55_fallback_tilt_64ppm_board_spread_t150.png.
  Walker unit tests 18/18 (fall, cards, crowd).
- EVIDENCE clip peds_drawn_fall_before_after_tilt70_64ppm_board_spread.mp4 (6.4 s: the pop to the
  parts | the drawn fall, real time then 0.25x; the board under --write-movie). frames.json #2; the
  it3 blast still out (superseded). Raw .avi deleted.
- GATE scenarios (headless, started 02:14 on the nine-fall head; I edited street_walker_* while it
  ran, view code only): 52 ran, 1 failed = scenario_rig_stress "50 people: rig p50 1.055 ms > 1.000"
  (a wall-clock budget, measured while my board renders and 2-3 other lanes' Godot runs were up).
  Re-run alone through `node tools/tests/run_scenarios.mjs --only=rig_stress`: 1 passed, exit 0.
  The it7 code returns at once without a card view (rig_stress runs `top`). 0 SCRIPT ERROR.
- NOT DONE: brief 6 crowd cost on a quiet machine (bench.lock free at 02:00 but 2-3 other lanes'
  Godot processes up all session: a pair would repeat it6's CONTENDED pair).

Registry rules applied (it7): sprite-and-atlas-production (the fall strips cut by one script with
a fixed cell order and a named anchor rule, the feet, so every frame lands on the ground point; the
library's B fix applied as a reproducible flag; one shared px/m with the still strips; the worker's
superseding v2 taken by its note, the suit's v2 rejected by its), generative-artifact-gating (B
sheets only with their named fix; the stray neighbour hand removed by rule, not by hand; the
shopper's green fruits checked against the key; cop_patrol_v2 A declined for a named identity
risk), motion-quality-gating (the fall judged as a tick strip and a before|after clip at real time
and 0.25x, eight blow directions on one board), concept-scene-parity (every before|after on one
seeded board, the before one constant away; pixel-identity used to prove a refactor), depth-
ordered-layered-art (the corpse is the head card's own sprite: the rig's depth sort, the decay's
modulate and the stain order unchanged), render-submission-economy (still one sprite per person
dead or alive; the parts stay hidden, so a drawn corpse costs less than the parts' corpse).

NEXT (iteration 8):
1. Cop fall strips (REQUEST above): when cop_*_fall_70 land, cut with street_fall.py (--stretch
   as their notes say) and add FALLS rows "cop/head_cap", "cop/head_helmet", "cop/head_swat"; the
   riot cop's shield card (RiotShieldCard) must hide while the fall draws (check it re-shows), and
   film the city bot run (cops die there: seed 5 ticks 500-1000) top | tilt70 at 48 px/m.
2. Crowd cost on a quiet machine (it6 NEXT 1, bench6/run.sh, 3 pairs), if the machine quiets.
3. The suit's standing anchor leans ~0.2 m toward the briefcase (the bottom-rows rule catches the
   case): if it reads at 64 px/m in motion, add a per-sheet x override to street_fall.py.
4. Freeze prep (08:30): the Windows export and REPORT calls (cop tone, crowd variety, walkers,
   the drawn fall's speed FALL_AT and the stretch, p55 height).
- MILESTONE (NEXT 3 above, done in it7): the buckle frame stands on its box centre, as
  street_head/street_walk place the walker. Measured on the sheets (old anchor - box centre, cm at
  1.7 m, per facing): suit -25/-34/-28/-14/+20, elder -29/-35/0/5/-4, shopper -3/-11/-22/1/-5, hood
  0/-11/-13/-5/0: the case and the cane pulled the old anchor sideways, a jump at the blow. Nine
  grids re-cut (deterministic), provenance re-hashed (9 lines). LOOKED the board t59/62/65 old |
  new (the shift is a few px at 64 px/m; the masters' stills and clip stay valid). Lint 15/15.
- Session end 02:27: tree clean, every change committed. Commits it7: 8762d7e7 (board
  --kill-spread), 42b780f1 (seven drawn falls), the punk/shopper/worker-v2 commit, the FALLS
  generalisation, 235374e8 (p55 fallback), the box-centre anchor, + docs. NEXT (iteration 8): 1
  cop falls when served, 2 quiet crowd cost, 4 freeze prep (NEXT 3 done).

## Iteration 8 (2026-11-07 02:27, BUILD)
Read: JOURNAL, git log, the library catalog (cop_patrol_fall_70 B landed, round 20261107-0300,
my it7 REQUEST 1 of 6; riot/SWAT falls not yet), the other lanes' journals (no REQUEST to street).
- MILESTONE (brief 5, cops): **the patrol cop falls and lies as drawn under p70.** Cut
  cop_patrol_fall_70 (B) with street_fall.py `--stretch=1.4` (drawn 1.09x, so ~1.5x as the ped
  strips) `--back-from-away`; FALLS row "cop/head_cap". Provenance line added.
- FOUND + FIXED (a real bug, it7's too): `react.post()` runs after StreetView.step in CutRig.drive
  and turns the card's parent, so a drawn corpse was drawn rotated by the death pose. On the cops
  it showed plainly (the 3/4-away corpse drew upright with a raised arm: I first took it for the
  sheet's named "standing man with raised hands" fault and tried stretch 1.7 and the front corpse
  turned 180 deg, neither helped; a frame probe showed the right cell drawn turned ~60 deg).
  StreetView.post (new) places a falling card again after the post; the global_transform-only
  try (skew) changed nothing and was reverted. The pedestrians had it too: the it7 board t150
  (committed master) has several corpses lying at angles that are not the blow's; with the fix
  all 16 lie along their blows. So it7's "lie as drawn in eight directions" was only partly true.
  Straight down there is no card, so `top` is unchanged (post returns at once).
- DECISION street/cop-back-corpse: the back facing's corpse is the 3/4-away row's (lying on the
  up-right diagonal, 45 deg off the blow), not the drawn back one: with the rotation fixed the
  drawn one is borderline (soles + hands by the cap read as lying or as a cop standing hands at
  head), the diagonal reads as lying beyond doubt. Alternative: drop `--back-from-away` from the
  cut (one flag). Peds keep their drawn back corpses.
- LOOKED: the cop board (`--cops`, new dev switch: 12 patrol, 2 riot, 2 SWAT) `--kill=light
  --kill-spread` at tilt70 64 and 32 px/m t59-150 (probe: walker i's frame_coords/flip/oct):
  the 12 patrol cops buckle, fall and lie in eight directions as drawn people at their spots;
  riot/SWAT still sprawl as the parts (white limbs), waiting for their strips.
- Lint 15/15 after `debt --accept-regression` (cut_rig +1 line: the post call; dev/showcase +9:
  the --cops switch).
- EVIDENCE (masters n8/street, frames.json #1-#3 new, 15 entries; dropped the 32 px/m it7 fall
  pair (its "after" carried the rotation), the walk9 frames clip and the p55 walkers board; the it7
  drawn-fall strip and clip notes now say which angles were wrong):
  cops_drawn_fall_before_after_tilt70_64ppm_board_t62-150.png (before row = the FALLS row removed:
  the parts' white cross), cops_drawn_fall_before_after_tilt70_32ppm_t150_x2.png,
  cops_drawn_fall_tilt70_64ppm_board_realtime_then_0.25x.mp4 (4 s), and
  peds_drawn_fall_postfix_before_after_tilt70_64ppm_t150.png (it7 master | it8).
- GATE unit no-arg on 74cb66dd's code (before the commits, same files): 1513 passed, 0 failed, no
  FLAKY (91 s). Lint 15/15 on each of the three commits (hook).
- GATE director reel under tilt70 on e47c984c (the it1 headless command): 19/19 chapters, every
  one all down, 0 SCRIPT ERROR (stopped after the 19th; my PID).
- LOOKED city block seed 5 tilt70 48 px/m 25 s (Rivet bot): 4 cops die by death_melee (frames
  513/658/763/994); one lies as the drawn patrol corpse by the kerb (t1010). FOUND (older than
  tonight): the first one (frame 513, under Rivet's claw on the crosswalk) vanishes ~10 ticks into
  the death, leaving a short black bar and the blood trail; the it7 code (the four files from
  be98fa1f) gives the identical frame 540, so it is not tonight's change. Not traced yet: suspect
  the full-rig budget (MAX_FULL) handing the dead cop to the baked LOD, or the melee family's
  slide. Captures deleted (city.avi kept in scratch until next iteration).
- NOT DONE: crowd cost (brief 6): vehicles' Godot render and my reel up all session, no quiet window.
- Registry rules applied (it8): generative-artifact-gating (the B sheet with its named fix (the
  stretch), and the back corpse swapped for a frame that reads, by a reproducible cut flag, not a
  hand edit), motion-quality-gating (the fall as a tick strip and a real-time-then-0.25x clip; a
  frame probe before blaming the art), concept-scene-parity (before|after on one deterministic
  board, the before one data row away; the it7 code re-run on the same city seed to rule my change
  out), sprite-and-atlas-production (one cut script, one px/m with the ped strips),
  render-submission-economy (still one sprite per dead cop, the parts hidden).

NEXT (iteration 9):
1. Riot and SWAT fall strips (REQUEST it7, 2-3 of 6) when served: `street_fall.py <keyed> <out>
   --stretch=<per note> [--back-from-away if the drawn back corpse reads upright]`, FALLS rows
   "cop/head_helmet" (check RiotShieldCard hides while the fall draws and re-shows on release) and
   "cop/head_swat"; film with the board `--cops` (looks 6 and 8 on walkers 12-15: widen COP_LOOKS
   to show all 8 directions for them) at 64 and 32 px/m, before = the row removed.
2. The vanishing city corpse (FOUND it8, older than tonight): `--arena=city --bot=rivet --seed=5
   --rigs --ppm=48 --view=tilt70`, actor 3000 dies at frame 513 and is gone by ~525. Probe whether
   it leaves ArenaRigs' feed (dev/arena/arena_rigs.gd fills it from the CombatArena) or keeps its row
   with the card hidden; if the arena drops the fighter, it is not street's code: REQUEST to the
   Director/combat with the probe; if the card, fix here. Also check `top` on the same seed.
3. Crowd cost on a quiet machine (it6 NEXT 1, bench6/run.sh, 3 pairs) if the machine quiets.
4. Freeze prep (08:30): the Windows export and REPORT calls (cop tone, crowd variety, walkers,
   drawn-fall speed FALL_AT / stretch / p55 height, the cop back corpse from the 3/4-away row).
- GATE director reel under combo on e47c984c (same command, `--view=combo`): 19/19 chapters, all
  down, 0 SCRIPT ERROR (stopped after the 19th; my PID 67904, the other combo run is view's).
- DECISION street/cop-back-corpse written to docs/decisions.md.
- Session end: every change committed (74cb66dd post-pose fix, 5b7906bd patrol cop fall,
  e47c984c board --cops, + docs). Scratch city.avi (it8) kept for NEXT 2, delete after.
- PROBE (NEXT 2, temporary printerr in CharacterRigs._assign, not committed, restored): on the
  city seed 5 run actor 3000 is RELEASED from its full rig on the tick it dies ("release 3000
  in_feed 20 dead true", right after "death_melee on 3000, frame 513"), still in the feed. So it
  is the LOD budget: RigSelect.nearest keeps the 16 nearest the focus (ArenaRigs.focus_m: the box
  centre of Rivet, his aim point and every hostile within FOCUS_REACH_M), the crowd of cops north
  of Rivet pulls that centre away, and the dead cop at the box's south edge is the 17th. It then
  draws as the baked crowd atlas row (CrowdAtlas, DEAD -> its corpse cell): the short black bar
  on the crosswalk is that cell under tilt. Not street's selection code (CharacterRigs/RigSelect
  are chars/view, ArenaRigs is dev/arena). Street's share: the atlas corpse under a card view
  should be the drawn lying frame (StreetWalkerFall's grid, frame 2 of the blow's facing) rather
  than a bar. NEXT 2 becomes: (a) REQUEST to view: RigSelect keeps a dying/fresh corpse within
  RADIUS_M ahead of the living past the 16th (or ranks dead by distance to Rivet, not the focus);
  (b) street: look at CrowdAtlas' corpse cell under p70 and, if cheap, draw the FALLS lying frame
  for a baked dead row.
- REQUEST to view: RigSelect / the LOD bubble: keep a dying or freshly dead body that is on screen
  on its full rig past the MAX_FULL-th living one (or rank the dead by distance to Rivet rather
  than to the box-centre focus). Repro: `--arena=city --bot=rivet --seed=5 --rigs --ppm=48
  --view=tilt70`, actor 3000 dies at frame 513 under Rivet's claw and is released the same tick
  (it drops to the baked atlas: a black bar where a drawn corpse should lie). Under the card views
  the drawn corpse costs one sprite, the same as the parts. If view prefers street to carry it,
  say so and street will do it in a file of its own.
- Scratch: city.avi and the probe logs deleted (the finding is in the lines above).
- 03:14 library check: riot/SWAT fall strips not served yet; contractor_fall_55 and thug_fall_55
  landed (not mine to have asked for at 55 first; the thug and contractor walk under p70 in play):
  NEXT 1b: read their catalog notes, cut them with street_fall.py if their identity matches the
  in-game cards, FALLS rows under "p55" (and p70 through FALLBACK only if no 70 twin comes).
  Session stopped here (not enough time left for a cut + film + gates cycle).

## Iteration 9 (2026-11-07 03:15, BUILD)
Read: JOURNAL, git log, the library catalog: my 03:14 check was wrong, the riot/SWAT fall strips
(cop_riot_fall_70, swat_fall_70 B) had landed at 02:30 with the patrol's round 0300; also thug,
contractor, cultist, torque_gang falls at 70 (0315) and 55 (0325/0335). Other lanes' journals: no
REQUEST to street.
- MILESTONE 9fa20822 (brief 5, NEXT 1): **the riot cop and SWAT fall and lie as drawn under p70.**
  street_fall.py `--stretch=1.3` (riot: drawn 1.18x/1.10x) / `1.35` (SWAT: 1.18x/1.06x), both
  `--back-from-away` (their notes: the drawn back corpse reads as a kneel); FALLS rows
  cop/head_helmet, cop/head_swat. The riot shield: the drawing carries it on the arm (buckle,
  mid-fall) and flat beside the body (lying); the upright RiotShieldCard plate is a child of the
  torso, hidden with the parts, so no double shield at any tick looked (62/65/68/90/150/240).
  New board switch `--heavy` (8 riot + 8 SWAT, so --kill-spread shows each in all 8 directions);
  debt +4 dev lines accepted. Unit test: every FALLS grid exists, all three cops have one.
- LOOKED the board tilt70 64 and 32 px/m (x2 crop), before = the two rows removed (a local edit,
  restored): before, the parts sprawl with white limbs and crescent shields; after, 16 drawn
  corpses along their blows, shields flat. One riot cop at 32 px/m t62 still stands in both runs
  (its death starts a few ticks later; drawn by t68), not a missed row.
- GATE unit no-arg on 9fa20822: 1514 passed, 0 failed, no FLAKY (46 s).
- MILESTONE a376cbdb (brief 2+5, NEXT 1b): **the robot thug powers down and lies as drawn under
  p70** (thug_fall_70 B, stretch 1.4, --back-from-away: "row 5 reads as a standing robot with
  raised claws"). FALLS row "thug" (RigHeadCard's row key for ThugPlan's art_dir); the death is
  kill_robot's death_robot family, a HumanReact, so the drawn fall takes it with no code.
  Filming FRICTION: `--bot=ghosts` needs the scene path `res://dev/arena/arena.tscn` (the
  arena is main_scene.showcase, not main); the Kerf beat's thug dies by Kerf's cut (a signature
  slice: the parts in halves, not the drawn fall, correct), the Ohm beat's by a power-down.
  PROBE (temporary printerr in strip_of, restored): thug dead/dying, row "thug", art p70.
  LOOKED Ohm beat seed 4 48 px/m x2: before = the dead thug's parts as one ink sprawl (the
  brief's complaint, now at death); after = the lit steel robot slumps and lies on its side.
  The living thug's long-armed parts swap to the compact drawing at the blow (same spot/height).
- EVIDENCE (masters n8/street, frames.json 15 entries, 4 new at #2-#4, #7):
  cops_riot_swat_drawn_fall_before_after_tilt70_64ppm_board_t65_t150.png,
  thug_drawn_fall_before_after_tilt70_48ppm_x2_ohmbeat.png,
  thug_drawn_fall_before_after_tilt70_48ppm_x2_ohmbeat_realtime_then_0.25x.mp4 (10 s),
  cops_riot_swat_drawn_fall_before_after_tilt70_32ppm_x2_board_t62-150.png. Dropped (superseded,
  files deleted): the patrol 32 px/m pair, the ped t59-150 still (the clip #5 stays), the city
  walkers 32 pair, the it2 Kerf-beat 32 px/m cops/thug pair.
- IN PROGRESS (brief 4+5): quest 1's dead dock contractors draw as the drawn lying frame
  (contractor_fall_70 B, stretch 1.4, --back-from-away: the back row's lying frame read as a
  kneel) instead of the flat guard_down sprite: StreetQuestCards.draw_down, called by CastView
  where it drew guard_down; opaque (the sprite's DOWN_FADE 0.8 alpha would show the ground through
  a drawn body); fallen forward along the guard's facing (CastView has no blow direction).
- MILESTONE 72dde64b (brief 4+5): **quest 1's dead dock contractors lie as drawn people** under
  the card views (contractor_fall_70 B lying frame; StreetQuestCards.draw_down where CastView drew
  the flat guard_down sprite). LOOKED quest 1 Dock 9 t14100 at tilt70 48 px/m x2, before =
  `DOWN = {}` (a local edit, restored; a separate run: quest runs differ in blood and heap size):
  before, every dead guard is a white top-down sprawl; after, orange-vested contractors lie with
  their rifles beside them. First film: the gate heap of five all lay the same way (charging
  west, fallen forward) = clones; added a per-spot turn (spread_of: -45/0/+45 deg from the ground
  point, render only, no RNG stream; SPREAD 0 = the alternative); the re-film shows one diagonal
  in the heap, still mostly side-on. No fall animation (CastView has no death clock; the corpse
  appears at death as the sprite did). Size: the standing card's height (WIDTH_M x the cell
  aspect) at the grid's STILL_PX, so the corpse is in the walkers' proportions.
- DECISION street/contractor-corpse: opaque (the sprite's DOWN_FADE 0.8 would show the ground
  through a drawn body), fallen along the facing turned by spot. Alternatives: tint DOWN_FADE (one
  argument), SPREAD 0.
- EVIDENCE: masters contractor_drawn_corpse_before_after_tilt70_48ppm_x2_quest1_dock9.png
  (frames.json #5; dropped the 12 s walk9 city clip, covered by the 40 s city clip #10).
- GATE unit no-arg on 72dde64b: 1516 passed, 0 failed, no FLAKY.
- PREPARED (scratch it9/p55, not in the project yet): the 55 fall grids for the boss arenas
  (cop_patrol/cop_riot/swat/thug_fall_55 B, stretch 1.45 as their notes, --back-from-away); LOOKED
  the four grids (the p55 patrol cop is the 55 sheet's brighter police blue, as its p55 card).
  Needs grid_of to fall back per row (today a "p55" key would drop the peds' p70 fallback):
  scratch it9/p55/apply.py does both.
- GATE director reel under tilt70 on the it9 code (72dde64b, headless, the it1 command): 19/19
  chapters, every one all down, 0 SCRIPT ERROR (stopped after the 19th: my PID 47076 tree).
- Registry rules applied (it9): generative-artifact-gating (four B sheets each with its named fix,
  the stretch, plus the back corpse swapped by a cut flag where the note names a kneel; the
  contractor's back corpse looked at and swapped for the same fault), motion-quality-gating (the
  thug's death in a real-time-then-0.25x clip; a probe before blaming the art, which showed the
  "parts" I saw were the drawn lying frame), concept-scene-parity (every before one data row away
  on the same seed; quest 1 same tick, separate runs, said so), sprite-and-atlas-production (one
  cut script, one px/m for every fall grid; the contractor sized from its own standing card),
  depth-ordered-layered-art (the riot shield: the drawn one replaces the upright plate, never both),
  render-submission-economy (one sprite per corpse, the parts hidden; the contractor one
  draw_texture_rect_region where the sprite drew one).

NEXT (iteration 10):
1. p55 fall grids for the boss arenas (prepared in scratch it9/p55: copy the four PNGs to
   art/view/p55/, run scratch it9/p55/apply.py from the worktree root (grid_of per-row fallback +
   a "p55" FALLS dict), add a test: p55 cop -> "p55/cop_patrol_fall.png", p55 ped -> the p70 grid),
   --import, film the board `--view=tilt --heavy --kill=light --kill-spread` at 64 px/m, before =
   today (the p70 grids at p55 height), provenance x4 (rounds 0300 / 0335, hashes in the catalog).
2. Contractor at 55 and the cultist / Torque gang falls: nothing in game spawns cultists or
   Torque's gang (it3/it4 scout) - the strips wait; the contractor 55 only matters under --view=tilt.
3. Crowd cost on a quiet machine (bench6/run.sh, 3 pairs) if the machine quiets.
4. Freeze prep (08:30): the Windows export and REPORT calls (cop tone, crowd variety, walkers,
   drawn-fall speed FALL_AT / stretch / p55 height, cop back corpse, contractor corpse opaque +
   spread).
- GATE scenarios on 72dde64b: 52 ran, 0 failed (exit 0; vehicle drive timing CONTENDED as usual,
  another lane's scenarios ran alongside).
- MILESTONE 361448cb (NEXT 1 above, done this session): **under p55 the cops and the thug fall as
  their own 55 drawings** (cop_patrol/cop_riot/swat_fall_55 round 0300, thug_fall_55 round 0335, B,
  stretch 1.45 = the notes' factor, --back-from-away). grid_of falls back per row (a "p55" FALLS
  dict no longer drops the pedestrians' p70 fallback); test: p55 cop -> its own grid, p55 ped ->
  the p70 grid. FRICTION: `FALLS.get(art, {}).has(row)` is a parse error (Variant method call,
  warnings are errors); a typed local fixes it. tools/godot/check.mjs reports the known
  CutRig-cycle false FAIL on this file; GUT is the compile check (19/19).
  LOOKED the heavy board `--view=tilt` 64 px/m t65/t150, before = HEAD's file (p70 grids at p55
  height): after shows the faces/visors at 55 as the 55 standing cards do, the same blues as the
  55 cards; corpses lie along the blows. Masters: cops_riot_swat_p55_falls_before_after_tilt_64ppm_
  board_t65_t150.png (frames.json #6, replacing the it8 postfix still; its file kept).
NEXT (iteration 10), replacing the list above:
1. Film a boss fight under combo with cops/thugs dying at p55 (`--boss=king --view=combo` or
   `--view=tilt`): check the p55 grids in play, the thug's p55 card vs its p55 fall.
2. Contractor 55 (only under --view=tilt in quest 1): StreetQuestCards.DOWN "p55" from
   contractor_fall_55 (B) if quest 1 is ever judged at 55. Cultist / Torque falls wait for a spawn.
3. Crowd cost on a quiet machine (bench6/run.sh, 3 pairs) if the machine quiets.
4. Freeze prep (08:30): Windows export, REPORT calls (cop tone, crowd variety, walkers, drawn-fall
   FALL_AT / stretch / p55 height, cop back corpse, contractor corpse opaque + spread).
- GATE unit no-arg on 361448cb: 1516 passed, 0 failed, no FLAKY. GATE director reel under combo on
  361448cb (the it1 command, `--view=combo`): 19/19 chapters, every one all down, 0 SCRIPT ERROR
  (stopped after the 19th: my PID 33180 tree).
- LOOKED the Ohm beat under `--view=tilt` 48 px/m (p55 in play): the thug buckles and lies as its
  55 drawing; a shade darker steel than the 70 corpse, plates readable. Capture deleted.
- view ANSWERED my it8 REQUEST (n8-view JOURNAL l.916): RigSelect will keep a fresh on-screen corpse
  on its full rig (view it12). Street keeps (b): a baked dead row under a card view should draw the
  FALLS lying frame, not CrowdAtlas' bar: add as NEXT 2b.
- Scratch it9 emptied (the composites are in the masters).
- Session end 03:54: tree clean, every change committed. Commits it9: 9fa20822 (riot/SWAT falls +
  board --heavy), a376cbdb (thug fall), 72dde64b (contractor corpse), 361448cb (p55 cop/thug falls),
  + docs (JOURNAL, DECISION street/contractor-corpse).
NEXT 2b (iteration 10): CrowdAtlas' corpse cell under p70/p55 for a baked dead cop/ped: draw the
  FALLS lying frame (StreetWalkerFall's grid, frame 2 of the blow's facing) if CrowdAtlas lets a
  card view swap the cell; else REQUEST to view with the repro (city seed 5, actor 3000).
