# REPORT - n23 lane `prologue` (2026-11-22)

DRAFT written 05:35 by session 5; the final session fills every `TODO` and removes this line.

Branch `n23-prologue`, cut from `main` `76111adec`. Head: TODO. Gate: TODO (`node tools/gate/run.mjs --rev=HEAD` line + `gate.json` path).
Films and stills: `C:\Users\kazda\kiro\gtai-masters\n23\prologue\` (`frames.json`, best first).

## What works

| Item | Evidence | Number |
|---|---|---|
| Entry `node tools/dev/run.mjs prologue [--bot] [--seed=N] [--result=<abs json>]`, `--controls=wheel` set by the entry | `project/boot/prologue/prologue_game.gd`, `project/dev/prologue/` | verdict `ok exit 0; SCRIPT ERROR 0; unknown arg 0; result fresh` (05:29, seed 7) |
| Owner's lines verbatim | `project/data/tables/prologue_lines.json`, `project/tests/unit/test_prologue_lines.gd` | TODO rows; independent node compare 37/37 owner rows equal (01:58) |
| Enemy rows `sergeant_mulroney`, `appliance_warden` (MILESTONE iface `c7f139b95`) | `project/data/tables/enemies.json` | 2 rows |
| The yard: wreckage cover, three bodies, gate, street with payphone, no wall on the crossing | stills `scratch/yard-t0300.png`, `scratch/gate-exit-t4864.png` | TODO after call 05 |
| Beat 1: lines in order, ghosts' "Kill ! Kill !" drawn as in-head (teal), Dale walks up, first input kills him | still `scratch/dale-first-kill-t2061.png` | Dale down tick 2193 |
| Wave 1, hands: patrol cops with panic pistols + wardens with poles; prompts strike, claw, guard, roll | pilot result | TODO s |
| Beat 2 + wave 2: marked pistol from a fallen cop, wheel + fire prompt, Mulroney commands volley / shield flank, exposed after each order, falls last, boss bar with his name | stills `scratch/pistol-marked-t3417.png`, `scratch/mulroney-order-t3410.png` | TODO s, TODO orders |
| Beat 3: walk out, payphone rings, answer by interact, Don Fax call, Operation Dethrone channel request accepted with one key, Don Fax's last line on the channel, end card; the pistol is gone | stills `scratch/payphone-ringing-t5034.png`, `scratch/channel-request-t6814.png`, `scratch/end-card-t7151.png` | end card tick TODO |
| Death restarts the current beat | TODO `scenario_prologue_checkpoint` | TODO |
| Pilot headless, twice byte-identical | `build/dev/dir-05-a.json` vs `-b.json` cmp 0 (05:29) | 119 s at HEAD `ca84bf492`; TODO after call 05 |
| Scenario `scenario_prologue_pilot` (every line in order, both waves, pistol picked and left, end reached) | `project/tests/scenarios/scenario_prologue_pilot.gd` | run_scenarios 66 ran, 0 failed (call 04) |

Seconds per beat and deaths for the pilot (seed 7): TODO table (beat 1 talk, wave 1, beat 2 talk, wave 2, beat 3, total, deaths).

## What does not

TODO.

## What blocked or slowed you

- Call 02's wrapper hung on an open pipe 20 min after Astra finished (02:50 -> 03:11): killed by PID. ~20 min.
- mutate on `prologue_game.gd`: 1 killed / 10 at call 03, then `infrastructure failure on mutant 51`; call 04 `infrastructure failure on mutant 74 (line 175)`. TODO final score.
- TODO.

## Calls for the owner

1. The four draft lines (Director's, `draft: true`, shown in game): `draft_mulroney_radio`, `draft_cop_power_down`, `draft_rivet_why`, `draft_winnick_closer`. TODO still each.
2. Two place names: "the skip on Harbor Road" (`<locality name>`), "the Toner Room" (`<location>`, on the end card). Still `scratch/end-card-t7151.png`.
3. Mulroney's shotgun is three `rifle` rounds across 18 degrees at eight metres (no shotgun row in the shared weapon table). Alternative: a `shotgun` weapon row (combat owner).
4. Mulroney falls last: damage leaves him at 0.25 hp while any of his squad stands. Alternative: he can fall first (one value).
5. Dale can be killed during his lines; the rest of the beat's lines are skipped.
6. The gate to the street opens only after Mulroney falls.

## Merge notes

- `enemies.json` rows came in `c7f139b95` (moves merges it before adding `machine: true`).
- The gauntlet composer picked up the two new rows (tier pool); street served `roster_exclude` (street brief 03 Part 0, merged into loop at `2b2ff79d4`). Merge street with or before prologue, or the warden appears in gauntlet waves.
- Root `JOURNAL.md` / `REPORT.md`: keep each lane's own on the add/add conflict.
- TODO: shared-file one-liners (KNOWN_FLAGS, decisions.md, debt baseline).

## Next steps

TODO.

## Astra ledger

| Call | Tag | Minutes | Result |
|---|---|---|---|
| 01 | iface | 57 | accepted |
| 02 | beat1-wave1 | 56 (+20 wrapper hang) | accepted |
| 03 | beat2-mulroney | 73 | accepted |
| 04 | beat3-call | 58 | accepted |
| 05 | polish | TODO | TODO |
| 06 | film-proof | TODO | TODO |

What I would brief differently: TODO (stills-first acceptance for character reads: calls 02-03 shipped a Mulroney and wardens that could not be told apart; the brief asked for it but did not make a still of it an acceptance check).
