# Brief n19-gfx-09 (resume of polish): report 07, then brief 08 Part A

Your previous session was stopped at the 75 min cap with no final message. Commits that landed: 8519afcd4 (apron test), 1c4183544 (contact tests), 2e1fa4d76 (junction goldens re-bless). Clips exist: gen/item4-apron-tilt70-32ppm.mp4, contact/item3a-contact-tilt70-32ppm.mp4, contact/NEED-anim-triangulation.md.

Environment as before: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/gfx` before every Godot run; one Godot at a time; d3d12; `--position 0,1440`; kill only your own PIDs. Do NOT touch the other lanes' gtai-mutate-* temp dirs or processes (move, guns, anim are mutating right now).

1. First (5 min, no new runs): write `C:/Users/kazda/kiro/gtai-masters/n19/gfx/polish-07-REPORT.md` with brief 07's report-back (A: apron probe counts by south neighbour, components v33 vs v34, dock_painter mutate scores whole + changed lines; B: the zebra guard's planted-fault failure line + its mutate score, or "not done"; C: survivors list with killed/equivalent per line, new score for city_crowd_contact.gd and sim_render.gd changed lines, clip, triangulation verdict ours/pre-existing; D: golden verdict). Anything you did not finish: say "not done". Check `git status`: commit nothing half-done; if a scratch planted fault is still in the tree, revert that single path.
2. Then do Part A of `evidence/briefs/n19-gfx-08-apron-bench.md` (the apron edge drawn with existing bollards/ground texture, version bump, re-bake, decision line, test, mutate, frames). Skip Parts B and C of that brief (the next call does them).
3. Acceptance as in brief 08; final message = both reports, short.
