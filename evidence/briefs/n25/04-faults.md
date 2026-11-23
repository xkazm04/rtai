# Package 04 `faults`: the smaller faults, the mutate runner, the one film

Wall-clock hard stop and commit deadline: given at the top of the launch note below. Stop early when done.
Packages 01 (lessons), 02 (shotgun) and 03 (new game -> prologue -> quest 1) are committed: keep them.

## 1. Mulroney's orders show the owner's whole line
Today `project/boot/prologue/prologue_battle.gd:~115-119` repeats a short command during the fight ("Mulroney · Line up!",
"Mulroney · Shoot him !"): fragments of the owner's rows `b2_l01_mulroney_line_up` and `b2_l05_mulroney_shoot`
(`prologue_lines.json`). Show the **whole line verbatim** (typos, spacing and capitals as written) with his name each time he
gives that order, in the prologue's line box (or wherever the order text shows today), long enough to read (use the line
player's own reading-time rule) and without covering Rivet or Mulroney (the camera rule from n23 keeps them clear of the
boss bar and the line box: keep that true). The order's combat timing (90-tick tell, 96-tick exposure) does not change; if the
text outlasts the tell, it stays up while the fight goes on. Remove the short-command strings. Unit test: the text shown for each
order equals the row's `t`.

## 2. The money card does not read "$0 unarmed" during the prologue
The HUD cash card (`project/features/hud/hud_cash.gd`, fed by `project/boot/collect_call/view/hud_feed.gd`) shows "$0 / unarmed"
through the prologue. Hide it in the prologue until money exists (the prologue has no money: so hidden throughout). Do it from the
prologue's side (the prologue builds its view: `prologue_view.gd` / `prologue_game.gd`); if hiding needs a change in
`features/hud/**` or `boot/collect_call/**`, make it a tiny additive switch (default unchanged for quest 1) and say so. Quest 1's
HUD must be unchanged after the hand-over (the card is back in quest 1). Still: `C:/Users/kazda/kiro/gtai-masters/n25/path/hud-no-cash-before-after.png`
(the same tick, before | after side by side, 1920x1080 each, scaled into one image).

## 3. (dropped) The end card void
The yard lane fixed it on its branch (street and pavements drawn 40 m past both side edges, commits ccb9b543f..6a1a627b0 on
`n25-yard`); the Director merges it in the morning. Do NOT touch the end-card camera or scenery for it.

## 4. mutate on `prologue_game.gd` runs a full sample
Last night: `infrastructure failure on mutant 70 (line 179): exit 1 with no test result: unit-tests: gut exit 1; no JUnit report;
zero tests ran` (also mutants 51 and 74). Package 01 also found that the CLI refuses an in-tree scratch path. Find the cause in
`tools/mutate/**` (you may edit it: keep its own tests green, `node --test "tools/mutate/*.test.mjs"` if they exist, and the tooling
test glob in AGENTS.md) or in the prologue code (e.g. a mutant that makes Godot quit before GUT writes JUnit should count as KILLED,
not infra). Then run `node tools/mutate/mutate.mjs --file=project/boot/prologue/prologue_game.gd --max=40` to the end and quote
killed/(killed+survived), plus any mutant still marked infra with its reason.

## 5. The one film: menu -> prologue -> quest 1's first line
Using package 03's menu-to-quest-1 pilot entry, render ONE film: the game started from the menu (the title card visible ~2 s,
Start pressed by the pilot), the whole prologue, the hand-over, and quest 1's first line on screen for ~3 s, then stop.
1920x1080, 60 fps, 32 px/m, tilt 70, seed 7, `--write-movie` the way `project/dev/prologue/capture/film.ps1` does it (add a
mode or a sibling script under `project/dev/prologue/capture/`). Output `C:/Users/kazda/kiro/gtai-masters/n25/path/newgame-to-quest1.avi`
-> ffmpeg `newgame-to-quest1.mp4` (H.264, yuv420p, crf 22), delete the .avi; quote `ffprobe` duration. Take three stills from it:
`film-title.png`, `film-handover.png`, `film-quest1-first-line.png`.

Package 03 left `project/dev/prologue/newgame_pilot.gd` (SceneTree entry) + `prologue_menu_film.gd` (accelerated driver: steps the worlds 180
ticks per frame, stills only) + `prologue_menu_drive.gd` (presses the real Start). The film must be REAL-TIME (one sim tick per rendered
frame under `--fixed-fps 60 --write-movie`), so add a real-time mode (e.g. `--realtime`, declared in the entry's own `KNOWN_FLAGS`) or a
sibling driver; the menu scene must be the current scene so `NewGamePath` takes the campaign path. Expected length: title ~2 s + prologue
(~145 s at seed 7) + quest 1's first line ~3 s; if one movie over ~3 min fails, render it in two parts and join with ffmpeg concat
(say so). The owner's films are 15-40 s per clip elsewhere, but this one is the whole path by the owner's request: keep it whole.

## 6. The shotgun close-up (64 px/m)
Package 02's `shotgun.mp4` is at 32 px/m: the pellet fan reads, Mulroney's pump (fore-end travel + marker) is a few pixels.
Add a clip mode `shotgun_close` to the prologue film tool (same seed 7 pilot): 64 px/m, tilt 70, 1080p60, 12-20 s, the camera
holding Mulroney and Rivet in frame through two blasts and their pump windows (Rivet's opening). Output
`C:/Users/kazda/kiro/gtai-masters/n25/path/shotgun-close-64ppm.mp4` (+ ffprobe) and a still `shotgun-pump-64ppm.png` mid-pump.
Run this after item 2 so the "$0" card is gone from it.

## Acceptance (quote every result)
- Pilot `node tools/dev/run.mjs prologue --bot --seed=7 --result=<abs>` twice cmp-identical, 0 deaths, end card; and the
  menu-to-quest-1 pilot twice cmp-identical, quote its four ticks.
- `node tools/tests/run_unit.mjs --changed` green; full scenario suite green; replay `cbeb734ff9b97c41`; `node tools/tests/release_compile.mjs` exit 0;
  `node tools/gate/quick.mjs` green before each commit.
- One commit per numbered item (1, 2, 4), then the film entry. mutate `--max=20` on the files of items 1-2.
- Mulroney order still: `mulroney-order-full-line.png` (64 px/m, during an order).

## Final message
Commit shas per item, every number above, file paths of stills and film, NEEDs, and anything left.
