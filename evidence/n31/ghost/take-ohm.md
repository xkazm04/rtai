# n31 ghost 14: Ohm's drop in real gauntlet play, main | HEAD at the same seed

Builder `g14-ohm-take`, 2026-11-26. Scene `res://dev/ghost_n31/ghost_n31_take.tscn` with the new `--form=ohm --fit=relaxed`
(commit `8abdee4d9`): the gauntlet bot film (`--pick-view`, wheel controls, 32 px/m, tilt 70) with Ohm granted from the start
and kept the only free ghost; the bot's spot scorer is g13's dev `GhostN31BotSpot` (Ohm at 3+ bodies inside his circle), because
the shipped bot never deploys Ohm in early waves. The strike is the real one, logged by `GhostN31Strike`. Seed 6,
`--bot=average --pick=random --controls=wheel --waves=3`, 1920x1080, `--fixed-fps 60 --write-movie`, d3d12, windowed at 0,1440.
Before = main `ba8e470b0` (temp worktree with this branch's `project/dev/ghost_n31/` minus the beats probes; hold to aim, teal
ring, release, instant r3.5 bolt burst). After = `8abdee4d9` (temp snapshot worktree; product code = `6dcc748ed`: Ohm drop
r5, 18-tick charge, g12's drawn beats). Both temp worktrees had `viewport_width/height` set to 1920x1080 in their own
`project.godot` for the capture (the shared checkout's 1280x800 makes Movie Maker record 1280x800 whatever `--resolution`
or `--fullscreen` says). Both movies start at tick 400 (`--from=400`, stepped headless before the view opens) and their
deploy ticks match the headless runs of the same scene exactly.

Seed search (headless, take scene, `--form=ohm --fit=relaxed --waves=3`, seeds 1 2 6 7 8; rows are wave:hits/near):
seed 6 is the only one where HEAD lands on 5+ in wave 1 or 2 and main hits fewer in the same wave (HEAD w1 7/12, main w1 4/8).
Seed 2 HEAD w2 5/5 vs main w2 3/5 was the runner-up. Raw rows: `build/n31/g14/{head,main}-s<seed>.json` (git-ignored).

| clip deploy | main press / damage tick, clip time | main hits / kills (foes within 9 m) | HEAD press / damage tick, clip time | HEAD hits / kills (foes within 9 m) |
|---|---|---|---|---|
| 1 (wave 1) | 562 / 563, 2.8 s | 4 / 4 (8) | 512 / 530, 2.2 s | 7 / 7 (12) |
| 2 (wave 2) | 1093 / 1094, 14.4 s | 3 / 3 (3) | 993 / 1011, 12.7 s | 3 / 3 (3) |
| 3 (wave 2) | 1575 / 1576, 22.9 s | 3 / 3 (4) | 1474 / 1492, 21.3 s | 4 / 4 (4) |
| clip total | | 10 / 10 | | 14 / 14 |
| whole 3-wave run | | 10 / 10 (3 deploys) | | 17 / 17 (4 deploys) |

Main damages on the release tick (1 tick after the key goes down: the bot's hold is that short); HEAD damages 18 ticks after the
press (the charge). The runs share the seed and the start tick and split at the first Ohm, so each row is the same wave and
the same bot, not the same instant.

FILES_PLACEHOLDER

What a player would say: PLAYER_PLACEHOLDER
