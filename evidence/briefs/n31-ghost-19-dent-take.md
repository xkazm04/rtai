# n31 ghost 19 - Dent's drop in real gauntlet play, main | HEAD at the same seed (item 4 Dent's required first clip)

Builder tag: `g19-dent-take`. **First commit within 25 minutes; hard stop 50 minutes after launch** (last commit START 15 min before it; the hook takes ~12 min). Report and END. Launch time: see the addendum.
Worktree (cwd): `C:\Users\kazda\kiro\gtai-wt\n25-yard`, branch `n31-ghost`. Read `AGENTS.md`, `git log --oneline -20`, and the finished Ohm take as THE recipe: `evidence/briefs/n31-ghost-14-ohm-take.md`, `evidence/n31/ghost/take-ohm.md`, `project/dev/ghost_n31/ghost_n31_take.gd` (+ `.tscn`, `_closeup.tscn`; it already has `--form=dent` and `--fit=relaxed`). Also `evidence/n31/ghost/measure-dent-head.md` and the Dent commits (`git log --grep="ghost 1[5789]"`).

## Why
Owner: every item's first clip is real play in the gauntlet with the default wheel controls, before beside after at the same seed. Dent on HEAD: one press, he comes out of Rivet's side, cocks for 15 ticks while a skid telegraph runs down the lane to the aim point (2.6 m wide), then dives along it and rams everyone in it, leaving a scuff. On main: hold to aim with a teal capsule marker, release, an instant 1.8 m-wide shove.

## Do
1. Find a seed (try 1..10, 3 waves, headless, `--form=dent`, default fit first; `--fit=relaxed` if the shipped bot never fires Dent early) where HEAD's ram lands on >= 3 bodies in wave 1 or 2 and main's deploy in the same wave hits fewer or the same. Main side = `ba8e470b0` in a temp worktree with this branch's `project/dev/ghost_n31/` copied in (copy only dev files; never product files). Project resolution 1920x1080 only in the temp worktrees' `project.godot` (Movie Maker ignores `--resolution`): for HEAD use a second temp worktree at HEAD; never edit this worktree's `project.godot`.
2. Films at 32 px/m, tilt 70 (`--pick-view`), 1920x1080, `--fixed-fps 60 --write-movie`, d3d12, windowed at `--position 0,1440`, through `node tools/dev/run.mjs` (runGodot): main side, HEAD side, side by side 3840x1080 labelled "main ba8e470b0" | "n31 ghost <hash>", 15-40 s (ffprobe it). 64 px/m: a still pair at the ram (R+3) and a half-speed HEAD clip of one whole drop (press, cock + skid, dive, scuff), 12-20 s (g14's close-up stopped at 320 frames = 10.65 s: set the frame count for >= 12 s).
3. Read the frames yourself (extract 4-6 pngs with ffmpeg and Read them): the skid must be visible during the wind-up, the dive at R, the scuff after. If a beat is missing on screen, say so plainly; do not fix product code.
4. `evidence/n31/ghost/take-dent.md` (layout of take-ohm.md: table of filmed deploys main | HEAD press / damage tick, hits / kills, near; files with ffprobe lengths; one honest sentence of what a player feels differently). Masters to `C:\Users\kazda\kiro\gtai-masters\n31\ghost\` with `take-dent-*` names; ADD entries to the existing `frames.json` (keep the existing ones). Commit the md (and any dev change).

## Rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/ghost` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`. Lane Godot lock `build/n31/godot.lock` (`g19-dent-take <pid>` per run, helper: copy `build/n31/g17lock.sh` with your tag; delete only yours; wait for another's). Films via runGodot only. No `--reels`.
- Allowlist: `project/dev/ghost_n31/ghost_n31_take*`, `evidence/n31/ghost/**`, `build/n31/**`, masters ghost folder, `tools/debt/baseline.json` via the debt tool. Any other path: STOP and report a NEED.
- Typed GDScript, <= 40 lines/function, files <= 200 lines. Fix lint and format findings in your own edit and go on. Stage per path, `git commit -m "..." -- <paths>`; no add -A/./-u, stash, amend, rebase, reset --hard, --no-verify. Commit messages end with a blank line then `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Remove your temp worktrees with `git worktree remove` when done; delete only Temp folders you created.

## Report
Commits, the table, master files with lengths, what you saw in the frames, the player sentence, NEED lines.

## Added 02:51 (director) - launch times and neighbours
Launched 02:51. **First commit by 03:16, last commit START by 03:28, hard stop 03:41: report and END.** HEAD has Dent's ground marks (g18b: skid telegraph, wake, scuff; `git log --grep="ghost 18b"`), so film HEAD at its current commit.
- A builder `g18b-dent-marks` may still be finishing (souls files, decisions.md). Never stage its paths; wait for its lock (`build/n31/godot.lock`), never delete it.
- If 03:16 comes with no seed found, commit what you have (the seed table in take-dent.md) and film the best seed you have.
