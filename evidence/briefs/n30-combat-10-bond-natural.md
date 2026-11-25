# n30 combat call 10: one natural (no prefill) bond film of the gauntlet

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. Check `date +%H:%M` at start: **evidence commit by
minute 45, report and END by minute 60.** Never end uncommitted. No product code or data changes in this call (measurement).
Env before Godot: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
**One Godot at a time in this worktree**: before every launch wait until no file in `$LOCALAPPDATA/gtai/runs/*.json` names
`n23-street`, re-check every 30 s. Only through `runGodot` (the script below uses it). Windowed runs: `--position 0,1440`.

## What is known
n29 (`evidence/n29/bond/film.md`, `mastery.md`): the Tonnage-70 film was taken with `--bond-prefill=6` (labelled), because
`bond_film.gd` crashed at prefill 0; `820c8dfe5` fixed that. In n29's ten-seed measurement (average bot, greedy picks, wheel
controls) seed 1 mastered Tonnage at wave 7 (bond by wave 0, 12, 32, 48, 52, 64, 70). The owner has not seen a mastery
reached naturally. `evidence/n29/bond/render_bond.mjs <out> <32|64> <seed> <prefill> <fromTick> <toTick> [--waves=N]`
renders a tick window (BOT env picks the bot, default expert). The n29 ten seeds ran `res://dev/ghost-forms/bond_measure.tscn --fixed-fps=60 --bot=average --pick=greedy --seed=<n> --waves=15 --mastery-free=1` (`evidence/n29/bond/report.mjs:58`): the film should pass `--bot=average --mastery-free=1` too if `bond_film.gd` accepts them (check its flag list), so the natural take matches the measured seed.

## Do
1. Copy the script to `evidence/n30/bond/render_bond.mjs` (paths n29 -> n30). Pass 1: find the ticks. Run seed 1, prefill 0,
   `--waves=8`, BOT matching n29's measurement (read `evidence/n29/bond/` to see which bot name the ten seeds used; if the film
   scene only knows expert, use expert and say so) with a tiny render window (e.g. from=1 to=2) and read the log/result for bond
   full, mastery card offered, mastered, Tonnage entered ticks (the `bond-film:` lines and result.json). If seed 1 does not
   master by wave 8 with that bot, try seeds 8 and 5 (n29 mastered Ohm/Kerf) once each; record every attempt.
2. Pass 2: a 32 px/m film 25-40 s around the mastery (the card and the first Tonnage entry) to
   `C:/Users/kazda/kiro/gtai-masters/n30/combat/films/bond_natural_32.mp4` (1920x1080, 60 fps; `ffprobe` and quote
   width/height/r_frame_rate/duration). Look at 3 frames from it (extract with ffmpeg to build/) and say what you see.
   Append one `frames.json` entry there (re-read it just before writing; `{file,title,ppm,before,note}`, note says natural,
   no prefill, seed, bot, wave and tick of mastery).
3. `evidence/n30/bond/natural.md`: commands, per-attempt seed/bot/wave/ticks, the bond by wave if the log gives it, how this
   compares with n29's prefill-6 take (minutes of play to mastery). Commit the md and script
   (`n30 combat: natural bond film (seed S, mastery wave W, tick T)`).

## Commits
Stage per path, commit with a pathspec (`git commit -m "..." -- <paths>`); never `git add -A/./-u`, no stash, no amend, no
rebase, no reset --hard. End messages with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Never skip the hook.
Do not touch docs/decisions.md, JOURNAL.md, REPORT.md. A `mem-budget: waiting` line means the machine is full: wait, note minutes.

## Allowlist
`evidence/n30/bond/**`, `build/**`, the masters dir. Any other path: stop and report a NEED.

## Report and END
Attempts table, film ffprobe line, what you saw, what you could not do.
