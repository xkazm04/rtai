# Brief n28-cast-08: contractor, transitions + checklist + films (on only if every point passes)

Lane `cast`, branch `n28-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd). Do NOT switch branches.
**Hard stop 21:40 local** (check `date` often): at the hard stop commit what is green, report and END.
**Start your first commit by 21:00; start your last commit by 21:28.** Never leave finished work uncommitted; if a part
is not green by 21:28, commit nothing half-made and list the paths in your report.

Read first, in full: `evidence/briefs/n28-cast-07-contractor-card.md` (parts 3 and 4 are this call's spec) and
`evidence/briefs/n28-cast-03-contractor.md` (bars, Films path, owned-file ALLOWLIST, FORBIDDEN list, repo law, the
"Added 19:25" lessons). Both bind this call. Read the "Contractor, n28" sections at the end of `docs/art/cast-audit.md`.
Done: `930b3b9f3` (cut), `c6792df55` (row off, anchors), `cd738c9a6` (card path test: the generic
`CastCards.current` -> `FoeCastView.feed` -> `CastCardPose`/`CastFarCard` path draws him when the row is on),
`337bb3144` (WALK_STEP_M 0.30 = 10.00 drawings/s at 3 m/s; sole 0.001 px; jump 70 R/DR 3.73/9.04, 55 R/DR 5.09/7.94),
`eb233cf51` (`project/dev/cast/cast_feet.gd` forces the row on via `GTAI_CAST_FORCE=contractor`).

Env, every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/cast`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Never run `Godot_*.exe`
directly (not even `--import`): use `tools/dev/run.mjs`, the film tools, gate, mutate, or `node -e` with `runGodot` from
`tools/lib/godot.mjs`. One Godot at a time; rendering `--rendering-driver d3d12`; windowed `--position 0,1440`. Fold takes
into as few launches as possible (the machine has an 8 GB cap; `mem-budget: waiting` is not a hang).

## Work, in order

A. **Generator keeps 0.30** (small): make the walk step an argument (or a per-sheet constant) of
   `tools/art/cast_foe_soles.py contractor`, so regenerating `CastContractorAnchors` writes 0.30 and not 0.2202. Prove it:
   regenerate, `git diff` on the anchors file is empty. Update the audit note that says "re-apply 0.30 after a regeneration".

B. **Stop, turn, reversal** at 32 px/m, 70 and 55, the way the gunner's audit row was measured (`cast_gunner_turns` scene +
   `tools/art/cast_gunner_transitions.py`, or extend `test_cast_walk_reversal.gd`): stop (walk -> idle: no slide of the
   support sole > 2 px after the stop), turn (facing change mid-walk: body jump <= 12 px), reversal (aim one way, step the
   other: jump <= 12 px, no backwards moonwalk read). Numbers per pitch in a table.

C. **Checklist, ONE frozen-exposure Godot launch** (copy the gunner's poses harness, `project/dev/cast/cast_gunner_poses*`
   and `tools/art/cast_gunner_poses.mjs`, as a contractor variant or with a kind argument): bars, exactly these:
   - Size at 32 px/m, 70 deg: patrol cop 43 / 45 px (70 / 55), Rivet 77 / 75; never taller than Rivet.
   - Live 64 px/m rim (`tools/art/cast_mulroney_edge.py`, frozen exposure) on walk, attack, hit, fall: bar 0, like the
     warden and gunner.
   - Shadow: same-pose toggle at 32 px/m, 70 deg, front three-quarter, px darkened >= 12/255: patrol 236; pass = order
     150-350, a separate ground contact, no baked key shadow.
   - Ink from the sheets (the gunner's ink tool): front passing pose, left contour, y = 70/75/80 of the 192 px cell: patrol
     3,3,4 (70) / 3,3,3 (55); pass = within about 2 px, outline closes, no lost hands, no duplicate hatching.
   - Live palette: hat white (S <= 0.12, V >= 0.78 on the live frame), vest pale lemon (hue >= 45 deg median on the live
     frame, not orange); no red outside blood, no teal, no vermilion, no blue/navy on him.
   Audit table in `docs/art/cast-audit.md` (point, number, verdict), like the gunner's. Deliver
   `contractor_beside_64ppm_tilt70.png` (contractor beside the patrol cop and Rivet, front three-quarter and back, 64 px/m)
   to `C:\Users\kazda\kiro\gtai-masters\n28\cast\` and look at it. Commit (tools + dev scene + audit).

D. **Only if every point of B and C passes**: films through `tools/film/cast_gunner_films.mjs`'s 1920x1080 scratch-project
   path (a contractor variant under `tools/film/`; never edit `project/project.godot`): `contractor_close_64.mp4` (walk, aim
   tell, fire, hit 0.20 s, fall to rest) and `contractor_fight_32.mp4` (Rivet against three contractors, card on), both
   1920x1080, 60/1, 15-40 s: quote the `ffprobe` lines. Extract frames at 1 fps around tell, fire, hit and rest and LOOK at
   them: describe what you see. At every rest count the guns: ONE (the game's pickup; his fall cells draw none). If two,
   it fails. Check Rivet is about 77 px tall at 32 px/m in a frame. Then `enabled: true` in `cast_cards.json`, flip the test
   in `test_cast_contractor.gd`, a `docs/decisions.md` line (append one line at the end:
   `- [2026-11-24] DECISION cast n28: contractor card on ...` with the numbers), add both films + the beside still to
   `C:\Users\kazda\kiro\gtai-masters\n28\cast\frames.json` (valid JSON array; keep existing entries). Commit.
   If any point fails: he stays OFF; write which bar fails and by how much.

## Owned files (ALLOWLIST; any other path: stop and report a NEED)
`project/data/tables/cast_cards.json` (contractor row only), `project/features/characters/cast_*anchors*.gd`,
`project/dev/cast/**`, `project/tests/unit/test_cast_*.gd`, `tools/art/cast_*`, `tools/film/cast_*`, `docs/art/cast-audit.md`,
`docs/art/cast-checklist.md`, `docs/decisions.md` (append one line), `tools/debt/baseline.json` (only through
`node tools/debt/debt.mjs --update --accept-regression="<reason> for n28 cast"`), `project/boot/launch_args.gd` KNOWN_FLAGS
(append only), `C:\Users\kazda\kiro\gtai-masters\n28\cast\**`, `C:\Users\kazda\kiro\gtai-art\foes-n26\contractor*\**`.
FORBIDDEN: `project/boot/prologue/**`, `prologue_*.json`, `rivet_motion.json`, `input_actions.json`, `ghost_*.json`,
`combat.json`, `enemies.json`, `weapons.json`, `project/features/combat/**` (except reading), `project/features/player/**`,
quest 1's `contractor_hit/fall.png` and `street_quest_*`, root `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`.

## Checks and repo law
Before each commit: `node tools/tests/run_unit.mjs --changed` (quote its summary line in your report; the pre-commit hook
does NOT run GUT) and `node tools/gate/quick.mjs --files=<changed>` (known: "Failed to compile depended scripts" on files
unchanged since main is an environment cascade: show `death_pose.gd` fails the same way and rely on GUT). Fix lint and
format findings in your own edit and go on. If the hook fails on `tools/film/kill_reel_*.break.test.mjs`, run an `--import`
through runGodot and commit again; never skip the hook. Stage per path; never stash, `add -A/./-u`, `commit -a`, amend,
rebase, push. Typed GDScript, files ~200 lines (300 hard), functions <= 40 lines, <= 5 params, `Log` not `print`. A new dev
script needs its `.uid` committed (run the import first). A debt rise: accept through the debt tool with a reason. Rendering
only: no behaviour or speed change. No image generation. Never fake a number or a frame; look at every frame you deliver.
Kill only your own PIDs. No mutate in this call.

## Report (then END)
Commits; A proof; B table; C table; beside still path and what you saw; film paths + ffprobe lines + frame descriptions;
`--changed` summary line; on/off and why; what is uncommitted.
