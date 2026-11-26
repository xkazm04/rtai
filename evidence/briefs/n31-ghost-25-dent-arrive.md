# n31 ghost 25 - Dent's body reaches the cops on the ram tick (the hit no longer lands before he arrives)

Builder tag: `g25-dent-arrive`. **First commit within 20 minutes; hard stop 35 minutes after launch** (last commit START 15 min before it). Report and END. Launch time: see the addendum.
Worktree (cwd): `C:\Users\kazda\kiro\gtai-wt\n25-yard`, branch `n31-ghost`. Read `AGENTS.md`, `git log --oneline -15`, `evidence/n31/ghost/take-dent.md` (g19: "at R the hit stars and the scuffed lane are drawn while Dent's body is still behind Rivet; he reaches the cops ~4 ticks later"), `project/features/souls/dent_drop_beats.gd`, `dent_drop_marks.gd`, `test_dent_drop*.gd`.

## Why
The ram resolves on R (the charge's last tick, P + 15) for every body in the lane, but the view dives origin -> spot over R..R+8, so cops fall before Dent touches them. A player sees cause after effect.

## Director decision (do not reopen)
Keep the sim (hits on R, charge 0.25 s, no digest move). Move the view: the DIVE runs R-6..R (ease-out quad, origin -> spot), so the body is at the spot ON R; COCK holds P+4..R-7; JAB from R to the fade. The wake (`DentDropBeats.dive`) follows the same path R-6..R+1; the skid telegraph stays whole by R-6 (reveal P+4..R-6); the lane scuff still replaces the skid on R; the launch puff on R-6 (not R). Keep the shape so the dive length is ONE constant (`DIVE_TICKS` 6).

## Do
1. `DentDropBeats` + `DentDropMarks` timing as above; update their tests (the skid front whole by R-6; body at the spot on R; COCK before R-6). `node tools/tests/run_unit.mjs --select=test_dent_drop,test_dent_drop_marks,test_dent_drop_beats` (whatever exists) green. Commit.
2. A 64 px/m still pair through the dev probe `project/dev/ghost_n31/ghost_n31_dent_beats*` at R-3 (mid-dive) and R (body at the cops, the hit): Read both; the body must be at the spot on R. Copy to `C:\Users\kazda\kiro\gtai-masters\n31\ghost\dent-arrive-{dive,hit}-64ppm.png` + frames.json entries (keep existing). Commit any probe change.
3. One `docs/decisions.md` line (`- [2026-11-26] DECISION ghost n31 Dent arrival: dive R-6..R so the body meets the ram tick; sim unchanged`), only when `git diff --quiet docs/decisions.md` is clean, committed alone.

## Rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/ghost` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`. Lane Godot lock `build/n31/godot.lock` per run (`g25-dent-arrive <pid>`, helper: copy `build/n31/g17lock.sh` with your tag; never delete another's; wait). Godot only through the repo tools.
- Allowlist: `project/features/souls/{dent_drop_beats.gd, dent_drop_marks.gd, dent_body.gd}`, `project/tests/unit/test_dent_*.gd`, `project/dev/ghost_n31/ghost_n31_dent_beats*`, `docs/decisions.md` (one line), `evidence/n31/ghost/**`, `build/n31/**`, masters ghost folder. Any other path: STOP, report a NEED. A parallel builder works on Kerf files: never touch or stage them.
- Typed GDScript, <= 40 lines/function, `Log` not `print`. Fix lint and format findings in your own edit and go on. Stage per path, `git commit -m "..." -- <paths>`; no add -A/./-u, stash, amend, rebase, reset --hard, --no-verify. Commit messages end with a blank line then `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Mutate: skip.

## Report
Commits, the two stills and what you saw, tests, NEED lines, what was not done.

## Added 03:17 (director) - launch times
Launched 03:17. **First commit by 03:35, last commit START by 03:35, hard stop 03:47: report and END.** Parts 1 and 2 are the must; 3 only if committed by 03:40. A parallel builder `g24-kerf-relock` (Kerf files, measure dev files) shares the lane Godot lock.
