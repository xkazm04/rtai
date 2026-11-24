# Brief n27-pressure-04-contrast: the late dash damage traced, the sword's cadence contrast measured and filmed

Launched about 06:12. **Hard stop 07:15** (report and END by then). Commit each finished part as soon as it passes,
the first commit by 06:40. No product behaviour changes in this call (dev takes, tests, tools and evidence only; no
`project/data/**`, no `project/features/**`). No balance values change tonight.

## Context

Your call 3 is accepted (commits a382890e5, dfe3c9ab1, 72c9e1754, 4ea2a8d2c). Two open points from it are this call:

- `pair_dash` seeds 3 and 5 lose 50.9 and 40.6 HP although their HP at 10 s was 97.6 and 99.9; you did not trace it.
  The owner reads "dash across each line = safe" from the film, so the director must know what hits him after 10 s.
- `blade6`: the shipped plasma sword is single-swing, 33 ticks (8 wind-up + 6 active + 19 recovery), and deflects only
  in its 6 active ticks. The riflemen fire pairs 18 ticks apart, so the second round of every pair arrives mid-swing
  (650 of 1300). The owner should see what the sword does when rounds do NOT arrive inside its recovery: a measured
  contrast, not a retune.

## Godot is held until `evidence/n27-pressure/medians/whatif/DONE` exists

The director's what-if batch (two arms, a temp worktree) runs until about 06:35. Read and write code first; start Godot
only after that file exists. One Godot process at a time. When your last Godot run ends, write
`evidence/n27-pressure/godot-free-4.txt` with the time.

## Tasks, in order

1. **Trace the late dash damage.** Run `pair_dash` seeds 3 and 5 (and one clean seed for contrast) and log each HP drop
   after tick 600: tick, amount, source (direct / splash / other, as your split already does), Rivet's motion phase,
   his distance to the circle radius and to each trooper, and whether a dash press was refused by the cooldown. Name
   the cause in one or two plain sentences (for example: the circle drifts and the troopers' lead lands; a volley falls
   inside the 40-tick cooldown; Rivet runs into a burst). Write it to `evidence/n27-pressure/takes/dash_late.md` with
   the per-drop table. If the cause is a fault in the take's bot (not the game), fix it in the take only if the fix is
   one or two lines, re-run the pair_dash seed table, and say so beside the old numbers; otherwise keep the take and
   report the cause. Do not change game code to fix it.
2. **A cadence contrast take for the sword**: a new take `blade6_spaced` (in `project/dev/gauntlet/`, beside `blade6`):
   the same three riflemen at 6 m and the same plasma sword, but rounds reach Rivet at least 34 ticks apart, so every
   round can meet a fresh swing. Do it in the take only (dev code), for example one rifleman firing, or the take
   gating which rifleman may fire, never by editing `enemies.json`/`weapons.json`/`combat.json`. State exactly how the
   spacing is made, in the caption note and in `seeds.md`. Run seeds 1 to 10 and add a `blade6_spaced` section to
   `evidence/n27-pressure/takes/seeds.md` / `seeds.json` with the same columns as `blade6` (fired, returned, passed,
   struck, share, unswung hit, mid-swing), pooled with a Wilson 95 % interval for (a) the share of returns that hit a
   shooter and (b) the share of fired rounds turned back. Beside it, the same two numbers for `blade6`.
   Add `blade6_spaced` to `test_pressure_takes.gd`: assert the spacing (no two rounds within 34 ticks at Rivet), that
   it returns a larger share of fired rounds than `blade6` on seed 1, and that it never hits Rivet mid-swing.
3. **Film it**: `blade6` (left) beside `blade6_spaced` (right), same seed 1, 32 px/m, tilt 70, 1920x1080, 60/1,
   15 to 40 s, H.264 crf 23 (use `tools/gauntlet/pressure_films.mjs`; add an entry, keep the existing ones re-runnable),
   caption per side: `Fired %d  Returned %d  Passed %d  Hit a shooter %d  Turned back %d%%`. Output
   `C:/Users/kazda/kiro/gtai-masters/n27/pressure/blade_cadence_32.mp4`; check with `ffprobe` and quote it. One 64 px/m
   still `blade_spaced_return_64.png` at a tick where the spaced sword visibly turns a round back (look at the PNG with
   your image tool and describe it). Add both to `frames.json` (keep 8 to 15 entries, best first; insert the film as
   entry 3, the still near it; drop `trooper_pair_64.png` if the list would pass 15). Notes in plain English for the
   owner, no class names, each with the pooled 10-seed number.
4. If time is left after 3: mutate the new take,
   `node tools/mutate/mutate.mjs --file=dev/gauntlet/<new take file> --max=10 --tests=test_pressure_takes`, append the
   score to `evidence/n27-pressure/mutate/scores.md` as section 3c.

## Files (allowlist; any other path: stop and write NEED in your report)

`project/dev/gauntlet/**` (with `.uid`), `project/tests/unit/test_pressure_takes.gd`, `tools/gauntlet/pressure_films.mjs`,
`evidence/n27-pressure/takes/**`, `evidence/n27-pressure/mutate/scores.md` (append), `evidence/n27-pressure/godot-free-4.txt`,
`C:/Users/kazda/kiro/gtai-masters/n27/pressure/**`, `tools/debt/baseline.json` only through
`node tools/debt/debt.mjs --update --accept-regression="<reason> for n27 pressure"`.
**Forbidden**: `project/data/**`, `project/features/**`, `project/boot/**`, `JOURNAL.md`, `REPORT.md`,
`evidence/n27-pressure/medians/**`, every other lane's worktree and files (`n23-controls`, `n23-street`,
`n23-prologue`, `n25-yard`).

## Machine rules

- Before any Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/pressure` and
  `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`; rendering runs
  add `--rendering-driver d3d12`; any windowed run `--position 0,1440` (never the main display). Free your own
  processes by PID; never kill by name.
- After new scripts land, one Godot `--import` before committing (new `.uid` files must be committed). Fix lint and
  format findings in your own edit and go on. If the pre-commit hook fails on `tools/film/kill_reel_*.break.test.mjs`,
  run a Godot `--import` and commit again; never `--no-verify`.
- Mutate capped: `--max=10`, the named test only.

## Repo law

AGENTS.md and STANDARDS.md: typed GDScript, ~200 lines a file (hard 300), functions <= 40 lines, <= 5 params, `Log`
not `print`, deterministic (fixed tick, RNG registry; no global randf/randi). Stage per path; `git commit -- <paths>`.
Banned: `git stash`, `git add -A/./-u`, `commit -a`, `reset --hard`, amend, rebase, push.

## Report

Commits; the cause of the late dash damage in plain words with its table path; how the spacing is made; the
`blade6_spaced` pooled numbers beside `blade6`'s (with intervals); ffprobe of the new film; what you saw in the still;
the frames.json order; mutate score if run; anything undone and why.
