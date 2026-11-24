# Brief n27-melee-02-films: the two missing films (bond and mastery card on screen; the charged claw on a robot)

Lane `melee`, branch `n27-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadlines are given at the end of this brief (wall clock).** At the hard stop write your report
and END, even mid-task. Never stop to ask: at a fork pick what best serves the owner's words, write it in your report,
go on. Fix lint and format findings in your own edit and go on. No amend, no rebase.

The owner judges this lane by these films. He has never seen (a) the mastery card on screen nor (b) the claw's full
discharge finishing a robot in motion. You add film tooling only (dev and tools code); gameplay is already committed
(`git log --oneline -20`: master_at 30, Kerf boss cuts earn bond, mastery is free).

## Output
To `C:\Users\kazda\kiro\gtai-masters\n27\melee\` (create it): `films/*.mp4` at 32 px/m, tilt 70, 1920x1080, 60 fps,
15 to 40 s each (check every file with `ffprobe`, quote width/height/fps/duration), `stills/*.png` at 64 px/m, and
`frames.json` (8 to 15 entries best first: `[{ "file", "title", "ppm", "before", "note" }]`, `before` = path or null;
if a `frames.json` already exists there, add your entries in the right rank, do not drop others). Scratch under
`build/n27-films/`. Look at every film yourself (pull 4 frames with ffmpeg, read them) and say in one line what each
shows. Never fake a frame: every film is the real game rendering; a film that failed is reported as failed.

## Film 1: the bond and the mastery card (tick-exact)
A dev entry `project/dev/ghost-forms/bond_film.gd/.tscn` (extend `project/dev/test_player/gauntlet_bot_film.gd` or
`project/dev/gauntlet/gauntlet.gd`; declare `const KNOWN_FLAGS`) with:
- `--bond-prefill=<points short of master_at>` (e.g. 6): at the start each owned ghost's `GhostBond` is filled to
  `master_at - N`, so one short wave shows the teal ring on the chip closing from deploy kills;
- the rest card screen DRAWN while the test player decides: today the bot picks without the screen being rendered
  (n26 REPORT "What does not"). Hold the card screen on screen about 2.5 s (150 frames) before the bot takes the
  mastery card, show the taken card change state, hold about 1.5 s, then the normal pick (mastery is free now, so a
  second card is taken), hold 1 s, close. The sim is paused during the offer; only the presentation waits;
- then the next wave: T into the mastered ghost (the test player presses T once the form is mastered and a fight is
  near: check `bot` code for an existing transform action; add the press in the film entry only if needed).
Expert test player; choose a seed where it reads (try a few headless first, cheap; give the ghost and wave in your
report). Render through Godot's movie writer at a fixed 60 fps (as `tools/film/film.mjs` / `owner_takes.mjs` do: read
how they produce tick-exact frames and reuse that path; `--rendering-driver d3d12`, `--position 0,1440`). Cut to 20-40 s
around fill -> offer -> taken -> pick -> T: `films/bond_mastery.mp4` (32 px/m). Stills at 64 px/m:
`stills/bond_chip_ring_64.png` (the chip at three fill steps side by side), `stills/bond_offer_64.png` (the card screen).
Before: `C:/Users/kazda/kiro/gtai-masters/n26/melee/films/bond_fill_mastery_ohm_seed5.mp4` (screen capture, no card).

## Film 2: the charged claw finishing robots
Extend `tools/film/owner_take.gd` + `tools/film/owner_takes.mjs` with a take `claw_shock`: Rivet's claw full discharge
(the fully charged claw; see `tools/film/electric_stills.gd` which already stages `claw_shock` for stills, and
`project/features/combat/kills/` `robot_finishers.json`) against the robot list (thug, gunner, shield robot, war machine)
in the arena, one victim after another like the `electric_robots` take, subtitles naming each. Keep `hands`,
`electric_robots` and every other take working unchanged (run `node --test tools/film/melee.test.mjs` or the test
beside it). `films/claw_shock_robots.mp4` (32 px/m, 15-40 s; real time, then the first finish once more at quarter
speed if it fits, as last night's `electro_gun_robot_finish.mp4`), `stills/claw_shock_64.png` (64 px/m: the clamp,
lift on the arc, core burst, wreck as a 4-up sheet or one frame where it reads). Before: the plain claw on robots in
`C:/Users/kazda/kiro/gtai-masters/n26/melee/films/electro_gun_robot_finish.mp4` (after 8 s: no kill).

## Order and commits
1. Film 2's tooling first (smaller), commit, render, write its frames.json entries.
2. Film 1's entry, commit, render, frames.json.
Log every command and ffprobe line in `evidence/n27/films/films.md` (commit it).

## Repo law (binding)
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/melee` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`;
  `--rendering-driver d3d12` for renders; windowed only at `--position 0,1440`, never on the main display. One Godot
  process at a time; kill only your own PIDs, never by name.
- Typed GDScript, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not print, `.uid` with every
  new `.gd`, Godot `--import` after new scripts before committing. `node tools/gate/quick.mjs` before every commit.
  Stage per path; banned: `git stash`, `add -A/./-u`, `commit -a`, `reset --hard`, amend, rebase, push. If the
  pre-commit hook fails on `tools/film/kill_reel_*.break.test.mjs`, run a Godot `--import` and commit again.
- `node tools/dev/run.mjs <entry> ...` checks flags against the entry's `KNOWN_FLAGS`.
- A global flag (avoid): append to `project/boot/launch_args.gd` `KNOWN_FLAGS` and
  `node tools/debt/debt.mjs --update --accept-regression="<flag> for n27 melee films"`.

## Allowlist (any other path: stop that part and report `NEED <what>`)
`project/dev/ghost-forms/**` (new files), `project/dev/test_player/**` (film helpers only), `tools/film/owner_take.gd`,
`tools/film/owner_takes.mjs`, `tools/film/electric_stills.gd`, tests beside them, `evidence/n27/films/**`,
`tools/debt/baseline.json` via the debt tool, `project/boot/launch_args.gd` `KNOWN_FLAGS` append only, the masters dir.
Forbidden: every gameplay file (`project/features/**`, `project/data/**`, `project/boot/**` except KNOWN_FLAGS),
tests' expectations, tapes, `project/dev/gauntlet/**` (pressure lane), other worktrees, root `JOURNAL.md`/`REPORT.md`.

## Report and END (short)
Commits; per film: path, ffprobe line, one line of what it shows, its before; the frames.json order; what failed.

## Times (wall clock)
Launched about 03:56. **Commit film 2 tooling by 04:25 and film 1 entry by 04:45. Hard stop 05:00: report and END.**
Renders after 04:45 are fine (no repo commits needed for them), but stop at 05:00 whatever state they are in. The
branch already carries the keys lane's slot order (1 Dent, 2 Tonnage, 3 Kerf, 4 Ohm): the HUD strip in film 1 shows it.

## Step 0 (before anything else, 10 minutes at most)
The director merged the keys lane's slot order (`4a3ff4b04`, one hand-resolved conflict in `ghost_forms.json`'s `doc`).
Run `node tools/tests/run_unit.mjs --select=test_ghost_number_keys,test_ghost_bond,test_ghost_bond_input,test_ghost_form_hud,test_ghost_deploy_bot,test_gauntlet_mastery,test_bot_pick_mastery,test_ghost_boss_cut`
after the `--import`. If one fails because the two lanes' tests meet (e.g. a 25 vs 30 or a slot order), fix the test
expectation to the merged truth (30, slots dent/tonnage/kerf/ohm), commit it separately, and say so in your report. Any
other failure: report it, do not chase it, go on with the films.
