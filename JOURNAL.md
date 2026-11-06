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
- 14:58 GATE director reel (`arena.tscn --fixed-fps 60 -- --bot=reel --reel=director --loadout=pistol
  --rigs`, windowed so the view hook runs) under `--view=tilt70` and `--view=combo`: 19/19 chapters
  fully down each, 0 SCRIPT ERROR (`evidence/it1/reel_tilt70.log`, `reel_combo.log`; the reel does not
  quit itself, I killed my two process trees by PID after the 19th chapter).
- Note: `top` and `tilt` are untouched by this lane's code (the hook returns when flat; under `tilt`
  the row has no art and no ease, so no node is attached); scenarios 52/0 with the replay identical.
  A top frame md5 vs main is still owed (NEXT 2).

NEXT (final for iteration 1, supersedes the list above where they differ):
1. Merge d8-chars (keep OUR JOURNAL.md); add `boss_art` (p55) to combo; tilt70 King size via chars'
   `SET_CARDS["p70"]` rows or my overlay scaling; re-film the 32 px/m King trio + 64 px/m pair.
2. Read bosses' answer on the cape/bell REQUEST; crop or keep the p70 bell to match their p55 bust.
3. Gates after the merge: lint, unit full, scenarios, reel 19/19 (tilt70, combo, tilt, top), a top
   frame md5 vs main at tick 900.
4. Tonnage at 70 (ghost, magenta sheet under the image lock); ease length clips 0.8 / 1.0 / 1.2 s;
   a card-region pop metric; frame cost 70 vs 55 (bench lock or CONTENDED); city clip labels.
5. At 18:30: the exe (int-day recipe in docs/decisions.md) and REPORT.md with the Calls for the owner
   (70 vs 55 vs combo for city and bosses; transition length; cross-fade vs swap = fade_deg 5 vs 0).

## Iteration 2 (2026-11-06 15:00-16:00, BUILD)

- 15:00 READ chars (e0e73ffc `SET_CARDS["p70"]` rows king 3.53 / rivet 1.17 = my REQUEST; 01387fb6
  `ViewMode.set_pitch` + `revision`) and bosses (KingArt court strips keyed by `roundi(pitch)` under
  `features/bosses/king/art/p<pitch>/`, part cache keyed by pitch, CARD_CAPE A/B; no answer yet on the
  two-bells REQUEST).
- 15:03 MILESTONE d0c2edf8 merge d8-chars (ordinary merge): conflicts only JOURNAL.md (kept ours) and
  view.schema.json (kept both: their `art`, my boss_pitch/ease/fade/swap). Lint 15/15.
- 15:12 MILESTONE b3cf4418 combo on chars' route: ViewPitchEase writes `ViewMode.set_pitch` (bumps
  `revision`) and sets `ViewMode.art` = `art` (p70) at mix >= 0.5, else the new row key `boss_art`
  (p55); RigHeadCard rebuilds every card from that folder (its rows_of: p70 rows, p55 Rivet bust).
  ViewPitchCards now only overlays the OTHER folder's row inside the fade window, sized by that row's
  own width (`(k_o/cell_o)/(k_mine/cell_mine)`) and anchor, picked per card from the art it was built
  under (a card not yet rebuilt after a swap still fades right). tilt70 needs no node any more
  (RigHeadCard draws p70 itself). Unit test_view_pitch/test_rig_head_card/test_view_mode 28/0.
- 15:14 FILM King seed 2 at combo/tilt70/tilt, 32 px/m, 1500 ticks (`scratch/view70/it2`), 0 SCRIPT
  ERROR; log: `pitch ease 70.0 -> boss at tick 1`, `cards art p55 (pitch 62.1) at tick 32`.
  LOOKED at frames 20-43 x3 (masters `combo_fade_p70_to_p55_rivet_frames20-43_x3.png`): Rivet's p70
  head card fades into chars' p55 bust over ~6 frames; mid-fade both draw (a short double image: the
  p55 bust's chest under the p70 head). MEASURED card-region pop (`scratch/view70/card_pop.py`, crop
  80x70 on Rivet, frames 10-60): max 33.9 at frame 11 (the ease's first frames: the ground moves),
  median 19.9, fade window frames 27-36 all 17.4-20.9: no spike above the moving-ground floor.
- 15:16 LOOKED tilt vs tilt70 at tick 1400 (King on the car, cone tell): the 70 bust now draws as
  tall as the 55 one through chars' p70 rows (it drew at 68 % before).
- FINDING (integration, bosses x view70): KingArt picks `art/p<roundi(pitch)>/` and dresses a card
  once. Under combo the card is rebuilt at 62 deg (my art swap) -> no `p62` strip -> it keeps the
  shared strip forever, so the combo boss fight at 55 would show the base King, not bosses' p55 bust.
  Not merging bosses this iteration for that reason.

### REQUEST to bosses (iteration 2)
- REQUEST bosses: please do your NEXT 2 (fold the court strips into chars' route) soon: put
  `king_bust_card.png` / `gang_head_card.png` under `features/characters/art/view/p55/` and ask chars
  for `SET_CARDS["p55"]["king"]` = [, 0.80, 3.6, true, true] and `["gang"]` = [, 0.84, 1.75, false,
  true] (your 14:47 numbers). Then `--view=combo` draws your 55 bust in the fight and my p70 bust in
  play, cross-faded, with no KingArt hook. If you keep the KingArt swap instead, key it by
  `ViewMode.shared().art` (the folder name, "p55") not by `roundi(pitch)`, and re-dress a card when
  its art meta changes (combo eases 70 -> 55 live; a card built at 62 deg never swaps today).
  Your part sets (limbs, gang bodies) keyed by pitch are fine as they are under combo: please make
  the lookup `>= 55 and < 62.5 -> p55` or key it by `ViewMode.art` too, so the limbs switch with the
  bust at swap_deg 62.5 and not only once the pitch lands exactly on 55.
- 15:20 GATES on b3cf4418: unit full (no-arg) 1423 passed, 0 failed (100 s); scenarios `52 ran, 0 failed`,
  0 SCRIPT ERROR, city replay identical (timings CONTENDED); lint 15/15 on every commit.
- 15:21 GATE `top` bit-identical with main: King fight seed 2, 32 px/m, 900 frames written by both
  (main checkout 0bea8b93 vs d8-view70 b3cf4418): all 900 video framemd5 equal (list md5 6e865449),
  frame 899 rgb md5 9f9921bd both.
- 15:22 MILESTONE 350c8f44 study rows `combo_ease08` / `combo_ease12` (the transition-length call).
  FILM `--phase=3` (King on foot, defeated at tick 1138): masters
  `combo_ease_08_10_12_defeat_55to70_32ppm.mp4` (ticks 1080-1320, three panels). Cards swap to p70 at
  ticks 1162 / 1168 / 1174 (pitch 62.5). LOOKED: at 32 px/m the three differ by a few frames; 0.8 s
  reads as a quick camera lift, 1.2 s as a slow settle; 1.0 stays the default.
- 15:25 GATE director reel on 350c8f44 (`--bot=reel --reel=director --loadout=pistol --rigs`, windowed,
  --quit-after 8000): tilt70 19/19 chapters fully down, combo 19/19, 0 SCRIPT ERROR each
  (`evidence/it2/reel_tilt70.log`, `reel_combo.log`).
- 15:23 MEASURED visible ground: depth on screen at 32 px/m, 800 px = 800/(32 sin p): 55 -> 30.5 m,
  70 -> 26.6 m, 90 -> 25.0 m. 55 shows 14.7 % more ground depth than 70 (checked on the King stills:
  lane-line spacing 165 vs 189 px = 1.145). Width is the same at every pitch.
- 15:27 MEASURED frame cost, exported `windows-bench` (bake + export on this branch), city drive_dense,
  zoom 1.0, vsync off, 30 s x 2 passes alternating, UNDER bench.lock but CONTENDED (four lanes running):
  | | tilt (55) | tilt70 |
  |---|---|---|
  | avg frame ms | 1.147 / 1.099 | 1.081 / 1.184 |
  | p99 CPU ms | 5.90 / 5.32 | 5.57 / 6.32 |
  | render CPU avg ms | 0.391 / 0.385 | 0.324 / 0.348 |
  | draw calls avg | 573 / 578 | 371 / 373 |
  | visible actors avg (max) | 28.3 (51) / 28.5 (51) | 25.4 (46) / 25.5 (46) |
  | >25 ms hitches, >50 ms | 2, 0 / 0, 0 | 3, 0 / 2, 0 |
  Frame time is a wash (noise under contention); 70 sees 10 % fewer people (1/sin ratio 1.147 on
  depth). OPEN: tilt70's draw calls equal it18's `top` (370), 200 fewer than tilt: not explained by the
  ground alone. A 10 s A/B (tilt65 no cards 500, tilt_noshadow 593, tilt55 592) saw other crowds, so it
  does not settle it. Next: a frame of city_bench at tilt70 to see whether the cards / cast shadows draw
  there (scratch/view70/bench/).
- 15:21 IMAGE r2 (image.want touched, lock taken and dropped by my gen.mjs copy with a 10 min cap):
  `tonnage_70_body_magenta.png`, 76 s, first try: 5 legless facings, clean magenta. Inked 15k
  chroma-green flecks between the hoses (bleed from the green reference) before the key, keyed with
  chars' `ghost_bust.py` (read-only from their worktree) -> `scratch/view70/r2/tonnage_body_card_p70.png`
  (5 x 178x192). LOOKED x2 (masters `tonnage_p70_body_card_strip_x2_staged.png`): reads as the sheet's
  press; faint violet wisp fringe; facing 1's hazard stripes came out teal (prompt asked amber). NOT
  wired: Tonnage is a code rig (TonnageRig, chars) with no card route yet; the sheet is all teal-steel
  while the game's Tonnage has a gunmetal crown (needs a tone print like chars' Dent card). No
  provenance line until it ships.
- FILM Tonnage ghost reel 55 vs 70 at 48 px/m (masters `tonnage_55_vs_70_48ppm_x2_ghostreel_t150_nocard.png`):
  both draw chars' lifted top-down press; neither reads as the sheet's standing press.

### REQUEST to chars (iteration 2)
- REQUEST chars: when you build Tonnage's card (your NEXT "a south-face card over the lifted crown"),
  please resolve its strip through `ViewMode.art` like RigHeadCard (`art/view/<art>/<file>.png`) and
  tell me the file name and cell size you pick; I have a p70 legless body strip staged (5 x 178x192,
  bottom-aligned, same convention as your ghost_bust.py output) and will drop it in `p70/` under your
  name. Also: should its plating get your ghost_card_tone print (gunmetal crown), as Dent's did?
- 15:29 FILM re-filmed the deliverable on the chars merge (f6f5a05b), 0 SCRIPT ERROR each, raw avis
  deleted: masters `king_55_70_combo_32ppm_45s_merged.mp4` (46 s, three panels, labels bottom right),
  `city_55_vs_70_32ppm_45s_merged.mp4` (46 s; dev HUD still on), `king_rivet_onfoot_55_vs_70_64ppm_15s_merged.mp4`
  (+ stills `*_merged.png`). LOOKED at 64 px/m t9: Rivet p55 bust (55) vs p70 head (70); the King p70
  bust (plum crown, emerald) vs the LAB bust at 55 on this branch (bosses' p55 King not merged); the
  cloth-cape flag behind the bust and the doubled bell are still there (REQUEST bosses, it1).
  The pre-merge it1 films are deleted from masters (superseded); frames.json 15 entries.
- 15:28 FINDING (frame cost): a city_bench frame at tilt vs tilt70 (`scratch/view70/bench/cb_cmp.png`)
  shows the same kinds of draws at both (cards, cast shadows, props): the tilt70 draw-call drop looks like
  a step in visible chunk rows (55 sees 3.9 m more depth), NOT a feature off. Hypothesis, unverified.
- 15:33 READ chars a743199e `GhostCard` (non-CutRig ghost card: `features/souls/art/view/<art>/
  <name>_card.png`, width/anchor per rig) and 4eb02025 (Tonnage p55 card: gunmetal, teal seams, amber
  hazard band). MILESTONE e1d0a6c2 merged d8-chars again (JOURNAL ours, no other conflict).
- 15:34 IMAGE r3 (image.want, lock queued behind chars, my gen.mjs copy, 92 s, first try):
  `tonnage_70_card_magenta.png` with refs tonnage_70.png (angle) + chars' p55 tonnage_card.png
  (palette). The r2 all-teal strip is dropped (it clashed with the p55 card). Keyed with ghost_bust.py
  -> `features/souls/art/view/p70/tonnage_card.png` (5 x 164x192). LOOKED: p55 over p70 strips x2
  (masters `tonnage_card_p55_vs_p70_strips_x2.png`): one design, 70 steeper.
- 15:36 MILESTONE 419610f7 Tonnage's p70 card + provenance. FILM ghost reel 55 vs 70 at 48 px/m
  (masters `tonnage_card_55_vs_70_48ppm_x2_ghostreel_t150.png`), 0 SCRIPT ERROR: the 70 card stands
  over the walking feet, matched to the 55 one.
- 15:39 MILESTONE cb85b405 ViewPitchCards cross-fades `ghost_card` sprites too (the other folder's
  strip of the same name, same width and anchor; folder read from the strip's path). Unit
  test_view_pitch/test_ghost_card/test_rig_head_card 25/0. NOT seen live: in the King fight the combo
  swaps at tick 32, before Tonnage is summoned (~tick 60), and the ghost bot never defeats the King, so
  the ease-back with Tonnage on screen is owed (needs a boss-down + Tonnage beat).

NEXT (iteration 3):
1. Read bosses' JOURNAL: if their court strips moved into chars' route (`art/view/p55/king_bust_card.png`
   + SET_CARDS p55 king row), merge d8-chars/d8-bosses (ordinary merges; JOURNAL ours) and re-film the
   King trio + the 64 px/m pair, so 55 shows bosses' King. If not, merge d8-bosses anyway before the
   freeze and check combo at 55 draws their bust (KingArt keys by roundi(pitch): a card built at 62 deg
   keeps the shared strip - my REQUEST it2); film the result either way.
2. Bell/cape at 70: per bosses' answer, crop the bell off the p70 bust (prep_king70.py) or keep it.
3. City clip without the dev HUD (find the HUD flag or F1-off in the arena; `--hud`?), re-film 55 vs 70.
4. Verify the draw-call step (city_bench frames at tilt / tilt70: count visible chunks per frame).
5. Combo ease-back with Tonnage on screen (boss down + ghost beat), measure the ghost fade per frame.
6. 18:30 freeze: exe (int-day recipe in docs/decisions.md) -> build/export/windows/RTAI.exe; REPORT.md
   with Calls: 70 vs 55 vs combo (city/boss), ease 0.8/1.0/1.2 (clip ready), cross-fade vs swap
   (fade_deg 5 vs 0), bell on the p70 bust. Exe lines: `RTAI.exe -- --view=tilt70`, `--view=combo`,
   `--view=combo_ease08`, `--boss=king --view=combo`.
- 15:42 GATE unit full (no-arg) on cb85b405: 1428 passed, 0 failed.
- 15:44 FILM city 55 vs 70 re-filmed with `--clean` (dev HUD off; `arena_game.gd` reads it), 46 s,
  0 SCRIPT ERROR: masters `city_55_vs_70_32ppm_45s_merged.mp4` + t25 still. NEXT 3 done.
- 15:46 MEASURED (bench.lock held, CONTENDED): exported bench, city drive_dense, `--view=tilt70
  --zoom=0.872` (= 55's 30.5 m ground depth at 70; it also widens the view), 30 s: draw calls 606,
  visible 32.7. So the 371-vs-575 draw-call gap follows the visible area (chunks / props on screen),
  not a feature switched off at 70: the hypothesis above holds. BUT this pass's avg frame was 11.7 ms
  (p99 33.6), 10x the other passes: unexplained (contention at 15:46, or a zoom-out cost) - re-run
  under a quiet machine before quoting any frame time from it (`scratch/view70/bench/`).

NEXT (iteration 3) stands as written above (15:41), plus: re-run the zoom 0.872 pass when the
machine is quiet; REPORT.md is a draft (iteration 2) - update it at the freeze.
