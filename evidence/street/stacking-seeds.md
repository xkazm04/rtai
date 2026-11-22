# Stacking with the tuned opening

At commit `b98480af1`, the search used `node tools/dev/run.mjs gauntlet --seed=<seed> --bot=<bot> --result=<absolute path>` with default wheel controls, random picks and no wave limit. Peak concurrent waves across the 1 finished runs was 1.

1 runs ended in death. 0 result rows recorded `timed_out: true`. Each peak comes from scanning every wave announcement in that run. The last announcement and final tick below are copied from the runner log.

| Seed | Bot | Wave reached | Death (wave, by) | Timed-out waves | Peak waves alive | Last wave announcement | Final log |
| ---: | --- | ---: | --- | --- | ---: | --- | --- |
| 5 | novice | 23 | 23, shield_robot | none | 1 | `wave 23 tick 41246 block 23, 1 alive` | `tick 42255, segment 23` |

Coverage at this checkpoint was 1 of the 20 seed/profile combinations.

The completed runs provided no tick at which three waves were alive.

The separate five-wave screening runs on this budget also produced 25 clears, zero timeout rows and a peak of one live wave. [Opening results](budget-opening.md)
