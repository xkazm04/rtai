# Brief n26-04-grids-p55: the 55 degree camera, first weapon (Gloria), then stop

Lane `keys`, branch `n26-keys`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (your cwd).

**Hard stop: HARDSTOP wall clock (check `date`). Commit deadline: COMMITBY.** Small commits, staged per path,
`git commit -- <paths>`. No amend, no rebase, no stash, no `add -A/./-u`, no `commit -a`, no `reset --hard`, never push.
Fix lint and format findings in your own edit and go on. mutate: `--max=20`, changed lines only.
Environment, pipeline, provenance, colour law, allowlist and forbidden list: exactly as `evidence/briefs/n26-03-grids-p70.md`,
with `p55` in place of `p70` in every art path and cell folder name (`..._55_cells`).

## Why and what went wrong last time
The owner: "The 55 degree camera: draw the new weapons for it too", starting with last run's seven (gloria, rocket_launcher,
chainsaw, electro_baton, assault_rifle, hand_cannon, machine_pistol). Last run's one p55 attempt (gloria, round
`C:/Users/kazda/kiro/gtai-art/library/rounds/20261122-2025-n24motion/candidate_2/`, read its `review.md` and
`tilt_capture/review.md`) drifted 9.1 cm walk / 18 cm run mean at 32 px/m and was not shipped. Its own review says the
right-profile walk "needs its own cadence" and the front-left run "favours the same leg": it was installed with NO p55
calibration (no `p55/gloria` cycle, no p55 run row factors), and judged as a whole set at the end.

## What you do differently (do all of these; write them at the top of `evidence/n26-keys/grid_gloria_p55.md`)
1. **Reference frames from p55, never p70**: image 1 for every row is the same row of the SHIPPED p55 grid of Gloria's family
   (`project/features/characters/art/view/p55/rivet_walk_eq_pistol.png` / `rivet_run8_eq_pistol.png`, or plasma_rifle p55 if the
   long two-hand hold fits Gloria's eq card better; say which and why); image 2 = Gloria as held in that facing cropped from
   `project/features/characters/art/view/p55/rivet_eq_gloria*.png`. Read `C:/Users/kazda/kiro/gtai-art/library/deliveries/rivet_armed_run_55_it132.md`
   and `rivet_walk_55_it94.md` first (the dome-width scaling to `rivet_run8_55_cells`).
2. **Per-facing check before any packing**: each generated row is compared to the p55 pistol row of the same facing:
   dome width (within 3 %), sole line y (within 2 px in 110 px space), stance travel ratio (`travel 1->3 / 5->7 x H`, within 0.05 of the
   reference row), which boot leads, no extra limb. A row that fails is regenerated alone by example (at most two fixes per row);
   write a per-row table (pick, grade, travel, reference travel, fixes).
3. **Per-row calibration at p55**: measure every row's drawn stride and write the p55 numbers (walk cycle for `p55/gloria`, a run
   factor per run row shorter than bare run8 p55, the profile walk travel) into the stride data, then measure in the game at
   6.75 and 9.3 m/s with `tools/film/foot_slide.py`. Target: walk drift <= 2 cm, run <= 7 cm mean at 32 px/m (p70's standard).
4. **Stop after Gloria.** Do not start a second p55 weapon in this session. Ship Gloria p55 only if it meets the target and your
   own look at 32 and 64 px/m in the game (tilt 55: find how the game selects the p55 view, e.g. a camera tilt flag, and say which);
   otherwise leave it on the fallback, commit the evidence md with the numbers and say what failed.

## Also (cheap, the owner asked; no art change)
A still of Gloria held beside the pistol, same tick and facing, both pitches, 64 px/m, to
`C:/Users/kazda/kiro/gtai-masters/n26/keys/gloria_vs_pistol_64.png` (two to four panels, labelled). The owner asks whether
Gloria, the first pistol-class weapon, is a long two-handed gun and should be redrawn: show it plainly, do not change it.

## Accept, films, report
As brief n26-03 (before | after still at 32 and 64 px/m to `C:/Users/kazda/kiro/gtai-masters/n26/keys/grid_gloria_p55_<32|64>.png`,
one commit with pngs + .import + provenance + numbers + md). Report: the per-row table, drift numbers, whether it shipped, image
jobs and minutes, and what you would change for the next six weapons.
