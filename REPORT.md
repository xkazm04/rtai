# REPORT lane foes, run n31 (2026-11-25 night)

Branch `n31-foes`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, cut from `main` `ba8e470b0`.
Final game setting: `9b3730e36` (HEAD's default game code is the same; call B is playable behind `--foe-fire=hot`,
PENDING b4q).
Films: `C:\Users\kazda\kiro\gtai-masters\n31\foes\` (`frames.json`, best first).
Gate: PENDING (`node tools/gate/run.mjs --rev=HEAD`).

## What a player now meets when a wave starts (item 4 paragraph)

On main, wave 1's thirteen patrol cops spread out 10 to 12 m from Rivet. Most crouch behind boxes or circle, and
only two may shoot at a time: you walk at a crowd that mostly watches you, and a cop that sees you in range takes
a median 1.05 s to fire (one in ten waits more than 6 s). On HEAD, half of the ranged foes alive (at least 3) may
shoot. Each fires its own gun in short bursts (cops a 2-round pistol, SWAT a 3-round rifle) instead of everyone
sharing the assault rifle. A cop that sees you in range fires after a median 0.68 s (p90 2.58 s instead of 6.15 s).
A cop that is shooting walks slowly backwards and sideways while facing you, and a cop you rush inside 4 m drops its
gun and runs. What a player feels: the first rounds come sooner and from more guns, and a rush now breaks a cop's
fire instead of being met by a full-speed backpedal while it shoots. What has not changed enough: cops still spend
a lot of time walking to cover without firing. On HEAD, fewer foes fire per second than on main (0.83 against 1.02,
average bot) because a cop walking to cover is in the no-fire travel move. In wave 3 on seed 3 the HEAD take shows
less fire than main (0.40 against 0.67 foes firing per second). Setting B (call 0) is the one that beats main on
every fire number.

## What works

| item | evidence | the number (average bot, seeds 1-10, waves 1-4 + 6-7, wheel controls, unless noted) |
| --- | --- | --- |
| 1 measure the waiting | `tools/gauntlet/waiting.mjs` + probe (5e081baa5, 214602c88, f1dfc7492), `evidence/n31/foes/waiting-main/waiting.md` | main: react in range p50/p90 1.05/6.15 s, idle share 66 % (engaged rule), cops shoot from a median 9.0 m though they see 24 m, 173 of 569 ranged foes never fired, 1.02 foes firing per second with 6.4 alive |
| 2 two movement types | `project/features/combat/squad/foe_gait.gd`, `foe_gait_drive.gd` (a4a7a3537, 09d6abdba, 7dfba0b0f); mutate foe_gait.gd 20/20 | FIGHT = 0.45 x speed, faces Rivet, the only state that may fire; TRAVEL = full speed (panic x1.6), no fire, gun lowered; urgent inside 4 m; at least 0.6 s per mode; 0.25 s settle before the first shot. Clip `gait64_hold_side.mp4` (64 px/m, seed 3): the followed cop backs off at 0.26-1.08 m/s 6.1-6.6 m away and fires 3 rounds (s 1-3), then runs at 3.09 m/s with 0 rounds when Rivet rushes inside 4 m (s 6) |
| 3 they open fire | `evidence/n31/foes/item3-compare.md`, `waiting-final/`, `noise.md` | react p50 1.05 -> 0.68 s (bar <= 1.0: holds), p90 6.15 -> 2.58 s (bar 2.5: 0.08 over), idle 66 -> 55 % (bar < 35 %: fails), never fired 173 -> 160 of ~500, damage w1-4 62.9 -> 71.3 (rail 53.5..72.3 holds). 20 seeds: damage 63.8 -> 70.0 (+9.7 %) |
| 4 re-measure and film | `wave1_side`, `wave3_side`, `callb_wave3`, `gait64_hold`, wave 6 PENDING b4p (`evidence/n31/foes/takes/`) | wave 1 seed 3: foes that fired per second 0.63 -> 0.93 with fewer alive (9.2 -> 7.1); wave 3 seed 3: 0.67 -> 0.40 (less, see above) |
| 5a prologue two moves (patch for ground) | `evidence/n31/foes/prologue_moves.patch` + `.md` | yard patrol rounds while Rivet < 4 m: main 2-25 -> 0 on 5 seeds; not pinned (see Merge notes) |

## What does not

- Idle share 55 % (bar < 35 %). Why (`evidence/n31/foes/travel-cause/cause.md`, seed 3, waves 1-4): of the ranged
  foe-ticks with a clear line in range, 61 % are in TRAVEL (no fire). Of those: walking to cover 53 % (85 % of those
  walks are longer than 3 m, because a token-less cop re-picks a cover spot within 8 m every 12 ticks), morale panic
  32 %, Rivet inside 4 m 12 %. A foe in FIGHT without a token still does not fire, so idle is bound by the tokens.
  Four more settings were measured and none kept (`evidence/n31/foes/item3-compare.md`, b4j section): G (a walk
  <= 3 m in range is FIGHT) idle 53 %, damage 74.4; A (share 0.75, pistol 2, rifle 1.5) idle 44 %, damage 83.0;
  B (A + pistol 1.5) idle 43 %, damage 75.1; C (patrol cover_bias 0.5) idle 52 %, damage 81.7. Every setting that adds
  fire breaks the damage rail (top 72.3), so item 3 stops at `9b3730e36` as the brief says. B is call 0 below.
- React p90 2.58 s (bar 2.5 s).
- On HEAD, fewer foes fire per second than on main (0.83 against 1.02): the travel move eats the token gain.
- The damage rail is noisy: damage per seed has an sd of 21-37, so B minus final is 4.0 +- 21.3. At 10 seeds a
  difference under about 5 points means nothing.
- Average-bot deaths went up from 5 to 7 of 10 runs (20 seeds: 13 -> 15 of 20), and waves 6/7 were reached 6/6 -> 3/3
  times out of 10. The rail is on damage in waves 1-4 only.
- Enemy pistol and rifle rounds look and sound like the assault rifle's (`shot_draw` draws enemy rounds by size).
  The difference on screen is the rhythm only. That is a melee/combat file (see Merge notes).

## What blocked or slowed you (minutes each)

- FRICTION builders-share-live-tree 10 (session 2): a measuring builder read the live tree while another edited it.
- FRICTION machine-load 8 (session 3): `waiting.mjs --check` silent for 8 min under other lanes' Godot runs.
- FRICTION lane-lock 17 (session 5): a hung parse-error run held the lane's Godot lock while another builder waited.
- 64 px/m gait clip, 3 calls (b4g 8, b4k 35, b4m 11): the killing bot and the nearest-cop camera could not show one
  cop's two moves. A scripted stalk input (b4h, b4l) was needed.

## Calls for the owner

0. **Setting B: more cops shooting, each round weaker.** It is one data block in `enemies.json`
   (`squad.max_shooters_share` 0.5 -> 0.75, `own_weapon_damage` pistol 3 -> 1.5, rifle 2 -> 1.5). Play it with
   `gauntlet.tscn -- --pick-view --foe-fire=hot` (PENDING b4q; the gauntlet's own flag list needs
   `need_gauntlet_flags.patch`, see Merge notes). Average bot, 20 seeds (`evidence/n31/foes/noise.md`), main | final
   (HEAD) | B:
   - idle share 65 | 53 | 43 %
   - foes firing per second 1.02 | 0.83 | 1.07
   - foes that never fired 332 | 308 | 255 of ~1050
   - react p50 1.05 | 0.67 | 0.70 s
   - Rivet damage in waves 1-4 63.8 | 70.0 | 74.0 (rail +-15 % = 54.2..73.4: B is 0.6 over)
   - deaths 13 | 15 | 13 of 20 runs; waves 6/7 reached 10/9 | 7/5 | 12/9

   B minus final damage is 4.0 +- 21.3 (95 %), inside the noise. B is the only setting that beats main on every fire
   number at main's death count. It is not the default only because it misses the brief's rail by 0.6. Clip:
   `C:\Users\kazda\kiro\gtai-masters\n31\foes\callb_wave3_side.mp4` (final | B, seed 3, wave 3: 0.40 against 0.63
   foes firing per second, 3-round bursts, wave 3 cleared earlier).
1. Fight-move speed share 0.45 of `speed_mps` (`enemies.json` `fight_speed_k`). Clip `gait64_hold_side.mp4`: the
   firing cop backs off at 0.26-1.08 m/s. Rivet walks faster, so he can close on a cop that is shooting, and the cop
   then turns and runs.
2. Simultaneous shooters: fixed 2 -> `max(3, ceil(0.5 x ranged alive))` (`squad.max_shooters_share`). Lever 1 alone
   (share 0.35): react p90 6.15 -> 4.13 s, damage 62.9 -> 77.4 with the shared rifle.
3. Each kind its own gun (pistol / rifle / cannon, `squad.own_weapons`) against the shared assault rifle. At share
   0.35, damage in waves 1-4 77.4 -> 55.0. Rounds still look like the rifle's (above).
4. Waves 1-4 harder or easier (main -> HEAD, 10 seeds): average bot damage 62.9 -> 71.3, deaths 5 -> 7 of 10, waves
   6/7 reached 6/6 -> 3/3. Novice damage 93.7 -> 92.0, deaths 10 -> 10 of 10. Slightly harder for the average player,
   unchanged for the novice.

## Merge notes

- NEED director: `evidence/n31/foes/need_gauntlet_flags.patch` (PENDING b4q). `project/dev/gauntlet/gauntlet.gd`'s
  own `KNOWN_FLAGS` rejects `--foe-fire` and `--foe-moves` (exit 2). Without it, B is playable only through the take
  tool (`project/dev/foes_n31/play_take.tscn`).
- NEED director: `evidence/n31/foes/need_gun_down.patch` (arena_rigs.gd, unowned): no AIMING pose while in TRAVEL.
- NEED ground: `evidence/n31/foes/prologue_moves.patch` + `prologue_moves.md` (the yard patrol's two moves). It
  applies clean on n31-foes but is NOT pinned: prologue_checkpoint and prologue_pilot need ground's re-pin and a look
  at the bot dying (seed 42 wave two, checkpoint wave one). `--foe-moves=legacy` keeps main.
- NEED melee (informational): a distinct enemy pistol/rifle tracer and sound if each gun should read.
- Digests re-pinned: test_foe_gait LEGACY_TRACE, scenario_arena_squad flankers, scenario_enemy_pit share cap,
  test_enemy_ai token cap (decisions lines 2026-11-25/26).
- `tools/debt/baseline.json`: dev_loc accepted for the probe and stalk scripts. A KNOWN_FLAGS rise for `--foe-moves`
  and `--foe-fire`. On a conflict: `node tools/debt/merge_baseline.mjs`.

## Next steps

- If the owner picks B: change the two values in `enemies.json` (or make `hot` the default preset), re-pin the
  digests the flag test names, and re-run `waiting.mjs` on 20 seeds.
- Cover stickiness: a token-less cop keeps its cover spot instead of re-picking one every 12 ticks. That is the
  biggest single cause of TRAVEL in range (53 %); measure it before more tokens.
- Warden hat tan (n30 pick, item 5b): not started.

## Builder ledger

PENDING final minutes for b4p, b4q.
