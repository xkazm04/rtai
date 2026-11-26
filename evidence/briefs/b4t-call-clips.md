# Brief b4t-call-clips (lane foes, run n31): clips for owner calls 3 and 2 (evidence only)

Worktree (cwd) `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n31-foes`. **Hard stop 35 min after launch:
report and END.** Commit each take JSON as soon as it is checked (inert evidence-only commits, fast). Never end
with a commit in the pre-commit hook. No game code changes: the lane's gate already passed.

## Why
REPORT "Calls for the owner" 3 (each kind its own gun against the shared assault rifle) and 2 (simultaneous
shooters: fixed 2 against a share of the ranged alive) have numbers but no clip. The owner judges by real play.

## Do (in this order; take 2 only if take 1 is committed and 15+ min remain)
1. Call 3: `node tools/gauntlet/play_takes.mjs --seed=3 --wave=1 --seconds=30 --name=call3_guns
   --left=rev:8ce3eb779 --right=rev:0fbe651eb` (left = share 0.35 + everyone the shared assault rifle; right =
   share 0.35 + each kind its own gun; read `evidence/briefs/b4p-wave6.md` and
   `evidence/n31/foes/takes/wave6_side.json` for how the tool ran; output into
   `C:\Users\kazda\kiro\gtai-masters\n31\foes\`). Wave 1 is 13 patrol cops: pistol (2-round burst) vs rifle bursts.
2. Call 2: same command with `--name=call2_shooters --left=rev:ebcd2f37b --right=rev:8ce3eb779` (left = the two
   moves with the fixed 2 shooters; right = the same with `max(3, ceil(0.35 x ranged alive))`).
3. For each take: ffprobe each clip (1920x1080, 60 fps, ~30 s); stills of left and right at 5 and 12 s (ffmpeg into
   `build/n31/stills/b4t/`), Read them yourself; one honest sentence per side (how many fire, burst rhythm if
   visible, Rivet's health), quoting the take JSON's mean alive / fired per second.
4. Re-read `C:\Users\kazda\kiro\gtai-masters\n31\foes\frames.json` right before writing; the tool may already have
   added the row; keep every entry, valid JSON, these rows go after the existing ones, max 12 entries in total.
   Commit `evidence/n31/foes/takes/<name>.json` per take (stage per path).

## Binding
`export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/foes` and
`export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'` before every
run; Godot only through the tool (runGodot). Lane lock `build/n31/godot.lock`: the tool writes its own tag; never
delete a lock that is not yours. `mem-budget: waiting` means the machine is full, not a hang. Owned:
`evidence/n31/foes/takes/**`, the masters folder above; any other path: stop and report a NEED. Do not edit game
code, tools, JOURNAL.md, REPORT.md, `docs/decisions.md`. Stage per path, no amend/rebase/stash/--no-verify, no
`git add -A/./-u`. Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
Report: commits, the commands with result lines, ffprobe lines, the per-side sentences with the means, what you
could not do.
