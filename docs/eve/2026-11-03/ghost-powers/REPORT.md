# REPORT: ghost-powers lane (branch `e-powers`), 2026-11-03 evening run

Scope: the soul power framework, **Hauler** (tank transform) and **Gearbox** (car hijack), the power table,
the bulky ghost form, the power bindings, and the arena station. 94 files changed since `baf2e80`.
`M` below means `C:\Users\kazda\kiro\gtai-masters\eve\ghost-powers`. `E` means `evidence/ghost-powers` in this worktree.

**What the owner said, and what I did with it:** ghost-powers-1 (Gearbox control) = A, aim-to-steer.
ghost-powers-2 (tank look) = B, bulked short arms. Both answers came back at 21:25 as "not judgeable in this
state, keep the default as a placeholder; re-ask only with a real-time clip in the final look". So from then on
the Hauler was the one power I finished, and Gearbox stayed at the logic and test level.

## What works (each with its proof)

| Claim | Evidence |
|---|---|
| A data-driven power framework: activation, duration, cooldown, the Madness stub (using a soul raises it), interruption rules, a bark id per power. `SoulPowers`, `PowerDef`, `PowerTable`, `SoulTuning` in `project/features/souls/`, data in `project/data/tables/powers.json` + schema | unit `project/tests/unit/test_soul_powers.gd`; gate `E/unit-iter6.log` (570 passed, 0 failed) |
| The Hauler changes the body class: as `rivet_ghost` at 4.2 m/s, Rivet knocks down a human and a robot in the real city sim. Base Rivet at the same speed knocks down nobody and is blocked by the robot (planted) | `scenario_souls_powers` -> `E/souls-powers.json` (`human`, `planted_no_class`, `planted_robot_base`); `E/scenarios-iter5c.txt` (20 ran, 0 failed) |
| The stomp is a radial shockwave: the 6-person ring is floored, 2 people 6 m out are untouched. With no pulse (planted) or radius 0 (planted), 0 are knocked down | `E/souls-powers.json` (`stomp_city`, `planted_no_pulse`, `planted_stomp_r0`) |
| Gearbox logic: the car turns onto a robot 17 m off the aim axis and wrecks it at 14 m/s in 1.42 s. With turn 0 (planted) it never reaches the robot. The turn rate is limited, a tied soft lock goes to the lower index, and the residue upgrade is in | `E/souls-powers.json` (`gearbox`, `planted_no_turn`); `project/tests/unit/test_gearbox_link.gd` 7/7; planted `E/planted-gearbox-turn-iter5.txt`, `E/planted-gearbox-residue-iter5.txt` |
| The Hauler is **playable** on quest 1's stage (and on any `StagePilot`, so the arena too): Q / LB transforms, the stick steers with heavy movement (momentum and a turn limit), the melee press arms the stomp (0.3 s wind-up), and the stomp and the ram hurt and throw guards | `project/features/souls/hauler_stage.gd`; unit `test_hauler_stage.gd`; planted `E/planted-stomp-damage-0.txt` |
| The look in the playable view: Rivet's capture grows and turns teal with the morph and swells on the wind-up. A shock ring plus a crack baked from the D5 road crack art marks where the stomp lands | clip `M/clips/quest-hauler/quest-hauler-32ppm.mp4`, still `M/clips/quest-hauler/still-stomp2-t250.png` |
| Impact: on landing the stomp holds the sim for 8 ticks (hit-stop, wall time only, the replay is unchanged) and shakes the camera 7 px. A ram hit gets its own stop (6 ticks) and a 4 px shake, at most one per burst. Reduced motion is honoured | `hauler_kick.gd`; unit `test_hauler_kick.gd`; planted `E/planted-stomp-hitstop-unknown.txt`; clips `M/clips/quest-hauler-kick/`, `M/clips/quest-hauler-kick-48/`, strip `M/clips/quest-hauler-kick/strip-landing-32.png` |
| **Headline numbers** (bound input, the real quest view, 60 fps, 32 and 48 px/m): 1 activation, 2 stomps (4 hits), 2 ram hits, **6 kills per activation**, 25 held frames; Rivet stayed transformed for the whole 5.9 s run | `M/clips/quest-hauler-ram2/quest-hauler-ram-32ppm.mp4`, `M/clips/quest-hauler-ram2-48/quest-hauler-ram-48ppm.mp4`, `M/clips/quest-hauler-ram/strip-ram.png` |
| City clip on the real World and rig: **10 knockdowns per activation** (6 from the stomp) over 8.0 s transformed. The same path as base Rivet (`--before`): 0 | `M/clips/hauler-city/hauler-city-{32,48}ppm.mp4`, `M/clips/hauler-city/before-32ppm-t250.png` |
| The rig-side slam pose: claws go up on the wind-up and slam down on the landing. The bulked look (arm_k 0.6) is restored exactly when the morph ends | `M/clips/hauler-slam/hauler-slam-{32,48}ppm.mp4`; unit `test_hauler_look.gd`; `M/clips/hauler-look/after-bulked-32ppm-t430.png` |
| Quest 1 on the CITY path now bleeds on kills: CombatBlood and corpse stains on the CityView actor layer (was REQUEST 3) | `M/clips/quest-hauler-blood/`, `M/clips/quest-hauler-blood-48/` |
| Sound hook: `HaulerCity.cued` fires `servo` at the morph and `crash` at the stomp landing (temporary audio ids) | `M/clips/hauler-cues/` |
| Arena station `project/data/tables/arena_stations/ghost-powers.json` (`hauler_pad`, `gearbox_pad`). Input rows `power_hauler` (Q, LB) and `power_gearbox` (G, RB) | file; lint gate `E/lint-iter5b.txt` (13/13) |
| Owner-facing frames page: 15 entries, every file checked to exist at 23:45 | `M/frames.json` |

**Gates at HEAD (last code change `003f4b6`; every commit after it is docs or evidence only):**
- lint: 13/13 on every commit (pre-commit hook).
- unit: 570/570 when run alone (`E/unit-iter6.log`).
- scenarios: 20/20, replay identical (`E/scenarios-iter5c.txt`).
- parity: exact, the planted mutation is caught (`E/evidence-gate-iter1.txt`).

## What does not work yet (honest)

- **Gearbox is not playable.** Its logic, the soft lock and residue have unit and scenario proof, but nothing binds G to it in a playable view and there is no clip. The arena hook needs `ArenaHook`, which exists only on `e-arena`, so it could not land on this branch.
- **The tank in the exe is the scaled capture, not the rig.** Quest 1 draws Rivet as a capture, so the playable tank keeps the long arms. The bulked arms and the slam pose show only in the rig-based city clips.
- **The victims are quest placeholder guards, not cast rigs.** There are no hit reactions beyond being thrown and bleeding, and no robot victims (no sparks or oil).
- **The arena pad bots are range dummies.** After the merge, Hauler hits will land on the pit's waves (`--start=pit`), not on the `hauler_pad` bots.
- **Quest 1 has no CameraRig.** The stomp shake uses a private shake-only rig fed through `kick_px` instead.
- **Morph and sound are placeholders.** The morph is a scale lerp (no ink burst), and the sound ids are temporary (`servo`, `crash`).
- **Not re-asked.** Neither ask can be put to the owner again until there is a clip in the final look (owner rule, 21:25).
- **No bench run by this lane.** The cost of the city-path blood is UNMEASURED. Power logic runs only after a Q press (a few vector ops per tick).

## Blockers and friction (with duration)

- **Shared `user://` between worktrees** (from about 21:23 until the run ended). `test_save_slots.gd` and `test_save_facade.gd` write fixed `user://test_save`, so when other lanes run their gates at the same time, our unit run goes red. Iteration 5 lost about 10 minutes to it (`E/unit-iter5c-full.log`: all 67 failures were in save tests). It is green when run alone. REQUEST 4: per-worktree scratch dir, proposed patch `E/request4-per-worktree-scratch.patch`, not applied and not yet parsed or run.
- **`ArenaHook` exists only on `e-arena`.** A script extending a missing class fails every parse, so the Gearbox pad hook waits for the merge.
- **A changed PNG is not re-imported by a windowed run.** The first two crack bakes were invisible; about 15 minutes lost. Fix: run `--headless --import` first.
- **Bench lock** held by another lane at 22:37, so the bench was skipped.

## Shared files touched (minimal, recorded in JOURNAL)

- `input_actions.json` (+2 rows)
- `bodies.json` (`rivet_ghost` live)
- `RivetBody.body_class` and `pulse` (zero by default)
- `city_view.gd` and `print_stage.gd` (`kick_px`, zero by default; goldens unchanged)
- `collect_call_stage.gd` (`clock`, read only)
- `collect_call_view.gd` (Hauler kick + city-path blood)
- The arena station schema and its lint hunk (byte copies of `e-arena`; take theirs on conflict)

## Next steps (night run, after the 00:00 merge)

1. Apply REQUEST 4 (`E/request4-per-worktree-scratch.patch`), run `--check-only`, then the unit gate.
2. Put the tank on Rivet's real rig in the playable view (bulked arms + slam pose), with cast-rig victims and their hit reactions. Then re-ask ghost-powers-1/2 with that real-time D5 clip.
3. Gearbox `ArenaHook` on `gearbox_pad` (`stage.cars()`, `soul_hijack`); playable G binding; residue_s 2 on the pad through station data.
4. The Hauler in the arena pit (`--start=pit`), or a hook that spawns the pad bots as real guards.
5. Robot victims get sparks and oil; a real stomp sound cue with the audio lane; an ink burst on the morph.
6. Bench the city-path blood (riot scene) when `bench.lock` is free.
