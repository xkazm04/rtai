# Brief n23-prologue-01 - prologue interface commit, then the yard skeleton

Lane `prologue` of night run n23. You are the builder. Worktree: C:\Users\kazda\kiro\gtai-wt\n23-prologue (branch n23-prologue).
**Hard stop: 02:05 local time** (check `date`). **First commit (the interface) by 01:35 at the latest**, even if rough: another lane merges it.

## Environment (every Godot run)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/prologue` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'` before every Godot or tool run.
- One Godot process at a time. Headless only in this call. Never kill processes by name, by PID only. Never rebuild native.
- After adding scripts or scenes run a headless Godot `--import` so `.uid` files exist; commit `.uid` files with their sources.

## Goal
The prologue is the first playable piece of the main game: the scene after the opening trailer (burnt factory yard, Rivet over three dead cops, more police arrive; he learns melee, guard, the first gun, beats squad commander Mulroney, walks out, answers a payphone, gets a channel call from Don Fax). Tonight's lane builds it in steps. THIS call builds step 1 (the interface, committed first) and then starts step 2 (the yard).

### Step 1 - interface commit (commit by 01:35)
1. `project/data/tables/prologue_lines.json` + `project/data/schemas/prologue_lines.schema.json` (`"schema": "gtai.prologue_lines/1"`): every row of `C:\Users\kazda\kiro\gtai-n23\prologue\dialog.owner.json` in order (kinds beat/line/dir/stage, `who`, `t`, `cue`), each with a stable snake_case `id` (for example `b1_l01_warden_three_down`) and its `beat` (1..3). Text **verbatim, character for character**: typos ("happenned", "attrocity", "amongs"), the space before `!`/`?`, capitals, the `<locality name>` / `<location>` placeholders all stay in the owner text. Add the four draft lines from `C:\Users\kazda\kiro\gtai-n23\prologue\drafts.json` as rows with `"draft": true`, id from their draft id (snake_cased), each placed right after the direction row it stands for (`for_direction`). The two place names go in a `places` block with `draft: true`. Rows keep the owner's order (rows are an ordered array, not sorted by id).
2. Unit test `project/tests/unit/test_prologue_lines.gd`: copy the owner file byte for byte to `project/tests/golden/prologue/dialog.owner.json` and drafts to `project/tests/golden/prologue/drafts.json` (commit both); the test compares every owner row's `k`, `who`, `t`, `cue` character for character and in order against the table's non-draft rows; drafts likewise; ids unique and stable; a second test that the golden copy is byte-identical to the absolute owner path when that path exists (pending() if not).
3. `project/data/tables/prologue_stage.json` + schema (`gtai.prologue_stage/1`): the plan as data: beats 1..3 with their first/last line ids; wave 1 (ten police that came with Dale: frightened patrol cops with pistols fired in panic + `appliance_warden` pole catchers; Lieutenant Dale Winnick, who walks up during his lines, is part of beat 1); wave 2 (at most ten including `sergeant_mulroney`: riot shields, rifles); the pistol pickup id; a checkpoint per beat; yard size. First-guess numbers are fine; they are data.
4. Two new rows in `project/data/tables/enemies.json`: `sergeant_mulroney` (human-sized squad commander with a shotgun, stays behind his line, `explicit_spawn: true`, a tier) and `appliance_warden` (human catcher with a pole that holds Rivet at reach, melee reach about 2.2 m, `explicit_spawn: true`, a tier). Copy the shape of existing rows (patrol_cop, riot_cop) and satisfy the enemies schema in `project/data/schemas/`. Humans are always weaker than Rivet. **Do not change any existing row.** Follow the file's ordering.
   - MUST prove the new rows enter NO existing spawn path: EnemyRoster archetypes, legacy pit waves, and **the gauntlet composer** (`project/features/gauntlet/gauntlet_composer.gd` builds its tier pool from the rows it is given: find which rows). Run `node tools/dev/run.mjs gauntlet --seed=7 --bot=average --waves=3 --result=<abs json under build/>` before and after adding the rows and diff the wave compositions: they must be identical. If the gauntlet would pick them up, find a data-only way inside your own rows (you may NOT edit gauntlet files); if impossible, say `NEED street: ...` in the report and keep going.
5. `project/boot/prologue/prologue.tscn` + `prologue_game.gd` (root) that boots a flat placeholder yard with Rivet controllable (reuse how `project/boot/quest1.tscn`, `quest1_game.gd` and `project/boot/collect_call/**` stand Rivet up and show lines: READ them, do not edit them; reuse classes, do not fork quest 1) and a line display that shows a line by id through `tr()` with the line id as key (fallback to the table text). Flags read through `LaunchArgs`, declared in a `const KNOWN_FLAGS` in the entry: `--bot` (pilot), `--result=<abs json>` (written at quit: schema `gtai.prologue-run/1`, lines shown in order, beats reached, ticks), `--seed`. The entry itself forces `--controls=wheel` (find how quest1 / gauntlet read `--controls` and force wheel from the entry without editing player files). New flags go into `project/boot/launch_args.gd` `KNOWN_FLAGS` (append-only, one line each); if the debt ratchet complains, `node tools/debt/debt.mjs --update --accept-regression="--<flag> for n23 prologue"`.
6. A thin dev entry so `node tools/dev/run.mjs prologue --result=<abs>` resolves (a bare name is searched in `project/dev`), e.g. `project/dev/prologue/prologue.tscn` loading the boot scene. Check with `--dry-run`, then a real headless run with `--quit-after=300`; quote the runner's final verdict line.
7. `node tools/gate/quick.mjs` (see `tools/README.md`), then commit, each path staged by name: "Add the prologue interface: lines, stage table, Mulroney and warden rows, entry". Report the sha.

### Step 2 - the yard (after the commit, until the hard stop)
In `project/boot/prologue/`: the burnt factory yard, about 1.5 screens at 32 px/m (roughly 60 x 34 m, size in prologue_stage.json): wreckage and machine carcasses as solid cover (with collision), the three dead cops (reuse the bodies / corpse system: `bodies.json`, `corpse_decay.json`), a gate the police come through, a way out to a short street with a payphone (reuse what quest 1 uses for the payphone; `payphone_router.json`). No wall on a zebra crossing. Reuse existing props, art and rigs; generate no art. Deterministic: no global RNG (`ctx.rng.stream(&"prologue")`), sim steps on `SimClock.TICK_DT`. Commit each working piece separately. A unit test that the layout loads and the cover is solid.

## Owned files (allowlist). Any other path: stop and write `NEED <lane>: <file> <why>` in your report
- `project/boot/prologue/**`, `project/dev/prologue/**`, `project/dev/bots/prologue_*`
- `project/data/tables/prologue_*.json`, `project/data/schemas/prologue_*.schema.json`
- `project/data/tables/enemies.json` (ONLY adding the two rows); `project/data/tables/bosses.json` (ONLY a new `mulroney` entry; not needed in this call)
- `project/tests/unit/test_prologue_*.gd`, `project/tests/golden/prologue/**`, `project/tests/scenarios/scenario_prologue_*.gd`
- append-only, one line each: `project/boot/launch_args.gd` KNOWN_FLAGS, `tools/debt/baseline.json` (only through the debt tool), `docs/decisions.md`
- Forbidden (other lanes; read-only): `project/boot/collect_call/**`, `project/boot/quest1*`, `project/features/player/**`, `project/features/gauntlet/**`, `project/features/combat/**`, `project/features/souls/**`, `combat.json`, `gauntlet*.json`, `input_actions.json`, `test_player.json`, `tools/gauntlet/**`, every existing tape and golden.

## Law
- AGENTS.md and STANDARDS.md bind. Typed GDScript, files about 200 lines (hard 300), functions of 40 lines or fewer, at most 5 parameters. `Log`, not print. UI text through `tr()`. InputMap actions, no raw keycodes. Data is JSON with a schema.
- Fix lint and format findings in your own edits and go on (`node tools/lint/lint.mjs`, gdformat).
- Stage per path. No `git add -A/./-u`, no `commit -a`, no stash, no amend, no rebase, no reset --hard, never push.
- Tests: `node tools/tests/run_unit.mjs --select=test_prologue_lines` etc. The full suite at most once.
- Mutate only after a commit and only if time: `node tools/mutate/mutate.mjs --file=<main prologue .gd> --max=20`; quote killed/(killed+survived).
- Shipped scenes, quest 1, the 60 s replay and every existing tape stay byte-identical.
- Do not invent story or lines: text comes only from the owner file and drafts.

## Report at the end
Files changed, commits (sha + subject), commands run and their result lines (runner verdict, gauntlet before/after diff, unit result), what is left of step 2, any NEED.
