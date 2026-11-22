# Stacking with the tuned opening

The five-wave average-bot runs on the budget committed in `b98480af1` produced 25 clear rows, zero `timed_out: true` rows and a peak of one live wave in every log. All five bots survived to the requested stop.

| Seed and raw result | Last wave announcement |
| --- | --- |
| [1](budget/opening-180-16/seed-1.json) | `wave 5 tick 3150 block 5, 1 alive` |
| [2](budget/opening-180-16/seed-2.json) | `wave 5 tick 4071 block 5, 1 alive` |
| [3](budget/opening-180-16/seed-3.json) | `wave 5 tick 3680 block 5, 1 alive` |
| [4](budget/opening-180-16/seed-4.json) | `wave 5 tick 3498 block 5, 1 alive` |
| [5](budget/opening-180-16/seed-5.json) | `wave 5 tick 3542 block 5, 1 alive` |

The full-run search uses the novice and average bots with seeds 1–10, default wheel controls and random picks. At the commit checkpoint those runs were queued behind the composer mutation test. The opening samples alone provide no two-wave or three-wave tick and no death.
