# n8 view lane: REPORT (the freeze, it17 07:50; no code after the it16 candidate: the gated build IS the freeze)

**Gates at cc76970c** (code = e369f4b0, it15's last code commit): `node tools/evidence/run.mjs --no-bench`
all PASS (lint 15/15, unit 1524/0, scenarios 52, parity exact + planted caught, selftest goldens
11/11 + 5/5, release-compile 561/0: `evidence/n8-view/evidence-run-it16.log`); the director reel
on n8-view HEAD top 19/19 and combo 19/19 chapters down, 0 SCRIPT ERROR; on the it16 trial merge of
all five lanes the same (`director-reel-it16-trial-*.log`). **Final trial merge it17** on the lanes'
freeze-time heads (07:44, n8-view + city 7d73de04, street 2de46fa1, vehicles 0f4810f0, hud f80e09ba):
lint 15/15, unit 1690/0, reel top + combo 19/19, 0 SCRIPT ERROR, no code conflict
(`evidence/n8-view/*-it17-trial.log`). `top` stays the default and draws
today's art: look goldens, replay and parity did not move.

Lane `view`, branch `n8-view`. Evidence: `C:\Users\kazda\kiro\gtai-masters\n8\view\` (`frames.json`,
15 entries, best first; the combined reel `view_set_combined_n8_it15.mp4`, 75 s, its first and last segments filmed on all five lanes merged). Repo evidence
under `evidence/n8-view/`. Full log: `JOURNAL.md`.

## What works (with its evidence)

1. **The view code is open to the lanes.** `RigCardSets.all()` merges every
   `data/tables/card_sets/<lane>.json` (`gtai.card-set/1`) over `RigCardSets.SETS`; street registers
   its heads there (`card_sets/street.json`) without touching view files. `RigDepthSort.on(layer)`
   hands later nodes the frame's visible rigs (city's occlusion and shadows use it);
   `ArenaPropCards.stand_rect` for city's prop cards; `ViewPitchCards.holders` for every per-pitch
   holder under combo.
2. **The owner's d8 values**, one value each, in `docs/decisions.md`: Kerf's card +20 % (`KerfRig.CARD_M`
   0.8 -> 0.96, lean kept; `kerf_card_before_after_tilt_48ppm.png`); the King's bust 2.0x
   (`KingArt.STRIPS["king"][2]`; 1.5 / 1.75 / 2.0 at 32 and 64 px/m: `king_bust_abc_{32,64}ppm.png`);
   no cape train (`KingCape.TRAIN_K` 0; `king_bust_cape_before_after_64ppm.png`). The gems, the
   throne-car, Servo's stand, the halos, Dent's tan and the 5+3 facings unchanged.
3. **Boss attack targets freeze at the wind-up** (`bosses.json aim_lock_at_windup: true`, every King
   and Servo attack): `king_ring_lock_before_after_combo_32ppm.mp4` (Rivet walks out of the frozen
   ring at 7.0-7.5 s; the King lands on it empty), `king_car_aim_lock_before_after_combo_32ppm.mp4`
   (the car's ram line and horn cone). Test `test_boss_lock_at_windup`. No replay golden moved (no
   scenario fights a boss).
4. **Rivet's death beat**: 1.0 s in his sprawl (`combat.json rivet.death_beat_s`), an ink veil over the
   last 0.4 s, lifted 0.3 s after the cut; quest stage and dev arena (`DeathBeat`, `DeathVeil`).
   `death_beat_before_after_combo_32ppm.mp4`; the length options side by side at 64 px/m:
   `death_beat_length_07_10_15_combo_64ppm.mp4`.
5. **Combo for the cast**: p70 cards for Ohm (A), Kerf (A, with p55's amber shoulder rings) and Dent
   (B, toned to the p55 tan) from the library's served 70 sheets; Servo keyed by the art key (under
   combo he drew today's top-down parts all fight: fixed, `servo_combo_art_key_before_after_32ppm.png`);
   `KingArt`, `KingAccents`, `KingCarWalls` keyed by `ViewMode.art_pitch()` (no drawn cape fan mid-ease);
   Rivet's held weapon picks its part by the art key too (it13: under combo the boss fight drew the
   top-down part made at 70 all fight; now `tilt`'s 55 part, swapped on the cards' frame; no art
   changed: `held_art_key_before_after_combo_48ppm.mp4`);
   the King-down return seen live with Ohm (`king_down_return_ohm_combo_*.mp4`) and with Tonnage in
   form (`tonnage_king_down_swap_combo_{32,64}ppm.mp4`, dev flag `--ghost-at`).
6. **The camera at 70**: city on foot and driving (`city_{foot,drive}_top_vs_tilt70_32ppm.mp4`); the boss
   camera keeps the King's lifted crown under the bar (`boss_cam_*`); quest 1 ships the rig cast under
   a card view (`quest1_dock9_shipped_*`); the camera lead at driving speed filmed on the real
   CameraRig (`lead_combo_vs_combo_lead_{15,25}mps_48ppm_t150.png`).
   it15: **quest 1's boss eases combo to 55 too.** Quest 1 had no arena hook, so Mertz's fight stayed
   at 70; now `ViewPitchQuest` eases to 55 while he is up and back to 70 when he is down (ease at
   tick 15270, back at ~16000): before/after on the merge `quest1_mertz_ease_before_after_combo_32ppm_merged_t15200_15600.mp4`, `quest1_mertz_engage_ease_combo_32ppm_t15000_15700.mp4`, on the
   merge at 48 px/m `quest1_mertz_combo_48ppm_merged_t15600_55_t16000_play.png`. `ViewPitchQuest.ON`
   false = 70 all quest.
7. **Draw order**: Tonnage's legs in the depth sort (order probe 0/9 wrong at 70); the King's accents in
   the order probe; the King on foot behind his wreck (car pairs 10/10 wrong -> 0/10); PropOcclusion
   (a rig behind a prop shows through it); it13: the silhouette cut to a card's opaque outline
   (`prop_occlusion_card_outline_before_after_combo_64ppm.mp4`); it14: re-filmed on city's REAL
   `PropCards.stand_polys` (n8-city 55ede50c) on the trial merge: no kite f940-f1100, the crates
   cream (`prop_occlusion_city_stand_polys_real_combo_64ppm_seed2_f940_f1100_every20.png`).
8. **A fresh corpse keeps its drawn fall** (street's REQUEST, it12): under a card view a body that
   dies on its full rig keeps it in a slot past the living 16 (at most 4), until it leaves the feed
   in the arena / quest 1 (no atlas there), 90 ticks in the city (then street's atlas lying frame).
   `arena_corpse_keeps_rig_before_after_tilt70_48ppm_seed5.mp4`. Dent's p70 card re-cut from the
   library's dent_v2 70 A (drawn tan): `dent70_v2_before_after_tilt70_64ppm_f160_f200_x2.png`.
   The Servo depot's bay apron marks draw over the vehicles band under a card view (vehicles'
   REQUEST, it11): `servo_bay_marks_over_van_before_after_combo_32ppm_f130.png` (+ `.mp4`).
   it14: the bay NUMBER gets an ink stroke under a firmer paper fill under a card view, so bay 3
   reads over vehicles' cream stage van at 32 px/m (vehicles' it19 REQUEST):
   `servo_bay_number_ink_combo_32ppm_seed2_f130_before_top_after_bottom_x2.png`.
   **Quest 1's contractors are hi-vis dock guards again** (it14, found on the merged tree): view's
   rig cast had dressed every quest fighter as a blue POLICE rig (colour law), and on the merge
   their deaths threw 102 SCRIPT ERRORs (street_walker_cards.gd:91) and fell to gore blobs.
   `QuestGuardCast.ON` keeps them on the cast view (street's drawn cards); Rivet keeps his rig:
   `quest1_dock9_guards_cast_before_after_tilt70_48ppm.mp4` (+ `_t13840_crop.png`).
9. **Frame cost combo vs top**: see the table below (release export: the city drive; the King fight
   in the editor binary, because the release export drops `dev/bots`).

## Frame cost (item 8)
- **City drive, release export** (`windows-bench`, drive_dense 48 px/m, 30 s x 2 per view, under
  bench.lock, CONTENDED by a GUT run and a render; `evidence/n8-view/bench-it11-drive/`): combo vs
  top render CPU 0.34 / 0.31 ms, draw calls 254 / 252, rig p50 0.57 / 0.44 ms, visible actors
  10.9 / 9.8. The same as it5's take: combo costs ~0.1 ms a frame.
- **King fight, editor binary** (`--boss=king --bot=boss --seed=2 --rigs`, 1500 ticks, vsync off,
  1920x1080, x2 alternated, under bench.lock, CONTENDED by one render; `evidence/n8-view/bench-it11/`):
  p50 top 4.96 / 5.17 ms, combo 3.81 / 4.06 ms; p99 top 11.1 / 9.9, combo 8.0 / 8.7. Combo was 3.3x
  top at it8 and 1.6x at it9; the held floor, the PropOcclusion and frame-rig fixes took it under top.

- **it16 re-take at the freeze candidate** (58dee013, under bench.lock, CONTENDED by three other
  lanes' Godot runs; `evidence/n8-view/bench-it16/`): drive render CPU top 0.31 / 0.29, combo 0.29 /
  0.30 ms; draw calls 252-253 vs 255; rig p50 0.43-0.45 vs 0.52 ms; King fight wall p50 top 4.64 /
  4.41, combo 3.16 / 2.94 ms, p99 8.4-8.9 vs 6.8. The drive's wall frame times paced at ~16.7 ms in
  both views (a 3 / 30 ms present alternation on the shared desktop): not a verdict.

## What does not work / not done
- Servo has no p70 PART sheet (the parts are top views); p70 uses the p55 parts. Servo is a boss
  (55 under combo), so this only shows under `tilt70`.
- Quest 1 under tilt70 on this branch draws the street and the city top-down: their cards and lifts are
  on `street` and `city`. Judge quest 1 after the merge.
- The King fight in a release export cannot be benched (its bot is dev-only).
- On n8-view ALONE quest 1's contractors draw as the flat top-down dock-guard sprites at tilt70
  (`quest1_dock9_guards_cast_n8view_alone_tilt70_48ppm_t13700_crop.png`); street's cards bring
  them up on the merge. They no longer interleave with Rivet's rig in the depth sort (they fight at
  range at Dock 9; no overlap seen).

- FOUND it17 on the final merge (not fixed): in the city block at tilt70 (seed 5, tick 900, 32 px/m)
  two dead cops lying just north of the kerb barrier draw their heads and shoulders OVER the
  barrier's top face (masters `FOUND_corpse_head_over_barrier_merged_it17_tilt70_32ppm_seed5_t900_crop3x.png`).
  Measured cause (07:52-07:55): after street's 90-tick hold the corpse leaves its rig for city's crowd
  atlas, drawn on the actors canvas over the whole world canvas; `CityCrowdOcclusion` patches lying
  crowd bodies (`LYING_HALF_M` 0.9) but only behind city's buildings, and view's `PropOcclusion`
  (the arena's kerb barriers, `wall_high`) only sees rigs. A lying-rig patch in PropOcclusion was
  tried (dead hits 2 -> 192 body-frames) and left the frame pixel-identical, so it was NOT landed
  (`scratch/view/prop_occlusion_lie_wip.gd`). The fix is one seam: hand the arena's tall props to
  CityOcclusion as occluders, or feed the crowd snapshot to PropOcclusion.

## Calls for the owner
(Each: options, the default built, how to see it.)
1. **The King's bust size.** Built 2.0x; option 1.75x (`KingArt.STRIPS["king"][2]`). See
   `king_bust_abc_32ppm.png`, `king_bust_abc_64ppm.png`. Exe:
   `RTAI.exe res://dev/arena/arena.tscn -- --rigs --boss=king --phase=3 --view=combo [--ppm=64]`.
2. **The death beat's length.** Built 1.0 s; options 0.7 s, 1.5 s (`combat.json rivet.death_beat_s`).
   See `death_beat_length_07_10_15_combo_64ppm.mp4` (three side by side). Exe:
   `RTAI.exe res://dev/arena/arena.tscn -- --rigs --boss=king --phase=3 --seed=2 --view=combo` and stand still.
3. **The attack lock.** Built: frozen when the wind-up starts (every boss attack); option `false` =
   d8's late lock (`bosses.json aim_lock_at_windup`). It makes every attack easier to dodge; if the
   fights get too easy, shorten the wind-ups instead. See `king_ring_lock_before_after_combo_32ppm.mp4`.
4. **The camera lead at driving speed.** Built `combo` (x1: 4.9 m at 15 m/s, 6.6 m capped at 25);
   option the `combo_lead` row (x1.5: 7.4 / 9.9 m), one value (`view.json lead_k`). See
   `lead_combo_vs_combo_lead_25mps_48ppm_t150.png`, `_15mps_`. Exe: `--view=combo_lead`.
5. **Quest 1's cast under the angled view.** Built: the rig cast (cards) when the view draws cards;
   option the sprite cast (`Quest1Game.RIGS_UNDER_CARDS` false), which lies flat on tilted ground.
   See `quest1_dock9_shipped_before_after_tilt70_32ppm.png`.
6. **Quest 1's Mertz as a combo boss.** Built: his fight eases to 55 like the arena bosses (it lasts
   ~12 s, so the 1 s ease each way is a large share of it); option 70 all quest
   (`ViewPitchQuest.ON` false). See `quest1_mertz_engage_ease_combo_32ppm_t15000_15700.mp4` and
   `quest1_mertz_combo_48ppm_merged_t15600_55_t16000_play.png`. Exe: `RTAI.exe -- --view=combo`, play
   quest 1 to Dock 9's crates ("Rated for Appliances").

7. **The boss fight's camera.** Built (as since d8): the follow camera; option `BossCam`
   (`--boss-cam`), which frames the boss with Rivet and keeps the King's lifted bust under the bar.
   With the follow camera the throne-car ramming from the top edge hides his bust under hud's boss
   banner (on the merge, combo 48 px/m, seed 2 f500-700): before
   `king_under_hud_banner_merged_it16_combo_48ppm_seed2_f500_560_620_700_crop.png`, after
   `king_boss_cam_merged_it16_combo_48ppm_seed2_f500_560_620_700.png` (the bust whole in all four).
   View's recommendation: BossCam. Exe: `RTAI.exe -- --rigs --boss=king --seed=2 --view=combo --ppm=48 [--boss-cam]`.

## Merge notes for the Director
Trial merge it11 (03:15-03:40, a throwaway detached tree): city, street, vehicles and hud onto
n8-view; lint 15/15, unit 1624/0, quest 1 at tilt70 0 SCRIPT ERROR. Re-run it12 (04:13, n8-view
b097c7a5 + city 7b63bcb1, street cfc90d46, vehicles 1b6740ac, hud 69c3b200): lint 15/15 with no
hand fix, unit 1639/0, director reel top + combo 19/19 all down, 0 SCRIPT ERROR.
- Text conflicts in view-owned or co-written files are comment lines: take view's side
  (`rig_card_sets.gd` doc line, `arena_floor_view.gd` doc lines, `quest1_clip.gd` `--view` line).
  JOURNAL.md: keep each lane's; `tools/debt/baseline.json`: either side, then `debt.mjs --update`.
- hud: `StoryForms.fold_rigs` duplicates view's `StoryForms.follow` (same fold; follow also lifts
  and voices). Take view's side in `story_forms.gd`, `quest1_game.gd`, `test_story_forms.gd`; hud's
  test case lives on in view's follow test.
- city + hud: `BossView.attach` was 41 lines (gd-size) at it11's heads; gone at it12's heads (lint
  15/15 on the merge with no hand fix).

- it14: trial merge refreshed 05:26 (n8-view 0afbbefa + city aa795463, street 82c6f40c, vehicles
  2bccd4d1, hud c36dac9e): the same conflicts as it11, view's side; director reel top + combo 19/19
  all down, 0 SCRIPT ERROR with QuestGuardCast (`evidence/n8-view/director-reel-it14-trial-*.log`).
  street's `StreetWalkerCards.step` loop at :91 got its guard (n8-street d61f48bc; checked it15 on the merge with `ON` false: 0 SCRIPT ERROR, was 102);
  QuestGuardCast keeps quest 1 off that path either way.
- it15: trial merge rebuilt 06:06-06:10 on n8-view a2745fe0 + city 814c0a4e, street 6d177df4,
  vehicles aa086daa, hud 610da507, then + n8-view 971fc2c5 (06:31): the same conflicts, view's
  side; the debt baseline: either side + `debt.mjs --update`. Director reel top + combo 19/19 all
  down, 0 SCRIPT ERROR (`evidence/n8-view/director-reel-it15-trial-*.log`). `ViewPitchQuest` adds
  one call in `boot/quest1_game.gd` `_casts()` (after `GhostAttackViews.attach_quest`): no other
  lane touches that function.
- it16: trial merge refreshed 06:56-07:04 (n8-view f4a95f31 + city f14b97c9, street 49b57ffb,
  vehicles 907d73b3, hud 38bc8bee): one CODE conflict, `boot/collect_call/view/cast_view.gd`
  `_draw`'s guard/corpse branch: take street's hunk whole (`StreetQuestCards.draw_guard` +
  `StreetQuestCorpses.draw`; view's `QuestGuardCast` branch above it merges clean). The merged file
  is 230 lines (229 on either side), so `debt.mjs --update` needs `--accept-regression`. Director reel
  top + combo 19/19 all down, 0 SCRIPT ERROR (`evidence/n8-view/director-reel-it16-trial-*.log`);
  quest 1 Dock 9 at combo 48 px/m: street's corpse decay and view's guard cast together, 0 SCRIPT
  ERROR (`quest1_dock9_merged_it16_corpse_decay_guard_cast_combo_48ppm_t14400_t15500.png`).
- it16 (look on the merge, not a regression): with the shipped follow camera, the King's throne-car
  ramming from the arena's top edge puts his bust under hud's boss banner at 48 px/m (seed 2 f500-700,
  `king_under_hud_banner_merged_it16_combo_48ppm_seed2_f500_560_620_700_crop.png`). `BossCam`
  (`--boss-cam`, off by default since d8) keeps the bust under the bar; its band `HUD_PX` (58 px)
  predates hud's paper banner (ends ~63 px) and crest (~88 px at the left). Next: make BossCam the
  boss fight's camera and read the band from `BossBar` after the merge.
- it17 (07:40-07:50, the final trial on the lanes' freeze-time heads; n8-view code = e369f4b0):
  + city 7d73de04, street 2de46fa1, vehicles 0f4810f0, hud f80e09ba onto the it16 merge: conflicts in
  JOURNAL.md / REPORT.md ONLY (each lane's own); the it16 `cast_view.gd` resolution (street's hunk)
  still applies if the Director merges from main fresh. `--import` 0 errors, debt-ratchet ok
  without an accept on this incremental merge, lint 15/15, unit 1690/0, director reel top + combo
  19/19, 0 SCRIPT ERROR; quest 1 at combo 48 px/m 0 SCRIPT ERROR
  (`quest1_merged_it17_freeze_heads_combo_48ppm_t2400_t13700.png`). vehicles' ada297fe (three p55
  cells mirrored, art + cutter) landed after this trial.
- it13: PropOcclusion reads city's `PropCards.stand_polys` by method presence (landed on n8-city
  8c982682 + 55ede50c, checked on the 05:56 trial merge); merge order does not matter, without it
  the cut stays the card's rect.

## Exe
`build/export/windows/RTAI.exe` (the `windows-showcase` preset: boots into the dev arena; embedded pck,
the native DLL beside it). **The freeze exe** was built 07:20 at cc76970c; no code changed after it
(`git diff e369f4b0 HEAD -- project native tools` is empty), so it is the freeze HEAD's build; re-smoked
07:39 with Call 7's line, 0 SCRIPT ERROR. Recipe (proven it16 06:55, 10 s, 0 errors):
`export APPDATA=C:/Users/kazda/kiro/gtai-n8/appdata/view; "$GODOT_BIN" --headless --path project --export-release windows-showcase ../build/export/windows/RTAI.exe`.
Smoke: `RTAI.exe -- --rigs --boss=king --seed=2 --view=combo` (eases to 55 at the engage, p55 cards).
Try: `RTAI.exe -- --rigs --boss=king --phase=3 --view=combo [--ppm=64]`, `RTAI.exe -- --rigs --boss=servo --view=combo`,
`RTAI.exe -- --arena=city --rigs --view=tilt70`, `RTAI.exe -- --rigs --view=combo_lead` (Call 4).

## Next steps
1. Servo's p70 PART sheet (his parts are top views; p70 borrows p55's): only `tilt70` shows it,
   because combo fights him at 55. REQUEST to assets if `tilt70` boss fights are ever wanted.
2. After the owner's Rivet pick: the whole-figure Rivet frames per pitch (p55 for bosses, p70 for
   play) register through `data/tables/card_sets/` like street's heads; the held-weapon parts keyed
   by the art key (it13) then retire.
3. The Calls for the owner (1-7) are each one value; flip the chosen ones on main after the merge.
4. Re-take the frame cost on an idle machine (every take tonight was CONTENDED by the other lanes).
5. Make `BossCam` the boss fight's camera (today behind `--boss-cam`) so the King's bust never rams
   under hud's banner, with its band read from `BossBar` (bar + paper + crest) after the merge.
6. The crowd's dead behind the arena's kerb barriers (it17 FOUND): view + city choose the seam
   (the arena's `wall_high` props as `CityOccluders` entries, or the crowd snapshot in PropOcclusion,
   which then also wants the lying-rig patch tried it17); film the city block at tilt70 seed 5 tick
   900 before/after.
