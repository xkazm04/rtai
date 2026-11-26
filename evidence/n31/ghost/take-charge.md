# n31 ghost 32: Tonnage charge 0.45 s (shipped) | charge 0, in gauntlet play

Builder `g32-charge`, 2026-11-26. Evidence only, no product change. This is a clip for REPORT's owner call "Charge 0.45 s":
the lab says the charge costs about 16 points of share because cops walk out. Until now that call had numbers but no clip.

## Recipe

- Temp worktree `gtai-wt/g32-charge` at `a23c957a3` (this branch's HEAD at launch; no product change since `2dca1b650`),
  detached, with this worktree's git-ignored runtime copied (`project/.godot`, `project/data/generated/city`,
  `project/native/bin`). 1920x1080 is set only in that worktree's own `project.godot`.
- One value changed only in that temp worktree, never committed: `ghost_attacks.json` `tonnage.charge_s` `0.45` -> `0.0`.
  The schema minimum is 0 and the code takes it (`charge_ticks` = 0): the dump lands on the press tick.
- Scene and flags are exactly the `take-drop.md` recipe: `res://dev/ghost_n31/ghost_n31_take.tscn`, seed 3,
  `--bot=average --pick=greedy --controls=wheel --waves=3 --pick-view`.
- Headless first (charge 0), then both sides rendered at 1920x1080, `--fixed-fps 60 --write-movie`, d3d12, windowed at
  0,1440, 2600 frames, through `runGodot` under the lane lock (`build/n31/g32lock.sh`). The shipped side was rendered
  again from the same temp worktree with 0.45 restored. The existing `extra/take-drop-head-32ppm.mp4` starts at movie
  frame 765, after deploy 1, so it cannot be aligned on deploy 1's press. The new shipped movie has the same deploy ticks
  as that clip, and its deploy 2 dump is at frame 915 (765 + 150, the same as g04's cut). Scratch is in
  `build/n31/g32/` (git-ignored).
- The charge-0 movie's deploy ticks match its headless run exactly.

The two runs are identical up to deploy 1's press (t238, movie frame 238 on both sides) and split at the first dump.
With charge 0 the bot presses again as soon as the 480-tick cooldown runs out (719 = 238 + 481), so deploys 2-4 come
137 ticks earlier than on the shipped side. They are the same wave, not the same instant.

## Per deploy (press / dump tick, dump movie frame, hits / kills, foes within 9 m)

| deploy | charge 0.45 s (shipped) | charge 0 |
|---|---|---|
| 1 | wave 1, 238 / 265, f265, 4 / 4 (4) | wave 1, 238 / 238, f238, 4 / 4 (4) |
| 2 | wave 1, 856 / 883, f915, 3 / 3 (4) | wave 1, 719 / 719, f755, 3 / 3 (3) |
| 3 | wave 2, 1337 / 1364, f1548, 8 / 8 (10) | wave 2, 1200 / 1200, f1386, 7 / 7 (10) |
| 4 | wave 3, 1818 / 1845, f2171, 9 / 9 (12) | wave 3, 1681 / 1681, f2021, 9 / 9 (10) |
| whole 3-wave run | 4 deploys, 24 / 24 | 4 deploys, 23 / 23, segment 3 at tick 1843 |

On this seed the 0.45 s charge does not lose kills: 24 vs 23. Deploy 3 is 8 vs 7 with 10 near on both sides.

## Files

Files are in `C:\Users\kazda\kiro\gtai-masters\n31\ghost\`; lengths are from ffprobe.

- `take-charge-045-vs-0-32ppm.mp4`: 3840x1080, 2144 frames, 35.73 s, no audio. Labelled "charge 0.45 s (shipped)" |
  "charge 0". Both sides are movie frames 118-2261, aligned on deploy 1's press: the press is at clip 2.0 s on both
  sides. Shipped dumps are at clip 2.45 / 13.3 / 23.8 / 34.2 s; charge-0 dumps are at 2.0 / 10.6 / 21.1 / 31.7 s.
- `take-charge-045-vs-0-strip.png`: 3840x560 at 32 px/m, four 960x560 crops of deploy 4 (12 near on the shipped side, the
  most). Panels: shipped press t1818 (f2144), press+13 t1831 (f2157), dump t1845 (f2171), then charge 0 at its dump t1681
  (f2021).
- `frames.json`: entry 13 of 15, right after the drop_at clip, ppm 32, with `before` `extra/take-drop-head-32ppm.mp4`.
  To keep the list at 15, the lowest-ranked non-take entry was dropped: `dump-kill-after-64ppm.png` (was 15 of 15) has
  moved to `extra/`. Its `before`, `dump-kill-before-64ppm.png`, is still at the top level.
- Single-side clips, movies, deploy JSON, frames and the ring overlay `fr/ring-pair.png`: `build/n31/g32/`.
- Check: the new shipped render vs `extra/take-drop-head-32ppm.mp4` over its first 60 frames gives PSNR 34.5 dB average
  (32.8 luma, min 33.0). That is re-encode level, not a different run; the deploy ticks match exactly.

## Read from the frames (32 px/m)

**Deploy 1 (clip 2.0 s, the aligned press)**
- charge 0: on the press frame the crack and dust ring is already on the road, before the robot appears.
- shipped: on the same frame the road shows nothing. 27 frames later the body is down in its own dust ring.

**Deploy 4, shipped (strip panels 1-3)**
- Press t1818: Rivet is rolling as the ball at the left. About 13 m to his right are 9 cops and 2 armed hard hats.
- Counted inside the 6.5 m ring at the press: **8 cops**. The ring is drawn from the dump frame's dust ring and shifted by
  the camera move, so it is approximate. One more cop is on the line at the right, and 1 cop and 2 hard hats are outside
  to the lower and upper right.
- Press+13 t1831: the teal body hangs over the pack with the black cracks crawling out under it. The cops have not
  scattered: most still stand where they stood, shooting at Rivet, who has unrolled at the left edge.
- Dump t1845: **9 down**, all inside the ring. Two are still standing on the ring line: the shield cop at the upper left,
  who had drifted from mid-left to the edge, and the cop at the lower right. The 2 hard hats are still outside.
- So on this deploy nobody visibly walked out during the 27 ticks: 8 inside at the press, 9 down at the dump.
  The one extra came from the right edge. The "cops walk out" cost from the lab is not visible in this take.

**Deploy 4, charge 0 (strip panel 4)**
- t1681: the crack ring and dust go off on the press tick with no robot drawn yet; only a small dark aim ring and puff
  are in the middle. 9 go down, and 1 cop stands at the lower right edge.
- The teal body shows up about 9 frames later (f2030), standing in a ring that is already full of bodies.

## What a player would see

With charge 0, the cops drop the instant the button is pressed and the robot appears a beat after the damage. With the
shipped 0.45 s, the robot hangs over the pack with cracks crawling out first, then the same 8-9 go down, so the charge
reads as a wind-up that this bot's crowd (seed 3) does not escape.

## Not done

- No 64 px/m view and no half-speed clip of charge 0.
- One seed only (3). The lab's 16-point share cost is not reproduced here; a fair test of the cost needs more seeds or the
  lab, not one take.
