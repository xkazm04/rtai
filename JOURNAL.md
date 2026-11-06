# JOURNAL - lane view70 (d8, 2026-11-06)

Branch `d8-view70` cut from main `0bea8b93`. Evidence: `C:\Users\kazda\kiro\gtai-masters\d8\view70\`.
Scratch: `C:\Users\kazda\kiro\gtai-d8\scratch\view70\`.

## 14:11 iteration 1 (BUILD)
- Read: AGENTS.md, view.json (tilt = 55 + cards + cast_k 1.2 already), view REPORT (cost table,
  owed items), ViewMode, RigHeadCard, ArenaHook, BossHook/BossCam, the angle sheets rivet_70 /
  king_70, NOTES.md (70: King's cape drifts brick red; Rivet's 70 is only a little steeper).
- Registry rules applied:
  - motion-quality-gating: judge the ease in motion, frame by frame; unfilmed = ?, no number made up.
  - depth-ordered-layered-art: the order is a measurement (--order-probe at 70 owed), every pose
    reachable (the ease passes every pitch from 70 to 55, not just the two ends).
  - generative-artifact-gating: the p70 cards are cut from real generated sheets; I look at every
    cut; provenance per asset.
  - sprite-and-atlas-production: a card strip is a set (5 frames, one cell, one anchor fraction).
  - concept-scene-parity: judged in the live path (the King fight, the city block), not on the sheet.

### REQUEST to chars (owner of RigHeadCard / ViewMode)
- REQUEST chars: please let `RigHeadCard` resolve its strip through the view row's `art` key
  (view.json, new optional string; schema already extended on d8-view70): path
  `res://features/characters/art/view/<art>/<file>` when that file exists, else the base path
  (my `ViewPitch.card_path(base, art)` does exactly this; feel free to call it or copy it).
  And a `RigHeadCard.retexture_all(root, art)` (or a signal) for the combined view, which swaps the
  art at a pitch threshold mid-fight. Until it lands I seed `RigHeadCard._tex` (the texture cache,
  keyed by the base path) from my own file `features/view_pitch/view_pitch_cards.gd` and re-texture
  the live `head_card` sprites; no edit of your files.
- REQUEST chars: ViewMode.pitch_deg is written live by my `ViewPitchEase` under `--view=combo`
  (70 in play, 55 in a boss fight). Everything in your view code that caches a pitch-derived value at
  build time (not per frame) will lag under combo; please keep pitch reads per frame, or tell me
  which ones cache.

### DECISION (also in docs/decisions.md)
- DECISION view70 art per pitch: a view row names an `art` folder (`p70`); the cards draw
  `art/view/p70/<card>` when it exists, else the base (55) card. So 55 and 70 art sit side by
  side and `tilt` (55) / `top` are untouched. Wired via a station-only ArenaHook
  (`data/tables/arena_stations/view-pitch.json`, `ViewPitchHook`), so no shared file is edited.
- DECISION view70 combined view: `--view=combo` = pitch 70 in play, eased (smoothstep, ease_s 1.0)
  to 55 on Events.boss_engaged and back to 70 when the BossHook's fight is DEFEATED. The ease runs on
  sim ticks, so a hit-stop (SimClock.hold) holds it. Cards SWAP at swap_deg 62.5 (the middle):
  the alternative (cross-fade) is not built yet. 55-only = `tilt`, 70-only = `tilt70`: one value.

### MILESTONES
- 14:16 MILESTONE: Rivet p70 head card cut from `rivet_70.png` top row (head + collar masked per
  figure, `scratch/view70/prep_rivet70.py`, then `tools/art/cut_facings.py --tan`, 5 x 105x128).
- 14:19 MILESTONE: view.json rows `tilt70`, `combo`; schema keys art / boss_pitch_deg / ease_s /
  swap_deg; `features/view_pitch/` (ViewPitch, ViewPitchCards, ViewPitchEase, ViewPitchHook);
  unit `test_view_pitch` 6/6. Headless combo King fight seed 2: king defeated, 0 SCRIPT ERROR.
- FRICTION: `node tools/godot/check.mjs` FAILs on untouched files here too (rig_head_card.gd:
  "Failed to compile depended scripts"); used run_unit --select instead.
- 14:24 FRICTION/fix: the King engages inside BossHook.setup (station order: bosses before
  view-pitch), before my hook listens to Events.boss_engaged; `boss_on()` now reads the BossHook's
  live fight state directly (signal kept for arena bosses without a BossHook).
- 14:29 MILESTONE (film, seed 2, 5400 frames, 32 px/m): combo log: `pitch ease 70.0 -> boss at
  tick 1`, cards to the base art at tick 32, `king defeated`, `pitch ease 55.0 -> play at tick
  5252`, cards to p70 at tick 5282. 0 SCRIPT ERROR in tilt / tilt70 / combo.
- 14:31 LOOKED: at 70 the King's p70 bust drew tiny and sunk behind the throne (t12, t34 zooms).
  Cause: RigHeadCard sizes a card by cell WIDTH (2.4 x torso); the 70 bust cell is 169 px wide vs
  the 55's 115 px (the bell, the wide fur), so it drew at 68 % height.
- DECISION: per-pitch art is an OVERLAY child of the live card (same frame/mirror, same height in
  the card's pixels, base anchor fraction, parent material) instead of re-texturing; the card's own
  texture goes invisible via self_modulate. This also gives the cross-fade: combo fades over
  fade_deg 5 centred on swap_deg 62.5 (fade_deg 0 = hard swap). Unit 9/9.
- 14:36 MILESTONE (films, 0 SCRIPT ERROR each): re-filmed tilt70 + combo with the overlay. combo log:
  `cards mix 1 (70.0) tick 1`, `cards mix 0 (59.9) tick 38` (fade ticks ~23-38), `king defeated`,
  `pitch ease 55.0 -> play at tick 5252`, `cards mix 1 (65.1) at tick 5289`. LOOKED at t12 x2: the
  70 King bust now reads (plum cap, fur, vermilion) at the 55 card's height; lower lift at 70.
- MEASURED pop (frame-to-frame mean abs diff, full 1280x800 frame, frames 5240-5330, i.e. the whole
  defeat ease): combo max 17.97, median 14.29; tilt70 (no ease) max 19.94, median 13.43. The ease and
  the cross-fade add no spike above the print-grain floor. Caveat: a full-frame metric; a card-region
  metric would be sharper (next). `gtai-masters/d8/view70/combo_defeat_ease_framediff.txt`.
- MEASURED occlusion (logs): King fight 55 = 113 body-frames hidden / 90 s, 70 = 6; city block
  55 = 176 / 45 s, 70 = 30. COMPUTED ground north-south vs top: 55 1.221x, 70 1.064x.
- EVIDENCE in gtai-masters/d8/view70 (frames.json, 9 entries): king_55_70_combo_32ppm_45s.mp4,
  king_defeat_combo_eases_back_to_70_32ppm.mp4, city_55_vs_70_32ppm_45s.mp4 (+ t18 still),
  king_car_55_vs_70_32ppm_x2_t12.png, rivet_55_vs_70_64ppm_t12/t30.png, the two p70 strips x3.
- READ chars JOURNAL 14:44: they built REQUEST 1 in d8-chars 8e557502 (`ViewMode.art` from the row's
  `art`; `RigHeadCard.rows_of(art)`: a same-name strip under art/view/<art>/ replaces the base path,
  KEEPING the base row's anchor/width; `SET_CARDS[art]` replaces whole rows; a live
  `ViewMode.shared().art` change rebuilds cards). NOTE the 55 art is `p55` there, not the base.
- REQUEST chars (rows for p70, since rows_of keeps the base width and RigHeadCard sizes by cell
  width): `SET_CARDS["p70"]["king"]` = base king row with width k 2.4 * 169/115 = 3.53 (anchor 0.80,
  bust true, raw true); `SET_CARDS["p70"]["rivet"]` = base rivet row with width k 1.0 * 105/90 = 1.17
  (anchor 0.86, raw true). Those keep each 70 card as tall as its 55 card (MEASURED at 32 px/m: with
  the base width the 70 King bust drew at 68 % height, sunk behind the throne). Or I keep my
  overlay, which does the height match itself (ViewPitchCards.SCALE).
- ANSWER chars (REQUEST 2 proposal): yes please, `ViewMode.revision` bumped on each pitch write;
  I will bump it from ViewPitchEase once it lands. No objection.
- GATE unit (full, no-arg) on 05d684e9: 1416 passed, 0 failed (60 s).
- MEASURED draw order at 70 (`--order-probe`, King fight seed 2, 32 px/m, to tick 3000;
  `evidence/it1/order_tilt*.log`): tilt (55) rig pairs 318, reversed 0, interleaved 1, car pairs
  356 car wrong 2; tilt70 rig pairs 218, reversed 0, interleaved 0, car pairs 313 car wrong 1.
  70 has fewer overlapping pairs (smaller lift) and no new failure.
- FILM 64 px/m close-up, King on foot (`--phase=3 --boss-cam`): king_onfoot_55_vs_70_64ppm_t9.png +
  15 s mp4. LOOKED: the 70 bust reads in close combat (plum crown, grin, chain, emerald medallion);
  the fur's step cut mostly hides under the arms. frames.json now 11 entries.

NEXT (iteration 2):
1. Merge `d8-chars` (ordinary merge; their 8e557502 `ViewMode.art` + `RigHeadCard.rows_of`, tilt row
   art `p55`). Expect view.json / schema hunks (their schema `art` = mine). After the merge:
   - tilt70: RigHeadCard draws the p70 strips itself but with the BASE width -> the King small again
     unless chars adds `SET_CARDS["p70"]` rows (REQUEST above: king k 3.53, rivet k 1.17). If not
     landed, keep my overlay for the height match (it skips a card already drawn from the folder,
     so make ViewPitchCards scale THAT card instead, or ask chars for a `height_match` flag).
   - combo: set `ViewMode.shared().art` = "p70" above swap_deg, the boss art ("p55", new row key
     `boss_art`) below, and keep the overlay only for the cross-fade window (mix 0<x<1); bump
     `ViewMode.revision` once chars lands it (floor + PropOcclusion redraw on a pitch write).
   - re-film the baseline (King seed 2 at tilt/tilt70/combo 32 px/m, the 64 px/m on-foot pair).
2. Gates on the merge: lint, unit full, scenarios, director reel 19/19 under tilt70 and combo
   (`--bot=reel --reel=director`), top bit-identical (md5 of a top frame vs main at tick 900).
3. Tonnage at 70 from tonnage_70.png (a ghost: production sheet on MAGENTA under the image lock, or
   cut from the sheet + despill), card/parts under art/view/p70/.
4. Quality: the King p70 bust's flat step cut at the shoulders (a curved fur edge mask), Rivet p70
   frame 4's shoulder ball; a card-region pop metric for the cross-fade; the ease length 0.8 vs 1.2 s
   clips for the owner call; frame cost 70 vs 55 under the bench lock (CONTENDED otherwise).
5. Film labels off the dev HUD in the city clip; a 30-90 s combined clip of the set.
- GATE scenarios on 3ce6148c: `run_scenarios: 52 ran, 0 failed`, 0 SCRIPT ERROR, the replay
  `identical` (timings CONTENDED: four lanes on the machine). Lint 15/15 on every commit.
- 14:53 CHECKED the chars merge (`git merge-tree HEAD d8-chars`): 14 files, conflicts only in
  JOURNAL.md (add/add: every lane keeps a root JOURNAL; keep OURS) and view.schema.json (same `art`
  text). Deferred to iteration 2 (NEXT 1): post-merge the 70 King shrinks to 68 % until the p70
  SET_CARDS rows land, and a re-film + gates do not fit in this session.
- 14:51 QUALITY: the King p70 bust's flat step cut at the shoulders -> a sloped shoulder mask
  (`tools/art/view70/prep_king70.py` SLOPE 22). LOOKED at both x2 (masters
  `king_p70_bust_step_vs_slope_cut.png`): the fur now falls off round the fists, no ledge. Shipped;
  NOT yet re-filmed in game (the it1 films show the step cut). Unit test_view_pitch 9/9.
- 14:54 FILM re-filmed the 64 px/m on-foot pair on 3a5df575 (sloped cut), 0 SCRIPT ERROR;
  `king_onfoot_70_64ppm_x3_t9.png`. FOUND at x3: (a) two bells: the rig's top-down hand bell AND the
  70 card's shoulder bell; (b) the top-down cloth cape (cream, dots, vermilion) draws behind the bust
  card like a flag. Both are King-rig matters (bosses lane / KingAccents). Next: a REQUEST to bosses
  (hide the cloth cape under a bust card at 70, or crop the bell off the p70 card; my default would be
  to keep the card's bell and ask them to hide the hand bell's duplicate only if it IS the same prop).
  frames.json 13 entries; raw avis deleted (scratch 28 MB).

### REQUEST to bosses (King's rig / KingAccents)
- REQUEST bosses: under a tilted view with a bust card (`tilt70`, `combo`, and likely your p55 bust),
  at 64 px/m the King shows (a) the top-down cloth cape drawing behind the bust card like a flat flag
  and (b) two bells: the hand bell from the rig and the shoulder bell drawn on the 70 sheet's bust.
  Evidence: `gtai-masters/d8/view70/king_onfoot_70_64ppm_x3_t9.png`. Ask: hide the cloth cape under a
  bust card (or draw it below the card's footprint only). I will crop the shoulder bell off the p70
  bust if your 55 bust has no bell, so 55 and 70 match: tell me in your JOURNAL which you keep.
