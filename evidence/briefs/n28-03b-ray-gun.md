# Brief n28-03b-ray-gun: finish the ray gun's own p70 grids (resume its round)

Same header rules, bars, wiring, evidence, allowlist (ray_gun only) and forbidden list as `evidence/briefs/n28-03-nuke-ray.md`
(read it). Worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls`, `cd` there in every shell command.
**HARD STOP: report and END by {END}. Commit the grids by {COMMIT1}.**

State: `C:/Users/kazda/kiro/gtai-art/rivet-n28/ray_gun/STATE.md`. The run-sheet edit exists only under codex's folder
(`C:/Users/kazda/.codex/generated_images/01a20eaa-916f-7252-83d1-afd2ddc1d58a/exec-b89235d0-23ef-44a6-b4a7-7ad32134d219.png`,
1536x1024, 18:50): copy it to `out/edit_a_run_sheet.png` and log the copy. The walk-sheet edit never came back: re-run it
alone (one `gen.mjs` job per call; walk and run never in parallel), cap 4 images for this call.
**Fix the prompt contradiction first** (`scripts/mkjobs.py`): the ray gun is a one-hand pistol-grip gun; say "the ray gun
held exactly as in image 2 (one hand on the grip, the other arm as in image 2), legs, boots and soles pixel-identical to
image 1, the held part inside its cell"; drop "keeping each cell's own hand and arm positions". Codex said the run edit moved
"some boot pixels": check the run cells' legs against the donor (leg IoU as for the homing shard; >= 0.85) and re-edit a row
that fails. Render the stop-gap column from a temp worktree (`git worktree add build/wt-before-ray <start sha>`), and
add the stop-gap column to `grid_mini_nuke_64/_32.png` the same way (it shipped without it). Row labels must not overprint.
Report: `IMAGES n`, rows passed, leg IoU per run row, foot_slide beside the plasma rifle's, commit shas, still paths.
