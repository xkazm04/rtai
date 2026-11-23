# Brief n26-03 `fence-pump`: the factory chain-link and gate, Mulroney's pump tell (lane yard, run n26)

HARD STOP: <HARD> local (stop work, report). LAST COMMIT: <LAST>. Check `date` now and then.

## Before anything
- `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/yard` and `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe` in every shell that runs Godot. One Godot at a time; windowed runs `--position 0,1440`; kill only PIDs you started.
- Re-read your own recent commits (`git log --oneline -15`): the `line_fire` dressing row, its layout and its dusk light are yours.

## Part A: the factory chain-link and gate sheet (owner: "draw a factory chain-link and gate sheet")
Today the yard fence wire is the quest `cage_mesh` (`project/features/quest/art/collect_call/cage_mesh.png`) mounted on posts by `tools/art/prologue_yard_perimeter.py`; at 64 px/m it reads as a city cage. A sheet drawn for this factory is at `C:\Users\kazda\kiro\gtai-art\factory-n26\out\fence-gate.png`: (1) a long straight chain-link run with posts, top rail and barbed wire that should tile left to right, (2) the same fence end-on (a side fence, top to bottom), (3) a sliding gate leaf on wheels, (4) a pair of gate posts with a hazard plate, (5) a corner post.
1. Cut it with the repo's cut tool (`tools/art/prologue_yard_cut.py`, extend its spec; or extend `prologue_yard_perimeter.py` to take the sheet instead of the cage mesh) into `project/boot/prologue/art/line_fire/`: a fence panel that tiles seamlessly (check the seam: a 3-repeat strip `evidence/yard26/fence_tile_check.png`), a side-fence strip, the gate leaf, the gate posts, the corner post.
2. Use them in the `line_fire` row only (`torn_line` keeps the cage mesh): the south fence each side of the gate, the side fences, the parked gate leaf, the gate posts. Keep the collision exactly as it is (fence rects come from the stage). No wall on the zebra crossing; the gate opening stays open.
3. Kill the 3 fence mutants named in the n25 REPORT if the code they live in is touched (`prologue_yard_fence.gd` lines about panel orientation, highlight, cap thickness), and run `node tools/mutate/mutate.mjs --file=project/boot/prologue/prologue_yard_fence.gd --max=20`.
4. Stills: `evidence/yard26/fence_gate_64ppm.png` (torn_line left, line_fire right, same tick and camera at the gate) and `fence_gate_32ppm.png`.

## Part B: Mulroney's pump tell at play distance (owner: "The pump tell larger at play distance: a bigger marker and a visible arm motion")
Code: `project/boot/prologue/prologue_command_view.gd` (`_marker`, `_pump_marker`: drawn at fixed px sizes, radius 14-17) and `project/boot/prologue/prologue_commander_dress.gd` (`_shotgun`: the rack moves the gun by `rack * 0.32` rad and the slide by 7 px). At the 32 px/m play camera both are too small to read.
1. **Cast lane frames first**: run `grep -n "MILESTONE mulroney" C:/Users/kazda/kiro/gtai-wt/n23-prologue/JOURNAL.md`. If there is a line, it names a commit on branch `n26-cast` and the pump frames: do NOT merge or cherry-pick; report the line to me and continue with step 2 (I wire the frames after the merge). If none: step 2 only.
2. **Bigger marker**: scale the pump marker (and keep the order marker in step) so at 32 px/m it reads at about 1.6 m across on screen (measure its on-screen px at 32 px/m and at 64 px/m; it must not swamp the 64 px/m view: cap it there at its current size or 1.2x). Draw it so the slide's back-and-forward travel is the obvious motion (a pump glyph with the slide moving its full length), plus the countdown ring. Cream on ink, no new colours (vermilion is only for the order countdown: keep it so).
3. **Visible arm motion**: make the rack a clear two-beat motion on the figure: the gun tips up (about 25-30 degrees) and the fore-end/arm pulls back then forward over the pump, so at 32 px/m the silhouette changes. Render only; the sim (pump timing, cooldown, shots) stays exactly as it is: the seed-7 pilot result and the prologue scenarios must be byte-identical before/after.
4. Evidence: a 32 px/m clip of 15-25 s around Mulroney's first two blasts in the seed-7 pilot, before (HEAD before your change, via `git worktree`-free way: `tools/film/` has a same-tick before/after helper, read `tools/README.md`) beside after: `evidence/yard26/pump_32ppm_before_after.mp4` (h264, 1080p60, check with `ffprobe`), and a 64 px/m still of the rack at its widest: `evidence/yard26/pump_64ppm.png`. Report the marker's on-screen size at 32 and 64 px/m.
5. Tests: a unit test that the marker size at 32 px/m is >= the target and at 64 px/m <= the cap; that the arm angle at pump 0.5 differs from pump 0 by >= 0.4 rad.

## Owned files (allowlist). Any other path: stop and write the NEED in your final report.
- `project/boot/prologue/**`, `project/data/tables/prologue_yard_dressings.json`, `prologue_stage.json`, their schemas
- `project/dev/prologue/**`, `project/dev/prologue_yard/**`, `tools/art/prologue_yard_*.py` and their tests
- `project/tests/unit/test_prologue_*.gd`, `project/tests/scenarios/scenario_prologue_*.gd`
- `evidence/yard26/**`, `steam/ai-provenance/2026-11.jsonl` (append one line for the fence sheet, same format as the n25 yard lines), `tools/debt/baseline.json` (only through `node tools/debt/debt.mjs --update --accept-regression="<reason> for n26 yard"`), `docs/decisions.md` (append only)
- `.uid` / `.import` of new files (run one `--import` after adding art, before committing).

## Forbidden
`project/features/**` (incl. Mulroney's cast art under features/characters: the cast lane owns it), `project/core/**`, `lights.json`, `palette.json`, `input_actions.json`, `combat.json`, `enemies.json`, `weapons.json`, `ghost_*.json`, `cast_cards.json`, `native/**`, quest 1 files and tapes, other worktrees. No balance or timing change.

## Repo law
Typed GDScript, files <= 200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`. Stage per path; one commit per change; no `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push. Fix lint and format findings in your own edit and go on. `node tools/gate/quick.mjs` before each commit. Mutate `--max=20` on `prologue_command_view.gd` after Part B; quote killed/(killed+survived).

## Report (final message)
Commits, pieces cut, seam check, marker sizes, arm angle, clip paths and ffprobe line, pilot cmp, mutate scores, NEEDs, what was not done.
