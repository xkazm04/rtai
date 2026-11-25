# Foes waiting: compare (n31)

Columns: main = ba8e470b0fdfc796c4eb8d256bd086d4d7cfa969; gait = f1dfc7492 (live tree; game code as 19cb2decd, item 2 FoeGait split). Ranged kinds, waves 1-4 + 6-7 unless the row names waves.

## average

| metric | main | gait |
| --- | --- | --- |
| react in range p50 / p90 s | 1.05 / 6.15 | 1.13 / 6.32 |
| react any distance p50 / p90 s | 3.37 / 8.72 | 3.13 / 9.07 |
| idle share (engaged rule, in range) | 66 % | 70 % |
| idle strict (any distance / in range) | 89 % / 86 % | 92 % / 90 % |
| pressing share | 69 % | 62 % |
| enemies firing / s (ranged alive) | 1.02 (6.4) | 0.66 (6.3) |
| never fired / ranged foes | 173 / 569 | 308 / 570 |
| token share | 25 % | 26 % |
| damage taken w1 mean | 12.5 | 6 |
| damage taken w2 mean | 10.6 | 4 |
| damage taken w3 mean | 22.6 | 15.3 |
| damage taken w4 mean | 17.2 | 13.7 |
| damage taken w1-4 sum | 62.9 | 39 |
| deaths, all waves incl. 5 (runs) / waves 6, 7 reached | 5 (10) / 6, 6 | 4 (10) / 6, 6 |

## novice

| metric | main | gait |
| --- | --- | --- |
| react in range p50 / p90 s | 1.32 / 5.6 | 0.75 / 3.38 |
| react any distance p50 / p90 s | 3.58 / 8.45 | 2.08 / 6.8 |
| idle share (engaged rule, in range) | 71 % | 61 % |
| idle strict (any distance / in range) | 91 % / 89 % | 90 % / 88 % |
| pressing share | 67 % | 69 % |
| enemies firing / s (ranged alive) | 0.99 (6.5) | 1.07 (6.6) |
| never fired / ranged foes | 124 / 441 | 154 / 441 |
| token share | 23 % | 38 % |
| damage taken w1 mean | 17.5 | 10.1 |
| damage taken w2 mean | 16.1 | 10.4 |
| damage taken w3 mean | 33.6 | 36.8 |
| damage taken w4 mean | 26.5 | 22.2 |
| damage taken w1-4 sum | 93.7 | 79.5 |
| deaths, all waves incl. 5 (runs) / waves 6, 7 reached | 10 (10) / 0, 0 | 10 (10) / 1, 0 |


## Bars (brief b4, average bot, ranged kinds, waves 1-4 + 6-7)

| bar | main | gait (item 2 alone) |
| --- | --- | --- |
| react in range p50 <= 1.0 s | 1.05: no | 1.13: no |
| react in range p90 <= 2.5 s | 6.15: no | 6.32: no |
| idle share (engaged rule) < 35 % | 66 %: no | 70 %: no |
| pressing share >= 0.6 | 0.69: yes | 0.62: yes (barely) |
| guard rail: damage w1-4 sum in 53.5..72.3 | 62.9: yes (the anchor) | 39.0: **no**, 38 % under |

Notes (b4a, 2026-11-25):
- The engaged rule (`project/dev/foes_n31/waiting_engaged.gd`) counts a foe as engaged for burst + cooldown + 0.1 s
  after a round of the weapon it fires, while it winds up, fires or bursts, and in the FoeGait settle window. Main's
  strict columns came out identical to b1's BEFORE (89 % / 86 %, react 1.05 / 6.15, never fired 173, damage per
  wave), so the probe stayed read-only and the runs are reproducible.
- Engaged idle at main is still 66 %: the cooldown was only part of the "waiting"; most of it is foes with a clear
  line in range and no token (token share 25 %, `max_shooters` 2).
- Item 2 alone (FoeGait split) makes the average bot's foes fire less: firing/s 1.02 -> 0.66, never fired
  173 -> 308 of ~570, damage w1-4 62.9 -> 39.0. It breaks the guard rail before any Part B lever; the Part B levers
  (more shooters, longer attack_m) push the other way. Novice moves the other way (react 1.32 -> 0.75 s,
  firing/s 0.99 -> 1.07, damage sum 93.7 -> 79.5): the two bots differ, so read both before a lever lands.
- Pressing share is already >= 0.6 at both: at main every ranged foe has the one legacy gait, so any approach at
  > 0.5 m/s counts. It is a weak bar on its own; idle share and react p90 are the ones far off.

## Lever 1: shooter slots as a share (b4b, 8ce3eb779)

`squad.max_shooters_share` 0.35, `max_shooters_min` 3: ranged tokens = max(3, ceil(0.35 x ranged alive)) instead of
the fixed 2 (rockets stay on `max_shooters` 2; a stage that writes its own `max_shooters`, the prologue and the arena
pit rules, keeps its fixed cap). Average bot, seeds 1-10, `--waves=7`: `evidence/n31/foes/waiting-l1-shooters/`.
Novice not measured for lever 1.

### average (lever 1 = 8ce3eb779)

| metric | main | gait | lever1 |
| --- | --- | --- | --- |
| react in range p50 / p90 s | 1.05 / 6.15 | 1.13 / 6.32 | 0.75 / 4.13 |
| react any distance p50 / p90 s | 3.37 / 8.72 | 3.13 / 9.07 | 2.13 / 6.5 |
| idle share (engaged rule, in range) | 66 % | 70 % | 60 % |
| idle strict (any distance / in range) | 89 % / 86 % | 92 % / 90 % | 88 % / 85 % |
| pressing share | 69 % | 62 % | 65 % |
| enemies firing / s (ranged alive) | 1.02 (6.4) | 0.66 (6.3) | 0.94 (6.4) |
| never fired / ranged foes | 173 / 569 | 308 / 570 | 194 / 554 |
| token share | 25 % | 26 % | 42 % |
| damage taken w1 mean | 12.5 | 6 | 8.2 |
| damage taken w2 mean | 10.6 | 4 | 8.3 |
| damage taken w3 mean | 22.6 | 15.3 | 31.7 |
| damage taken w4 mean | 17.2 | 13.7 | 29.2 |
| damage taken w1-4 sum | 62.9 | 39 | 77.4 |
| deaths, all waves incl. 5 (runs) / waves 6, 7 reached | 5 (10) / 6, 6 | 4 (10) / 6, 6 | 7 (10) / 6, 5 |

| bar (average) | main | gait | lever 1 |
| --- | --- | --- | --- |
| react in range p50 <= 1.0 s | 1.05: no | 1.13: no | 0.75: **yes** |
| react in range p90 <= 2.5 s | 6.15: no | 6.32: no | 4.13: no |
| idle share (engaged rule) < 35 % | 66 %: no | 70 %: no | 60 %: no |
| pressing share >= 0.6 | 0.69: yes | 0.62: yes | 0.65: yes |
| guard rail: damage w1-4 sum in 53.5..72.3 | 62.9: yes | 39.0: no (under) | 77.4: **no, 23 % over** (w3 31.7, w4 29.2) |

Notes (b4b):
- Lever 1 breaks the guard rail upward (77.4 vs 72.3 max) while idle is still 60 %: more foes hold a token (42 % vs
  26 %) but most token-less ones still wait. Kept on HEAD because the per-kind weapon lever (b4c lever 5: each kind its
  own, weaker or slower gun) is planned; lever 2 (`attack_m` up) was NOT run: it would push damage further over.
- **gait column caveat**: b4b's lever 1 files were in this worktree from about 22:58:30 to 23:01:51 while b4a's gait
  run read the live tree (gait runs `novice-3` .. `novice-10` finished 22:58:43 .. 23:01:27, `average-1` 23:01:42,
  `average-2` 23:01:55). Those runs may carry lever 1 (the novice gait token share 38 % vs main 23 % fits that). Re-run
  the gait novice seeds 3-10 and average 1-2 from `--rev=f1dfc7492` (game code as 19cb2decd) before quoting the gait novice column.
