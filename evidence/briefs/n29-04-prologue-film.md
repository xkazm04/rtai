# Brief n29-04 `prologue-film`: the whole prologue on the new default yard, and the two missing 64 px/m stills (lane yard, run n29)

HARD STOP: {STOP} local (stop work, write the report, END). LAST COMMIT started by {LAST}. Check `date` often. You are an in-session builder: you die when the director's session ends, so the hard stop is absolute.


## Before anything (every shell that runs Godot)
```
export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
```
cwd `C:/Users/kazda/kiro/gtai-wt/n25-yard` (branch `n29-yard`). One Godot process at a time: first check that no gate is running (`build/gate-run/gate-*.out` has its final verdict line, and no node `tools/gate/run.mjs` process is alive). If one is, wait for it. Windowed runs use `--position 0,1440`. Launch Godot only through repo tools (`tools/dev/run.mjs`, the film tools). 16 GB memory cap: `mem-budget: waiting` = wait. Never run `builder.mjs`, `astra.mjs` or `codex`. Never stage `hs_err_pid*.log`, `JOURNAL.md`, `REPORT.md` or `evidence/briefs/**`.

## What to make, in this order
1. **The whole prologue from the menu's Start into quest 1's first line, on the default yard** (`arched_line` as committed at HEAD: floor i55, tall hall facade, belt spans if they have landed; say which commits are in). n27 did the same job: `docs/day/2026-11-24/n27-yard/REPORT.md` row "The whole prologue on the new yard" (`project/dev/prologue/newgame_pilot.gd --bot --seed=7`; how it was filmed: `build/films26/films.sh`, section `menu`, if it still exists; else read `newgame_pilot.gd`'s header). Output `C:/Users/kazda/kiro/gtai-masters/n29/yard/prologue_menu_to_quest1.mp4`: h264 `yuv420p` (re-encode: the MJPEG capture comes out `yuvj420p`), 1920x1080, 60 fps. It is long (n27: 189 s), and that is accepted for this one master. Quote ffprobe. Report the handover tick and the first-line tick (n27: 10792 / 10793), and say whether they moved. If they moved, that is a finding: report it, do not fix it. LOOK at 5 frames: the menu, the yard fight on the arched belt, Mulroney's card, Don Fax, the city with quest 1's first line. Write one line each.
   Known trap: `tools/art/prologue_yard_film.mjs --movie` refuses at the project's 1280x800 size. The films call before you filmed through `build/prologue-film` (an `override.cfg` with 1920x1080); `build/films28/run.sh` shows how.
2. `C:/Users/kazda/kiro/gtai-masters/n29/yard/floor_pass4_64ppm.png`: 64 px/m, the arched_line floor between pools with Rivet standing on it (`tools/art/prologue_yard_film.mjs --still=`, read its header). Copy it to `evidence/yard28/`.
3. `belt_pass4_64ppm.png`: 64 px/m, one arched section with its hanging appliances and Rivet beside it, in masters and in `evidence/yard28/`.
4. Add the three to `frames.json` in the masters folder (keep 8 to 15 entries, best first). The prologue film goes right after the mid clip. Drop the weakest entry if you pass 15.

Delete scratch renders and `.avi` files that `frames.json` does not reference. Commit only the `evidence/yard28/` stills, with `git commit -- <paths>`. `node tools/gate/quick.mjs` first. The masters folder is outside the repo.

## Owned files (allowlist). Any other path: stop and report a NEED.
`evidence/yard29/**`, `build/**`, `C:/Users/kazda/kiro/gtai-masters/n29/yard/**`.

## Repo law
Stage per path; `git commit -- <paths>`; no `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push; never `--no-verify`.

## Report (final message, then END)
Commit sha; each master with its ffprobe line; the two ticks; one line per frame you looked at; what was not done.

## n29 additions (director)
- Item 2 and 3 stills go to `evidence/yard29/` (not yard28). Commit only `evidence/yard29/**` stills.
- 5. **Plate beside game at three cameras, 32 and 64 px/m:** gate, mid yard, hall front, same cameras as `evidence/yard28/plate_vs_game_{gate,mid,front}_{32,64}ppm.png` (the n28 stills tool: `tools/art/prologue_yard_stills.mjs` / `project/dev/prologue_yard/yard_dusk_capture.gd`, and `evidence/yard28/compose.py` for the hstack) to `evidence/yard29/plate_vs_game_{gate,mid,front}_{32,64}ppm.png`; copy the three 32 px/m ones to masters. LOOK at each and write one honest line per camera in `evidence/yard29/plate_judgement.md`: how far from the plate it still is and the biggest gap.
- Masters: append to `frames.json` (do not drop the other items' entries unless past 15).
