# Brief n23-prologue-04 - beat 3 (out, the payphone, the channel), the end card, the full pilot and the scenario

Lane `prologue`, night run n23. Same worktree and branch. Builds on calls 01 (interface, yard), 02 (beat 1, wave 1, line player, prompts, checkpoints) and 03 (pistol, wave 2, Mulroney).
**Hard stop: <HH:MM>. Last commit by <HH:MM>.** Check `date` as you go.

## Environment (every Godot run)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/prologue` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`.
- One Godot process at a time; kill by PID only; never rebuild native; windowed runs `--rendering-driver d3d12 --position 0,1440` (secondary monitor). Headless `--import` after new scripts; commit `.uid` files.

## Goal
Beat 3 of the owner's script (rows `beat: 3` of `prologue_lines.json`) and the end of the prologue. No line text changes; the two draft place names (`draft-hideout` "the skip on Harbor Road", `draft-don-waits` "the Toner Room") fill `<locality name>` and `<location>` at show time, and the result marks those lines `draft_place: true`. The table text stays verbatim with the placeholders (the verbatim test must keep passing).

### A. Out
When Mulroney falls the gate to the street opens (it stays shut while he stands). The pistol is left behind at the start of beat 3 if call 03 did not already do it (`pistol_left: true`). Rivet walks out; `b3_l01` ("Fuck! Everyone is getting after me! SHUT UP!") plays as he crosses the gate (or after a short fixed delay if he idles).

### B. The payphone
Stage row "phone starts ringing": the payphone on the street (placed in call 01, `PayphoneRouter` in `project/features/missions/payphone_router.gd` read-only) rings: a ring marker/pulse (vermilion = objective is allowed) and an objective hint through `tr()` with the key from the InputMap (`use`/interact, `ObjectiveHint.with_keys` style). Rivet's line "A Phone. Ringing. They are trying to lure me." plays on the way. The call is answered by walking to the phone and pressing interact. Then the call lines play in order (Don Fax / Rivet, the "interrupting" and "a beat later, suddenly quiet" cues as timing: interrupting = the previous line is cut short; quiet = a longer pause before it). Rivet stands at the phone during the call (movement locked only while the call plays; each line still skippable).

### C. The channel (stage note "introduction of personal communicator/radio mechanic to avoid phone boots")
After Don Fax's "Open your channel..." line, a small on-screen **channel request** named `'Operation Dethrone'` (text through `tr()`; style it as a small incoming-request card, not a phone) asks to accept with one key (an existing InputMap action, e.g. `use`; key shown from the InputMap). On accept: stage "communication channel rings" = a short ring on the card, then Don Fax's last line plays on the channel (the speaker shown with a channel/radio mark so it reads as not-the-phone) while Rivet is free to walk. Build this inside `project/boot/prologue/` (it is the prologue's own; a later quest may adopt it).

### D. End card
After the last line: an end card ("Prologue" title + the place he is sent to, through `tr()`), the result file gets `end_tick` and `ended: true`, and under `--bot`/`--result` the scene quits cleanly (exit 0) a few seconds later.

### E. Checkpoint
Dying in beat 3 is unlikely (no enemies), but the beat-3 checkpoint restores to the gate if it happens.

### F. The full pilot and the scenario
1. `project/dev/bots/prologue_bot.gd` plays the WHOLE prologue headless, deterministically: beat 1 (Dale), wave 1, beat 2, pistol pickup, wave 2 + Mulroney, walk out, answer the phone, accept the channel, reach the end card. It skips no lines (it plays them through; a second mode `--bot=skipper` that skips every line is welcome if cheap).
2. Two headless runs with the same seed give byte-identical result JSON (`cmp`). Quote both `tools/dev/run.mjs` verdict lines, total seconds, seconds per beat, deaths.
3. A scenario `project/tests/scenarios/scenario_prologue_pilot.gd` (extends `Scenario`, auto-discovered by `tests/run_scenarios.gd`) that runs the pilot and checks: every line of kind `line` shown exactly once and in table order (or skipped and marked), both waves cleared, the pistol picked up and left, Mulroney down, the call answered, the channel accepted, the end reached, within the tick budget. Keep it under about 20 s wall headless; if the full prologue is too slow, run it at the scenario's fixed tick as fast as possible and report the wall time. Run the whole scenario suite once: `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd` and quote the summary line (every existing scenario must still pass; the 60 s replay untouched).

### G. Stills
32 px/m tilt 70 stills of: Rivet walking out the gate, the payphone ringing, the call, the channel request card, the end card -> `C:\Users\kazda\kiro\gtai-masters\n23\prologue\scratch\` (extend `project/dev/prologue/prologue_stills.gd`). Never fake a frame.

## Tests
Unit tests `project/tests/unit/test_prologue_*.gd` for: gate shut while Mulroney stands, place-name fill (table stays verbatim), phone answer needs interact at the phone, channel accept needs the key, end reached writes `ended: true`. `node tools/tests/run_unit.mjs --select=<basenames>`; `node tools/lint/lint.mjs`; `node tools/gate/quick.mjs` before each commit.

## Owned files (allowlist). Any other path: stop and write `NEED <lane>: <file> <why>` in your report
- `project/boot/prologue/**`, `project/dev/prologue/**`, `project/dev/bots/prologue_*`
- `project/data/tables/prologue_*.json`, `project/data/schemas/prologue_*.schema.json`
- `project/tests/unit/test_prologue_*.gd`, `project/tests/golden/prologue/**`, `project/tests/scenarios/scenario_prologue_*.gd`
- append-only, one line each: `project/boot/launch_args.gd` KNOWN_FLAGS (then `node tools/debt/debt.mjs --update --accept-regression="<flag> for n23 prologue"`), `docs/decisions.md`
- Forbidden (other lanes, read-only): `enemies.json`, `bosses.json` (except the `mulroney` entry call 03 added), `project/boot/collect_call/**`, `project/boot/quest1*`, `project/features/**` (all of it), `combat.json`, `gauntlet*.json`, `input_actions.json`, `test_player.json`, `quest_rules.json`, `tools/gauntlet/**`, every existing tape and golden. Wrap features classes from `project/boot/prologue/`; never edit them.

## Law
- AGENTS.md and STANDARDS.md bind. Typed GDScript; files about 200 lines (hard 300; split into new `prologue_*.gd` files before you hit it); functions of 40 lines or fewer; at most 5 parameters. `Log`, not print. UI text through `tr()`. InputMap actions, no raw keycodes. No global RNG; sim on `SimClock.TICK_DT`.
- Colour law: red is blood only; cops blue; vermilion only for danger, objectives and Rivet's collar; teal only for souls; amber for heat/overload.
- Fix lint and format findings in your own edits and go on.
- Stage per path. No `git add -A/./-u`, no `commit -a`, no stash, no amend, no rebase, no reset --hard, never push. One commit per working piece. Do not commit `JOURNAL.md`, `REPORT.md` or `evidence/briefs/**` (the director's).
- Shipped scenes, quest 1, the 60 s replay and every existing tape stay byte-identical.
- Do not invent story or lines.
- Mutate after the last commit if time: `node tools/mutate/mutate.mjs --file=project/boot/prologue/prologue_game.gd --max=20` (clean tree at HEAD). Quote killed/(killed+survived), or the exact error.

## Report at the end
Commits (sha + subject), files, commands with result lines (unit, lint, quick gate, scenario suite summary, two pilot runs + cmp, verdicts), seconds per beat and deaths, still paths, what is left, any NEED.
