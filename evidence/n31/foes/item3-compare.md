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

## Lever 5: each kind its own gun (b4c, 0fbe651eb) and lever 2 measured on top (b4c, rejected)

`squad.own_weapons` true: patrol cop / SWAT / contractor / robot gunner fire their enemies.json pistol / rifle / cannon
(FoeOwnGun) at `squad.own_weapon_damage` pistol 3 / rifle 2 / cannon 8 Rivet hp per round, instead of the shared
assault-rifle (4 rounds / 0.61 s, 1.2 per round). Lever 2 (`attack_m` patrol 14 -> 20, SWAT 20 -> 26, contractor
15 -> 20) measured on top of lever 5 and NOT kept. Average bot, seeds 1-10, `--waves=7`, live tree holding exactly the
measured setting: `waiting-l5-weapons/`, `waiting-l2-reach/`. Novice not measured.

| metric | main | gait | lever1 | lever5 (kept) | lever5+2 (rejected) |
| --- | --- | --- | --- | --- | --- |
| react in range p50 / p90 s | 1.05 / 6.15 | 1.13 / 6.32 | 0.75 / 4.13 | 0.72 / 3.57 | 1.02 / 4.6 |
| react any distance p50 / p90 s | 3.37 / 8.72 | 3.13 / 9.07 | 2.13 / 6.5 | 1.95 / 6.37 | 1.65 / 6.27 |
| idle share (engaged rule, in range) | 66 % | 70 % | 60 % | 69 % | 67 % |
| idle strict (any distance / in range) | 89 % / 86 % | 92 % / 90 % | 88 % / 85 % | 92 % / 90 % | 91 % / 90 % |
| pressing share | 69 % | 62 % | 65 % | 66 % | 69 % |
| enemies firing / s (ranged alive) | 1.02 (6.4) | 0.66 (6.3) | 0.94 (6.4) | 0.65 (6.7) | 0.77 (6.5) |
| never fired / ranged foes | 173 / 569 | 308 / 570 | 194 / 554 | 219 / 509 | 209 / 572 |
| token share | 25 % | 26 % | 42 % | 39 % | 39 % |
| damage taken w1 / w2 / w3 / w4 mean | 12.5 / 10.6 / 22.6 / 17.2 | 6 / 4 / 15.3 / 13.7 | 8.2 / 8.3 / 31.7 / 29.2 | 11.7 / 7.5 / 27.9 / 7.9 | 10.8 / 8.4 / 19.5 / 18.4 |
| damage taken w1-4 sum | 62.9 | 39 | 77.4 | 55 | 57.1 |
| deaths (runs) / waves 6, 7 reached | 5 (10) / 6, 6 | 4 (10) / 6, 6 | 7 (10) / 6, 5 | 8 (10) / 4, 3 | 5 (10) / 6, 6 |

| bar (average) | lever 1 | lever 5 | lever 5 + 2 |
| --- | --- | --- | --- |
| react in range p50 <= 1.0 s | 0.75: yes | 0.72: **yes** | 1.02: no |
| react in range p90 <= 2.5 s | 4.13: no | 3.57: no | 4.6: no |
| idle share (engaged rule) < 35 % | 60 %: no | 69 %: no | 67 %: no |
| pressing share >= 0.6 | 0.65: yes | 0.66: yes | 0.69: yes |
| guard rail: damage w1-4 in 53.5..72.3 | 77.4: no (over) | 55.0: **yes** (low edge) | 57.1: yes |

Notes (b4c):
- Lever 5 brings the guard rail back (77.4 -> 55.0) and keeps react p50 under 1 s (0.72), p90 down to 3.57. Idle rises
  60 -> 69 %, but the probe (`waiting_engaged.gd` `foe_window`) still judges these foes on the assault-rifle window
  (burst + cooldown + 0.1 s = ~1 s) while a pistol cycle is ~1.9 s and a rifle ~2.1 s, so idle is over-counted for
  own-gun foes; the probe was not changed in this call (re-measure with the own gun's window before quoting idle).
- Lever 2 on top: damage stays in band (57.1) and deaths fall (8 -> 5), but react p50 loses its bar (0.72 -> 1.02) and
  idle moves 2 points: rejected, data reverted (enemies.json at 0fbe651eb).
- Flank check (point 4): the scenario's own counter (FLANK foe within 1 m of its spot) finds 0 arrivals on all five
  probe seeds; the live seed has no FLANK tick; seed 5's flankers (444 flank ticks) get no closer than 2.97 m to a
  spot that moves with Rivet. Recorded in `arena-squad.json`, not judged.
- Gait column re-run from `--rev=f1dfc7492` (e) and levers 4 / share 0.5 / cover_bias not run (time).
- Checks at lever 5 (0fbe651eb) + the flank counter: `node tools/tests/run_scenarios.mjs` 68 passed; `node tools/tests/run_unit.mjs` 4391 passed, 0 failed, 2 skipped. Mutate not run (time).

## b4f: own-gun window, share 0.5 (kept), lever 4 (measured, not kept), final

Columns: lever1 = 8ce3eb779, lever5 = 0fbe651eb (both live tree holding exactly that setting, probe on the shared
assault-rifle window); lever5-ownwin = 1789c3b37 (game code as 0fbe651eb, probe judges own-gun foes on their own
gun's window, b4e d6bacc8ab); share05 = scratch a59258bd4 (1789c3b37 + `max_shooters_share` 0.5, the exact tree of
9b3730e36); share05+lever4 = scratch b43025906 (826d1898c + a token-less ranged foe's strafe ring `attack_m - 1`,
melee unchanged; not on the branch); final = 9b3730e36 (`--rev`, novice + average). The scratch commits are
`git commit-tree` objects for `--rev` only (no branch moved). Old-rev check: the probe at `--rev=ba8e470b0`
compiles and its average seed 1 run file is byte-identical to `waiting-main/runs/average-1.json`.

### average

| metric | main | gait | lever1 | lever5 | lever5-ownwin | share05 | share05+lever4 | final |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| react in range p50 / p90 s | 1.05 / 6.15 | 1.13 / 6.32 | 0.75 / 4.13 | 0.72 / 3.57 | 0.72 / 3.57 | 0.68 / 2.58 | 0.72 / 2.6 | 0.68 / 2.58 |
| react any distance p50 / p90 s | 3.37 / 8.72 | 3.13 / 9.07 | 2.13 / 6.5 | 1.95 / 6.37 | 1.95 / 6.37 | 1.67 / 5.47 | 1.7 / 5.47 | 1.67 / 5.47 |
| idle share (engaged rule, in range) | 66 % | 70 % | 60 % | 69 % | 60 % | 55 % | 54 % | 55 % |
| idle strict (any distance / in range) | 89 % / 86 % | 92 % / 90 % | 88 % / 85 % | 92 % / 90 % | 92 % / 90 % | 92 % / 90 % | 91 % / 90 % | 92 % / 90 % |
| pressing share | 69 % | 62 % | 65 % | 66 % | 71 % | 75 % | 76 % | 75 % |
| enemies firing / s (ranged alive) | 1.02 (6.4) | 0.66 (6.3) | 0.94 (6.4) | 0.65 (6.7) | 0.65 (6.7) | 0.83 (6.6) | 0.76 (6.4) | 0.83 (6.6) |
| never fired / ranged foes | 173 / 569 | 308 / 570 | 194 / 554 | 219 / 509 | 219 / 509 | 160 / 499 | 174 / 517 | 160 / 499 |
| token share | 25 % | 26 % | 42 % | 39 % | 39 % | 47 % | 47 % | 47 % |
| damage taken w1 mean | 12.5 | 6 | 8.2 | 11.7 | 11.7 | 11.7 | 12.9 | 11.7 |
| damage taken w2 mean | 10.6 | 4 | 8.3 | 7.5 | 7.5 | 13.8 | 9.3 | 13.8 |
| damage taken w3 mean | 22.6 | 15.3 | 31.7 | 27.9 | 27.9 | 29.6 | 24.1 | 29.6 |
| damage taken w4 mean | 17.2 | 13.7 | 29.2 | 7.9 | 7.9 | 16.2 | 24.4 | 16.2 |
| damage taken w1-4 sum | 62.9 | 39 | 77.4 | 55 | 55 | 71.3 | 70.7 | 71.3 |
| deaths, all waves incl. 5 (runs) / waves 6, 7 reached | 5 (10) / 6, 6 | 4 (10) / 6, 6 | 7 (10) / 6, 5 | 8 (10) / 4, 3 | 8 (10) / 4, 3 | 7 (10) / 3, 3 | 7 (10) / 4, 3 | 7 (10) / 3, 3 |

### novice

| metric | main | gait | lever1 | lever5 | lever5-ownwin | share05 | share05+lever4 | final |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| react in range p50 / p90 s | 1.32 / 5.6 | 0.75 / 3.38 | - | - | - | - | - | 0.67 / 2.07 |
| react any distance p50 / p90 s | 3.58 / 8.45 | 2.08 / 6.8 | - | - | - | - | - | 1.75 / 5.15 |
| idle share (engaged rule, in range) | 71 % | 61 % | - | - | - | - | - | 58 % |
| idle strict (any distance / in range) | 91 % / 89 % | 90 % / 88 % | - | - | - | - | - | 94 % / 93 % |
| pressing share | 67 % | 69 % | - | - | - | - | - | 66 % |
| enemies firing / s (ranged alive) | 0.99 (6.5) | 1.07 (6.6) | - | - | - | - | - | 0.79 (6.6) |
| never fired / ranged foes | 124 / 441 | 154 / 441 | - | - | - | - | - | 148 / 441 |
| token share | 23 % | 38 % | - | - | - | - | - | 44 % |
| damage taken w1 mean | 17.5 | 10.1 | - | - | - | - | - | 11.4 |
| damage taken w2 mean | 16.1 | 10.4 | - | - | - | - | - | 11.4 |
| damage taken w3 mean | 33.6 | 36.8 | - | - | - | - | - | 37.5 |
| damage taken w4 mean | 26.5 | 22.2 | - | - | - | - | - | 31.7 |
| damage taken w1-4 sum | 93.7 | 79.5 | - | - | - | - | - | 92 |
| deaths, all waves incl. 5 (runs) / waves 6, 7 reached | 10 (10) / 0, 0 | 10 (10) / 1, 0 | - | - | - | - | - | 10 (10) / 0, 0 |


| bar (average) | main | lever5-ownwin | share05 = final | share05+lever4 |
| --- | --- | --- | --- | --- |
| react in range p50 <= 1.0 s | 1.05: no | 0.72: yes | 0.68: **yes** | 0.72: yes |
| react in range p90 <= 2.5 s | 6.15: no | 3.57: no | 2.58: no (0.08 over) | 2.6: no |
| idle share (engaged rule) < 35 % | 66 %: no | 60 %: no | 55 %: no | 54 %: no |
| pressing share >= 0.6 | 0.69: yes | 0.71: yes | 0.75: yes | 0.76: yes |
| guard rail: damage w1-4 in 53.5..72.3 | 62.9: yes | 55.0: yes | 71.3: **yes** (1.0 under the top) | 70.7: yes |

| novice (informational) | main | gait | final |
| --- | --- | --- | --- |
| react in range p50 / p90 s | 1.32 / 5.6 | 0.75 / 3.38 | 0.67 / 2.07 (both bars would hold) |
| idle share (engaged rule) | 71 % | 61 % | 58 % |
| damage w1-4 (rail informational) | 93.7 | 79.5 | 92.0 (main -1.7) |
| deaths (runs) / waves 6, 7 reached | 10 (10) / 0, 0 | 10 (10) / 1, 0 | 10 (10) / 0, 0 |

Notes (b4f, 2026-11-26):
- Own-gun window (STEP 0): same runs as lever 5 (react, damage, never fired identical), only the engaged rule moved:
  idle 69 % -> 60 %, pressing 66 % -> 71 %. The lever-5 idle rise was the probe's assault-rifle window.
- Share 0.5 kept: p90 3.57 -> 2.58, idle 60 -> 55 %, firing/s 0.65 -> 0.83, never fired 219 -> 160, damage 55.0 -> 71.3
  (deaths in waves 1-4 + 6-7: 3 -> 1 of 10; all waves incl. 5: 8 -> 7). The rail has 1.0 left: any further lever that
  adds fire breaks it. Final (9b3730e36) reproduces share05 exactly (same tree).
- Lever 4 on top of share 0.5: every number within noise (p50 0.68 -> 0.72, p90 2.58 -> 2.6, idle 55 -> 54 %, damage
  71.3 -> 70.7); no bar crosses, and landing it needs a `squad.waiting_ring` schema field (not this lane's file). Not kept.
- Still failing on the average bot: idle 55 % (bar < 35 %) and p90 2.58 s (bar 2.5). Idle is foes with a clear line in
  range and no token (token share 47 %); closing it needs more tokens, which the rail no longer allows, or a rail move:
  owner's call.
