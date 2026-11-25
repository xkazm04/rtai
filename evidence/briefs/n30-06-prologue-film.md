# Brief n30-06 `prologue-film`: the whole prologue on the n30 yard, plate beside game from three cameras (lane yard, run n30)

HARD STOP: see the time in the prompt that launched you (report and END). FIRST COMMIT (the plate stills + judgement) started no later than 35 minutes after launch; LAST COMMIT started no later than 12 minutes before the hard stop. Check `date` often. Never amend, never rebase.

## Setup
Same as `evidence/briefs/n30-03-span-shadow.md` (env exports with `APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/yard`, renders d3d12 at `--position 0,1440`, Godot only through repo tools / runGodot, the lane's Godot lock `build/yard-godot.lock` with your tag `prologue-film`). Never stage files you did not edit; always `git commit -m ... -- <paths>`. Evidence only: you edit NO product file.

## What to make
1. **The whole prologue from the menu's Start into quest 1's first line on HEAD's default yard** (`arched_line`; list which n30 commits are in: shade 0.5, decals over the impression, span shadow, hall roof, mouth span). n29 did the same job: brief `evidence/briefs/n29-04b-prologue-film-0410.md` item 1 and its known trap (`prologue_yard_film.mjs --movie` refuses at 1280x800: film through a `build/prologue-film` copy with an `override.cfg` at 1920x1080; `build/films28/run.sh` and `build/films26/films.sh` case `menu` if they still exist; else `project/dev/prologue/newgame_pilot.gd`'s header, `--bot --seed=7`, `--write-movie`, `--fixed-fps 60`). The copy must carry THIS branch's HEAD data and art. Output `C:/Users/kazda/kiro/gtai-masters/n30/yard/prologue_menu_to_quest1.mp4`: h264 `yuv420p` crf 20, 1920x1080, 60 fps (long by nature, n29 189.32 s). Quote ffprobe. Report the handover tick and first-line tick (n29: 10792 / 10793) and whether they moved (if moved: a finding, report it, do not fix). LOOK at 5 frames (menu, the yard fight on the belt, Mulroney's card, Don Fax, the city with quest 1's first line), one line each. Delete the `.avi`.
2. **Plate beside game at three cameras, 32 and 64 px/m**: gate (tick 6400), mid (2290), front (2858), exactly as `evidence/yard29/plate_vs_game_{gate,mid,front}_{32,64}ppm.png` were made (commit `cc53b7202`; tools `tools/art/prologue_yard_stills.mjs` / `project/dev/prologue_yard/yard_dusk_capture.gd`, hstack `evidence/yard28/compose.py`; plate A `C:/Users/kazda/kiro/gtai-art/factory-n25/out/a-torn-line.png`) to `evidence/yard30/plate_vs_game_{gate,mid,front}_{32,64}ppm.png`. Also `evidence/yard30/n29_vs_n30_{mid,front}_32ppm.png`: the n29 game still (from `evidence/yard29/`) left, n30 right, same camera, labelled. LOOK at each. Write `evidence/yard30/plate_judgement.md`: per camera one honest line on how far it still is from the plate and the biggest remaining gap, and one line on what n30 changed there. COMMIT 1 (`evidence/yard30/**` only).
3. Masters: copy the three 32 px/m plate stills to `C:/Users/kazda/kiro/gtai-masters/n30/yard/`; add entries for the prologue film and the front plate still to its `frames.json` (keep valid JSON, 8 to 15 entries best first; drop the weakest only past 15). Delete scratch renders under the masters folder that `frames.json` does not reference (only files you made).

## Owned files (allowlist). Any other path: stop and report a NEED.
`evidence/yard30/**`, `build/**`, `C:/Users/kazda/kiro/gtai-masters/n30/yard/**`.

## Forbidden
Every other repo path (product files, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`), other worktrees, `C:/Users/kazda/kiro/gtai-art/**` except reading. No image generation. No `git add -A/./-u`, `git commit -a`, stash, amend, rebase, reset --hard, push, `--no-verify`.

## Report (final message, then END)
Commit sha; ffprobe line; the two ticks; one line per frame looked at; the plate judgement lines; what was not done.
