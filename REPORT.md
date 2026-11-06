# REPORT: lane `king` (Act 1's King + the shared boss framework), night 2026-11-05/06

DRAFT written in iteration 8 (01:05). The final pass lands after the 08:30 freeze.
Branch `n7-king`, cut from main `763f8fba`. Clips and stills are in
`C:\Users\kazda\kiro\gtai-masters\n7\king\` (see `frames.json`, newest and best first).
The moveset is `docs/bosses/king.md`; the full log is `JOURNAL.md`.

## What works (with its evidence)

- **The shared boss framework** (`project/features/bosses/`, servo merged it all night):
  - a phased state machine with attacks as data (`data/tables/bosses.json` + schema):
    windup / active / recovery ticks, aim lock, `leap_m`, `buff_adds`, adds per phase, `ghost_k`;
  - telegraph views, adds (`BossAdds`), the boss bar with phase marks and a lost-hp trail, music;
  - arena records (`arena_stations/bosses.json`), a boss camera kept on the fight's floor;
  - the dev flags `--boss=<id> [--phase=N]` and `--bot=boss` (dodging, `--bot-stand`, `--bot-human`,
    `--ghost=<id>`).

  No boss's special case lives in the framework: King's own code is `features/bosses/king/`.
- **King's body**, all render-only and deterministic:
  - KingPlan's cutout rig at boss size, his chest and arms gilded by the gold print swap;
  - (it8) **two flat gold press plates and a shoulder megaphone**, replacing the claw and the megaphone
    forearm he inherited (`king_press_plates_before_after_48ppm_it8.png`);
  - (it13) the megaphone prints gold with a dark bell mouth at 32 px/m (it was an ink smudge with
    vermilion flecks: `evidence/king/shots/it13/horn_lift_10_155_19_p3_p1_32ppm_4x.png`);
  - a jewelled crown and the ermine collar over the vermilion cape; (it13) the cape is folded cloth
    under an ermine border that sways and trails his charge (`evidence/king/shots/it13/cape_before_after_32_48ppm.png`);
  - the gilded plum throne-car, a boss-owned vehicle with drapes and a hood cannon (banded gold barrel on a swivel mount since it12, `evidence/king/shots/it12/hood_cannon_before_after_48ppm_2x.png`);
  - the gang: the rich robot thug with gold chains, a steel helmet and shades.
- **Three phases** (`king_phase{1,2,3}_*_32ppm_it13.mp4`, cut from the it13 full fight):
  - phase 1, the procession: ram lanes and the hood cannon's coin fan (since it10 a spray of 48 coins out of the muzzle, `evidence/king/shots/it10/coin_spray_before_after_48ppm.png`), with the gang pushing and riding;
  - phase 2, the court: the car stops, the gang brawls, and decrees buff them;
  - phase 3, on foot: the press slam (a leap onto the ring, shockwave plus coin ring) and the charge.

  Then a defeat beat: the crown falls off and rolls away.
- **Clips**:
  - the full fight played by the human-like bot on the current body (`king_fight_bot_human_32ppm_it13.mp4`, 95 s; King down at tick 4933, the headless run's tick);
  - the procession entering, from the gang's first appearance to King stepping down (`king_procession_enter_32ppm_it13.mp4`);
  - the press slam, telegraph (the plates raised beside the crown), hit and dodge (`king_slam_plates_48ppm_it13.mp4`);
  - the charge, telegraph lane, hit and dodge, the cape drawn in and flared (`king_charge_48ppm_it13.mp4`);
  - the ram and the coin fan, hit and dodge (`king_ram_coin_fan_48ppm_it12.mp4`), and the decree's windup arc and buff (`king_decree_48ppm_it10.mp4`);
  - the target sheet beside the game at 32 px/m (`king_target_vs_game_32ppm_it13.png`);
  - the ghosts on King (Dent, Kerf, Tonnage, Ohm).
- **Combat holds**: the director reel was 19/19 chapters down with 0 SCRIPT ERROR on the branch
  (`evidence/king/director-reel-it6.log`).
- **Gates** (it10): lint 13/13, unit 1160/0 (`evidence/king/unit-it10c.log`), scenarios 52/0
  (`evidence/king/scenarios-it10.log`).
- **The boss camera** (it10): n7-servo's `BossCam` bar band and `keep_in` are ported to this branch
  as identical files, so King stays whole below the boss bar at the boulevard's top edge.

## Numbers (encounter-balance-simulation: full fights, seeds 1-5, CONTENDED machine)

| bot | King down | Rivet took | deaths | ram | coin fan | slam | charge |
|---|---|---|---|---|---|---|---|
| dodging (it5c) | 80.1 s | 0 | 0 | 0/10 | 0/43 | 0/10 | 0/9 |
| human-like (it5d) | 83.9 s (77.9-90.6) | 78 | 0 | 4/10 | 13/48 | 5/12 | 0/6 |
| standing (it5d) | 87.6 s | 190 | 5 | 10/10 | 36/40 | 7/7 | 3/8 |
| human + Dent (it7) | 90.8 s | 78.8 | 0 | 4/15 | 11/45 | 5/12 | 1/9 |

Every attack is dodgeable (the dodging bot takes 0) and every attack lands on a stander. The
easy band is as built (call C). The it8 body change is render-only: King still goes down at tick
4933 for the human bot on seed 2 and 5315 for the standing bot, the same as before, in the editor
and in the exported exe.

## What does not work yet / gaps against the target

- The gang at 32 px/m: bulkier since it8 (size 1.2, arm width 1.7), and since it10 their heads
  read as light steel domes with a gold frame (`evidence/king/shots/it10/gang_head_before_after_32ppm_3x.png`). In
  the top view their size matches the target's 90-degree panel (measured in it12: ~1.6 m across the
  shoulders beside the ~6 m car, over a 1.0 m hit circle); they are less blocky and look smaller than
  the target's 3/4 view, where its bodyguards are drawn tall (call J).
- The plain robot thug (the enemy-ai lane's, not King's) prints as solid ink at 48 px/m. The gang's
  lift would fix it (`evidence/king/shots/it7/plain_thug_48ppm_ink_x2.png`).

## Calls for the owner

Each call names its options, the default that is built, and how to see it.

- **A. Ghosts on bosses.** Bosses take the ghosts' full machine damage (built: `bosses.json
  king.ghost_k` 1.0), or e.g. 0.5. Ohm takes about 14 % off the fight. Dent's car and Tonnage's
  shove are set pieces, not damage. See `RTAI.exe -- --rigs --boss=king --bot=boss --bot-human --ghost=ohm`.
- **B. The wreck is cover in phase 3** (built: `KingMoves.WRECK_SOLID` true), or paint only.
- **C. Difficulty band.** Easy (built: the human-like bot survives 5/5 and takes 78 of 100), or
  fair (about 7 in 10 survive).
- **D. Gang steel.** The D4 lift x1.55, the visor and the steel dome (built), or the old dark print:
  `evidence/king/shots/gang_steel_before_after_48ppm.png`.
- **E. Gold swap.** King's gilded chest and arms (built: `KingRigs.GOLD_SWAP` 5), or plain steel (-1):
  `evidence/king/shots/gold_ab_p3_32ppm_2x.png`.
- **F. The slam's leap.** King hops onto the locked ring (built: `leap_m` 6), or slams on the spot (0).
- **G. Decree buff.** The decree buffs the gang x1.3 damage and x1.2 speed for 6 s (built), or the
  decree only shouts.
- **H. Press plates (it8).** Two gold press plates and a shoulder megaphone (built:
  `KingRigs.PRESS_PLATES` true), or the claw and megaphone forearm (false):
  `king_press_plates_before_after_48ppm_it8.png`.

- **I. Gang heads (it10).** A light steel dome with a gold frame and a black shade strip (built:
  `tools/art/gang_parts.py` STEEL 204, VISOR_FROM 0.70), or the ink head of it7-it9 (STEEL 158,
  VISOR_FROM 0.60). At 32 px/m the print gives a head only paper or ink, with no grey between
  (measured: `evidence/king/shots/it10/dome_158_148_204_32ppm_4x.png`). See
  `evidence/king/shots/it10/gang_head_before_after_32ppm_3x.png`.

- **J. Gang bulk (it12).** The gang as built (drawn ~1.6 m across over a 1.0 m hit circle,
  `GangPlan.SIZE_K` 1.2), or bigger bodyguards whose hit grows with the drawing (`bosses.json
  king_gang.radius_m` 0.58 with `SIZE_K` 1.4: a gameplay change, harder to dodge round, not built
  and not measured). A size step that only changes the drawing is rejected: it would draw a wider
  robot than Rivet can hit. See `evidence/king/shots/it12/gang_d5_p2_64ppm_t120.png`.
- **K. Gang close-up steel (it12).** At 56 px/m and above the gang's D5 set is lifted x1.3 and
  reads as light plated steel like the target's (built: `tools/art/gang_parts.py LIFT_K_D5` 1.3), or
  the old near-black close-up (1.0): `evidence/king/shots/it12/gang_d5_lift_before_after_64ppm_3x.png`.
- **L. The cape (it13).** Fur-trimmed cloth that moves (built: `KingCape.FOLDS` 4: a folded hem,
  short ink folds, an ermine border with ink tails, a slow sway, drawn in through the charge and ram
  tells and flared through the dash), or the flat vermilion trapezoid with a cream band (`FOLDS` 0):
  `evidence/king/shots/it13/cape_before_after_32_48ppm.png` (stills),
  `evidence/king/shots/it13/cape_charge_gather_flare_48ppm_5fps.png` (the charge), and in play
  `RTAI.exe -- --boss=king --phase=3`.

## The exe

Export it with
`"$GODOT_BIN" --headless --path project --export-release "windows-showcase" <worktree>/build/export/windows/RTAI.exe`.
The showcase preset boots the arena, so the boss flags reach the fight. It was exported and
smoke-tested in it8 (headless, seed 2: King down at tick 4933, 0 SCRIPT ERROR); it is
re-exported at the freeze.

- `build/export/windows/RTAI.exe -- --rigs --boss=king` (play the fight)
- `build/export/windows/RTAI.exe -- --rigs --boss=king --phase=3`
- `build/export/windows/RTAI.exe -- --rigs --boss=king --bot=boss --bot-human --boss-cam` (watch the bot)

## Next steps

See `JOURNAL.md` NEXT.
