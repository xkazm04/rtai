# Brief a6c (resume of a6b, lane dent): unblock the red host test, then the flip. Commits by 05:55.

Same machine rules and repo law as a6b. Check `date` before every commit; nothing after 05:55.

## 1. The red test (it is red at HEAD whatever Dent's default: the final gate would fail)
`project/tests/unit/test_ghost_flight_hosts.gd:114` (flight's test, merged at 1f03405db from
b0f2629c1) reads `drawn.sprite().frame_coords` every tick. Dent's spectral rig sets
`drawn.own_body = true`, so `GhostDrawn.sprite()` is documented to return null (README "Spectral
look"). Make the smallest fix in that test, and only there (the director names this edit in JOURNAL
and sends flight the same lines): read the sprite once per tick into a typed local and record
`frame_coords.x` only when it is not null, e.g.

```gdscript
		var sprite: Sprite2D = drawn.sprite()
		if sprite != null:
			cells[sprite.frame_coords.x] = true
```

Do not change any assertion. Confirm with `node tools/tests/run_unit.mjs --select=test_ghost_flight_hosts`
that it passes with Dent's row `legacy` AND with it `spectral`, and that the other forms' cases are
unchanged (quote pass counts). If it still fails for a different reason, stop and report it exactly
(file:line, message); do not widen the edit. Quick gate, commit alone: "Let the flight host test
pass a ghost that draws its own spectral body".

## 2. The flip (from a6b item 3)
Then set Dent's row `"look": "spectral"` in `project/data/tables/ghost_forms.json` and repeat a6b's
checks: `--changed`, the 46-file selection, scenarios `quest1_dent`, `quest1_dent_lock`,
`replay_60s` (replay must stay `cbeb734ff9b97c41`). All green: commit with the decision line exactly
as a6b's brief gives it. Anything red: restore the value, do not commit the flip, report it.

## Report
Shas, pass counts with both defaults, scenario results, replay hash.
