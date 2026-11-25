# n30-07 arsenal-turn-fire: `arsenal_turn_rec.gd` fires again at HEAD, with a test (lane keys, item 4)

**Commit within 25 minutes of launch; report and END within 40** (`date +%H:%M` at start; write both deadlines in your first
line). Work in `C:/Users/kazda/kiro/gtai-wt/n23-controls` (branch `n30-keys`). Never amend, rebase, push, stash,
`git add -A/./-u`, `commit -a`, `reset --hard`. Stage per path. Fix lint and format findings in your own edit and go on.

## The bug
`project/dev/rivet_arsenal/arsenal_turn.gd` (driver of `arsenal_turn_rec.gd`) cannot fire any gun at HEAD:
`no attack for <weapon> at octant 0`, exit 1 (pistol and Gloria alike). Cause and the proven dev-only fix (used in an n29
snapshot, never committed) are in `evidence/n29-keys/gloria_strips.md` section "n29-15": with `wheel_inventory` on,
`RivetCarry.take` selects nothing and the first `session.step()` runs the hands-first wheel, which stows the gun
(`RivetWheel._stow`). Fix: `TurnPad.slot` ORs the weapon's slot key bit (`RivetCarry.SLOT_ACTIONS[slot]`) for one `_step()`
before `_record()`, then 5 idle steps (about +8 lines); and the still crop `Vector2i(204, 194)` -> `(404, 294)`, base 164 -> 214
(the stock crop clips every diagonal flash).

## Do
1. Reproduce at HEAD (one run, the runGodot command in that md, `--weapon=pistol --pitch=p55 --ppm=64`, out under `build/`): exit 1.
2. Apply the fix in `project/dev/rivet_arsenal/arsenal_turn_rec.gd` (and `arsenal_turn.gd` only if needed). Keep files <= 200 lines
   (hard 300), functions <= 40 lines, typed, `Log` not `print`.
3. A test that fails before and passes after: extend `project/dev/rivet_arsenal/test_arsenal_turn.gd` (read how it is run: it
   lives in `dev/`; if GUT does not collect it, put the test in `project/tests/integration/` or `tests/unit/` where the arsenal
   tests are collected, naming the class under test; lint's `layers` check allows tests to name dev classes only where the
   existing tests already do - check). The test asserts the gun is still equipped after the slot step and that an attack is
   recorded at octant 0 (or the smallest observable equivalent). Prove it red on the unfixed code (say how) and green after.
4. Re-run step 1's command with `--weapon=pistol` and `--weapon=gloria`: exit 0, 16 stills each; look at two stills
   (octant 1 and 7) and say whether the flash is whole.
5. `node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs`, commit
   `fix(keys n30): arsenal turn recorder equips the gun before firing (wheel stowed it), wider still crop`.
6. `node tools/mutate/mutate.mjs --file=project/dev/rivet_arsenal/arsenal_turn_rec.gd --max=10 --lines=<your changed lines> --tests=<your test basename>`
   with a 10-minute budget; quote killed/(killed+survived). Write `evidence/n30-keys/arsenal_turn.md` (bug, fix, test red/green,
   runs, mutate score) and commit it.

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Lane lock
`build/n30-godot.lock` (exclusive create with tag `n30-07` + pid; if another tag holds it, wait; never delete another's).
Only through runGodot / repo tools. d3d12, windowed `--position 0,1440`. Free only your own processes, by PID.

## Allowlist (anything else: stop and report a NEED)
`project/dev/rivet_arsenal/**`, one test file you add or extend (name it in the report), `evidence/n30-keys/arsenal_turn.md`,
`build/**`, `C:/Users/kazda/kiro/gtai-masters/n30/keys/arsenal/**`. Forbidden: `project/features/**`, data tables, art, `JOURNAL.md`,
`REPORT.md`, `docs/decisions.md`, combat/cast/yard files, other worktrees; `p55/rivet_run8.png` and the collar round (another builder).

## Report (short), then END
Commit shas, test name + red/green proof, the two runs' exit codes and still paths, mutate score, what you could not do.
