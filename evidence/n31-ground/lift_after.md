# Rivet lift after (n31-03 part 1: the bob rule; the shadow answer is part 2)

Same probe, tool and columns as `lift_before.md` (`node tools/ground/lift/capture.mjs` +
`tools/ground/lift/lift.py`, 80 ticks per direction, px at the owner's **32 px/m**), on the n31-03
tree; plus `stretch max/min (code)`: `RivetBob.fit` replicated on each logged frame
(`build/n31/n31-03/after_table.py`), and the per-frame shadow rx vs card lift correlation (None =
rx constant or no lift: the shadow does not answer yet, part 2). JSON: `lift_after.json`.

## What changed (render only)

- Found: the table's helmet tops are 110-space px, but `RivetBob.stretch` divided by the native
  recut's cell (1.5x taller), so the stretch delivered 2/3 of what it took back and the lift
  carried the rest: the N flight frame (pistol, top 32 vs 3) dipped 7 px *and* lifted 8.6 px.
- New rule (`rivet_bob.gd`, `rivet_bob.json`): each grid row aims at one figure height (the row's
  mean, held inside what every frame can reach); each frame moves toward it by damp with a height
  factor about the planted feet in `stretch_min` 0.92 .. `stretch_max` 1.12 (tall frames squash,
  short ones stretch), and only a run frame the stretch cannot carry lifts, by at most
  `lift_max_cell` 2.2 (110-space px = 1.49 px at 32 px/m). `damp_run` 0.75 -> 0.9, `damp_walk` 0.7,
  `stretch_cell` 9 removed. damp 0 = the drawn bob before n11.

## Bars (every p70 row, hands and pistol, move and sprint; before -> after)

1. helmet travel per stride <= 3 px: 4-8 -> **1-3** (pass).
2. sole lift max <= 2 px: up to 8 -> **max 1.0** (N rows; card lift 0.89 hands, 1.49 pistol); planted
   <= 0.5: **0.0-0.11** (pass).
3. gap planted <= 2.5: **1.5-2.5** (pass); gap all max <= 3.5: up to 9.5 -> **2.5** (pass).
4. shadow answers: part 2.
5. stretch within 0.92..1.12: **0.920-1.120** every row (code; the 64 px/m eye check is part 2).
6. p55 sprint hands: travel 5-6 -> **1-3**, lift 3 -> **max 1.0** (pass; gap columns are the long
   cast figure, ignore).

## Table

| run | gait | dir | m/s | frames | measured | planted | phase cover | helmet travel px | travel cm | sole lift planted px | sole lift max px | shadow-sole gap planted max | gap planted mean | gap all max | shadow y range | corr shadow/helmet | shadow rx | shadow ry | card lift max px (code) | code vs frame shadow y | stretch max (code) | stretch min (code) | corr shadow rx/card lift (frame) | corr rx/lift (code) | code rx min |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| p70_hands | move | E | 6.7 | 80 | 80 | 80 | 1.0 | 1.0 | 3.1 | 0.0 | 0.0 | 2.0 | 1.66 | 2.0 | 0.5 | 0.051 | 19.5 | 11.3 | 0.0 | 0.35 | 1.037 | 0.954 | None | None | 19.8 |
| p70_hands | move | SE | 6.8 | 80 | 80 | 80 | 1.0 | 2.0 | 6.2 | -0.0 | 0.0 | 1.5 | 1.44 | 1.5 | 1.5 | 0.64 | 18.2 | 10.7 | 0.0 | 0.21 | 1.086 | 0.945 | None | None | 8.91 |
| p70_hands | move | S | 6.7 | 80 | 80 | 80 | 1.0 | 3.0 | 9.4 | -0.0 | 0.0 | 1.5 | 1.5 | 1.5 | 1.0 | 0.558 | 19.5 | 11.5 | 0.0 | 0.18 | 1.076 | 0.928 | None | None | 19.8 |
| p70_hands | move | SW | 6.8 | 80 | 80 | 80 | 1.0 | 3.0 | 9.4 | -0.0 | 0.0 | 2.5 | 2.04 | 2.5 | 2.0 | -0.226 | 19.5 | 11.0 | 0.58 | 0.73 | 1.12 | 0.933 | None | -0.0 | 19.8 |
| p70_hands | move | W | 6.7 | 80 | 80 | 80 | 1.0 | 2.0 | 6.2 | 0.0 | 0.0 | 2.5 | 1.66 | 2.5 | 1.0 | 0.497 | 19.5 | 11.3 | 0.0 | 0.34 | 1.11 | 0.961 | None | None | 19.8 |
| p70_hands | move | NW | 6.8 | 80 | 80 | 80 | 1.0 | 2.0 | 6.2 | -0.0 | 0.0 | 2.5 | 1.75 | 2.5 | 2.0 | 0.684 | 19.5 | 11.2 | 0.0 | 0.43 | 1.068 | 0.947 | None | None | 19.8 |
| p70_hands | move | N | 6.7 | 80 | 80 | 70 | 1.0 | 3.0 | 9.4 | 0.04 | 1.0 | 2.5 | 1.54 | 2.5 | 1.0 | 0.472 | 19.5 | 11.5 | 0.89 | 0.18 | 1.12 | 0.924 | None | 0.0 | 19.8 |
| p70_hands | move | NE | 6.8 | 80 | 80 | 80 | 1.0 | 2.0 | 6.2 | -0.0 | 0.0 | 2.5 | 1.66 | 2.5 | 2.0 | 0.199 | 19.5 | 11.3 | 0.6 | 0.34 | 1.12 | 0.93 | None | 0.0 | 19.8 |
| p70_hands | sprint | E | 9.3 | 80 | 80 | 80 | 1.0 | 1.0 | 3.1 | 0.0 | 0.0 | 2.0 | 1.62 | 2.0 | 0.5 | 0.165 | 19.5 | 11.4 | 0.0 | 0.31 | 1.037 | 0.954 | None | None | 19.8 |
| p70_hands | sprint | SE | 9.3 | 80 | 80 | 80 | 1.0 | 1.0 | 3.1 | 0.0 | 0.0 | 1.5 | 1.44 | 1.5 | 0.5 | 0.356 | 18.3 | 10.8 | 0.0 | 0.21 | 1.086 | 0.945 | None | None | 8.91 |
| p70_hands | sprint | S | 9.3 | 80 | 80 | 80 | 1.0 | 2.0 | 6.2 | 0.0 | 0.0 | 1.5 | 1.5 | 1.5 | 0.0 | None | 19.5 | 11.5 | 0.0 | 0.18 | 1.076 | 0.928 | None | None | 19.8 |
| p70_hands | sprint | SW | 9.3 | 80 | 80 | 80 | 1.0 | 2.0 | 6.2 | 0.0 | 0.0 | 2.5 | 2.04 | 2.5 | 1.0 | -0.781 | 19.5 | 11.0 | 0.58 | 0.72 | 1.12 | 0.933 | None | 0.0 | 19.8 |
| p70_hands | sprint | W | 9.3 | 80 | 80 | 80 | 1.0 | 2.0 | 6.2 | 0.0 | 0.0 | 2.5 | 1.73 | 2.5 | 1.0 | 0.545 | 19.5 | 11.3 | 0.0 | 0.41 | 1.11 | 0.961 | None | None | 19.8 |
| p70_hands | sprint | NW | 9.3 | 80 | 80 | 80 | 1.0 | 1.0 | 3.1 | 0.0 | 0.0 | 2.5 | 1.74 | 2.5 | 1.0 | 0.444 | 19.5 | 11.3 | 0.0 | 0.42 | 1.068 | 0.947 | None | None | 19.8 |
| p70_hands | sprint | N | 9.3 | 80 | 80 | 80 | 1.0 | 2.0 | 6.2 | 0.11 | 1.0 | 2.5 | 1.61 | 2.5 | 0.0 | None | 19.5 | 11.5 | 0.89 | 0.18 | 1.12 | 0.924 | None | -0.0 | 19.8 |
| p70_hands | sprint | NE | 9.3 | 80 | 80 | 80 | 1.0 | 1.0 | 3.1 | 0.0 | 0.0 | 2.5 | 1.69 | 2.5 | 1.0 | -0.556 | 19.5 | 11.3 | 0.6 | 0.38 | 1.12 | 0.93 | None | 0.0 | 19.8 |
| p70_pistol | move | E | 6.7 | 80 | 80 | 80 | 1.0 | 1.0 | 3.1 | 0.0 | 0.0 | 2.0 | 1.62 | 2.0 | 0.5 | -0.173 | 19.5 | 11.4 | 0.0 | 0.31 | 1.039 | 0.947 | None | None | 19.8 |
| p70_pistol | move | SE | 6.8 | 80 | 80 | 80 | 1.0 | 3.0 | 9.4 | -0.0 | 0.0 | 1.5 | 1.41 | 1.5 | 1.5 | 0.567 | 17.7 | 10.4 | 0.0 | 0.22 | 1.085 | 0.944 | None | None | 8.91 |
| p70_pistol | move | S | 6.7 | 80 | 80 | 80 | 1.0 | 2.0 | 6.2 | -0.0 | 0.0 | 1.5 | 1.5 | 1.5 | 1.0 | 0.638 | 19.5 | 11.5 | 0.0 | 0.18 | 1.093 | 0.928 | None | None | 19.8 |
| p70_pistol | move | SW | 6.8 | 80 | 80 | 80 | 1.0 | 3.0 | 9.4 | -0.0 | 0.0 | 2.5 | 2.07 | 2.5 | 2.0 | 0.068 | 19.5 | 10.9 | 0.57 | 0.75 | 1.12 | 0.942 | None | 0.0 | 19.8 |
| p70_pistol | move | W | 6.7 | 80 | 80 | 80 | 1.0 | 2.0 | 6.2 | 0.0 | 0.0 | 2.0 | 1.62 | 2.0 | 0.5 | -0.072 | 19.5 | 11.4 | 0.0 | 0.3 | 1.113 | 0.965 | None | None | 19.8 |
| p70_pistol | move | NW | 6.8 | 80 | 80 | 80 | 1.0 | 3.0 | 9.4 | -0.0 | 0.0 | 2.5 | 1.94 | 2.5 | 2.0 | -0.24 | 19.5 | 11.1 | 0.0 | 0.62 | 1.062 | 0.928 | None | None | 19.8 |
| p70_pistol | move | N | 6.7 | 80 | 80 | 74 | 1.0 | 3.0 | 9.4 | -0.0 | 1.0 | 1.5 | 1.5 | 2.5 | 1.0 | 0.441 | 19.5 | 11.5 | 1.49 | 0.18 | 1.12 | 0.92 | None | 0.0 | 19.8 |
| p70_pistol | move | NE | 6.8 | 80 | 80 | 80 | 1.0 | 2.0 | 6.2 | -0.0 | 0.0 | 2.5 | 1.71 | 2.5 | 2.0 | 0.258 | 19.5 | 11.3 | 0.58 | 0.39 | 1.12 | 0.933 | None | 0.0 | 19.8 |
| p70_pistol | sprint | E | 9.3 | 80 | 80 | 80 | 1.0 | 1.0 | 3.1 | 0.0 | 0.0 | 2.0 | 1.62 | 2.0 | 0.5 | 0.029 | 19.5 | 11.4 | 0.0 | 0.31 | 1.039 | 0.947 | None | None | 19.8 |
| p70_pistol | sprint | SE | 9.3 | 80 | 80 | 80 | 1.0 | 2.0 | 6.2 | 0.0 | 0.0 | 1.5 | 1.44 | 1.5 | 0.5 | 0.321 | 18.3 | 10.8 | 0.0 | 0.21 | 1.085 | 0.944 | None | None | 8.91 |
| p70_pistol | sprint | S | 9.3 | 80 | 80 | 80 | 1.0 | 1.0 | 3.1 | 0.0 | 0.0 | 1.5 | 1.5 | 1.5 | 0.0 | None | 19.5 | 11.5 | 0.0 | 0.18 | 1.093 | 0.928 | None | None | 19.8 |
| p70_pistol | sprint | SW | 9.3 | 80 | 80 | 80 | 1.0 | 2.0 | 6.2 | 0.0 | 0.0 | 2.5 | 2.05 | 2.5 | 1.0 | -0.628 | 19.5 | 10.9 | 0.57 | 0.73 | 1.12 | 0.942 | None | -0.0 | 19.8 |
| p70_pistol | sprint | W | 9.3 | 80 | 80 | 80 | 1.0 | 2.0 | 6.2 | 0.0 | 0.0 | 2.0 | 1.62 | 2.0 | 0.5 | 0.0 | 19.5 | 11.4 | 0.0 | 0.3 | 1.113 | 0.965 | None | None | 19.8 |
| p70_pistol | sprint | NW | 9.3 | 80 | 80 | 80 | 1.0 | 2.0 | 6.2 | 0.0 | 0.0 | 2.5 | 1.93 | 2.5 | 1.0 | -0.772 | 19.5 | 11.1 | 0.0 | 0.61 | 1.062 | 0.928 | None | None | 19.8 |
| p70_pistol | sprint | N | 9.3 | 80 | 80 | 80 | 1.0 | 3.0 | 9.4 | 0.11 | 1.0 | 2.5 | 1.61 | 2.5 | 0.0 | None | 19.5 | 11.5 | 1.49 | 0.18 | 1.12 | 0.92 | None | -0.0 | 19.8 |
| p70_pistol | sprint | NE | 9.3 | 80 | 80 | 80 | 1.0 | 1.0 | 3.1 | 0.0 | 0.0 | 2.5 | 1.86 | 2.5 | 1.0 | -0.491 | 19.5 | 11.1 | 0.58 | 0.55 | 1.12 | 0.933 | None | -0.0 | 19.8 |
| p55_hands | sprint | E | 9.3 | 80 | 80 | 80 | 1.0 | 1.0 | 3.1 | 0.0 | 0.0 | 39.5 | 39.5 | 39.5 | 0.0 | None | 19.5 | 24.5 | 0.0 | 38.14 | 1.097 | 0.96 | None | None | 23.4 |
| p55_hands | sprint | SE | 9.3 | 80 | 80 | 80 | 1.0 | 2.0 | 6.2 | 0.0 | 0.0 | 39.5 | 37.4 | 39.5 | 21.0 | 0.23 | 18.4 | 23.2 | 0.33 | 36.12 | 1.12 | 0.951 | 0.118 | 0.118 | 10.53 |
| p55_hands | sprint | S | 9.3 | 80 | 80 | 80 | 1.0 | 1.0 | 3.1 | 0.0 | 0.0 | 39.5 | 39.5 | 39.5 | 0.0 | None | 19.5 | 24.5 | 0.0 | 38.14 | 1.086 | 0.933 | None | None | 23.4 |
| p55_hands | sprint | SW | 9.3 | 80 | 80 | 80 | 1.0 | 1.0 | 3.1 | 0.0 | 0.0 | 39.5 | 39.5 | 39.5 | 0.0 | None | 19.5 | 24.5 | 0.0 | 38.14 | 1.071 | 0.954 | None | None | 23.4 |
| p55_hands | sprint | W | 9.3 | 80 | 80 | 80 | 1.0 | 1.0 | 3.1 | 0.0 | 0.0 | 39.5 | 39.5 | 39.5 | 0.0 | None | 19.5 | 24.5 | 0.0 | 38.14 | 1.071 | 0.962 | None | None | 23.4 |
| p55_hands | sprint | NW | 9.3 | 80 | 80 | 80 | 1.0 | 2.0 | 6.3 | 0.0 | 0.0 | 39.5 | 39.5 | 39.5 | 0.0 | None | 19.5 | 24.5 | 0.0 | 38.14 | 1.065 | 0.932 | None | None | 23.4 |
| p55_hands | sprint | N | 9.3 | 80 | 80 | 80 | 1.0 | 3.0 | 9.4 | 0.11 | 1.0 | 40.5 | 39.61 | 40.5 | 0.0 | None | 19.5 | 24.5 | 1.53 | 38.14 | 1.12 | 0.92 | None | 0.0 | 23.4 |
| p55_hands | sprint | NE | 9.3 | 80 | 80 | 80 | 1.0 | 1.0 | 3.1 | 0.0 | 0.0 | 39.5 | 39.5 | 39.5 | 0.0 | None | 19.5 | 24.5 | 0.0 | 38.14 | 1.078 | 0.942 | None | None | 23.4 |
