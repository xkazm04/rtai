# Brief n26-melee-05-films: the owner's films for the melee lane (n26)

Lane `melee`, branch `n26-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`.
**Hard stop 17:55 wall clock. Last commit by 17:10 (after that: renders only, NO commits, no repo edits).**
At the hard stop, write your report and END, even mid-task. Never stop to ask: at a fork, pick what best serves
the owner's words, record it in your report, go on. Fix lint and format findings in your own edit and go on.

The owner judges this lane only by these films. Every behaviour is already committed (read `git log --oneline -25`);
you add film tooling only (dev/tools code), never gameplay. The director's final gate runs on HEAD from about
17:10: any repo commit after 17:10 would break it, so build and commit the tooling first, then render.

## Output
Everything to `C:\Users\kazda\kiro\gtai-masters\n26\melee\` (create it): `films/*.mp4` (32 px/m, tilt 70,
1920x1080, 60 fps, 15 to 40 s each: check every file with `ffprobe` and quote width/height/fps/duration),
`closeups/*.png` (64 px/m), and `frames.json` with 8 to 15 entries best first:
`[{ "file", "title", "ppm", "before", "note" }]` (`before` = the path of the before file, or null). Scratch
renders go under `build/n26-films/`; delete scratch the frames.json does not reference from the masters dir.
Look at every film yourself (pull 3-4 frames with ffmpeg and read them) and say in one line what each shows.

## In this order (the most important first; stop at the hard stop)
1. **The bond and the mastery** (item 4; the owner has never seen it). A dev entry of your own,
   `project/dev/ghost-forms/bond_film.gd/.tscn` (extend `project/dev/test_player/gauntlet_bot_film.gd` or
   `project/dev/gauntlet/gauntlet.gd`; declare `const KNOWN_FLAGS`), with `--bond-prefill=<points short of
   master_at>` that pre-fills each owned ghost's `GhostBond` at the start so one short wave shows: the teal ring
   on the chip filling from deploy kills, the rest card "Master <ghost>" offered and taken (the test player takes
   it), then the next wave T and the mastered transformation in use. Expert test player, a seed where it reads.
   Film at 32 px/m: `films/bond_mastery.mp4` (cut to 20-40 s around fill -> offer -> taken -> transformation;
   the offer pauses the sim: keep the card on screen 2-3 s). 64 px/m: `closeups/bond_chip_ring_64.png` (the chip
   at three fill steps side by side) and `closeups/bond_offer_64.png`. Before: the same seed and wave on main
   `0779185ac` has no ring and no offer: one still `closeups/bond_before_after_64.png` (left main, right HEAD,
   same tick; `node tools/film/compare.mjs` or a `--rev` snapshot render).
2. **The two electric finishers on robots** (item 2): extend `tools/film/owner_take.gd` / `owner_takes.mjs` with
   two loadouts, `claw_shock` (the claw's full discharge) and `electro_gun` (the direct hit), each against the
   ROBOT list (thug, gunner, shield robot, war machine), keeping `hands` and `electric_robots` working unchanged.
   `films/electric_claw_shock.mp4`, `films/electric_electro_gun.mp4` (32), `closeups/claw_shock_64.png`,
   `closeups/electro_gun_64.png`. Before: `C:\Users\kazda\kiro\gtai-masters\n24\melee\films\electric_robots.mp4`
   (the baton, the only shutdown the owner saw).
3. **Bare hands kill every human type** (item 1): `node tools/film/owner_takes.mjs <masters dir> 32 hands` and
   `... 64 hands` (patrol cop, riot cop, SWAT, contractor, rocket trooper; subtitles name each). Add the appliance
   warden to the human list if it is two lines; else say so. Before:
   `C:\Users\kazda\kiro\gtai-masters\n24\melee\films\hands_kills.mp4` and `closeups\hands_64.png`.
4. **Kerf's capped cut on a boss** (item 3): the boss wave with Kerf deployed, before (`03f42c220`, the commit
   before the cap) and after (HEAD), same seed and tick, 32 px/m, cut to 20-40 s each, then one side-by-side
   `films/kerf_boss_before_after.mp4` (ffmpeg hstack, scaled to 1920 wide). Use `--rev=<commit>` snapshots
   (`tools/film/compare.mjs`, `tools/film/film.mjs` README: `tools/README.md`) so the live tree is never edited
   between renders. 64 px/m stills already exist: copy `evidence/n26/kerf-cap/frames/kerf-{before,after}-64.png`
   into `closeups/`.

## Files you may edit (allowlist). Any other path: stop that part and report a NEED.
`project/dev/ghost-forms/**` (new files), `project/dev/test_player/**` (film helpers only), `tools/film/owner_take.gd`,
`tools/film/owner_takes.mjs` (and a test beside it if one exists for it), `project/boot/launch_args.gd`
`KNOWN_FLAGS` append only (only if your entry's flag must be global: prefer the entry's own `KNOWN_FLAGS`),
`tools/debt/baseline.json` via `node tools/debt/debt.mjs --update --accept-regression="<what> for n26 melee films"`,
`evidence/n26/films/**` (a `films.md` log of commands and ffprobe lines), the masters dir above.
Forbidden: every gameplay file (`project/features/**`, `project/data/**`, `project/boot/**` except KNOWN_FLAGS),
tests' expectations, tapes, root `JOURNAL.md`/`REPORT.md`, other lanes' worktrees.

## Repo law (binding)
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/melee` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`;
  `--rendering-driver d3d12`; windowed `--position 0,1440` (never the main display). One Godot process of yours
  at a time; kill only your own PIDs. The director's gate may run beside you after 17:10: do not touch
  `%TEMP%/gtai-gate-*`.
- Typed GDScript, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not print, `.uid` with
  every new `.gd`, Godot `--import` after new scripts before the commit. `node tools/gate/quick.mjs` before each
  commit. Stage per path; no amend, rebase, stash, `add -A/./-u`, `commit -a`, `reset --hard`; never push.
- Never fake a frame: every film is the real game rendering; a film that failed is reported as failed.
- `node tools/dev/run.mjs <entry> ...` checks flags against the entry's `KNOWN_FLAGS`.

## Report at the end (short)
Commits; per film: path, ffprobe line, one line of what it shows, its before; the frames.json order; what failed
or was not done.
