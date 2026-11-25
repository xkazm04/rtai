# n31 ghost 04: the Tonnage drop in real gauntlet play, main | HEAD at the same seed

Builder `g04-take`, 2026-11-25. Scene `res://dev/ghost_n31/ghost_n31_take.tscn` (commit `8ed77a08a`): the gauntlet bot
film (`--pick-view`, wheel controls by default, 32 px/m, tilt 70) with Tonnage granted from the start and kept the
only free ghost, so the shipped bot drops it whenever it is ready; every release is logged by `GhostN31Strike` over the
real strike. Seed 3, `--bot=average --pick=greedy --controls=wheel --waves=3`, 1920x1080, `--fixed-fps 60
--write-movie`, d3d12, windowed at 0,1440. Before = main `ba8e470b0` (temp worktree, hold-to-aim half disc). After =
`5d0f98ccd` (this branch with g02's drop, 6.5 m, g03's four beats and g07's crush kills; temp snapshot worktree).
The movies' deploy ticks match the headless runs of the same scene exactly on both sides.

The two runs share the seed and split at the first Tonnage (HEAD presses at tick 238, main at 306), so each deploy
below is the same wave and the same bot, not the same instant. Each side's clip starts 150 frames before its own
deploy 2 dump and runs 1662 frames (27.7 s); frames run a little ahead of ticks (wave-pick cards, hit stop).

| clip deploy | main press / dump tick, clip time | main hits / kills (foes within 9 m) | HEAD press / dump tick, clip time | HEAD hits / kills (foes within 9 m) |
|---|---|---|---|---|
| 2 (wave 1) | 932 / 933, 2.5 s | 3 / 3 (4) | 856 / 883, 2.5 s | 3 / 3 (4) |
| 3 (wave 2) | 1414 / 1415, 13.5 s | 3 / 3 (7) | 1337 / 1364, 13.1 s | 8 / 8 (10) |
| 4 (wave 3) | 1896 / 1897, 24.2 s | 2 / 2 (10) | 1818 / 1845, 23.4 s | 9 / 9 (12) |
| clip total | | 8 / 8 | | 20 / 20 |
| whole 3-wave run (4 deploys) | | 11 / 11 | | 24 / 24 |

Files (`C:\Users\kazda\kiro\gtai-masters\n31\ghost\`, ffprobe lengths): `take-drop-main-vs-head-32ppm.mp4` 3840x1080
27.70 s (labelled "main ba8e470b0" | "n31 ghost 5d0f98ccd"), `take-drop-main-32ppm.mp4` 27.70 s,
`take-drop-head-32ppm.mp4` 27.70 s. No audio track. Raw logs and deploy JSON: `build/n31/g04/` (git-ignored).

What a player would say: on HEAD the robot hangs over the pack with cracks running out for a beat while Rivet keeps
rolling, then the whole crowd goes down in one dust ring (8 and 9 of the 10 to 12 cops near it), where on main the
claw half disc clips two or three at once and the body shows up after the damage; read from stills of the take, the
0.45 s charge looks like a wind-up because the ghost body and telegraph are on screen during it, not like lag, but
nobody has played it with hands yet.
