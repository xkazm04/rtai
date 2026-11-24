# Brief n28-03-nuke-ray: mini-nuke and ray gun on their own p70 grids, by the homing shard's route

You are the builder (in-session subagent; builder.mjs is out of account). Worktree
`C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n28-keys`): **`cd` there in every shell command**. Repo law:
`AGENTS.md`, `STANDARDS.md`.

**HARD STOP: report and END by 19:14 whatever the state. Commit the mini-nuke by 18:55; the ray gun by 19:08 only if it
passes in time (otherwise leave its round resumable and uncommitted under project/, and say so).** Check `date` often.
Small commits, staged per path, `git commit -- <paths>`. No amend, rebase, stash, `add -A/./-u`, `commit -a`,
`reset --hard`, push. Fix lint and format findings in your own edit and go on. No subagents, no model CLI except the image
tool `C:/Users/kazda/kiro/gtai-art/gen.mjs`. Godot: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/keys`,
`GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`, `GTAI_GODOT_EST_MB=600`
(1000 for renders), `--rendering-driver d3d12`, windowed `--position 0,1440`, one Godot at a time, never raw, free your own
processes by PID only.

## Do exactly what you did for the homing shard (accepted by the director: 3ea5cf48c, 6d27d55a0)
Same route and scripts: copy `C:/Users/kazda/kiro/gtai-art/rivet-n28/homing_shard/` scripts into
`C:/Users/kazda/kiro/gtai-art/rivet-n28/mini_nuke/` and `.../ray_gun/`, each with its own `STATE.md` (resumable). Donor =
the plasma rifle's p70 walk and run sheets (the owner's words: "image edits of the plasma rifle's walk and run sheets").
One sheet-sized edit per sheet (2 images per weapon; at most 2 more per weapon for failing rows; cap 8 for this call).
Image 2 = the weapon's equipped strip `p70/rivet_eq_<weapon>.png` (+ `_left`/`_diag` as in your homing shard refs).
Add to the prompt your own two lessons: "legs, boots and soles pixel-identical to image 1" and "the held part stays inside
its cell". The collar a rigid orange-and-black hazard collar with straight stripes, never rope or cloth. Colour law on the
weapon: no red (red is blood only), no teal; the mini-nuke's warning paint stays the shipped strip's colours.
Cut raw, the same bars as the homing shard (dome within 3 %, sole y within 2 px, same leading boot, no extra limb, the
weapon as on its strip, no plasma-rifle remnant, tone within 2, foot_slide walk <= 2 cm / run <= 7 cm at 32 px/m, the
plasma rifle's beside), ship only if 16/16 rows pass, wired exactly as 3ea5cf48c (pngs + .import, `rivet_motion.json`
rows for that weapon, the `test_rivet_grid_stride.gd` pin, provenance lines), `run_unit.mjs --changed`,
`quick.mjs --no-godot` (the full quick fails on the known cut_rig.gd cyclic-load compile: say so), commit
"Mini-nuke walks and runs on its own p70 grids, edited from the plasma rifle's" (ray gun the same).

Two fixes from the director's look at your homing shard grid: the row labels of the grid still render garbled
(`ma#...`): print the facing names in plain ASCII (n, ne, e, ...) or the row index; and render the stop-gap from a temp
worktree at `6d27d55a0` with the weapon not yet own-gridded (`git worktree add build/wt-before-<w> 6d27d55a0`, `git worktree
remove` afterwards) instead of editing `rivet_motion.json` in place (no data edit to revert).

## Evidence per weapon (commit separately after its grids)
`C:/Users/kazda/kiro/gtai-masters/n28/keys/grid_<weapon>_64.png` and `_32.png` (stop-gap | new | plasma rifle, 8 facings,
walking 6.75 and sprinting 9.3 m/s, same tick), append entries to `frames.json` there (keep the existing ones),
`evidence/n28-keys/grid_<weapon>.md` (per-row table, foot_slide). No clip per weapon: the five-weapon 32 px/m clip comes
after the last one.

## Allowlist (anything else: stop and report a NEED line)
`project/features/characters/art/view/p70/rivet_walk_eq_{mini_nuke,ray_gun}*`, `rivet_run8_eq_{mini_nuke,ray_gun}*`,
`project/data/tables/rivet_motion.json` (rows of these two weapons only), `project/tests/unit/test_rivet_grid_stride.gd`
(their pins), `steam/ai-provenance/2026-11.jsonl` (append), `evidence/n28-keys/**`, `C:/Users/kazda/kiro/gtai-art/rivet-n28/**`,
`C:/Users/kazda/kiro/gtai-masters/n28/keys/**`, `build/**`.
Forbidden: every other weapon's art, the plasma rifle's art (read only), `weapons.json`, `weapon_art.json`,
`project/features/combat/**`, `project/dev/gauntlet/**`, `project/boot/prologue/**`, `ghost_*.json`, `combat.json`,
`enemies.json`, `native/`, other worktrees, `main`.

## Report and END (final message)
`IMAGES n` per weapon, rows passed, the table paths, foot_slide beside the plasma rifle's, commit shas, still paths,
STATE.md "next" per weapon, anything that would make molotov (one-hand bottle) and plasma sword fail on this route.
