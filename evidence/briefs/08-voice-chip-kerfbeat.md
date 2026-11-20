# Brief 08 (lane polish): give kerf_beat.gd back; voice-wash hook; Tonnage's chip face

Hard stop: 50 minutes after you start (write the stop time down at the start). **Last commit by 17:00 local time at the
latest**, whatever the stop time says. Order of value: Part 0 > Part 1 > Part 2. Commit each part separately as it
goes green; if you run short, report exactly where you stopped.

## Environment (every Godot / gate / film run)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n21/appdata/polish`
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- One Godot process at a time; windowed runs use `--position 0,1440`; kill only your own PIDs. Nobody rebuilds native.

## Part 0 (5 minutes): restore a file this lane does not own
Commit 1123a9881 edited `project/dev/ghost-powers/kerf_beat.gd`, which belongs to lane kerf. Restore it exactly:
`git checkout int-n21 -- project/dev/ghost-powers/kerf_beat.gd` (it keeps its own `_nearest`; `GhostReel.nearest`
stays for `ohm_beat.gd`). Check `git diff int-n21 -- project/dev/ghost-powers/kerf_beat.gd` is empty, parse-check it
(`node tools/godot/check.mjs res://dev/ghost-powers/kerf_beat.gd`), commit "Give kerf_beat.gd back its own nearest".
From then on `kerf_*` files are forbidden.

## Part 1: the speaking apparition washes ghosts that draw their own body
Follow `evidence/briefs/06-voice-hook-tonnage-tests.md`, Part 1, exactly (its owned-file list, the restored assert,
the stills, the mutate line). Kerf keeps working through a default no-op; write in your report
`NEED kerf: implement <hook name> on Kerf's spectral body to wash its parts`.
If no dev entry shows the apparition speaking, take the stills from the unit test's scene through a tiny capture
in `project/dev/ghost-powers/` (not `kerf_beat.gd`) or skip the stills and say so; do not spend more than 10 minutes on them.

## Part 2 (only if 15+ minutes remain): Tonnage's HUD chip face
The director looked at `masters:n21/polish/tonnage/tonnage_chip_{before,after}.png` (commit beb12782b). At HUD 1x the
visor slot is only a shade darker, so the face still does not read, and a sliver of a neighbouring cell shows at the
chip's right edge (before and after).
1. Re-cut `project/features/hud/art/ghost_chips/tonnage_spectral.png` with the existing cut script
   (`tools/art/tonnage_chip_cut.py`), never by hand. Take the head-and-shoulders crop from a three-quarter
   (toward-right) cell of the shipped p70 sheet so the visor is larger in the frame. Ink the visor slot near-black (the
   sheet's outline ink) with one thin bright teal glow line across it. No pixel of a neighbouring cell in the chip
   (check alpha at all four edges). Same size and framing rules as the other chips.
2. Godot `--import`; `node tools/tests/run_unit.mjs --changed`; `node tools/gate/quick.mjs`; a provenance line in
   `steam/ai-provenance/2026-11.jsonl` if the source cell is new to this PNG. Commit "Re-cut Tonnage's chip from a
   three-quarter cell".
3. Still at HUD 1x and 4x beside the other three chips: `C:/Users/kazda/kiro/gtai-masters/n21/polish/tonnage/tonnage_chip_after2.png`.

## Owned files (allowlist; any other path: stop and report a NEED, do not edit it)
- `project/features/souls/ghost_*.gd`, `ghost_apparition*.gd`, `tonnage_*.gd`, `ohm_*.gd`, `dent_*.gd`, `hauler_*.gd`,
  their shaders, and their tests under `project/tests/unit/` (+ `.uid`)
- `project/dev/ghost-powers/*` except `kerf_beat.gd` (Part 0 only restores it)
- `project/features/hud/art/ghost_chips/tonnage_spectral.png` (+ `.import`), `tools/art/tonnage_chip_cut.py`
- one line each in `docs/decisions.md` and `steam/ai-provenance/2026-11.jsonl`
- FORBIDDEN: every `kerf_*` file, `project/data/tables/*` Kerf rows, anything under `project/features/souls/art/kerf/`.

## After each commit
- `node tools/tests/run_unit.mjs --changed` green; `node tools/gate/quick.mjs` green.
- Mutate only Part 1's main file: `node tools/mutate/mutate.mjs --file=<file> --max=20 --lines=<changed lines>`; quote it.

## Repo law (binding)
- AGENTS.md / STANDARDS.md; typed GDScript, functions <= 40 lines, files about 200 lines (hard 300), <= 5 params, `Log`.
- Stage per path. No `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push.
- Fix lint and format findings in your own edit and go on.
- No sim, replay, parity or bake digest may move. Teal only for souls.

## Report back
Per part: files, commit, tests, mutate line, still paths, NEEDs, what was not done and why.
