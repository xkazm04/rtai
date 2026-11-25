# Brief n30-combat-28: a 32 px/m BEFORE film of the rocket and nuke chapters (film only, no product change)

Clock: launched ~17:55. The film must be rendered by **18:15**; md committed by **18:20**; report and END by **18:24**. If the
render is not done by 18:15, kill only the Godot you started (by PID), write what happened and commit the md.

## Goal
The owner has `gtai-masters/n30/combat/films/blast_floor_after_32.mp4` (rocket and nuke chapters of the arena reel at
32 px/m, 1920x1080 60 fps 25 s, made on our HEAD by
`CHAPTERS=rocket_launcher,mini_nuke QUIT=1500 node evidence/n29/red/film.mjs <out.mp4>`). He needs the same take with the
round and blast art as it was on `main` `5114a4441` (vermilion nose bands, vermilion blast fringe), for a side-by-side.

## Steps
1. `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat`,
   `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
2. Temp worktree at our HEAD, outside the repo: `git worktree add --detach "$LOCALAPPDATA/Temp/gtai-c28-before" HEAD`.
   In it, take ONLY these four PNGs from main: `git checkout 5114a4441 -- project/features/combat/weapons/art/fx/{rocket,nuke_shell,blast_0,blast_1}.png`.
   Copy from OUR worktree into it what a fresh worktree lacks for Godot: `project/native/bin/` (the CitySim DLLs; nobody
   rebuilt native), `project/data/generated/city/` (bake, git-ignored), and `project/.godot/` (import cache) - the gate does
   the same three. Then run one `--import` through runGodot, e.g. `node tools/godot/check.mjs res://features/combat/weapons/art/fx/rocket.png`
   after `"$GODOT_BIN" ...` is NOT allowed directly: use `node -e` with `tools/lib/godot.mjs` `runGodot(['--headless','--import'], {cwd: 'project'})`
   or any tool that does (the class cache check in runGodot imports when stale). Check with a quick md5 that the
   imported `.godot/imported/rocket.png-*.ctex` changed after the import (the PNGs must be the old art on screen).
3. In the temp worktree root: `CHAPTERS=rocket_launcher,mini_nuke QUIT=1500 node evidence/n29/red/film.mjs build/before.mp4`.
4. ffprobe it (bar: 1920x1080, 60/1, 25.0 s). Copy to `C:/Users/kazda/kiro/gtai-masters/n30/combat/films/rounds_before_32.mp4`.
5. Same-tick check against the after film: extract the frame at 7.6 s (nuke in flight) and 8.3 s (nuke floor) and 1.3 s
   (rocket) from both; count px differing > 24 in any channel and their bbox; in the before frame count vermilion
   (r - max(g,b) >= 79) inside the round/blast box. Expect: differences only around the round and the blast.
   Save the 8.3 s crop pair (before | after, labelled) as `gtai-masters/n30/combat/stills/rounds_before_after_32.png`.
6. Write `evidence/n30/rounds/before_film.md` (command, ffprobe line, the counts per second) and commit in OUR worktree:
   `git add evidence/n30/rounds/before_film.md` then `git commit -m "evidence: n30 combat c28 rounds before film" -- evidence/n30/rounds/before_film.md`.
7. `git worktree remove --force "$LOCALAPPDATA/Temp/gtai-c28-before"`, `git worktree prune`.

## Law
- Allowlist in our worktree: `evidence/n30/rounds/before_film.md` only (plus files under gtai-masters/n30/combat/films and
  stills named above; do NOT edit frames.json: the director does). Never edit `project/` in OUR worktree. Never touch other
  lanes' worktrees, `main`, or Temp entries you did not create.
- One Godot at a time; the lane's Godot is free now. Windowed runs at `--position 0,1440` (the script does).
- No `git stash`, amend, rebase, `add -A/./-u`, `reset --hard`.
- Report: files, commit, ffprobe line, counts, what you could not do. Then END.
