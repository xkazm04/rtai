# Brief b3b-takes (lane foes, run n31): play takes main | HEAD for waves 1, 3, 6 + a 64 px/m gait clip

Worktree (your cwd): `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n31-foes`. Read `AGENTS.md` and
`tools/gauntlet/play_takes.mjs` (b3 wrote it, commit 91f93eb0a) first.
**Hard stop: 60 minutes after launch, report and END.** Commit each finished part as soon as it is done.

## Why
The owner judges by films of real play (the gauntlet, wheel controls, 32 px/m, tilt 70, 1080p60). Item 2
(enemies FIGHT slow and may fire, TRAVEL fast and may not) and item 3 (more of them open fire sooner) are on
HEAD; main is `ba8e470b0`.

## Do
1. **File size:** the side takes are 108-196 MB per 30 s (crf 20/23 on a paper-grain image). Change
   `play_takes.mjs` so each mp4 is <= 25 MB per 30 s at 1080p60 (try `-crf 28 -preset slow` and, only if still
   over, `-tune grain` off / a `-maxrate 6M -bufsize 12M` cap); check a frame at 1:1 for visible blocking on
   the cops before accepting. Re-encode the existing wave 1 files from their frames if the tool kept them;
   otherwise re-shoot wave 1. Node test for the argv change. Commit.
2. **Takes** (seed 3, average profile, 30 s, `--left=rev:ba8e470b0 --right=HEAD`): `--wave=3 --name=wave3_side`,
   `--wave=6 --name=wave6_side`, and wave 1 if re-shot. Check each with
   `ffprobe` (1920x1080, 60 fps, 15-40 s). Out: `C:\Users\kazda\kiro\gtai-masters\n31\foes\`.
3. **64 px/m gait clip** (HEAD only, `--ppm=64 --follow=patrol_cop`, 15-20 s, name `gait64_patrol`): one patrol
   cop walking backwards slowly while it fires, then turning and running when Rivet closes inside 4 m. Pick
   seed/wave/start so the clip shows it (scout first; the take JSON has per-second fired counts). If the tool
   cannot follow one cop, add a `--follow` fix in your own files.
4. **Look at the frames yourself**: extract 4 stills per side clip (`ffmpeg -ss <t> -frames:v 1`) and Read
   them. In your report, for each take, say in one sentence what the cops do on each side (how many fire, how
   far, do they walk slowly while firing, run without firing) and quote the take JSON's mean alive / fired per
   second for each side.
5. Upsert `C:\Users\kazda\kiro\gtai-masters\n31\foes\frames.json` rows (best first, `file`, `title`, `ppm`,
   `before`, `note`); delete scratch renders it does not reference (only ones you made). Commit the take JSONs
   under `evidence/n31/foes/takes/`.

## Godot
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/foes` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
Lane lock `build/n31/godot.lock` (exclusive create, content `b3b <pid>`; wait while another tag holds it,
re-check every 30 s; delete only yours). Godot only through runGodot (the tool already does). Windowed runs go
to `--position 0,1440` (secondary screen), never the main display. `mem-budget: waiting` = machine full.

## Owned files (allowlist; anything else: NEED in your report)
`tools/gauntlet/play_takes*`, `tools/gauntlet/rev_tree.mjs`, `project/dev/foes_n31/play_take.*`,
`evidence/n31/foes/takes/**`, `C:\Users\kazda\kiro\gtai-masters\n31\foes\**` (films and frames.json only; no
scripts there). Forbidden: game code, data tables, `tools/gauntlet/waiting*`, other lanes' files.

## Repo law
Stage per path, `git commit -- <paths>`; banned: `git stash`, `git add -A/./-u`, `git commit -a`,
`reset --hard`, amend, rebase, push, `--no-verify`. Message ends with
`Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Fix lint and format findings in your own edit and go
on. Remove any temp worktree you create (`git worktree remove`), only yours.

## Report (final message)
Commits, files written (path, size, ffprobe line), the per-take sentences, what you could not do.
