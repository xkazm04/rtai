# Street-fight squad balance

At `0925e0399`, the city squad dealt 32.4% less damage than the city guard. The pit squad dealt 8.5% less. The acceptance limits for the city squad are at least 2.37 HP lost, at most 22.10 s to clear and zero deaths.

## Baseline

The director's four headless `fight_probe` runs used the pit bot and seeds 20261103–20261122. Each seed cleared three waves. Clear time covers those waves including gaps. HP lost and deaths cover all 2,400 ticks. Parentheses give sample standard deviations.

| Encounter | Brain | Clear time, s (SD) | HP lost (SD) | Deaths |
|---|---|---:|---:|---:|
| City | Guard | 17.68 (0.75) | 3.15 (1.77) | 0 |
| City | Squad | 21.14 (1.88) | 2.13 (1.07) | 0 |
| Pit | Guard | 14.72 (0.64) | 8.13 (2.97) | 0 |
| Pit | Squad | 17.68 (1.47) | 7.44 (2.00) | 0 |

I reproduced the summary with `python ../../evidence/briefs/fair20-sum.py` from `build/fair20`. The individual seed digests in those four JSONs are the comparison point for the tuning trials.
