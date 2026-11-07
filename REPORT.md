# n8 street: the street cast under the angled view (REPORT, DRAFT at iteration 12)

DRAFT: written 05:20, updated 06:25 (it12) so the freeze has a base. The freeze iteration (08:30) completes the gates,
the exe command lines and the final evidence numbers. Lane journal: `JOURNAL.md`. Stills and clips:
`C:\Users\kazda\kiro\gtai-masters\n8\street\` (`frames.json`, 15 entries, best first;
the combined clip `street_combined_tilt70_50s.mp4`).

Judged at `--view=tilt70` (play), `--view=combo` (boss fights) and `--view=tilt` (p55: boss arenas,
quest 1 when Mertz engages). `top` (the default) draws today's art: every street change is
selected by the view row's art key (`p70` / `p55`) or `cards`, never by a pitch.

## What works (with evidence)

- **Cops**: patrol, riot and SWAT head-and-chest cards at p70 and p55, navy (the cop-tone default;
  police blue one argument away). The riot shield stands as an opaque frosted plate.
  `riot_shield_plate_before_after_tilt70_64ppm_reactline_t4.png`.
- **Quest 1's patrol cops** stand as a whole-figure card (it10), face their walk, and (it11) **walk
  on the REQUESTed cop_patrol_walk grid** at 70 and 55, the strip's blue matched to the card's
  navy (`tools/art/street_tone.py`). `quest1_patrol_cop_walk_frames_tilt70_48ppm_t600-760.mp4`.
- **The robot thug**: lit steel plates and eyes, not an ink mass; powers down and lies as drawn
  (thug_fall 70/55). `thug_drawn_fall_before_after_tilt70_48ppm_x2_ohmbeat.png`.
- **Pedestrians**: the nine types as whole-figure walkers with stride frames at p70; at p55 the
  still figures cut from the 55 sheets (no 55 walk strips), bobbing; mild crowd variety (scale
  +-8 %, value +-7 %).
  `peds_walkers_tilt70_64ppm_board_t120.png`.
- **Contractors** (quest 1 dock): standing cards and drawn corpses at both pitches, one body
  length at every pitch. `contractor_drawn_corpse_before_after_tilt70_48ppm_x2_quest1_dock9.png`.
- **Hit reactions and deaths at height**: cops, riot, SWAT, thug and peds buckle, fall and lie as
  drawn at 70 and as their own 55 drawings at p55; the corpse lands where the body was.
  (it12) The people lie as the library's round-0630 redraws (lying frames drawn long, no post
  stretch) and every back corpse is the 3/4-away one: before, a pedestrian killed from the front
  lay as a figure that read as a person standing on the lane. The patrol cop keeps its navy when
  it dies (the fall grid toned to its card).
  `peds_long_fall_back_corpse_before_after_tilt70_32ppm_board_t150.png`,
  `peds_long_fall_frames_before_after_tilt70_64ppm_t59-150.png`.
  `cops_drawn_fall_before_after_tilt70_64ppm_board_t62-150.png`,
  `cops_riot_swat_p55_falls_before_after_tilt_64ppm_board_t65_t150.png`.
- **Far corpses** (the baked crowd atlas): every DEATH cell is drawn under the card views: 0.1 s
  the drawn mid-fall, then the lying body (it10 + it11), instead of a top-down stump cut at the
  shoulders. `riot_atlas_corpse_drawn_before_after_tilt70_48ppm_x1.4_f1200.png`,
  `riot_atlas_death_frames_before_after_tilt70_48ppm_x2_f100-124.png`.
- **The crowd's cost** (400-actor riot, 3 alternating pairs, bench.lock held, CONTENDED: other
  lanes' Godot up): avg frame 5.31 -> 5.65 ms (+0.33, +6 %), draw calls 685 -> 778 (+93), 0
  hitches over 50 ms either way. `evidence/street-bench-it10/summary.json`.

## What does not (yet)

- **Kronk's cultists and Torque's gang**: the library has their sheets and falls (B), but nothing
  spawns them in the game tonight, so there is nothing to judge in motion.
- **City cops still glide** on head cards over parts (only quest 1's patrol cops use the walk
  grid). Scouted for it12: walk while no gun is out, the parts when it comes out (a pop to judge).
- The city seed-5 corpse "black bar" was the blood's head mark (view, it12), fixed on n8-view.

## Calls for the owner

1. **Cop tone**: navy (BUILT) vs the sheets' brighter police blue.
   `call_cop_tone_navy_vs_policeblue_tilt70_48ppm_x1.5_reactline_t5.png`.
2. **Crowd variety**: mild (BUILT, SCALE_VAR 0.08 / VALUE_VAR 0.07) vs strong (0.16 / 0.14).
   `call_crowd_variety_mild_vs_strong_tilt70_48ppm_x1.5_board_t4.png`.
3. **The contractor's hi-vis orange** near vermilion: kept (the approved concept) vs a dull ochre.
4. **The walkers**: whole-figure cards with stride frames (BUILT) vs head cards over parts
   (`StreetWalkerCards.ENABLED = false`).
5. **Far deaths**: mid-fall then corpse (BUILT, `StreetCrowdCorpse.FROM_FALL` [1,2,2,2]) vs the
   corpse at once ([2,2,2,2]).
6. **The people's falls**: the round-0630 long redraws with the 3/4-away back corpse (BUILT,
   `StreetWalkerFall.LONG = true`) vs the it9 grids post-stretched 1.3-1.5 (`LONG = false`).
   `peds_long_fall_back_corpse_before_after_tilt70_32ppm_board_t150.png`. The contractor's redraw
   was judged worse at quest 1 Dock 9 (puffier, loses its dropped rifle) and is not used.

Exe command lines: (freeze) `RTAI.exe --arena=city --rigs --view=tilt70`, quest 1
`RTAI.exe --view=tilt70`, the boss fights `--boss=king --view=combo`.

## Gates

(freeze) lint, unit, scenarios, `node tools/evidence/run.mjs --no-bench`, the director reel under
`top`, `tilt70` and `combo`.

## Next steps

(freeze)
