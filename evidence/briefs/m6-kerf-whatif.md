# Brief m6 (lane moves, n23, follow-up of m4b's probe): Kerf blink behind in kill time, at a slice that no longer one-shots

Wall clock: start 06:50. **Commit deadline 07:45. Hard stop 07:52.** If the work is not green by 07:42, commit nothing and report what you have. Setup: `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/moves`, `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`, one Godot at a time for this lane (the director runs none while you work), `--position 0,1440` on anything windowed.

## Why

`evidence/moves/ttk.md` shows Kerf blink behind at 0.02 s both arms: the slice uses the 99-damage GUARD row, so one slice kills every new enemy whether it lands on the front plate or the back. The bypass only shows in kill time once a slice no longer one-shots. The owner judges this lane by four off/on kill-time pairs; Kerf's pair is currently empty of information.

## What to build (dev probe only, no product or data change)

1. In the probe `project/dev/moves/move_ttk*.gd` add one flag `--slice-k=<float>` (default 1.0, declared in `move_ttk.gd` `KNOWN_FLAGS`) that scales Kerf's slice damage **in the probe only** (an in-memory override of the loaded row or a scaled target HP that is mathematically the same: say which and why in the md). `ghost_attacks.json`, `enemies.json` and `combat.json` stay byte-for-byte as they are.
2. Run the Kerf rows with `--move=kerf_blink_behind --seeds=10` at `--slice-k=0.1` (slice 9.9: shield robot front ~2 vs hp 10, rear 9.9) and `--slice-k=0.2` (19.8), shipped HP, same seeds, same pilot. The pilot must keep slicing until the kill (repeated blinks on cooldown, re-approaching as today's pilot does); if the pilot only ever slices once, extend it so it repeats. Report per target (shield robot, war machine with its plate closed, sentry turret): median kill time off/on, paired delta, faster count, slices to kill off/on.
3. Write the result to `evidence/moves/ttk-kerf-whatif.json` and a short section `## Kerf at a lower slice (probe-only what-if)` appended to `evidence/moves/ttk.md` (table + 3 lines of plain-words reading; say clearly it is a what-if, the shipped slice still one-shots).

## Checks before the commit

- `node tools/lint/lint.mjs` green (if `dev_loc` debt rises: authorised, `node tools/debt/debt.mjs --update --accept-regression="move_ttk slice-k what-if for n23 moves"` and stage `tools/debt/baseline.json`).
- `node tools/gate/quick.mjs` green.
- `node tools/tests/run_unit.mjs --changed` green.
- One commit, staged per path: the probe files, `evidence/moves/ttk.md`, `evidence/moves/ttk-kerf-whatif.json`, the baseline if touched.

## Report

The commit sha, the table, the lint line, and the exact command you ran.

## Law

Allowlist: `project/dev/moves/move_ttk*.gd` (+ `.uid` of any new file), `evidence/moves/ttk.md`, `evidence/moves/ttk-kerf-whatif.json`, `tools/debt/baseline.json` (through the debt tool). Any other path: stop and report a NEED. Forbidden: every file of the other lanes (`project/features/gauntlet/**`, `project/features/player/**`, `project/boot/prologue/**`, `tools/gauntlet/**`, ...), all data tables. Typed GDScript, files under 200 lines (300 hard), functions 40 lines or fewer, 5 parameters max, `Log` not `print` (a dev probe's `printerr` usage stays as the file already does). No `add -A/./-u`, `commit -a`, stash, amend, rebase, reset --hard, push. Fix lint and format findings in your own edit and go on. No mutate run needed (dev probe).
