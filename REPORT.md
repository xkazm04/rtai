# n8 view lane: REPORT (DRAFT it11, 03:25; final at the freeze)

Lane `view`, branch `n8-view`. Evidence: `C:\Users\kazda\kiro\gtai-masters\n8\view\` (`frames.json`,
15 entries, best first; the combined reel `view_set_combined_n8_it11.mp4`, 86 s). Repo evidence
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
   the King-down return seen live with Ohm (`king_down_return_ohm_combo_*.mp4`) and with Tonnage in
   form (`tonnage_king_down_swap_combo_{32,64}ppm.mp4`, dev flag `--ghost-at`).
6. **The camera at 70**: city on foot and driving (`city_{foot,drive}_top_vs_tilt70_32ppm.mp4`); the boss
   camera keeps the King's lifted crown under the bar (`boss_cam_*`); quest 1 ships the rig cast under
   a card view (`quest1_dock9_shipped_*`); the camera lead at driving speed filmed on the real
   CameraRig (`lead_combo_vs_combo_lead_{15,25}mps_48ppm_t150.png`).
7. **Draw order**: Tonnage's legs in the depth sort (order probe 0/9 wrong at 70); the King's accents in
   the order probe; the King on foot behind his wreck (car pairs 10/10 wrong -> 0/10); PropOcclusion
   (a rig behind a prop shows through it).
8. **Frame cost combo vs top**: see the table below (release export: the city drive; the King fight
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

## What does not work / not done
- Servo has no p70 PART sheet (the parts are top views); p70 uses the p55 parts. Servo is a boss
  (55 under combo), so this only shows under `tilt70`.
- Quest 1 under tilt70 on this branch draws the street and the city top-down: their cards and lifts are
  on `street` and `city`. Judge quest 1 after the merge.
- The King fight in a release export cannot be benched (its bot is dev-only).

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

## Merge notes for the Director
Trial merge it11 (03:15-03:40, a throwaway detached tree): city, street, vehicles and hud onto
n8-view; lint 15/15, unit 1624/0, quest 1 at tilt70 0 SCRIPT ERROR.
- Text conflicts in view-owned or co-written files are comment lines: take view's side
  (`rig_card_sets.gd` doc line, `arena_floor_view.gd` doc lines, `quest1_clip.gd` `--view` line).
  JOURNAL.md: keep each lane's; `tools/debt/baseline.json`: either side, then `debt.mjs --update`.
- hud: `StoryForms.fold_rigs` duplicates view's `StoryForms.follow` (same fold; follow also lifts
  and voices). Take view's side in `story_forms.gd`, `quest1_game.gd`, `test_story_forms.gd`; hud's
  test case lives on in view's follow test.
- city + hud: `BossView.attach` becomes 41 lines (gd-size) with no text conflict; move city's
  `BossDressing.attach` call into `static func _dress(v: CollectCallView, hook: BossHook)`.

## Exe
(at the freeze: `build/export/windows/RTAI.exe`, the int-day recipe)

## Next steps
(at the freeze)
