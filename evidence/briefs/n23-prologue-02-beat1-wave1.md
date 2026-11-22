# Brief n23-prologue-02 - beat 1 (talk, the first kill) and wave 1 (hands)

Lane `prologue`, night run n23. You built the interface and the yard in the previous call (c7f139b95..6dda3528d on n23-prologue). Same worktree, same branch.
**Hard stop: 03:10 local time** (check `date`). **Commit each working piece as it lands; last commit by 03:05.**

## Environment (every Godot run)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/prologue` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`.
- One Godot process at a time. Kill only by PID. Never rebuild native. Any windowed or rendering run: `--rendering-driver d3d12 --position 0,1440` (secondary monitor, never the main display).
- Headless `--import` after new scripts; commit `.uid` files with sources.

## Goal
Make beat 1 and wave 1 of the owner's prologue playable, from the scene's first frame to the last cop of wave 1 falling. The script is in `project/data/tables/prologue_lines.json` (rows `beat: 1`). Do not add or change any line text.

### A. The line player (beat 1)
1. Lines of beat 1 play in table order (kind `line`, including draft rows; `dir` and `stage` rows are never shown, they drive the action). Reuse `QuestLinePlayer` (`project/features/quest/quest_line_player.gd`) / `QuestLine.duration_ticks` timing from `quest_rules.json` and the `HudDialogue` subtitle view (`project/features/hud/hud_dialogue.gd`) if they fit without editing them; otherwise a small prologue-side player in `project/boot/prologue/`. Every shown line goes through `tr(<line id>)` with the table text as fallback.
2. Who speaks is shown with the line (speaker name through `tr()`). The ghosts' "Kill ! Kill !" (who `ghosts`) is drawn differently from spoken lines: it is in Rivet's head (for example italic or shaken, a different colour; **teal is for souls only**, so teal is allowed here; never red). Draft rows are shown like the others (the result file marks them).
3. A line can be skipped with one input (an InputMap action: use an existing action such as interact/`use` if one fits, do not add raw keycodes; new actions would be `input_actions.json`, which is NOT yours: if you need one, say `NEED controls` and use an existing action). Lines never lock the player out for more than a few seconds: Rivet can move during lines.
4. The police fan out as the lines play (the `cue` texts say how: the warden steps out with his pole and sees the bodies; catchers fan out). Dale (Lieutenant Dale Winnick, who `winnick`; tell him apart at a glance: a megaphone or a distinct placeholder from an existing rig, no new art) walks up to Rivet during his lines.
5. **The first kill.** The scene's first input that matters is the player's: when the line `SHUT!...UP!` (the last Rivet line of beat 1) is reached, a prompt to strike (left mouse, through `ObjectiveHint.with_keys` style key lookup from the InputMap, text through `tr()`) appears, and Dale dies to Rivet's strike. DECISION already taken: Dale can be killed before his lines end; then the remaining lines of beat 1 are skipped and wave 1 starts. Dale's death starts wave 1 (the panic).
6. Record in the result JSON (`gtai.prologue-run/1`): every line shown with its id and tick, skipped lines with `skipped: true`, the tick Dale died, beat start/end ticks.

### B. Wave 1 - hands (the ten police that came with Dale)
1. Spawn wave 1 from `prologue_stage.json` through the squad AI (`ArenaSquad.spawn_member(arena, at, &"patrol_cop")` etc. on an `ArenaStage`, as `project/features/arena/arena_stage.gd` does): frightened patrol cops with pistols fired in panic and `appliance_warden` pole catchers. Ten in total including those already on stage. They come in through the gate.
2. Frightened: they back off, bunch up, fire wild (low accuracy, panic). Do this with prologue-side settings (spawn placement, squad caps, a per-member accuracy or morale override applied from `prologue_stage.json` in your own code) - **do not change existing enemies.json rows or combat code**. The pole catchers try to hold Rivet at reach.
3. Rivet has only his hands (the wheel opens on `hands`; no gun in wave 1). Wheel controls are forced by the entry.
4. Teaching prompts, one each, only the first time it matters: strike (left mouse) - already given at Dale; the quick claw (Space) when a catcher holds him at reach; guard (hold right mouse) when the first pistol round is fired at him; roll. Text through `tr()`, keys from the InputMap.
5. Wave 1 is cleared when every wave-1 enemy is down; then beat 2 starts (for this call: show beat 2's first line and stop there; beat 2 is the next call).
6. **Death and checkpoint.** Rivet can die. Dying restarts the current beat (beat 1 or wave 1), not the prologue: reset enemies, Rivet and the line position to the beat's checkpoint from `prologue_stage.json`. Count deaths in the result.

### C. The pilot (start it now, finish it next call)
`project/dev/bots/prologue_bot.gd`: under `--bot`, a deterministic headless pilot that writes intents (pattern: `project/dev/bots/collect_call_bot.gd` writes `stage.intent`) to walk to Dale, strike him at the prompt, and fight wave 1 with hands until it is cleared. Headless run twice with the same seed must give byte-identical result JSON (compare with `cmp`). Quote both runner verdict lines and the seconds per beat and deaths.

### D. A still to look at
Render one still of the yard at tick ~300 and one at the first kill, 32 px/m tilt 70 (see `tools/film/film.mjs` and `tools/README.md`; if no shot fits the prologue, a small dev still script under `project/dev/prologue/` that writes PNGs, run windowed with `--rendering-driver d3d12 --position 0,1440`). Write them to `C:\Users\kazda\kiro\gtai-masters\n23\prologue\scratch\` and give the paths in your report. Never fake a frame.

## Tests
Unit tests `project/tests/unit/test_prologue_*.gd` for: beat 1 order (lines in table order, dir/stage rows not shown), skip, Dale killable early (remaining beat-1 lines skipped), wave 1 spawns ten from the table, death restarts the beat, prompts shown once. `node tools/tests/run_unit.mjs --select=<basenames>`; lint `node tools/lint/lint.mjs`; `node tools/gate/quick.mjs` before each commit.

## Owned files (allowlist). Any other path: stop and write `NEED <lane>: <file> <why>` in your report
- `project/boot/prologue/**`, `project/dev/prologue/**`, `project/dev/bots/prologue_*`
- `project/data/tables/prologue_*.json`, `project/data/schemas/prologue_*.schema.json`
- `project/tests/unit/test_prologue_*.gd`, `project/tests/golden/prologue/**`, `project/tests/scenarios/scenario_prologue_*.gd`
- append-only, one line each: `project/boot/launch_args.gd` KNOWN_FLAGS, `tools/debt/baseline.json` (only through the debt tool), `docs/decisions.md`
- **Do not touch** `enemies.json` again in this call (another lane merges it). Forbidden (other lanes, read-only): `project/boot/collect_call/**`, `project/boot/quest1*`, `project/features/**` (all of it: player, gauntlet, combat, souls, quest, hud, bosses, arena), `combat.json`, `gauntlet*.json`, `input_actions.json`, `test_player.json`, `quest_rules.json`, `tools/gauntlet/**`, every existing tape and golden. Subclass or wrap features classes from `project/boot/prologue/`; never edit them.

## Law
- AGENTS.md and STANDARDS.md bind. Typed GDScript; files about 200 lines (hard 300); functions of 40 lines or fewer; at most 5 parameters. `Log`, not print. UI text through `tr()`. InputMap actions, no raw keycodes. No global RNG (`ctx.rng.stream(&"prologue")` or the registry); sim on `SimClock.TICK_DT`.
- Colour law: red is blood only; cops are blue; vermilion only for danger, objectives and Rivet's collar; teal only for souls (the ghost voices may use it); amber for heat/overload.
- Fix lint and format findings in your own edits and go on.
- Stage per path. No `git add -A/./-u`, no `commit -a`, no stash, no amend, no rebase, no reset --hard, never push. One commit per working piece.
- Shipped scenes, quest 1, the 60 s replay and every existing tape stay byte-identical.
- Do not invent story or lines.
- Mutate only if time after a commit: `node tools/mutate/mutate.mjs --file=project/boot/prologue/<main file>.gd --max=20` (it commits nothing; it needs a clean tree at HEAD - commit first). Quote killed/(killed+survived), or the exact error if it cannot run.

## Report at the end
Commits (sha + subject), files, commands run with result lines (unit, lint, quick gate, two pilot runs + cmp, runner verdicts), seconds per beat and deaths, still paths, what is left, any NEED.
