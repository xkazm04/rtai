# Brief b3-takes (lane foes, run n31): play takes of the gauntlet, main beside HEAD

Worktree (your cwd): `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n31-foes`.
Hard stop: **60 minutes after launch, report and END**. First commit within **25 minutes**; commit each
finished part as soon as its checks pass. Never end with uncommitted work or a commit stuck in the hook.

## Why
The owner judges by films of real play, the way he plays: `res://dev/gauntlet/gauntlet.tscn -- --pick-view`
(wave mode, wheel controls default, tilt 70, 32 px/m). Tonight this lane changes how enemies move and when
they fire. Every change needs a take of the real gauntlet, before (main `ba8e470b0`) beside after (HEAD),
same seed, same ticks. This brief builds the film tool and shoots the BEFORE|HEAD takes of whatever HEAD is.

## What exists (read these first)
- `tools/gauntlet/pressure_films.mjs` + `project/dev/gauntlet/pressure_film.gd`: renders a scene with
  `--rendering-driver d3d12 --position 0,1440 --resolution 1920x1080 --fixed-fps 60 --disable-vsync
  --quit-after N`, the scene writes `%04d.jpg` frames itself, ffmpeg encodes, and a side-by-side is the
  centre 960 px of each take `hstack`ed to 1920x1080 (L161-205). Copy that pattern.
- `project/dev/gauntlet/gauntlet.gd` (shared, READ-ONLY): `--pick-view` = `ViewMode.select("tilt70")`,
  32 px/m (`camera_ppm`), the pick cards; with `--bot=<profile>` the bot plays and picks.
  `project/dev/test_player/gauntlet_bot_film.gd` shows how to extend it (`extends "res://dev/gauntlet/gauntlet.gd"`).
- `tools/gauntlet/waiting.mjs` + `project/dev/foes_n31/waiting_probe.gd`, `waiting_tally.gd` (b1, committed; read them) has a `--rev=<commit>`
  temp-worktree mechanism (tools/mutate/worktree.mjs + tools/gauntlet/prepare_worktree.mjs) that runs a
  probe at another commit. Reuse it (import its helper; if it is not exported, factor it into a small shared
  module under `tools/gauntlet/` that both use, without changing waiting.mjs behaviour).

## Build
1. `project/dev/foes_n31/play_take.tscn` + `.gd` (`extends "res://dev/gauntlet/gauntlet.gd"` or the bot film
   scene, **no caption box**): flags `--take-wave=<n>` (fast-forward the simulation WITHOUT rendering to
   `lead_s` (default 1.0 s) before wave n's first enemy spawns: step the session in a loop inside one frame,
   e.g. a deferred call after `super._ready()`, the way `_run_headless` steps), `--take-s=<seconds>`
   (frames written after the fast-forward), `--frames-out=<abs dir>` (write `%04d.jpg` per rendered frame
   like pressure_film.gd), `--zoom-ppm=<32|64>` (default 32; set `view.px_per_m`), optional
   `--follow=<archetype>` for the 64 px/m close-up (centre the camera on the nearest living enemy of that
   kind instead of Rivet, if the view allows it from your scene; otherwise skip and say so). Print one
   summary line `[INFO] play-take: {json}` with seed, wave, first rendered tick, frames, and per second the
   count of enemies alive and of enemies that fired (read like b1's probe; reuse its code if it is a class).
   Pass through every other gauntlet flag (`--seed`, `--bot`, `--pick`, `--controls`, `--pick-view`, and
   `--foe-moves=legacy|split` if it exists in `project/boot/launch_args.gd` KNOWN_FLAGS by then).
2. `tools/gauntlet/play_takes.mjs` (+ a node:test for its arg parsing and plan): 
   `--seed=<n> --wave=<n> --seconds=<15..40> --profile=average --out=<abs masters dir> --name=<stem>
   [--left=rev:<commit>|flags:<extra flags>] [--right=HEAD|flags:<extra flags>] [--ppm=32|64]`.
   Renders the left take (default `rev:ba8e470b0`) and the right take (default `rev:<HEAD sha at launch>`;
   `--right=live` = the live tree, refused when `git status --short project/` is dirty: another builder (b2)
   edits project/ in this worktree right now, so use revs), both through the temp-worktree mechanism, each with `--bot=<profile> --pick=greedy
   --controls=wheel --pick-view`, then writes `<name>_left.mp4`, `<name>_right.mp4` (1080p60, h264, crf 20)
   and `<name>_side.mp4` (centre 960 px of each, `hstack`, with a small `drawtext` label "main" / "HEAD"
   (or the flag set) top-left of each half, crf 23), and checks each with `ffprobe` (duration within 0.1 s
   of `--seconds`, 60 fps, 1920x1080). Scratch under `build/n31/takes/`; only the mp4s go to `--out`.
   All Godot runs through `runGodot` (tools/lib/godot.mjs), sequentially, one at a time.
3. **Shoot** into `C:\Users\kazda\kiro\gtai-masters\n31\foes\` (create it): seed 3 (or the first seed in
   1..10 where the average bot reaches wave 7 in b1's run files under `evidence/n31/foes/waiting-main/`):
   `wave1_side` (wave 1, 30 s), `wave3_side` (wave 3 or 4, 30 s), `wave6_side` (wave 6 or 7, 30 s), left
   = main, right = HEAD (HEAD now has b2's fight/travel gait: `--foe-moves=split` is the default there). Look at 3 frames of each
   side film yourself (extract with ffmpeg, Read the png) and describe in one line each what the enemies
   do. Write/update `C:\Users\kazda\kiro\gtai-masters\n31\foes\frames.json` (array, best first:
   `{file,title,ppm,before,note}`; `before` = the left take file or null).

## Acceptance
- `node --test "tools/gauntlet/play_takes.test.mjs"` green, `node tools/lint/lint.mjs` green,
  `node tools/godot/check.mjs res://dev/foes_n31/play_take.gd` ok.
- Three side films exist, ffprobe-verified (quote the ffprobe duration/size lines), each 15-40 s.
- Left and right show the same seed and the same wave start tick (print both first ticks; they must match
  when the waves start at the same tick; if they do not (the AI change moves wave timing), say by how much).

## Repo law (read AGENTS.md first)
- Typed GDScript, warnings are errors, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log`
  not `print`. New `.gd` -> commit its `.uid` (one Godot `--import` before the commit). Declare the scene's
  flags (see how gauntlet.gd and `tools/dev/run.mjs` check `KNOWN_FLAGS`; extend the const in YOUR scene).
- Stage per path, `git commit -- <paths>`. Banned: `git stash`, `git add -A/./-u`, `git commit -a`,
  `reset --hard`, amend, rebase, push, `--no-verify`. Message ends with
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Fix lint and format findings in your own edit and go on. If the hook fails on a
  `kill_reel_*.break.test.mjs`, the class cache is stale: run a Godot `--import`, commit again.
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/foes` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
  Windowed runs always `--position 0,1440` (secondary monitor), `--rendering-driver d3d12`.
  **One Godot at a time for the whole lane**: hold the lane lock `build/n31/godot.lock` (create it
  exclusively with content `b3 <pid>`; while another tag holds it, wait and re-check every 30 s; delete it
  when your Godot exits; never delete a lock that is not yours). `mem-budget: waiting` = machine full: wait.
- Never touch `main`, other worktrees, `C:\Users\kazda\kiro\pof`. No Codex, no API keys. No tool or script
  may live under `gtai-masters` (films and frames.json only).

## Owned files (allowlist; any other path: stop and write a NEED in your report)
- `project/dev/foes_n31/play_take.*` (new), `tools/gauntlet/play_takes*.mjs`, a new shared helper under
  `tools/gauntlet/` for the rev worktree (and the import line in waiting.mjs only if you factor it out),
  `C:\Users\kazda\kiro\gtai-masters\n31\foes\**`, `evidence/n31/foes/takes/**`.
- Read-only: everything else. Forbidden: `project/features/**`, `project/data/**`, `project/dev/gauntlet/**`,
  other lanes' files, `docs/decisions.md`.

## Report (your final message)
Files, commits, commands with result lines, the three films (path, duration, size) with your one-line
description of each, what you could not do and why.
