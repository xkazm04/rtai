# Brief n29-11 `gate-lamp`: the gate lamp casts a visible warm pool again without losing the pellet (lane yard, run n29, brief item 5)

HARD STOP: 06:12 local (report and END). First commit by 05:48. LAST COMMIT started by 06:00 (never after 07:15). Check `date` often. Never let the call end before its commit. If no value passes the bars by 06:00, commit NO table change: commit the sweep table only.

## Setup
Repo worktree `C:/Users/kazda/kiro/gtai-wt/n25-yard` (branch `n29-yard`). Bash with absolute paths. Every shell that runs Godot:
```
export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
```
`--rendering-driver d3d12`; windowed runs `--position 0,1440`. Godot only through repo tools (`tools/art/prologue_yard_film.mjs`, `tools/dev/run.mjs`, `tools/tests/run_unit.mjs`, the `evidence/yard29/art_sweep.sh` / `bars.sh` method if it goes through them; check, and if a script calls `$GODOT_BIN` directly for a render, route that render through `tools/art/prologue_yard_film.mjs` instead) except a plain `--import`. Builder `impression-evidence` (film, stills; hard stop 05:58) shares this lane's single Godot slot with you (`build/yard-godot.lock`: create it with noclobber as `gate-lamp ...`, delete when your Godot exits; never delete another's unless older than 25 min). 16 GB cap: `mem-budget: waiting` = wait. Kill only PIDs you started.

## Where it stands
n27: the gate lamp (`arched_line.lights.kinds` id `yard_lamp_gate`, intensity 0.1, radius 9, `floor_glow.strength` 0; pool `gate_lamp` at about (?, 32.3)) lost its floor glow because a glow there dropped the pellet (shotgun) bar under 90 % (`docs/day/2026-11-24/n27-yard/JOURNAL.md` 05:21). The light layer tints actors; the floor glow lights the floor only. Bars and how they are measured: `evidence/yard29/floor_i55_bars.md`, `evidence/yard29/readability.py`, `evidence/yard29/art_sweep.sh`, `evidence/yard29/bars.sh` (gate camera, i55 today: patrol 80.6 / 88.7 %, rifle 104.5 %, pellet 100.9 %).

## Work
1. Sweep `arched_line`'s `yard_lamp_gate` only (edit the arched_line row; never the other rows): `floor_glow.strength` 0 (today) / 0.06 / 0.10 / 0.15, `floor_glow.radius_m` 5 (smaller than today's 8 so the pool sits at the lamp, not across the gate lane); if the schema allows a pool offset, keep the pool at the lamp's foot. Per value: the gate bars (patrol inside / between >= 65 %, rifle >= 95 %, pellet >= 90 %) and the pool gain (mean floor luminance inside the pool minus a ring outside, today's method in `floor_i55_bars.md`). One table `evidence/yard29/gate_lamp_sweep.md`.
2. Take the strongest value that keeps every bar; LOOK at a 32 px/m gate still (`--place=gate --tick=6400`) and say whether a warm pool reads at the lamp. Commit the one-row data change + a unit pin in `project/tests/unit/test_prologue_raised_line.gd` (the arched_line gate lamp glow value) + the sweep table. `node tools/tests/run_unit.mjs --select=test_prologue_raised_line,test_prologue_yard_lights`, `node tools/gate/quick.mjs`.
3. Stills: `evidence/yard29/gate_lamp_before_after_32ppm.png` (strength 0 | chosen, same tick) and `evidence/yard29/gate_lamp_64ppm.png`; copy both to `C:/Users/kazda/kiro/gtai-masters/n29/yard/` and append two `frames.json` entries (keep best first, do not reorder). Pilots seeds 7/3/11/21/42 identical to `evidence/yard29/prologue-yard-pilots-props.json` (one Godot process) to `evidence/yard29/prologue-yard-pilots-lamp.json`. Commit.
4. ONE `docs/decisions.md` line: `- [2026-11-25] DECISION yard n29 gate lamp: ...` (value, bars, rejected values).

## Owned files (allowlist). Any other path: stop and report a NEED.
`project/data/tables/prologue_yard_dressings.json` (`arched_line.lights` `yard_lamp_gate` only), `project/tests/unit/test_prologue_raised_line.gd`, `evidence/yard29/gate_lamp_*`, `evidence/yard29/prologue-yard-pilots-lamp.json`, `build/**`, `docs/decisions.md` (one line), `C:/Users/kazda/kiro/gtai-masters/n29/yard/**` (two stills, two entries).

## Forbidden
`project/boot/**` code, `project/features/**`, `core/**`, every other row and table, the schema, other worktrees, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`, `hs_err_pid*.log`, `C:/Users/kazda/kiro/gtai-art/**`. No image generation; never `builder.mjs`, `astra.mjs`, `codex`.

## Repo law
Stage per path; `git commit -- <paths>`; no `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push, never `--no-verify`. Pre-commit hook up to 12 min (hold the slot lock across it). `kill_reel_*.break.test.mjs` failure in the hook = stale class cache: `--import`, commit again. Fix lint and format findings in your own edit and go on.

## Report (final message, then END)
Commit shas; sweep table; chosen value; what you saw in each still; pilots vs expected; what was not done.
