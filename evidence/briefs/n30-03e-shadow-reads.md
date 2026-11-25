# Brief n30-03e `shadow-reads`: make Rivet's span shadow read IN PLAY (values only). Lane yard, run n30.

HARD STOP 17:12 (report and END). COMMIT by 17:08 or restore everything (`git checkout -- <file>` on your own edits) and report: the lane's green gate on `7d87cf75a` then stands. Check `date` every few minutes.

## Setup
Worktree `C:/Users/kazda/kiro/gtai-wt/n25-yard` (branch `n30-yard`). Bash, absolute paths. `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/yard`, `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Godot only through repo tools (`node tools/art/prologue_yard_film.mjs`, `node tools/tests/run_unit.mjs`, `node tools/dev/run.mjs`). Lane Godot slot `build/yard-godot.lock` (tag `shadow-reads` + pid, noclobber) around every Godot launch and commit.

## Problem
`arched_line.span_shadow` in `project/data/tables/prologue_yard_dressings.json` (line ~1441): alpha 0.75, offset_m (0.55, -0.6) (NORTH-east, so the blot sits under his body), size_m (1.9, 2.3), body_m (0.9, 1.9), fade 6; drawn by `project/boot/prologue/prologue_span_shadow.gd`, clipped to the span art. In play it is near-invisible: `evidence/yard30/span_shadow_play_64ppm.png` (seed 42, `--at=27.9,19.9`, ticks 7300 / 7450, before | after look the same).

## Work (fast, values only, no code change unless one line is unavoidable)
1. Try offset_m toward SOUTH-east so the shade falls clear of his body on the beam (start (0.6, 0.45)), alpha 0.9, size about (1.7, 1.3). Render ONE after still per try: `node tools/art/prologue_yard_film.mjs --dressing=arched_line --place=mid --tick=7450 --ppm=64 --still=<abs png> -- --seed=42 --at=27.9,19.9` (check the flag order against `tools/art/prologue_yard_film.mjs` usage and `project/dev/prologue_yard/yard_film.gd`), and Read the png. Bar: a dark soft shade on the span beside/below Rivet visible at a glance at 64 px/m, no dark rectangle edge, nothing on the floor off the span. At most 3 tries.
2. Compose before (the existing left halves of `evidence/yard30/span_shadow_play_64ppm.png` are fine as before) | after at ticks 7300 and 7450 to `evidence/yard30/span_shadow_reads_64ppm.png`, labelled with the values. Read it.
3. Update `project/tests/unit/test_prologue_span_shadow.gd` pins (lines ~41-46, ~134) to the new values; `node tools/tests/run_unit.mjs --select=test_prologue_span_shadow,test_prologue_raised_line`. The shadow is render-only: pilots cannot move, skip them. Fix lint/format findings in your own edit.
4. Commit table + test + png: `git commit -m "Yard n30: span shadow reads in play (offset SE, alpha ...)" -- <paths>`. Then one `docs/decisions.md` line (`git diff --quiet -- docs/decisions.md` first): `- [2026-11-25] DECISION yard n30 span shadow in play: ...` committed alone. Copy the png to `C:/Users/kazda/kiro/gtai-masters/n30/yard/` and replace the `span_shadow_play_64ppm.png` entry in its frames.json with it (valid JSON).

## Allowed
`project/data/tables/prologue_yard_dressings.json` (the `arched_line.span_shadow` values only), `project/tests/unit/test_prologue_span_shadow.gd`, `evidence/yard30/**`, `docs/decisions.md` (one line), `C:/Users/kazda/kiro/gtai-masters/n30/yard/**`, `build/**`. Everything else forbidden (JOURNAL.md, REPORT.md, other worktrees, project/features/**). No `git add -A/./-u`, `commit -a`, stash, amend, rebase, reset --hard, push, `--no-verify`. Kill only PIDs you started.

## Report (final message, then END)
Sha(s), values chosen, tries and what each looked like, test result.
