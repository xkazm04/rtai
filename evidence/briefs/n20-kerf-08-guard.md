# n20-kerf brief 08: one test guard (10 minutes, commit by 06:00)

Lane `kerf`, worktree `C:\Users\kazda\kiro\gtai-wt\n20-kerf`, branch `n20-kerf`. `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/kerf`
before any Godot run. Do NOT run `git merge`. Never edit, stage or commit JOURNAL.md, REPORT.md or evidence/briefs/*.

`project/tests/unit/test_ghost_flight_hosts.gd` line ~114 (`_drive_arena`) crashes on this branch: under spectral, Kerf
draws its own body, so `drawn.sprite()` is null. Flight accepted this guard as a call site in its test; n20-tonnage
carries it. Make exactly this change and nothing else (the same lines as n20-tonnage, so the merge is trivial):

```
-		cells[drawn.sprite().frame_coords.x] = true
+		if not drawn.own_body:
+			cells[drawn.sprite().frame_coords.x] = true
```

Check: `node tools/tests/run_unit.mjs --select=test_ghost_flight_hosts,test_kerf_hit,test_kerf_spectral` green.
Commit only that file, message "Skip the sprite cell count for an own-body ghost in the arena gait test". No mutate,
no films. Final message: the commit sha and the test line.
