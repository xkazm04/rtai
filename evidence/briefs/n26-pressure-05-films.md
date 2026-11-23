# Brief n26 pressure 05: the owner's films for lane pressure

Hard stop HARDSTOP wall clock. Last commit COMMITBY. The code is FROZEN: this call makes films and evidence only.
If a film needs a dev change (a new take in the existing dev film), it lives under `project/dev/gauntlet/**` only and is
committed by COMMITBY; otherwise film with what exists. Fix lint and format findings in your own edit and go on.

## Setup, every shell
`export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/pressure` and
`export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`.
One Godot at a time in this worktree (Godot is yours alone; the Director's final gate starts after your hard stop, on your last commit, so a dev commit after COMMITBY is not allowed). Anything that renders
uses `--rendering-driver d3d12`; every windowed run uses `--position 0,1440` (never the main display). Film committed
code only: `tools/film/film.mjs ... --rev=<sha>` or a snapshot worktree; `tools/film/compare.mjs` for same-tick pairs.

## What exists (read first)
- `project/dev/gauntlet/pressure_film.gd` + `pressure_take.gd` (n24): takes `guard`, `blade`, `stand`, `circle`,
  `dash`, `rockets`, with an hp bar, a title and a numbers label; `--take --seed --ppm --out --still`. n24's results:
  `C:\Users\kazda\kiro\gtai-masters\n24\pressure\` (`rocket_pair_32.mp4`, `standing_punished_32.mp4`, `deflect_half_32.mp4`).
- This run's changes (n26, on this branch): `7d23e60c5` deflect spread 20 deg; `b370c3ba4`/`dab47bef7`/`d42706a60`/
  `41eccb33e` the trooper's cased rocket with ice rim and jets; the trooper commit(s) of call 03 (rest / lead, read
  `git log` and `docs/decisions.md` "pressure rocket trooper"); the stall fix of call 04 (read its `evidence/n26-pressure/stall/cause.md`).
- Before = `main` `0779185ac`. Stills of the rocket already made: `C:\Users\kazda\kiro\gtai-masters\n26\pressure\rocket-*.png`
  (keep them; do not re-make).

## Every film
32 px/m, tilt 70, 1920x1080, 60 fps, 15 to 40 s (check each with `ffprobe`; quote duration, size, fps), plus one 64 px/m
still or clip per item. To `C:\Users\kazda\kiro\gtai-masters\n26\pressure\`. Look at frames of every film yourself
(extract 3 stills with ffmpeg and read them): a film of the wrong thing, a black frame or a frozen Rivet is not delivered.

1. **Both rockets in a fight** (`rockets_fight_32.mp4`, 15-30 s): Rivet with the rocket launcher against a squad with a
   rocket trooper, both rockets in the air in the same frames; plus a before/after still pair at the same tick at 32
   and 64 px/m (`rockets_fight_<ppm>_pair.png`: `0779185ac` left, HEAD right). Reuse the `rockets` take or the
   n24 `rocket_pair` path.
2. **Deflect at 6 m** (`deflect_6m_32.mp4`, 15-25 s): Rivet guarding at 6 m from rifle shooters, the returned rounds'
   spread readable (some hit the shooter, most miss), caption with the measured share at 6 m from
   `evidence/n26-pressure/deflect/share.md`; a 64 px/m still `deflect_6m_64.png`. Before/after: the same take at
   `0779185ac` (12 deg) side by side or as `deflect_6m_32_before.mp4`.
3. **Circling against two troopers** (the owner's main proof for item 3): `circle_vs_troopers_32.mp4` and
   `circle_dash_vs_troopers_32.mp4`, 20-30 s each, same seed and start: Rivet circles two rocket troopers without
   dashing (takes rocket damage) / circles and dashes across each locked line (takes none). Health bar in frame and a
   caption with hp lost and rocket hits. If the `circle`/`dash` takes have one trooper, add a take `circle2`/`dash2`
   with two (dev file only). Before/after: the circle take at `0779185ac` beside HEAD (hp lost each, in the caption or
   in REPORT). One 64 px/m still of a rocket meeting the circler.

## frames.json
`C:\Users\kazda\kiro\gtai-masters\n26\pressure\frames.json`, 8 to 15 entries, best first:
`[{ "file", "title", "ppm", "before", "note" }]` (`before` = the before file or null), covering the three films, their
64 px/m stills, the rocket stills already in the folder (`rocket-vs-rivet-32.png` first among them, `rocket-a-vs-c-32.png`
as the owner call). Delete scratch renders it does not reference. Commit nothing under the masters folder (it is outside
the repo); a short `evidence/n26-pressure/films.md` (paths, ffprobe lines, caption numbers) is committed.

## Allowlist (any other path: stop and report a NEED)
`project/dev/gauntlet/**`, `evidence/n26-pressure/**`, `C:\Users\kazda\kiro\gtai-masters\n26\pressure\**`,
`project/boot/launch_args.gd` `KNOWN_FLAGS` (append only, if a dev flag is truly needed). Forbidden: every table, product
code, art, other lanes' files, root `JOURNAL.md` / `REPORT.md`.

## Law
Stage per path; `git commit -- <paths>`; no stash, no `add -A`, no amend, no rebase, no reset --hard, never push.
`node tools/gate/quick.mjs` before a commit that touches `project/`. Typed GDScript, functions <= 40 lines.

## Report
Per film: path, ffprobe line, what it shows, the caption numbers; the frames.json order; every NEED.
