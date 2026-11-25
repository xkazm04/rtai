# n29 keys 01: the gauntlet HUD

Commit 24fc9c4c3. Caption of the bot film moved to the bottom centre (anchored 0.5, grows both ways, same font 26 and
paper style): the strip is bottom-left (x 12..324 at 1080p) and the centre was free in the gauntlet; the story subtitle
box is not shown in the gauntlet. `bond_film*.tscn` and `gauntlet_bot_film_closeup.tscn` inherit the scene, so all follow.
Chip number plates: `GhostChipNumber.anchor` pushes the plate right just enough that its left edge is >= max(8, margin - 6 + 3).

Frames (`gtai-masters/n29/keys/hud/`): `hud_after_1080.png` = bond_film_64, seed 1, prefill 16, tick window 600-640 frame 20,
1920x1080. `hud_before_1080.png` is the n28 frame `n28/combat/stills/bond_chips_64.png` (not re-rendered at c649a15d6:
the temp worktree has no import cache/DLLs; same scene, seed and prefill, a different tick). `hud_pair_crop_3x.png` = 400x160 at 0,920, 3x nearest.
`hud_after_handheld.png` not made (the bond film capture only writes 1920x1080); the compact layout is pinned by the unit test.

Measured (pixel scan of the paper border of chip 1's plate, rows 1005-1022):
- chip 1 plate left edge: before x = 7 (strip plate starts x = 12: 5 px overhang), after x = 15 (>= 8; strip plate x = 12: 0 px outside).
- caption rect (880..1040, y 1014..1062) vs strip plate (12..324, y 928..1062 at desktop): 0 px overlap (screen x ranges disjoint).
- number sizes unchanged: 30 desktop / 24 compact.
- unit test `test_every_number_plate_lies_inside_the_strip_and_off_the_screen_edge`: slots 0..3, both layouts, plate x >= 8 and enclosed by the grown strip.
  Before this change the compact plate for slot 0 started at x = -1.5 (off screen).
