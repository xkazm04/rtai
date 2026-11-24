# Brief n27-pressure-01-takes: two dev takes (two-trooper circling, 6 m deflect) and their films

Launched about 02:55. **Hard stop 04:05** (report and END by then, whatever state). **Commit the takes by 03:40** (each
finished part as soon as its checks pass: aim for the first commit 25 minutes into the call). Films after the commit.

## Goal

The owner asked for two films he judges by (no balance change tonight, his words: "I play first and give numbers"):

A. **Two-trooper circling take.** Two rocket troopers (`rocket_trooper`, spawned as in `PressureTake._rockets()` via
   `arena.squad_ai.spawn_member(arena, at, &"rocket_trooper")`), Rivet circling them at about **10 m** without dashing;
   then the same seed and spawn with **a dash across each locked line** (dash when a rocket is launched/locked, sideways to
   its flight line, as `PressureTake._fight_input` "dash" does with `_last_rocket.vel.orthogonal()` and
   `BotProfile.shipped(&"average").dash_read_ticks`). Rivet does not shoot back (no kills: the troopers must keep firing for
   the whole take). Rivet's health in the caption, per side. The measured reference from n26 (one trooper, 10 m, arena
   `project/dev/gauntlet/rocket_arena.gd`, `evidence/n26-pressure/trooper/arena.md`): steady circling hit 48/48, circle +
   dash 0/48, one trooper kills a steady circler in about 13.4 s. Reuse `rocket_arena.gd`'s circling and lock logic where
   it helps.
B. **6 m deflect take.** Riflemen at **6 m** (today `PressureRifles.place` puts three at 9.5 m) against the **guard**
   and against the **plasma sword** (the "plasma bat" timed deflect), enough returned rounds to see the share: the
   measured curve (`evidence/n26-pressure/deflect/share.md`, 1000 rounds per cell) says **24.3 % guard, 30.6 % blade** at
   6 m. Aim for at least 30 returned rounds per take (about 30 to 40 s at today's 130-tick salvo beat; you may shorten
   the beat if it keeps the guard readable). Counts in the caption: rounds fired, returned, returns that hit a shooter,
   share in %, and the curve's figure beside it ("curve 24 %"). Shooters must not die and leave the take empty: if a
   returned round kills a rifleman, keep the count right (respawn or give them enough HP in the DEV take only, never in
   data) and say which in the caption note.

## Files (allowlist; any other path: stop and write NEED in your report)

- `project/dev/gauntlet/pressure_take.gd`, `pressure_rifles.gd`, `pressure_film.gd`, `pressure_film.tscn`, new files
  under `project/dev/gauntlet/` (with `.uid`), `tools/gauntlet/pressure_films.mjs` (add the new films; keep the old
  three working; you may add `--only=<file,...>` so the new ones can be filmed alone), new tests under
  `project/tests/unit/` for the new takes (headless: the circling take is hit, the dash take takes far less, the 6 m
  take returns >= 30 rounds and its share lies within a sane band of the curve).
- `tools/debt/baseline.json` only through `node tools/debt/debt.mjs --update` (with `--accept-regression="<reason> for n27 pressure"` if it rises).
- Film outputs: `C:\Users\kazda\kiro\gtai-masters\n27\pressure\` (create it) with `frames.json` entries
  `{ "file", "title", "ppm", "before", "note" }`. Scratch renders stay under `build/`.
- **Forbidden**: every data table (`project/data/**`: no balance values change tonight), `project/features/**`,
  `project/boot/**` (incl. `launch_args.gd`), every other lane's files (souls, player, prologue, cast art). Take flags
  go in the dev entry's own `const KNOWN_FLAGS`, not `launch_args.gd`.

## Films (the owner judges by these)

- 32 px/m, tilt 70 (`ViewMode.select("tilt70")` as `pressure_film.gd` does), 1920x1080, 60 fps, **15 to 40 s per clip**
  (`ffprobe`; the tool already checks this). One clip per item:
  - `trooper_pair_32.mp4`: circle vs circle+dash. Preferred: side by side at the same tick (two 960x1080 halves, or
    sequential if side by side costs too much), HP per side in the caption. If the steady circler dies before 15 s, keep
    the clip going on the dash side and caption the death time.
  - `deflect_6m_32.mp4`: guard then blade (or side by side), counts in the caption.
- One 64 px/m still per item: `trooper_pair_64.png` (a cased rocket on its line toward Rivet), `deflect_6m_64.png`
  (a returned round leaving the guard / blade).
- Look at every still yourself (Read the png) before writing frames.json: the rocket must be visible and Rivet in
  frame; the caption readable. Never fake a frame.
- frames.json: add the new entries first (best first), keep any other rows. `before`: null (these are new takes).

## Machine rules (read them, they bind)

- **Godot is held by the director's median batch until the file `evidence/n27-pressure/medians/main/DONE` exists**
  (expected about 03:25). Until then write code, run `gdformat`/`gdlint` (`node tools/lint/lint.mjs` is fine if it
  does not start Godot; if unsure, wait), and **write every .gd file in one piece so it always parses**: the batch's
  runner re-imports when the class cache goes stale. After DONE: one Godot process at a time.
- Before any Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/pressure` and
  `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`; add
  `--rendering-driver d3d12` for rendering; every windowed run `--position 0,1440` (secondary monitor, never the main).
- After new scripts land, run one Godot `--import` (`"$GODOT_BIN" --headless --path project --import`) before committing.
- Tests: `node tools/tests/run_unit.mjs --select=<your test basenames>`; `node tools/gate/quick.mjs` before each commit.
- Fix lint and format findings in your own edit and go on. If the pre-commit hook fails on
  `tools/film/kill_reel_*.break.test.mjs`, the class cache is stale: run a Godot `--import` and commit again (never
  skip the hook, never `--no-verify`).
- Free your own processes by PID; never kill by name.

## Repo law

AGENTS.md and STANDARDS.md. Typed GDScript, files about 200 lines (hard 300), functions <= 40 lines, <= 5 params,
`Log` not `print`, no global RNG (the takes are deterministic: fixed 60 Hz tick, `--fixed-fps 60`). One commit per
change, staged per path (`git add <path>`; `git commit -- <paths>` is fine). Banned: `git stash`, `git add -A/./-u`,
`commit -a`, `reset --hard`, amend, rebase, push. Commit `.uid` files with new scripts.
No mutate run in this call.

## Report

End with: commits (sha + one line), the measured numbers per take (HP at the end and at 10 s, hits per side; fired /
returned / shooter hits / share per deflect take), the film files with ffprobe durations, anything left undone and why.
