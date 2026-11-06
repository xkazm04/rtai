# d8 lane view70: the 70-degree sample and the combined view (final, freeze 18:30)

Evidence: `C:\Users\kazda\kiro\gtai-masters\d8\view70\` (`frames.json`, 15 entries, best first).

## What works (with evidence)
- **Two new view rows**, data only (`project/data/tables/view.json`):
  - `tilt70`: the `tilt` row's switches (cards, cast shadows, occlusion) at 70 degrees, with art `p70`;
  - `combo`: 70 degrees in play, easing to 55 while a boss is engaged, and back to 70 when it goes down.
    `ease_s` 1.0 (smoothstep, on sim ticks, so it holds during a hit-stop), `boss_art` p55, `swap_deg`
    62.5, `fade_deg` 5. Studies `combo_ease08` / `combo_ease12`.
- **Art per pitch, side by side**: `features/characters/art/view/p70/` (Rivet head, King bust) and
  `features/souls/art/view/p70/tonnage_card.png`, beside chars' `p55/`. Selected by the view row's
  `art` (chars' `RigHeadCard.rows_of`, `GhostCard`); never hard-coded 55.
- **The combined view's card swap** sets `ViewMode.art` live and cross-fades Rivet, the King and
  Tonnage's cards over 5 degrees. Card-region pop measured frame by frame: no spike above the
  moving-ground floor (`combo_fade_p70_to_p55_rivet_frames20-43_x3.png`).
- **The films**:
  - the King fight, seed 2, at 55 | 70 | combo, 32 px/m, 46 s;
  - the city block at 55 vs 70, 46 s;
  - King and Rivet close-ups at 64 px/m;
  - Tonnage at 48 px/m;
  - the 0.8 / 1.0 / 1.2 s ease clip.
- **Gates** (iteration 2):
  - lint 15/15;
  - unit 1428/0;
  - scenarios 52/0 with the replay identical;
  - the director reel 19/19 down, 0 SCRIPT ERROR, under tilt70 and under combo;
  - `top` is bit-identical with main: 900/900 frames, framemd5.

## Measured, 70 vs 55
- **Ground depth on screen** at 32 px/m: 26.6 m at 70 vs 30.5 m at 55. So 55 shows 14.7 % more depth
  (checked on the stills); the width is the same.
- **Frame cost** (exported bench, city drive_dense, 2 x 30 s, CONTENDED; not re-taken at 18:13: two other lanes' freeze gates were running):
  - average frame 1.08/1.18 ms at 70 vs 1.15/1.10 ms at 55, a wash;
  - draw calls 372 vs 575. They follow the visible area: tilt70 zoomed out to 55's depth draws 602-606
    calls, repeated twice. No feature is switched off at 70.
  - 70 sees 10 % fewer people (25.4 vs 28.4 visible on average).

## Iteration 3 (bosses merged)
- **combo at 55 now equals tilt**: bosses' court King, throne-car and gang (d8-bosses merged,
  5639148f; `ViewPitchCourt`, ae847c59). After landing, combo and tilt frames differ in about 1000
  pixels out of 1 million (mean 0.025).
- **The return trip cross-fades too.** Until ae847c59, every card rebuilt after a swap was missed:
  the rebuilt card is renamed while the old one frees. So the 55 -> 70 return was a hard swap.
  Measured now: no spike above the motion floor
  (`combo_return_fade_vs_swap_king_frames1150-1186_x2.png`).
- **One bell at 70** (4eca94b0): the p70 King bust draws the bell, so the rig's horn part hides.
- **Gates on 4eca94b0**:
  - unit 1447/0;
  - scenarios 52 passed;
  - director reel 19/19 all down, 0 SCRIPT ERROR, under tilt70 and under combo;
  - `top` 900/900 frames identical with main;
  - lint 15/15;
  - a trial exe export and smoke run under combo.

## Iteration 4 (chars + bosses merged again, the 70 King made whole)
- **Merged** d8-chars (street p55 heads, SWAT helmet, Kerf v2 card, ghost depth sort) and d8-bosses
  (Servo parcels as boxes) at 16:43; unit 1456/0 on the merge.
- **The 70 King at close range** (2316e44f): the p70 bust also fills bosses' KingArt `p70/` slot, and
  the court limbs are copied there (`p70/parts`). So at 70 the flat drawn cape fan behind the bust
  is gone, and the King has the same gilded press arm and court limbs as at 55: 55 vs 70 now
  compares the pitch, not two art sets. The bust draws at the same size (its cells are padded by
  KingArt's 1.5 width factor; a unit test guards it).
  - The King's gang (95109a45) and throne-car (f2361702) at 70 also draw bosses' court art, so the
    two pitches show the same art set.
  - Before/after: `king_car_gang_55_vs_70_32ppm_t40_before_it4.png` and
    `king_rivet_onfoot_55_vs_70_64ppm_t9_it3.png` (before: the fan, print limbs, pale gang) vs the it4
    films and stills.

- **Films re-taken on 95109a45** (swap default, both merges, the 70 King and gang): the King trio
  (46 s), the 64 px/m pair, the city pair, the ease study; 10 films, 0 SCRIPT ERROR. The King trio
  and the 64 px/m pair were re-taken again on f2361702 (the throne-car at 70): at t40 all three
  panels show one art set; at 70 the throne back shows above the seated King, at 55 the bigger bust
  covers it (`king_55_70_combo_32ppm_t40_it4.png`).
- **Gates on iteration 4**: lint 15/15 on every commit; unit 1456/0 on the merge (the final run is
  in JOURNAL); scenarios 52 passed; director reel 19/19 all down, 0 SCRIPT ERROR, under tilt70 and
  combo; `top` 900/900 frames identical with main (list md5 6e865449 both).

## Iteration 5 (the freeze)
- **Merged** d8-bosses (8dbbbcf0: a live pitch change re-dresses the court card, for combo) and
  d8-chars (2dd6e236: `RigHeadCard.drop` renames the dropped card = view70's it3 REQUEST; the p55 cop
  cap and riot cards; ghost host depth; Kerf's lean) at 17:41.
- **Gates on afbdee5b** (the code tip: the merges plus one test fix):
  - `node tools/evidence/run.mjs --no-bench`: ALL PASS: lint 15/15, unit 1462/0, scenarios 52/52
    (city_chase missed its budget under contention, passed re-judged alone), parity bit-exact
    (planted mutation caught at step 629), selftest (look goldens 11/11, block goldens 5/5),
    export-audit 548 loaded / 0 failed;
  - the first evidence run (on 4fffaf24) failed one unit test, mine: `test_view_pitch` assumed p55
    draws the base cop cap strip, which chars' merge changed (their p55 cop card). The code was
    right; the test now compares p70 with p65, a folder with no art (afbdee5b);
  - director reel 19/19 chapters fully down, 0 SCRIPT ERROR, under tilt70 and under combo
    (`evidence/it5/reel_*.log`);
  - `top` bit-identical with main: King fight seed 2, 32 px/m, 900/900 frames framemd5 equal (list
    md5 6e865449 both);
  - the combo return (the King dying, 55 -> 70) frame by frame at 48 px/m after bosses' re-dress
    merge: no flicker, one card swap at tick 1168
    (`evidence/it5/combo_return_king_dying_48ppm_frames1138-1185_it5.png`). The drawn cape fan shows
    through the ease (the known gap below).

## Not done / owed
- **The 70 sample is narrower than the 55 cast.** Drawn from the 70 sheet: Rivet's head, the King's
  bust and Tonnage's card. At 70 the King's limbs, gang and throne-car reuse bosses' 55 art (the
  limbs and the car are pitch-agnostic; the gang's card is the 55 drawing). The car came last
  (f2361702, after bosses moved their test to 65).
- **The street heads at 70 are today's.** chars' p55 street cards (SWAT, the patrol cap, the riot
  helmet, peds, thugs) have no p70 rows, so the city pair compares two street art sets for the
  humans (Rivet and the cast are matched). REQUEST to chars in JOURNAL: a `p70` row that points at
  the p55 strips (the 55 drawing at 70, as the King's gang does) until 70 street sheets exist.
- **Under combo, during the 1 s ease, the King's drawn cape fan shows** (KingArt keys by the live
  pitch rounded, and no strip exists for 56-69), and the gang chains switch when the pitch rounds
  to 55. The King is off screen at the engage in every seed tried (1-5); at the return he is dying.
  Seen at the freeze (48 px/m, frames 1138-1185): the bust card stays the court bust and swaps once,
  but the fan shows from the first frames off 55 to the end of the ease. bosses' 8dbbbcf0 re-dresses
  the card when the pitch moves, but still keys by the live pitch; keying KingArt by `ViewMode.art`
  closes it (REQUEST; the fan is drawn in their body `_draw`, out of my files' reach).
- **Tonnage's ghost cross-fade** under combo is unit-tested, but not seen live: no seeded fight has
  Tonnage on screen when the King goes down.

## Calls for the owner (default built, how to see it)
1. **Pitch per situation**: 55 vs 70 vs combo, for the city and for boss fights. Built: all three rows;
   `top` stays the default.
   - See: `king_55_70_combo_32ppm_46s_it4.mp4`, `king_rivet_onfoot_55_vs_70_64ppm_16s_it4.mp4` and
     `city_55_vs_70_32ppm_46s_it4.mp4`.
   - Exe: `RTAI.exe -- --view=tilt`, `--view=tilt70`, `--view=combo`.
2. **Transition length**: 0.8 / 1.0 / 1.2 s. Default 1.0.
   - See: `combo_ease_08_10_12_defeat_55to70_32ppm_it4.mp4` (hard swap, the default).
   - Exe: `--view=combo_ease08` / `combo_ease12`.
3. **Cross-fade or hard swap** of the cards. Default since 16:40: **hard swap** (`fade_deg` 0 on
   `combo` and the ease studies). At 48 px/m the cross-fade drew a double head for about 4 frames;
   the swap changes once, inside the camera's pitch move. The cross-fade is one flag away:
   `--view=combo_fade` (`fade_deg` 5).
   - See: `combo_engage_fade_vs_swap_rivet_48ppm_frames22-42_x2.png` (the engage) and
     `combo_return_fade_vs_swap_king_frames1150-1186_x2.png` (King down).
4. **The bell on the p70 King bust**: built as the strip's own bell, with the rig's horn hidden (one
   bell, as bosses' 55 court bust does). The alternative is to crop the bell off the strip and show
   the rig's horn.
   - See: `king_rivet_onfoot_55_vs_70_64ppm_t9_it4.png`.

## The exe (exported at the freeze from afbdee5b, 18:02)
- `build/export/windows/RTAI.exe` (258 MB) plus `gtai_sim.windows.template_release.x86_64.dll`, in
  the worktree `C:\Users\kazda\kiro\gtai-wt\d8-view70`. Smoke: `RTAI.exe --quit-after 600 -- --boss=king
  --bot=boss --bot-human --seed=2 --rigs --view=combo` exit 0, 0 SCRIPT ERROR (`pitch ease 70.0 ->
  boss at tick 4`, `cards art p55 (pitch 62.1) at tick 35`); the same with `--view=tilt70`: exit 0,
  0 SCRIPT ERROR.
- Export: `"$GODOT_BIN" --headless --path project --export-release windows-showcase ../build/export/windows/RTAI.exe`
- See the same King fight in all three:
  `RTAI.exe -- --boss=king --bot=boss --bot-human --seed=2 --rigs --view=tilt` (55), `--view=tilt70`
  (70), `--view=combo` (70 in play, easing to 55 when the boss engages).
- Close range: add `--ppm=64 --phase=3` (the King on foot). The city: `RTAI.exe -- --arena=city --bot=rivet --seed=2 --rigs --view=tilt|tilt70`.
