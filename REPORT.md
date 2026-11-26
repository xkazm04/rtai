# REPORT lane foes, run n31 (2026-11-25 night)

Branch `n31-foes`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, cut from `main` `ba8e470b0`.
Final game setting: `9b3730e36` (DRAFT: updated at the end if b4j keeps a setting).
Films: `C:\Users\kazda\kiro\gtai-masters\n31\foes\` (`frames.json`, best first).
Gate: (pending, slot ~06:25).

## What a player now meets when a wave starts (item 4 paragraph)

(DRAFT, finished after the wave 3/6 takes and the 64 px/m stalk clip.) On main, wave 1's thirteen patrol cops
spread out 10 to 12 m from Rivet, most of them crouch behind boxes or circle, and only two may shoot at a time:
you walk at a crowd that mostly watches you. On the final setting, half of the ranged cops alive hold a gun token
(at least 3), each fires its own pistol in short 2-round bursts instead of the shared assault rifle, and a cop that
sees you in range opens fire after a median 0.68 s instead of 1.05 s (p90 2.58 s instead of 6.15 s). A cop that is
firing walks slowly (45 % of its speed) and backs off facing you; a cop you rush inside 4 m stops shooting and runs.

## What works

| item | evidence | the number (average bot, seeds 1-10, waves 1-4 + 6-7, wheel controls) |
| --- | --- | --- |
| 1 measure the waiting | `tools/gauntlet/waiting.mjs` + probe (5e081baa5, 214602c88, f1dfc7492), `evidence/n31/foes/waiting-main/waiting.md` | main: react in range p50/p90 1.05/6.15 s, idle share 66 % (engaged rule; strict 89 %), cops shoot from a median 9.0 m though they see 24 m, 173 of 569 ranged foes never fired, 1.02 foes firing per second with 6.4 alive |
| 2 two movement types | `project/features/combat/squad/foe_gait.gd`, `foe_gait_drive.gd` (a4a7a3537, 09d6abdba, 7dfba0b0f); mutate foe_gait.gd 20/20 | FIGHT = 0.45 x speed, faces Rivet, the only state that may fire; TRAVEL = full speed (panic x1.6), no fire; urgent inside 4 m; hold 0.6 s; settle 0.25 s. Clip: (pending b4h gait64_stalk) |
| 3 they open fire | `evidence/n31/foes/item3-compare.md`, `waiting-final/` | react p50 1.05 -> 0.68 s (bar <= 1.0: holds), p90 6.15 -> 2.58 s (bar 2.5: 0.08 over), idle 66 -> 55 % (bar < 35 %: fails), never fired 173 -> 160 of ~500, damage w1-4 62.9 -> 71.3 (rail 53.5..72.3 holds) |
| 4 re-measure and film | `wave1_side` (3519f232e), wave 3/6 (pending b4i), `gait64_stalk` (pending b4h) | wave 1 seed 3: foes that fired per second 0.63 -> 0.93 with fewer alive (9.2 -> 7.1) |

## What does not

- Idle share 55 % (bar < 35 %): the remaining idle is foes in range without a token (token share 47 %); more
  tokens at today's round damage break the damage rail (DRAFT: b4j tries more tokens with weaker rounds).
- React p90 2.58 s (bar 2.5 s).

## What blocked or slowed you (minutes each)

- FRICTION builders-share-live-tree 10 (session 2): a measuring builder read the live tree while another edited it.
- FRICTION machine-load 8 (session 3): `waiting.mjs --check` silent for 8 min under other lanes' Godot runs.
- 64 px/m gait clip: the killing bot and nearest-cop camera could not show one cop's two moves (b4g, 8 min); a
  scripted stalk input was needed (b4h).

## Calls for the owner

1. Fight-move speed share 0.45 of `speed_mps` (`enemies.json` `fight_speed_k`): (clip pending).
2. Simultaneous shooters: fixed 2 -> `max(3, ceil(0.5 x ranged alive))` (`squad.max_shooters_share`).
3. Each kind its own gun (pistol / rifle / cannon, `squad.own_weapons`) against the shared assault rifle: damage
   w1-4 77.4 -> 55.0 at share 0.35.
4. Waves 1-4 harder or easier: average damage 62.9 -> 71.3, novice 93.7 -> 92.0; deaths (pending exact table).

## Merge notes

- NEED director: `project/dev/gauntlet/gauntlet.gd` KNOWN_FLAGS lacks `--foe-moves` (shared read-only).
- NEED director: `evidence/n31/foes/need_gun_down.patch` (arena_rigs.gd, unowned): no AIMING while in TRAVEL.
- NEED ground: `evidence/n31/foes/prologue_moves.patch` (pending b5).
- Digests re-pinned: test_foe_gait LEGACY_TRACE, scenario_arena_squad flankers, scenario_enemy_pit share cap,
  test_enemy_ai token cap (decisions lines 2026-11-25/26).

## Next steps

## Builder ledger
