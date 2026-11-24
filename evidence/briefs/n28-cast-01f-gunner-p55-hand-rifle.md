# Brief n28-cast-01f: robot gunner A, p55 fall: take the rifle out of his hand (image edit)

Lane `cast`, branch `n28-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd). Do NOT switch branches.
Owned/forbidden files and repo law as in `evidence/briefs/n28-cast-01-gunner-on.md`; this call MAY generate images, **at most 3**.
**Hard stop 19:15 local** (check `date` often). Start your commit by 19:00 at the latest (hook up to 12 min). Never amend/rebase.
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/cast` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Godot only through
`tools/lib/godot.mjs` users; one at a time. Fix lint/format findings in your own edit and go on.

## State
`4960c33d6`: fall cells draw the body only (the dropped rifle island is cut; the game's `GroundRifle` pickup is the one rifle).
p70 is clean. **p55 is not:** in `project/features/characters/art/view/p55/robot_gunner_fall.png` (shipped layout: rows =
the three fall drawings, columns = five facings) the lying drawings still hold a rifle in the hand: row 1 all five columns,
row 2 columns 2, 3, 4. With the pickup beside him that is two rifles again. Row 0 (the upright first drawing) keeps its rifle.
Source: `C:\Users\kazda\kiro\gtai-art\foes-n27\gunnerA\out\gunnerA_fall_55.png` (green key; source layout rows = facings,
columns = drawings: read `tools/art/cast_gunner_pack.py` `source()` to map cells).

## Do (follow the p70 fix of `cacff1b4b`: same round-dir layout, same composite method)
1. Round dir `C:\Users\kazda\kiro\gtai-art\foes-n28\gunner-fall55\`, `jobs.json` for `node C:\Users\kazda\kiro\gtai-art\gen.mjs <dir>`
   (known fault: copy from `~/.codex/generated_images/` by hand if a job stalls after the image exists). Refs: the full
   `gunnerA_fall_55.png` (to edit) and the edited p70 sheet (`gunnerA_fall_70.png`, now empty-handed) as the look reference.
   Prompt in substance: "Edit the first image. In every drawing where the robot lies on the ground (the middle and right
   columns), remove the rifle from his hand and from beside him: the hose arm ends in an open empty hand resting on the
   ground. Keep the upright left-column drawings exactly as they are, rifle included. Keep every other pixel, pose, colour,
   outline, position and the flat green background exactly as they are. Same canvas size."
2. Composite ONLY the lying cells that held a rifle into a copy of the original (others byte-identical); keep the original as
   `gunnerA_fall_55_v1_hand_rifle.png` beside it. Align by body mask if the edit drifted; reroll if the body changed.
3. Re-cut (`cast_gunner_pack.py`), confirm only `p55/robot_gunner_fall.png` changed. Look at the new sheet on grey: empty
   hands, body whole. Godot `--import` through runGodot (not `tools/godot/check.mjs`). Rerun
   `node tools/art/cast_gunner_poses.mjs` once and look at `poses55_64/fall_1.png`, `fall_2.png`.
4. Copy the 55 rest frame to `C:\Users\kazda\kiro\gtai-masters\n28\cast\gunner_fall55_64.png` and add a `frames.json` entry.
   Provenance line (`steam/ai-provenance/2026-11.jsonl`, shape of the p70 line), audit line in the gunner fall row.
   `node tools/tests/run_unit.mjs --select=test_cast_gunner`, `node tools/gate/quick.mjs`, commit.
If it cannot be committed by 19:00: say so; do not commit a half sheet.

## Report
Commit sha; IMAGES n/3; cells changed; what the new sheet and fall_1/2 at 55/64 show; quick gate line.
