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

## Main side (filmed first)

`take-kerf-main-32ppm.mp4` 1920x1080 25.00 s (ffprobe), movie frames 0-1499 from tick 260 (`--from=260`): deploy 1 press t321 /
cut t322 (frame 62), 1 hit / 1 kill (3 near); deploy 2 (wave 2) press t1008 / cut t1009 (frame 933), 1 / 1 (5 near). The movie's
deploy ticks match the headless seed run. Main frames 61-70 (crop): at the press the teal dashed range ring and a chevron, one
tick later a teal slash on the cop below-right of Rivet and the cop falls, by frame 70 a translucent teal Kerf figure with blade
arms stands over the body. The HEAD side and the rest of this note follow in the next commit.
