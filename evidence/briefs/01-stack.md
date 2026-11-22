# Brief 01 (street lane, n23): a timed-out wave stacks

Hard stop: 02:15 wall clock (check `date`). Commit deadline: 02:05. If you are not done, commit what is green and report what is left.

## Setup for every Godot run
`export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/street` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Any windowed run: `--position 0,1440`. Never kill processes by name; only by a PID you started.

## Goal (owner: "The next wave starts on top of what is left, until Rivet dies." and "Keep him held until the wave is down.")
Today in `project/features/gauntlet/gauntlet_waves.gd`, when a wave runs 90 s (`TIMEOUT_TICKS`) the run ENDS (`death_by = timeout`). Change it:

1. `project/data/tables/gauntlet.json` gains `"on_timeout": "next_wave"` and `"max_alive": 40` (top level, sorted keys; update `project/data/schemas/gauntlet.schema.json`: `on_timeout` enum `["next_wave"]`, `max_alive` int >= 1). Read the wave timeout from the table too if cheap (`wave_timeout_s`: 90), otherwise keep the const.
2. When the timer runs out on the newest live wave: compose and spawn the next wave (`_composer.compose(_run.wave + 1)`) in the SAME block, while the old wave's enemies stay alive and keep fighting. The timer restarts for the new wave. The old wave's result row gets `"timed_out": true`. It repeats: wave 3 can land on waves 1 and 2. The boss wave (every 5th) may arrive on top (decided: yes).
3. Rivet stays held in the block (`_street.forward_limit`) until EVERY enemy of every live wave is down. Only then the street opens.
4. No pick screen on a timeout. When the street is clear, Rivet is owed one pick per wave cleared since the last pick (stacked ones included; decided: all are given). Offer them one after another: `pending` holds the current offer; a public counter says how many remain; each `choose()` draws the next offer until none is owed. The headless bot picks all of them in sequence through the same path as today. Expose the owed total and the current index (e.g. `owed_total`, `owed_index`) so the pick view can later show "pick 2 of 3".
5. Live cap: never more than `max_alive` live gauntlet hostiles. When a wave's roster would exceed it, spawn what fits and spawn the rest (roster order, deterministic) on later ticks as members die. Write `spawn_delayed` (int, how many members of that wave were delayed) on every wave row: the cap is evaluated every wave, so 0 is a measured value there. A wave's timer starts when its first member spawns.
6. Per-wave accounting: each live wave keeps its own member list. Hits, contacts and kills count to the wave whose member was hit. A wave row is closed (stats `finish`, `seconds`) when its last member falls; for a timed-out wave `seconds` is still its spawn-to-last-death time (it may exceed 90). Keep `GauntletWaveStats` working; one stats object per live wave is acceptable. Keep `_run.waves[-1]` meaning the newest wave: the loop lane's bot `project/features/gauntlet/bot/bot_street_stats.gd` writes `shots` into `_run.waves[-1]`. Read it, do NOT edit it; if stacking breaks it, report `NEED loop: <what>`.
7. End of run: only Rivet's death (or `--waves=N` reached and cleared, as today). `death.wave` = the newest wave running when he died. `death_by` is never `timeout` any more.
8. Tick cap: in `project/dev/gauntlet/gauntlet.gd` raise `RUN_TICKS` 72000 -> 216000 (one hour) and fix the header comment. When the cap is hit, the result gets top-level `"capped": true` (a `capped` var on `GauntletRun`, written only when true); keep today's exit behaviour otherwise. Check `tools/dev/run.mjs` picks up the new RUN_TICKS (it reads the const).
9. HUD (`project/dev/gauntlet/gauntlet_hud.gd`): the wave label shows the wave number and, when more than one wave is alive, how many (e.g. "WAVE 7 - 3 ALIVE"). Text through `tr()`; add the key beside the existing `GAUNTLET__WAVE` key (grep for it; name that file in your report). `wave_seconds()` returns the newest wave's timer.
10. Result schema `project/data/schemas/gauntlet_run.schema.json`: add optional `timed_out` (const true) and `spawn_delayed` (int >= 0) on a wave row, `capped` (const true) at top level, each with a description. Make `tools/gauntlet/test_run_schema.py` pass (read it to see how it runs).

Keep files about 200 lines (hard 300), functions <= 40 lines, <= 5 params, typed GDScript, `Log` not print. `gauntlet_waves.gd` is already 199 lines: move per-wave bookkeeping into a new file, e.g. `project/features/gauntlet/gauntlet_live_wave.gd` (class `GauntletLiveWave`: members, stats, hits, contacts, start tick, not-yet-spawned roster, row) and, if needed, `gauntlet_owed_picks.gd`. New `.gd` files need their `.uid` committed (run `"$GODOT_BIN" --headless --path project --import` once).

## Tests (yours to write)
Extend `project/tests/unit/test_gauntlet_waves.gd` and/or add `project/tests/unit/test_gauntlet_live_wave.gd`:
- a timeout spawns the next wave while the old members still live, marks the old row `timed_out`, and keeps `forward_limit` closed;
- the street opens and picks are owed only after all are down; N stacked waves give N picks in a row;
- the cap delays spawns and counts `spawn_delayed`; delayed ones arrive as others die;
- `death.wave` is the newest wave.
Read the existing test file first for how it builds a session cheaply.

## Acceptance checks (run them, quote results in your report)
- `node tools/gate/quick.mjs` clean. Fix lint and format findings in your own edit and go on.
- `node tools/tests/run_unit.mjs --changed` green, plus `--select=test_gauntlet_waves,test_gauntlet_run,test_gauntlet_pick_view,test_gauntlet_composer,test_bot_street_stats,test_gauntlet_wave_stats`.
- `node tools/dev/run.mjs gauntlet --seed=7 --bot=average --result=C:/Users/kazda/kiro/gtai-wt/n23-street/build/gauntlet/s7a.json` ends in Rivet's death with a schema-valid result. Run it a second time to `s7b.json` and `cmp` the two: byte-identical. Report wave reached, how many rows have `timed_out`, the most waves alive at once, total ticks, wall time.
- Find a seed and bot level where 2 and 3 waves are alive at once (try novice and average, seeds 1..5); report it (the director films it).
- Quest 1 and the 60 s replay are untouched: run the scenario suite (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`; read the file for an `--only` option) and quote the summary line.
- `node tools/debt/debt.mjs --check`; if it prints `tighten:`, run `--update` and commit the baseline.

## Commit
One or two commits, staged per path (`git add <path>`; never `-A`, `.`, `-u`, `commit -a`, stash, amend, rebase, reset --hard, push). Message style: see `git log`. End messages with
`Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`.
After committing run `node tools/mutate/mutate.mjs --file=project/features/gauntlet/gauntlet_waves.gd --max=20 --lines=<changed lines>` and quote killed/(killed+survived). The same for the new live-wave file if time allows.

## Allowlist (edit only these)
`project/features/gauntlet/**` EXCEPT `project/features/gauntlet/bot/**`; `project/dev/gauntlet/**`; `project/data/tables/gauntlet.json`; `project/data/schemas/gauntlet.schema.json`; your optional fields in `project/data/schemas/gauntlet_run.schema.json`; `tools/gauntlet/test_run_schema.py` only for added asserts on your new fields (the loop lane owns it; say so if you touch it); new or existing tests named `test_gauntlet_*` for your files; the one translation key line; `tools/debt/baseline.json` through the debt tool; `.uid` files of your new scripts.
Forbidden: `project/features/gauntlet/bot/**`, `tools/gauntlet/*.mjs`, `project/features/player/**`, `project/features/combat/combat_arena.gd` (one-line call site at most; name it), `project/data/tables/enemies.json`, `combat.json`, `gauntlet_bonuses.json`, `project/boot/**`, JOURNAL.md, REPORT.md. Any other path: stop and report a NEED.
Do not change balance numbers (budget, costs, enemy rows) and do not change the composer's selection (that is the next brief).
