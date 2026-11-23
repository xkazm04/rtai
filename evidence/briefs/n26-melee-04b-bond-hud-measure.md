# Brief n26-melee-04b-bond-hud-measure: the chip shows the bond; ten seeds; stills (call 2 of 2)

Lane `melee`, branch `n26-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`.
**Hard stop HARDSTOP wall clock. Last commit by COMMITBY.** At the hard stop, write your report and END, even
mid-task. Commit what is green; revert your own unfinished edits with `git checkout -- <path>`; list the rest in
your report. Never stop to ask: at a fork, pick what best serves the owner's words, record a DECISION line, go on.
Fix lint and format findings in your own edit and go on.

**Read first: `evidence/briefs/n26-melee-04-bond.md`** (design, allowlist, forbidden files, repo law, the 12:45
addendum: all of it binds) and `git log --oneline -10`: the previous call landed GhostBond, the offer card and
the bot pick (read its commits). This call does steps 3, 4 and 5 of brief 04.

## This call, in order (commit each when green)
1. Step 4 first (numbers decide the tuning): the gauntlet test player on seeds 1..10, profile average, to wave 15
   or death; per seed the wave each ghost is mastered, bond per wave, transformations used, wave lengths. Target:
   median first mastery between wave 8 and 15. Tune only `per_kill`, `per_stun`, `master_at` (say what you tried).
   Any wave over 180 s is a FAIL to diagnose (addendum). `evidence/n26/bond/mastery.json` + `mastery.md`.
2. Step 3: the bond on each ghost's HUD chip (new node of your own over the chip rects; keys lane files get at
   most 3 lines each, reported as `TOUCH <file>:<line>`, else a `NEED keys` line). Thin teal ring filling to
   master_at, a distinct ready-to-master look at full, a closed ring when mastered. A unit test for the ring's
   fill fraction from the bond. Godot `--import` after new scripts, before the commit.
3. Step 5 stills to `evidence/n26/bond/frames/` (32 px/m tilt 70 and 64 px/m, `--rendering-driver d3d12`,
   windowed `--position 0,1440`): the chip at three fill steps, the offer card at the rest, the card taken, T and
   the mastered transformation in use. Look at each still yourself and say what it shows.
4. If anything moved since the previous call's tape check: scenarios `--only=<touched>`, 60 s replay
   `cbeb734ff9b97c41`, parity. Mutate the ring file `--max=20`.

Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/melee` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. One Godot
at a time; kill only your own PIDs. `node tools/gate/quick.mjs` before each commit. Stage per path; no amend,
rebase, stash, `add -A/./-u`, `commit -a`, `reset --hard`; never push. Root `JOURNAL.md`/`REPORT.md` are not yours.

## Report at the end (short)
Commits, the mastery table (wave per ghost per seed + median first mastery), the numbers chosen and what you
tried, the HUD mount + TOUCH/NEED lines, still paths with one line each, tapes, mutate score, not done.
