# n31 ghost 04 - play take of the new Tonnage drop: gauntlet, wheel controls, main | HEAD at the same seed

Builder tag: `g04-take`. **Commit each finished part by 25 minutes into the call; hard stop 60 minutes after launch: commit what passes, report, END.**
Worktree (cwd): `C:\Users\kazda\kiro\gtai-wt\n25-yard`, branch `n31-ghost`. Read `AGENTS.md`, `git log --oneline -10`, `evidence/n31/ghost/measure-main.md` (and `measure-head.md` if present), `docs/gauntlet-loop.md` lines 265-285 (the gauntlet film recipe).

## Why
The owner judges by films of real play. Item 2 (commit `d7db0eb24`) made Tonnage one press, a 0.45 s charge, a 5.5 m full-circle dump. The first clip must be the gauntlet with the default wheel controls, Tonnage dropped on a real cluster in a wave, before (main `ba8e470b0`) beside after (HEAD), same seed and ticks.

## What to build / do
1. A dev film scene under `project/dev/ghost_n31/` (e.g. `ghost_n31_take.tscn` + `.gd`) that extends `res://dev/test_player/gauntlet_bot_film.gd` (or composes it) and unlocks Tonnage from the start and selects it the same way `project/dev/ghost_n31/ghost_n31_play.gd` does (read it: `locks.done = [tonnage]`, only free ghost, selected), so the shipped bot drops Tonnage whenever ready. Flags: the gauntlet's own (`--seed --bot --pick --controls --waves --pick-view --result`) declared in `KNOWN_FLAGS`. The default controls are wheel.
2. Pick a seed and a window: run headless first (fast) on HEAD and on main to find a deploy on a cluster of >= 5 foes in wave 2 or 3, in BOTH runs at nearly the same tick (the runs share the seed; the first deploy should match until the first Tonnage). Name the tick window (press tick, dump tick = press + 27 on HEAD).
3. Render 1080p60 at 32 px/m, tilt 70 (the gauntlet's default camera), `--fixed-fps 60 --write-movie`, windowed on the secondary screen `--position 0,1440`, `--rendering-driver d3d12`, a 15-30 s clip covering 2-3 Tonnage deploys, for main (a temp worktree at `ba8e470b0` with your dev scene copied in: `git worktree add <path> ba8e470b0`; native DLLs: copy this worktree's `project/native/bin/*.dll` if the new worktree lacks them; `--import` there; remove the worktree after) and for HEAD. Every Godot through `runGodot` (`node tools/dev/run.mjs <scene> --windowed ... -- <flags>` supports `--windowed`; or a tiny node script calling `runGodot` from `tools/lib/godot.mjs` with `{headless:false}`); write-movie needs the 1920x1080 viewport: follow the recipe's scratch capture project (junctions + `override.cfg`) or `--resolution 1920x1080` if that gives a 1920x1080 movie (check with ffprobe).
4. Encode (ffmpeg libx264, CRF 18, yuv420p) and make a side-by-side `main | HEAD` mp4 (hstack, labelled "main" / "n31 ghost" with drawtext), 15-40 s, plus each side alone. ffprobe each length.
5. A 64 px/m still pair (main | HEAD) at the dump tick of one deploy (`gauntlet_bot_film_closeup.tscn` is the 64 px/m variant: check the closeup scale, or the camera zoom).
6. Output to `C:\Users\kazda\kiro\gtai-masters\n31\ghost\` (films and stills ONLY, no scripts) and add entries to `frames.json` there (create it if missing; a JSON array, best first: `{ "file", "title", "ppm", "before", "note" }`, `before` = the main file name or null).
7. Count, from the HEAD and main runs' probe/result, the hits and kills of each filmed deploy, and write one paragraph to `evidence/n31/ghost/take-drop.md`: seed, ticks, per deploy hits/kills main vs HEAD, the files, and one sentence a player would say about the difference (honest; if the charge reads as lag on screen, say so).

## Rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/ghost` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`. **Lane Godot lock** `build/n31/godot.lock` (wait, write `g04-take <pid>`, delete yours after; never another's). One Godot at a time. No `--reels`.
- Allowlist: `project/dev/ghost_n31/**`, `evidence/n31/ghost/**`, `build/n31/**`, `C:\Users\kazda\kiro\gtai-masters\n31\ghost\**`, `tools/debt/baseline.json` via `node tools/debt/debt.mjs --update --accept-regression="n31 ghost take scene"` only if the ratchet names your dev folder. Anything else: STOP, report a NEED. Never edit `project/dev/gauntlet/**`, `project/dev/test_player/**`, other lanes' files.
- Typed GDScript, <= 200 lines/file, <= 40 lines/function, `Log` not `print`. New `.gd` -> `--import` via runGodot, commit the `.uid`.
- Fix lint/format findings in your own edit and go on. Stage per path, `git commit -- <paths>`; no add -A/./-u, stash, amend, rebase, reset --hard; never skip the hook (~12 min). Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Report
Seed and ticks, files (paths, ffprobe lengths), commits, per-deploy numbers main vs HEAD, the one-sentence feel, what you could not do.

## Added 22:40 (director, session 2) - overrides the above where they differ
- HEAD now: radius 6.5 m (`0f81d27dd`), the four drawn beats from `g03-beats` (read its commits in `git log`: telegraph cracks over the charge, shock ring + crack at the true radius, crater 2 s + 1 s fade, body strip). Film after them. Read `evidence/n31/ghost/measure-head.md` and the 6.5 m numbers in JOURNAL 22:17.
- Reuse first: `project/dev/ghost_n31/ghost_n31_play.gd` already unlocks/selects Tonnage for the measure's play mode; `tools/ghost/deploy_measure.mjs` already runs a main temp worktree (read how it does it). Do not rebuild what exists.
- The main side: on main the deploy is hold-to-aim; the shipped bot handles it. Same seed; the two runs diverge after the first Tonnage deploy, which is fine: label each deploy's tick in the film's notes.
- Name the dump-tick windows before rendering. Film the gauntlet's default camera (32 px/m, tilt 70, `--pick-view`), wheel controls (default).
- Also wanted in this call if time remains: the half-speed 64 px/m clip of one whole deploy (lead-in, drop, charge, dump, crater fade; 15-40 s), `ffmpeg setpts=2.0*PTS`.

## Added 23:32 (director, session 3) - overrides the above where they differ
- Launch 23:33. Hard stop 00:45: commit, report, END. Commit the dev scene by 00:00 and the take notes as soon as the film exists.
- HEAD now 71c4e3914 (beats landed in `b8e1739eb`). A parallel builder `g07-kills` changes `ghost_deploy_strike.gd` so dump kills play the Tonnage crush (not the bullet fall). Order: (1) your scene + headless seed/window search on main and HEAD, (2) render the MAIN side (main never changes), (3) render the HEAD side with `--rev`-style snapshot of the newest commit at that time; if g07 has committed its kill change by then (git log: "kills" / ghost_deploy_strike), film that commit; do not wait past 00:10 for it.
- Lane Godot lock `build/n31/godot.lock`: hold it per Godot run, release between runs. g07 runs short tests; let it in between your renders.
- Use the film kit where it fits: `tools/film/film.mjs` / `compare.mjs` (`tools/README.md` 32-60, 261-300) give same-tick before/after with throwaway checkouts (`--a=ba8e470b0 --b=<sha>`); if they cannot run a custom dev scene, do the temp worktree route above. Check that the movie is 1920x1080 with ffprobe.
- Stay out of `project/features/**` entirely.
- Required outputs, in priority order: (a) main | HEAD side-by-side gauntlet take 15-40 s at 32 px/m with 2-3 Tonnage deploys + `evidence/n31/ghost/take-drop.md`; (b) 64 px/m still pair at a dump tick; (c) the half-speed 64 px/m clip of one whole HEAD deploy. Stop after (a) if time is short.
