# n10 rivet JOURNAL

## it4 (21:01, first real session; it1-3 exited in seconds on billing, see gtai-n10/logs/runner.log)
Brief: defect hunt. Starting with the static audit of the 17 weapons' sheets, then a harness to walk them.

FRICTION (21:10-21:40) the harness cost ~30 min: first import 9 min on the contended machine; a crop bug (canvas px vs the 800x600 image); TaskStop and a too-broad taskkill filter left overlapping batches writing the same files.
DECISION dev/debt: `dev/rivet_motion/rivet_tour*` (211 lines, dev only) raises `dev_loc`, recorded with `debt.mjs --update --accept-regression` (the README's route for a deliberate increase; reason stored under `accepted`). Delete it after the hunt if it is not worth keeping.
FINDING pistol tour log (21:35, combo 64 px/m): at octant 1 the FIRE cell shows ONE tick then the facing cell for the rest of the latch (t263 frame 5, t264-269 frame 1): a pop inside a burst. Cause not yet proven.
