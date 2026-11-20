# Brief a6b (resume of a6, lane dent, n20): chip still out of git, the 55-degree check, then the default

Same machine rules and repo law as a6 (APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/dent, d3d12,
`--position 0,1440` on windowed runs, one Godot at a time, PID kills only, stage per path, quick gate
before each commit, never push). **No commit after 05:55 local time** (check `date` before each).

## 1. The chip still is evidence, not product (2 min)
42dcad19f committed `scratch/a6/chip.png` at the repo root. Copy it to
`C:\Users\kazda\kiro\gtai-masters\n20\dent\scratch\a6\chip.png`, then `git rm scratch/a6/chip.png`
and commit ("Move Dent's chip still out of the tree"). Nothing else under `scratch/` in git.

## 2. Dent at the 55-degree tilt (the second play tilt; 10 min)
The films are tilt 70 + top only. The row may go spectral only if he is complete in BOTH tilts.
With `project/dev/ghost-powers/ghost_review.tscn`, `--ghost-look=spectral --view=tilt` (55 degrees,
see `project/features/souls/README.md` "Spectral look": `--shot-tick`, `--shot=<abs png>`), render at
64 px/m: move take tick 110 (dive) and tick 163 (turn swing); attack take tick 94 (jab), 160 (strap
taut), 234 (heat ring), 239 (blast). Save to `C:\Users\kazda\kiro\gtai-masters\n20\dent\scratch\a6\tilt55_<take>_t<tick>.png`
and one contact sheet `tilt55_sheet.jpg` (the six, labelled with tick). Look at each: legless, the
body uses the p55 sheets (not the p70 cells and not the legacy standing body), nothing cut off, the
strap leaves his hand and ends on the roof buckle, the ring sits on the road. Write one line per
still in the report.

## 3. Dent's row defaults to spectral (only if every 55 still passed)
In `project/data/tables/ghost_forms.json` set only Dent's row `"look": "spectral"` (one value; the
strap stays the default tether). Then run, with the default look (no `--ghost-look` flag):
`node tools/tests/run_unit.mjs --changed`, plus `--select=` every test that names `GhostLook`,
`ghost_forms`, `dent_` or a look golden that draws Dent (find them with
`node tools/tests/test_map.mjs project/data/tables/ghost_forms.json`). Scenarios
`quest1_dent`, `quest1_dent_lock`, `replay_60s` (sim digests must not move: quote the replay hash,
it was `cbeb734ff9b97c41`). If a look golden that draws Dent moved ONLY because Dent's look changed,
re-bless just that golden and name it in the commit body; if anything else goes red, do NOT commit the
flip: restore the value and report what failed. One commit, message "Make the spectral Ejected look
Dent's default", with a `docs/decisions.md` line appended (one line:
`- [2026-11-20] DECISION dent look: Dent's ghost_forms row defaults to spectral (body, flight, jab, strap, overload filmed in tilt 70, 55 and top); legacy stays reachable with --ghost-look=legacy; rejected: leaving the plate behind a flag.`).

## 4. Overload tests
If your item 4 (overload tests, mutate >= 10/20) is still uncommitted, finish and commit it FIRST,
before item 1, and quote killed/(killed+survived).

## Report
Shas, the six 55 stills with one line each, test/scenario results with numbers, the replay hash,
any golden re-blessed, what is not done.
