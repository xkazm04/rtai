# Brief 08 `films`: the three skill levels on the merged game, and the before/after page (lane loop, n23)

Hard stop: 09:25 wall clock. Commit deadline: 09:20. Commit each film's evidence as it lands.
Fix lint and format findings in your own edit and go on. No code change is expected; if one is needed (a film scene flag), stop and report it.

## Why

The owner judges the loop lane by films: "the three skill levels playing the combined game, plus the before and after report as a readable page".
The film scenes and capture recipe exist from night n22: `docs/gauntlet-loop.md` "Replay and film a run from its seed" and `evidence/loop/film.json`
(`res://dev/test_player/gauntlet_bot_film.tscn` at 32 px/m, `gauntlet_bot_film_closeup.tscn` at 64 px/m, captions read state after the tick).

## Work, in order

1. **Three clips, one per profile, same seed, merged game (this worktree's HEAD)**, 32 px/m, tilt as the film scene sets it, 1920x1080, `--fixed-fps 60`, 20-40 s each after the cut:
   novice, average, expert with `--pick=greedy --controls=wheel --seed=<S>`. Choose S from `evidence/n23-loop/moves/on/runs/` so that the novice run DIES inside the clip window
   (novice death waves there: 9-29; pick a seed whose novice death wave is <= 10, e.g. look at `death.wave` in `novice-<S>.json`) and cut each clip to the same span of waves
   (the novice's last 20-40 s before death; the same waves for average and expert show them surviving it). Each clip's caption/name says profile, seed, waves.
   Before filming, check determinism: the headless result of the filmed settings equals the batch's result file for that profile and seed (`cmp`), or say why not.
   Also one 64 px/m close-up (10-20 s) of the novice's death.
2. **A side-by-side**: the three 32 px/m clips stacked or tiled at the same wave/tick (FFmpeg `hstack`/`vstack` or `tools/film/compare.mjs` if it fits; read its usage first), 1080p, 20-40 s.
3. **The before/after page as a film**: open `C:/Users/kazda/kiro/gtai-wt/n23-loop/evidence/n23-loop/compare.html` in headless Chrome (`"C:/Program Files/Google/Chrome/Application/chrome.exe" --headless --screenshot=<png> --window-size=1920,<height>`; there is no Edge on this machine; a reference still is `build/n23/films/compare-1.png`) and render it as 1920x1080 stills (scroll in page-height steps); then a 15-30 s slow scroll film from the stills (FFmpeg). No browser window on the main display: headless only.
4. Encode: libx264, preset fast, CRF 18, yuv420p. Outputs to `C:/Users/kazda/kiro/gtai-masters/n23/loop/` with a `frames.json` of 8 to 15 entries, best first: `[{ "file", "title", "ppm", "before", "note" }]` (stills: a frame from each clip at the same wave, the novice death, the page stills). Delete scratch renders frames.json does not reference.
5. Look at every frame you list (read the PNG): say in one line each what it shows. A frame that shows nothing readable is not listed.
6. Write `evidence/n23-loop/films.json` in the lane (seed, profile, waves, ticks, command, result cmp verdict, output paths) and commit it.

## Machine rules

`export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/loop`, `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`, `--rendering-driver d3d12` for anything that renders,
every windowed run `--position 0,1440` (secondary monitor), never on the main display. **One Godot process at a time** (yours), and none while the director's gate runs: check
`build/n23/gate.out` for `gate done` before the first Godot start (wait for it, polling every 60 s). Never kill a process you did not start. Never touch another lane's worktree or another lane's folder in gtai-masters.

## Files

Allowlist: `evidence/n23-loop/films.json`, scratch under `build/n23/films/`, outputs under `C:/Users/kazda/kiro/gtai-masters/n23/loop/`. Any other path: stop and report a NEED.
Forbidden: `project/**`, `tools/**`, `docs/**`, every table, `JOURNAL.md`, `REPORT.md`, other worktrees.

## Repo law

Staged per path (`git commit -- <paths>`); no stash / `add -A` / `commit -a` / `reset --hard` / amend / rebase / push / `--no-verify`.

End with: files written, the frames.json list with your one-line look at each, commands, anything not done and why.
