# n31 ghost 01: Tonnage deploy measured on main (`ba8e470b0`)

Builder `g01-measure`, 2026-11-25. Every number comes from a temp worktree at `ba8e470b0` with only
`project/dev/ghost_n31` and `tools/ghost` copied in, because g02-drop's uncommitted souls edits sit in
the lane worktree. Numbers from the lane worktree were thrown away. The tool is `tools/ghost/deploy_measure.mjs`, which runs
`res://dev/ghost_n31/ghost_measure.tscn` through `tools/dev/run.mjs`. The JSON for each run sits next to this file
(`measure-ba8e470b0-<mode>-<tag>.json`).

**A deploy on an 8-cop cluster hits 4.3 of 8 on main** (lab: mean 4.33, median 4, 54 % of the group, 15
real gauntlet shapes). A 12-cop cluster loses 5.2 of 12 (44 %). In real play the average bot's 106 Tonnage
deploys over 10 seeds hit 2.80 foes on average and 3 at the median, and killed 2.33. Two of those deploys hit nobody.
The shipped half-disc, 4 m around the spot plus 0.9 m ahead, behind-the-spot foes excluded, reaches about
half a real group. The same 4 m as a full circle at the spot (victim radius added) already gives 64 % on 8.
A full circle of 5.5 m at the spot gives 83 %, of 6 m gives 88 %, and of 6.5 m gives 92 %. A circle centred on Rivet at the press tick is
weak at every radius: in the sampled gauntlet moments Rivet stands a median 7.1 m from the 8-cluster's
centroid, so 6 m on Rivet hits 35 % of 8, and in play the at=rivet circle hits nobody on 22 of 54 deploys.
Caveat: in play the bot still picks WHEN to deploy with the shipped spot search (3+ bodies under a spot
up to 6 m away), not with a drop-on-Rivet rule.

## Method

- **lab**: `project/dev/ghost_n31/shapes.json` holds 15 / 15 / 13 cluster shapes of 4 / 8 / 12 foes. They were
  sampled from 10 gauntlet seeds (profile `average`, 8 waves) every 60 ticks at which
  `GhostDeployBotSpot.best(tonnage, ..., require_fit=true)` would drop Tonnage. Each shape is the densest N live
  foes within 14 m of Rivet, stored as offsets from their centroid, plus Rivet's own offset. For every shape a fresh open-floor
  ArenaStage gets patrol cops (1 hp) at the shape and Rivet at the sampled stand-off. The cursor is the best of
  every heading and reach the input word encodes, scored with the footprint under test. On main this is the
  bot's own `_score`, and the swept "half r4" row reproduces the real-code row exactly. The deploy key
  is pressed for one tick and released through the real input path, and `GhostDeployStrike.land` resolves it.
  `GhostN31Strike` (a subclass) only replaces `_tonnage`'s footprint for the what-ifs.
- **play**: 10 gauntlet seeds 1..10 in ONE Godot process, the shipped test player `GauntletTestPlayer`
  with profile `average`. The bot profiles in `data/tables/test_player.json` are novice, average and expert, and average has
  form_use 0.55. In the gauntlet, Tonnage is locked until its ghost bonus card is taken at a rest
  (`GauntletSession` sets each form's unlock = its id, `GauntletBonusApply` "ghost" adds it to
  `GhostLocks.done`). The play mode grants it at the start the same way, `locks.done = [tonnage]`, and keeps it the only
  free ghost and the selected one, so the shipped `GhostDeployBot` drops it whenever it is off cooldown, the
  wave is live and its spot search finds 3 or more bodies. The cap is 8 waves (`--waves=8`). Seeds 3, 4 and 7 died at waves 5, 6 and 5.
  The what-if play runs use 3 waves for time, with their own main baseline at 3 waves.
- **key-down to damage**: ticks from the tick the ghost enters AIMING (key down) to the tick the hits land.

## Hold time of a press on main (the aiming step)

- `GhostDeployBot` (the gauntlet bot): holds the number key **1 tick**. It presses on tick t (`_try_deploy` sets
  `_held_spot`) and releases on t+1 (`steer` clears it), so release and damage come 1 tick (16.7 ms) after key down.
  Every lab and play row shows 1.
- `dev/ghost-forms/ghost_deploy_film_input.gd` (the deploy film's scripted "human" press): holds
  `ghost_deploy` for **54 ticks (0.9 s)** for a single form such as Tonnage (`placing` = age in [RELEASE-54, RELEASE),
  RELEASE = 108), or 84 ticks (1.4 s) in the all-forms reel. Damage lands on the release tick.
- `tools/film/owner_cursor.gd` models only the mouse cursor and the weapon wheel. It never presses a deploy key.
- On main the strike resolves on release with no charge, so key-down-to-damage equals the hold, which is 1 tick for
  the bot and 54 ticks for the film's human-like press.

## Lab, main as shipped (real GhostDeployStrike.land)

| footprint | group | shapes | mean hits | median | mean kills | share hit | zero-hit | key-down->damage |
|---|---|---|---|---|---|---|---|---|
| half r4 at spot (main) | 4 cops | 15 | 3.13 | 3 | 3.13 | 78% | 1 | 1 |
| half r4 at spot (main) | 8 cops | 15 | 4.33 | 4 | 4.33 | 54% | 0 | 1 |
| half r4 at spot (main) | 12 cops | 13 | 5.23 | 5 | 5.23 | 44% | 0 | 1 |

## Lab sweep (GhostN31Strike what-if footprint; "half r4" reproduces main exactly)

| footprint | group | shapes | mean hits | median | mean kills | share hit | zero-hit | key-down->damage |
|---|---|---|---|---|---|---|---|---|
| half r4 at spot | 4 cops | 15 | 3.13 | 3 | 3.13 | 78% | 1 | 1 |
| half r4 at spot | 8 cops | 15 | 4.33 | 4 | 4.33 | 54% | 0 | 1 |
| half r4 at spot | 12 cops | 13 | 5.23 | 5 | 5.23 | 44% | 0 | 1 |
| full r4 at spot | 4 cops | 15 | 3.33 | 4 | 3.33 | 83% | 1 | 1 |
| full r4 at spot | 8 cops | 15 | 5.13 | 5 | 5.13 | 64% | 0 | 1 |
| full r4 at spot | 12 cops | 13 | 7.77 | 7 | 7.77 | 65% | 0 | 1 |
| full r4 at rivet | 4 cops | 15 | 0.47 | 0 | 0.47 | 12% | 10 | 1 |
| full r4 at rivet | 8 cops | 15 | 1.13 | 1 | 1.13 | 14% | 7 | 1 |
| full r4 at rivet | 12 cops | 13 | 3.08 | 3 | 3.08 | 26% | 0 | 1 |
| half r5 at spot | 4 cops | 15 | 3.53 | 4 | 3.53 | 88% | 0 | 1 |
| half r5 at spot | 8 cops | 15 | 5.27 | 5 | 5.27 | 66% | 0 | 1 |
| half r5 at spot | 12 cops | 13 | 6.62 | 7 | 6.62 | 55% | 0 | 1 |
| full r5 at spot | 4 cops | 15 | 3.67 | 4 | 3.67 | 92% | 0 | 1 |
| full r5 at spot | 8 cops | 15 | 6.07 | 6 | 6.07 | 76% | 0 | 1 |
| full r5 at spot | 12 cops | 13 | 9.31 | 9 | 9.31 | 78% | 0 | 1 |
| full r5 at rivet | 4 cops | 15 | 0.93 | 1 | 0.93 | 23% | 7 | 1 |
| full r5 at rivet | 8 cops | 15 | 1.87 | 2 | 1.87 | 23% | 4 | 1 |
| full r5 at rivet | 12 cops | 13 | 4.15 | 4 | 4.15 | 35% | 0 | 1 |
| half r5.5 at spot | 4 cops | 15 | 3.67 | 4 | 3.67 | 92% | 0 | 1 |
| half r5.5 at spot | 8 cops | 15 | 5.53 | 5 | 5.53 | 69% | 0 | 1 |
| half r5.5 at spot | 12 cops | 13 | 7.15 | 7 | 7.15 | 60% | 0 | 1 |
| full r5.5 at spot | 4 cops | 15 | 3.80 | 4 | 3.80 | 95% | 0 | 1 |
| full r5.5 at spot | 8 cops | 15 | 6.60 | 7 | 6.60 | 82% | 0 | 1 |
| full r5.5 at spot | 12 cops | 13 | 10.08 | 10 | 10.08 | 84% | 0 | 1 |
| full r5.5 at rivet | 4 cops | 15 | 1.07 | 1 | 1.07 | 27% | 7 | 1 |
| full r5.5 at rivet | 8 cops | 15 | 2.40 | 2 | 2.40 | 30% | 2 | 1 |
| full r5.5 at rivet | 12 cops | 13 | 4.38 | 4 | 4.38 | 37% | 0 | 1 |
| half r6 at spot | 4 cops | 15 | 3.73 | 4 | 3.73 | 93% | 0 | 1 |
| half r6 at spot | 8 cops | 15 | 5.80 | 6 | 5.80 | 72% | 0 | 1 |
| half r6 at spot | 12 cops | 13 | 7.77 | 8 | 7.77 | 65% | 0 | 1 |
| full r6 at spot | 4 cops | 15 | 3.80 | 4 | 3.80 | 95% | 0 | 1 |
| full r6 at spot | 8 cops | 15 | 7 | 7 | 7 | 88% | 0 | 1 |
| full r6 at spot | 12 cops | 13 | 10.69 | 11 | 10.69 | 89% | 0 | 1 |
| full r6 at rivet | 4 cops | 15 | 1.40 | 1 | 1.40 | 35% | 5 | 1 |
| full r6 at rivet | 8 cops | 15 | 2.80 | 2 | 2.80 | 35% | 1 | 1 |
| full r6 at rivet | 12 cops | 13 | 5.15 | 5 | 5.15 | 43% | 0 | 1 |
| half r6.5 at spot | 4 cops | 15 | 3.87 | 4 | 3.87 | 97% | 0 | 1 |
| half r6.5 at spot | 8 cops | 15 | 6.07 | 6 | 6.07 | 76% | 0 | 1 |
| half r6.5 at spot | 12 cops | 13 | 8.38 | 8 | 8.38 | 70% | 0 | 1 |
| full r6.5 at spot | 4 cops | 15 | 3.80 | 4 | 3.80 | 95% | 0 | 1 |
| full r6.5 at spot | 8 cops | 15 | 7.33 | 8 | 7.33 | 92% | 0 | 1 |
| full r6.5 at spot | 12 cops | 13 | 11.23 | 12 | 11.23 | 94% | 0 | 1 |
| full r6.5 at rivet | 4 cops | 15 | 1.80 | 2 | 1.80 | 45% | 4 | 1 |
| full r6.5 at rivet | 8 cops | 15 | 3.33 | 3 | 3.33 | 42% | 1 | 1 |
| full r6.5 at rivet | 12 cops | 13 | 5.77 | 5 | 5.77 | 48% | 0 | 1 |
| half r7 at spot | 4 cops | 15 | 4 | 4 | 4 | 100% | 0 | 1 |
| half r7 at spot | 8 cops | 15 | 6.47 | 6 | 6.47 | 81% | 0 | 1 |
| half r7 at spot | 12 cops | 13 | 8.85 | 9 | 8.85 | 74% | 0 | 1 |
| full r7 at spot | 4 cops | 15 | 3.93 | 4 | 3.93 | 98% | 0 | 1 |
| full r7 at spot | 8 cops | 15 | 7.47 | 8 | 7.47 | 93% | 0 | 1 |
| full r7 at spot | 12 cops | 13 | 11.54 | 12 | 11.54 | 96% | 0 | 1 |
| full r7 at rivet | 4 cops | 15 | 1.87 | 2 | 1.87 | 47% | 4 | 1 |
| full r7 at rivet | 8 cops | 15 | 3.87 | 4 | 3.87 | 48% | 0 | 1 |
| full r7 at rivet | 12 cops | 13 | 6.69 | 5 | 6.69 | 56% | 0 | 1 |

## Play, main as shipped, 10 seeds x up to 8 waves (profile average)

| footprint | seeds | deploys | mean hits | median | mean kills | zero-hit | key-down->damage |
|---|---|---|---|---|---|---|---|
| half r4 at spot (main) | seed 1 | 10 | 3.20 | 3 | 2.80 | 0 | 1 |
| half r4 at spot (main) | seed 2 | 10 | 2.20 | 2.50 | 2 | 1 | 1 |
| half r4 at spot (main) | seed 3 | 9 | 2.67 | 3 | 2.44 | 0 | 1 |
| half r4 at spot (main) | seed 4 | 10 | 3.10 | 3 | 2.60 | 0 | 1 |
| half r4 at spot (main) | seed 5 | 12 | 2.75 | 3 | 2.33 | 0 | 1 |
| half r4 at spot (main) | seed 6 | 10 | 3.50 | 3 | 3 | 0 | 1 |
| half r4 at spot (main) | seed 7 | 7 | 2.57 | 3 | 2.43 | 1 | 1 |
| half r4 at spot (main) | seed 8 | 11 | 2.45 | 3 | 1.73 | 0 | 1 |
| half r4 at spot (main) | seed 9 | 12 | 2.92 | 3 | 2.08 | 0 | 1 |
| half r4 at spot (main) | seed 10 | 15 | 2.67 | 3 | 2.13 | 0 | 1 |
| half r4 at spot (main) | total | 106 | 2.80 | 3 | 2.33 | 2 | 1 |

## Play, main as shipped, 10 seeds x 3 waves (the what-if baseline)

| footprint | seeds | deploys | mean hits | median | mean kills | zero-hit | key-down->damage |
|---|---|---|---|---|---|---|---|
| half r4 at spot (main) | total | 48 | 3.21 | 3 | 3.21 | 0 | 1 |

## Play what-if: full circle at the bot spot, 10 seeds x 3 waves

| footprint | seeds | deploys | mean hits | median | mean kills | zero-hit | key-down->damage |
|---|---|---|---|---|---|---|---|
| full r5 at spot | total | 43 | 3.74 | 3 | 3.74 | 0 | 1 |
| full r5.5 at spot | total | 43 | 3.86 | 4 | 3.86 | 0 | 1 |
| full r6 at spot | total | 38 | 4.29 | 4 | 4.29 | 0 | 1 |
| full r6.5 at spot | total | 37 | 4.43 | 4 | 4.43 | 0 | 1 |

## Play what-if: full circle on Rivet at the press tick, 10 seeds x 3 waves

| footprint | seeds | deploys | mean hits | median | mean kills | zero-hit | key-down->damage |
|---|---|---|---|---|---|---|---|
| full r5 at rivet | total | 50 | 1.06 | 0.50 | 1.06 | 25 | 1 |
| full r5.5 at rivet | total | 54 | 1.17 | 1 | 1.17 | 25 | 1 |
| full r6 at rivet | total | 54 | 1.22 | 1 | 1.22 | 22 | 1 |
| full r6.5 at rivet | total | 49 | 1.67 | 1 | 1.67 | 17 | 1 |

## Play what-if: full circle r6, hits resolved 27 ticks after the press, 10 seeds x 3 waves

| footprint | seeds | deploys | mean hits | median | mean kills | zero-hit | key-down->damage |
|---|---|---|---|---|---|---|---|
| full r6 at spot charge 27 | total | 38 | 4.13 | 4 | 4.13 | 0 | 27 |
| full r6 at rivet charge 27 | total | 53 | 1.42 | 1 | 1.42 | 22 | 27 |
