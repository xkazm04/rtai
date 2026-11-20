# Brief 09 (lane polish): give kerf_beat.gd back; measure the cost for real; voice-wash hook

You are resuming the cost session (a first start of this brief was stopped after one minute; `kerf_beat.gd` may
already be restored and staged: check `git status` and go on from there). Hard stop: **17:05 local time**. **Last commit by 17:00** at the latest. Order of
value: Part 0 > Part 0b > Part 1 > Part 2. Commit each part separately as it goes green; if you run short, report exactly where
you stopped. Write the clock time at the start of each part in your report.

## Environment (every Godot / gate / perf run)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n21/appdata/polish`
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- "One Godot process at a time" is **per lane** (you and the director), NOT machine-wide. The other lane (kerf) runs its
  own Godot processes all evening; you can neither wait for them nor kill them. Kill only your own PIDs.
- Windowed runs use `--position 0,1440`. Nobody rebuilds native.

## Part 0 (5 minutes): restore a file this lane does not own
Commit 1123a9881 edited `project/dev/ghost-powers/kerf_beat.gd`, which belongs to lane kerf. Restore it exactly:
`git checkout int-n21 -- project/dev/ghost-powers/kerf_beat.gd` (it keeps its own `_nearest`; `GhostReel.nearest`
stays for `ohm_beat.gd`). Check `git diff int-n21 -- project/dev/ghost-powers/kerf_beat.gd` is empty, parse-check it
(`node tools/godot/check.mjs res://dev/ghost-powers/kerf_beat.gd`), commit "Give kerf_beat.gd back its own nearest".
From then on every `kerf_*` file is forbidden.

## Part 0b (15 minutes, committed by 16:30): a plain blink in Kerf's attack take (lane kerf asked for it)
Lane kerf: "`project/dev/ghost-powers/ghost_review_input.gd` Kerf's attack take presses only slices (t 28/77/126/200,
every press finds a guard); the owner never sees a plain blink (no target, 4 m dash, after-image) in `kerf_attack_32`.
Wish: one press at a moment with no guard within 9 m / 35 degrees of aim."
- In the `&"kerf"` branch of the attack take, keep the slices at 28/77/126/200 exactly as they are and add ONE more
  `melee` press after the last slice, aimed away from every guard (the guards stand east of Rivet, at
  `Vector2(5,0)..(16,0.8)`; aim `Vector2.LEFT` or whatever direction has no living guard within 9 m / 35 degrees at that
  tick), late enough that the 200 slice has recovered and early enough that the take still shows the dash and its
  after-image before it ends (read the take length in this file). If the take is too short for that, turn the 200 press
  into the plain blink instead and say so.
- Prove it with a test (in `project/tests/unit/test_ghost_review_input.gd`, new or existing): at the new press tick the
  aim has no guard inside 9 m / 35 degrees, and the four slice ticks are unchanged. `node tools/tests/run_unit.mjs
  --changed` green, quick gate green; commit "Give Kerf's attack take one plain blink".
- Do NOT film Kerf (lane kerf re-shoots its own film). Do not touch any `kerf_*` file.

## Part 1 (target 30 minutes, done by 16:50): the cost table, measured
Your last run measured nothing because `launch()` in `tools/perf/polish_ghost_cost.mjs` waits for a machine with no
other Godot process. The lane law: "Performance numbers are CONTENDED unless measured under the bench lock". The lock is
the contract; the paired design and the A/A twin are what absorb the other lane's load.
1. Change the wait: wait at most 15 s for a clear scan, then launch anyway. Record per run `otherGodotAtLaunch` (count)
   and keep `otherGodotAfter` and the other-cores figure. Keep the lock checks exactly as they are (no lock = no run).
   Add a column "other Godot at launch (median)" to the first table of cost.md, and one sentence under it saying the
   machine was shared with lane kerf and the A/A floor is the noise measure. Update the test that pins the wait;
   `node --test "tools/perf/*.test.mjs"` green; lint green; commit "Run the ghost cost under the bench lock on a shared
   machine".
2. Run it: `node tools/perf/polish_ghost_cost.mjs --rounds=4 --until=<now + 25 min, ISO with +01:00>` (if a run takes
   longer than 25 s on average after the first round, stop after round 4 anyway; 4 rounds is the floor the tool
   accepts). It must hold `C:/Users/kazda/kiro/gtai-n21/bench.lock` and release it (verify it is gone afterwards).
3. Read the result yourself: for each ghost, spectral minus legacy p50 / p99 / CPU with the CI95 and the A/A floor, and
   the call (WIN / WASH / LOSS). If one ghost's spectral body costs more than its A/A floor, say which part of its
   body draws the most (count the nodes / draw calls / shader passes it adds over legacy from the scene tree in a
   short headless dump, no profiler work).
4. `cost.md` and `cost.json` land in `C:/Users/kazda/kiro/gtai-masters/n21/polish/cost/` (not in git). Delete the
   empty `runs-*` directories of the failed attempts.

## Part 2 (rest of the time, last commit by 17:00): the speaking apparition washes ghosts that draw their own body
Follow `evidence/briefs/06-voice-hook-tonnage-tests.md`, Part 1, exactly (its owned-file list, the restored assert,
the mutate line). Kerf keeps working through a default no-op; write in your report
`NEED kerf: implement <hook name> on Kerf's spectral body to wash its parts`.
Stills: only if a dev entry already shows the apparition speaking; otherwise skip them and say so (no new capture tool).
If at 16:50 Part 2 is not green, do not commit half of it: report the state and leave the tree clean
(`git checkout -- <your paths>` for uncommitted product edits only).

## Owned files (allowlist; any other path: stop and report a NEED, do not edit it)
- `tools/perf/polish_ghost_cost.mjs`, `tools/perf/polish_ghost_cost.test.mjs`
- `project/features/souls/ghost_*.gd`, `ghost_apparition*.gd`, `tonnage_*.gd`, `ohm_*.gd`, `dent_*.gd`, `hauler_*.gd`,
  their shaders, and their tests under `project/tests/unit/` (+ `.uid`)
- `project/dev/ghost-powers/*` except `kerf_beat.gd` (Part 0 only restores it); `project/tests/unit/test_ghost_review_input.gd`
- one line in `docs/decisions.md`
- FORBIDDEN: every `kerf_*` file, `project/data/tables/*` Kerf rows, anything under `project/features/souls/art/kerf/`.

## After each commit
- `node tools/tests/run_unit.mjs --changed` green (Part 2); `node tools/gate/quick.mjs` green.
- Mutate only Part 2's main file: `node tools/mutate/mutate.mjs --file=<file> --max=20 --lines=<changed lines>`; quote
  it. Skip mutate if it would run past 17:00 and say so.

## Repo law (binding)
- AGENTS.md / STANDARDS.md; typed GDScript, functions <= 40 lines, files about 200 lines (hard 300), <= 5 params, `Log`.
- Stage per path. No `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push.
- Fix lint and format findings in your own edit and go on.
- No sim, replay, parity or bake digest may move. Teal only for souls.

## Report back
Per part: files, commit, tests, the cost table (both tables, verbatim), mutate line, NEEDs, what was not done and why.
