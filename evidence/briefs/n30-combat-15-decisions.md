# n30 combat call 15: one docs/decisions.md line (append only), END by 15:05

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. No Godot. Append exactly this one line at the end of
`docs/decisions.md` (keep the file's line endings; one line, no blank line inside), then commit only that path:
`git commit -m "docs: n30 combat decision (rim patch shipped as a proven patch file)" -- docs/decisions.md` with the trailer
`Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. No stash, no amend, no add -A. Touch no other file. Report the hash.

- [2026-11-25] DECISION n30 combat explosion rim: the amber rim needs a light-model change in `project/core/render/light_pool.gd` and `project/assets/shaders/light_ink.gdshader` (no lane's files), so the lane ships it as `evidence/n30/lights/rim.patch` (8 files: per-kind `rim` flag, alt ink packed into INSTANCE_CUSTOM.w by `LightPool.custom_data`, two tests), proven on screen at t486 64 px/m (cream -> amber, red/teal/vermilion added 0, `evidence/n30/lights/rim_proof.md`) and checked with `git apply --check`, product files restored; the Director applies it after the merge. Rejected: committing core/render from the combat lane (strict ownership), a shader uniform rim colour (one colour for the whole MultiMesh). Re-check: the owner's view of `stills/explosion_rim_patched_pair_64.png` (the rim reads weakly over the nuke's amber floor; a deeper alt ink is one value).
