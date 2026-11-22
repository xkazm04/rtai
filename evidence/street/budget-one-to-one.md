# Gauntlet budget conversion

At `e24cc3847`, each enemy cost its tier and the budget was `2 + 2 × wave`. Commit A uses ten units per tier, an empty cost map and `20 + 20 × wave`. Each run used the average bot with the default wheel controls and random picks.

`node tools/dev/run.mjs gauntlet --seed=<seed> --bot=average --waves=10 --result=<absolute path>` produced all six files. All six runs reached wave 10 and exited 0. Paths below are relative to this document.

| Seed | Original result | Converted result | Bytes per file | cmp exit |
| ---: | --- | --- | ---: | ---: |
| 1 | [seed 1 before](budget/one-to-one-before/seed-1.json) | [seed 1 after](budget/one-to-one-after/seed-1.json) | 7,284 | 0 |
| 2 | [seed 2 before](budget/one-to-one-before/seed-2.json) | [seed 2 after](budget/one-to-one-after/seed-2.json) | 7,049 | 0 |
| 3 | [seed 3 before](budget/one-to-one-before/seed-3.json) | [seed 3 after](budget/one-to-one-after/seed-3.json) | 7,250 | 0 |

`cmp.exe <original> <converted>` found all three pairs byte-identical, including enemy counts, combat counters, timings and picks. The composer unit test also compares roster order for each of these seeds over waves 1 through 30.
