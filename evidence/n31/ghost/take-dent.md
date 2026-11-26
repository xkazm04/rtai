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

## Films (seed 6, `--bot=average --pick=random --controls=wheel --waves=3 --form=dent --fit=shipped`)

Gauntlet bot film, `--pick-view`, 32 px/m, tilt 70, 1920x1080, `--fixed-fps 60 --write-movie`, d3d12, windowed at 0,1440,
through `runGodot` (`build/n31/g19/rg.mjs`) under the lane lock. Both movies start at tick 450 (`--from=450`, stepped headless
before the view opens) and their deploy ticks match the headless runs of the same seed exactly. Movie frames run ahead of
ticks while the wave 1 upgrade card is up (about 185 frames), so clip time is frame / 60, not tick / 60.

| clip deploy | main press / damage tick, clip time | main hits / kills (foes within 9 m) | HEAD press / damage tick, clip time | HEAD hits / kills (foes within 9 m) |
|---|---|---|---|---|
| 1 (wave 1) | 694 / 695, 4.4 s | 2 / 2 (7) | 573 / 588, 2.4 s | 2 / 2 (10) |
| 2 (wave 2) | 1176 / 1177, 15.2 s | 2 / 2 (3) | 1275 / 1290, 17.1 s | 3 / 3 (3) |
| 3 (wave 2) | 1658 / 1659, 23.8 s | 2 / 2 (5) | 1756 / 1771, 25.8 s | 3 / 3 (4) |
| clip total | | 6 / 6 | | 8 / 8 |
| whole 3-wave run | | 8 / 8 (4 deploys) | | 10 / 10 (5 deploys) |

Main damages on the release tick (1 tick after the key goes down: the bot's hold is that short); HEAD damages 15 ticks after
the press (the cock). The runs share the seed and the start tick and split at the first Dent, so each row is the same wave
and the same bot, not the same instant.

Files (`C:\Users\kazda\kiro\gtai-masters\n31\ghost\`, ffprobe lengths): `take-dent-main-vs-head-32ppm.mp4` 3840x1080
26.67 s (labelled "main ba8e470b0" | "n31 ghost 81a831263"), `take-dent-main-32ppm.mp4` 1920x1080 26.67 s,
`take-dent-head-32ppm.mp4` 1920x1080 26.67 s; both clips are movie frames 0-1599 from tick 450. No audio. At 64 px/m
(`ghost_n31_take_closeup.tscn`, same seed, same deploy ticks): the still pair at deploy 3, R+3
`take-dent-main-vs-head-64ppm-ram.png` (main release t1659 + 3, closeup from 1600 frame 68 | HEAD ram t1771 + 3, closeup
from 1686 frame 94; each alone: `take-dent-main-64ppm-release-t1662.png`, `take-dent-head-64ppm-ram-t1774.png`) and
`take-dent-head-64ppm-halfspeed.mp4` 1920x1080 13.32 s (HEAD deploy 2 whole at half speed, closeup from tick 1210, frames
0-399: lead-in, press t1275 at frame 65, cock + skid, dive and ram t1290 at frame 80, scuffed lane held to the end; deploy 3
was not used for it because the wave 2 upgrade card covers the screen from about R+60). Raw logs and deploy JSON:
`build/n31/g19/` (git-ignored).

Read from the movies: 32 px/m HEAD frame 1019 (between press t1275 and ram t1290, crop) shows Dent's teal body at Rivet's
side and two dark scrape lines with tan grit running down-right from him to the three cops on the kerb: the telegraph reads
at the gameplay camera. Frame 1027 (R+3) the teal body is in the dust wake among the cops with hit stars on them; frames 1110
and 1180 (1.4 s and 2.6 s later) a tan-brown scuffed lane stays on the road with the three bodies lying at its end. At 64
px/m, deploy 3: frame 87 (R-4) Dent cocked just behind Rivet, both skid lines whole up the lane to four cops; frame 94 (R+3)
Dent mid-dive with a thick dust wake behind him, three white hit stars on the three cops at the lane's end, blood spray;
frames 101-120 the scuff under the lane, then the wave-clear card. Main at its release + 3 (64 px/m frame 68): two white hit
stars on the cops pressed against Rivet, no Dent body and no teal capsule on screen (the bot holds for 1 tick, so the
capsule never shows). One thing a player may read as off: in the half-speed clip (frame 80 = R) the hit stars are already on
the cops while Dent's body is still near the lane origin; it reaches them about 4 ticks later (the dive is R..R+8, ease-out),
so the bodies drop just before he arrives. At 64 px/m Dent's body also crosses Rivet's sprite at the start of the dive
(Rivet walked into the lane during the cock).

What a player would say: on main Dent is a shove you barely see, two cops next to you fall at the instant you let go; on HEAD
you tap once, he pops out at your side, two scrape lines run down the road to the cops for a quarter second, then he
rockets along them and drops the whole line (3 of 3 and 3 of 4 in wave 2, main 2 of 3 and 2 of 5) leaving a scuffed lane;
the wind-up reads as a wind-up because the lines are drawn before the hit, but over 10 seeds the ram is a 3+ hit only a
little more often than main's shove, and nobody has played it with hands yet.

## Re-film at c2973118d (g28)

Builder `g28-dent-refilm`, 2026-11-26. The HEAD side re-shot at `c2973118d` (after `1da987d15`, the arrival fix: the dive
runs R-6..R so the body meets the ram tick), main side unchanged (the existing `take-dent-main-32ppm.mp4`, `ba8e470b0`).
Same recipe as g19: temp worktree `gtai-wt/g28-head` (1920x1080 in its own `project.godot`), seed 6, `--form=dent
--fit=shipped --bot=average --pick=random --controls=wheel --waves=3 --pick-view`, `--from=450`, tilt 70, 32 px/m,
`--fixed-fps 60 --write-movie`, d3d12, windowed at 0,1440, through `runGodot` under the lane lock. Scratch:
`build/n31/g28/` (git-ignored).

Deploy ticks, press / damage (movie frame of the damage): 573 / 588 (142), 1275 / 1290 (1024), 1756 / 1771 (1547), hits
2 / 3 / 3, kills 2 / 3 / 3: identical to g19, frames included. The 64 px/m closeup from 1210: 573 / 588, 1275 / 1290 at
frame 80, 3 hits, as g19.

Files (`C:\Users\kazda\kiro\gtai-masters\n31\ghost\`, ffprobe): `take-dent-main-vs-head-32ppm.mp4` 3840x1080 1600 frames
26.67 s (labels "main ba8e470b0" | "n31 ghost c2973118d"); `extra/take-dent-head-32ppm.mp4` 1920x1080 1600 frames 26.67 s;
`extra/take-dent-head-64ppm-halfspeed.mp4` 1920x1080 799 frames 13.32 s (closeup from 1210, frames 0-399, half speed);
`dent-arrive-take-64ppm-R.png` (closeup frame 80 = ram tick 1290, deploy 2). The replaced g19 files are in `extra/` with
the suffix `-81a831263`. `frames.json`: the side-by-side's note names the new commit.

Read from the movies, deploy 2 (R = tick 1290). 32 px/m frame 1022 (R-2): Dent's teal body is mid-dive at the near edge of
the three cops on the kerb, the skid lines behind him, no stars yet. Frame 1024 (R): the teal body sits among the cops and
three white hit stars burst around it, the cops tipping over, a dust wake back to Rivet. At 64 px/m frame 78 (R-2) Dent is
already touching the first cop, the other two standing just past him; frame 80 (R) his body is in the middle of the three
with a hit star on each and the dust wake whole behind him. The body is at the cops when the stars appear (g19's take had
the stars at R with the body still near the lane origin and arriving about 4 ticks later).

What a player sees now: Dent rockets down the scraped lane and the cops drop the instant he slams into them, not a beat
before he gets there.
