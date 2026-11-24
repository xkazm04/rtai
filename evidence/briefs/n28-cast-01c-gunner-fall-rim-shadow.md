# Brief n28-cast-01c: robot gunner A, fix the double rifle in his p70 fall, then rim and shadow numbers

Lane `cast`, branch `n28-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd). Do NOT switch branches.
**Read `evidence/briefs/n28-cast-01-gunner-on.md` first: the four open points with their exact bars, owned and forbidden
files and repo law hold unchanged** (one exception below: this call MAY generate images, at most 4).

**Hard stop 19:15 local** (check `date` often): commit what is green, report and END. **Start commit 1 by 18:35.** Start your
last commit no later than 19:00 (the pre-commit hook takes up to 12 minutes). Never amend, never rebase.
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/cast` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
**Never run `Godot_*.exe` directly**: only through `tools/lib/godot.mjs` users (`tools/dev/run.mjs`, `tools/art/cast_gunner_poses.mjs`,
`tools/film/cast_gunner_films.mjs`, `tools/godot/check.mjs`, gate, mutate). One Godot at a time. Windowed runs `--position 0,1440`.
Fix lint and format findings in your own edit and go on.

## State you inherit (do not redo it)
- Commits on the branch: `c7910f4fd` (gunner poses/fight dev scenes, ink/review tools, `cast_gunner_poses.mjs`, `cast_gunner_films.mjs`),
  `4503cf13d` (audit Ink row from the sheets, PASS sheet side).
- **Uncommitted:** `tools/art/cast_gunner_poses.mjs` (+1 line: prints the last 40 log lines on failure). Commit it in commit 1.
- **The frozen pose launch FINISHED** at 17:45 (`build/cast/gunner/poses2.log`: "pose review complete true", exit 0, 50.7 s).
  Its frames are in `build/cast/gunner/poses/{poses70_32,poses70_64,poses55_64}/`: `stand/tell/fire/hit_*` each with a
  `*_no_shadow.png` twin, `walk_<facing>_<frame>.png`, `fall_0..2.png`, and at 64 px/m the rim exposures
  `edge_{planted8_armed_walk,attack,hit,fall}/{raw,live,ground}.png`. **Use these; do not relaunch the poses unless you
  change the art (you will, for the fall: see step 2).** The machine has room now (cap status ~3.4 GB of 8).
- The builder account (`builder.mjs`) is out until tomorrow; you are its stand-in. Same rules.

## The defect I found (director, looking at `poses70_64/fall_2.png` and the shipped sheet)
`project/features/characters/art/view/p70/robot_gunner_fall.png` draws **two rifles** in six cells: the dropped rifle on the
ground to his right (correct) AND a second rifle lying across his chest/hips (wrong). Source:
`C:\Users\kazda\kiro\gtai-art\foes-n27\gunnerA\out\gunnerA_fall_70.png` (1536x1024, green key, 5 rows = facings x 3 columns
= frames). The bad cells are **rows 1, 2, 3 (0-based; front-right three-quarter, side, back three-quarter), columns 1 and 2**.
Rows 0 and 4 and column 0 are correct. The p55 fall sheet (`gunnerA_fall_55.png`) is correct everywhere (one rifle) and is
the reference for how the chest should look empty. This fails "fall: rest on his back, rifle beside him".

## Order
1. **Commit 1 (by 18:35):** the poses.mjs line + audit rows for the two points you can measure from the existing frames:
   - **Rim (point 1):** run `tools/art/cast_mulroney_edge.py` (read its usage; the warden/Mulroney rows in
     `docs/art/cast-audit.md` show how it was quoted) on the four `edge_*` dirs at `poses70_64` and `poses55_64`. Bar: no dark
     exterior rim, comparable to the patrol cop's / the warden's live count in the same exposure (warden: 0 on ten sheets).
     Quote dark-exterior px per exposure. Look at `live.png` of each yourself.
   - **Shadow (point 3):** count px darkened by >= 12/255 between `stand.png` and `stand_no_shadow.png` at `poses70_32`
     (front three-quarter, 32 px/m, 70 deg); also `hit_*`/`fire` pairs for "feet still on it after the shot and during a
     wound". Bar: a separate ground contact of roughly 150-350 px (patrol 236, cop8 248/221), no baked key shadow. If the
     `_no_shadow` twins show the toggle did not reach his rings (diff ~0), say so: that is a tool fault to fix, not a pass.
   - **Ink, live look:** look at the walk frames at `poses70_32` and `poses70_64`; one line in the Ink row that the live
     frames were looked at (contours closed, hands and rifle whole) or what is wrong.
   Write the numbers into the gunner section of `docs/art/cast-audit.md` (~line 327-350), one row each. `node tools/gate/quick.mjs`, commit.
2. **Fall fix (drawing only), by image edit, at most 4 generated images total:**
   - New round dir `C:\Users\kazda\kiro\gtai-art\foes-n28\gunner-fall\` with `refs/` and a `jobs.json` for
     `node C:\Users\kazda\kiro\gtai-art\gen.mjs <roundDir>` (read gen.mjs's header: `{style, jobs:[{name, track, refs, prompt}]}`;
     known fault: a job can stall copying to `./out` after the image exists under `~/.codex/generated_images/`: copy it by hand).
     Refs: the full `gunnerA_fall_70.png` (to edit) and `gunnerA_fall_55.png` (the empty-chest reference).
     Prompt, in substance: "Edit the first image. In rows 2, 3 and 4 (counting from the top), in the middle and right
     columns only, remove the second rifle lying across the robot's chest and hips; the hose arms rest empty, as in the
     second reference image. Keep the dropped rifle on the ground to the right of each robot. Keep every other drawing,
     pose, colour, outline, position and the flat green background exactly as they are. Same canvas 1536x1024."
   - Then **composite**: copy ONLY the six bad cells' regions from the edited image into a copy of the original sheet
     (every other cell byte-identical to the original), save it as `gunnerA_fall_70.png` in the n27 `out/` with the original
     kept as `gunnerA_fall_70_v1_double_rifle.png` beside it (accepted sources stay where the cutter reads them). If the
     edited cells drift in position or scale, align each by its body mask before pasting; if the edit changed the body or
     the dropped rifle, reroll (that is what the remaining images are for).
   - Re-cut with `tools/art/cast_gunner_pack.py` (fall only if it allows; otherwise all and confirm the other shipped PNGs
     are byte-identical with `git diff --stat`). Check: zero strongly green-leading px (its `check_cells`), one rifle per cell.
     Look at the new sheet yourself at full size. Godot `--import` through runGodot (e.g. `node tools/godot/check.mjs` on the
     sheet or a `tools/dev/run.mjs` import), then rerun `node tools/art/cast_gunner_poses.mjs` once and look at `fall_0..2`
     and `edge_fall` at 70/64.
   - Append one line per generated image to `steam/ai-provenance/2026-11.jsonl` (copy the shape of the existing gunner lines).
   - Audit: a line in the gunner section: "p70 fall: double rifle in rows 1-3 cols 1-2 removed by image edit (n28), before/after
     `build/cast/gunner/...`". `node tools/gate/quick.mjs`, commit (art + .import + provenance + audit + any tool change).
   - In your report: IMAGES used n/4.
3. Only if both commits are in by 18:55: start nothing new. Report. (Films and `enabled: true` are the next call.)

## Owned files for this call
As brief 01's allowlist, plus `C:\Users\kazda\kiro\gtai-art\foes-n28\gunner-fall\**` and the two files named above in
`C:\Users\kazda\kiro\gtai-art\foes-n27\gunnerA\out\`. Any other path: stop and report a NEED. Do NOT set `enabled: true` in this call.

## Report at the end
Commits (sha + subject); rim px per exposure beside the bar; shadow px per pose beside the bar; live ink look; fall fix
before/after paths and what you looked at; IMAGES n/4; quick gate line; minutes spent waiting on mem-budget; what you could not do.
