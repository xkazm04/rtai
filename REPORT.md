# d8 lane view70: the 70-degree sample and the combined view (DRAFT, iteration 2, 15:45)

DRAFT: the freeze iteration (18:30) updates the numbers, adds the exe and finalises this file.
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
- **Frame cost** (exported bench, city drive_dense, 2 x 30 s, CONTENDED):
  - average frame 1.08/1.18 ms at 70 vs 1.15/1.10 ms at 55, a wash;
  - draw calls 372 vs 575. The likely cause is a step in visible chunk rows, but this is unverified.
  - 70 sees 10 % fewer people (25.4 vs 28.4 visible on average).

## Not done / owed
- **The King's 55 art in the films** is still the lab bust on this branch: bosses' p55 King is on
  their branch, keyed by `roundi(pitch)` (REQUEST in JOURNAL). Under combo, a card rebuilt at 62
  degrees would keep the shared strip.
- **The King at 70 close up**: the cloth cape draws like a flag behind the bust card, and the bell
  shows twice (REQUEST to bosses).
- **Tonnage's ghost cross-fade** under combo is unit-tested, but not yet seen live.

## Calls for the owner (default built, how to see it)
1. **Pitch per situation**: 55 vs 70 vs combo, for the city and for boss fights. Built: all three rows;
   `top` stays the default.
   - See: `king_55_70_combo_32ppm_45s_merged.mp4` and `city_55_vs_70_32ppm_45s_merged.mp4`.
   - Exe: `RTAI.exe -- --view=tilt`, `--view=tilt70`, `--view=combo`.
2. **Transition length**: 0.8 / 1.0 / 1.2 s. Default 1.0.
   - See: `combo_ease_08_10_12_defeat_55to70_32ppm.mp4`.
   - Exe: `--view=combo_ease08` / `combo_ease12`.
3. **Cross-fade or hard swap** of the cards. Default: cross-fade (`fade_deg` 5); `fade_deg` 0 is the
   swap. Mid-fade, the p70 head and the p55 bust draw together for about 5 frames.
4. **The bell on the p70 King bust**: keep it, or crop it. Waiting on bosses' answer.
