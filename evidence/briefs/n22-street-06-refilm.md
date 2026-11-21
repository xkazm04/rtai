# n22-street brief 06: re-shoot the five-wave film on the dressed street, before/after pairs, frames.json

Lane `street`, worktree `C:\Users\kazda\kiro\gtai-wt\n22-street`, branch `n22-street`. Briefs 01 to 05 are
committed (read `git log --oneline -25` first). Never rename anything from the interface commit.

**Wall-clock hard stop: 05:45 (stop working, write the final message). Commit deadline: 05:40.** Commit each item when
it works. Fix lint and format findings in your own edits and go on. Never amend, never rebase. No `git stash`,
no `git add -A/./-u`, no `commit -a`, no `reset --hard`, no tags, no merges. Stage per path; never stage
`JOURNAL.md`, `REPORT.md` or `evidence/briefs/**`. Before every Godot run:
`export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/street` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
(`--rendering-driver d3d12` for rendering, `--position 0,1440` on any windowed run: never the main display).
One Godot process at a time; free your own by PID.

## Allowlist (any other path: stop and report `NEED <owner lane>: <file> <why>`)
`project/dev/gauntlet/**`, `project/features/gauntlet/**` except `bot/**`, `evidence/street/**`,
`C:\Users\kazda\kiro\gtai-masters\n22\street\`, `project/data/schemas/gauntlet_run.schema.json` and `project/tests/unit/test_gauntlet_*.gd` (item 5 only). Code changes only to fix a defect you see in the film
(one commit each, tests green). Forbidden: everything in brief 05's forbidden list, `tools/**`.

## Items, in order
0. **Does the paint match the collision?** The dressing (c7e8fbe07) draws city props (bus shelter, bench,
   kiosk, barrels, road barriers, parked-car hatches) where solid boxes stand. For each of the six (or eight)
   templates render one still with every solid box (`wall_high`, `cover_high`, `cover_low`) outlined over
   the dressing in a thin ink or white line (a dev-only overlay toggled by a dev flag or the stills script;
   not in the film), `segment_<id>_solids_32.png`, and say per template whether every drawn obstacle has a
   box and every box has a drawn obstacle. A drawn prop with no box (Rivet would walk through it) or a box
   with nothing drawn (an invisible wall, e.g. the underpass cross street that looks open but is walled at the kerb line) is a defect: fix it in the dressing data (paint follows collision;
   collision does not move, results stay byte-identical: prove with seed 7 cmp).
1. **Re-shoot the film** exactly as brief 04 item 3 did (same seed, flags, camera, `evidence/street/film.json`
   procedure): `gauntlet_waves1-3_32.mp4` and `gauntlet_waves4-5_32.mp4`, each 15 to 40 s, never time-lapsed.
   FIRST rename the current two to `gauntlet_waves1-3_before_32.mp4` / `gauntlet_waves4-5_before_32.mp4`
   (they are the undressed befores). Update `film.json` (new commit sha, wave start frames, seconds).
2. **Same-tick before/after stills**: from the old and new films extract one frame each at the same source
   frame (one in wave 2, one on the wave-5 war machine, one on a pick screen) and save them side by side as
   `pair_<what>_32.png` (left before, right after, 1920 wide total is fine). Also re-take
   `fight_cover_64.png` (64 px/m close-up of Rivet striking at a cover prop) on the dressed street; keep the
   old one as `fight_cover_before_64.png`.
3. **Look at every frame yourself** (4 stills per clip with `ffmpeg -ss <t> -i <mp4> -frames:v 1`): Rivet
   visible, enemies visible, HUD readable incl. the health bar fill, cards readable, no body/blood/debris drawn
   over a wall top or in the void beyond it, the camera follows, no teal outside the ghost lock icons. Report
   any defect; fix it only if it is in an allowlisted file and the fix is small, then re-shoot.
4. **frames.json** in the masters folder: 8 to 15 entries, best first, `[{file,title,ppm,before,note}]`
   with `before` set to the before file where one exists. Notes describe what is in the frame (Rivet strikes
   in melee unless he holds a gun: say which). Delete scratch renders frames.json does not reference.
   Commit `evidence/street/film.json` and anything else under `evidence/street/`.

5. **Lane loop's NEED (04:00): `hits` is not comparable with `shots`.** Read how `hits` is counted today
   (`gauntlet_waves.gd` `_hits`). Keep `hits` exactly as it is (rename nothing) and add two optional per-wave
   keys `hits_gun` (hits by rounds Rivet fired: comparable with `shots`) and `hits_melee` (melee/hands/blade
   contacts), each present only when measured; add them and a `description` on `shots`, `hits`, `hits_gun`,
   `hits_melee` to `gauntlet_run.schema.json` (schema id stays `gtai.gauntlet-run/1`). Unit test: a wave with
   one gun hit and one melee hit records 1 and 1. Seed 7 result changes only by the new keys: say so and
   record the new sha. One commit. Do this item right after item 0 (it is small and lane loop batches on it), then the film.

## Final message
Commits, every masters file with one line on what you saw, the defects found, anything undone.
