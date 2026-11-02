# boot

Composition root: `main.tscn` + `boot.gd`; `world.gd` (`World`) builds the `WorldContext` once and
calls `setup(ctx)` on every `WorldSystem` (ARC-04); `launch_args.gd`; `game.gd`.
