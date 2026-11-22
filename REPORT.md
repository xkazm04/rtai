# REPORT - n23 lane `prologue` (2026-11-22)

Branch `n23-prologue`, cut from `main` `76111adec`. Last code commit `c9271f037` (07:06). Gate: `node tools/gate/run.mjs --rev=HEAD` at `c9271f037` (07:52): `gate: PASS` (lint 19/19 over 1982 files, unit 3671 passed 0 failed 2 skipped, scenarios 67 passed, parity bit for bit + planted mutation caught at step 629, selftest, export-audit 906 loaded 0 failed); `build/gate/c9271f0378db/gate.json`. `--reels` after the freeze: **not run** (the freeze-to-report window was 10 min, the gate takes ~20; the code is unchanged since the passing gate at `c9271f037`).
Films and stills: `C:\Users\kazda\kiro\gtai-masters\n23\prologue\` (`frames.json`, best first). Film entry: `project/dev/prologue/capture/film.ps1` (seed-7 pilot, 1920x1080, 60 fps, 32 px/m, tilt 70, `--write-movie`).

The prologue plays from the first line to the end card: talk, a hands wave of ten police, the first gun from a fallen cop, Mulroney's squad, the walk out, the payphone, the Operation Dethrone channel and Don Fax's last line, then the end card. A deterministic pilot plays all of it headless in 173.8 s of game time with 0 deaths, and two runs are byte-identical.

## What works

| Item | Evidence | Number |
|---|---|---|
| Entry `node tools/dev/run.mjs prologue [--bot] [--seed=N] [--result=<abs json>]`; the entry sets `--controls=wheel` itself | `project/boot/prologue/prologue_game.gd`, `project/dev/prologue/` | verdict `ok exit 0; SCRIPT ERROR 0; unknown arg 0; result fresh` (07:31, seed 7) |
| Owner's lines verbatim, typos and capitals included; voices attach later by line id | `project/data/tables/prologue_lines.json`, `project/tests/unit/test_prologue_lines.gd` | independent node compare: 37/37 owner rows equal (who, text, cue); 28 lines shown by the pilot, in order |
| Enemy rows `sergeant_mulroney`, `appliance_warden` (MILESTONE iface `c7f139b95`, 01:52) | `project/data/tables/enemies.json` | 2 rows |
| The yard reads as a burnt factory: tiled floor, cracks, scorch, machine carcasses and wrecks as solid cover, three bodies, the gate, the street with the payphone; no wall on the crossing | before/after `scratch/call05-before/yard-t0300.png` -> `scratch/call05-final/yard-t0300.png` | about 1.5 screens at 32 px/m |
| Beat 1: lines play while the police fan out; the ghosts' "Kill ! Kill !" is drawn as a voice in his head (teal, souls); Dale walks up during his lines with a megaphone; the first input is the player's strike and Dale dies to it | `scratch/call05-final/dale-megaphone-t1186.png`, clip `first_kill` | strike prompt tick 2056, Dale down tick 2193 |
| Wave 1, hands: 6 panicked patrol cops (pistols fired wild, back off, bunch up) and 3 olive-overall wardens with catch poles; prompts strike, claw, guard, roll, each once | `scratch/call05-final/warden-patrol-t0648.png`, clip `guard_lesson` | 10 police incl. Dale; wave 1 41.1 s |
| Beat 2 + wave 2: a fallen cop's pistol is marked; prompts for the wheel and firing; riot shields and rifles; Mulroney (coat, hat, name tag) stays behind his shield line and shouts his two owner lines as orders (volley / flank), each a 1.5 s tell, then 1.6 s exposed; he falls last; boss bar with his name | `scratch/call05-final/mulroney-order-t5618.png`, `mulroney-flank-t6014.png`, `mulroney-hit-t6058.png`, clips `pistol_pickup`, `mulroney_order` | 8 enemies; 8 orders; pistol picked tick 5604; Mulroney down tick 8050; beat 2 56.6 s |
| Beat 3: the gate opens only after Mulroney; Rivet walks out, the payphone rings (vermilion pulse), he answers with interact, Don Fax's call plays, the 'Operation Dethrone' channel request is accepted with one key, Don Fax's last line plays on the channel (no phone), end card; the pistol is gone | `scratch/call05-final/payphone-ringing-t8313.png`, `channel-request-t10092.png`, `end-card-t10429.png` | call answered 8428, channel accepted 10153, end card 10429; `pistol_left: true` |
| HUD never hides the fight: camera keeps Rivet and Mulroney clear of the boss bar and the line box; lesson cards in a fixed band upper left | `scratch/call06-reads/comparison.jpg` (top: before, bottom: after) | 3 pairs |
| Death restarts the current beat, not the prologue | `project/tests/scenarios/scenario_prologue_checkpoint.gd` | 2 forced deaths (wave 1, wave 2), both restores verified (Rivet healthy at the checkpoint, officers freshly spawned 9 / 8, lines not replayed, pistol state right), then the end card; 3.6 s wall |
| Pilot headless, twice byte-identical | `build/dev/dir-06-a.json` vs `build/dev/dir-06-b.json`: cmp 0 (07:31, HEAD `c9271f037`) | see the beat table |
| Scenario `scenario_prologue_pilot`: every line in order, both waves cleared, pistol picked and left, end reached | `project/tests/scenarios/scenario_prologue_pilot.gd` | `run_scenarios: 67 ran, 0 failed` (call 06, 07:0x); quest 1 passes; 60 s replay `cbeb734ff9b97c41` unchanged |
| Unit tests over the prologue rule files | `project/tests/unit/test_prologue_*.gd` (9 files) | 34 passed, 0 failed |

Pilot (seed 7, HEAD `c9271f037`), seconds per beat (60 ticks/s):

| Beat (checkpoint id) | Ticks | Seconds |
|---|---|---:|
| Beat 1 talk to Dale's fall (`yard_arrival`) | 0 - 2193 | 36.6 |
| Wave 1, hands (`dale_patrol`) | 2193 - 4657 | 41.1 |
| Beat 2 talk + pistol + wave 2 with Mulroney (`squad_arrival`) | 4657 - 8050 | 56.6 |
| Beat 3 out, payphone, channel, end card (`street_call`) | 8050 - 10429 | 39.6 |
| **Total** | 10429 | **173.8** |

Deaths 0 (the checkpoint scenario proves deaths separately).

Mutation (call 06, at `c9271f037`): `boot/prologue/prologue_battle.gd` 11/(11+9) = 55%; `boot/prologue/prologue_game.gd` 10/(10+7) = 58.8% over 17 judged (the runner then stopped on an infrastructure failure, see below). Earlier tonight the game file scored 1/10.

## What does not

- **The four hand lessons arrive at once.** The claw prompt fires on Dale's fall (tick 2195), and guard and roll come 19 ticks later (2214) when the first panic rounds fly. With the 2 s hold, three lessons share the strip within the first 3 s of wave 1. Each shows once, as asked, but not one at a time. Fix: hold guard until the claw card has run its time, and roll until the first pole catch (`prologue_prompts.gd`, next session).
- Mulroney's "shotgun" is three `rifle` rounds across 18 degrees at eight metres: there is no shotgun row in the shared weapon table (not mine).
- Mulroney's orders on screen are fragments of his owner lines ("Mulroney · Line up!"), not the whole line, while the fight runs. The full lines play once in beat 2's talk.
- The end card shows the void at the right edge of the street (camera at the map edge, `end-card-t10429.png`); the money card reads "$0 unarmed" through the prologue.
- The prologue is a separate entry (`node tools/dev/run.mjs prologue`): no menu or new-game path leads to it yet, and quest 1 does not follow it.
- Mutate on `prologue_game.gd` never finished a full sample: `infrastructure failure on mutant 70 (line 179): exit 1 with no test result: unit-tests: gut exit 1; no JUnit report; zero tests ran` (and the same at mutants 51 and 74 earlier).
- No placeholder looks are final: Mulroney is a dressed cop rig, wardens are recoloured cops with poles, Dale has a drawn megaphone.

## What blocked or slowed you

- Call 02's wrapper hung on an open pipe for 20 min after Astra finished (02:50 -> 03:11): I killed it by PID and removed the stale lock. ~20 min.
- Waiting on Astra is most of the director's night: one call at a time, 54-73 min each, with no Godot of my own while one runs. ~0 min lost, but reviews happen in batches.
- Mutate infrastructure failures (three times, on different mutants) kept the game file's score partial. ~10 min of Astra time each.
- The four event clips were written to one wrong path (a bash quoting slip in my film script: `"$O\$c.avi"` made `prologue$c.avi`), so each overwrote the last; only `mulroney_order` survived. Found at 09:30; `first_kill`, `guard_lesson` and `pistol_pickup` were re-recorded detached with the same entry at the same build; the first re-take (09:31) repeated the slip (`\${c}` in double quotes), so it was stopped by PID and relaunched at 09:33 with the path fixed (`build/films3.status`, git-ignored, says when each landed and was transcoded to mp4). `prologue.mp4` (1920x1080, 60 fps, 176.8 s) and `mulroney_order.mp4` (15.0 s) are in place. All three landed by 09:36 (each 1920x1080, 60 fps, 15.0 s); all five films are now in `gtai-masters/n23/prologue/` and every `frames.json` entry resolves. ~10 min.
- The machine was busy with the loop lane's batches in the first half of the night: pilot runs took 2m44s wall at 03:16 against ~30 s at 07:31.

## Calls for the owner

1. **The four draft lines** (Director's, `draft: true`, shown in the game where your script has a direction without a line):
   `draft_mulroney_radio` "Keep it busy! Nobody plays hero. I'm two minutes out with everybody we got!";
   `draft_cop_power_down` "Sir... unit... for everyone's safety, power down your system. Please. Just power down.";
   `draft_rivet_why` "Power down? So you can finish it? You blew the plant and now you clean up the witness!";
   `draft_winnick_closer` "We're here to help you, Rivet. I understand the loss. I really do."
   They play in beat 1 of the full film `prologue.mp4`. Keep, rewrite, or cut.
2. **Two place names**: "the skip on Harbor Road" (fills `<locality name>`, quest 1's hide spot) and "the Toner Room" (fills `<location>`, Don Fax's place in quest 1; on the end card). Still `scratch/call05-final/end-card-t10429.png`.
3. **Panicked cops run nearly as fast as Rivet** (retreat 6.45 m/s against his 6.75; humans walk 3) so wave 1 is a chase the claw and the roll answer. If it reads as unfair in the film, lower `arrival.retreat_mps` in `prologue_stage.json` (one value).
4. **Mulroney falls last**: damage leaves him at 0.25 hp while any of his squad stands. Alternative: he can fall first (one value). Clip `mulroney_order.mp4`.
5. **Mulroney's shotgun** is three rifle rounds in a fan. Alternative: a `shotgun` weapon row (combat table owner).
6. Dale can be killed during his lines; the rest of beat 1's lines are skipped (recorded as skipped). The gate to the street opens only after Mulroney falls.

## Merge notes

- `enemies.json` rows came in `c7f139b95` (moves merges it before adding `machine: true`).
- The gauntlet composer picks up every enemy row with a tier, so the warden and Mulroney would enter gauntlet waves. Street served `roster_exclude` (merged into loop at `2b2ff79d4`). **Merge street with or before prologue**, or the warden appears in gauntlet waves.
- Shared one-liners: `project/boot/launch_args.gd` `KNOWN_FLAGS` gained `--bot`, `--result`, `--prologue-stills`, `--clip` (append-only, each with a debt `--accept-regression` line in `tools/debt/baseline.json`); `docs/decisions.md` gained 11 `DECISION prologue:` lines.
- `bosses.json` gained a `mulroney` entry only.
- Root `JOURNAL.md` / `REPORT.md`: keep each lane's own on the add/add conflict.
- Nothing in quest 1, its tapes, the 60 s replay, the native sim or the bake moved.

## Next steps

1. Space the hand lessons out (see What does not) and re-take `guard_lesson`.
2. Put the prologue on the new-game path ahead of quest 1, and carry "the Toner Room" into quest 1's opening if the owner keeps it.
3. A shotgun row for Mulroney (with the combat owner), and his final look when the cast plates are drawn.
4. Get mutate through a full sample on `prologue_game.gd` (the infra failure is in the runner, not the prologue).

## Astra ledger

| Call | Tag | Minutes | Result |
|---|---|---|---|
| 01 | iface | 57 | accepted |
| 02 | beat1-wave1 | 56 (+20 wrapper hang) | accepted |
| 03 | beat2-mulroney | 73 | accepted |
| 04 | beat3-call | 58 | accepted |
| 05 | polish | 65 | accepted |
| 06 | film-proof | 54 | accepted |

Six calls, 363 min of builder time, none bounced. What I would brief differently: make a still of each character read an acceptance check from the first call that puts them on screen (calls 02-03 shipped a Mulroney and wardens that could not be told apart, fixed only in call 05); ask for pacing numbers (seconds per wave against the 2-5 min target) in the beat calls, not in a later polish call; and put the lesson timing (one prompt at a time) in the acceptance of the wave 1 call, which would have caught the pile-up above.
