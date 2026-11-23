LAUNCH NOTE: wall-clock hard stop 05:38 (check the clock), commit deadline 05:36. Base: HEAD 69f1099c2 (packages 01-04 committed; keep them).
**The Director's final gate is running now (pid 73116, a node process; it spawns Godot in a snapshot). Do NOT start any Godot process
until pid 73116 has exited** (PowerShell: `Wait-Process -Id 73116`; it should end about 05:20). Edit and lint (no Godot) meanwhile.
If pid 73116 is still alive at 05:28, commit nothing, stop, and say so.

# Package 05 `title`: the title card names the chapter that Start opens

Today the slice title card (`project/boot/quest1_card.gd:61`) reads "Quest 1: Collect Call" under "RTAI: Uprising", but
since package 03 the Start button on the real menu opens the PROLOGUE (`project/boot/new_game_path.gd` `press_start`:
`campaign_menu or main_menu`, not `--autostart`, not `--skip-prologue`). The owner's morning film opens on this card
(`C:/Users/kazda/kiro/gtai-masters/n25/path/film-title.png`).

1. When Start will open the prologue (the same condition `press_start` uses: factor it into one `NewGamePath` predicate so the
   card and the button can never disagree), the card's vermilion subtitle reads the prologue's own name as the prologue shows it
   (its title card shows "Prologue": find the existing loc key/text the prologue end card uses, reuse it; do not write new story
   text). Otherwise (embedded runners, `--skip-prologue`, `--autostart`) the card is byte-for-byte as today. Text through the
   card's existing `_t()` (LOC-01). One unit test: the predicate and the subtitle for main-menu vs skip-prologue.
2. Every shipped scenario and tape stays byte-identical; quest 1's lines untouched.
3. Checks (after pid 73116 is gone): `node tools/tests/run_unit.mjs --changed` green; `node tools/godot/check.mjs` on the files;
   the scenarios that use the card (`quest1_input`, `quest1_keys`, `autosave_input`, `handheld_focus_pause`, `prologue_handover`):
   `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd -- --only=<names>` (or the runner's own --only form)
   green; `node tools/tests/release_compile.mjs` exit 0; `node tools/gate/quick.mjs` green; ONE commit. Then
   `node tools/mutate/mutate.mjs --file=project/boot/quest1_card.gd --max=10 --lines=<changed>` if time allows.
4. A still `C:/Users/kazda/kiro/gtai-masters/n25/path/title-prologue.png` (1920x1080, the menu as the real game opens, d3d12,
   `--position 0,1440`) only if it takes under 5 min; else skip it and say so.

Owned paths for this package: `project/boot/quest1_card.gd`, `project/boot/new_game_path.gd`, `project/tests/unit/test_prologue_*.gd`,
`project/boot/prologue/**` (non-scenery), `docs/decisions.md` (one appended line). Any other path: stop and report a NEED.

## Final message
The commit sha, the numbers, the still path or "skipped", anything left. Keep it short.

## Repo law and lane rules (bind every step)

- Before EVERY Godot or gate run: `export APPDATA=C:/Users/kazda/kiro/gtai-n25/appdata/path` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
  Anything that renders: `--rendering-driver d3d12`; any windowed run: `--position 0,1440` (never the main display).
  One Godot process at a time (you are the only Godot user of this lane while you run). Free your own processes by PID, never by name.
- AGENTS.md and STANDARDS.md are law. Typed GDScript, files about 200 lines (hard 300), functions <= 40 lines,
  <= 5 parameters, `Log` not `print`, no raw keycodes, UI text through `Loc.t()`/`QuestText` as the prologue already does.
  RNG only through the registry; sim steps on `SimClock.TICK_DT`.
- Fix lint and format findings in your own edits and go on (`node tools/lint/lint.mjs`, gdformat). Run
  `node tools/gate/quick.mjs` before each commit.
- One commit per change, staged per path (`git add <path>`; `git commit -- <paths>` is fine). Banned: `git stash`,
  `git add -A/./-u`, `git commit -a`, `reset --hard`, amend, rebase, push. Commit `.uid` files with new `.gd`. After new
  scripts or art, run a Godot `--import` before committing.
- Mutate is capped: `node tools/mutate/mutate.mjs --file=<file> --max=20 --lines=<changed lines>`; quote killed/(killed+survived).
- Every shipped scenario and tape outside the prologue stays byte-identical; quest 1's scripts, lines and rules do not change;
  the native sim and parity digest do not move; the 60 s replay stays `cbeb734ff9b97c41`.
- **Owned paths (allowlist)**: `project/boot/prologue/**` EXCEPT the yard lane's scenery files (`prologue_yard*.gd`,
  `prologue_floor.gd`, `prologue_props.gd`, `prologue_bodies.gd`, anything under `project/boot/prologue/art/**`); the
  non-scenery parts of `project/data/tables/prologue_stage.json` (beats, checkpoints, prompts, enemy placement; NOT its `yard`
  block or `yard_size_m`) and its schema; `project/data/tables/prologue_lines.json` (never change the owner's text);
  `project/dev/prologue/**`, `project/dev/bots/prologue_bot.gd`, `project/tests/unit/test_prologue_*.gd`,
  `project/tests/scenarios/scenario_prologue_*.gd`; plus whatever the package names. Shared append-only, one line each:
  `docs/decisions.md`, `project/boot/launch_args.gd` `KNOWN_FLAGS` (then
  `node tools/debt/debt.mjs --update --accept-regression="<flag> for n25 path"`), `tools/debt/baseline.json` via the debt tool only.
  **Any other path: stop and report it as a NEED in your final message; do not edit it.**
- **Forbidden** (other night lanes are editing them): `project/features/player/**`, `project/features/souls/**`,
  `project/features/gauntlet/**`, `project/features/combat/kills/**`, `project/data/tables/combat.json`,
  `project/data/tables/input_actions.json`, the numbers of any EXISTING row of `enemies.json` / `weapons.json`,
  character art, the yard lane's scenery files listed above, any other worktree.
- Do not invent story, characters, lines or quest content. The owner's lines are verbatim.
- Colour law: red is blood only; vermilion only for danger, objectives and Rivet's collar; teal only for souls; amber for heat.
- If you are about to run out of time: commit what is green, and say in the final message exactly what is left.

