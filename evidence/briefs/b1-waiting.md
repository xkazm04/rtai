# Brief b1-waiting (lane foes, run n31): measure how long enemies wait to shoot

Worktree (your cwd): `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n31-foes`. Base `ba8e470b0` (= main).
Hard stop: **60 minutes after launch, report and END**. Commit each finished part as soon as its checks pass;
the first commit must land **within 25 minutes**. Never end with uncommitted work or a commit stuck in the hook.

## Why
The owner played the gauntlet and said: "AI is waiting to shoot too much, cops are just waiting until I can
closer to start shooting". Before anyone changes the AI we need a number for that complaint, measured on
the current code (this branch is still identical to main in `project/`). This brief builds the measuring
tool and runs the BEFORE. It must NOT change any game behaviour, digest or sim code.

## Build
1. **A read-only probe scene** `project/dev/foes_n31/waiting_probe.tscn` + `.gd` that
   `extends "res://dev/gauntlet/gauntlet.gd"` (same pattern as `project/dev/test_player/gauntlet_bot_film.gd`:
   override `_run_headless()`, call `session.step()` yourself and observe after each step, then hand over to
   `super._run_headless()`; or hook per tick another way that does not touch shared files). It accepts the
   gauntlet's flags plus its own `--waiting-out=<abs path>` (declare its flags properly so `tools/dev/run.mjs`
   accepts them; read how gauntlet.gd and `ArenaArgs` validate flags; if a flag must go into
   `project/boot/launch_args.gd` KNOWN_FLAGS, append one line and run
   `node tools/debt/debt.mjs --update --accept-regression="--waiting-out for n31 foes"`).
   Each tick, for every living wave member (`arena.squad_ai.owns(h)`, `h.alive()`, find the arena through
   `session.stage.arena` / `GauntletCombat`), read only: archetype id, ranged or melee
   (`EnemyRoster` archetype `weapon.melee`), position, distance to Rivet, clear line
   (`GuardRouteMap.sight_line(h.pos, rivet.pos)` with the squad's map), whether it fired a round this tick
   (a Shot produced for it: find the reliable signal, e.g. `mind.agent.shot_tick == tick`, `h.burst_left`
   change, or the arena's shot list; verify against the per-wave `shots` the run result already counts),
   whether it is winding up / in a burst (`EnemyAgent.State.WINDUP` / `FIRE`), whether it holds a token,
   its speed this tick, and its `attack_m`. Melee kinds are recorded but reported separately.
   Wave number from `waves` / `run`. Rivet damage taken and deaths per wave (the run result has
   `damage_taken`; a death = run ends in that wave).
   Write per run one JSON `gtai.foes-waiting/1` with per-wave, per-archetype aggregates:
   - `react_s`: list of seconds from an enemy first having a clear line to Rivet **inside its weapon range**
     (record also the variant "clear line at any distance") to its first shot; enemies that never fire
     before death/wave end are counted separately (`never_fired`, with how many of those had a clear line).
   - `shot_dist_m`: distance of every round fired (for a histogram, 2 m bins).
   - `clear_s`, `clear_idle_s`: enemy-seconds with a clear line, and of those with no round fired and not in
     WINDUP/FIRE/burst. **idle share = clear_idle_s / clear_s** is the headline number.
   - `firing_per_s`: per second of wave time, how many enemies fired at least one round in that second
     (mean, p50, max); also `ranged_alive` mean.
   - `token_s` enemy-seconds holding a ranged token.
   - `damage_taken`, `died` per wave; `seconds` per wave.
2. **A node tool** `tools/gauntlet/waiting.mjs` (+ `waiting.test.mjs`, node:test, on a small fixture under
   `tools/gauntlet/fixtures/waiting/`): `--profiles=novice,average --seeds=10 --seed0=1 --out=<dir>
   [--rev=<commit>] [--from=<dir>]`. It runs the probe once per profile x seed through `tools/dev/run.mjs`'s
   `main` or `runGodot` (never a raw Godot), sequentially (ONE Godot at a time), `--controls=wheel`,
   `--pick=greedy` (check what `tools/gauntlet/commands.mjs` `entryArgs` passes for a gauntlet bot run and
   mirror it). It stops each run after wave 7 (find whether `--waves=7` means "run 7 waves"; wave 5 is the
   stomp: measure it but leave it out of the summary table). Then it aggregates over seeds per profile:
   a markdown table per wave (1-4, 6-7) x ranged archetype: n enemies, react median/p90 (in-range and
   any-distance), never fired, idle share, shot distance p10/p50/p90, firing-per-second mean, damage taken
   mean, deaths; and a totals row for waves 1-4 and 6-7. Writes `waiting.json` + `waiting.md`.
   `--from` re-aggregates existing run files without Godot. Waves a bot did not reach are shown as
   "not reached (k/10 seeds)", never as zero.
   If the bot rarely reaches waves 6-7, check whether the gauntlet has a start-wave flag (grep
   `GauntletWaves`, `ArenaArgs` in gauntlet.gd); if it exists, use it for a second pass over waves 6-7;
   if not, report reach and do not add one to shared files.
3. **Run the BEFORE**: both profiles, seeds 1-10, into `evidence/n31/foes/waiting-main/` (commit the
   `waiting.md`, `waiting.json` and the per-run JSON if under 2 MB total; otherwise only the summary).
   Note the wall time per run in your report.

## Acceptance
- The probe does not change a single gauntlet result: for seed 1 average wheel, the run result JSON of the
  probe equals plain `gauntlet` with the same args (diff them; same `waves`, `shots`, `damage_taken`).
- The `shots` your probe counts per wave equal the run result's `shots` for that wave on 3 seeds (or you
  explain exactly what the run result counts instead).
- `node --test "tools/gauntlet/waiting.test.mjs"` green; `node tools/lint/lint.mjs` green for your files;
  `node tools/godot/check.mjs res://dev/foes_n31/waiting_probe.gd` ok.
- `evidence/n31/foes/waiting-main/waiting.md` exists with numbers for both profiles.

## Repo law (from AGENTS.md / STANDARDS.md; read AGENTS.md first)
- Typed GDScript, warnings are errors, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params,
  `Log` not `print`. Every new `.gd` gets its `.uid` committed (run one Godot `--import` via
  `tools/lib/godot.mjs`, e.g. `node tools/godot/check.mjs`, or the importer the repo uses, before commit).
- Stage per path (`git add <path>`), one commit per finished part, `git commit -- <paths>` is fine.
  Banned: `git stash`, `git add -A/./-u`, `git commit -a`, `reset --hard`, amend, rebase, push.
  Commit message ends with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Fix lint and format findings (gdformat, gdlint, node lint) in your own edit and go on. The pre-commit hook
  can take ~12 minutes on this machine: never skip it (`--no-verify` banned). If the hook fails on a
  `kill_reel_*.break.test.mjs`, the class cache is stale: run a Godot `--import`, commit again.
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/foes` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
  Launch Godot only through `tools/lib/godot.mjs` users (`tools/dev/run.mjs`, `tools/godot/check.mjs`,
  `tools/tests/run_unit.mjs`, your tool). **One Godot at a time for the whole lane**: hold the lane lock
  `build/n31/godot.lock` (create it exclusively with your tag `b1` and pid; wait while another tag holds it;
  delete it when your Godot exits; never delete a lock that is not yours). A `mem-budget: waiting` line
  means the machine is full: wait, note the minutes in your report.
  Windowed runs (you should need none): `--position 0,1440`.
- Never touch `main`, other worktrees, `C:\Users\kazda\kiro\pof`. No Codex, no API keys.

## Owned files (allowlist; any other path: stop and report a NEED)
- `project/dev/foes_n31/**` (new), `tools/gauntlet/waiting*.mjs`, `tools/gauntlet/fixtures/waiting/**`,
  `evidence/n31/foes/**`, one appended line in `project/boot/launch_args.gd` KNOWN_FLAGS if needed,
  `tools/debt/baseline.json` only through the debt tool.
- Read-only: everything else, in particular `project/dev/gauntlet/**`, `project/features/**`,
  `project/data/**`. Forbidden: other lanes' areas (player, prologue, souls, kills, weapons).
  Do not append to `docs/decisions.md` (the director does that).

## Report (your final message)
Files, commits (hash + subject), commands you ran with their result line, the BEFORE headline numbers
(per profile: react median/p90, idle share, never-fired, firing per second, damage taken per wave 1-4,
deaths, waves reached), wall time per run, what you could not do and why.
