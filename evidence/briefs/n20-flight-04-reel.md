# n20 flight, package 4: the all-ghosts reel, fresh films, and what package 3 left weak

Same law as packages 1-3 (their briefs are in `evidence/briefs/`): visual only, no sim/replay/parity/bake
digest moves; `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/flight`;
`GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`;
`--rendering-driver d3d12` for anything that renders; windowed runs `--position 0,1440`; one Godot at a time;
never kill by name; stage per path; no stash / add -A / reset --hard / commit -a / amend / rebase; never push;
never merge another branch. Interface names in the README "Spectral look" never change. Flight's file list
is in package 3's brief; never edit another lane's files or rows (write `NEED <lane>: <file> <why>`).

## TIME BOX (hard)
It is 05:10. The final gate runs on this branch at 06:15, so **your last commit lands by 05:58** and then you
stop and report, even mid-list. Order: item 0, item 1 (tool + its test + ONE real reel run to prove it), then
item 3 (aura opt-out first: dent waits on `_aura.form_id`; then tail rise sign; Kerf's tail too straight at speed).
Item 2 (re-filming all clips + frames.json) is NOT for this session: the director runs it after the gate.
Never leave staged or uncommitted work at 05:58: commit what is green, discard (by path, `git checkout -- <path>`)
what is not, and list it.

## 0. Ohm's NEED (small, do first, one commit)
`ohm_drawn.gd` / `ohm_spirit.gd` on n20-ohm read GhostDrawn's private `_fade` (to clear the fallback belt
socket) and GhostDrawnActs' private `_hurt` (top-view hit lean via GhostRecoil.tilt). Add public, documented
accessors and list them in the README "Spectral look" section: `GhostDrawn.release_fade() -> void` (clears the
bridge fade off `flight` if any; same as the existing internal clear) and `GhostDrawnActs.hurt_tick() -> int`
(the tick of the last hurt, -1 if none). Use them inside flight's own code where it touches those privates.
Unit-test both (release_fade leaves no fade material; hurt_tick follows feed()). Commit:
`Expose the bridge-fade release and last hurt tick on GhostDrawn`. Do not edit any ohm file.

## 1. The all-ghosts reel (the owner's first film of the morning)
Teach `tools/film/ghost_films.mjs` (or a sibling `tools/film/ghost_reel_all.mjs` that imports its `film()`/
`compose()`; keep each file under the size law) to cut ONE film of all four ghosts under one look:
`node tools/film/ghost_films.mjs --all --look=spectral --out=C:/Users/kazda/kiro/gtai-masters/n20/flight --name=all_ghosts_32`
- For each ghost in order tonnage, dent, kerf, ohm: its `move` chapter then its `attack` chapter at 32 px/m,
  the same two-panel 1920x1080 layout (play tilt 70 above, top view below, the caption bar), 5 s each,
  so 40 s in total. A short card is NOT needed: the caption bar already names the ghost.
- Reuse the captures: if a chapter's panels were already captured in this run, do not capture again.
- Writes `all_ghosts_32.mp4` + `all_ghosts_32.jpg` (poster at Tonnage's move tick 163).
- Node test in `tools/film/*.test.mjs` for the plan (`--all` takes no `--ghost`; the order; the name) without
  running Godot. Add the command to `tools/README.md` and the AGENTS.md table only if the table already lists
  ghost_films (otherwise tools/README only).
- Run it and look at at least 4 frames (one per ghost). Commit: `Cut one review reel of all four ghosts`.
This branch merges no ghost lane, so the reel shows the legacy bodies with flight's motion, tail and shadow.
That is expected; say so in the report.

## 2. Re-film flight's own clips with everything from package 3
`node tools/film/ghost_films.mjs --ghost=<g> --look=spectral --out=C:/Users/kazda/kiro/gtai-masters/n20/flight --prefix=flight_ --takes=move,attack,close --stills=163`
for all four (kerf and tonnage first). Plus `--take=morph` films if package 3 added them (kerf, tonnage).
Delete the superseded scratch renders in that folder that no frames.json entry will reference (keep
`before/` and `package2/`). Then write `C:/Users/kazda/kiro/gtai-masters/n20/flight/frames.json`: 8 to 15
entries, best first, `[{ "file", "title", "ppm", "before", "note" }]`; `before` names the matching legacy
or package-2 frame where one exists. First entry: the all-ghosts reel poster.

## 3. Weak items from the director's review (fix what package 3 has not already fixed; check its commits first)
Read your package-3 resume report (evidence/briefs/n20-flight-03b-effects-resume.out.txt) first. Then, in this order,
only what it lists as not done or still weak: (a) any item of 0b/7a/U-stroke still weak; (b) package 3 items
4 (aura opt-out, form_id), 5b (tail rise 0/negative, unit-tested), 6 (hit lean rocks the lifted body, tail swings),
5 (apparition hovers); (c) anything left of morph/emerge/soul line. Commit each on its own.

## Checks and report
Before each commit: `node tools/godot/check.mjs <changed .gd>`, `node tools/lint/lint.mjs`,
`node tools/tests/run_unit.mjs --changed`, `node --test "tools/film/*.test.mjs"`, `node tools/gate/quick.mjs`.
Stop by the 65-minute mark with everything committed. Report: commits (sha + line), checks and results, every
film/still path with one line of what you judged in it, NEED lines, what is still weak.
