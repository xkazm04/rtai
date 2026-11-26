# n31 ghost 13: Ohm (and Kerf) play measure with a relaxed bot fit, main | HEAD; Tonnage bond per wave

Builder `g13-ohm-play`, 2026-11-26. main = `ba8e470b0` (temp worktree `gtai-wt/g13-main`, dev files copied in, removed after), HEAD = `649a17523`
(g12 part 0: Ohm `press_mode drop`, radius 3.5 -> 5, charge 18 ticks, life 66). Play, profile average, 10 seeds, `--waves=3` (Tonnage bond: `--waves=8`).
The shipped `GhostDeployBot` never deploys Ohm or Kerf in early waves (g08), so the bot's spot scorer is swapped for the dev
`GhostN31BotSpot` (`--fit=relaxed`): Ohm fires when 3+ bodies sit inside his circle (shipped: 2+ machines or a sentry turret), Kerf fires at any target
(shipped: tier 3+, shield_robot, war_machine). Tonnage and Dent keep the shipped rules. The strike is the real one.
Table labels say "(main)" on HEAD rows too: that is the tool's "no --radius = shipped footprint" flag, not the revision. The rev is in the file name.

## Ohm play (relaxed fit, 10 seeds x 3 waves)
| side | deploys | mean hits | median hits | mean kills | mean near (<= 9 m) | share hit | zero-hit | key-down->damage ticks (median) |
|---|---|---|---|---|---|---|---|---|
| main r3.5, hold | 42 | 2.98 | 3 | 2.98 | 5.76 | 52% | 1 | 1 |
| HEAD r5, drop | 41 | 3.71 | 3 | 3.71 | 5.41 | 68% | 0 | 18 |

- Per deploy a player's Ohm now takes out 3.7 foes instead of 3.0 (+25 %), and he reaches 68 % of the cops within 9 m instead of 52 %; he never whiffs (0 of 41 hit nobody, main 1 of 42).
- The delay from key to damage is the 18-tick charge (0.3 s): every release now lands 0.3 s after the press, where main hit on the release tick.
- Per seed (HEAD): hits 3.3 3.6 3.2 3.8 3.7 5.0 3.8 4.0 3.3 3.8, share 48..91 %; per-seed rows for both sides are in the JSON.

## Kerf play (relaxed fit, 10 seeds x 3 waves): the before for the Kerf item
| side | deploys | mean hits | median hits | mean kills | mean near | share hit | zero-hit | key-down->damage ticks (median) |
|---|---|---|---|---|---|---|---|---|
| main | 60 | 1 | 1 | 1 | 4.13 | 24% | 0 | 1 |
| HEAD (control, Kerf unchanged) | 60 | 1 | 1 | 1 | 4.13 | 24% | 0 | 1 |

- One Kerf cut kills exactly one foe (60 of 60 deploys), instant on the release; main and HEAD are identical, so the bot and the sim are stable between the two builds (a clean control).

## Tonnage bond (10 seeds x 8-wave cap, shipped bot; bond = 4 per kill, bar 70, no stuns logged)
| side | deploys | mean kills / deploy | share hit | key-down->damage | bond per deploy | bond per wave (all runs) | mean bond per run | runs reaching 70 | mastery wave (median; each run) |
|---|---|---|---|---|---|---|---|---|---|
| main (half r4 stomp) | 106 | 2.33 | 58 % | 1 | 9.3 | 13.7 | 98.8 | 9 of 10 | 4 (3 7 4 3 3 3 7 6 4) |
| HEAD (full circle r6.5, 27-tick charge) | 109 | 3.39 | 80 % | 27 | 13.5 | 20.2 | 147.6 | 9 of 10 | 3 (3 4 2 4 3 4 3 4 3) |

- The bigger circle does inflate bond: +45 % per deploy (9.3 -> 13.5), so Tonnage reaches mastery 70 about one wave earlier (median wave 4 -> 3; the slowest run 7 -> 4). Deploy count is unchanged (106 vs 109), the gain is all kills per deploy.
- Meaning for a player: with the shipped kill-based bond, the free Tonnage mastery card arrives around wave 3 instead of wave 4. To keep mastery where it was, the bar (`master_at_by_form` tonnage 70) would need to be about 100 (70 x 1.45), or per_kill scaled for his dump; measure only, nothing changed.
- Wave = `run.wave` at the deploy's release (stamped by the dev play loop).

## Proposed decisions line (director adds it)
`- [2026-11-26] DECISION ghost-ohm: play measure (relaxed bot fit, avg profile, 10 seeds x 3 waves): Ohm main r3.5 hold hits 2.98 of 5.76 near (52 %), HEAD r5 drop 3.71 of 5.41 (68 %), zero-hit 1 -> 0, key-down to damage 1 -> 18 ticks; Kerf 1 kill per cut, unchanged (60 deploys both). Tonnage bond per deploy 9.3 -> 13.5 (+45 %), mastery 70 median wave 4 -> 3: the bigger circle speeds mastery by a wave; raising the bar to ~100 would restore it (owner call).`

## Commands
```
export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/ghost GODOT_BIN=<gtai-spike>/tools/godot/Godot_v4.7.2-stable_win64_console.exe
R=C:/Users/kazda/kiro/gtai-wt/g13-main   # git worktree at ba8e470b0 + dev/ghost_n31 (no beats/take) + native DLLs
node tools/ghost/deploy_measure.mjs --mode=play --form=ohm    --fit=relaxed --seeds=10 --waves=3 --root=$R --tag=main-ohm-relaxed
node tools/ghost/deploy_measure.mjs --mode=play --form=kerf   --fit=relaxed --seeds=10 --waves=3 --root=$R --tag=main-kerf-relaxed
node tools/ghost/deploy_measure.mjs --mode=play --form=tonnage --bond --seeds=10 --waves=8        --root=$R --tag=main-ton-w8
node tools/ghost/deploy_measure.mjs --mode=play --form=ohm    --fit=relaxed --seeds=10 --waves=3 --tag=head-ohm-relaxed
node tools/ghost/deploy_measure.mjs --mode=play --form=tonnage --bond --seeds=10 --waves=8        --tag=head-ton-w8
node tools/ghost/deploy_measure.mjs --mode=play --form=kerf   --fit=relaxed --seeds=10 --waves=3 --tag=head-kerf-relaxed
```
JSON (copies of `build/n31/ghost/measure-<rev>-play-<tag>.json`): `evidence/n31/ghost/measure-ba8e470b0-play-main-{ohm,kerf}-relaxed.json`,
`measure-ba8e470b0-play-main-ton-w8.json`, `measure-649a17523-play-head-{ohm,kerf}-relaxed.json`, `measure-649a17523-play-head-ton-w8.json`.
Not run: Ohm/Kerf at 8 waves, other profiles; the bond counts kills only (the dump logs no stuns).
