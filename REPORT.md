# REPORT - n23 lane `moves` (2026-11-22) - DRAFT, finished at 09:40

Branch `n23-moves`, cut from `main` `76111adec`, merged the prologue interface `c7f139b95` (enemies.json rows) before the machine flags. Ready for loop at `73eec563c` (`MILESTONE ready`).
Gate on the last code commit `81723e268` (07:42): `gate: PASS` (lint 19/19, unit 3696 passed 0 failed 2 skipped, scenarios 65 passed, parity bit-exact over 1200 steps with the planted mutation caught, selftest, release-compile 895 loaded 0 failed); `build/gate/81723e2682c8/gate.json` (git-ignored, in the lane). `--reels` owed after the 09:30 freeze.

## What works

| Item | Evidence | Number |
|---|---|---|
| `moves` block in `combat.json`, every row `enabled` (true), loader `MoveTable`, per-wave `moves{<id>: count}` in the gauntlet result | `project/features/combat/moves/move_table.gd`, `move_tally.gd`, schema `project/data/schemas/gauntlet_run.schema.json` | commit `156eff508` |
| Ohm short circuit (`ohm_short_circuit`): a flagged machine (`machine: true` in `enemies.json`: sentry turret, shield robot, war machine) struck by Ohm's bolt is stunned 2 s (war machine 0.6 s), 4 s immunity; turret stops sweeping and firing, shield robot drops its arc | `project/features/combat/moves/ohm_short_circuit.gd`, `project/features/combat/squad/foe_stun_view.gd`, `evidence/moves/ttk.md` | shield robot, pistol: 13.18 -> 1.88 s, 10/10 seeds faster; sentry turret 7.83 = 7.83 s (stationary), 4.02 = 4.02 s (flanking): the ordinary bolt already locks a turret (rounds fired 0/0) |
| Tonnage armour crack (`tonnage_armour_crack`): a Tonnage stomp/ram hit in the war machine's post-stomp recovery opens its front 4 s at 1.0x (from 0.5x), once per stomp, every damage source benefits | `project/features/combat/moves/tonnage_crack.gd`, `evidence/moves/ttk.md` | war machine, pistol: 17.53 -> 11.83 s, 10/10 faster; Rivet hp lost 77 -> 41 |
| Kerf blink behind (`kerf_blink_behind`): the blink-slice into a front plate lands behind the target, facing its back, when the spot is free of walls and props | `project/features/souls/kerf_behind.gd`, `evidence/moves/ttk.md` | first-slice damage off/on: shield robot 19.8 -> 99, war machine 49.5 -> 148.5, sentry turret 24.75 -> 99; kill time 0.02 s both arms (one slice kills at shipped HP). Probe-only what-if at a lower slice (`29bd06ce8`, `evidence/moves/ttk-kerf-whatif.json`): at 0.2x all three die in 1 slice instead of 2 (0.32 -> 0.02 s, 10/10 seeds); at 0.1x the war machine takes 2 slices instead of 4 (1.03 -> 0.32 s, 10/10) |
| Overkill carry (`overkill_carry`) + rank 2: leftover damage of a base-form kill jumps to the nearest hostile within 3 m at 1.0x, once; rank 2 4.5 m, two hops | `project/features/combat/moves/move_carry.gd`, `move_carry_view.gd`, `evidence/moves/ttk.md` | 3 patrol cops, hand cannon: 1.82 -> 0.98 s (R1) / 0.10 s (R2), 10/10 faster |
| All four off = the game before the lane (same roster) | `evidence/moves/byte-identity.md` | gauntlet seed 7 average SHA-256 `2d60b987...555f` both; `replay_60s` final `cbeb734ff9b97c41` on and off |

### Tests and mutation

Unit tests cover each rule and its edges: immunity, war-machine boss stun, once per stomp, a closed crack, a blocked landing spot (wall at the rear spot, wall across the blink line, body clearance, the street boundary), a carry with no enemy in range, rank 1 not re-carrying, and `requires` in the draw. Runs: `--changed` 3680 passed, 0 failed, 2 skipped (`a8a060feb`); lint 19/19. `tools/mutate` (`--max=20`, changed lines):

- `ohm_short_circuit.gd` 19/20 (`4a307d57f`)
- `tonnage_crack.gd` 7/7
- `kerf_behind.gd` 19/20 (survivor: the exact shield-angle boundary)
- `move_carry.gd` 17/18 (survivor: the initial rank)
- `move_bonus.gd` 14/14
- `move_ttk_stats.gd` 19/20

### Films (`C:\Users\kazda\kiro\gtai-masters\n23\moves\`, 32 px/m, 1080p60, 16 s each; dev scene `project/dev/moves/move_film.tscn`, `77a73eed1`)

| Clip | What it shows |
|---|---|
| `ohm_short_circuit.mp4` | the shield drops at 1.80 s with two SWAT behind it, six frontal pistol hits at full damage during the 2 s stun; the turret's sweep stops at 9.58 s |
| `tonnage_armour_crack.mp4` | stomp at 1.63 s, Tonnage's counter at 2.67 s, a frontal pistol hit at full damage at 3.53 s, the split closes at 6.67 s, a frontal shot at 7.75 s is back to half |
| `overkill_carry.mp4` | one hand-cannon round: rank 1 carries one hop at 2.33 s, rank 2 kills all three at 12.67 s |
| `kerf_blink_behind.mp4` | a head-on blink at 1.80 s; at the crate corner Kerf lands behind the carrier at 10.92 s (shipped slice: the carrier dies on the landing tick) |
| `kerf_blink_behind-alive.mp4` | the same landing at a probe-only slice x0.1 so the carrier survives (`81723e268`). Off: Kerf stops inside the shield arc, carrier 8.02/10 hp. On: Kerf lands 1.35 m behind it, facing its back, carrier 0.10/10 hp, shield raised and facing away for 0.73 s |

Each film has 64 px/m and 32 px/m stills with a move-off twin at the same frame (11 pairs, `frames.json`). Looked at by the director: the Ohm, Tonnage and overkill cues read; Kerf's landing spot reads but its facing does not (call 2).

### Rank table (weapon effects in `gauntlet_bonuses.json`)

The pool had no weapon-effect bonus before tonight (kinds: ghost 4, stat 10 already in two levels, weapon 12). Overkill carry is the first and only one, so it is the only effect ranked; no new effect was invented.

| Effect | Rank 1 (`effect_overkill_carry`) | Rank 2 (`effect_overkill_carry_2`, requires rank 1) |
|---|---|---|
| overkill carry | carry_k 1.0, radius 3 m, 1 hop; min_wave 3, weight 2 | carry_k 1.0, radius 4.5 m, 2 hops; min_wave 6, weight 2 |

## What does not

- Ohm short circuit gains nothing on a sentry turret: Ohm's ordinary bolt (1.2 s stun on every body, every bolt) already keeps a turret from firing. The first build made it worse (the short circuit replaced the ordinary stun and its 4 s immunity let the turret fire 85 rounds over ten seeds); fixed in `a8a060feb`, now 0/0.
- Kerf blink behind cannot show in kill time: the slice uses the 99-damage GUARD row, so it one-shots every new enemy, the war machine boss included (front 49.5 vs hp 26). The bypass is a 3x to 5x damage gain that only matters once the tuner lowers the slice. The probe-only what-if (`--slice-k`, `29bd06ce8`) shows it does matter then: at 0.2x it halves the slices on all three machines.

- The rank 2 card does not yet say in plain words what it adds. Gauntlet cards show only a name ("Overkill Carry II") and no description line, and the card view belongs to street (`project/features/gauntlet/**`). The `NEED street` in JOURNAL asks for a description line: "Leftover damage jumps twice, up to 4.5 m".

## What blocked or slowed you

- astra.mjs wrapper hung 17 min after m1's last message (pid held the pipe): killed by PID.
- m4 stopped at the `dev_loc` debt boundary (my brief did not authorise it): one follow-up.

## Calls for the owner

Stills and clips: `C:\Users\kazda\kiro\gtai-masters\n23\moves\` (`frames.json`, best first; every still has its move-off twin at the same frame).

1. **Ohm short circuit adds to the ordinary electro stun instead of replacing it** (`a8a060feb`). The first build replaced it, and the 4 s immunity let a turret fire in the gaps (85 rounds over ten seeds against 0). The upshot is that the move does nothing extra against a turret, because Ohm's ordinary bolt already silences one. Its value is the shield robot: 13.18 s down to 1.88 s. Alternative: drop the immunity (your spec names it) or make the short circuit longer than the ordinary stun. Both are values in `combat.json` `moves.ohm_short_circuit`. Still: `ohm_short_circuit-on-64-f0580.png` against its `-off-` twin.
2. **Kerf's slice kills every new enemy in one hit, the war machine boss included** (99 guard damage against war machine hp 26 at 0.5x front). The blink-behind move works (first-slice damage 19.8 -> 99 on the shield robot, 49.5 -> 148.5 on the war machine) but cannot change a kill time that is already one hit. The choice: let the tuner lower the slice against machines (loop's knob), or accept Kerf as the boss answer. Clips: `kerf_blink_behind.mp4` (shipped slice), `kerf_blink_behind-alive.mp4` (probe-only slice x0.1, the carrier survives); still `kerf_blink_behind-alive-on-64-f0633.png` against its `-off-` twin. At the shipped slice the cut pose faces along the travel path for its first frames and the carrier dies on the same tick, so only the landing spot reads. A pose that turns at once would need the blink to record which landing rule fired; that was not built tonight.
3. **Overkill carry starts only from Rivet's base form** (guns, claw, shock, burn), never from a ghost form, because the ghosts have their own moves. A rank 1 carry that kills does not carry again. Clip: `overkill_carry.mp4` (rank 1, one hop at 2.33 s; rank 2, two hops at 12.67 s).
4. **Stun and armour cues are amber and white**: by colour law amber means overload, and teal stays souls-only. Stills: `ohm_short_circuit-on-64-f0113.png` (shield slab lowered across the carrier's feet), `tonnage_armour_crack-on-64-f0164.png` (the split in the front plate), `tonnage_armour_crack-on-64-f0155.png` (sag: the plates lift).

## Merge notes

- loop merged `n23-moves` at `73eec563c` (its `620fb288e`), before the Ohm fix `a8a060feb`; its Ohm on/off arm measured the pre-fix rule unless it merged again (`NEED loop` 07:44). The Director's merge of `n23-moves` at its head carries the fix.
- One-line call sites in shared files: `combat_arena.gd` (`var move_tally`, `MoveState.write_fighter` in write_state, `MoveCarry.take` at :196; two doc-comment lines trimmed to stay under the cap), `gauntlet_wave_stats.gd` (`begin_wave`, `append_wave`), `foe_shield_view.gd` (`FoeStunView.place_shield`), `foe_ordnance_view.gd:47` (`MoveCarryView.paint`), `gauntlet_draw.gd:9,34`, `gauntlet_bonus_apply.gd:26-27`.
- `project/data/loc/en.po`: three appended entries (`GAUNTLET__KIND__EFFECT`, `GAUNTLET__EFFECT__OVERKILL_CARRY`, `_2`), `73eec563c`; an append conflict with another lane keeps both sides.
- `project/features/souls/plate_sparks.gd` `tracer()` enemy-round colour: left to street (needs `ShotDraw`, which exists only on `n23-street`).

## Next steps

- loop: add the `moves` knobs (`stun_s`, `boss_stun_s`, `immune_s`, `open_s`, `open_front_k`, `carry_k`, `radius_m`, `hops`, card `min_wave`/`weight`; Kerf's landing distance is `behind_m` in the kerf row of `ghost_attacks.json`) and teach the bot the four moves (the `NEED loop:` lines in JOURNAL name the state each one reads).
- Kerf's slice against machines (call 2) has to be settled before Kerf's kill-time pair can mean anything in play.
- Real enemy art (lancer, clamshell, door carrier, pile-driver) will need the stun, sag and split cues redrawn onto it: `project/features/combat/squad/foe_stun_view.gd`, `foe_walker_crack_view.gd`.
- Further weapon effects for the pool, each with a rank 2 under the `requires` rule (the draw already honours it).

## Astra ledger

| Call | Minutes | Verdict | What I would brief differently |
|---|---:|---|---|
| m1-ohm | 71 | accepted | |
| m2-tonnage-kerf | 73 | accepted | |
| m3-overkill-ranks | 59 | accepted | |
| m4-ttk-probe | 23 | bounced | authorise the dev_loc debt rise for a new dev probe up front; ask the probe to check that the "off" arm is really the old game against each enemy (Ohm already stunned turrets) |
| m4b-ttk-fix | 42 | accepted | |
| m5-films | 41 | bounced | same debt-boundary miss as m4: authorise the `dev_loc` rise in every brief that creates a dev scene |
| m5b-commit-decisions | 9 | accepted | |
| m6-kerf-whatif | 15 | accepted | ask for the lower-slice what-if in the first probe brief, as soon as the shipped numbers one-shot the target |
| m7-kerf-film | 15 | accepted | the film brief should require the target to survive the move whenever the move is about position or facing |
