# boot

Composition root: `main.tscn` + `boot.gd`; `world.gd` (`World`) builds the `WorldContext` once and
calls `setup(ctx)` on every `WorldSystem` (ARC-04); `launch_args.gd`; `game.gd`.

The slice (lane slice-play): `quest1.tscn` (`Quest1Game`) is the windows-slice export's main
scene (`run/main_scene.slice`): the title card (`Quest1Card`), quest 1 on `Quest1Session`
(World + stage + quest + `StagePilot` on `LiveInput`), pause with `Quest1SettingsPanel`, beat
checkpoints (features/save) and `--replay` / `--record`. Export:
`"$GODOT_BIN" --headless --path project --export-release windows-slice ../build/export/windows/RTAI.exe`.
