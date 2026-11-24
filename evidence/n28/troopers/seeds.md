# Two troopers (pair_dash), seeds 1 to 10: n27 dash 40 (before) beside n28 dash 24 (after)

Before = this HEAD with `rivet_motion.json` `dash.cooldown_ticks` toggled to 40 uncommitted for the runs only (main `d0ab9d03a` version, restored after). After = HEAD, dash cooldown 24. Take `pair_dash` unchanged in both arms; 25 s windows (1500 ticks). Raw: `before/seeds/`, `after/seeds/`, `before|after/dash_trace.json` (note: these hold markdown, not JSON).

The toggle reproduces n27: seeds 3 and 5 lost 50.9 and 40.6 HP, median 4.6, no downs (matches `evidence/n27-pressure/takes/seeds.md`).

HP lost whole = HP lost over 25 s; HP lost after 10 s = HP at 10 s minus HP at end. Refused = presses minus dashes started.

| seed | rockets b/a | direct b/a | splash b/a | HP lost whole b/a | HP lost after 10 s b/a | dashes b/a | refused b/a | down b/a |
|---:|---|---|---|---|---|---|---|---|
|1|26 / 26|0 / 0|4 / 4|4.5 / 4.5|3.4 / 3.4|13 / 13|13 / 13|no / no|
|2|26 / 26|0 / 0|4 / 4|4.5 / 4.5|3.9 / 3.9|13 / 13|13 / 13|no / no|
|3*|24 / 23|1 / 0|5 / 4|50.9 / 5.1|48.5 / 2.7|13 / 15|11 / 8|no / no|
|4|24 / 24|0 / 0|5 / 5|9.2 / 8.7|7.7 / 7.2|13 / 16|11 / 8|no / no|
|5*|24 / 24|0 / 0|7 / 3|40.6 / 1.6|40.5 / 1.4|13 / 16|11 / 8|no / no|
|6|23 / 23|0 / 0|3 / 3|4.9 / 4.9|4.1 / 4.1|13 / 13|10 / 10|no / no|
|7|26 / 26|0 / 0|4 / 4|4.5 / 4.5|4.1 / 4.1|13 / 13|13 / 13|no / no|
|8|23 / 23|0 / 0|3 / 3|4.0 / 4.0|3.3 / 3.3|13 / 13|10 / 10|no / no|
|9|26 / 26|0 / 0|3 / 3|4.7 / 4.7|4.7 / 4.7|13 / 13|13 / 13|no / no|
|10|26 / 26|0 / 0|4 / 4|3.7 / 3.7|3.4 / 3.4|13 / 13|13 / 13|no / no|

before: HP lost median 4.6, max 50.9, downs 0 of 10, refused 118, rockets 248, direct 1, splash 42.

after: HP lost median 4.5, max 8.7, downs 0 of 10, refused 109, rockets 247, direct 0, splash 37.

Wilson 95% (pooled, from the run tables): direct/rockets before 1/248 = 0.4% [0.1, 2.2], after 0/247 = 0.0% [-0.0, 1.5]; splash/rockets before 42/248 = 16.9% [12.8, 22.1], after 37/247 = 15.0% [11.1, 20.0]. The intervals overlap: the pooled hit shares do not separate; the gain is in the two drifting seeds.

Seeds marked * are 3 and 5. The shorter cooldown covered the second rocket: in both seeds the dash that was refused at 40 (11 refused) is now available (8 refused, 15 and 16 dashes), and HP lost fell 50.9 to 5.1 (seed 3) and 40.6 to 1.6 (seed 5); the median stayed near 4.5 and nobody went down in either arm. Seed 4 improved slightly (9.2 to 8.7); the other seeds are identical to the tenth of an HP, as expected since their second rocket was already covered.
