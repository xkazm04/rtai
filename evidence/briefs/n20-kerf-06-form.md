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

## Step 0: merge
`git log --oneline HEAD..n20-flight`; if anything is new, `git merge n20-flight` (the only merge allowed).
Flight's package 3 brings the shared transformation (morph take + emerge), the soul line fade, the aura opt-out,
the apparition hover, the hit lean (12 degrees for Kerf, `GhostRecoil.LEAN_BY_FORM`) and a denser tail root.
Abort and report on conflict. Run `node tools/tests/run_unit.mjs --changed` after the merge.

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

## Step 3: (filled in by the director after the films)

## Checks before each commit
`node tools/gate/quick.mjs` (if it fails ONLY with the "Failed to compile depended scripts" cascade on
combat/kills files, use `--no-godot` plus `node tools/tests/run_unit.mjs --changed` and say so); legacy look
unchanged (render the legacy attack strip at the same ticks and compare to `slice_strip_legacy_32.png`); after the
last commit `node tools/mutate/mutate.mjs --file=<main changed file>` and quote killed/(killed+survived).

## Final message
Commits, the strips you made and what you saw in each, test and mutate lines, NEED lines.
