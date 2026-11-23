LAUNCH NOTE: wall-clock hard stop 03:55 (check the clock), commit deadline 03:50. Base: HEAD c5fba0f4e (packages 01 lessons and 02 shotgun are committed; keep them). The Director's own session may be replaced while you run: just finish and write the final message.

# Package 03 `newgame`: New game starts the prologue, and the prologue hands over to quest 1

Wall-clock hard stop and commit deadline: given at the top of the launch note below. Stop early when done.

## Goal (owner, verbatim): "Put it on the new-game path ahead of quest 1 next run."
The game's menu **Start** (the new game) runs the prologue; the prologue's end hands over to **quest 1's opening without a
return to the menu**. **Continue** and existing saves still go where they went. A save made in the prologue resumes in the
prologue. A dev flag starts quest 1 directly (tests and tapes depend on it: every shipped scenario and tape stays byte-identical).

## What I know
- The game with a menu is `project/boot/quest1.tscn` (`Quest1Game`, `project/boot/quest1_game.gd`, 273 lines: near the 300 hard
  limit, so put new logic in a new file, e.g. `project/boot/prologue/prologue_handover.gd` or `project/boot/new_game_path.gd`).
  `boot()` connects `card.start_pressed` to `start()`, which opens `Quest1Session.open(Events, Data)` via `_begin()`;
  `card.continue_pressed` -> `_continue()` loads the newest autosave (`Save.load_latest(Quest1Autosave.accept(...))`);
  `_can_continue()` reads `Save.read_meta()["point"]`. Title card: `project/boot/quest1_card.gd` (`show_title`).
  `--replay` runs from `boot()` too. `project.godot`: `run/main_scene.slice="res://boot/quest1.tscn"` (`windows-slice` export).
- The prologue: `project/boot/prologue/prologue.tscn` + `PrologueGame` (`prologue_game.gd`): `boot()`, `encounter.end_card_reached`,
  `_finished()` quits when `--bot` / `--result`; dev entry `project/dev/prologue/prologue.tscn`; pilot `project/dev/bots/prologue_bot.gd`
  (dev/ is NOT in a release export: the shipped path must not need it; check with `node tools/tests/release_compile.mjs`).
  The prologue has its own beat checkpoints (death restores the current beat) but, as far as I know, no persisted save yet.
- The place names the owner kept: "the skip on Harbor Road" (quest 1's stage hide spot `harbor-skip`,
  `collect_call_places.json` "Harbor Road") and "the Toner Room" (`places.json` `toner_room`, `collect_call_places.json`
  "The Toner Room"). `prologue_lines.json` rows for them say why.

## What to build
0. First, its own commit (the yard lane asked for it): add `--yard-dressing` to the prologue entry's own `KNOWN_FLAGS` in
   `project/boot/prologue/prologue_game.gd` (one line; it takes a value), so `node tools/dev/run.mjs prologue --yard-dressing=<id>
   --dry-run` is accepted. Do not read or implement the flag: the yard lane does. Quote the dry-run line and the sha.
0b. Second commit, before anything else: package 02 (shotgun) left two unit tests red because the new arsenal row `shotgun`
   (stand-in art `assault_rifle`, class `two_hand_long`) is not registered: `test_held_classes.gd::test_every_arsenal_weapon_has_a_class`
   ("held_classes.json: shotgun has no hold class") and `test_arsenal_audit.gd::test_every_hole_is_known` ("NEW hole
   shotgun/top/held: art_stand_in -> assault_rifle; missing own held art"). Fix additively: a `shotgun` entry in
   `project/data/tables/held_classes.json` (same hold as the assault rifle / its class) and the known hole in
   `project/dev/rivet_arsenal/arsenal_known_holes.json` (the stand-in is deliberate until the art is drawn). Both files are allowed
   for this one addition. Rerun those two files (`--select=test_held_classes,test_arsenal_audit`) green, quote it, commit.
1. **Start** = prologue, in-process: Quest1Game (or a small new node it owns) instances the prologue scene, the player plays it;
   at the end card (after its existing hold, or a confirm key) the prologue is freed and quest 1 opens exactly as Start opens it
   today (`Quest1Session.open`), with no title card in between. Pause / settings during the prologue: use the prologue's own if
   it has one; if not, Esc at least must not break (report what it does).
2. **Dev flag** `--skip-prologue` (declare in `project/boot/launch_args.gd` `KNOWN_FLAGS`, then
   `node tools/debt/debt.mjs --update --accept-regression="--skip-prologue for n25 path"`): Start opens quest 1 directly, as today.
   Find EVERY scenario, tape, dev runner, film tool, export smoke and test that presses Start on `quest1.tscn` or calls
   `Quest1Game.start()` and decide per caller: if it means "quest 1", it must keep quest 1 (prefer making the old code path the
   API they already call, e.g. `start()` stays "open quest 1" and the menu's button goes to a new `new_game()`; then those
   callers need no change). Every shipped scenario and tape outside the prologue stays byte-identical: prove it (full scenario
   suite; the quest 1 tapes / `--replay` checks the repo has; the 60 s replay `cbeb734ff9b97c41`).
3. **Saves**: Continue and existing quest 1 saves behave exactly as today. A save made in the prologue resumes in the prologue
   at its last beat checkpoint: write a prologue autosave point through the existing save system at each prologue checkpoint
   (use `features/save` APIs as they are; if they cannot hold a prologue point without a change there, report a NEED and ship the
   rest), and Continue on such a save opens the prologue at that checkpoint. A finished prologue (hand-over reached) leaves
   quest 1's normal saves in charge.
4. **Carry-over**: only where quest 1's script already agrees: if quest 1's first screen names a place that the prologue also
   named ("the skip on Harbor Road", "the Toner Room"), nothing changes in quest 1's lines. Do NOT edit quest 1's lines, rules or
   data. List every mismatch between the prologue's script (`prologue_lines.json`, the owner's script in
   `C:/Users/kazda/kiro/gtai-n23/prologue/`) and quest 1's opening (its first lines / objective text / places) in your final
   message, with ids and quotes, for the owner.
5. **Pilot from the menu**: a dev way to run the whole path headless with bots: Start pressed by the dev runner, the prologue
   pilot plays the prologue, the hand-over happens, quest 1 opens and its **first line** is shown (find what quest 1's first
   shown line is). Then quit with a result JSON (`--result=<abs>`) holding the tick of: Start, prologue end card, hand-over,
   quest 1 first line. E.g. `node tools/dev/run.mjs <entry> --bot --seed=7 --result=<abs>`. It must run twice byte-identical.
   Add a scenario `project/tests/scenarios/scenario_prologue_handover.gd` (headless, fast as the existing prologue scenarios)
   that asserts: Start -> prologue; end card -> quest 1 opened without the title; quest 1's first line reached; `--skip-prologue`
   path still opens quest 1 directly; a prologue save resumes in the prologue.
6. Unit tests for the new routing file (new game vs skip flag vs continue with a prologue save vs a quest 1 save).
7. `docs/decisions.md`: one `- [2026-11-23] DECISION prologue: ...` line each for the routing, the flag, and the prologue save point.

## Owned for this package (in addition to the allowlist)
`project/data/tables/held_classes.json` and `project/dev/rivet_arsenal/arsenal_known_holes.json` (step 0b only, one entry each),
`project/boot/quest1_game.gd` (only the Start/Continue routing; nothing in quest 1's session, rules or lines),
`project/boot/quest1_card.gd` (only if a button label must change; avoid), `project/boot/main*`, `project/features/menus/**`,
new files under `project/boot/` named for this job, `project/tests/scenarios/scenario_prologue_handover.gd`, new unit tests.
`project/features/save/**`: only if strictly needed and additive; prefer a NEED.

## Acceptance (run all, quote results)
- The headless menu-to-quest-1 pilot, twice, `cmp` identical; quote the four ticks and the total seconds.
- `node tools/tests/run_unit.mjs --changed` green; FULL scenario suite green (quote the `ran, failed` line); the replay
  identity; `node tools/tests/release_compile.mjs` exit 0; `node tools/gate/quick.mjs` green before each commit.
- A windowed smoke (`--position 0,1440`, `--rendering-driver d3d12`) of quest1.tscn: Start shows the prologue's first frame;
  save a 1920x1080 still `C:/Users/kazda/kiro/gtai-masters/n25/path/newgame-prologue-first.png` and, from the pilot run rendered,
  `handover-quest1-first-line.png` (quest 1's first line on screen right after the hand-over).
- mutate `--max=20` on the new routing file; quote the score.
- Commits: (a) routing + flag + tests, (b) prologue save point, (c) pilot entry + scenario.

## Final message
Files changed, commit shas, every caller of Start you found and what it now does, the four ticks, the mismatch list between the
two scripts, test/scenario/mutate lines, NEEDs, and anything left.

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

