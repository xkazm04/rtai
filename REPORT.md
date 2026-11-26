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

- Idle share 55 % (bar < 35 %). Why (`evidence/n31/foes/travel-cause/cause.md`, seed 3, waves 1-4): of the ranged
  foe-ticks with a clear line in range, 61 % are in TRAVEL (no fire): walking to cover 53 % (85 % of those walks are
  longer than 3 m: a token-less cop re-picks a cover spot within 8 m every 12 ticks), morale panic 32 %, Rivet inside
  4 m 12 %. A foe in FIGHT without a token still does not fire, so idle is token-bound. Four more settings were
  measured and none kept (`evidence/n31/foes/item3-compare.md`, b4j section): G (a walk <= 3 m in range is FIGHT)
  idle 53 %, damage 74.4; A (share 0.75, pistol 2, rifle 1.5) idle 44 %, damage 83.0; B (A + pistol 1.5) idle 43 %,
  damage 75.1; C (patrol cover_bias 0.5) idle 52 %, damage 81.7. Every setting that adds fire breaks the damage rail
  (top 72.3), so item 3 stops at `9b3730e36` as the brief says; B is a call below.
- React p90 2.58 s (bar 2.5 s).
- The damage rail itself is noisy at 10 seeds: G and C barely change fire but move damage by 3 and 10 points.

## What blocked or slowed you (minutes each)

- FRICTION builders-share-live-tree 10 (session 2): a measuring builder read the live tree while another edited it.
- FRICTION machine-load 8 (session 3): `waiting.mjs --check` silent for 8 min under other lanes' Godot runs.
- 64 px/m gait clip: the killing bot and nearest-cop camera could not show one cop's two moves (b4g, 8 min); a
  scripted stalk input was needed (b4h).

## Calls for the owner

0. **Setting B: more cops shooting, each round weaker** (`c825715e8`, one data block in `enemies.json`:
   `squad.max_shooters_share` 0.5 -> 0.75, `own_weapon_damage` pistol 3 -> 1.5, rifle 2 -> 1.5). Average bot, 20
   seeds (`evidence/n31/foes/noise.md`), main | final (HEAD) | B: idle share 65 | 53 | 43 %, foes firing per second
   1.02 | 0.83 | 1.07, foes that never fired 332 | 308 | 255 of ~1050, react p50 1.05 | 0.67 | 0.70 s, Rivet damage
   waves 1-4 63.8 | 70.0 | 74.0 (rail +-15 % = 54.2..73.4: B is 0.6 over), deaths 13 | 15 | 13 of 20 runs, waves 6/7
   reached 10/9 | 7/5 | 12/9. B minus final damage 4.0 +- 21.3 (95 %): inside the noise. B is the only setting that
   beats main on every fire number at main's death count; it is not on HEAD only because it misses the brief's rail by
   0.6. Clip: `C:\Users\kazda\kiro\gtai-masters\n31\foes\callb_wave3_side.mp4` (final | B, seed 3, wave 3).

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
