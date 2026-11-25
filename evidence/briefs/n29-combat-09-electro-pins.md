# Brief n29-combat-09: pin the electro hash and fork arithmetic (tests only), re-score mutate

Lane combat, run n29. Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n29-combat` (stay on it). You are a builder
sub-agent; the director reviews your diff. Read `AGENTS.md` top rules first.

## Wall clock (hard)
- Launched 06:10. **Commit A (the new test file) by 06:40.** Commit B (mutate note) by 06:55. **Hard stop 07:00: report and END.**
- Never end before your commit lands (an uncommitted part is lost). No amend, no rebase, no stash, stage per path.

## Goal
The electro gun's live-current draw code (n29 item 3) has hash and fork arithmetic that no test pins: `mutate` survivors.
Pin them with **tests only** (no product code change), then re-run mutate and write the scores.

Files under test (READ ONLY, do not edit):
- `project/features/combat/weapons/art/weapon_fx_bolt.gd`: `spawn_id(origin)` (`posmod(q.x*7 + q.y*13, 997)` of the
  origin floored to 0.25 m) survived mutate (see `evidence/n29/electric/bolt.md` "## Mutate").
- `project/features/combat/weapons/art/weapon_fx_electro.gd`: `_serial(a, b)` (line ~155), `star_plan` / fork count
  (FORKS_MIN..FORKS_MAX), `stun_plan` (`7 + i` serial), `add_path` (stroke order: two halos, ink outline at
  `(BODY_PX + INK_EXTRA_PX) * k`, body `BODY_PX * k`, core `CORE_PX * k`; `outline=false` drops the ink), `to_px`.
- Existing tests: `project/tests/unit/test_weapon_fx_electro.gd` (200 lines: FULL, do not add to it).

## What to do
1. New file `project/tests/unit/test_weapon_fx_electro_hash.gd` (GUT 9.7.1, `extends GutTest`, typed, under 200 lines,
   functions <= 40 lines). Pin with exact expected values computed by hand from the formulas (write the arithmetic in a
   comment), e.g.: `spawn_id(Vector2(1.3, 2.6))` exact value; two origins inside one 0.25 m cell give the same id, the
   neighbour cells (+0.25 m in x, in y) give different ids and differ by the coefficient (7 / 13 mod 997); a negative
   origin goes through `posmod` (non-negative result, exact value); `_serial(a, b)` exact values and that swapping a/b
   changes it (the `* 31` weight); `stun_plan(p, tick, i)` for i 0 and 1 differ; the star fork count stays in
   [FORKS_MIN, FORKS_MAX] over a sweep of 40 serials and BOTH 3 and 4 occur; `add_path` widths exact at k = 1 and k = 0.5,
   order and count (5 with outline, 4 without). Call private `_serial` only if GDScript allows it from a test (it does for
   static funcs); if lint objects, test it through `chain_plan` determinism instead.
   Also: `WeaponFxElectro.cells` is a static var read from the command line: if any test sets it, restore it in
   `after_each`.
2. Run it: `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/combat` then
   `node tools/tests/run_unit.mjs --select=test_weapon_fx_electro_hash,test_weapon_fx_electro` -> all green.
   `node tools/lint/lint.mjs` green on your file (fix lint and format findings in your own edit and go on:
   `gdformat` it). A new `.gd` needs its `.uid`: run one Godot `--import` through the runner
   (`"$GODOT_BIN" --headless --path project --import` is NOT allowed raw; use `node tools/dev/run.mjs` is not for import:
   use `node tools/godot/check.mjs res://tests/unit/test_weapon_fx_electro_hash.gd` first, then the unit runner, which
   imports when the class cache is stale) and commit the `.uid` with the test. If no `.uid` appears, run
   `node -e "import('./tools/lib/godot.mjs').then(async m=>{const r=await m.runGodot(['--headless','--path','project','--import'],{timeoutMs:600000});console.log(r.code)})"`
   only if `tools/lib/godot.mjs` exports `runGodot` with that shape (read it first); otherwise report.
3. **Commit A**: `git add project/tests/unit/test_weapon_fx_electro_hash.gd project/tests/unit/test_weapon_fx_electro_hash.gd.uid`
   then `git commit -m "n29 electric: pin spawn_id, _serial, fork count and add_path widths (tests only)"` with the trailer
   `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. The pre-commit hook may take ~12 min: wait for it; if
   it fails on `tools/film/kill_reel_*.break.test.mjs`, the class cache is stale: run the import (above) and commit again.
   Never `--no-verify`.
4. Mutate (after commit A; each run has a time budget, stop it at 10 min):
   - `node tools/mutate/mutate.mjs --file=features/combat/weapons/art/weapon_fx_bolt.gd --lines=34-40,48-50 --max=12 --tests=test_weapon_fx_electro_hash,test_weapon_fx_electro`
   - `node tools/mutate/mutate.mjs --file=features/combat/weapons/art/weapon_fx_electro.gd --lines=<star_plan, add_path, _serial line ranges you read> --max=20 --tests=test_weapon_fx_electro_hash,test_weapon_fx_electro`
   (check the `--file` form against `tools/mutate/README.md`: project-relative). Quote killed/(killed+survived).
   Bar: >= 70 % on each; explain every survivor (equivalent or pixel-only).
5. **Commit B**: append a `## Call 9: hash and fork pins` section to `evidence/n29/electric/bolt.md` with the commands and
   scores; `git add evidence/n29/electric/bolt.md`, commit.

## Rules
- One Godot for the lane: before any Godot run check none of ours runs:
  `powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"Name like 'Godot%'\" | Select ProcessId,CommandLine"`
  and look for `n23-street` in the command line; wait if one is there. `wmic` is missing. Never start Godot raw.
- Before every Godot/mutate/test run: `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/combat` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- Allowlist (the only paths you may create or change): `project/tests/unit/test_weapon_fx_electro_hash.gd` (+ `.uid`),
  `evidence/n29/electric/bolt.md`. Any other path: stop and report a NEED. Do not touch `docs/decisions.md`, JOURNAL.md,
  REPORT.md, other lanes' worktrees, the HUD files (`ghost_form_hud.gd` etc.), or Temp files you did not create.
- No `print()`; typed everything; warnings are errors.
- `mem-budget: waiting` = the machine is full, not a hang: wait.

## Report (your final message)
Files, commit hashes, the test count passed/failed, the two mutate scores with survivors, what you could not do.
