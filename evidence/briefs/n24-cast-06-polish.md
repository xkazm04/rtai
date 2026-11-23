# Brief 06 (lane cast): kill the card-view survivors, review fixes, the weakest checklist items
Wall-clock HARD STOP 00:00 (Windows local time; check with `date`). Last code commit 23:55. Whatever is not committed
by 23:55 is left unstaged and reported. The director runs the final gate at 00:05: leave no Godot running.
Fix lint and format findings in your own edit and go on. Never amend, never rebase. One commit per item below.

## 1. Kill the mutation survivors (first, by 23:30)
Call 05 scored `foe_turret_card_view.gd` 3/(3+17) and `foe_war_card_view.gd` 4/(4+14) (logs:
`C:\Users\kazda\kiro\gtai-art\foes-n24\05-mutate-turret.log`, `05-mutate-war.log`). Survivors (line, operator):
- turret: 41 or->and; 52 -; 57 not removed; 60 / and 0.0; 61 < -> <=; 64 0->1; 65 ==, or, !=; 71 !=; 72 false->true;
  76 ==; 77 1.0 and *; 87 -; 89 ==.
- war: 44 0.0; 49 /; 76 <=; 109 * and 0.5; 114 /; 120 <= and 0.0; 132/136/138/141 frame-index literals; 140 144.0.
Add assertions to `project/tests/unit/test_cast_turret.gd` and `test_cast_war_machine.gd` that pin the observable
result of those lines (which cell/row/frame an action at a given tick picks, the flip for left facings, the scale /
offset a card is drawn at, the boundary tick where an action ends). For a literal that is a sheet layout constant
(frame counts, cell sizes), assert it against the sheet: cell count = texture width / cell width, so a wrong constant
fails. If a survivor is truly equivalent (no observable change), say which and why in one line; do not chase it.
Commit `cast: pin the turret and walker card views in tests`. Then re-run
`node tools/mutate/mutate.mjs --file=project/features/combat/squad/foe_turret_card_view.gd --max=20` and the same for
`foe_war_card_view.gd` (one at a time, never while another Godot of yours runs) and quote both scores.

## 2. Review fixes (by 23:45)
- `project/features/characters/cast_cards.gd` reads `stomp` only under `if key == "war_machine"`: make `stomp` an
  optional per-pitch key read for any row (schema: optional string; absent = ""), no id branch. Test: a row without
  `stomp` loads with an empty stomp path; the war_machine row loads its stomp sheet. Commit.
- `audit_after_lineup_{32,64}ppm_tilt70.png` in `C:\Users\kazda\kiro\gtai-masters\n24\cast\` show mojibake in the
  header ("Â·", "70Â°", "Ã—"): UTF-8 read as Latin-1 in the label path (`tools/art/cast_*` or `project/dev/cast/**`).
  Fix the cause (or use plain ASCII "x", "deg", "-") and re-render both after plates. Do not re-render the
  `audit_lineup_*` (before) plates. Commit the tool/scene fix.

## 3. 64 px/m beside clips (by 23:50, outside the repo except dev-scene changes)
`<enemy>_beside_32.mp4` (lancer, door, clamshell, pile) are right but the figures are tiny on an empty matte. Add
`<enemy>_beside_64.mp4` for the four: same beats (stand beside patrol cop and Rivet, walk, tell + fire, hit, death),
64 px/m, tilt 70, 1920x1080, 60 fps, 15-25 s by ffprobe, to `C:\Users\kazda\kiro\gtai-masters\n24\cast\`. Hide the
HUD lock icons / bar in the dev scene if it can (dev scene only). Look at 3 stills of each yourself before accepting.
Add them to `frames.json` (keep 8-15 entries, best first; drop the weakest if needed).

## 4. The weakest checklist items (only if time is left, stop at 23:50)
`docs/art/cast-audit.md` after-table: Feet FAIL lancer (10 px slide per held drawing) and door carrier (11 px);
Contact shadow FAIL door carrier and clamshell. If the fix is a view-side value in the cast card views (gait phase,
card stride / playback rate matched to ground speed, shadow radius for the card), make it, re-measure with the same
tool as 05 (`05-sole-track.py` / `tools/film/foot_slide.py`), and flip the cell only on a measured pass (quote the
number). Otherwise leave FAIL. No new art tonight.

## Setup and law
`export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/cast` before every Godot run;
`GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`; `--rendering-driver d3d12`
to render; `--position 0,1440` on any window. One Godot at a time; kill only your own PIDs, never by name.
Allowed paths: `project/features/characters/art/view/**/{rocket_trooper,shield_robot,sentry_turret,war_machine}_*`;
new `project/features/characters/cast_*.gd`, `project/features/combat/squad/foe_*view*.gd` (existing foe views: render
switches only); `project/data/tables/cast_cards.json` + schema; `project/tests/unit/test_cast_*`; `project/dev/cast/**`;
`tools/art/cast_*`; `docs/art/cast-*.md` (+ one pointer line in a docs/art index); one-line call sites in shared render
files (`arena_*`, `street_*`, `foe_looks.gd`, `arena_robot_rigs.gd`), each listed in your report;
`steam/ai-provenance/2026-11.jsonl` (append); `C:\Users\kazda\kiro\gtai-art\foes-n24\**`;
`C:\Users\kazda\kiro\gtai-masters\n24\cast\**`. Any other path: stop and report a NEED. Forbidden: numbers in
`enemies.json`, `weapons.json`, `combat.json`; `input_actions.json`; `project/features/player/**`; `rivet_walk*`,
`rivet_run8*`; `project/features/souls/**`; `project/features/gauntlet/**`; `project/dev/gauntlet/**`;
`gauntlet.json`; `melee_*`; `signature_kills.json`; `project/features/combat/kills/**`; `combat_arena.gd` (one-line
call sites only, listed); `docs/decisions.md` (except the one line of section 5), `STANDARDS.md`, `AGENTS.md`; JOURNAL.md, REPORT.md, `evidence/briefs/`.
AGENTS.md / STANDARDS.md: typed GDScript, ~200 lines per file (300 hard), functions <= 40 lines, <= 5 params, `Log`
not `print`, data JSON with a schema. `node tools/lint/lint.mjs`, `node tools/godot/check.mjs`,
`node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs` before each commit. If the debt ratchet prints
`tighten:`, run `node tools/debt/debt.mjs --update` and commit the baseline.
Commit `.uid`/`.import` with sources; run a Godot `--import` after new art. Stage per path; never amend, rebase, stash,
`add -A`, `commit -a`, push. Commit messages start `cast: `. After a code commit:
`node tools/mutate/mutate.mjs --file=<your main new .gd> --max=20` and quote the score.
Colour law: red is blood only; cops are blue; vermilion only for danger/objectives/Rivet's collar; teal only for souls;
amber for heat and the hazard bands. Never a real person's likeness. Do not change who these enemies are.


## Report back
Commits (sha + message), files, checks (lint, `node tools/tests/run_unit.mjs --changed` pass line, quick gate),
both mutate scores before -> after, equivalent survivors named, the 4 new clip paths with ffprobe duration and size,
the re-rendered plate paths, Feet/Shadow cells changed or not (with the number), what is uncommitted (should be
nothing), what is undone.
