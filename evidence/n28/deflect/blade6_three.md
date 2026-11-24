# blade6 with the third rifleman firing (n28), seeds 1 to 10, same ticks as n27

Cause: `PressureRifles.drive` picked the shooter for the shipped sword take as `beat / gap_ticks`; the sword beat is
36 ticks with gap 18, so only beats 0 and 1 existed and riflemen 1 and 2 fired every pair, the third never. Fix: the
sword takes (blade6, blade6_spaced) pick the shooter by rounds fired; timing is untouched, so the pairs rotate over
three (seed 1: 44 / 43 / 43 rounds). guard6 (26 / 26 / 26) and blade6_spaced (22 / 22 / 21) are unchanged.

| take | fired | turned back | returns that hit a shooter | share [Wilson 95 %] |
|---|---:|---:|---:|---:|
| n27 blade6 (two shooters) | 1300 | 334 | 91 | 27.2 % [22.7, 32.3] |
| n28 blade6 (three shooters) | 1300 | 334 | 91 | 27.2 % [22.7, 32.3] |

Identical to the digit, per seed too (`seeds/seeds.md`): the three shooters stand at the same range from the mark and
Rivet is stationary in this take, so every round has the same flight time and the same swing meets it; which shooter
fires changes only where the round comes from, and which one is struck (not counted by index here).
