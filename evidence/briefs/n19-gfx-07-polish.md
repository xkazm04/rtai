# Brief n19-gfx-07-polish: finish the evidence of items 3A and 4, kill the contact survivors, settle the junction goldens

Lane `gfx`, night run n19, NEW session (fresh context). Read `git log --oneline -12`, `AGENTS.md`, and the last 6 lines of `docs/decisions.md` first. You build and measure; the director reviews every diff and frame. Engine polish only: no new content, no colour change to the print.

## Environment (every Godot run)
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/gfx` before every gate or Godot run.
- One Godot process at a time. `--rendering-driver d3d12` for anything that renders; windowed runs take `--position 0,1440`. Kill only your own PIDs, never by name.
- Never push, never read other `n19-*` worktrees. gfx owns `project/features/city/**`, `project/features/police/**`, `native/**`, look profiles. `project/features/characters/**` is the anim lane's, `project/features/arena/**` the ai lane's: do not edit them (write a NEED spec file instead, see part C).
- Stage per path. No `git add -A/./-u`, no stash, no `reset --hard`. `node tools/gate/quick.mjs` before each commit. Commit `.uid` with every new `.gd`.
- The previous builder session was killed mid-run at 00:51. Do not trust any half-written scratch under `build/`; re-run what you need.

## Context (what landed already)
- `268960380` item 3A: baked crowd contact = the rig's three ink rings scaled by hip height (`features/city/view/city_crowd_contact.gd`, `features/city/sim/sim_render.gd`, native `render.cpp`), one call in `project/boot/city_characters.gd`. Report: `C:/Users/kazda/kiro/gtai-masters/n19/gfx/contact/REPORT.md`. Mutate on `city_crowd_contact.gd`: 9/18 killed, 9 survivors (contact-view thresholds, rig-pass attachment, triangle indexing).
- `08db28411` `project/tests/unit/test_city_zebra_clear.gd`: 0 hits over 3,712 zebras. No planted-fault proof was quoted.
- `6ead32adc` + `77ad43790` item 4: `features/city/gen/dock_painter.gd` stamps a 3 m `C_PROP` loading apron on a yard tile when `posmod(t.y, PERIOD) < PERIOD - 1 and not is_yard(g, zone, t + Vector2i.DOWN)`; GENERATOR_VERSION 34; 46 docks chunks moved. Frames `C:/Users/kazda/kiro/gtai-masters/n19/gfx/gen/`. No mutate score was recorded (the run was killed), and there is no clip.

## Part A. Item 4 (docks apron), close the evidence (first, about 20 min)
1. Probe the apron condition over all 256 chunks: count apron tiles by the tile type of the south neighbour. The intent is "a warehouse north wall" only. If any apron sits against something that is not a warehouse block (quay, road, kerb, water, another district), tighten the condition to the block case, bump GENERATOR_VERSION 34 -> 35, re-bake, `-- --check` green, prove downtown and mixed chunks did not move (equal-version bake comparison as last time), and add one decision line `- [2026-11-19] DECISION city/zones-v35-apron-blocks-only ...`. If all aprons sit against blocks, change nothing and quote the counts.
2. Also confirm the walk network is still connected per docks chunk (no walkable pocket left cut off by the apron): count connected walk components per docks chunk at v33 vs v34 (or v35); quote any chunk where the count rose and fix it if one did.
3. Mutation score: `node tools/mutate/mutate.mjs --file=project/features/city/gen/dock_painter.gd --oracle=tests,bake-check --max=15`, and the same with `--lines=` set to the changed lines only (the apron lines). Quote killed/(killed+survived) for both. If a surviving mutant in the changed lines is not equivalent, add a test to `project/tests/unit/test_dock_yard.gd` that kills it and quote the re-run.
4. Clip: a 32 px/m clip, 10 to 40 s, tilt 70, of the same warehouse north wall (the spot in `yard_compare_tilt70_64ppm_t150.png`), v33 before and v34 after, same seed and ticks, side by side (`tools/film/`: read `tools/README.md` for film/compare usage). Name it `item4-apron-tilt70-32ppm.mp4` (or whatever container the kit makes) in `C:/Users/kazda/kiro/gtai-masters/n19/gfx/gen/`, and add it to that folder's `frames.json` as entry 2.

## Part B. The zebra guard proves it fires (about 5 min)
Plant one fault by hand in a scratch edit (not committed): e.g. make the kerb dresser put one solid prop on one zebra's centre in one chunk, run only `--test=test_city_zebra_clear`, quote the failure line it prints, then revert the edit with `git checkout -- <that file>` (single path) and confirm the tree is clean. Also run `node tools/mutate/mutate.mjs` on the generator file you planted in, with `--tests=test_city_zebra_clear` and `--max=8`, to give the guard a score. Quote it.

## Part C. Item 3A (crowd contact), raise its quality
1. Survivors: list all 9 surviving mutants of `project/features/city/view/city_crowd_contact.gd` (line, mutation). For each, either add a unit test that kills it (in a `project/tests/unit/test_city_crowd_contact*.gd`), or state in one line why it is equivalent. Re-run mutate on that file and quote the new score. Do the same, with `--max=12`, for the changed lines of `project/features/city/sim/sim_render.gd` in `268960380` (use `--lines=`).
2. Clip of the LOD crossing: a 32 px/m clip, 10 to 40 s, tilt 70, where at least one walker crosses the 16-rig boundary (rank 16 <-> 17) in shot, before (`268960380^`) and after (`268960380`), same seed and ticks, side by side. Mark the crossing walker (a thin vermilion-free marker: use a neutral grey box or the label strip, never red or vermilion). Into `C:/Users/kazda/kiro/gtai-masters/n19/gfx/contact/` and its `frames.json` as entry 2.
3. The contact report said `RigCastShadows._contact` logged two polygon-triangulation errors in the arena city run. `RigCastShadows` is `project/features/characters/rig_cast_shadows.gd`, anim's file. Find whether `268960380` causes them (run the same scene at `268960380^` and at HEAD, count the errors). If ours, fix it on our side (city files). If it is pre-existing and in anim's file, write `C:/Users/kazda/kiro/gtai-masters/n19/gfx/contact/NEED-anim-triangulation.md` (repro command, the polygon that fails, a proposed fix) and do not edit the file.

## Part D. The six junction look goldens (about 15 min)
The look selftest's junction frames `look-d4-48`, `look-d5-48`, `look-d5-64`, `look-auto-48`, `look-auto-56`, `look-auto-64` miss their stored tolerance on this branch, and did so already before `268960380` (`C:/Users/kazda/kiro/gtai-masters/n19/gfx/contact/golden-comparison.json`). Find out whether they also miss on the base `28302bd3c`: make a temporary worktree of `28302bd3c` under `%TEMP%` (`git worktree add --detach <tmp> 28302bd3c`), copy the needed native DLLs from this worktree's build output if it needs them (do not commit any), run the same look selftest, compare, then `git worktree remove --force <tmp>` and `git worktree prune`. Report one of:
- they miss on the base too: pre-existing (machine/driver), we do not re-bless; quote the means vs tolerance;
- they pass on the base: one of our commits moved them. Bisect the gfx commits (`28302bd3c..HEAD`) and name the commit and the frame. If the move is the intended effect of that item (say which), re-bless only those goldens in one commit naming each frame, with a decision line; if it is not intended, stop and report (do not re-bless).

## Acceptance
- `node tools/lint/lint.mjs`, full `node tools/tests/run_unit.mjs`, the scenarios, `node tools/tests/run_parity.mjs`, bake `-- --check`: all green at your last commit. Quote each line.
- Commits small and per change.
- Frames and clips: look at each before you list it.

## Report back
Per part: what you found (numbers), what you changed (commit ids), mutate scores before/after, the clip paths, the golden verdict, anything not done and why. Order: A, B, C, D. If time runs short, finish A and C2 first.
