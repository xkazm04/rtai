# Riot + drive on n-gunplay HEAD (2026-11-04 03:37-03:40, CONTENDED)

Tree 12dfc10d (+ the plasma halo, view only). Exported windows-bench under `gtai-n4/bench.lock`,
30 s each, vsync off, riot zoom 1.0, drive zoom 0.3, order riot, drive, riot, drive. Other lanes were
rendering at the time: CONTENDED. Script `evidence/n5/riot_head.sh`, raw JSON `evidence/n5/bench/`.
p99 / avg / 1 % low computed from `frame_ms`.

| run | p99 ms | avg ms | 1 % low fps | blood us/frame | pool redraws | drop redraws |
|---|---|---|---|---|---|---|
| riot 1  | 10.283 | 2.397 | 66  | 79.5 | 300 | 1686 |
| drive 1 | 3.692  | 1.108 | 112 | 3.8  | 300 | 1    |
| riot 2  | 8.727  | 2.232 | 72  | 67.3 | 301 | 1690 |
| drive 2 | 5.286  | 1.184 | 101 | 4.2  | 300 | 1    |

Before (01:54-01:56, tree 01b034aa, settled 6, same method): riot p99 8.68 / 6.47 ms, blood 59 / 50 us.
Reading: the combat blood is 0.07-0.08 ms a frame in the riot (under 1 % of the p99); the riot p99
moved with the machine's load (8.7-10.3 now vs 6.5-8.7 at 01:55), not with this lane's code (nothing
in the riot path changed between the trees: the new guns are not in the riot). No idle number this
iteration; the idle bench of record stays the merge's 6.007 ms.
