# Ray gun at tilt 70: own walk and run grids, by sheet-sized image edit

Commit 011e504f6. Same route as the homing shard and mini-nuke (`grid_homing_shard.md`, `grid_mini_nuke.md`): the plasma rifle's packed sheets as image 1, the ray gun equipped strip as image 2. Round: `C:/Users/kazda/kiro/gtai-art/rivet-n28/ray_gun/` (`STATE.md`, `jobs.json`, `roundb/`, `roundc/`, `scripts/`).

## Route and cost

Run sheet: 1 edit, then 1 re-edit with the fixed one-hand wording (the first still showed plasma rifle clutter under the muzzle on rows 2 to 6): `roundc/jobs.json#edit_b_run_sheet`. Walk: the full 8x4 sheet edit never returned (twice); it was split into two half sheets (facings 1-4 and 5-8, each a 4x4 block centred in a 1536x1024 frame), `jobs.json#edit_a_walk_L`, `#edit_a_walk_R`, joined by `scripts/joinhalves.py`. One extra left-half retry (`roundb`) had worse legs and was discarded. **IMAGES 4 this call** (L, R, L retry, run re-edit) plus the run edit and two stalled walk attempts of the earlier call. Donor for every row: the plasma rifle (the pistol fallback was not needed).

Why the walk edit stalls: Codex writes the finished image under `~/.codex/generated_images/<id>/` after about 4 minutes but its copy to `out/` (and its exit) never happens, so `gen.mjs` waits the full 15 min. Both halves and the run re-edit were recovered by copying that file by hand and stopping the gen tree by PID. The full-sheet walk produced no file at all in 12 to 15 min.

## Rows (raw cut for all 16)

Leg IoU = overlap with the donor below 64 % of the figure height (min over the row's cells; this band also holds the pistol hand and gun on rows 1-2, so it reads low there). Signed travel is contact-to-passing / push in packed px, own against plasma rifle.

| Row | Dome dev max | Sole y dev | Leg IoU min | Signed travel own / donor | Tone dev |
|---|---|---|---|---|---|
| walk 1 | 0.0 % | 0 | 0.80 | -18.0, 18.0 / -18.0, 18.0 | 0.0 |
| walk 2 | 0.0 % | 0 | 0.81 | -8.33, 8.33 / -9.33, 9.33 | 0.0 |
| walk 3 | 0.0 % | 0 | 0.86 | 47.33, 34.33 / 45.67, 33.33 | 0.0 |
| walk 4 | 0.7 % | 0 | 0.91 | -32.33, 32.33 / -31.67, 31.67 | 0.0 |
| walk 5 | 0.7 % | 0 | 0.91 | 20.0, -20.0 / 20.33, -20.33 | 0.2 |
| walk 6 | 0.8 % | 0 | 0.88 | -13.33, 13.33 / -14.0, 14.0 | 0.1 |
| walk 7 | 0.0 % | 0 | 0.86 | 31.67, 40.67 / 31.0, 41.0 | 0.1 |
| walk 8 | 0.8 % | 0 | 0.91 | -14.0, 14.0 / -14.0, 14.0 | 0.2 |
| run 1 | 0.7 % | 0 | 0.84 | 2.0, 3.67 / 2.0, 3.33 | 0.1 |
| run 2 | 0.8 % | 0 | 0.82 | 45.33, 47.0 / 44.0, 47.67 | 0.0 |
| run 3 | 0.0 % | 0 | 0.90 | 67.67, 62.67 / 68.0, 63.67 | 0.1 |
| run 4 | 0.0 % | 0 | 0.90 | -4.0, -0.33 / -3.0, -1.33 | 0.0 |
| run 5 | **4.1 %** (cell 1 only) | 0 | 0.91 | 4.0, -4.33 / 4.67, -4.0 | 0.2 |
| run 6 | 0.7 % | 0 | 0.82 | 44.33, 43.67 / 44.0, 43.0 | 0.1 |
| run 7 | 0.8 % | 0 | 0.89 | 62.67, 62.67 / 62.0, 62.67 | 0.0 |
| run 8 | 0.0 % | 0 | 0.91 | 47.67, 47.33 / 47.33, 46.33 | 0.1 |

Open against the brief's bars, for the director: leg IoU is under 0.85 on walk rows 1-2 (0.80, 0.81), run rows 1, 2, 6 (0.84, 0.82, 0.82); run row 5 cell 1 has a dome 4.1 % wide of the donor (the muzzle enters the dome band; the head looks right by eye). The sole line is exact on all 96 cells and the signed travel matches the donor everywhere, so the stride data barely moves. The sole-centre "same leading boot" flag fired on walk (2,2) (2,4) (3,1) (5,1) (5,2) (5,4); the signed travel has the donor's sign on all of them. Legs-kept (donor legs under a seam at 80 %) was tried on walk rows 1-2 and rejected: it left rifle-arm pieces beside the gun. Collar: as the donor sheet's banded orange-and-black; no teal, no red on the weapon; no plasma rifle remnant on the run re-edit by eye.

Data: `grid_stride.armed_cycle_cell` p70/ray_gun 79, walk_profile_travel 25.5 / 34.5; the stride rule gave run_row_k 0.97 to 0.99 on four rows, left out (k = 1) as for the homing shard and mini-nuke. Pinned in `test_rivet_grid_stride.gd`. `run_unit.mjs --changed`: 714 passed; `tools/gate/quick.mjs --no-godot`: ok.

## foot_slide (legs-film rig, turn_090 lane, 32 px/m, cm; walk = planted hold, run = push step; measured now for both)

| | Ray gun | Plasma rifle |
|---|---|---|
| walk hold mean / max | 0.39 / 1.56 | 0.60 / 1.56 |
| run step mean / max | 6.35 / 8.26 | 6.69 / 8.93 |

Bars (walk <= 2, run <= 7): met.

## Stills

`C:/Users/kazda/kiro/gtai-masters/n28/keys/grid_ray_gun_32.png`, `grid_ray_gun_64.png`: stop-gap (temp worktree at ff1586958) | new | plasma rifle, row labels plain ASCII ("row N" = sprite row). The mini-nuke grids `grid_mini_nuke_32.png`, `_64.png` were re-rendered with their stop-gap column (temp worktree at 6d27d55a0). Entries in `frames.json` there.
