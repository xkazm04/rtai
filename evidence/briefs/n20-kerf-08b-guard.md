# n20-kerf brief 08b (follow-up, 5 minutes, commit by 06:00)

The `own_body` guard does not cover Kerf. Replace your two lines with n20-dent's null check, exactly:

```
		var sprite: Sprite2D = drawn.sprite()
		if sprite != null:
			cells[sprite.frame_coords.x] = true
```

(only those lines; leave the rest of `_drive_arena` as it is). Then run
`node tools/tests/run_unit.mjs --select=test_ghost_flight_hosts,test_kerf_hit,test_kerf_spectral` and commit only that
file ("Count sprite cells only when the ghost draws through its shared sprite") ONLY if it is green. If it is still red,
do not commit: `git checkout` nothing, leave the change unstaged and report the failing line and message.
Same rules as brief 08 (no merge, no JOURNAL/REPORT/briefs).
