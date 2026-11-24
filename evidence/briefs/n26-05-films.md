# Brief n26-05 `films`: the owner's films of the second-pass yard (lane yard, run n26)

HARD STOP: <HARD> local (stop work, report). LAST COMMIT: <LAST>. Check `date` now and then.

These are the films the owner judges the lane by. The art and behaviour are final: do NOT change any game, data or art file in this call. Dev film code only (allowlist below).

## Before anything
- `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/yard` and `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe` in every shell that runs Godot. `--rendering-driver d3d12`. One Godot at a time; windowed runs `--position 0,1440`; kill only PIDs you started.
- `git log --oneline -25`: calls 01-04 built the `line_fire` row (cover, dusk, front, fence, pump, line join). The n25 films were made with `project/dev/prologue_yard/yard_film.gd` (places gate/mid/harbor, dressings plain/torn_line) and `project/dev/prologue/prologue_menu_film.gd` (menu Start through the prologue); read both and `docs/day/2026-11-23/n25-yard/REPORT.md` (films section) first.
- Output: `C:\Users\kazda\kiro\gtai-masters\n26\yard\` (create it). Every clip h264 1920x1080 60 fps, 15-40 s unless said; check each with `ffprobe` and quote the line. Camera tilt 70, 32 px/m unless said.

## The films and stills (in this order; best first in `frames.json`)
1. **Plate beside the game** (stills, 32 and 64 px/m): `plate_vs_game_{gate,mid,front}_{32,64}ppm.png`: the plate `C:\Users\kazda\kiro\gtai-art\factory-n25\out\a-torn-line.png` (crop the matching region, scaled to the same height) left, the `line_fire` yard right, same tick 6000 on the seed-7 pilot. Extend `yard_film.gd` to accept `--yard-dressing=line_fire` and `--place=front` (the hall front with the burst doors) if it does not yet; declare flags in its `KNOWN_FLAGS`.
2. **First pass beside second pass** (clips): `pair_{gate,mid,front}_32ppm.mp4`: `torn_line` left, `line_fire` right, same camera and ticks (as n25's `pair_*` films), 20-30 s each, plus `pair_{gate,mid,front}_64ppm.png` stills.
3. **The whole prologue from the menu's Start into quest 1's first line, one film**, on the new yard (default dressing `line_fire`): `prologue_menu_to_quest1.mp4` (may be longer than 40 s: the whole run; say its length), plus `excerpt_wave1.mp4` and `excerpt_mulroney.mp4` (25-35 s each). Check the lesson cards in it name the new keys (Space sprint, Shift dash, F claw, 1-4 ghosts / 1 for the car): list each card's text as seen in the frames.
4. **The pump tell** at 32 px/m: `pump_32ppm.mp4` (15-25 s around Mulroney's first two blasts, seed-7 pilot) and `pump_64ppm.png` at the widest rack; if call 03 made `evidence/yard26/pump_32ppm_before_after.mp4`, copy it in as `pump_32ppm_before_after.mp4`.
5. **Dusk readability**: `dusk_readability_32ppm.png` (patrol cop, a rifle round and a pellet on the dusk floor beside the same on the day floor; from `evidence/yard26/dusk_samples.png` or re-taken).
5b. **Dusk depth, a call for the owner**: the shipped `line_fire` `ground_shade` is 0.81 (the measured patrol-contrast limit, decisions line `n26 yard ground shade`); at 0.62 the yard looks like the plate's dusk and the cops still read by their ink outline, but the luminance metric says patrol blue keeps only ~29 % of daylight contrast. Make `dusk_depth_{gate,mid}_32ppm.mp4` (20 s each, seed-7 pilot, same ticks): left the shipped 0.81, right 0.62, plus `dusk_depth_mid_64ppm.png`. Do this with a dev-only override in the film script (e.g. `--ground-shade=0.62` in `yard_film.gd`'s own `KNOWN_FLAGS`, set on the loaded `PrologueYardDressing` before the floor is built); do NOT change the data row. Label each half with its value and the contrast numbers from `evidence/yard26/dusk_shade_steps_32ppm.png`.
6. `frames.json`: 8 to 15 entries, best first, `[{ "file", "title", "ppm", "before", "note" }]` (`before` = the file or side it is compared with, or null). Delete scratch renders it does not reference. Also `evidence/yard26/films.json` with sha256 + ffprobe duration of every master.

## Owned files (allowlist). Any other path: stop and write the NEED in your final report.
- `project/dev/prologue/**`, `project/dev/prologue_yard/**` (film code only), `evidence/yard26/**`, `C:\Users\kazda\kiro\gtai-masters\n26\yard\**`
- `tools/debt/baseline.json` (only through `node tools/debt/debt.mjs --update --accept-regression="<reason> for n26 yard"`), `.uid` of new dev scripts.

## Forbidden
Every other repo path: game code, data, art, tests outside dev, other lanes' masters folders, other worktrees.

## Repo law
Typed GDScript, files <= 200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`. Stage per path; one commit per change; no `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push. Fix lint and format findings in your own edit and go on. `node tools/gate/quick.mjs` before each commit.

## Report (final message)
Every file in masters with its ffprobe line, the lesson card texts seen, commits, what was not done.
