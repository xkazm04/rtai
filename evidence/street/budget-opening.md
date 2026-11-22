# Opening gauntlet wave times

Each setting used `node tools/dev/run.mjs gauntlet --seed=<seed> --bot=average --waves=5 --result=<absolute path>` for seeds 1 through 5. The tables show each wave row's `seconds` from first spawn to last kill, rounded to two decimals. The timeout column lists waves with `timed_out: true`. Medians use the full precision in the linked results. The 15-second target applies to combat time and excludes travel and picks.

## Before tuning

Budget in tenths was `20 + 20 × wave` with tier-based costs. The pooled median across all 25 clears was **7.10 s**. The median of the five wave medians was 6.17 s.

| Seed | Wave 1 (s) | Wave 2 (s) | Wave 3 (s) | Wave 4 (s) | Wave 5 (s) | Timed-out waves |
| ---: | ---: | ---: | ---: | ---: | ---: | --- |
| [1](budget/opening-before/seed-1.json) | 4.00 | 7.47 | 2.73 | 4.72 | 20.23 | none |
| [2](budget/opening-before/seed-2.json) | 4.85 | 8.23 | 7.15 | 4.50 | 30.63 | none |
| [3](budget/opening-before/seed-3.json) | 5.62 | 8.68 | 4.12 | 9.23 | 22.25 | none |
| [4](budget/opening-before/seed-4.json) | 6.10 | 6.98 | 7.27 | 8.55 | 13.42 | none |
| [5](budget/opening-before/seed-5.json) | 7.10 | 5.57 | 4.92 | 6.17 | 12.62 | none |
| **Median** | **5.62** | **7.47** | **4.92** | **6.17** | **20.23** | |

## Settings measured

| Trial | Base | Per wave | Cost override | Wave 1 median | Wave 2 | Wave 3 | Wave 4 | Wave 5 | Pooled median |
| --- | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| [1](budget/opening-100-12/) | 100 | 12 | none | 8.95 | 9.07 | 6.57 | 8.40 | 17.33 | 8.98 s |
| [2](budget/opening-180-10/) | 180 | 10 | war_machine 120 | 12.18 | 14.07 | 13.07 | 14.45 | 27.95 | 14.07 s |
| [3](budget/opening-180-10-boss-200/) | 180 | 10 | war_machine 200 | 12.18 | 14.07 | 13.07 | 14.45 | 14.57 | 13.92 s |
| [4, chosen](budget/opening-180-16/) | 180 | 16 | patrol_cop 15, war_machine 200 | 10.35 | 11.70 | 14.13 | 11.48 | 12.17 | 11.67 s |

All five seeds cleared all five waves in the first three trials. Trial 1 left the four regular waves short. Trial 2 put all four regular-wave medians inside the target band. Its boss and escorts took almost twice the 15-second target. Trial 3 increased the machine's reserved cost on the same budget, leaving 30 units for escorts on wave 5, down from 110.

The unchanged three-wave fixture uses seed 7 and a 40-hostile cap. With trial 3, waves 1 and 2 used 39 slots. The third wave queued members that arrived after the fixture captured its first spawn. Clearing that first spawn left the wave active, and the changed suite failed at line 97 of `test_gauntlet_live_wave.gd`. Trial 4 increased patrol cost to leave slots for the mixed third wave and used a 16-unit slope, below the original 20.

## Chosen opening

Trial 4 brought the pooled median across 25 clears to **11.67 s**, 0.33 s below the requested lower bound. The median of the five wave medians was 11.70 s. The 13.92 s setting met the pacing target but failed the stacking fixture. Of the four settings, trial 4 came closest while preserving the tested three-wave behavior.

| Seed | Wave 1 (s) | Wave 2 (s) | Wave 3 (s) | Wave 4 (s) | Wave 5 (s) | Timed-out waves |
| ---: | ---: | ---: | ---: | ---: | ---: | --- |
| [1](budget/opening-180-16/seed-1.json) | 9.40 | 11.87 | 8.42 | 10.90 | 16.40 | none |
| [2](budget/opening-180-16/seed-2.json) | 10.70 | 14.83 | 17.65 | 8.65 | 14.55 | none |
| [3](budget/opening-180-16/seed-3.json) | 10.90 | 11.42 | 14.13 | 11.48 | 12.17 | none |
| [4](budget/opening-180-16/seed-4.json) | 9.07 | 9.50 | 15.75 | 16.23 | 10.32 | none |
| [5](budget/opening-180-16/seed-5.json) | 10.35 | 11.70 | 11.67 | 12.07 | 11.97 | none |
| **Median** | **10.35** | **11.70** | **14.13** | **11.48** | **12.17** | |

## Late budgets and the 40-hostile cap

The selected budget grows by 16 units per wave, down from 20. The counts are `GauntletComposer.shipped(RngRegistry.new(seed)).compose(wave).size()` measured headlessly for seeds 1–5. Boss waves spend 200 units on the machine before the escort draw.

| Wave | Before (units) | Chosen (units) | Roster sizes, seeds 1 / 2 / 3 / 4 / 5 | Queued at start on an empty block |
| ---: | ---: | ---: | --- | ---: |
| 1 | 40 | 196 | 13 / 13 / 13 / 13 / 13 | 0 |
| 5 | 120 | 260 | 4 / 4 / 4 / 4 / 4 | 0 |
| 10 | 220 | 340 | 6 / 6 / 6 / 6 / 8 | 0 |
| 20 | 420 | 500 | 11 / 13 / 11 / 14 / 13 | 0 |
| 40 | 820 | 820 | 26 / 27 / 26 / 25 / 27 | 0 |

`max_alive = 40` applies across all live waves. If older waves hold slots, the street admits only the new members that fit and spawns the rest in roster order as slots open. For example, 20 survivors would initially queue seven of seed 5's 27 wave-40 members. Seed 7's first three rosters contain 13, 14 and 12 enemies, fitting all 39 into the stacking fixture.
