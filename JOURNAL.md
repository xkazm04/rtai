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
