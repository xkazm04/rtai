# n31 ghost 14 - Ohm's drop in real gauntlet play, main | HEAD at the same seed (item 4 Ohm's required first clip)

Builder tag: `g14-ohm-take`. **First commit within 25 minutes; hard stop 50 minutes after launch** (last commit START 15 min before it; the hook takes ~12 min). Report and END.
Worktree (cwd): `C:\Users\kazda\kiro\gtai-wt\n25-yard`, branch `n31-ghost`. Read `AGENTS.md`, `git log --oneline -15`, and the finished Tonnage take as THE recipe: `evidence/n31/ghost/take-drop.md`, `evidence/briefs/n31-ghost-04-drop-take.md` (+ addenda), `project/dev/ghost_n31/ghost_n31_take.gd` (+ `.tscn`, `_closeup.tscn`). Also `evidence/n31/ghost/measure-ohm-play.md` (g13: the dev relaxed bot fit `ghost_n31_bot_spot.gd`, `--fit=relaxed`) and the Ohm beats commits (`git log --grep="ghost 12"`).

## Why
Owner: every item's first clip is real play in the gauntlet with the default wheel controls, before beside after at the same seed. Ohm on HEAD: one press, he stands on the aim point, an 18-tick charge with an amber creep crawling to the 5 m rim, a discharge ring, a scorch that stays. On main: hold to aim with a teal ring marker, release, an instant r3.5 bolt burst.

## Do
1. `ghost_n31_take.gd`: a `--form=<tonnage|ohm|dent|kerf>` flag (default tonnage = unchanged behaviour) that grants and keeps that form the only free ghost (the way it does Tonnage), and a `--fit=relaxed` flag using g13's `GhostN31BotSpot` (the shipped bot never fires Ohm in early waves). Declare both in the scene's `KNOWN`.
2. Find a seed (try 1..10, 3 waves, headless runs of the take scene with `--deploys=<json>`) where HEAD's Ohm drop lands on a cluster of >= 5 in wave 1 or 2 and main's deploy in the same wave hits fewer. Main side = `ba8e470b0` in a temp worktree with this branch's `project/dev/ghost_n31/` copied in (if main lacks a class the dev files need, copy only dev files; never product files). The main side holds/aims via the bot's hold flow (works on main as g08 measured with Dent).
3. Films at 32 px/m, tilt 70 (`--pick-view`), 1920x1080, `--fixed-fps 60 --write-movie`, d3d12, windowed at `--position 0,1440`, through `node tools/dev/run.mjs` (runGodot): main side, HEAD side, side by side 3840x1080 labelled "main ba8e470b0" | "n31 ghost <hash>", 15-40 s (ffprobe it). 64 px/m: a still pair at the discharge and a half-speed HEAD clip of one whole drop (press, charge, discharge, scorch), 12-20 s.
4. Read the frames yourself (extract 4-6 pngs with ffmpeg and Read them): the creep must be visible during the charge, the ring at the discharge, the scorch after. If a beat is missing on screen, say so plainly; do not fix product code (not yours in this call).
5. `evidence/n31/ghost/take-ohm.md` (same layout as take-drop.md: table of filmed deploys main | HEAD press / damage tick, hits / kills, near; files with ffprobe lengths; one honest sentence of what a player feels differently). Masters to `C:\Users\kazda\kiro\gtai-masters\n31\ghost\` with `take-ohm-*` names; ADD entries to the existing `frames.json` there (keep the existing entries; Ohm play take first among the new ones). Commit the dev change + md.

## Rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/ghost` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`. Lane Godot lock `build/n31/godot.lock` (`g14-ohm-take <pid>` per run; delete only yours). Films via runGodot only. No `--reels`.
- Allowlist: `project/dev/ghost_n31/ghost_n31_take*`, `evidence/n31/ghost/**`, `build/n31/**`, masters ghost folder, `tools/debt/baseline.json` via the debt tool. Any other path: STOP and report a NEED.
- Typed GDScript, <= 40 lines/function, files <= 200 lines (split if needed). Fix lint and format findings in your own edit and go on. Stage per path, `git commit -m "..." -- <paths>`; no add -A/./-u, stash, amend, rebase, reset --hard, --no-verify. Commit messages end with a blank line then `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Remove your temp worktree with `git worktree remove` when done.

## Report
Commits, the table, master files with lengths, what you saw in the frames, the player sentence, NEED lines.
