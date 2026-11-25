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

## n29-01b (same-tick pair, caption, decision lines)
- Caption text centred: `horizontal_alignment = 1` on `Caption/Act` in `gauntlet_bot_film.tscn` (1dcbdd09c, with the five decision lines in `docs/decisions.md`).
- Same-tick pair: `tools/film/compare.mjs` takes only its own shots (arena, city, chapter, weapon, melee, kill), none of which draws the ghost strip, so it was not used. Instead `bond_film_64.tscn` (seed 1, `--bond-prefill=16`, 1920x1080, `--fixed-fps 60`, `GTAI_FILM_FROM/TO` 600..640, frame 20 = tick ~619) was run in a snapshot of `c649a15d6` (`tools/lib/snapshot.mjs`, kind `hudbefore`) and in this tree at `1dcbdd09c` (HUD code as in `24fc9c4c3`), both rendered the same way. Only the strip region differs between the frames (diff bbox 0,991 to 49,1041).
- Chip 1 plate: before the first dark plate column is x = 9 (paper border x = 7), after x = 17 (border x = 15): +8 px, >= 8 px off the screen edge. Chip numbers 2..4 unchanged in place.
- The caption is not on screen at that tick (the bot shows it only while it acts), so the pair shows the strip and chips, not the caption.
- Stills: `gtai-masters/n29/keys/hud/hud_pair_1080.png` (3840x1080, before | after), `hud_pair_same_tick_crop_3x.png` (0,900 420x180, 3x nearest).
- Not done: `hud_after_handheld.png` (the capture tool writes only 1920x1080; a movie-writer run with `--device=deck` at 1280x800 was refused by the permission system) and the mutate run.
- `run_unit --select=test_rivet_walk_every_weapon,test_rivet_grid_stride,test_rivet_walk_sprint_fallback` on HEAD: 18 passed, 0 failed (21.8 s).
- Mutate (`ghost_chip_number.gd` lines 26-29, `--tests=test_ghost_chip_number,test_ghost_form_hud,test_ghost_form_layout`, baseline green in 247 s, 484 s total): killed 3 / (killed 3 + survived 4) = 42.9%. Killed: `1.2 -> 2.2`, `+= -> -=`, `- -> +` (the min-x clamp). Survived: `+ -> -`, `1.15 -> 2.15`, `* -> /` on line 27 (the plate's offset from the chip centre: no test pins the vertical offset or the offset sign) and `0.0 -> 1.0` on line 29 (a 1 px clamp slack, equivalent for the tests' >= 8 px bound). Owed: a test that pins `anchor()` against the chip centre.
- Mutate re-run after commit 568f99552 (tests pin the plate's offset; same lines, same tests): killed 7 / (killed 7 + survived 0) = 100%, baseline green in 192 s, 390 s total. Before: 3/7 = 42.9%. The `0.0 -> 1.0` clamp slack is now killed too (slot 1's left edge is pinned to `number_min_x()` within 0.5 px).

## n29-01d handheld
Not rendered. Deck row: `deck` in `project/data/tables/devices.json` (hud `compact`, 1280x800 panel; `deck40`, `deck30` are the same layout). The only capture route, `BondFilmCapture._capture` (`project/dev/ghost-forms/bond_film_capture.gd` line 38), quits with exit 1 on any frame that is not 1920x1080, so a `--device=deck` run at 1280x800 cannot write a frame; the other route, `--write-movie`, was refused by the permission system in 01b and was not retried. No Godot step was run and no still exists.
NEED (dev file, not in this lane's allowlist): `bond_film_capture.gd` should accept the window's own size (e.g. compare to `DisplayServer.window_get_size()` or take `GTAI_FILM_SIZE`), after which `node tools/dev/run.mjs bond_film_64 --windowed --position 0,1440 ... --device=deck` with `GTAI_FILM_FROM/TO` 600..640 gives the 1280x800 frame. The compact layout stays pinned by `test_every_number_plate_lies_inside_the_strip_and_off_the_screen_edge` (both layouts, plate x >= 8).

## n29-01e handheld (snapshots)
- Snapshots (`tools/lib/snapshot.mjs`, kinds `hudhhb` = `c649a15d6`, `hudhha` = `a04fc1b40`, HEAD). Each SNAPSHOT (never this worktree) carried two dev-only edits: `bond_film_capture.gd` line 38 `if image.get_size().x < 640:` (instead of the 1920x1080 check), and `"--device",` added to `KNOWN_FLAGS` in `project/dev/gauntlet/gauntlet.gd` (the gauntlet's own argument check answered `invalid argument --device`, exit 2, in the first try, so the scene refused the flag that `LaunchArgs` reads). The product HUD code is the committed one in both.
- Command, per snapshot (via its own `tools/lib/godot.mjs` `runGodot`, `cwd` = snapshot, windowed, `GTAI_FILM_DIR` a temp dir, `GTAI_FILM_FROM/TO` 600/640): `--rendering-driver d3d12 --position 0,1440 --fixed-fps 60 res://dev/ghost-forms/bond_film_64.tscn -- --bond-prefill=16 --device=deck` (seed default 1, as 01b; `tools/dev/run.mjs` cannot pass `--rendering-driver`/`--position`). Log: `device: profile deck: window 1280x800 ... tier handheld`; 41 frames each. The frame is 1280x800 (deck row, 1:1 panel). Frame 20 (tick ~619) of each; diff bbox of the pair 0,735 to 49,769 (only the strip's left end differs).
- Strip box (the dark rounded panel) x 6..198, y 682..794 in both. Plates y 737..762.

| measure | before (c649a15d6) | after (HEAD) | bar |
|---|---|---|---|
| chip 1 plate left edge | about x = -4 (right border at x 22, plate 26 wide: clipped by the screen edge) | border x = 9 (first dark column 11) | >= 8 px after: met (9) |
| plate 1 inside the strip box | no (starts left of the box edge x 6 and of the screen) | yes (9..35) | yes |
| plates 2, 3, 4 inside the strip box | yes (39..64, 81..106, 123..148) | yes, unchanged | yes |
| caption vs strip overlap | no caption on screen (the bot shows it only while it acts) | same | 0 px: n/a |

- Stills (read): `gtai-masters/n29/keys/hud/hud_handheld_before.png` (full 1280x800: before, chip 1 cut at the left edge, its digit "1" hard against the screen edge), `hud_handheld_after.png` (full frame: Wave 0 panel top left, Rivet mid, strip bottom left; chip 1 plate whole with a small gap to plate 2, about 3 px), `hud_handheld_pair_crop_3x.png` (0,680 320x120 before | after, 3x nearest, 1932x360). Plate 1 and plate 2 are now 3 px apart (border to border): tight but not overlapping.
- `frames.json` entry added (replacing `rag/strips_4x_p55.png`), 15 entries.

## n29-14 compact gap patch (snapshot)
- Snapshot `C:\Users\kazda\AppData\Local\Temp\gtai-hudgap-a4608d65595e` (kind `hudgap`, HEAD `a4608d65595e`). Product diff only: `evidence/n29-keys/hud_compact_gap.patch` (`GhostFormLayout.compact()` `gap` 42.0 -> 50.0, plus one new test in `project/tests/unit/test_ghost_chip_number.gd`); `git apply --check` from this worktree: applies. No test pinned 42, nothing else changed.
- Test `test_adjacent_number_plates_keep_a_gap_and_the_first_clears_the_minimum` (both layouts, labels "1".."4", every adjacent pair plate(n+1).left - plate(n).right >= 8, plate 1 left >= `number_min_x()`). On n29 code it FAILS: `test_ghost_chip_number.gd:91 ... gap 0: plates 1 and 2 are 2.6 px apart` (1 failing, 5 passed). Patched: `--select=test_ghost_chip_number,test_ghost_form_layout,test_ghost_form_hud` 20 passed, 0 failed (also after gdformat).
- Lint: `gdformat` reformatted the new test once (wrapped args), then `gdformat --check` clean on both files; `gdlint` no problems. The full `tools/lint/lint.mjs` was not run (snapshot only).
- Render: the 01e handheld run in the snapshot (two dev-only edits: `bond_film_capture.gd` size check, `"--device",` in gauntlet KNOWN_FLAGS; not in the patch), `--device=deck`, seed 1, `--bond-prefill=16`, d3d12, `--position 0,1440`, GTAI_FILM 600/640, 41 frames, frame 20, 1280x800.

| measure | n29 (01e after) | patched | bar |
|---|---|---|---|
| plate 1 left border x | 9 | 9 | >= 8 met |
| plate borders (left..right) 1 / 2 / 3 / 4 | 9..35 / 39..64 / 81..106 / 123..148 | 9..35 / 51..76 / 101..126 / 151..176 | |
| plate 1-2 gap (border to border) | 3 px | 15 px | >= 8 met |
| strip box (dark panel) right edge | about x 198 | about x 230 (+32 for 4 chips, as predicted) | |
| every plate inside the strip box (x 6..) | yes | yes | yes |

- Still (read): `gtai-masters/n29/keys/hud/hud_handheld_gap_patch_crop_3x.png` (0,680 420x120, n29 | patched, 3x nearest). Left: "1" and "2" touch as "12". Right: "1" and "2" are two separate plates, each at the lower-left rim of its own avatar's lock icon; the strip is wider and the Madness bar follows. The desktop strip does not change: only `compact()` is edited, the desktop uses `GhostFormLayout.new()` with `GhostFormHud.GAP` 72, so no 1080p render.
- Apply with `git apply evidence/n29-keys/hud_compact_gap.patch`, then a `docs/decisions.md` line (compact gap 42 -> 50, option B `number_dx` rejected: strip unchanged but needs anchor tests rewritten). Not done: mutate run, `tools/gate/quick.mjs`.
