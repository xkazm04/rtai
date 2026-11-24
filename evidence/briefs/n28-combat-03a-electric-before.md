# Brief n28-combat-03a: the electric "before" stills only (no code change)

Lane `combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd), branch `n28-combat`.
**HARD STOP 19:20 (wall clock): report and END, even mid-task.** This call does ONLY part A of
`evidence/briefs/n28-combat-03-electric.md` (read its Why and part A): the three 64 px/m "before" stills on the current
tree, `C:/Users/kazda/kiro/gtai-masters/n28/combat/stills/electro_{stun,chain,deflect}_before_64.png`. No product edit,
no commit of product files. If you write a small render helper, keep it under `build/n28electric/` (git-ignored) and give
its exact command lines in your report, so the next call renders the "after" at the same ticks.
Note: the deflect fix 7e95d96fb is already in (no red-cored muzzle flash on a turned round): the deflect "before" is the
spider spark as it stands now.
Every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe GTAI_GODOT_EST_MB=1000`;
renders through runGodot only (tools/dev/run.mjs, tools/film/*, tools/gauntlet/*); `--rendering-driver d3d12`; one Godot at a time.
Read each still yourself (the electro arc and the daze sparks must be in frame and readable). Report: the three paths, the
take/scene, seed, tick and command of each, and what each shows.
