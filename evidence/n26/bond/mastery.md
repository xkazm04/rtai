# Ghost mastery on the street

Six of ten average test players took a mastery card by wave 8 with **4 bond per deploy kill, 3 per successful deploy stun and a threshold of 25**. In the ten-seed cohort the fifth and sixth first masteries both landed on wave 8. Four players died before taking a card. Among the six who took one, the median was wave 6.

| Seed | Dent | Kerf | Ohm | Tonnage | Death wave | Form entries | Longest wave (s) |
|---:|---:|---:|---:|---:|---:|---|---:|
| 1 | — | — | — | 4 | 5 | 1 Tonnage | 15.87 |
| 2 | — | — | — | 2 | 5 | 2 Tonnage | 21.05 |
| 3 | — | — | — | — | 9 | 0 | 32.78 |
| 4 | — | — | — | — | 5 | 0 | 18.25 |
| 5 | — | — | 8 | — | 12 | 5 Ohm | 28.63 |
| 6 | — | — | — | — | 5 | 0 | 23.83 |
| 7 | — | — | 8 | — | 9 | 1 Ohm | 23.95 |
| 8 | — | — | 7 | 4 | 10 | 6 Tonnage, 2 Ohm | 32.43 |
| 9 | — | — | — | — | 6 | 0 | 39.30 |
| 10 | — | — | — | 8 | 9 | 1 Tonnage | 24.00 |

Wave numbers identify the rest where the card was taken. A dash means the ghost went unmastered through death. Both arms ran wheel controls and greedy picks to wave 15 or death. Each player died before the cap. The tuned arm's longest fight was seed 9, wave 4, at 39.30 seconds. All 75 wave intervals passed the 180-second limit, including the fatal waves.

## Tuning

At the original 1 / 0.5 / 25, seed 1 took Tonnage at rest 8. The other nine died without mastery, so the cohort never reached a median. The longest baseline wave lasted 69.68 seconds. Before the wave 8 rest, seed 5's Ohm landed four kills and three stuns for 5.5 points, while seed 10's Tonnage landed eight kills for 8 points. At 4 / 3 / 25 those same outcomes earn a card at that rest. A Tonnage player who gets early packs can earn it sooner, as seeds 1, 2 and 8 did. Seed 1 spent its wave 4 pick on mastery and died on wave 5. Its original wave 4 pick was Dent and it reached wave 13.

## Which ghosts had a chance

- **Dent** was owned only on seed 7. The bot released Dent twice for two kills, finishing at 8/25.
- **Kerf** had six releases for four kills on seed 10, nine for three on seed 5, and five for one on seed 7. Kerf's boss cuts can deal damage without securing a kill. On seed 8 the player took Kerf at rest 9 and used it once without a kill. On seed 2 it took Kerf at rest 4, kept its deploy plan on Tonnage and died on the next wave without a Kerf release.
- **Ohm** mastered on seeds 5, 7 and 8. Seed 3 took Ohm at rest 8, landed two kills and one stun on wave 9, and died with 11/25.
- **Tonnage** ended at 24/25 on seed 3 and 20/25 on seed 9. Seed 5 took Tonnage at its last rest, wave 11, and died on wave 12 without a Tonnage release. A repeat with the plan sampled only while the ghost was owned confirmed zero eligible base-combat ticks planning Tonnage. Seeds 4 and 6 took no ghost cards.

## Measurement

The per-wave rows include the ghosts owned during combat, the ending bond, releases, kills, stuns, form-entry ticks, settled form time, wave length and subsequent card draw. A ghost granted at rest first counts as owned on the next block. Overlapping waves share releases within their intervals. Run totals count each release once. Death times use the last simulated tick. An entry between waves appears in the run's entry list. [Per-seed data](mastery.json)

Run the normal gauntlet through the read-only observer, substituting each seed from 1 to 10 and its absolute result path. After all ten runs, the summarizer joins the result files with the matching developer logs.

```text
node tools/dev/run.mjs res://dev/ghost-forms/bond_measure.tscn --fixed-fps=60 --bot=average --pick=greedy --seed=5 --waves=15 --result=<absolute-path>/bond-tuned-5.json
node evidence/n26/bond/summarize.mjs build/gauntlet build/dev bond-tuned-
```
