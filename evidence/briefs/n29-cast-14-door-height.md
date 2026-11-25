# Brief n29-cast-14: why the door carrier reads 63 px in the walking film and 56 in the stills (measure only)

Lane `cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd), branch `n29-cast`. Builder sub-agent.
**Hard stop 07:12 local** (check `date +%H:%M` often). **Your one commit by 07:08.** Then report and END.

Read `docs/art/cast-audit.md` sections "Card foes beside the rig patrol cop, n29" (stills: shield_robot 111 px at 64,
56 at 32, body_scale 1.03) and "Heights in size_beside_32.mp4, n29" (`ff06ff086`: door carrier median 63 at 32 px/m over 50
frames; Rivet 80 vs 77, others within 2), the tool `tools/art/cast_film_heights.py` and its crops `build/look/n29-size-film/`.
Question: is the 63 a different drawing (facing: the film walks a rectangle, so it shows down / right / up / left; the
still shows one facing), the door raised above the head in some facings, the walk sheet vs the standing cell (the view's
`HEIGHT_M` 2.0 rescale applied to a different cell height: `foe_shield_card_view.gd`, `cast_door_anchors.gd`), or a
measuring artefact (shadow, label, neighbour)? Per facing in the film: height median (min-max), frames, and a 4x crop of
one frame per facing (LOOK at each). Also the same for Rivet (80 vs 77). Python on the film frames only, no Godot, no code
change. Append "Door carrier height, film vs stills, n29" (table + cause in two lines; say "cause not found" if so) to
`docs/art/cast-audit.md`; small edits to `tools/art/cast_film_heights.py` are allowed. Commit:
`git commit -- docs/art/cast-audit.md tools/art/cast_film_heights.py` (trailer
`Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`). Banned: `git add -A/./-u`, `commit -a`, stash, amend, rebase,
reset. Hook flake `step_guard.break.test.mjs`: run alone, commit again. Never fake a number.
Allowlist: those two files, scratch `build/look/n29-door-height/`. Anything else: report a NEED.
