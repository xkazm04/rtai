# Brief 07 (lane polish): what the spectral bodies cost, measured under the bench lock

Hard stop: 50 minutes after you start (write the stop time down at the start). Last commit 8 minutes before it.
The director already checked step 1: no launch flag starts Rivet in a ghost form in the fight-gate scenes (`--rivet-form` is the cast size, not a ghost form). Skip step 1 and go straight to step 2 (`ghost_review.tscn`). Keep the driver small: 4 paired rounds per ghost if 6 do not fit, and say so.

## Environment
- `export APPDATA=C:/Users/kazda/kiro/gtai-n21/appdata/polish`
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- One Godot process at a time; windowed runs use `--position 0,1440`; kill only your own PIDs. Nobody rebuilds native.

## The bench lock (machine-wide, two lanes share the machine)
`C:/Users/kazda/kiro/gtai-n21/bench.lock`: create it **exclusively** before any timed run (e.g.
`node -e "require('fs').writeFileSync('C:/Users/kazda/kiro/gtai-n21/bench.lock', 'polish '+Date.now(), {flag:'wx'})"`),
delete it when the timed runs end (also on failure). If it exists and is younger than 20 min, do not run: do the
non-timed preparation, then retry every 5 min. If it is older than 20 min it is stale: delete it and take it.
Numbers measured without the lock are CONTENDED and must be labelled so; the goal is numbers that are not.

## Goal
For Tonnage, Dent and Ohm: frame cost with the spectral body vs `--ghost-look=legacy`, same scene, same ticks,
paired rounds. Kerf is not measured (being rebuilt in another lane).

## How
1. First find a timed scene that actually **draws a ghost body**. Read `tools/perf/fight_gate.mjs` (its scenes are
   reel chapter 18 city fight and the arena horde, both with Rivet, in the exported `windows-showcase` build) and
   `project/dev/bench/rig_bench.gd` (RigStress at 50 and 200 people). Check whether either can run with Rivet in a ghost
   form (a launch flag that starts in a form, e.g. grep `KNOWN_FLAGS` in `project/boot/launch_args.gd` for form/ghost
   flags). If one can: use `node tools/perf/fight_gate.mjs --arms=legacy:<flags> --ghost-look=legacy ...,spectral:<flags>
   --ghost-look=spectral --rounds=6` per ghost (its A/A twin gives the noise floor), and the rig bench likewise if the
   ghost can be added there.
2. If neither scene can show a ghost without new code, measure with `project/dev/ghost-powers/ghost_review.tscn`
   (`--ghost=<id> --take=move|attack --look=...`): windowed d3d12, `--position 0,1440`, `--fixed-fps 60`,
   `--disable-vsync`, at 32 px/m, for the same ticks; record per-frame wall time (an existing frame-log flag or the
   perf tools' frame log: read `tools/perf/stats.mjs` / `ab.mjs` for the format they read), 6 paired rounds,
   order rotated per round, plus an A/A pair. Put the driver in `tools/perf/polish_ghost_cost.mjs` (new, yours) with a
   Node test of its pure parts. Commit it before running.
3. Table: per ghost x look: frame p50 / p99 / worst / frames over 25 ms, process CPU s, the paired delta spectral -
   legacy with CI95, and the A/A floor. Write `C:/Users/kazda/kiro/gtai-masters/n21/polish/cost/cost.json` and
   `cost.md` (the table + the exact commands + whether every run held the lock + the machine's other load). If a ghost
   costs visibly more than its legacy body (delta above the A/A floor), find where with one A/B that turns off one
   piece at a time if a flag exists for it (glow, morph, plume/tail, light pool): name the piece.
4. Commit only tools and tests (`tools/perf/polish_ghost_cost*.mjs`); results stay outside git.

## Owned files (allowlist; any other path: stop and report a NEED)
- new `tools/perf/polish_ghost_cost.mjs` and `tools/perf/polish_ghost_cost.test.mjs`; `project/dev/ghost-powers/*`
  except `kerf_beat.gd` (only if a frame-log flag is truly needed there, declared in the entry's `KNOWN_FLAGS`).

## Repo law (binding)
- AGENTS.md / STANDARDS.md. Stage per path; no `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase,
  no reset --hard, never push. Fix lint and format findings in your own edit and go on.
- Unmeasured is never zero: a number you could not take is "not measured", with the reason.

## Report back
The table, the files, commits, whether the lock was held for every timed run, and what you could not measure and why.
