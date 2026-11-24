# n27 melee m4: wreck arcs, mastery card (2026-11-24, branch n27-melee)

Env for every Godot run: `APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/melee`,
`GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`, d3d12, `--position 0,1440`.

## C: the mastery card has a picture (commit 42f8c948f)
- `project/dev/gauntlet/gauntlet_pick_card.gd`: `mastery` shares the `ghost` branch (`_mount_ghost`: chip face + the ghost's
  drawn card figure), and `_draw_mastery_ring` draws `GhostBondRing`'s INK/TRACK/TEAL/STROKE constants as a full ring with
  the crown diamond behind the figure. `picture()`, `has_figure()`, `is_mastery()` for tests.
- `project/tests/unit/test_gauntlet_pick_card.gd` (2 tests, pass with test_gauntlet_pick_view: 10/10).
- debt: `dev_loc` baseline raised with `--accept-regression` (+44 dev lines, pick card).
- Film: `node evidence/n27/films/render_bond.mjs C:/Users/kazda/kiro/gtai-masters/n27/melee/films/bond_mastery.mp4 32 2 6 1650 2990`
  -> ffprobe `1920,1080,60/1,28.816667,1729`; old kept as `films/bond_mastery_blankcard.mp4`.
  At 15 s the first card shows Tonnage in a full teal ring with the diamond on the crown.
