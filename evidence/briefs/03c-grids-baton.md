# Brief 03c `grids` (resume): electro_baton, then assault_rifle; the film grows (lane motion, n24)

Hard stop: 23:15 wall clock (check `date`). Commit deadline: 23:05 (electro_baton committed alone first, by
22:55 at the latest). Whatever is not committed by then, describe in your final report. Fix lint and format findings
in your own edit and go on. No amend, no rebase, no `git stash`, no `git add -A/./-u`, no `commit -a`, no reset --hard,
never push. Stage per path. mutate: `--max=20`, changed lines only. Everything from briefs 03 and 03b still binds
(pipeline, accept rule, allowlist, forbidden list, environment, the quick-gate note): same session, continued.

## 0. First: commit the staged chainsaw (director accepted it, 22:03)
Director's look at `grid_chainsaw_64.png`: accepted (bar forward in both hands in every facing, legs step).
Your NEED is granted: `project/tests/unit/test_rivet_walk.gd` is this lane's test (named for `rivet_walk.gd`) and is
added to your allowlist. At :82 point the "no drawn walk" assertion at a weapon that still has no p70 grid (or at p55
chainsaw), keeping what it tests. Run `node tools/tests/run_unit.mjs --changed` (0 failed), then commit the staged
chainsaw files + that test in one commit. Then go on.

## 1. electro_baton p70 (the owner's film needs a baton)
One-hand / blade family as fits `rivet_eq_electro_baton*.png`: the baton held as on its eq card, never a thin grey stick.
Same accept rule: every row looked at in the game at 32 and 64 px/m, stride measured into `rivet_walk.gd` +
`evidence/n24-motion/grid_electro_baton.md`, `walk_grid` pointing at it, before | after stills
`grid_electro_baton_<32|64>.png`, `run_unit --changed` green, one commit. Electric glow, if the eq card has one, stays
in the weapon's own colours (no teal: teal is souls).

## 2. Then assault_rifle p70 (two-hand long family), same rule, its own commit. Then hand_cannon if time is left.

## 3. The game-speed film grows
Re-render `C:/Users/kazda/kiro/gtai-masters/n24/motion/legs_game_32.mp4` (same scene, same framing, fallback left |
own grid right, 6.75 and 9.3 m/s) with every weapon that has landed: gloria, rocket_launcher, chainsaw, electro_baton
(+ assault_rifle if landed). Keep it 15 to 40 s (shorten each weapon's segment; ffprobe it); update its frames.json
entry (`weapons` list, probe). Add a `frames.json` entry per new grid still. Start the film no later than 25 minutes
before the hard stop, even if item 2 is unfinished.

## 4. Before you stop: scratch
`C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_<weapon>_arena/` folders hold GBs of raw frames. Delete the raw
frame folders and .avi intermediates that no `frames.json` entry references (keep the mp4/png outputs and the
capture-source/ scripts). Report the size before and after.

## Report
Per weapon: done / partial / fallback kept, row grades, stride numbers, stills, commit sha; the film path + ffprobe
line; image_gen count and minutes; scratch freed.
