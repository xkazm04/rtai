# Brief n26-melee-04a-bond-core: the bond, the offer, the unlock (call 1 of 2)

Lane `melee`, branch `n26-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`.
**Hard stop 15:50 wall clock. Last commit by 15:43.** At the hard stop, write your report and END, even
mid-task: the last two calls ran into the 75 min cap without a report, which cost the director an hour of
diff-reading. Commit what is green; revert your own unfinished edits with `git checkout -- <path>`; list the rest
in your report. Never stop to ask: at a fork, pick what best serves the owner's words, record a DECISION line,
go on. Fix lint and format findings in your own edit and go on.

**Read first: `evidence/briefs/n26-melee-04-bond.md`** (the full design, what exists, the allowlist, the forbidden
files, repo law and the 12:45 addendum: all of it binds this call). This call does ONLY its steps 1, 2, 6 and 7.
Steps 3 (HUD chip), 4 (ten-seed measure and tune) and 5 (stills) are the next call: do not start them.

## This call, in order (commit each when green)
1. Step 1 of brief 04: `GhostBond` + per-form unlock + T picks the mastered ghost deployed last + the unit tests
   listed there. Start values `per_kill` 1, `per_stun` 0.5, `master_at` 25, `enabled` true (the owner picked the
   proposal: ships on). With `enabled` false nothing changes anywhere (test it).
2. Step 2 of brief 04: the gauntlet "Master <ghost>" card at the first rest after a form reaches `master_at`
   (DECISION: in place of one drawn card or in addition: say which and why), Loc keys, the test player takes it
   (`bot_pick.gd`), result wave rows carry optional `bond{}` (schema). One integration-level test that a run's
   card stream offers it once the bond is full and that taking it flips that form's unlock.
   Also make one short probe so the next call can measure fast: a gauntlet test-player run on one seed (profile
   average) to wave 12 or death, headless, printing per wave the bond per form and any mastery; quote the
   command and its numbers in your report (this is the smoke check, not the ten-seed measure).
3. Stall guard (brief 04 addendum): with a mastered form the test player may now transform. In that one probe run,
   any wave over 180 s is a FAIL: find the cause before going on (see the addendum for what to do per cause).
4. Step 6 (tape identity), touched scenarios first with `--only=<names>`, then the full suite once; shipped
   tapes, 60 s replay `cbeb734ff9b97c41`, parity 1200 exact. Quest 1: print the bond values at the end of each
   quest 1 tape (they must stay below `master_at`, so no story offer ever appears there).
5. Step 7 mutate: `node tools/mutate/mutate.mjs --file=project/features/souls/ghost_bond.gd --max=20`; quote
   killed/(killed+survived).

Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/melee` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. One Godot
at a time; kill only your own PIDs. `node tools/gate/quick.mjs` before each commit. Stage per path; no amend,
rebase, stash, `add -A/./-u`, `commit -a`, `reset --hard`; never push. Root `JOURNAL.md`/`REPORT.md` are not yours.

## Report at the end (short)
Commits (sha + subject), the API of GhostBond, the offer DECISION, the probe command + per-wave bond numbers,
any TOUCH lines, any NEED lines, tape list (old -> new digests, or "identical"), mutate score, not done.
