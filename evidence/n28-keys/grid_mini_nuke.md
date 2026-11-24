# Mini-nuke at tilt 70: own walk and run grids, by sheet-sized image edit

Commit 2f5dde79d. Same route as the homing shard (`evidence/n28-keys/grid_homing_shard.md`): one edit of the plasma rifle's walk sheet (8x4) and one of the run sheet (8x8), image 2 = the mini-nuke equipped strip. **IMAGES 2** (no re-edit). Round: `C:/Users/kazda/kiro/gtai-art/rivet-n28/mini_nuke/` (`STATE.md`, `jobs.json`, `scripts/`). Prompt added: legs, boots and soles pixel-identical to image 1; the held part stays inside its cell; rigid hazard collar.

## Rows (raw cut, 16 of 16 raw)

| Check | Walk 32 cells | Run 64 cells |
|---|---|---|
| Dome width vs plasma rifle cell | max 0.8 % | all within 3 % |
| Sole y vs donor | 0 px | 0 px |
| Leading boot | same on all | same on all but run row 5 col 2 flagged by the sole-centre test; signed travel on that row matches the donor (5.3 / -3.7 vs 4.7 / -4.0), so it passes |
| Tone vs equipped strip | within 2 | within 2 |
| Collar | as the donor sheet's (banded, as drawn at that size) | same |
| Signed travel own / donor, walk row 3 | 47.3, 34.0 / 45.7, 33.3 | |

Walk cycle 71.3 (armed_cycle_cell), right-profile travel 22.5 / 31 packed texels. Run rows keep k = 1.

## foot_slide (legs-film rig, right profile lane, 32 px/m, cm mean / max)

| | Mini-nuke | Plasma rifle (homing round) |
|---|---|---|
| walk | 1.52 / 1.76 | 5.63 / 7.19 |
| run | **7.62 / 8.15** (limit 7: missed by 0.6) | 4.35 / 7.69 |

A trial `run_row_k` of 1.02 on profile row 2 changed nothing on this rig (identical numbers) and was reverted. The run miss is open.

## Stills

`C:/Users/kazda/kiro/gtai-masters/n28/keys/grid_mini_nuke_32.png`, `grid_mini_nuke_64.png`: stop-gap | new | plasma rifle (the stop-gap column rendered afterwards from a temp worktree at 6d27d55a0, row labels plain ASCII).
