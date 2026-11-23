# Brief n26-05-keys-film: the owner's film of the new keys, with an on-screen key overlay

Lane `keys`, branch `n26-keys`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (your cwd).

**Hard stop: HARDSTOP wall clock (check `date` first and often). Commit deadline: COMMITBY.**
Small commits, staged per path, `git commit -- <paths>`. No amend, no rebase, no stash, no `add -A/./-u`, no `commit -a`,
no `reset --hard`, never push. Fix lint and format findings in your own edit and go on. mutate: not needed (dev code only).

Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/keys` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; anything that renders
`--rendering-driver d3d12`; windowed runs `--position 0,1440` (never the main display). One Godot process at a time in this
lane; free your own by PID, never by name.

## Why
The owner judges the keys item by "a film of the three keys in use with an on-screen key overlay (sprint on Space, dash on
Shift, claw on F, all four ghosts deployed by number, 1 entering a car)". The keys landed in this branch (8ee4e085b table,
974647488 `GhostNumberKeys`, e75e90ce1 chips, the quest1 prompt fix of the last call). Nothing filmed them yet.

## What to build (dev only, excluded from release)
A dev take scene under `project/dev/controls/keys_film.gd` (+ `.tscn`, `.uid`), patterned on
`project/dev/controls/arena_opening_film.gd` + `opening_film_pad.gd` (read both first; reuse `OpeningFilmPad` for sticks).
1. **Press keys, not actions**: for every scripted press, take the event the table installed,
   `InputMap.action_get_events(<action>)` -> the first `InputEventKey` (or the mouse button for the claw's second binding,
   not needed here), duplicate it, set `pressed`, and `Input.parse_input_event()` it. That proves the BINDING, which
   `Input.action_press` would not. No raw keycode constants in the file (lint bans them): the key comes from the InputMap.
2. **The overlay**: a CanvasLayer drawn on top, bottom-left, large enough to read at 1080p (about 56 px glyphs): one keycap per
   key currently held, labelled with the event's own text (`as_text_physical_keycode()` / `as_text()`, e.g. "Space",
   "Shift", "F", "1") plus the action's player-facing name through `Loc.t()` / the existing prompt label if one exists (else
   the action id). A released key fades over about 0.3 s. Dev code, but still no hard-coded UI words except the key text
   from Godot itself; `Log`, not `print`.
3. **The scene**: one continuous take where Rivet owns all four ghosts (Dent, Kerf, Ohm, Tonnage; find the dev/arena flag or
   loadout the gauntlet or `ghost_films.mjs` uses to grant them) and a drivable car is parked within reach (find a scene that
   has both: the arena with a car spawn, the street, or the gauntlet's city block; say which and why). Sequence, about 30 s:
   walk -> hold **Space** sprint (2 s) -> release -> tap **Shift** dash (faint trail) -> **F** quick claw on a dummy or enemy ->
   hold **1** away from the car (Dent's range shows, release deploys Dent) -> hold **2** (Kerf) release -> **3** Ohm ->
   **4** Tonnage -> walk to the car -> beside the car tap **1**: Rivet enters (Dent does NOT deploy) and drives 3-4 s ->
   **1** again: he leaves. Every deploy must actually deploy (log
   the form id and tick per deploy; the take fails if one is missing) and the car entry must actually happen (log the tick).
   Respect the ghost cooldowns (space the deploys by their cooldown; read it from data, do not change it).
4. Register any new launch flag in the scene's own `const KNOWN_FLAGS` (no `launch_args.gd` change needed for a dev scene
   flag read through `ArenaArgs`; if you must touch `project/boot/launch_args.gd` `KNOWN_FLAGS`, one appended line and the debt
   tool's `--accept-regression="<flag> for n26 keys"`).

## The film (the deliverable)
- 32 px/m, tilt 70, 1080p60 (`--fixed-fps 60`), 25-40 s: `C:/Users/kazda/kiro/gtai-masters/n26/keys/keys_overlay_32.mp4`
  (`ffprobe` it: duration, 1920x1080, 60 fps; quote the line). Use `tools/dev/run.mjs` with `--windowed --position 0,1440`
  and the repo's frame capture (`--write-movie` or the film kit; read `tools/README.md` "film.mjs" and "A dev run draws the
  current pixels at a fixed step").
- One 64 px/m still at the moment the four ghosts are out (or Dent's range shows): `.../keys/keys_overlay_64.png`.
- LOOK at frames yourself (extract 6 with ffmpeg across the take): overlay readable, every key shown when it is pressed, Rivet
  on screen the whole take, the car entry visible. Fix and re-take if not.
- Append entries to `C:/Users/kazda/kiro/gtai-masters/n26/keys/frames.json` (create if absent; keep existing entries; fields
  `file`, `title`, `ppm`, `before` (null here), `note`; the keys film goes FIRST).
- `evidence/n26-keys/keys_film.md`: scene used, the press log (tick, key text, action, result: form deployed / car entered /
  car left), ffprobe line, how the binding was proven (events from InputMap).

## Second deliverable, after the keys film (cheap, owner asked; NO art change)
A still of Gloria held beside the pistol, same tick and facing, at tilt 70 and tilt 55, 64 px/m, to
`C:/Users/kazda/kiro/gtai-masters/n26/keys/gloria_vs_pistol_64.png` (four labelled panels: p70 pistol | p70 gloria /
p55 pistol | p55 gloria; Rivet standing armed and walking, aim to the right). Use `tools/film/film.mjs weapon:gloria` /
`weapon:pistol` stills (or the arsenal turn tool) and compose with Python/PIL; find how the game selects the 55 degree view
and say which. The owner asks whether Gloria, the first pistol-class weapon, is drawn as a long two-handed gun and should be
redrawn: show it plainly; add one line to `evidence/n26-keys/keys_film.md` with what the still shows (hands on the gun, length
vs the pistol in px). A frames.json entry for it.

## Gates for your commit
`node tools/godot/check.mjs res://dev/controls/keys_film.gd res://dev/controls/keys_film.tscn`, `node tools/gate/quick.mjs`,
`node tools/lint/lint.mjs` green (layers: nothing outside `dev/` names the new class). Then `node tools/tests/release_compile.mjs`
still exit 0. One commit: the dev scene + `.uid` + evidence md. Masters files are outside the repo (not committed).

## Allowlist (anything else: stop and report a NEED line)
`project/dev/controls/keys_film*` (new), `project/dev/controls/opening_film_pad.gd` (add a helper only, keep its callers'
behaviour), `evidence/n26-keys/**`, `C:/Users/kazda/kiro/gtai-masters/n26/keys/**`, `build/**` (scratch).
Forbidden: all product code and data (`project/features/**`, `project/boot/**` except the one `KNOWN_FLAGS` line above,
`project/data/**`), tests, other lanes' files, `native/`. If the take shows a real keys bug (a key that does not do its job),
do NOT fix product code: stop, write the bug with the tick and log line in your final message as `NEED keys-fix <what>`.

## Report (final message)
Scene and why, the press log, film path + ffprobe line, still path, frames you looked at and what you saw, commit sha,
any NEED lines.
