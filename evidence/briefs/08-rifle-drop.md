# Package 8 (guns lane, n19): the dropped rifle lies 0.5 m from the body (owner verdict)

Small package; same law as before. The owner's standing verdict (n11): "The dropped rifle lies 0.5 m from the body." The anim lane measured ~0.86 m from the fallen corpse's boots at 64 px/m (`C:/Users/kazda/kiro/gtai-masters/n19/anim/death-cells/A/after-64.jpg`, read-only, another lane's evidence). Cause (ai lane's reading, verify it): `GroundRifle.lies_at_from` (`project/features/combat/weapons/art/ground_rifle.gd`, consts `AWAY`, `TOWARD_M` 0.5, `SIDE_M` 0.25) places the gun 0.5 m back toward the shooter from the guard's DROP point, while the body falls away from the shot, so gun-to-body is drop->gun plus drop->body. `GroundDropShowcase` (`ground_drop_showcase.gd`) may draw it instead; check which path the arena and quest actually take (`boot/collect_call/view/fx_ground.gd:62`, `fx_view.gd:52`).

## Do
1. Measure first: in a real arena kill (turn kit / existing death films; the body's drawn extent comes from the anim lane's death cells, read them, do not edit them), the distance at 64 px/m from the drawn rifle's nearest point to the drawn body's nearest point, at rest after landing, for a shot from each of 4 sides. Write the numbers down.
2. Fix the placement (our files only: `ground_rifle.gd`, `ground_drop_showcase.gd`, and their tests) so the gun lies 0.5 m (+-0.1) from the body, beside it (not under the legs, not on the head), on the shooter's side. Express it as data/consts so the alternative is one value. If the corpse's lying length is needed, read it from the anim lane's existing data rather than hard-coding a guess, and name the source.
3. Unit test: for the four shot directions, the computed lie point is 0.5 m (+-0.1) from the body's lying segment. Keep the old behaviour testable through the const.
4. Re-measure after (same 4 shots), before/after stills at 64 px/m same tick, to `C:/Users/kazda/kiro/gtai-masters/n19/guns/rifle_drop/` + `frames.json`.

## Acceptance
Unit `--changed` + `--select=test_ground_rifle,test_ground_drop_showcase` green; lint; release_compile; quick gate before commit (say if `--no-godot`). Mutate `ground_rifle.gd` (quote the score). No digest move (view only; if a scenario digest moves, stop and report). One commit, staged per path.
`export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/guns`, `GODOT_BIN`, d3d12, `--position 0,1440`, one Godot, own PIDs. No stash / add -A / commit -a / reset --hard / push.
Report: the before and after numbers, commit, mutate score, evidence paths.
