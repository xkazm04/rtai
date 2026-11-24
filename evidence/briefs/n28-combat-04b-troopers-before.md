# Brief n28-combat-04b: the two-trooper "before" runs at main d0ab9d03a (temp worktree, no code)

Lane `combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd), branch `n28-combat`.
**HARD STOP 19:26 (wall clock): report and END. Whatever happens, by 19:24 remove the temp worktree
(`git worktree remove --force <dir>` from this cwd) and say so.** Part A of `evidence/briefs/n28-combat-04-troopers.md`
(read its Why, A and Repo law):
1. `git worktree add "$LOCALAPPDATA/Temp/gtai-combat-before" d0ab9d03a` (detached). Copy the native DLLs it needs from
   this worktree (`project/bin/` and whatever `.gdextension` names; see the memory note: never old DLLs from elsewhere).
   The bake chunks are git-ignored: check whether the pressure takes need them (`pressure_seeds` is an arena scene; if it
   fails for missing chunks, copy this worktree's baked chunk folder). Run ONE headless `--import` there through
   `node tools/godot/check.mjs`-style runGodot or `"$GODOT_BIN" --headless --path project --import` launched via the
   repo's runner (from the temp worktree's own `tools/`).
2. In the temp worktree: `node tools/dev/run.mjs pressure_seeds -- --out=<abs: this worktree's evidence/n28/troopers/before/seeds>`
   and `node tools/dev/run.mjs pressure_dash_trace -- --out=<abs: .../before/dash_trace.json> --seeds=1,2,3,4,5,6,7,8,9,10`
   (same flags as the after runs: see `evidence/briefs/n28-combat-04a-troopers-after.md`).
3. Remove the temp worktree. No product edits, no commits.
Env for every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe GTAI_GODOT_EST_MB=600`. One Godot at a time.
Report: dev_verdict lines, paths, per seed 1..10 pair_dash: HP lost whole run AND after 10 s, dashes pressed, refused,
down; seeds 3 and 5 first; and the same two numbers for the after runs from `evidence/n28/troopers/after/` (same window).
