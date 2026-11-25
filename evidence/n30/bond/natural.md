# n30 natural bond film (no prefill)

Seed 1, bot `average` (BOT env; `bond_film.gd` accepts `--bot=average`), greedy picks, wheel controls, `--bond-prefill=0`.
`--mastery-free=1` is not a film flag; the table default `mastery_free` is already true, so the take matches n29's measured seed 1.
Script: `evidence/n30/bond/render_bond.mjs` (the n29 script, paths n29 -> n30).

## Commands
Pass 1 (find ticks; from/to far beyond the run so no frames are saved and the whole run plays):
`BOT=average node evidence/n30/bond/render_bond.mjs build/n30-bond/p1.mp4 32 1 0 900000 900001 --waves=8`
(the script then exits 1 on its own post step; the log `build/n30-films/bond-32-s1-p0/film.log` is complete.)
Pass 2 (film): `BOT=average node evidence/n30/bond/render_bond.mjs C:/Users/kazda/kiro/gtai-masters/n30/combat/films/bond_natural_32.mp4 32 1 0 7900 9300 --waves=8`
(1792 frames).

## Attempts
| Seed | Bot | Waves | Bond full | Mastery card offered | Mastered / Tonnage entered | Result |
|---:|---|---:|---:|---:|---:|---|
| 1 | average | 8 | tick 7937 (wave 7) | tick 8774 (wave 7 rest) | tick 8775 / 8775 | mastered at wave 7; seeds 8 and 5 not needed |

Wave starts (tick): 1 255, 2 922, 3 1486, 4 2438, 5 3354, 6 5116, 7 6200, 8 9325. Tonnage bond at each release:
12 (t1037), 32 (t1613), 48 (t2529), 52 (t3513, t4055), 64 (t5220), 68 (t6202), 70 (t7937), identical to n29's by-wave 0, 12, 32, 48, 52, 64, 70.
Picks: ghost_tonnage w1, ghost_dent w4, flamethrower w5, gatling w6, master_tonnage w7 (then katana as the second pick: mastery_free).
Entry at 8775 held until exit at 9254 (8 s), second entry 10502.

## Versus n29 prefill-6
Natural mastery arrives at tick 8775 = 146 s (2.4 min) of play, the seventh wave, with 7 Tonnage releases. n29's prefill-6 take
skipped those releases (bond within 6 of the bar from tick 0). No death before wave 8 (hp 40/110 at the card).

## Film
`gtai-masters/n30/combat/films/bond_natural_32.mp4`, 1920x1080, 60/1, 29.87 s. Frames: 4 s shows Rivet in melee with Dent and Tonnage
chips at the left and bond bar under them; 17 s the "Wave 7 cleared / Choose an upgrade" screen with card 1 "Ghost Mastery: Master Tonnage";
22 s Tonnage's teal form standing in the street, HUD chip 2 lit. Overkill Carry (card 2) draws no icon. Entry in the
rest is a hard cut from the card to the form (tick holds on the card for about 330 drawn frames).
