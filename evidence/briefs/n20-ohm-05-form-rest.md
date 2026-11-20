# Brief n20-ohm-05: the rest of the form (transform, hit, HUD chip), then the look switch

Worktree `C:\Users\kazda\kiro\gtai-wt\n20-ohm`, branch `n20-ohm`. Read `git log --oneline -15` first: the spectral
body, the jar tell, the spectral bolt and the old-man drift are in. Plate:
`C:\Users\kazda\kiro\gtai-masters\n20\concepts\ohm_c.png`. VISUAL ONLY: no sim, replay, parity or digest moves; no
`powers.json`, speed, timing or footprint change. Everything applies only under `GhostLook.spectral(&"ohm")`; legacy
draws exactly as now.

Environment: in every shell `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/ohm` and
`GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; `--rendering-driver
d3d12` for anything that renders; `--position 0,1440` on every windowed run (never the main display); one Godot at a
time; free only your own PIDs, never kill by name.

## Files you may edit
`project/features/souls/ohm_*.gd` (+ new `ohm_*.gd`), the `ohm` row of `project/data/tables/ghost_hover.json` and of
`project/data/tables/ghost_forms.json` (ONLY that row, and only when Part D says so), `project/features/souls/art/ohm/**`,
Ohm files under `project/features/souls/art/view/`, new files named `ohm*` (e.g. a new
`project/features/hud/art/ghost_chips/ohm_spec.png`), `tools/art/ohm_*`, `project/dev/ghost-powers/ohm_beat.gd`,
`test_ohm_*` tests, one line appended to `docs/decisions.md`. NOT flight's `ghost_*.gd` / `soul_*.gd` / `power_*.gd`,
`ghost_chip_face.gd`, `ghost_review*`, and no combat/kill files. Size caps: never delete `##` doc comments or
constants to fit a cap; split into a new `ohm_*.gd` instead. Never hand-edit `tools/debt/baseline.json`. If a
non-Ohm file is what is wrong, write `NEED <lane>: <file> <why>` in your report and leave it.

## Part 0: the staff from above (small, first; one commit)
In the move and close films (`n20/ohm/ohm_move_32.mp4`, `ohm_close_64.mp4`, still `ohm_turn_64_t163.png`) the
top-view staff is a thin rod lying along his right flank and the copper fork is a 3-4 px speck at 32 px/m: the
stoop and the jars read, the fork does not. The plate's top view (right inset) holds the arm out to his right with
the fork clearly beyond the hand. In `ohm_spirit.gd` / the top staff parts only: hold the rest fork further out to
the side (try `REST_FORK_M` about (1.0, 0.70)), draw the shaft about 1.5x thicker and the two copper prongs about
1.5x larger with their ink edge, so at 32 px/m the fork is a clear copper U of 6+ px beyond the body silhouette.
Keep the lead/turn behaviour and the thrust from 080bfdd5e. Before/after top stills at 32 and 64 px/m, same tick:
`C:\Users\kazda\kiro\gtai-masters\n20\ohm\drift\staff_{before,after}_top_{32,64}.png`. Also name (file:line) the small RED dash that rides
between Ohm and the guards in `ohm_attack_32.mp4` (e.g. at 0.5 s and 1.5 s, both views; also in `ohm_tilt55_32.png`
on the bolt line). Red is blood only: if it is Ohm's (bolt/fork/jar), make it copper or teal; if it is not Ohm's,
just name it.

## Part A: transformation in and out (one commit if anything changes)
Shoot first, change second. Under `--ghost-look=spectral`, Rivet -> Ohm and Ohm -> Rivet at 32 px/m, tilt70 and top:
stills at the start, the midpoint (the one in-between pose of `enter_s` 0.5-0.9 s / `exit_s`) and the end, into
`C:\Users\kazda\kiro\gtai-masters\n20\ohm\form\{enter,exit}_{start,mid,end}_{tilt70,top}_32.png` (12 PNGs; a
`ghost_review` take or `ohm_beat.gd` that presses the form key; say which). Judge each against the plate:
- Does any frame show the legacy Ohm (legs, walk cell, old shell) or a foot contact? Then make the spectral path use
  the spectral body there (an in-between of Rivet's sprite and the hover cell is fine: e.g. the body rising out of
  the teal burst, jars lighting one after another as he forms, emptying on the exit). Only in Ohm's files.
- If the transform already reads as the spectral Ohm, change nothing and say so with the stills.

## Part B: hit reaction (one commit if anything changes)
Strike spectral Ohm with a guard/cop (the arena or `ohm_beat.gd`), 32 px/m tilt70 + top, stills at the hit tick and
+4/+8/+16: `...\n20\ohm\form\hit_{0,4,8,16}_{tilt70,top}_32.png`. Expected: the spectral hit cell (column 3 of
`ohm_spec_act.png`) or the hover cell leaning 12 deg (`GhostRecoil.LEAN_BY_FORM`), the jars and fork still on, no
legacy cell, no teal cancel colour (an interrupted delayed cast is amber; plain hits are not a cast). Fix only what
is wrong, in Ohm's files.

## Part C: HUD chip (new file only)
The HUD avatar is `project/features/hud/art/ghost_chips/ohm.png`, cut from the legacy p55 card by
`tools/art/ghost_chip_cut.py`. Cut a spectral one the same way (read the script; run it on frame 0 = toward
facing, idle column, of `art/view/p55/ohm_spec_hover.png` with the jar overlay composited if the chip needs the jars
to read) into a NEW file `ghost_chips/ohm_spec.png` (+ `.import` after `--import`), and a provenance line in
`steam/ai-provenance/2026-11.jsonl` if the tool convention needs one (it is derived from an already-logged sheet:
check how ohm.png is logged). Do not edit the script or `ghost_chip_face.gd`; write `NEED flight:
project/features/hud/ghost_chip_face.gd face(id) should load <id>_spec.png when GhostLook.spectral(id)` in your
report. Save a 4x preview of both chips side by side to `...\n20\ohm\form\chip_legacy_vs_spec.png`.

## Part D: the look switch (only if the director's line below says GO)
DIRECTOR: GO (04:05, after the drift films: body, drift and bolt read as the plate in tilt70, tilt55 and top).
Start Part D by 05:15 at the latest even if A-C are unfinished; commit it on its own.
If GO: set the `ohm` row's `"look": "spectral"` in `ghost_forms.json` (only that row; keep the sorted keys), append
`- [2026-11-20] DECISION souls/ohm: spectral Lightning Rod is Ohm's default look (body, drift, bolt, cast tell and
cancel filmed in tilt70, tilt55 and top, gate green); legacy stays reachable with --ghost-look=legacy.` to
`docs/decisions.md`, and run the full unit + scenario suite (a look golden that moves because of this flip is
re-blessed ONLY if it is an Ohm golden; name it; any non-Ohm golden that moves: stop and report).

## Acceptance (quote every result)
`node tools/godot/check.mjs` on each changed `.gd`; `node tools/lint/lint.mjs`; `node tools/tests/run_unit.mjs
--changed`; the scenario suite green; `node tools/gate/quick.mjs` before each commit; staged per path, one commit per
Part. After a code commit `node tools/mutate/mutate.mjs --file=<the main changed file> --max=12` and quote
killed/(killed+survived).

Hard stop 70 minutes. Parts in order 0, A, B, C, D (D started by 05:15 regardless); a Part not reached: say so. Last commit by 06:00.

## Report
Commit shas, every still path, test/lint/scenario/mutate numbers, NEED lines, and what still does not look like the
plate.
