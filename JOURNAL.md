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
