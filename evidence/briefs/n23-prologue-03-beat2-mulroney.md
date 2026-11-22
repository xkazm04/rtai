# Brief n23-prologue-03 - beat 2: the pistol, wave 2 and Mulroney

Lane `prologue`, night run n23. Same worktree and branch. Builds on calls 01 (interface, yard) and 02 (beat 1, wave 1, line player, prompts, beat checkpoints, pilot start).
**Hard stop: 04:30 local time** (check `date`). **Commit each working piece as it lands; last commit by 04:25.**

## Environment (every Godot run)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/prologue` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`.
- One Godot process at a time; kill by PID only; never rebuild native; windowed runs `--rendering-driver d3d12 --position 0,1440`. Headless `--import` after new scripts; commit `.uid` files.

## Goal
Beat 2 of the owner's script (rows `beat: 2` of `prologue_lines.json`): Mulroney's lines, the cop's arrest line, Rivet's answer, the ghosts, then the ranged wave with Mulroney as the final boss. No line text changes.

### A. The first gun
When the ranged wave opens (the stage row "ranged combat wave starts, with Mulroney as final boss"), a fallen wave-1 patrol cop's pistol is marked on the floor (reuse `WeaponPickups.drop` / `PickupsView` ring from `project/features/player/weapon_pickups.gd`; read-only). Picking it up teaches the wheel: a prompt for scroll (the wheel) and one for firing, through `tr()` with keys from the InputMap (`ObjectiveHint.with_keys` style). The pistol is left behind at the end of beat 2 / start of beat 3: there is no remove call in player code, so remove it from Rivet's carry in prologue code (clear the carry slot, `first_seen`, `arena.rivet.weapon`, `arena.gun`, as `rivet_carry.gd:77` does) and record `pistol_left: true` in the result. Gloria in quest 1 stays his first owned gun.

### B. Wave 2 (data: `prologue_stage.json` wave `mulroney_squad`)
Better equipped: riot shields in front, rifles behind, Mulroney behind his line. At most ten including Mulroney. Come through the gate.

### C. Mulroney - a squad commander, not a big slow boss (owner's design)
- Human-sized (`sergeant_mulroney` row; radius and speed of a human). He stays behind his line with a shotgun and shouts orders.
- **Each order is a readable tell**: his two shouted lines ARE his orders in the fight: "Oh...my...god. Okay! Line up! ..." -> the line forms / holds and a flank push by his men; "Quit babying the chrome! ... Shoot him !" -> a volley from the rifle line. Show the order line as his speech plus a clear tell on him (wind-up pose / marker, vermilion = danger is allowed), then his men act on it after a fixed readable delay.
- **He is exposed for a moment after each order** (stays still / steps out of cover, takes full damage) **and when his line is broken** (riot shields down). Otherwise he is behind cover and his line protects him.
- The shotgun: no enemy shotgun row exists; fire a short spread of rifle rounds from prologue code at close range, or the `rifle` row as is. Record the choice.
- He is the last to fall: while any of his men stand, damage to him is capped above zero hp, or his line refills from cover (pick the simpler readable rule and record it).
- A boss bar with his name: a `mulroney` entry in `project/data/tables/bosses.json` (ONLY adding it; copy the shape of a human-sized entry such as `king_gang`) and the `BossBar` (`project/features/bosses/boss_bar.gd`, read-only; its name is `tr(spec.id.to_upper())`). If `BossFight` cannot drive an enemies.json fighter, show the bar from prologue code bound to his hp.
- The way out opens only after him: walking out before Mulroney is down is blocked (the gate to the street stays shut).
- Make it harder by what he does to a moving player (orders, reach, pressure from range), never by size or health alone.

### D. Death and checkpoint
Dying in beat 2 restarts beat 2 (the pistol back on the floor, wave 2 reset). Count deaths.

### E. Pilot and clips
Extend `project/dev/bots/prologue_bot.gd` to pick up the pistol, fight wave 2 and kill Mulroney after an order. Two headless runs with the same seed: byte-identical result JSON (`cmp`). Stills at 32 px/m of: the marked pistol, Mulroney giving an order, Mulroney hit right after it -> `C:\Users\kazda\kiro\gtai-masters\n23\prologue\scratch\`.

## Tests
Unit tests `project/tests/unit/test_prologue_*.gd` for: pistol marked when the ranged wave opens, pickup puts it in the carry and the wheel prompt shows once, pistol removed at the end of beat 2 (`pistol_left`), an order line triggers its squad action after the fixed delay, Mulroney exposed after an order (full damage) and protected otherwise, Mulroney last to fall, gate shut while he stands, death in beat 2 restarts beat 2. `node tools/tests/run_unit.mjs --select=<basenames>`; `node tools/lint/lint.mjs`; `node tools/gate/quick.mjs` before each commit.

## Owned files (allowlist). Any other path: stop and write `NEED <lane>: <file> <why>` in your report
- `project/boot/prologue/**`, `project/dev/prologue/**`, `project/dev/bots/prologue_*`
- `project/data/tables/prologue_*.json`, `project/data/schemas/prologue_*.schema.json`
- `project/data/tables/bosses.json`: ONLY adding a `mulroney` entry (no other entry changes). If the bosses schema rejects a human-sized commander, bind the BossBar from prologue code instead and skip the entry.
- `project/tests/unit/test_prologue_*.gd`, `project/tests/golden/prologue/**`, `project/tests/scenarios/scenario_prologue_*.gd`
- append-only, one line each: `project/boot/launch_args.gd` KNOWN_FLAGS (then `node tools/debt/debt.mjs --update --accept-regression="<flag> for n23 prologue"`), `docs/decisions.md`
- Forbidden (other lanes, read-only): `enemies.json` (stays as committed), `project/boot/collect_call/**`, `project/boot/quest1*`, `project/features/**` (all of it: player, gauntlet, combat, souls, quest, hud, bosses, arena), `combat.json`, `gauntlet*.json`, `input_actions.json`, `test_player.json`, `quest_rules.json`, `tools/gauntlet/**`, every existing tape and golden. Subclass or wrap features classes from `project/boot/prologue/`; never edit them.

## Law
- AGENTS.md and STANDARDS.md bind. Typed GDScript; files about 200 lines (hard 300; split into new `prologue_*.gd` files before you hit it); functions of 40 lines or fewer; at most 5 parameters. `Log`, not print. UI text through `tr()`. InputMap actions, no raw keycodes. No global RNG (`ctx.rng.stream(...)` from the registry); sim on `SimClock.TICK_DT`.
- Colour law: red is blood only; cops blue; vermilion only for danger, objectives and Rivet's collar; teal only for souls; amber for heat/overload.
- Owner on enemy size: "we should be careful with too large bosses and enemies to avoid very heavy and slow oponents very easy to beat by just moving". Mulroney is human-sized and near Rivet's size; humans are always weaker than Rivet.
- Fix lint and format findings in your own edits and go on.
- Stage per path. No `git add -A/./-u`, no `commit -a`, no stash, no amend, no rebase, no reset --hard, never push. One commit per working piece. Do not commit `JOURNAL.md`, `REPORT.md` or `evidence/briefs/**` (the director's).
- Shipped scenes, quest 1, the 60 s replay and every existing tape stay byte-identical.
- Do not invent story or lines.
- Mutate after the last commit if time: `node tools/mutate/mutate.mjs --file=project/boot/prologue/<main new file>.gd --max=20` (clean tree at HEAD). Quote killed/(killed+survived), or the exact error.

## Report at the end
Commits (sha + subject), files, commands with result lines (unit, lint, quick gate, two pilot runs + cmp, verdicts), seconds per beat and deaths, still paths, what is left, any NEED.

## Known state from call 02 (director's review)
- Pilot `--bot --seed=7`: Dale dies tick 2061, wave 1 cleared tick 2449 (6.5 s after Dale), 0 deaths. Wave 1 is far too short for a prologue of 2 to 5 minutes; do not fix wave 1 in this call (a later call paces it), but make wave 2 last a readable fight for the pilot: Mulroney gives at least two orders before he falls, so the order/exposed cycle is visible.
- The result file is `gtai.prologue-run/1`; extend it with `pistol_picked_tick`, `pistol_left`, `mulroney_orders[{line, tick}]`, `mulroney_died_tick`, `wave_two_cleared_tick`, beat-2 deaths. Unmeasured values are omitted, never 0.
- Astra wrappers have hung after the final message on this machine: when you are done, make sure no Godot or shell you started is still running (kill by PID).
