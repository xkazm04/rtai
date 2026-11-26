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

Files (`C:\Users\kazda\kiro\gtai-masters\n31\ghost\`, ffprobe lengths): `take-ohm-main-vs-head-32ppm.mp4` 3840x1080 24.50 s
(labelled "main ba8e470b0" | "n31 ghost 8abdee4d9"), `take-ohm-main-32ppm.mp4` 1920x1080 24.50 s, `take-ohm-head-32ppm.mp4`
1920x1080 24.50 s; both clips are movie frames 0-1469 from tick 400. No audio. At 64 px/m (`ghost_n31_take_closeup.tscn`,
same seed, same deploy ticks; HEAD from tick 440, main from 470): the still pair at deploy 1
`take-ohm-main-vs-head-64ppm-discharge.png` (main release t563 movie frame 94 | HEAD discharge t530 frame 91, plus each alone:
`take-ohm-main-64ppm-release-t563.png`, `take-ohm-head-64ppm-discharge-t530.png`) and `take-ohm-head-64ppm-halfspeed.mp4`
1920x1080 10.65 s (HEAD deploy 1 whole at half speed, `setpts=2.0*PTS`, frames 0-319: lead-in, press t512, creep, discharge,
scorch; under the asked 12 s because the closeup render held 320 frames). Raw logs and deploy JSON: `build/n31/g14/` (git-ignored).

Read from the movies: 32 px/m HEAD frame 128 (between press t512 and discharge t530) shows Ohm's teal body on the aim point
with the amber creep cracks spreading through the pack; frame 135 (discharge) teal bolts from him to every body inside an
amber, dark-fringed ring at the rim; frame 200 (1.1 s later) a charred scorch ring and a dark core stay on the road with the
bodies lying along the ring. All three beats read at the gameplay camera. Main at its release (frame 168): a teal forked bolt
chain jumps over four cops from beside them, no Ohm body on screen. At 64 px/m the camera follows Rivet and the HEAD circle
sits at the lower right edge of the frame, partly cut off at the discharge; the scorch (closeup frame 200) is fully in frame.

What a player would say: on main Ohm is a zap that chains through three or four cops the moment you let go; on HEAD you
tap once, he appears in the middle of the crowd, the ground crackles amber for a beat, and the whole circle goes down at once
(7 of the 12 near in wave 1, main 4 of 8) leaving a burn mark; the 0.3 s charge reads as a wind-up because his body and the
creep are on screen during it, not as lag, but nobody has played it with hands yet.

## Half-speed re-render (g30)

Builder `g30-ohm-halfspeed`, 2026-11-26. Only the 64 px/m half-speed clip, re-rendered long enough (g14's was 10.65 s, under
the 15-40 s rule, because its closeup render held 320 frames). Temp worktree `gtai-wt/g30-head` at `168139f1e` (detached;
git-ignored runtime copied from this worktree: `.godot`, `data/generated/city`, `native/bin`; 1920x1080 in its own
`project.godot` only), `ghost_n31_take_closeup.tscn`, seed 6, `--form=ohm --fit=relaxed --bot=average --pick=random
--controls=wheel --waves=3 --pick-view --from=440`, 560 frames, `--fixed-fps 60 --write-movie`, d3d12, windowed at 0,1440,
through `runGodot` under the lane lock. Scratch: `build/n31/g30/` (git-ignored).

Deploy 1: press 512, discharge 530 (movie frame 90), wave 1, hits 7 / kills 7, near 12: the same ticks and counts as g14.

File (`C:\Users\kazda\kiro\gtai-masters\n31\ghost\`): `take-ohm-head-64ppm-halfspeed.mp4` 1920x1080 h264 60 fps, 1119 frames,
ffprobe 18.65 s (movie frames 0-559, `setpts=2.0*PTS`). The g14 clip moved to
`extra/take-ohm-head-64ppm-halfspeed-8abdee4d9.mp4`. `frames.json`: that entry's title and note name the new commit and length.

Read from the movie (1280-wide stills in `build/n31/g30/fr/`). Frame 72 (press t512): Rivet rolling as the ball beside the
zebra, the cops spread to the right and below, the Ohm slot lit in the HUD; nothing of Ohm on the road yet. Frame 78 (t518,
creep): Ohm's teal body stands among the cops lower right with amber cracks spreading out from under him. Frame 90 (discharge
t530): an amber crackle ring with a dark fringe fills the lower right, thick teal bolts fork from his body to teal hit rings on
the cops inside it, some already falling; the circle runs off the bottom and right edges of the frame (the camera follows
Rivet, as g14 noted). Frame 150 (discharge + 60): Rivet back on his feet running right along the kerb; a charred dark ring
with spiky fringe and a scorched core stay on the road, cops lying along the ring with their rifles dropped, the cops outside
it still standing and aiming.
