# Brief n28-cast-01e: robot gunner A, one rifle when he falls (the game's pickup), re-film

Lane `cast`, branch `n28-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd). Do NOT switch branches.
Owned/forbidden files and repo law as in `evidence/briefs/n28-cast-01-gunner-on.md` (read its "Owned files" and "Repo law").
**Hard stop 19:15 local** (check `date` often). Start your commit by 19:00 at the latest (hook up to 12 min). Never amend/rebase.
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/cast` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Godot only through
`tools/lib/godot.mjs` users (never `Godot_*.exe` directly); one at a time. Fix lint/format findings in your own edit and go on.

## The defect (director, looked at the films you shot)
`gtai-masters/n28/cast/gunner_close_64.mp4` at 18 s and `gunner_fight_32.mp4` at 16 s: every fallen gunner shows **two
rifles**: the rifle drawn in his fall cell (left of the body) AND the game's rifle pickup `GroundRifle`
(`project/features/combat/weapons/art/ground_rifle.gd`, drawn by the views for each `CombatArena.rifle_drops` entry; a squad
foe with `assault-rifle` drops one, `combat_arena.gd` `_drop`). The pickup is gameplay (Rivet picks it up): it stays. So the
**card's drawn rifle must go**: his fall cells draw the body only. The previous report's "one rifle each" was wrong; the
audit film row must say what was seen and fixed.

## Do
1. `tools/art/cast_gunner_pack.py` keeps "the muzzle flash and the dropped rifle as props of the nearest body". For the
   **fall** action only, at both pitches, drop the rifle island (the disconnected component(s) that are not the body) instead
   of attaching it; keep the attack muzzle flash. Re-cut. Only `p70/robot_gunner_fall.png` and `p55/robot_gunner_fall.png`
   may change (check `git status`; every other shipped PNG byte-identical). If the cell/anchor geometry depends on the rifle
   (cell width, centring), keep the body exactly where it was (compare the body's bbox per cell before/after: 0 px shift).
   Look at both new sheets yourself on a grey background: body whole (hands, hoses, feet), no rifle, no stray fragments.
2. `--import` through runGodot (`node -e` with `runGodot(['--headless','--import'])` from `tools/lib/godot.mjs`, or however
   the repo does it; `tools/godot/check.mjs` does NOT reimport art).
3. Re-film: `node tools/film/cast_gunner_films.mjs C:/Users/kazda/kiro/gtai-masters/n28/cast 64 32` (overwrites both clips).
   `ffprobe` both (1920x1080, 60/1, 15-40 s). Extract frames at 16, 17, 18, 19 s of each and LOOK at the fallen gunners:
   exactly one rifle (the pickup) beside each body, nothing drawn on/under the body. Also look at one mid-fight frame.
4. Also measure, from a lossless frame (not the mp4: chroma subsampling invents pink fringes): does the pickup rifle draw any
   red/pink pixels (R > G + 60 and R > B + 40) at 64 px/m? If the film runner cannot write a PNG, extract with
   `ffmpeg ... -pix_fmt rgb24` and say it is from the video. Report the count; do NOT edit `ground_rifle*` (not ours).
5. Audit: correct the gunner film row (what the first films showed, the fix, the new look) and add a line to the fall row.
   Update `frames.json` notes for the two clips. `node tools/gate/quick.mjs`, then commit (tool + two PNGs + .import if changed + audit).
   `node tools/tests/run_unit.mjs --select=test_cast_gunner` green before committing.
If the fix cannot be finished and filmed by 19:00: set `enabled: false` for `robot_gunner` in `cast_cards.json` (and the test
`test_gunner_row_is_on_after_the_n28_audit` back to asserting null, renamed to say off), audit says why, commit that instead.

## Report
Commit sha; per pitch the body bbox shift (must be 0); what each looked-at frame showed; ffprobe lines; the pink count; quick gate line.
