# Brief 05 (lane polish): Ohm's top view carried by the jars and the fork; pin what OhmSpirit draws

Hard stop: 50 minutes after you start (write the stop time down at the start). Last commit 10 minutes before it.
Order of value: the top-view read (part 1) > the tests (part 2). Commit what is green; report where you stopped.

## Environment (every Godot / gate / film run)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n21/appdata/polish`
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- One Godot process at a time; windowed runs use `--position 0,1440`; kill only your own PIDs. Nobody rebuilds native.

## Look first (open these images)
- The plate's top inset (top right of `C:/Users/kazda/kiro/gtai-masters/n20/concepts/ohm_c.png`): from straight above,
  Ohm reads by **three big round glowing jars side by side across his back** (filled teal, the third emptier), the
  goggles and beard forward, both arms out, and the **staff held in his right fist reaching forward, the copper fork
  out ahead of him and bright**.
- Today in game: `C:/Users/kazda/kiro/gtai-masters/n20/ohm/drift/staff_after_top_64.png` and `turn_after_top_32.png`,
  `.../n20/ohm/wire/ohm_top_idle_full.png`: a small blob, the jars small and dim, and the staff lying loose beside
  him (pointing forward but held at its butt, away from the body, the fist not clearly on it).
- The top-view parts: `project/features/souls/art/ohm/spectral/*.png` + `parts.json` (master
  `C:/Users/kazda/kiro/gtai-masters/n20/ohm/masters/ohm_spec_top_t1.png`). The rig: `project/features/souls/ohm_spirit.gd`
  (+ `ohm_jars.gd`, `ohm_fork.gd`, `ohm_drift.gd`, `ohm_parts.gd`).

## Owned files (allowlist; any other path: stop and report a NEED, do not edit it)
- `project/features/souls/ohm_*.gd`, `project/features/souls/art/ohm/spectral/parts.json`, Ohm's row in
  `project/data/tables/ghost_hover.json`, tests `project/tests/unit/test_ohm_*.gd` (+ `.uid`), one line in
  `docs/decisions.md`. No new image generation in this brief: reuse the existing parts.

## Part 1: make the jars and the fork carry the top view (rig and data only)
Using the parts that exist:
- **Jars**: the three jars are the read. Make them larger on the body (the jar glass circles about 1.3 to 1.5x their
  diameter today, relative to the body; keep them inside/over the back plate so they don't float) and their fill a
  brighter lit teal so a full jar glows like the plate (the charge levels empty / 1 / 2 / 3 and the amber vent must
  still read: do not change the fill logic, only its size and brightness).
- **Staff in his fist**: the staff is gripped by the staff arm's fist (the fist ring over the staff shaft, not beside
  its end), carried forward-right of his head at a slight outward angle, so the copper fork is clearly **out ahead of
  the goggles**, not alongside the body. Keep the existing thrust motion (THRUST_M, OUT_TICKS, BACK_TICKS: sim-timed
  presentation, do not change those timings) and the fork tip position the bolt starts from must follow the drawn
  fork (`OhmFork`).
- The whole figure may grow up to 1.15x in the top view if that is what it takes to read beside a guard at 32 px/m;
  the hit box and footprint do not change (they are not drawn here).
- Before/after at the same tick, 32 and 64 px/m, top view, idle full charge, mid charge, and the press frame:
  `C:/Users/kazda/kiro/gtai-masters/n21/polish/ohm/ohm_top_{idle,mid,press}_{32,64}_{before,after}.png`, made with
  the same tool and ticks the n20 ohm lane used (read `docs/day/2026-11-20/ohm/JOURNAL.md` for the commands and
  ticks; `tools/film/ghost_films.mjs --ghost=ohm --look=spectral --stills=...` gives top + tilt panels).
- Also a board `ohm/ohm_top_vs_plate.png`: the after at 64 px/m beside the plate's top inset (crop of the plate).
- Commit: "Let Ohm's jars and fork carry his top view".

## Part 2: pin what OhmSpirit draws (n20 mutation 4/9)
Add tests that pin the drawn result, not only states: per jar fill 0/1/2/3 the jar fill amount of each of the three
jars; the amber vent colour on cancel; the draw order (z / child order) of hem, body, jars, arms, staff, beard; the
staff/fork position at rest, at the thrust peak (OUT_TICKS) and back (BACK_TICKS); the arm-fork two-link joint (the
wrist at the common joint); and the alpha of the puffs. Read the values the code produces after Part 1 and assert them.
- `node tools/tests/run_unit.mjs --changed` green; `node tools/gate/quick.mjs` green; commit
  ("Pin what Ohm's top-view spirit draws").
- `node tools/mutate/mutate.mjs --file=features/souls/ohm_spirit.gd --max=20` and quote killed/(killed+survived).
  If below 70%, look at the survivors, add the tests that would kill them, commit and run it once more.

## Part 3 (only if time is left before the hard stop): Ohm's three films
`node tools/film/ghost_films.mjs --ghost=ohm --look=spectral --out=C:/Users/kazda/kiro/gtai-masters/n21/polish/ohm`
(move, attack, close takes as the tool defaults; this carries the eight-facing hover sheet from the previous call and
the top view from Part 1). Report the paths. Nothing to commit.

## Repo law (binding)
- AGENTS.md / STANDARDS.md. Typed GDScript, functions <= 40 lines, files about 200 lines (hard 300; `ohm_spirit.gd` is
  176 today: move code into a new `ohm_spirit_*.gd` helper rather than past 200), <= 5 params, `Log` not `print`.
- Stage per path. No `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push.
- Fix lint and format findings in your own edit and go on.
- No sim, replay, parity or bake digest may move; the bolt's sim-side origin does not move (only what is drawn).
  Colour law: teal only for souls; amber for overload/cancel. Ohm's bolt delay (`--ohm-bolt-delay`) stays off.
- Do not change the X-ray skeleton on killed guards or the tilt-view sheets (another package handles those).

## Report back
What changed (files, values before -> after), commits, still and board paths, test results, mutate line(s), and
anything not done and why.
