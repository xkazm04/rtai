# n26 pressure films (made 16:24 to 16:40 by the Director; the builder was at its usage limit)

Made with the committed n24 tool `tools/gauntlet/pressure_films.mjs` on `244833dac` (= HEAD code; log
`evidence/n26-pressure/films-head.out.txt`), 32 px/m, tilt 70, 1920x1080, 60 fps. Before = the same tool, takes and seeds
filmed at the n24 pressure final (= main's pressure state), `gtai-masters/n24/pressure/`. Side-by-sides by ffmpeg hstack.
All under `C:\Users\kazda\kiro\gtai-masters\n26\pressure\`, indexed by `frames.json` (15 entries).

| file | ffprobe (w,h,fps,s) | shows | numbers (HEAD; before) |
|---|---|---|---|
| rocket_pair_32.mp4 | 1920,1080,60/1,16.0 | rockets take seed 1: Rivet's launcher vs a rocket trooper | 238 frames with both rockets in flight, 8 dashes, HP 95.3 (n24: 206, 7, 95.3) |
| rocket_pair_32_before_after.mp4 | 1920,1080,60/1,16.0 | n24 left, HEAD right | - |
| rocket_pair_64.png / _before_after.png | still, tick 100 | both rockets in one frame; solid ice shape -> cased rocket | - |
| deflect_half_32.mp4 | 1920,1080,60/1,20.0 | guard then plasma bat vs three rifles at 9.5 m, seed 19 | guard 4 passed / 5 returned / 2 shooter hits, HP 95.2; bat 3 / 3 / 1, HP 91.6 (12 deg: 5/5/1, 5/5/1) |
| deflect_half_32_before_after.mp4 | 1920,1080,60/1,20.0 | 12 deg left, 20 deg right | - |
| deflect_curve.png | chart | share.md as a curve | 6 m: guard 24.3 %, bat 30.6 % (12 deg 42.3 / 51.6 %) |
| standing_punished_32.mp4 | 1920,1080,60/1,21.0 | wave 6 seed 28: stand, circle, circle+dash, 7 s each, HP in caption | final HP 33.6 / 69.7 / 89.2 (n24 33.6 / 67.9 / 89.2) |
| standing_punished_32_before_after.mp4 | 1920,1080,60/1,21.0 | n24 left, HEAD right | - |
| standing_punished_64.png | still, dash take tick 265 | a cased rocket on its line as Rivet dashes | - |

Not made (no take exists, no builder to add one): circling against exactly two troopers at range with and without the
dash (the wave-6 take is a mixed crew with two launchers and its 7 s circle does not separate the trooper change:
69.7 vs 67.9 HP), and a guard take at 6 m (the take's rifles stand at 9.5 m). The circling proof is
`evidence/n26-pressure/trooper/arena.md` (steady circle hit 48/48, circle + dash 0/48), the 6 m proof `deflect/share.md`.
I looked at 3 stills of each film and every 64 px/m still: no black or frozen frame; the right subject in each.
