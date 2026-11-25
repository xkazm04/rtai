# Brief n29-combat-06-kill-card-scale: a killed card foe keeps its card size (NEED combat from cast)

Lane `combat`, branch `n29-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadline: see "Wall clock" at the end (binding). At the hard stop write your report and END, even
mid-task, committed.** Never stop to ask: at a fork pick what best serves the owner's words, write it in your report, go on.
Fix lint and format findings in your own edit and go on. No amend, no rebase, no push. Read `AGENTS.md` briefly.

## Why
The cast lane (`C:/Users/kazda/kiro/gtai-wt/n23-prologue/JOURNAL.md`, 03:33, read-only for you) wrote:
"NEED combat: `project/features/combat/kills/kill_fall_cells.gd` `_scale` / `height_px` size a killed card foe with the
crowd jitter only (no `CastCards.Sheets.scale_of`), so a kill style draws a card foe at 0.84-1.16 of its card size (a 1.23
Mulroney shrinks on a kill). Fix: take `pose.sheets.scale_of(actor_id)` when the victim is a card. Owner of the file: combat."
The owner's pick this run: every card foe measured against the patrol cop and scaled with ONE value each
(`cast_cards.json` `body_scale`). A kill must not change a foe's size mid-death.

## The merge catch (read this before coding)
`CastCards.Sheets.scale_of(actor_id)` and `build_jitter` exist only on branch `n29-cast` (commit 31df5170f, "card foes drop
the build jitter, one body_scale per foe"); on this branch `Sheets` has `body_scale` only, and the foe card views size
themselves their own way. Read both read-only: `git show n29-cast:project/features/characters/cast_cards.gd`,
`git show n29-cast:project/features/combat/squad/foe_shield_card_view.gd` (and its siblings), and this branch's copies.
You may NOT edit `cast_cards.gd` or any `foe_*_card_view.gd` (cast's files). So:
1. Find out first (code + a quick headless check) **which victims reach `KillFallCells.attach` / `height_px` / `_scale`**
   (and the sibling kill files that size a body by the crowd jitter: grep `StreetCrowdCards.vary` / `SCALE_VAR` under
   `project/features/combat/kills/`): street walkers only, or card foes too (Mulroney, contractor, gunner...). If card foes
   never reach these paths on either branch, the NEED is void: write why with file:line evidence in
   `evidence/n29/kills/card_scale.md`, commit it, END.
2. If they do: add ONE seam in a combat-owned file (e.g. `static func victim_scale(rig: CutRig) -> float` in
   `kill_fall_cells.gd` or a tiny new `kill_card_scale.gd` beside it) that returns **the same scale the live card view
   uses for that actor on this branch** (call the live view's own scale source, do not copy its arithmetic), and the crowd
   jitter for a non-card street walker (today's behaviour unchanged). Route `_scale` and `height_px` (and any sibling that
   sizes a dying body the same way) through it. Write in `card_scale.md` the exact one-line change the Director makes after
   merging `n29-cast` (most likely `sheets.scale_of(rig.actor_id)`), and make the unit test compare the seam against the
   live view's scale source (so a merge that leaves the seam stale fails the test, not the eye).
3. Test `project/tests/unit/test_kill_card_scale.gd` (+ `.uid`): a card victim's fall scale equals its live card scale;
   a street walker keeps the jitter (pin one actor id's value from today's code); same id -> same value.
   `node tools/tests/run_unit.mjs --changed` green.

## Evidence
A 64 px/m before/after still of one card foe killed by a kill style that uses the fall grid (find one in
`signature_kills.json` / `kill_new_styles.gd`; Mulroney or the gunner if card rows are on, otherwise say which foe), last
living frame beside the first fall frame, height in px of both measured from the PNG (bar: the fall frame within 3 % of the
living frame). If no card foe is switched on on this branch so nothing changes on screen, say so and give the test as the
evidence. Stills to `C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/kill_card_scale_*.png`, entry in
`C:/Users/kazda/kiro/gtai-masters/n29/combat/frames.json` (re-read before writing, keep others). Mutate:
`node tools/mutate/mutate.mjs --file=<the seam's file> --max=15 --lines=<changed lines> --tests=test_kill_card_scale`
(budget 10 min), quote the score in `card_scale.md`.

## Repo law (binding)
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe GTAI_GODOT_EST_MB=1000`
  (600 headless). Windowed only at `--position 0,1440`. Godot only through `tools/dev/run.mjs` / `runGodot` / film / test
  tools. **One Godot at a time for the whole lane**: another builder (the electro bolt, renders) works beside you; before
  each Godot run check `tasklist //FI "IMAGENAME eq Godot*"` and wait if one runs that you did not start. Never kill a
  process you did not start, never by name. `mem-budget: waiting` = the 16 GB cap: wait.
- `node tools/gate/quick.mjs` before every commit. The pre-commit hook takes up to ~12 min; if it fails on
  `tools/film/kill_reel_*.break.test.mjs`, run a Godot `--import` and commit again. Never skip the hook.
- Typed GDScript, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not print, `.uid` with new `.gd`,
  Godot `--import` after a new script. Stage per path. Banned: `git stash`, `git add -A/./-u`, `git commit -a`,
  `reset --hard`, amend, rebase, push. One appended `docs/decisions.md` line if behaviour changes
  (`- [2026-11-25] DECISION n29 combat: ...`); another builder may append too: commit both lines, they are legitimate.
  Commit trailer: `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Never delete anything in Temp you did not create; report it. Replays, parity, scenarios: presentation only, unchanged.

## Allowlist (any other path: stop that part and report `NEED <what>`)
`project/features/combat/kills/**` (+ `.uid`), `project/tests/unit/test_kill_card_scale.gd` (+ `.uid`), other
`project/tests/unit/test_kill_*.gd` only if a pinned value moves, `docs/decisions.md` (one line), `evidence/n29/kills/**`,
`build/**`, `C:/Users/kazda/kiro/gtai-masters/n29/combat/`.
Forbidden: `cast_cards.gd`, `cast_cards.json`, `foe_*_card_view.gd`, every PNG, `project/features/combat/weapons/**`
(another builder), the HUD files, `project/boot/**`, other worktrees, root `JOURNAL.md` / `REPORT.md`.

## Report and END (short)
Who reaches the path (file:line); the seam; the post-merge line for the Director; test + units; stills with measured
heights; mutate score; what was left.

## Wall clock (binding)
Started 03:52. Step 1 finding written down by **04:10**. Commit A (seam + test, or the "void" note) by **04:35**.
Evidence + mutate committed by **04:55**. HARD STOP **05:00**: report and END, committed.
