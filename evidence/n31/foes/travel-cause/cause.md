# Why ranged foes with a clear line in range are in TRAVEL (n31 foes, b4j)

One seed (average bot, seed 3, `--waves=7`, waves 1-4 counted), `node tools/gauntlet/waiting.mjs --rev=<rev>
--profiles=average --seeds=1 --seed0=3 --out=<dir> --tag=b4j`, counted by `project/dev/foes_n31/waiting_cause.gd`
(one count per ranged foe-tick with a clear line inside attack_m, by the first reason that holds: panic, Rivet
inside danger_m, out of its sight cone, then the walk's kind; `*_short` = the walk's spot within 3 m; hold = no TRAVEL
reason this tick, kept by the 0.6 s min-mode hold). final = the 9b3730e36 rules (measured at 9d9f61ea2, same gait
code, `travel-cause/average-3.json`); G = a4224e310 (walk <= 3 m in range and sight is FIGHT;
`waiting-g/runs/average-3.json`, a different fight from the same seed once G changes it).

| cause (TRAVEL ticks, ranged, clear line, in range, waves 1-4) | final ticks (share of TRAVEL) | G ticks (share of TRAVEL) |
| --- | --- | --- |
| urgent_panic | 1613 (32.5 %) | 737 (18.1 %) |
| urgent_near | 591 (11.9 %) | 625 (15.3 %) |
| far_unseen | 11 (0.2 %) | 19 (0.5 %) |
| cover | 2248 (45.2 %) | 2297 (56.3 %) |
| cover_short | 391 (7.9 %) | 18 (0.4 %) |
| flank | 11 (0.2 %) | 86 (2.1 %) |
| route | 84 (1.7 %) | 181 (4.4 %) |
| hold | 20 (0.4 %) | 118 (2.9 %) |
| **TRAVEL total** | 4969 (61.0 % of clear-line in-range ticks) | 4081 (46.2 % of clear-line in-range ticks) |
| FIGHT | 3180 | 4761 |

Read: moving to cover is the largest TRAVEL cause (2639 of 4969 ticks, 53 %), then morale panic (32 %) and Rivet
inside danger_m (12 %). But 85 % of the cover-walk ticks are on walks still more than 3 m long: a token-less cop
plans a cover spot among boxes within SquadMind.COVER_RADIUS_M 8 m (re-planned every 12 ticks), so a 3 m threshold converts only
the 8 % `cover_short` share. On seed 3, G turned TRAVEL 61 % -> 46 % of the clear-line in-range ticks, but over 10
seeds idle moved only 55 -> 53 % (`waiting-g/waiting.md`): a foe in FIGHT without a token still does not fire.
