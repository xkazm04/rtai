# n30 combat c28: rounds BEFORE film (32 px/m)

Film only, no product change. Temp worktree at HEAD 560c382e8 with only rocket.png, nuke_shell.png, blast_0.png, blast_1.png
checked out from main 5114a4441; native/bin, data/generated/city, .godot copied from this worktree; one `--import` through
runGodot (`--path <abs project>`; the relative `project` cwd form failed with "Invalid project path"). Imported ctex md5 changed
(rocket d7aad483.. -> 5c5eabd6.., nuke_shell 4f3af47f.. -> 3c0dab1e.., blast_0 (b978..) 10b0570b.. -> e65a32ec..), so the old art is on screen.

Command (temp worktree root):
`CHAPTERS=rocket_launcher,mini_nuke QUIT=1500 node evidence/n29/red/film.mjs build/before.mp4` (godot exit 0, not timed out)

ffprobe: `1920,1080,60/1,25.000000` (bar met).
Film: `gtai-masters/n30/combat/films/rounds_before_32.mp4`. Still: `gtai-masters/n30/combat/stills/rounds_before_after_32.png`
(8.3 s, before | after, labelled; crop is the full width, y 122-1080 because stray low-level diffs span the frame).

## Same-tick check vs blast_floor_after_32.mp4 (px differing > 24 in any channel)
| t | diff px | dense-cluster bbox (40 px cells with >50 diff px) | px in dense cells | vermilion before (whole frame = in box) | vermilion after in same diff bbox |
|---|---|---|---|---|---|
| 1.3 s rocket | 1671 | ~(1104,480)-(1343,639) | 1573 | 368 | 228 |
| 7.6 s nuke in flight | 2778 | ~(912,440)-(959,479) | 291 | 1269 | 1131 |
| 8.3 s nuke floor | 10273 | ~(720,280)-(1391,759) | 9739 | 2151 | 491 |

Vermilion = r - max(g,b) >= 79. Caveat: the plain full-frame bbox of the diff is the whole frame at every second
(scattered low-count differing pixels: 100 to 1100 px outside the dense cluster at 1.3 s and 7.6 s, 534 at 8.3 s;
probably encode noise or small moving actors), so the "differences only around the round and blast" expectation holds for the
dense mass (94 to 97 % at 1.3 s and 8.3 s) but at 7.6 s only 10 % of the differing px sit in the round cluster; the rest is
scattered and not attributed. The dense bboxes x-range is overstated by up to 20 % (cell width mis-scaled in the script).
The before film has about 4.4x the vermilion of the after at the nuke floor (2151 vs 491).
