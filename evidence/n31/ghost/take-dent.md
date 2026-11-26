# n31 ghost 19: Dent's drop in real gauntlet play, main | HEAD at the same seed

Builder `g19-dent-take`, 2026-11-26. Scene `res://dev/ghost_n31/ghost_n31_take.tscn` with `--form=dent --fit=shipped`
(no dev change: the shipped bot fires Dent in wave 1 on every seed tried, so the relaxed fit was not needed): the gauntlet bot
film (`--pick-view`, wheel controls, 32 px/m, tilt 70) with Dent granted from the start and kept the only free ghost. The ram
is the real one, logged by `GhostN31Strike`. `--bot=average --pick=random --controls=wheel --waves=3`.
Before = main `ba8e470b0` (temp worktree `gtai-wt/g19-main` with this branch's `project/dev/ghost_n31/` minus the four
beats probes, which name HEAD-only classes; hold to aim, teal capsule, release, instant 1.8 m-wide shove).
After = `81a831263` (temp worktree `gtai-wt/g19-head`; Dent drop with ram_half_m 1.3 = 2.6 m lane, 15-tick cock, g17's
beats and g18b's ground marks: skid telegraph, dive wake, scuff). Both temp worktrees had `viewport_width/height` set to
1920x1080 in their own `project.godot` for the capture.

## Seed search

Headless, take scene, `--form=dent --fit=shipped --waves=3`. Each cell is `wave@press tick: hits/near` (near = foes within
9 m at the damage tick). HEAD seeds 1-10, main seeds 1-8 (9 and 10 were cut for time). Raw rows:
`build/n31/g19/{head,main}-shipped-s<seed>.json` (git-ignored).

| seed | HEAD deploys | main deploys |
|---|---|---|
| 1 | w1@325:2/7 w1@836:2/8 w2@1605:2/8 w3@2322:1/8 | w1@330:2/7 w1@842:3/4 w2@1354:3/8 w2@1878:2/3 w3@2420:3/6 |
| 2 | w1@506:1/8 w1@987:2/2 w2@1568:4/6 | w1@616:2/4 w2@1098:2/4 w2@1925:2/2 |
| 3 | w1@238:2/3 w1@719:1/5 w2@1200:0/3 w2@1681:3/3 w3@2192:3/9 w3@2767:2/3 | w1@238:2/2 w1@720:2/3 w2@1226:0/3 w2@1833:2/6 w3@2453:2/5 w3@3052:1/2 |
| 4 | w1@353:2/4 w1@1063:0/2 w2@1544:0/5 w2@2025:2/3 w3@2603:2/4 | w1@356:0/4 w1@1084:2/4 w2@1712:2/9 w3@2392:2/9 w3@3027:2/3 |
| 5 | w1@316:1/1 w1@827:1/3 w2@1656:3/7 w2@2339:1/2 w3@3086:2/7 | w1@541:1/8 w2@1426:3/5 w3@1968:1/2 w3@2578:2/4 |
| 6 | w1@573:2/10 w2@1275:3/3 w2@1756:3/4 w3@2327:0/2 w3@2846:2/4 | w1@694:2/7 w2@1176:2/3 w2@1658:2/5 w3@2343:2/6 |
| 7 | w1@528:2/9 w2@1070:2/11 w3@1678:2/10 w3@2533:2/2 | w1@713:2/4 w2@1471:2/10 w3@2167:2/10 |
| 8 | w1@467:1/6 w2@1821:2/7 | w1@472:2/6 w2@1378:0/7 |
| 9 | w1@364:2/4 w1@845:2/5 w2@2006:3/4 w3@2838:2/4 | - |
| 10 | w1@321:2/3 w1@802:3/6 w2@1387:2/4 w3@1889:2/6 | - |

Seeds where a HEAD ram lands on 3+ in wave 1 or 2 and main's deploys in that wave hit fewer: 2 (HEAD w2 4/6 vs main 2/4,
2/2), 3 (HEAD w2 3/3 vs main 0/3, 2/6), 5 (HEAD w2 3/7 vs main 3/5: equal), 6 (HEAD w2 3/3 and 3/4 vs main 2/3 and 2/5).
Filmed: seed 6, the only one with two 3-body rams in one wave, each against a 2-body main deploy in the same wave.
The honest read of the table: the 2.6 m lane does not change the typical count much. Most rams on both sides take 2; HEAD
whole runs over seeds 1-8 hit 60 in 34 deploys (1.76 each), main 59 in 32 (1.84 each); HEAD has 6 rams of 3+ against
main's 4, and 4 zero-hit deploys against main's 3.
