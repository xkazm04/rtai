# n31 ghost 23: Kerf's drop in real gauntlet play, main | HEAD at the same seed

Builder `g23-kerf-take`, 2026-11-26. Scene `res://dev/ghost_n31/ghost_n31_take.tscn` with `--form=kerf --fit=relaxed`
(no dev change): the gauntlet bot film (`--pick-view`, wheel controls, 32 px/m, tilt 70) with Kerf granted from the start and
kept the only free ghost. Relaxed fit (dev `GhostN31BotSpot`, Kerf at any target) on both sides, because the shipped bot never
fires Kerf in 10 seeds x 3 waves (part 1, `measure-kerf-head.md`). The strike is the real one, logged by `GhostN31Strike`.
`--bot=average --pick=random --controls=wheel --waves=3`, 1920x1080, `--fixed-fps 60 --write-movie`, d3d12, windowed at 0,1440.
Before = main `ba8e470b0` (temp worktree with this branch's `project/dev/ghost_n31/` minus the beats probes, and
`ghost_n31_strike.gd` from `e485c7be1^` because the current one names HEAD's `KerfDrop`; hold to aim with the teal cone,
release, instant blink-cut). After = `f86b03e38` (temp worktree, = g24's relock commit "ghost 24b": one press locks, sight
line + brackets for 12 ticks, blink behind + cut, seam and scorch; a lock broken at the cut re-picks). Both temp worktrees had
`viewport_width/height` 1920x1080 in their own `project.godot` (Movie Maker records the project size).

## Seed search

Headless, take scene, `--form=kerf --fit=relaxed --waves=3`, seeds 1-10 on both sides. Rows are waves 1-2 only:
`wave press/damage tick hits/near` (near = live foes within 9 m at the strike). Raw rows: `build/n31/g23t/{main,head}-relaxed-s<seed>.json`
(git-ignored). The runs are identical up to the first Kerf press, so deploy 1 presses on the same tick on both sides on every seed.

| seed | main (hold, cone, instant cut) | HEAD `f86b03e38` (lock, sight 12 ticks, blink + cut, relock) |
|---|---|---|
| 1 | w1 314/315 1/7, w1 972/973 1/1, w2 1604/1605 1/3 | w1 314/326 1/1, w1 945/957 1/1, w2 1576/1588 1/4 |
| 2 | w1 354/355 1/5, w1 956/957 0/5, w1 1618/1619 1/2, w2 2220/2221 1/3, w2 2822/2823 1/8, w2 3539/3540 1/1 | w1 354/366 1/0, w1 955/967 1/3, w2 1616/1628 0/0 whiff (dead, no relock target) |
| 3 | w1 238/239 1/4, w1 840/841 1/4, w2 1442/1443 1/10, w2 2044/2045 1/4 | w1 238/250 1/4, w1 839/851 1/2, w2 1440/1452 1/3 |
| 4 | w1 343/344 1/4, w1 975/976 1/4, w1 1577/1578 1/1, w2 2179/2180 1/8 | w1 343/355 1/1, w1 974/986 1/4, w2 1629/1641 1/3, w2 2230/2242 1/3 |
| 5 | w1 316/317 1/2, w1 957/958 1/3, w2 1619/1620 1/2, w2 2311/2312 1/2 | w1 316/328 0/1 whiff (dead, no relock target), w1 947/959 1/1, w2 1608/1620 1/3, w2 2393/2405 1/1 |
| 6 | w1 441/442 1/8, w1 1043/1044 1/1, w1 1645/1646 1/2, w2 2337/2338 1/5 | w1 441/453 1/2, w1 1042/1054 1/1, w2 1882/1894 1/3, w2 2582/2594 1/3 |
| 7 | w1 387/388 1/6, w1 989/990 1/1, w2 1621/1622 1/7 | w1 387/399 1/2, w1 988/1000 1/1, w2 1619/1631 1/1 |
| 8 | w1 331/332 1/4, w1 1029/1030 1/2, w2 1740/1741 1/5 | w1 331/343 1/1, w1 992/1004 1/1, w2 1738/1750 1/6 |
| 9 | w1 356/357 1/4, w1 958/959 1/3, w2 1620/1621 1/2, w2 2310/2311 1/1 | w1 356/368 1/3, w1 957/969 1/3, w2 1747/1759 1/4 |
| 10 | w1 321/322 1/3, w2 1008/1009 1/5 | w1 321/333 1/3, w1 922/934 1/1 **relock** (lock broke: target dead 1.0 m from Rivet, re-picked, cut kills), w2 1630/1642 1/1, w2 2231/2243 1/1 |

Every side fires Kerf in wave 1 on every seed, deploy 1 on the same tick. A pre-relock HEAD run (`b5175ba0a`, same 10 seeds) had
three whiffs (seed 2 w2, seed 5 w1, seed 10 w1 deploy 2); with the relock seed 10's is a kill and seeds 2 and 5 still whiff
(nobody else within reach: near 0 and 1). Seeds 1-9 are identical before and after the relock (seed 10 diverges after its relock). **Seed 10** is the take: the
only seed where the HEAD side shows the relock, deploy 1 presses on the same tick on both sides (t321) and each cut kills a
visible cop; main's deploy 2 is in wave 2 (t1008), HEAD's in wave 1 (t922) because the runs split at the first Kerf.

## Take (seed 10, both sides from tick 260; main filmed first, HEAD after g24's relock landed)

| clip deploy | main press / damage tick, clip time | main hits / kills (foes within 9 m) | HEAD press / damage tick, clip time | HEAD hits / kills (foes within 9 m) |
|---|---|---|---|---|
| 1 (wave 1) | 321 / 322, 1.0 s | 1 / 1 (3) | 321 / 333, 1.1 s / 1.3 s | 1 / 1 (3) |
| 2 | 1008 / 1009 (wave 2), 15.6 s | 1 / 1 (5) | 922 / 934 (wave 1), 12.0 s / 12.2 s, **relock**: the locked cop died to Rivet's melee 1.0 m away in the wind-up, the cut re-picked the cop behind him | 1 / 1 (1) |
| clip total | | 2 / 2 | | 2 / 2 |
| whole 3-wave run | | 3 / 3 (3 deploys) | | 6 / 6 (6 deploys, 0 whiffs, 1 relocked) |

Main damages on the release tick (the bot's hold is one tick); HEAD damages 12 ticks after the press (the sight). HEAD's third
deploy (t1630) falls after the clip's last frame (the view holds the sim on some frames, e.g. the wave card, so frame n is not tick 260+n).
The movie deploy ticks match the headless seed runs exactly.

Files (`C:\Users\kazda\kiro\gtai-masters\n31\ghost\`, ffprobe lengths): `take-kerf-main-vs-head-32ppm.mp4` 3840x1080
25.00 s (labelled "main ba8e470b0" | "n31 ghost f86b03e38"), `take-kerf-main-32ppm.mp4` 1920x1080 25.00 s,
`take-kerf-head-32ppm.mp4` 1920x1080 25.00 s; both clips are movie frames 0-1499 from tick 260. No audio. At 64 px/m
(`ghost_n31_take_closeup.tscn`, same seed, same deploy ticks): the still pair at deploy 1, C+2,
`take-kerf-main-vs-head-64ppm-cut.png` (main cut t322+2, closeup from 260 frame 64 | HEAD cut t333+2, closeup from 260 frame
79; each alone: `take-kerf-main-64ppm-cut-t324.png`, `take-kerf-head-64ppm-cut-t335.png`) and
`take-kerf-head-64ppm-halfspeed.mp4` 1920x1080 12.65 s (HEAD deploy 2, the relock, whole at half speed, `setpts=2.0*PTS`,
closeup from tick 860, frames 0-379: lead-in, press t922, Kerf at Rivet's side with the lock on the near cop, that cop dies to
Rivet, cut t934 at frame 80 on the cop behind, the body and the seam held until the camera follows Rivet away). Raw logs, AVIs
and deploy JSON: `build/n31/g23t/` (git-ignored).

## What is on screen

- Main, 32 px/m frames 61-70 (deploy 1): at the press the teal dashed range ring and a chevron; one tick later a teal slash on
  the cop below-right of Rivet and he falls; by frame 70 a translucent teal Kerf with blade arms stands over the body. 64 px/m
  C+2: the cop falling with the teal slash across him, no Kerf body yet.
- HEAD, 32 px/m frames 66-140 (deploy 1, target about 3 m below Rivet): P+1 and P+7 Kerf's teal body at Rivet's side, a thin
  teal sight line from him down to the target and white bracket arcs around the target: the wind-up reads at the gameplay
  camera. Frame 77 (C) Kerf is behind the target on the kerb side, blades out; frame 79 a bright teal diagonal slash through
  him; frame 90 the cop drops; frame 100 a fading teal ring around the body. The char seam and the scorched star are NOT
  readable at 32 px/m: the body lies on the cut spot and only a few amber specks show by its head (frame 140).
- HEAD, the relock (32 px/m frames 716-770, 64 px/m half-speed source): two cops in a line below Rivet; at the press Kerf
  appears at Rivet's side and the near cop carries white lock bars; no sight line is visible (the target is 1 m away, under
  Kerf's and Rivet's sprites). In the wind-up Rivet's claw kills that cop (blood); at C Kerf is behind the second cop on the
  kerb and cuts him. Nothing on screen says "re-locked": the brackets do not move to the new cop before the blink, so it reads
  as Kerf simply taking the next cop. At 64 px/m frames 100-140 a thin dark seam with an amber glint runs diagonally out from
  under the body and a small tan scorch scribble sits by its head at the kerb; both are mostly covered by the body and the
  blood, so the seam reads only if you look for it.

What a player would say: on main Kerf is an instant slash on the cop you aim at the moment you let go, his body showing only
after the kill; on HEAD you tap once, he stands at your side drawing a line and brackets on the cop for a fifth of a second, then
he is behind that cop and cuts him, and when Rivet kills the cop first Kerf takes the one behind instead of wasting the press;
still one cop per deploy on both sides, the wind-up reads at 3 m but vanishes under the sprites at 1 m, the seam is mostly
hidden under the body, and nobody has played it with hands yet.
