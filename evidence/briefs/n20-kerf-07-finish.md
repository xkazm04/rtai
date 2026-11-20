# n20-kerf brief 07: transformation, hit, then the look row (last code package; commit by 06:00)

Lane `kerf`, worktree `C:\Users\kazda\kiro\gtai-wt\n20-kerf`, branch `n20-kerf`. Visual night: no change to
powers.json numbers, hit boxes, the sim, any replay/parity/bake digest or any serialized value. Before every
Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/kerf`. Godot:
`C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`, `--rendering-driver d3d12`,
`--position 0,1440` on windowed runs, one Godot process at a time, kill only your own PIDs. Repo law: AGENTS.md.
Kerf owns `project/features/souls/kerf_*.gd`, `art/kerf/**`, the Kerf files under `art/view/`,
`project/dev/ghost-powers/kerf_beat.gd`, its own rows in `ghost_forms.json` and `ghost_hover.json`, tests named for
its files. Anything else: a `NEED flight: <file> <why>` line in your final message. Do NOT run `git merge` (the
director merges). Never edit, stage or commit JOURNAL.md or evidence/briefs/*.

HARD STOP: your last commit lands by 06:00. If a step is not finished by 05:50, commit what is green and stop.

## Step 1: transformation in and out (spectral)
(Flight's package 3 morph take + emerge is merged before this session if it landed; check `git log`.) Film a strip
(70 tilt above, top view below, 32 px/m, every 3 ticks across enter_s and exit_s) of base Rivet -> Kerf and Kerf ->
base Rivet under `--ghost-look=spectral`. Look at it: Kerf must appear from flight's morph with no legacy legged
frame, no frame with both bodies at full alpha, no beams/echo/after-image popping in at full length on the first
tick (fade the beams in over the enter time if they pop). Fix only Kerf's side. `kerf_transform_strip_32.png` in
`C:\Users\kazda\kiro\gtai-masters\n20\kerf\`.

## Step 2: hit reaction
Strip of Kerf taking a hit (spectral, 32 and 64 px/m: hit tick, +3, +8, +15). Flight's 12 degree lean
(`GhostRecoil.LEAN_BY_FORM`) must tilt the whole spectral body in both views with the beams following. If the
rig already exposes a hit signal to kerf code, flinch the lens to the slit for ~6 ticks (view only); if not
without a non-kerf edit, skip the flinch and say so. `kerf_hit_strip.png`.

## Step 3: the look row (only if every check below is true)
Set kerf's row in `project/data/tables/ghost_forms.json` to `"look": "spectral"` ONLY IF: body, flight, blink and
blink-slice are filmed in both tilts (they are: brief 04/06 films), steps 1 and 2 show no legacy frame, the unit
suite is green, `node tools/tests/run_unit.mjs` full is green and the scenario suite passes
(`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`), and no look golden other than a Kerf
one moves (re-bless only goldens that show Kerf, name each). Also check: with no flag the shipped path draws
spectral Kerf (still at 32 px/m), and `--ghost-look=legacy` still draws the old Kerf. If any check fails, leave the
row `legacy` and say exactly which check failed.

## Checks before each commit
`node tools/gate/quick.mjs` (cascade-only failure on combat/kills -> `--no-godot` + `run_unit.mjs --changed`, say so);
legacy look unchanged against `slice_strip_legacy_32.png`; after the last code commit
`node tools/mutate/mutate.mjs --file=<main changed kerf file>` and quote killed/(killed+survived). Update
frames.json (add the transform and hit strips; keep 8-15 entries, best first).

## Final message
Commits, strips and what you saw in each, test / scenario / mutate lines, whether the look row flipped and why.
