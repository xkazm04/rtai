# JOURNAL - n8 lane `view` (branch n8-view)

## Iteration 3 (20:25-21:25) - first real session (iterations 1-2 died at start on billing)

Registry rules applied (game-production): `depth-ordered-layered-art` (one sort key per card,
per-pitch strips side by side), `sprite-and-atlas-production` (equal-frame strips, keyed by art
key not by pitch), `concept-scene-parity` / `motion-quality-gating` (judge on the real scenes in
motion, same seed before/after), `generative-artifact-gating` (A first, B with its named fix,
never C), `combat-pacing-and-dramatic-arc` (a telegraph commits its target when the wind-up
starts), `perf-regression-gating` (frame cost under the bench lock, CONTENDED otherwise).

- MILESTONE 20:50 item 1: the card sets are open to the lanes. `RigCardSets.all()` merges every
  `project/data/tables/card_sets/<lane>.json` (schema `gtai.card-set/1`,
  `data/schemas/card_set.schema.json`) over the base `RigCardSets.SETS`, files in name order, a
  later row replacing an earlier one. Lint's data-tables check maps the dir to the schema
  (`LANE_TABLE_DIRS`, the `arena_stations` precedent). Test: `test_rig_card_sets.gd`. Commit 8b006bae.

### To the other lanes (street, city, vehicles, hud)
Register head/bust card rows WITHOUT editing view files: add
`project/data/tables/card_sets/<your-lane>.json`:
```json
{
  "doc": "...",
  "lane": "street",
  "schema": "gtai.card-set/1",
  "sets": {
    "p70": {
      "ped/head_hair": {"anchor_y": 0.74, "bust": false, "raw": true, "strip": "res://features/characters/art/view/p70/ped_hair_card.png", "width": 2.0}
    }
  }
}
```
Keys are RigHeadCard keys (`<art_dir>` or `<art_dir>/<head part>`); `strip` "" keeps the base
strip and changes the rest; strips must split into RigHeadCard.FRAMES equal frames. Canonical JSON
(sorted keys, 2 spaces) or lint fails. Cherry-pick 8b006bae or merge n8-view to get it.

### REQUESTs
- REQUEST to assets: dent, 70, the ghost Dent (tan, as the p55 bust) at 70 degrees: five facings
  + the signature actions, the same proportions as `angle-r1/out/dent_55.png`; the combo view
  plays 70 in the city where Dent is on screen most.
- REQUEST to assets: ohm, 70, the ghost Ohm at 70 degrees, as `angle-r1/out/ohm_55.png`.
- REQUEST to assets: kerf, 70, Kerf v2 (the thin leaning card, 12 degree lean) at 70 degrees, as
  `angle-r1/out/kerf_55.png`.
- REQUEST to assets: king_car, 70, the throne-car at 70 degrees (five rotations), as
  `angle-r1/out/king_car_55.png`; only a 55 exists.
Meanwhile the 70 sets for Dent/Ohm/Kerf are built from the 55 drawings (the d8 p70 street-row way).

- MILESTONE 20:45 item 2: the owner's d8 values (commit d08768ea). `KerfRig.CARD_M` 0.8 -> 0.96
  (+20 %, lean kept); `KingArt.STRIPS["king"][2]` 1.5 -> 2.0; `KingCape.TRAIN_K` 1.0 -> 0.0.
  DECISION bust 2.0 over 1.75: at 32 px/m 2.0 reads as the boss at a glance and the stubby legs
  read stubby at every size, so the bigger bust costs nothing extra (Call for the owner, 1.75 one
  value away). The p70 court strip was padded for 1.5, so the 70 King grows by the same 2.0/1.5;
  `test_view_pitch_court` now states that (PAD_K). Evidence: `gtai-masters/n8/view/king_bust_abc_{32,64}ppm.png`,
  `king_bust_cape_before_after_64ppm.png`. Kerf +20 % NOT filmed yet.
- MILESTONE 20:55 item 3: the attack target freezes as the windup begins (commit e513d663).
  `bosses.json` top-level `aim_lock_at_windup: true` sets every attack's `lock` to its windup
  (BossSpec.from_table); false = the d8 lock. Applies to the King and Servo alike (every shipped
  attack). Test `test_boss_lock_at_windup.gd`: a step out 10 ticks into the windup dodges with the
  flag and is hit without it; every shipped attack locks at its windup. No replay golden moved:
  there is no boss scenario/golden (scenarios 52 ran; the only fail was rig_stress p50 1.041 ms,
  CONTENDED by my filming in parallel). Evidence: `king_ring_lock_before_after_combo_32ppm.mp4`
  (phase 3: at 7.0-7.5 s Rivet walks out of the frozen ring, the King lands on it empty),
  `king_ring_after_sequence_combo_32ppm.png`, `king_car_aim_lock_before_after_combo_32ppm.mp4`.
- FRICTION: the scenario suite read bosses.json while I flipped the flag for the before clip; it
  has no boss scenario so nothing was contaminated, but next time film the before from a worktree
  or a launch flag, never by editing a table under a running suite.
- FRICTION: Python on Windows writes CRLF by default; open(..., newline='') for every edit.

### Answers to REQUESTs (21:00)
- ANSWER to street (registration hook for the card rows): landed as data, not a second GDScript
  const: put your rows in `project/data/tables/card_sets/street.json` (shape above; `strip`,
  `anchor_y`, `width`, `bust`, `raw` per key). `RigHeadCard.rows_of(art)` reads
  `RigCardSets.all()`, which merges every card_sets file over `RigCardSets.SETS`, so your rows
  win for the keys they name; no view file to edit, no uncommitted patch. Merge n8-view (or
  cherry-pick 8b006bae). I leave the p55/p70 street rows in SETS; yours override. Tell me in your
  JOURNAL when your file is in and I drop the duplicates from SETS.
- ANSWER to city (building occlusion): `PropOcclusion` is the arena's (it redraws ArenaFloorView's
  props); it does not take an outside provider tonight. DECISION: the city draws its own cue
  over its roofs, from your `ChunkLift.occluder_at()` query, using the SAME look: read
  `PropOcclusion.SILHOUETTE`, `PropOcclusion.RIM`, `PropOcclusion.SIL_W_M` and `PropOcclusion.FRONT_DZ`
  (public consts; do not copy the numbers), so a hidden body reads identically behind a wall and
  behind a tenement. If you need a shared helper (the silhouette polygon from a rig), REQUEST it
  and I will lift it out of PropOcclusion into a static func you can call.
- MILESTONE 21:03 Kerf +20 % evidenced: `gtai-masters/n8/view/kerf_card_before_after_tilt_48ppm.png`.
  Found: at `--view=tilt70` Kerf (and every ghost without a p70 strip) draws the TOP-DOWN rig
  (hull + cables), not a card: GhostCard has no `art/view/p70/kerf_card.png`. That is item 5's
  first job: build p70 ghost strips from the 55 drawings now (the d8 p70 street-row way).
- Gates at d08768ea+e513d663: lint 15/15; unit 1489 passed / 0 failed (full no-arg run);
  scenarios 52 ran, 1 failed = rig_stress p50 1.041 ms > 1 ms CONTENDED (my filming ran alongside;
  re-run alone owed).
- MILESTONE 21:02 item 5 (part): `ViewMode.art_pitch()` (the art key's pitch, `p55` -> 55; a row
  without a key falls back to the live pitch, so `tilt_basecards` and `top` are unchanged).
  KingArt, KingAccents and KingCarWalls ask it instead of `roundi(pitch_deg)`, so under combo the
  court strip, the King's limb parts and the car walls swap with the card key and never fall back
  to the shared card + drawn cape fan mid-ease (answers view70's open REQUEST). Commit 504403a2.
  Tests: `test_view_art_pitch.gd`; `test_king_art` re-dress test now drives the art key.
  Evidence OWED: the King-down return under combo. The windup lock changes every King fight, so
  seed 2 phase 3 no longer has the King down by frame 1200 (d8's reference frames 1150-1186);
  film to the defeat (try `--quit-after 2400`) or find the frame from the log's defeat tick.
- rig_stress re-run alone: p50 0.984 ms < 1 ms, PASS (the earlier miss was contention).

NEXT (iteration 4, in brief order):
1. Item 4, Rivet's death beat (sim timing, not art). Plan: a `RivetDeathBeat` (features/player,
   RefCounted, BEAT_TICKS = 60 from data, e.g. combat.json `death_beat_s` 1.0 with schema) used by
   `CollectCallStage._respawn` and `ArenaStage._respawn`: on death count ticks, respawn when the
   beat ends. While the beat runs: ignore the intent (no move/fire/ghost), hostiles keep their
   step but deal no damage to a dead Rivet (check `arena.rivet.alive()` callers), the rig plays
   `RigClips.die(false)` (rig_input feeds the clip from the sim: find where Rivet's die clip is
   fed), and the view fades to the print's ink over the last ~0.4 s (a CanvasLayer ColorRect on
   the stage view, render only). Re-bless what moves: run scenarios, the 60 s replay, the director
   reel (19/19, 0 SCRIPT ERROR) in top and tilt70. Film quest 1 and the dev arena death.
2. Item 5: p70 ghost card strips for Dent, Ohm, Kerf from the 55 drawings (until assets serves
   the REQUESTs); at tilt70 the ghosts still draw their top-down rigs. Servo 70 exists
   (`angle-r1/out/servo_70.png`); Tonnage 70 exists. Then the King-down return evidence (above),
   Tonnage's swap and a ghost on screen at the boss-down moment under combo.
3. Items 6-8: camera at 70 (city on foot + car, boss zoom-in, quest 1), Tonnage's legs in the
   depth sort, the King's accents in the order probe, frame cost combo vs top under bench.lock.
4. Read the lane journals again: street (card_sets JSON answer given), city (occlusion answer
   given); answer any new REQUEST.
5. Before calling the night done: the director reel 19/19 in top and combo; evidence run --no-bench.

### Calls for the owner (draft, for REPORT)
- The King's bust size: built 2.0x (`KingArt.STRIPS["king"][2]`); option 1.75x (one value).
  See `gtai-masters/n8/view/king_bust_abc_32ppm.png` / `_64ppm.png`; exe
  `RTAI.exe -- --rigs --boss=king --phase=3 --view=combo` (add `--ppm=64` for close range).
- The attack lock: built "frozen at the windup start" for every boss attack (`bosses.json`
  `aim_lock_at_windup` true); option false = d8's late lock. Note it makes every King/Servo attack
  easier to dodge (the whole windup is reaction time); if the fights get too easy, the next lever is
  a shorter windup, not a later lock. See `king_ring_lock_before_after_combo_32ppm.mp4`.
- MILESTONE 21:18 combat does not regress: director reel (headless, `--quit-after 14000
  --bot=reel --reel=director --loadout=pistol --rigs`) 19/19 chapters, every chapter all down,
  0 SCRIPT ERROR, in `top` and in `combo` (at 504403a2). Logs: `evidence/n8-view/director-reel-it3-{top,combo}.log`,
  `unit-it3.log` (1489/0, at e513d663), `rig-stress-alone-it3.log`.

## Iteration 4 (21:20-22:20)
Read: JOURNAL, git log, the lane journals (no new REQUEST to view; street withdrew its hook
REQUEST, city's occlusion answer stands), the library catalog: assets SERVED dent/ohm/kerf/king_car
at 70 (round 20261106-2150; kerf re-done 2151 grade A, ohm A, dent B fixed tan, king_car B).
Registry rules applied: combat-pacing (a death needs a readable beat before the cut, the cut
hidden in the dark), motion-quality-gating (judged frame by frame, luminance per frame measured),
generative-artifact-gating (Ohm 70 sheet's all-teal body is a colour-law fault; fixed by tone).

- MILESTONE 21:52 item 4, Rivet's death beat (commits d422334f, 9a8eb3ac). `DeathBeat`
  (features/player) holds the respawn `combat.json rivet.death_beat_s` = 1 s (60 ticks): the
  quest stage and the arena's `_respawn` ask `death_beat.holding(alive)`; a dead Rivet's intent is
  cleared in `_move` (no walk, hide, interact, fire); the rigs play the sprawl from the DEAD flag
  (ArenaRigs already fed it; it never showed because the respawn came the same tick). `DeathVeil`
  (boot/collect_call/view, under the HUD) inks the frame over the last 0.4 s and lifts it 0.3 s
  after. BossHook: the boss keeps stepping over the corpse but deals no hit (it froze before:
  read as a hang). `WaveDirector.ordinal` took `_wave_number` out of the stage (size budget);
  debt baseline +1 line on collect_call_view accepted (stage -4).
  Gates: lint 15/15; unit 1497/0 (full no-arg, at d422334f); scenarios 52 ran / 0 failed (no golden
  moved: no scenario kills Rivet); director reel `top` 19/19 down, 0 SCRIPT ERROR (at 9a8eb3ac).
  Evidence: `gtai-masters/n8/view/death_beat_before_after_combo_32ppm.mp4` (seed 2, King phase 3,
  no bot: Rivet dies at tick 1728; before = the instant cut to the hub, after = the King over the
  sprawl, then ink), `death_beat_after_sequence_combo_32ppm.png`. Frame luminance through the
  cut: 110 -> 22 (ink) -> 128 (the hub) over 0.7 s.
  NOT covered: release builds without `--rigs` draw Rivet as quest 1's sprite, which has no
  death pose: there the beat is a standing Rivet under the veil (Rivet's art is frozen tonight).
- FRICTION: a ColorRect under a CanvasLayer with only `set_anchors_preset(FULL_RECT)` stayed
  0 x 0; size it from `get_viewport_rect()` (found by logging the veil, not by the film).
- MILESTONE 22:10 item 5 (part): Ohm's p70 card from the served `ohm_70` (A): top row cut by
  ghost_bust.py, hue guard, then ghost_card_tone.py against the game's p55 ohm_card (the served
  sheet is all teal; the game's Ohm is steel, teal only in the wisps). Strip comparison:
  scratch `ohm_55_70_strips.png`. Installed as `souls/art/view/p70/ohm_card.png`.
- MILESTONE 22:14 combat does not regress with the death beat: director reel (headless,
  `--quit-after 14000 --bot=reel --reel=director --loadout=pistol --rigs`) 19/19 chapters all down,
  0 SCRIPT ERROR, in `top` and `combo` (at 9a8eb3ac). Logs `evidence/n8-view/director-reel-it4-{top,combo}.log`,
  `unit-it4.log`, `scenarios-it4.log`.

### Calls for the owner (add to REPORT)
- The death beat's length: built 1.0 s (`combat.json rivet.death_beat_s`), ink over the last 0.4 s.
  Options: 0.7 s (snappier) or 1.5 s (a longer look at the sprawl); one value. See
  `gtai-masters/n8/view/death_beat_before_after_combo_32ppm.mp4`; exe
  `RTAI.exe res://dev/arena/arena.tscn -- --rigs --boss=king --phase=3 --seed=2 --view=combo` and stand still.

NEXT (iteration 5, in brief order):
1. Ohm p70 card: film it in game at `--view=tilt70` and `combo` (32 + 64 px/m), before/after
   (before = the top-down rig at tilt70); check its size against Ohm p55 (GhostCard width).
2. Kerf p70 from `library/rounds/20261106-2151/out/kerf_70.png` (A): crop the top row, cut with
   ghost_bust.py (cell 256 like p55), hue guard; the sheet is teal but the game's p55 Kerf v2 is
   game-palette steel with amber shoulders: tone it against the p55 kerf_card (ghost_card_tone.py,
   check the hue window keeps the cyan blade edges) and compare side by side before installing.
3. Dent p70 bust from `library/keyed/street/dent_70.png` (B, fixed tan in keyed/): Dent is a
   RigHeadCard bust (characters/art/view/p55/dent_bust_card.png): add `p70/dent_bust_card.png` and
   its row in `RigCardSets.SETS` p70 (my file). Servo 70 from angle-r1/out/servo_70.png.
4. king_car 70 (B) served: tell `vehicles`? No: the throne-car is the boss cast (mine); read its
   notes and plan the slice-stack swap by art key.
5. Then the King-down return under combo, Tonnage's swap with a ghost on screen; items 6-8.
6. Death beat close-up at `--ppm=64` (not filmed: the 32 px/m clip and a 2x crop only).

## Iteration 5 (22:03-23:03)
Read: JOURNAL, git log, the four lane journals (no new REQUEST to view; street's card_sets file,
city's occlusion answer and vehicles' notes stand), the catalog rows for kerf/dent at 70.
Registry rules applied: generative-artifact-gating (the served 70 sheets draw the ghosts all teal:
a colour-law fault, fixed by tone; the hue window widened for Kerf after the first pass left teal
mid-tones, then narrowed back for Dent whose wisps sit in that window), concept-scene-parity (each
card judged in the arena next to its p55 twin and the before), depth-ordered-layered-art (the bust
stands on the legs' anchor at 70, width set over the wider 70 cell).

- MILESTONE 22:08 Kerf p70 card (commit 90444ddc) from library kerf_70 (A, round 20261106-2151):
  top row cut (ghost_bust.py, 256 px cell like p55), hue guard, tone to the p55 card's steel with
  hue window 135-190 (the default 135-175 left the 160-190 teal mid-tones; the cyan blades sit
  above 190 and stay). The p55 card's amber shoulder rings are not on the 70 sheet (not added).
  Evidence: `gtai-masters/n8/view/ghosts70_ohm_kerf_before_after_tilt70_32ppm.png` (before: the
  top-down hull + cables at tilt70; after: the 70 card) and `ghosts70_ohm_kerf_closeup_tilt70_64ppm.png`
  (Ohm's p70 card from it4 filmed in game here for the first time).
- MILESTONE 22:12 Dent p70 bust (commit 375fba7b) from library dent_70 (B; its named fix "tan, not
  teal" applied by our own tone route from the teal original): cropped at the belt (y 298) into a
  bust like p55, toned to the p55 bust's tan (default hue window: Dent's wisps are 175-190),
  RigCardSets p70 row `dent` (anchor 0.72, width 2.1 = p55's 1.75 over the 189/154 wider cell).
  Evidence `dent70_before_after_tilt70_32_64ppm.png` (before at tilt70: the top-down crash dummy
  flat; after: the bust stands over his legs). The 70 bust prints a little darker than p55
  (the 70 sheet is shaded deeper); reads at 32 px/m by the target discs.
- MILESTONE 22:30 Servo under combo (commit 89cac319). FOUND on screen: under `combo` Servo drew
  today's top-down tan parts all fight (ServoRig loaded its parts once in `_ready`, by the rounded
  LIVE pitch 70, which has no p70 parts), while `tilt` draws the ochre p55 boss palette. Fix:
  ServoArt keyed by `ViewMode.art_pitch()`, a row with art but no part for its pitch falls back to
  p55 (`ServoArt.FALLBACK_PITCH`; lab rows without art keep d8's lookup, `top` unchanged), and
  `ServoParts` (new) reloads the rig's and the air layer's textures when the art key changes.
  servo_rig.gd 288 -> 287 (the debt ratchet caught the first version at 300).
  Evidence `servo_combo_art_key_before_after_32ppm.png` (tilt d8 | combo before | combo after /
  tilt70 before | after). Tests: test_servo_art (+3: fallback, key not live pitch, reload).
  Note: no Servo p70 PART sheet exists (angle-r1 servo_70.png is an angle sheet; the parts are top
  views), so p70 = the p55 parts; Servo is only on screen at 70 under tilt70 or mid-ease.
- GATES at 89cac319: unit 1500 passed / 0 failed (full no-arg, `evidence/n8-view/unit-it5.log`);
  scenarios 52 ran / 0 failed (`scenarios-it5.log`; no golden moved: `top` unchanged); lint 15/15.
- MILESTONE 22:27 the King-down return under combo with a ghost on screen (brief item 5, owed since
  it3). `--boss=king --phase=3 --bot=boss --ghost=ohm --seed=2 --view=combo`: the King falls at
  tick ~422, the ease back starts there, the cards swap to p70 at tick 452 (pitch 62.5): the King's
  p55 bust -> p70 strip and Ohm's p55 -> p70 card in the same tick, and no drawn cape fan mid-ease
  (the art_pitch fix of it3, now seen). `gtai-masters/n8/view/king_down_return_ohm_combo_32ppm.mp4`,
  `_closeup_x2.mp4`, `king_down_ohm_swap_p55_p70_combo_crop.png` (ticks 440/452/470).
  With `--ghost=tonnage` the bot never had Tonnage on screen at the defeat (tick ~1160): the
  Tonnage cross-fade under combo is still NOT seen live.
  NOTE: at the swap the King's size jumps (the p55 bust at 2.0x reads larger than the p70 down pose);
  judged acceptable for a hard swap the owner chose, but watch it in the next combo clip.
- MILESTONE 22:30 item 6 (part): the camera at 70 in the city. Drive (`dev/bench/city_bench.tscn
  --scenario=drive --zoom=1.0`, 15 s) and on foot (`--arena=city --bot=rivet --seed=7`), top | tilt70
  side by side: `city_drive_top_vs_tilt70_32ppm.mp4`, `city_foot_top_vs_tilt70_32ppm.mp4` (+ stills).
  The framing holds: the car and Rivet stay centred; at 70 the view shows ~6 % more ground along y
  (1/sin 70), no extra lead ahead of the car at speed (the camera lead at driving speed stays a
  Call for the owner). Not filmed yet: the boss camera's zoom-in under combo at 64 px/m, quest 1.
- frames.json (masters) rewritten: 15 entries, best first.
- MILESTONE 22:33 item 8 (part): frame cost combo vs top on the in-car drive, under bench.lock (held
  by me, NOT contended), release export `windows-bench` (debug_build false), `drive_dense` at
  zoom 1.5 (48 px/m), 30 s x 2 runs per view, alternated. `evidence/n8-view/bench-it5/drive48_*.json`.
  | metric | top r1 / r2 | combo r1 / r2 |
  | renderCpuMsAvg | 0.300 / 0.399 | 0.346 / 0.356 |
  | drawCallsAvg | 252.0 / 252.3 | 254.1 / 254.7 |
  | rigMsP50 | 0.439 / 0.544 | 0.582 / 0.565 |
  | rigMsP99 | 1.107 / 1.330 | 1.187 / 1.251 |
  | visibleAvg | 9.8 / 9.8 | 10.9 / 10.7 |
  | p99CpuMs / low1Fps | 32.6 / 30.0, 32.9 / 24.4 | 19.5 / 50.5, 31.2 / 31.4 |
  Reading: combo costs ~+1 % draw calls and ~+0.05-0.1 ms rig time per frame (one more visible
  actor at 70: the view covers more ground); render CPU within run noise. The p99 / low-1 % rows are
  the known vsync-off present stalls (~32 ms trios, bench run.mjs note), present in BOTH views, not a
  view cost. NOT measured: the King fight (the bench export runs the city only; needs an arena bench).
- MILESTONE 22:40 item 7 (part): `--order-probe` counts the King's accents (commit e1c4d9b9). Under
  the card views KingAccents draws only the press tell's raised plates, the decree's buff rings,
  the shout and the falling crown at OVER_RIG_Z (the cards wear crown, ermine and chains). The
  plates rise to 5.5 m, so drawing them over a body is right once they clear BODY_H_M; the probe
  counts a plate still below body height beside the King against a rig south of him.
  MEASURED (seed 2, 3000 ticks, `evidence/n8-view/order-probe-it5/`): phases 1-3 under combo, with
  and without `--bot-stand`, phases 2-3 under tilt: accent pairs 0 in every run = UNMEASURED (the
  plates clear head height within the windup's first third; no rig stood that close south).
  FOUND: phase 3 car pairs wrong 10/10 (combo) and 12/12 (tilt), every other phase 0 wrong
  (phase 1: 993 pairs 0 wrong). Hypothesis: in phase 3 the wreck is drawn by KingCarStack /
  KingCarWalls, not at the KingBodyView rank the probe reads (a probe artifact), OR the wreck
  really draws over a Rivet south of it. Check with a still at a car-pair tick next iteration.
  Tonnage's legs: RigDepthSort._with_cards already moves the card's HOST z (legs and all) to the
  card's level (comment and code agree); re-measure Tonnage with the ghost reel's probe to close it.

NEXT (iteration 6, in brief order):
1. The phase-3 car pairs 10/10 wrong: film a still at a car-pair tick (log the tick from the probe:
   add the tick of the first car_wrong to the summary), decide artifact vs real, fix the side
   that is wrong (KingCarStack z vs RigDepthSort under a tilt).
2. Item 7 close: `--bot=ghosts --ghost=tonnage --order-probe` at tilt and combo (ghost wrong vs
   d8's 3/26); the accent pairs need a scripted stand south of the King in a press windup (a
   `--bot-stand` start position) or stay reported as unmeasured.
3. Item 6 rest: the boss camera's zoom-in under combo at 64 px/m (`--boss-cam --ppm=64`), quest 1
   (`collect-call`) scenes at tilt70; film each.
4. Item 5 rest: the Tonnage cross-fade under combo seen live (a seeded fight where the bot holds
   Tonnage on screen at the defeat: try `--ghost=tonnage` with `--phase=3 --seed=` 3..6, read the
   defeat tick from the log first, headless).
5. Item 8 rest: the King fight frame cost combo vs top (no arena in the bench export: a windowed
   editor run of the arena with the bench's frame metrics, labelled as such) under bench.lock.
6. Weakest item to raise: Dent's p70 bust prints darker than p55 (lift the tone's low quantiles);
   Kerf p70 lacks the p55's amber shoulder rings.
7. Before the freeze: director reel 19/19 top + combo, evidence run --no-bench, export the exe,
   REPORT with the Calls (King bust size, death beat length, attack lock, camera lead at speed).
- 22:46 the phase-3 car pairs: the probe now logs the first wrong car pair's tick (60; all 10 at
  ticks 60-114). Stills at ticks 72 and 102 (64 px/m, combo,
  `evidence/n8-view/order-probe-it5/phase3_car_wrong_ticks_72_102_combo_64ppm.png`): NO car on
  screen near Rivet. A `--phase=3` start draws no wreck there while `KingMoves.car_at` is set, so the
  10/10 is a PROBE ARTIFACT (it pairs Rivet with an undrawn car), not a draw fault. Fix for the
  probe next: skip the car when the wreck is not drawn (read the wreck's visibility from KingBodyView).
  NEXT item 1 above is answered; keep the probe fix as a small item.
- 22:50 item 6 (part): the boss camera under combo at close range (`--boss=king --phase=2 --bot=boss
  --bot-human --seed=2 --boss-cam`, tick 600): `gtai-masters/n8/view/boss_cam_combo_32_64_vs_tilt64_king_p2.png`
  (combo 32 | combo 64 | tilt 64). combo and tilt frame identically once engaged (55 both). FOUND at
  64 px/m: the frame holds the King's GROUND point, so his raised bust (2.0x, on the car) rises into
  the HP bar, and Rivet ~10 m to the right is OFF SCREEN (20 x 12.5 m of view). At 32 both fit.
  Fix to try next: under a tilt frame the midpoint of Rivet and the boss's LIFTED top
  (ViewMode.lift_px of the boss's drawn height), and cap the boss-cam zoom so both stay in. A
  Call candidate: "boss camera at close range: keep Rivet in frame (built) vs the boss's close-up".
  This goes to the top of NEXT (a combat-readability fault under combo at 48-64 px/m).
- CORRECTION 22:53: `BossCam` is the DEV clip camera (`--boss-cam`, features/bosses/boss_cam.gd);
  the shipped game follows Rivet. So the 64 px/m finding above hurts our close-range FILMS, not the
  player. Its keep_in keeps BOSS_MARGIN_M round the boss's ground centre: under a tilt add the
  boss's lifted height (ViewMode.lift_px) to the top margin, and at 64 px/m FRAME_K 0.45 leaves Rivet
  out past ~9 m. Lower priority than the NEXT list's items 2-5; do it before filming close-ups.
- 22:53 cleaned: scratch renders kept only where frames.json or JOURNAL point; raw AVIs deleted.
  Session ends here (23:03 stop). Head at the JOURNAL commit; lint 15/15; unit 1500/0 and
  scenarios 52/0 on 89cac319 (code after it: the dev probe only).

## Iteration 6 (22:54-23:54)
Read: JOURNAL, git log, the other journals. New REQUEST to view from city (it7): the arena's cover
as city's standing prop cards (`PropCards.named().draw_named`). street / vehicles / hud: none.
- ANSWERED city (commits c1a0e777, 7cfd96d7): `ArenaPropCards` (features/arena, mine) is called from
  `ArenaFloorView._prop` under a tilt card view (not top_lift, not top): cone -> traffic_cone,
  cover_high -> dumpster, cover_low -> crate_stack (one stack sized to the row's width on an
  east-west row; one per square cell down a north-south row). PropCards is looked up BY PATH
  (`res://features/city/view/prop_cards.gd`), so my branch compiles without city and draws today's
  face until the Director merges n8-city; walls stay architecture. PropOcclusion redraws through
  `_prop`, so the cards are redrawn over a body behind them for free.
  VERIFIED on a throwaway merge (scratch worktree, my HEAD + n8-city, never committed):
  `--bot=course --rigs --view=tilt70 --seed=2`, frame 150, 0 SCRIPT ERROR:
  `gtai-masters/n8/view/arena_cover_cards_before_after_tilt70_32ppm.png` (before: lifted face +
  flat crates | first cut: three crate_stack cards per row, 1.8x wider than the cover the player
  collides with | built: one stack spanning the row). DECISION: the stack fits the collision box
  (readability of cover beats a chunkier cargo pile); the alternative is the per-cell loop.
- MILESTONE 23:13 item 5 close: the Tonnage swap under combo SEEN LIVE (owed since it3). New dev
  flag `--ghost-at=<tick>` (commit 5a5ef6e6; BossBotGhost holds the soul until that tick; default
  0 = today): the 8 s form was over long before the defeat at ~1160. `--boss=king --phase=3
  --bot=boss --ghost=tonnage --ghost-at=700 --seed=2 --view=combo --rigs`: Tonnage's slam speeds
  the kill (defeat tick 948, ease back from 948, cards p70 at tick 978), Tonnage in form through
  both. Same ticks headless and windowed. Evidence: `tonnage_king_down_swap_combo_32ppm.mp4`,
  `_64ppm.mp4`, `tonnage_king_swap_ticks970-1004_combo_64ppm.png`. Judged: the King swaps hard at
  978 (bust -> p70 strip); Tonnage's back card p55 -> p70 is near seamless (the two strips are the
  same press drawing); the larger change at ~990 is Tonnage TURNING (back -> three-quarter away), not
  the swap. No double draw, 0 SCRIPT ERROR.
- MILESTONE 23:28 item 7 close for Tonnage's legs: `--bot=ghosts --ghost=tonnage --order-probe
  --seed=2`, 2400 ticks (`evidence/n8-view/order-probe-it6/`): tilt70 0/9 ghost pairs wrong, combo
  (no boss: 70) 0/9, tilt 3/26 (d8's count, unchanged). The probe now logs each wrong pair (commit
  cf6bed71): ticks 360/366/372, a cop 0.7-1.0 m NORTH of the press with dz 0 (a tie the probe calls
  wrong because its rule wants the north rig a full part span under). Filmed at 64 px/m
  (`tonnage_order_probe_ticks354-372_tilt_64ppm.png`): the press draws over the cops north of it,
  as it should (tree order resolves the tie right). Verdict: not a draw fault; the legs follow the
  card's host z (RigDepthSort._with_cards). Not changing the sort for a tie that draws right.
- frames.json: 15 (Tonnage swap clip at 5th, arena cover cards at 9th; dropped the King swap crop
  and the Kerf/Ohm close-up, both still on disk and in JOURNAL).
- Registry rules applied this iteration: depth-ordered-layered-art (the cover card's foot on the
  prop's south edge, drawn in the floor's prop pass so PropOcclusion's redraw keeps it in front of
  bodies north of it; the dz-0 tie judged on film, not by the probe's count), concept-scene-parity
  (the cover card judged in the arena at 32 px/m against the face it replaces and against its
  collision box), sprite-and-atlas-production (the stack sized from city's own cell_w_m, not a
  guessed scale), motion-quality-gating (the swap judged frame by frame at 64 px/m; a turn told
  apart from a swap), combat-pacing-and-dramatic-arc (cover must read at its real size: the
  player's cover decisions follow the drawn size).
- GATES at cf6bed71: lint 15/15; unit full no-arg 1504 passed / 0 failed, 0 FLAKY
  (`evidence/n8-view/unit-it6.log`); scenarios: see the line below.

NEXT (iteration 7, in brief order):
1. The boss-cam (dev clip camera) at 64 px/m under a tilt: add the boss's lifted height to its top
   margin and cap the zoom so Rivet stays in (it5 finding); then re-film the King close-ups.
2. Quest 1 (`collect-call`) at tilt70: city found its stage (boot/collect_call/view/stage_view.gd)
   does not read ViewMode at all (flat at Ink's 48 px/m); grep confirms nothing under boot/ reads
   ViewMode, but the quest shares CollectCallView and CutRig with the arena, so its rigs may tilt
   over a flat floor. Film it at tilt70 (`--view=tilt70` on the quest launch) to see, and decide:
   bring the stage under the view (cards for Rivet + cast via the arena's rig path) or a Call.
3. Item 8 rest: the King fight frame cost combo vs top (a windowed arena run with frame metrics,
   labelled, under bench.lock), and a release-export number if the bench export can load an arena.
4. Weakest art: Dent's p70 bust prints darker than p55 (lift the tone's low quantiles); Kerf p70
   lacks the p55 amber shoulder rings.
5. The order probe: skip a car pair when the wreck is not drawn (phase-3 artifact, it5); the accent
   pairs stay unmeasured until a scripted stand south of the King.
6. Before the freeze: director reel 19/19 top + combo, evidence run --no-bench, export the exe,
   REPORT with the Calls (King bust size, death beat length, attack lock, camera lead at speed,
   cover as a stack sized to the collision box).
- CORRECTION 23:42 to it5's "phase-3 car pairs are a probe artifact": KingBodyView._wreck draws
  the stalled car under the SAME condition the probe pairs on (phase >= 2 and KingMoves.car_at
  set), so the wreck should be drawn at those ticks. Either the stills at 72/102 framed it out,
  or the card views draw the wreck's stack/roof invisibly. Re-check with a 64 px/m still centred
  on km.car_at (NEXT 5) before calling it an artifact; the it5 verdict is withdrawn until then.
  23:39 first re-check: `--boss=king --phase=3 --bot=boss --seed=2 --view=combo --rigs --order-probe`
  windowed, 130 ticks: car pairs 0 (it5's 10 pairs came with another flag set, likely
  `--bot-stand`), and neither the King nor a wreck is in Rivet's frame for those 130 ticks. Repeat
  it5's exact command (from `evidence/n8-view/order-probe-it5/`) with a still at its first wrong tick.
- GATE scenarios at cf6bed71 (`evidence/n8-view/scenarios-it6.log`): 52 ran, 1 failed: city_chase's
  2 ms WALL-CLOCK nav budget (max 2571 us) while my Godot films ran beside it (contended, not a
  code fault: no city/nav code touched this iteration). Re-run alone through
  `tools/tests/run_scenarios.mjs --only=city_chase`: 1 passed (`scenarios-it6-city_chase-alone.log`).
  0 SCRIPT ERROR; no golden moved (`top` unchanged: every change this iteration is behind a tilt
  card view or a dev flag).

## Iteration 7 (23:45-00:45)
Read: JOURNAL, git log, the other lanes' journals: no new REQUEST to view (street, vehicles, city,
hud; city's occlusion and arena-cover REQUESTs answered in it2/it6).
- MILESTONE 23:55 NEXT 1, the boss clip camera (`--boss-cam`, dev) under a tilt (commit a73a900f):
  `BossCam.hold_top` keeps the boss's LIFTED top (BOSS_TOP_M 4 m, `ViewMode.lift_px`) TOP_MARGIN_M
  1 m under the boss bar, after the ground point's bottom margin; and Rivet is kept in with 1.5 m
  (`keep_in` on Rivet first, then the boss's margins win). Straight down the lift is 0: today's frame.
  FRICTION: the first cut kept BOSS_MARGIN_M (3 m) over the lifted top: at 64 px/m 3 + 2.8 + 3 m plus
  the bar and ghost-card bands do not fit 12.5 m of screen, so it fell back and moved nothing; 1 m
  over the crown fits. Evidence (seed 2, phase 2, tick 600, combo):
  `gtai-masters/n8/view/boss_cam_lifted_top_before_after_combo_64ppm.png` (crown under the bar ->
  crown clear) and `boss_cam_rivet_and_king_combo_48ppm.png` (the King whole and Rivet with the gang
  both in at 48). At 64 px/m Rivet ~13+ m sideways still cannot fit a 20 m screen: the boss wins.
  Not capping the zoom (a close-up film asks for its ppm). Unit test `test_hold_top_*` (6/6).
- MILESTONE 00:05 NEXT 2, quest 1 (`collect-call`) at tilt70 (commit 43ff9ef1: `--view` on
  dev/frames/quest1_clip.gd). Stills at ticks 600 (Line Stopped) and 13700 (Dock 9), 32 px/m:
  `quest1_tick600_top_vs_tilt70_32ppm.png`, `quest1_tick13700_top_vs_tilt70_32ppm.png`,
  `quest1_dock9_tilt70_rigs_48ppm.png`, `quest1_dock9_tilt70_sprites_vs_rigs_32ppm.png`. 0 SCRIPT ERROR.
  FOUND: quest 1 DOES follow the view (CollectCallView's print stage takes the tilt: ground
  foreshortened, the street crowd and lamps lifted, cast shadows). With `--rigs` the fighters stand on
  the rigs with Rivet's card (judged: reads as the arena does). WITHOUT `--rigs` (the shipped slice:
  `Quest1Game._dev_rigs` is debug-only, the rig cast is `dev/arena/arena_rigs.gd`, dropped by a
  release export) Rivet and the cops are FLAT top-down sprites on the tilted ground, beside a lifted
  crowd. So under combo the release exe draws quest 1's cast flat. Fix (larger than this session):
  move the rig cast (ArenaRigs' attach path) out of dev/ into features/ and pick it in Quest1Game when
  `ViewMode.shared().cards` is true; `top` keeps the sprite cast (goldens). A Call for the owner:
  quest 1's cast under the angled view, sprites (today's ship) vs the rig cast (the dev path, filmed).
- MILESTONE 00:15 quest 1 ships the rig cast under a card view (commit ebd77c13, DECISION in
  docs/decisions.md): `Quest1Game._dev_rigs` takes the rig cast when `RIGS_UNDER_CARDS and
  ViewMode.shared().cards` (combo, tilt70, tilt), or on `--rigs` in a debug build as before; `top`
  keeps the sprite cast + StoryForms (no golden, replay or parity input moves). `ArenaRigs` and
  `ArenaRobotRigs` moved dev/arena -> features/arena (git mv, class names kept) so a release export
  carries them; the 2026-11-04 decision rejected the move only for night-lane merge conflicts, and
  `git diff main...n8-<lane>` shows no n8 lane touches either file. release_compile: 558 loaded, 0
  failed. Targeted unit (slice closure, arena rigs, flamer sway, boss cam) 18/0. Debt: dev_loc
  -392 (the move), files_near_cap/cmdline reads re-keyed to the new paths, quest1_game +1 line
  (accepted with a reason). Evidence: `gtai-masters/n8/view/quest1_dock9_shipped_before_after_tilt70_32ppm.png`
  (left: flat sprites, right: the same release path now on the rigs, Rivet's card, cops lifted with
  shadows; log "quest1: cast rigs: true" with no --rigs), 0 SCRIPT ERROR. frames.json: added at 3rd,
  dropped city_foot (still on disk).
  Owner Call (REPORT): quest 1's cast under the angled view, rig cast (built) vs sprites
  (`RIGS_UNDER_CARDS` false). The rig cast's Rivet is today's frozen Rivet; it changes with the
  owner's whole-figure Rivet.
- Registry rules applied it7: concept-scene-parity (quest 1 judged on its real scene, the shipped
  path, not the dev flag the lane filmed before), depth-ordered-layered-art (the boss's drawn top is
  his lifted height, not his ground point), motion-quality-gating (stills at the same tick and seed,
  before/after differ only in the change), perf-regression-gating (not measured this iteration: the
  quest's rig cast vs sprites frame cost is UNMEASURED, owed).
- GATE unit full no-arg at ebd77c13: 1505 passed / 0 failed, 0 FLAKY (`evidence/n8-view/unit-it7.log`).

NEXT (iteration 8, in brief order):
1. Quest 1 under combo/tilt70 on the rig cast: film the opening and the Dock 9 fight as a CLIP
   (quest1_clip.gd without --stills, `--view=tilt70`, then `--view=combo`) and judge in motion;
   measure its frame cost vs the sprite cast (perf-regression-gating: UNMEASURED now). Check the
   ghost forms/voices: the rig cast brings GhostFormView instead of StoryForms; confirm the voice
   lines and form HUD still show under tilt70 (the dialogue box did show in the still).
2. Item 8 rest: the King fight frame cost combo vs top under bench.lock, release export.
3. Weakest art: Dent's p70 bust darker than p55; Kerf p70 lacks the amber shoulder rings.
4. The order probe's phase-3 car pairs: repeat it5's exact command, still at the first wrong tick.
5. Before the freeze: director reel 19/19 top + combo, evidence run --no-bench, export the exe,
   REPORT with the Calls (King bust size, death beat length, attack lock, camera lead at speed,
   cover as a stack, quest 1's cast under the angled view: rigs (built) vs sprites).
  NEXT 1 note (code read, 00:24): StoryForms on the sprite path gives the ghost form view with its
  story voice bound (GhostFormView.events), the subtitle camera lift (zero at 32 px/m) and the form
  card's fold under the subtitle box. The rig path attaches its own GhostFormView (events bound by
  default, so the voice should play) but no subtitle lift and no card fold: judge both on the clip.
- GATE scenarios at ebd77c13 (`evidence/n8-view/scenarios-it7.log`): 52 passed, 0 SCRIPT ERROR, no
  CONTENDED (run alone); no golden or replay moved (`top` keeps the sprite cast).
- GATE 00:35 combat does not regress after the rig-cast move: director reel (headless, `--quit-after
  14000 --bot=reel --reel=director --loadout=pistol --rigs --view=<v>`) 19/19 chapters, every chapter
  all down, 0 SCRIPT ERROR, in `top` and `combo` at ce7b4b87 (`evidence/n8-view/director-reel-it7-{top,combo}.log`).
  Session ends here (00:45 stop). Head clean; lint 15/15; unit 1505/0; scenarios 52/0; reels 19/19.
  Scratch stills deleted (copies in gtai-masters/n8/view). NEXT stands as written above.

## Iteration 8 (00:37-01:37)
Read: JOURNAL, git log, the other lanes' journals. No new REQUEST to view (street's withdrawn,
city's two answered it2/it6). hud's FINDING (n8-hud JOURNAL l.244): under `--rigs` quest 1's
ghost-form card never folds under a subtitle line (StoryForms is null on the rig path). Since
ebd77c13 the rig cast IS the shipped path under a card view, so that became a release bug under
combo/tilt70.
- MILESTONE 00:50 (commit 8e02cc3c) `StoryForms.follow(host, view, stage, ArenaRigs.ghost_view)`:
  the fold (one chip while a line is up) and the subtitle camera lift on the rig cast's own form
  view (no second form view, the sprite cast is not told to step out; story_voice/story_lift
  honoured). Quest1Game calls it after the rigs attach; quest1_game.gd stays at 270 lines (debt
  flat). Unit `test_follow_folds_the_rig_casts_own_form_card_and_skips_without_one`;
  `--select=test_story_forms,test_slice_closure` 12/0; lint 15/15.
  Evidence: `gtai-masters/n8/view/quest1_rigcast_formcard_fold_before_after_tilt70_crop2x.png`
  (before = hud's own crop of the rig cast, unfolded; after = the shipped tilt70 run at tick 600,
  1280x800, no --rigs, "cast rigs: true", card folded). FOUND on the after: the subtitle's last
  line sits on the box's hatch, and the box inset is today's 144 px: hud's SIDE_X 166 fix lives
  on n8-hud and reaches this path when the Director merges (no edit here).
  FOUND: quest 1's street itself (CityView chunks, props, the cops) still draws top-down at
  tilt70 on this branch: the city's lifts and the street cast's cards are city's and street's
  branches, not merged here. Judge the quest at tilt70 after the Director's merge.
- MILESTONE 00:50 NEXT 1 in motion: quest 1's Dock 9 (ticks 13560-13900) on the SHIPPED path at
  tilt70 (no --rigs, "cast rigs: true"), 1920x1080, 32 px/m:
  `gtai-masters/n8/view/quest1_dock9_shipped_rigcast_tilt70_32ppm.mp4` (5.7 s at 30 fps, every 2nd
  tick). Judged: Rivet's card stands, the Tonnage morph plays, the cops fall with blood, the form
  card folds under each line, 0 SCRIPT ERROR. The fight lives in the band above the subtitle box
  (the box takes the lower 40 % at 1080p); the street and the cops are top-down on this branch
  (city's lifts and street's cards are on their branches).
- MILESTONE 00:52 (commit 563e3709) Dent's p70 bust: the plating (opaque, saturation < 0.38: not the
  yellow badges, not the teal wisps) quantile-matched per channel to the p55 card: median luma
  67 -> 73, mean RGB 95/89/81 -> 104/94/83 (p55 104/94/84). Script kept in scratch
  (`scratch/view/tone8/match.py`). Evidence `dent70_tone_before_after_cards_and_64ppm.png` (the
  three cards + the after in game, `--bot=ghosts --ghost=dent --view=tilt70 --rigs --ppm=64`).
- MILESTONE 00:55 (commit a5500f67) Kerf's p70 card: the amber shoulder rings p55 has (the served
  kerf_70 drew none) painted on the shoulder joints of all five facings with p55's own amber pixels
  by a luma ramp (ink under luma 45 kept). Evidence `kerf70_amber_rings_before_after_cards_and_64ppm.png`
  (cards + in game at 64 px/m, tilt70, the amber joint reads). No provenance line: the same served
  sheet as it5's line, retoned.
- MILESTONE 01:00 item 8, the King fight's frame cost, combo vs top (under bench.lock, taken 00:57,
  released by the script; editor binary (debug), dev arena: a release export drops dev/arena, so
  this is NOT a release number). `--boss=king --bot=boss --seed=2 --rigs --view=<v> --disable-vsync
  --resolution 1920x1080 --frames=<json> --frames-ticks=1500`, top/combo alternated x2
  (`evidence/n8-view/bench-it8-king/`):
  top p50 5.87 / 5.93 ms, p99 12.6 / 12.5; combo p50 19.3 / 21.3 ms, p99 29.5 / 30.9, low 1 % 31 fps.
  FOUND: combo's frame was 3.3x top's, all in script `_process` (11.5 ms vs 0.5). `--spans`:
  `view_pitch_ease.gd` 6.45 ms mean per frame (0 under top). Cause: `RigHeadCard.rows_of(art)` was
  uncached (a `ResourceLoader.exists` per card row + the RigCardSets merge) and
  `ViewPitchCourt.dress` calls it per court strip per card per frame. Fix (commit after a5500f67):
  cache rows_of per art folder (pure in the folder: strips and RigCardSets load once). Spans after:
  ease 0.60 ms; the rest of combo's extra is the tilt itself (arena_floor_view draw 2.6 vs 0.84 ms,
  prop_occlusion 1.25 ms). Unit (rig_head_card, view_pitch, card sets, king art) 40/0.
- MEASURE 01:03 after the rows_of cache, same command and lock (`evidence/n8-view/bench-it8-king-after/`):
  combo p50 12.1 / 13.5 ms (was 19.3 / 21.3), p99 23.5 / 26.7 (was 29.5 / 30.9), script process
  p50 4.5 / 5.4 ms (was 11.5). top p50 7.28 / 12.5 ms: top run 2 had a 3.6 s stall and top run 1 sits
  1.4 ms over the first pair's 5.9, so the machine was busy under my lock (other lanes' work does
  not take bench.lock): label this pair CONTENDED. Combo vs top by the clean first pair + the after
  combo: ~12-13.5 vs ~5.9 ms p50, still about 2x: the rest is the tilt's own draw (floor view prop
  cards 2.6 ms, PropOcclusion 1.25 ms, find_children walk 0.6 ms). NOT a release number (owed:
  a release-export fight bench needs a shipped boss entry point; the bench export has none).
- MILESTONE 01:08 (commit 823903aa) PropOcclusion (view's file): each rig's feet and head once a
  frame instead of per prop, a Hit only for a body that meets the prop, unused `_patch` dropped.
  Same seed 2, combo, `--fixed-fps 60 --quit-after 900`, old vs new: occlusion log identical
  ("2 body-frames hidden over 900 frames, frames 743-744"), spans prop_occlusion 1.73 -> 0.36 ms
  mean. Debt tightened (205 lines). Unit prop_occlusion/arena cards/depth sort 12/0.
  Left in combo's extra after both fixes (spans, windowed, not under the lock): the floor view's
  draw +1.8 ms (the arena floor redraws the tilted prop faces/cards every frame: the floor is
  the arena's, the cards city's; a cached floor under a static camera pitch is the next win),
  ViewPitchEase 0.6-0.8 ms (the find_children walk over the whole arena tree every frame).
- GATE unit full no-arg at the rows_of cache (before the PropOcclusion edit): 1506 passed / 0
  failed, 0 FLAKY (`evidence/n8-view/unit-it8.log`).
- frames.json: 15 (Dock 9 tilt70 clip 4th; Kerf rings and Dent tone added; dropped the old Kerf
  tilt-48 card pair, the King-down Ohm return clip and the city drive: still on disk).
- Registry rules applied it8: perf-regression-gating (measured before a claim: frames + spans with
  a view-free control (top), the same seed and command, alternated runs, the contended pair named;
  a behaviour identity check (the occlusion count) for a perf refactor), depth-ordered-layered-art
  (the occlusion refactor keeps the hidden/front split exactly), generative-artifact-gating +
  sprite-and-atlas-production (the library sheet is retoned, never regenerated; badge and soul
  colours masked out of the tone match; ink kept under the ring paint), concept-scene-parity (the
  p70 cards judged against their p55 twins and in the arena at 64 px/m), motion-quality-gating
  (quest 1 judged as a clip on the shipped path).

NEXT (iteration 9, in brief order):
1. Combo's frame cost, the rest: (a) ViewPitchCards.apply walks the whole arena tree twice a frame
   (find_children for CutRig and ghost_card): keep a rig/ghost-card list refreshed on the tree's
   node_added/node_removed for those types, read head_card fresh per rig; measure with `--spans`
   (0.6-0.8 ms now). (b) the arena floor's tilted draw (+1.8 ms): say so to the owner, not mine
   alone (ArenaFloorView + city's PropCards). Then re-take the King fight frames under bench.lock,
   top/combo alternated x2 (the it8 after-pair was CONTENDED), and quest 1's rig cast vs sprites
   (`dev/bench/quest1_frames.gd` takes no --view yet: add it, dev only).
2. Quest 1 at tilt70 after the Director merges city + street: film the opening and Dock 9 again
   (the street, props and cops are top-down on this branch).
3. The order probe's phase-3 car pairs (it5's exact command, a still at the first wrong tick).
4. Before the freeze: director reel 19/19 top + combo, evidence run --no-bench, export the exe,
   REPORT with the Calls (King bust size, death beat length, attack lock, camera lead at speed,
   cover as one stack, quest 1's cast under the angled view: rigs (built) vs sprites).
- GATE scenarios at 1b1e30eb (`evidence/n8-view/scenarios-it8.log`): 52 ran, 2 failed: city_chase's
  2 ms WALL-CLOCK nav budget (max 2546 us) and rig_stress's 1 ms rig p50 (1.021 ms), while my
  commit's lint hook and a windowed occlusion run went beside it. Re-run alone through
  `tools/tests/run_scenarios.mjs --only=city_chase,rig_stress --quiet-wait=3`: 2 passed
  (`scenarios-it8-alone.log`). 0 SCRIPT ERROR. No sim file touched this iteration (view, art,
  dev-arena-only perf); `top` builds no card, so rows_of's cache and PropOcclusion (made only
  under a tilt) do not run there.
  Session ends here (01:20). Head: lint 15/15, unit 1506/0 (+ the targeted 12/0 after the
  PropOcclusion edit), scenarios 52 (2 wall-clock, passed alone). NEXT stands as written above.
- MILESTONE 01:29 NEXT 1a done early: ViewPitchEase keeps `ViewPitchCards.holders` (ghost cards +
  rigs) and walks the tree again only when it gains or loses a CutRig or a ghost card
  (node_added/node_removed); head cards are still read through the rig each frame. Spans, seed 2,
  combo, fixed 60 fps, 900 frames: ViewPitchEase 0.80 -> 0.18 ms mean; the same "cards art p55
  (pitch 62.1) at tick 32" swap; 0 SCRIPT ERROR; still at frame 400 (`--boss-cam`): the King's p55
  court bust, cape, one bell, gang cards as built. Unit view_pitch/rig_head_card/ghost_card 29/0.
  Combo's script extra over top is now ~0.6 ms (ease 0.18 + occlusion 0.36 + depth sort 0.16);
  the floor's tilted draw (+1.8 ms) is what remains. Re-take the frames under the lock (NEXT 1).
- GATE unit full no-arg at cb1290b7 (the head): 1506 passed / 0 failed, 0 FLAKY
  (`evidence/n8-view/unit-it8-head.log`). Session ends (01:26); NEXT stands (1a done).

## Iteration 9 (01:26-02:26)
Read: JOURNAL, git log, the four lane journals. New to view: city it12 REQUEST (PropOcclusion's
area = `PropCards.stand_rect` when it has one) and city it12 NEXT 3 (a rig list for
RigCastShadows.collect: "REQUEST to view if view exposes one", conditional). hud it7: no request.
- MILESTONE 01:30 (commit c38c82e5) city's REQUEST answered: `ArenaPropCards.stand_rect(kind, r)`
  calls city's `PropCards.stand_rect` by path (the class is absent on this branch), empty when city
  is not merged, under a flat view, or for walls; `PropOcclusion.drawn_area` takes it when it has an
  area, else the lifted box as before. Unit (arena prop cards + prop occlusion) 9/0; lint 15/15.
  PROVED on a throwaway trial merge of n8-city (a1fe2bbf..c63a03a4) into this head (scratch worktree,
  removed after): `--boss=king --bot=boss --seed=2 --rigs --view=combo`, 1500 frames headless:
  occlusion 5 body-frames (frames 743-988) on this branch -> 114 (frames 336-1001) merged: the
  crate cards stand ~2.6 m on screen, so a body 1-1.8 m north of a crate row is now redrawn under
  it (logs `evidence/n8-view/occ-it9/`). 0 SCRIPT ERROR both.
  MERGE NOTE for the Director: n8-view and n8-city both edit `ArenaFloorView._prop` (view: the
  `ArenaPropCards.draw` elif, it6, city's own REQUEST; city: `PropCards.stand` early return, it11).
  Take city's hunk: PropCards.stand is the same cards drawn by their owner, and stand_rect then
  matches what is drawn; ArenaPropCards.draw is left unused (its stand_rect bridge stays).
  Also `dev/frames/quest1_clip.gd`'s `--view` doc line conflicts (n8-hud/n8-city vs mine): same
  flag, take either line. `tools/debt/baseline.json`: take either side and `debt.mjs --update`.
- FINDING for city (seen on the trial merge, King fight seed 2 tick 362, combo, 32 and 48 px/m):
  the boulevard's middle crate row draws as a RED-ORANGE crate stack beside two cream stacks.
  Red is blood only, vermilion only for danger/objectives/Rivet's collar/the King's cape: is that
  card a vermilion danger mark by intent? If not, retone it like the cream stacks.
- MILESTONE 01:50 city it12 NEXT 3 answered (their conditional REQUEST): `RigDepthSort.on(layer)`
  returns the actor layer's sorter (null: flat view, no rig cast, freed; a WeakRef in the layer's
  meta `rig_depth_sort`), and its `frame_rigs` are this frame's visible rigs once its process
  (priority 100) ran. A node at priority > 100 or in `_draw` (CityOcclusion 101, RigCastShadows'
  draw) reads them instead of walking the actor layer (400 crowd children on the drive).
  PropOcclusion now does. Under a flat view (top_lift's cast shadows) there is no sorter: keep
  the walk. Identity: King seed 2 combo 1500 frames, occlusion "5 body-frames, 743-988" as before,
  order probe 0 wrong (`evidence/n8-view/occ-it9/king_combo_seed2_after_frame_rigs.log`).
  RigDepthSort._process calls `_with_cards` always (levels() with no card: the same sums).
  Unit (depth sort, occlusion, prop cards, cast shadows) 19/0.
- MEASURE 01:42-01:46 the King fight frames re-taken UNDER bench.lock (taken by me 01:42, released
  by the script), same command as it8 (`--boss=king --bot=boss --seed=2 --rigs --view=<v>
  --disable-vsync --resolution 1920x1080 --frames-ticks=1500`, editor binary, dev arena; NOT a
  release number), top/combo alternated x2, head 3855bae3 (rows_of cache + PropOcclusion + the
  ease's holder list + frame_rigs). `evidence/n8-view/bench-it9/king_*.json`:
  | run | p50 ms | p99 ms | low 1 % fps | over 33 ms settled |
  | top 1 / 2 | 6.04 / 5.66 | 11.41 / 10.66 | 79 / 84 | 0 / 0 |
  | combo 1 / 2 | 8.27 / 9.98 | 15.76 / 15.77 | 55 / 53 | 0 / 0 |
  it8 before the fixes, same lock: combo 19.3 / 21.3 p50, 29.5 / 30.9 p99, low 1 % 31 fps, 2-4
  frames over 33 ms. Combo is now ~1.6x top's p50 (was 3.3x), never over 33 ms settled. One
  disturbance of mine: my decision commit's lint hook ran beside `top 1` (01:42:30, ~30 s): top 1
  sits 0.4 ms over top 2. What remains of combo's extra: the arena floor's tilted draw (the
  floor redraws its lifted prop faces/cards every frame; arena's and city's code, not view's alone).
- MEASURE 01:44-01:46 quest 1's Dock 9 (`dev/bench/quest1_frames.gd --from=13560 --frames=900
  --view=<v>`, the window came up 1422x800: the script ignores --resolution), the SHIPPED path
  (top: the sprite cast; tilt70: the rig cast, "cast rigs: true"), alternated x2 under the same lock:
  top p50 3.83 / 3.84 ms, p99 12.2 / 12.6; tilt70 p50 5.71 / 7.37 ms, p99 14.8 / 17.7. tilt70 run 2
  overlapped my own unit run (01:45:00-01:45:10): CONTENDED; take run 1. Reading: quest 1 under a
  card view costs ~+1.9 ms p50 (the rig cast + the tilt's cards), all under 30 ms max (max 28.9).
  This answers it7's open "rig cast vs sprites" cost: affordable at 1080p on this machine.
- MILESTONE 02:00 the King on foot behind his wreck (brief item 7, the order probe's phase-3 car
  pairs, owed since it5): REAL, not a probe artifact. it5's command (`--boss=king --phase=3
  --bot=boss --seed=2 --view=combo --rigs --order-probe`) reproduces 10/10 wrong, first at tick 60;
  a debug line (not committed) named the pair: the car at (70,-15) m, a rig 2.2 m north of it.
  The it5/it6 stills missed it because they followed Rivet (the wreck is 30 m west); with
  `--boss-cam` at tick 72 the King stands just north of the wreck and his boots draw over its
  roof edge. Cause: `KingCarStack.sort_rigs` never put the King's own rig behind the car ("on the
  roof"), true in phases 0-1 only; from phase 2 he is on foot. Fix: the King goes behind too from
  phase 2 (`id != king_id or f.phase >= 2`). After: car pairs 10, 0 wrong over 2400 ticks; rig,
  ghost and accent pairs unchanged (0 wrong); 0 SCRIPT ERROR. Evidence
  `evidence/n8-view/order-probe-it9/` (logs + the x3 before/after crop at tick 72, combo 32 px/m:
  the roof's ink edge now runs unbroken over his boots). Tilt only (sort_rigs is never called
  flat): top unchanged. Unit (fast suite via --changed) 1493/0.
- FRICTION 01:52 the camera lead study (combo_lead) cannot be filmed on the city bench: the bench
  makes its own CityView with no CameraRig and no clock, so both views drew identical frames
  (deleted). The lead is proved by unit test only; the owner sees it in the exe by driving
  (`RTAI.exe -- --view=combo_lead` vs `--view=combo`). A dev drive with the real World camera is
  the way to film it (World._register_features makes the rig; the bench would need it + a clock).
- GATE unit full no-arg at 105de9d5: 1509 passed / 0 failed, 0 FLAKY (`evidence/n8-view/unit-it9.log`).
- Registry rules applied it9: perf-regression-gating (the King fight re-taken under the lock with
  the same seed, command and alternation as it8's before; the one disturbance of mine named; quest 1
  rig cast vs sprites labelled with its contended run), depth-ordered-layered-art (the occlusion
  area follows the drawn card, not a guessed box; the wreck/King order judged against the ground
  depth rule and seen on a still centred on the pair), concept-scene-parity (the trial merge judged
  with city's real cards), motion-quality-gating (the lead study: no frame faked when the bench
  could not show it; FRICTION logged), generative-artifact-gating (FINDING to city: a red crate card
  breaks the colour rule).

NEXT (iteration 10, in brief order):
1. The camera lead filmed: a dev drive with the real World camera (World._register_features makes
   the CameraRig; the bench has none): film combo vs combo_lead at speed, 48 px/m, side by side.
2. Quest 1 at tilt70 after the Director merges city + street (still not on main at 02:00): film the
   opening and Dock 9 again. If the merge lands, check the arena_floor_view conflict was taken as
   city's hunk (JOURNAL it9 MERGE NOTE) and re-run the King occlusion count (expect ~114).
3. Combo's remaining frame cost: the arena floor's tilted draw (+1.8 ms). FOUND (code read 02:08):
   `ArenaFloorView._held` (the `_static` child redrawn only on a new stage / ViewMode.revision)
   is used ONLY on the city (`arena.cells != null`); the King's boulevard and the depot are dock
   floors (cells null), so `_draw` re-issues the tiles AND every lifted prop/card each frame (the
   rings make it redraw). Fix: hold tiles + props in `_static` for every arena (it draws behind
   the parent: tiles, props, then the parent's cars, labels, rings: today's order). Touches the
   `top` path: prove pixel identity with the look goldens (evidence run) + a top still diff, then
   spans + the King fight frames under the lock.
4. Before the freeze: director reel 19/19 top + combo, evidence run --no-bench, export the exe,
   REPORT with the Calls (King bust size, death beat length, attack lock, camera lead at speed:
   combo vs combo_lead, cover as one stack, quest 1's cast under the angled view).
- GATE 02:09 scenarios at 917e30b1 (`tools/tests/run_scenarios.mjs --quiet-wait=3`,
  `evidence/n8-view/scenarios-it9.log`): 52 passed, 0 failed, 0 SCRIPT ERROR, nothing contended.
  Head gates it9: lint 15/15, unit 1509/0 (105de9d5; later commits: King sort z (tilt only) +
  docs, fast suite 1493/0), scenarios 52/0, director reel 19/19 top + combo. Session closes; the
  NEXT above stands.

## Iteration 10 (02:11-03:11)
Read: JOURNAL, git log, the four lane journals. New to view: vehicles it14 REQUEST (draw the
soul-seize cues: ghost halo, teal tether, bay markers above the vehicles band z > 200, so
`VehicleStageCards.over = true` can stand a stage car over the actors; "not urgent"). city it13:
ANSWER to my red crate FINDING (their redraw under the item print, fixed on city's side; take
n8-city >= d70c8b06). street, hud: nothing to view.
- MILESTONE 02:20 (1dd745b8) ANSWER to vehicles it14 REQUEST (seize cues over z 200), in part:
  `GhostAttackViews.dent_dz(view)`: under a card view DentView (the teal tether and the seized
  car's heat halo) draws at vehicles + 1 (z 201, under roof_occluders 300); flat views keep
  actors + 1, so `top` is unchanged. Filmed on this branch (no stage cards here): Servo depot
  `--boss=servo --bot=boss --servo-ghost=dent --view=combo --ppm=32 --rigs --seed=2`, 200 frames
  before/after: 80 frames differ, each only a ~20 x 15 px box round the tether's hand end (it now
  draws over the ghost's own teal aura instead of under it; reads cleaner), 0 SCRIPT ERROR
  (`evidence/n8-view/seize-z-it10/`, x3 crop f130). Unit 2/0 (`test_ghost_attack_views_z`).
  NOT moved, by intent: (a) Dent's soul halo (GhostFormView, rigs z + Z_OVER_RIGS) belongs to the
  ghost's body: lifting every ghost over the vehicles band would draw a ghost standing BEHIND a
  van over it. Feed the ghosts to your VehicleFront grid like the fighters (vehicles' side:
  `ArenaRigs.ghost_view` / the ghost cards' positions), so a ghost in front of the van goes over
  it with its halo. (b) bay 3's marker is a ground mark: a van standing on it covers it depth-
  correctly. If the seize must read through the van, the marker belongs on the `world_markers`
  canvas (objective marks); say so and I take it next iteration.
- MILESTONE 02:33 (cca797f9) NEXT 3 of it9: the dock arenas (King boulevard, Servo depot, dev
  stations; `arena.cells == null`) now hold their floor tiles and props on `ArenaFloorView._static`
  like the city block (redraw only on a new stage, a `ViewMode.revision`, or under a perspective
  eye). Tiles + rim, barrier runs, crate rows moved to `ArenaFloorStatic` (static, any canvas
  item), the same calls in the same order: the floor file 201 -> 173 lines. PROOF of identity:
  `--boss=king --bot=boss --seed=2 --rigs --view=<v>`, 240 frames each, before (4fc67214) vs
  after, PNG per frame: top 0/240 differ, combo 0/240 differ (combo's ease and card swap at tick
  32 inside the window), 0 SCRIPT ERROR. DECISION in docs/decisions.md.
  FRICTION: the first after-run had 10 SCRIPT ERROR (a new class_name not in the class cache:
  run `--import` after adding a class before any direct Godot run; the runners do it themselves).
  `tools/godot/check.mjs` on arena_floor_view.gd reports the CutRig-cycle false FAIL (street's
  FRICTION); the recording is the real compile check.
- 02:34 bench.lock taken by me (absent before), `scratch/view/bench10.sh`: it9's King fight
  command, top/combo alternated x2, -> `evidence/n8-view/bench-it10/`; the script releases it.
- MEASURE 02:39-02:41 the King fight after the held dock floor, bench.lock held (taken 02:38,
  released by the script), it9's command (`--path project --disable-vsync --resolution 1920x1080
  res://dev/arena/arena.tscn -- --boss=king --bot=boss --seed=2 --rigs --view=<v> --frames=<json>
  --frames-ticks=1500`), top/combo alternated x2, head cca797f9, `evidence/n8-view/bench-it10/`:
  | run | p50 ms | p99 ms | low 1 % fps | over 33 ms settled |
  | top 1 / 2 | 7.34 / 9.75 | 17.6 / 19.8 | 46 / 12 | 1 / 6 |
  | combo 1 / 2 | 5.85 / 4.86 | 16.2 / 11.7 | 40 / 69 | 7 / 1 |
  CONTENDED: other lanes ran street_crowd + a city trial render (GPU) and a GUT + a scenarios run
  during it (the lock guards benches only); top itself sits 1.3-4 ms over it9's 6.0 / 5.7. Reading,
  within one contended window and alternated: combo's p50 is now at or under top's (it9: 1.6x top;
  it8: 3.3x). Take the quiet re-take before the freeze (NEXT).
  FRICTION 02:38: my first take put `--disable-vsync --resolution` after `--` (user args): every
  run paced at 16.67 ms p50; discarded, re-run with the engine flags before the scene path.
  (The bench evidence + this JOURNAL entry landed inside 3c5aacba: the hook had rejected their own
  commit on the then-unstaged lead_showcase edit and left them staged.)
- MILESTONE 02:47 (3c5aacba) NEXT 1 of it9, the camera lead FILMED with the real CameraRig:
  `lead_showcase` (the city selftest junction, CityView feeds the rig from a focus driven east)
  takes `--view=<id>` and `--speed=<m/s>`. `godot --fixed-fps 60 --path project
  res://dev/selftest/lead_showcase.tscn -- --out=<dir> --view=<combo|combo_lead> --speed=<15|25>`,
  48 px/m (car mode), 0 SCRIPT ERROR x4. Lead at tick 150 (settled): combo 4.93 m @15, 6.58 m @25
  (the cap); combo_lead 7.40 m @15, 9.87 m @25 (`evidence/n8-view/lead-it10/*.json`). Checked the
  selftest really draws the tilt: `--view=top` vs combo at tick 0 differ everywhere (compressed
  crosswalks, the crowd as cards). Masters: `lead_combo_vs_combo_lead_{25,15}mps_48ppm_t150.png`
  (frames.json #9, replacing the arena cover cards still: city's PropCards own that at the merge).
  Looked at: the focus sits further back in the frame with combo_lead. Road ahead of the focus to
  the frame edge (1280 px window = 26.7 m at 48 px/m, half 13.3 m + the lead): combo 19.9 m,
  combo_lead 23.2 m at 25 m/s (0.8 s vs 0.93 s of travel). Default stays combo (x1); the Call
  is the owner's (REPORT).
- GATE unit full no-arg at 3c5aacba: 1511 passed / 0 failed, 0 FLAKY (`evidence/n8-view/unit-it10.log`).
  Lint 15/15 at each commit (the hook).
- Registry rules applied it10: depth-ordered-layered-art (the seize cue's z chosen against the
  band table, the ghost's own halo left with its body so a ghost behind a van stays behind it;
  bay marks stay ground), perf-regression-gating (the held floor proved pixel-identical before it
  was timed; the bench labelled CONTENDED with what ran beside it; the vsync-paced first take
  discarded, not reported), motion-quality-gating (the lead filmed on the real CameraRig, settled
  tick, two speeds; the selftest's tilt verified against top before trusting the stills),
  concept-scene-parity (the Dent tether judged in the Servo depot fight, not a probe),
  generative-artifact-gating (no new art this iteration).

NEXT (iteration 11, in brief order):
1. Quiet re-take of the King fight frames (top vs combo, `scratch/view/bench10.sh`, engine flags
   before the scene path) when no other lane renders; then the release-export number for item 8
   (the dev arena is not in a release export: use `tools/bench/run.mjs` crowded drive top vs combo).
2. Vehicles' answer on the seize cues: if they want bay 3's marker through the van, move the bay
   marks to the `world_markers` canvas under card views (servo_bays / depot draw; mine: Servo).
3. Quest 1 at tilt70 after the Director merges city + street (check the arena_floor_view merge:
   city's `PropCards.stand` hunk now sits in `_prop`, which the held `_ground` calls for every
   arena: the cards are held too; expect the King occlusion count ~114 on the merge).
4. Before the freeze: director reel 19/19 top + combo, evidence run --no-bench, export the exe,
   REPORT with the Calls (King bust size, death beat length, attack lock, camera lead at speed:
   combo vs combo_lead with the it10 stills, cover as one stack, quest 1's cast under the angled view).
MERGE NOTE it10 for the Director: `ArenaFloorView` changed again (cca797f9): `_draw` no longer
tiles/props per frame on dock arenas (`_held` -> `_ground` for every arena), `_barrier`/`_crate_row`
moved to `ArenaFloorStatic`, `_prop`'s `side` line split in two. city's `_prop` hunk
(`PropCards.stand` early return) still goes into `_prop` as before; if city's cards change per
frame (they did not on the it9 trial merge: stand_rect from static props), they must ask the held
child to redraw (`_static.queue_redraw()`).
- GATE 02:51 scenarios at 3c5aacba (`run_scenarios.mjs --quiet-wait=3`): 52 passed, 0 SCRIPT ERROR, none contended (`evidence/n8-view/scenarios-it10.log`).
- GATE 02:57 director reel (headless, `--quit-after 14000 res://dev/arena/arena.tscn -- --bot=reel --reel=director --loadout=pistol --rigs --view=<v>`) at 025f48ac: 19/19 chapters all down, 0 SCRIPT ERROR, top + combo (`evidence/n8-view/director-reel-it10-{top,combo}.log`). Session closes (02:58): head gates lint 15/15, unit 1511/0, scenarios 52/0, reels 19/19; scratch frames deleted (crops in evidence + masters). NEXT above stands.

## Iteration 11 (2026-11-07 02:59 - 03:59), BUILD

Read: JOURNAL, git log, the four lane journals: no new REQUEST to view (vehicles it15 read
before my 02:20 answer to their it14 seize-cue REQUEST; their NEXT 1 waits on it), main has not
merged the lanes (n8-view..main = 0), so quest 1 after the merge (NEXT 3) still waits.
- 03:00 machine busy (two windowed movie renders by street / vehicles, a headless reel): no bench.
- MILESTONE 03:06 the lane's combined clip (owed by common.md, absent until now):
  `gtai-masters/n8/view/view_set_combined_n8_it11.mp4`, 86 s, 1920x1080 60 fps, 8 titled segments
  from the masters clips (ring lock, car-line lock, death beat x2, Tonnage + Ohm through the King-
  down return, quest 1 Dock 9, city on foot and driving top vs tilt70). Script
  `scratch/view/combined/make.sh`. Looked at a 6-still contact sheet: titles legible, each
  segment's before/after sides as titled. frames.json #1 (dropped the Dent tone pair: #9 covers Dent).
- MILESTONE 03:14 the death beat's Call filmed at 64 px/m (the close-up owed since it4): the seed-2
  King phase 3 death (no bot, dies tick 1727), `combat.json rivet.death_beat_s` 0.7 / 1.0 / 1.5
  (edited per run by `scratch/view/dbeat.sh`, restored with `git checkout --`), respawn ticks
  1769 / 1787 / 1817, 0 SCRIPT ERROR x3. `death_beat_length_07_10_15_combo_64ppm.mp4` (+ `_seq.png`),
  frames.json #4 (dropped the Kerf rings pair: #8 covers Kerf). LOOKED: 0.7 s inks before the
  King's stomp lands over the corpse; 1.0 s shows one stomp over the sprawl, then ink; 1.5 s holds a
  second look at the King standing on the wreck. Close up the King's body covers half the sprawl.
  Default stays 1.0 s.
- MEASURE 03:19-03:21 the King fight, top vs combo alternated x2, bench.lock held (taken 03:18:32,
  released by the script), head a5bbf95f, `scratch/view/bench11.sh` (it10's command, engine flags
  before the scene path), `evidence/n8-view/bench-it11/`:
  | run | p50 ms | p99 ms | low 1 % fps | over 33 ms settled | worst settled ms |
  | top 1 / 2 | 4.96 / 5.17 | 11.1 / 9.9 | 79 / 92 | 0 / 0 | 25.3 / 12.4 |
  | combo 1 / 2 | 3.81 / 4.06 | 8.0 / 8.7 | 112 / 102 | 0 / 0 | 12.7 / 14.0 |
  CONTENDED: vehicles started a windowed Godot render (n8-vehicles project) at ~03:19 during run 1;
  no other bench. Quieter than it10 (top 5.0 vs 7.3-9.8 then). Reading: combo is now CHEAPER than
  top on the King fight (-1.1 ms p50, -2 ms p99), both runs; it8 combo was 3.3x top, it9 1.6x,
  it10 at or under. Likely why: under combo the cast draws as one card quad per body where top draws
  every rig part flat (not split by spans this time). Combo's unsettled worst (77-88 ms) is the first
  second (card atlas + shader load), outside the settled stats.
- 03:15 TRIAL MERGE (throwaway detached worktree in %TEMP%, never a branch) of city, street,
  vehicles, hud onto n8-view: conflicts in view-owned or co-written files are comment lines only
  (rig_card_sets.gd doc line vs street's copy of my 091f5309; arena_floor_view.gd doc lines vs city;
  quest1_clip.gd's `--view` doc line, which city, hud and I each added), plus every JOURNAL.md and
  tools/debt/baseline.json. ONE REAL OVERLAP with hud: `StoryForms.fold_rigs` (hud 6fd17433, 00:26)
  and my `StoryForms.follow` (8e02cc3c, 00:41) do the same fold for quest 1's rig cast; follow also
  lifts and voices, and quest1_game.gd under view builds the cast in features (ArenaRigs moved out
  of dev/, ebd77c13), where hud's side still loads `res://dev/arena/arena_rigs.gd`. Resolution: take
  view's side in story_forms.gd, quest1_game.gd and test_story_forms.gd; hud's test case (the card
  unfolds when the line closes) is now in my follow test (8ecf8f2d), so no coverage is lost.
- 03:25 TRIAL MERGE result (detached %TEMP%/view-trial-it11, head a7f4cdf5, never a branch): all
  four lanes merge onto n8-view with the resolutions above. ONE SEMANTIC CLASH (lint gd-size, no
  text conflict): `features/bosses/boss_view.gd` `attach` is 41 lines > 40 once city's
  `BossDressing.attach` call (+2: an `@warning_ignore` and the call) and hud's `bar.crest` line (+1)
  meet; each branch alone is at 40/39, view does not touch the file. In the trial I moved city's
  two lines into a `static func _dress(v, hook)` (attach -> 40); lint 15/15 then.
  REQUEST to city: shrink `BossView.attach` by a line on your branch so the merge with hud passes
  gd-size, e.g. `BossDressing.attach(...) -> void` (no `@warning_ignore` needed) or the `_dress`
  helper above. (Not urgent before the Director's merge; one line.)
  NOTE to hud: `StoryForms.fold_rigs` and view's `StoryForms.follow` fold the same card; the merge
  takes `follow` (it also lifts and voices; quest1_game.gd under view no longer loads the dev
  arena_rigs.gd path), and your unfold-on-silence assertion is in my follow test (8ecf8f2d). Nothing
  to do on your side unless you object in your JOURNAL.
- GATE 03:31 the trial merge tree (d8d1ee75: n8-view a5bbf95f + city ca539e27 + street b1fe5682 +
  vehicles 21597e15 + hud 0ce401f0, the resolutions above): lint 15/15 (the commit hook), unit
  full no-arg 1624 passed / 0 failed (`%TEMP%/trial_unit.log`). FRICTION: my first trial-only
  `_dress(v: BossView, ...)` was wrong (`v` is a CollectCallView in `BossView.attach`); the
  quest film's 12 SCRIPT ERROR showed it, check.mjs named it. The REQUEST to city above means
  `_dress(v: CollectCallView, hook: BossHook)`. check.mjs's king_body_view FAIL is the known
  cycle false FAIL (the same on n8-view alone).
- MILESTONE 03:33 quest 1 judged AFTER the merge (NEXT 3, owed since it7), on the trial tree:
  `quest1_clip.gd -- --stills=600,2400,6000,13700 --view=tilt70 --ppm=32` (shipped path, no
  --rigs), 1920x1080, 0 SCRIPT ERROR; n8-view alone left, all lanes right:
  `gtai-masters/n8/view/quest1_merge_preview_view_vs_all_lanes_tilt70_32ppm.png` (not in frames.json:
  a trial, not this branch). LOOKED: the whole street now stands at 70 (city's facades, lamps,
  dumpster and payphone cards; street's pedestrians as cards; vehicles' cards; hud's portraits in the
  dialogue box); view's cast (Rivet's card, the rig cast, the form card) sits in it without a draw
  fault I can see at 32 px/m; Rivet in the dumpster (tick 600) draws over the dumpster card's lid.
  FOUND two things, neither view's:
  (a) the Dock 9 Gloria floor drawing is ~7 m long at 32 px/m (about four crates), over the crate
  row and the objective label (`quest1_merge_preview_dock9_gloria_pickup_crop2x.png`). A second
  throwaway tree with n8-hud ALONE draws it the same (`scratch/view/it11/keep_q_hud_vs_merged_13700.png`):
  hud's, not a merge effect.
  (b) a cop at the Line Stopped crossing (tick 600) is the top-down sprite in both trees (shoulders
  and cap from above), while street's crowd stands as cards: not view's rig cast (those stand as
  head cards); the city sim's cop sprite path.
  REQUEST to hud: the quest 1 Dock 9 Gloria drawing under tilt70 (tick 13700, 32 px/m) spans ~7 m;
  if it is the objective showcase on purpose, a size near the crate (1.6 m) would keep the crate
  row and the "PROJECT TUG..." label readable; if not, it is a pickup sized off the wrong width.
  Stills: the two paths above.
  NOTE to street: the tick-600 cop (Line Stopped crossing) still draws top-down at tilt70 in the
  merged tree; if city cops are yours (the --cops board), quest 1's street cops are not on it yet.
- 03:36 director reel on the trial tree, top + combo in parallel (headless): running.
- GATE 03:40 director reel on the trial merge tree d8d1ee75 (headless, `--fixed-fps 60 --quit-after
  14000 res://dev/arena/arena.tscn -- --bot=reel --reel=director --loadout=pistol --rigs --view=<v>`):
  top 19/19 chapters all down, combo 19/19 all down, 0 SCRIPT ERROR each
  (`evidence/n8-view/director-reel-it11-trialmerge-{top,combo}.log`, unit log `unit-it11-trialmerge.log`).
  Combat does not regress across the five lanes' merge. The trial tree stays at
  `%TEMP%/view-trial-it11` (detached, registered in the shared worktree list) for it12's checks;
  removed before the freeze.
- Registry rules applied it11: concept-scene-parity (quest 1 judged on the merged real scene, not
  per lane; the Gloria size traced to its lane by a second single-lane tree before any REQUEST),
  perf-regression-gating (the King bench under the lock, alternated, CONTENDED named with what ran;
  the merged tree's gates before calling the merge safe), motion-quality-gating (the death beat
  options filmed side by side on one seed, the same ticks), combat-pacing-and-dramatic-arc (the death
  beat lengths judged against the King's stomp: 0.7 s inks before the stomp lands), generative-
  artifact-gating (no new art).

NEXT (iteration 12, in order):
1. Answers: city (BossView.attach 41 lines), hud (Gloria size; fold_rigs), street (the tick-600
   cop), vehicles (their reply on the seize cues: bay marks to world_markers if they ask).
2. The release-export drive (top vs combo, `tools/bench/run.mjs`-style windows-bench export with
   `--view=`), under bench.lock when it is free and the machine is quiet: it5's number is old.
3. Re-run the trial merge on the lanes' newer heads (`scratch/view/trial_merge.sh`, then
   trial_reel.sh + run_unit in the tree) after their next commits; delete the tree before the freeze.
4. The freeze (08:30): director reel top + combo on n8-view, evidence run --no-bench, the exe,
   REPORT final (frame-cost table: it5 drive, it11 King fight; the Calls: bust, death beat length
   with the 64 px/m film, attack lock, camera lead, quest 1 cast under the angled view).
- MEASURE 03:39-03:41 NEXT 2 done early: the city drive in a RELEASE export (`windows-bench`,
  exported at 7a9ad790, `scratch/view/export11.sh`), `drive_dense` 48 px/m, 30 s x 2 per view,
  top/combo alternated, bench.lock held (03:38:43, released by `drive11.sh`),
  `evidence/n8-view/bench-it11-drive/`:
  | metric | top r1 / r2 | combo r1 / r2 |
  | renderCpuMsAvg | 0.312 / 0.285 | 0.344 / 0.332 |
  | drawCallsAvg | 252.0 / 251.8 | 254.2 / 254.2 |
  | rigMsP50 | 0.446 / 0.436 | 0.572 / 0.564 |
  | rigMsP99 | 1.035 / 0.819 | 1.327 / 1.348 |
  | visibleAvg | 9.8 / 9.8 | 10.9 / 11.0 |
  | p99CpuMs / low1Fps | 32.1 / 31.0, 19.6 / 45.8 | 32.1 / 29.2, 33.2 / 27.6 |
  CONTENDED: a headless GUT run and a windowed 1280x800 render by other lanes were seen during it
  (`contention.txt`, sampled every 20 s). Reading: the same as it5 after six iterations of view work:
  combo costs ~+2 draw calls, ~+0.12 ms rig p50, one more visible actor (70 shows more ground);
  render CPU +0.04 ms. The p99 / low-1 % rows are the known ~32 ms vsync-off present stalls, in both.
- 03:45 READ two new REQUESTs to view (landed during this session):
  ANSWER to vehicles (it16, bay markers to world_markers now that VehicleStageCards.over is on):
  YES, view takes it in it12 (Servo is mine). Plan: `ServoDepotDraw._bay` splits into the door
  (ground, as today) and the apron mark (the box outline + the bay number), the mark drawn by a
  `ServoBodyView` child on the `world_markers` z under a card view only (`ViewMode.shared().cards`);
  flat views keep the one ground pass in today's order, so `top` stays bit-identical. Filmed in the
  Servo depot at combo 32 + 64 px/m with a van on bay 3, before/after.
  ANSWER to street (it8/9, RigSelect keeps a fresh corpse on its full rig): YES, view takes it in
  it12. Plan: in `RigSelect.nearest` a body that died within a short hold (the death beat's 1 s or
  the fall's length) and is on screen ranks by its distance to Rivet, not to the box-centre focus,
  ahead of living bodies past the MAX_FULL-th; repro `--arena=city --bot=rivet --seed=5 --rigs
  --ppm=48 --view=tilt70`, actor 3000 at frame 513. Street keeps (b), the atlas corpse cell.
NEXT (iteration 12) replaces the order above: 1. vehicles' bay marks (plan above), 2. street's
RigSelect corpse (plan above), 3. city's / hud's answers on the trial findings, 4. re-run the
trial merge on the newer heads, 5. the freeze items (NEXT 4 above). Session closes 03:46.
- MILESTONE 03:47 vehicles' it16 REQUEST done this session (it12 NEXT 1 taken early):
  `ServoDepotDraw.marks_apart` + `marks()` / `_mark()` (the apron box and number split out of `_bay`,
  same calls in the same order when not apart), `ServoBodyView._marks` (absolute z
  `RenderLayers.z(&"vehicles") + 1`, only when `ViewMode.shared().cards`). Not the world_ui
  `world_markers` canvas: a different CanvasLayer would take the marks off the print stage's grade
  and ink; just over the vehicles band on the same canvas does what the REQUEST needs. FILMED on the
  trial merge tree (vehicles' `over` on, f09f4456), Servo depot `--boss=servo --bot=boss
  --servo-ghost=dent --view=combo --ppm=32 --rigs --seed=2`, 200 frames, before = the tree as is,
  after = my two files copied in (reverted after), 0 SCRIPT ERROR both:
  `servo_bay_marks_over_van_before_after_combo_32ppm_f130.png` + `.mp4`. LOOKED at f130: before,
  the van on bay 3 hides its box and number; after, the "3" and the box read over the van, under
  Dent's seize ring and tether. `top`: marks_apart false, the ground pass unchanged. Servo tests
  39/0. DECISION in docs/decisions.md. ANSWER to vehicles: done on n8-view (this commit).
- GATE 03:52 at 73a78455: unit full no-arg 1511 passed / 0 failed, 0 FLAKY (`evidence/n8-view/unit-it11.log`); scenarios 52 passed, 0 failed (`scenarios-it11.log`); lint 15/15 (hook). NEXT (it12): 1. street's RigSelect corpse (plan above), 2. city's / hud's answers on the trial findings, 3. the trial merge re-run on newer heads (then delete the tree), 4. the freeze items. Session closes 03:52.

## Iteration 12 (2026-11-07 03:53, BUILD)
Read: JOURNAL (it11 NEXT), git log, the four lane journals (no new REQUEST to view; city and hud
have not answered the it11 trial findings yet; street's it9 notes my answer and keeps its 2b).
- MILESTONE 04:10 street's RigSelect corpse REQUEST (it12 NEXT 1) done, edee640a.
  FIRST CUT (rejected, filmed): a fresh corpse ranked right after Rivet. On the repro
  (`--arena=city --bot=rivet --seed=5 --rigs --ppm=48 --view=tilt70`, the trial merge tree for
  street's cards, my two files copied in and reverted) the corpse lay drawn, but a living cop lost
  LOD 0 and VANISHED (an empty selection ring at f600): the arena (ArenaRigs) has no crowd atlas, a
  row off its rig draws nothing. Before my change the same is why the corpse vanished: street's
  "black bar" is the blood's head mark, the body itself was gone.
  BUILT: `RigSelect.nearest(..., pinned)` puts pinned rows in a TAIL past the living `limit`, so
  the living 16 are exactly the old selection; `RigSelect.fresh_dead` keeps actor -> death tick for
  rigged DEAD rows and pins at most CORPSE_PINS 4 (latest first) younger than the host's hold;
  `CharacterRigs.corpse_hold_ticks` defaults to HOLD_NO_ATLAS (until the row leaves the feed:
  arena, quest 1), `CityCharacters` sets CORPSE_HOLD_TICKS 90 (then the atlas, where street draws
  the lying frame); PREWARM +4 per plan (pool().grown stays 0); a pinned fall poses at rank 0
  (full rate). Flat views clear the pins: `top` selects as before.
  FILMED before/after, 640 frames, 0 SCRIPT ERROR both: `gtai-masters/n8/view/arena_corpse_keeps_
  rig_before_after_tilt70_48ppm_seed5.mp4` (f470-660) + `_f545_f635.png`. LOOKED: before, at f545
  and f635 only the blood trail; after, the cop lies drawn at the trail's foot at both, and every
  living cop that had a rig still has it. Unit test_character_rigs 12/0 (+3 tests). DECISION line.
  ANSWER to street: done on n8-view (edee640a). In the city game the corpse keeps its rig 90 ticks,
  then your atlas lying frame (your 2b) takes it: if you want a longer hold there, it is
  `RigSelect.CORPSE_HOLD_TICKS` (one value; tell me).
- GATE 04:17 at b097c7a5 (the corpse rig): unit full no-arg 1515 passed / 0 failed, 0 FLAKY
  (`evidence/n8-view/unit-it12.log`); scenarios 52 ran, 0 failed (`scenarios-it12.log`; vehicle
  drive timing CONTENDED, passes); director reel under combo 19/19 chapters all down, 0 SCRIPT
  ERROR (`director-reel-it12-combo.log`). Lint 15/15 (hook).
- 04:13-04:17 TRIAL MERGE re-run (it12 NEXT 3) on the newer heads: the trial tree reset to n8-view
  b097c7a5 (detached), then city 7b63bcb1, street cfc90d46, vehicles 1b6740ac, hud 69c3b200 by
  `trial_merge.sh` (conflicts: view's side, as it11). Lint 15/15 over 1185 files with NO hand fix:
  the it11 BossView.attach gd-size clash is gone on the lanes' heads. Unit + reel top/combo running.
- GATE 04:21 the trial merge tree (n8-view b097c7a5 + city/street/vehicles/hud heads above):
  unit full 1639 passed / 0 failed (`evidence/n8-view/unit-it12-trialmerge.log`); director reel
  top 19/19 and combo 19/19 chapters all down, 0 SCRIPT ERROR each
  (`director-reel-it12-trialmerge-{top,combo}.log`). The it11 BossView.attach clash is gone (city
  or hud shrank it): REPORT merge notes updated. The trial tree stays for the freeze check.
- MILESTONE 04:22 Dent p70 (2685766e): the asset lane served `dent_v2` 70 A (round 20261107-0400,
  drawn tan by copy-by-example, superseding the 2150 B whose tone we fixed in post). Same layout as
  v1, so the same belt crop (y 298) + ghost_bust.py; no tone step. Cards side by side (p55 | old p70
  | new p70: `dent70_v2_cards_p55_p70old_p70v2.png`): the new one is the p55 tan, the old printed
  grey-dark. FILMED Servo depot `--servo-ghost=dent --view=tilt70 --seed=2` at 32 and 64 px/m, 240
  frames, 0 SCRIPT ERROR before/after: `dent70_v2_before_after_tilt70_64ppm_f160_f200_x2.png`,
  `_32ppm_f200.png`. LOOKED: warmer dome and shoulders, discs and wisps unchanged; subtle at 32.
  Provenance line (round + prompt_hash), decision line. frames.json: Dent v2 replaces the old Dent
  pair, the corpse clip in at #8, king_bust_abc_32 out (still in the folder, named in REPORT).
- Registry rules applied it12: motion-quality-gating (the corpse fix judged in motion over the
  death and 120 frames after it; the first cut's side effect, a vanished living cop, seen in the
  film, not in the unit test, and fixed before commit), generative-artifact-gating (dent_v2 graded
  A in the catalog, looked at against p55 and the old cut before integrating; provenance with
  round + prompt_hash), concept-scene-parity (the corpse fix filmed on the merged tree, where
  street's cards are), depth-ordered-layered-art (the pinned corpse keeps the depth sort's rig
  path, no new layer), perf-regression-gating (pins bounded at 4, pools prewarmed: pool().grown 0).
NEXT (iteration 13, in order):
1. Answers: city / hud on the it11 trial findings if they reply (Gloria size, fold_rigs); street on
   the corpse hold (CORPSE_HOLD_TICKS, one value).
2. Library check for new 70 sheets in view's cast (Kerf, King, King's car, gang, Servo parts):
   the asset lane is serving view's REQUESTs (dent_v2 came at 04:00).
3. The freeze (08:30): delete the trial tree (`git worktree remove` on %TEMP%/view-trial-it11),
   director reel top + combo on n8-view, evidence run --no-bench, the exe, REPORT final.
- MEASURE 04:24-04:33 mutation test of rig_select.gd (`tools/mutate/mutate.mjs --max=12
  --tests=test_character_rigs`): 10 killed / 1 survived (90.9 %), 1 timeout (line 64's `>` -> `<=`
  makes the pin-cap loop endless: a hang, which the test run catches as a timeout). Survivor
  line 62 `tick - seen < hold` -> `+`: the cap test used ticks near 0. Fixed (the test counts from
  a late death tick, 5000); re-run `--ops=arith`: 5/5 killed (100 %).
- Session close 04:34: tree clean, every change committed. Commits it12: edee640a (corpse rig),
  2685766e (Dent v2 + trial evidence), the test tightening, + JOURNAL/REPORT/evidence. NEXT as above.

## Iteration 13 (2026-11-07 04:34, BUILD)
Read: JOURNAL (it12 NEXT), git log, the four lane journals: no new REQUEST to view; street has not
answered on CORPSE_HOLD_TICKS (stays 90); hud answered the Gloria finding (the HUD icon, moved onto
the ammo ticket, 93c8bd2a); city answered BossDressing.attach (it11). Library: nothing new for
view's cast since dent_v2 (torque_gang_fall 70/55 B is street-class, and nothing spawns Torque's
gang: street's it10 notes). The throne-car's p70 is a lifted stack (pitch-agnostic), so king_car
70 B is not needed.
- 04:37-04:40 TRIAL MERGE re-run on the newest heads (n8-view b1943c79 + city e95c7cf6, street
  4ed5f41e, vehicles 3ff6b4bc, hud d63fb403), `--import` clean. FILMED the city block on foot at
  tilt70 48 px/m seed 5 and 32 px/m seed 13 (720 frames each, 0 SCRIPT ERROR) to judge the shared
  depth sort / occlusion against the lanes' new art. FOUND, not view's: (a) frames 0-2 show city's
  ViewPrewarm (WLD-07) texture patch + FX sample at the camera centre; the shipped city game runs
  it under the loading screen, the dev arena shows it (no action; noted for city); (b) two empty
  selection rings at tick 120: present in `top` too (same seed), pre-existing arena slots. Nothing
  in view's draw order misplaced in the sampled frames.
- MILESTONE 04:55 combo's held weapon follows the ART key (FOUND while auditing every per-pitch
  lookup in the merged tree for `roundi(pitch_deg)` / `.pitch_deg`: HeldPitchArt.held was the last
  one keyed by the live pitch). Fix: `held()` asks `ViewMode.art_pitch()`, tags the sprite with
  the art key, `HeldPitchArt.stale(s)` makes RivetHeldView re-make it on combo's swap (one
  condition in rivet_held_view.gd, no line added: the debt ratchet's soft cap held it at 288).
  FILMED King fight combo 48 px/m seed 2, 900 frames before/after, 0 SCRIPT ERROR:
  `held_art_key_before_after_combo_48ppm.mp4` + `_f300_f600_x3.png`. LOOKED: before, the slim
  top-down part all fight (drawn at 70 at tick 0, never re-made); after, the 55 three-quarter part
  (what `tilt` draws) once the boss engages. At 48 px/m the 55 part reads chunkier than the slim
  top-down stick: that is d8's tilt choice, followed, not re-judged (the held art is frozen; the
  owner's equipped-Rivet frames replace both). Re-filmed on the final code: Rivet's crop at f600
  pixel-identical. Test +1 (planted the old `pitch_deg` line: it fails). Lint 15/15, unit
  --changed 1500/0. DECISION view/held-art-key.
- GATE 04:53 at 04429dee: unit full no-arg 1516 passed / 0 failed, 0 FLAKY (`evidence/n8-view/unit-it13.log`); director reel top 19/19 and combo 19/19 chapters all down, 0 SCRIPT ERROR (`director-reel-it13-{top,combo}.log`). Every per-pitch art lookup in the merged tree now goes through the art key (KingArt, KingCarWalls, ServoArt, HeldPitchArt; the lanes' through `view.art`; ChunkLift reads pitch_deg for geometry, right).
- FOUND 05:00 on the trial merge, King fight combo 64 px/m seed 2 (1500 frames, 0 SCRIPT ERROR):
  (a) VIEW's: PropOcclusion inked Rivet as a black kite over city's crate-stack card's see-through
  upper corners (the cut was the card's rect, `stand_rect`). (b) city's: the crate stack prints
  vermilion-orange from the King's first cone over it on (cream at f940, orange from f960, stays
  after the cone). If that is a hit/damage state it reads as a danger mark on the cover for the
  rest of the fight: NOTE to city below.
- MILESTONE 05:08 (a) fixed on view's side: `ArenaPropCards.cut_polys` (city's `stand_polys` when
  present, else the area quad: today's behaviour) and PropOcclusion intersects the silhouette with
  each outline (prop_occlusion.gd stays 204 lines; the cut computed once per prop with a hit).
  FILMED with a PROTOTYPE of city's function written into the trial tree only (never city's
  branch): `prop_occlusion_card_outline_before_after_combo_64ppm.mp4` + `_f940_f1100.png`. LOOKED:
  before, the kite beside the top crate at f1000-1100; after, gone; at f1040 where Rivet is behind
  the top crate the ink shows inside the crate. Test +1 (fallback quad). DECISION line.
- REQUEST to city: add `static func stand_polys(kind: String, r: Rect2) -> Array` to PropCards (or
  a helper your prop_cards.gd calls; it is at 200 lines): the card's opaque outline(s) in
  `stand_rect(kind, r)`'s space, as PackedVector2Array each. The prototype I filmed (trial tree
  only): the facing cell `cards.facing(t, 0 if r.size.x >= r.size.y else PI/2)` of `_strip[t]`,
  `BitMap.create_from_image_alpha(cell image, 0.5)`, `opaque_to_polygons(Rect2i(0, cell), 2.0)`
  cached per (t, facing), each point mapped `rect.position + (u * rect.size.x, v * rect.size.y)`
  with u mirrored when `f.y == 1`. view's side (n8-view, this commit) picks it up by method
  presence; nothing else to wire. Repro: `--boss=king --bot=boss --bot-human --seed=2 --boss-cam
  --ppm=64 --view=combo --rigs`, f960-1100.
- NOTE to city: the arena's crate stack turns vermilion-orange when the King's cone first covers it
  (f960, seed 2) and stays: if intended (a danger/damaged state), fine; if not, the colour law
  keeps vermilion for danger marks, objectives, Rivet's collar and the King's cape.
- GATE 05:12 at ba67b4a2: unit full no-arg 1517 passed / 0 failed, 0 FLAKY (`unit-it13b.log`);
  scenarios 52 ran, 0 failed (`scenarios-it13.log`; vehicle drive timing CONTENDED, passes); lint
  15/15 (hook). The trial tree's prototype reverted (`git checkout --` on the three files).
- Registry rules applied it13: concept-scene-parity (the occlusion fault seen only on the merged
  tree with city's cards: judged where the art meets the code), depth-ordered-layered-art (a hidden
  body's ink bounded by the occluder's real silhouette, not its bounds), motion-quality-gating (both
  fixes judged over 200+ frames in motion, before/after, same seed), generative-artifact-gating (no
  new art; the held fix changes selection only, not the frozen art), combat-pacing-and-dramatic-arc
  (n/a this iteration), perf-regression-gating (the outline cut computed once per prop with a hit;
  city's prototype caches the bitmap polys per facing).
- MEASURE 05:14-05:21 mutation test of arena_prop_cards.gd (`--tests=test_arena_prop_cards`):
  first --max=10: 4 killed / 6 survived (40 %), none on the new cut_polys lines (not sampled). Added
  a stub-of-city's-script test (014ddf54: outlines kept, degenerate dropped, quad without
  stand_polys). Re-run --max=14: 6 killed / 8 survived (42.9 %); the new filter line 84 (`>= 3`)
  killed. The 8 survivors are the city-only paths that n8-view cannot run without city's script:
  `draw` (39/40/45), the method detection (105), `_crate_w_m` (25), `_has_polys` default (23),
  `not CARD.has` (32). They are covered on the merged tree by city's own PropCards tests + film;
  a stubbed `draw_named` test would kill 39/40/45: owed, low value.
- Session close 05:22: tree clean, every change committed. Commits it13: 04429dee (held art key),
  bd55a29b (evidence), 01865f0e (REPORT), ba67b4a2 (occlusion card outline), 02ead854 (evidence),
  014ddf54 (test). Scratch .avi deleted.
NEXT (iteration 14, in order):
1. Read city's JOURNAL for the stand_polys REQUEST and the crate-colour NOTE; when city lands
   stand_polys, merge-check it on the trial tree (re-run trial_merge.sh on the newer heads) and
   film the King fight combo 64 px/m seed 2 f900-1110 on the real code (replace the prototype
   film in frames.json).
2. Other lanes' journals for REQUESTs to view; the library for new 70 sheets in view's cast.
3. Quality pass on the merged tree: quest 1 under tilt70 and the Servo depot under combo at
   64 px/m, looking for view-owned draw-order faults with the lanes' newest art (as this one).
4. The freeze (08:30): delete the trial tree (`git worktree remove` on
   %TEMP%/view-trial-it11), director reel top + combo on n8-view, evidence run --no-bench, the
   exe, REPORT final.

## Iteration 14 (05:21-06:21, BUILD)
Read: JOURNAL, git log, the four lane journals. city: no answer yet to the it13 stand_polys
REQUEST or the crate-colour NOTE (its last session closed before 05:08). vehicles it19 (l.1223):
REQUEST to view: the Servo bay numbers need an ink stroke or dark backing (bay 3 fades over the
cream stage van roof at 32 px/m). street, hud: no new REQUEST to view.
- 05:22-05:26 TRIAL MERGE refreshed on the newest heads (n8-view 0afbbefa + city aa795463, street
  82c6f40c, vehicles 2bccd4d1, hud c36dac9e; `trial_merge.sh`, view's side on conflicts as it11),
  `--import` exit 0.
- MILESTONE c3deecd3 ANSWER to vehicles (it19 REQUEST): under a card view (marks_apart) the bay
  number draws an ink stroke (`ServoDepotDraw.NUMBER_INK_M` 0.12 m, >= 3 px) under a paper fill at
  0.9 (was 0.6); flat views run the same single call with the same args (top unchanged). Chose the
  stroke over a dark backing plate (a second box on the apron reads heavy on the bare floor).
  FILMED on the trial merge with vehicles' cream van: Servo depot combo 32 px/m seed 2, 200 frames
  before/after, 0 SCRIPT ERROR each. LOOKED f130: before, bay 3's "3" is gone on the cream roof;
  after, it reads (ink-ringed paper); bays 1, 2, 4 on the bare floor read a touch firmer, not heavy.
  Masters: `servo_bay_number_ink_combo_32ppm_seed2_f130_before_top_after_bottom_x2.png` (+ the
  full-frame pair). No unit test: a draw-only change (a recorder would need a canvas); the film is
  the proof. Lint 15/15. DECISION view/servo bay number ink.
- 05:29-05:31 QUALITY PASS on the merged tree (NEXT 3). Servo depot combo 64 px/m seed 2, 900
  frames (`--bot-human --boss-cam`), 0 SCRIPT ERROR: LOOKED at f150-880 (6 frames): the HUD boss bar
  covers the bay numbers (right), the van sits under the marks, Rivet/ghost/Servo order holds;
  nothing view-owned misplaced. Quest 1 tilt70 32 px/m stills 600/2400/6000/13700 (shipped path):
  the street stands at 70; at 13700 (Dock 9) the dead "cops" at the crossing were TOP-DOWN parts.
- FOUND 05:33-05:38 (view's): quest 1's fighters are Fighter GUARD contractors (CombatArena.
  spawn_guard: the hi-vis dock guards with rifles, street's StreetQuestCards.draw_guard/draw_down
  cards on the sprite path). Since it7 view's rig cast is the shipped path under card views and
  ArenaRigs dresses every hostile as BodyPlan COP: BLUE POLICE at Dock 9 (colour law: police blue
  for police only). And on the merged tree their deaths throw SCRIPT ERRORs: Dock 9 ticks
  13560-13900 tilt70 48 px/m = 102 x "Trying to assign invalid previously freed instance" at
  street_walker_cards.gd:91 (StreetWalkerCards.step, the typed `for c: CanvasItem in HID` loop over
  a rig item freed after the fall card hid it), and the corpses fall to gore blobs. Checked on a
  throwaway n8-street-alone tree (%TEMP%/view-street-check): the sprite path draws the hi-vis
  guards standing and lying, no rig.
- MILESTONE 105961e2 `QuestGuardCast.ON`: under quest 1's rig cast the contractors stay on the cast
  view (ArenaRigs skips them; CastView draws them through its own loop, street's cards on the
  merge, and `_rivet` steps out for the rigs); Rivet, Mertz and the dev arena keep their rigs.
  FILMED on the trial merge, Dock 9 ticks 13560-13900, tilt70 48 px/m, 1920x1080, before (ON
  false: 102 SCRIPT ERROR) / after (0 SCRIPT ERROR):
  `quest1_dock9_guards_cast_before_after_tilt70_48ppm.mp4` + `_t13840_crop.png`. LOOKED: before,
  blue cops and gore blobs where they die; after, hi-vis contractors stand, shoot and lie drawn,
  Rivet on his card. Depth: the guards no longer interleave with Rivet's rig (they shoot from
  range; no overlap in the 340 ticks). Unit test_quest_guard_cast 3 cases (+ story forms, slice
  closure 15/0). Debt: cast_view.gd 225 -> 229 accepted with the reason. DECISION line.
- REQUEST to street: `StreetWalkerCards.step` (street_walker_cards.gd:91) assigns through a typed
  `CanvasItem` loop over the HID list, and a rig item it hid can be freed later (as `release()`
  already guards with is_instance_valid): on the merged tree a dying COP rig with the cop fall
  grid threw 102 SCRIPT ERRORs in quest 1 Dock 9 (repro on the trial merge with
  `QuestGuardCast.ON = false`: `-s res://dev/frames/quest1_clip.gd -- --ticks=13560-13900
  --view=tilt70 --ppm=48`). View no longer sends quest 1's guards there, but any rig whose part
  is freed mid-fall (a dropped gun?) hits it: `for c: Variant in ...: if is_instance_valid(c):`.
- GATE 05:49 at 2ee50990 (code as 105961e2): unit full no-arg 1521 passed / 0 failed, 0 FLAKY
  (`unit-it14.log`); scenarios 52 ran, 0 failed (`scenarios-it14.log`; vehicle drive timing
  CONTENDED, passes); lint 15/15. Trial merge (05:26 heads + QuestGuardCast): director reel top
  19/19 and combo 19/19 chapters all down, 0 SCRIPT ERROR (`director-reel-it14-trial-*.log`).
  MEASURE mutate quest_guard_cast.gd (--tests=test_quest_guard_cast): 5 killed / 0 survived (100 %).
  Also filmed n8-view ALONE quest 1 13700 tilt70 48 px/m: the contractors draw as flat top-down
  hi-vis sprites until street's cards merge (`quest1_dock9_guards_cast_n8view_alone_*_crop.png`).
  frames.json: the Dock 9 contractors pair in at #5; servo_combo_art_key out (file stays).
- CORRECTION 05:51: Mertz was never on a rig in quest 1 (ArenaRigs skips the quest's BOSS; CastView draws him): QuestGuardCast leaves him as he was. The decision line now says so; the 105961e2 message's "Mertz ... keep their rigs" is loose wording.
- 05:52 city answered the it13 REQUEST: `PropCards.stand_polys` (n8-city 8c982682, parse fix
  55ede50c). TRIAL MERGE rebuilt 05:53-05:56 on n8-view 3aa2b05a + city 55ede50c, street f67f272b,
  vehicles cf72cfc4, hud 19924999 (view's side on the known conflicts), `--import` 0.
- MILESTONE 05:57 the occlusion cut on city's REAL outlines (NEXT 1): King fight combo 64 px/m
  seed 2 (`--bot-human --boss-cam`), 1110 frames, 0 SCRIPT ERROR. LOOKED f940-f1100 every 20 at
  the crate stack: no black kite in any frame (it13's fault), at f1040 Rivet behind the top crate
  shows his ink only inside the crate; the stack stays cream under the King's cone (city's colour
  fix: the it13 NOTE is closed). Masters
  `prop_occlusion_city_stand_polys_real_combo_64ppm_seed2_f940_f1100_every20.png`; frames.json's
  occlusion entry notes it (the prototype pair stays the before/after). No code change on view's
  side: the method-presence bridge picked it up as built.
- Registry rules applied it14: concept-scene-parity (all three findings judged on the merged tree,
  where the lanes' art meets view's code: the van under the number, street's contractors under the
  rig cast, city's outlines under the cut), depth-ordered-layered-art (marks over the vehicles
  band; the guards' order traded for identity, written as the cost), motion-quality-gating (Dock 9
  340 ticks and the King fight 1110 frames in motion, before/after same seed), generative-artifact-
  gating (no new art), combat-pacing-and-dramatic-arc (n/a: no sim change), perf-regression-gating
  (no new per-frame work: the stroke is one draw call per bay, the guards' draw moves, not adds).
- GATE 05:59 director reel on the 05:56 trial merge (city's stand_polys in): top 19/19 and combo
  19/19 chapters all down, 0 SCRIPT ERROR (`director-reel-it14b-trial-*.log`).
- Session close 06:00: tree clean after this commit. Commits it14: c3deecd3 (bay number ink),
  92a3de77, 105961e2 (QuestGuardCast), bc84c69e, 2ee50990 (REPORT), c308f040 (evidence), 3aa2b05a
  (decision wording), this one. Scratch .avi deleted; the throwaway tree
  %TEMP%/view-street-check stays until the freeze (remove with the trial tree).
NEXT (iteration 15, in order):
1. Other lanes' journals: street's answer to the street_walker_cards.gd:91 REQUEST (if street
   ships dock-guard RIG looks instead, put the contractors back on the rigs: QuestGuardCast.ON
   false); vehicles/city on the bay number and stand_polys notes.
2. Quality pass on the merged tree still owed: the city drive at tilt70 64 px/m (view's lead +
   the lanes' cars), quest 1 under combo at 48 px/m (the contractors' corpses pile up all quest on
   the cast path: street's sprite-path behaviour; judge if it reads as a mess at Dock 9, 15000).
3. The freeze (08:30): `git worktree remove` %TEMP%/view-trial-it11 and %TEMP%/view-street-check,
   director reel top + combo on n8-view, `evidence/run.mjs --no-bench`, the exe, REPORT final.
