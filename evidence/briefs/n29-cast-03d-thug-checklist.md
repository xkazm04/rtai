# Brief n29-cast-03d: robot thug A, the remaining checklist points, then the switch

Lane `cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd), branch `n29-cast`. You are a builder sub-agent.
**Hard stop HARDSTOP local** (check `date +%H:%M` often). **Commit 1 by COMMIT1, your last commit by LASTCOMMIT** (hook ~12 min).
Never end with finished work uncommitted. Then report and END.
**Your PART is named in the launch line (A or B). Do only that part.**

## Read first
`evidence/briefs/n28-cast-04-thug.md` section "The checklist's exact bars" (these bars and nothing else; read n29 for n28:
APPDATA `C:/Users/kazda/kiro/gtai-n29/appdata/cast`, outputs to `C:\Users\kazda\kiro\gtai-masters\n29\cast\`),
`evidence/n29/thug/feet_size.md` (feet, body jump, drawings/s, 70 size: all PASS), `evidence/n29/thug/footline.md` (the
cutter fix `588c7b706`), the 03c commits after it (`git log --oneline -8 -- project/dev/cast tools/art/cast_thug_*`), and
the dev scenes `project/dev/cast/cast_thug_*` (the row is forced on only there: `GTAI_CAST_PREVIEW=robot_thug` /
`CastMulroneyPreview.enable`). Models for each measurement: the gunner's and the lancer's audit rows in
`docs/art/cast-audit.md` (search "gunner", "lancer") and the tools they name.

## PART A: ink + live 64 px/m rim (both can fail: measure, report, fix only the cut if a fix is a cut matter)
- Ink: front passing pose, left contour, runs at y = 70, 75, 80 of the 192 px cell (scale his 256 cell: say how), 70 and 55,
  against the patrol's 3,3,4 / 3,3,3; outline closes at native 32 and 64 px/m; no lost hands, no duplicate hatching. Crops
  at 4x on grey to `build/look/n29-thug/ink/`, look at them.
- Rim: `tools/art/cast_mulroney_edge.py` (frozen exposure) on EVERY state's sheet (walk planted8, attack, hit, fall; 70 and 55),
  live at 64 px/m: dark exterior rim px, beside the patrol / warden reference (0 on ten sheets) in the same exposure.
- A failing point: one cut fix if it is a cut matter (matte, edge erosion), re-measured; else report FAIL with the crop.

## PART B: shadow + palette + 55 size + the fall's up facing
- Shadow: same-pose toggle at 32 px/m, 70 deg, front three-quarter, px darkened >= 12/255, against the patrol's 236.
- Palette: hue counts on every shipped thug sheet: strict red (outside the lens), teal (hue 160-200, S >= 0.35, V >= 0.35),
  vermilion, navy (cops alone wear navy), amber only on stripes / lens / heat. Quote counts; look at any non-zero cluster.
- Size at 55: the thug, the spawned rig patrol cop and Rivet at 32 and 64 px/m, 55 deg, in one delivered frame
  (`cast_thug_beside` with the pitch flag); bar 0.90-1.00 of Rivet, never taller.
- The fall's UP facing (5th column of `robot_thug_fall.png`, both pitches) never falls: all three drawings stand
  (director looked at `build/look/n29-thug/foot/fall70_after.png`). Check how the card view picks the fall facing: if an
  up-facing death can happen in a fight, report it as a FAIL with the still and say which source row would need a redraw;
  do not redraw (no image generation).

## Both parts
Append your rows to `evidence/n29/thug/checklist.md` (create it; one table: point, number, bar, verdict, evidence path).
`node tools/tests/run_unit.mjs --changed` (quote), commit. Do NOT switch the row on: the director decides from the table.

## Repo law (binding)
- Godot only through runGodot (`tools/dev/run.mjs`, film tools, gate, mutate); before it
  `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/cast` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; rendering gets
  `--rendering-driver d3d12`, windowed runs `--position 0,1440`.
- **Lane Godot lock** (shared with another builder): `until mkdir build/lane-godot.lock 2>/dev/null; do sleep 15; done` before
  any Godot launch, `rmdir build/lane-godot.lock` right after (also on failure); older than 25 min = stale, remove it.
- `mem-budget: waiting` = machine full: wait, do not kill. Kill only your own PIDs. Never delete anything you did not create.
- Typed GDScript, ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`.
- Stage per path, `git commit -- <your paths>`. Banned: `git add -A/./-u`, `commit -a`, `stash`, `reset --hard`, amend,
  rebase, branch switches, push. Never skip the hook (`kill_reel_*.break.test.mjs` red: import, commit again; only
  `step_guard.break.test.mjs` red: run it alone, if it passes commit again). The quick gate's Godot parse step failed on
  untouched files: `node tools/gate/quick.mjs --no-godot` + GUT is accepted, say so. Debt red: `node tools/debt/debt.mjs
  --update` (`--accept-regression="robot_thug for n29 cast"` if it rises), include the baseline.
- Fix lint and format findings in your own edit and go on. No image generation. Never fake a frame or a number.
- Commit messages end with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Allowlist (any other path: stop and report a NEED)
PART A: `tools/art/cast_thug_*.py`, `project/features/characters/art/view/{p70,p55}/robot_thug_*` (+ `.import`, only for a cut
fix), `steam/ai-provenance/2026-11.jsonl` (append, only for a re-cut PNG), `evidence/n29/thug/**`, scratch
`build/look/n29-thug/ink/`, `build/look/n29-thug/rim/`.
PART B: new or existing `project/dev/cast/cast_thug_*` (+ `.uid`, `.tscn`), new `tools/art/cast_thug_palette.py` /
`cast_thug_shadow.py`, `evidence/n29/thug/**`, scratch `build/look/n29-thug/partb/`, outputs in
`C:\Users\kazda\kiro\gtai-masters\n29\cast\` (append to `frames.json`).
Both: `tools/debt/baseline.json` (debt tool only). If both parts run at once, `evidence/n29/thug/checklist.md` is PART A's;
PART B writes `evidence/n29/thug/checklist_b.md`.
Forbidden: `cast_cards.json`, `cast_card_kinds.gd`, `foe_thug_card_view.gd` (NEED), every `shield_robot_*` / `war_machine_*`
file, `cast_door_*`, `cast_war_*`, `docs/**`, root `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`, other lanes' files.

## Report (then END)
Commits, the rows of your table (point, number, bar, verdict), crops/stills you looked at and what you saw, the
`run_unit --changed` line, NEEDs, what you could not do.
