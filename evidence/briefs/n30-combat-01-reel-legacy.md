# n30 combat call 01: kill_reel.mjs passes `--controls=legacy` by default

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. Hard stop: 25 minutes after start; commit by minute 15.

## Goal
`tools/film/kill_reel.mjs` kills nothing at HEAD unless `-- --controls=legacy` is passed (the dev arena starts on wheel/hands
controls and takes the lab's gun away). Make the reel append `--controls=legacy` to the game flags it passes to each film
**by default**; a `--controls=<x>` the caller passes after `--` still wins (no duplicate, caller's value only).

## Do
1. Read `tools/film/kill_reel.mjs` and find where the extra game flags (after `--`) are collected and handed to `film.mjs`.
   Put the default in one small exported pure function (e.g. `withControls(flags)` -> flags plus `--controls=legacy` unless
   any flag starts with `--controls=`) in `kill_reel.mjs` or `kill_reel_lib.mjs`, and use it on that path (also for
   `--before`/`--rev` films if they go through a separate path). Mention it in the file's usage header comment.
2. Node test in `tools/film/kill_reel.test.mjs` (or the lib's test): default added; caller's `--controls=wheel` kept and no
   legacy added; other flags kept in order.
3. `node --test tools/film/kill_reel.test.mjs` and `node --test "tools/film/*.test.mjs"` (the `.break.test.mjs` ones need Godot's
   class cache; if they fail on a stale cache, run `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat` then
   `node tools/godot/check.mjs` is not needed: just note it).
4. `node tools/dev/run.mjs` is not needed. Prove with `--dry-run`: `node tools/film/kill_reel.mjs --out=build/kreel/dry --weapons=machine_pistol --quick --dry-run`
   shows `--controls=legacy` in the planned command; with `-- --controls=wheel` it shows only wheel. Paste both lines in your report.
5. `node tools/lint/lint.mjs` if it lints .mjs (fix findings in your own edit and go on).
6. Commit: stage per path (`git add <path>`), message `n30 combat: kill_reel passes --controls=legacy by default (a passed --controls= wins)`,
   ending with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. The pre-commit hook may take ~10 min; never skip it.
   If it fails on `tools/film/kill_reel_*.break.test.mjs` with a stale class cache, run
   `node -e "import('./tools/lib/godot.mjs').then(m=>m.runGodot(['--import'],{name:'import'}))"` (with
   `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`)
   and commit again. One Godot at a time in this worktree: another builder may be filming; if a Godot of this
   worktree is running, wait for it.

## Allowlist (any other path: stop and report a NEED)
`tools/film/kill_reel.mjs`, `tools/film/kill_reel_lib.mjs`, `tools/film/kill_reel.test.mjs`, `tools/film/kill_reel_lib.test.mjs` (new ok).
Forbidden: everything else, other lanes' worktrees. No amend, no rebase, no `git add -A/./-u`, no stash, no `reset --hard`.
Don't touch `docs/decisions.md`, JOURNAL.md, REPORT.md.

## Report and END
Files, commit hash, the commands run with their result lines, what you could not do.
