# n20-kerf brief 06: the rest of the form (transformation, hit, tail smoke, cocked idle)

Lane `kerf`, worktree `C:\Users\kazda\kiro\gtai-wt\n20-kerf`, branch `n20-kerf`. Visual night: no change to
powers.json numbers, hit boxes, the sim, any replay/parity/bake digest or any serialized value. Before every
Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/kerf`. Godot:
`C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`, `--rendering-driver d3d12`,
`--position 0,1440` on windowed runs, one Godot process at a time, kill only your own PIDs. Repo law: AGENTS.md
(typed GDScript, files ~200 lines / 300 hard, functions <= 40 lines, `Log` not `print`, stage per path, one commit
per change, `.uid` with every new `.gd`). Kerf owns `project/features/souls/kerf_*.gd`, `art/kerf/**`, the Kerf
files under `art/view/`, `project/dev/ghost-powers/kerf_beat.gd`, its own rows in `ghost_forms.json` and
`ghost_hover.json`, tests named for its files. Anything else: write `NEED flight: <file> <why>` in your final
message, do not edit it.

The plate: `C:\Users\kazda\kiro\gtai-masters\n20\concepts\kerf_a.png`. Look at it before judging any frame.

## Step 0: no merge
The director merges n20-flight before this session starts (JOURNAL.md conflicts otherwise). Do NOT run
`git merge`. Never edit, stage or commit JOURNAL.md or evidence/briefs/*. Note `git log --oneline -3` and whether
flight's package 3 (morph take, emerge, hit lean) is in the tree; steps 1 and 2 need it, else skip them and say so.

## Step 1: transformation in and out, under --ghost-look=spectral
Film strips (top view below the 70 tilt, 32 px/m, every 3 ticks across the whole enter_s and exit_s) of base Rivet
-> Kerf and Kerf -> base Rivet, and form-to-form (Tonnage -> Kerf) if the driver can. Look at them: the spectral
Kerf must appear from flight's morph (no legacy legged Kerf frame, no frame with both bodies at full alpha, no
popping beams/echo/after-image at the start). Fix only Kerf's side (KerfSpectral/KerfRig/KerfBeams/KerfEcho). Save
`kerf_transform_strip_32.png` in `C:\Users\kazda\kiro\gtai-masters\n20\kerf\`.

## Step 2: hit reaction
Strip of Kerf taking a hit (spectral, 32 and 64 px/m, press tick of the hit, +3, +8, +15): flight's 12 degree lean
must tilt the whole spectral body (tilted cell and top-view parts alike, beams following), and the lens should
flinch to the slit for a few ticks (view only: KerfSpectral reads whatever hit signal the rig already has; if there
is none without touching a non-kerf file, skip the flinch and say so). `kerf_hit_strip.png`.

## Step 3: what the director saw in the films (do these FIRST, before steps 1 and 2)
3a. ONE BODY SIZE. `kerf_plate_vs_game.png`: the 70-tilt cruise cell is about 140 px nose-to-tail against about
    185 px for the top-view hull at the same 64 px/m (the tilt body is ~75 % of the top body). Same in
    `kerf_turn_64_t163.png`. Measure both (hull nose tip to hull rear, not the beams) for CRUISE and POISED in
    p70 and p55, and scale the tilted cell (KerfSpectral.GRID_PX_PER_M or a per-mood factor in kerf code) so the
    tilted body's length along the screen x axis matches the top view within 5 %. Vertical stays foreshortened
    by the tilt as now. Re-check that the beams start at the hull's rear in both views after the change.
3b. COCKED ON THE AIM LINE IN PLAY TILT. `kerf_creature_32.png`: poised near a guard, the 70-tilt cell does not
    point at the guard; `pose()` applies `_yaw` only when `_sheet == null` (top view). When a target is in sight
    (`locked`), draw the tilted cell at the octant of `facing + yaw_to_target` (the full unclamped yaw is fine
    for the drawn octant; view only, KerfStage aim and the sim untouched) and point the beams the same way, so
    in play tilt his nose is on the guard and the lens is at the half/slit state like the top view. Render
    `kerf_creature_32.png` again (same layout) and a pair: before/after of that frame.
3c. RE-FILM after 3a/3b with the same commands you used in brief 04 (the current `kerf_close_64.mp4` idle-to-slice
    take is the right content: keep it): `kerf_move_32`, `kerf_attack_32`, `kerf_close_64`, `kerf_tilt55_32`,
    `kerf_plate_vs_game.png`, `kerf_creature_32.png`. `kerf_attack_32.jpg` poster: pick a press tick with one long
    slot, the after-image and a STANDING guard (the current poster is a crowd with short slots). Keep the old
    versions as `before/<name>` in the same folder for the pair. Update frames.json notes.
Then steps 1 and 2 if time allows (the session ends at 75 min: commit each finished step as it lands).

## Checks before each commit
`node tools/gate/quick.mjs` (if it fails ONLY with the "Failed to compile depended scripts" cascade on
combat/kills files, use `--no-godot` plus `node tools/tests/run_unit.mjs --changed` and say so); legacy look
unchanged (render the legacy attack strip at the same ticks and compare to `slice_strip_legacy_32.png`); after the
last commit `node tools/mutate/mutate.mjs --file=<main changed file>` and quote killed/(killed+survived).

## Final message
Commits, the strips you made and what you saw in each, test and mutate lines, NEED lines.
