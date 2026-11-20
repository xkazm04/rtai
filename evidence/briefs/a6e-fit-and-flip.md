# Brief a6e (resume): fit the function, commit, then the flip. Commits by 05:55.

`_drive_arena` is 41 lines. Bring it to 40 or fewer inside the same test file: e.g. the sprite guard
as two lines (`if drawn.sprite() != null:` / `cells[drawn.sprite().frame_coords.x] = true`), or move
the per-tick Dent foot check into a small typed helper `_dent_planted(view) -> bool` in the same
file. No assertion changes. Routine lint/format findings in YOUR edit: fix them yourself and go on;
stop only for a test failure you did not cause.

Then: `--select=test_ghost_flight_hosts` (legacy default), quick gate, commit the test alone.

Then the flip (a6c item 2): Dent's row `"look": "spectral"`, `--changed` run, scenarios
`quest1_dent`, `quest1_dent_lock`, `replay_60s` (replay `cbeb734ff9b97c41`), quick gate, commit
"Make the spectral Ejected look Dent's default" with the decision line from a6b's brief. If the clock
passes 05:55 before the flip is green, restore the value and do not commit it.
Report shas, counts, replay hash.
