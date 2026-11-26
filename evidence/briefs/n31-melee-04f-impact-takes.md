# Builder n31-melee-04f (opus, 45 min): item 4's play takes, the audit sheet before|after, two small fixes

Read `evidence/briefs/n31-common.md` (binding), `evidence/n31-melee/04-impacts/audit.md`, and what 04b-04e
committed (`git log --oneline --grep="melee 04"`). Tag `04f`. Commit each part by 25 min into the call; report and
END 45 min after launch (times are in the launch prompt). `git commit -- <paths>`.

Part A (play takes, the owner judges these first). Item 4's changes are view only and have no flag, so the
"before" renders from a temp worktree at `0f1e1ce95` (the audit commit: play_take.mjs + the take scene exist, no
04b-04e marks) with `--game-flags=--melee-sweep=off`, and the "after" from HEAD with
`--game-flags=--melee-sweep=off,--kill-feed=off` (same rules both sides, only the impacts differ). Use
`tools/melee/fatal_takes.sh`'s composite (03p5: crop around Rivet, 1920x1080, labels "main" / "n31 impacts").
Weapons in the order a player meets them: katana, plasma_sword, chainsaw (seed 7, 2100 frames, 32 px/m, tilt 70).
-> `gtai-masters/n31/melee/beside_impacts_<w>.mp4`. LOOK at 3 stills per film where a blade lands; say at which
second the cut / sear / bite shows on the after half and what the main half shows there. frames.json entries
(read it first; after the fatality entries). A temp worktree needs the native DLLs: copy them from this worktree's
`project/` bin folder (see memory: do not copy old DLLs from elsewhere) and run one `--import` there; delete the
worktree (`git worktree remove`) when done.

Part B (audit sheet before|after): one PNG `evidence/n31-melee/04-impacts/sheet_before_after.png` (+ copy to
masters, frames.json entry): rows = claw, katana, plasma_sword, chainsaw, electro_baton, pistol, gatling; columns =
hit human / hit robot / hit shield, each cell a 64 px/m crop before | after from `marks_still` (before = the same
temp worktree; if marks_still does not exist there, copy only that dev scene into the temp tree), score 0-3 before
-> after printed in the cell corner (scores from audit.md; after = your look, say why). Python + PIL in
`tools/melee/impact_sheet.py`.

Part C (two fixes, only if A and B are committed): `marks_still` re-pins the victim after its sim step so the cop
stays under the hit (04d/04e stills lost him); `gun_fx.json` `body_hot_m` 0.06/0.09 -> 0.09/0.13 if the 32 px/m still
shows the hot point still lost against Rivet's claw (look first; one decisions line with before -> after).

Owned: `tools/melee/**`, `project/dev/melee_n31/**`, `project/features/combat/weapons/gun_fx.json`,
`evidence/n31-melee/04-impacts/**`, masters beside_impacts_* / sheet files + their frames.json entries, one
decisions line. Nothing else.
