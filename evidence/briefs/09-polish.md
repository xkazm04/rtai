# Package 9 (guns lane, n19): honest matrix, centred turning clips, weak tests

Same law as packages 3-8 (your thread knows it). No new drawn art in this package.

## Do (in this order, one commit each)
1. **Walk/run column, informational.** The audit claims "0 holes" while 12 of 17 weapons have no armed walk grid (`rivet_walk_eq_<w>.png`) or armed run (`rivet_run8_eq_<w>.png`; RivetWalk falls back to the bobbing facing card). Add `walk` and `run` columns per pitch (p55, p70; `-` at top if top has none) to `tools/arsenal` audit output (txt + json), reported in the matrix but NOT counted in the ratcheted hole total (a separate line `Informational gaps N`). The ratchet test must not fail on them. Write `evidence/arsenal/matrix_after_9.txt` (+ .json).
2. **Centred turning clips.** The turn kit (`arsenal_turn.gd` + its tools/film wrapper) films Rivet at the right third of an arena edge with half the frame empty sand. Centre the camera on Rivet (or move his spot to the room's open middle) so he fills the frame centre at 32 px/m, and he stays in frame through all eight octants. Re-shoot the 32 px/m p55 turning clip for every weapon finished tonight that you can fit in 25 minutes of filming (assault_rifle, homing_shard, ray_gun, mini_nuke, rocket_launcher first; then 06's and 07's weapons), into each weapon's folder, replacing the off-centre clip in `frames.json`.
3. **Weak mutate scores.** `arsenal_turn.gd` scored 5/10 and `rivet_gun_diag.gd` 7/8 (fit-angle boundary survived). Add tests that kill the survivors (list each), re-run `node tools/mutate/mutate.mjs --file=<file>` for both and quote killed/(killed+survived).

## Acceptance
Unit `--changed` + `--select=test_arsenal_audit` green; lint; release_compile; quick gate before each commit (say if `--no-godot`). Director looks at a still from each re-shot clip.
Report: commits, the matrix's informational line, clip paths, mutate scores before/after.
