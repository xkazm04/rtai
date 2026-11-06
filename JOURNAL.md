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
