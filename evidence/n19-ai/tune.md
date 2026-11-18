# Contractor squad tuning

Five seeds (20261103–20261107), 60 Hz. Clear time covers the first three waves including gaps. Damage and deaths cover the full 2,400 arena ticks. The reference is the A1 guard probe on the same seeds. Percentage changes use the unrounded means. All runs reached their objectives.

| Configuration | Shooter slots | Contractor cover_bias | City clear s | City HP lost | Pit clear s | Pit HP lost | Deaths |
|---|---|---|---|---|---|---|---|
| A1 guard | — | — | 17.58 | 3.60 | 14.53 | 7.32 | 0 |
| trial1 | 3 | 0.65 | 19.39 (+10.3%) | 2.88 (-20.0%) | 17.92 (+23.3%) | 9.24 (+26.2%) | 0 |
| trial2 | 4 | 0.65 | 19.81 (+12.7%) | 2.04 (-43.3%) | 17.73 (+22.0%) | 8.64 (+18.0%) | 0 |
| trial3 | 3 | 1.0 | 20.62 (+17.3%) | 3.12 (-13.3%) | 17.42 (+19.8%) | 7.44 (+1.6%) | 0 |
| trial4 | 3 | 0.9 | 21.67 (+23.3%) | 2.64 (-26.7%) | 17.40 (+19.7%) | 7.68 (+4.9%) | 0 |
| trial5 | 4 | 1 | 19.91 (+13.2%) | 2.76 (-23.3%) | 17.43 (+19.9%) | 7.08 (-3.3%) | 0 |
| trial6 | 3 | 0.8 | 19.98 (+13.6%) | 1.44 (-60.0%) | 17.52 (+20.6%) | 7.56 (+3.3%) | 0 |

Selected **trial3**, with 3 shooter slots and contractor cover_bias 1. It minimized the largest absolute percentage change across the four city/pit measurements among zero-death candidates (19.8%). The ±20% tuning target and ±25% default-change condition both passed. Peek, aggression, ranges, HP and weapon values retained their A4 values.

## Mixed roster for the owner’s Call

| Mode | City clear s | City HP lost | Pit clear s | Pit HP lost | Deaths |
|---|---|---|---|---|---|
| mixed | 24.60 (+39.9%) | 3.84 (+6.7%) | 21.26 (+46.3%) | 7.32 (+0.0%) | 0 |

The mixed run used the selected slot count and the full production roster. All five non-contractor rows are byte-for-byte unchanged.

## Guard parity

All 15 explicit guard digests equal A1. The table gives the digest prefixes. tune.json retains the full SHA-256 digests and individual fight results.

| Seed | City | Pit | Quest 1 |
|---|---|---|---|
| 20261103 | 7a61766c8e50d058 | 1efb05436029012b | 0e26748f40d64c51 |
| 20261104 | 6c453d01df988d82 | b69d9deefdf67c5a | 53d9556ea0e1315b |
| 20261105 | 638eac3e621c0a7d | cb2515acd326c937 | 3e19499c28878dac |
| 20261106 | b98df35202c6ddff | 3976a3c2f3c61b5b | 02f49b97b9ccf8d3 |
| 20261107 | d91f383ea1078089 | 99df41cff4ce6625 | 167aca0103c2f65c |

Each trial used the same command. The guard and mixed verification runs changed only the brain argument and output path.

~~~powershell
node tools/dev/run.mjs fight_probe --all --seeds=5 --enemy-brain=squad --out=<absolute.json>
~~~
