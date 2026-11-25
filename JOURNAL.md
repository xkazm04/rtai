# JOURNAL lane keys, run n29 (2026-11-25 01:15 to 09:15)

Branch `n29-keys` from `main` `c649a15d6`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls`. Builders: Claude sub-agents (Agent tool).
IMAGES 0/60.

## Session 1 (01:04 to 02:34)
- 01:05 READ n28-keys REPORT (Next steps), owner verdict line, decisions tail. No `NEED keys` in combat/cast/yard journals.
- 01:06 FINDING the "ATTACK CLAW" box is the bot film's caption (`project/dev/test_player/gauntlet_bot_film.tscn` Caption/Act, bottom-left at offset 18,-66): it sits over the ghost chip strip (`GhostFormLayout` margin 18, bottom-left). The owner judges by these films, so the caption moves; the strip's chip-1 plate also overhangs the left edge.
- 01:07 BUILDER n29-01-hud launched (sonnet, background): caption off the strip, chip plates inside, stills + test.
- 01:07 BUILDER n29-02a-sword-row1 launched (opus, background): katana-donor row 1 walk+run, judge crops, no Godot, no commit. DECISION: the sword's first row is judged on sheet crops scaled to 64 px/m because the HUD builder holds the lane's one Godot; in-game grids come with the rows 2-8 call.
- 01:09 BRIEFS written for the next session: n29-03-gloria-walk.md, n29-04-collar-rows.md (placeholders {START}/{COMMIT}/{END}/{IMAGES}/{GODOT_RULE} filled at launch).
- 01:09 IMAGES 2/60 (sword walk row 1 + run row 1, in flight).
- 01:13 MILESTONE hud-code `24fc9c4c3`: bot film caption to bottom centre; chip number plates clamped inside the strip (>= 8 px off the edge), test pins both layouts. Evidence `26d320430` (`evidence/n29-keys/hud.md`): chip 1 plate left edge 7 -> 15 px, caption/strip overlap 0. I looked at `gtai-masters/n29/keys/hud/hud_pair_crop_3x.png`: numbers 1-4 whole and clear. Weak: the "before" is n28's frame (other tick); owed: a same-tick pair.
- 01:25 BUILDER n29-02a-sword-row1 18 accepted: walk row 1 PASS first try (leg IoU 0.959), run row 1 PASS on its retry (sole y 2 px at the bar). IMAGES 3 -> lane 3/60.
- 01:27 REVIEW sword row 1 crops (`gtai-masters/n29/keys/sword/row1_judge_64.png`): walk row 1 accepted (one claw, straight amber blade hue 40 deg = the strip's, rigid flat collar). Run row 1 soft (laid out at 0.64, rivets lost, no crossguard, slight stripe twist): redo every run row at >= 0.90.
- DECISION keys sword blade: amber as the shipped plasma sword strip (hue 43 deg; amber = heat under the colour law); the hilt rings are combat's.
- 01:26 BUILDER n29-02b-sword-rows launched (opus): rows walk 2-8, run 1-8 at >= 0.90, wire, commit by 02:12, END 02:28; Godot gated on `build/n29-hud.done`.
- 01:36 BUILDER n29-01-hud 28 accepted (2 commits, 198 unit passed, lint 19/19). Not done: mutate (the temp-worktree baseline `--import` timed out after 647 s under load), a same-tick before (temp worktree has no import cache), the handheld still (capture writes 1080p only). Owed next session: `tools/film/compare.mjs` same-tick pair + mutate with a test subset. Caption text sits left in its centred 160 px box (cosmetic).
- 01:36 FRICTION mutate baseline import 11 min timeout on the loaded machine (other lanes' Godots: cast `--import` + combat reel running).
- 01:36 Godot gate opened for n29-02b (`build/n29-hud.done`).
- 01:37 BUILDER n29-03a-gloria-rows-prep launching (opus): Gloria p70 rows by image edit, prep only, one job at a time, cap 12, END 02:26.
- 01:43 DECISION sword order: commit the walk sheet alone as soon as walk row 8 passes (sprint falls back to the bare run, as the molotov's in n28), run rows keep generating; the run sheet is wired by the next call. Sword walk rows 1-5 PASS (IoU 0.94-0.96). IMAGES: sword 3+6, gloria 1 -> lane 10/60.
- 02:08 MILESTONE sword-walk `3dbef1803`: plasma sword walks on its own p70 grid (katana donor, 8/8 walk rows pass; row 6 on its retry, row 8 with a per-column height fit); sprint on the fallback until the run sheet lands. FRICTION images: Gloria walk row 3 timed out at 900 s with no png (three jobs in flight across this lane).
- 02:14 MILESTONE sword-walk evidence `2bd8769a5` (`evidence/n29-keys/grid_plasma_sword.md`): walk foot_slide turn_090 row 0 at 32 px/m hold 1.00/1.56 cm (bar 2) PASS. I looked at the 32 px/m rows (`gtai-masters/n29/keys/sword/grid_plasma_sword_arena/rows/turn_*`): walk = amber blade in one claw, rigid collar; the SPRINT lanes still draw the stop-gap's thin grey held blade, so the blade's look changes walk -> sprint until the run sheet is wired: first job next session.
- 02:23 BUILDER n29-02b-sword-rows 57 accepted (walk sheet `3dbef1803` + evidence `2bd8769a5`; run rows 1-3 pass at s0.95 (crisp, crossguard, flat collar), run 4 failed try 1 (wrong facing), run 5 never returned, 6-8 not started). by_weapon.plasma_sword left unset on purpose (set it only with the run sheet). IMAGES 13 this call.
- 02:23 FRICTION `tools/gate/quick.mjs` Godot parse check fails on committed files nobody touched (`cut_rig.gd`, `test_rivet_windup.gd`), `--no-godot` ok: check on the next import before the gate.
- 02:24 IMAGES lane: sword 3 + 13 = 16, gloria ~5 -> about 21/60.
- 02:23 BUILDER n29-03a-gloria-rows-prep 44 accepted (prep): walk rows 1-3 PASS (IoU 0.87-0.93), walk 4 stalled > 11 min and was stopped, IMAGES 5 launched / 3 received. I looked at `gtai-masters/n29/keys/gloria/walk_rows_judge_64.png`: brass nail gun in one claw, other claw free, flat collar; row 1 muzzle tip cut 1-4 px at the cell edge (check in game). No builder running at session end.

NEXT (session 2, in this order; at most two builders, never two on one Godot):
1. Sword run sheet (fresh opus, ~45 min): resume `gtai-art/rivet-n29/plasma_sword/STATE.md` Next 1-6 (check for a late run 5 png; run 4 retry with an explicit facing line; run 6-8 two at a time; assemble; wire; by_weapon.plasma_sword -> plasma_sword; pins at 200 lines; commit with a 15 min hook budget; capture + foot_slide vs katana + grid_plasma_sword_64/_32 composites + a 32 px/m clip walk->sprint). Also a decisions.md line for the sword grids.
2. Gloria walk rows (fresh opus, image-only until the sword's Godot is free): resume `gtai-art/rivet-n29/gloria_walk/STATE.md` (walk 4-8, then run 1-8; one job at a time while the sword job runs two); then brief `n29-03-gloria-walk.md` wiring. Note row 1's muzzle overhangs the cell by 1-4 px: check it in game.
3. HUD evidence `evidence/briefs/n29-01b-hud-evidence.md` (same-tick pair via compare.mjs, handheld still, mutate, centred caption text, decision line) when a Godot slot is free (sonnet, 30 min).
4. Then `n29-03b-gloria-strips.md` (p55 brass strips + left p70 cells), `n29-04-collar-rows.md` (p55 collar, one row per job).
5. Fill the brief placeholders {START}/{COMMIT}/{END}/{IMAGES}/{GODOT_RULE} at launch. Commit the last new work by 07:15, final gate `node tools/gate/run.mjs --rev=HEAD` by 07:30; films to `gtai-masters/n29/keys/` + frames.json.
