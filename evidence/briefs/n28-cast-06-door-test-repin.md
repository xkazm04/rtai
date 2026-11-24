# Brief n28-cast-06: re-pin test_cast_door to the door carrier's anchored walk (15-minute call)

Lane `cast`, branch `n28-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd). Do NOT switch branches.
**Hard stop 20:31 local; start the commit by 20:24.** If not green by 20:24, commit nothing; report the diff and END.

`89ac6ff8f` put the door carrier (`shield_robot`) on the anchored placement (`CastDoorAnchors`, STEP_M 0.16 m per drawing).
`project/tests/unit/test_cast_door.gd` still pins the old four-drawing contact (`StreetQuestCards.STRIDE_M`):
`node tools/tests/run_unit.mjs --select=test_cast_door` FAILS at `_check_walk_contact` (frame `(2,0)`, expected `(2,2)`).
The walk change is deliberate: re-pin the TEST to the anchored contact (a step of `CastDoorAnchors.WALK_STEP_M` / the
`StreetCopWalk.Contact` step advances one drawing; assert the drawing the anchored contact really shows, and that the card
stays planted within a contact, as the test does now). Do not change product code. Keep every other assertion as it is.
Run `node tools/tests/run_unit.mjs --select=test_cast_door,test_cast_door_walk,test_cast_contractor` green, then commit
only `project/tests/unit/test_cast_door.gd` with a message naming `89ac6ff8f`.

Env for Godot runs: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/cast`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Never run Godot_*.exe
directly. Never stash, `add -A/./-u`, `commit -a`, amend, rebase, push. Do not edit JOURNAL.md, REPORT.md, evidence/briefs/**.
Fix lint/format findings in your own edit and go on. Report: commit sha, the test result line, then END.
