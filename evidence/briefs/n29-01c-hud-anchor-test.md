# Brief n29-01c-hud-anchor-test: pin GhostChipNumber.anchor() to the chip centre (lane keys, run n29)

Builder for lane `keys`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`.

## Wall clock
`{START}` launched. Commit by `{COMMIT}`. **Report and END by `{END}`.**

## Why
Mutate on `project/features/souls/ghost_chip_number.gd` lines 26-29 killed 3/7 (`evidence/n29-keys/hud.md`): the plate's
offset from the chip centre (line 27: `c + Vector2(-1.2, 1.15) * l.chip_r`) is unpinned: `+ -> -`, `1.15 -> 2.15`, `* -> /`
survive. Add tests in `project/tests/unit/test_ghost_chip_number.gd` (only that file) that pin, for both layouts (the full and
the compact `GhostFormLayout`, as the existing tests build them): for a slot whose plate is NOT clamped (slot 2, 3 or 4), `anchor()`
== `chip_center + Vector2(-1.2, 1.15) * chip_r` within 0.01 px; the plate sits below the chip centre (y > c.y) and left of it
(x < c.x); for slot 1 the x is clamped so the plate's left edge == `number_min_x()` (within 0.5 px) and y is unclamped.
No product code change. Then re-run
`node tools/mutate/mutate.mjs --file=project/features/souls/ghost_chip_number.gd --max=12 --lines=26-29 --tests=test_ghost_chip_number,test_ghost_form_hud,test_ghost_form_layout`
(time box 15 min; the baseline took 247 s) and quote killed/(killed+survived); the `0.0 -> 1.0` clamp slack may survive
(equivalent). Update the mutate line in `evidence/n29-keys/hud.md`. Commits: "keys n29: tests pin the chip number plate's
offset" then the evidence line.

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. `{GODOT_RULE}`.
Godot only through repo tools; the pre-commit hook can take 12 min (no shell timeout under 20 min).

## Allowlist
`project/tests/unit/test_ghost_chip_number.gd`, `evidence/n29-keys/hud.md`, `build/**`. Everything else: NEED. Banned: amend,
rebase, `git stash`, `git add -A/./-u`, `commit -a`, `reset --hard`. Fix lint and format findings in your own edit and go on.
Delete in Temp only what you created (mutate cleans its own worktree; if it leaves one, name it in the report).

## Report (short), then END
Tests added, unit result, mutate score before -> after, commit shas.
